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
    test('Initializes with seed educational posters and categories', () async {
      final posters = await PocketPresidentPosterService.getAllPosters();
      expect(posters.isNotEmpty, isTrue);
      expect(posters.any((p) => p.title.contains('Phrases with WHO')), isTrue);
      expect(posters.any((p) => p.category == 'Vocabulary'), isTrue);
    });

    test('Can add, retrieve, and delete educational poster', () async {
      final initialPosters = await PocketPresidentPosterService.getAllPosters();
      final initialCount = initialPosters.length;
      final newPoster = PresidentEducationalPoster(
        id: 'test_poster_vocab',
        title: 'Daily English: Greetings',
        imageUrl: 'https://example.com/greetings.jpg',
        language: 'ml',
        category: 'Vocabulary',
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

    test('Strict Homes seen tracking: once seen, does not return duplicate', () async {
      final poster1 = await PocketPresidentPosterService.getNextUnseenPosterForHomes(
        userId: 'user_homes_test',
        language: 'ml',
      );
      expect(poster1, isNotNull);

      if (poster1 != null) {
        await PocketPresidentPosterService.markPosterSeenInHomes('user_homes_test', poster1.id);
        
        final poster2 = await PocketPresidentPosterService.getNextUnseenPosterForHomes(
          userId: 'user_homes_test',
          language: 'ml',
        );
        // Should either be a DIFFERENT unseen poster or null if all seen
        if (poster2 != null) {
          expect(poster2.id != poster1.id, isTrue);
        }
      }
    });
  });

  group('👑 PocketPresidentService Thankful & Supportive English Tone Tests', () {
    test('Answers "who are you" / "നിങ്ങൾ ആരാണ്?" with gratitude and supportive teammate tone in English', () async {
      final replyEn = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'Who are you?',
        userName: 'Rahul',
      );
      expect(replyEn.toLowerCase().contains('thank you'), isTrue);
      expect(replyEn.toLowerCase().contains('president'), isTrue);
      expect(replyEn.toLowerCase().contains('supporter') || replyEn.toLowerCase().contains('team'), isTrue);

      final replyMl = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'നിങ്ങൾ ആരാണ്?',
        userName: 'Anandu',
      );
      // Replies in gentle supportive English
      expect(replyMl.toLowerCase().contains('thank you'), isTrue);
      expect(replyMl.toLowerCase().contains('president'), isTrue);
    });

    test('Answers "rules" with thankfulness and encouragement', () async {
      final reply = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'What are the rules of the pocket world?',
      );
      expect(reply.toLowerCase().contains('thank you'), isTrue);
      expect(reply.toLowerCase().contains('english'), isTrue);
    });

    test('Answers "attack" / "citadel protection" with reassuring support', () async {
      final reply = await PocketPresidentService.generatePresidentRobotReply(
        userMessage: 'Can someone attack me or my citadel?',
      );
      expect(reply.toLowerCase().contains('thank you'), isTrue);
      expect(reply.contains('Citadel') || reply.contains('Protection') || reply.contains('safe'), isTrue);
    });
  });
}
