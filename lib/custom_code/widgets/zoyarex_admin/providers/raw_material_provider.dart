import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ProductRawMaterialModel {
  final String id;
  final String productId;
  final String productName;
  final List<dynamic> rawMaterials;

  ProductRawMaterialModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.rawMaterials,
  });

  factory ProductRawMaterialModel.fromJson(Map<String, dynamic> json) {
    return ProductRawMaterialModel(
      id: json['id']?.toString() ?? '',
      productId: json['item_code']?.toString() ?? '',
      productName: json['item_name']?.toString() ?? 'Unknown Material',
      rawMaterials: [], // Mocking mapping for now
    );
  }
}

final rawMaterialsProvider = FutureProvider<List<ProductRawMaterialModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('warehouse_items')
      .select('*')
      .applyTenantFilter('warehouse_items')
      .order('item_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => ProductRawMaterialModel.fromJson(json)).toList();
});
