import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PriceListModel {
  final String id;
  final String name;
  final bool isActive;

  PriceListModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
      id: json['id']?.toString() ?? json['price_list_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['price_list_name']?.toString() ?? 'Unnamed',
      isActive: json['is_active'] ?? json['active'] ?? true,
    );
  }
}

final priceListProvider = FutureProvider<List<PriceListModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('price_lists')
        .select('*')
      .applyTenantFilter('price_lists')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => PriceListModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
