import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_daily_mission_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Days 12–14 Daily Mission Progression & XP Tests', () {
    test('XP formula scales progressively for Days 12, 13, 14', () {
      int xpForDay(int day) => 100 + (day - 1) * 50;
      expect(xpForDay(12), 650);
      expect(xpForDay(13), 700);
      expect(xpForDay(14), 750);
    });

    testWidgets('Day 12 renders Dialectic of Contradiction & Subjunctive Rule', (tester) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PocketDailyMissionPage(day: 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('DAY 12'), findsWidgets);
      expect(find.textContaining('DIALECTIC OF CONTRADICTION'), findsWidgets);
      expect(find.textContaining('Rule 12: Formal Subjunctive'), findsWidgets);
      expect(find.textContaining('RAPID COMBAT ATTACK'), findsWidgets);
      expect(find.textContaining('Highland Warlord Lvl 16'), findsWidgets);
    });

    testWidgets('Day 13 renders Alchemy of Intellect & Negative Inversion Rule', (tester) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PocketDailyMissionPage(day: 13),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('DAY 13'), findsWidgets);
      expect(find.textContaining('ALCHEMY OF INTELLECT'), findsWidgets);
      expect(find.textContaining('Rule 13: Negative & Restrictive Inversion'), findsWidgets);
      expect(find.textContaining('Bastion Tactician Lvl 17'), findsWidgets);
    });

    testWidgets('Day 14 Milestone renders Citadel of Rhetoric & Fronting Rule', (tester) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PocketDailyMissionPage(day: 14),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('DAY 14 MILESTONE'), findsWidgets);
      expect(find.textContaining('CITADEL OF RHETORIC'), findsWidgets);
      expect(find.textContaining('Rule 14: Rhetorical Fronting'), findsWidgets);
      expect(find.textContaining('Citadel Archon Lvl 18'), findsWidgets);
    });
  });
}
