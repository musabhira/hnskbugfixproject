import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class OnlineSetupModel {
  final String branchId;
  final String branchName;
  final bool isOnlineEnabled;
  final double deliveryRadius;
  final double minOrderValue;
  final double deliveryFee;

  OnlineSetupModel({
    required this.branchId,
    required this.branchName,
    required this.isOnlineEnabled,
    required this.deliveryRadius,
    required this.minOrderValue,
    required this.deliveryFee,
  });

  factory OnlineSetupModel.fromJson(Map<String, dynamic> json) {
    return OnlineSetupModel(
      branchId: json['gt_branch_id']?.toString() ?? json['id']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? 'Unknown',
      isOnlineEnabled: json['is_online_enabled'] == true,
      deliveryRadius: double.tryParse(json['delivery_radius']?.toString() ?? '0') ?? 0.0,
      minOrderValue: double.tryParse(json['min_order_value']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
    );
  }
}

final onlineSetupProvider = FutureProvider<List<OnlineSetupModel>>((ref) async {
  // Querying from branches table for online settings
  final response = await ZoyarexSupabase.client
      .from('branches')
      .select('gt_branch_id, branch_name, is_online_enabled, delivery_radius, min_order_value, delivery_fee')
      .applyTenantFilter('branches')
      .order('branch_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => OnlineSetupModel.fromJson(json)).toList();
});
