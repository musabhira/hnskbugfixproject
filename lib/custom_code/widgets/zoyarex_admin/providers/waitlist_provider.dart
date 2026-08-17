import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class WaitlistModel {
  final String id;
  final String customerName;
  final String? customerPhone;
  final int? partySize;
  final String status;
  final String? notes;

  WaitlistModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.partySize,
    required this.status,
    this.notes,
  });

  factory WaitlistModel.fromJson(Map<String, dynamic> json) {
    return WaitlistModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Unknown',
      customerPhone: json['customer_phone']?.toString(),
      partySize: json['party_size'] as int?,
      status: json['status']?.toString() ?? 'waiting',
      notes: json['notes']?.toString(),
    );
  }
}

final waitlistProvider = FutureProvider<List<WaitlistModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('waitlist')
        .select('*')
      .applyTenantFilter('waitlist')
        .order('created_at', ascending: false);
    final data = response as List<dynamic>;
    return data.map((json) => WaitlistModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
