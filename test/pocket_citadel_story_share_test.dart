import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_story_share_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pocket Citadel Story Card & Share Tests (12 Aesthetic Templates & Robust Carousel)', () {
    test('CitadelStoryAspectRatio has valid dimensions for 1080p target export', () {
      expect(CitadelStoryAspectRatio.story9x16.ratio, closeTo(9 / 16, 0.001));
      expect(CitadelStoryAspectRatio.feedPortrait4x5.ratio, closeTo(4 / 5, 0.001));
      expect(CitadelStoryAspectRatio.square1x1.ratio, closeTo(1.0, 0.001));

      expect(CitadelStoryAspectRatio.story9x16.designWidth, 360.0);
      expect(CitadelStoryAspectRatio.story9x16.designHeight, 640.0);

      expect(CitadelStoryAspectRatio.square1x1.designWidth, 540.0);
      expect(CitadelStoryAspectRatio.square1x1.designHeight, 540.0);
    });

    testWidgets('PocketCitadelStorySharePage renders 12 templates, minimal action buttons, and zero overflow',
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

      // Verify title is "Story Card" (as requested)
      expect(find.text('Story Card'), findsOneWidget);

      // Verify Template 1 doesn't have "TODAY WAS A 20!" text
      expect(find.text('TODAY WAS A 20!'), findsNothing);

      // Verify initial template indicator
      expect(find.text('1/12  •  '), findsOneWidget);
      expect(find.text('Scrapbook Desk Poster'), findsOneWidget);

      // Verify minimal action buttons: Image, Video, Share
      expect(find.text('Image'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Switch to Square 1:1 and ensure no layout overflow
      await tester.tap(find.text('Square (1:1)'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Switch to Portrait 4:5 and ensure no layout overflow
      await tester.tap(find.text('Portrait (4:5)'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Navigate through templates using next chevron
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
    });
  });
}
