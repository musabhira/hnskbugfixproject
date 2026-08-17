import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class FloorModel {
  final String id;
  final String floorName;
  final String branchId;
  final String branchName;

  FloorModel({
    required this.id,
    required this.floorName,
    required this.branchId,
    required this.branchName,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    String bName = 'Unknown Branch';
    final bData = json['branches'];
    if (bData != null && bData is Map) {
      bName = bData['branch_name']?.toString() ?? 'Unknown Branch';
    }

    return FloorModel(
      id: json['id']?.toString() ?? '',
      floorName: json['floor_name']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      branchName: bName,
    );
  }
}

final floorsProvider = FutureProvider<List<FloorModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_floors')
      .select('*, branches(branch_name)')
      .applyTenantFilter('pos_floors')
      .order('floor_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => FloorModel.fromJson(json)).toList();
});
