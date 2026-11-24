import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_story_share_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pocket Citadel Story Card & Share Tests', () {
    test('CitadelStoryAspectRatio has valid aspect ratios and labels', () {
      expect(CitadelStoryAspectRatio.story9x16.ratio, closeTo(9 / 16, 0.001));
      expect(CitadelStoryAspectRatio.feedPortrait4x5.ratio, closeTo(4 / 5, 0.001));
      expect(CitadelStoryAspectRatio.square1x1.ratio, closeTo(1.0, 0.001));

      expect(CitadelStoryAspectRatio.story9x16.label, 'Story (9:16)');
      expect(CitadelStoryAspectRatio.feedPortrait4x5.label, 'Portrait (4:5)');
      expect(CitadelStoryAspectRatio.square1x1.label, 'Square (1:1)');

      expect(CitadelStoryAspectRatio.story9x16.designWidth, 360.0);
      expect(CitadelStoryAspectRatio.story9x16.designHeight, 640.0);
    });

    testWidgets('PocketCitadelStorySharePage renders user stats, format selector and actions',
        (WidgetTester tester) async {
      final neighbor = PocketNeighbor(
        id: 'test_user_1',
        name: 'Felix the Explorer',
        day: 20,
        streak: 20,
        rank: 'Level 20 Pioneer',
        paletteId: 'preset_default',
        isMe: true,
        hasActiveShield: true,
        statusMessage: 'Ready to learn!',
        planetCode: 'EP',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PocketCitadelStorySharePage(
            neighbor: neighbor,
            level: 20,
            pocketScore: 13220,
            globalRank: 1,
            isNight: false,
          ),
        ),
      );

      await tester.pump();

      // Verify title & badges
      expect(find.text('Citadel Story Card'), findsOneWidget);
      expect(find.text('🏰 LEVEL 20 CITADEL'), findsOneWidget);
      expect(find.text('Felix the Explorer'), findsOneWidget);
      expect(find.text('🏆 Global Rank #1'), findsOneWidget);
      expect(find.text('13220'), findsOneWidget);
      expect(find.text('PoketMates'), findsOneWidget);
      expect(find.text(' • Speak English Every Day'), findsOneWidget);

      // Verify aspect ratio selector pills
      expect(find.text('Story (9:16)'), findsOneWidget);
      expect(find.text('Portrait (4:5)'), findsOneWidget);
      expect(find.text('Square (1:1)'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Share Story'), findsOneWidget);

      // Tap on Portrait 4:5
      await tester.tap(find.text('Portrait (4:5)'));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Square 1:1
      await tester.tap(find.text('Square (1:1)'));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
