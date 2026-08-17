import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/receipt_template_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_receipt_template_form.dart';

class ZoyarexReceiptTemplatesPage extends ConsumerWidget {
  const ZoyarexReceiptTemplatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(receiptTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexReceiptTemplateFormPage()));
            },
            tooltip: 'Create Template',
          ),
        ],
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('No Templates Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(receiptTemplatesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.print, color: Colors.white),
                    ),
                    title: Text(template.templateName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Doc Type: ${template.documentType} | Size: ${template.paperSize} | Branch: ${template.branchName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (template.isDefault) const Icon(Icons.star, color: Colors.amber, size: 20),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexReceiptTemplateFormPage(template: template)));
                          },
                        ),
                      ],
                    ),
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
