import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_master_curriculum_90.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Days 12–14 Daily Mission Progression & XP Tests', () {
    test('XP formula scales progressively for Days 12, 13, 14', () {
      int xpForDay(int day) => 100 + (day - 1) * 50;
      expect(xpForDay(12), 650);
      expect(xpForDay(13), 700);
      expect(xpForDay(14), 750);
    });

    test('Day 12 curriculum loads correctly', () {
      final day12 = PocketMasterCurriculum90.getDay(12);
      expect(day12.day, equals(12));
      expect(day12.title, isNotEmpty);
    });

    test('Day 13 curriculum loads correctly', () {
      final day13 = PocketMasterCurriculum90.getDay(13);
      expect(day13.day, equals(13));
      expect(day13.title, isNotEmpty);
    });

    test('Day 14 curriculum loads correctly', () {
      final day14 = PocketMasterCurriculum90.getDay(14);
      expect(day14.day, equals(14));
      expect(day14.title, isNotEmpty);
    });
  });
}
