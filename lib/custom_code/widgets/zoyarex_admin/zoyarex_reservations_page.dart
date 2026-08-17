import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/reservation_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_reservation_form.dart';

class ZoyarexReservationsPage extends ConsumerWidget {
  const ZoyarexReservationsPage({Key? key}) : super(key: key);

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(reservationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexReservationForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('No Reservations Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(reservationProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(res.status),
                      child: const Icon(Icons.event_seat, color: Colors.white),
                    ),
                    title: Text(res.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${res.reservationTime.split('T')[0]} | Guests: ${res.numberOfGuests ?? 1}'),
                        if (res.customerPhone != null) Text('Phone: ${res.customerPhone}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(res.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: _statusColor(res.status),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexReservationForm(reservation: res)));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
