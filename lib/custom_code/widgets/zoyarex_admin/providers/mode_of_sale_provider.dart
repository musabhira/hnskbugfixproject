import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ModeOfSaleModel {
  final String id;
  final String name;
  final String? type;
  final bool isActive;

  ModeOfSaleModel({
    required this.id,
    required this.name,
    this.type,
    required this.isActive,
  });

  factory ModeOfSaleModel.fromJson(Map<String, dynamic> json) {
    return ModeOfSaleModel(
      id: json['id']?.toString() ?? json['mode_of_sale_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['mode_name']?.toString() ?? 'Unnamed',
      type: json['type']?.toString(),
      isActive: json['is_active'] ?? json['active'] ?? true,
    );
  }
}

final modeOfSaleProvider = FutureProvider<List<ModeOfSaleModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('mode_of_sales')
        .select('*')
      .applyTenantFilter('mode_of_sales')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => ModeOfSaleModel.fromJson(json)).toList();
  } catch (e) {
    try {
      final response = await ZoyarexSupabase.client
          .from('modes_of_sale')
          .select('*')
      .applyTenantFilter('modes_of_sale')
          .order('name');
      final data = response as List<dynamic>;
      return data.map((json) => ModeOfSaleModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
