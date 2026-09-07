import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_daily_mission_page.dart';

void main() {
  group('Audio 10 Requirements: Attack Gating & Subtasks', () {
    test('Attack is locked on Days 1-3, unlocked at Day 4+', () {
      expect(PocketFortressDefenseService.canUserAttack(1), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(2), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(3), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(4), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(10), isTrue);
    });

    test('Attacker at Level 4 targets Level 5 or 6 citadels', () {
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 5), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 6), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 4), isFalse);
    });

    test('Supported translation languages contains all key languages', () {
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Malayalam'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Tamil'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Hindi'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Telugu'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('Kannada'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels.containsKey('English'), isTrue);
      expect(PocketDailyMissionPage.kLanguageLabels['Malayalam'], equals('മലയാളം'));
      expect(PocketDailyMissionPage.kSupportedLanguages.contains('Malayalam'), isTrue);
      expect(PocketDailyMissionPage.kSupportedLanguages.contains('Tamil'), isTrue);
      expect(PocketDailyMissionPage.kSupportedLanguages.contains('Hindi'), isTrue);
    });
  });
}
