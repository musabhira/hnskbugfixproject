import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/robot_snap_dataset.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pocket Robot Voice & Malayalam Handling Tests', () {
    test('Detects pure Malayalam script', () {
      expect(PocketRobotService.isMalayalamOrManglish('ഹലോ സുഖമാണോ?'), isTrue);
      expect(PocketRobotService.isMalayalamOrManglish('എനിക്ക് മനസ്സിലായില്ല'), isTrue);
      expect(PocketRobotService.isMalayalamOrManglish('ഇംഗ്ലീഷ് പഠിക്കാൻ സഹായിക്കുമോ?'), isTrue);
    });

    test('Detects Manglish transliterated phrases', () {
      expect(PocketRobotService.isMalayalamOrManglish('nammukku english padikkam'), isTrue);
      expect(PocketRobotService.isMalayalamOrManglish('sugamano bro'), isTrue);
      expect(PocketRobotService.isMalayalamOrManglish('entha cheyyunne?'), isTrue);
      expect(PocketRobotService.isMalayalamOrManglish('evideya ullath'), isTrue);
    });

    test('Does not flag standard English sentences as Malayalam', () {
      expect(PocketRobotService.isMalayalamOrManglish('Hello! How are you doing today?'), isFalse);
      expect(PocketRobotService.isMalayalamOrManglish('Can you help me practice for IELTS speaking?'), isFalse);
      expect(PocketRobotService.isMalayalamOrManglish('Let us practice vocabulary together.'), isFalse);
    });

    test('Robot Busy check functions without crashing', () {
      final robot = PocketRobotService.getRobotByLevel(1);
      final isBusy = PocketRobotService.isRobotBusy(robot);
      expect(isBusy, isA<bool>());
    });
  });

  group('Robot Snap Dataset Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Dataset contains extensive curated snaps across 12 categories', () {
      expect(RobotSnapDataset.totalCuratedSnaps, greaterThanOrEqualTo(50));
    });

    test('Pollinations AI URL generation produces valid secure prompt URLs', () {
      final robot = PocketRobotService.getRobotByLevel(1);
      final url = RobotSnapDataset.generatePollinationsAiSnapUrl(
        robot: robot,
        themeDescription: 'cozy cafe book reading',
      );
      expect(url, startsWith('https://image.pollinations.ai/prompt/'));
      expect(url, contains('Pocket%20World'));
      expect(url, contains('seed='));
    });

    test('getUniqueSnapForRobot returns non-empty image and caption', () async {
      final robot = PocketRobotService.getRobotByLevel(5);
      final snap = await RobotSnapDataset.getUniqueSnapForRobot(
        robot: robot,
        userId: 'test_user_abc_123',
      );

      expect(snap['imageUrl'], isNotEmpty);
      expect(snap['caption'], isNotEmpty);
    });

    test('Sequential calls do not return duplicate image URLs immediately', () async {
      final robot = PocketRobotService.getRobotByLevel(1);
      const testUserId = 'duplicate_checker_user';

      final snap1 = await RobotSnapDataset.getUniqueSnapForRobot(
        robot: robot,
        userId: testUserId,
      );
      final snap2 = await RobotSnapDataset.getUniqueSnapForRobot(
        robot: robot,
        userId: testUserId,
      );

      expect(snap1['imageUrl'], isNot(equals(snap2['imageUrl'])));
    });
  });

  group('Contacts Name Normalization Tests', () {
    test('Normalizes numbers with country codes correctly', () {
      final service = ContactsNameService();
      expect(service.normalizePhoneNumber('+91 98765 43210'), equals('9876543210'));
      expect(service.normalizePhoneNumber('09876543210'), equals('9876543210'));
      expect(service.normalizePhoneNumber('(555) 123-4567'), equals('5551234567'));
    });
  });
}
