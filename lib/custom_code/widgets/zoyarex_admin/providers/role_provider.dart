import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class RoleModel {
  final String id;
  final String name;

  RoleModel({
    required this.id,
    required this.name,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

final rolesProvider = FutureProvider<List<RoleModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('roles')
      .select('*')
      .applyTenantFilter('roles')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => RoleModel.fromJson(json)).toList();
});
