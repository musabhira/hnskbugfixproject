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

    // 3. Dynamic Continuous Tree Growth (Scales noticeably with EVERY single completed day!)
    final centerX = w * 0.5;
    final sway = math.sin(_tick * 1.5) * (3.0 + (completedDays / 100.0).clamp(0.0, 1.0) * 3.0);

    if (completedDays == 0) {
      // Day 0: Small Pot & Tiny 2-Leaf Sprout 🌱
      final potPaint = Paint()..color = const Color(0xFFB45309);
      final potRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, groundY + 10), width: 50, height: 35),
        const Radius.circular(8),
      );
      canvas.drawRRect(potRect, potPaint);

      final sproutPaint = Paint()
        ..color = const Color(0xFF4ADE80)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(centerX, groundY - 5),
          Offset(centerX, groundY - 24), sproutPaint);
      final leafPaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(Offset(centerX - 8, groundY - 26), 6, leafPaint);
      canvas.drawCircle(Offset(centerX + 8, groundY - 26), 6, leafPaint);
    } else {
      // Day 1 to 300+: Continuous Dynamic Growth Engine 🌱 ➔ 🌿 ➔ 🌸 ➔ 🌳 ➔ 🍎 ➔ 👑
      // Calculate dynamic trunk height based on exact day count
      double trunkHeight;
      double trunkThickness;
      if (completedDays <= 10) {
        trunkHeight = 32.0 + (completedDays * 4.2);
        trunkThickness = 4.0 + (completedDays * 0.35);
      } else if (completedDays <= 30) {
        trunkHeight = 74.0 + ((completedDays - 10) * 2.4);
        trunkThickness = 7.5 + ((completedDays - 10) * 0.3);
      } else if (completedDays <= 60) {
        trunkHeight = 122.0 + ((completedDays - 30) * 1.5);
        trunkThickness = 13.5 + ((completedDays - 30) * 0.25);
      } else if (completedDays <= 100) {
        trunkHeight = 167.0 + ((completedDays - 60) * 1.15);
        trunkThickness = 21.0 + ((completedDays - 60) * 0.2);
      } else {
        trunkHeight = 213.0 + math.min((completedDays - 100) * 0.3, 40.0);
        trunkThickness = 29.0;
      }

      final trunkTopX = centerX + sway * 0.3;
      final trunkTopY = groundY - trunkHeight;

      // Draw Wooden Trunk (Wood color deepens as tree ages)
      final trunkColor = completedDays < 10
          ? const Color(0xFF16A34A) // Tender green stem
          : (completedDays < 30 ? const Color(0xFF78350F) : const Color(0xFF451A03));
      final trunkPaint = Paint()
        ..color = trunkColor
        ..strokeWidth = trunkThickness
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(centerX, groundY), Offset(trunkTopX, trunkTopY), trunkPaint);

      // Draw Side Branches from Day 8 onwards
      if (completedDays >= 8) {
        final branchSpread = math.min(18.0 + (completedDays * 0.55), 75.0);
        final branchPaint = Paint()
          ..color = trunkColor
          ..strokeWidth = trunkThickness * 0.55
          ..strokeCap = StrokeCap.round;

        // Left branch
        canvas.drawLine(
          Offset(centerX, groundY - trunkHeight * 0.6),
          Offset(trunkTopX - branchSpread, trunkTopY + trunkHeight * 0.25),
          branchPaint,
        );
        // Right branch
        canvas.drawLine(
          Offset(centerX, groundY - trunkHeight * 0.55),
          Offset(trunkTopX + branchSpread, trunkTopY + trunkHeight * 0.3),
          branchPaint,
        );

        if (completedDays >= 35) {
          // Upper secondary branches
          canvas.drawLine(
            Offset(trunkTopX, trunkTopY + 20),
            Offset(trunkTopX - branchSpread * 0.65, trunkTopY - 15),
            branchPaint,
          );
          canvas.drawLine(
            Offset(trunkTopX, trunkTopY + 20),
            Offset(trunkTopX + branchSpread * 0.65, trunkTopY - 15),
            branchPaint,
          );
        }
      }

      // Draw Foliage / Canopy Leaves
      // Canopy radius grows smoothly with every day
      final mainRadius = (completedDays <= 10)
          ? 12.0 + (completedDays * 1.6)
          : (completedDays <= 30
              ? 28.0 + ((completedDays - 10) * 1.1)
              : (completedDays <= 60
                  ? 50.0 + ((completedDays - 30) * 0.75)
                  : math.min(72.5 + ((completedDays - 60) * 0.45), 105.0)));

      final canopyColor = completedDays < 20
          ? const Color(0xFF4ADE80)
          : (completedDays < 60 ? const Color(0xFF22C55E) : const Color(0xFF15803D));
      final canopyPaint = Paint()..color = canopyColor;

      // Central apex foliage
      canvas.drawCircle(Offset(trunkTopX, trunkTopY - mainRadius * 0.35), mainRadius, canopyPaint);

      // Side foliage clouds
      if (completedDays >= 10) {
        final subRadius = mainRadius * 0.72;
        final subCanopyPaint = Paint()..color = canopyColor.withValues(alpha: 0.95);
        canvas.drawCircle(
          Offset(trunkTopX - mainRadius * 0.65, trunkTopY + mainRadius * 0.1),
          subRadius,
          subCanopyPaint,
        );
        canvas.drawCircle(
          Offset(trunkTopX + mainRadius * 0.65, trunkTopY + mainRadius * 0.1),
          subRadius,
          subCanopyPaint,
        );
      }

      // Fresh Leaf Clusters (proportional to completed days)
      final leafCount = math.min(2 + (completedDays ~/ 2), 24);
      final leafPaint = Paint()..color = const Color(0xFF86EFAC);
      for (int i = 0; i < leafCount; i++) {
        final angle = (i * (math.pi * 2 / leafCount)) + (_tick * 0.2);
        final r = mainRadius * 0.85;
        final lx = trunkTopX + math.cos(angle) * r;
        final ly = (trunkTopY - mainRadius * 0.35) + math.sin(angle) * (r * 0.8);
        canvas.drawCircle(Offset(lx, ly), 5.5, leafPaint);
      }

      // Blooming Flowers (from Day 25+)
      if (completedDays >= 25) {
        final flowerCount = math.min(1 + ((completedDays - 25) ~/ 4), 14);
        final flowerPaint = Paint()..color = const Color(0xFFF43F5E);
        final flowerCenterPaint = Paint()..color = const Color(0xFFFFD700);
        for (int i = 0; i < flowerCount; i++) {
          final fa = (i * (math.pi * 1.8 / flowerCount)) + 0.3;
          final fr = mainRadius * 0.65;
          final fx = trunkTopX + math.cos(fa) * fr;
          final fy = (trunkTopY - mainRadius * 0.35) + math.sin(fa) * (fr * 0.75);
          canvas.drawCircle(Offset(fx, fy), 6.0, flowerPaint);
          canvas.drawCircle(Offset(fx, fy), 2.5, flowerCenterPaint);
        }
      }

      // Hanging Red Apples & Golden Fruits (from Day 50+)
      if (completedDays >= 50) {
        final fruitCount = math.min(2 + ((completedDays - 50) ~/ 3), 16);
        final applePaint = Paint()..color = const Color(0xFFDC2626);
        final goldFruitPaint = Paint()..color = const Color(0xFFFFD700);
        for (int i = 0; i < fruitCount; i++) {
          final isGold = (i % 4 == 0);
          final fAngle = (i * (math.pi * 1.7 / fruitCount)) + 0.6;
          final fDist = mainRadius * 0.55;
          final ax = trunkTopX + math.cos(fAngle) * fDist;
          final ay = (trunkTopY - mainRadius * 0.25) + math.sin(fAngle) * (fDist * 0.65) + 8;
          canvas.drawCircle(Offset(ax, ay), 7.0, isGold ? goldFruitPaint : applePaint);
          // Fruit shine highlight
          final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
          canvas.drawCircle(Offset(ax - 2, ay - 2), 2.0, shinePaint);
        }
      }

      // Fireflies Aura (from Day 75+)
      if (completedDays >= 75) {
        final fireflyCount = math.min(4 + ((completedDays - 75) ~/ 3), 16);
        final fireflyPaint = Paint()..color = const Color(0xFFFDE047);
        for (int i = 0; i < fireflyCount; i++) {
          final fx = trunkTopX + math.sin(_tick * 1.4 + i * 1.2) * (mainRadius * 1.25);
          final fy = trunkTopY - 20 + math.cos(_tick * 1.1 + i * 0.9) * (mainRadius * 0.9);
          canvas.drawCircle(Offset(fx, fy), 3.5, fireflyPaint);
        }
      }

      // Royal Golden Crown & Rainbow Aura (from Day 100+)
      if (completedDays >= 100) {
        final crownPaint = Paint()..color = const Color(0xFFFFD700);
        final crownCenter = Offset(trunkTopX, trunkTopY - mainRadius * 1.45);
        canvas.drawCircle(crownCenter, 18, crownPaint);

        // Rainbow aura ring
        final auraPaint = Paint()
          ..shader = const SweepGradient(
            colors: [
              Color(0xFFFF2D55),
              Color(0xFFFF9500),
              Color(0xFFFFCC00),
              Color(0xFF34C759),
              Color(0xFF007AFF),
              Color(0xFFAF52DE),
              Color(0xFFFF2D55),
            ],
          ).createShader(Rect.fromCircle(center: crownCenter, radius: 26))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        canvas.drawCircle(crownCenter, 26, auraPaint);
      }
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
                        : completedDaysCount <= 10
                            ? "🌱 Day $completedDaysCount Sprout: Tender green stem shooting up ($completedDaysCount% grown)!"
                            : completedDaysCount <= 30
                                ? "🌿 Day $completedDaysCount Young Sapling: Wooden trunk & side branches sprouting ($completedDaysCount% grown)!"
                                : completedDaysCount <= 60
                                    ? "🌸 Day $completedDaysCount Blooming Tree: Fresh flowers blossoming ($completedDaysCount% grown)!"
                                    : completedDaysCount <= 100
                                        ? "🍎 Day $completedDaysCount Fruit Tree: Sweet red apples & golden fruits hanging ($completedDaysCount% grown)!"
                                        : "👑 Day $completedDaysCount Ancient Wisdom Tree: Royal Golden Crown ($completedDaysCount Days Conquered)!",
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
