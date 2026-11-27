import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/pocketgang_task_service.dart';
import 'pocket_spend_page.dart';

/// 💡 PocketGang Ideas & Voting Board Widget
class PocketGangIdeasBoardWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final VoidCallback? onTaskCreated;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangIdeasBoardWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.onTaskCreated,
    this.coupleTheme,
  });

  @override
  State<PocketGangIdeasBoardWidget> createState() => _PocketGangIdeasBoardWidgetState();
}

class _PocketGangIdeasBoardWidgetState extends State<PocketGangIdeasBoardWidget> {
  List<Map<String, dynamic>> _ideas = [];
  bool _isLoading = true;
  final TextEditingController _ideaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  Future<void> _loadIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_ideas_${widget.groupId}';
    final raw = prefs.getString(cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        setState(() {
          _ideas = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } catch (_) {}
    }

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('group_activities')
          .select('data')
          .eq('group_id', widget.groupId)
          .eq('activity_type', 'gang_ideas_board')
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['ideas'] is List) {
          list = data['ideas'];
        } else if (data is List) {
          list = data;
        }
        final remote = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        if (mounted) {
          setState(() {
            _ideas = remote;
            _isLoading = false;
          });
        }
        await prefs.setString(cacheKey, jsonEncode(remote));
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_ideas_${widget.groupId}';
    await prefs.setString(cacheKey, jsonEncode(_ideas));

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('group_activities').upsert({
        'group_id': widget.groupId,
        'activity_type': 'gang_ideas_board',
        'data': {'ideas': _ideas},
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _addIdea() async {
    final text = _ideaController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    final newIdea = {
      'id': 'idea_${DateTime.now().millisecondsSinceEpoch}',
      'title': text,
      'author_id': widget.currentUserId,
      'votes': <String>[],
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _ideas.insert(0, newIdea);
      _ideaController.clear();
    });
    await _saveIdeas();
  }

  Future<void> _toggleVote(Map<String, dynamic> idea) async {
    HapticFeedback.selectionClick();
    final List<dynamic> votes = List<dynamic>.from(idea['votes'] ?? []);
    if (votes.contains(widget.currentUserId)) {
      votes.remove(widget.currentUserId);
    } else {
      votes.add(widget.currentUserId);
    }
    idea['votes'] = votes;
    setState(() {});
    await _saveIdeas();
  }

  Future<void> _convertToTask(Map<String, dynamic> idea) async {
    HapticFeedback.heavyImpact();
    final task = PocketGangTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      groupId: widget.groupId,
      title: idea['title']?.toString() ?? 'New Task',
      status: 'todo',
      createdBy: widget.currentUserId,
      estimatedHours: 2.0,
    );

    final currentTasks = await PocketGangTaskService.instance.getTasks(widget.groupId);
    currentTasks.add(task);
    await PocketGangTaskService.instance.saveTasks(
      groupId: widget.groupId,
      tasks: currentTasks,
      userId: widget.currentUserId,
    );

    widget.onTaskCreated?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Idea converted to Team Task! ✅'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bgColor = theme != null ? theme.bgGradient.first : const Color(0xFF0F111A);
    final headerBg = theme != null ? theme.cardColor : const Color(0xFF161924);
    final inputBg = theme != null ? theme.surfaceAltColor : const Color(0xFF1E2232);
    final textColor = theme != null ? theme.textColor : Colors.white;
    final subTextColor = theme != null ? theme.subTextColor : Colors.white54;
    final accentColor = theme != null ? theme.accent : const Color(0xFFFFD600);
    final onAccentColor = theme != null ? theme.onAccentTextColor : Colors.black;
    final borderColor = theme != null ? theme.borderColor : Colors.white.withValues(alpha: 0.08);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gang Ideas & Brainstorming',
                        style: GoogleFonts.outfit(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Propose ideas, upvote favourites, and turn them into tasks',
                        style: GoogleFonts.outfit(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _ideaController,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Share an idea for the gang...',
                        hintStyle: GoogleFonts.outfit(color: subTextColor, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addIdea(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addIdea,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add, color: onAccentColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _ideas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'No ideas posted yet!',
                              style: GoogleFonts.outfit(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suggest a topic or initiative above.',
                              style: GoogleFonts.outfit(color: subTextColor, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: _ideas.length,
                        itemBuilder: (context, idx) {
                          final item = _ideas[idx];
                          final votes = (item['votes'] as List?) ?? [];
                          final hasVoted = votes.contains(widget.currentUserId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161924),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => _toggleVote(item),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: hasVoted
                                          ? const Color(0xFFFFD600).withValues(alpha: 0.2)
                                          : const Color(0xFF1E2232),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasVoted ? const Color(0xFFFFD600) : Colors.white12,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          size: 16,
                                          color: hasVoted ? const Color(0xFFFFD600) : Colors.white54,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${votes.length}',
                                          style: GoogleFonts.outfit(
                                            color: hasVoted ? const Color(0xFFFFD600) : Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item['title']?.toString() ?? '',
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Convert to Task',
                                  icon: const Icon(Icons.playlist_add_check, color: Color(0xFF38BDF8), size: 20),
                                  onPressed: () => _convertToTask(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

