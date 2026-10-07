import 'dart:convert';
import 'package:flutter/services.dart';

/// 🏛️ Universal Modular Day Curriculum Service (Days 1 to 90)
///
/// Loads each day's dedicated JSON file (e.g. `assets/curriculum/day_1_curriculum.json`,
/// `assets/curriculum/day_2_curriculum.json`, ...) dynamically from assets.
/// Provides seamless multi-language translation resolution and caching.
class PocketDayCurriculumService {
  static final Map<int, Map<String, dynamic>> _cache = {};

  static bool isSupportedDay(int day) => day >= 1 && day <= 90;

  /// Loads the curriculum data for any specified [day] (1 to 90)
  static Future<Map<String, dynamic>?> loadDayCurriculum(int day) async {
    if (!isSupportedDay(day)) return null;
    if (_cache.containsKey(day)) {
      return _cache[day];
    }

    try {
      final assetPath = 'assets/curriculum/day_${day}_curriculum.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      _cache[day] = data;
      return data;
    } catch (e) {
      // Fallback: check master syllabus if day JSON not yet created
      return null;
    }
  }

  /// Loads a curriculum day or throws a clear error for callers that cannot
  /// render a legacy fallback safely.
  static Future<Map<String, dynamic>> loadRequiredDayCurriculum(int day) async {
    final data = await loadDayCurriculum(day);
    if (data == null) {
      throw StateError('Unable to load curriculum for day $day.');
    }
    return data;
  }

  /// Preloads a day before a screen builds synchronous child widgets.
  static Future<void> preloadDay(int day) async {
    await loadRequiredDayCurriculum(day);
  }

  /// Synchronous cached getter (returns null if day not yet loaded)
  static Map<String, dynamic>? getCachedDay(int day) {
    return _cache[day];
  }

  /// Helper to resolve localized text from a map or dynamic field
  /// Supports Malayalam ('ml'), Hindi ('hi'), Tamil ('ta'), Telugu ('te'), and English ('en')
  static String getLocalizedText(
    dynamic field, {
    String lang = 'en',
    String fallback = '',
  }) {
    if (field == null) return fallback;
    if (field is String) return field;
    if (field is Map) {
      final l = lang.toLowerCase();
      if (l.startsWith('ml') || l.contains('malay')) {
        return field['ml']?.toString() ?? field['en']?.toString() ?? fallback;
      }
      if (l.startsWith('hi') || l.contains('hind')) {
        return field['hi']?.toString() ?? field['en']?.toString() ?? fallback;
      }
      if (l.startsWith('ta') || l.contains('tamil')) {
        return field['ta']?.toString() ?? field['en']?.toString() ?? fallback;
      }
      if (l.startsWith('te') || l.contains('telug')) {
        return field['te']?.toString() ?? field['en']?.toString() ?? fallback;
      }
      return field['en']?.toString() ?? field.values.firstOrNull?.toString() ?? fallback;
    }
    return field.toString();
  }

  /// Clears cache (useful for hot reload / testing edits)
  static void clearCache() {
    _cache.clear();
  }
}
