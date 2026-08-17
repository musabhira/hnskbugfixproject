import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class TagModel {
  final String id;
  final String name;

  TagModel({
    required this.id,
    required this.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id']?.toString() ?? json['tag_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['tag_name']?.toString() ?? '',
    );
  }
}

final tagsProvider = FutureProvider<List<TagModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('tags')
      .select('*')
      .applyTenantFilter('tags')
      .order('tag_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => TagModel.fromJson(json)).toList();
});
