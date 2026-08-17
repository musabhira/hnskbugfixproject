import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle;
  final bool isActive;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.isActive,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id']?.toString() ?? json['plan_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['plan_name']?.toString() ?? 'Unnamed Plan',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      billingCycle: json['billing_cycle']?.toString() ?? 'monthly',
      isActive: json['is_active'] == true || json['status'] == 'active',
    );
  }
}

final planProvider = FutureProvider<List<PlanModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('plans')
        .select('*')
      .applyTenantFilter('plans')
        .order('price');
    final data = response as List<dynamic>;
    return data.map((json) => PlanModel.fromJson(json)).toList();
  } catch (e) {
    try {
      final response = await ZoyarexSupabase.client
          .from('subscription_plans')
          .select('*')
      .applyTenantFilter('subscription_plans')
          .order('price');
      final data = response as List<dynamic>;
      return data.map((json) => PlanModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
