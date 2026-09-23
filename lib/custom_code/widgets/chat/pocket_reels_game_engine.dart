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
  ];
}
