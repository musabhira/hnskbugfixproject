import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ShopModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String countryCode;
  final bool open;
  final bool featured;
  final bool isActive;

  ShopModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.countryCode,
    required this.open,
    required this.featured,
    required this.isActive,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      open: json['open'] == true,
      featured: json['featured'] == true,
      isActive: json['is_active'] ?? true, // defaults to true if missing
    );
  }
}

final shopsProvider = FutureProvider<List<ShopModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('shops')
      .select('*')
      .applyTenantFilter('shops')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => ShopModel.fromJson(json)).toList();
});
