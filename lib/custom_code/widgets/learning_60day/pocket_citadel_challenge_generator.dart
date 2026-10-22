import 'dart:math' as math;
import 'pocket_fortress_defense_service.dart';
import 'curriculum_data/pocket_90day_sentence_builder_data.dart';
import 'pocket_90day_vocab_curriculum.dart';
import 'pocket_defense_question_bank.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// ⚔️ Pocket Citadel Challenge Generator
/// Generates an arcade mix of 4 interactive game formats for Citadel Raids:
/// 1. 🧩 Sentence Builder ('sentence_builder')
/// 2. 🔤 Word Spelling Challenge ('spelling_challenge')
/// 3. ⏳ Verb Timeline Arena ('verb_timeline')
/// 4. 🛡️ Tactical Defense MCQ ('mcq')
///
/// Guaranteed:
/// - Question count strictly matches defender level (e.g. Level 20 = 20 challenges).
/// - Non-repetitive rotation across the 4 arcade game modes.
/// - Full multi-language support (English, Hindi, Tamil, Telugu, Kannada, Malayalam).
class PocketCitadelChallengeGenerator {
  /// Generates the complete gauntlet of challenges when attacking a user/citadel
  static List<HouseShieldQuestion> generateChallengesForDefender({
    required int defenderLevel,
    bool isPresident = false,
    bool isVip = false,
    List<HouseShieldQuestion>? customArmedQuestions,
  }) {
    if (isPresident) {
      return _generatePresidentialGauntlet();
    }

    final List<HouseShieldQuestion> result = [];
    final random = math.Random(defenderLevel * 17);

    // 🏛️ 1. If defender is a VIP, generate the 10 Elite Presidential Protection Sentry Tasks FIRST!
    // User Audio Directive:
    // "വിഐപികൾക്ക് പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷന്റെ 10 ടാസ്ക് ഫസ്റ്റ് തോൽപ്പിച്ച് കഴിഞ്ഞിട്ടാണ് ഇവന്റെ വരുക!
    // പ്രസിഡൻഷ്യൽ കഴിഞ്ഞിട്ട് ഇവനെ അറ്റാക്ക് ചെയ്യണം! അപ്പോ എത്രയായി? 30 ക്വസ്റ്റ്യൻസ് ഉണ്ടാവും (Level 20 VIP)!
    // 10-ആമത്തെ ലെവലിൽ നിൽക്കുന്ന വിഐപി ആണെങ്കിൽ 20 ക്വസ്റ്റ്യൻസ് (10 pres + 10 level)!"
    if (isVip) {
      result.addAll(_generatePresidentialSentryTasks(10, random));
    }

    // 🛡️ 2. Defender's personal custom defense questions come FIRST!
    // User Audio Directive: "Attack cheyyaan nokkuna samayathu ee defense aanu aadyam varandathu."
    final armedPool = (customArmedQuestions != null && customArmedQuestions.isNotEmpty)
        ? List<HouseShieldQuestion>.from(customArmedQuestions)
        : <HouseShieldQuestion>[];

    final baseCount = defenderLevel > 0 ? defenderLevel.clamp(1, 90) : 1;
    final customCount = math.min(armedPool.length, baseCount);
    for (int i = 0; i < customCount; i++) {
      final taskIndex = result.length + 1;
      final customQ = armedPool[i];
      result.add(
        HouseShieldQuestion(
          id: 'raid_gate_${taskIndex}_custom_${customQ.id}',
          question: customQ.question,
          options: customQ.options,
          correctIndex: customQ.correctIndex,
          explanation: customQ.explanation,
          category: customQ.category,
          trapType: customQ.trapType,
          gameFormat: customQ.gameFormat,
        ),
      );
    }

    // 🕹️ 3. Fill remaining tasks up to defenderLevel with alternating interactive game formats
    for (int i = customCount; i < baseCount; i++) {
      final taskIndex = result.length + 1;
      final cycle = i % 4;
      final dayOffset = (i ~/ 4);
      final sourceDay = (((defenderLevel - 1 + dayOffset) % 90) + 1).clamp(1, 90);

      switch (cycle) {
        case 0:
          // 🧩 1. Sentence Builder Challenge
          result.add(_buildSentenceBuilderChallenge(taskIndex, sourceDay, random));
          break;
        case 1:
          // 🔤 2. Word Spelling Challenge (4 words)
          result.add(_buildSpellingChallenge(taskIndex, sourceDay, random));
          break;
        case 2:
          // ⏳ 3. Verb Timeline Challenge
          result.add(_buildVerbTimelineChallenge(taskIndex, sourceDay, random));
          break;
        case 3:
        default:
          // 🛡️ 4. Tactical Defense Gate Question
          result.add(_buildTacticalMcqChallenge(taskIndex, sourceDay, random));
          break;
      }
    }

    return result;
  }

  /// 🧩 1. Builds Sentence Builder Challenge
  static HouseShieldQuestion _buildSentenceBuilderChallenge(int qNum, int day, math.Random random) {
    final sentenceRounds = Pocket90DaySentenceBuilderData.getSentencesForDay(day);
    if (sentenceRounds.isNotEmpty) {
      final round = sentenceRounds[random.nextInt(sentenceRounds.length)];
      final cleanSentence = round.sentence.trim();
      final words = round.tiles.isNotEmpty
          ? round.tiles.map((t) => t.word).toList()
          : cleanSentence.split(RegExp(r'\s+'));

      final scrambled = List<String>.from(words)..shuffle(random);
      final localizedHint = round.getLocalizedTranslation();

      return HouseShieldQuestion(
        id: 'raid_gate_${qNum}_sentence_builder_day$day',
        question: localizedHint.isNotEmpty
            ? '🧩 Sentence Builder • Day $day\n"$localizedHint"'
            : '🧩 Sentence Builder • Construct the target sentence in grammatical order:',
        options: scrambled,
        correctIndex: 0,
        explanation: cleanSentence,
        category: 'syntax',
        trapType: 'syntax_wall',
        gameFormat: 'sentence_builder',
      );
    }

    const fallback = 'I practice speaking English with confidence.';
    final words = fallback.split(' ');
    final scrambled = List<String>.from(words)..shuffle(random);

    return HouseShieldQuestion(
      id: 'raid_gate_${qNum}_sentence_builder_day$day',
      question: '🧩 Sentence Builder • Day $day\n"ഞാൻ ആത്മവിശ്വാസത്തോടെ സംസാരിക്കുന്നു."',
      options: scrambled,
      correctIndex: 0,
      explanation: fallback,
      category: 'syntax',
      trapType: 'syntax_wall',
      gameFormat: 'sentence_builder',
    );
  }

  /// 🔤 2. Builds 4-Word Spelling Challenge
  /// User Audio Directive: "വേർഡ് സ്പെല്ലിംഗ് ചലഞ്ചിന്റെ ഒരു ടാസ്കിൽ തന്നെ നാലെണ്ണം ഫിക്സ് ചെയ്യണം, നാല് വേർഡുകൾ കറക്റ്റ് ആക്കണം, എന്നാലാണ് ആ ടാസ്ക് ജയിക്കുകയുള്ളൂ!"
  static HouseShieldQuestion _buildSpellingChallenge(int qNum, int day, math.Random random) {
    final vocabList = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final pool = vocabList.isNotEmpty ? List.from(vocabList) : <dynamic>[];
    pool.shuffle(random);

    final selected4 = pool.take(4).toList();
    if (selected4.length < 4) {
      selected4.addAll(Pocket90DayVocabCurriculum.getVocabForDay(1).take(4 - selected4.length));
    }

    final activeLang = PocketLanguageService.currentLanguage;
    final w1 = selected4[0].word.trim().toUpperCase();
    final w2 = selected4[1].word.trim().toUpperCase();
    final w3 = selected4[2].word.trim().toUpperCase();
    final w4 = selected4[3].word.trim().toUpperCase();

    final m1 = selected4[0].getMeaning(activeLang);
    final m2 = selected4[1].getMeaning(activeLang);
    final m3 = selected4[2].getMeaning(activeLang);
    final m4 = selected4[3].getMeaning(activeLang);

    // Helper to generate a subtle typo
    String makeTypo(String word) {
      if (word.length <= 3) return '${word}E';
      final idx = 1 + random.nextInt(word.length - 2);
      const vowels = ['A', 'E', 'I', 'O', 'U'];
      final char = word[idx];
      if (vowels.contains(char)) {
        final replacement = vowels[(vowels.indexOf(char) + 1) % vowels.length];
        return word.substring(0, idx) + replacement + word.substring(idx + 1);
      } else {
        return word.substring(0, idx) + char + word.substring(idx);
      }
    }

    final correctSet = '1. $w1 • 2. $w2 • 3. $w3 • 4. $w4';
    final distractor1 = '1. ${makeTypo(w1)} • 2. $w2 • 3. $w3 • 4. $w4';
    final distractor2 = '1. $w1 • 2. ${makeTypo(w2)} • 3. $w3 • 4. ${makeTypo(w4)}';
    final distractor3 = '1. $w1 • 2. $w2 • 3. ${makeTypo(w3)} • 4. $w4';

    final options = [correctSet, distractor1, distractor2, distractor3]..shuffle(random);
    final correctIdx = options.indexOf(correctSet);

    final meaningClues = (!PocketLanguageService.isEnglish && m1.isNotEmpty)
        ? '\nMeaning Clues: 1. $m1 | 2. $m2 | 3. $m3 | 4. $m4'
        : '';

    return HouseShieldQuestion(
      id: 'raid_gate_${qNum}_spelling4_day$day',
      question: '🔤 4-Word Spelling Gauntlet • Day $day\nFix all 4 words: Which set has ALL 4 words spelled 100% correctly?$meaningClues',
      options: options,
      correctIndex: correctIdx,
      explanation: 'All 4 Words Spelled Correctly: $w1, $w2, $w3, $w4',
      category: 'vocab',
      trapType: 'word_scramble',
      gameFormat: 'spelling_challenge',
    );
  }

  /// ⏳ 3. Builds Verb Timeline / Tenses Challenge
  static HouseShieldQuestion _buildVerbTimelineChallenge(int qNum, int day, math.Random random) {
    // Curated high-impact practical verb timeline scenarios
    final scenarios = [
      {
        'verb': 'WRITE',
        'past': 'wrote',
        'present': 'writes',
        'future': 'will write',
        'targetTense': 'PAST',
        'sentence': 'Yesterday, she ______ a heartfelt thank-you letter.',
        'correct': 'wrote',
        'rule': 'Use past tense "wrote" for an action finished yesterday.',
      },
      {
        'verb': 'SPEAK',
        'past': 'spoke',
        'present': 'speaks',
        'future': 'will speak',
        'targetTense': 'FUTURE',
        'sentence': 'Tomorrow, Rahul ______ at the international conference.',
        'correct': 'will speak',
        'rule': 'Use future form "will speak" for scheduled tomorrow events.',
      },
      {
        'verb': 'BUILD',
        'past': 'built',
        'present': 'builds',
        'future': 'will build',
        'targetTense': 'PRESENT',
        'sentence': 'Every morning, the team ______ new English fluency habits.',
        'correct': 'builds',
        'rule': 'Use simple present "builds" for habitual daily routines.',
      },
      {
        'verb': 'BEGIN',
        'past': 'began',
        'present': 'begins',
        'future': 'will begin',
        'targetTense': 'PAST',
        'sentence': 'Last week, we ______ our 90-day English adventure.',
        'correct': 'began',
        'rule': 'Use past tense "began" for an event that took place last week.',
      },
      {
        'verb': 'CHOOSE',
        'past': 'chose',
        'present': 'chooses',
        'future': 'will choose',
        'targetTense': 'FUTURE',
        'sentence': 'In the upcoming tournament, they ______ their best avatar.',
        'correct': 'will choose',
        'rule': 'Use future "will choose" for upcoming future decisions.',
      },
      {
        'verb': 'GROW',
        'past': 'grew',
        'present': 'grows',
        'future': 'will grow',
        'targetTense': 'PRESENT',
        'sentence': 'With consistent daily practice, vocabulary ______ rapidly.',
        'correct': 'grows',
        'rule': 'Use singular present "grows" for universal continuous progress.',
      },
      {
        'verb': 'DRIVE',
        'past': 'drove',
        'present': 'drives',
        'future': 'will drive',
        'targetTense': 'PAST',
        'sentence': 'Earlier today, they ______ through the mountain citadel.',
        'correct': 'drove',
        'rule': 'Use past form "drove" for completed travel.',
      },
      {
        'verb': 'ACHIEVE',
        'past': 'achieved',
        'present': 'achieves',
        'future': 'will achieve',
        'targetTense': 'FUTURE',
        'sentence': 'By Day 90, every dedicated learner ______ spoken fluency.',
        'correct': 'will achieve',
        'rule': 'Use future "will achieve" for future milestone accomplishment.',
      },
    ];

    final sc = scenarios[(day + qNum) % scenarios.length];
    final options = [
      '${sc['past']} (Past)',
      '${sc['present']} (Present)',
      '${sc['future']} (Future)',
    ];

    final correctIndex = sc['targetTense'] == 'PAST'
        ? 0
        : (sc['targetTense'] == 'PRESENT' ? 1 : 2);

    return HouseShieldQuestion(
      id: 'raid_gate_${qNum}_verb_timeline_day$day',
      question: '⏳ Verb Timeline • Complete the ${sc['targetTense']} tense:\n"${sc['sentence']}"\n(Base Verb: ${sc['verb']})',
      options: options,
      correctIndex: correctIndex,
      explanation: '${sc['rule']} (Correct: ${sc['correct']})',
      category: 'tense',
      trapType: 'tense_fortress',
      gameFormat: 'verb_timeline',
    );
  }

  /// 🛡️ 4. Builds Tactical Defense MCQ
  static HouseShieldQuestion _buildTacticalMcqChallenge(int qNum, int day, math.Random random) {
    final challenge = PocketDefenseQuestionBank.getRandomChallenge('grammar_defusal', day: day);
    final options = List<String>.from(challenge['options'] ?? ['Option A', 'Option B', 'Option C', 'Option D']);
    final correctIdx = (challenge['correctIndex'] as num? ?? 0).toInt().clamp(0, options.length - 1);

    return HouseShieldQuestion(
      id: 'raid_gate_${qNum}_mcq_day$day',
      question: '🛡️ Defense Gate • Day $day\n${challenge['question'] ?? 'Choose the grammatically accurate sentence:'}',
      options: options,
      correctIndex: correctIdx,
      explanation: challenge['explanation'] ?? 'Grammatical consistency is required.',
      category: challenge['category'] ?? 'grammar',
      trapType: 'grammar_sentry',
      gameFormat: 'mcq',
    );
  }

  /// 🏛️ Builds 200 Presidential Gauntlet Trials
  static List<HouseShieldQuestion> _generatePresidentialGauntlet() {
    final List<HouseShieldQuestion> trials = [];
    final random = math.Random(999);

    for (int i = 0; i < 200; i++) {
      final cycle = i % 4;
      final day = (i % 90) + 1;
      switch (cycle) {
        case 0:
          trials.add(_buildSentenceBuilderChallenge(i + 1, day, random));
          break;
        case 1:
          trials.add(_buildSpellingChallenge(i + 1, day, random));
          break;
        case 2:
          trials.add(_buildVerbTimelineChallenge(i + 1, day, random));
          break;
        case 3:
        default:
          trials.add(_buildTacticalMcqChallenge(i + 1, day, random));
          break;
      }
    }
    return trials;
  }

  /// 🏛️ Builds 10 Elite Presidential Protection Sentry Tasks for VIP Defended Estates
  /// User Audio Directive:
  /// "വിഐപികൾക്ക് പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷന്റെ 10 ടാസ്ക് ഫസ്റ്റ് തോൽപ്പിച്ച് കഴിഞ്ഞിട്ടാണ് ഇവന്റെ വരുക!
  /// പ്രസിഡൻഷ്യൽ കഴിഞ്ഞിട്ട് ഇവനെ അറ്റാക്ക് ചെയ്യണം! അപ്പോ എത്രയായി? 30 ക്വസ്റ്റ്യൻസ് ഉണ്ടാവും (Level 20 VIP)!
  /// 10-ആമത്തെ ലെവലിൽ നിൽക്കുന്ന വിഐപി ആണെങ്കിൽ 20 ക്വസ്റ്റ്യൻസ് (10 pres + 10 level)!"
  static List<HouseShieldQuestion> _generatePresidentialSentryTasks(int count, math.Random random) {
    final List<HouseShieldQuestion> sentries = [];
    for (int i = 0; i < count; i++) {
      final cycle = i % 4;
      final sentryDay = ((i * 7 + 13) % 90) + 1;
      final taskNum = i + 1;

      switch (cycle) {
        case 0:
          final q = _buildSentenceBuilderChallenge(taskNum, sentryDay, random);
          sentries.add(
            HouseShieldQuestion(
              id: 'vip_pres_sentry_${taskNum}_sentence',
              question: '🏛️ PRESIDENTIAL SENTRY $taskNum/10 (Guarding VIP Estate)\n${q.question}',
              options: q.options,
              correctIndex: q.correctIndex,
              explanation: q.explanation,
              category: 'presidential_sentry',
              trapType: 'presidential_wall',
              gameFormat: 'sentence_builder',
            ),
          );
          break;
        case 1:
          final q = _buildSpellingChallenge(taskNum, sentryDay, random);
          sentries.add(
            HouseShieldQuestion(
              id: 'vip_pres_sentry_${taskNum}_spelling',
              question: '🏛️ PRESIDENTIAL SENTRY $taskNum/10 (Guarding VIP Estate)\n${q.question}',
              options: q.options,
              correctIndex: q.correctIndex,
              explanation: q.explanation,
              category: 'presidential_sentry',
              trapType: 'presidential_spelling',
              gameFormat: 'spelling_challenge',
            ),
          );
          break;
        case 2:
          final q = _buildVerbTimelineChallenge(taskNum, sentryDay, random);
          sentries.add(
            HouseShieldQuestion(
              id: 'vip_pres_sentry_${taskNum}_verb',
              question: '🏛️ PRESIDENTIAL SENTRY $taskNum/10 (Guarding VIP Estate)\n${q.question}',
              options: q.options,
              correctIndex: q.correctIndex,
              explanation: q.explanation,
              category: 'presidential_sentry',
              trapType: 'presidential_timeline',
              gameFormat: 'verb_timeline',
            ),
          );
          break;
        case 3:
        default:
          final q = _buildTacticalMcqChallenge(taskNum, sentryDay, random);
          sentries.add(
            HouseShieldQuestion(
              id: 'vip_pres_sentry_${taskNum}_mcq',
              question: '🏛️ PRESIDENTIAL SENTRY $taskNum/10 (Guarding VIP Estate)\n${q.question}',
              options: q.options,
              correctIndex: q.correctIndex,
              explanation: q.explanation,
              category: 'presidential_sentry',
              trapType: 'presidential_gate',
              gameFormat: 'mcq',
            ),
          );
          break;
      }
    }
    return sentries;
  }

  /// 🛠️ Generates a specific challenge matching the selected format for day
  /// Supports: 'sentence_builder', 'spelling_challenge', 'verb_timeline', 'mcq'
  static HouseShieldQuestion buildChallengeForFormat({
    required String format,
    required int day,
    int taskIndex = 1,
    math.Random? random,
  }) {
    final r = random ?? math.Random(day * 31 + taskIndex);
    switch (format) {
      case 'sentence_builder':
        return _buildSentenceBuilderChallenge(taskIndex, day, r);
      case 'spelling_challenge':
        return _buildSpellingChallenge(taskIndex, day, r);
      case 'verb_timeline':
        return _buildVerbTimelineChallenge(taskIndex, day, r);
      case 'mcq':
      default:
        return _buildTacticalMcqChallenge(taskIndex, day, r);
    }
  }
}
