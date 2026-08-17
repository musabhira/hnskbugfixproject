import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PaymentTermModel {
  final String id;
  final String name;
  final int days;
  final int discountDays;
  final double discountPercent;

  PaymentTermModel({
    required this.id,
    required this.name,
    required this.days,
    required this.discountDays,
    required this.discountPercent,
  });

  factory PaymentTermModel.fromJson(Map<String, dynamic> json) {
    return PaymentTermModel(
      id: json['id']?.toString() ?? json['gt_payment_term_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      days: json['days'] is int ? json['days'] : int.tryParse(json['days']?.toString() ?? '0') ?? 0,
      discountDays: json['discount_days'] is int ? json['discount_days'] : int.tryParse(json['discount_days']?.toString() ?? '0') ?? 0,
      discountPercent: json['discount_percent'] is num ? (json['discount_percent'] as num).toDouble() : double.tryParse(json['discount_percent']?.toString() ?? '0') ?? 0.0,
    );
  }
}

final paymentTermsProvider = FutureProvider<List<PaymentTermModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_payment_terms')
      .select('*')
      .applyTenantFilter('gt_payment_terms')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => PaymentTermModel.fromJson(json)).toList();
});
