import '/backend/supabase/supabase.dart';
import 'package:flutter/foundation.dart';

class CouponService {
  static final supabase = SupaFlow.client;

  /// Validates a promo code and returns the discount amount and type if valid.
  static Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    try {
      final response = await supabase
          .from('promo_codes')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final expiryDateStr = response['expiry_date'];
      if (expiryDateStr != null) {
        final expiryDate = DateTime.parse(expiryDateStr);
        if (expiryDate.isBefore(DateTime.now())) {
          return null; // Expired
        }
      }

      final maxUses = response['max_uses'] ?? 0;
      final currentUses = response['current_uses'] ?? 0;
      if (maxUses > 0 && currentUses >= maxUses) {
        return null; // Max uses reached
      }

      return {
        'id': response['id'],
        'code': response['code'],
        'discount_amount': response['discount_amount'],
        'discount_type': response['discount_type'],
      };
    } catch (e) {
      debugPrint('Error validating promo code: $e');
      return null;
    }
  }

  /// Increments the usage count of a promo code.
  static Future<void> incrementUsage(String codeId) async {
    try {
      // Get current uses first
      final response = await supabase
          .from('promo_codes')
          .select('current_uses')
          .eq('id', codeId)
          .single();
      
      final currentUses = response['current_uses'] as int;

      await supabase
          .from('promo_codes')
          .update({'current_uses': currentUses + 1})
          .eq('id', codeId);
    } catch (e) {
      debugPrint('Error incrementing promo code usage: $e');
    }
  }
}
