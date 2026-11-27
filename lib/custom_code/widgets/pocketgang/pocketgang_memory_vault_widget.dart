import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_tool_storage.dart';

/// 🎙️ Voice Notes & Memory Vault (Solo = Local, 2+ Members = Global Sync)
class PocketGangMemoryVaultWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangMemoryVaultWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.memberCount = 1,
    this.coupleTheme,
  });

  @override
  State<PocketGangMemoryVaultWidget> createState() =>
      _PocketGangMemoryVaultWidgetState();
}

class _PocketGangMemoryVaultWidgetState
    extends State<PocketGangMemoryVaultWidget> {
  static const String _activityType = 'gang_memory_vault';
  final TextEditingController _noteController = TextEditingController();
  String _selectedKind = 'Memory';
  List<Map<String, dynamic>> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    final loaded = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: _activityType,
      memberCount: widget.memberCount,
    );
    if (!mounted) return;
    setState(() {
      _memories = loaded;
      _isLoading = false;
    });
  }

  Future<void> _persist() async {
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: _activityType,
      title: 'Memory & Voice Vault',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: _memories,
    );
  }

  Future<void> _addMemory() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    _noteController.clear();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    setState(() {
      _memories.insert(0, {
        'id': 'm_${now.millisecondsSinceEpoch}',
        'kind': _selectedKind,
        'note': text,
        'date': dateStr,
        'pinned': false,
      });
    });
    await _persist();
  }

  Future<void> _togglePin(int index) async {
    HapticFeedback.selectionClick();
    final item = Map<String, dynamic>.from(_memories[index]);
    item['pinned'] = !(item['pinned'] == true);
    setState(() {
      _memories[index] = item;
      _memories.sort((a, b) =>
          (b['pinned'] == true ? 1 : 0).compareTo(a['pinned'] == true ? 1 : 0));
    });
    await _persist();
  }

  Future<void> _deleteMemory(int index) async {
    HapticFeedback.lightImpact();
    setState(() => _memories.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bgColor = theme?.bgGradient.first ?? const Color(0xFF0F111A);
    final headerBg = theme?.cardColor ?? const Color(0xFF161924);
    final inputBg = theme?.surfaceAltColor ?? const Color(0xFF1E2232);
    final textColor = theme?.textColor ?? Colors.white;
    final subTextColor = theme?.subTextColor ?? Colors.white54;
    final accentColor = theme?.accent ?? const Color(0xFFF472B6);
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
                        'Memory & Voice Vault',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_memories.length} saved • ${isShared ? "Shared Sync" : "Local Only"}',
                        style: GoogleFonts.outfit(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedKind,
                  dropdownColor: headerBg,
                  underline: const SizedBox.shrink(),
                  style: GoogleFonts.outfit(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  items: const ['Memory', 'Voice Note', 'Milestone']
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedKind = v);
                  },
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
                      controller: _noteController,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Save a memory, quote, or voice note...',
                        hintStyle: GoogleFonts.outfit(
                            color: subTextColor, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addMemory(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addMemory,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bookmark_add_rounded,
                        color: onAccentColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _memories.isEmpty
                    ? Center(
                        child: Text(
                          'No memories pinned yet.',
                          style: GoogleFonts.outfit(
                              color: subTextColor, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _memories.length,
                        itemBuilder: (context, index) {
                          final m = _memories[index];
                          final isPinned = m['pinned'] == true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: headerBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isPinned
                                    ? accentColor.withValues(alpha: 0.65)
                                    : borderColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            accentColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        m['kind']?.toString() ?? 'Memory',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      m['date']?.toString() ?? '',
                                      style: TextStyle(
                                          color: subTextColor, fontSize: 11),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        isPinned
                                            ? Icons.push_pin_rounded
                                            : Icons.push_pin_outlined,
                                        color: isPinned
                                            ? accentColor
                                            : subTextColor,
                                        size: 17,
                                      ),
                                      onPressed: () => _togglePin(index),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.delete_outline_rounded,
                                          color: subTextColor, size: 17),
                                      onPressed: () => _deleteMemory(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  m['note']?.toString() ?? '',
                                  style: GoogleFonts.outfit(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
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
