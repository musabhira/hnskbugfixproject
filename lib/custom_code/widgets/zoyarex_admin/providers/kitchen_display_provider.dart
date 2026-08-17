import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class KitchenDisplayModel {
  final String id;
  final String name;
  final String? outletId;
  final String displayType;
  final bool isActive;

  KitchenDisplayModel({
    required this.id,
    required this.name,
    this.outletId,
    required this.displayType,
    required this.isActive,
  });

  factory KitchenDisplayModel.fromJson(Map<String, dynamic> json) {
    return KitchenDisplayModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      outletId: json['outlet_id']?.toString(),
      displayType: json['display_type']?.toString() ?? 'kitchen',
      isActive: json['is_active'] ?? true,
    );
  }
}

final kitchenDisplayProvider = FutureProvider<List<KitchenDisplayModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('kitchen_displays')
        .select('*')
      .applyTenantFilter('kitchen_displays')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => KitchenDisplayModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
