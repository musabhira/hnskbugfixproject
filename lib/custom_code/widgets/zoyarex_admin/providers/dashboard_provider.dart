import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class DashboardStats {
  final List<dynamic> topSellingCategories;
  final List<dynamic> topSellingProducts;
  final List<dynamic> modeOfSaleAmountGroup;
  final List<dynamic> modeOfSaleOrderGroup;
  final List<dynamic> hourlyActiveOrderGroup;
  final List<dynamic> topSellingWaiter;
  final Map<String, dynamic> overallStats;

  DashboardStats({
    required this.topSellingCategories,
    required this.topSellingProducts,
    required this.modeOfSaleAmountGroup,
    required this.modeOfSaleOrderGroup,
    required this.hourlyActiveOrderGroup,
    required this.topSellingWaiter,
    required this.overallStats,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      topSellingCategories: json['topSellingCategories'] ?? [],
      topSellingProducts: json['topSellingProducts'] ?? [],
      modeOfSaleAmountGroup: json['modeOfSaleAmountGroup'] ?? [],
      modeOfSaleOrderGroup: json['modeOfSaleOrderGroup'] ?? [],
      hourlyActiveOrderGroup: json['hourlyActiveOrderGroup'] ?? [],
      topSellingWaiter: json['topSellingWaiter'] ?? [],
      overallStats: (json['overallStats'] != null && (json['overallStats'] as List).isNotEmpty)
          ? (json['overallStats'] as List).first
          : {
              'activeOrderAmount': 0,
              'cancelledOrderAmount': 0,
              'completedOrderAmount': 0,
              'orderCount': 0,
              'activeOrderCount': 0,
              'cancelledOrderCount': 0,
              'completedOrderCount': 0,
              'uniqueCustomerCount': 0,
              'uniqueBranchCount': 0,
            },
    );
  }
}

class DashboardFilter {
  final String? modeOfSaleId;
  final List<String>? branchIds;
  final String? startDate;
  final String? endDate;
  final String tenantId;

  DashboardFilter({
    this.modeOfSaleId,
    this.branchIds,
    this.startDate,
    this.endDate,
    this.tenantId = "", // Should be replaced with actual tenant ID logic
  });
}

class DashboardFilterNotifier extends Notifier<DashboardFilter> {
  @override
  DashboardFilter build() {
    return DashboardFilter(
      startDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      endDate: DateTime.now().toIso8601String(),
    );
  }

  void updateFilter(DashboardFilter filter) {
    state = filter;
  }
}

final dashboardFilterProvider = NotifierProvider<DashboardFilterNotifier, DashboardFilter>(
  () => DashboardFilterNotifier(),
);

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final filter = ref.watch(dashboardFilterProvider);

  final response = await ZoyarexSupabase.client.rpc('get_dashboard_stats', params: {
    'p_mode_of_sale_id': filter.modeOfSaleId,
    'p_branch_ids': filter.branchIds ?? [],
    'p_start_date': filter.startDate,
    'p_end_date': filter.endDate,
    'p_tenant_id': filter.tenantId,
  });

  final Map<String, dynamic> data = (response is List && response.isNotEmpty) 
      ? response.first 
      : (response as Map<String, dynamic>);

  return DashboardStats.fromJson(data);
});
