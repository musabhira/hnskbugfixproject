import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class TaxModel {
  final String id;
  final String taxName;
  final String taxMode;
  final String taxRate;
  final String calculationType;
  final String branchId;
  final String branchName;
  final String status;
  final bool coreAmountFlag;
  final String description;

  TaxModel({
    required this.id,
    required this.taxName,
    required this.taxMode,
    required this.taxRate,
    required this.calculationType,
    required this.branchId,
    required this.branchName,
    required this.status,
    required this.coreAmountFlag,
    required this.description,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id']?.toString() ?? '',
      taxName: json['name']?.toString() ?? '',
      taxMode: 'Percentage',
      taxRate: json['rate']?.toString() ?? '0',
      calculationType: 'Standard',
      branchId: '',
      branchName: 'All Branches',
      status: 'Enabled',
      coreAmountFlag: true,
      description: '',
    );
  }
}

final taxesProvider = FutureProvider<List<TaxModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('taxes')
      .select('*')
      .applyTenantFilter('taxes')
      .order('name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => TaxModel.fromJson(json)).toList();
});
