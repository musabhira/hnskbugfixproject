import 'dart:math' as math;

/// 🌐 App-Wide Universal Speech Normalizer & Crash-Resistant Fuzzy Matcher
///
/// Handles mobile STT quirks, number-to-word conversions, phonetic mishearings,
/// and forgiving accent tolerance across the entire application.
class PocketSpeechNormalizer {
  /// Cleans and sanitizes raw text: removes control chars, trims, collapses spaces
  static String clean(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w'\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Normalizes spoken text against common mobile Speech-To-Text inaccuracies:
  /// - Numbers to words ("4" -> "for" / "four", "2" -> "two" / "to", etc.)
  /// - Letter-number combos ("A 4" -> "A for", "B4" -> "B for", "C 4" -> "C for")
  /// - Common phonetic phoneme confusions ("before ball" -> "B for ball", "see for cat" -> "C for cat")
  /// - Contractions ("can't" -> "cannot", "i'm" -> "i am")
  static String normalize(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';

    String s = ' ${raw.toLowerCase().trim()} ';

    // 1. Common Phonetic Alphabet confusions from mobile STT
    s = s.replaceAll(RegExp(r'\bbefore\s+ball\b'), 'b for ball');
    s = s.replaceAll(RegExp(r'\bsee\s+for\s+cat\b'), 'c for cat');
    s = s.replaceAll(RegExp(r'\btea\s+for\s+tiger\b'), 't for tiger');
    s = s.replaceAll(RegExp(r'\byou\s+for\s+umbrella\b'), 'u for umbrella');
    s = s.replaceAll(RegExp(r'\bare\s+for\s+rabbit\b'), 'r for rabbit');
    s = s.replaceAll(RegExp(r'\bour\s+for\s+rabbit\b'), 'r for rabbit');
    s = s.replaceAll(RegExp(r'\bwhy\s+for\s+yak\b'), 'y for yak');
    s = s.replaceAll(RegExp(r'\beye\s+for\s+ice\b'), 'i for ice');
    s = s.replaceAll(RegExp(r'\boh\s+for\s+orange\b'), 'o for orange');

    // 2. Letter + 4 patterns (e.g. "a 4", "a4", "b 4", "b4", etc.)
    s = s.replaceAll(RegExp(r'\b([a-z])\s*4\b'), r'$1 for');
    s = s.replaceAll(RegExp(r'\b([a-z])4\b'), r'$1 for');

    // 3. Standalone digit normalization
    s = s.replaceAll(RegExp(r'\b4\b'), 'for');
    s = s.replaceAll(RegExp(r'\b2\b'), 'to');
    s = s.replaceAll(RegExp(r'\b1\b'), 'one');
    s = s.replaceAll(RegExp(r'\b3\b'), 'three');
    s = s.replaceAll(RegExp(r'\b5\b'), 'five');
    s = s.replaceAll(RegExp(r'\b6\b'), 'six');
    s = s.replaceAll(RegExp(r'\b7\b'), 'seven');
    s = s.replaceAll(RegExp(r'\b8\b'), 'eight');
    s = s.replaceAll(RegExp(r'\b9\b'), 'nine');
    s = s.replaceAll(RegExp(r'\b0\b'), 'zero');
    s = s.replaceAll(RegExp(r'\b10\b'), 'ten');

    // 4. English Contraction expansions
    s = s.replaceAll("couldn't", 'could not');
    s = s.replaceAll("wouldn't", 'would not');
    s = s.replaceAll("shouldn't", 'should not');
    s = s.replaceAll("don't", 'do not');
    s = s.replaceAll("doesn't", 'does not');
    s = s.replaceAll("didn't", 'did not');
    s = s.replaceAll("can't", 'cannot');
    s = s.replaceAll("won't", 'will not');
    s = s.replaceAll("i'm", 'i am');
    s = s.replaceAll("we're", 'we are');
    s = s.replaceAll("they're", 'they are');
    s = s.replaceAll("it's", 'it is');
    s = s.replaceAll("that's", 'that is');
    s = s.replaceAll("what's", 'what is');
    s = s.replaceAll("let's", 'let us');

    // 5. Clean up extra punctuation and collapse whitespace
    return s
        .replaceAll(RegExp(r"[^\w'\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Crash-resistant safe matching between spoken user voice and target sentence/word
  static bool isMatch({
    required String spokenText,
    required String targetSentence,
    int thresholdPercentage = 50,
  }) {
    try {
      final cleanSpoken = normalize(spokenText);
      final cleanTarget = normalize(targetSentence);

      if (cleanSpoken.isEmpty) return false;
      if (cleanTarget.isEmpty) return true;

      // 1. Direct equality
      if (cleanSpoken == cleanTarget) return true;

      // 2. Substring inclusion
      if (cleanSpoken.contains(cleanTarget) || cleanTarget.contains(cleanSpoken)) {
        return true;
      }

      final spokenTokens = cleanSpoken.split(' ').where((w) => w.isNotEmpty).toList();
      final targetTokens = cleanTarget.split(' ').where((w) => w.isNotEmpty).toList();

      if (spokenTokens.isEmpty || targetTokens.isEmpty) return false;

      // 3. Alphabet Drill Rule: e.g. "a for apple" -> if user said "apple", "a", or "a for"
      if (targetTokens.length >= 2 && targetTokens.contains('for')) {
        final keyWord = targetTokens.last;
        final keyLetter = targetTokens.first;
        if (spokenTokens.contains(keyWord) ||
            spokenTokens.contains(keyLetter) ||
            cleanSpoken.contains(keyWord) ||
            cleanSpoken.contains(keyLetter)) {
          return true;
        }
      }

      // 4. Token overlap count
      int matchedCount = 0;
      for (final t in targetTokens) {
        if (spokenTokens.any((s) => s == t || _isPhoneticallyClose(s, t))) {
          matchedCount++;
        }
      }

      final matchPercent = (matchedCount / targetTokens.length * 100).round();
      if (matchPercent >= thresholdPercentage) {
        return true;
      }

      // 5. Fuzzy string distance
      final distance = _levenshtein(cleanSpoken, cleanTarget);
      final maxLen = math.max(cleanSpoken.length, cleanTarget.length);
      if (maxLen > 0) {
        final similarity = ((1.0 - (distance / maxLen)) * 100).round();
        if (similarity >= thresholdPercentage) {
          return true;
        }
      }

      return false;
    } catch (_) {
      // In case of any unexpected format or regex error, fail gracefully without crashing
      return false;
    }
  }

  static bool _isPhoneticallyClose(String a, String b) {
    if (a == b) return true;
    if ((a.length - b.length).abs() > 2) return false;
    return _levenshtein(a, b) <= 2;
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = math.min(
          v1[j] + 1,
          math.min(v0[j + 1] + 1, v0[j] + cost),
        );
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}
