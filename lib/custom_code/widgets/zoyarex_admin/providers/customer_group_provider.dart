import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class CustomerGroupModel {
  final String id;
  final String name;
  final String description;
  final String status;

  CustomerGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  factory CustomerGroupModel.fromJson(Map<String, dynamic> json) {
    return CustomerGroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['customer_group_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

final customerGroupsProvider = FutureProvider<List<CustomerGroupModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('customer_groups')
        .select('*')
      .applyTenantFilter('customer_groups')
        .neq('status', 'Deleted')
        .order('name', ascending: true);

    final data = response as List<dynamic>;
    return data.map((json) => CustomerGroupModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
