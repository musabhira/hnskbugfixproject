import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/lost_package_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/lost_package_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('📦 Level 6: Mission 06 The Lost Package Curriculum Tests', () {
    test('Level 6 curriculum has exactly 10 challenges and target reference PK-4827', () {
      expect(kMission06LostPackageData.challenges.length, equals(10));
      expect(kMission06LostPackageData.levelNumber, equals(6));
      expect(kMission06LostPackageData.title, equals('The Lost Package'));
      expect(kMission06LostPackageData.targetReference, equals('PK-4827'));
    });

    test('All 20 target vocabulary terms are defined', () {
      final expectedVocab = [
        'package',
        'delivery',
        'collection',
        'reference',
        'recipient',
        'address',
        'reception',
        'locker',
        'label',
        'building',
        'floor',
        'available',
        'deadline',
        'confirm',
        'valid',
        'document',
        'code',
        'notice',
        'pick up',
        'return',
      ];
      expect(kMission06LostPackageData.targetVocabulary.length, equals(20));
      expect(kMission06LostPackageData.targetVocabulary, containsAll(expectedVocab));
    });

    test('Storage depot contains 4 parcel packages including target PK-4827', () {
      final packages = kMission06LostPackageData.storagePackages;
      expect(packages.length, equals(4));
      final refs = packages.map((p) => p.referenceNumber).toList();
      expect(refs, containsAll(['PK-4817', 'PK-4827', 'PK-4872', 'PK-4287']));
      final target = packages.firstWhere((p) => p.isTargetPackage);
      expect(target.referenceNumber, equals('PK-4827'));
      expect(target.recipientName, equals('Alex Morgan'));
    });

    test('Challenge 1 verifies address reading for Building B, Second Floor', () {
      final c1 = kMission06LostPackageData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.type, equals(LostPackageChallengeType.addressReading));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Building B, Second Floor'));
    });

    test('Challenge 2 verifies package search for PK-4827', () {
      final c2 = kMission06LostPackageData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.type, equals(LostPackageChallengeType.packageSearch));
      expect(c2.targetReference, equals('PK-4827'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('PK-4827'));
    });

    test('Challenge 3 verifies information scan for collection before 6:00 PM', () {
      final c3 = kMission06LostPackageData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(LostPackageChallengeType.informationScan));
      final correctOpt = c3.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Before 6:00 PM'));
    });

    test('Challenge 4 verifies message investigation for reception desk and valid ID', () {
      final c4 = kMission06LostPackageData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.type, equals(LostPackageChallengeType.messageComprehension));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Reception desk'));
      expect(correctOpt.text, contains('Valid ID'));
    });

    test('Challenge 5 verifies natural NPC conversation response', () {
      final c5 = kMission06LostPackageData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.type, equals(LostPackageChallengeType.npcResponse));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Yes, I’m here to collect a package'));
    });

    test('Challenge 6 spots the mismatch in PK-4872 vs PK-4827', () {
      final c6 = kMission06LostPackageData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.type, equals(LostPackageChallengeType.mismatchDetection));
      expect(c6.mismatchReference, equals('PK-4872'));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('last two digits are swapped'));
    });

    test('Challenge 7 evaluates schedule window for 4:30 PM and 8:00 PM', () {
      final c7 = kMission06LostPackageData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(LostPackageChallengeType.timeReading));
      final correctOpt = c7.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Yes at 4:30 PM'));
      expect(correctOpt.text, contains('No at 8:00 PM'));
    });

    test('Challenge 8 selects contingency action to leave at reception', () {
      final c8 = kMission06LostPackageData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(LostPackageChallengeType.instructionAction));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Leave it at reception'));
    });

    test('Challenge 9 defines contextual meaning of collect as Pick up', () {
      final c9 = kMission06LostPackageData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.type, equals(LostPackageChallengeType.contextVocabulary));
      final correctOpt = c9.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Pick up'));
    });

    test('Challenge 10 unlocks Locker 24 with PIN code 7316', () {
      final c10 = kMission06LostPackageData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(LostPackageChallengeType.lockerCode));
      expect(c10.targetLockerNumber, equals(24));
      expect(c10.targetLockerCode, equals('7316'));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('7316'));
    });
  });

  group('🎮 LostPackageGamePage Widget Tests', () {
    testWidgets('Renders clean non-overflowing AppBar, HUD, and Walk Controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LostPackageGamePage(),
        ),
      );

      // Verify title without overflow
      expect(find.text('The Lost Package'), findsOneWidget);

      // Verify Investigation 1 indicator
      expect(find.text('INVESTIGATION 1 / 10'), findsOneWidget);
      expect(find.text('REF: PK-4827'), findsOneWidget);

      // Verify inspect button and walk controls
      expect(find.text('INSPECT 📄'), findsOneWidget);
      expect(find.text('WALK LEFT'), findsOneWidget);
      expect(find.text('WALK RIGHT'), findsOneWidget);
    });
  });
}
