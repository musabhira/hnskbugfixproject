import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/cyber_vocab_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/cyber_vocab_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🚀 Cyber Vocab Striker (Level 2) Curriculum Tests', () {
    test('Level 2 has exactly 10 comprehensive waves', () {
      expect(kMission02VocabStrikerData.waves.length, equals(10));
      expect(kMission02VocabStrikerData.levelNumber, equals(2));
      expect(kMission02VocabStrikerData.title, equals('Cyber Vocab Striker'));
    });

    test('All 10 required high-impact vocabulary terms are present and valid', () {
      final expectedWords = [
        'NAVIGATE',
        'DESTINATION',
        'TRANSIT',
        'CONVERGE',
        'EXPEDITE',
        'CONSENSUS',
        'MILESTONE',
        'DETOUR',
        'PROXIMITY',
        'EFFICIENT',
      ];

      final allWords = kMission02VocabStrikerData.allVocabulary;
      expect(allWords.length, equals(10));

      for (int i = 0; i < expectedWords.length; i++) {
        final item = allWords[i];
        expect(item.word, equals(expectedWords[i]));
        expect(item.phonetic.startsWith('/'), isTrue);
        expect(item.phonetic.endsWith('/'), isTrue);
        expect(item.definition.isNotEmpty, isTrue);
        expect(item.malayalamMeaning.isNotEmpty, isTrue);
        expect(item.exampleSentence.isNotEmpty, isTrue);
        expect(item.category.isNotEmpty, isTrue);
      }
    });

    test('Wave 1 target is NAVIGATE with clueMatrix power-up', () {
      final w1 = kMission02VocabStrikerData.waves[0];
      expect(w1.target.word, equals('NAVIGATE'));
      expect(w1.bonusPowerUp, equals(StrikerPowerUpType.clueMatrix));
      expect(w1.distractorWords.length, equals(3));
      expect(w1.allChoices.length, equals(4));
      expect(w1.allChoices, contains('NAVIGATE'));
    });

    test('Wave 5 target is EXPEDITE with shieldBoost power-up', () {
      final w5 = kMission02VocabStrikerData.waves[4];
      expect(w5.target.word, equals('EXPEDITE'));
      expect(w5.bonusPowerUp, equals(StrikerPowerUpType.shieldBoost));
      expect(w5.cluePrompt, contains('speed up'));
    });

    test('Wave 10 target is EFFICIENT', () {
      final w10 = kMission02VocabStrikerData.waves[9];
      expect(w10.target.word, equals('EFFICIENT'));
      expect(w10.target.malayalamMeaning, contains('കാര്യക്ഷമമായ'));
    });
  });

  group('🎮 CyberVocabGamePage Widget Tests', () {
    testWidgets('Renders clean non-overflowing AppBar and Wave 1 HUD',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CyberVocabGamePage(),
        ),
      );

      // Verify title
      expect(find.text('Cyber Vocab Striker'), findsOneWidget);

      // Verify Wave 1 indicator and clue prompt
      expect(find.text('WAVE 1 / 10'), findsOneWidget);
      expect(
        find.text('To plan and direct the route of travel or find one’s way'),
        findsOneWidget,
      );

      // Verify Bottom Controls
      expect(find.text('FIRE LASER ⚡'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right_rounded), findsOneWidget);
    });
  });
}
