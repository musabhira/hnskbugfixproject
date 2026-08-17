import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_loyalty_point_form.dart';

class ZoyarexLoyaltyPointsPage extends ConsumerWidget {
  const ZoyarexLoyaltyPointsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Points'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexLoyaltyPointForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLoyaltyPoints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final points = snapshot.data ?? [];
          if (points.isEmpty) {
            return const Center(child: Text('No Loyalty Points Records Found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: points.length,
            itemBuilder: (context, index) {
              final lp = points[index];
              final isEarned = lp['transaction_type'] == 'earned';
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEarned ? Colors.green : Colors.red,
                    child: Icon(isEarned ? Icons.add : Icons.remove, color: Colors.white),
                  ),
                  title: Text(lp['customer_name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${lp['transaction_type']?.toString().toUpperCase()} | ${lp['transaction_date']?.toString().split('T')[0] ?? ''}'),
                  trailing: Text(
                    '${isEarned ? '+' : '-'}${lp['points']} pts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isEarned ? Colors.green : Colors.red),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexLoyaltyPointForm(loyaltyPoint: lp)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchLoyaltyPoints() async {
    try {
      final response = await ZoyarexSupabase.client
          .from('loyalty_points')
          .select('*')
          .order('transaction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }
}
