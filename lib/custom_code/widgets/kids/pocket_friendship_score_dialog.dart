import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_friendship_score_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

/// 💖 Interactive Friendship Score Modal for Kids
/// Shows cosmic compatibility, zodiac match, shared interests, and interactive score boosters.
class PocketFriendshipScoreDialog extends StatefulWidget {
  final String mateId;
  final String mateName;
  final String mateAvatar;
  final int dayLevel;

  const PocketFriendshipScoreDialog({
    super.key,
    required this.mateId,
    required this.mateName,
    required this.mateAvatar,
    this.dayLevel = 1,
  });

  static Future<void> show(
    BuildContext context, {
    required String mateId,
    required String mateName,
    required String mateAvatar,
    int dayLevel = 1,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PocketFriendshipScoreDialog(
        mateId: mateId,
        mateName: mateName,
        mateAvatar: mateAvatar,
        dayLevel: dayLevel,
      ),
    );
  }

  @override
  State<PocketFriendshipScoreDialog> createState() =>
      _PocketFriendshipScoreDialogState();
}

class _PocketFriendshipScoreDialogState
    extends State<PocketFriendshipScoreDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late FriendshipReport _report;
  bool _hasBoosted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _report = PocketFriendshipScoreService.calculateReport(
      widget.mateId,
      mateDayLevel: widget.dayLevel,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _boostScore() async {
    if (_hasBoosted) return;
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    await PocketFriendshipScoreService.boostFriendship(widget.mateId, points: 3);
    setState(() {
      _hasBoosted = true;
      _report = PocketFriendshipScoreService.calculateReport(
        widget.mateId,
        mateDayLevel: widget.dayLevel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mateCfg = PocketKidsAvatarSystem.getAvatarConfigForDay(widget.dayLevel);
    final myDay = PocketKidsService.currentUnlockedDay;
    final myCfg = PocketKidsAvatarSystem.getAvatarConfigForDay(myDay);
    final mateZodiac = PocketKidsAvatarSystem.getZodiacForDay(widget.dayLevel);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF311042),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFEC4899).withValues(alpha: 0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💖', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'FRIENDSHIP COMPATIBILITY',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dual Avatars with Animated Heart Connector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // My Avatar
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                        ),
                        child: VectorAvatarWidget(config: myCfg, size: 68),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        PocketFriendshipScoreService.myZodiac,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Animated Heart Energy Beam
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final scale = 1.0 + (math.sin(_animController.value * math.pi) * 0.18);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFEC4899), Color(0xFF9D174D)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEC4899).withValues(alpha: 0.6),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Text('⚡💖⚡', style: TextStyle(fontSize: 14)),
                          ),
                        );
                      },
                    ),
                  ),

                  // Mate's Avatar
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: VectorAvatarWidget(config: mateCfg, size: 68),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.mateName.split(' ').first,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        mateZodiac,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Giant Score Callout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_report.score}%',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFFFD700),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _report.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ],
                    ),
                    Text(
                      _report.title,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF472B6),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _report.zodiacAnalysis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Shared Interest Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shared Adventure Vibe',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _report.sharedInterest,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Interactive Action Buttons
              Row(
                children: [
                  // High Five / Boost Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasBoosted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _boostScore,
                      icon: Text(_hasBoosted ? '✅' : '✋', style: const TextStyle(fontSize: 16)),
                      label: Text(
                        _hasBoosted ? 'BOOSTED! +3%' : 'HIGH FIVE! ✋',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Chat Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF78350F),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WhatsAppGroupChat(
                              groupId: 'p:${widget.mateId}',
                              groupName: widget.mateName,
                              avatarConfig: mateCfg.toMap(),
                            ),
                          ),
                        );
                      },
                      icon: const Text('💬', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'OPEN CHAT',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
