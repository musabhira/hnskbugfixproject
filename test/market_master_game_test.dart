import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/market_master_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/market_master_game_page.dart';

void main() {
  group('Mission 09 – Market Master Curriculum & Data Models', () {
    test('Level 9 data includes 11 challenges and 6 supermarket zones', () {
      final data = kMission09MarketMasterData;
      expect(data.missionId, equals('09'));
      expect(data.title, contains('Market Master'));
      expect(data.tagline, equals('Read it. Find it. Ask for it. Buy it.'));
      expect(data.challenges.length, equals(11));
      expect(data.zones.length, equals(6));
      expect(data.targetVocabulary.length, equals(22));
      expect(data.shoppingListNote, contains('2 bottles of water'));
      expect(data.shoppingListNote, contains('6:00 PM'));
    });

    test('Challenge 1 tests understanding the list and quantity of water bottles', () {
      final c1 = kMission09MarketMasterData.challenges[0];
      expect(c1.type, equals(MarketChallengeType.understandList));
      expect(c1.correctOption.text, contains('2 bottles of water'));
      expect(c1.awardedCartItem, isNotNull);
      expect(c1.awardedCartItem!.id, equals('water'));
      expect(c1.awardedCartItem!.unitPrice, equals(25));
      expect(c1.awardedCartItem!.quantity, equals(2));
      expect(c1.awardedCartItem!.totalPrice, equals(50));
    });

    test('Challenge 2 verifies shelf product inspection for instant coffee', () {
      final c2 = kMission09MarketMasterData.challenges[1];
      expect(c2.type, equals(MarketChallengeType.productSearch));
      expect(c2.shelfProducts, isNotNull);
      expect(c2.shelfProducts!.length, equals(3));

      final target = c2.shelfProducts!.firstWhere((p) => p.isTarget);
      expect(target.name, contains('Instant Coffee'));
      expect(target.price, equals(180));

      expect(c2.correctOption.text, contains('Instant Coffee Granules'));
      expect(c2.awardedCartItem!.totalPrice, equals(180));
    });

    test('Challenge 3 verifies quantity pickup for 6 eggs', () {
      final c3 = kMission09MarketMasterData.challenges[2];
      expect(c3.type, equals(MarketChallengeType.quantityPickup));
      expect(c3.correctOption.text, contains('Carton of 6 Eggs'));
      expect(c3.awardedCartItem!.id, equals('eggs'));
      expect(c3.awardedCartItem!.totalPrice, equals(60));
    });

    test('Challenge 4 verifies digital shelf price tag reading', () {
      final c4 = kMission09MarketMasterData.challenges[3];
      expect(c4.type, equals(MarketChallengeType.priceReading));
      expect(c4.correctOption.text, equals('₹25'));
    });

    test('Challenge 5 verifies polite inquiry when asking store clerk for help', () {
      final c5 = kMission09MarketMasterData.challenges[4];
      expect(c5.type, equals(MarketChallengeType.askForHelp));
      expect(c5.correctOption.text, contains('Excuse me, could you tell me where the rice is?'));
      expect(c5.options.any((o) => o.text == '“Where rice?”' && !o.isCorrect), isTrue);
    });

    test('Challenge 6 verifies auditory direction comprehension and location', () {
      final c6 = kMission09MarketMasterData.challenges[5];
      expect(c6.type, equals(MarketChallengeType.listenToStaff));
      expect(c6.correctOption.text, equals('Cooking oil'));
      expect(c6.awardedCartItem!.id, equals('rice'));
      expect(c6.awardedCartItem!.totalPrice, equals(65));
    });

    test('Challenge 7 verifies product quantity and price comparison', () {
      final c7 = kMission09MarketMasterData.challenges[6];
      expect(c7.type, equals(MarketChallengeType.comparison));
      expect(c7.correctOption.text, contains('Pack B (1kg) gives more rice'));
      expect(c7.awardedCartItem!.id, equals('bread'));
      expect(c7.awardedCartItem!.totalPrice, equals(45));
    });

    test('Challenge 8 tests customer service explanation for wrong item', () {
      final c8 = kMission09MarketMasterData.challenges[7];
      expect(c8.type, equals(MarketChallengeType.customerService));
      expect(c8.correctOption.text, contains('Sorry, I think I picked up the wrong item.'));
    });

    test('Challenge 9 verifies itemized checkout bill calculation totaling ₹400', () {
      final c9 = kMission09MarketMasterData.challenges[8];
      expect(c9.type, equals(MarketChallengeType.checkoutSum));
      expect(c9.correctOption.text, equals('₹400'));
    });

    test('Challenge 10 supports multiple valid polite cashier responses', () {
      final c10 = kMission09MarketMasterData.challenges[9];
      expect(c10.type, equals(MarketChallengeType.cashierDialogue));

      final validAnswers = c10.options.where((o) => o.isCorrect).toList();
      expect(validAnswers.length, equals(2));
      expect(validAnswers.any((o) => o.text.contains('Yes, please.')), isTrue);
      expect(validAnswers.any((o) => o.text.contains('No, thank you.')), isTrue);
    });

    test('Challenge 11 sets a 90-second shopping rush countdown timer', () {
      final c11 = kMission09MarketMasterData.challenges[10];
      expect(c11.type, equals(MarketChallengeType.shoppingRush));
      expect(c11.timeLimitSeconds, equals(90));
      expect(c11.correctOption.text, contains('Yes, I did.'));
    });

    test('All 5 shopping list cart items correctly sum to ₹400', () {
      final allItems = [
        kMission09MarketMasterData.challenges[0].awardedCartItem!, // water: 25 * 2 = 50
        kMission09MarketMasterData.challenges[1].awardedCartItem!, // coffee: 180
        kMission09MarketMasterData.challenges[2].awardedCartItem!, // eggs: 60
        kMission09MarketMasterData.challenges[5].awardedCartItem!, // rice: 65
        kMission09MarketMasterData.challenges[6].awardedCartItem!, // bread: 45
      ];
      final totalSum = allItems.fold(0, (sum, it) => sum + it.totalPrice);
      expect(totalSum, equals(400));
    });
  });

  group('MarketMasterGamePage Widget Rendering Tests', () {
    testWidgets('MarketMasterGamePage renders top bar, buttons, and prompt correctly',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: MarketMasterGamePage(
            levelData: kMission09MarketMasterData,
          ),
        ),
      );

      // In Flame tests, pump single frames rather than pumpAndSettle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Market Master'), findsOneWidget);
      expect(find.text('WALK LEFT'), findsOneWidget);
      expect(find.text('WALK RIGHT'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.textContaining('How many bottles do you need to pick up?'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
