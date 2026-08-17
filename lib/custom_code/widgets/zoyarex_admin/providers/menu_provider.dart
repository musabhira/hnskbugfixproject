import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class MenuModel {
  final String id;
  final String menuName;
  final String menuCode;
  final String description;
  final String categoryId;
  final String categoryName;
  final String status;

  MenuModel({
    required this.id,
    required this.menuName,
    required this.menuCode,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.status,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // Handling join with pos_categories for categoryName if it exists
    String catName = 'Unknown Category';
    final catData = json['pos_categories'];
    if (catData != null && catData is Map) {
      catName = catData['category_name']?.toString() ?? 'Unknown Category';
    }

    return MenuModel(
      id: json['id']?.toString() ?? '',
      menuName: json['sub_category_name']?.toString() ?? '',
      menuCode: json['sub_category_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: catName,
      status: json['status']?.toString() ?? 'Enabled',
    );
  }
}

final menusProvider = FutureProvider<List<MenuModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_sub_categories')
      .select('*, pos_categories(category_name)')
      .applyTenantFilter('pos_sub_categories')
      .order('sub_category_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => MenuModel.fromJson(json)).toList();
});
