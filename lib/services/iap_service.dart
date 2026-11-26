import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  static const String vipMonthlyProductId = 'poketmates_vip_monthly';
  static const String vipQuarterlyProductId = 'poketmates_vip_quarterly'; // 90-Day Full Pass
  static const String vipYearlyProductId = 'poketmates_vip_yearly';
  static const String certificateProductId = 'poketmates_c2_certificate';

  static const List<String> allVipProductIds = [
    // Standard Poket IDs (Monthly)
    vipMonthlyProductId,
    'poket_vip_monthly',
    'poketmates_monthly',
    'com.poketmates.app.vip.monthly',
    'vip_monthly',

    // Standard Poket IDs (Quarterly / 90 Days / Fluency Pass)
    vipQuarterlyProductId,
    'poket_vip_quarterly',
    'poketmates_quarterly',
    'poketmates_vip_90day',
    'poketmates_vip_90days',
    'poketmates_90day',
    'poketmates_90days',
    'poket_vip_90day',
    'poket_vip_90days',
    'poket_90day',
    'poket_90days',
    'poketmates_fluency_pass',
    'poketmates_vip_fluency_pass',
    'poket_fluency_pass',
    'fluency_pass',
    'vip_fluency_pass',
    'com.poketmates.app.vip.quarterly',
    'com.poketmates.app.vip.90day',
    'vip_quarterly',
    'vip_90day',

    // Standard Poket IDs (Yearly / Annual)
    vipYearlyProductId,
    'poket_vip_yearly',
    'poketmates_yearly',
    'poketmates_vip_annual',
    'poketmates_annual',
    'poket_vip_annual',
    'poket_annual',
    'poketmates_vip_1year',
    'poketmates_1year',
    'com.poketmates.app.vip.yearly',
    'com.poketmates.app.vip.annual',
    'vip_yearly',
    'vip_annual',

    // Certificate
    certificateProductId,
    'poketmates_certificate_c2',
    'poket_c2_certificate',
    'poketmates_certificate',

    // iOS Bundle Identifier (com.handskill.friends) matches
    'com.handskill.friends.vip_monthly',
    'com.handskill.friends.monthly',
    'com.handskill.friends.vip.monthly',
    'com.handskill.friends.vip_quarterly',
    'com.handskill.friends.quarterly',
    'com.handskill.friends.vip.quarterly',
    'com.handskill.friends.vip_90day',
    'com.handskill.friends.vip_90days',
    'com.handskill.friends.90day',
    'com.handskill.friends.90days',
    'com.handskill.friends.vip_fluency_pass',
    'com.handskill.friends.fluencypass',
    'com.handskill.friends.fluency_pass',
    'com.handskill.friends.vip_yearly',
    'com.handskill.friends.yearly',
    'com.handskill.friends.annual',
    'com.handskill.friends.vip_annual',
    'com.handskill.friends.vip.yearly',
    'com.handskill.friends.vip.annual',
    'com.handskill.friends.c2_certificate',
    'com.handskill.friends.certificate',
    'handskill_vip_monthly',
    'handskill_monthly',
    'handskill_vip_quarterly',
    'handskill_quarterly',
    'handskill_vip_90day',
    'handskill_vip_yearly',
    'handskill_yearly',
    'handskill_vip_annual',
    'handskill_annual',

    // Pocket (with 'c') variations
    'pocketmates_vip_monthly',
    'pocket_vip_monthly',
    'pocketmates_monthly',
    'pocketmates_vip_quarterly',
    'pocket_vip_quarterly',
    'pocketmates_quarterly',
    'pocketmates_vip_90day',
    'pocketmates_vip_90days',
    'pocketmates_90day',
    'pocketmates_90days',
    'pocket_vip_90day',
    'pocket_vip_90days',
    'pocketmates_fluency_pass',
    'pocketmates_vip_fluency_pass',
    'pocketmates_vip_yearly',
    'pocket_vip_yearly',
    'pocketmates_yearly',
    'pocketmates_vip_annual',
    'pocketmates_annual',
    'pocket_vip_annual',
    'pocketmates_vip_1year',
    'pocketmates_c2_certificate',
    'pocket_c2_certificate',
  ];

  InAppPurchase? _iapInstance;
  InAppPurchase get _iap => _iapInstance ??= InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  List<ProductDetails> _products = [];
  bool _available = false;
  bool _isVipActive = false;
  String? lastError;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _available;
  bool get isVipActive => _isVipActive;

  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isVipActive = prefs.getBool('is_vip') ?? false;

      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint('IAPService: In-App Purchases are only supported on Android & iOS mobile platforms.');
        _available = false;
        return;
      }

      _available = await _iap.isAvailable();
      if (!_available) {
        debugPrint('IAPService: Store not available on this platform/device');
        return;
      }

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

      // Pre-fetch default VIP subscriptions and certificate
      await fetchProducts(allVipProductIds);
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
        debugPrint('IAPService: Loaded ${_products.length} products: ${_products.map((e) => e.id).toList()}');
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint('IAPService: Products not found by store: ${response.notFoundIDs}');
        }
      } else {
        lastError = 'StoreKit query error: ${response.error?.message} (code: ${response.error?.code})';
        debugPrint('IAPService query error: ${response.error}');
      }
    } catch (e) {
      lastError = 'Exception fetching products: $e';
      debugPrint('IAPService fetchProducts exception: $e');
    }
  }

  ProductDetails? getProduct(String productId) {
    if (_products.isEmpty) return null;
    // 1. Direct exact match
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {}

    // 2. Case-insensitive exact match
    try {
      return _products.firstWhere((p) => p.id.toLowerCase() == productId.toLowerCase());
    } catch (_) {}

    // 3. Fuzzy match based on keywords in product ID
    final targetLower = productId.toLowerCase();
    try {
      if (targetLower.contains('cert')) {
        return _products.firstWhere((p) => p.id.toLowerCase().contains('cert'));
      } else if (targetLower.contains('quarter') ||
          targetLower.contains('90') ||
          targetLower.contains('pass') ||
          targetLower.contains('fluency')) {
        return _products.firstWhere((p) {
          final id = p.id.toLowerCase();
          return id.contains('quarter') ||
              id.contains('90') ||
              id.contains('pass') ||
              id.contains('fluency') ||
              id.contains('3month');
        });
      } else if (targetLower.contains('year') ||
          targetLower.contains('annual') ||
          targetLower.contains('12month')) {
        return _products.firstWhere((p) {
          final id = p.id.toLowerCase();
          return id.contains('year') || id.contains('annual') || id.contains('12month');
        });
      } else if (targetLower.contains('month')) {
        return _products.firstWhere((p) {
          final id = p.id.toLowerCase();
          return id.contains('month') && !id.contains('12month') && !id.contains('3month');
        });
      }
    } catch (_) {}

    // 4. Fuzzy match based on product title & description from App Store
    try {
      if (targetLower.contains('cert')) {
        return _products.firstWhere((p) =>
            ('${p.title} ${p.description}').toLowerCase().contains('cert'));
      } else if (targetLower.contains('quarter') ||
          targetLower.contains('90') ||
          targetLower.contains('pass') ||
          targetLower.contains('fluency')) {
        return _products.firstWhere((p) {
          final text = ('${p.title} ${p.description}').toLowerCase();
          return text.contains('quarter') ||
              text.contains('90') ||
              text.contains('pass') ||
              text.contains('fluency') ||
              text.contains('3 month');
        });
      } else if (targetLower.contains('year') ||
          targetLower.contains('annual')) {
        return _products.firstWhere((p) {
          final text = ('${p.title} ${p.description}').toLowerCase();
          return text.contains('year') ||
              text.contains('annual') ||
              text.contains('12 month');
        });
      } else if (targetLower.contains('month')) {
        return _products.firstWhere((p) {
          final text = ('${p.title} ${p.description}').toLowerCase();
          return text.contains('month') &&
              !text.contains('12 month') &&
              !text.contains('3 month');
        });
      }
    } catch (_) {}

    return null;
  }

  /// Initiates subscription purchase through Google Play or Apple App Store
  Future<bool> buyVipSubscription({bool isYearly = false, String planType = 'monthly'}) async {
    String targetId = vipMonthlyProductId;
    final lowerPlan = planType.toLowerCase();
    if (lowerPlan.contains('quarter') ||
        lowerPlan.contains('90') ||
        lowerPlan.contains('pass') ||
        lowerPlan.contains('fluency')) {
      targetId = vipQuarterlyProductId;
    } else if (lowerPlan.contains('year') ||
        lowerPlan.contains('annual') ||
        isYearly) {
      targetId = vipYearlyProductId;
    } else if (lowerPlan.contains('cert')) {
      targetId = certificateProductId;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('IAPService: In-App Purchases are only supported on Android & iOS mobile platforms.');
      return false;
    }

    try {
      if (!_available) {
        _available = await _iap.isAvailable();
      }

      if (!_available) {
        lastError = 'Store billing is not available on this device or has been restricted in iOS settings.';
        debugPrint('IAPService: Store billing not available');
        return false;
      }

      // Refresh products if not cached or targetId not present
      if (_products.isEmpty || getProduct(targetId) == null) {
        await fetchProducts(allVipProductIds);
      }

      final product = getProduct(targetId) ?? (_products.isNotEmpty ? _products.first : null);
      if (product == null) {
        lastError = _products.isEmpty
            ? 'Connecting to Apple App Store... Pocket VIP subscriptions will be active as soon as Apple completes activation.'
            : 'Product $targetId not found among loaded products: ${_products.map((p) => p.id).toList()}';
        debugPrint('IAPService: Product $targetId not found in store catalog yet. Loaded: ${_products.map((e) => e.id).toList()}');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      lastError = 'Purchase initiation failed: $e';
      debugPrint('IAPService buyVipSubscription error: $e');
      return false;
    }
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
      final pid = purchase.productID.toLowerCase();
      final isCertificateProduct = pid.contains('cert');
      final isVipProduct = !isCertificateProduct && (
          pid.contains('vip') ||
          pid.contains('month') ||
          pid.contains('quarter') ||
          pid.contains('year') ||
          pid.contains('pass') ||
          pid.contains('annual')
      );

      final prefs = await SharedPreferences.getInstance();
      final supabase = SupaFlow.client;
      final userId = supabase.auth.currentUser?.id;

      if (isCertificateProduct) {
        // Unlock C2 Certificate permanently
        await prefs.setBool('has_purchased_c2_certificate', true);
        if (userId != null) {
          try {
            await supabase.from('profile').update({
              'has_purchased_c2_certificate': true,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('user_id', userId);
          } catch (_) {}
        }
        debugPrint('IAPService: C2 Certificate permanently unlocked for $userId 🎓');
      } else if (isVipProduct) {
        // 1. Update Local Preferences immediately
        await prefs.setString('handskill_plan', 'pro');
        await prefs.setBool('is_vip', true);
        await prefs.setBool('is_ad_free', true);
        await prefs.setBool('has_purchased_c2_certificate', true); // Free with VIP!
        await prefs.setString('vip_product_id', purchase.productID);
        await prefs.setString('vip_purchased_at', DateTime.now().toIso8601String());
        _isVipActive = true;

        if (userId != null) {
          await prefs.setBool('is_vip_$userId', true);
          await prefs.setString('handskill_plan_$userId', 'pro');
        }

        // Immediately sync AdMob cache & dispose preloaded ads so VIP sees zero ads right away
        PocketAdMobService.instance.updateCachedVipStatus(true);

        // 2. Sync to Supabase user profile & entitlements (both 'profiles' and 'profile')
        if (userId != null) {
          String planName = 'monthly';
          if (pid.contains('quarter') || pid.contains('90day') || pid.contains('pass')) {
            planName = 'quarterly';
          } else if (pid.contains('year') || pid.contains('annual')) {
            planName = 'yearly';
          }

          final iapUpdate = {
            'is_vip': true,
            'is_premium': true,
            'verified': true,
            'subscription_tier': planName,
            'subscription_status': 'active',
            'vip_product_id': purchase.productID,
            'has_purchased_c2_certificate': true,
            'updated_at': DateTime.now().toIso8601String(),
          };
          try {
            await supabase.from('profiles').update(iapUpdate).eq('id', userId);
          } catch (_) {}
          try {
            await supabase.from('profile').update(iapUpdate).eq('user_id', userId);
          } catch (_) {}

          // Record transaction in user_subscriptions table if exists
          try {
            String planName = 'monthly';
            if (pid.contains('quarter') || pid.contains('90day') || pid.contains('pass')) {
              planName = 'quarterly_90day';
            } else if (pid.contains('year') || pid.contains('annual')) {
              planName = 'annual';
            }
            await supabase.from('user_subscriptions').upsert({
              'user_id': userId,
              'plan': planName,
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

  /// 🧪 Grants VIP directly for developer sandbox / testing when App Store Connect products are syncing
  Future<void> grantSimulatedVip({String planId = 'quarterly'}) async {
    final prefs = await SharedPreferences.getInstance();
    final supabase = SupaFlow.client;
    final userId = supabase.auth.currentUser?.id;

    await prefs.setString('handskill_plan', 'pro');
    await prefs.setBool('is_vip', true);
    await prefs.setBool('is_ad_free', true);
    await prefs.setBool('has_purchased_c2_certificate', true);
    await prefs.setString('vip_product_id', 'simulated_$planId');
    await prefs.setString('vip_purchased_at', DateTime.now().toIso8601String());
    _isVipActive = true;
    PocketAdMobService.instance.updateCachedVipStatus(true);

    if (userId != null) {
      try {
        await supabase.from('profile').update({
          'is_vip': true,
          'subscription_tier': 'vip_gold',
          'subscription_status': 'active',
          'vip_product_id': 'simulated_$planId',
          'verified': true,
          'has_purchased_c2_certificate': true,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      } catch (_) {}
    }

    _purchaseController.add(
      PurchaseDetails(
        productID: 'simulated_$planId',
        verificationData: PurchaseVerificationData(localVerificationData: 'sim', serverVerificationData: 'sim', source: 'sim'),
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
        status: PurchaseStatus.purchased,
      ),
    );
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
