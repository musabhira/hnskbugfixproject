import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class OrderModel {
  final String id;
  final String branchId;
  final String branchName;
  final String customerName;
  final String orderNumber;
  final String orderDate;
  final String orderType;
  final String orderStatus;
  final double netAmount;
  final double finalAmount;
  final String paymentStatus;

  OrderModel({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.customerName,
    required this.orderNumber,
    required this.orderDate,
    required this.orderType,
    required this.orderStatus,
    required this.netAmount,
    required this.finalAmount,
    required this.paymentStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String bName = 'Unknown Branch';
    if (json['branches'] != null && json['branches'] is Map) {
      bName = json['branches']['branch_name']?.toString() ?? 'Unknown Branch';
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      branchName: bName,
      customerName: json['table_id'] != null ? 'Table ${json['table_id']}' : 'Walk-In',
      orderNumber: json['id']?.toString() ?? '',
      orderDate: json['created_at']?.toString() ?? '',
      orderType: 'POS',
      orderStatus: json['status']?.toString() ?? 'PENDING',
      netAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['status']?.toString()?.toUpperCase() == 'COMPLETED' ? 'PAID' : 'UNPAID',
    );
  }
}

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('pos_orders')
      .select('*, branches(branch_name)')
      .applyTenantFilter('pos_orders')
      .order('created_at', ascending: false);

  final data = response as List<dynamic>;
  return data.map((json) => OrderModel.fromJson(json)).toList();
});
