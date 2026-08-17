import 'package:flutter/material.dart';

class ZoyarexReportsDashboardPage extends StatelessWidget {
  const ZoyarexReportsDashboardPage({Key? key}) : super(key: key);

  Widget _buildReportCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Click to view detailed analytics and metrics. (Coming Soon)'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is currently under development.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(context, 'Sales Report', Icons.bar_chart, Colors.blue),
          _buildReportCard(context, 'Waiter Performance', Icons.person, Colors.orange),
          _buildReportCard(context, 'Payment Methods', Icons.payments, Colors.green),
          _buildReportCard(context, 'Item Cancellations', Icons.cancel, Colors.red),
          _buildReportCard(context, 'Tax Reports', Icons.account_balance, Colors.indigo),
        ],
      ),
    );
  }
}
