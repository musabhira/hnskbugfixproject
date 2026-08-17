import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/voice_assistant/pocket_mates_voice_provider.dart';

class PocketMatesVoiceButton extends ConsumerWidget {
  const PocketMatesVoiceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pocketMatesVoiceProvider);

    return FloatingActionButton(
      heroTag: 'pocket_mates_voice_fab',
      onPressed: () {
        if (state.isListening) {
          ref.read(pocketMatesVoiceProvider.notifier).stopListening();
        } else {
          ref.read(pocketMatesVoiceProvider.notifier).startListening();
          _showVoiceBottomSheet(context, ref);
        }
      },
      backgroundColor: state.isListening ? Colors.red : Colors.blue,
      child: Icon(state.isListening ? Icons.stop : Icons.mic),
    );
  }

  void _showVoiceBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(pocketMatesVoiceProvider);
            return Container(
              padding: const EdgeInsets.all(24.0),
              height: 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isListening) ...[
                    const Icon(Icons.mic, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('Listening...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(state.spokenText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ] else if (state.isThinking) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Thinking...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ] else ...[
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(state.aiResponse, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Automatically stop listening if user closes sheet
      ref.read(pocketMatesVoiceProvider.notifier).stopListening();
    });
  }
}
