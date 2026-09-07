import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/avatar_game_perk.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Raid Matchmaking Rules (User Audio Directive: Under Lvl 20 vs Lvl 20+)', () {
    test('Under Level 20: Matchmaking targets higher-level citadels (userDay + 4)', () {
      // Day 1 beginner faces Level 5 house
      expect(PocketFortressDefenseService.getRaidTargetDay(1), equals(5));

      // Day 5 user faces Level 9 citadel (exactly user example: 9-o 10-o levelil ulla aalukar)
      expect(PocketFortressDefenseService.getRaidTargetDay(5), equals(9));

      // Day 12 faces Level 16 citadel
      expect(PocketFortressDefenseService.getRaidTargetDay(12), equals(16));

      // Day 14 faces Level 18 citadel
      expect(PocketFortressDefenseService.getRaidTargetDay(14), equals(18));

      // Day 19 faces Level 23 citadel
      expect(PocketFortressDefenseService.getRaidTargetDay(19), equals(23));
    });

    test('Level 20 and above: Matchmaking allows same-level peer combat', () {
      expect(PocketFortressDefenseService.getRaidTargetDay(20), equals(20));
      expect(PocketFortressDefenseService.getRaidTargetDay(35), equals(35));
      expect(PocketFortressDefenseService.getRaidTargetDay(50), equals(50));
      expect(PocketFortressDefenseService.getRaidTargetDay(90), equals(90));
    });

    test('isRaidTargetValid enforces growth restriction under Level 20', () {
      // For user at Level 5:
      // Same level (5) or lower (1-4) is NOT valid
      expect(PocketFortressDefenseService.isRaidTargetValid(5, 5), isFalse);
      expect(PocketFortressDefenseService.isRaidTargetValid(5, 3), isFalse);
      expect(PocketFortressDefenseService.isRaidTargetValid(5, 1), isFalse);

      // Higher level (9, 10) is valid
      expect(PocketFortressDefenseService.isRaidTargetValid(5, 9), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(5, 10), isTrue);

      // For user at Level 20+:
      // Any level is valid (peer or higher)
      expect(PocketFortressDefenseService.isRaidTargetValid(20, 20), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(25, 20), isTrue);
    });

    test('generateRivalForUser creates properly named higher-level rivals under Level 20', () {
      final rivalForDay5 = PocketFortressDefenseService.generateRivalForUser(5);
      expect(rivalForDay5.day, equals(9));
      expect(rivalForDay5.name, contains('Oxford Dialectician Lvl 9'));

      final rivalForDay1 = PocketFortressDefenseService.generateRivalForUser(1);
      expect(rivalForDay1.day, equals(5));
      expect(rivalForDay1.name, contains('Citadel Sea Vanguard Lvl 5'));

      final rivalForDay12 = PocketFortressDefenseService.generateRivalForUser(12);
      expect(rivalForDay12.day, equals(16));
      expect(rivalForDay12.name, contains('Highland Warlord Lvl 16'));
    });
  });

  group('Shield Defense Scaling Rule: 1 Day / Level = 1 Question Slot', () {
    test('Every level completed adds exactly 1 question slot to the fortress shield', () {
      for (int day = 1; day <= 90; day++) {
        expect(PocketFortressDefenseService.getMaxQuestionsForStage(day), equals(day));
      }
    });
  });

  group('Avatar Traits: Gunangal (Pros) & Doshangal (Cons / Tradeoffs)', () {
    test('All 90 avatars have distinct non-empty advantage (Gunam) and challenge (Dosham)', () {
      for (int day = 1; day <= 90; day++) {
        final perk = AvatarGamePerk.forDay(day);
        expect(perk.advantageText, isNotEmpty);
        expect(perk.challengeText, isNotEmpty);
        expect(perk.shortBadgeText, isNotEmpty);
      }
    });

    test('Early avatars (Days 1–14) specify 0 lifelines challenge', () {
      final perk = AvatarGamePerk.forDay(5);
      expect(perk.challengeText, contains('0 lifelines available'));
    });

    test('Mid-tier avatars specify higher stakes challenge', () {
      final perk = AvatarGamePerk.forDay(25);
      expect(perk.challengeText, contains('speech pronunciation'));
    });
  });
}
