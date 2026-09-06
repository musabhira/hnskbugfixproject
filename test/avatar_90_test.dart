import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';

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
}
