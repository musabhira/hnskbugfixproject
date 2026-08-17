import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class CustomerTypeModel {
  final String id;
  final String name;
  final String description;
  final String status;

  CustomerTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  factory CustomerTypeModel.fromJson(Map<String, dynamic> json) {
    return CustomerTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['customer_type_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

final customerTypesProvider = FutureProvider<List<CustomerTypeModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('customer_types')
        .select('*')
      .applyTenantFilter('customer_types')
        .neq('status', 'Deleted')
        .order('name', ascending: true);

    final data = response as List<dynamic>;
    return data.map((json) => CustomerTypeModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
