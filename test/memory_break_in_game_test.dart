import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/memory_break_in_models.dart';

void main() {
  group('Mission 03 Memory Break-In Curriculum Tests', () {
    test('Level 3 curriculum has exactly 10 comprehensive challenges', () {
      expect(kMission03MemoryData.challenges.length, equals(10));
      expect(kMission03MemoryData.levelNumber, equals(3));
      expect(kMission03MemoryData.title, contains('Mission 03 – Memory Break-In'));
    });

    test('All 15 workplace memory vocabulary terms are populated', () {
      final expectedVocab = [
        'appointment',
        'calendar',
        'document',
        'wallet',
        'headphones',
        'notebook',
        'schedule',
        'meeting',
        'keys',
        'laptop',
        'charger',
        'receipt',
        'folder',
        'message',
        'package',
      ];
      expect(kMission03MemoryData.targetVocabularyList.length, equals(15));
      expect(kMission03MemoryData.targetVocabularyList, containsAll(expectedVocab));
    });

    test('Challenge 1 is Object Match with Laptop as correct item', () {
      final c1 = kMission03MemoryData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.targetVocabulary, equals('laptop'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Laptop'));
    });

    test('Challenge 2 verifies Word Recognition Memory', () {
      final c2 = kMission03MemoryData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.targetVocabulary, equals('document'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Laptop'));
    });

    test('Challenge 3 is Spelling Memory for HEADPHONES with draggable tiles', () {
      final c3 = kMission03MemoryData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c3.targetVocabulary, equals('headphones'));
      expect(c3.sentenceTiles, isNotNull);
      expect(c3.sentenceTiles, containsAll(['H', 'E', 'A', 'D', 'P', 'H', 'O', 'N', 'E', 'S']));
      expect(c3.targetSentence, equals('H E A D P H O N E S'));
    });

    test('Challenge 4 verifies Position Memory with spatial prepositions', () {
      final c4 = kMission03MemoryData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.targetVocabulary, equals('notebook'));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('On the desk'));
    });

    test('Challenge 5 tests Sentence Memory recall', () {
      final c5 = kMission03MemoryData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.targetVocabulary, equals('keys'));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Beside the laptop'));
    });

    test('Challenge 6 tests Listening Memory with audio prompt', () {
      final c6 = kMission03MemoryData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.type, equals(AdventureChallengeType.listening));
      expect(c6.audioPrompt, isNotNull);
      expect(c6.audioPrompt, contains('The blue notebook is on the table.'));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Blue notebook'));
    });

    test('Challenge 7 identifies the Word Intruder not present in the room', () {
      final c7 = kMission03MemoryData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.targetVocabulary, equals('wallet'));
      final correctOpt = c7.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Banana'));
    });

    test('Challenge 8 has 8-second time limit for fast memory recall of time concepts', () {
      final c8 = kMission03MemoryData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(AdventureChallengeType.quickResponse));
      expect(c8.timeLimitSeconds, equals(8));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('CALENDAR'));
    });

    test('Challenge 9 is Sentence Reconstruction from scrambled words', () {
      final c9 = kMission03MemoryData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c9.targetSentence, equals('I left my wallet on the desk.'));
      expect(c9.sentenceTiles, containsAll(['I', 'left', 'my', 'wallet', 'on', 'the', 'desk.']));
    });

    test('Challenge 10 is Master Memory Certification comprehensive summary', () {
      final c10 = kMission03MemoryData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(AdventureChallengeType.finalInterview));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Headphones on sofa, calendar on wall'));
    });

    test('Workspace room contains 12 interactive memory objects', () {
      expect(kRoomMemoryObjects.length, equals(12));
      final ids = kRoomMemoryObjects.map((o) => o.id).toList();
      expect(ids, containsAll([
        'laptop',
        'notebook',
        'keys',
        'headphones',
        'backpack',
        'bottle',
        'calendar',
        'phone',
        'wallet',
        'camera',
        'folder',
        'charger',
      ]));
    });

    test('Workspace room contains 5 architectural zones', () {
      expect(kRoomZones.length, equals(5));
      final zoneIds = kRoomZones.map((z) => z.id).toList();
      expect(zoneIds, containsAll([
        'entrance',
        'workstation',
        'sofa_lounge',
        'bookshelf_unit',
        'kitchen_counter',
      ]));
    });

    test('Supervisor NPC Vance is defined', () {
      expect(kMission03MemoryData.npcs.length, equals(1));
      expect(kMission03MemoryData.npcs.first.id, equals('mentor_vance'));
    });
  });
}
