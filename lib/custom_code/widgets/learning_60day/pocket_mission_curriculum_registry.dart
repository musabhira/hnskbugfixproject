import 'daily_vocab_item.dart';
import 'pocket_mission_curriculum_19_28.dart';
import 'pocket_mission_curriculum_29_38.dart';
import 'pocket_mission_curriculum_39_50.dart';

/// 🏛️ Master Registry for Pocket World Daily Mission Curricula (Days 19–50 and beyond)
class PocketMissionCurriculumRegistry {
  /// Checks whether this registry contains rich curriculum data for the specified day
  static bool hasDay(int day) {
    return PocketCurriculum19To28.handles(day) ||
        PocketCurriculum29To38.handles(day) ||
        PocketCurriculum39To50.handles(day);
  }

  /// Full story narrative text
  static String getStoryText(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryText(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryText(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryText(day);
    }
    return '';
  }

  /// 4-Part formatted story narrative
  static String getStoryFormatted(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryFormatted(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryFormatted(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryFormatted(day);
    }
    return '';
  }

  /// Story headline title
  static String getStoryTitle(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryTitle(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryTitle(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryTitle(day);
    }
    return '';
  }

  /// Story subtitle describing skills
  static String getStorySubtitle(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStorySubtitle(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStorySubtitle(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStorySubtitle(day);
    }
    return '';
  }

  /// Story emoji icon
  static String getStoryIcon(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryIcon(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryIcon(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryIcon(day);
    }
    return '🏛️';
  }

  /// Opening quotation preview
  static String getStoryQuotePreview(int day) {
    if (PocketCurriculum19To28.handles(day)) {
      return PocketCurriculum19To28.getStoryQuotePreview(day);
    }
    if (PocketCurriculum29To38.handles(day)) {
      return PocketCurriculum29To38.getStoryQuotePreview(day);
    }
    if (PocketCurriculum39To50.handles(day)) {
      return PocketCurriculum39To50.getStoryQuotePreview(day);
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
    return const [];
  }
}
