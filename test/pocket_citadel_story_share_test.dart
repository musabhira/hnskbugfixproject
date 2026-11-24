import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_story_share_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pocket Citadel Story Card & Share Tests (Boxed Scrapbook & Templates)', () {
    test('CitadelStoryAspectRatio has valid dimensions for 1080p target export', () {
      expect(CitadelStoryAspectRatio.story9x16.ratio, closeTo(9 / 16, 0.001));
      expect(CitadelStoryAspectRatio.feedPortrait4x5.ratio, closeTo(4 / 5, 0.001));
      expect(CitadelStoryAspectRatio.square1x1.ratio, closeTo(1.0, 0.001));

      expect(CitadelStoryAspectRatio.story9x16.designWidth, 360.0);
      expect(CitadelStoryAspectRatio.story9x16.designHeight, 640.0);
    });

    testWidgets('PocketCitadelStorySharePage renders Scrapbook Desk Poster template with torn header, player pod and actions',
        (WidgetTester tester) async {
      final neighbor = PocketNeighbor(
        id: 'test_user_scrapbook',
        name: 'Mus\'ab hira',
        day: 20,
        streak: 20,
        rank: 'Level 20 Pioneer',
        paletteId: 'preset_default',
        isMe: true,
        hasActiveShield: true,
        statusMessage: 'Ready to build!',
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

      // Verify title & brand elements
      expect(find.text('Citadel Story Card'), findsOneWidget);
      expect(find.text('Speak English.'), findsWidgets);
      expect(find.text('Meet Your POKETMates.'), findsWidgets);
      expect(find.text('Mus\'ab hira'), findsWidgets);
      expect(find.text('🏆 Rank #1'), findsWidgets);
      expect(find.text('13220'), findsWidgets);
      expect(find.text('PoketMates'), findsWidgets);
      expect(find.text(' • Speak English Every Day'), findsWidgets);

      // Verify aspect ratio selector pills
      expect(find.text('Story (9:16)'), findsOneWidget);
      expect(find.text('Portrait (4:5)'), findsOneWidget);
      expect(find.text('Square (1:1)'), findsOneWidget);

      // Verify action buttons: Save Image, Save Video, Share
      expect(find.text('Save Image'), findsOneWidget);
      expect(find.text('Save Video'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Tap on Portrait 4:5
      await tester.tap(find.text('Portrait (4:5)'));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Square 1:1
      await tester.tap(find.text('Square (1:1)'));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
