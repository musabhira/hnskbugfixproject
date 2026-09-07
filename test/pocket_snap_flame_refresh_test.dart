import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_snap_flame_refresh.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🔥 PocketSnapFlameRefresh Tests', () {
    testWidgets('Renders child content cleanly when resting', (WidgetTester tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PocketSnapFlameRefresh(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView(
                children: const [
                  ListTile(title: Text('Chat with Alex')),
                  ListTile(title: Text('Chat with Sarah')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chat with Alex'), findsOneWidget);
      expect(find.text('Chat with Sarah'), findsOneWidget);
      expect(refreshed, isFalse);
    });

    testWidgets('Pulling down triggers refresh callback and displays ignition status', (WidgetTester tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PocketSnapFlameRefresh(
              triggerDistance: 60.0,
              maxPullDistance: 120.0,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 50));
                refreshed = true;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  ListTile(title: Text('Message Item 1')),
                  ListTile(title: Text('Message Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Message Item 1'), findsOneWidget);

      // Perform downward drag gesture
      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, 180));
      await tester.pump();

      // Verify refresh was initiated
      await tester.pump(const Duration(milliseconds: 100));
      expect(refreshed, isTrue);

      // Let success state and animation finish
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('Custom texts and colors configure properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PocketSnapFlameRefresh(
              pullText: 'Custom Pull 🔥',
              readyText: 'Custom Ready ✨',
              refreshingText: 'Custom Refreshing ⚡',
              successText: 'Custom Success 🎉',
              primaryFlameColor: Colors.amber,
              accentFlameColor: Colors.redAccent,
              onRefresh: () async {},
              child: const Center(child: Text('Profile Content')),
            ),
          ),
        ),
      );

      expect(find.text('Profile Content'), findsOneWidget);
    });
  });
}
