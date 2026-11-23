import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/services/iap_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/chat_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. IAP Product IDs & Keyword Resolution Tests', () {
    test('allVipProductIds contains comprehensive variants', () {
      final ids = IAPService.allVipProductIds;
      expect(ids.contains('poketmates_vip_monthly'), isTrue);
      expect(ids.contains('poketmates_vip_quarterly'), isTrue);
      expect(ids.contains('poketmates_vip_yearly'), isTrue);
      expect(ids.contains('poketmates_vip_90day'), isTrue);
      expect(ids.contains('poketmates_vip_annual'), isTrue);
      expect(ids.contains('poketmates_fluency_pass'), isTrue);
      expect(ids.contains('com.handskill.friends.fluencypass'), isTrue);
      expect(ids.contains('com.handskill.friends.annual'), isTrue);
    });
  });

  group('2. Robot Rank vs Animal Rank vs Global Rank Tile Tests', () {
    test('Animals correctly resolve to Animal Rank', () {
      // kid_bot_1 (Sparky Tiger) is an animal buddy
      const animalId = 'kid_bot_1';
      final isAnimal = PocketKidsRobotsData.getAnimalById(animalId) != null;
      expect(isAnimal, isTrue);

      final String rankLabel = isAnimal
          ? 'Animal Rank #1'
          : (PocketRobotService.isRobotId(animalId) ? 'Robot Rank #1' : 'Global Rank #1');
      expect(rankLabel, 'Animal Rank #1');
    });

    test('Robots correctly resolve to Robot Rank', () {
      const robotId = 'robot_day_10';
      final isAnimal = PocketKidsRobotsData.getAnimalById(robotId) != null;
      final isRobot = !isAnimal && PocketRobotService.isRobotId(robotId);

      expect(isAnimal, isFalse);
      expect(isRobot, isTrue);

      final String rankLabel = isAnimal
          ? 'Animal Rank #10'
          : (isRobot ? 'Robot Rank #10' : 'Global Rank #10');
      expect(rankLabel, 'Robot Rank #10');
    });

    test('Humans correctly resolve to Global Rank', () {
      const humanUuid = '11111111-2222-3333-4444-555555555555';
      final isAnimal = PocketKidsRobotsData.getAnimalById(humanUuid) != null;
      final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(humanUuid);
      final isRobot = !isAnimal && (PocketRobotService.isRobotId(humanUuid) || !isUuid);

      expect(isAnimal, isFalse);
      expect(isRobot, isFalse);

      final String rankLabel = isAnimal
          ? 'Animal Rank #42'
          : (isRobot ? 'Robot Rank #42' : 'Global Rank #42');
      expect(rankLabel, 'Global Rank #42');
    });
  });

  group('3. English Hub Human vs Robot Message Filtering Tests', () {
    test('Human filter strictly isolates humans and excludes robots', () {
      final messages = [
        ChatMessage(
          id: 'msg_1',
          senderId: 'user_human_1',
          messageText: 'Hello learners!',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_2',
          senderId: 'robot_day_5',
          messageText: 'Greetings from AI bot!',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_3',
          senderId: 'user_human_2',
          messageText: 'Glad to practice English here.',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
      ];

      // Human tab filter
      final humanMessages = messages.where((m) {
        return !PocketRobotService.isRobotId(m.senderId);
      }).toList();

      expect(humanMessages.length, 2);
      expect(humanMessages[0].id, 'msg_1');
      expect(humanMessages[1].id, 'msg_3');
    });

    test('Robot filter contains robots and active user participation', () {
      const currentUserId = 'my_current_user_id';
      final messages = [
        ChatMessage(
          id: 'msg_1',
          senderId: 'user_human_1',
          messageText: 'Hello learners!',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_2',
          senderId: 'robot_day_5',
          messageText: 'Let us discuss favorite hobbies.',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_3',
          senderId: currentUserId,
          messageText: 'I love playing chess and reading!',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_4',
          senderId: 'robot_day_6',
          messageText: 'Chess is fantastic for strategy!',
          messageType: 'text',
          createdAt: DateTime.now(),
        ),
      ];

      // Robot tab filter
      final robotMessages = messages.where((m) {
        final isRobot = PocketRobotService.isRobotId(m.senderId);
        final isMe = m.senderId == currentUserId;
        return isRobot || isMe;
      }).toList();

      expect(robotMessages.length, 3);
      expect(robotMessages.any((m) => m.id == 'msg_1'), isFalse);
      expect(robotMessages.any((m) => m.id == 'msg_2'), isTrue);
      expect(robotMessages.any((m) => m.id == 'msg_3'), isTrue);
      expect(robotMessages.any((m) => m.id == 'msg_4'), isTrue);
    });
  });
}
