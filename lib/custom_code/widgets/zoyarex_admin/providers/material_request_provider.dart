import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class MaterialRequestModel {
  final String requestId;
  final String? requestNumber;
  final String requestDate;
  final String? requestedBy;
  final String? sourceWarehouse;
  final String? targetWarehouse;
  final String status;

  MaterialRequestModel({
    required this.requestId,
    this.requestNumber,
    required this.requestDate,
    this.requestedBy,
    this.sourceWarehouse,
    this.targetWarehouse,
    required this.status,
  });

  factory MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestModel(
      requestId: json['request_id']?.toString() ?? json['id']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? json['document_no']?.toString(),
      requestDate: json['request_date']?.toString() ?? json['created_at']?.toString() ?? '',
      requestedBy: json['requested_by']?.toString() ?? json['user_name']?.toString(),
      sourceWarehouse: json['source_warehouse']?.toString(),
      targetWarehouse: json['target_warehouse']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

final materialRequestProvider = FutureProvider<List<MaterialRequestModel>>((ref) async {
  try {
    // Attempt 1: Fetch from specific table if it exists
    final response = await ZoyarexSupabase.client
        .from('material_requests')
        .select('*')
      .applyTenantFilter('material_requests')
        .order('created_at', ascending: false);
    
    final data = response as List<dynamic>;
    return data.map((json) => MaterialRequestModel.fromJson(json)).toList();
  } catch (e) {
    try {
      // Attempt 2: Fetch from unified requests table filtered by type
      final response = await ZoyarexSupabase.client
          .from('requests')
          .select('*')
      .applyTenantFilter('requests')
          .eq('request_type', 'material_request')
          .order('created_at', ascending: false);
      
      final data = response as List<dynamic>;
      return data.map((json) => MaterialRequestModel.fromJson(json)).toList();
    } catch (innerE) {
      // If neither exists, return empty list gracefully
      return [];
    }
  }
});
