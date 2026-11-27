import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocketgang_tools_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/notifications/notifications_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocketgang/pocketgang_modular_plus_sheet.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocketgang/poket_focus_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Code hygiene, brand spelling, and assets verification', () {
    test(
        'Key chat, course, notification, and tool files contain zero UTF-8 mojibake',
        () {
      final filesToCheck = [
        'lib/custom_code/widgets/chat/whatsapp_group_chat.dart',
        'lib/custom_code/widgets/courses_widget.dart',
        'lib/custom_code/widgets/notifications/notifications_page.dart',
        'lib/custom_code/widgets/pocketgang/pocket_spend_page.dart',
        'lib/custom_code/widgets/pocketgang/poket_focus_page.dart',
        'lib/custom_code/widgets/tools_page.dart',
      ];

      final mojibakePattern = RegExp(
        '('
        r'\u00f0\u0178|' // double-encoded 4-byte emoji prefix (ðŸ...)
        r'\u00e0\u00b4|' // double-encoded Malayalam UTF-8 prefix (à´...)
        r'\u00e2\u20ac|' // double-encoded smart quotes/dashes (â€™, â€œ, â€”)
        r'\u00c2\u00a9|\u00c2\u00ae|' // Â© / Â®
        r'\u00c3[\u00a0-\u00bf]|' // double-encoded German/Latin umlauts (Ã¤, Ã¶, Ã¼, ÃŸ)
        r'\u00ef\u00b8' // variation selector EF B8 (ï¸)
        ')',
      );

      for (final path in filesToCheck) {
        final content = File(path).readAsStringSync();
        expect(
          mojibakePattern.hasMatch(content),
          isFalse,
          reason: 'Found UTF-8 mojibake sequence in $path',
        );
      }
    });

    test('No broken assets/images/placeholder.png or Pocc typos remain in lib/',
        () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains('assets/images/placeholder.png'),
          isFalse,
          reason: 'Found missing asset placeholder.png in ${file.path}',
        );
        expect(
          RegExp(r'\bPocc\b', caseSensitive: false).hasMatch(content),
          isFalse,
          reason: 'Found Pocc spelling typo in ${file.path}',
        );
      }
    });
  });

  group('Poket Focus and Tools Consolidation configuration tests', () {
    test(
        'Under-20 student default tools center on poket_focus and exclude clutter',
        () {
      expect(
          PocketGangToolsService.studentDefaultTools, contains('poket_focus'));
      expect(PocketGangToolsService.studentDefaultTools,
          isNot(contains('study_timer')));
      expect(PocketGangToolsService.studentDefaultTools,
          isNot(contains('exam_tracker')));
      expect(PocketGangToolsService.studentDefaultTools,
          isNot(contains('flashcards')));
    });

    test(
        'Modular plus sheet lists Poket Focus & Poket Spend and drops boring tools',
        () {
      final keys =
          PocketGangModularPlusSheet.availableTools.map((t) => t.key).toSet();
      final names =
          PocketGangModularPlusSheet.availableTools.map((t) => t.name).toSet();

      expect(keys, containsAll(['poket_focus', 'expense_tracker']));
      expect(names, containsAll(['Poket Focus', 'Poket Spend']));
      expect(keys, isNot(contains('quick_poll')));
      expect(keys, isNot(contains('split_wishlist')));
      expect(keys, isNot(contains('habit_tracker')));
    });

    test('Age helper distinguishes students (<20) and 20+ adults accurately',
        () async {
      SharedPreferences.setMockInitialValues({'pm_age_guest': 16});
      expect(await PocketGangToolsService.getCurrentUserAge(), 16);
      expect(await PocketGangToolsService.isUnder20User(), isTrue);

      SharedPreferences.setMockInitialValues({'pm_age_guest': 24});
      expect(await PocketGangToolsService.getCurrentUserAge(), 24);
      expect(await PocketGangToolsService.isUnder20User(), isFalse);
    });

    test('Poket Focus includes both dark and light themes', () {
      expect(PoketFocusPage.focusThemes.any((t) => t.isDark), isTrue);
      expect(PoketFocusPage.focusThemes.any((t) => !t.isDark), isTrue);
    });
  });

  group('Widget UI verification for PoketFocusPage and NotificationsPage', () {
    testWidgets('PoketFocusPage renders modes, themes, and all 5 tabs smoothly',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: PoketFocusPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Poket Focus'), findsOneWidget);
      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Diagram'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Vault'), findsNothing);

      final initialThemeIdx = PoketFocusPage.focusThemeNotifier.value;

      // Tap top theme pill to cycle smoothly without a bottom sheet
      await tester.tap(find.byIcon(Icons.palette_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Choose Poket Focus Theme'), findsNothing);
      final expectedNextIdx =
          (initialThemeIdx + 1) % PoketFocusPage.focusThemes.length;
      expect(PoketFocusPage.focusThemeNotifier.value, expectedNextIdx);

      // Navigate through Tasks, Schedule, Diagram, Habits, and Focus tabs
      for (final tabLabel in [
        'Tasks',
        'Schedule',
        'Diagram',
        'Habits',
        'Focus'
      ]) {
        await tester.tap(find.text(tabLabel));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'NotificationsPage renders Instagram-style Notifications header and filters',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
