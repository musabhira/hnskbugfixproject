import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('PocketMissionTimerService Rules & Lifecycle Tests', () {
    test('Timer initializes with default 60 minutes (3600 seconds) target', () async {
      final service = PocketMissionTimerService.instance;
      await service.initForDay(1);

      expect(service.day, 1);
      expect(service.targetSeconds, 3600);
      expect(service.elapsedSeconds, 0);
      expect(service.hasReachedTarget, isFalse);
      expect(service.formatTime(3600), '60:00');
    });

    test('Loads existing elapsed practice time from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_mission_day_2_elapsed_sec': 1245,
        'pocket_mission_day_2_target_sec': 3600,
      });

      final service = PocketMissionTimerService.instance;
      await service.initForDay(2);

      expect(service.day, 2);
      expect(service.elapsedSeconds, 1245);
      expect(service.formatTime(), '20:45');
      expect(service.hasReachedTarget, isFalse);
    });

    test('Clamps elapsed time if loaded value exceeds target', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_mission_day_3_elapsed_sec': 4000,
        'pocket_mission_day_3_target_sec': 3600,
      });

      final service = PocketMissionTimerService.instance;
      await service.initForDay(3);

      expect(service.elapsedSeconds, 3600);
      expect(service.hasReachedTarget, isTrue);
    });

    test('Auto-pauses when app lifecycle transitions to background (paused / inactive)', () async {
      final service = PocketMissionTimerService.instance;
      await service.initForDay(1);

      service.startTimer();
      expect(service.isRunning, isTrue);

      // App minimized / phone locked
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(service.isRunning, isFalse);
      expect(service.pauseReason, contains('background'));

      // Call inactive (e.g. notification tray pulled down)
      service.startTimer();
      expect(service.isRunning, isTrue);
      service.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(service.isRunning, isFalse);
    });

    test('addAnotherHourPractice increases target by +3600 seconds', () async {
      final service = PocketMissionTimerService.instance;
      await service.initForDay(1);

      expect(service.targetSeconds, 3600);
      service.addAnotherHourPractice();
      expect(service.targetSeconds, 7200);
      expect(service.formatTime(service.targetSeconds), '120:00');
      service.pauseTimer();
    });

    test('restartPracticeSession resets elapsed seconds back to 0', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_mission_day_1_elapsed_sec': 3600,
        'pocket_mission_day_1_target_sec': 3600,
      });

      final service = PocketMissionTimerService.instance;
      await service.initForDay(1);
      expect(service.hasReachedTarget, isTrue);

      service.restartPracticeSession();
      expect(service.elapsedSeconds, 0);
      expect(service.hasReachedTarget, isFalse);
      service.pauseTimer();
    });
  });
}
