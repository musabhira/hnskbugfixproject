import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PaymentOutModel {
  final String voucherId;
  final String? voucherNumber;
  final String voucherDate;
  final String voucherStatus;
  final String partyName;
  final String branchName;
  final double netAmount;

  PaymentOutModel({
    required this.voucherId,
    this.voucherNumber,
    required this.voucherDate,
    required this.voucherStatus,
    required this.partyName,
    required this.branchName,
    required this.netAmount,
  });

  factory PaymentOutModel.fromJson(Map<String, dynamic> json) {
    return PaymentOutModel(
      voucherId: json['voucher_id']?.toString() ?? json['id']?.toString() ?? '',
      voucherNumber: json['voucher_number']?.toString(),
      voucherDate: json['voucher_date']?.toString() ?? '',
      voucherStatus: json['voucher_status']?.toString() ?? 'draft',
      partyName: json['party_name']?.toString() ?? 'Supplier',
      branchName: json['branch_name']?.toString() ?? 'Main Branch',
      netAmount: json['net_amount'] is num ? (json['net_amount'] as num).toDouble() : double.tryParse(json['net_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

final paymentOutsProvider = FutureProvider<List<PaymentOutModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_vouchers')
      .select('*')
      .applyTenantFilter('gt_vouchers')
      .eq('voucher_type', 'paymentOut')
      .order('voucher_date', ascending: false);

  final data = response as List<dynamic>;
  return data.map((json) => PaymentOutModel.fromJson(json)).toList();
});
