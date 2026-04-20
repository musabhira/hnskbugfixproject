import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/backend/supabase/supabase.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  List<ProductDetails> _products = [];
  bool _available = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _available;

  final StreamController<PurchaseDetails> _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('IAP Error: $error');
    });
  }

  Future<void> fetchProducts(List<String> productIds) async {
    if (!_available) return;
    
    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds.toSet());
    if (response.error == null) {
      _products = response.productDetails;
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if (Platform.isIOS) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
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
    // In a real app, you should verify the receipt on your backend.
    // For now, we will trust the client and update Supabase.
    try {
      final supabase = SupaFlow.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Find the course matching this product ID
      final response = await supabase
          .from('courses')
          .select('id')
          .or('product_id_android.eq.${purchase.productID},product_id_ios.eq.${purchase.productID}')
          .maybeSingle();

      if (response != null) {
        final courseId = response['id'];
        
        await supabase.from('user_course_access').upsert({
          'user_id': userId,
          'course_id': courseId,
          'has_paid': true,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,course_id');
        
        debugPrint('Access granted for course: $courseId');
      }
    } catch (e) {
      debugPrint('Error granting access: $e');
    }
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
