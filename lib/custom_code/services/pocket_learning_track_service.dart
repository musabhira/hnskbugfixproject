import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

/// 🌍 Unified Target Track Service (English Mastery vs German A1 Master Track)
/// Allows reusing the exact same UI, Open-World Mountain Climb, Games, and Avatar Voice Engine
/// while isolating progress keys and switching curriculum + TTS/STT locales cleanly.
class PocketLearningTrackService {
  PocketLearningTrackService._();

  static const String trackEnglish = 'english';
  static const String trackGerman = 'german';
  static const int germanMaxDay = 90;
  static const int germanPhase1MaxDay = 90;

  static final ValueNotifier<String> activeTrackNotifier =
      ValueNotifier<String>(trackEnglish);

  static String get currentTrack => activeTrackNotifier.value;
  static bool get isGerman => activeTrackNotifier.value == trackGerman;
  static bool get isEnglish => !isGerman;

  static String get ttsLocale => isGerman ? 'de-DE' : 'en-US';
  static String get sttLocale => isGerman ? 'de_DE' : 'en_US';

  /// Isolated SharedPreferences key prefixes so German progress never overwrites English progress
  static String get dayPrefPrefix => isGerman ? 'pocket_de_day_' : 'pocket_day_';
  static String get learningDatePrefix =>
      isGerman ? 'learning_de_day_' : 'learning_day_';
  static String get gateBreachedPrefix =>
      isGerman ? 'pocket_de_gate_' : 'pocket_gate_';
  static String get stagePrefPrefix =>
      isGerman ? 'pocket_learning_de_stage_' : 'pocket_learning_user_stage_';
  static String get activeDayPrefPrefix =>
      isGerman ? 'learning_de_day_' : 'learning_day_';

  static String lastCompletedDayKey(String uid) => isGerman
      ? 'learning_de_last_completed_day_$uid'
      : 'learning_last_completed_day_$uid';

  static String currentDayPref(String uid) =>
      isGerman ? 'learning_de_current_day_$uid' : 'learning_current_day_$uid';

  static String scorePref(String uid) =>
      isGerman ? 'learning_de_score_$uid' : 'learning_score_$uid';

  static String streakPref(String uid) =>
      isGerman ? 'learning_de_streak_$uid' : 'learning_streak_$uid';

  static String completedDayPref(String uid, int day) =>
      '${dayPrefPrefix}${uid}_${day}_completed';

  static String get displayTitle =>
      isGerman ? 'Deutsch 90-Tage-Kurs' : 'English Mastery Track';
  static String get displayPillTitle =>
      isGerman ? 'DEUTSCH 90-DAY TRACK' : 'ENGLISH MASTERY TRACK';

  static bool _initialized = false;

  static Future<String> init({bool force = false, String? userId}) async {
    if (_initialized && !force) return activeTrackNotifier.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      String uid = userId ?? '';
      if (uid.isEmpty) {
        try {
          uid = SupaFlow.client.auth.currentUser?.id ?? '';
        } catch (_) {}
      }
      String? saved;
      if (uid.isNotEmpty) {
        saved = prefs.getString('pm_active_learning_track_$uid');
      }
      saved ??= prefs.getString('pm_active_learning_track');
      if (saved == trackGerman) {
        activeTrackNotifier.value = trackGerman;
      } else {
        activeTrackNotifier.value = trackEnglish;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('PocketLearningTrackService init error: $e');
    }
    return activeTrackNotifier.value;
  }

  static Future<void> setTrack(String track, {String? userId}) async {
    final normalized = track == trackGerman ? trackGerman : trackEnglish;
    activeTrackNotifier.value = normalized;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String uid = userId ?? '';
      if (uid.isEmpty) {
        try {
          uid = SupaFlow.client.auth.currentUser?.id ?? '';
        } catch (_) {}
      }
      if (uid.isNotEmpty) {
        await prefs.setString('pm_active_learning_track_$uid', normalized);
      }
      await prefs.setString('pm_active_learning_track', normalized);
      await prefs.setString(
          'pm_target_language', normalized == trackGerman ? 'German' : 'English');
    } catch (e) {
      debugPrint('PocketLearningTrackService setTrack error: $e');
    }
  }
}
