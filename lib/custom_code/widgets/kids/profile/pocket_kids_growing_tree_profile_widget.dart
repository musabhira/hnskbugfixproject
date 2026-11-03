import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 🌳 FLAME 2D GROWING TREE WORLD (Strictly Driven by Verified Local Progress)
/// Milestones:
/// - Day 0: Sky, sun/moon, soil, small pot, tiny 2-leaf sprout
/// - Days 1–30: Small seedling growing into strong green stem with fresh leaves
/// - Days 31–60: Young leafy plant with blooming colorful flowers
/// - Days 61–100: Small sturdy tree with branches and fluttering birds
/// - Days 101–180: Flourishing garden tree with red apples / golden fruits
/// - Days 181–240: Majestic shaded canopy tree with gentle drifting fireflies
/// - Days 241–300: Fully mature Ancient Wisdom Tree with golden crown and rainbow aura
class FlameGrowingTreeWorld extends FlameGame {
  final int completedDays;
  FlameGrowingTreeWorld({required this.completedDays});

  double _tick = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    _tick += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    final groundY = h * 0.76;

    // 1. Sky & Sun/Moon
    final isDayTime = DateTime.now().hour >= 6 && DateTime.now().hour < 18;
    final celestialPaint = Paint()
      ..color = isDayTime ? const Color(0xFFFFD700) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(w * 0.8, h * 0.18), isDayTime ? 32 : 24, celestialPaint);

    // 2. Rolling Lush Soil / Grass
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8CD837), Color(0xFF4D7C0F)],
      ).createShader(Rect.fromLTWH(0, groundY, w, h - groundY));
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, h - groundY), groundPaint);

    // 3. Tree Rendering based strictly on completedDays (NO fake progress)
    final centerX = w * 0.5;
    final sway = math.sin(_tick * 1.5) * 4.0;

    if (completedDays == 0) {
      // Day 0: Small Pot & Tiny 2-Leaf Sprout 🌱
      final potPaint = Paint()..color = const Color(0xFFB45309);
      final potRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, groundY + 10), width: 50, height: 35),
        const Radius.circular(8),
      );
      canvas.drawRRect(potRect, potPaint);

      // Tiny 2-leaf sprout
      final sproutPaint = Paint()
        ..color = const Color(0xFF4ADE80)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(centerX, groundY - 5),
          Offset(centerX, groundY - 24), sproutPaint);
      final leafPaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(Offset(centerX - 8, groundY - 26), 5, leafPaint);
      canvas.drawCircle(Offset(centerX + 8, groundY - 26), 5, leafPaint);
    } else if (completedDays <= 30) {
      // Days 1–30: Small Seedling / Tender Green Stem 🌱
      final stemPaint = Paint()
        ..color = const Color(0xFF16A34A)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(centerX, groundY),
          Offset(centerX + sway * 0.5, groundY - 60), stemPaint);
      final leafPaint = Paint()..color = const Color(0xFF4ADE80);
      canvas.drawCircle(Offset(centerX - 16, groundY - 45), 10, leafPaint);
      canvas.drawCircle(Offset(centerX + 16, groundY - 52), 10, leafPaint);
      canvas.drawCircle(Offset(centerX + sway, groundY - 65), 12, leafPaint);
    } else if (completedDays <= 60) {
      // Days 31–60: Leafy Bush with First Flowers 🌸
      final trunkPaint = Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(centerX, groundY),
          Offset(centerX + sway * 0.5, groundY - 90), trunkPaint);
      final foliagePaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(Offset(centerX, groundY - 110), 38, foliagePaint);
      canvas.drawCircle(Offset(centerX - 24, groundY - 95), 26, foliagePaint);
      canvas.drawCircle(Offset(centerX + 24, groundY - 95), 26, foliagePaint);

      // Colorful flowers 🌸
      final flowerPaint = Paint()..color = const Color(0xFFF43F5E);
      canvas.drawCircle(Offset(centerX - 12, groundY - 115), 6, flowerPaint);
      canvas.drawCircle(Offset(centerX + 14, groundY - 105), 6, flowerPaint);
    } else if (completedDays <= 100) {
      // Days 61–100: Sturdy Young Tree with Branches 🌳
      final trunkPaint = Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(centerX, groundY),
          Offset(centerX + sway * 0.3, groundY - 130), trunkPaint);
      final canopyPaint = Paint()..color = const Color(0xFF15803D);
      canvas.drawCircle(Offset(centerX, groundY - 160), 55, canopyPaint);
      canvas.drawCircle(Offset(centerX - 35, groundY - 140), 36, canopyPaint);
      canvas.drawCircle(Offset(centerX + 35, groundY - 140), 36, canopyPaint);
    } else if (completedDays <= 180) {
      // Days 101–180: Flourishing Tree with Apples 🍎
      final trunkPaint = Paint()
        ..color = const Color(0xFF5A2A06)
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(centerX, groundY),
          Offset(centerX + sway * 0.2, groundY - 160), trunkPaint);
      final canopyPaint = Paint()..color = const Color(0xFF166534);
      canvas.drawCircle(Offset(centerX, groundY - 195), 70, canopyPaint);
      canvas.drawCircle(Offset(centerX - 45, groundY - 170), 45, canopyPaint);
      canvas.drawCircle(Offset(centerX + 45, groundY - 170), 45, canopyPaint);

      // Red Apples 🍎
      final applePaint = Paint()..color = const Color(0xFFDC2626);
      canvas.drawCircle(Offset(centerX - 20, groundY - 210), 7, applePaint);
      canvas.drawCircle(Offset(centerX + 22, groundY - 190), 7, applePaint);
      canvas.drawCircle(Offset(centerX, groundY - 175), 7, applePaint);
      canvas.drawCircle(Offset(centerX - 35, groundY - 165), 7, applePaint);
    } else if (completedDays <= 240) {
      // Days 181–240: Majestic Tree Canopy with Firefly Aura ✨
      final trunkPaint = Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(centerX, groundY), Offset(centerX, groundY - 190), trunkPaint);
      final canopyPaint = Paint()..color = const Color(0xFF14532D);
      canvas.drawCircle(Offset(centerX, groundY - 230), 85, canopyPaint);
      canvas.drawCircle(Offset(centerX - 60, groundY - 200), 55, canopyPaint);
      canvas.drawCircle(Offset(centerX + 60, groundY - 200), 55, canopyPaint);

      // Fireflies ✨
      final fireflyPaint = Paint()..color = const Color(0xFFFDE047);
      for (int i = 0; i < 6; i++) {
        final fx = centerX + math.sin(_tick + i) * 70;
        final fy = groundY - 220 + math.cos(_tick * 1.2 + i) * 50;
        canvas.drawCircle(Offset(fx, fy), 4, fireflyPaint);
      }
    } else {
      // Days 241–300: Supreme Ancient Wisdom Tree with Royal Golden Crown 👑🌳
      final trunkPaint = Paint()
        ..color = const Color(0xFF381503)
        ..strokeWidth = 36
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(centerX, groundY), Offset(centerX, groundY - 210), trunkPaint);
      final canopyPaint = Paint()..color = const Color(0xFF0F766E);
      canvas.drawCircle(Offset(centerX, groundY - 250), 98, canopyPaint);
      canvas.drawCircle(Offset(centerX - 70, groundY - 220), 65, canopyPaint);
      canvas.drawCircle(Offset(centerX + 70, groundY - 220), 65, canopyPaint);

      // Golden Crown above mature tree 👑
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(Offset(centerX, groundY - 365), 18, crownPaint);
    }
  }
}

/// Profile Tab 3 Component: Full Screen Growing Tree World with Minimal Overlay
class PocketKidsGrowingTreeProfileWidget extends StatefulWidget {
  final VoidCallback onEditProfile;

  const PocketKidsGrowingTreeProfileWidget({
    super.key,
    required this.onEditProfile,
  });

  @override
  State<PocketKidsGrowingTreeProfileWidget> createState() =>
      _PocketKidsGrowingTreeProfileWidgetState();
}

class _PocketKidsGrowingTreeProfileWidgetState
    extends State<PocketKidsGrowingTreeProfileWidget> {
  @override
  Widget build(BuildContext context) {
    // Strictly read locally completed days (NO Supabase, genuine progress only)
    final completedDaysCount = PocketKidsService.completedDays.length;
    final currentDay = PocketKidsService.currentUnlockedDay;
    final totalStars = PocketKidsService.totalStarsEarned;
    final kidScore = PocketKidsService.kidScore;
    final kidName = PocketKidsService.kidName;
    final kidAvatar = PocketKidsService.kidAvatar.isNotEmpty
        ? PocketKidsService.kidAvatar
        : '🦁';

    return Stack(
      children: [
        // 1. Dynamic Flame 2D Growing Tree World
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFBAE6FD),
                  Color(0xFFE0F2FE),
                  Color(0xFFEDFAF7)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: GameWidget(
              game: FlameGrowingTreeWorld(completedDays: completedDaysCount),
            ),
          ),
        ),

        // 2. Minimal Child-Friendly Glass Overlays
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Top Bar: Child Avatar, Name, and Edit Profile
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF8CD837), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child:
                          Text(kidAvatar, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kidName,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F3E34),
                            ),
                          ),
                          Text(
                            "Day $currentDay Explorer • $completedDaysCount Days Conquered",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B8B82),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Unobtrusive Edit Profile Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onEditProfile();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFC7EDE3), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_rounded,
                                size: 14, color: Color(0xFF0F3E34)),
                            const SizedBox(width: 4),
                            Text(
                              "Edit",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F3E34),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stats Banner: Stars & KS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("⭐", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            "$totalStars Stars",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF8CD837)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("🏆", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            "$kidScore KS",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom Stage Indicator
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF8CD837), width: 1.5),
                  ),
                  child: Text(
                    completedDaysCount == 0
                        ? "🌱 Sprout Stage: Complete Day 1 to grow your seedling!"
                        : completedDaysCount <= 30
                            ? "🌱 Seedling Stage (Days 1–30): Tender green stem growing tall!"
                            : completedDaysCount <= 60
                                ? "🌸 Blooming Stage (Days 31–60): Fresh flowers opening!"
                                : completedDaysCount <= 100
                                    ? "🌳 Sturdy Tree Stage (Days 61–100): Strong branches reached!"
                                    : completedDaysCount <= 180
                                        ? "🍎 Flourishing Tree (Days 101–180): Sweet apples hanging!"
                                        : completedDaysCount <= 240
                                            ? "✨ Canopy Tree (Days 181–240): Drifting firefly forest!"
                                            : "👑 Ancient Wisdom Tree (Days 241–300): 300-Day Master Champion!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F3E34),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
