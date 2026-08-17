import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class OutletModel {
  final String id;
  final String branchCode;
  final String branchName;
  final String address;
  final String phone;
  final String shopName;
  final bool isOpen;

  OutletModel({
    required this.id,
    required this.branchCode,
    required this.branchName,
    required this.address,
    required this.phone,
    required this.shopName,
    required this.isOpen,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id']?.toString() ?? '',
      branchCode: json['branch_code']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      isOpen: json['is_open'] == true,
    );
  }
}

final outletsProvider = FutureProvider<List<OutletModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('branches')
      .select('*')
      .applyTenantFilter('branches')
      .order('is_open', ascending: false);

  final data = response as List<dynamic>;
  return data.map((json) => OutletModel.fromJson(json)).toList();
});
