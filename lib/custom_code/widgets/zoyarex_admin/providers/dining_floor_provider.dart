import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class DiningFloorModel {
  final String id;
  final String name;
  final String description;
  final int sortOrder;
  final bool isActive;

  DiningFloorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory DiningFloorModel.fromJson(Map<String, dynamic> json) {
    return DiningFloorModel(
      id: json['id']?.toString() ?? json['gt_dining_floor_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 'true',
    );
  }
}

final diningFloorsProvider = FutureProvider<List<DiningFloorModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_dining_floors')
      .select('*')
      .applyTenantFilter('gt_dining_floors')
      .order('sort_order', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => DiningFloorModel.fromJson(json)).toList();
});
