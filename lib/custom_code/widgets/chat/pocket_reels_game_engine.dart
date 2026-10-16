import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎮 Types of interactive English mini-games displayed in the Reels feed
enum ReelGameType {
  gapFill,           // Tricky grammar & preposition fill-in-the-blank
  sentenceBuilder,   // Jumbled words tap-to-order into a natural sentence
  smartReply,        // Funny, witty, or polite conversational reply/comeback
  spotTheError,      // Find the faulty word in the sentence
  vocabularyMatch,   // Synonym / Antonym / Meaning challenge
  idiomDecrypter,    // Pro idiom / everyday slang in real context
  collocationClash,  // Natural English pairings (Make vs Do, Heavy vs Strong)
  phonicsRiddle,     // Silent letters & pronunciation traps
  tenseShift,        // Fast past-tense / irregular verb blitz
}

/// 🎯 Model for any Reel English Mini-Game Card
class ReelGameCard {
  final String id;
  final ReelGameType gameType;
  final String category; // e.g. 'SMART REPLY 💬', 'SENTENCE BUILDER 🧩', 'SPOT THE ERROR 🕵️'
  final String prompt; // Main prompt, conversational question, or setup
  final String? contextSituation; // e.g. "Colleague asks: 'Why did you change the deadline?'"
  final List<String> options; // Multiple choice options OR jumbled words for sentenceBuilder
  final int correctOptionIndex; // Index of correct option (or -1 if sentenceBuilder)
  final List<String>? correctSentenceWords; // Correct word sequence for sentenceBuilder
  final Map<String, String> nativeExplanations; // 'Malayalam', 'Tamil', 'Hindi', 'English'
  final String contextHint; // Subtle hint or situational clue
  final String? funnyNote; // Humorous takeaway or conversational tip
  final String? speakerName; // Character name e.g. "Sparky Tiger", "Pandy Panda", "King Lion"
  final String? speakerAvatar; // Character avatar emoji e.g. "🐯", "🐼", "🦁"
  final String? speakerRole; // Character role e.g. "Phonics Buddy", "Manners Guide", "Kingdom Sovereign"

  final int minLevel;
  final int maxLevel;

  const ReelGameCard({
    required this.id,
    required this.gameType,
    required this.category,
    required this.prompt,
    this.contextSituation,
    required this.options,
    this.correctOptionIndex = 0,
    this.correctSentenceWords,
    required this.nativeExplanations,
    required this.contextHint,
    this.funnyNote,
    this.speakerName,
    this.speakerAvatar,
    this.speakerRole,
    this.minLevel = 1,
    this.maxLevel = 90,
  });

  String getExplanation(String lang) {
    if (nativeExplanations.containsKey(lang)) {
      return nativeExplanations[lang]!;
    }
    return nativeExplanations['Malayalam'] ??
        nativeExplanations['English'] ??
        'Master natural English by practicing daily!';
  }
}

/// 🧠 Central Game Engine & Dataset for Reels Feed Mini-Games
class PocketReelsGameEngine {
  static final Set<String> _viewedGameIds = {};
  static bool _initialized = false;
  static final math.Random _random = math.Random();

  /// Initialize and load previously viewed games from SharedPreferences
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('pm_viewed_game_ids') ?? [];
      _viewedGameIds.addAll(saved);
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing PocketReelsGameEngine: $e');
    }
  }

  /// Mark a game as viewed/played so it is not shown again immediately
  static Future<void> markGameViewed(String gameId) async {
    if (_viewedGameIds.add(gameId)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('pm_viewed_game_ids', _viewedGameIds.toList());
      } catch (e) {
        debugPrint('Error saving viewed game id: $e');
      }
    }
  }

  /// Reset viewed games history
  static Future<void> clearViewedHistory() async {
    _viewedGameIds.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pm_viewed_game_ids');
    } catch (_) {}
  }

  /// Fetch a batch of games prioritizing unviewed cards.
  /// If unviewed cards run low, recycles seen cards at the bottom or dynamically generates fresh cards.
  static List<ReelGameCard> getNextGameBatch({int count = 6}) {
    final allCards = List<ReelGameCard>.from(_curatedGameCards);

    // Filter unviewed cards
    final unviewed = allCards.where((g) => !_viewedGameIds.contains(g.id)).toList();
    unviewed.shuffle(_random);

    final List<ReelGameCard> result = [];

    if (unviewed.length >= count) {
      result.addAll(unviewed.take(count));
    } else {
      // Add all available unviewed
      result.addAll(unviewed);

      // If needed, generate dynamic cards or add seen ones at the end
      final seen = allCards.where((g) => _viewedGameIds.contains(g.id)).toList();
      seen.shuffle(_random);

      final needed = count - result.length;
      result.addAll(seen.take(needed));

      // If still not enough, generate dynamic challenges
      while (result.length < count) {
        result.add(_generateDynamicGameCard(result.length + 1));
      }
    }

    return result;
  }

  /// 🌟 Dynamically generates endless variety of English challenges
  static ReelGameCard _generateDynamicGameCard(int seed) {
    final types = ReelGameType.values;
    final chosenType = types[_random.nextInt(types.length)];
    final dynId = 'dyn_game_${DateTime.now().millisecondsSinceEpoch}_$seed';

    switch (chosenType) {
      case ReelGameType.smartReply:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.smartReply,
          category: 'SMART COMEBACK 💬',
          prompt: 'Someone asks: "Can you keep a secret?"',
          contextSituation: 'A mischievous friend whispers before sharing gossip',
          options: [
            '"My lips are sealed! 🤐"',
            '"I am keeping it inside bag."',
            '"Yes, I will say to everyone."',
            '"Secret is not my problem."',
          ],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': '"My lips are sealed" എന്നാൽ ഞാൻ ആരോടും പറയില്ല, രഹസ്യമായി സൂക്ഷിക്കും എന്ന നേറ്റീവ് ശൈലിയാണ്! 🤐',
            'Tamil': '"My lips are sealed" என்றால் யாரிடமும் சொல்ல மாட்டேன், ரகசியமாக வைத்திருப்பேன்! 🤐',
            'Hindi': '"My lips are sealed" का अर्थ है कि यह राज़ मेरे तक ही रहेगा! 🤐',
            'English': '"My lips are sealed" is a native idiom meaning you promise to keep a secret completely safe! 🤐',
          },
          contextHint: 'Classic idiomatic reply when trusted with a secret',
          funnyNote: 'Native speakers love this dramatic response! 🤐',
        );

      case ReelGameType.sentenceBuilder:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.sentenceBuilder,
          category: 'SENTENCE BUILDER 🧩',
          prompt: 'Arrange the words in correct natural order:',
          options: ['coffee', 'I', 'need', 'a', 'hot', 'cup', 'of'],
          correctSentenceWords: ['I', 'need', 'a', 'hot', 'cup', 'of', 'coffee'],
          nativeExplanations: {
            'Malayalam': 'ശരിയായ ക്രമം: "I need a hot cup of coffee" (Subject + Verb + Object phrase) ☕',
            'Tamil': 'சரியான வரிசை: "I need a hot cup of coffee" ☕',
            'Hindi': 'सही क्रम: "I need a hot cup of coffee" ☕',
            'English': 'Standard SVO structure: "I need a hot cup of coffee" ☕',
          },
          contextHint: 'Subject + Verb + Article + Adjective + Noun phrase',
        );

      case ReelGameType.spotTheError:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.spotTheError,
          category: 'SPOT THE ERROR 🕵️',
          prompt: 'Which word contains the grammatical mistake?',
          contextSituation: '"He don\'t know the correct answer."',
          options: ['He', 'don\'t', 'know', 'correct'],
          correctOptionIndex: 1,
          nativeExplanations: {
            'Malayalam': 'തെറ്റ്: "don\'t". Third person singular (He/She/It) ആയതിനാൽ "doesn\'t" ആണ് വരേണ്ടത്! ✅',
            'Tamil': 'தவறு: "don\'t". He உடன் "doesn\'t" வரவேண்டும்! ✅',
            'Hindi': 'गलती: "don\'t". He के साथ "doesn\'t" आता है! ✅',
            'English': 'Correction: "He doesn\'t know...". Third-person singular requires "does not". ✅',
          },
          contextHint: 'Subject-verb agreement rule for third-person singular',
        );

      case ReelGameType.vocabularyMatch:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.vocabularyMatch,
          category: 'VOCAB POWER ⚡',
          prompt: 'What is the closest synonym of "BENEVOLENT"?',
          contextSituation: 'Describing a generous leader who donates to charities',
          options: ['Kind & Generous', 'Selfish & Greedy', 'Strict & Angry', 'Slow & Lazy'],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': '"Benevolent" എന്നാൽ ദയാലുവും മറ്റുള്ളവരെ സഹായിക്കാൻ സന്നദ്ധനുമായ വ്യക്തി (Kind & Generous) 💖',
            'Tamil': '"Benevolent" என்றால் அன்பும் கருணையும் உள்ளவர்! 💖',
            'Hindi': '"Benevolent" का अर्थ है दयालु और परोपकारी! 💖',
            'English': '"Benevolent" means well-meaning, kindly, and charitable. 💖',
          },
          contextHint: 'Think of "benefit" and "benefactor"',
        );

      case ReelGameType.collocationClash:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.collocationClash,
          category: 'NATURAL COLLOCATION ⚔️',
          prompt: 'Which phrase is natural and grammatically correct?',
          options: [
            'Make a decision ✅',
            'Do a decision ❌',
            'Take a decision ❌',
            'Build a decision ❌',
          ],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': 'ഇംഗ്ലീഷിൽ "Make a decision" എന്നാണ് പറയുക ("Do a decision" എന്ന് പറയരുത്)! 🎯',
            'Tamil': 'ஆங்கிலத்தில் "Make a decision" என்பதே சரியான பயன்பாடு! 🎯',
            'Hindi': 'अंग्रेजी में "Make a decision" कहा जाता है ("Do a decision" नहीं)! 🎯',
            'English': 'Standard collocation: we "make a decision" or "reach a decision", never "do a decision". 🎯',
          },
          contextHint: 'Common "Make vs Do" trap for non-native speakers',
          funnyNote: 'You make coffee, and you make decisions! ☕',
        );

      case ReelGameType.phonicsRiddle:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.phonicsRiddle,
          category: 'SILENT LETTER TRAP 🤫',
          prompt: 'Which word has a SILENT letter that is NOT pronounced?',
          options: [
            'DOUBT (Silent B) 🤫',
            'CABIN 🏡',
            'ROBOT 🤖',
            'PLANT 🌱',
          ],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': '"DOUBT" എന്ന വാക്കിലെ "B" ഉച്ചരിക്കാറില്ല (Silent B). "ഡൗട്ട്" (/daʊt/) എന്നാണ് പറയേണ്ടത്! 🤫',
            'Tamil': '"DOUBT" என்பதில் "B" உச்சரிக்கப்படுவதில்லை! /daʊt/ 🤫',
            'Hindi': '"DOUBT" में "B" साइलेंट होता है, इसे "डाउट" बोलते हैं! 🤫',
            'English': 'The letter "B" is completely silent in "doubt", "debt", and "subtle"! 🤫',
          },
          contextHint: 'Look for the silent consonant',
          funnyNote: 'English spelling loves sneaking in silent letters! 🕵️',
        );

      case ReelGameType.tenseShift:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.tenseShift,
          category: 'PAST TENSE BLITZ ⏳',
          prompt: 'What is the past tense (V2) of "CHOOSE"?',
          options: ['Chose 🎯', 'Choosed ❌', 'Chosen ❌', 'Choosen ❌'],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': '"Choose" എന്ന വാക്കിന്റെ ഭൂതകാല രൂപം (Past tense) "Chose" ആണ്. "Chosen" എന്നത് V3 (Past Participle) ആണ്! ⏳',
            'Tamil': '"Choose" என்பதன் இறந்த காலம் "Chose"! ⏳',
            'Hindi': '"Choose" का past tense "Chose" होता है! ⏳',
            'English': 'Irregular verb: Choose (V1) -> Chose (V2) -> Chosen (V3). ⏳',
          },
          contextHint: 'Single "o" in simple past',
        );

      case ReelGameType.idiomDecrypter:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.idiomDecrypter,
          category: 'NATIVE SLANG 🎭',
          prompt: 'What does "Piece of cake" mean in conversation?',
          contextSituation: '"Don\'t worry about the interview, it will be a piece of cake!"',
          options: [
            'Very easy and simple to do 🍰',
            'A sweet dessert for lunch 🧁',
            'A difficult math exam 📚',
            'A birthday celebration 🎈',
          ],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': '"Piece of cake" എന്നാൽ വളരെ എളുപ്പമുള്ള കാര്യം (Very easy) എന്നാണ് അർത്ഥം! 🍰',
            'Tamil': '"Piece of cake" என்றால் மிக எளிதான விஷயம்! 🍰',
            'Hindi': '"Piece of cake" का अर्थ है बहुत आसान काम! 🍰',
            'English': '"Piece of cake" is a classic idiom meaning something is effortless or very easy to accomplish. 🍰',
          },
          contextHint: 'Think of how effortless it is to eat a piece of cake!',
        );

      default:
        return ReelGameCard(
          id: dynId,
          gameType: ReelGameType.gapFill,
          category: 'FLUENCY GAP-FILL 🚀',
          prompt: 'I have been living in this city _____ five years.',
          options: ['for', 'since', 'from', 'during'],
          correctOptionIndex: 0,
          nativeExplanations: {
            'Malayalam': 'കാലയളവ് (Duration of time - 5 years) പറയുമ്പോൾ "for" ഉപയോഗിക്കണം. നിർദ്ദിഷ്ട പോയിന്റ് ആണെങ്കിൽ "since" വരും! ⏰',
            'Tamil': 'கால அளவைக் (5 years) குறிக்க "for" பயன்படுத்த வேண்டும்! ⏰',
            'Hindi': 'समय की अवधि (5 years) के लिए "for" का प्रयोग होता है! ⏰',
            'English': 'Use "for" with periods of time (five years), and "since" with specific starting points (2019). ⏰',
          },
          contextHint: 'Duration of time vs starting point',
        );
    }
  }

  /// 📚 Rich Master Curated Library of Diverse Mini-Games
  static List<ReelGameCard> get curatedGameCards => _curatedGameCards;
  static ReelGameCard getGameByIndex(int index) =>
      _curatedGameCards[index.abs() % _curatedGameCards.length];

  static const List<ReelGameCard> _curatedGameCards = [
    // -------------------------------------------------------------
    // 1. SMART COMEBACK & FUNNY CONVERSATION REPLIES (Category: smartReply)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_reply_1',
      gameType: ReelGameType.smartReply,
      category: 'SMART REPLY 💬',
      prompt: 'Someone says: "Why are you always late?"',
      contextSituation: 'Your friend jokingly confronts you when you arrive 10 minutes late',
      options: [
        '"A master arrives precisely when meant to! 🧙‍♂️"',
        '"Because clock is running very fast."',
        '"I am not late, you came too early."',
        '"Shut your mouth please."',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'നല്ലൊരു ഫണ്ണി വിറ്റി റിപ്ലൈ: "A master arrives precisely when meant to!" (ലോർഡ് ഓഫ് ദി റിങ്സ് സിനിമയിലെ പ്രശസ്തമായ തമാശ ഡയലോഗ്) 😄',
        'Tamil': 'மிகவும் நகைச்சுவையான பதில்: "A master arrives precisely when meant to!" 😄',
        'Hindi': 'एक मजेदार और स्मार्ट उत्तर: "A master arrives precisely when meant to!" 😄',
        'English': 'A witty, humorous Lord of the Rings reference that diffuses tension with playful charm! 😄',
      },
      contextHint: 'Playful native movie quote reply',
      funnyNote: 'Use this with close friends for instant laughter! 😂',
    ),
    ReelGameCard(
      id: 'game_reply_2',
      gameType: ReelGameType.smartReply,
      category: 'POLITE REFUSAL 🛡️',
      prompt: 'Colleague asks: "Can you finish this urgent report for me tonight?"',
      contextSituation: 'You already have your own deadlines and need to decline professionally',
      options: [
        '"I wish I could, but my plate is completely full today. 📋"',
        '"No I hate reports do it yourself."',
        '"Why you are always giving me work?"',
        '"I am going to sleep goodbye."',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"My plate is full" എന്നാൽ എനിക്ക് ഇപ്പോൾ തന്നെ ഒരുപാട് ജോലികൾ ചെയ്യാനുണ്ട് എന്ന പ്രൊഫഷണൽ ഇംഗ്ലീഷ് ശൈലിയാണ്! 💼',
        'Tamil': '"My plate is full" என்றால் எனக்கு ஏற்கனவே நிறைய வேலைகள் உள்ளன என்று மரியாதையாக மறுப்பது! 💼',
        'Hindi': '"My plate is full" का अर्थ है कि मेरे पास पहले से ही बहुत काम है! 💼',
        'English': '"My plate is full" is the go-to professional idiom for declining extra tasks politely without offending anyone. 💼',
      },
      contextHint: 'Polite corporate boundary idiom',
      funnyNote: 'Zero drama, 100% professional! 💼',
    ),
    ReelGameCard(
      id: 'game_reply_3',
      gameType: ReelGameType.smartReply,
      category: 'NATIVE GREETING ☕',
      prompt: 'A native speaker walks past and says: "What’s cooking, good looking?"',
      contextSituation: 'A friendly casual greeting from a colleague in the office kitchen',
      options: [
        '"Not much, just brewing some coffee! ☕"',
        '"I am not cooking anything in kitchen."',
        '"Who are you calling looking good?"',
        '"No food is present."',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"What\'s cooking?" എന്നത് "എന്തൊക്കെയുണ്ട് വിശേഷങ്ങൾ?" എന്ന സൗഹൃദ സംഭാഷണമാണ്, അല്ലാതെ ഭക്ഷണം പാചകം ചെയ്യുന്നതിനെക്കുറിച്ചല്ല! ☕',
        'Tamil': '"What\'s cooking?" என்பது நலம் விசாரிக்கும் ஒரு வேடிக்கையான வழக்குச்சொல்! ☕',
        'Hindi': '"What\'s cooking?" का अर्थ है "क्या चल रहा है?", यह खाना पकाने से संबंधित नहीं है! ☕',
        'English': '"What\'s cooking?" is a rhyming, casual informal greeting meaning "What\'s going on?" or "How are things?" ☕',
      },
      contextHint: 'Casual rhyming greeting — do not take it literally!',
    ),

    // -------------------------------------------------------------
    // 2. SENTENCE BUILDER (Category: sentenceBuilder)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_sent_1',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      prompt: 'Tap words in order to form the natural sentence:',
      options: ['forward', 'looking', 'to', 'am', 'I', 'meeting', 'you'],
      correctSentenceWords: ['I', 'am', 'looking', 'forward', 'to', 'meeting', 'you'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ വാക്യം: "I am looking forward to meeting you." ("look forward to" കഴിഞ്ഞ് Gerund -ing വരണം) ✅',
        'Tamil': 'சரியான வாக்கியம்: "I am looking forward to meeting you." ✅',
        'Hindi': 'सही वाक्य: "I am looking forward to meeting you." ✅',
        'English': 'Proper word order: Subject (I) + Auxiliary (am) + Phrasal Verb (looking forward to) + Gerund (meeting) + Object (you). ✅',
      },
      contextHint: 'Standard email sign-off phrasing',
    ),
    ReelGameCard(
      id: 'game_sent_2',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      prompt: 'Arrange the words into a fluent question:',
      options: ['time', 'what', 'does', 'the', 'meeting', 'start'],
      correctSentenceWords: ['what', 'time', 'does', 'the', 'meeting', 'start'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ ചോദ്യം: "What time does the meeting start?" (Wh-word + Auxiliary + Subject + Main verb) ⏰',
        'Tamil': 'சரியான கேள்வி: "What time does the meeting start?" ⏰',
        'Hindi': 'सही प्रश्न: "What time does the meeting start?" ⏰',
        'English': 'Natural question order: Wh-phrase (What time) + Aux (does) + Subject (the meeting) + Base Verb (start)? ⏰',
      },
      contextHint: 'Question order: Wh-phrase + Aux + Subject + Verb',
    ),
    ReelGameCard(
      id: 'game_sent_3',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      prompt: 'Arrange into an everyday polite request:',
      options: ['you', 'could', 'me', 'pass', 'salt', 'the', 'please'],
      correctSentenceWords: ['could', 'you', 'please', 'pass', 'me', 'the', 'salt'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ ക്രമം: "Could you please pass me the salt?" (ഭക്ഷണമേശയിലെ മാന്യമായ ഇംഗ്ലീഷ് ചോദ്യം) 🧂',
        'Tamil': 'சரியான வரிசை: "Could you please pass me the salt?" 🧂',
        'Hindi': 'सही क्रम: "Could you please pass me the salt?" 🧂',
        'English': 'Polite table etiquette: "Could you please pass me the salt?" 🧂',
      },
      contextHint: 'Polite dining request formula',
    ),

    // -------------------------------------------------------------
    // 3. SPOT THE ERROR / GRAMMAR POLICE (Category: spotTheError)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_err_1',
      gameType: ReelGameType.spotTheError,
      category: 'SPOT THE ERROR 🕵️',
      prompt: 'Identify the word with the grammatical mistake:',
      contextSituation: '"She has lived in Kerala since three years."',
      options: ['She', 'has lived', 'since', 'three years'],
      correctOptionIndex: 2,
      nativeExplanations: {
        'Malayalam': 'തെറ്റ് "since" ആണ്! മൂന്ന് വർഷം എന്നത് ഒരു കാലയളവ് (duration) ആയതിനാൽ "for three years" എന്നാണ് പറയേണ്ടത്! 💡',
        'Tamil': 'தவறு "since". கால அளவிற்கு "for three years" என்று கூற வேண்டும்! 💡',
        'Hindi': 'गलती "since" है। समय की अवधि के लिए "for three years" होना चाहिए! 💡',
        'English': 'Error: "since". Use "for" with durations (for three years), and "since" only with starting points (since 2021). 💡',
      },
      contextHint: 'Duration of time vs starting point',
    ),
    ReelGameCard(
      id: 'game_err_2',
      gameType: ReelGameType.spotTheError,
      category: 'SPOT THE ERROR 🕵️',
      prompt: 'Where is the grammatical slip in this sentence?',
      contextSituation: '"Each of the students were given a medal."',
      options: ['Each', 'of the students', 'were', 'given a medal'],
      correctOptionIndex: 2,
      nativeExplanations: {
        'Malayalam': 'തെറ്റ് "were" ആണ്! "Each" എന്നത് ഏകവചനം (singular) ആയതിനാൽ "was given" എന്നാണ് ശരി! 🏅',
        'Tamil': 'தவறு "were". "Each" ஒருமை என்பதால் "was" வரவேண்டும்! 🏅',
        'Hindi': 'गलती "were" है। "Each" एकवचन है, इसलिए "was" आएगा! 🏅',
        'English': 'Error: "were". "Each" is singular, so the verb must be "was given", not "were given". 🏅',
      },
      contextHint: 'Indefinite pronoun subject agreement',
    ),
    ReelGameCard(
      id: 'game_err_3',
      gameType: ReelGameType.spotTheError,
      category: 'SPOT THE ERROR 🕵️',
      prompt: 'Find the mistake in this common phrase:',
      contextSituation: '"I look forward to hear from you."',
      options: ['I', 'look forward', 'to hear', 'from you'],
      correctOptionIndex: 2,
      nativeExplanations: {
        'Malayalam': 'തെറ്റ് "to hear" ആണ്! ശരിയായ ഉപയോഗം "to hearing" (-ing gerund) എന്നാണ്! ✉️',
        'Tamil': 'தவறு "to hear". "to hearing" என்பதே சரியான பயன்பாடு! ✉️',
        'Hindi': 'गलती "to hear" है। सही "to hearing" होता है! ✉️',
        'English': 'Error: "to hear". The phrasal verb "look forward to" takes a gerund: "to hearing". ✉️',
      },
      contextHint: 'Phrasal verb preposition + Gerund',
    ),

    // -------------------------------------------------------------
    // 4. PRO IDIOMS & SLANG DECRYPTER (Category: idiomDecrypter)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_idiom_1',
      gameType: ReelGameType.idiomDecrypter,
      category: 'SLANG & IDIOM 💡',
      prompt: 'What does "Bite the bullet" mean in real life?',
      contextSituation: '"I have to bite the bullet and tell my boss I resigned."',
      options: [
        'Face a difficult situation with courage 🦁',
        'Eat something metallic and dangerous ⚠️',
        'Shoot a gun at a target 🎯',
        'Refuse to speak in a meeting 🤐',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Bite the bullet" എന്നാൽ എത്ര ബുദ്ധിമുട്ടുള്ള കാര്യമാണെങ്കിലും ധൈര്യത്തോടെ നേരിടുക എന്നാണ് അർത്ഥം! 🦁',
        'Tamil': '"Bite the bullet" என்றால் கடினமான சூழ்நிலையை துணிச்சலுடன் எதிர்கொள்வது! 🦁',
        'Hindi': '"Bite the bullet" का अर्थ है किसी कठिन परिस्थिति का हिम्मत से सामना करना! 🦁',
        'English': '"Bite the bullet" means to bravely face an unpleasant or difficult situation that cannot be avoided. 🦁',
      },
      contextHint: 'Originated from soldiers biting a lead bullet during battlefield surgery',
    ),
    ReelGameCard(
      id: 'game_idiom_2',
      gameType: ReelGameType.idiomDecrypter,
      category: 'SLANG & IDIOM 💡',
      prompt: 'Someone says: "Let\'s break the ice!" What do they mean?',
      contextSituation: 'At the start of an English meetup when everyone is quiet and shy',
      options: [
        'Start conversation to ease tension & shyness 🧊',
        'Smash ice cubes into a drink 🥤',
        'Cancel the party and leave early 🚪',
        'Argue with someone loudly 🗣️',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Break the ice" എന്നാൽ തുടക്കത്തിലെ അപരിചിതത്വവും മടിയും മാറ്റി സംസാരിച്ചു തുടങ്ങുക എന്നാണ് അർത്ഥം! 🧊',
        'Tamil': '"Break the ice" என்றால் கூச்சத்தைப் போக்கி பேச்சைத் தொடங்குவது! 🧊',
        'Hindi': '"Break the ice" का अर्थ है झिझक तोड़कर बातचीत शुरू करना! 🧊',
        'English': '"Break the ice" means to do or say something that relieves tension and makes people feel comfortable talking. 🧊',
      },
      contextHint: 'Common icebreaker activities at conferences',
    ),
    ReelGameCard(
      id: 'game_idiom_3',
      gameType: ReelGameType.idiomDecrypter,
      category: 'SLANG & IDIOM 💡',
      prompt: 'What does "Spill the tea" mean among young native speakers?',
      contextSituation: '"Come on, what happened on your date? Spill the tea!"',
      options: [
        'Share the juicy gossip or secret details ☕',
        'Accidentally drop hot beverage on table 🍵',
        'Make tea for the guests 🫖',
        'Complain about poor restaurant service 📋',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Spill the tea" എന്നാൽ പുതിയ ഗോസിപ്പോ രസകരമായ വിശേഷങ്ങളോ തുറന്നു പറയുക എന്നാണ് അർത്ഥം! ☕',
        'Tamil': '"Spill the tea" என்றால் சுவாரஸ்யமான கிசுகிசுவை பகிர்ந்து கொள்வது! ☕',
        'Hindi': '"Spill the tea" का अर्थ है गरमा-गरम गपशप या राज़ बताना! ☕',
        'English': '"Spill the tea" (or just "the T") is modern slang meaning to share gossip, truth, or insider stories. ☕',
      },
      contextHint: 'T stands for Truth/Gossip in popular modern English slang',
    ),

    // -------------------------------------------------------------
    // 5. VOCABULARY MATCH (Category: vocabularyMatch)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_vocab_1',
      gameType: ReelGameType.vocabularyMatch,
      category: 'VOCAB POWER ⚡',
      prompt: 'Which word is the opposite (ANTONYM) of "METICULOUS"?',
      contextSituation: 'A meticulous person pays deep attention to every tiny detail',
      options: [
        'Careless & Sloppy ❌',
        'Detailed & Precise 🎯',
        'Punctual & Fast ⚡',
        'Polite & Kind 🌸',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Meticulous" എന്നാൽ അതീവ ശ്രദ്ധയുള്ളയാൾ. അതിന്റെ വിപരീതം (Opposite) "Careless & Sloppy" (അശ്രദ്ധൻ) ആണ്! ✅',
        'Tamil': '"Meticulous" என்றால் மிகுந்த கவனத்துடன் செயல்படுபவர். அதன் எதிர்ச்சொல் "Careless" (கவனக்குறைவு)! ✅',
        'Hindi': '"Meticulous" का अर्थ है बहुत सावधान। इसका विलोम "Careless" (लापरवाह) है! ✅',
        'English': '"Meticulous" means showing great attention to detail. Its opposite is "careless" or "sloppy". ✅',
      },
      contextHint: 'Opposite of being hyper-organized and precise',
    ),
    ReelGameCard(
      id: 'game_vocab_2',
      gameType: ReelGameType.vocabularyMatch,
      category: 'VOCAB POWER ⚡',
      prompt: 'Choose the word that means "Brief and clearly expressed":',
      contextSituation: '"His presentation was _____, lasting only 5 minutes but covering everything."',
      options: [
        'Concise 🎯',
        'Confusing 🌀',
        'Lengthy 📜',
        'Loud 📢',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Concise" എന്നാൽ ചുരുങ്ങിയ വാക്കുകളിൽ വ്യക്തമായി കാര്യങ്ങൾ പറയുക (Brief & clear) എന്നാണ്! 🎯',
        'Tamil': '"Concise" என்றால் சுருக்கமாகவும் தெளிவாகவும் இருப்பது! 🎯',
        'Hindi': '"Concise" का अर्थ है संक्षिप्त और स्पष्ट! 🎯',
        'English': '"Concise" means giving a lot of information clearly and in a few words. 🎯',
      },
      contextHint: 'Crucial word for resume writing and interview presentations',
    ),

    // -------------------------------------------------------------
    // 6. FLUENCY GAP-FILL (Category: gapFill)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_gap_1',
      gameType: ReelGameType.gapFill,
      category: 'DAILY GRAMMAR ⚡',
      prompt: 'If I _____ you, I would accept the job offer immediately.',
      options: ['were', 'was', 'am', 'will be'],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'സാങ്കൽപ്പിക അവസ്ഥ (Subjunctive mood) ആയതിനാൽ "If I were you" എന്നാണ് പറയേണ്ടത് ("was" അല്ല)! ✅',
        'Tamil': 'கற்பனை சூழ்நிலைக்கு (Subjunctive) "If I were you" என்றே வர வேண்டும்! ✅',
        'Hindi': 'काल्पनिक स्थिति (Subjunctive) में "If I were you" का प्रयोग होता है! ✅',
        'English': 'In unreal conditional sentences (Second Conditional), always use "were" with "I": "If I were you". ✅',
      },
      contextHint: 'Second conditional for hypothetical advice',
    ),
    ReelGameCard(
      id: 'game_gap_2',
      gameType: ReelGameType.gapFill,
      category: 'FLUENCY GAP-FILL 🚀',
      prompt: 'He succeeded _____ passing the IELTS exam on his first try.',
      options: ['in', 'to', 'for', 'with'],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Succeed" എന്ന വാക്കിന് ശേഷം "in + gerund (-ing)" വരും: "succeeded in passing" ✅',
        'Tamil': '"Succeed" உடன் "in" வர வேண்டும்: "succeeded in passing" ✅',
        'Hindi': '"Succeed" के साथ "in" आता है: "succeeded in passing" ✅',
        'English': 'The verb "succeed" collocates with the preposition "in": "succeed in doing something". ✅',
      },
      contextHint: 'Collocation: succeed + preposition',
    ),
    ReelGameCard(
      id: 'game_gap_3',
      gameType: ReelGameType.gapFill,
      category: 'COMMON PHRASE 💡',
      prompt: 'Please make yourself _____ home.',
      options: ['at', 'in', 'on', 'to'],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'അതിഥികളെ സ്വാഗതം ചെയ്യുമ്പോൾ പറയുന്ന ശൈലി: "Make yourself at home" (സ്വന്തം വീടുപോലെ കരുതുക) 🏡',
        'Tamil': 'விருந்தினர்களை வரவேற்கும் பயன்பாடு: "Make yourself at home" 🏡',
        'Hindi': 'अतिथियों के स्वागत का वाक्य: "Make yourself at home" 🏡',
        'English': '"Make yourself at home" is the customary welcoming phrase meaning relax as if you were in your own house. 🏡',
      },
      contextHint: 'Friendly hospitality phrase for visitors',
    ),

    // -------------------------------------------------------------
    // 7. COLLOCATION CLASH (Category: collocationClash)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_colloc_1',
      gameType: ReelGameType.collocationClash,
      category: 'NATURAL ENGLISH ⚔️',
      prompt: 'Which phrase is 100% natural and correct?',
      options: [
        'Make a mistake 🎯',
        'Do a mistake ❌',
        'Have a mistake ❌',
        'Build a mistake ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഇംഗ്ലീഷിൽ "Make a mistake" എന്നാണ് പറയുക ("Do a mistake" തെറ്റാണ്)! 🎯',
        'Tamil': 'ஆங்கிலத்தில் "Make a mistake" என்பதே சரியானது! 🎯',
        'Hindi': 'अंग्रेजी में "Make a mistake" कहा जाता है! 🎯',
        'English': 'Standard collocation: we always "make a mistake", never "do a mistake". 🎯',
      },
      contextHint: 'Classic Make vs Do pairing',
    ),
    ReelGameCard(
      id: 'game_colloc_2',
      gameType: ReelGameType.collocationClash,
      category: 'NATURAL ENGLISH ⚔️',
      prompt: 'How do native speakers describe very bad traffic?',
      options: [
        'Heavy traffic 🚗',
        'Strong traffic ❌',
        'Big traffic ❌',
        'Thick traffic ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ട്രാഫിക്കിനെ കുറിച്ച് പറയുമ്പോൾ "Heavy traffic" എന്നാണ് നാച്ചുറൽ ഇംഗ്ലീഷ്! 🚗',
        'Tamil': 'அதிக வாகன நெரிசலுக்கு "Heavy traffic" என்று கூறுவர்! 🚗',
        'Hindi': 'भारी जाम के लिए "Heavy traffic" का प्रयोग होता है! 🚗',
        'English': 'Traffic collocates with "heavy" or "light", not "strong" or "big". 🚗',
      },
      contextHint: 'Think of "heavy rain" and "heavy traffic"',
    ),
    ReelGameCard(
      id: 'game_colloc_3',
      gameType: ReelGameType.collocationClash,
      category: 'NATURAL ENGLISH ⚔️',
      prompt: 'Which request is spoken naturally worldwide?',
      options: [
        'Can you take a photo of us? 📸',
        'Can you click a photo of us? ❌',
        'Can you catch a photo of us? ❌',
        'Can you pull a photo of us? ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ആഗോളതലത്തിൽ ഫോട്ടോ എടുക്കാൻ ആവശ്യപ്പെടുമ്പോൾ "Take a photo" (അല്ലെങ്കിൽ Take a picture) എന്നാണ് പറയേണ്ടത്! 📸',
        'Tamil': 'புகைப்படம் எடுக்க "Take a photo" என்றே உலகளவில் சொல்வார்கள்! 📸',
        'Hindi': 'ग्लोबल इंग्लिश में "Take a photo" ही सही बोला जाता है! 📸',
        'English': 'Internationally, native speakers always say "take a photo/picture", whereas "click a photo" is regional Indian English. 📸',
      },
      contextHint: 'Standard international photographic collocation',
    ),

    // -------------------------------------------------------------
    // 8. PHONICS & SILENT LETTER TRAPS (Category: phonicsRiddle)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_phonics_1',
      gameType: ReelGameType.phonicsRiddle,
      category: 'SILENT LETTER TRAP 🤫',
      prompt: 'In which word is the letter "K" completely SILENT?',
      options: [
        'KNIFE 🔪',
        'KITCHEN 🍳',
        'KANGAROO 🦘',
        'KINGDOM 👑',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"KNIFE" എന്ന വാക്ക് "നൈഫ്" (/naɪf/) എന്നാണ് ഉച്ചരിക്കുന്നത്; "K" ശബ്ദമില്ലാത്ത സൈലന്റ് ലെറ്ററാണ്! 🔪',
        'Tamil': '"KNIFE" என்பதில் "K" உச்சரிக்கப்படுவதில்லை (நைஃப்)! 🔪',
        'Hindi': '"KNIFE" में "K" साइलेंट होता है, इसे "नाइफ" बोलते हैं! 🔪',
        'English': 'Whenever "K" precedes "N" at the start of a word (knife, knee, know, knot), the "K" is completely silent. 🔪',
      },
      contextHint: 'K + N combination at start of word',
    ),
    ReelGameCard(
      id: 'game_phonics_2',
      gameType: ReelGameType.phonicsRiddle,
      category: 'PRONUNCIATION RIDDLE 🎵',
      prompt: 'Which word perfectly RHYMES with "GREAT"?',
      options: [
        'EIGHT (Same /eɪt/ sound) 🎯',
        'MEAT (/iːt/) ❌',
        'SEAT (/iːt/) ❌',
        'BEAT (/iːt/) ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Great" (/ɡreɪt/) എന്ന വാക്കിന്റെ അതേ സ്വരമാണ് "Eight" (/eɪt/) എന്ന വാക്കിന്. Meat, Seat എന്നിവ വ്യത്യസ്ത സ്വരങ്ങളാണ്! 🎵',
        'Tamil': '"Great" மற்றும் "Eight" இரண்டும் ஒரே ஓசையைக் கொண்டவை (/eɪt/)! 🎵',
        'Hindi': '"Great" और "Eight" की ध्वनि एक जैसी (/eɪt/) होती है! 🎵',
        'English': '"Great" and "Eight" share the /eɪt/ vowel sound, while meat/seat/beat use the /iː/ vowel! 🎵',
      },
      contextHint: 'Listen carefully to the vowel sound /eɪt/',
    ),
    ReelGameCard(
      id: 'game_phonics_3',
      gameType: ReelGameType.phonicsRiddle,
      category: 'SILENT LETTER TRAP 🤫',
      prompt: 'Which word has a SILENT letter "W"?',
      options: [
        'WRIST (Silent W) ⌚',
        'WATER 💧',
        'WINTER ❄️',
        'WINDOW 🪟',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"WRIST" എന്ന വാക്ക് "റിസ്റ്റ്" (/rɪst/) എന്നാണ് പറയുന്നത്. "W" സൈലന്റാണ്! ⌚',
        'Tamil': '"WRIST" என்பதில் "W" அமைதியாக இருக்கும் (ரிஸ்ட்)! ⌚',
        'Hindi': '"WRIST" में "W" साइलेंट होता है (रिस्ट)! ⌚',
        'English': 'In English, "WR" at the beginning of words (wrist, write, wrong, wrap) always drops the "W" sound. ⌚',
      },
      contextHint: 'WR combination rule',
    ),

    // -------------------------------------------------------------
    // 9. PAST TENSE SPEED BLITZ (Category: tenseShift)
    // -------------------------------------------------------------
    ReelGameCard(
      id: 'game_tense_1',
      gameType: ReelGameType.tenseShift,
      category: 'PAST TENSE BLITZ ⏳',
      prompt: 'What is the past tense (V2) of "FLY"?',
      options: [
        'Flew 🦅',
        'Flied ❌',
        'Flown (That is V3) ❌',
        'Flyed ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Fly" എന്നതിന്റെ ഭൂതകാലം (Past tense) "Flew" ആണ്. "Flown" എന്നത് V3 (Past Participle) ആണ്! 🦅',
        'Tamil': '"Fly" என்பதன் இறந்த காலம் "Flew"! 🦅',
        'Hindi': '"Fly" का past tense "Flew" होता है! 🦅',
        'English': 'Irregular verb pattern: Fly (V1) -> Flew (V2) -> Flown (V3). 🦅',
      },
      contextHint: 'Irregular vowel shift to "-ew"',
    ),
    ReelGameCard(
      id: 'game_tense_2',
      gameType: ReelGameType.tenseShift,
      category: 'PAST TENSE BLITZ ⏳',
      prompt: 'What is the past tense (V2) of "BRING"?',
      options: [
        'Brought 📦',
        'Bought (That means Buy!) ❌',
        'Brang ❌',
        'Bringed ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Bring" (കൊണ്ടുവരിക) എന്നതിന്റെ ഭൂതകാലം "Brought" ആണ്. "Bought" എന്നാൽ "Buy" (വാങ്ങി) എന്നാണർത്ഥം! 📦',
        'Tamil': '"Bring" என்பதன் இறந்த காலம் "Brought"! (Bought என்பது Buy-ன் இறந்த காலம்) 📦',
        'Hindi': '"Bring" का past tense "Brought" होता है ("Bought" Buy का होता है)! 📦',
        'English': 'Bring -> Brought. Watch out: "Bought" is the past of "Buy"! 📦',
      },
      contextHint: 'Don\'t confuse Bring (Brought) with Buy (Bought)',
    ),
    ReelGameCard(
      id: 'game_tense_3',
      gameType: ReelGameType.tenseShift,
      category: 'PAST TENSE BLITZ ⏳',
      prompt: 'What is the past tense (V2) of "WEAR"?',
      options: [
        'Wore 👔',
        'Weared ❌',
        'Worn (That is V3) ❌',
        'Ware ❌',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Wear" (ധരിക്കുക) എന്നതിന്റെ ഭൂതകാലം "Wore" ആണ്! 👔',
        'Tamil': '"Wear" என்பதன் இறந்த காலம் "Wore"! 👔',
        'Hindi': '"Wear" का past tense "Wore" होता है! 👔',
        'English': 'Wear (V1) -> Wore (V2) -> Worn (V3). Never say "weared"! 👔',
      },
      contextHint: 'Irregular past: Wear -> Wore',
    ),
  ];

  /// 🧸 Kids Dedicated Communication & Chat Comeback Games (Prioritizes unviewed cards)
  static List<ReelGameCard> getKidsCommunicationGames({int count = 8}) {
    final allCards = List<ReelGameCard>.from(_curatedKidsCommunicationGames);
    final unseen = allCards.where((g) => !_viewedGameIds.contains(g.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = allCards.where((g) => _viewedGameIds.contains(g.id)).toList();
    seen.shuffle(_random);
    final combined = [...unseen, ...seen];
    if (combined.length >= count) return combined.take(count).toList();

    while (combined.length < count) {
      combined.add(_generateDynamicKidChatGame(combined.length + 1));
    }
    return combined.take(count).toList();
  }

  /// 🌟 Dynamically generates endless variety of English challenges for kids
  static ReelGameCard _generateDynamicKidChatGame(int seed) {
    final companions = [
      {'name': 'Sparky Tiger', 'avatar': '🐯', 'role': 'Phonics Buddy'},
      {'name': 'Pandy Panda', 'avatar': '🐼', 'role': 'Manners Guide'},
      {'name': 'Bouncy Bunny', 'avatar': '🐰', 'role': 'Story Explorer'},
      {'name': 'King Lion', 'avatar': '🦁', 'role': 'Kingdom Sovereign'},
      {'name': 'Puppy Max', 'avatar': '🐶', 'role': 'Playground Scout'},
    ];
    final comp = companions[seed % companions.length];
    final dynId = 'dyn_kid_chat_${DateTime.now().millisecondsSinceEpoch}_$seed';

    return ReelGameCard(
      id: dynId,
      gameType: ReelGameType.smartReply,
      category: 'ANIMAL BUDDY CHAT 💬',
      speakerName: comp['name'],
      speakerAvatar: comp['avatar'],
      speakerRole: comp['role'],
      contextSituation: '${comp['name']} ${comp['avatar']} sent you a friendly message',
      prompt: 'Hello my awesome friend! Are you having fun learning English with me today?',
      options: [
        'Yes, I love learning with you! It is super fun! 🌟🎉',
        'I am not here today.',
        'Learning is only for grown-ups.',
        'No, go away.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കൂട്ടുകാരോട് സന്തോഷത്തോടെ "Yes, I love learning with you! It is super fun!" എന്ന് ആത്മവിശ്വാസത്തോടെ പറയാം! 🌟💖',
        'Tamil': 'நண்பர்களிடம் உற்சாகமாக "Yes, I love learning with you!" என்று கூறலாம்! 🌟💖',
        'Hindi': 'दोस्त से उत्साहपूर्वक कहें "Yes, I love learning with you! It is super fun!" 🌟💖',
        'English': 'Positive communication! Expressing joy and enthusiasm makes conversational English delightful! 🌟💖',
      },
      contextHint: 'Friendly enthusiasm and joy',
      funnyNote: 'Animal buddies love chatting with you! 🐾',
    );
  }

  /// 🗣️ Level-Matched Spoken English Communication & Dialogue Games for Adults (User Audio Directive)
  /// Matches the learner's day/level:
  /// - Beginner (Day 1-15): Basic introductions, greetings, everyday courtesies, simple questions
  /// - Intermediate (Day 16-45): Workplace, cafe, phone calls, social opinions, polite requests
  /// - Advanced (Day 46-90): Diplomatic business comebacks, negotiations, strategic communication
  static List<ReelGameCard> getSpokenCommunicationGames({
    required int userLevel,
    int count = 8,
  }) {
    final allCards = List<ReelGameCard>.from(_curatedSpokenCommunicationGames);

    // Filter cards matching user level tier
    final levelMatched = allCards
        .where((g) => g.minLevel <= userLevel && userLevel <= g.maxLevel)
        .toList();
    final candidatePool = levelMatched.isNotEmpty ? levelMatched : allCards;

    final unseen = candidatePool.where((g) => !_viewedGameIds.contains(g.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = candidatePool.where((g) => _viewedGameIds.contains(g.id)).toList();
    seen.shuffle(_random);
    final combined = [...unseen, ...seen];
    if (combined.length >= count) return combined.take(count).toList();

    while (combined.length < count) {
      combined.add(_generateDynamicSpokenGame(combined.length + 1, userLevel));
    }
    return combined.take(count).toList();
  }

  static ReelGameCard _generateDynamicSpokenGame(int seed, int userLevel) {
    final dynId = 'dyn_spoken_${DateTime.now().millisecondsSinceEpoch}_$seed';
    if (userLevel <= 15) {
      return ReelGameCard(
        id: dynId,
        gameType: ReelGameType.smartReply,
        category: 'DAILY CHAT 💬',
        speakerName: 'Priya 👩‍💼',
        speakerAvatar: '👩‍💼',
        speakerRole: 'Colleague',
        prompt: 'Good morning! Did you catch the morning news today?',
        options: [
          'Good morning! No, I did not get time to read it. 📰',
          'Morning is good, I don\'t know news.',
          'News is not caught by me.',
          'I am not news reader.',
        ],
        correctOptionIndex: 0,
        nativeExplanations: {
          'Malayalam': 'ലളിതമായി മറുപടി പറയാൻ "No, I did not get time to read it" എന്ന് സ്വാഭാവികമായി പറയുക! 📰',
          'Tamil': 'இயல்பாக "No, I did not get time to read it" என்று கூறலாம்! 📰',
          'Hindi': 'सहज रूप से कहें "No, I did not get time to read it" 📰',
          'English': 'Natural everyday spoken reply: "No, I didn\'t get time to read it."',
        },
        contextHint: 'Natural morning courtesy',
        minLevel: 1,
        maxLevel: 15,
      );
    } else {
      return ReelGameCard(
        id: dynId,
        gameType: ReelGameType.smartReply,
        category: 'WORKPLACE DIALOGUE 💼',
        speakerName: 'Arun 👨‍💻',
        speakerAvatar: '👨‍💻',
        speakerRole: 'Project Lead',
        prompt: 'Could we wrap up this discussion and send the final notes?',
        options: [
          'Sure, I will summarize our action items and email everyone! ✉️',
          'Yes, finish discussion now.',
          'Notes will put by me soon.',
          'I am going to wrap it quickly.',
        ],
        correctOptionIndex: 0,
        nativeExplanations: {
          'Malayalam': 'മീറ്റിംഗ് കഴിഞ്ഞ് നോട്ടുകൾ അയക്കാൻ "I will summarize our action items and email everyone" എന്ന് പ്രൊഫഷണലായി പറയുക! ✉️',
          'Tamil': '"I will summarize our action items and email everyone" என்று தொழில்முறையாக கூறவும்! ✉️',
          'Hindi': '"I will summarize our action items and email everyone" एक पेशेवर उत्तर है! ✉️',
          'English': 'Polite professional summary response.',
        },
        contextHint: 'Professional meeting follow-up',
        minLevel: 16,
        maxLevel: 90,
      );
    }
  }

  // =========================================================================
  // 🗣️ CURATED SPOKEN ENGLISH COMMUNICATION DATASET (30+ Level-Matched Cards)
  // =========================================================================
  static const List<ReelGameCard> _curatedSpokenCommunicationGames = [
    // --- TIER 1: BEGINNER (Days 1 - 15) ---
    ReelGameCard(
      id: 'spoken_chat_name',
      gameType: ReelGameType.smartReply,
      category: 'DAILY INTRODUCTIONS 👋',
      speakerName: 'Rahul 👨‍💼',
      speakerAvatar: '👨‍💼',
      speakerRole: 'New Colleague',
      prompt: 'Hi there! I am new to this building. What is your name?',
      options: [
        'Hi! My name is Rahul, nice to meet you! 😊',
        'I am having name Rahul.',
        'My name Rahul is.',
        'Name is my Rahul.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ആദ്യമായി പേര് പറയുമ്പോൾ "My name is..." അല്ലെങ്കിൽ "I am..." എന്ന് ലളിതമായി പറയുക! 😊',
        'Tamil': 'பெயரைக் கூறும்போது "My name is..." அல்லது "I am..." என எளிமையாக கூறவும்! 😊',
        'Hindi': 'नाम बताते समय "My name is..." या "I am..." कहना सबसे सही तरीका है! 😊',
        'English': 'Standard natural English introduction: "My name is..." or "I am..."',
      },
      contextHint: 'Friendly personal introduction',
      funnyNote: 'First impressions matter! Smile and say your name clearly! 🌟',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_origin',
      gameType: ReelGameType.smartReply,
      category: 'MEETING PEOPLE 🌴',
      speakerName: 'Ananya 👩‍💻',
      speakerAvatar: '👩‍💻',
      speakerRole: 'Tech Lead',
      prompt: 'Your accent sounds so friendly! Where are you from?',
      options: [
        'I am from Kerala, India! 🌴',
        'I from Kerala coming.',
        'Kerala is my from place.',
        'I am in Kerala from.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'സ്വദേശം പറയുമ്പോൾ "I am from..." അല്ലെങ്കിൽ "I come from..." എന്ന് ഉപയോഗിക്കുക! 🌴',
        'Tamil': 'சொந்த ஊரை கூற "I am from..." என்று சொல்லுங்கள்! 🌴',
        'Hindi': 'अपने स्थान के बारे में बताने के लिए "I am from..." कहें! 🌴',
        'English': 'Use "I am from [Place]" to state your origin naturally.',
      },
      contextHint: 'Stating where you are from',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_how_are_you',
      gameType: ReelGameType.smartReply,
      category: 'MORNING GREETINGS ☕',
      speakerName: 'David 👨‍💼',
      speakerAvatar: '👨‍💼',
      speakerRole: 'Manager',
      prompt: 'Good morning! How are you doing today?',
      options: [
        'I am doing great, thank you! How about you? ☕',
        'I am doing goodly today.',
        'Today is doing me fine.',
        'I am fine doing.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"How are you doing?" എന്ന് ചോദിച്ചാൽ "I am doing great, thank you! How about you?" എന്ന് തിരിച്ചു ചോദിക്കുന്നത് സ്വാഭാവിക ശൈലിയാണ്! ☕',
        'Tamil': '"I am doing great, thank you! How about you?" என கேட்பது மரியாதையானது! ☕',
        'Hindi': 'जवाब में "I am doing great, thank you! How about you?" पूछना शिष्टाचार है! ☕',
        'English': 'Natural response acknowledging the question and asking back politely.',
      },
      contextHint: 'Warm polite morning conversation',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_water',
      gameType: ReelGameType.smartReply,
      category: 'EVERYDAY COURTESY 💧',
      speakerName: 'Priya 👩‍🎓',
      speakerAvatar: '👩‍🎓',
      speakerRole: 'Classmate',
      prompt: 'Could you please pass me that water bottle on the table?',
      options: [
        'Sure! Here you go! 💧',
        'Take water go.',
        'Water is giving to you.',
        'Yes, I am passing.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ആരെങ്കിലും ചോദിച്ച വസ്തു നൽകി കൊടുക്കുമ്പോൾ "Here you go!" അല്ലെങ്കിൽ "Here it is!" എന്ന് പറയുക! 💧',
        'Tamil': 'பொருளை கொடுக்கும்போது "Here you go!" என்று கூறுங்கள்! 💧',
        'Hindi': 'चीज देते समय "Here you go!" कहना सबसे स्वाभाविक तरीका है! 💧',
        'English': 'Standard idiom when handing something over to someone: "Here you go!"',
      },
      contextHint: 'Handing an object over politely',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_breakfast',
      gameType: ReelGameType.smartReply,
      category: 'CASUAL CHIT-CHAT 🥪',
      speakerName: 'Alex 👨‍💻',
      speakerAvatar: '👨‍💻',
      speakerRole: 'Coworker',
      prompt: 'It is already 11 AM! Did you have breakfast today?',
      options: [
        'Yes, I had breakfast around 9 AM! 🥪',
        'Yes, I was eat breakfast.',
        'I did have taken breakfast.',
        'Yes, breakfast has eaten.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കഴിഞ്ഞ കാര്യത്തെക്കുറിച്ച് പറയുമ്പോൾ സിമ്പിൾ പാസ്റ്റ് "I had breakfast" അല്ലെങ്കിൽ "I ate breakfast" എന്ന് പറയുക! 🥪',
        'Tamil': 'கடந்த காலத்தை குறிப்பிட "I had breakfast" என்று கூறுங்கள்! 🥪',
        'Hindi': 'भूतकाल के लिए "I had breakfast" का प्रयोग करें! 🥪',
        'English': 'Simple past tense: "I had breakfast" or "I ate breakfast."',
      },
      contextHint: 'Past action answer',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_help_thanks',
      gameType: ReelGameType.smartReply,
      category: 'POLITE GRATITUDE 🙏',
      speakerName: 'Sarah 👩‍⚕️',
      speakerAvatar: '👩‍⚕️',
      speakerRole: 'Doctor',
      prompt: 'Thank you so much for helping me carry these medical files!',
      options: [
        'You are very welcome! Happy to help! 😊',
        'No thanks needed.',
        'Welcome to you.',
        'It is not problem.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Thank you" എന്ന് പറഞ്ഞാൽ മാന്യമായി "You are very welcome!" അല്ലെങ്കിൽ "Happy to help!" എന്ന് മറുപടി നൽകാം! 😊',
        'Tamil': 'நன்றிக்கு பதிலாக "You are very welcome!" அல்லது "Happy to help!" எனலாம்! 😊',
        'Hindi': 'धन्यवाद का उत्तर "You are very welcome!" कहकर दें! 😊',
        'English': 'Best natural reply to thank you: "You are very welcome!"',
      },
      contextHint: 'Graceful reply to gratitude',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_restroom',
      gameType: ReelGameType.smartReply,
      category: 'GIVING DIRECTIONS 🚻',
      speakerName: 'Tourist 🎒',
      speakerAvatar: '🎒',
      speakerRole: 'Visitor',
      prompt: 'Excuse me, could you tell me where the restroom is?',
      options: [
        'It is down the hallway on your left! 🚻',
        'Go left hallway restroom.',
        'Restroom is there going.',
        'Left side hall restroom is.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'വഴി പറഞ്ഞു കൊടുക്കുമ്പോൾ "It is down the hallway on your left" എന്ന് വ്യക്തമായി പറയുക! 🚻',
        'Tamil': 'வழிகாட்டும்போது "It is down the hallway on your left" என்று தெளிவாக சொல்லுங்கள்! 🚻',
        'Hindi': 'दिशा बताते समय कहें "It is down the hallway on your left"! 🚻',
        'English': 'Clear directional phrase: "It is down the hallway on your left."',
      },
      contextHint: 'Clear polite directions',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_apology_late',
      gameType: ReelGameType.smartReply,
      category: 'HANDLING APOLOGIES 🤝',
      speakerName: 'Vikram 👨‍💼',
      speakerAvatar: '👨‍💼',
      speakerRole: 'Team Member',
      prompt: 'I am so sorry I was ten minutes late to our study group!',
      options: [
        'No worries at all! We just started reviewing chapter 2. 🤝',
        'Don\'t be sorry again.',
        'Late is okay for me.',
        'No issue is there.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ആരെങ്കിലും വൈകിയതിന് ക്ഷമ ചോദിച്ചാൽ "No worries at all!" അല്ലെങ്കിൽ "That is totally fine!" എന്ന് സൗഹൃദത്തോടെ മറുപടി നൽകാം! 🤝',
        'Tamil': 'மன்னிப்பு கேட்கும்போது "No worries at all!" என்று நட்புணர்வை காட்டுங்கள்! 🤝',
        'Hindi': '"No worries at all!" कहकर सामने वाले को सहज महसूस कराएं! 🤝',
        'English': '"No worries at all" graciously diffuses an apology.',
      },
      contextHint: 'Gracious friendly response',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_coffee_preference',
      gameType: ReelGameType.smartReply,
      category: 'CAFE & ORDERING ☕',
      speakerName: 'Barista ☕',
      speakerAvatar: '☕',
      speakerRole: 'Cafe Host',
      prompt: 'Welcome! Would you prefer tea or coffee this morning?',
      options: [
        'I would prefer a hot coffee with milk, please! ☕',
        'Coffee is my like.',
        'I like to drink coffee please.',
        'Coffee I am taking.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഓർഡർ ചെയ്യുമ്പോൾ "I would prefer..." അല്ലെങ്കിൽ "I would like..." എന്ന് മാന്യമായി ഉപയോഗിക്കുക! ☕',
        'Tamil': 'ஆர்டர் செய்யும்போது "I would prefer..." என்று நாகரீகமாக கூறுங்கள்! ☕',
        'Hindi': 'पसंद बताने के लिए "I would prefer..." कहना सबसे विनम्र है! ☕',
        'English': '"I would prefer [Item], please" is the standard polite order structure.',
      },
      contextHint: 'Polite ordering expression',
      minLevel: 1,
      maxLevel: 15,
    ),
    ReelGameCard(
      id: 'spoken_chat_time',
      gameType: ReelGameType.smartReply,
      category: 'ASKING THE TIME ⏰',
      speakerName: 'Commuter ⌚',
      speakerAvatar: '⌚',
      speakerRole: 'Metro Passenger',
      prompt: 'Excuse me, do you have the time by any chance?',
      options: [
        'Yes, it is exactly 4:15 PM! ⏰',
        'Yes, time is with me.',
        'I have time now.',
        'Clock is 4:15.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Do you have the time?" എന്നാൽ "സമയം എത്രയായി?" എന്നാണ് അർത്ഥം! "Yes, it is 4:15 PM" എന്ന് പറയുക! ⏰',
        'Tamil': '"Do you have the time?" என்றால் நேரம் என்ன என்று அர்த்தம்! ⏰',
        'Hindi': '"Do you have the time?" का मतलब समय पूछना है! "It is 4:15 PM" कहें! ⏰',
        'English': '"Do you have the time?" means "What time is it?". Answer with the current time.',
      },
      contextHint: 'Understanding common idiomatic time inquiries',
      minLevel: 1,
      maxLevel: 15,
    ),

    // --- TIER 2: INTERMEDIATE (Days 16 - 45) ---
    ReelGameCard(
      id: 'spoken_chat_reschedule',
      gameType: ReelGameType.smartReply,
      category: 'WORKPLACE SCHEDULING 📅',
      speakerName: 'Meera 👩‍💼',
      speakerAvatar: '👩‍💼',
      speakerRole: 'Project Manager',
      prompt: 'Our 2 PM meeting conflicts with a client demo. Could we reschedule to 3:30 PM?',
      options: [
        'Sure, 3:30 PM works perfectly for me! 📅',
        'Yes, I will work that time.',
        '3:30 PM is my working time.',
        'Time is OK for work.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'സമയം സൗകര്യപ്രദമാണെന്ന് പറയാൻ "3:30 PM works perfectly for me" എന്ന സ്വാഭാവിക പ്രയോഗം ഉപയോഗിക്കുക! 📅',
        'Tamil': '"3:30 PM works perfectly for me" என்று அலுவலக ரீதியாக கூறலாம்! 📅',
        'Hindi': '"3:30 PM works perfectly for me" कहना सबसे पेशेवर तरीका है! 📅',
        'English': '"[Time] works perfectly for me" is the most natural way to accept a meeting time.',
      },
      contextHint: 'Accepting a revised schedule naturally',
      minLevel: 16,
      maxLevel: 45,
    ),
    ReelGameCard(
      id: 'spoken_chat_phone_message',
      gameType: ReelGameType.smartReply,
      category: 'PHONE ETIQUETTE 📞',
      speakerName: 'Receptionist ☎️',
      speakerAvatar: '☎️',
      speakerRole: 'Office Front Desk',
      prompt: 'I am afraid Mr. John is in a conference right now. May I take a message?',
      options: [
        'Yes please, could you ask him to call me back when he is free? 📞',
        'Yes, take my call back.',
        'Tell him to call me fast.',
        'Message is please call me.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഫോണിൽ സന്ദേശം നൽകുമ്പോൾ "Could you ask him to call me back when he is free?" എന്ന് മാന്യമായി പറയുക! 📞',
        'Tamil': 'போன் காலில் "Could you ask him to call me back" என்று நாகரீகமாக தெரிவிக்கவும்! 📞',
        'Hindi': 'मैसेज छोड़ते समय "Could you ask him to call me back" कहें! 📞',
        'English': 'Professional phone message request: "Could you ask him to call me back..."',
      },
      contextHint: 'Polite telephone message request',
      minLevel: 16,
      maxLevel: 45,
    ),
    ReelGameCard(
      id: 'spoken_chat_feedback',
      gameType: ReelGameType.smartReply,
      category: 'CONSTRUCTIVE FEEDBACK 💡',
      speakerName: 'Sanjay 👨‍💻',
      speakerAvatar: '👨‍💻',
      speakerRole: 'Designer',
      prompt: 'I just finished the first slide deck draft. What do you think?',
      options: [
        'The flow is great, but let us simplify slide 4 to make it punchier! 💡',
        'Slide 4 is very big words.',
        'I am thinking slide 4 is not good.',
        'Presentation is like that only.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'പോസിറ്റീവ് ആയ കാര്യങ്ങൾ അഭിനന്ദിച്ച ശേഷം തിരുത്തലുകൾ നിർദ്ദേശിക്കുന്നതാണ് മികച്ച രീതി (The flow is great, but let us...)! 💡',
        'Tamil': 'முதலில் பாராட்டி பிறகு மாற்றங்களை பரிந்துரைப்பது சிறந்த அணுகுமுறை! 💡',
        'Hindi': 'पहले तारीफ करें फिर सुधार का सुझाव दें (Sandwich feedback method)! 💡',
        'English': 'Constructive feedback acknowledges strong points before suggesting improvements.',
      },
      contextHint: 'Diplomatic constructive feedback',
      minLevel: 16,
      maxLevel: 45,
    ),
    ReelGameCard(
      id: 'spoken_chat_volume',
      gameType: ReelGameType.smartReply,
      category: 'CONSIDERATE SPEAKING 🎧',
      speakerName: 'Desk Neighbor 💻',
      speakerAvatar: '💻',
      speakerRole: 'Coworker',
      prompt: 'Would you mind turning down the speaker volume just a little bit?',
      options: [
        'Not at all, apologies for that! I will use headphones. 🎧',
        'Yes, I mind.',
        'Volume is not loud.',
        'I am decreasing it now only.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Would you mind...?" എന്ന് ചോദിച്ചാൽ "എനിക്ക് ബുദ്ധിമുട്ടില്ല" എന്ന് പറയാൻ "Not at all!" എന്ന് മറുപടി നൽകുക! 🎧',
        'Tamil': '"Would you mind...?" என்பதற்கு "எனக்கு எந்த ஆட்சேபனையும் இல்லை" என கூற "Not at all!" என தொடங்குங்கள்! 🎧',
        'Hindi': '"Would you mind...?" का विनम्र उत्तर "Not at all" से शुरू होता है! 🎧',
        'English': 'Answering "Not at all" means you are happy to comply with the request.',
      },
      contextHint: 'Agreeing to a polite request',
      minLevel: 16,
      maxLevel: 45,
    ),
    ReelGameCard(
      id: 'spoken_chat_decline_lunch',
      gameType: ReelGameType.smartReply,
      category: 'POLITE REFUSAL 🥗',
      speakerName: 'Kavita 👩‍🔬',
      speakerAvatar: '👩‍🔬',
      speakerRole: 'Team Mate',
      prompt: 'A few of us are heading to the cafeteria for lunch. Care to join?',
      options: [
        'I would love to, but I have a client call in 15 minutes! Next time for sure! 🥗',
        'No, I am not eating with you.',
        'I am having prior work today.',
        'Lunch is not free for me.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ക്ഷണം നിരസിക്കുമ്പോൾ വിഷമം തോന്നാത്ത രീതിയിൽ "I would love to, but... Next time for sure!" എന്ന് മറുപടി നൽകുക! 🥗',
        'Tamil': 'அழைப்பை நாகரீகமாக மறுக்க "I would love to, but... Next time for sure!" எனலாம்! 🥗',
        'Hindi': 'शालीनता से मना करने के लिए "I would love to, but... Next time for sure!" कहें! 🥗',
        'English': 'Politely declining invitations involves appreciating the invite and giving a brief reason.',
      },
      contextHint: 'Soft, polite decline of an invitation',
      minLevel: 16,
      maxLevel: 45,
    ),
    ReelGameCard(
      id: 'spoken_chat_clarify',
      gameType: ReelGameType.smartReply,
      category: 'SEEKING CLARITY 🎯',
      speakerName: 'Director 👔',
      speakerAvatar: '👔',
      speakerRole: 'Executive',
      prompt: 'We need to streamline the downstream pipeline before the third quarter.',
      options: [
        'Could you please elaborate on which specific deliverables we should prioritize? 🎯',
        'What are you talking about?',
        'I did not get your meaning.',
        'Say again please.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'വ്യക്തത കുറവുള്ളപ്പോൾ "Could you please elaborate on...?" എന്ന് ചോദിക്കുന്നത് ആത്മവിശ്വാസമുള്ള ശൈലിയാണ്! 🎯',
        'Tamil': 'விளக்கம் கேட்க "Could you please elaborate on..." என்பது சரியான முறை! 🎯',
        'Hindi': 'विस्तार से समझने के लिए "Could you please elaborate on...?" पूछें! 🎯',
        'English': '"Could you please elaborate on..." is executive and polished.',
      },
      contextHint: 'Professional inquiry for more details',
      minLevel: 16,
      maxLevel: 45,
    ),

    // --- TIER 3: ADVANCED (Days 46 - 90) ---
    ReelGameCard(
      id: 'spoken_chat_deadline_negotiation',
      gameType: ReelGameType.smartReply,
      category: 'STRATEGIC DIPLOMACY ⚖️',
      speakerName: 'VP Product 💼',
      speakerAvatar: '💼',
      speakerRole: 'Vice President',
      prompt: 'The client wants the entire release date moved up by two weeks! Can we deliver?',
      options: [
        'We can achieve that if we prioritize the core MVP features and defer the secondary add-ons. ⚖️',
        'Tell them it is completely impossible.',
        'We will work all night without sleep.',
        'Client is always changing their mind.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'മുഴുവൻ കാര്യവും നിഷേധിക്കുന്നതിന് പകരം, സാധ്യമായ പരിഹാരം നിർദ്ദേശിക്കുക (We can achieve that if we prioritize...)! ⚖️',
        'Tamil': 'நேரடியாக மறுக்காமல், சாத்தியமான மாற்று வழியை முன்மொழியுங்கள்! ⚖️',
        'Hindi': 'नकारने के बजाय व्यावहारिक समाधान पेश करें! ⚖️',
        'English': 'Executive trade-off negotiation: scope vs. timeline.',
      },
      contextHint: 'Constructive trade-off negotiation',
      minLevel: 46,
      maxLevel: 90,
    ),
    ReelGameCard(
      id: 'spoken_chat_disagreement',
      gameType: ReelGameType.smartReply,
      category: 'RESPECTFUL DISSENT 📊',
      speakerName: 'Senior Architect 🏛️',
      speakerAvatar: '🏛️',
      speakerRole: 'Principal Engineer',
      prompt: 'I believe we should discard the old architecture and rebuild from scratch immediately.',
      options: [
        'I understand your perspective; however, a gradual migration would carry far less risk for existing users. 📊',
        'You are completely wrong about this.',
        'I don\'t agree with your thinking at all.',
        'Rebuilding is a terrible idea.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'വിയോജിപ്പ് പ്രകടിപ്പിക്കുമ്പോൾ മറ്റൊരാളുടെ കാഴ്ചപ്പാടിനെ അംഗീകരിച്ച് ബദൽ നിർദ്ദേശം വെക്കുക (I understand your perspective; however...)! 📊',
        'Tamil': 'எதிர்க்கருத்தை தெரிவிக்க "I understand your perspective; however..." என தொடங்குவது சிறந்த தலைமைப் பண்பு! 📊',
        'Hindi': 'सहमति-असहमति को संतुलित तरीके से पेश करें! 📊',
        'English': 'Diplomatic disagreement acknowledging other viewpoints first.',
      },
      contextHint: 'Diplomatic professional disagreement',
      minLevel: 46,
      maxLevel: 90,
    ),
  ];
  static const List<ReelGameCard> _curatedKidsCommunicationGames = [
    // --- 1. SHARING CRAYONS (Sparky Tiger) ---
    ReelGameCard(
      id: 'kid_chat_crayons_1',
      gameType: ReelGameType.smartReply,
      category: 'SHARING IS CARING 🎨',
      speakerName: 'Sparky Tiger',
      speakerAvatar: '🐯',
      speakerRole: 'Phonics Buddy',
      contextSituation: 'Sparky reaches towards your art kit while coloring a jungle tree',
      prompt: 'Hey buddy! Can I borrow your blue coloring pencil for a minute?',
      options: [
        'Sure! Here you go, buddy! ✏️✨',
        'No way, blue is my secret color!',
        'Pencils are made of wood.',
        'I do not speak to tigers.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കൂട്ടുകാരുമായി സന്തോഷത്തോടെ പങ്കുവെക്കാൻ "Sure! Here you go, buddy!" എന്ന് മാന്യമായി പറയാം! 🎨💖',
        'Tamil': 'நண்பர்களுடன் பகிர்ந்துகொள்ள "Sure! Here you go, buddy!" என்று அன்பாக கூறலாம்! 🎨💖',
        'Hindi': 'दोस्तों के साथ बांटने के लिए "Sure! Here you go, buddy!" कहना सबसे अच्छा है! 🎨💖',
        'English': 'Polite sharing with friends! Saying "Sure, here you go!" makes everyone happy and builds great friendship! 🎨💖',
      },
      contextHint: 'Polite sharing formula: "Sure, here you go!"',
      funnyNote: 'Sharing makes coloring twice as fun! 🎨',
    ),

    // --- 2. DROPPED ICE CREAM (Pandy Panda) ---
    ReelGameCard(
      id: 'kid_chat_icecream_2',
      gameType: ReelGameType.smartReply,
      category: 'EMPATHY & KINDNESS 🍦',
      speakerName: 'Pandy Panda',
      speakerAvatar: '🐼',
      speakerRole: 'Manners Guide',
      contextSituation: 'Pandy accidentally dropped his strawberry cone on the playground grass',
      prompt: 'Oh no! My ice cream fell on the grass! 😢🍦',
      options: [
        'Don\'t worry, Pandy! We can share mine! 🍦💖',
        'Haha! You are clumsy!',
        'Grass likes strawberry flavor.',
        'Go buy ten more.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'സങ്കടപ്പെട്ടിരിക്കുന്ന കൂട്ടുകാരനെ ആശ്വസിപ്പിക്കാൻ "Don\'t worry, we can share mine!" എന്ന് പറയുക! 🍦💖',
        'Tamil': 'வருத்தப்படும் நண்பருக்கு "Don\'t worry, we can share mine!" என்று ஆறுதல் கூறலாம்! 🍦💖',
        'Hindi': 'दुखी दोस्त को सहारा देने के लिए कहें "Don\'t worry, we can share mine!" 🍦💖',
        'English': 'Kindness matters! Cheering up a friend with "Don\'t worry, we can share mine!" shows real caring. 🍦💖',
      },
      contextHint: 'Comforting an upset friend with sharing',
      funnyNote: 'Kind words taste sweeter than ice cream! 🍨',
    ),

    // --- 3. PLAYGROUND RACE (Bouncy Bunny) ---
    ReelGameCard(
      id: 'kid_chat_playground_race_3',
      gameType: ReelGameType.smartReply,
      category: 'PLAYGROUND ENERGY 🏁',
      speakerName: 'Bouncy Bunny',
      speakerAvatar: '🐰',
      speakerRole: 'Story Explorer',
      contextSituation: 'Bouncy jumps up and down by the starting line near the apple tree',
      prompt: 'Are you ready to race me to the big apple tree? 🌳🏁',
      options: [
        'Ready, set, go! Catch me if you can! 🏃‍♂️💨',
        'Trees do not have legs.',
        'I am going to sleep here.',
        'No running allowed in the kingdom.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കളിസ്ഥലത്ത് ഓട്ടമത്സരം തുടങ്ങുമ്പോൾ പറയുന്ന രസകരമായ വാചകമാണ് "Ready, set, go! Catch me if you can!" 🏃‍♂️💨',
        'Tamil': 'விளையாட்டு தொடங்கும் போது "Ready, set, go! Catch me if you can!" என்று உற்சாகமாக கூறலாம்! 🏃‍♂️💨',
        'Hindi': 'रेस शुरू करते समय कहें "Ready, set, go! Catch me if you can!" 🏃‍♂️💨',
        'English': 'Playful challenge! "Ready, set, go! Catch me if you can!" is full of fun and playground energy! 🏃‍♂️💨',
      },
      contextHint: 'Standard countdown for fun kids races',
      funnyNote: 'Bunnies hop fast, but your English is faster! 🐰⚡',
    ),

    // --- 4. ROYAL PALACE GREETING (King Lion) ---
    ReelGameCard(
      id: 'kid_chat_king_lion_palace_4',
      gameType: ReelGameType.smartReply,
      category: 'ROYAL GREETING 👑',
      speakerName: 'King Lion',
      speakerAvatar: '🦁',
      speakerRole: 'Kingdom Sovereign',
      contextSituation: 'King Lion welcomes you to the Golden Palace with a regal nod',
      prompt: 'Welcome to my Golden Palace, young cub! How was your school today? 🏰',
      options: [
        'It was wonderful, Your Majesty! I learned new English words! 🌟',
        'School is boring, give me coins.',
        'Who are you wearing a crown?',
        'I forgot what happened.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'രാജാവിനോട് ആദരവോടെ സംസാരിക്കാൻ "It was wonderful, Your Majesty!" എന്ന് പറയാം! 👑✨',
        'Tamil': 'மரியாதையுடன் "It was wonderful, Your Majesty!" என்று உற்சாகமாக கூறலாம்! 👑✨',
        'Hindi': 'सम्मानपूर्वक कहें "It was wonderful, Your Majesty! I learned new words!" 👑✨',
        'English': 'Respectful and proud response! "It was wonderful, Your Majesty!" shows great confidence and manners! 👑✨',
      },
      contextHint: 'Polite honorific for a king: "Your Majesty"',
      funnyNote: 'King Lion loves enthusiastic learners! 🦁👑',
    ),

    // --- 5. BANANAS & FOOD TASTES (Milo Monkey) ---
    ReelGameCard(
      id: 'kid_chat_milo_banana_5',
      gameType: ReelGameType.smartReply,
      category: 'FOOD & TASTES 🍌',
      speakerName: 'Milo Monkey',
      speakerAvatar: '🐵',
      speakerRole: 'Playground Scout',
      contextSituation: 'Milo hangs upside down munching on fresh yellow fruit',
      prompt: 'Bananas are super sweet! What is your favorite fruit to eat? 🍌',
      options: [
        'I love juicy red apples! They are so crunchy! 🍎😋',
        'I only eat stones and mud.',
        'Bananas are yellow so I am angry.',
        'Fruit is too healthy for me.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'നമുക്കിഷ്ടപ്പെട്ട ഭക്ഷണത്തെക്കുറിച്ച് പറയാൻ "I love juicy red apples! They are crunchy!" എന്ന് ഉപയോഗിക്കാം! 🍎😋',
        'Tamil': 'விருப்பமான உணவைப்பற்றி "I love juicy red apples!" என்று சுவையாக விளக்கலாம்! 🍎😋',
        'Hindi': 'अपनी पसंद बताने के लिए कहें "I love juicy red apples! They are crunchy!" 🍎😋',
        'English': 'Expressing food favorites with descriptive adjectives like "juicy" and "crunchy" makes English lively! 🍎😋',
      },
      contextHint: 'Adjectives for food: "juicy" and "crunchy"',
      funnyNote: 'Monkeys love fruit, and so do healthy kids! 🍌🍏',
    ),

    // --- 6. LOST BALL DIRECTION (Puppy Max) ---
    ReelGameCard(
      id: 'kid_chat_puppy_ball_6',
      gameType: ReelGameType.smartReply,
      category: 'HELPING A FRIEND 🎾',
      speakerName: 'Puppy Max',
      speakerAvatar: '🐶',
      speakerRole: 'Playground Scout',
      contextSituation: 'Max is running around sniffing the lawn for his favorite red ball',
      prompt: 'Woof woof! I lost my red ball! Have you seen where it rolled? 🎾',
      options: [
        'Look right behind the green bush! There it is! 🌿👀',
        'Balls are round so they disappear.',
        'I hid your ball in my pocket.',
        'Go bark somewhere else doggy.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഒരു സാധനം എവിടെയാണെന്ന് വഴി കാണിക്കാൻ "Look right behind the bush! There it is!" എന്ന് പറയാം! 🌿👀',
        'Tamil': 'பொருளை சுட்டிக்காட்ட "Look right behind the bush! There it is!" என வழிகாட்டலாம்! 🌿👀',
        'Hindi': 'दिशा दिखाने के लिए कहें "Look right behind the bush! There it is!" 🌿👀',
        'English': 'Giving clear directional help! "Look behind the bush! There it is!" uses great prepositional phrases. 🌿👀',
      },
      contextHint: 'Directional phrase: "behind the bush"',
      funnyNote: 'Good doggy Max wagged his tail happily! 🐶❤️',
    ),

    // --- 7. BEDTIME MANNERS (Oliver Owl) ---
    ReelGameCard(
      id: 'kid_chat_oliver_night_7',
      gameType: ReelGameType.smartReply,
      category: 'BEDTIME MANNERS 🌙',
      speakerName: 'Oliver Owl',
      speakerAvatar: '🦉',
      speakerRole: 'Bedtime Guide',
      contextSituation: 'Oliver perches on the chimney as the moon and stars twinkle in the dark sky',
      prompt: 'Whoo-whoo! The stars are out and it is time for bed. What do we say at night? 🌙',
      options: [
        'Good night and sweet dreams, Oliver! 🌟🛌',
        'Good morning sunshine wake up!',
        'Why do owls stay awake at night?',
        'Goodbye forever.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഉറങ്ങാൻ പോകുമ്പോൾ എല്ലാവർക്കും ആശംസിക്കാൻ "Good night and sweet dreams!" എന്ന് പറയണം! 🌙🛌',
        'Tamil': 'இரவில் விடைபெறும்போது "Good night and sweet dreams!" என்று கூற வேண்டும்! 🌙🛌',
        'Hindi': 'सोते समय विनम्रता से कहें "Good night and sweet dreams!" 🌙🛌',
        'English': 'The universal polite bedtime wish: "Good night and sweet dreams!" wraps the day in warmth and love. 🌙🛌',
      },
      contextHint: 'Night greeting: "Good night and sweet dreams"',
      funnyNote: 'Time to count fluffy sheep and dream in English! 🐑💤',
    ),

    // --- 8. WELCOMING TO PLAY (Freddy Fox) ---
    ReelGameCard(
      id: 'kid_chat_fox_blocks_8',
      gameType: ReelGameType.smartReply,
      category: 'JOINING PLAY 🧱',
      speakerName: 'Freddy Fox',
      speakerAvatar: '🦊',
      speakerRole: 'Playground Scout',
      contextSituation: 'Freddy walks into the playroom holding colorful wooden building blocks',
      prompt: 'Excuse me! That castle looks amazing. May I play blocks with you? 🏰',
      options: [
        'Of course! Come join in, let\'s build the tower together! 🏰✨',
        'No, all the blocks belong only to me.',
        'Foxes are not allowed to build castles.',
        'I am breaking the castle now.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കളിക്കാൻ വരുന്നവരെ സ്വാഗതം ചെയ്യാൻ "Of course! Come join in, let\'s build together!" എന്ന് പറയുക! 🏰✨',
        'Tamil': 'நண்பர்களை விளையாட அழைக்க "Of course! Come join in!" என்று கூறலாம்! 🏰✨',
        'Hindi': 'खेल में शामिल करने के लिए कहें "Of course! Come join in, let\'s build together!" 🏰✨',
        'English': 'Welcoming friends to play! "Of course! Come join in!" builds teamwork and social joy. 🏰✨',
      },
      contextHint: 'Welcoming phrase: "Of course! Come join in!"',
      funnyNote: 'Two architects build higher than one! 🧱🏰',
    ),

    // --- 9. MAGIC WORDS (Starlight Unicorn) ---
    ReelGameCard(
      id: 'kid_chat_unicorn_magic_9',
      gameType: ReelGameType.smartReply,
      category: 'MAGIC WORDS ✨',
      speakerName: 'Starlight Unicorn',
      speakerAvatar: '🦄',
      speakerRole: 'Kingdom Sovereign',
      contextSituation: 'Starlight Unicorn hands you a sparkling golden star badge for speaking clearly',
      prompt: 'Here is a magical star for your hard work! What is the golden magic word? ⭐',
      options: [
        'Thank you so much! I appreciate it! 🙏💖',
        'Give me five more right now.',
        'I already had three stars.',
        'Stars are made of gas.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'സമ്മാനങ്ങൾ ലഭിക്കുമ്പോൾ നന്ദി പറയാൻ "Thank you so much!" എന്ന മാജിക് വാക്ക് ഉപയോഗിക്കുക! 🙏💖',
        'Tamil': 'பரிசு பெறும்போது "Thank you so much!" என்ற மேஜிக் வார்த்தையை மறக்காமல் சொல்லுங்கள்! 🙏💖',
        'Hindi': 'उपहार मिलने पर हमेशा कहें "Thank you so much!" 🙏💖',
        'English': 'The magic word of gratitude: "Thank you so much!" opens every heart with warmth and politeness! 🙏💖',
      },
      contextHint: 'The golden word of gratitude: "Thank you"',
      funnyNote: 'Magic words sparkle brighter than diamonds! 💎✨',
    ),

    // --- 10. WEATHER TALK (Barnaby Bear) ---
    ReelGameCard(
      id: 'kid_chat_bear_rain_10',
      gameType: ReelGameType.smartReply,
      category: 'WEATHER TALK 🌧️',
      speakerName: 'Barnaby Bear',
      speakerAvatar: '🐻',
      speakerRole: 'Story Explorer',
      contextSituation: 'Raindrops tap on the window as dark clouds drift over the forest',
      prompt: 'Pitter-patter! Rain is falling! What should we take before stepping outside? 🌧️',
      options: [
        'Grab your umbrella and wear your rain boots! ☔🥾',
        'Take a bottle of sunscreen lotion.',
        'Wear sunglasses and a beach hat.',
        'Leave the front door wide open.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'മഴക്കാലത്ത് പുറത്തിറങ്ങുമ്പോൾ "Grab your umbrella and wear rain boots!" എന്ന് ഓർമ്മിപ്പിക്കാം! ☔🥾',
        'Tamil': 'மழை நேரத்தில் "Grab your umbrella and wear rain boots!" என்று கூறலாம்! ☔🥾',
        'Hindi': 'बारिश में बाहर जाते समय कहें "Grab your umbrella and rain boots!" ☔🥾',
        'English': 'Weather awareness! "Grab your umbrella and rain boots!" connects English vocabulary with daily life. ☔🥾',
      },
      contextHint: 'Rainy gear: umbrella & boots',
      funnyNote: 'Splash in puddles safely with bright boots! 🌧️🥾',
    ),

    // --- 11. PHONICS RHYME (Flipper Dolphin) ---
    ReelGameCard(
      id: 'kid_chat_dolphin_rhyme_11',
      gameType: ReelGameType.smartReply,
      category: 'PHONICS RHYME 🎶',
      speakerName: 'Flipper Dolphin',
      speakerAvatar: '🐬',
      speakerRole: 'Phonics Buddy',
      contextSituation: 'Flipper leaps out of the crystal ocean with a splash of sea foam',
      prompt: 'Splash! Listen to the sound: "STAR"! Which word rhymes with "STAR"? ⭐',
      options: [
        'CAR! Star and Car rhyme with the /ɑːr/ sound! 🚗✨',
        'MOON! Moon rhymes with Star.',
        'FISH! Because I am in water.',
        'TREE!',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"Star", "Car" എന്നീ വാക്കുകൾ അവസാനിക്കുന്നത് ഒരേ ശബ്ദത്തിലാണ് (/ɑːr/). ഇതിനെയാണ് Rhyme എന്ന് വിളിക്കുന്നത്! 🚗⭐',
        'Tamil': '"Star" மற்றும் "Car" ஒரே ஓசையில் முடிவடையும் Rhyming வார்த்தைகள்! 🚗⭐',
        'Hindi': '"Star" और "Car" एक जैसे तुकांत (Rhyming) शब्द हैं! 🚗⭐',
        'English': 'Rhyming fun! "Star" and "Car" share the exact same ending phonics sound /-ɑːr/! 🚗⭐',
      },
      contextHint: 'Rhyme sounds like: Star, Car, Far',
      funnyNote: 'Drive a star-car across the sky! 🚗✨',
    ),

    // --- 12. POLITE SCARF ASSISTANCE (Pip Penguin) ---
    ReelGameCard(
      id: 'kid_chat_penguin_scarf_12',
      gameType: ReelGameType.smartReply,
      category: 'POLITE MANNERS 🧣',
      speakerName: 'Pip Penguin',
      speakerAvatar: '🐧',
      speakerRole: 'Manners Guide',
      contextSituation: 'Pip is sitting on an ice block shivering in the cold mountain air',
      prompt: 'Brrr, it is chilly on the glacier! Could you please pass me my warm red scarf? ❄️',
      options: [
        'Here you go, Pip! Wrap it up nice and warm! 🧣❤️',
        'Penguins are supposed to be cold.',
        'No, scarves are boring.',
        'I used your scarf to clean the floor.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ആരെങ്കിലും സഹായം ചോദിക്കുമ്പോൾ സന്തോഷത്തോടെ "Here you go! Wrap it up nice and warm!" എന്ന് മറുപടി നൽകാം! 🧣❤️',
        'Tamil': 'உதவி செய்யும்போது "Here you go!" என்று புன்னகையுடன் கூறலாம்! 🧣❤️',
        'Hindi': 'मदद करते समय कहें "Here you go! Wrap it up nice and warm!" 🧣❤️',
        'English': 'Warm and helpful! "Here you go, wrap it up nice and warm!" is kind and full of sweet empathy. 🧣❤️',
      },
      contextHint: 'Helpful response: "Here you go!"',
      funnyNote: 'A warm scarf keeps penguins singing happy songs! 🐧🧣',
    ),

    // --- 13. SILLY JOKE & LAUGHTER (Dino Rex) ---
    ReelGameCard(
      id: 'kid_chat_dino_roar_13',
      gameType: ReelGameType.smartReply,
      category: 'SILLY JOKE & LAUGHTER 😄',
      speakerName: 'Dino Rex',
      speakerAvatar: '🦖',
      speakerRole: 'Playground Scout',
      contextSituation: 'Rex tries to do a big ferocious roar, but it comes out as a tiny squeak',
      prompt: 'Squeeeak! Oh dear, my big scary dinosaur roar turned into a mouse squeak! 🐭🦖',
      options: [
        'Haha that was so cute, Rex! You are a sweet dino! 🦖💖',
        'You are not a real dinosaur anymore.',
        'Mice are scary, run away!',
        'Roar louder or I am leaving.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'തമാശ നിറഞ്ഞ സന്ദർഭങ്ങളിൽ കൂട്ടുകാരനെ ചിരിപ്പിക്കാൻ "Haha that was so cute! You are a sweet dino!" എന്ന് പറയാം! 😄🦖',
        'Tamil': 'நகைச்சுவையான நேரத்தில் "Haha that was so cute!" என்று உற்சாகப்படுத்தலாம்! 😄🦖',
        'Hindi': 'हंसी-मजाक में कहें "Haha that was so cute, you are a sweet dino!" 😄🦖',
        'English': 'Lighthearted humor! "Haha that was so cute, you are a sweet dino!" makes laughter easy and fun! 😄🦖',
      },
      contextHint: 'Friendly laughter: "That was so cute!"',
      funnyNote: 'Even T-Rex can have a squeaky day! 🦖🐭',
    ),

    // --- 14. CLASSROOM PERMISSION (Wise Owl Teacher) ---
    ReelGameCard(
      id: 'kid_chat_teacher_permission_14',
      gameType: ReelGameType.smartReply,
      category: 'CLASSROOM ENGLISH 🏫',
      speakerName: 'Wise Owl Teacher',
      speakerAvatar: '🦉',
      speakerRole: 'Bedtime Guide',
      contextSituation: 'You feel thirsty during English reading time in the classroom',
      prompt: 'You are thirsty during reading time. How do you politely ask teacher? 💧',
      options: [
        'May I please go drink some water, Teacher? 🙋‍♂️💧',
        'Give me water right now.',
        'I am leaving the room bye.',
        'Water is wet.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ക്ലാസ്സ് മുറിയിൽ ടീച്ചറോട് മാന്യമായി അനുവാദം ചോദിക്കാൻ "May I please go drink some water?" എന്ന് ഉപയോഗിക്കുക! 🏫💧',
        'Tamil': 'ஆசிரியரிடம் அனுமதி கேட்க "May I please go drink some water?" என்பதே நாகரீகமான முறை! 🏫💧',
        'Hindi': 'कक्षा में अनुमति लेने के लिए कहें "May I please go drink some water, Teacher?" 🏫💧',
        'English': 'Essential classroom etiquette: "May I please..." is the most polite and natural way to ask permission! 🏫💧',
      },
      contextHint: 'Polite permission formula: "May I please..."',
      funnyNote: 'Teachers always smile when you say "May I please"! 🦉🍎',
    ),

    // --- 15. DRAWING COMPLIMENT (Daisy Duck) ---
    ReelGameCard(
      id: 'kid_chat_drawing_compliment_15',
      gameType: ReelGameType.smartReply,
      category: 'GIVING COMPLIMENTS 🎨',
      speakerName: 'Daisy Duck',
      speakerAvatar: '🦆',
      speakerRole: 'Playground Scout',
      contextSituation: 'Daisy proudly shows you her new painting with a bright sunflower',
      prompt: 'Look at my new painting! I used yellow, green, and orange! Do you like it? 🌻',
      options: [
        'Wow, Daisy! Your painting is so colorful and bright! 🌈🎨',
        'I have seen better sunflowers.',
        'You used too much yellow.',
        'Painting is a waste of paper.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കൂട്ടുകാരന്റെ ചിത്രരചനയെ പ്രശംസിക്കാൻ "Wow! Your painting is so colorful and bright!" എന്ന് പറയാം! 🌈✨',
        'Tamil': 'நண்பரின் ஓவியத்தைப் பாராட்ட "Wow! Your painting is so colorful and bright!" என உற்சாகப்படுத்துங்கள்! 🌈✨',
        'Hindi': 'दोस्त की कला की तारीफ करें: "Wow! Your painting is so colorful and bright!" 🌈✨',
        'English': 'Positive affirmations! Saying "Wow, your painting is so colorful and bright!" encourages creativity and builds warm friendship! 🌈✨',
      },
      contextHint: 'Compliment: "colorful and bright"',
      funnyNote: 'Kind words make artwork shine even brighter! 🎨✨',
    ),

    // --- 16. SAYING SORRY (Leo Lion Cub) ---
    ReelGameCard(
      id: 'kid_chat_accidental_bump_16',
      gameType: ReelGameType.smartReply,
      category: 'SAYING SORRY 🤝',
      speakerName: 'Leo Lion Cub',
      speakerAvatar: '🦁',
      speakerRole: 'Phonics Buddy',
      contextSituation: 'While running towards the swings, you accidentally bumped into Leo',
      prompt: 'Oops! You bumped into Leo by accident. What is the right thing to say? 🥺',
      options: [
        'I am so sorry, Leo! Are you okay? 🤝❤️',
        'Watch where you are walking!',
        'It was not my fault, you were standing there.',
        'Run away quickly.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'അറിയാതെ തട്ടിയാൽ മാപ്പ് പറയാൻ "I am so sorry! Are you okay?" എന്ന് സ്നേഹത്തോടെ ചോദിക്കുക! 🤝❤️',
        'Tamil': 'தற்செயலாக மோதினால் "I am so sorry! Are you okay?" என்று மன்னிப்பு கேட்க வேண்டும்! 🤝❤️',
        'Hindi': 'अनजाने में टकराने पर कहें "I am so sorry! Are you okay?" 🤝❤️',
        'English': 'Manners and apology: "I am so sorry, are you okay?" resolves accidents immediately with kindness and maturity. 🤝❤️',
      },
      contextHint: 'Heartfelt apology: "I am so sorry! Are you okay?"',
      funnyNote: 'A true hero knows how to say sorry! 🦁🤝',
    ),

    // --- 17. ORDERING ICE CREAM (Sunny Squirrel) ---
    ReelGameCard(
      id: 'kid_chat_icecream_order_17',
      gameType: ReelGameType.smartReply,
      category: 'ORDERING SNACKS 🍦',
      speakerName: 'Sunny Squirrel',
      speakerAvatar: '🐿️',
      speakerRole: 'Playground Scout',
      contextSituation: 'The ice-cream cart rings its bell in the sunny park',
      prompt: 'Hello there, young buddy! What flavor of ice cream would you like today? 🍦',
      options: [
        'Could I please have one chocolate scoop in a cone? 🍦🍫',
        'Throw an ice cream at me.',
        'Give it fast.',
        'Ice cream is cold.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'കടകളിൽ പോയി മാന്യമായി ഓർഡർ ചെയ്യാൻ "Could I please have..." എന്ന് ഉപയോഗിക്കുക! 🍦🍫',
        'Tamil': 'மரியாதையாக கேட்க "Could I please have..." என்று தொடங்குங்கள்! 🍦🍫',
        'Hindi': 'शालीनता से मांगने के लिए कहें "Could I please have one chocolate scoop in a cone?" 🍦🍫',
        'English': 'Polite ordering formula: "Could I please have..." is native, polite, and universally appreciated! 🍦🍫',
      },
      contextHint: 'Polite ordering phrase: "Could I please have..."',
      funnyNote: 'Polite kids get the biggest chocolate scoops! 🍨😋',
    ),

    // --- 18. PLAYFUL RIDDLE (Gizmo Fox) ---
    ReelGameCard(
      id: 'kid_chat_riddle_cheesy_18',
      gameType: ReelGameType.smartReply,
      category: 'PLAYFUL RIDDLE 🧀',
      speakerName: 'Gizmo Fox',
      speakerAvatar: '🦊',
      speakerRole: 'Story Explorer',
      contextSituation: 'Gizmo winks with a giggle while holding up a puzzle riddle card',
      prompt: 'Riddle time! What building has the most stories in the whole world? 📚🏢',
      options: [
        'The Library! Because it is filled with storybooks! 📖✨',
        'The Golden Castle.',
        'A tall skyscraper.',
        'My bedroom.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'രസകരമായ വാക്ക് കളി: "Stories" എന്നാൽ കെട്ടിടത്തിന്റെ നിലകൾ എന്നും കഥകൾ എന്നും അർത്ഥമുണ്ട്. അതിനാൽ "The Library" ആണ് ശരി! 📖😄',
        'Tamil': '"Stories" என்பதற்கு மாடிகள் மற்றும் கதைகள் என இரு பொருள் உண்டு. எனவே "The Library" என்பதே பதில்! 📖😄',
        'Hindi': '"Stories" के दो अर्थ होते हैं - कहानियां और मंजिलें. इसलिए "Library" सही जवाब है! 📖😄',
        'English': 'Clever double meaning! "Stories" means both floors of a building and tales in books! The library has the most stories! 📖😄',
      },
      contextHint: 'Double meaning: "stories" in books vs "stories" in building',
      funnyNote: 'Reading books gives you superpower knowledge! 📚⚡',
    ),

    // --- 19. COMFORTING A KITTEN (Barnaby Bear) ---
    ReelGameCard(
      id: 'kid_chat_lost_pet_19',
      gameType: ReelGameType.smartReply,
      category: 'COMPASSION & COMFORT 🐱',
      speakerName: 'Barnaby Bear',
      speakerAvatar: '🐻',
      speakerRole: 'Story Explorer',
      contextSituation: 'Little kitten Mimi climbed onto a low garden branch and meows softly',
      prompt: 'Look, poor Mimi is stuck on the low branch! How can we comfort her? 🐱',
      options: [
        'Don\'t be afraid, little kitty! We will help you down safely! 🐾❤️',
        'Jump down and hit the ground.',
        'Stay in the tree forever.',
        'Cats should learn how to fly.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'ഭയന്നിരിക്കുന്ന ജീവികളോട് സ്നേഹത്തോടെ "Don\'t be afraid, we will help you down!" എന്ന് പറയുക! 🐾💖',
        'Tamil': 'அன்புடன் "Don\'t be afraid, we will help you down!" என்று தைரியம் கூறலாம்! 🐾💖',
        'Hindi': 'सांत्वना देते हुए कहें "Don\'t be afraid, we will help you down safely!" 🐾💖',
        'English': 'Gentle compassion: "Don\'t be afraid, we will help you down safely!" calms distress and shows great leadership! 🐾💖',
      },
      contextHint: 'Comforting phrase: "Don\'t be afraid"',
      funnyNote: 'Mimi purred and gave Barnaby a soft high-five! 🐾🐱',
    ),

    // --- 20. MORNING ENERGY (Sparky Tiger) ---
    ReelGameCard(
      id: 'kid_chat_morning_energy_20',
      gameType: ReelGameType.smartReply,
      category: 'MORNING ENTHUSIASM ☀️',
      speakerName: 'Sparky Tiger',
      speakerAvatar: '🐯',
      speakerRole: 'Phonics Buddy',
      contextSituation: 'The morning sun rises golden over the green hills as Sparky stretches with energy',
      prompt: 'Good morning, best buddy! The sun is shining bright! Are you ready for fun? ☀️',
      options: [
        'Good morning, Sparky! Let\'s make today super awesome! 🚀🌟',
        'Go away sun, I want darkness.',
        'Morning is too bright.',
        'I am staying in bed for a week.',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': 'പ്രഭാതത്തിൽ ഊർജ്ജസ്വലമായി "Good morning! Let\'s make today super awesome!" എന്ന് ആശംസിക്കുക! ☀️🚀',
        'Tamil': 'காலை வேளையில் "Good morning! Let\'s make today super awesome!" என்று புத்துணர்ச்சியுடன் கூறலாம்! ☀️🚀',
        'Hindi': 'सुबह की ताजगी के साथ कहें "Good morning! Let\'s make today super awesome!" ☀️🚀',
        'English': 'High morning energy: "Good morning, let\'s make today super awesome!" sets a positive tone for great English learning! ☀️🚀',
      },
      contextHint: 'Enthusiastic morning greeting',
      funnyNote: 'Rise and shine, superstar learner! 🌟☀️',
    ),

    // --- 21. SENTENCE BUILDER: CAN I PLAY (Bouncy Bunny) ---
    ReelGameCard(
      id: 'kid_sent_play_21',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      speakerName: 'Bouncy Bunny',
      speakerAvatar: '🐰',
      speakerRole: 'Story Explorer',
      prompt: 'Tap words in order to form the polite playground question:',
      options: ['play', 'can', 'with', 'I', 'please', 'you'],
      correctSentenceWords: ['can', 'I', 'please', 'play', 'with', 'you'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ വാക്യം: "Can I please play with you?" (കൂട്ടുകാരോട് കളിയിൽ പങ്കുചേരാൻ ചോദിക്കുന്ന മാന്യമായ വാചകം) ⚽✨',
        'Tamil': 'சரியான வாக்கியம்: "Can I please play with you?" ⚽✨',
        'Hindi': 'सही वाक्य: "Can I please play with you?" ⚽✨',
        'English': 'Natural playground invitation: "Can I please play with you?" is courteous, open, and friendly! ⚽✨',
      },
      contextHint: 'Question order: Can + I + please + play + with + you?',
      funnyNote: 'Everyone says YES when you ask politely! 🐰⚽',
    ),

    // --- 22. SENTENCE BUILDER: READING BOOKS (Wise Owl) ---
    ReelGameCard(
      id: 'kid_sent_books_22',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      speakerName: 'Oliver Owl',
      speakerAvatar: '🦉',
      speakerRole: 'Bedtime Guide',
      prompt: 'Arrange words into a happy sentence about reading:',
      options: ['English', 'read', 'to', 'love', 'I', 'books'],
      correctSentenceWords: ['I', 'love', 'to', 'read', 'English', 'books'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ ക്രമം: "I love to read English books." (ഇംഗ്ലീഷ് പുസ്തകങ്ങൾ വായിക്കാൻ എനിക്കിഷ്ടമാണ്) 📚💖',
        'Tamil': 'சரியான வரிசை: "I love to read English books." 📚💖',
        'Hindi': 'सही क्रम: "I love to read English books." 📚💖',
        'English': 'Fluent word order: Subject (I) + Verb (love to read) + Object (English books). 📚💖',
      },
      contextHint: 'Subject + love to + verb + object',
      funnyNote: 'Books take you on magical flying carpet journeys! 📖✨',
    ),

    // --- 23. PHONICS: SILENT K IN KNIFE (Sparky Tiger) ---
    ReelGameCard(
      id: 'kid_phonics_silent_k_23',
      gameType: ReelGameType.phonicsRiddle,
      category: 'PHONICS SECRET 🤫',
      speakerName: 'Sparky Tiger',
      speakerAvatar: '🐯',
      speakerRole: 'Phonics Buddy',
      prompt: 'Which word has a SILENT letter that you do NOT say out loud?',
      options: [
        'KNIFE (Silent K) 🤫',
        'TIGER 🐯',
        'APPLE 🍎',
        'BALL ⚽',
      ],
      correctOptionIndex: 0,
      nativeExplanations: {
        'Malayalam': '"KNIFE" എന്ന വാക്കിലെ ആദ്യത്തെ "K" ഉച്ചരിക്കില്ല (Silent K). "നൈഫ്" (/naɪf/) എന്നാണ് പറയേണ്ടത്! 🤫',
        'Tamil': '"KNIFE" என்பதில் "K" அமைதியாக இருக்கும், உச்சரிக்கப்படாது! /naɪf/ 🤫',
        'Hindi': '"KNIFE" में "K" साइलेंट होता है, इसे "नाइफ" बोलते हैं! 🤫',
        'English': 'The letter "K" is completely silent in "knife", "knee", and "knot"! 🤫',
      },
      contextHint: 'Look for words starting with "Kn-"',
      funnyNote: 'Silent letters are like ninjas hiding in the alphabet! 🥷✨',
    ),

    // --- 24. SENTENCE BUILDER: WATER REQUEST (Pandy Panda) ---
    ReelGameCard(
      id: 'kid_sent_water_24',
      gameType: ReelGameType.sentenceBuilder,
      category: 'SENTENCE BUILDER 🧩',
      speakerName: 'Pandy Panda',
      speakerAvatar: '🐼',
      speakerRole: 'Manners Guide',
      prompt: 'Tap words to ask for a glass of water politely:',
      options: ['water', 'may', 'of', 'glass', 'I', 'a', 'have', 'please'],
      correctSentenceWords: ['may', 'I', 'please', 'have', 'a', 'glass', 'of', 'water'],
      nativeExplanations: {
        'Malayalam': 'ശരിയായ വാക്യം: "May I please have a glass of water?" (മാന്യമായ ഇംഗ്ലീഷ് ശൈലി) 💧✨',
        'Tamil': 'சரியான வாக்கியம்: "May I please have a glass of water?" 💧✨',
        'Hindi': 'सही वाक्य: "May I please have a glass of water?" 💧✨',
        'English': 'Polite dining request: "May I please have a glass of water?" is perfect etiquette! 💧✨',
      },
      contextHint: 'May + I + please + have + a glass of water',
      funnyNote: 'Good manners refresh the heart! 💧🐼',
    ),
  ];
}
