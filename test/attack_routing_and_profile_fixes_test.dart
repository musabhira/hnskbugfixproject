import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_daily_mission_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

void main() {
  group('Attack Routing & Terminology Tests', () {
    test('PocketFortressDefenseService rules remain consistent', () {
      // Attack is available starting from Day 1 (Audio directive: ഒന്നാമത്തെ ലെവൽ മുതൽ അറ്റാക്ക് ചെയ്യാൻ പറ്റും)
      expect(PocketFortressDefenseService.canUserAttack(1), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(2), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(3), isTrue);
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
      expect(PocketDailyMissionPage.kLanguageLabels['Malayalam'], equals('🇮🇳 മലയാളം'));
      expect(PocketDailyMissionPage.kSupportedLanguages.contains('Malayalam'), isTrue);
    });
  });
}
