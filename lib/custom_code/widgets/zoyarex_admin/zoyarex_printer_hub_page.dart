import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/printer_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_printer_form.dart';

class ZoyarexPrinterHubPage extends ConsumerWidget {
  const ZoyarexPrinterHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printersAsync = ref.watch(printerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Hub'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPrinterForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: printersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (printers) {
          if (printers.isEmpty) {
            return const Center(child: Text('No Printers Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(printerProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: printer.isActive ? Colors.teal : Colors.grey,
                      child: const Icon(Icons.print, color: Colors.white),
                    ),
                    title: Text(printer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IP: ${printer.ipAddress}'),
                        Text('Type: ${printer.type.toUpperCase()}'),
                      ],
                    ),
                    trailing: const Icon(Icons.settings, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPrinterForm(printer: printer)));
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
