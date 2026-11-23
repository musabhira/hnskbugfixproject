import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('President Chat Persistence Tests', () {
    test('President chat messages persist reliably across save and load', () async {
      const testUserId = 'test_citizen_123';

      // 1. Initial history has default welcome message
      final initialHistory = await PocketPresidentService.getPresidentChatHistory(testUserId);
      expect(initialHistory.isNotEmpty, isTrue);
      expect(initialHistory.any((m) => m['sender_id'] == PocketPresidentService.presidentId), isTrue);

      // 2. User sends message
      const userText = 'Hello President, how do I improve English?';
      final sent = await PocketPresidentService.sendUserMessageToPresident(
        userId: testUserId,
        messageText: userText,
      );
      expect(sent['message_text'], equals(userText));

      // 3. President replies
      const replyText = 'Greetings Citizen! Practice every day with Pocket Talk!';
      await PocketPresidentService.sendPresidentReplyToUser(
        targetUserId: testUserId,
        replyText: replyText,
      );

      // 4. Reload history (simulating re-entering chat after exiting)
      final reloaded = await PocketPresidentService.getPresidentChatHistory(testUserId);
      expect(reloaded.any((m) => m['message_text'] == userText), isTrue);
      expect(reloaded.any((m) => m['message_text'] == replyText), isTrue);
    });

    test('savePresidentChatMessages persists whole message list cleanly without loss', () async {
      const testUserId = 'test_citizen_456';
      final testMessages = [
        {
          'id': 'msg_1',
          'sender_id': testUserId,
          'receiver_id': PocketPresidentService.presidentId,
          'message_text': 'Citizen question',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': true,
        },
        {
          'id': 'msg_2',
          'sender_id': PocketPresidentService.presidentId,
          'receiver_id': testUserId,
          'message_text': 'Presidential answer',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': true,
        }
      ];

      await PocketPresidentService.savePresidentChatMessages(testUserId, testMessages);

      final history = await PocketPresidentService.getPresidentChatHistory(testUserId);
      expect(history.any((m) => m['id'] == 'msg_1'), isTrue);
      expect(history.any((m) => m['id'] == 'msg_2'), isTrue);
    });
  });

  group('President Feedback Vibe & Periodic Reminder Tests', () {
    test('Active President Vibes include feedback prompt if not yet given', () async {
      final vibes = await PocketPresidentService.getActivePresidentVibes();
      expect(vibes.any((v) => v['is_feedback_vibe'] == true || v['id'] == 'pres_vibe_feedback_prompt'), isTrue);
    });

    test('Submitting feedback marks as given and records into chat', () async {
      const testUserId = 'citizen_feedback_user';
      const feedbackText = 'The daily speaking exercises are great, please add more accent training!';

      await PocketPresidentService.submitCitizenFeedback(
        userId: testUserId,
        feedback: feedbackText,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('president_feedback_given_$testUserId'), isTrue);

      final history = await PocketPresidentService.getPresidentChatHistory(testUserId);
      expect(history.any((m) => m['message_text']?.toString().contains(feedbackText) == true), isTrue);
    });
  });

  group('Mate Request Name Resolution (Never "Pocket Mate")', () {
    test('resolveRealUserName never defaults to generic Pocket Mate or Poket Mate', () {
      expect(PocketMateService.resolveRealUserName(
        userId: 'abcdef123456',
        preferredName: 'Pocket Mate',
      ), equals('Mate #ABCD'));

      expect(PocketMateService.resolveRealUserName(
        userId: '9876543210ab',
        preferredName: 'Poket Mate',
      ), equals('Mate #9876'));

      expect(PocketMateService.resolveRealUserName(
        userId: 'user_xyz_7890',
        preferredName: 'John Doe',
      ), equals('John Doe'));

      expect(PocketMateService.resolveRealUserName(
        userId: '1122334455',
        profileMap: {'display_name': 'Rahul K', 'name': 'Rahul'},
      ), equals('Rahul K'));

      expect(PocketMateService.resolveRealUserName(
        userId: '1122334455',
        profileMap: {'display_name': 'Pocket Mate', 'name': 'Poket Mate'},
      ), equals('Mate #1122'));
    });
  });

  group('Humans Category Filter Logic', () {
    test('Non-mates (e.g. Citadel attackers) are excluded from Humans category', () {
      final localMateIds = {'mate_uuid_1', 'mate_uuid_2'};
      final pocketTalkActivePeerIds = {'pact_uuid_1'};

      final convs = [
        ChatConversation(
          id: 'mate_uuid_1',
          name: 'Real Mate',
          lastMessage: 'Hi',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isGroup: false,
        ),
        ChatConversation(
          id: 'attacker_uuid_99',
          name: 'Citadel Attacker Opponent',
          lastMessage: 'Attacked your gate!',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isGroup: false,
        ),
        ChatConversation(
          id: PocketPresidentService.presidentId,
          name: 'The President',
          lastMessage: 'Welcome',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isGroup: false,
        ),
      ];

      // Category 2 (Humans) filtering:
      final humans = convs.where((c) {
        if (c.isGroup || c.isTool || c.isNotification || c.isActiveTimer) return false;
        return localMateIds.contains(c.id) ||
            pocketTalkActivePeerIds.contains(c.id) ||
            PocketPresidentService.isPresidentId(c.id);
      }).toList();

      expect(humans.length, equals(2));
      expect(humans.any((c) => c.id == 'mate_uuid_1'), isTrue);
      expect(humans.any((c) => c.id == PocketPresidentService.presidentId), isTrue);
      expect(humans.any((c) => c.id == 'attacker_uuid_99'), isFalse);
    });
  });

  group('Birthday Celebration & Notification Tests', () {
    test('checkAndDeliverBirthdayWish logic correctly identifies birthday and avoids re-wishing', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const testUser = 'birthday_user_123';
      final now = DateTime.now();

      // Set user's cached DOB to today
      final dobToday = DateTime(2000, now.month, now.day);
      await prefs.setString('pm_dob_$testUser', dobToday.toIso8601String());

      // Simulate first birthday check
      expect(prefs.getInt('president_birthday_wish_year_$testUser'), isNull);

      await PocketPresidentService.checkAndDeliverBirthdayWish(testUser);

      // Now it should be recorded for the current year
      expect(prefs.getInt('president_birthday_wish_year_$testUser'), equals(now.year));
      expect(prefs.getString('president_birthday_wish_date_$testUser'), equals('${now.year}-${now.month}-${now.day}'));

      // Re-triggering should safely skip
      await PocketPresidentService.checkAndDeliverBirthdayWish(testUser);
      expect(prefs.getInt('president_birthday_wish_year_$testUser'), equals(now.year));
    });

    test('Different DOB does not trigger birthday wish', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const testUser = 'non_birthday_user_456';
      final now = DateTime.now();

      // Set user's DOB to tomorrow
      final tomorrow = now.add(const Duration(days: 1));
      final dobTomorrow = DateTime(2000, tomorrow.month, tomorrow.day);
      await prefs.setString('pm_dob_$testUser', dobTomorrow.toIso8601String());

      await PocketPresidentService.checkAndDeliverBirthdayWish(testUser);
      expect(prefs.getInt('president_birthday_wish_year_$testUser'), isNull);
    });
  });
}
