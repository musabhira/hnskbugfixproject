import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/city_navigator_models.dart';

void main() {
  group('Mission 02 City Navigator Curriculum Tests', () {
    test('Level 2 curriculum has exactly 10 comprehensive challenges', () {
      expect(kMission02CityData.challenges.length, equals(10));
      expect(kMission02CityData.levelNumber, equals(2));
      expect(kMission02CityData.title, equals('City Navigator'));
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
      expect(c1.targetVocabulary, equals('opposite'));
      expect(c1.npcDialogue, contains('opposite the bus stop'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('At the corner opposite the bus stop'));
    });

    test('Challenge 2 tests direction choice for the pharmacy location', () {
      final c2 = kMission02CityData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.targetVocabulary, equals('between'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Between the Central Bank and City Square'));
    });

    test('Challenge 3 is listening navigation with spoken prompt and replay', () {
      final c3 = kMission02CityData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(AdventureChallengeType.listening));
      expect(c3.audioPrompt, isNotNull);
      expect(c3.audioPrompt, contains('beside the supermarket'));
      final correctOpt = c3.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('On your left, beside the supermarket'));
    });

    test('Challenge 4 is Sign Hunt for the public library', () {
      final c4 = kMission02CityData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.targetVocabulary, equals('library'));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('LIBRARY ➔'));
    });

    test('Challenge 5 tests spatial prepositions with scene analysis', () {
      final c5 = kMission02CityData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.targetVocabulary, equals('beside'));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('beside'));
    });

    test('Challenge 6 asks for directions politely and professionally', () {
      final c6 = kMission02CityData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.targetVocabulary, equals('straight'));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('Excuse me, could you please direct me to the City Business Center?'));
    });

    test('Challenge 7 has interactive Route Builder tiles matching target sequence', () {
      final c7 = kMission02CityData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c7.sentenceTiles, isNotNull);
      expect(c7.sentenceTiles, containsAll(['Exit the station', 'turn right at the corner', 'walk straight past the library', 'and enter the main lobby']));
      expect(c7.targetSentence, equals('Exit the station turn right at the corner walk straight past the library and enter the main lobby'));
    });

    test('Challenge 8 has 15-second time limit for rapid transit decision', () {
      final c8 = kMission02CityData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(AdventureChallengeType.quickResponse));
      expect(c8.timeLimitSeconds, equals(15));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('straight'));
    });

    test('Challenge 9 checks security interaction and building entrance directions', () {
      final c9 = kMission02CityData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.targetVocabulary, equals('entrance'));
      final correctOpt = c9.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('delivering an encrypted dispatch to the executive boardroom'));
    });

    test('Challenge 10 is executive dispatch delivery final handover challenge', () {
      final c10 = kMission02CityData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(AdventureChallengeType.finalInterview));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('followed the road signs opposite the bus stop'));
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
        'subway_station',
        'tech_office',
      ]));
    });

    test('City Signs contain directional landmark signs', () {
      expect(kCitySigns.length, equals(4));
      final signTexts = kCitySigns.map((s) => s.text).toList();
      expect(signTexts, containsAll(['BANK ➔', 'LIBRARY ➔', 'PHARMACY ➔', 'METRO ⬆']));
    });

    test('NPCs contain Officer Harris, Elena Torres, and Security Marcus', () {
      expect(kMission02CityData.npcs.length, equals(3));
      final npcIds = kMission02CityData.npcs.map((n) => n.id).toList();
      expect(npcIds, containsAll(['officer_harris', 'transit_elena', 'security_marcus']));
    });
  });
}
