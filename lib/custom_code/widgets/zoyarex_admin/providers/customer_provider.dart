import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

final customersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('customers')
      .select('*')
      .applyTenantFilter('customers')
      .neq('status', 'Deleted')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => CustomerModel.fromJson(json)).toList();
});
