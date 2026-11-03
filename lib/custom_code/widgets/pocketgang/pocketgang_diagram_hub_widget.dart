import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pocket_diagram_studio_editor_page.dart';

/// 📐 PocketGang Diagram Hub Tab: Shows Gang-Specific Diagrams & Creation
class PocketGangDiagramHubWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const PocketGangDiagramHubWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  State<PocketGangDiagramHubWidget> createState() =>
      _PocketGangDiagramHubWidgetState();
}

class _PocketGangDiagramHubWidgetState
    extends State<PocketGangDiagramHubWidget> {
  List<Map<String, dynamic>> _diagrams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGangDiagrams();
  }

  Future<void> _loadGangDiagrams() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_diagrams_${widget.groupId}';

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('group_activities')
          .select('data')
          .eq('group_id', widget.groupId)
          .eq('activity_type', 'gang_diagram_studio')
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['diagrams'] is List) {
          list = data['diagrams'];
        } else if (data is List) {
          list = data;
        }
        final loaded = list
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        await prefs.setString(cacheKey, jsonEncode(loaded));
        if (mounted) {
          setState(() {
            _diagrams = loaded;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final List list = jsonDecode(cached);
        if (mounted) {
          setState(() {
            _diagrams = list
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            _isLoading = false;
          });
        }
        return;
      } catch (_) {}
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveGangDiagrams() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_diagrams_${widget.groupId}';
    await prefs.setString(cacheKey, jsonEncode(_diagrams));

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('group_activities').upsert({
        'group_id': widget.groupId,
        'activity_type': 'gang_diagram_studio',
        'title': 'Gang Diagrams',
        'data': {
          'diagrams': _diagrams,
          'updated_by': widget.currentUserId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'created_by': widget.currentUserId,
        'is_active': true,
      });
    } catch (_) {}
  }

  void _createNewDiagram(String templateKey, String templateName) {
    final titleController = TextEditingController(text: '$templateName - ${widget.groupName}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Diagram',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Diagram Title',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  Navigator.pop(ctx);

                  final newId = 'diag_${DateTime.now().millisecondsSinceEpoch}';
                  setState(() {
                    _diagrams.insert(0, {
                      'id': newId,
                      'title': title,
                      'template': templateKey,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                  });
                  _saveGangDiagrams();

                  PocketDiagramStudioEditorPage.open(
                    context,
                    diagramTitle: title,
                    templateKey: templateKey,
                    groupName: widget.groupName,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Open Diagram Studio',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      {'key': 'flowchart', 'name': 'Flowchart', 'icon': '🔄', 'desc': 'Decision logic & routing'},
      {'key': 'mindmap', 'name': 'Mind Map', 'icon': '🧠', 'desc': 'Brainstorming & concepts'},
      {'key': 'architecture', 'name': 'Architecture', 'icon': '💻', 'desc': 'System topology & APIs'},
      {'key': 'er', 'name': 'ER Database', 'icon': '🗄️', 'desc': 'Schemas & relations'},
    ];

    return Container(
      color: const Color(0xFF0F172A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DIAGRAM STUDIO',
                  style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('GANG COLLABORATION',
                    style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Template Quick Starters
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final t = templates[idx];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _createNewDiagram(t['key']!, t['name']!);
                  },
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['icon']!, style: const TextStyle(fontSize: 20)),
                        const Spacer(),
                        Text(t['name']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold)),
                        Text(t['desc']!,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 9),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Text('SAVED GANG DIAGRAMS',
              style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
            )
          else if (_diagrams.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text('📐', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('No Gang Diagrams yet',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any template above to create and architect a visual canvas for your team.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._diagrams.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  leading: const Text('📊', style: TextStyle(fontSize: 22)),
                  title: Text(
                    d['title']?.toString() ?? 'Diagram',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Template: ${(d['template'] ?? 'flowchart').toString().toUpperCase()}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white30, size: 14),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    PocketDiagramStudioEditorPage.open(
                      context,
                      diagramTitle: d['title']?.toString() ?? 'Diagram',
                      templateKey: d['template']?.toString() ?? 'flowchart',
                      groupName: widget.groupName,
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

