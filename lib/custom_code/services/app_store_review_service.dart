import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🛡️ App Store / Google Play Store Review Mode & World Switch Guard Service
///
/// Features requested:
/// 1. Android toggle: Hide Kids & Student mode entry buttons on Android (Globe icon & Settings tile)
/// 2. iOS toggle: Hide Kids & Student mode entry buttons on iOS
/// 3. Specific reviewer email override (e.g. `hira@gmail.com`):
///    - If enabled, strictly hides Kids & Student world switch buttons for this account,
///      even if global platform toggles are off.
/// 4. Synchronous cached check (`isWorldSwitchVisible`) with background Supabase fetch & reactive notifier.
class AppStoreReviewService {
  static const String _kReviewConfigKey = 'app_store_review_mode_config';
  static const String _kPrefsHideAndroid = 'pm_review_hide_kids_android';
  static const String _kPrefsHideIos = 'pm_review_hide_kids_ios';
  static const String _kPrefsHideReviewEmail = 'pm_review_hide_kids_review_email';
  static const String _kPrefsReviewEmail = 'pm_review_custom_email';

  /// Default reviewer account specified by user
  static const String defaultReviewerEmail = 'hira@gmail.com';

  /// In-memory cache for ultra-fast, zero-jank synchronous UI builds
  static bool _hideOnAndroid = false;
  static bool _hideOnIos = false;
  static bool _hideForReviewerEmail = true; // default true for hira@gmail.com review safety
  static String _reviewerEmail = defaultReviewerEmail;
  static bool _initialized = false;

  /// Reactive notifier for UI components (Header Globe icon, Settings tile, Chat popup)
  static final ValueNotifier<bool> worldSwitchVisibleNotifier = ValueNotifier<bool>(true);

  static String _cachedUserEmail = '';
  static const String _kPrefsCachedUserEmail = 'pm_review_cached_user_email';

  /// Synchronous getter to check if World Switch Buttons should be shown right now
  static bool get isWorldSwitchVisible {
    if (!_initialized) {
      _loadFromPrefsSyncFallback();
    }

    final currentUser = SupaFlow.client.auth.currentUser;
    String userEmail = currentUser?.email?.toLowerCase().trim() ?? '';
    if (userEmail.isEmpty && _cachedUserEmail.isNotEmpty) {
      userEmail = _cachedUserEmail;
    }
    final targetReviewEmail = _reviewerEmail.toLowerCase().trim();

    // 1. Email Specific Hide Check (e.g., hira@gmail.com)
    if (_hideForReviewerEmail) {
      if (userEmail.isNotEmpty &&
          (userEmail == defaultReviewerEmail ||
              userEmail.startsWith('hira@') ||
              userEmail.contains('hira@') ||
              (targetReviewEmail.isNotEmpty &&
                  (userEmail == targetReviewEmail ||
                      userEmail.contains(targetReviewEmail))))) {
        return false; // HIDE for review account!
      }
    }

    // 2. Platform Specific Hide Check
    if (!kIsWeb) {
      if (Platform.isAndroid && _hideOnAndroid) {
        return false; // HIDE on Android
      }
      if (Platform.isIOS && _hideOnIos) {
        return false; // HIDE on iOS
      }
    }

    return true; // Show normally
  }

  /// Initialize service at app startup and fetch remote config from Supabase
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hideOnAndroid = prefs.getBool(_kPrefsHideAndroid) ?? false;
      _hideOnIos = prefs.getBool(_kPrefsHideIos) ?? false;
      _hideForReviewerEmail = prefs.getBool(_kPrefsHideReviewEmail) ?? true;
      _reviewerEmail = prefs.getString(_kPrefsReviewEmail) ?? defaultReviewerEmail;
      _cachedUserEmail = prefs.getString(_kPrefsCachedUserEmail) ??
          (SupaFlow.client.auth.currentUser?.email?.toLowerCase().trim() ?? '');
      _initialized = true;
      _updateNotifier();

      // Listen to auth changes so when user logs in/out, notifier updates immediately
      try {
        SupaFlow.client.auth.onAuthStateChange.listen((data) {
          final email = data.session?.user.email ?? SupaFlow.client.auth.currentUser?.email;
          if (email != null && email.isNotEmpty) {
            _cachedUserEmail = email.toLowerCase().trim();
            prefs.setString(_kPrefsCachedUserEmail, _cachedUserEmail);
          }
          _updateNotifier();
        });
      } catch (_) {}

      // Fetch from Supabase app_tool_configs
      await fetchRemoteReviewConfig();

      // Listen to Supabase realtime updates on app_tool_configs
      try {
        SupaFlow.client
            .from('app_tool_configs')
            .stream(primaryKey: ['tool_name'])
            .eq('tool_name', _kReviewConfigKey)
            .listen((data) {
              if (data.isNotEmpty) {
                final row = data.first;
                _hideOnAndroid = row['android_active'] == true;
                _hideOnIos = row['ios_active'] == true;
                if (row['reviewer_email_hide'] != null) {
                  _hideForReviewerEmail = row['reviewer_email_hide'] == true;
                }
                if (row['reviewer_email'] != null && row['reviewer_email'].toString().isNotEmpty) {
                  _reviewerEmail = row['reviewer_email'].toString();
                }
                _updateNotifier();
              }
            });
      } catch (_) {}
    } catch (_) {
      _initialized = true;
      _updateNotifier();
    }
  }

  /// Fallback sync load
  static void _loadFromPrefsSyncFallback() {
    _initialized = true;
    _updateNotifier();
  }

  /// Refresh from Supabase table: `app_tool_configs` (or local fallback)
  static Future<void> fetchRemoteReviewConfig() async {
    try {
      final res = await SupaFlow.client
          .from('app_tool_configs')
          .select('*')
          .eq('tool_name', _kReviewConfigKey)
          .maybeSingle();

      if (res != null) {
        _hideOnAndroid = res['android_active'] == true;
        _hideOnIos = res['ios_active'] == true;
        if (res['reviewer_email_hide'] != null) {
          _hideForReviewerEmail = res['reviewer_email_hide'] == true;
        }
        if (res['reviewer_email'] != null && res['reviewer_email'].toString().isNotEmpty) {
          _reviewerEmail = res['reviewer_email'].toString();
        }

        // Cache locally in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kPrefsHideAndroid, _hideOnAndroid);
        await prefs.setBool(_kPrefsHideIos, _hideOnIos);
        await prefs.setBool(_kPrefsHideReviewEmail, _hideForReviewerEmail);
        await prefs.setString(_kPrefsReviewEmail, _reviewerEmail);
        _updateNotifier();
      }
    } catch (e) {
      debugPrint('AppStoreReviewService fetchRemoteReviewConfig notice: $e');
    }
  }

  /// Update admin review settings in Supabase and SharedPreferences
  static Future<void> updateReviewConfig({
    required bool hideOnAndroid,
    required bool hideOnIos,
    required bool hideForReviewerEmail,
    required String reviewerEmail,
  }) async {
    _hideOnAndroid = hideOnAndroid;
    _hideOnIos = hideOnIos;
    _hideForReviewerEmail = hideForReviewerEmail;
    _reviewerEmail = reviewerEmail.trim().isEmpty ? defaultReviewerEmail : reviewerEmail.trim();

    _updateNotifier();

    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefsHideAndroid, _hideOnAndroid);
      await prefs.setBool(_kPrefsHideIos, _hideOnIos);
      await prefs.setBool(_kPrefsHideReviewEmail, _hideForReviewerEmail);
      await prefs.setString(_kPrefsReviewEmail, _reviewerEmail);
    } catch (_) {}

    // 2. Persist in Supabase `app_tool_configs`
    try {
      await SupaFlow.client.from('app_tool_configs').upsert({
        'tool_name': _kReviewConfigKey,
        'android_active': _hideOnAndroid,
        'ios_active': _hideOnIos,
        'reviewer_email_hide': _hideForReviewerEmail,
        'reviewer_email': _reviewerEmail,
      }, onConflict: 'tool_name');
    } catch (e) {
      debugPrint('AppStoreReviewService updateReviewConfig error: $e');
    }
  }

  static void _updateNotifier() {
    worldSwitchVisibleNotifier.value = isWorldSwitchVisible;
  }

  // Getters for Admin UI
  static bool get hideOnAndroid => _hideOnAndroid;
  static bool get hideOnIos => _hideOnIos;
  static bool get hideForReviewerEmail => _hideForReviewerEmail;
  static String get reviewerEmail => _reviewerEmail;
}
