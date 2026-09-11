import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/services/push_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Mission Midnight Unlock & Countdown Tests', () {
    test('getRemainingTimeUntilMidnight returns positive duration <= 24 hours', () {
      final remaining = Learning60DayService.getRemainingTimeUntilMidnight();
      expect(remaining.isNegative, isFalse);
      expect(remaining.inHours, lessThanOrEqualTo(24));
      expect(remaining.inSeconds, greaterThan(0));
    });

    test('formatRemainingCountdown correctly formats durations', () {
      const d1 = Duration(hours: 4, minutes: 22, seconds: 15);
      expect(Learning60DayService.formatRemainingCountdown(d1), '04h : 22m : 15s');

      const d2 = Duration(hours: 0, minutes: 5, seconds: 9);
      expect(Learning60DayService.formatRemainingCountdown(d2), '00h : 05m : 09s');

      const d3 = Duration(seconds: -10);
      expect(Learning60DayService.formatRemainingCountdown(d3), '00h : 00m : 00s');
    });

    test('isDayWaitingForMidnightUnlock returns true only when previous day completed today', () async {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}';

      SharedPreferences.setMockInitialValues({
        'learning_last_completed_day': 5,
        'learning_day_5_completed_date': todayStr,
      });

      // Day 6 (5 + 1) completed today -> waiting for midnight unlock!
      final isDay6Waiting = await Learning60DayService.isDayWaitingForMidnightUnlock(6);
      expect(isDay6Waiting, isTrue);

      // Day 5 (already completed) -> not waiting
      final isDay5Waiting = await Learning60DayService.isDayWaitingForMidnightUnlock(5);
      expect(isDay5Waiting, isFalse);

      // Day 7 (not next day) -> not waiting
      final isDay7Waiting = await Learning60DayService.isDayWaitingForMidnightUnlock(7);
      expect(isDay7Waiting, isFalse);
    });

    test('isDayWaitingForMidnightUnlock returns false if completed on earlier day', () async {
      SharedPreferences.setMockInitialValues({
        'learning_last_completed_day': 5,
        'learning_day_5_completed_date': '2025-01-01', // Earlier date
      });

      // Midnight has already passed since completion
      final isWaiting = await Learning60DayService.isDayWaitingForMidnightUnlock(6);
      expect(isWaiting, isFalse);
    });

    test('scheduleMorningMissionNotification does not throw on test environment', () {
      expect(
        () => PushNotificationService.scheduleMorningMissionNotification(
          day: 12,
          targetHour: 8,
          targetMinute: 30,
        ),
        returnsNormally,
      );
    });
  });
}
