import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class WarehouseModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final String description;
  final String adminId;
  final bool isPrivate;
  final String status;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.description,
    required this.adminId,
    required this.isPrivate,
    required this.status,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id']?.toString() ?? '',
      name: json['warehouse_name']?.toString() ?? '',
      code: json['warehouse_code']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: '',
      adminId: '',
      isPrivate: false,
      status: json['status']?.toString() ?? 'Enabled',
    );
  }
}

final warehousesProvider = FutureProvider<List<WarehouseModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('warehouses')
      .select('*')
      .applyTenantFilter('warehouses')
      .order('warehouse_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => WarehouseModel.fromJson(json)).toList();
});
