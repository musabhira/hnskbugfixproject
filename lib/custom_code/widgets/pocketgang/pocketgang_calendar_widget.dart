import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📅 PocketGang Group Calendar & Events Widget
class PocketGangCalendarWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const PocketGangCalendarWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  State<PocketGangCalendarWidget> createState() => _PocketGangCalendarWidgetState();
}

class _PocketGangCalendarWidgetState extends State<PocketGangCalendarWidget> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  final TextEditingController _eventController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_calendar_${widget.groupId}';
    final raw = prefs.getString(cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        setState(() {
          _events = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
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
          .eq('activity_type', 'gang_calendar')
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['events'] is List) {
          list = data['events'];
        } else if (data is List) {
          list = data;
        }
        final remote = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        if (mounted) {
          setState(() {
            _events = remote;
            _isLoading = false;
          });
        }
        await prefs.setString(cacheKey, jsonEncode(remote));
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_calendar_${widget.groupId}';
    await prefs.setString(cacheKey, jsonEncode(_events));

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('group_activities').upsert({
        'group_id': widget.groupId,
        'activity_type': 'gang_calendar',
        'data': {'events': _events},
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _addEvent() async {
    final title = _eventController.text.trim();
    if (title.isEmpty) return;

    HapticFeedback.mediumImpact();
    final newEvent = {
      'id': 'evt_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'date': _selectedDate.toIso8601String(),
      'author_id': widget.currentUserId,
    };

    setState(() {
      _events.add(newEvent);
      _events.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
      _eventController.clear();
    });
    await _saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F111A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161924),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE879F9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('📅', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Calendar & Events',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Schedule squad meetups, milestone deadlines & practice calls',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2232),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _eventController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add an event or milestone...',
                            hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addEvent(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2232),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.calendar_month, color: Color(0xFFE879F9), size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _addEvent,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE879F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE879F9)))
                : _events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🗓️', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'No scheduled events yet',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Plan your gang events above.',
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: _events.length,
                        itemBuilder: (context, idx) {
                          final item = _events[idx];
                          final d = DateTime.tryParse(item['date']?.toString() ?? '') ?? DateTime.now();

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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE879F9).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${d.day}',
                                        style: GoogleFonts.outfit(color: const Color(0xFFE879F9), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'][d.month - 1],
                                        style: GoogleFonts.outfit(color: const Color(0xFFE879F9), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item['title']?.toString() ?? '',
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white24),
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    _events.removeAt(idx);
                                    setState(() {});
                                    await _saveEvents();
                                  },
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

