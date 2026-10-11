import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

/// 🏡 Kids House / Homestead Model
class KidsHouse {
  final int tier;
  final String title;
  final String emoji;
  final String description;
  final int unlockedAtDay;
  final Color themeColor;

  const KidsHouse({
    required this.tier,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlockedAtDay,
    required this.themeColor,
  });
}

/// 🧸 Service for managing Kids vs Adult account separation,
/// Kids profile state, 100-Day learning journey, and parental safety gates.
class PocketKidsService {
  static const String _keyIsKidAccount = 'pm_is_kid_account';
  static const String _keyKidName = 'pm_kid_name';
  static const String _keyKidAgeGroup = 'pm_kid_age_group';
  static const String _keyKidAvatar = 'pm_kid_avatar';
  static const String _keyKidStars = 'pm_kid_stars';
  static const String _keyKidCurrentDay = 'pm_kid_current_day';
  static const String _keyKidCompletedDays = 'pm_kid_completed_days';

  static final ValueNotifier<bool> isKidAccountNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<int> kidStarsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> kidDayNotifier = ValueNotifier<int>(1);
  static bool _initialized = false;

  static bool _isKidAccount = false;
  static String _kidName = 'Little Explorer';
  static String _kidAgeGroup = '4-6';
  static String _kidAvatar = '🦁';
  static int _kidStars = 0;
  static int _currentUnlockedDay = 1;
  static final Map<int, int> _completedDays = {}; // day -> stars earned (1-3)

  static bool get isKidAccount => _isKidAccount;
  static String get kidName => _kidName;
  static String get kidAgeGroup => _kidAgeGroup;
  static String get kidAvatar => _kidAvatar;
  static int get kidStars => _kidStars;
  static int get currentUnlockedDay => _currentUnlockedDay;
  static Map<int, int> get completedDays => Map.unmodifiable(_completedDays);

  /// 🏰 Milestone Achievable Houses for Kids
  static const List<KidsHouse> houses = [
    KidsHouse(
      tier: 1,
      title: 'Rainbow Treehouse',
      emoji: '🌳',
      description: 'Cozy wooden treehouse nestled high in ABC Valley!',
      unlockedAtDay: 1,
      themeColor: Color(0xFF10B981),
    ),
    KidsHouse(
      tier: 2,
      title: 'Candy Cottage',
      emoji: '🍭',
      description: 'Sweet gingerbread cottage made of sugary treats!',
      unlockedAtDay: 16,
      themeColor: Color(0xFFF43F5E),
    ),
    KidsHouse(
      tier: 3,
      title: 'Dino Safari Den',
      emoji: '🦖',
      description: 'Prehistoric cave filled with friendly dinosaurs!',
      unlockedAtDay: 31,
      themeColor: Color(0xFFF59E0B),
    ),
    KidsHouse(
      tier: 4,
      title: 'Magic Sky Castle',
      emoji: '🏰',
      description: 'Majestic fortress floating above cloud kingdom!',
      unlockedAtDay: 51,
      themeColor: Color(0xFF6366F1),
    ),
    KidsHouse(
      tier: 5,
      title: 'Crystal Star Palace',
      emoji: '👑',
      description: 'Grand champion palace shining across the universe!',
      unlockedAtDay: 76,
      themeColor: Color(0xFFFFD700),
    ),
  ];

  /// Get the kid's currently unlocked house based on their completed days
  static KidsHouse get currentHouse {
    int maxCompleted = 1;
    for (final day in _completedDays.keys) {
      if (day > maxCompleted) maxCompleted = day;
    }
    final effectiveDay = maxCompleted > _currentUnlockedDay ? maxCompleted : _currentUnlockedDay;
    KidsHouse achieved = houses.first;
    for (final h in houses) {
      if (effectiveDay >= h.unlockedAtDay) {
        achieved = h;
      }
    }
    return achieved;
  }

  /// Get the next house to unlock
  static KidsHouse? get nextHouseToUnlock {
    final cur = currentHouse;
    final idx = houses.indexOf(cur);
    if (idx >= 0 && idx + 1 < houses.length) {
      return houses[idx + 1];
    }
    return null;
  }

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
      _currentUnlockedDay = prefs.getInt(_keyKidCurrentDay) ?? 1;

      final savedDaysJson = prefs.getString(_keyKidCompletedDays);
      if (savedDaysJson != null && savedDaysJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedDaysJson) as Map<String, dynamic>;
          _completedDays.clear();
          decoded.forEach((k, v) {
            final day = int.tryParse(k);
            final stars = v is int ? v : 3;
            if (day != null) _completedDays[day] = stars;
          });
        } catch (_) {}
      }

      isKidAccountNotifier.value = _isKidAccount;
      kidStarsNotifier.value = _kidStars;
      kidDayNotifier.value = _currentUnlockedDay;
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
    kidStarsNotifier.value = _kidStars;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidStars, _kidStars);
    } catch (_) {}
  }

  /// Record completion of a day game session
  static Future<void> completeDayGame(int day, int starsEarned) async {
    _completedDays[day] = starsEarned;
    await addStars(starsEarned);

    if (day >= _currentUnlockedDay && _currentUnlockedDay < 100) {
      _currentUnlockedDay = day + 1;
      kidDayNotifier.value = _currentUnlockedDay;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidCurrentDay, _currentUnlockedDay);
      final jsonMap = _completedDays.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_keyKidCompletedDays, jsonEncode(jsonMap));
    } catch (_) {}
  }

  /// Reset or update progress (for testing or profile editing)
  static Future<void> updateKidProfile({
    String? name,
    String? ageGroup,
    String? avatar,
  }) async {
    if (name != null) _kidName = name;
    if (ageGroup != null) _kidAgeGroup = ageGroup;
    if (avatar != null) _kidAvatar = avatar;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_keyKidName, _kidName);
      if (ageGroup != null) await prefs.setString(_keyKidAgeGroup, _kidAgeGroup);
      if (avatar != null) await prefs.setString(_keyKidAvatar, _kidAvatar);
    } catch (_) {}
  }
}
