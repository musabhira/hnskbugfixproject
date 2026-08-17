import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class TenantModel {
  final String id;
  final String name;
  final String domain;
  final String status;
  final String email;
  final String phone;
  final String createdAt;
  final String tenantCode;

  TenantModel({
    required this.id,
    required this.name,
    required this.domain,
    required this.status,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.tenantCode,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id']?.toString() ?? json['tenant_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['tenant_name']?.toString() ?? 'Unnamed',
      domain: json['domain']?.toString() ?? json['subdomain']?.toString() ?? '',
      status: json['status']?.toString() ?? (json['is_active'] == false ? 'inactive' : 'active'),
      email: json['email']?.toString() ?? json['contact_email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['contact_phone']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      tenantCode: json['tenant_code']?.toString() ?? '',
    );
  }
}

final tenantProvider = FutureProvider<List<TenantModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('tenants')
        .select('*')
      .applyTenantFilter('tenants')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => TenantModel.fromJson(json)).toList();
  } catch (e) {
    try {
      final response = await ZoyarexSupabase.client
          .from('organizations')
          .select('*')
      .applyTenantFilter('organizations')
          .order('name');
      final data = response as List<dynamic>;
      return data.map((json) => TenantModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
