import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class CategoryModel {
  final String id;
  final String categoryName;
  final String categoryCode;
  final String description;
  final String status;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.categoryCode,
    required this.description,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      categoryCode: json['category_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_categories')
      .select('*')
      .applyTenantFilter('pos_categories')
      .order('category_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => CategoryModel.fromJson(json)).toList();
});
