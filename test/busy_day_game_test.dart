import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/busy_day_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/busy_day_game_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🗓️ Level 7: Mission 07 The Busy Day Curriculum Tests', () {
    test('Level 7 curriculum has exactly 10 scenes and correct title', () {
      expect(kMission07BusyDayData.scenes.length, equals(10));
      expect(kMission07BusyDayData.missionId, equals('07'));
      expect(kMission07BusyDayData.title, equals('Mission 07 – The Busy Day'));
      expect(kMission07BusyDayData.tagline, equals('Your day. Your choices. Your English.'));
    });

    test('All 24 target vocabulary terms are defined', () {
      expect(kMission07BusyDayData.targetVocabulary.length, equals(24));
      expect(kMission07BusyDayData.targetVocabulary, contains('meeting'));
      expect(kMission07BusyDayData.targetVocabulary, contains('delay'));
      expect(kMission07BusyDayData.targetVocabulary, contains('route'));
      expect(kMission07BusyDayData.targetVocabulary, contains('station'));
      expect(kMission07BusyDayData.targetVocabulary, contains('folder'));
      expect(kMission07BusyDayData.targetVocabulary, contains('deadline'));
    });

    test('Initial task board defines 6 real-world quests', () {
      expect(kMission07BusyDayData.initialQuests.length, equals(6));
      final questTitles = kMission07BusyDayData.initialQuests.map((q) => q.title).toList();
      expect(questTitles, contains('Reach Central Station'));
      expect(questTitles, contains('Order lunch at Café'));
      expect(questTitles, contains('Deliver work report'));
      expect(questTitles, contains('Retrieve small blue folder'));
      expect(questTitles, contains('Attend 4:30 PM meeting'));
      expect(questTitles, contains('Send final email before 5 PM'));
    });

    test('Scene 1 verifies natural morning reply with future will', () {
      final scene = kMission07BusyDayData.scenes[0];
      expect(scene.type, equals(BusyDaySceneType.morningMessage));
      expect(scene.clockTime, equals('08:00 AM'));
      expect(scene.correctOption.text, equals("Yes, I'll be there at 9."));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 2 verifies realistic uncertainty at bus stop', () {
      final scene = kMission07BusyDayData.scenes[1];
      expect(scene.type, equals(BusyDaySceneType.busStop));
      expect(scene.clockTime, equals('08:30 AM'));
      expect(scene.correctOption.text, equals('Yes, I think so.'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 3 verifies proactive consequence decision for bus delay', () {
      final scene = kMission07BusyDayData.scenes[2];
      expect(scene.type, equals(BusyDaySceneType.delayProblem));
      expect(scene.clockTime, equals('08:45 AM'));
      expect(scene.correctOption.text, equals('Check another route.'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 4 verifies polite request for alternate train route', () {
      final scene = kMission07BusyDayData.scenes[3];
      expect(scene.type, equals(BusyDaySceneType.askForHelp));
      expect(scene.clockTime, equals('08:50 AM'));
      expect(scene.correctOption.text, equals('Excuse me, is there another way to get to Central Station?'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 5 verifies polite café ordering with courtesy words', () {
      final scene = kMission07BusyDayData.scenes[4];
      expect(scene.type, equals(BusyDaySceneType.cafeOrder));
      expect(scene.clockTime, equals('11:30 AM'));
      expect(scene.correctOption.text, equals("I’d like a coffee and a sandwich, please."));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 6 verifies constructive problem solving for wrong order', () {
      final scene = kMission07BusyDayData.scenes[5];
      expect(scene.type, equals(BusyDaySceneType.wrongOrder));
      expect(scene.clockTime, equals('11:45 AM'));
      expect(scene.correctOption.text, equals('Sorry, I ordered a coffee, not tea.'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 7 verifies workplace commitment to send report before lunch', () {
      final scene = kMission07BusyDayData.scenes[6];
      expect(scene.type, equals(BusyDaySceneType.workMessage));
      expect(scene.clockTime, equals('01:00 PM'));
      expect(scene.correctOption.text, equals('Sure. I’ll send it before lunch.'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 8 verifies collegial acknowledgement of interruption', () {
      final scene = kMission07BusyDayData.scenes[7];
      expect(scene.type, equals(BusyDaySceneType.interruption));
      expect(scene.clockTime, equals('02:30 PM'));
      expect(scene.correctOption.text, equals('Sure. What do you need?'));
      expect(scene.correctOption.quality, equals(ChoiceQuality.excellent));
    });

    test('Scene 9 includes small blue folder target', () {
      final scene = kMission07BusyDayData.scenes[8];
      expect(scene.type, equals(BusyDaySceneType.folderDetail));
      expect(scene.clockTime, equals('03:30 PM'));
      expect(scene.folderChoices, isNotNull);
      final target = scene.folderChoices!.firstWhere((f) => f.isTarget);
      expect(target.label, equals('Small Blue Folder'));
      expect(target.isSmall, isTrue);
    });

    test('Scene 10 prioritizes 4:30 PM meeting before 5:00 PM email', () {
      final scene = kMission07BusyDayData.scenes[9];
      expect(scene.type, equals(BusyDaySceneType.priorityDecision));
      expect(scene.clockTime, equals('04:00 PM'));
      expect(scene.correctOption.text,
          equals('Attend the 4:30 PM meeting first, then send the email before 5:00 PM.'));
      expect(scene.priorityTasks, isNotNull);
      expect(scene.priorityTasks!.first.correctOrder, equals(1));
    });
  });

  group('🎮 BusyDayGamePage Widget Tests', () {
    testWidgets('Renders clean non-overflowing AppBar, Clock HUD, and Walk Controls',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: BusyDayGamePage(
            levelData: kMission07BusyDayData,
          ),
        ),
      );

      await tester.pump();

      // Verify minimal AppBar
      expect(find.text('The Busy Day'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);

      // Verify Digital Clock HUD
      expect(find.text('08:00 AM'), findsOneWidget);
      expect(find.textContaining('Apartment Bedroom'), findsOneWidget);

      // Verify Walk Controls
      expect(find.text('WALK LEFT'), findsOneWidget);
      expect(find.text('WALK RIGHT'), findsOneWidget);

      // Verify Scene 1 Options
      expect(find.text("Yes, I'll be there at 9."), findsOneWidget);
    });
  });
}
