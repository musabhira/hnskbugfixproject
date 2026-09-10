import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/city_navigator_models.dart';

void main() {
  group('Mission 02 City Navigator Curriculum Tests', () {
    test('Level 2 curriculum has exactly 10 comprehensive challenges', () {
      expect(kMission02CityData.challenges.length, equals(10));
      expect(kMission02CityData.levelNumber, equals(2));
      expect(kMission02CityData.title, contains('Mission 02 – City Navigator'));
    });

    test('All 20 city navigation vocabulary terms are populated', () {
      final expectedVocab = [
        'left',
        'right',
        'straight',
        'corner',
        'opposite',
        'beside',
        'between',
        'near',
        'behind',
        'across',
        'entrance',
        'exit',
        'station',
        'pharmacy',
        'supermarket',
        'bank',
        'restaurant',
        'library',
        'office',
        'bus stop',
      ];
      expect(kMission02CityData.targetVocabularyList.length, equals(20));
      expect(kMission02CityData.targetVocabularyList, containsAll(expectedVocab));
    });

    test('Challenge 1 is Follow Written Directions with correct option', () {
      final c1 = kMission02CityData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.targetVocabulary, equals('corner'));
      expect(c1.npcDialogue, contains('Go straight and turn right'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Proceed straight, then make a right turn'));
    });

    test('Challenge 2 tests direction choice for the pharmacy location', () {
      final c2 = kMission02CityData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.targetVocabulary, equals('pharmacy'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('It is next to the bank.'));
    });

    test('Challenge 3 is listening navigation with spoken prompt and replay', () {
      final c3 = kMission02CityData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(AdventureChallengeType.listening));
      expect(c3.audioPrompt, isNotNull);
      expect(c3.audioPrompt, contains('turn left after the bus stop'));
      final correctOpt = c3.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Turn left'));
    });

    test('Challenge 4 is Sign Hunt for the public library', () {
      final c4 = kMission02CityData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.targetVocabulary, equals('library'));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Look for the "LIBRARY" sign'));
    });

    test('Challenge 5 tests spatial prepositions with scene analysis', () {
      final c5 = kMission02CityData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.targetVocabulary, equals('beside'));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Beside the restaurant'));
    });

    test('Challenge 6 asks for directions politely and professionally', () {
      final c6 = kMission02CityData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.targetVocabulary, equals('station'));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Yes. Could you tell me how to get to the station?'));
    });

    test('Challenge 7 has interactive Route Builder tiles matching target sequence', () {
      final c7 = kMission02CityData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c7.sentenceTiles, isNotNull);
      expect(c7.sentenceTiles, containsAll(['GO STRAIGHT', 'TURN RIGHT', 'CROSS THE ROAD', 'TURN LEFT']));
      expect(c7.targetSentence, equals('GO STRAIGHT TURN RIGHT CROSS THE ROAD'));
    });

    test('Challenge 8 has 60-second time limit for timed navigation to meeting', () {
      final c8 = kMission02CityData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(AdventureChallengeType.quickResponse));
      expect(c8.timeLimitSeconds, equals(60));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Go straight → Turn left at the bank → Cross the road → Enter the building'));
    });

    test('Challenge 9 checks security interaction and building floor directions', () {
      final c9 = kMission02CityData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.targetVocabulary, equals('office'));
      final correctOpt = c9.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Yes. It is on the second floor.'));
    });

    test('Challenge 10 is 4-stage master navigation final challenge', () {
      final c10 = kMission02CityData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(AdventureChallengeType.finalInterview));
      expect(c10.audioPrompt, isNotNull);
      expect(c10.audioPrompt, contains('The office is opposite the restaurant'));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Opposite the restaurant'));
    });

    test('City Landmarks contain all 9 major city buildings and plaza', () {
      expect(kCityLandmarks.length, equals(9));
      final ids = kCityLandmarks.map((l) => l.id).toList();
      expect(ids, containsAll([
        'start_plaza',
        'bus_stop',
        'supermarket',
        'bank',
        'restaurant',
        'pharmacy',
        'library',
        'metro_station',
        'business_center',
      ]));
    });

    test('City Signs contain BANK, LIBRARY, PHARMACY, and STATION', () {
      expect(kCitySigns.length, equals(4));
      final signTexts = kCitySigns.map((s) => s.text).toList();
      expect(signTexts, containsAll(['BANK', 'LIBRARY', 'PHARMACY', 'STATION']));
    });

    test('NPCs contain Officer Harris, Elena Torres, and Security Marcus', () {
      expect(kMission02CityData.npcs.length, equals(3));
      final npcIds = kMission02CityData.npcs.map((n) => n.id).toList();
      expect(npcIds, containsAll(['officer_harris', 'transit_elena', 'security_marcus']));
    });
  });
}
