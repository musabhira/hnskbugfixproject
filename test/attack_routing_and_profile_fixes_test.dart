import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_daily_mission_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

void main() {
  group('Attack Routing & Terminology Tests', () {
    test('PocketFortressDefenseService rules remain consistent', () {
      // Days 1-3 locked, Day 4+ unlocked
      expect(PocketFortressDefenseService.canUserAttack(1), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(2), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(3), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(4), isTrue);
    });

    test('PocketWorldStreetPage accepts autoRollRaid and day streak parameters', () {
      const page = PocketWorldStreetPage(
        currentDay: 5,
        streak: 5,
        autoRollRaid: true,
      );
      expect(page.currentDay, equals(5));
      expect(page.streak, equals(5));
      expect(page.autoRollRaid, isTrue);
    });

    test('Language labels and supported languages on PocketDailyMissionPage remain intact', () {
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Malayalam'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels['Malayalam'], equals('മലയാളം'));
      expect(PocketDailyMissionPage.kSupportedLanguages.contains('Malayalam'), isTrue);
    });
  });
}
