import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/flame_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/flame_profile_banner_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('All 90 days have unique animal species and valid configs', () {
    final speciesSet = <String>{};
    for (int day = 1; day <= 90; day++) {
      final config = VectorAvatarConfig.getEvolutionAvatarForStage(day);
      expect(config.species, isNotEmpty);
      expect(config.rarityTier, isNotEmpty);
      expect(speciesSet.contains(config.species), isFalse,
          reason: 'Duplicate species found at day $day: ${config.species}');
      speciesSet.add(config.species);
    }
    expect(speciesSet.length, equals(90));
  });

  test('All 90 avatars paint without error in VectorAvatarPainter', () {
    for (int day = 1; day <= 90; day++) {
      final config = VectorAvatarConfig.getEvolutionAvatarForStage(day);
      final painter = VectorAvatarPainter(config: config);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(120, 120));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    }
  });

  test('All 90 avatars run through FlameAvatarGame without error', () {
    for (int day = 1; day <= 90; day++) {
      final config = VectorAvatarConfig.getEvolutionAvatarForStage(day);
      final game = FlameAvatarGame(config: config);
      game.onGameResize(Vector2(120, 120));
      game.update(0.016);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      game.render(canvas);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    }
  });

  test('All 90 days have distinct banner decorations in VectorAvatarConfig', () {
    final bannerSet = <String>{};
    for (int day = 1; day <= 90; day++) {
      final decoration = VectorAvatarConfig.getEvolutionBannerDecoration(day);
      expect(decoration, isNotNull);
      expect(decoration.gradient, isNotNull);
      final gradient = decoration.gradient as LinearGradient;
      final key = '${gradient.colors.map((c) => c.toARGB32()).join('-')}';
      bannerSet.add(key);
    }
    // Across 90 days, there should be dozens of distinct custom animal color palettes
    expect(bannerSet.length, greaterThanOrEqualTo(70));
  });

  test('StageBannerArtPainter paints all 90 days without error', () {
    for (int day = 1; day <= 90; day++) {
      final painter = StageBannerArtPainter(stage: day, baseColor: const Color(0xFF00F0FF));
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 200));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    }
  });

  test('Fortress defense trap templates contain 100% English and zero Malayalam', () {
    final malayalamRegex = RegExp(r'[\u0D00-\u0D7F]');
    for (final trap in kDefenseTrapTemplates) {
      expect(malayalamRegex.hasMatch(trap.title), isFalse, reason: 'Trap title must be English: ${trap.title}');
      expect(malayalamRegex.hasMatch(trap.titleMalayalam), isFalse, reason: 'Trap descriptor must be English: ${trap.titleMalayalam}');
      expect(malayalamRegex.hasMatch(trap.description), isFalse, reason: 'Trap description must be English: ${trap.description}');
    }
  });

  test('All 90 days have unique and functional in-game fortress perks', () {
    final titlesSet = <String>{};
    final perkTypeCounts = <PerkType, int>{};
    final malayalamRegex = RegExp(r'[\u0D00-\u0D7F]');

    for (int day = 1; day <= 90; day++) {
      final perk = VectorAvatarConfig.getAvatarPerkForDay(day);
      expect(perk.day, equals(day));
      expect(perk.title, isNotEmpty);
      expect(perk.description, isNotEmpty);
      expect(perk.icon, isNotEmpty);
      expect(perk.bonusValue, greaterThan(0));
      expect(perk.shortBadgeText, isNotEmpty);
      expect(titlesSet.contains(perk.title), isFalse, reason: 'Duplicate perk title at day $day: ${perk.title}');
      titlesSet.add(perk.title);

      // Verify 100% English
      expect(malayalamRegex.hasMatch(perk.title), isFalse, reason: 'Perk title must be 100% English: ${perk.title}');
      expect(malayalamRegex.hasMatch(perk.description), isFalse, reason: 'Perk description must be 100% English: ${perk.description}');

      perkTypeCounts[perk.perkType] = (perkTypeCounts[perk.perkType] ?? 0) + 1;
    }

    expect(titlesSet.length, equals(90));
    // Verify all 7 perk categories are utilized across the 90 companions
    for (final type in PerkType.values) {
      expect(perkTypeCounts.containsKey(type), isTrue, reason: 'Category $type must be represented across 90 avatars');
      expect(perkTypeCounts[type]!, greaterThanOrEqualTo(5));
    }
  });

  test('Specific milestone avatars grant user-requested perks (Iron Dome, Knights, etc.)', () {
    // Day 8 Kodiak Bear grants Iron Dome
    final bearPerk = VectorAvatarConfig.getAvatarPerkForDay(8);
    expect(bearPerk.perkType, equals(PerkType.ironDome));

    // Day 12 Starlight Unicorn grants Tier 2 Iron Dome
    final unicornPerk = VectorAvatarConfig.getAvatarPerkForDay(12);
    expect(unicornPerk.perkType, equals(PerkType.ironDome));
    expect(unicornPerk.bonusValue, equals(2));

    // Day 30 Celestial Dragon grants Tier 3 Iron Dome
    final dragonPerk = VectorAvatarConfig.getAvatarPerkForDay(30);
    expect(dragonPerk.perkType, equals(PerkType.ironDome));
    expect(dragonPerk.bonusValue, equals(3));

    // Day 4 Bengal Tiger & Day 20 Silverback Titan grant Army Knights
    final tigerPerk = VectorAvatarConfig.getAvatarPerkForDay(4);
    expect(tigerPerk.perkType, equals(PerkType.armyKnights));
    final titanPerk = VectorAvatarConfig.getAvatarPerkForDay(20);
    expect(titanPerk.perkType, equals(PerkType.armyKnights));

    // Day 1 Cyber Cat grants FDC Boost
    final catPerk = VectorAvatarConfig.getAvatarPerkForDay(1);
    expect(catPerk.perkType, equals(PerkType.fdcBoost));

    // Day 3 Shadow Wolf grants Siege Damage
    final wolfPerk = VectorAvatarConfig.getAvatarPerkForDay(3);
    expect(wolfPerk.perkType, equals(PerkType.siegeDamage));
  });

  test('FlameProfileBannerGame runs game loop and renders floating doodles for all 90 days', () {
    for (int day = 1; day <= 90; day++) {
      final config = VectorAvatarConfig.getEvolutionAvatarForStage(day);
      final bannerGame = FlameProfileBannerGame(config: config, stage: day);
      bannerGame.onGameResize(Vector2(400, 200));
      bannerGame.onMount();
      bannerGame.update(0.016);
      bannerGame.update(0.016);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      bannerGame.render(canvas);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    }
  });

  test('PocketFortressDefenseService applies companion avatar perks to house status', () async {
    // Stage 8 has Day 8 Kodiak Bear -> Free Tier 1 Iron Dome
    final status8 = await PocketFortressDefenseService.getHouseStatus(8);
    expect(status8.hasIronDome, isTrue);
    expect(status8.ironDomeTier, greaterThanOrEqualTo(1));
    expect(status8.activePerk, isNotNull);
    expect(status8.activePerk!.title, contains('Kodiak Iron Dome'));

    // Stage 4 has Day 4 Royal Bengal Tiger -> Stationed Knights augmented
    final status4 = await PocketFortressDefenseService.getHouseStatus(4);
    expect(status4.armyKnightsCount, greaterThanOrEqualTo(2));
    expect(status4.activePerk!.title, contains('Royal Bengal'));
  });

  test('FlameProfileBannerGame generates diverse atmospheric weather types across biomes', () {
    final weatherCounts = <BannerWeatherType, int>{};
    for (int day = 1; day <= 90; day++) {
      final config = VectorAvatarConfig.getEvolutionAvatarForStage(day);
      final bannerGame = FlameProfileBannerGame(config: config, stage: day);
      final weather = bannerGame.getWeatherType();
      weatherCounts[weather] = (weatherCounts[weather] ?? 0) + 1;

      // Ensure game loop runs and renders with active weather particles
      bannerGame.onGameResize(Vector2(400, 200));
      bannerGame.onMount();
      for (int f = 0; f < 10; f++) {
        bannerGame.update(0.05);
      }
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      bannerGame.render(canvas);
      final pic = recorder.endRecording();
      expect(pic, isNotNull);
    }

    // Verify multiple diverse weather types are actively used
    expect(weatherCounts[BannerWeatherType.rain], greaterThan(0));
    expect(weatherCounts[BannerWeatherType.fireEmbers], greaterThan(0));
    expect(weatherCounts[BannerWeatherType.sakuraPetals], greaterThan(0));
    expect(weatherCounts[BannerWeatherType.cosmicStardust], greaterThan(0));
    expect(weatherCounts[BannerWeatherType.bioluminescentBubbles], greaterThan(0));
  });
}
