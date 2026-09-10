import 'daily_vocab_item.dart';
import 'pocket_mission_curriculum_1_18.dart';
import 'pocket_mission_curriculum_19_28.dart';
import 'pocket_mission_curriculum_29_38.dart';
import 'pocket_mission_curriculum_39_50.dart';
import 'pocket_mission_curriculum_51_60.dart';
import 'pocket_mission_curriculum_56_62.dart';
import 'pocket_mission_curriculum_63_70.dart';
import 'pocket_mission_curriculum_69_75.dart';
import 'pocket_mission_curriculum_76_82.dart';
import 'pocket_mission_curriculum_83_90.dart';

export 'pocket_mission_curriculum_1_18.dart';

/// 🏛️ Master Registry for Pocket World Daily Mission Curricula (Days 1–90)
class PocketMissionCurriculumRegistry {
  /// Checks whether this registry contains rich curriculum data for the specified day
  static bool hasDay(int day) {
    return PocketCurriculum1To18.handles(day) ||
        PocketCurriculum19To28.handles(day) ||
        PocketCurriculum29To38.handles(day) ||
        PocketCurriculum39To50.handles(day) ||
        PocketCurriculum51To60.handles(day) ||
        PocketCurriculum56To62.handles(day) ||
        PocketCurriculum63To70.handles(day) ||
        PocketCurriculum69To75.handles(day) ||
        PocketCurriculum76To82.handles(day) ||
        PocketCurriculum83To90.handles(day);
  }

  /// Get 3-page deep story split for multi-page reading & listening
  static List<String> getStoryPages(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryPages(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryPages(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryPages(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryPages(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryPages(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryPages(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryPages(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryPages(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryPages(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryPages(day);
    }
    final text = getStoryText(day);
    return text.isNotEmpty ? [text] : const [];
  }

  /// Full story narrative text
  static String getStoryText(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryText(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryText(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryText(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryText(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryText(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryText(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryText(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryText(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryText(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryText(day);
    }
    return '';
  }

  /// 4-Part formatted story narrative
  static String getStoryFormatted(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryFormatted(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryFormatted(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryFormatted(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryFormatted(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryFormatted(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryFormatted(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryFormatted(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryFormatted(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryFormatted(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryFormatted(day);
    }
    return '';
  }

  /// Story headline title
  static String getStoryTitle(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryTitle(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryTitle(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryTitle(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryTitle(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryTitle(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryTitle(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryTitle(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryTitle(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryTitle(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryTitle(day);
    }
    return '';
  }

  /// Story subtitle describing skills
  static String getStorySubtitle(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStorySubtitle(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStorySubtitle(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStorySubtitle(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStorySubtitle(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStorySubtitle(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStorySubtitle(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStorySubtitle(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStorySubtitle(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStorySubtitle(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStorySubtitle(day);
    }
    return '';
  }

  /// Story emoji icon
  static String getStoryIcon(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryIcon(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryIcon(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryIcon(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryIcon(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryIcon(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryIcon(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryIcon(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryIcon(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryIcon(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryIcon(day);
    }
    return '🏛️';
  }

  /// Opening quotation preview
  static String getStoryQuotePreview(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getStoryQuotePreview(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryQuotePreview(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryQuotePreview(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryQuotePreview(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStoryQuotePreview(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStoryQuotePreview(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStoryQuotePreview(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStoryQuotePreview(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStoryQuotePreview(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStoryQuotePreview(day);
    }
    return '';
  }

  /// Grammar rule headline title
  static String getGrammarRuleTitle(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getGrammarRuleTitle(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getGrammarRuleTitle(day);
    }
    return '';
  }

  /// Practical quiz question
  static String getQuizQuestion(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getQuizQuestion(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getQuizQuestion(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getQuizQuestion(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getQuizQuestion(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getQuizQuestion(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getQuizQuestion(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getQuizQuestion(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getQuizQuestion(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getQuizQuestion(day);
    }
    return '';
  }

  /// Quiz options (3 options, first is correct)
  static List<String> getQuizOptions(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getQuizOptions(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getQuizOptions(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getQuizOptions(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getQuizOptions(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getQuizOptions(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getQuizOptions(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getQuizOptions(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getQuizOptions(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getQuizOptions(day);
    }
    return const [];
  }

  /// Multilingual grammar explanation (Malayalam, Tamil, Hindi, Telugu, Kannada)
  static String getGrammarRuleExplanation(int day, String lang) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getGrammarRuleExplanation(day, lang);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getGrammarRuleExplanation(day, lang);
    }
    return '';
  }

  /// Multilingual story moral summary
  static String getStorySummary(int day, String lang) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStorySummary(day, lang);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStorySummary(day, lang);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStorySummary(day, lang);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getStorySummary(day, lang);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getStorySummary(day, lang);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getStorySummary(day, lang);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getStorySummary(day, lang);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getStorySummary(day, lang);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getStorySummary(day, lang);
    }
    return '';
  }

  /// 10 High-impact vocabulary items for the day
  static List<DailyVocabItem> getVocabItems(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getVocabItems(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getVocabItems(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getVocabItems(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getVocabItems(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getVocabItems(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getVocabItems(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getVocabItems(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getVocabItems(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getVocabItems(day);
    }
    return const [];
  }

  // --- 🔤 NEW PEDAGOGICAL GETTERS (User Voice Directives) ---

  /// Get Alphabet & Phonics list for beginners
  static List<AlphabetPhonicItem> getAlphabetPhonics(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getAlphabetPhonics(day);
    }
    return const [];
  }

  /// Get Sentence Pattern drills
  static List<SentencePatternItem> getSentencePatterns(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getSentencePatterns(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getSentencePatterns(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getSentencePatterns(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getSentencePatterns(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getSentencePatterns(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getSentencePatterns(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getSentencePatterns(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getSentencePatterns(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getSentencePatterns(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getSentencePatterns(day);
    }
    return const [];
  }

  /// Get Pronunciation & Phonetics clinic
  static PronunciationClinicItem getPronunciationClinic(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getPronunciationClinic(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getPronunciationClinic(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getPronunciationClinic(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getPronunciationClinic(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getPronunciationClinic(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getPronunciationClinic(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getPronunciationClinic(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getPronunciationClinic(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getPronunciationClinic(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getPronunciationClinic(day);
    }
    return const PronunciationClinicItem(
      focusSound: 'Standard Fluency Clarity',
      mouthPositionTip: 'Pronounce each word with active breath.',
      minimalPairs: [],
      practicePhrases: ['Fluency is built through daily practice.'],
    );
  }

  /// Get English Thinking workout
  static EnglishThinkingItem getEnglishThinkingWorkout(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getEnglishThinkingWorkout(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getEnglishThinkingWorkout(day);
    }
    return const EnglishThinkingItem(
      situation: 'Daily Routine Question',
      mentalTrapMalayalam: 'Do not translate in native language.',
      directEnglishThought: 'Think the concept directly in English.',
      instantResponses: ['"I am ready to speak."'],
    );
  }

  /// Get In-Lesson Speaking Challenge
  static SpeakingChallengeItem getSpeakingChallenge(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getSpeakingChallenge(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getSpeakingChallenge(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getSpeakingChallenge(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getSpeakingChallenge(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getSpeakingChallenge(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getSpeakingChallenge(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getSpeakingChallenge(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getSpeakingChallenge(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getSpeakingChallenge(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getSpeakingChallenge(day);
    }
    return const SpeakingChallengeItem(
      title: 'Daily Speaking Milestone',
      contextScenario: 'Speak for 30 seconds describing today\'s main achievement.',
      targetSeconds: 30,
      guidingPoints: ['Speak clearly', 'Breathe naturally'],
      sampleNativeAudioScript: 'Today I practiced my English diligently.',
    );
  }

  /// Get Sovereign Fluency Shortcut / Kurukkuvazhi
  static FluencyShortcutItem getFluencyShortcut(int day) {
    if (PocketCurriculum1To18.handles(day)) {
      return PocketCurriculum1To18.getFluencyShortcut(day);
    }
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getFluencyShortcut(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getFluencyShortcut(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getFluencyShortcut(day);
    }
    if (PocketCurriculum51To60.handles(day)) {
      return PocketCurriculum51To60.getFluencyShortcut(day);
    }
    if (PocketCurriculum56To62.handles(day)) {
      return PocketCurriculum56To62.getFluencyShortcut(day);
    }
    if (PocketCurriculum63To70.handles(day)) {
      return PocketCurriculum63To70.getFluencyShortcut(day);
    }
    if (PocketCurriculum69To75.handles(day)) {
      return PocketCurriculum69To75.getFluencyShortcut(day);
    }
    if (PocketCurriculum76To82.handles(day)) {
      return PocketCurriculum76To82.getFluencyShortcut(day);
    }
    if (PocketCurriculum83To90.handles(day)) {
      return PocketCurriculum83To90.getFluencyShortcut(day);
    }
    return const FluencyShortcutItem(
      title: 'Consistency Rule',
      malyalamHeading: '⚡ കുറുക്കുവഴി: തുടർച്ചയായ പ്രാക്ടീസ്',
      ruleSummary: '60 minutes daily beats 7 hours on Sunday.',
      quickHack: 'Practice speaking aloud in the morning.',
      examples: ['Consistency builds unstoppable fluency.'],
    );
  }
}
