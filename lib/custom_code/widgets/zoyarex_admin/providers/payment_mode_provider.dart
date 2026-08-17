import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PaymentModeModel {
  final String id;
  final String name;
  final String code;
  final String type;
  final String description;
  final String status;

  PaymentModeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.description,
    required this.status,
  });

  factory PaymentModeModel.fromJson(Map<String, dynamic> json) {
    return PaymentModeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

final paymentModesProvider = FutureProvider<List<PaymentModeModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('payment_modes')
        .select('*')
      .applyTenantFilter('payment_modes')
        .neq('status', 'Deleted')
        .order('name', ascending: true);

    final data = response as List<dynamic>;
    return data.map((json) => PaymentModeModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
