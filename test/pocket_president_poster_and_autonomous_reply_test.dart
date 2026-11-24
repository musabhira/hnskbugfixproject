import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_poster_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🏛️ PocketPresidentPosterService Tests', () {
    test('Initializes with seed educational posters', () async {
      final posters = await PocketPresidentPosterService.getAllPosters();
      expect(posters.isNotEmpty, isTrue);
      expect(posters.any((p) => p.title.contains('Phrases with WHO')), isTrue);
    });

    test('Can add, retrieve, and delete educational poster', () async {
      final initialPosters = await PocketPresidentPosterService.getAllPosters();
      final initialCount = initialPosters.length;
      final newPoster = PresidentEducationalPoster(
        id: 'test_poster_vocab',
        title: 'Daily English: Greetings',
        imageUrl: 'https://example.com/greetings.jpg',
        language: 'ml',
        subtitle: 'Learn greetings in English & Malayalam',
        createdAt: DateTime.now(),
      );

      await PocketPresidentPosterService.addPoster(newPoster);
      final afterAdd = await PocketPresidentPosterService.getAllPosters();
      expect(afterAdd.length, equals(initialCount + 1));

      final fetched = await PocketPresidentPosterService.getAllPosters(languageFilter: 'ml');
      expect(fetched.any((p) => p.id == 'test_poster_vocab'), isTrue);

      await PocketPresidentPosterService.deletePoster('test_poster_vocab');
      final afterDelete = await PocketPresidentPosterService.getAllPosters();
      expect(afterDelete.length, equals(initialCount));
    });

    test('Unseen poster retrieval and markPosterSeen works properly', () async {
      final poster = PocketPresidentPosterService.getNextUnseenPosterSync(
        userId: 'user_test_123',
        language: 'ml',
      );
      expect(poster, isNotNull);

      if (poster != null) {
        await PocketPresidentPosterService.markPosterSeen('user_test_123', poster.id);
      }
    });
  });

  group('👑 PocketPresidentService Autonomous Reply Tests', () {
    test('Answers "who are you" / "ആരാണ്" in dignified Presidential tone', () async {
      final replyEn = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'Who are you?',
        userName: 'Rahul',
      );
      expect(replyEn.toLowerCase().contains('president'), isTrue);

      final replyMl = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'നിങ്ങൾ ആരാണ്?',
        userName: 'Anandu',
      );
      expect(replyMl.contains('പോക്കറ്റ്') || replyMl.contains('പ്രസിഡന്റ്') || replyMl.contains('പ്രസിഡന്റ'), isTrue);
    });

    test('Answers "rules" / "നിയമങ്ങൾ" query authoritatively', () async {
      final reply = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'What are the rules of the pocket world?',
      );
      expect(reply.contains('Presidential Rules') || reply.contains('നിയമം') || reply.contains('English'), isTrue);
    });

    test('Answers "attack" / "citadel protection" inquiries', () async {
      final reply = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'Can someone attack me or my citadel?',
      );
      expect(reply.contains('Citadel') || reply.contains('പ്രൊട്ടക്ഷൻ') || reply.contains('Protection') || reply.contains('ഡിഫൻസ്'), isTrue);
    });
  });
}
