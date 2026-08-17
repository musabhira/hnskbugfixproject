import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class AppModel {
  final String id;
  final String name;
  final String description;
  final String status;

  AppModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id']?.toString() ?? json['app_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['app_name']?.toString() ?? 'Unnamed App',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

final appProvider = FutureProvider<List<AppModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('apps')
        .select('*')
      .applyTenantFilter('apps')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => AppModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
