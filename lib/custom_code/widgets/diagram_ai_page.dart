import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'ai_prompt_service.dart';

class DiagramAiPage extends StatefulWidget {
  const DiagramAiPage({super.key});

  @override
  _DiagramAiPageState createState() => _DiagramAiPageState();
}

class _DiagramAiPageState extends State<DiagramAiPage> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  String? _imageUrl;
  bool _isLoading = false;
  String _status = 'Enter a topic to generate a beautiful diagram...';

  Future<void> _generateDiagram() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _imageUrl = null;
      _status = 'AI is architecting your diagram...';
    });

    final prompt =
        "A clean, professional, high-quality diagram or flowchart illustrating: ${_controller.text.trim()}. Minimalist style, clear labels, white background, presentation quality.";

    final response = await _aiService.generateImage(
      prompt: prompt,
      size: '1024x1024',
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _imageUrl = response.data;
          _status = 'Diagram generated successfully!';
        } else {
          _status = 'Error: ${response.error}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text('Diagram AI',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. How Photosynthesis works...',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateDiagram,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Generate Diagram'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(_status,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: InteractiveViewer(
                          child: _imageUrl!.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(_imageUrl!.split(',')[1]),
                                  fit: BoxFit.contain,
                                )
                              : Image.network(_imageUrl!, fit: BoxFit.contain),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.account_tree_outlined,
                            size: 64, color: Colors.white.withValues(alpha: 0.1)),
                      ),
              ),
            ),
            if (_imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _aiService.saveImageToGallery(_imageUrl!),
                      icon: const Icon(Icons.download),
                      label: const Text('Save to Gallery'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
