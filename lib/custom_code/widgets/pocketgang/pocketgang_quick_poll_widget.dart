import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_tool_storage.dart';

/// 📊 Quick Poll & Decision Maker (Solo = Local, 2+ Members = Global Sync)
class PocketGangQuickPollWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangQuickPollWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.memberCount = 1,
    this.coupleTheme,
  });

  @override
  State<PocketGangQuickPollWidget> createState() =>
      _PocketGangQuickPollWidgetState();
}

class _PocketGangQuickPollWidgetState extends State<PocketGangQuickPollWidget> {
  static const String _activityType = 'gang_quick_polls';
  List<Map<String, dynamic>> _polls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  Future<void> _loadPolls() async {
    final loaded = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: _activityType,
      memberCount: widget.memberCount,
    );
    if (!mounted) return;
    setState(() {
      _polls = loaded;
      _isLoading = false;
    });
  }

  Future<void> _persist() async {
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: _activityType,
      title: 'Quick Polls',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: _polls,
    );
  }

  Future<void> _showCreatePollDialog(PocketSpendCoupleTheme? theme) async {
    final qCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();

    final cardBg = theme?.cardColor ?? const Color(0xFF161924);
    final textColor = theme?.textColor ?? Colors.white;
    final subColor = theme?.subTextColor ?? Colors.white60;
    final accent = theme?.accent ?? const Color(0xFF38BDF8);
    final onAccent = theme?.onAccentTextColor ?? Colors.white;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: Text('Create Quick Poll',
            style: GoogleFonts.outfit(
                color: textColor, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Question (e.g. Movie tonight?)',
                  hintStyle: TextStyle(color: subColor),
                ),
              ),
              TextField(
                controller: opt1Ctrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Option 1',
                  hintStyle: TextStyle(color: subColor),
                ),
              ),
              TextField(
                controller: opt2Ctrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Option 2',
                  hintStyle: TextStyle(color: subColor),
                ),
              ),
              TextField(
                controller: opt3Ctrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Option 3 (optional)',
                  hintStyle: TextStyle(color: subColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: subColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
            ),
            onPressed: () async {
              final q = qCtrl.text.trim();
              final opts = [
                opt1Ctrl.text.trim(),
                opt2Ctrl.text.trim(),
                opt3Ctrl.text.trim(),
              ].where((s) => s.isNotEmpty).toList();
              if (q.isEmpty || opts.length < 2) return;
              Navigator.pop(ctx);
              setState(() {
                _polls.insert(0, {
                  'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
                  'question': q,
                  'options': opts
                      .map((label) => {'label': label, 'voters': <String>[]})
                      .toList(),
                });
              });
              await _persist();
            },
            child: const Text('Post Poll'),
          ),
        ],
      ),
    );
  }

  Future<void> _vote(int pollIdx, int optIdx) async {
    HapticFeedback.selectionClick();
    final poll = Map<String, dynamic>.from(_polls[pollIdx]);
    final options = (poll['options'] as List)
        .map((o) => Map<String, dynamic>.from(o as Map))
        .toList();

    for (int i = 0; i < options.length; i++) {
      final voters = List<String>.from(options[i]['voters'] ?? []);
      voters.remove(widget.currentUserId);
      if (i == optIdx) {
        voters.add(widget.currentUserId);
      }
      options[i]['voters'] = voters;
    }
    poll['options'] = options;
    setState(() => _polls[pollIdx] = poll);
    await _persist();
  }

  Future<void> _deletePoll(int pollIdx) async {
    HapticFeedback.lightImpact();
    setState(() => _polls.removeAt(pollIdx));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bgColor = theme?.bgGradient.first ?? const Color(0xFF0F111A);
    final headerBg = theme?.cardColor ?? const Color(0xFF161924);
    final textColor = theme?.textColor ?? Colors.white;
    final subTextColor = theme?.subTextColor ?? Colors.white54;
    final accentColor = theme?.accent ?? const Color(0xFF38BDF8);
    final onAccentColor = theme?.onAccentTextColor ?? Colors.white;
    final borderColor =
        theme?.borderColor ?? Colors.white.withValues(alpha: 0.08);
    final isShared =
        PocketGangToolStorage.isSharedGroup(widget.groupId, widget.memberCount);

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Poll & Decision',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_polls.length} active polls • ${isShared ? "Shared Sync" : "Local Only"}',
                        style: GoogleFonts.outfit(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePollDialog(theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: onAccentColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Poll',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _polls.isEmpty
                    ? Center(
                        child: Text(
                          'No polls yet. Tap "New Poll" to decide fast!',
                          style: GoogleFonts.outfit(
                              color: subTextColor, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _polls.length,
                        itemBuilder: (context, pollIdx) {
                          final poll = _polls[pollIdx];
                          final options = (poll['options'] as List)
                              .map((o) => Map<String, dynamic>.from(o as Map))
                              .toList();
                          final totalVotes = options.fold<int>(
                              0,
                              (sum, o) =>
                                  sum + ((o['voters'] as List?)?.length ?? 0));

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: headerBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        poll['question']?.toString() ?? '',
                                        style: GoogleFonts.outfit(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.delete_outline_rounded,
                                          color: subTextColor, size: 18),
                                      onPressed: () => _deletePoll(pollIdx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...List.generate(options.length, (optIdx) {
                                  final opt = options[optIdx];
                                  final voters =
                                      List<String>.from(opt['voters'] ?? []);
                                  final voted =
                                      voters.contains(widget.currentUserId);
                                  final pct = totalVotes > 0
                                      ? voters.length / totalVotes
                                      : 0.0;

                                  return GestureDetector(
                                    onTap: () => _vote(pollIdx, optIdx),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: voted
                                            ? accentColor.withValues(alpha: 0.16)
                                            : (theme?.surfaceAltColor ??
                                                const Color(0xFF1E2232)),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: voted
                                              ? accentColor
                                              : borderColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              opt['label']?.toString() ?? '',
                                              style: GoogleFonts.outfit(
                                                color: textColor,
                                                fontSize: 13.5,
                                                fontWeight: voted
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${(pct * 100).round()}% (${voters.length})',
                                            style: TextStyle(
                                              color: voted
                                                  ? accentColor
                                                  : subTextColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
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
