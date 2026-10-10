import 'package:flutter/material.dart';
import 'english_realm_models.dart';
import 'english_realm_data_p1.dart';
import 'english_realm_data_p2.dart';
import 'english_realm_data_p3.dart';

/// 🏛️ Master Manifest for all 180 Games across the 90-Day English Realm
class EnglishRealmManifest {
  /// 9 Thematic Regions in the English Realm
  static const List<RealmRegion> regions = [
    RealmRegion(
      id: 'foundations_village',
      name: 'English Foundations Village',
      nameMl: 'അടിസ്ഥാന ഇംഗ്ലീഷ് ഗ്രാമം',
      startDay: 1,
      endDay: 7,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
      landmark: '🌿 The Golden Phonics Mill',
      description: 'Cozy cobblestone paths, peaceful cottages, and phonics workshops.',
      icon: '🏡',
      worldStartX: 0.0,
      worldEndX: 2800.0,
    ),
    RealmRegion(
      id: 'sentence_forest',
      name: 'Sentence Structure Forest',
      nameMl: 'വാക്യഘടന വനം',
      startDay: 8,
      endDay: 14,
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF0E7490),
      landmark: '🌲 The Ancient Grammar Canopy',
      description: 'Lush pines, sparkling river bridges, and sentence puzzle shrines.',
      icon: '🌲',
      worldStartX: 2800.0,
      worldEndX: 5600.0,
    ),
    RealmRegion(
      id: 'tense_kingdom',
      name: 'Tense Kingdom',
      nameMl: 'കാലങ്ങളുടെ രാജ്യം (Tense Kingdom)',
      startDay: 15,
      endDay: 30,
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF1D4ED8),
      landmark: '🏰 The Clocktower Citadel',
      description: 'Grand castle gates, royal timekeeper squares, and tense timeline arches.',
      icon: '🏰',
      worldStartX: 5600.0,
      worldEndX: 12000.0,
    ),
    RealmRegion(
      id: 'modal_mountains',
      name: 'Question & Modal Mountains',
      nameMl: 'മോഡൽ & ചോദ്യ പർവ്വതനിരകൾ',
      startDay: 31,
      endDay: 40,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
      landmark: '⛰️ Mount Interrogation',
      description: 'Snow-capped trails, torchlit explorer basecamps, and modal bridges.',
      icon: '⛰️',
      worldStartX: 12000.0,
      worldEndX: 16000.0,
    ),
    RealmRegion(
      id: 'verb_caverns',
      name: 'Verb & Grammar Caverns',
      nameMl: 'ക്രിയാ ഗുഹകൾ',
      startDay: 41,
      endDay: 50,
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFBE185D),
      landmark: '💎 Crystal Mine of Participles',
      description: 'Glowing amethyst tunnels, subterranean rivers, and voice transformers.',
      icon: '💎',
      worldStartX: 16000.0,
      worldEndX: 20000.0,
    ),
    RealmRegion(
      id: 'grammar_citadel',
      name: 'Complex Grammar Citadel',
      nameMl: 'കോംപ്ലക്സ് ഗ്രാമർ കോട്ട',
      startDay: 51,
      endDay: 60,
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFF6D28D9),
      landmark: '🏛️ The Hall of Conditionals',
      description: 'Marble colonnades, floating rune crystals, and reported speech halls.',
      icon: '🏛️',
      worldStartX: 20000.0,
      worldEndX: 24000.0,
    ),
    RealmRegion(
      id: 'sentence_islands',
      name: 'Advanced Sentence Islands',
      nameMl: 'വാക്യ നിർമ്മാണ ദ്വീപുകൾ',
      startDay: 61,
      endDay: 70,
      primaryColor: Color(0xFF14B8A6),
      secondaryColor: Color(0xFF0F766E),
      landmark: '🏝️ The Archipelago of Inversion',
      description: 'Turquoise lagoons, rope bridges, and clause connection lighthouses.',
      icon: '🏝️',
      worldStartX: 24000.0,
      worldEndX: 28000.0,
    ),
    RealmRegion(
      id: 'vocab_town',
      name: 'Vocabulary Trading Town',
      nameMl: 'പദസമ്പത്ത് വ്യാപാര നഗരം',
      startDay: 71,
      endDay: 80,
      primaryColor: Color(0xFFFF8906),
      secondaryColor: Color(0xFFEA580C),
      landmark: '🎪 The Grand Collocation Bazaar',
      description: 'Bustling harbor markets, spice stalls, idiom cafés, and word forges.',
      icon: '🎪',
      worldStartX: 28000.0,
      worldEndX: 32000.0,
    ),
    RealmRegion(
      id: 'pragmatics_observatory',
      name: 'Pronunciation & Pragmatics Realm',
      nameMl: 'ഉച്ചാരണ & ആശയവിനിമയ മണ്ഡലം',
      startDay: 81,
      endDay: 90,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFD97706),
      landmark: '🔭 The Celestial Speech Spire',
      description: 'Astral domes, glowing constellations, IPA sound chambers, and master podiums.',
      icon: '🔭',
      worldStartX: 32000.0,
      worldEndX: 36000.0,
    ),
  ];

  /// Find the region that houses [day]
  static RealmRegion getRegionForDay(int day) {
    for (final r in regions) {
      if (r.containsDay(day)) return r;
    }
    return regions.first;
  }

  /// Cached lookup table for all 180 games
  static Map<String, RealmGameSpec>? _gamesCache;

  static Map<String, RealmGameSpec> _getGamesMap() {
    if (_gamesCache != null) return _gamesCache!;
    final map = <String, RealmGameSpec>{};

    for (final g in englishRealmPhase1Games) {
      map[g.gameKey] = g;
    }
    for (final g in englishRealmPhase2Games) {
      map[g.gameKey] = g;
    }
    for (final g in englishRealmPhase3Games) {
      map[g.gameKey] = g;
    }

    _gamesCache = map;
    return map;
  }

  /// Get the 2 games assigned to [day]
  static List<RealmGameSpec> getGamesForDay(int day) {
    final map = _getGamesMap();
    final g1 = map['day_${day}_game_1'];
    final g2 = map['day_${day}_game_2'];

    final list = <RealmGameSpec>[];
    if (g1 != null) list.add(g1);
    if (g2 != null) list.add(g2);
    return list;
  }

  /// Get a specific game
  static RealmGameSpec? getGame(int day, int gameIndex) {
    return _getGamesMap()['day_${day}_game_$gameIndex'];
  }

  /// Total count of games across all 90 days
  static int get totalGamesCount => _getGamesMap().length;
}
