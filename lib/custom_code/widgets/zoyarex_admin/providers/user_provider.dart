import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String roleName;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roleName: json['role_name']?.toString() ?? 'User',
    );
  }
}

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  // Assuming a 'users' or 'profiles' table with a join to roles
  final response = await ZoyarexSupabase.client
      .from('users')
      .select('*, roles(name)')
      .applyTenantFilter('users')
      .limit(50);

  final data = response as List<dynamic>;
  return data.map((json) {
    final roleData = json['roles'];
    if (roleData != null && roleData is Map) {
      json['role_name'] = roleData['name'];
    }
    return UserModel.fromJson(json);
  }).toList();
});
