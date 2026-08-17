import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ReceiptTemplateModel {
  final String id;
  final String branchId;
  final String branchName;
  final String documentType;
  final String templateName;
  final String paperSize;
  final bool isDefault;
  final Map<String, dynamic> configData;

  ReceiptTemplateModel({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.documentType,
    required this.templateName,
    required this.paperSize,
    required this.isDefault,
    required this.configData,
  });

  factory ReceiptTemplateModel.fromJson(Map<String, dynamic> json) {
    return ReceiptTemplateModel(
      id: json['id']?.toString() ?? '',
      branchId: '',
      branchName: 'All Branches',
      documentType: json['voucher_type']?.toString() ?? '',
      templateName: json['template_name']?.toString() ?? '',
      paperSize: json['paper_size']?.toString() ?? '80mm',
      isDefault: json['is_default'] == true,
      configData: json['config_data'] != null && json['config_data'] is Map ? Map<String, dynamic>.from(json['config_data']) : {},
    );
  }
}

final receiptTemplatesProvider = FutureProvider<List<ReceiptTemplateModel>>((ref) async {
  final response = await ZoyarexSupabase.client
      .from('gt_print_templates')
      .select('*')
      .applyTenantFilter('gt_print_templates')
      .order('template_name', ascending: true);

  final data = response as List<dynamic>;
  return data.map((json) => ReceiptTemplateModel.fromJson(json)).toList();
});
