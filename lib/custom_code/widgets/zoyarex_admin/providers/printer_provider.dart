import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PrinterModel {
  final String id;
  final String name;
  final String ipAddress;
  final String type; // e.g. receipt, kot
  final bool isActive;

  PrinterModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.type,
    required this.isActive,
  });

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json['id']?.toString() ?? json['printer_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['printer_name']?.toString() ?? 'Unnamed',
      ipAddress: json['ip_address']?.toString() ?? json['ip']?.toString() ?? '',
      type: json['type']?.toString() ?? json['printer_type']?.toString() ?? 'unknown',
      isActive: json['is_active'] ?? json['active'] ?? true,
    );
  }
}

final printerProvider = FutureProvider<List<PrinterModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('printers')
        .select('*')
      .applyTenantFilter('printers')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => PrinterModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
