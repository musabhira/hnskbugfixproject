import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/travel_rush_models.dart';

void main() {
  group('TravelRush – Level 14 Models & Travel Logic', () {
    test('Level data is properly defined', () {
      expect(kMission14TravelRushData.title, contains('Level 14'));
      expect(kMission14TravelRushData.challenges.isNotEmpty, isTrue);
      expect(kMission14TravelRushData.zones.length, equals(10));
      expect(kMission14TravelRushData.flights.length, equals(4));
    });

    test('Has 11 challenges covering all travel scenarios', () {
      expect(kMission14TravelRushData.challenges.length, equals(11));
    });

    test('Initial travel card has Passenger Alex Morgan to Bengaluru at 4:30 PM Gate 12', () {
      final card = kMission14TravelRushData.initialTravelCard;
      expect(card.passengerName, equals('Alex Morgan'));
      expect(card.destination, equals('Bengaluru'));
      expect(card.departureTime, equals('4:30 PM'));
      expect(card.gate, equals('12'));
      expect(card.seat, equals('18A'));
    });

    test('Challenge 1 reads Gate 12 from confirmation', () {
      final ch1 = kMission14TravelRushData.challenges[0];
      expect(ch1.type, equals(TravelChallengeType.ticketReading));
      expect(ch1.options[ch1.correctOptionIndex], equals('Gate 12'));
    });

    test('Challenge 2 checks departure board time 4:30 PM', () {
      final ch2 = kMission14TravelRushData.challenges[1];
      expect(ch2.type, equals(TravelChallengeType.departureBoardScan));
      expect(ch2.options[ch2.correctOptionIndex], equals('4:30 PM'));
    });

    test('Challenge 4 is polite direction inquiry to Info Desk', () {
      final ch4 = kMission14TravelRushData.challenges[3];
      expect(ch4.type, equals(TravelChallengeType.directionRequest));
      expect(ch4.options[ch4.correctOptionIndex], contains('Could you tell me where Gate 12 is?'));
    });

    test('Challenge 6 identifies the blue suitcase', () {
      final ch6 = kMission14TravelRushData.challenges[5];
      expect(ch6.type, equals(TravelChallengeType.luggageIdentification));
      expect(ch6.options[ch6.correctOptionIndex], equals('Blue suitcase'));
    });

    test('Challenge 7 evaluates 30-minute delay', () {
      final ch7 = kMission14TravelRushData.challenges[6];
      expect(ch7.type, equals(TravelChallengeType.delayUnderstanding));
      expect(ch7.delayMinutes, equals(30));
      expect(ch7.options[ch7.correctOptionIndex], equals('30 minutes'));
    });

    test('Challenge 8 updates gate to Gate 18', () {
      final ch8 = kMission14TravelRushData.challenges[7];
      expect(ch8.type, equals(TravelChallengeType.gateChangeAdjustment));
      expect(ch8.updatedGate, equals('18'));
      expect(ch8.options[ch8.correctOptionIndex], equals('Gate 18'));
    });

    test('Challenge 11 is 90s final boarding sprint with highest XP', () {
      final ch11 = kMission14TravelRushData.challenges[10];
      expect(ch11.type, equals(TravelChallengeType.finalBoardingRush));
      expect(ch11.timeLimitSeconds, equals(90));
      expect(ch11.xpReward, equals(60));
    });

    test('TravelCard copyWith updates gate dynamically', () {
      final card = kMission14TravelRushData.initialTravelCard;
      final updated = card.copyWith(gate: '18');
      expect(updated.gate, equals('18'));
      expect(updated.destination, equals('Bengaluru'));
    });
  });
}
