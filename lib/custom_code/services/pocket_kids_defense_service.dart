import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

/// 🛡️ Types of Kids House Defense Traps (100% Child-Friendly & Gamified)
enum KidDefenseTrapType {
  sentenceBuilder, // 🧩 Assemble colored word blocks in order
  wordSpelling,    // 🚂 Arrange letter train wagons to spell
  spokenEcho,      // 🗣️ Speak the defense motto aloud into mic
  balloonPhonics,  // 🎈 Pop the matching phonics sound balloon
}

/// 🛡️ Individual Kid Defense Trap Model
class KidHouseDefenseTrap {
  final int day;
  final KidDefenseTrapType type;
  final String title;
  final String prompt;
  final String targetPhrase;
  final List<String> fragments; // Scrambled words or letters for builder/speller
  final List<String> options;   // Multiple choice options for phonics
  final int correctOptionIndex;
  final String helperMascot;
  final String spokenText;

  const KidHouseDefenseTrap({
    required this.day,
    required this.type,
    required this.title,
    required this.prompt,
    required this.targetPhrase,
    this.fragments = const [],
    this.options = const [],
    this.correctOptionIndex = 0,
    required this.helperMascot,
    required this.spokenText,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'type': type.name,
        'title': title,
        'prompt': prompt,
        'targetPhrase': targetPhrase,
        'fragments': fragments,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'helperMascot': helperMascot,
        'spokenText': spokenText,
      };

  factory KidHouseDefenseTrap.fromJson(Map<String, dynamic> json) {
    return KidHouseDefenseTrap(
      day: json['day'] as int? ?? 1,
      type: KidDefenseTrapType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KidDefenseTrapType.sentenceBuilder,
      ),
      title: json['title'] as String? ?? 'Defense Shield',
      prompt: json['prompt'] as String? ?? 'Solve to breach!',
      targetPhrase: json['targetPhrase'] as String? ?? '',
      fragments: (json['fragments'] as List<dynamic>? ?? []).cast<String>(),
      options: (json['options'] as List<dynamic>? ?? []).cast<String>(),
      correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
      helperMascot: json['helperMascot'] as String? ?? '🛡️',
      spokenText: json['spokenText'] as String? ?? '',
    );
  }
}

/// 🛡️ Isolated Kids House Defense & Attacking Raid Service
/// 
/// Strict Isolation Rules (Audio Directive):
/// 1. Adults NEVER have access to Kids' houses, search, or raids.
/// 2. Kids NEVER attack Adult houses.
/// 3. House Defense Layers = Defender's Level (e.g. Level 20 Defender has 20 Defense Traps!).
/// 4. Day 1 provides the initial default defense shield with easy customization.
class PocketKidsDefenseService {
  static const String _kidDayArmedPrefix = 'pocket_kid_day_armed_trap_';

  /// 🔒 Absolute safety gate: verifies action is strictly within Kids space
  static bool get isKidsSpaceAllowed => PocketKidsService.isKidAccount;

  /// Returns the total defense capacity for a kid's house (1 Day = 1 Defense Slot)
  static int getDefenseSlotsForLevel(int dayLevel) {
    return dayLevel.clamp(1, 90);
  }

  /// Returns default planned defense trap for a specific day level
  static KidHouseDefenseTrap getDefaultDefenseForDay(int day) {
    final clamped = day.clamp(1, 90);
    final syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(clamped);
    final primaryWord = syllabus.dailyVocabulary.isNotEmpty
        ? syllabus.dailyVocabulary.first
        : 'CAT';

    // Cycle between Sentence Builder, Word Spelling, Spoken Echo, and Balloon Phonics
    final trapCycle = (clamped - 1) % 4;

    switch (trapCycle) {
      case 0: // 🧩 Sentence Builder Trap
        final sentence = clamped == 1
            ? 'I see a cat'
            : (syllabus.dialogueSentence.isNotEmpty
                ? syllabus.dialogueSentence
                : 'I love English words');
        final words = sentence.split(' ')..shuffle(math.Random(clamped));
        return KidHouseDefenseTrap(
          day: clamped,
          type: KidDefenseTrapType.sentenceBuilder,
          title: 'Sentence Puzzle Shield',
          prompt: 'Snap the colored words into a proper sentence to breach!',
          targetPhrase: sentence,
          fragments: words,
          helperMascot: syllabus.mascot,
          spokenText: 'Assemble the sentence: $sentence',
        );

      case 1: // 🚂 Word Spelling Train Trap
        final letters = primaryWord.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').split('')
          ..shuffle(math.Random(clamped + 11));
        return KidHouseDefenseTrap(
          day: clamped,
          type: KidDefenseTrapType.wordSpelling,
          title: 'Letter Train Defense',
          prompt: 'Arrange the letter wagons to spell $primaryWord!',
          targetPhrase: primaryWord.toUpperCase(),
          fragments: letters,
          helperMascot: '🚂',
          spokenText: 'Spell the word: $primaryWord',
        );

      case 2: // 🗣️ Spoken Voice Echo Trap
        final echoPhrase = clamped == 1 ? 'Hello friend!' : 'I am a brave explorer!';
        return KidHouseDefenseTrap(
          day: clamped,
          type: KidDefenseTrapType.spokenEcho,
          title: 'Magic Voice Echo Trap',
          prompt: 'Speak the defender\'s motto into the microphone to shatter the shield!',
          targetPhrase: echoPhrase,
          helperMascot: '🗣️',
          spokenText: 'Speak clearly into the microphone: $echoPhrase',
        );

      case 3: // 🎈 Balloon Phonics Trap
      default:
        final options = [
          primaryWord,
          'DOG',
          'BALL',
          'SUN',
        ];
        return KidHouseDefenseTrap(
          day: clamped,
          type: KidDefenseTrapType.balloonPhonics,
          title: 'Phonics Balloon Trap',
          prompt: 'Pop the balloon matching the /${primaryWord[0].toLowerCase()}/ sound!',
          targetPhrase: primaryWord,
          options: options,
          correctOptionIndex: 0,
          helperMascot: '🎈',
          spokenText: 'Find the balloon for $primaryWord',
        );
    }
  }

  /// Loads all defense traps for a defender at a specific level (1 to defenderLevel)
  /// If user A is Level 20, returns 20 traps representing Days 1 to 20!
  static Future<List<KidHouseDefenseTrap>> getDefenderTrapsForDay(int dayLevel, {String? defenderId}) async {
    final prefs = await SharedPreferences.getInstance();
    final totalTraps = dayLevel.clamp(1, 90);
    final list = <KidHouseDefenseTrap>[];

    for (int day = 1; day <= totalTraps; day++) {
      final key = '$_kidDayArmedPrefix${defenderId ?? "me"}_$day';
      final savedJson = prefs.getString(key);
      if (savedJson != null && savedJson.isNotEmpty) {
        try {
          final map = jsonDecode(savedJson) as Map<String, dynamic>;
          list.add(KidHouseDefenseTrap.fromJson(map));
          continue;
        } catch (_) {}
      }
      // Fallback to rich systematically generated default defense for that day
      list.add(getDefaultDefenseForDay(day));
    }

    return list;
  }

  /// Arms or updates the defense trap for a specific day slot on the child's house
  static Future<void> armDayDefenseTrap(int day, KidHouseDefenseTrap trap, {String? kidId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kidDayArmedPrefix${kidId ?? "me"}_$day';
    await prefs.setString(key, jsonEncode(trap.toJson()));
  }

  /// Automatically arms Day 1 defense if not yet configured
  static Future<void> ensureDay1DefenseArmed({String? kidId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kidDayArmedPrefix${kidId ?? "me"}_1';
    if (!prefs.containsKey(key)) {
      final def = getDefaultDefenseForDay(1);
      await prefs.setString(key, jsonEncode(def.toJson()));
    }
  }
}
