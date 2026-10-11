import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';

/// ⚔️ Dedicated Attacking Profile Page for Kids Mode
/// Shows the peer's Citadel/Avatar House, defense stats, and provides:
/// 1. "⚔️ Challenge House" (automated Spoken English defense raid)
/// 2. "🤝 Become Mates" (add to Kids Mates circle)
/// 3. "💬 Talk / Mate Chat" (child-safe gamified messaging)
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
  late bool _isMate;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _isMate = widget.mate.isFriend || PocketKidsService.isMate(widget.mate.id);
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

  Future<void> _toggleMate() async {
    await PocketKidsService.toggleMate(widget.mate.id);
    setState(() {
      _isMate = PocketKidsService.isMate(widget.mate.id);
    });

    final message = _isMate
        ? "Awesome! You and ${widget.mate.name} are now Mates! 🤝 You can talk anytime!"
        : "Mate removed from your circle.";
    _speak(message);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _isMate ? const Color(0xFF10B981) : Colors.grey.shade700,
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

  void _openMateChat() {
    if (!_isMate) {
      _toggleMate();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsMateChatPage(mate: widget.mate),
      ),
    );
  }

  @override
  void dispose() {
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
                      const Expanded(
                        child: Text(
                          'ATTACKING PROFILE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFEF4444)),
                                    ),
                                    child: const Text(
                                      '🛡️ 3-LAYER DEFENSE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFF87171),
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
                      // Challenge / Raid Button
                      GestureDetector(
                        onTap: _openHouseChallenge,
                        child: Container(
                          width: double.infinity,
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
                            children: const [
                              Text('⚔️', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Text(
                                'CHALLENGE CITADEL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // Become / Remove Mate Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _toggleMate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: _isMate
                                      ? const Color(0xFF334155)
                                      : const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isMate
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF059669),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(_isMate ? '🤝' : '➕', style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isMate ? 'MATES' : 'ADD MATE',
                                      style: const TextStyle(
                                        fontSize: 14,
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
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('💬', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'MATE CHAT',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
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
}
