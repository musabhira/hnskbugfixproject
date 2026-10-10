import 'package:flutter/material.dart';
import 'english_realm_localization_service.dart';

/// 🎮 Archetype defining the gameplay mechanics of a challenge
enum GameArchetype {
  sortingFactory,       // Word classification into bins / conveyor sorting
  arenaBattle,          // Grammar duel against opponent / boss with health bars
  runnerCollector,      // Collect correct items while avoiding obstacles
  sentenceBuilder,      // Tap/drag word blocks into correct grammatical sequence
  detectiveInvestigation, // Clue analysis, spotting grammar bugs & errors
  gatekeeperDungeon,    // Key & lock puzzles to open doors / portals
  timelineSequencer,    // Chronological / duration ordering on a time axis
  dialogueRpg,          // Conversational situational roleplay with NPC
}

/// 🌟 A single challenge round inside a game session
class RealmChallengeRound {
  final int id;
  final String promptEn;
  final String promptMl;
  final String? contextSnippet;
  final List<String> options;
  final dynamic solution; // int (index) or List<String> (sequence) or Map<String, String> (sorting)
  final String explanationEn;
  final String explanationMl;
  final String? audioVoiceText;
  final List<String>? tags;

  const RealmChallengeRound({
    required this.id,
    required this.promptEn,
    required this.promptMl,
    this.contextSnippet,
    required this.options,
    required this.solution,
    required this.explanationEn,
    required this.explanationMl,
    this.audioVoiceText,
    this.tags,
  });

  /// Dynamically resolves the prompt according to the selected native language
  /// Supports Tamil ('ta'), Hindi ('hi'), Telugu ('te'), Kannada ('kn'), Malayalam ('ml'), and English ('en')
  String getLocalizedPrompt([String? lang]) {
    return EnglishRealmLocalizationService.translatePrompt(promptEn, promptMl, lang);
  }

  /// Dynamically resolves the linguistic explanation according to the selected native language
  String getLocalizedExplanation([String? lang]) {
    return EnglishRealmLocalizationService.translateExplanation(explanationEn, explanationMl, lang);
  }

  bool isCorrectAnswer(dynamic answer) {
    if (solution is int && answer is int) {
      return solution == answer;
    }
    if (solution is String && answer is String) {
      return (solution as String).trim().toLowerCase() == answer.trim().toLowerCase();
    }
    if (solution is List && answer is List) {
      if (solution.length != answer.length) return false;
      for (int i = 0; i < solution.length; i++) {
        if (solution[i].toString().trim().toLowerCase() != answer[i].toString().trim().toLowerCase()) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}

/// 📘 Specification for one of the 180 games in English Realm
class RealmGameSpec {
  final int day;
  final int gameIndex; // 1 or 2
  final String title;
  final String subtitle;
  final GameArchetype archetype;
  final String regionId;
  final String regionName;
  final String englishTopic;
  final String descriptionEn;
  final String descriptionMl;
  final String icon;
  final Color accentColor;
  final List<RealmChallengeRound> rounds;
  final int xpReward;
  final int coinReward;

  const RealmGameSpec({
    required this.day,
    required this.gameIndex,
    required this.title,
    required this.subtitle,
    required this.archetype,
    required this.regionId,
    required this.regionName,
    required this.englishTopic,
    required this.descriptionEn,
    required this.descriptionMl,
    required this.icon,
    required this.accentColor,
    required this.rounds,
    this.xpReward = 40,
    this.coinReward = 15,
  });

  String get gameKey => 'day_${day}_game_$gameIndex';

  /// Dynamically resolves game description for the active native language
  String getLocalizedDescription([String? lang]) {
    return EnglishRealmLocalizationService.translateGameDescription(descriptionEn, descriptionMl, lang);
  }
}

/// 🗺️ Explorable thematic region in the English Realm
class RealmRegion {
  final String id;
  final String name;
  final String nameMl;
  final int startDay;
  final int endDay;
  final Color primaryColor;
  final Color secondaryColor;
  final String landmark;
  final String description;
  final String icon;
  final double worldStartX;
  final double worldEndX;

  const RealmRegion({
    required this.id,
    required this.name,
    required this.nameMl,
    required this.startDay,
    required this.endDay,
    required this.primaryColor,
    required this.secondaryColor,
    required this.landmark,
    required this.description,
    required this.icon,
    required this.worldStartX,
    required this.worldEndX,
  });

  bool containsDay(int day) => day >= startDay && day <= endDay;

  /// Dynamically resolves region title for the active native language
  String getLocalizedName([String? lang]) {
    return EnglishRealmLocalizationService.getRegionName(id, lang);
  }
}
