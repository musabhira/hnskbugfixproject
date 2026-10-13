import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_friendship_score_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'pocket_friendship_score_dialog.dart';

/// 🃏 3D Collectible Kid Avatar Card Dialog
/// Displays the full vector avatar, species, friendship compatibility, zodiac, and bio.
class PocketKidAvatarCardDialog extends StatelessWidget {
  final int day;
  final String mateId;
  final String mateName;
  final String mateBio;

  const PocketKidAvatarCardDialog({
    super.key,
    required this.day,
    required this.mateId,
    required this.mateName,
    required this.mateBio,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    required String mateId,
    required String mateName,
    required String mateBio,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PocketKidAvatarCardDialog(
        day: day,
        mateId: mateId,
        mateName: mateName,
        mateBio: mateBio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = PocketKidsAvatarSystem.getAvatarConfigForDay(day);
    final zodiac = PocketKidsAvatarSystem.getZodiacForDay(day);
    final report = PocketFriendshipScoreService.calculateReport(mateId, mateDayLevel: day);
    final isLion = mateId == 'mentor_animal_king_lion' || day == 100;
    final displayName = isLion ? 'King' : mateName;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.7),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Level Tag & Zodiac
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: Text(
                    'DAY $day • ${cfg.rarityTier.toUpperCase()}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    zodiac,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Giant Vector Avatar with Glow
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: VectorAvatarWidget(
                  config: cfg,
                  size: 115,
                  showAura: true,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Name + Blue Tick for Lion
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                if (isLion) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    size: 20,
                    color: Color(0xFFFFD700),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 6),

            // Bio / Description
            Text(
              mateBio.isNotEmpty ? mateBio : 'Loyal adventure companion on the mountain path.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            // Friendship Score Pill (Tappable!)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                PocketFriendshipScoreDialog.show(
                  context,
                  mateId: mateId,
                  mateName: displayName,
                  mateAvatar: '🦁',
                  dayLevel: day,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF831843), Color(0xFFBE185D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF472B6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💖', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Friendship Score: ${report.score}% (${report.title})',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Chat with Mate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF78350F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WhatsAppGroupChat(
                        groupId: 'p:$mateId',
                        groupName: displayName,
                        avatarConfig: cfg.toMap(),
                      ),
                    ),
                  );
                },
                icon: const Text('💬', style: TextStyle(fontSize: 16)),
                label: Text(
                  'CHAT WITH $displayName',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
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
