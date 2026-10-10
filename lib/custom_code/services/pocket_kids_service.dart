import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

/// 🧸 Service for managing Kids vs Adult account separation,
/// Kids profile state, and parental safety gates.
class PocketKidsService {
  static const String _keyIsKidAccount = 'pm_is_kid_account';
  static const String _keyKidName = 'pm_kid_name';
  static const String _keyKidAgeGroup = 'pm_kid_age_group';
  static const String _keyKidAvatar = 'pm_kid_avatar';
  static const String _keyKidStars = 'pm_kid_stars';

  static final ValueNotifier<bool> isKidAccountNotifier = ValueNotifier<bool>(false);
  static bool _initialized = false;

  static bool _isKidAccount = false;
  static String _kidName = 'Little Explorer';
  static String _kidAgeGroup = '4-6';
  static String _kidAvatar = '🦁';
  static int _kidStars = 0;

  static bool get isKidAccount => _isKidAccount;
  static String get kidName => _kidName;
  static String get kidAgeGroup => _kidAgeGroup;
  static String get kidAvatar => _kidAvatar;
  static int get kidStars => _kidStars;

  /// Load cached account mode from SharedPreferences
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isKidAccount = prefs.getBool(_keyIsKidAccount) ?? false;
      _kidName = prefs.getString(_keyKidName) ?? 'Little Explorer';
      _kidAgeGroup = prefs.getString(_keyKidAgeGroup) ?? '4-6';
      _kidAvatar = prefs.getString(_keyKidAvatar) ?? '🦁';
      _kidStars = prefs.getInt(_keyKidStars) ?? 0;
      isKidAccountNotifier.value = _isKidAccount;
      _initialized = true;
    } catch (e) {
      debugPrint('PocketKidsService: Error initializing: $e');
    }
  }

  /// Activate Kids Account Mode and save profile
  static Future<void> activateKidAccount({
    required String name,
    required String ageGroup,
    required String avatar,
  }) async {
    _isKidAccount = true;
    _kidName = name.trim().isNotEmpty ? name.trim() : 'Little Explorer';
    _kidAgeGroup = ageGroup;
    _kidAvatar = avatar;
    isKidAccountNotifier.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsKidAccount, true);
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAgeGroup, _kidAgeGroup);
      await prefs.setString(_keyKidAvatar, _kidAvatar);

      // Also persist to Supabase user metadata if logged in
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', true);
        await SupaFlow.client.from('profile').update({
          'account_type': 'kid',
          'kid_name': _kidName,
          'kid_age_group': _kidAgeGroup,
          'kid_avatar': _kidAvatar,
        }).eq('user_id', user.id).catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating kid account: $e');
    }
  }

  /// Activate Adult Account Mode
  static Future<void> activateAdultAccount() async {
    _isKidAccount = false;
    isKidAccountNotifier.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsKidAccount, false);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', false);
        await SupaFlow.client.from('profile').update({
          'account_type': 'adult',
        }).eq('user_id', user.id).catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating adult account: $e');
    }
  }

  /// Add stars to the kid's bank
  static Future<void> addStars(int amount) async {
    _kidStars += amount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidStars, _kidStars);
    } catch (_) {}
  }
}
