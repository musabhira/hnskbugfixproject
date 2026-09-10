import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/signal_hunt_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/signal_hunt_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('📡 Level 5: Mission 05 Signal Hunt Curriculum Tests', () {
    test('Level 5 curriculum has exactly 10 challenges and correct title', () {
      expect(kMission05SignalHuntData.challenges.length, equals(10));
      expect(kMission05SignalHuntData.levelNumber, equals(5));
      expect(kMission05SignalHuntData.title, equals('Signal Hunt'));
      expect(
        kMission05SignalHuntData.tagline,
        equals('Listen carefully. Find the signal. Make the right move.'),
      );
    });

    test('All 17 target vocabulary terms are defined', () {
      final expectedVocab = [
        'appointment',
        'entrance',
        'receptionist',
        'available',
        'meeting',
        'manager',
        'schedule',
        'instead',
        'collect',
        'ticket',
        'information',
        'floor',
        'outside',
        'early',
        'later',
        'message',
        'confirm',
      ];
      expect(kMission05SignalHuntData.targetVocabulary.length, equals(17));
      expect(kMission05SignalHuntData.targetVocabulary, containsAll(expectedVocab));
    });

    test('All 5 Communication Hub zones are defined with boundaries', () {
      expect(kMission05SignalHuntData.zones.length, equals(5));
      final zoneIds = kMission05SignalHuntData.zones.map((z) => z.id).toList();
      expect(
        zoneIds,
        containsAll([
          'street',
          'cafe',
          'building_entrance',
          'information_desk',
          'executive_corridor',
        ]),
      );
    });

    test('Challenge 1 is Listen and Move to building on left', () {
      final c1 = kMission05SignalHuntData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.type, equals(SignalHuntChallengeType.listenAndMove));
      expect(c1.audio.spokenText, contains('building on your left'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Building on your left'));
    });

    test('Challenge 2 verifies Key Information for 2:30 PM in Room 204', () {
      final c2 = kMission05SignalHuntData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.type, equals(SignalHuntChallengeType.keyInformation));
      expect(c2.audio.spokenText, contains('two-thirty in Room 204'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('2:30 PM in Room 204'));
    });

    test('Challenge 3 is Phone Call appointment day change', () {
      final c3 = kMission05SignalHuntData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(SignalHuntChallengeType.phoneCall));
      expect(c3.audio.spokenText, contains('Thursday instead of Friday'));
      final correctOpt = c3.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('The day'));
    });

    test('Challenge 4 is Listen for the Number 78 with ticket options', () {
      final c4 = kMission05SignalHuntData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.type, equals(SignalHuntChallengeType.numberListening));
      expect(c4.targetNumber, equals(78));
      expect(c4.ticketOptions, equals([68, 71, 78, 87]));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Ticket 78'));
    });

    test('Challenge 5 is Café item selection for chicken sandwich and water', () {
      final c5 = kMission05SignalHuntData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.type, equals(SignalHuntChallengeType.itemSelection));
      expect(c5.targetItems, containsAll(['Chicken sandwich', 'Bottle of water']));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Chicken sandwich and Bottle of water'));
    });

    test('Challenge 6 is natural Conversation Response', () {
      final c6 = kMission05SignalHuntData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.type, equals(SignalHuntChallengeType.conversationResponse));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Sure. What do you need help with?'));
    });

    test('Challenge 7 is Listening Memory for Room 204', () {
      final c7 = kMission05SignalHuntData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(SignalHuntChallengeType.listeningMemory));
      final correctOpt = c7.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Outside Room 204'));
    });

    test('Challenge 8 is Distraction Test with 6:00 PM close time', () {
      final c8 = kMission05SignalHuntData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(SignalHuntChallengeType.distractionTest));
      expect(c8.hasBackgroundNoise, isTrue);
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('6:00 PM'));
    });

    test('Challenge 9 is Fast Decision with 6-second timer', () {
      final c9 = kMission05SignalHuntData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.type, equals(SignalHuntChallengeType.fastDecision));
      expect(c9.timeLimitSeconds, equals(6));
      final correctOpt = c9.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('OFFICE ENTRANCE'));
    });

    test('Challenge 10 is Signal Master final mission with Yes I am response', () {
      final c10 = kMission05SignalHuntData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(SignalHuntChallengeType.signalMaster));
      expect(c10.xpReward, equals(50));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Yes, I am.'));
    });
  });

  group('🎮 SignalHuntGamePage Widget Tests', () {
    testWidgets('Renders minimal AppBar, audio speed toggle, and Challenge 1 HUD',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignalHuntGamePage(),
        ),
      );

      // Verify clean AppBar title without overflow
      expect(find.text('Signal Hunt'), findsOneWidget);

      // Verify Audio Speed control
      expect(find.text('1.0x'), findsOneWidget);

      // Verify HUD Signal 1 indicator
      expect(find.text('SIGNAL 1 / 10'), findsOneWidget);

      // Verify Walk direction controls
      expect(find.text('WALK LEFT'), findsOneWidget);
      expect(find.text('WALK RIGHT'), findsOneWidget);
    });
  });
}
