import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';

/// 🏡 Dedicated Avatar House Widget for Kids Mode
/// Uses the exact same Flame architectural rendering engine as the adult app,
/// with chimney smoke, animated windows, and progressive stages across Days 1–100.
class PocketAvatarHouseWidget extends StatelessWidget {
  final int day;
  final double width;
  final double height;
  final bool isDamaged;
  final bool isPresident;
  final bool lightsOn;

  const PocketAvatarHouseWidget({
    super.key,
    required this.day,
    this.width = 160,
    this.height = 140,
    this.isDamaged = false,
    this.isPresident = false,
    this.lightsOn = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _KidAvatarHousePainter(
          day: day,
          isDamaged: isDamaged,
          isPresident: isPresident,
          lightsOn: lightsOn,
        ),
      ),
    );
  }
}

class _KidAvatarHousePainter extends CustomPainter {
  final int day;
  final bool isDamaged;
  final bool isPresident;
  final bool lightsOn;
  late final HouseMasterComponent _comp;

  _KidAvatarHousePainter({
    required this.day,
    this.isDamaged = false,
    this.isPresident = false,
    this.lightsOn = true,
  }) {
    // 🏰 Progressive Palettes: Days 91–100 get progressive majestic themes!
    HousePalette effectivePalette = HousePalette.presets[0];
    if (day >= 90) {
      // Days 91–100 cycle through Royal Gold, Luxury Mirror Glass, Emerald, Cyber Yellow, and Sakura
      final highTierPalettes = [
        HousePalette.presets[3], // 👑 Royal Grandmaster (Gold/Purple)
        HousePalette.presets[2], // 💎 Luxury Mirror Glass (Sapphire/Azure)
        HousePalette.presets[4], // 🌲 Emerald Pine Lodge
        HousePalette.presets[1], // ⚡ Profile Neon Yellow
        HousePalette.presets[5], // 🌸 Rose Blossom
      ];
      effectivePalette = highTierPalettes[(day - 90) % highTierPalettes.length];
    }

    // Days 95–100 unlock Presidential Storey & Grand Citadel apex automatically!
    final bool effectivePresident = isPresident || (day >= 95);

    _comp = HouseMasterComponent(
      day: day.clamp(1, 100),
      streak: 1,
      palette: effectivePalette,
      isDamaged: isDamaged,
      isPresident: effectivePresident,
    )..lightsOn = lightsOn;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _comp.resize(Vector2(size.width, size.height));
    _comp.render(canvas);
  }

  @override
  bool shouldRepaint(covariant _KidAvatarHousePainter oldDelegate) {
    return oldDelegate.day != day ||
        oldDelegate.isDamaged != isDamaged ||
        oldDelegate.lightsOn != lightsOn;
  }
}
