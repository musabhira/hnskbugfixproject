import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_ai_provider.dart';

class ZoyarexAiPage extends ConsumerStatefulWidget {
  const ZoyarexAiPage({super.key});

  @override
  _ZoyarexAiPageState createState() => _ZoyarexAiPageState();
}

class _ZoyarexAiPageState extends ConsumerState<ZoyarexAiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    
    ref.read(zoyarexAiProvider.notifier).sendMessage(text);
    _controller.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoyarexAiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1418),
      appBar: AppBar(
        title: Text(
          'Zoyarex AI',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1F2C34),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (state.isAuthenticated)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.cloud_done, color: Colors.greenAccent),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.cloud_off, color: Colors.redAccent),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: state.messages.length + (state.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      ),
                    ),
                  );
                }

                final message = state.messages[index];
                final isMe = message.isUser;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(text: message.text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message copied to clipboard'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C34),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16.0),
                          topRight: const Radius.circular(16.0),
                          bottomLeft: isMe ? const Radius.circular(16.0) : Radius.zero,
                          bottomRight: isMe ? Radius.zero : const Radius.circular(16.0),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        message.text,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16.0,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isListening)
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF1F2C34),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.spokenText.isEmpty ? "Listening..." : state.spokenText,
                      style: GoogleFonts.outfit(color: Colors.white70, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: const Color(0xFF1F2C34),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3942),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask Zoyarex AI...',
                        hintStyle: GoogleFonts.outfit(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      minLines: 1,
                      maxLines: 6,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: state.isListening ? Colors.redAccent : const Color(0xFF2A3942),
                  child: IconButton(
                    icon: Icon(
                      state.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (!state.speechEnabled) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Voice recognition is not available on this platform."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (state.isListening) {
                        ref.read(zoyarexAiProvider.notifier).stopListening();
                      } else {
                        ref.read(zoyarexAiProvider.notifier).startListening();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00A884),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
