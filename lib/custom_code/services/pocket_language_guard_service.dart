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

      // 3. Score deduction removed per directive: No penalties, disciplinary warnings, or score reductions!
      // The system only provides gentle inline warnings below the message bubble.

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

  // -------------------------------------------------------------
  // 🎯 HIGH-ACCURACY PERSONAL CHAT LANGUAGE DETECTOR (NO AI TOKENS)
  // -------------------------------------------------------------

  /// Safe common greetings and conversational short terms exempt from warnings
  static final Set<String> _exemptTerms = {
    'hi', 'hello', 'hey', 'ok', 'okay', 'yes', 'no', 'yeah', 'yep', 'nope',
    'gm', 'gn', 'tc', 'k', 'kk', 'ty', 'thx', 'thanks', 'thank you', 'welcome',
    'congrats', 'pls', 'please', 'bye', 'good', 'fine', 'cool', 'nice',
    'done', 'sure', 'alright', 'wait', 'wait a sec', 'coming', 'call you later',
    'see you', 'cu', 'cya', 'super', 'awesome', 'great', 'lol', 'haha', 'hahaha',
    'wow', 'omg', 'idk', 'brb', 'btw', 'gud', 'wfh', 'asap', 'fyi', 'tbd',
  };

  /// High-confidence German vocabulary indicators
  static final Set<String> _germanWords = {
    'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr', 'und', 'oder', 'aber',
    'nicht', 'ja', 'nein', 'bitte', 'danke', 'hallo', 'guten', 'morgen',
    'abend', 'nacht', 'wie', 'geht', 'mir', 'dir', 'was', 'ist',
    'ein', 'eine', 'der', 'die', 'das', 'den', 'dem', 'des', 'haben',
    'sein', 'werden', 'können', 'müssen', 'wollen', 'schön', 'tschüss',
  };

  /// Check a Personal Chat message for English-only policy.
  /// Strictly avoids false positives on:
  /// - Short messages (<= 3 chars, or <= 2 words matching exempt greetings)
  /// - URLs (http://, https://, www., .com, etc.)
  /// - Email addresses
  /// - Numbers, code snippets, emojis
  /// Confidently flags:
  /// - Malayalam script
  /// - Hindi script
  /// - Tamil, Telugu, Kannada, Arabic scripts
  /// - German words
  /// - Transliterated Malayalam (Manglish)
  /// - Transliterated Hindi (Hinglish)
  static LanguageCheckResult checkPersonalChatMessage(String text) {
    if (text.trim().isEmpty) {
      return const LanguageCheckResult(isValid: true);
    }

    final trimmed = text.trim();

    // 1. Skip if message is entirely or primarily a URL
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('www.') ||
        RegExp(r'https?:\/\/[^\s]+').hasMatch(trimmed) ||
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
      return const LanguageCheckResult(isValid: true);
    }

    // 2. Skip code snippets (enclosed in backticks or curly braces)
    if (trimmed.startsWith('```') || (trimmed.startsWith('{') && trimmed.endsWith('}'))) {
      return const LanguageCheckResult(isValid: true);
    }

    // 3. Remove emojis, symbols, and check remaining alphanumeric text length
    final withoutEmojis = trimmed.replaceAll(RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    ), ' ').trim();

    if (withoutEmojis.isEmpty) {
      return const LanguageCheckResult(isValid: true); // Pure emojis
    }

    // 4. Skip pure numbers, times, math, or punctuation
    final onlyAlpha = withoutEmojis.replaceAll(RegExp(r'[^a-zA-Z\u0D00-\u0D7F\u0900-\u097F\u0B80-\u0BFF\u0C00-\u0C7F\u0C80-\u0CFF\u0600-\u06FF]'), '');
    if (onlyAlpha.length < 2) {
      return const LanguageCheckResult(isValid: true);
    }

    // 5. Script checks (Immediate 100% confidence non-English)
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Malayalam',
      );
    }
    if (RegExp(r'[\u0900-\u097F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Hindi',
      );
    }
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Tamil',
      );
    }
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Arabic',
      );
    }
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Telugu',
      );
    }
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(trimmed)) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Kannada',
      );
    }

    // 6. Tokenize words for Latin-script text
    final tokens = withoutEmojis
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const LanguageCheckResult(isValid: true);
    }

    // Check if entire phrase is an exempt short conversational greeting
    final fullPhrase = tokens.join(' ');
    if (_exemptTerms.contains(fullPhrase)) {
      return const LanguageCheckResult(isValid: true);
    }

    if (tokens.length == 1 && (_exemptTerms.contains(tokens.first) || tokens.first.length <= 3)) {
      return const LanguageCheckResult(isValid: true);
    }

    // Count vocabulary matches
    int manglishMatches = 0;
    int hinglishMatches = 0;
    int germanMatches = 0;
    String? sampleNonEnglish;

    for (final token in tokens) {
      if (_manglishWords.contains(token)) {
        manglishMatches++;
        sampleNonEnglish ??= token;
      } else if (_hinglishWords.contains(token)) {
        hinglishMatches++;
        sampleNonEnglish ??= token;
      } else if (_germanWords.contains(token)) {
        germanMatches++;
        sampleNonEnglish ??= token;
      }
    }

    final totalNonEnglish = manglishMatches + hinglishMatches + germanMatches;

    // High confidence classification threshold:
    // If short (<= 3 words), require at least 1 strong indicator word
    // If longer (> 3 words), require at least 2 indicator words or >= 25% of tokens
    if (tokens.length <= 3 && totalNonEnglish >= 1) {
      String detected = 'Malayalam (Manglish)';
      if (hinglishMatches > manglishMatches && hinglishMatches > germanMatches) {
        detected = 'Hindi (Hinglish)';
      } else if (germanMatches > manglishMatches && germanMatches > hinglishMatches) {
        detected = 'German';
      }
      return LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.manglish,
        detectedWord: detected,
      );
    }

    if (totalNonEnglish >= 2 || (tokens.isNotEmpty && (totalNonEnglish / tokens.length) >= 0.25)) {
      String detected = 'Malayalam (Manglish)';
      if (hinglishMatches > manglishMatches && hinglishMatches > germanMatches) {
        detected = 'Hindi (Hinglish)';
      } else if (germanMatches > manglishMatches && germanMatches > hinglishMatches) {
        detected = 'German';
      }
      return LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.manglish,
        detectedWord: detected,
      );
    }

    return const LanguageCheckResult(isValid: true);
  }

  // -------------------------------------------------------------
  // 🏢 POCKETGANG GROUP MULTI-LANGUAGE VERIFIER (NO AI TOKENS)
  // -------------------------------------------------------------

  /// Verify whether a message sent in a PocketGang group matches the allowed languages.
  /// If the group allows ['en', 'ml'], both English and Malayalam are permitted!
  /// If the message contains an unsupported language (e.g. Arabic when only en+ml are allowed),
  /// returns isValid: false with the unsupported language name.
  static LanguageCheckResult checkGangMessage({
    required String text,
    required List<String> allowedLanguageCodes,
  }) {
    if (text.trim().isEmpty) return const LanguageCheckResult(isValid: true);

    // If English is the ONLY allowed language, delegate to personal check
    if (allowedLanguageCodes.length == 1 && allowedLanguageCodes.contains('en')) {
      return checkPersonalChatMessage(text);
    }

    final trimmed = text.trim();

    // Check script mismatches against allowed language codes
    final hasMalayalamScript = RegExp(r'[\u0D00-\u0D7F]').hasMatch(trimmed);
    if (hasMalayalamScript && !allowedLanguageCodes.contains('ml')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Malayalam',
      );
    }

    final hasHindiScript = RegExp(r'[\u0900-\u097F]').hasMatch(trimmed);
    if (hasHindiScript && !allowedLanguageCodes.contains('hi')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Hindi',
      );
    }

    final hasTamilScript = RegExp(r'[\u0B80-\u0BFF]').hasMatch(trimmed);
    if (hasTamilScript && !allowedLanguageCodes.contains('ta')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Tamil',
      );
    }

    final hasArabicScript = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);
    if (hasArabicScript && !allowedLanguageCodes.contains('ar')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Arabic',
      );
    }

    final hasTeluguScript = RegExp(r'[\u0C00-\u0C7F]').hasMatch(trimmed);
    if (hasTeluguScript && !allowedLanguageCodes.contains('te')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Telugu',
      );
    }

    final hasKannadaScript = RegExp(r'[\u0C80-\u0CFF]').hasMatch(trimmed);
    if (hasKannadaScript && !allowedLanguageCodes.contains('kn')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.nonLatinScript,
        detectedWord: 'Kannada',
      );
    }

    // Tokenize Latin script words
    final tokens = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (tokens.isEmpty) return const LanguageCheckResult(isValid: true);

    int manglishCount = 0;
    int hinglishCount = 0;
    int germanCount = 0;

    for (final token in tokens) {
      if (_manglishWords.contains(token)) manglishCount++;
      if (_hinglishWords.contains(token)) hinglishCount++;
      if (_germanWords.contains(token)) germanCount++;
    }

    if (manglishCount >= 2 && !allowedLanguageCodes.contains('ml')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.manglish,
        detectedWord: 'Malayalam (Manglish)',
      );
    }

    if (hinglishCount >= 2 && !allowedLanguageCodes.contains('hi')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.hinglish,
        detectedWord: 'Hindi (Hinglish)',
      );
    }

    if (germanCount >= 2 && !allowedLanguageCodes.contains('de')) {
      return const LanguageCheckResult(
        isValid: false,
        reason: LanguageViolationType.none,
        detectedWord: 'German',
      );
    }

    return const LanguageCheckResult(isValid: true);
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
