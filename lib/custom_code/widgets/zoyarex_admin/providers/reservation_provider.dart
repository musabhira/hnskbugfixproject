import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ReservationModel {
  final String id;
  final String customerName;
  final String? customerPhone;
  final int? numberOfGuests;
  final String status;
  final String reservationTime;
  final String? notes;

  ReservationModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.numberOfGuests,
    required this.status,
    required this.reservationTime,
    this.notes,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Unknown',
      customerPhone: json['customer_phone']?.toString(),
      numberOfGuests: json['number_of_guests'] as int?,
      status: json['status']?.toString() ?? 'pending',
      reservationTime: json['reservation_time']?.toString() ?? DateTime.now().toIso8601String(),
      notes: json['notes']?.toString(),
    );
  }
}

final reservationProvider = FutureProvider<List<ReservationModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('reservations')
        .select('*')
      .applyTenantFilter('reservations')
        .order('reservation_time', ascending: false);
    final data = response as List<dynamic>;
    return data.map((json) => ReservationModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
