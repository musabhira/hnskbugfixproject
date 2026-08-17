import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class AddonModel {
  final String id;
  final String addOnName;
  final String description;
  final double addOnPrice;
  final bool isDynamicPrice;
  final bool isPriceWithProduct;

  AddonModel({
    required this.id,
    required this.addOnName,
    required this.description,
    required this.addOnPrice,
    required this.isDynamicPrice,
    required this.isPriceWithProduct,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['gt_addon_item_id']?.toString() ?? '',
      addOnName: json['name']?.toString() ?? '',
      description: '', // No description column in gt_addon_items
      addOnPrice: (json['price'] ?? 0).toDouble(),
      isDynamicPrice: false,
      isPriceWithProduct: false,
    );
  }
}

final addonsProvider = FutureProvider<List<AddonModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_addon_items')
      .select('*')
      .applyTenantFilter('gt_addon_items')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => AddonModel.fromJson(json)).toList();
});
