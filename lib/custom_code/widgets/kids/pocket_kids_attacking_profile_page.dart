import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_fight_dialog.dart';

/// ⚔️ Dedicated Attacking Profile Page for Kids Mode
class PocketKidsAttackingProfilePage extends StatefulWidget {
  final KidMate mate;

  const PocketKidsAttackingProfilePage({
    super.key,
    required this.mate,
  });

  @override
  State<PocketKidsAttackingProfilePage> createState() => _PocketKidsAttackingProfilePageState();
}

class _PocketKidsAttackingProfilePageState extends State<PocketKidsAttackingProfilePage> {
  final FlutterTts _tts = FlutterTts();
  late KidMateRequestStatus _requestStatus;
  late bool _isMate;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    PocketGameAudioService.instance.playAttackTheme(
      targetId: widget.mate.id,
      targetDay: widget.mate.dayLevel,
    );
    _requestStatus = PocketKidsService.getMateRequestStatus(widget.mate.id);
    _isMate = _requestStatus == KidMateRequestStatus.accepted;
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      _speak("Welcome to ${widget.mate.name}'s Castle! Ready to challenge or become mates?");
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      setState(() => _speaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _handleMateRequestAction() async {
    String message = '';
    Color snackColor = const Color(0xFF10B981);

    if (_requestStatus == KidMateRequestStatus.none) {
      await PocketKidsService.sendMateRequest(widget.mate.id);
      message = "Mate request sent to ${widget.mate.name}! 💌";
      snackColor = const Color(0xFF10B981);

      // If robot peer, auto-accepts shortly
      if (widget.mate.isRobot) {
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            setState(() {
              _requestStatus = PocketKidsService.getMateRequestStatus(widget.mate.id);
              _isMate = _requestStatus == KidMateRequestStatus.accepted;
            });
            _speak("${widget.mate.name} accepted your request! You are now Mates! 🤝");
          }
        });
      }
    } else if (_requestStatus == KidMateRequestStatus.sent) {
      await PocketKidsService.cancelMateRequest(widget.mate.id);
      message = "Request cancelled.";
      snackColor = Colors.grey.shade700;
    } else if (_requestStatus == KidMateRequestStatus.received) {
      await PocketKidsService.acceptMateRequest(widget.mate.id);
      message = "Hooray! You and ${widget.mate.name} are now Mates! 🤝";
      snackColor = const Color(0xFF10B981);
    } else {
      await PocketKidsService.removeMate(widget.mate.id);
      message = "Removed from your mates.";
      snackColor = Colors.grey.shade700;
    }

    setState(() {
      _requestStatus = PocketKidsService.getMateRequestStatus(widget.mate.id);
      _isMate = _requestStatus == KidMateRequestStatus.accepted;
    });

    _speak(message);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: snackColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openHouseChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsHouseChallengePage(defender: widget.mate),
      ),
    );
  }

  void _openFightDuel() {
    PocketCitadelFightModal.show(
      context,
      opponentId: widget.mate.id,
      opponentName: widget.mate.name,
      opponentAvatar: widget.mate.avatar,
      opponentDay: widget.mate.dayLevel,
      isKidMode: true,
    );
  }

  void _openMateChat() {
    if (_requestStatus != KidMateRequestStatus.accepted) {
      final hint = _requestStatus == KidMateRequestStatus.received
          ? "Accept ${widget.mate.name}'s Mate Request first to talk! ✨"
          : "Send a Mate Request to ${widget.mate.name} first! 🤝";
      _speak(hint);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hint, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsMateChatPage(mate: widget.mate),
      ),
    );
  }

  @override
  void dispose() {
    PocketGameAudioService.instance.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final house = PocketKidsService.getHouseForDay(widget.mate.dayLevel);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dramatic citadel night sky
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: house.themeColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.mate.dayLevel >= 90 || widget.mate.id == PocketKidsService.lionId
                              ? '👑 KING LION BOSS BATTLE (DAY 91)'
                              : 'ATTACKING PROFILE',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _speaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                          color: const Color(0xFFFBBF24),
                        ),
                        onPressed: () {
                          if (_speaking) {
                            _tts.stop();
                            setState(() => _speaking = false);
                          } else {
                            _speak("${widget.mate.name}'s Citadel. House stage: ${house.title}. Level: Day ${widget.mate.dayLevel}.");
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Citadel Display & Stats
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // Avatar Header Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.mate.avatar,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.mate.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ages ${widget.mate.ageGroup} Explorer',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: house.themeColor.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: house.themeColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Tier ${house.tier} • ${house.title}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: house.themeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Flame Animated Avatar House
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1E293B),
                                const Color(0xFF0F172A),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: house.themeColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: house.themeColor.withValues(alpha: 0.18),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(house.emoji, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 6),
                                      Text(
                                        house.title.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _showDefenseQuestionsSheet(widget.mate.dayLevel),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                                      ),
                                      child: Text(
                                        '🛡️ ${widget.mate.dayLevel} DEFENSES 👁️',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFF87171),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Live Flame Avatar House Widget
                              PocketAvatarHouseWidget(
                                day: widget.mate.dayLevel,
                                width: 220,
                                height: 180,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                house.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Citadel Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: '🏔️',
                                value: 'Day ${widget.mate.dayLevel}',
                                label: 'Trail Progress',
                                color: const Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: '⭐',
                                value: '${widget.mate.stars}',
                                label: 'Stars Earned',
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: '🏰',
                                value: 'Tier ${house.tier}',
                                label: 'Citadel Stage',
                                color: const Color(0xFFA855F7),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons:
                // 1. Attack / Challenge House
                // 2. Add / Toggle Mate
                // 3. Mate Chat / Talk
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Challenge / Raid Button & Fight Duel Button (Audio Directive)
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: GestureDetector(
                              onTap: _openHouseChallenge,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⚔️', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.mate.dayLevel == 100 || widget.mate.id == PocketKidsService.lionId
                                          ? 'ATTACK KING LION'
                                          : 'CHALLENGE CITADEL',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: _openFightDuel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('🥊', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 6),
                                    Text(
                                      'FIGHT',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // Become / Remove / Accept Mate Request Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _handleMateRequestAction,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: _requestStatus == KidMateRequestStatus.accepted
                                      ? const Color(0xFF334155)
                                      : _requestStatus == KidMateRequestStatus.received
                                          ? const Color(0xFFF59E0B)
                                          : _requestStatus == KidMateRequestStatus.sent
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _requestStatus == KidMateRequestStatus.accepted
                                        ? const Color(0xFF64748B)
                                        : _requestStatus == KidMateRequestStatus.received
                                            ? const Color(0xFFD97706)
                                            : _requestStatus == KidMateRequestStatus.sent
                                                ? const Color(0xFF475569)
                                                : const Color(0xFF059669),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _requestStatus == KidMateRequestStatus.accepted
                                          ? '💖'
                                          : _requestStatus == KidMateRequestStatus.received
                                              ? '✨'
                                              : _requestStatus == KidMateRequestStatus.sent
                                                  ? '⏳'
                                                  : '➕',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _requestStatus == KidMateRequestStatus.accepted
                                          ? 'MATES'
                                          : _requestStatus == KidMateRequestStatus.received
                                              ? 'ACCEPT'
                                              : _requestStatus == KidMateRequestStatus.sent
                                                  ? 'SENT'
                                                  : 'SEND REQUEST',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Talk / Mate Chat Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _openMateChat,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  gradient: _isMate
                                      ? const LinearGradient(
                                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                        )
                                      : null,
                                  color: _isMate ? null : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(16),
                                  border: _isMate
                                      ? null
                                      : Border.all(color: Colors.white24, width: 1.2),
                                  boxShadow: _isMate
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('💬', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MATE CHAT',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: _isMate ? Colors.white : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDefenseQuestionsSheet(int day) async {
    final traps = await PocketKidsDefenseService.getDefenderTrapsForDay(day, defenderId: widget.mate.id);
    final challenges = await PocketKidsService.getEffectiveDefenseForDay(day);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'CITADEL DEFENSE LAYERS ($day)',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Defenders must solve all $day defense challenge layers (Sentence Builder, Spelling, Voice Echo) to breach this citadel!',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: traps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final t = traps[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'DAY ${idx + 1} TRAP',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFF87171),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.helperMascot, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                t.title,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFBBF24), size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _speak(t.spokenText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.prompt,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: "${t.targetPhrase}"',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFDE047),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showEditDefenseDialog(context, day, challenges);
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(
                    'CUSTOMIZE MY DEFENSE QUESTIONS ✏️',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDefenseDialog(BuildContext context, int day, List<KidDefenseChallenge> challenges) {
    final layer1PromptCtrl = TextEditingController(text: challenges.isNotEmpty ? challenges[0].prompt : '');
    final layer1AnswerCtrl = TextEditingController(text: challenges.isNotEmpty ? challenges[0].spokenText : '');

    final layer2PromptCtrl = TextEditingController(text: challenges.length > 1 ? challenges[1].prompt : '');
    final layer2AnswerCtrl = TextEditingController(text: challenges.length > 1 ? challenges[1].spokenText : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🛡️ ', style: TextStyle(fontSize: 22)),
              Text(
                'EDIT DEFENSE QUESTIONS',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize your Spoken English challenges that attackers must solve to raid your citadel!',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
                ),
                const SizedBox(height: 14),
                Text('Layer 1 Question:', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: layer1PromptCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: layer1AnswerCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Correct Answer',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Layer 2 Question:', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: layer2PromptCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: layer2AnswerCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Correct Answer',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final updated = List<KidDefenseChallenge>.from(challenges);
                if (updated.isNotEmpty) {
                  final opts1 = [
                    layer1AnswerCtrl.text.trim(),
                    ...updated[0].options.where((o) => o != updated[0].options[updated[0].correctIndex]).take(2)
                  ];
                  updated[0] = KidDefenseChallenge(
                    prompt: layer1PromptCtrl.text.trim(),
                    spokenText: layer1AnswerCtrl.text.trim(),
                    helperMascot: updated[0].helperMascot,
                    options: opts1,
                    correctIndex: 0,
                    cheerMessage: updated[0].cheerMessage,
                  );
                }
                if (updated.length > 1) {
                  final opts2 = [
                    layer2AnswerCtrl.text.trim(),
                    ...updated[1].options.where((o) => o != updated[1].options[updated[1].correctIndex]).take(2)
                  ];
                  updated[1] = KidDefenseChallenge(
                    prompt: layer2PromptCtrl.text.trim(),
                    spokenText: layer2AnswerCtrl.text.trim(),
                    helperMascot: updated[1].helperMascot,
                    options: opts2,
                    correctIndex: 0,
                    cheerMessage: updated[1].cheerMessage,
                  );
                }
                await PocketKidsService.saveCustomDefense(day, updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Custom Citadel Defense saved for Day $day! 🛡️✨', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Text('SAVE DEFENSE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }
}
