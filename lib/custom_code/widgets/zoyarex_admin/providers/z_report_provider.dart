import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZReportModel {
  final String id;
  final String punchDate;
  final String? branchName;
  final bool isSynced;
  final double salesTotal;
  final double expectedCash;

  ZReportModel({
    required this.id,
    required this.punchDate,
    this.branchName,
    required this.isSynced,
    required this.salesTotal,
    required this.expectedCash,
  });

  factory ZReportModel.fromJson(Map<String, dynamic> json) {
    // Note: Depends on whether this is flat in `gt_cash_sessions` or inside `order_summary`. 
    // We will do a generic parse for now.
    return ZReportModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      punchDate: json['punch_date']?.toString() ?? '',
      branchName: json['branch_name']?.toString(),
      isSynced: json['isSynced'] == true || json['is_synced'] == true,
      salesTotal: json['sales_total'] is num ? (json['sales_total'] as num).toDouble() : double.tryParse(json['sales_total']?.toString() ?? '0') ?? 0.0,
      expectedCash: json['expected_cash'] is num ? (json['expected_cash'] as num).toDouble() : double.tryParse(json['expected_cash']?.toString() ?? '0') ?? 0.0,
    );
  }
}

final zReportsProvider = FutureProvider<List<ZReportModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('cash_sessions')
      .select('*')
      .applyTenantFilter('cash_sessions')
      .order('punch_date', ascending: false);

  final data = response as List<dynamic>;
  return data.map((json) => ZReportModel.fromJson(json)).toList();
});
