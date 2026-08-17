import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class TableModel {
  final String id;
  final String tableNumber;
  final String capacity;
  final String branchId;
  final String branchName;
  final String floorId;
  final String floorName;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.branchId,
    required this.branchName,
    required this.floorId,
    required this.floorName,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    String bName = 'Unknown Branch';
    if (json['branches'] != null && json['branches'] is Map) {
      bName = json['branches']['branch_name']?.toString() ?? 'Unknown Branch';
    }

    String fName = 'Unknown Floor';
    if (json['pos_floors'] != null && json['pos_floors'] is Map) {
      fName = json['pos_floors']['floor_name']?.toString() ?? 'Unknown Floor';
    }

    return TableModel(
      id: json['id']?.toString() ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      branchName: bName,
      floorId: json['floor_id']?.toString() ?? '',
      floorName: fName,
    );
  }
}

final tablesProvider = FutureProvider<List<TableModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_tables')
      .select('*, branches(branch_name), pos_floors(floor_name)')
      .applyTenantFilter('pos_tables')
      .order('table_number', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => TableModel.fromJson(json)).toList();
});
