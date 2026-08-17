import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PurchaseReturnModel {
  final String voucherId;
  final String? voucherNumber;
  final String voucherDate;
  final String? supplierName;
  final double netAmount;
  final String status;
  final String voucherType;

  PurchaseReturnModel({
    required this.voucherId,
    this.voucherNumber,
    required this.voucherDate,
    this.supplierName,
    required this.netAmount,
    required this.status,
    this.voucherType = 'purchaseReturn',
  });

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> row) {
    final Map<String, dynamic> v = row['voucher'] ?? {};
    final Map<String, dynamic> p = row['parties'] ?? {};

    return PurchaseReturnModel(
      voucherId: row['id']?.toString() ?? '',
      voucherNumber: v['voucher_number']?.toString(),
      voucherDate: v['voucher_date']?.toString() ?? '',
      supplierName: p['party_name']?.toString() ?? 'Supplier',
      netAmount: v['net_amount'] is num ? (v['net_amount'] as num).toDouble() : double.tryParse(v['net_amount']?.toString() ?? '0') ?? 0.0,
      status: v['status']?.toString() ?? 'draft',
      voucherType: v['voucher_type']?.toString() ?? 'purchaseReturn',
    );
  }
}

final purchaseReturnProvider = FutureProvider<List<PurchaseReturnModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('gt_vouchers')
        .select('*')
      .applyTenantFilter('gt_vouchers')
        .limit(100);
    
    final data = response as List<dynamic>;
    return data
        .map((json) => PurchaseReturnModel.fromJson(json))
        .where((inv) => inv.voucherType == 'purchaseReturn')
        .toList();
  } catch (e) {
    return [];
  }
});
