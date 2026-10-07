import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'pocket_mission_curriculum_registry.dart';
import 'flame_english_house_game.dart';

/// 🌟 End-of-Level Milestone Share Card & Vibe Story Dialog
///
/// User Audio Directive:
/// - Generates an achievement card after completing/passing a level exam.
/// - Shows stage avatar, exam marks/score, earned XP, and mastered topic.
/// - Allows one-tap "Share to Vibes" (app status story) and external WhatsApp/social sharing.
class PocketLevelMilestoneVibeCardDialog extends StatefulWidget {
  final int level;
  final int score;
  final int total;
  final VoidCallback? onContinue;

  const PocketLevelMilestoneVibeCardDialog({
    super.key,
    required this.level,
    required this.score,
    this.total = 8,
    this.onContinue,
  });

  static Future<void> show(
    BuildContext context, {
    required int level,
    required int score,
    int total = 8,
    VoidCallback? onContinue,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PocketLevelMilestoneVibeCardDialog(
        level: level,
        score: score,
        total: total,
        onContinue: onContinue,
      ),
    );
  }

  @override
  State<PocketLevelMilestoneVibeCardDialog> createState() =>
      _PocketLevelMilestoneVibeCardDialogState();
}

class _PocketLevelMilestoneVibeCardDialogState
    extends State<PocketLevelMilestoneVibeCardDialog> {
  bool _isPostingVibe = false;
  bool _hasPostedVibe = false;

  String _getTopicTitle() {
    final grammarTitle = PocketMissionCurriculumRegistry.getGrammarRuleTitle(widget.level);
    if (grammarTitle.isNotEmpty) return grammarTitle;
    final estate = FlameEnglishHouseWidget.getEstateStageTitle(widget.level);
    if (estate.isNotEmpty) return estate;
    return 'Day ${widget.level} English Mastery';
  }

  Future<void> _postToVibes() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to post to your Vibes.')),
      );
      return;
    }

    setState(() => _isPostingVibe = true);
    HapticFeedback.mediumImpact();

    final topic = _getTopicTitle();
    final caption = '🏆 DAY ${widget.level} EXAM PASSED! (${widget.score}/${widget.total})\n'
        '📚 Mastered: $topic\n'
        '⚡ XP Earned: +250 XP\n'
        '#PocketMates #EnglishMastery #Vibes';

    try {
      final now = DateTime.now();
      await SupaFlow.client.from('statuses').insert({
        'user_id': uid,
        'caption': caption,
        'type': 'text',
        'privacy': 'public',
        'created_at': now.toIso8601String(),
        'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
      });

      if (mounted) {
        setState(() {
          _isPostingVibe = false;
          _hasPostedVibe = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✨ Successfully posted to your Vibes! Friends can now celebrate your English progress!',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPostingVibe = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post to Vibes: $e')),
        );
      }
    }
  }

  void _shareExternal() {
    HapticFeedback.selectionClick();
    final topic = _getTopicTitle();
    final text = '🏆 I just passed the Day ${widget.level} Gatekeeper Exam on Pocket Mates with a score of ${widget.score}/${widget.total}!\n'
        '📚 Today\'s Mastery: $topic\n'
        '⚡ Level Up Your English with Pocket Mates!';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final avatarConfig =
        VectorAvatarConfig.getEvolutionAvatarForStage(widget.level);
    final topic = _getTopicTitle();
    final isPerfect = widget.score == widget.total;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPerfect ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isPerfect ? const Color(0xFFFFD700) : const Color(0xFF38BDF8))
                  .withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isPerfect
                    ? const Color(0xFFFFD700).withValues(alpha: 0.22)
                    : const Color(0xFF10B981).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPerfect ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isPerfect ? '👑 PERFECT PASS' : '🎉 EXAM PASSED',
                      style: GoogleFonts.outfit(
                        color: isPerfect ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 🌟 Stage Avatar with Golden Halo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0F172A)],
                ),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: ClipOval(
                child: Center(
                  child: VectorAvatarWidget(
                    config: avatarConfig,
                    size: 104,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Milestone Day & Topic
            Text(
              'DAY ${widget.level} COMPLETE!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF67E8F9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Deck: Score & XP
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text('EXAM SCORE',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.score}/${widget.total}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text('XP EARNED',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          '+250 XP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 📢 Button 1: Post to My Vibes
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasPostedVibe ? const Color(0xFF047857) : const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _isPostingVibe ? null : _postToVibes,
                icon: _isPostingVibe
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(_hasPostedVibe ? Icons.check_circle_rounded : Icons.photo_camera_rounded, size: 20),
                label: Text(
                  _hasPostedVibe ? 'POSTED TO VIBES ✓' : 'SHARE TO YOUR VIBES 📸 (വൈബ്സ് ഇടുക)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 📲 Button 2: Share Externally (WhatsApp)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _shareExternal,
                icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFFFFD700)),
                label: Text(
                  'SHARE CARD TO WHATSAPP 📲',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onContinue?.call();
                },
                child: Text(
                  'CONTINUE TO HOUSE ${widget.level + 1} ➔',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
