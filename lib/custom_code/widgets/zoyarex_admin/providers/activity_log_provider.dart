import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ActivityLogModel {
  final String id;
  final String action;
  final String entityType;
  final String entityValue;
  final String createdByName;
  final String createdAt;
  final Map<String, dynamic> details;

  ActivityLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityValue,
    required this.createdByName,
    required this.createdAt,
    required this.details,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'UNKNOWN',
      entityType: json['entity_type']?.toString() ?? json['entityType']?.toString() ?? 'Unknown',
      entityValue: json['entity_value']?.toString() ?? json['entityValue']?.toString() ?? '',
      createdByName: json['created_by_name']?.toString() ?? json['updated_by_name']?.toString() ?? 'System',
      createdAt: json['created_at']?.toString() ?? json['updated_at']?.toString() ?? '',
      details: json['details'] as Map<String, dynamic>? ?? {},
    );
  }
}

final activityLogProvider = FutureProvider<List<ActivityLogModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('audit_logs') // or activity_logs, adjust if needed based on real schema
        .select('*')
        .order('created_at', ascending: false)
        .limit(100);

    final data = response as List<dynamic>;
    return data.map((json) => ActivityLogModel.fromJson(json)).toList();
  } catch (e) {
    // If audit_logs doesn't exist, maybe it's activity_logs
    try {
      final response = await ZoyarexSupabase.client
          .from('activity_logs')
          .select('*')
      .applyTenantFilter('activity_logs')
          .order('created_at', ascending: false)
          .limit(100);

      final data = response as List<dynamic>;
      return data.map((json) => ActivityLogModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
