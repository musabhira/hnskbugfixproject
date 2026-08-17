import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ProductModel {
  final String id;
  final String productName;
  final String categoryName;
  final double defaultPrice;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.productName,
    required this.categoryName,
    required this.defaultPrice,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? 'Uncategorized',
      defaultPrice: (json['cost'] ?? 0).toDouble(),
      isActive: json['status'] == 'active' || json['status'] == 'Enabled',
    );
  }
}

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_products')
      .select('*, pos_categories(category_name)')
      .applyTenantFilter('pos_products')
      .limit(50); // Using limit for basic listing

  final data = response as List<dynamic>;
  return data.map((json) {
    // Flatten category name if join succeeded
    final catData = json['pos_categories'];
    if (catData != null && catData is Map) {
      json['category_name'] = catData['category_name'];
    }
    return ProductModel.fromJson(json);
  }).toList();
});
