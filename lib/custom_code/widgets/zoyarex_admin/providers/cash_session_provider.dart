import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class CashSessionModel {
  final String id;
  final String userId;
  final double openingBalance;
  final double? closingBalance;
  final String status;
  final String sessionDate;
  final String? notes;

  CashSessionModel({
    required this.id,
    required this.userId,
    required this.openingBalance,
    this.closingBalance,
    required this.status,
    required this.sessionDate,
    this.notes,
  });

  factory CashSessionModel.fromJson(Map<String, dynamic> json) {
    return CashSessionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      openingBalance: (json['opening_balance'] ?? 0.0).toDouble(),
      closingBalance: json['closing_balance'] != null ? (json['closing_balance']).toDouble() : null,
      status: json['status']?.toString() ?? 'open',
      sessionDate: json['session_date']?.toString() ?? DateTime.now().toIso8601String(),
      notes: json['notes']?.toString(),
    );
  }
}

final cashSessionProvider = FutureProvider<List<CashSessionModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('cash_sessions')
        .select('*')
      .applyTenantFilter('cash_sessions')
        .order('session_date', ascending: false);
    final data = response as List<dynamic>;
    return data.map((json) => CashSessionModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
