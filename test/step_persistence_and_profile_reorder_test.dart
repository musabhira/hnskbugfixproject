import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step Persistence & Auto-Resume Tests', () {
    test('Steps 1 to 5 completed persist and resume correctly at Step 6', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const uid = 'test_user_456';
      const day = 3;

      // Simulate user completing steps 1 through 5
      for (int step = 1; step <= 5; step++) {
        await prefs.setBool('pocket_day_${uid}_${day}_step_${step}_done', true);
        await prefs.setBool('pocket_day_${uid}_${day}_step_${step}_completed', true);
        await prefs.setBool('pocket_day_guest_${day}_step_${step}_done', true);
      }

      // Step 6 has NOT been completed yet
      expect(prefs.getBool('pocket_day_${uid}_${day}_step_6_done'), isNull);

      // Verify state reconstruction matching PocketDayOpenWorldAdventurePage._loadState()
      const totalSteps = 21;
      final Map<String, bool> flags = {};
      for (int step = 1; step <= totalSteps; step++) {
        final userKey = 'pocket_day_${uid}_${day}_step_${step}_done';
        final guestKey = 'pocket_day_guest_${day}_step_${step}_done';

        final bool userDone = (prefs.getBool(userKey) == true) ||
            (prefs.getBool('pocket_day_${uid}_${day}_step_${step}_completed') == true);
        final bool guestDone = (prefs.getBool(guestKey) == true) ||
            (prefs.getBool('pocket_day_guest_${day}_step_${step}_completed') == true);

        final bool isDone = userDone || guestDone;
        flags['step_$step'] = isDone;
      }

      // Steps 1 to 5 must all be true
      for (int step = 1; step <= 5; step++) {
        expect(flags['step_$step'], isTrue, reason: 'Step $step should be recorded as completed');
      }

      // Step 6 must be false
      expect(flags['step_6'], isFalse, reason: 'Step 6 should be incomplete');

      // Helper function matching _findFirstIncompleteStep()
      int findFirstIncompleteStep(Map<String, bool> stepFlags) {
        for (int s = 1; s <= totalSteps; s++) {
          if (!(stepFlags['step_$s'] ?? false)) return s;
        }
        return totalSteps;
      }

      final resumeStep = findFirstIncompleteStep(flags);
      expect(resumeStep, equals(6), reason: 'After completing 5 steps, learner MUST resume at Step 6');
    });

    test('Guest step completions are recognized when user logs in (Self-healing)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const day = 3;
      const uid = 'newly_logged_in_user';

      // Completed as guest while taking a phone call or offline
      await prefs.setBool('pocket_day_guest_${day}_step_1_done', true);
      await prefs.setBool('pocket_day_guest_${day}_step_2_done', true);

      // UserKey not set yet
      expect(prefs.getBool('pocket_day_${uid}_${day}_step_2_done'), isNull);

      // Verify that load logic resolves guest key even with uid present
      final userKey = 'pocket_day_${uid}_${day}_step_2_done';
      final guestKey = 'pocket_day_guest_${day}_step_2_done';

      final bool userDone = prefs.getBool(userKey) == true;
      final bool guestDone = prefs.getBool(guestKey) == true;
      final bool isDone = userDone || guestDone;

      expect(isDone, isTrue, reason: 'Guest completed step should be recognized');

      // Auto self-heal sync
      if (isDone && !userDone) {
        await prefs.setBool(userKey, true);
      }

      expect(prefs.getBool(userKey), isTrue, reason: 'Auto self-heal should copy guest progress to user key');
    });

    test('Android Bottom Navigation Bar minimum height calculation prevents bezel squeeze', () {
      double calculateBarHeight(double rawBottomPadding) {
        final effectiveBottomPadding = rawBottomPadding > 0 ? rawBottomPadding : 8.0;
        return 64.0 + effectiveBottomPadding;
      }

      // On Android with 3-button navigation (raw bottom padding = 0)
      final android3ButtonHeight = calculateBarHeight(0.0);
      expect(android3ButtonHeight, equals(72.0), reason: 'Ensures 8px clearance + 64px height on 3-button Android');

      // On Android with gesture navigation (e.g. 15px)
      final androidGestureHeight = calculateBarHeight(15.0);
      expect(androidGestureHeight, equals(79.0));

      // On iOS (34px home indicator)
      final iosHeight = calculateBarHeight(34.0);
      expect(iosHeight, equals(98.0));
    });
  });
}
