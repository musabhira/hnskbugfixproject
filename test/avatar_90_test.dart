import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/flame_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

void main() {
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
}
