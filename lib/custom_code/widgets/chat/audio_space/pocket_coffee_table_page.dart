import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_audio_space_engine.dart';
import 'pocket_audio_room_sheet.dart';

/// ☕ PocketCoffeeTablePage
/// Intimate 4-seat English voice rooms — 100% free P2P WebRTC via existing engine.
/// Tap once. Auto-join an open table or create a new one. No host ceremony needed.
class PocketCoffeeTablePage extends StatefulWidget {
  const PocketCoffeeTablePage({super.key});

  @override
  State<PocketCoffeeTablePage> createState() => _PocketCoffeeTablePageState();
}

class _PocketCoffeeTablePageState extends State<PocketCoffeeTablePage>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PocketAudioSpaceEngine _engine = PocketAudioSpaceEngine.instance;

  static const int _maxSeats = 4;
  static const String _coffeeCategory = 'Coffee Table';

  List<Map<String, dynamic>> _activeTables = [];
  bool _isLoading = true;
  bool _isJoining = false;
  String? _joiningTableId;
  Timer? _refreshTimer;
  late AnimationController _pulseController;

  static const List<String> _icebreakers = [
    "What's something new you learned this week?",
    'Describe your perfect weekend in English!',
    "What's your favorite English movie and why?",
    'Tell us something funny that happened to you recently.',
    "What's one English word you just learned today?",
    'If you could travel anywhere, where would you go?',
    "What's your biggest goal for this year?",
    'Describe your hometown in 3 sentences.',
    'What food would you recommend to a foreigner?',
    'Teach us one word from your local language!',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _engine.initUser();
    _loadActiveTables();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _loadActiveTables());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveTables() async {
    try {
      final rows = await _supabase
          .from('live_audio_spaces')
          .select('*')
          .eq('is_active', true)
          .eq('category', _coffeeCategory)
          .order('created_at', ascending: true)
          .limit(20);
      if (mounted) {
        setState(() {
          _activeTables = List<Map<String, dynamic>>.from(rows);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _randomIcebreaker() {
    final list = List<String>.from(_icebreakers)..shuffle();
    return list.first;
  }

  int get _firstOpenTableCount {
    if (_activeTables.isEmpty) return 0;
    final open = _activeTables.where(
        (t) => (t['participant_count'] as num? ?? 0) < _maxSeats);
    if (open.isEmpty) return 0;
    return (open.first['participant_count'] as num? ?? 0).toInt();
  }

  Future<void> _quickJoin() async {
    HapticFeedback.mediumImpact();
    if (_isJoining) return;
    setState(() => _isJoining = true);
    try {
      final openRow = _activeTables.firstWhere(
        (t) => (t['participant_count'] as num? ?? 0) < _maxSeats,
        orElse: () => {},
      );

      AudioSpaceModel? space;
      if (openRow.isNotEmpty) {
        final existing = AudioSpaceModel.fromMap(openRow);
        setState(() => _joiningTableId = existing.id);
        final myId = _supabase.auth.currentUser?.id;
        final role = (existing.hostUserId == myId) ? AudioRole.host : AudioRole.speaker;
        await _engine.joinSpace(existing, initialRole: role);
        space = existing;
      } else {
        space = await _engine.createSpace(
          title: '☕ English Coffee Table',
          topic: _randomIcebreaker(),
          category: _coffeeCategory,
          levelTag: 'All Levels',
          speakerLimit: _maxSeats,
        );
      }

      if (!mounted) return;
      if (space != null) {
        await PocketAudioRoomSheet.show(context);
      } else {
        _snack('Could not connect — please try again.');
      }
    } catch (_) {
      if (mounted) _snack('Connection failed. Check your internet.');
    } finally {
      if (mounted) setState(() { _isJoining = false; _joiningTableId = null; });
    }
  }

  Future<void> _joinTable(AudioSpaceModel space) async {
    HapticFeedback.selectionClick();
    if (_isJoining) return;
    setState(() { _isJoining = true; _joiningTableId = space.id; });
    try {
      if (_engine.isInRoom && _engine.currentSpace?.id == space.id) {
        if (mounted) await PocketAudioRoomSheet.show(context);
      } else {
        final myId = _supabase.auth.currentUser?.id;
        final role = (space.hostUserId == myId) ? AudioRole.host : AudioRole.speaker;
        await _engine.joinSpace(space, initialRole: role);
        if (mounted) await PocketAudioRoomSheet.show(context);
      }
    } catch (_) {
      if (mounted) _snack('Could not join this table.');
    } finally {
      if (mounted) setState(() { _isJoining = false; _joiningTableId = null; });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
      backgroundColor: const Color(0xFF1E293B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────── BUILD ───────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060A0F),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildHeroCard()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00))),
              )
            else if (_activeTables.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final space = AudioSpaceModel.fromMap(_activeTables[i]);
                    final count = space.participantCount;
                    return _buildTableCard(space, count, count >= _maxSeats, i);
                  },
                  childCount: _activeTables.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        border: Border(bottom: BorderSide(color: Color(0xFF161D2E), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF161D2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white60, size: 15),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('☕', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                Text('ENGLISH COFFEE TABLE',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    )),
              ]),
              Text('4-seat voice rooms · Instant · Free',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 11.5,
                  )),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms);
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: _isJoining ? null : _quickJoin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF192038), Color(0xFF0D1422)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isJoining
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.7)
                  : const Color(0xFFFFFC00).withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.07),
                blurRadius: 28,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pulsing cup
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, child) => Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.065,
                  child: child,
                ),
                child: Container(
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.28),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(child: Text('☕', style: TextStyle(fontSize: 28))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isJoining ? 'Finding your table...' : 'Pull up a chair!',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isJoining
                          ? 'Connecting to audio...'
                          : 'Tap to auto-join or create a 4-seat table.',
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12.5),
                    ),
                    const SizedBox(height: 10),
                    // 4 seat bubbles
                    Row(
                      children: List.generate(4, (i) {
                        final taken = i < _firstOpenTableCount;
                        return Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: taken
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.18)
                                : const Color(0xFF1A2235),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: taken
                                  ? const Color(0xFFFFFC00).withValues(alpha: 0.7)
                                  : Colors.white12,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(taken ? '🧑' : '💺',
                                style: const TextStyle(fontSize: 13)),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (_isJoining)
                const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFC00)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Join',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.12, end: 0, duration: 380.ms, curve: Curves.easeOutCubic)
        .fadeIn();
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
      child: Row(
        children: [
          Text('Active Tables',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(width: 8),
          if (_activeTables.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
              ),
              child: Text('${_activeTables.length} live',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          const Spacer(),
          GestureDetector(
            onTap: _showHostTableDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFC00),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    'Host Table',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showHostTableDialog() async {
    HapticFeedback.selectionClick();
    final titleController = TextEditingController(text: '☕ Daily English Chit-Chat');
    String selectedCategory = 'Casual';
    final categories = ['Casual', 'Beginner', 'Debate', 'Career'];
    bool isCreating = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Text('☕', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Host 4-Seat Table',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Intimate voice table · Max 4 participants',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇬🇧', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'English Only',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  'Table Title / Topic',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Weekend Plans, Tech Talk...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFFFC00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Topic Category',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: categories.map((cat) {
                    final isSel = selectedCategory == cat;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => selectedCategory = cat);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF334155),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: GoogleFonts.outfit(
                                color: isSel ? Colors.black : Colors.white70,
                                fontSize: 11.5,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isCreating
                        ? null
                        : () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;
                            setModalState(() => isCreating = true);
                            try {
                              final space = await _engine.createSpace(
                                title: title,
                                topic: '$selectedCategory Discussion',
                                category: _coffeeCategory,
                                levelTag: selectedCategory,
                                speakerLimit: _maxSeats,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted && space != null) {
                                await PocketAudioRoomSheet.show(context);
                              }
                            } catch (_) {
                              if (ctx.mounted) {
                                setModalState(() => isCreating = false);
                              }
                            }
                          },
                    child: isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                'Launch Space 🚀',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCard(
      AudioSpaceModel space, int count, bool isFull, int index) {
    final isJoiningThis = _joiningTableId == space.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: isFull ? null : () => _joinTable(space),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isFull ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1220),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFull
                    ? Colors.white10
                    : const Color(0xFF10B981).withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Host avatar
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: space.hostAvatar != null && space.hostAvatar!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: space.hostAvatar!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _buildInitial(space.hostName),
                              )
                            : _buildInitial(space.hostName),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (!isFull)
                                Container(
                                  width: 6, height: 6,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                )
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scale(
                                      begin: const Offset(0.7, 0.7),
                                      end: const Offset(1.4, 1.4),
                                    ),
                              Text(
                                isFull ? '🔒 Full' : '✅ Open',
                                style: GoogleFonts.outfit(
                                  color: isFull
                                      ? Colors.white30
                                      : const Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(space.hostName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                    // Seat row
                    Row(
                      children: List.generate(_maxSeats, (i) {
                        final taken = i < count;
                        return Container(
                          width: 20, height: 20,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: taken
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.18)
                                : const Color(0xFF1A2235),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: taken
                                  ? const Color(0xFFFFFC00).withValues(alpha: 0.55)
                                  : Colors.white10,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              taken ? '🧑' : '·',
                              style: TextStyle(
                                fontSize: taken ? 10 : 13,
                                color: Colors.white30,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                if (space.topic.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text('💬 ${space.topic}',
                      style: GoogleFonts.outfit(
                          color: Colors.white54, fontSize: 12.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$count / $_maxSeats seats',
                        style: GoogleFonts.outfit(
                            color: Colors.white30, fontSize: 11.5)),
                    if (!isFull)
                      isJoiningThis
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: Color(0xFFFFFC00)))
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFC00)
                                    .withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFFC00)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('☕',
                                      style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 5),
                                  Text('Pull up a chair',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFFC00),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.5,
                                      )),
                                ],
                              ),
                            ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 55))
        .slideY(begin: 0.08, end: 0, duration: 300.ms)
        .fadeIn();
  }

  Widget _buildInitial(String name) {
    return Container(
      color: const Color(0xFF1A2235),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1220),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            const Text('☕', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text('No tables yet — you go first!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 6),
            Text(
              'Be the first to pull up a chair.\nOthers will see your table and join instantly.',
              style: GoogleFonts.outfit(
                  color: Colors.white54, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 180.ms);
  }
}
