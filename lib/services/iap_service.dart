import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  static const String vipMonthlyProductId = 'poketmates_vip_monthly';
  static const String vipYearlyProductId = 'poketmates_vip_yearly';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  List<ProductDetails> _products = [];
  bool _available = false;
  bool _isVipActive = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _available;
  bool get isVipActive => _isVipActive;

  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  Future<void> initialize() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        debugPrint('IAPService: Store not available on this platform/device');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _isVipActive = prefs.getBool('is_vip') ?? false;

      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _handlePurchaseUpdates(purchaseDetailsList);
        },
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint('IAPService Error: $error');
        },
      );

      // Pre-fetch default VIP subscriptions
      await fetchProducts([vipMonthlyProductId, vipYearlyProductId]);
    } catch (e) {
      debugPrint('IAPService initialize exception: $e');
    }
  }

  Future<void> fetchProducts(List<String> productIds) async {
    if (!_available) return;
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds.toSet());
      if (response.error == null) {
        _products = response.productDetails;
        debugPrint('IAPService: Loaded ${_products.length} products');
      } else {
        debugPrint('IAPService query error: ${response.error}');
      }
    } catch (e) {
      debugPrint('IAPService fetchProducts exception: $e');
    }
  }

  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Initiates subscription purchase through Google Play or Apple App Store
  Future<bool> buyVipSubscription({bool isYearly = false}) async {
    final targetId = isYearly ? vipYearlyProductId : vipMonthlyProductId;
    
    if (!_available) {
      debugPrint('IAPService: Store billing not available');
      return false;
    }

    // Refresh products if not cached
    if (_products.isEmpty) {
      await fetchProducts([vipMonthlyProductId, vipYearlyProductId]);
    }

    final product = getProduct(targetId);
    if (product == null) {
      debugPrint('IAPService: Product $targetId not found in store catalog yet');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Initiates purchase for a specific ProductDetails object
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_available) {
      debugPrint('IAPService: Store billing not available');
      return false;
    }
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restores previous purchases (Mandatory for Apple App Store guidelines)
  Future<void> restorePurchases() async {
    if (!_available) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAPService restorePurchases error: $e');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('IAPService: Purchase pending for ${purchaseDetails.productID}');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('IAPService: Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndGrantAccess(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
        
        _purchaseController.add(purchaseDetails);
      }
    }
  }

  Future<void> _verifyAndGrantAccess(PurchaseDetails purchase) async {
    try {
      final isVipProduct = purchase.productID == vipMonthlyProductId ||
          purchase.productID == vipYearlyProductId;

      if (isVipProduct) {
        // 1. Update Local Preferences immediately
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('handskill_plan', 'pro');
        await prefs.setBool('is_vip', true);
        await prefs.setBool('is_ad_free', true);
        await prefs.setString('vip_product_id', purchase.productID);
        await prefs.setString('vip_purchased_at', DateTime.now().toIso8601String());
        _isVipActive = true;

        // 2. Sync to Supabase user profile & entitlements
        final supabase = SupaFlow.client;
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await supabase.from('profile').update({
            'is_vip': true,
            'subscription_tier': 'vip_gold',
            'subscription_status': 'active',
            'vip_product_id': purchase.productID,
            'verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);

          // Record transaction in user_subscriptions table if exists
          try {
            await supabase.from('user_subscriptions').upsert({
              'user_id': userId,
              'plan': purchase.productID == vipYearlyProductId ? 'annual' : 'monthly',
              'status': 'active',
              'store': Platform.isIOS ? 'apple_app_store' : 'google_play',
              'transaction_id': purchase.purchaseID ?? 'sub_${DateTime.now().millisecondsSinceEpoch}',
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'user_id');
          } catch (_) {}
        }

        debugPrint('IAPService: VIP Access successfully granted for ${purchase.productID} ✨');
      }
    } catch (e) {
      debugPrint('IAPService _verifyAndGrantAccess error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
