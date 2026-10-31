import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

/// 🛡️ PocketLanguageGuardService
/// Enforces English-only conversations in Pocket Talk, Group Chats, and direct chats.
/// Detects non-Latin scripts (Malayalam, Tamil, Telugu, Kannada, Hindi, Arabic, etc.)
/// and common Manglish / Hinglish / Romanized regional words without costly AI calls.
/// Dispatches async Presidential Notifications so chat is smooth without abrupt blocking.
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

  /// Result of language inspection with specific script/dialect identification
  static LanguageCheckResult checkMessage(String text) {
    if (text.trim().isEmpty) {
      return const LanguageCheckResult(isValid: true);
    }

    final trimmed = text.trim();

    // 1. Script Check: Distinguish Malayalam, Tamil, Telugu, Kannada, Hindi, Arabic, etc.
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'മലയാളം (Malayalam)',
      );
    }
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'தமிழ் (Tamil)',
      );
    }
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'తెలుగు (Telugu)',
      );
    }
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'ಕನ್ನಡ (Kannada)',
      );
    }
    if (RegExp(r'[\u0900-\u097F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'हिन्दी (Hindi)',
      );
    }
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Arabic / Urdu',
      );
    }
    if (RegExp(r'[\u0980-\u09FF\u0A80-\u0AFF\u4E00-\u9FFF]').hasMatch(trimmed)) {
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

  /// 🏛️ Asynchronously dispatch a Presidential Warning when a non-English message is sent in chat.
  /// (User Audio Directive: "മെല്ലെ സമാധാനത്തിൽ കണ്ടുപിടിച്ചാൽ മതി. കണ്ടുപിടിച്ചിട്ട് തന്നെ പറയും നിങ്ങൾ സംസാരിച്ചു,
  /// നോട്ടിഫിക്കേഷൻ പോകും. പ്രസിഡൻഷ്യൽ നോട്ടിഫിക്കേഷൻ പോകാം. പ്രസിഡന്റ് നോട്ടിഫിക്കേഷൻ അയക്കും.")
  static Future<bool> dispatchPresidentialWarning({
    required String userId,
    required String detectedLanguage,
    required String messageSnippet,
    String? contextId,
  }) async {
    if (userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final throttleKey = 'pres_lang_warn_ts_${userId}_${contextId ?? "global"}';
      final lastSent = prefs.getInt(throttleKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Throttle warning to at most once every 5 minutes per user per conversation to avoid spamming
      if (now - lastSent < 5 * 60 * 1000) {
        return false;
      }
      await prefs.setInt(throttleKey, now);

      final snippetClean = messageSnippet.length > 35
          ? '${messageSnippet.substring(0, 35)}...'
          : messageSnippet;

      final warningText = '🏛️ Presidential English Notice:\n'
          'Non-English communication detected ($detectedLanguage): "$snippetClean".\n\n'
          'Pocket Mates is designed to build English fluency! Converse in English to maintain your streak and earn Gold Trophies 🏆';

      // 1. Post to user's chat with The President
      try {
        await PocketPresidentService.sendPresidentReplyToUser(
          targetUserId: userId,
          replyText: warningText,
        );
      } catch (_) {}

      // 2. Insert into Supabase notifications table for instant sync with Notifications Page
      try {
        await SupaFlow.client.from('notifications').insert({
          'user_id': userId,
          'source_id': userId,
          'sender_id': null,
          'type': 'language_warning',
          'message': warningText,
          'status': 'unread',
        });
      } catch (_) {}

      // 3. Asynchronously trigger Jevv AI background score deduction (Adult Pocket Score / Student Score / Kids Score)
      applyNonEnglishScorePenalty(
        userId: userId,
        detectedLanguage: detectedLanguage,
        messageSnippet: messageSnippet,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  /// 🤖 Jevv AI Asynchronous Background Moderator:
  /// Periodically checks messages (every 10-15 mins throttle) and applies score deduction
  /// to enforce English-only conversations without impeding realtime chat responsiveness.
  static Future<void> applyNonEnglishScorePenalty({
    required String userId,
    required String detectedLanguage,
    required String messageSnippet,
  }) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final penaltyThrottleKey = 'jevv_ai_penalty_ts_$userId';
      final lastPenalty = prefs.getInt(penaltyThrottleKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Background penalty applies at most once every 10-15 minutes
      if (now - lastPenalty < 10 * 60 * 1000) {
        return;
      }
      await prefs.setInt(penaltyThrottleKey, now);

      final accountType = prefs.getString('pm_app_world_mode') ?? 'adult';
      const penalty = 15;

      // Deduct score based on account type
      if (accountType == 'kids') {
        final currentStars = prefs.getInt('pm_kid_stars') ?? 0;
        final newStars = math.max(0, currentStars - 5);
        await prefs.setInt('pm_kid_stars', newStars);
      } else if (accountType == 'student') {
        final currentScore = prefs.getInt('pm_kid_student_score') ?? 100;
        final newScore = math.max(0, currentScore - penalty);
        await prefs.setInt('pm_kid_student_score', newScore);
      } else {
        final currentScore = prefs.getInt('user_pocket_score') ?? 150;
        final newScore = math.max(0, currentScore - penalty);
        await prefs.setInt('user_pocket_score', newScore);
      }

      // Supabase database deduction
      try {
        final profRes = await SupaFlow.client
            .from('profile')
            .select('pocket_score')
            .eq('user_id', userId)
            .maybeSingle();
        final currentScore = (profRes?['pocket_score'] as num?)?.toInt() ?? 100;
        final updatedScore = math.max(0, currentScore - penalty);
        await SupaFlow.client
            .from('profile')
            .update({'pocket_score': updatedScore})
            .eq('user_id', userId);

        try {
          await SupaFlow.client
              .from('users')
              .update({'pocket_score': updatedScore})
              .eq('id', userId);
        } catch (_) {}

        await SupaFlow.client.rpc('deduct_pocket_score_penalty', params: {
          'user_id': userId,
          'penalty_amount': penalty,
          'reason': 'Jevv AI: Non-English language detected ($detectedLanguage)',
        }).catchError((_) {});
      } catch (_) {}

      // Friendly Jevv AI In-App notification
      final sample = messageSnippet.length > 25
          ? '${messageSnippet.substring(0, 25)}...'
          : messageSnippet;
      final penaltyNotice = '🤖 Jevv AI Language Moderator:\n'
          'Non-English detected ($detectedLanguage): "$sample".\n'
          '⚠️ Pocket Score -$penalty. Pocket Mates is an English-Only community! Please chat in English to restore your score. 🌟';

      try {
        await SupaFlow.client.from('notifications').insert({
          'user_id': userId,
          'source_id': userId,
          'type': 'jevv_language_penalty',
          'message': penaltyNotice,
          'status': 'unread',
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Jevv AI score penalty error: $e');
    }
  }

  /// 🌐 Background Language Guard Evaluation (User Audio Directive)
  /// Non-blocking: runs asynchronously after message is sent.
  /// If non-English / Malayalam is detected, deducts Pocket Score and dispatches warning notice.
  static void evaluateOutgoingMessageInBackground({
    required String userId,
    required String messageText,
    String? contextId,
  }) {
    if (userId.isEmpty || messageText.trim().isEmpty) return;
    Future.microtask(() async {
      try {
        final result = checkMessage(messageText);
        if (!result.isValid) {
          final lang = result.detectedWord ?? 'Regional Language';
          await dispatchPresidentialWarning(
            userId: userId,
            detectedLanguage: lang,
            messageSnippet: messageText,
            contextId: contextId,
          );
        }
      } catch (e) {
        debugPrint('Language guard background eval error: $e');
      }
    });
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
