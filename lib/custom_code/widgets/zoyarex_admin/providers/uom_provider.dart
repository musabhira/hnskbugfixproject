import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class UomModel {
  final String id;
  final String name;

  UomModel({
    required this.id,
    required this.name,
  });

  factory UomModel.fromJson(Map<String, dynamic> json) {
    return UomModel(
      id: json['id']?.toString() ?? json['uom_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['uom']?.toString() ?? '',
    );
  }
}

final uomProvider = FutureProvider<List<UomModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('uom')
      .select('*')
      .applyTenantFilter('uom')
      .order('uom', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => UomModel.fromJson(json)).toList();
});
