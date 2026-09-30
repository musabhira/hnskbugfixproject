import 'package:shared_preferences/shared_preferences.dart';

/// 🛡️ PocketLanguageGuardService
/// Enforces English-only conversations in Pocket Talk (and 4-Day Spoken Pacts).
/// Detects non-Latin scripts (Malayalam, Hindi, Arabic, Tamil, etc.)
/// and common Manglish / Hinglish / Romanized regional words without costly AI calls,
/// with progressive friendly warnings (Warning 1, 2, 3+).
class PocketLanguageGuardService {
  static const String _kWarningPrefix = 'pocket_talk_lang_warning_';

  // 1. High-frequency Manglish (Malayalam written in English alphabet) indicator tokens
  static final Set<String> _manglishWords = {
    // Pronouns & Question words
    'njan', 'njn', 'njangal', 'njankal', 'ningal', 'ningalkk', 'avan', 'aval', 'avar',
    'ithu', 'athu', 'enth', 'entha', 'entharu', 'enthina', 'enthinanu', 'evide', 'evideya',
    'eppol', 'engane', 'enganeya', 'aaranu', 'aara', 'aaroke',
    // Common conversational verbs & expressions
    'sukhamano', 'sukham', 'sukhamane', 'onnumilla', 'onnum', 'illa', 'illada', 'illadi',
    'alla', 'allada', 'alladi', 'aano', 'aanu', 'undu', 'undo', 'undallo',
    'poda', 'podi', 'mone', 'chetta', 'chechi', 'aliya', 'machane', 'macha', 'bhavi',
    'sheriyanu', 'sheri', 'sherida', 'parayoo', 'parayu', 'paranjath', 'paranja',
    'cheyyo', 'cheyyanam', 'cheyyunnu', 'cheyyalle', 'cheythe', 'vannu', 'poyi',
    'varum', 'pokum', 'nokku', 'nokki', 'kando', 'kandittilla', 'ariyilla', 'ariyumo',
    'pinne', 'athre', 'alle', 'ithoke', 'athoke', 'kure', 'kurachu', 'ippol', 'appol',
    'pettannu', 'mathi', 'venda', 'tharam', 'tharaam', 'vaada', 'vaadi', 'poyekku',
    'theerkkam', 'marannu', 'kazhinju', 'kazhinjo', 'oomb', 'thetta', 'nannayi',
    'oru', 'pakshe', 'athukondu', 'ennittu', 'enna', 'enthelum', 'athinte', 'ithinte',
    'namukku', 'enikku', 'ninakku', 'avanu', 'avalkku', 'avarkku',
  };

  // 2. High-frequency Hinglish (Hindi written in English alphabet) indicator tokens
  static final Set<String> _hinglishWords = {
    'kya', 'kyun', 'kaise', 'kahan', 'kab', 'kaun', 'mera', 'meri', 'mere',
    'tera', 'teri', 'tere', 'hum', 'tum', 'aap', 'unka', 'inka',
    'nahi', 'nhi', 'haan', 'theek', 'acha', 'achha', 'bhai', 'yaar', 'bhaiya',
    'karo', 'karna', 'karoonga', 'karoge', 'karungi', 'hoga', 'hogi', 'hogaa',
    'bolo', 'batao', 'samajh', 'samjha', 'kuch', 'kuchh', 'bahut', 'bohot',
    'thoda', 'sab', 'kripya', 'shukriya', 'alvida', 'milte', 'namaste',
  };

  /// Result of language inspection
  static LanguageCheckResult checkMessage(String text) {
    if (text.trim().isEmpty) {
      return const LanguageCheckResult(isValid: true);
    }

    final trimmed = text.trim();

    // 1. Script Check: Look for non-Latin script characters (Malayalam: \u0D00-\u0D7F, Devanagari: \u0900-\u097F, etc.)
    final nonLatinRegex = RegExp(r'[\u0D00-\u0D7F\u0900-\u097F\u0B80-\u0BFF\u0C00-\u0C7F\u0600-\u06FF\u4E00-\u9FFF]');
    if (nonLatinRegex.hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Regional Script',
      );
    }

    // 2. Tokenize into normalized words (strip punctuation, lower-case)
    final words = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .toList();

    if (words.isEmpty) {
      return const LanguageCheckResult(isValid: true);
    }

    int manglishMatches = 0;
    int hinglishMatches = 0;
    String? matchedWord;

    for (final word in words) {
      if (_manglishWords.contains(word)) {
        manglishMatches++;
        matchedWord ??= word;
      } else if (_hinglishWords.contains(word)) {
        hinglishMatches++;
        matchedWord ??= word;
      }
    }

    final totalMatches = manglishMatches + hinglishMatches;

    // If total words is small (1 to 3 words) and has at least 1 match, flag!
    if (words.length <= 3 && totalMatches >= 1) {
      return LanguageCheckResult(
        isValid: false,
        reason: manglishMatches > 0 ? LanguageViolationType.manglish : LanguageViolationType.hinglish,
        detectedWord: matchedWord,
      );
    }

    // If longer sentence, flag if 2+ indicator words or > 20% of words are indicator tokens
    if (totalMatches >= 2 || (words.isNotEmpty && (totalMatches / words.length) >= 0.20)) {
      return LanguageCheckResult(
        isValid: false,
        reason: manglishMatches >= hinglishMatches ? LanguageViolationType.manglish : LanguageViolationType.hinglish,
        detectedWord: matchedWord,
      );
    }

    return const LanguageCheckResult(isValid: true);
  }

  /// Get total warnings accumulated by user for a given context / pact
  static Future<int> getWarningCount(String userId, String contextId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$_kWarningPrefix${userId}_$contextId') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Record violation, increment warning count, and return user warning message
  static Future<({int count, String message, String title})> recordWarning({
    required String userId,
    required String contextId,
    required LanguageViolationType violationType,
    String? sampleWord,
  }) async {
    final current = await getWarningCount(userId, contextId);
    final newCount = current + 1;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_kWarningPrefix${userId}_$contextId', newCount);
    } catch (_) {}

    String detectedName = 'Manglish/Regional words';
    if (violationType == LanguageViolationType.nonLatinScript) {
      detectedName = 'Regional script (Malayalam/Hindi)';
    } else if (violationType == LanguageViolationType.hinglish) {
      detectedName = 'Hinglish phrases';
    }

    final hintWord = sampleWord != null ? ' ("$sampleWord")' : '';

    if (newCount == 1) {
      return (
        count: 1,
        title: '⚠️ Practice in English Only (Notice 1/3)',
        message: 'In Pocket Talk, every conversation is an English fluency pact! We detected $detectedName$hintWord. Please try expressing that in English 🌟',
      );
    } else if (newCount == 2) {
      return (
        count: 2,
        title: '⚠️ 2nd Warning: Spoken Pact in Jeopardy',
        message: 'Non-English message detected$hintWord. To earn your 🏆 Spoken Trophy, 4-Day Pacts require communicating exclusively in English. Let’s switch to English now!',
      );
    } else {
      return (
        count: newCount,
        title: '🚨 Warning #$newCount: English Only Required',
        message: 'Continuous use of non-English will pause your 4-Day Spoken Pact progress. Please translate your thought into English to keep your streak alive!',
      );
    }
  }
}

enum LanguageViolationType {
  none,
  nonLatinScript,
  manglish,
  hinglish,
}

class LanguageCheckResult {
  final bool isValid;
  final LanguageViolationType reason;
  final String? detectedWord;

  const LanguageCheckResult({
    required this.isValid,
    this.reason = LanguageViolationType.none,
    this.detectedWord,
  });
}
