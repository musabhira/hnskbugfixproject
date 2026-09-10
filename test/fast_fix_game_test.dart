import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/fast_fix_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/fast_fix_game_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('⚡ Level 8: Mission 08 Fast Fix Curriculum Tests', () {
    test('Level 8 curriculum has exactly 10 challenges and correct title', () {
      expect(kMission08FastFixData.challenges.length, equals(10));
      expect(kMission08FastFixData.missionId, equals('08'));
      expect(kMission08FastFixData.title, equals('Mission 08 – Fast Fix'));
      expect(kMission08FastFixData.tagline,
          equals('Spot the mistake. Fix the English. Save the day.'));
    });

    test('All 20 target vocabulary terms are defined', () {
      expect(kMission08FastFixData.targetVocabulary.length, equals(20));
      expect(kMission08FastFixData.targetVocabulary, contains('updated'));
      expect(kMission08FastFixData.targetVocabulary, contains('confirm'));
      expect(kMission08FastFixData.targetVocabulary, contains('report'));
      expect(kMission08FastFixData.targetVocabulary, contains('appointment'));
      expect(kMission08FastFixData.targetVocabulary, contains('deadline'));
      expect(kMission08FastFixData.targetVocabulary, contains('repair'));
      expect(kMission08FastFixData.targetVocabulary, contains('restore'));
    });

    test('All 5 Operations Facility Zones are configured', () {
      expect(kMission08FastFixData.zones.length, equals(5));
      final zoneIds = kMission08FastFixData.zones.map((z) => z.id).toList();
      expect(zoneIds, contains('reception'));
      expect(zoneIds, contains('customer_desk'));
      expect(zoneIds, contains('office'));
      expect(zoneIds, contains('info_room'));
      expect(zoneIds, contains('control_center'));
    });

    test('Challenge 1 spots preposition and tense error (since -> for)', () {
      final c1 = kMission08FastFixData.challenges[0];
      expect(c1.type, equals(FastFixChallengeType.spotError));
      expect(c1.terminalCode, equals('TERM-01'));
      expect(c1.correctOption.text,
          equals('“I have been working here for two years.”'));
      expect(c1.correctOption.isCorrect, isTrue);
    });

    test('Challenge 2 verifies base verb send after modal could', () {
      final c2 = kMission08FastFixData.challenges[1];
      expect(c2.type, equals(FastFixChallengeType.missingWord));
      expect(c2.terminalCode, equals('TERM-02'));
      expect(c2.correctOption.text, equals('send'));
      expect(c2.correctOption.isCorrect, isTrue);
    });

    test('Challenge 3 verifies workplace word choice confirm', () {
      final c3 = kMission08FastFixData.challenges[2];
      expect(c3.type, equals(FastFixChallengeType.wordChoice));
      expect(c3.terminalCode, equals('TERM-03'));
      expect(c3.correctOption.text, equals('confirm'));
      expect(c3.correctOption.isCorrect, isTrue);
    });

    test('Challenge 4 verifies infinitive marker to in would like to', () {
      final c4 = kMission08FastFixData.challenges[3];
      expect(c4.type, equals(FastFixChallengeType.messageRepair));
      expect(c4.terminalCode, equals('TERM-04'));
      expect(c4.correctOption.text, equals('to'));
      expect(c4.correctOption.isCorrect, isTrue);
    });

    test('Challenge 5 fixes subject-verb agreement (don’t -> doesn’t)', () {
      final c5 = kMission08FastFixData.challenges[4];
      expect(c5.type, equals(FastFixChallengeType.grammarTerminal));
      expect(c5.terminalCode, equals('TERM-05'));
      expect(c5.correctOption.text,
          equals('She doesn’t have enough information.'));
      expect(c5.correctOption.isCorrect, isTrue);
    });

    test('Challenge 6 chooses natural workplace reply', () {
      final c6 = kMission08FastFixData.challenges[5];
      expect(c6.type, equals(FastFixChallengeType.naturalResponse));
      expect(c6.terminalCode, equals('TERM-06'));
      expect(c6.correctOption.text, equals('“Sure. Let me take a look.”'));
      expect(c6.correctOption.isCorrect, isTrue);
    });

    test('Challenge 7 matches and delivers Updated Report to Sarah', () {
      final c7 = kMission08FastFixData.challenges[6];
      expect(c7.type, equals(FastFixChallengeType.documentDelivery));
      expect(c7.terminalCode, equals('TERM-07'));
      expect(c7.documentChoices, isNotNull);
      final targetDoc = c7.documentChoices!.firstWhere((d) => d.isTarget);
      expect(targetDoc.title, equals('Updated Operations Report'));
      expect(targetDoc.recipient, equals('Sarah'));
      expect(c7.correctOption.text, contains('Updated Operations Report'));
    });

    test('Challenge 8 has 5 sentences with error diagnostic accuracy', () {
      final c8 = kMission08FastFixData.challenges[7];
      expect(c8.type, equals(FastFixChallengeType.speedRepair));
      expect(c8.timeLimitSeconds, equals(30));
      expect(c8.speedSentences, isNotNull);
      expect(c8.speedSentences!.length, equals(5));
      final errorItems = c8.speedSentences!.where((s) => s.hasError).toList();
      expect(errorItems.length, equals(3));
    });

    test('Challenge 9 corrects listening tense from have sent to sent', () {
      final c9 = kMission08FastFixData.challenges[8];
      expect(c9.type, equals(FastFixChallengeType.listenAndCorrect));
      expect(c9.terminalCode, equals('TERM-09'));
      expect(c9.correctOption.text,
          equals('“I sent the document yesterday.”'));
      expect(c9.correctOption.isCorrect, isTrue);
    });

    test('Challenge 10 defines 6-part override diagnostics in 60 seconds', () {
      final c10 = kMission08FastFixData.challenges[9];
      expect(c10.type, equals(FastFixChallengeType.systemOverride));
      expect(c10.timeLimitSeconds, equals(60));
      expect(c10.overrideProblems, isNotNull);
      expect(c10.overrideProblems!.length, equals(6));
      expect(c10.overrideProblems![0].correctAnswer, equals('meets'));
      expect(c10.overrideProblems![1].correctAnswer, equals('at'));
    });
  });

  group('🎮 FastFixGamePage Widget Tests', () {
    testWidgets('Renders clean non-overflowing AppBar, Terminal HUD, and Controls',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: FastFixGamePage(
            levelData: kMission08FastFixData,
          ),
        ),
      );

      await tester.pump();

      // Verify minimal AppBar
      expect(find.text('Fast Fix'), findsOneWidget);
      expect(find.byIcon(Icons.build_circle_rounded), findsOneWidget);

      // Verify Terminal HUD
      expect(find.text('TERM-01'), findsOneWidget);
      expect(find.textContaining('Reception Terminal'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // Verify Walk Controls
      expect(find.text('WALK LEFT'), findsOneWidget);
      expect(find.text('WALK RIGHT'), findsOneWidget);

      // Verify Challenge 1 Options
      expect(find.text('“I have been working here for two years.”'),
          findsOneWidget);
    });
  });
}
