import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class SaleInvoiceModel {
  final String voucherId;
  final String? voucherNumber;
  final String voucherDate;
  final String voucherStatus;
  final String voucherType;
  final String partyName;
  final String branchName;
  final double netAmount;
  final double paidAmount;
  final double balanceAmount;

  SaleInvoiceModel({
    required this.voucherId,
    this.voucherNumber,
    required this.voucherDate,
    required this.voucherStatus,
    required this.voucherType,
    required this.partyName,
    required this.branchName,
    required this.netAmount,
    required this.paidAmount,
    required this.balanceAmount,
  });

  factory SaleInvoiceModel.fromJson(Map<String, dynamic> row) {
    final Map<String, dynamic> v = row['voucher'] ?? {};
    final Map<String, dynamic> p = row['parties'] ?? {};
    
    String parsedBranchName = 'Main Branch';
    if (row['branches'] != null && row['branches'] is Map) {
      parsedBranchName = row['branches']['branch_name']?.toString() ?? 'Main Branch';
    }

    return SaleInvoiceModel(
      voucherId: row['id']?.toString() ?? '',
      voucherNumber: v['voucher_number']?.toString(),
      voucherDate: v['voucher_date']?.toString() ?? '',
      voucherStatus: v['status']?.toString() ?? 'draft',
      voucherType: v['voucher_type']?.toString() ?? 'saleInvoice',
      partyName: p['party_name']?.toString() ?? 'Walk-in Customer',
      branchName: parsedBranchName,
      netAmount: v['net_amount'] is num ? (v['net_amount'] as num).toDouble() : double.tryParse(v['net_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: v['paid_amount'] is num ? (v['paid_amount'] as num).toDouble() : double.tryParse(v['paid_amount']?.toString() ?? '0') ?? 0.0,
      balanceAmount: v['balance_amount'] is num ? (v['balance_amount'] as num).toDouble() : double.tryParse(v['balance_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

final saleInvoicesProvider = FutureProvider<List<SaleInvoiceModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_vouchers')
      .select('*, branches(branch_name)')
      .applyTenantFilter('gt_vouchers')
      .limit(100);

  final data = response as List<dynamic>;
  return data
      .map((json) => SaleInvoiceModel.fromJson(json))
      .where((inv) => inv.voucherType == 'saleInvoice')
      .toList();
});
