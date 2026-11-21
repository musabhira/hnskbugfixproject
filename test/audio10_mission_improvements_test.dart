import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

void main() {
  group('Audio 10 Requirements: Attack Gating & Subtasks', () {
    test('Attack is unlocked from Day 1+ per audio directive', () {
      expect(PocketFortressDefenseService.canUserAttack(1), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(2), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(3), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(4), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(10), isTrue);
    });

    test('Attacker at Level 4 targets Level 5 or 6 citadels', () {
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 5), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 6), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(0, 4), isFalse);
    });

    test('Supported translation languages in PocketLanguageService remain intact', () {
      final ml = PocketLanguageService.localize(
        en: 'Feedback',
        ml: 'ഫീഡ്ബാക്ക്',
        ta: 'கருத்து',
        hi: 'फ़ीडबैक',
      );
      expect(ml, isNotEmpty);
    });
  });
}
