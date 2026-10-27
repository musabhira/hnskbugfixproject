import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/letters_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/diaries_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/profiles_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/notices_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/emails_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/spellings_90.dart';

/// 📜 90-Day Progressive Curriculum Models for Student Writing Activities
/// Strictly zero duplicates across all 90 days.
/// Difficulty smoothly scales from simple 2-line beginners (Day 1) to advanced mastery (Day 90).

class DayLetterData {
  final int day;
  final String title;
  final String recipient;
  final List<String> line1Words;
  final List<String> line2Words;
  final List<String> distractors;
  final String hint;

  const DayLetterData({
    required this.day,
    required this.title,
    required this.recipient,
    required this.line1Words,
    required this.line2Words,
    required this.distractors,
    required this.hint,
  });

  List<String> get allTargetWords => [...line1Words, ...line2Words];
}

class DayDiaryData {
  final int day;
  final String dateStr;
  final String mood;
  final List<String> sentence1Words;
  final List<String> sentence2Words;
  final List<String> distractors;
  final String prompt;

  const DayDiaryData({
    required this.day,
    required this.dateStr,
    required this.mood,
    required this.sentence1Words,
    required this.sentence2Words,
    required this.distractors,
    required this.prompt,
  });

  List<String> get allWords => [...sentence1Words, ...sentence2Words];
}

class DayProfileData {
  final int day;
  final String heroName;
  final String heroEmoji;
  final Map<String, String> examClues;
  final List<List<String>> sentences;
  final List<String> distractors;

  const DayProfileData({
    required this.day,
    required this.heroName,
    required this.heroEmoji,
    required this.examClues,
    required this.sentences,
    required this.distractors,
  });

  List<String> get allSentenceWords => [for (final s in sentences) ...s];
}

class DayNoticeData {
  final int day;
  final String title;
  final String category;
  final List<String> targetParts;
  final List<String> partLabels;
  final List<String> distractors;

  const DayNoticeData({
    required this.day,
    required this.title,
    required this.category,
    required this.targetParts,
    required this.partLabels,
    required this.distractors,
  });
}

class DayEmailData {
  final int day;
  final String recipient;
  final String subjectCorrect;
  final List<String> subjectOptions;
  final String greetingCorrect;
  final List<String> greetingOptions;
  final String bodyCorrect;
  final List<String> bodyOptions;

  const DayEmailData({
    required this.day,
    required this.recipient,
    required this.subjectCorrect,
    required this.subjectOptions,
    required this.greetingCorrect,
    required this.greetingOptions,
    required this.bodyCorrect,
    required this.bodyOptions,
  });
}

class DaySpellingData {
  final int day;
  final String wrongWord;
  final String correctWord;
  final String clue;
  final List<String> distractors;

  const DaySpellingData({
    required this.day,
    required this.wrongWord,
    required this.correctWord,
    required this.clue,
    required this.distractors,
  });

  List<String> get correctLetters => correctWord.toUpperCase().split('');
  List<String> get wrongLetters => wrongWord.toUpperCase().split('');
}

/// 🏛️ Central 90-Day Curriculum Repository for Student Writing Steps
class StudentCreativeWriting90DayCurriculum {
  // ──────────────────────── 1. LETTER WRITING (90 Days) ────────────────────────
  static DayLetterData getLetterData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueLetters[d - 1];
    return DayLetterData(
      day: d,
      title: 'Day $d: ${item['title']}',
      recipient: item['recipient'] as String,
      line1Words: (item['line1'] as List).cast<String>(),
      line2Words: (item['line2'] as List).cast<String>(),
      distractors: (item['distractors'] as List).cast<String>(),
      hint: item['hint'] as String,
    );
  }

  // ──────────────────────── 2. DIARY ENTRY (90 Days) ────────────────────────
  static DayDiaryData getDiaryData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueDiaries[d - 1];
    return DayDiaryData(
      day: d,
      dateStr: 'Day $d Journal',
      mood: item['mood'] as String,
      sentence1Words: (item['sentence1'] as List).cast<String>(),
      sentence2Words: (item['sentence2'] as List).cast<String>(),
      distractors: (item['distractors'] as List).cast<String>(),
      prompt: item['prompt'] as String,
    );
  }

  // ──────────────────────── 3. EXAM PROFILE WRITING (90 Days) ────────────────────────
  static DayProfileData getProfileData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueProfiles[d - 1];
    return DayProfileData(
      day: d,
      heroName: item['name'] as String,
      heroEmoji: item['emoji'] as String,
      examClues: Map<String, String>.from(item['clues'] as Map),
      sentences: (item['sentences'] as List)
          .map((s) => (s as List).cast<String>())
          .toList(),
      distractors: (item['distractors'] as List).cast<String>(),
    );
  }

  // ──────────────────────── 4. NOTICE MASTERCLASS (90 Days) ────────────────────────
  static DayNoticeData getNoticeData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueNotices[d - 1];
    return DayNoticeData(
      day: d,
      title: item['title'] as String,
      category: item['category'] as String,
      partLabels: const ['1. Institution', '2. Header', '3. Headline', '4. Date & Details'],
      targetParts: (item['parts'] as List).cast<String>(),
      distractors: (item['distractors'] as List).cast<String>(),
    );
  }

  // ──────────────────────── 5. EMAIL ETIQUETTE (90 Days) ────────────────────────
  static DayEmailData getEmailData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueEmails[d - 1];
    return DayEmailData(
      day: d,
      recipient: item['recipient'] as String,
      subjectCorrect: item['subjectCorrect'] as String,
      subjectOptions: (item['subjectOptions'] as List).cast<String>(),
      greetingCorrect: item['greetingCorrect'] as String,
      greetingOptions: (item['greetingOptions'] as List).cast<String>(),
      bodyCorrect: item['bodyCorrect'] as String,
      bodyOptions: (item['bodyOptions'] as List).cast<String>(),
    );
  }

  // ──────────────────────── 6. SPELLING DETECTIVE (90 Days) ────────────────────────
  static DaySpellingData getSpellingData(int day) {
    final d = day.clamp(1, 90);
    final item = k90UniqueSpellings[d - 1];
    return DaySpellingData(
      day: d,
      wrongWord: item['wrong'] as String,
      correctWord: item['correct'] as String,
      clue: item['clue'] as String,
      distractors: (item['distractors'] as List).cast<String>(),
    );
  }
}
