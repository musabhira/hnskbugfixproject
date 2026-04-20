import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/supabase/supabase.dart';

class GooglePayService {
  static final GooglePayService _instance = GooglePayService._internal();
  factory GooglePayService() => _instance;
  GooglePayService._internal();

  final supabase = SupaFlow.client;

  // DIRECT UPI INTENT (The "Amazon-style" redirect)
  Future<String?> startDirectPayment({
    required String upiId,
    required String receiverName,
    required String amount,
    required String courseId,
    String? couponCode,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';

    // 1. Create a "Pending" transaction in Supabase
    final transactionInfo = await supabase.from('transactions').insert({
      'user_id': userId,
      'course_id': courseId,
      'amount': double.parse(amount),
      'status': 'pending',
      'applied_coupon': couponCode,
    }).select().single();

    final String transactionId = transactionInfo['id'];

    // 2. Construct the UPI URL
    // We add the transactionId to the 'tr' (Transaction Ref) or 'tn' (Note) for tracking
    final String url = 'upi://pay?'
      'pa=$upiId'
      '&pn=${Uri.encodeComponent(receiverName)}'
      '&am=$amount'
      '&cu=INR'
      '&tr=$transactionId'
      '&tn=${Uri.encodeComponent("Course Payment: $transactionId")}';

    final Uri uri = Uri.parse(url);

    try {
      // 3. Launch the External App (Google Pay / PhonePe)
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
        return transactionId; // Return ID so the UI can start polling/listening
      } else {
        throw 'No UPI payment app found. Please install Google Pay.';
      }
    } catch (e) {
      debugPrint("Error launching UPI intent: $e");
      rethrow;
    }
  }

  // Poll for status (Or use a Realtime subscription)
  Future<bool> checkPaymentStatus(String transactionId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select('status')
          .eq('id', transactionId)
          .single();
      
      return response['status'] == 'completed';
    } catch (e) {
      return false;
    }
  }

  // Subscribe to real-time status updates 
  // (Faster than polling - good for the automated feel)
  Stream<String> watchTransactionStatus(String transactionId) {
    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('id', transactionId)
        .map((event) => event.isEmpty ? 'pending' : event.first['status'] as String);
  }
}
