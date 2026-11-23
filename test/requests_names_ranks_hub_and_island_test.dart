import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_group_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_mates_suggested_grid_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Requests Category Name & Rank Resolution', () {
    test('resolveRealUserName never defaults to bare "Learner"', () {
      final res1 = PocketMateService.resolveRealUserName(
        userId: '12345678-abcd-ef01-2345-6789abcdef01',
        preferredName: 'Learner',
      );
      expect(res1, isNot('Learner'));
      expect(res1.startsWith('Learner'), isFalse);
      expect(res1, contains('Mate #1234'));

      final res2 = PocketMateService.resolveRealUserName(
        userId: '12345678-abcd-ef01-2345-6789abcdef01',
        preferredName: 'Learner 123456',
      );
      expect(res2, isNot('Learner 123456'));
      expect(res2.startsWith('Learner'), isFalse);

      final resReal = PocketMateService.resolveRealUserName(
        userId: '12345678-abcd-ef01-2345-6789abcdef01',
        preferredName: 'Shameer',
      );
      expect(resReal, 'Shameer');
    });

    test('resolveRealUserName resolves robot names and profile display_name', () {
      final botName = PocketMateService.resolveRealUserName(
        userId: 'pocket_robot_1',
      );
      expect(botName, isNotEmpty);
      expect(botName, isNot('Learner'));

      final fromProfile = PocketMateService.resolveRealUserName(
        userId: 'user_xyz_9999',
        profileMap: {
          'display_name': 'Aisha Rahman',
        },
      );
      expect(fromProfile, 'Aisha Rahman');
    });
  });

  group('2. English Hub Naming & Shuffling', () {
    test('cleanHubName simplifies long bracket names to English Hub #N', () {
      expect(
        EnglishHubLevelGroupService.cleanHubName('English Hub (Lvl 1 - 5)'),
        'English Hub #1',
      );
      expect(
        EnglishHubLevelGroupService.cleanHubName('English Hub (Lvl 6 - 11)'),
        'English Hub #2',
      );
      expect(
        EnglishHubLevelGroupService.cleanHubName('English Hub (All Learners • Lvl 1 - 90)'),
        'English Hub #1',
      );
      expect(
        EnglishHubLevelGroupService.cleanHubName('English Hub #3'),
        'English Hub #3',
      );
    });

    test('kDefaultBrackets uses clean English Hub #N names', () {
      expect(EnglishHubLevelGroupService.kDefaultBrackets[0]['name'], 'English Hub #1');
      expect(EnglishHubLevelGroupService.kDefaultBrackets[1]['name'], 'English Hub #2');
      expect(EnglishHubLevelGroupService.kDefaultBrackets[2]['name'], 'English Hub #3');
    });
  });

  group('3. Island Neighbors Deduplication Logic', () {
    test('isIslandGroup identifies island groups correctly', () {
      expect(
        PocketIslandGroupService.isIslandGroup('cosmos_island_ep_w1_i1', '🏝️ Island Neighbors'),
        isTrue,
      );
      expect(
        PocketIslandGroupService.isIslandGroup('any_uuid', 'Island Neighbors'),
        isTrue,
      );
      expect(
        PocketIslandGroupService.isIslandGroup('p:user_123', 'John Doe'),
        isFalse,
      );
    });
  });

  group('4. Suggested Mates 4-Card Grid Model', () {
    test('SuggestedMateItem model properly initializes with rank & plot', () {
      final item = SuggestedMateItem(
        id: 'u_123',
        name: 'Rahul',
        rank: 5,
        plotNumber: 12,
        isRobot: false,
      );
      expect(item.id, 'u_123');
      expect(item.name, 'Rahul');
      expect(item.rank, 5);
      expect(item.plotNumber, 12);
      expect(item.isRobot, isFalse);
    });
  });
}
