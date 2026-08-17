import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class DiscountModel {
  final String id;
  final String name;
  final String type;
  final double value;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isActive,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id']?.toString() ?? json['discount_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['discount_name']?.toString() ?? 'Unnamed',
      type: json['type']?.toString() ?? json['discount_type']?.toString() ?? 'percentage',
      value: json['value'] is num ? (json['value'] as num).toDouble() : double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == true || json['status'] == 'active',
    );
  }
}

final discountProvider = FutureProvider<List<DiscountModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('discounts') // Standardizing on discounts
        .select('*')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => DiscountModel.fromJson(json)).toList();
  } catch (e) {
    try {
      final response = await ZoyarexSupabase.client
          .from('discount')
          .select('*')
      .applyTenantFilter('discount')
          .order('name');
      final data = response as List<dynamic>;
      return data.map((json) => DiscountModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
