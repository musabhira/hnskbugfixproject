import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_vocab_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/day1_az_and_300vocab_data.dart';

/// 📖 Reel Short Story Model with Audio Read-Along & Dynamic Native Takeaway
class ReelStoryCard {
  final String id;
  final String title;
  final String category; // e.g. 'INSPIRATION ✨', 'WORKPLACE DIALOGUE 💼', 'CONFIDENCE BUILDER 🦁'
  final List<String> paragraphs;
  final String moralEn;
  final Map<String, String> nativeMorals; // 'Malayalam', 'Tamil', 'Hindi', etc.
  final List<Map<String, String>> keyVocab; // [{'word': 'Resilience', 'phonetic': '/rɪˈzɪl.jəns/', 'meaningEn': 'Ability to bounce back'}]
  final String fullReadText;

  const ReelStoryCard({
    required this.id,
    required this.title,
    required this.category,
    required this.paragraphs,
    required this.moralEn,
    required this.nativeMorals,
    required this.keyVocab,
    required this.fullReadText,
  });

  String getMoral(String lang) {
    final norm = PocketLanguageService.normalize(lang);
    if (nativeMorals.containsKey(norm)) return nativeMorals[norm]!;
    if (norm == 'Malayalam') return nativeMorals['Malayalam'] ?? moralEn;
    return nativeMorals['English'] ?? moralEn;
  }
}

/// 💼 Reel Interview & Workplace Communication Model
class ReelInterviewCard {
  final String id;
  final String question;
  final String category; // 'TOP HR QUESTION 🎯', 'STAR MODEL ANSWER ⭐', 'MEETING PHRASES 🤝'
  final String situationContext;
  final String starSituation;
  final String starAction;
  final String starResult;
  final String fullSpokenAnswer;
  final List<String> powerPhrases;
  final Map<String, String> nativeTips;

  const ReelInterviewCard({
    required this.id,
    required this.question,
    required this.category,
    required this.situationContext,
    required this.starSituation,
    required this.starAction,
    required this.starResult,
    required this.fullSpokenAnswer,
    required this.powerPhrases,
    required this.nativeTips,
  });

  String getTip(String lang) {
    final norm = PocketLanguageService.normalize(lang);
    if (nativeTips.containsKey(norm)) return nativeTips[norm]!;
    if (norm == 'Malayalam') {
      return nativeTips['Malayalam'] ??
          'Deliver your answer with clear pace and calm confidence.';
    }
    return nativeTips['English'] ??
        'Deliver your answer with clear pace and calm confidence.';
  }
}

/// 🗣️ Interactive Chatbot Speaking Challenge Model
class ReelSpeakChallengeCard {
  final String id;
  final String coachName;
  final String coachAvatar; // '🐱', '🤖', '👑', '🦉'
  final String situation;
  final String coachPrompt; // What the AI says
  final String targetSpeech; // What the user must speak
  final String phoneticGuide;
  final Map<String, String> nativeGuidance;
  final int pointsReward;

  const ReelSpeakChallengeCard({
    required this.id,
    required this.coachName,
    required this.coachAvatar,
    required this.situation,
    required this.coachPrompt,
    required this.targetSpeech,
    required this.phoneticGuide,
    required this.nativeGuidance,
    this.pointsReward = 25,
  });

  String getGuidance(String lang) {
    final norm = PocketLanguageService.normalize(lang);
    if (nativeGuidance.containsKey(norm)) return nativeGuidance[norm]!;
    if (norm == 'Malayalam') {
      return nativeGuidance['Malayalam'] ??
          'Speak naturally into the microphone!';
    }
    return nativeGuidance['English'] ?? 'Speak naturally into the microphone!';
  }
}

/// ⚡ Power Vocabulary & Idiom Model with Dynamic Multi-Language Meanings
class ReelVocabCard {
  final String id;
  final String word;
  final String partOfSpeech; // 'Noun', 'Verb', 'Adjective', 'Idiom'
  final String phonetic;
  final String definitionEn;
  final String contextSentence;
  final Map<String, String> nativeMeanings; // Never hardcoded
  final String proTip;
  final List<Map<String, dynamic>> phrases;

  const ReelVocabCard({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.phonetic,
    required this.definitionEn,
    required this.contextSentence,
    required this.nativeMeanings,
    required this.proTip,
    this.phrases = const [],
  });

  String getMeaning(String lang) {
    final norm = PocketLanguageService.normalize(lang);
    if (nativeMeanings.containsKey(norm)) return nativeMeanings[norm]!;
    if (norm == 'Malayalam') return nativeMeanings['Malayalam'] ?? definitionEn;
    return nativeMeanings['English'] ?? definitionEn;
  }
}

/// 🧠 Central Engine for Stories, Interview Vault, Speaking & Vocab Reels
class PocketReelsContentEngine {
  static final Set<String> _viewedItemIds = {};
  static final Set<String> _viewedVibesItemIds = {};
  static bool _initialized = false;
  static final math.Random _random = math.Random();

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('pm_viewed_content_ids') ?? [];
      _viewedItemIds.addAll(saved);
      final savedVibes = prefs.getStringList('pm_viewed_vibes_vocab_ids') ?? [];
      _viewedVibesItemIds.addAll(savedVibes);
      _initialized = true;
    } catch (_) {}
  }

  static Future<void> markContentViewed(String id) async {
    if (_viewedItemIds.add(id)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('pm_viewed_content_ids', _viewedItemIds.toList());
      } catch (_) {}
    }
  }

  static Future<void> markVibesContentViewed(String id) async {
    if (_viewedVibesItemIds.add(id)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('pm_viewed_vibes_vocab_ids', _viewedVibesItemIds.toList());
      } catch (_) {}
    }
  }

  /// 📓 Returns an unseen Daily English Phrases deck for Vibes feed (strict no-repeat)
  static ReelVocabCard? getVibesUnseenDeck({int slotOffset = 0}) {
    final all = allDailyEnglishDecks;
    final unseen = all.where((v) => !_viewedVibesItemIds.contains(v.id)).toList();
    if (unseen.isEmpty) return null;
    return unseen[slotOffset % unseen.length];
  }

  /// 📖 Get Short Story Batch (prioritizes unviewed)
  static List<ReelStoryCard> getStories({int count = 4}) {
    final unseen = _curatedStories.where((s) => !_viewedItemIds.contains(s.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedStories.where((s) => _viewedItemIds.contains(s.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  /// 💼 Get Interview Q&A Batch (prioritizes unviewed)
  static List<ReelInterviewCard> getInterviews({int count = 4}) {
    final unseen = _curatedInterviews.where((i) => !_viewedItemIds.contains(i.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedInterviews.where((i) => _viewedItemIds.contains(i.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  /// 🗣️ Get Spoken English Chatbot Challenges
  static List<ReelSpeakChallengeCard> getSpeakChallenges({int count = 4}) {
    final unseen = _curatedSpeakChallenges.where((s) => !_viewedItemIds.contains(s.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedSpeakChallenges.where((s) => _viewedItemIds.contains(s.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  static List<ReelVocabCard>? _cachedAllVocabDecks;
  static final Set<String> _sessionServedVocabIds = {};

  /// 📚 Generates 165+ Daily English Phrases & Words Scrapbook Decks (1,400+ entries across 90 days + everyday banks)
  static List<ReelVocabCard> get allDailyEnglishDecks {
    if (_cachedAllVocabDecks != null) return _cachedAllVocabDecks!;

    final List<ReelVocabCard> decks = [];
    // 1. Add all curated conversational Phrase Decks first
    decks.addAll(_curatedVocabCards.where((v) => v.phrases.isNotEmpty));

    // 2. Generate Scrapbook Decks from 90-Day Curriculum (900 unique words with multi-language translations)
    final List<Map<String, dynamic>> buffer = [];
    int deckIndex = 1;
    for (int day = 1; day <= 90; day++) {
      final items = Pocket90DayVocabCurriculum.getVocabForDay(day);
      for (final item in items) {
        final ml = item.malayalamMeaning.trim();
        final ta = item.tamilMeaning.trim();
        final hi = item.hindiMeaning.trim();
        final kn = item.kannadaMeaning.trim();
        final te = item.teluguMeaning.trim();
        if (item.word.isEmpty || (ml.isEmpty && hi.isEmpty && ta.isEmpty)) {
          continue;
        }
        buffer.add({
          'en': item.word,
          'Malayalam': ml.isNotEmpty ? ml : item.definition,
          'Tamil': ta.isNotEmpty ? ta : (ml.isNotEmpty ? ml : item.definition),
          'Hindi': hi.isNotEmpty ? hi : (ml.isNotEmpty ? ml : item.definition),
          'Kannada': kn.isNotEmpty ? kn : (ml.isNotEmpty ? ml : item.definition),
          'Telugu': te.isNotEmpty ? te : (ml.isNotEmpty ? ml : item.definition),
        });
        if (buffer.length == 8) {
          decks.add(ReelVocabCard(
            id: 'daily_90_deck_$deckIndex',
            word: 'Day $day • Daily Words',
            partOfSpeech: 'Daily English',
            phonetic: '',
            definitionEn: 'Essential Day $day Daily English Words',
            contextSentence: item.exampleSentence,
            nativeMeanings: const {},
            proTip: 'Tap any English word to hear clear pronunciation!',
            phrases: List<Map<String, dynamic>>.from(buffer),
          ));
          buffer.clear();
          deckIndex++;
        }
      }
    }
    if (buffer.isNotEmpty) {
      decks.add(ReelVocabCard(
        id: 'daily_90_deck_$deckIndex',
        word: 'Daily Mastery Words',
        partOfSpeech: 'Daily English',
        phonetic: '',
        definitionEn: 'Essential Daily English Words',
        contextSentence: '',
        nativeMeanings: const {},
        proTip: 'Tap any English word to hear clear pronunciation!',
        phrases: List<Map<String, dynamic>>.from(buffer),
      ));
      buffer.clear();
    }

    // 3. Generate Scrapbook Decks from Day 1 Everyday 300+ Vocab Bank
    int bankDeckIdx = 1;
    final List<Map<String, dynamic>> bankBuffer = [];
    for (final w in Day1VocabBankData.words300) {
      final wordStr = w['word']?.toString() ?? '';
      final mlMeaning = w['meaning']?.toString() ?? '';
      if (wordStr.isEmpty || mlMeaning.isEmpty) continue;
      bankBuffer.add({
        'en': wordStr,
        'Malayalam': mlMeaning,
        'Tamil': mlMeaning,
        'Hindi': mlMeaning,
        'Kannada': mlMeaning,
        'Telugu': mlMeaning,
      });
      if (bankBuffer.length == 8) {
        final cat = w['category']?.toString() ?? 'Everyday';
        decks.add(ReelVocabCard(
          id: 'daily_bank_deck_$bankDeckIdx',
          word: '$cat Essentials #$bankDeckIdx',
          partOfSpeech: 'Daily English',
          phonetic: '',
          definitionEn: 'Everyday $cat English words',
          contextSentence: w['example']?.toString() ?? '',
          nativeMeanings: const {},
          proTip: 'Practice speaking each word clearly!',
          phrases: List<Map<String, dynamic>>.from(bankBuffer),
        ));
        bankBuffer.clear();
        bankDeckIdx++;
      }
    }

    _cachedAllVocabDecks = decks;
    return decks;
  }

  /// ⚡ Get Power Vocabulary & Daily English Phrases Batch (Strict No-Repeat)
  static List<ReelVocabCard> getVocabCards({int count = 8}) {
    final all = allDailyEnglishDecks;
    // Strict no-repeat: exclude both permanently viewed AND already-served-this-session
    final unseen = all
        .where((v) =>
            !_viewedItemIds.contains(v.id) &&
            !_sessionServedVocabIds.contains(v.id))
        .toList();
    // Keep curated conversational decks prioritized at the front while shuffling the rest
    final curatedUnseen =
        unseen.where((v) => v.id.startsWith('vocab_phrases_')).toList()
          ..shuffle(_random);
    final bankUnseen =
        unseen.where((v) => !v.id.startsWith('vocab_phrases_')).toList()
          ..shuffle(_random);
    final orderedUnseen = [...curatedUnseen, ...bankUnseen];

    if (orderedUnseen.isNotEmpty) {
      final picked = orderedUnseen.take(count).toList();
      for (final p in picked) {
        _sessionServedVocabIds.add(p.id);
      }
      return picked;
    }

    // Only recycle if user has literally finished all 165+ decks!
    final fallbackUnserved =
        all.where((v) => !_sessionServedVocabIds.contains(v.id)).toList()
          ..shuffle(_random);
    if (fallbackUnserved.isNotEmpty) {
      final picked = fallbackUnserved.take(count).toList();
      for (final p in picked) {
        _sessionServedVocabIds.add(p.id);
      }
      return picked;
    }

    _sessionServedVocabIds.clear();
    final fresh = List<ReelVocabCard>.from(all)..shuffle(_random);
    return fresh.take(count).toList();
  }

  /// 🗣️ Get Spoken English Animal Buddy Challenges for Kids
  static List<ReelSpeakChallengeCard> getKidsSpeakChallenges({int count = 4}) {
    final unseen = _curatedKidsSpeakChallenges.where((s) => !_viewedItemIds.contains(s.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedKidsSpeakChallenges.where((s) => _viewedItemIds.contains(s.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  /// ⚡ Get Kids Fun Vocabulary Batch
  static List<ReelVocabCard> getKidsVocabCards({int count = 4}) {
    final unseen = _curatedKidsVocabCards.where((v) => !_viewedItemIds.contains(v.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedKidsVocabCards.where((v) => _viewedItemIds.contains(v.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  /// 📖 Get Kids Mini Stories Batch
  static List<ReelStoryCard> getKidsStories({int count = 4}) {
    final unseen = _curatedKidsStories.where((s) => !_viewedItemIds.contains(s.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedKidsStories.where((s) => _viewedItemIds.contains(s.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
  }

  // =========================================================================
  // 📚 CURATED HIGH-YIELD CONTENT DATASETS
  // =========================================================================

  static final List<ReelStoryCard> _curatedStories = [
    const ReelStoryCard(
      id: 'story_cracked_pot',
      title: 'The Tale of Two Water Pots',
      category: 'SELF-WORTH & VALUE 🪴',
      paragraphs: [
        'A water bearer in India had two large pots, each hung on opposite ends of a pole across his shoulders.',
        'One pot was flawless, but the other had a small crack and always leaked half its water along the long walk home.',
        'Ashamed, the cracked pot apologized: "I am flawed; you work so hard, yet I deliver only half my load."',
        'The water bearer smiled and replied: "Look at your side of the path. Because you dripped water every day, beautiful flowers grew there. I picked them to decorate my master\'s table."',
      ],
      moralEn: 'Our unique imperfections often plant seeds of beauty that perfection never could.',
      nativeMorals: {
        'Malayalam': 'നമ്മുടെ കുറവുകളും വ്യത്യസ്തതകളും പലപ്പോഴും മറ്റുള്ളവർക്ക് ഗുണകരമായ സൗന്ദര്യമായി മാറാറുണ്ട്.',
        'Tamil': 'நமது குறைகளும் சில நேரங்களில் அழகான மாற்றங்களை உருவாக்கக் கூடும்.',
        'Hindi': 'हमारी कमियां भी कई बार दूसरों के जीवन में खुशियां और सुंदरता ला सकती हैं.',
      },
      keyVocab: [
        {'word': 'Flawless', 'phonetic': '/ˈflɔː.ləs/', 'meaningEn': 'Without any mistake or defect'},
        {'word': 'Bearer', 'phonetic': '/ˈbeə.rər/', 'meaningEn': 'A person who carries something'},
      ],
      fullReadText:
          'A water bearer had two large pots. One was flawless, but the other was cracked and leaked water. The bearer told the cracked pot: because you leaked water, beautiful flowers grew along your path. Our unique flaws often create unexpected beauty.',
    ),
    const ReelStoryCard(
      id: 'story_the_two_wolves',
      title: 'The Battle of Two Wolves',
      category: 'MINDSET & STRENGTH 🐺',
      paragraphs: [
        'An old grandfather sat by the fire with his grandson and spoke of the inner battle within every human soul.',
        '"A terrible fight is going on inside me," the old man said gently. "It is between two fierce wolves."',
        '"One wolf is anger, jealousy, greed, and fear. The other wolf is joy, peace, gratitude, and confidence."',
        'The young boy thought for a moment and whispered, "Grandfather, which wolf wins?"',
        'The old man replied softly: "The one you feed."',
      ],
      moralEn: 'What you choose to practice and feed in your mind every day determines who you become.',
      nativeMorals: {
        'Malayalam': 'നമ്മൾ ഉള്ളിൽ വളർത്തുന്ന ചിന്തകളാണ് നമ്മുടെ വ്യക്തിത്വവും വിജയവും നിർണ്ണയിക്കുന്നത്.',
        'Tamil': 'நாம் எந்த எண்ணங்களுக்கு முக்கியத்துவம் கொடுக்கிறோமோ அதுவே நம்மை வழிநடத்தும்.',
        'Hindi': 'हम अपने मन में जिन विचारों को पोषण देते हैं, वही हमारे जीवन का निर्माण करते हैं.',
      },
      keyVocab: [
        {'word': 'Fierce', 'phonetic': '/fɪəs/', 'meaningEn': 'Showing aggressive or powerful intensity'},
        {'word': 'Gratitude', 'phonetic': '/ˈɡræt.ɪ.tjuːd/', 'meaningEn': 'The quality of being thankful'},
      ],
      fullReadText:
          'An old man told his grandson that a battle happens inside every human between two wolves: one of fear and anger, and one of peace and confidence. Which one wins? The one you choose to feed.',
    ),
    const ReelStoryCard(
      id: 'story_the_coffee_beans',
      title: 'Carrot, Egg, or Coffee Bean?',
      category: 'RESILIENCE & ADAPTABILITY ☕',
      paragraphs: [
        'A young woman complained to her father that life was too difficult and she felt like giving up.',
        'Her father brought three pots of boiling water. In one he placed carrots, in the second an egg, and in the third coffee beans.',
        'The carrot went in hard, but boiled into mush. The fragile egg boiled into a hardened shell.',
        'However, the coffee beans completely changed the boiling water itself, creating rich, aromatic coffee.',
        '"When adversity strikes," her father asked, "are you a carrot, an egg, or a coffee bean?"',
      ],
      moralEn: 'Do not let hard circumstances weaken or harden you; transform the environment around you.',
      nativeMorals: {
        'Malayalam': 'പ്രതിസന്ധികൾ വരുമ്പോൾ തളരുകയോ ദേഷ്യപ്പെടുകയോ ചെയ്യാതെ, ആ സാഹചര്യത്തെ തന്നെ മാറ്റിമറിക്കുക.',
        'Tamil': 'சிரமங்கள் வரும்போது சூழ்நிலையை மாற்றி அமைக்கும் நபராக மாறுங்கள்.',
        'Hindi': 'मुसीबतों में कमजोर पड़ने के बजाय, अपने आसपास के माहौल को सकारात्मक बनाएं.',
      },
      keyVocab: [
        {'word': 'Adversity', 'phonetic': '/ədˈvɜː.sə.ti/', 'meaningEn': 'Difficult or unpleasant situation'},
        {'word': 'Aromatic', 'phonetic': '/ˌær.əˈmæt.ɪk/', 'meaningEn': 'Having a pleasant and distinctive smell'},
      ],
      fullReadText:
          'A father boiled carrots, an egg, and coffee beans in water. The carrot became soft, the egg turned hard, but the coffee beans transformed the water into delicious coffee. Be like the coffee bean and transform your circumstances.',
    ),
  ];

  static final List<ReelInterviewCard> _curatedInterviews = [
    const ReelInterviewCard(
      id: 'interview_tell_me_about_yourself',
      question: 'Tell me about yourself.',
      category: 'TOP HR QUESTION 🎯',
      situationContext: 'Asked in the first 2 minutes of virtually every job interview.',
      starSituation: 'Past background: Graduated in technology and worked in client service.',
      starAction: 'Present role: Focused on proactive communication, problem-solving, and collaboration.',
      starResult: 'Future alignment: Ready to bring structured discipline and fresh energy to this team.',
      fullSpokenAnswer:
          'Thank you for this opportunity. Over the past few years, I have built a solid foundation in problem solving and active client communication. In my recent work, I led cross-functional coordination that reduced turnaround time by twenty percent. I am excited about this role because it aligns with my passion for high-impact teamwork.',
      powerPhrases: [
        '"Over the past few years, I have built a solid foundation in..."',
        '"A key highlight was when I coordinated..."',
        '"What excites me about this opportunity is..."',
      ],
      nativeTips: {
        'Malayalam': 'കുടുംബ പശ്ചാത്തലം പറയുന്നതിനു പകരം, നിങ്ങളുടെ തൊഴിൽപരമായ നേട്ടങ്ങളും പുതിയ റോളിലെ താല്പര്യവും മാത്രം പറയുക.',
        'Tamil': 'தனிப்பட்ட குடும்ப விவரங்களை தவிர்க்கவும்; உங்கள் தொழில் அனுபவம் மற்றும் சாதனைகளை மட்டும் தெளிவாக கூறுங்கள்.',
        'Hindi': 'व्यक्तिगत बातों के बजाय अपनी उपलब्धियों और इस नौकरी से जुड़ी अपनी क्षमताओं पर जोर दें.',
      },
    ),
    const ReelInterviewCard(
      id: 'interview_greatest_weakness',
      question: 'What is your biggest weakness?',
      category: 'CONFIDENCE & HONESTY 💡',
      situationContext: 'Testing your self-awareness and willingness to improve.',
      starSituation: 'I used to struggle with saying "no" and took on too many tasks at once.',
      starAction: 'I implemented a priority matrix and learned to communicate realistic deadlines.',
      starResult: 'Now I deliver higher quality output without burning out.',
      fullSpokenAnswer:
          'In the past, I found it difficult to say no and often took on too many commitments at once. To resolve this, I started using a daily priority matrix and setting clear expectations with my teammates. This has significantly enhanced my delivery quality and focus.',
      powerPhrases: [
        '"In the past, I noticed that I tended to..."',
        '"To address this, I deliberately adopted a system where..."',
        '"As a result, I have become much more effective at..."',
      ],
      nativeTips: {
        'Malayalam': 'യഥാർത്ഥമായ ഒരു ചെറിയ പോരായ്മ പറയുക, ഒപ്പം അത് പരിഹരിക്കാൻ നിങ്ങൾ ചെയ്യുന്ന കാര്യവും വ്യക്തമാക്കുക.',
        'Tamil': 'ஒரு சிறிய பலவீனத்தை கூறி, அதை நீங்கள் எவ்வாறு சரிசெய்து வருகிறீர்கள் என்பதை தெளிவாக விளக்குங்கள்.',
        'Hindi': 'अपनी किसी वास्तविक कमी को बताएं और यह भी दिखाएं कि आप उसे सुधारने के लिए क्या कदम उठा रहे हैं.',
      },
    ),
    const ReelInterviewCard(
      id: 'interview_conflict_resolution',
      question: 'How do you handle a disagreement with a team member?',
      category: 'WORKPLACE COMMUNICATION 🤝',
      situationContext: 'Evaluates your maturity, emotional intelligence, and diplomatic speaking.',
      starSituation: 'On a recent project, a colleague and I disagreed on the project timeline.',
      starAction: 'Instead of debating publicly, I scheduled a one-on-one coffee chat to understand their perspective.',
      starResult: 'We created a shared milestone plan that satisfied both technical quality and deadline goals.',
      fullSpokenAnswer:
          'When disagreements arise, I focus on the problem rather than personal opinions. I schedule a brief one-on-one discussion to actively listen to their perspective. By aligning on our shared goal, we can easily find a win-win compromise that moves the project forward.',
      powerPhrases: [
        '"I focus on the shared objective rather than personal opinions."',
        '"I find that listening actively diffuses tension very quickly."',
        '"We arrived at a balanced compromise that worked for both sides."',
      ],
      nativeTips: {
        'Malayalam': 'വ്യക്തിപരമായ തർക്കങ്ങളല്ല, കമ്പനിയുടെ ലക്ഷ്യത്തിനാണ് മുൻഗണന നൽകുന്നതെന്ന് തെളിയിക്കുക.',
        'Tamil': 'வாதிடாமல், பொதுவான இலக்கை அடைவதற்கு எவ்வாறு ஒத்துழைக்கிறீர்கள் என்பதை காட்டுங்கள்.',
        'Hindi': 'दिखाएं कि आप बहस करने के बजाय बातचीत और समझदारी से समस्या का हल निकालते हैं.',
      },
    ),
  ];

  static final List<ReelSpeakChallengeCard> _curatedSpeakChallenges = [
    const ReelSpeakChallengeCard(
      id: 'speak_coffee_shop',
      coachName: 'CyberCat 🐱',
      coachAvatar: '🐱',
      situation: 'Ordering politely at a modern cafe',
      coachPrompt: 'Imagine you are ordering a coffee. Say this sentence clearly aloud into the mic:',
      targetSpeech: 'Could I please get a hot cappuccino with oat milk?',
      phoneticGuide: 'kʊd aɪ pliːz ɡɛt ə hɒt ˌkæp.əˈtʃiː.nəʊ wɪð əʊt mɪlk',
      nativeGuidance: {
        'Malayalam': 'മാന്യമായി ഓർഡർ ചെയ്യാൻ "Give me" എന്നതിനു പകരം "Could I please get" എന്ന് ഉപയോഗിക്കുക.',
        'Tamil': 'மரியாதையாக கேட்க "Could I please get" என்று தொடங்குங்கள்.',
        'Hindi': 'विनम्रता से ऑर्डर करने के लिए "Could I please get" का उपयोग करें.',
      },
      pointsReward: 30,
    ),
    const ReelSpeakChallengeCard(
      id: 'speak_meeting_interruption',
      coachName: 'Alex 🤖 (Career Coach)',
      coachAvatar: '🤖',
      situation: 'Politely interrupting in a business meeting',
      coachPrompt: 'You need to add a crucial point while someone is speaking. Speak this sentence:',
      targetSpeech: 'Excuse me, may I quickly add something to that point?',
      phoneticGuide: 'ɪkˈskjuːz miː meɪ aɪ ˈkwɪk.li æd ˈsʌm.θɪŋ tuː ðæt pɔɪnt',
      nativeGuidance: {
        'Malayalam': 'മീറ്റിംഗുകളിൽ ആരെയും അലോസരപ്പെടുത്താതെ സംസാരിക്കാൻ ഈ വാചകം ഉപയോഗിക്കാം.',
        'Tamil': 'கூட்டங்களில் நாகரீகமாக குறுக்கிட்டு கருத்து தெரிவிக்க இதை பயன்படுத்துங்கள்.',
        'Hindi': 'மீटिंग में बीच में शालीनता से अपनी बात रखने के लिए यह वाक्य बोलें.',
      },
      pointsReward: 30,
    ),
    const ReelSpeakChallengeCard(
      id: 'speak_clarification',
      coachName: 'Maya 🦉 (Executive Coach)',
      coachAvatar: '🦉',
      situation: 'Asking for clarity on instructions',
      coachPrompt: 'You did not understand what the client said. Speak this professional request:',
      targetSpeech: 'Could you please clarify what you mean by that?',
      phoneticGuide: 'kʊd juː pliːz ˈklær.ɪ.faɪ wɒt juː miːn baɪ ðæt',
      nativeGuidance: {
        'Malayalam': '"What?" അല്ലെങ്കിൽ "Say again" എന്ന് പറയുന്നതിന് പകരം ഇത് ഉപയോഗിക്കുക.',
        'Tamil': 'விளக்கம் கேட்கும்போது மரியாதையாக "Could you please clarify" என கேளுங்கள்.',
        'Hindi': 'दोबारा पूछने के लिए "Could you please clarify" कहना सबसे पेशेवर तरीका है.',
      },
      pointsReward: 30,
    ),
  ];

  static final List<ReelVocabCard> _curatedVocabCards = [
    // 📖 1. Phrases with 'WHO' (Scrapbook Torn Notebook Deck)
    const ReelVocabCard(
      id: 'vocab_phrases_who',
      word: "Phrases with 'WHO'",
      partOfSpeech: 'Phrases',
      phonetic: '/huː/',
      definitionEn: 'Essential everyday conversational expressions starting with Who.',
      contextSentence: 'Who is this at the doorstep? Ask politely before answering.',
      nativeMeanings: {
        'Malayalam': "ചോദ്യങ്ങൾ ചോദിക്കാൻ ഉപയോഗിക്കുന്ന 'ആര്' (WHO) വാചകങ്ങൾ.",
        'Tamil': "'யார்' (WHO) கொண்டு தொடங்கும் அன்றாட வாக்கியங்கள்.",
        'Hindi': "'कौन' (WHO) से शुरू होने वाले दैनिक उपयोगी वाक्य.",
        'Kannada': "'ಯಾರು' (WHO) ನಿಂದ ಆರಂಭವಾಗುವ ದಿನನಿತ್ಯದ ವಾಕ್ಯಗಳು.",
        'Telugu': "'ఎవరు' (WHO) తో మొదలయ్యే దైనందిన సంభాషణ వాక్యాలు.",
      },
      proTip: 'Use rising intonation at the end when asking questions with Who.',
      phrases: [
        {'en': 'Who is this?', 'Malayalam': 'ഇതാരാണ്?', 'Tamil': 'இது யார்?', 'Hindi': 'यह कौन है?', 'Kannada': 'ಇದು ಯಾರು?', 'Telugu': 'ఇది ఎవరు?'},
        {'en': 'Who is that?', 'Malayalam': 'അതാരാണ്?', 'Tamil': 'அது யார்?', 'Hindi': 'वह कौन है?', 'Kannada': 'ಅದು ಯಾರು?', 'Telugu': 'అది ఎవరు?'},
        {'en': 'Who are you?', 'Malayalam': 'നിങ്ങൾ ആരാണ്?', 'Tamil': 'நீங்கள் யார்?', 'Hindi': 'आप कौन हैं?', 'Kannada': 'ನೀವು ಯಾರು?', 'Telugu': 'మీరు ఎవరు?'},
        {'en': 'Who said that?', 'Malayalam': 'അതാരാണ് പറഞ്ഞത്?', 'Tamil': 'அதை யார் சொன்னது?', 'Hindi': 'यह किसने कहा?', 'Kannada': 'ಅದನ್ನು ಯಾರು ಹೇಳಿದರು?', 'Telugu': 'అది ఎవరు చెప్పారు?'},
        {'en': 'Who knows?', 'Malayalam': 'ആർക്കറിയാം?', 'Tamil': 'யாருக்கு தெரியும்?', 'Hindi': 'किसे पता है?', 'Kannada': 'ಯಾರಿಗೆ ಗೊತ್ತು?', 'Telugu': 'ఎవరికి తెలుసు?'},
        {'en': 'Who is coming?', 'Malayalam': 'ആരാണ് വരുന്നത്?', 'Tamil': 'யார் வருகிறார்கள்?', 'Hindi': 'कौन आ रहा है?', 'Kannada': 'ಯಾರು ಬರುತ್ತಿದ್ದಾರೆ?', 'Telugu': 'ఎవరు వస్తున్నారు?'},
        {'en': 'Who called?', 'Malayalam': 'ആരാണ് വിളിച്ചത്?', 'Tamil': 'யார் அழைத்தது?', 'Hindi': 'किसने कॉल किया?', 'Kannada': 'ಯಾರು ಕರೆ ಮಾಡಿದ್ದು?', 'Telugu': 'ఎవరు కాల్ చేశారు?'},
        {'en': 'Who is next?', 'Malayalam': 'അടുത്തത് ആരാണ്?', 'Tamil': 'அடுத்து யார்?', 'Hindi': 'अगला कौन है?', 'Kannada': 'ಮುಂದೆ ಯಾರು?', 'Telugu': 'తరువాత ఎవరు?'},
      ],
    ),

    // 📖 2. Phrases with 'HOW' (Scrapbook Torn Notebook Deck)
    const ReelVocabCard(
      id: 'vocab_phrases_how',
      word: "Phrases with 'HOW'",
      partOfSpeech: 'Phrases',
      phonetic: '/haʊ/',
      definitionEn: 'Key expressions to inquire about state, method, condition, and feelings.',
      contextSentence: 'How is this working out for you in practice?',
      nativeMeanings: {
        'Malayalam': "വിശേഷങ്ങളും രീതികളും ചോദിക്കാൻ ഉപയോഗിക്കുന്ന 'എങ്ങനെ' (HOW) വാചകങ്ങൾ.",
        'Tamil': "'எப்படி' (HOW) பயன்படுத்தி கேட்கப்படும் பயனுள்ள வாக்கியங்கள்.",
        'Hindi': "'कैसे' (HOW) से स्थिति और हालचाल पूछने वाले वाक्य.",
        'Kannada': "'ಹೇಗೆ' (HOW) ಬಳಸಿ ಕೇಳುವ ಮುಖ್ಯ ಪ್ರಶ್ನೆಗಳು.",
        'Telugu': "'ఎలా' (HOW) తో అడిగే ముఖ్యమైన ప్రశ్నలు.",
      },
      proTip: "Great conversation starters for greeting friends and colleagues.",
      phrases: [
        {'en': 'How are you?', 'Malayalam': 'സുഖമാണോ?', 'Tamil': 'எப்படி இருக்கிறீர்கள்?', 'Hindi': 'आप कैसे हैं?', 'Kannada': 'ಹೇಗಿದ್ದೀರ?', 'Telugu': 'మీరు ఎలా ఉన్నారు?'},
        {'en': 'How is this?', 'Malayalam': 'ഇതെങ്ങനെയുണ്ട്?', 'Tamil': 'இது எப்படி இருக்கு?', 'Hindi': 'यह कैसा है?', 'Kannada': 'ಇದು ಹೇಗಿದೆ?', 'Telugu': 'ఇది ఎలా ఉంది?'},
        {'en': 'How much is it?', 'Malayalam': 'ഇതിന് എത്രയാണ് വില?', 'Tamil': 'இதன் விலை என்ன?', 'Hindi': 'यह कितने का है?', 'Kannada': 'ಇದರ ಬೆಲೆ ಎಷ್ಟು?', 'Telugu': 'దీని ఖరీదు ఎంత?'},
        {'en': 'How does it work?', 'Malayalam': 'ഇത് എങ്ങനെ പ്രവർത്തിക്കുന്നു?', 'Tamil': 'இது எப்படி செயல்படுகிறது?', 'Hindi': 'यह कैसे काम करता है?', 'Kannada': 'ಇದು ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ?', 'Telugu': 'ఇది ఎలా పనిచేస్తుంది?'},
        {'en': 'How was your day?', 'Malayalam': 'ഇന്ന് ദിവസം എങ്ങനെയുണ്ടായിരുന്നു?', 'Tamil': 'உங்கள் நாள் எப்படி இருந்தது?', 'Hindi': 'आपका दिन कैसा रहा?', 'Kannada': 'ನಿಮ್ಮ ದಿನ ಹೇಗಿತ್ತು?', 'Telugu': 'ఈ రోజు ఎలా గడిచింది?'},
        {'en': 'How can I help?', 'Malayalam': 'ഞാൻ എങ്ങനെ സഹായിക്കണം?', 'Tamil': 'நான் எப்படி உதவலாம்?', 'Hindi': 'मैं कैसे मदद करूँ?', 'Kannada': 'ನಾನು ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?', 'Telugu': 'నేను ఎలా సహాయపడగలను?'},
        {'en': 'How do you know?', 'Malayalam': 'നിങ്ങൾക്കെങ്ങനെ അറിയാം?', 'Tamil': 'உங்களுக்கு எப்படி தெரியும்?', 'Hindi': 'आपको कैसे पता चला?', 'Kannada': 'ನಿಮಗೆ ಹೇಗೆ ಗೊತ್ತು?', 'Telugu': 'మీకు ఎలా తెలుసు?'},
        {'en': 'How is everyone?', 'Malayalam': 'എല്ലാവർക്കും സുഖമാണോ?', 'Tamil': 'எல்லோரும் எப்படி இருக்கிறார்கள்?', 'Hindi': 'घर पर सब कैसे हैं?', 'Kannada': 'ಎಲ್ಲರೂ ಹೇಗಿದ್ದಾರೆ?', 'Telugu': 'అందరూ ఎలా ఉన్నారు?'},
      ],
    ),

    // 📖 3. Phrases with 'WHERE' (Scrapbook Torn Notebook Deck)
    const ReelVocabCard(
      id: 'vocab_phrases_where',
      word: "Phrases with 'WHERE'",
      partOfSpeech: 'Phrases',
      phonetic: '/weər/',
      definitionEn: 'Expressions used to ask about locations, destinations, and origins.',
      contextSentence: 'Where are you heading this weekend?',
      nativeMeanings: {
        'Malayalam': "സ്ഥലങ്ങളും വഴികളും ചോദിക്കാൻ ഉപയോഗിക്കുന്ന 'എവിടെ' (WHERE) വാചകങ്ങൾ.",
        'Tamil': "'எங்கே' (WHERE) கொண்டு இடங்களை கேட்கும் வாக்கியங்கள்.",
        'Hindi': "'कहाँ' (WHERE) से स्थान और दिशा पूछने वाले वाक्य.",
        'Kannada': "'ಎಲ್ಲಿ' (WHERE) ಬಳಸಿ ಜಾಗ ಕೇಳುವ ವಾಕ್ಯಗಳು.",
        'Telugu': "'ఎక్కడ' (WHERE) తో ప్రదేశాల గురించి అడిగే వాక్యాలు.",
      },
      proTip: 'Must-know phrases when traveling or meeting someone at a new venue.',
      phrases: [
        {'en': 'Where are you?', 'Malayalam': 'നിങ്ങൾ എവിടെയാണ്?', 'Tamil': 'நீங்கள் எங்கே இருக்கிறீர்கள்?', 'Hindi': 'आप कहाँ हैं?', 'Kannada': 'ನೀವು ಎಲ್ಲಿದ್ದೀರಿ?', 'Telugu': 'మీరు ఎక్కడ ఉన్నారు?'},
        {'en': 'Where is that?', 'Malayalam': 'അതെവിടെയാണ്?', 'Tamil': 'அது எங்கே இருக்கிறது?', 'Hindi': 'वह कहाँ है?', 'Kannada': 'ಅದು ಎಲ್ಲಿದೆ?', 'Telugu': 'అది ఎక్కడ ఉంది?'},
        {'en': 'Where are we going?', 'Malayalam': 'നമ്മൾ എങ്ങോട്ടാണ് പോകുന്നത്?', 'Tamil': 'நாம் எங்கே போகிறோம்?', 'Hindi': 'हम कहाँ जा रहे हैं?', 'Kannada': 'ನಾವು ಎಲ್ಲಿಗೆ ಹೋಗುತ್ತಿದ್ದೇವೆ?', 'Telugu': 'మనం ఎక్కడికి వెళ్తున్నాం?'},
        {'en': 'Where do you live?', 'Malayalam': 'നിങ്ങൾ എവിടെയാണ് താമസിക്കുന്നത്?', 'Tamil': 'நீங்கள் எங்கே வசிக்கிறீர்கள்?', 'Hindi': 'आप कहाँ रहते हैं?', 'Kannada': 'ನೀವು ಎಲ್ಲಿ ವಾಸಿಸುತ್ತಿದ್ದೀರಿ?', 'Telugu': 'మీరు ఎక్కడ నివసిస్తున్నారు?'},
        {'en': 'Where did you get this?', 'Malayalam': 'ഇത് എവിടെ നിന്നാണ് കിട്ടിയത്?', 'Tamil': 'இது எங்கே கிடைத்தது?', 'Hindi': 'यह आपको कहाँ से मिला?', 'Kannada': 'ಇದು ನಿಮಗೆ ಎಲ್ಲಿ ಸಿಕ್ಕಿತು?', 'Telugu': 'ఇది మీకు ఎక్కడ దొరికింది?'},
        {'en': 'Where is the way?', 'Malayalam': 'വഴി എങ്ങോട്ടാണ്?', 'Tamil': 'வழி எங்கே?', 'Hindi': 'रास्ता कहाँ है?', 'Kannada': 'ದಾರಿ ಎಲ್ಲಿದೆ?', 'Telugu': 'దారి ఎక్కడ?'},
        {'en': 'Where have you been?', 'Malayalam': 'നിങ്ങൾ എവിടെയായിരുന്നു?', 'Tamil': 'எங்கே போயிருந்தீர்கள்?', 'Hindi': 'आप इतने समय कहाँ थे?', 'Kannada': 'ಎಲ್ಲಿಗೆ ಹೋಗಿದ್ದಿರಿ?', 'Telugu': 'ఎక్కడ ఉన్నారు ఇంతసేపు?'},
        {'en': 'Where should we meet?', 'Malayalam': 'നമ്മൾ എവിടെ കാണണം?', 'Tamil': 'நாம் எங்கே சந்திக்கலாம்?', 'Hindi': 'हम कहाँ मिलें?', 'Kannada': 'ನಾವು ಎಲ್ಲಿ ಭೇಟಿಯಾಗೋಣ?', 'Telugu': 'మనం ఎక్కడ కలుద్దాం?'},
      ],
    ),

    // 📖 4. Phrases with 'WHAT' (Scrapbook Torn Notebook Deck)
    const ReelVocabCard(
      id: 'vocab_phrases_what',
      word: "Phrases with 'WHAT'",
      partOfSpeech: 'Phrases',
      phonetic: '/wɒt/',
      definitionEn: 'Most widely used expressions asking for information or clarity.',
      contextSentence: 'What do you think about our new plan?',
      nativeMeanings: {
        'Malayalam': "വിവരങ്ങളും കാര്യങ്ങളും അറിയാൻ ഉപയോഗിക്കുന്ന 'എന്ത്' (WHAT) വാചകങ്ങൾ.",
        'Tamil': "'என்ன' (WHAT) கொண்டு கேட்கப்படும் முக்கிய வாக்கியங்கள்.",
        'Hindi': "'क्या' (WHAT) से जानकारी मांगने वाले वाक्य.",
        'Kannada': "'ಏನು' (WHAT) ಬಳಸಿ ವಿವರ ಕೇಳುವ ವಾಕ್ಯಗಳು.",
        'Telugu': "'ఏమిటి' (WHAT) తో వివరాలు అడిగే వాక్యాలు.",
      },
      proTip: 'Keep your voice friendly and open when asking clarification with What.',
      phrases: [
        {'en': 'What is this?', 'Malayalam': 'ഇതെന്താണ്?', 'Tamil': 'இது என்ன?', 'Hindi': 'यह क्या है?', 'Kannada': 'ಇದೇನು?', 'Telugu': 'ఇది ఏమిటి?'},
        {'en': 'What happened?', 'Malayalam': 'എന്താണ് സംഭവിച്ചത്?', 'Tamil': 'என்ன நடந்தது?', 'Hindi': 'क्या हुआ?', 'Kannada': 'ಏನಾಯಿತು?', 'Telugu': 'ఏమైంది?'},
        {'en': 'What do you mean?', 'Malayalam': 'എന്താണ് ഉദ്ദേശിച്ചത്?', 'Tamil': 'என்ன சொல்ல வருகிறீர்கள்?', 'Hindi': 'आपका क्या मतलब है?', 'Kannada': 'ನಿಮ್ಮ ಅರ್ಥವೇನು?', 'Telugu': 'మీ ఉద్దేశం ఏమిటి?'},
        {'en': 'What should I do?', 'Malayalam': 'ഞാൻ എന്താണ് ചെയ്യേണ്ടത്?', 'Tamil': 'நான் என்ன செய்ய வேண்டும்?', 'Hindi': 'मुझे क्या करना चाहिए?', 'Kannada': 'ನಾನು ಏನು ಮಾಡಬೇಕು?', 'Telugu': 'నేను ఏమి చేయాలి?'},
        {'en': 'What time is it?', 'Malayalam': 'സമയം എത്രയായി?', 'Tamil': 'மணி என்ன?', 'Hindi': 'समय क्या हुआ है?', 'Kannada': 'ಸಮಯ ಎಷ್ಟು?', 'Telugu': 'సమయం ఎంతైంది?'},
        {'en': 'What is your name?', 'Malayalam': 'നിങ്ങളുടെ പേരെന്താണ്?', 'Tamil': 'உங்கள் பெயர் என்ன?', 'Hindi': 'आपका नाम क्या है?', 'Kannada': 'ನಿಮ್ಮ ಹೆಸರೇನು?', 'Telugu': 'మీ పేరు ఏమిటి?'},
        {'en': "What's going on?", 'Malayalam': 'എന്തൊക്കെയുണ്ട് വിശേഷങ്ങൾ?', 'Tamil': 'என்ன நடக்கிறது?', 'Hindi': 'क्या चल रहा है?', 'Kannada': 'ಏನು ನಡೆಯುತ್ತಿದೆ?', 'Telugu': 'ఏం జరుగుతోంది?'},
        {'en': 'What else?', 'Malayalam': 'വേറെന്താണ്?', 'Tamil': 'வேறு என்ன?', 'Hindi': 'और क्या?', 'Kannada': 'ಮತ್ತೇನು?', 'Telugu': 'ఇంకేమిటి?'},
      ],
    ),
    // 📖 5. Phrases with 'WHEN'
    const ReelVocabCard(
      id: 'vocab_phrases_when',
      word: "Phrases with 'WHEN'",
      partOfSpeech: 'Phrases',
      phonetic: '/wɛn/',
      definitionEn: 'Essential phrases for asking about time, schedules, and events.',
      contextSentence: 'When does the next bus arrive at this station?',
      nativeMeanings: {'Malayalam': "'എപ്പോൾ' (WHEN) ഉപയോഗിച്ചുള്ള വാക്യങ്ങൾ."},
      proTip: 'Great for planning meetings, travel, and daily routines.',
      phrases: [
        {'en': 'When are you coming?', 'Malayalam': 'നീ എപ്പോഴാണ് വരുന്നത്?', 'Tamil': 'நீங்கள் எப்போது வருகிறீர்கள்?', 'Hindi': 'आप कब आ रहे हैं?', 'Kannada': 'ನೀವು ಯಾವಾಗ ಬರುತ್ತಿದ್ದೀರಿ?', 'Telugu': 'మీరు ఎప్పుడు వస్తున్నారు?'},
        {'en': 'When did it happen?', 'Malayalam': 'അതെപ്പോഴാണ് സംഭവിച്ചത്?', 'Tamil': 'அது எப்போது நடந்தது?', 'Hindi': 'यह कब हुआ?', 'Kannada': 'ಅದು ಯಾವಾಗ ನಡೆಯಿತು?', 'Telugu': 'అది ఎప్పుడు జరిగింది?'},
        {'en': 'When does it start?', 'Malayalam': 'ഇത് എപ്പോഴാണ് തുടങ്ങുന്നത്?', 'Tamil': 'இது எப்போது தொடங்கும்?', 'Hindi': 'यह कब शुरू होता है?', 'Kannada': 'ಇದು ಯಾವಾಗ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ?', 'Telugu': 'ఇది ఎప్పుడు మొదలవుతుంది?'},
        {'en': 'When will you be free?', 'Malayalam': 'നീ എപ്പോൾ ഫ്രീ ആകും?', 'Tamil': 'நீங்கள் எப்போது ஃப்ரீயாக இருப்பீர்கள்?', 'Hindi': 'आप कब फ्री होंगे?', 'Kannada': 'ನೀವು ಯಾವಾಗ ಫ್ರೀ ಆಗುತ್ತೀರಿ?', 'Telugu': 'మీరు ఎప్పుడు ఖాళీగా ఉంటారు?'},
        {'en': 'When is your birthday?', 'Malayalam': 'നിന്റെ ജന്മദിനം എപ്പോഴാണ്?', 'Tamil': 'உங்கள் பிறந்தநாள் எப்போது?', 'Hindi': 'आपका जन्मदिन कब है?', 'Kannada': 'ನಿಮ್ಮ ಹುಟ್ಟುಹಬ್ಬ ಯಾವಾಗ?', 'Telugu': 'మీ పుట్టినరోజు ఎప్పుడు?'},
        {'en': 'When should I call?', 'Malayalam': 'ഞാൻ എപ്പോഴാണ് വിളിക്കേണ്ടത്?', 'Tamil': 'நான் எப்போது அழைக்க வேண்டும்?', 'Hindi': 'मुझे कब कॉल करना चाहिए?', 'Kannada': 'ನಾನು ಯಾವಾಗ ಕರೆ ಮಾಡಬೇಕು?', 'Telugu': 'నేను ఎప్పుడు కాల్ చేయాలి?'},
        {'en': 'When did you arrive?', 'Malayalam': 'നീ എപ്പോഴാണ് എത്തിയത്?', 'Tamil': 'நீங்கள் எப்போது வந்தீர்கள்?', 'Hindi': 'आप कब पहुँचे?', 'Kannada': 'ನೀವು ಯಾವಾಗ ತಲುಪಿದಿರಿ?', 'Telugu': 'మీరు ఎప్పుడు వచ్చారు?'},
        {'en': 'Since when?', 'Malayalam': 'എപ്പോൾ മുതൽ?', 'Tamil': 'எப்போதிலிருந்து?', 'Hindi': 'कब से?', 'Kannada': 'ಯಾವಾಗಿನಿಂದ?', 'Telugu': 'ఎప్పటి నుండి?'},
      ],
    ),
    // 📖 6. Phrases with 'WHY'
    const ReelVocabCard(
      id: 'vocab_phrases_why',
      word: "Phrases with 'WHY'",
      partOfSpeech: 'Phrases',
      phonetic: '/waɪ/',
      definitionEn: 'Natural ways to ask reasons and explanations politely.',
      contextSentence: 'Why is this road closed today?',
      nativeMeanings: {'Malayalam': "'എന്തുകൊണ്ട്' (WHY) ഉപയോഗിച്ചുള്ള വാക്യങ്ങൾ."},
      proTip: 'Soften "Why" questions with a polite tone in conversations.',
      phrases: [
        {'en': 'Why are you late?', 'Malayalam': 'എന്താ വൈകിയത്?', 'Tamil': 'ஏன் தாமதம்?', 'Hindi': 'आप देर से क्यों आए?', 'Kannada': 'ಏಕೆ ತಡವಾಯಿತು?', 'Telugu': 'ఎందుకు ఆలస్యమైంది?'},
        {'en': 'Why did you say that?', 'Malayalam': 'നീ എന്താ അങ്ങനെ പറഞ്ഞത്?', 'Tamil': 'ஏன் அப்படி சொன்னீர்கள்?', 'Hindi': 'आपने ऐसा क्यों कहा?', 'Kannada': 'ನೀವು ಹಾಗೆ ಏಕೆ ಹೇಳಿದಿರಿ?', 'Telugu': 'మీరు అలా ఎందుకు అన్నారు?'},
        {'en': 'Why not?', 'Malayalam': 'എന്തുകൊണ്ട് ആയിക്കൂടാ?', 'Tamil': 'ஏன் கூடாது?', 'Hindi': 'क्यों नहीं?', 'Kannada': 'ಏಕಾಗಬಾರದು?', 'Telugu': 'ఎందుకు కాదు?'},
        {'en': 'Why are you laughing?', 'Malayalam': 'നീ എന്തിനാ ചിരിക്കുന്നത്?', 'Tamil': 'ஏன் சிரிக்கிறீர்கள்?', 'Hindi': 'आप क्यों हँस रहे हैं?', 'Kannada': 'ನೀವು ಏಕೆ ನಗುತ್ತಿದ್ದೀರಿ?', 'Telugu': 'మీరు ఎందుకు నవ్వుతున్నారు?'},
        {'en': 'Why is it so expensive?', 'Malayalam': 'ഇതിന് എന്താ ഇത്ര വില?', 'Tamil': 'இது ஏன் இவ்வளவு விலை?', 'Hindi': 'यह इतना महंगा क्यों है?', 'Kannada': 'ಇದು ಏಕೆ ಇಷ್ಟು ದುಬಾರಿ?', 'Telugu': 'ఇది ఎందుకు ఇంత ఖరీదు?'},
        {'en': 'Why do you ask?', 'Malayalam': 'നീ എന്തിനാ ചോദിച്ചത്?', 'Tamil': 'ஏன் கேட்கிறீர்கள்?', 'Hindi': 'आप क्यों पूछ रहे हैं?', 'Kannada': 'ನೀವು ಏಕೆ ಕೇಳುತ್ತಿದ್ದೀರಿ?', 'Telugu': 'మీరు ఎందుకు అడుగుతున్నారు?'},
        {'en': 'Why did he leave?', 'Malayalam': 'അവൻ എന്തിനാ പോയത്?', 'Tamil': 'அவர் ஏன் சென்றார்?', 'Hindi': 'वह क्यों चला गया?', 'Kannada': 'ಅವರು ಏಕೆ ಹೋದರು?', 'Telugu': 'అతను ఎందుకు వెళ్ళాడు?'},
        {'en': "That's why!", 'Malayalam': 'അതുകൊണ്ടാണ്!', 'Tamil': 'அதனால்தான்!', 'Hindi': 'इसीलिए!', 'Kannada': 'ಅದಕ್ಕಾಗಿಯೇ!', 'Telugu': 'అందుకే!'},
      ],
    ),
    // 📖 7. Phrases with 'CAN'
    const ReelVocabCard(
      id: 'vocab_phrases_can',
      word: "Phrases with 'CAN'",
      partOfSpeech: 'Phrases',
      phonetic: '/kæn/',
      definitionEn: 'Polite requests, offers, and capability questions.',
      contextSentence: 'Can you please help me with this bag?',
      nativeMeanings: {'Malayalam': "'സാധിക്കുമോ / കഴിയുമോ' (CAN) വാക്യങ്ങൾ."},
      proTip: 'Using "Can you..." is the easiest way to make polite everyday requests.',
      phrases: [
        {'en': 'Can you help me?', 'Malayalam': 'എന്നെ ഒന്ന് സഹായിക്കാമോ?', 'Tamil': 'எனக்கு உதவ முடியுமா?', 'Hindi': 'क्या आप मेरी मदद कर सकते हैं?', 'Kannada': 'ನನಗೆ ಸಹಾಯ ಮಾಡುತ್ತೀರಾ?', 'Telugu': 'నాకు సహాయం చేయగలరా?'},
        {'en': 'Can I come in?', 'Malayalam': 'ഞാൻ അകത്തേക്ക് വരട്ടെ?', 'Tamil': 'நான் உள்ளே வரலாமா?', 'Hindi': 'क्या मैं अंदर आ सकता हूँ?', 'Kannada': 'ನಾನು ಒಳಗೆ ಬರಬಹುದೇ?', 'Telugu': 'నేను లోపలికి రావచ్చా?'},
        {'en': 'Can you hear me?', 'Malayalam': 'എന്നെ കേൾക്കുന്നുണ്ടോ?', 'Tamil': 'நான் பேசுவது கேட்கிறதா?', 'Hindi': 'क्या आप मुझे सुन सकते हैं?', 'Kannada': 'ನನ್ನ ಮಾತು ಕೇಳಿಸುತ್ತಿದೆಯೇ?', 'Telugu': 'నేను చెప్పేది వినిపిస్తోందా?'},
        {'en': 'Can you speak slowly?', 'Malayalam': 'ദയവായി പതുക്കെ സംസാരിക്കാമോ?', 'Tamil': 'கொஞ்சம் மெதுவாக பேச முடியுமா?', 'Hindi': 'क्या आप धीरे बोल सकते हैं?', 'Kannada': 'ಸ್ವಲ್ಪ ನಿಧಾನವಾಗಿ ಮಾತನಾಡುತ್ತೀರಾ?', 'Telugu': 'కొంచెం నెమ్మదిగా మాట్లాడగలరా?'},
        {'en': 'Can I pay by UPI?', 'Malayalam': 'യുപിഐ വഴി പണം നൽകാമോ?', 'Tamil': 'UPI மூலம் பணம் செலுத்தலாமா?', 'Hindi': 'क्या मैं UPI से भुगतान कर सकता हूँ?', 'Kannada': 'ನಾನು UPI ಮೂಲಕ ಪಾವತಿಸಬಹುದೇ?', 'Telugu': 'నేను UPI ద్వారా చెల్లించవచ్చా?'},
        {'en': 'Can we meet today?', 'Malayalam': 'നമുക്ക് ഇന്ന് കാണാമോ?', 'Tamil': 'நாம் இன்று சந்திக்கலாமா?', 'Hindi': 'क्या हम आज मिल सकते हैं?', 'Kannada': 'ನಾವು ಇಂದು ಭೇಟಿಯಾಗಬಹುದೇ?', 'Telugu': 'మనం ఈరోజు కలవవచ్చా?'},
        {'en': 'Can you repeat that?', 'Malayalam': 'അതൊന്ന് കൂടി പറയാമോ?', 'Tamil': 'அதை மீண்டும் சொல்ல முடியுமா?', 'Hindi': 'क्या आप वह दोहरा सकते हैं?', 'Kannada': 'ಅದನ್ನು ಮತ್ತೊಮ್ಮೆ ಹೇಳುತ್ತೀರಾ?', 'Telugu': 'దాన్ని మళ్ళీ చెప్పగలరా?'},
        {'en': 'I can do it!', 'Malayalam': 'എനിക്കിത് ചെയ്യാൻ സാധിക്കും!', 'Tamil': 'என்னால் இதை செய்ய முடியும்!', 'Hindi': 'मैं यह कर सकता हूँ!', 'Kannada': 'ನಾನು ಇದನ್ನು ಮಾಡಬಲ್ಲೆ!', 'Telugu': 'నేను ఇది చేయగలను!'},
      ],
    ),
    // 📖 8. Polite Everyday Phrases
    const ReelVocabCard(
      id: 'vocab_phrases_polite',
      word: "Polite Everyday Phrases",
      partOfSpeech: 'Phrases',
      phonetic: '/pəˈlaɪt/',
      definitionEn: 'Essential courteous phrases to sound friendly and confident.',
      contextSentence: 'Excuse me, could you tell me the way?',
      nativeMeanings: {'Malayalam': 'നിത്യജീവിതത്തിലെ മര്യാദയുള്ള വാക്യങ്ങൾ.'},
      proTip: 'Polite phrases immediately make native speakers eager to help you.',
      phrases: [
        {'en': 'Excuse me, please.', 'Malayalam': 'ക്ഷമിക്കണം, ഒന്ന് ശ്രദ്ധിക്കാമോ?', 'Tamil': 'மன்னிக்கவும்.', 'Hindi': 'सुनिए, कृपया.', 'Kannada': 'ಕ್ಷಮಿಸಿ, ದಯವಿಟ್ಟು.', 'Telugu': 'క్షమించండి, దయచేసి.'},
        {'en': 'I am really sorry.', 'Malayalam': 'എനിക്ക് ശരിക്കും വിഷമമുണ്ട് / ക്ഷമിക്കണം.', 'Tamil': 'மிகவும் வருந்துகிறேன்.', 'Hindi': 'मुझे वास्तव में खेद है.', 'Kannada': 'ನನಗೆ ನಿಜವಾಗಿಯೂ ಕ್ಷಮಿಸಿ.', 'Telugu': 'నన్ను క్షమించండి.'},
        {'en': 'No problem at all.', 'Malayalam': 'ഒരു കുഴപ്പവുമില്ല.', 'Tamil': 'ஒரு பிரச்சினையும் இல்லை.', 'Hindi': 'कोई बात नहीं.', 'Kannada': 'ಏನೂ ತೊಂದರೆ ಇಲ್ಲ.', 'Telugu': 'పర్వాలేదు, ఏం కాదు.'},
        {'en': 'Thank you so much!', 'Malayalam': 'വളരെയധികം നന്ദി!', 'Tamil': 'மிக்க நன்றி!', 'Hindi': 'आपका बहुत-बहुत धन्यवाद!', 'Kannada': 'ತುಂಬಾ ಧನ್ಯವಾದಗಳು!', 'Telugu': 'చాలా ధన్యవాదాలు!'},
        {'en': 'You are welcome.', 'Malayalam': 'സ്വാഗതം / സന്തോഷമേയുള്ളൂ.', 'Tamil': 'நல்வரவு / பரவாயில்லை.', 'Hindi': 'आपका स्वागत है.', 'Kannada': 'ನಿಮಗೆ ಸ್ವಾಗತ.', 'Telugu': 'మీకు స్వాగతం.'},
        {'en': 'Have a nice day!', 'Malayalam': 'നല്ലൊരു ദിവസം ആശംസിക്കുന്നു!', 'Tamil': 'இனிய நாளாக அமையட்டும்!', 'Hindi': 'आपका दिन शुभ हो!', 'Kannada': 'ನಿಮ್ಮ ದಿನ ಶುಭವಾಗಲಿ!', 'Telugu': 'మీ రోజు శుభప్రదంగా ఉండాలి!'},
        {'en': 'See you soon.', 'Malayalam': 'ഉടൻ കാണാം.', 'Tamil': 'விரைவில் சந்திப்போம்.', 'Hindi': 'जल्द ही मिलते हैं.', 'Kannada': 'ಶೀಘ್ರದಲ್ಲೇ ಸಿಗೋಣ.', 'Telugu': 'త్వరలో కలుద్దాం.'},
        {'en': 'Take care of yourself.', 'Malayalam': 'സ്വന്തം കാര്യം ശ്രദ്ധിക്കണേ.', 'Tamil': 'உங்களை கவனித்துக்கொள்ளுங்கள்.', 'Hindi': 'अपना ख्याल रखना.', 'Kannada': 'ನಿಮ್ಮ ಆರೋಗ್ಯ ನೋಡಿಕೊಳ್ಳಿ.', 'Telugu': 'మీ జాగ్రత్తగా ఉండండి.'},
      ],
    ),
    // 📖 9. Travel & Directions
    const ReelVocabCard(
      id: 'vocab_phrases_travel',
      word: "Travel & Directions",
      partOfSpeech: 'Phrases',
      phonetic: '/ˈtræv.əl/',
      definitionEn: 'Useful travel expressions for stations, buses, and directions.',
      contextSentence: 'How far is the railway station from here?',
      nativeMeanings: {'Malayalam': 'യാത്രയിലും വഴി ചോദിക്കാനും വേണ്ട വാക്യങ്ങൾ.'},
      proTip: 'Keep these phrases handy whenever exploring a new city.',
      phrases: [
        {'en': 'How far is it?', 'Malayalam': 'ഇവിടെ നിന്ന് എത്ര ദൂരമുണ്ട്?', 'Tamil': 'அது எவ்வளவு தூரம்?', 'Hindi': 'यह कितनी दूर है?', 'Kannada': 'ಅದು ಎಷ್ಟು ದೂರವಿದೆ?', 'Telugu': 'అది ఎంత దూరం?'},
        {'en': 'Which way to go?', 'Malayalam': 'ഏത് വഴിയിലൂടെയാണ് പോകേണ്ടത്?', 'Tamil': 'எந்த வழியில் செல்ல வேண்டும்?', 'Hindi': 'किस रास्ते से जाना है?', 'Kannada': 'ಯಾವ ದಾರಿಯಲ್ಲಿ ಹೋಗಬೇಕು?', 'Telugu': 'ఏ దారిలో వెళ్ళాలి?'},
        {'en': 'Stop right here.', 'Malayalam': 'ഇവിടെ നിർത്തൂ.', 'Tamil': 'இங்கே நிறுத்துங்கள்.', 'Hindi': 'यहीं रोकिए.', 'Kannada': 'ಇಲ್ಲಿಯೇ ನಿಲ್ಲಿಸಿ.', 'Telugu': 'ఇక్కడే ఆపండి.'},
        {'en': 'Turn left ahead.', 'Malayalam': 'മുന്നിൽ നിന്ന് ഇടത്തോട്ട് തിരിയുക.', 'Tamil': 'முன்னால் இடதுபுறம் திரும்பவும்.', 'Hindi': 'आगे से बाएं मुड़ें.', 'Kannada': 'ಮುಂದೆ ಎಡಕ್ಕೆ ತಿರುಗಿ.', 'Telugu': 'ముందు ఎడమవైపు తిరగండి.'},
        {'en': 'One ticket, please.', 'Malayalam': 'ദയവായി ഒരു ടിക്കറ്റ് തരൂ.', 'Tamil': 'ஒரு டிக்கெட் கொடுங்கள்.', 'Hindi': 'कृपया एक टिकट दीजिए.', 'Kannada': 'ದಯವಿಟ್ಟು ಒಂದು ಟಿಕೆಟ್ ಕೊಡಿ.', 'Telugu': 'దయచేసి ఒక టికెట్ ఇవ్వండి.'},
        {'en': 'Is this seat taken?', 'Malayalam': 'ഈ സീറ്റിൽ ആളുണ്ടോ?', 'Tamil': 'இந்த இருக்கை காலியாக உள்ளதா?', 'Hindi': 'क्या यह सीट खाली है?', 'Kannada': 'ಈ ಸೀಟು ಖಾಲಿ ಇದೆಯೇ?', 'Telugu': 'ఈ సీటు ఖాళీగా ఉందా?'},
        {'en': 'What is the fare?', 'Malayalam': 'ചാർജ് എത്രയാണ്?', 'Tamil': 'கட்டணம் எவ்வளவு?', 'Hindi': 'किराया कितना है?', 'Kannada': 'ಬಾಡಿಗೆ ಎಷ್ಟು?', 'Telugu': 'చార్జీ ఎంత?'},
        {'en': 'Have a safe trip!', 'Malayalam': 'സുരക്ഷിതമായ യാത്ര ആശംസിക്കുന്നു!', 'Tamil': 'பயணம் இனிதாகட்டும்!', 'Hindi': 'आपकी यात्रा सुरक्षित हो!', 'Kannada': 'ನಿಮ್ಮ ಪ್ರಯಾಣ ಸುರಕ್ಷಿತವಾಗಿರಲಿ!', 'Telugu': 'మీ ప్రయాణం సురక్షితంగా సాగాలి!'},
      ],
    ),
    // 📖 10. Shopping & Price
    const ReelVocabCard(
      id: 'vocab_phrases_shopping',
      word: "Shopping & Prices",
      partOfSpeech: 'Phrases',
      phonetic: '/ˈʃɒp.ɪŋ/',
      definitionEn: 'Confident shopping and bargaining phrases.',
      contextSentence: 'How much does this shirt cost?',
      nativeMeanings: {'Malayalam': 'ഷോപ്പിംഗിനും വില ചോദിക്കാനുമുള്ള വാക്യങ്ങൾ.'},
      proTip: 'Sound polite and confident when asking for discounts or sizes.',
      phrases: [
        {'en': 'How much is this?', 'Malayalam': 'ഇതിന് എത്ര വിലയാകും?', 'Tamil': 'இதன் விலை என்ன?', 'Hindi': 'यह कितने का है?', 'Kannada': 'ಇದರ ಬೆಲೆ ಎಷ್ಟು?', 'Telugu': 'దీని ధర ఎంత?'},
        {'en': 'Do you have a smaller size?', 'Malayalam': 'ഇതിന്റെ ചെറിയ സൈസ് ഉണ്ടോ?', 'Tamil': 'இதில் சிறிய அளவு உள்ளதா?', 'Hindi': 'क्या आपके पास छोटा साइज़ है?', 'Kannada': 'ಇದರಲ್ಲಿ ಚಿಕ್ಕ ಸೈಜ್ ಇದೆಯೇ?', 'Telugu': 'ఇందులో చిన్న సైజు ఉందా?'},
        {'en': 'Can I try it on?', 'Malayalam': 'എനിക്ക് ഇതൊന്ന് ഇട്ടു നോക്കാമോ?', 'Tamil': 'நான் இதை போட்டுப் பார்க்கலாமா?', 'Hindi': 'क्या मैं इसे पहन कर देख सकता हूँ?', 'Kannada': 'ನಾನು ಇದನ್ನು ಹಾಕಿ ನೋಡಬಹುದೇ?', 'Telugu': 'నేను దీనిని వేసుకొని చూడవచ్చా?'},
        {'en': 'It is too expensive.', 'Malayalam': 'ഇതിന് വില വളരെ കൂടുതലാണ്.', 'Tamil': 'விலை மிக அதிகமாக உள்ளது.', 'Hindi': 'यह बहुत महंगा है.', 'Kannada': 'ಇದು ತುಂಬಾ ದುಬಾರಿಯಾಗಿದೆ.', 'Telugu': 'ఇది చాలా ఖరీదుగా ఉంది.'},
        {'en': 'Any discount available?', 'Malayalam': 'വല്ല ഡിസ്കൗണ്ടും ഉണ്ടോ?', 'Tamil': 'தள்ளுபடி ஏதாவது உண்டா?', 'Hindi': 'कोई छूट मिलेगी क्या?', 'Kannada': 'ಏನಾದರೂ ರಿಯಾಯಿತಿ ಇದೆಯೇ?', 'Telugu': 'ఏదైనా డిస్కౌంట్ ఉందా?'},
        {'en': 'I am just looking.', 'Malayalam': 'ഞാൻ ജസ്റ്റ് നോക്കുകയാണ്.', 'Tamil': 'நான் சும்மா பார்க்கிறேன்.', 'Hindi': 'मैं बस देख रहा हूँ.', 'Kannada': 'ನಾನು ಸುಮ್ಮನೆ ನೋಡುತ್ತಿದ್ದೇನೆ.', 'Telugu': 'నేను ఊరికే చూస్తున్నాను.'},
        {'en': 'I will take this one.', 'Malayalam': 'ഞാൻ ഇതെടുക്കാം.', 'Tamil': 'நான் இதை எடுத்துக்கொள்கிறேன்.', 'Hindi': 'मैं यह लूँगा.', 'Kannada': 'ನಾನು ಇದನ್ನು ತೆಗೆದುಕೊಳ್ಳುತ್ತೇನೆ.', 'Telugu': 'నేను దీనిని తీసుకుంటాను.'},
        {'en': 'Give me the bill, please.', 'Malayalam': 'ദയവായി ബിൽ തരൂ.', 'Tamil': 'பில் கொடுங்கள்.', 'Hindi': 'कृपया बिल दीजिए.', 'Kannada': 'ದಯವಿಟ್ಟು ಬಿಲ್ ಕೊಡಿ.', 'Telugu': 'దయచేసి బిల్ ఇవ్వండి.'},
      ],
    ),
    const ReelVocabCard(
      id: 'vocab_resilient',
      word: 'Resilient',
      partOfSpeech: 'Adjective',
      phonetic: '/rɪˈzɪl.jənt/',
      definitionEn: 'Able to recover quickly from difficult conditions or setbacks.',
      contextSentence: 'She remained resilient despite facing numerous challenges during the interview process.',
      nativeMeanings: {
        'Malayalam': 'പ്രതിസന്ധികളെ അതിജീവിച്ച് പൂർവാധികം ശക്തിയോടെ തിരിച്ചുവരാൻ കഴിവുള്ള.',
        'Tamil': 'சிரமங்களை கடந்து மீண்டு வரும் திறன் கொண்ட.',
        'Hindi': 'कठिनाइयों से उबरकर पुनः मजबूत बनने में सक्षम; लचीला.',
      },
      proTip: 'Use in interviews to describe your mindset under high pressure.',
    ),
    const ReelVocabCard(
      id: 'vocab_hit_the_nail',
      word: 'Hit the nail on the head',
      partOfSpeech: 'Idiom',
      phonetic: '/hɪt ðə neɪl ɒn ðə hɛd/',
      definitionEn: 'To describe exactly what is causing a situation or problem; to be precisely right.',
      contextSentence: 'Your observation about our team communication hit the nail on the head.',
      nativeMeanings: {
        'Malayalam': 'കാര്യത്തിന്റെ കൃത്യമായ മർമ്മം പറയുക; ശരിയായ കാരണം കണ്ടെത്തുക.',
        'Tamil': 'சரியான காரணத்தை ஆணித்தரமாக சுட்டிக்காட்டுதல்.',
        'Hindi': 'बिल्कुल सही बात कहना; सटीक निशाना लगाना.',
      },
      proTip: 'A great everyday idiom for workplace meetings when agreeing strongly with a colleague.',
    ),
    const ReelVocabCard(
      id: 'vocab_meticulous',
      word: 'Meticulous',
      partOfSpeech: 'Adjective',
      phonetic: '/məˈtɪk.jə.ləs/',
      definitionEn: 'Showing great attention to detail; very careful and precise.',
      contextSentence: 'His meticulous preparation allowed him to present the proposal without a single flaw.',
      nativeMeanings: {
        'Malayalam': 'ഏറ്റവും സൂക്ഷ്മമായ കാര്യങ്ങളിൽ പോലും അതീവ ശ്രദ്ധ പുലർത്തുന്ന.',
        'Tamil': 'ஒவ்வொரு நுணுக்கத்திலும் மிகுந்த கவனம் செலுத்தும்.',
        'Hindi': 'हर छोटी बात पर बारीकी से ध्यान देने वाला; अति सावधान.',
      },
      proTip: 'A top power word to include in your resume to highlight your work quality.',
    ),
  ];

  // =========================================================================
  // 🧸 CURATED KIDS CONTENT DATASETS
  // =========================================================================

  static final List<ReelStoryCard> _curatedKidsStories = [
    const ReelStoryCard(
      id: 'kid_story_turtle',
      title: 'The Little Turtle Who Kept Walking 🐢',
      category: 'PATIENCE & PERSEVERANCE 🐢',
      paragraphs: [
        'A little green turtle wanted to see the golden summit castle high on the mountain.',
        'The fast rabbits chuckled and said: "You have tiny legs, you will never make it to the top!"',
        'The little turtle did not feel sad. Step by step, slow and steady, he kept walking forward.',
        'By evening, the turtle reached the mountain castle and watched the most glorious rainbow in the sky!',
      ],
      moralEn: 'Slow and steady progress always wins. Never give up on your dreams!',
      nativeMorals: {
        'Malayalam': 'പതുക്കെയാണെങ്കിലും ലക്ഷ്യബോധത്തോടെ മുന്നോട്ട് പോയാൽ വിജയം സുനിശ്ചിതമാണ്! 🐢🌈',
        'Tamil': 'விடாமுயற்சியுடன் தொடர்ந்து சென்றால் நிச்சயம் வெற்றி பெறலாம்! 🐢🌈',
        'Hindi': 'धैर्य और निरंतर प्रयास से कठिन से कठिन लक्ष्य भी हासिल हो जाता है! 🐢🌈',
      },
      keyVocab: [
        {'word': 'Steady', 'phonetic': '/ˈstɛd.i/', 'meaningEn': 'Moving at a constant and reliable speed'},
        {'word': 'Summit', 'phonetic': '/ˈsʌm.ɪt/', 'meaningEn': 'The highest point of a hill or mountain'},
      ],
      fullReadText:
          'A little green turtle wanted to see the summit castle. The fast rabbits said he could not do it. But the turtle walked step by step without stopping. By evening, he reached the golden summit castle and saw a glorious rainbow! Slow and steady wins the race!',
    ),
    const ReelStoryCard(
      id: 'kid_story_sharing_squirrel',
      title: 'Sammy Squirrel\'s Sweet Acorn 🐿️',
      category: 'SHARING & FRIENDSHIP 🌰',
      paragraphs: [
        'Sammy Squirrel found a giant golden acorn under the old oak tree.',
        'His tummy was hungry, but he saw his little friend Pip shivering in the cold breeze without food.',
        'Sammy smiled, split the big acorn in half, and handed the bigger piece to Pip.',
        'Pip smiled happily, and together they enjoyed the most delicious meal ever. Kindness makes everything sweeter!',
      ],
      moralEn: 'Sharing your blessings with friends brings twice as much joy to your own heart.',
      nativeMorals: {
        'Malayalam': 'നമ്മുടെ പക്കലുള്ളത് കൂട്ടുകാരുമായി പങ്കുവെക്കുമ്പോൾ ഇരട്ടി സന്തോഷം ലഭിക്കും! 🐿️💖',
        'Tamil': 'நண்பர்களுடன் பகிர்ந்து உண்ணும்போது மகிழ்ச்சி இரட்டிப்பாகும்! 🐿️💖',
        'Hindi': 'दूसरों के साथ बांटने से खुशियां दोगुनी हो जाती हैं! 🐿️💖',
      },
      keyVocab: [
        {'word': 'Shivering', 'phonetic': '/ˈʃɪv.ər.ɪŋ/', 'meaningEn': 'Shaking slightly because of cold or fear'},
        {'word': 'Delicious', 'phonetic': '/dɪˈlɪʃ.əs/', 'meaningEn': 'Highly pleasant to the taste'},
      ],
      fullReadText:
          'Sammy Squirrel found a big golden acorn. He saw his friend Pip cold and hungry. Sammy shared the acorn with Pip. Sharing food and friendship brings double happiness to everyone!',
    ),
  ];

  static final List<ReelSpeakChallengeCard> _curatedKidsSpeakChallenges = [
    const ReelSpeakChallengeCard(
      id: 'kid_speak_tiger',
      coachName: 'Sparky Tiger 🐯',
      coachAvatar: '🐯',
      situation: 'Meeting your tiger buddy in the flower meadow',
      coachPrompt: 'Sparky smiles and waves his paw! Say this friendly greeting into your mic:',
      targetSpeech: 'Hello Sparky, let us play together!',
      phoneticGuide: 'həˈləʊ ˈspɑːki lɛt ʌs pleɪ təˈɡɛðə',
      nativeGuidance: {
        'Malayalam': 'മൈക്കിലേക്ക് വ്യക്തമായി "Hello Sparky, let us play together!" എന്ന് പറയൂ!',
        'Tamil': 'தெளிவாக "Hello Sparky, let us play together!" என்று பேசுங்கள்!',
        'Hindi': 'माइक में स्पष्ट रूप से बोलें: "Hello Sparky, let us play together!"',
      },
      pointsReward: 25,
    ),
    const ReelSpeakChallengeCard(
      id: 'kid_speak_king',
      coachName: 'King Lion 🦁',
      coachAvatar: '🦁',
      situation: 'Climbing the Golden Mountain Summit',
      coachPrompt: 'King Lion roars proudly from the summit! Say this brave sentence aloud:',
      targetSpeech: 'I am ready to climb the golden mountain!',
      phoneticGuide: 'aɪ æm ˈrɛdi tuː klaɪm ðə ˈɡəʊldən ˈmaʊntɪn',
      nativeGuidance: {
        'Malayalam': 'ആത്മവിശ്വാസത്തോടെ ഉച്ചത്തിൽ പറയൂ: "I am ready to climb the golden mountain!"',
        'Tamil': 'தைரியமாக "I am ready to climb the golden mountain!" என்று கூறுங்கள்!',
        'Hindi': 'पूरे आत्मविश्वास से बोलें: "I am ready to climb the golden mountain!"',
      },
      pointsReward: 25,
    ),
    const ReelSpeakChallengeCard(
      id: 'kid_speak_panda',
      coachName: 'Pandy Panda 🐼',
      coachAvatar: '🐼',
      situation: 'Sharing snacks at the picnic table',
      coachPrompt: 'Pandy offers you a sweet bamboo cookie. Say thank you politely into the mic:',
      targetSpeech: 'Thank you for sharing with me!',
      phoneticGuide: 'θæŋk juː fɔː ˈʃeərɪŋ wɪð miː',
      nativeGuidance: {
        'Malayalam': 'മാന്യമായി നന്ദി പറയൂ: "Thank you for sharing with me!"',
        'Tamil': 'அன்புடன் நன்றி சொல்லுங்கள்: "Thank you for sharing with me!"',
        'Hindi': 'शालीनता से धन्यवाद कहें: "Thank you for sharing with me!"',
      },
      pointsReward: 25,
    ),
    const ReelSpeakChallengeCard(
      id: 'kid_speak_bunny',
      coachName: 'Bouncy Bunny 🐰',
      coachAvatar: '🐰',
      situation: 'Hopping high in the meadow',
      coachPrompt: 'Bouncy hops over a little stream! Say this energetic sentence:',
      targetSpeech: 'Look at me hop, I can jump so high!',
      phoneticGuide: 'lʊk æt miː hɒp aɪ kæn dʒʌmp səʊ haɪ',
      nativeGuidance: {
        'Malayalam': 'സന്തോഷത്തോടെ മൈക്കിലേക്ക് പറയൂ: "Look at me hop, I can jump so high!"',
        'Tamil': 'மகிழ்ச்சியாக "Look at me hop, I can jump so high!" என்று பேசுங்கள்!',
        'Hindi': 'उत्साह से बोलें: "Look at me hop, I can jump so high!"',
      },
      pointsReward: 25,
    ),
    const ReelSpeakChallengeCard(
      id: 'kid_speak_puppy',
      coachName: 'Puppy Max 🐶',
      coachAvatar: '🐶',
      situation: 'Playing fetch on the grass',
      coachPrompt: 'Max wags his tail eagerly holding his ball! Shout playfully:',
      targetSpeech: 'Fetch the red ball, good puppy!',
      phoneticGuide: 'fɛtʃ ðə rɛd bɔːl ɡʊd ˈpʌpi',
      nativeGuidance: {
        'Malayalam': 'നായക്കുട്ടിയോട് സ്നേഹത്തോടെ പറയൂ: "Fetch the red ball, good puppy!"',
        'Tamil': 'நட்போடு "Fetch the red ball, good puppy!" என்று கூறுங்கள்!',
        'Hindi': 'प्यार से बोलें: "Fetch the red ball, good puppy!"',
      },
      pointsReward: 25,
    ),
    const ReelSpeakChallengeCard(
      id: 'kid_speak_owl',
      coachName: 'Oliver Owl 🦉',
      coachAvatar: '🦉',
      situation: 'Saying good night under the stars',
      coachPrompt: 'Oliver watches over the kingdom! Whisper this gentle night greeting:',
      targetSpeech: 'Good night sweet stars, see you tomorrow!',
      phoneticGuide: 'ɡʊd naɪt swiːt stɑːz siː juː təˈmɒrəʊ',
      nativeGuidance: {
        'Malayalam': 'ഉറങ്ങാൻ പോകുമ്പോൾ പറയൂ: "Good night sweet stars, see you tomorrow!"',
        'Tamil': 'அமைதியாக "Good night sweet stars, see you tomorrow!" என்று சொல்லுங்கள்!',
        'Hindi': 'सोने से पहले बोलें: "Good night sweet stars, see you tomorrow!"',
      },
      pointsReward: 25,
    ),
  ];

  static final List<ReelVocabCard> _curatedKidsVocabCards = [
    const ReelVocabCard(
      id: 'kid_vocab_brave',
      word: 'Brave',
      partOfSpeech: 'Adjective 🦁',
      phonetic: '/breɪv/',
      definitionEn: 'Ready to face danger or pain with courage; not afraid.',
      contextSentence: 'The little lion was brave and stepped forward to speak English.',
      nativeMeanings: {
        'Malayalam': 'ധൈര്യശാലിയായ; ഒന്നിനെയും ഭയപ്പെടാത്ത.',
        'Tamil': 'துணிச்சலான; எதற்கும் அஞ்சாத.',
        'Hindi': 'बहादुर; साहसी.',
      },
      proTip: 'A superpower word for all our adventure explorers! 🦁✨',
    ),
    const ReelVocabCard(
      id: 'kid_vocab_kind',
      word: 'Kind',
      partOfSpeech: 'Adjective 💖',
      phonetic: '/kaɪnd/',
      definitionEn: 'Having or showing a friendly, generous, and considerate nature.',
      contextSentence: 'Pandy Panda is very kind and always shares his snacks with friends.',
      nativeMeanings: {
        'Malayalam': 'ദയയുള്ള; സ്നേഹവും കരുണയും കാണിക്കുന്ന.',
        'Tamil': 'அன்பான; கருணை உள்ளம் கொண்ட.',
        'Hindi': 'दयालु; परोपकारी स्वभाव वाला.',
      },
      proTip: 'Kindness is a language that everyone can understand! 💖🎋',
    ),
    const ReelVocabCard(
      id: 'kid_vocab_curious',
      word: 'Curious',
      partOfSpeech: 'Adjective 🧐',
      phonetic: '/ˈkjʊə.ri.əs/',
      definitionEn: 'Eager to know or learn something new and exciting.',
      contextSentence: 'The curious kitten explored every corner of the enchanted castle.',
      nativeMeanings: {
        'Malayalam': 'പുതിയ കാര്യങ്ങൾ അറിയാൻ അതീവ കൗതുകമുള്ള.',
        'Tamil': 'புதியவற்றை அறிந்துகொள்ள ஆர்வம் கொண்ட.',
        'Hindi': 'जिज्ञासु; नई चीजें सीखने को उत्सुक.',
      },
      proTip: 'Great learners are always curious and ask good questions! 🧐✨',
    ),
    const ReelVocabCard(
      id: 'kid_vocab_cheerful',
      word: 'Cheerful',
      partOfSpeech: 'Adjective ☀️',
      phonetic: '/ˈtʃɪə.fəl/',
      definitionEn: 'Noticeably happy, smiling, and optimistic.',
      contextSentence: 'Sparky Tiger woke up with a cheerful smile on his face.',
      nativeMeanings: {
        'Malayalam': 'സന്തോഷവും ഉന്മേഷവുമുള്ള; പ്രസന്നവദനനായ.',
        'Tamil': 'மகிழ்ச்சியான மற்றும் உற்சாகமான.',
        'Hindi': 'हंसमुख; प्रसन्नचित्त.',
      },
      proTip: 'A cheerful attitude makes learning English a breeze! ☀️🐯',
    ),
    const ReelVocabCard(
      id: 'kid_vocab_generous',
      word: 'Generous',
      partOfSpeech: 'Adjective 🎁',
      phonetic: '/ˈdʒɛn.ər.əs/',
      definitionEn: 'Showing a readiness to give more of something than is strictly necessary.',
      contextSentence: 'The generous squirrel gave two large acorns to his buddy.',
      nativeMeanings: {
        'Malayalam': 'ഉദാരമനസ്സുള്ള; മറ്റുള്ളവർക്ക് സന്തോഷത്തോടെ നൽകുന്ന.',
        'Tamil': 'தாராள மனப்பான்மை கொண்ட.',
        'Hindi': 'उदार; खुले दिल वाला.',
      },
      proTip: 'Being generous with words and smiles wins every heart! 🎁🐿️',
    ),
    const ReelVocabCard(
      id: 'kid_vocab_marvelous',
      word: 'Marvelous',
      partOfSpeech: 'Adjective ✨',
      phonetic: '/ˈmɑː.vəl.əs/',
      definitionEn: 'Causing great wonder; extraordinary and extremely good.',
      contextSentence: 'You did a marvelous job speaking English today!',
      nativeMeanings: {
        'Malayalam': 'അത്ഭുതകരമായ; അതിവിശിഷ്ടമായ.',
        'Tamil': 'அற்புதமான; பிரமிக்கத்தக்க.',
        'Hindi': 'अद्भुत; शानदार.',
      },
      proTip: 'Use "marvelous" instead of just "good" when praising your friends! ✨🌟',
    ),
  ];
}
