import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

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
    return nativeMorals[lang] ??
        nativeMorals['Malayalam'] ??
        nativeMorals['English'] ??
        moralEn;
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
    return nativeTips[lang] ??
        nativeTips['Malayalam'] ??
        nativeTips['English'] ??
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
    return nativeGuidance[lang] ??
        nativeGuidance['Malayalam'] ??
        nativeGuidance['English'] ??
        'Speak naturally into the microphone!';
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

  const ReelVocabCard({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.phonetic,
    required this.definitionEn,
    required this.contextSentence,
    required this.nativeMeanings,
    required this.proTip,
  });

  String getMeaning(String lang) {
    return nativeMeanings[lang] ??
        nativeMeanings['Malayalam'] ??
        nativeMeanings['English'] ??
        definitionEn;
  }
}

/// 🧠 Central Engine for Stories, Interview Vault, Speaking & Vocab Reels
class PocketReelsContentEngine {
  static final Set<String> _viewedItemIds = {};
  static bool _initialized = false;
  static final math.Random _random = math.Random();

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('pm_viewed_content_ids') ?? [];
      _viewedItemIds.addAll(saved);
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

  /// ⚡ Get Power Vocabulary Batch
  static List<ReelVocabCard> getVocabCards({int count = 4}) {
    final unseen = _curatedVocabCards.where((v) => !_viewedItemIds.contains(v.id)).toList();
    unseen.shuffle(_random);
    if (unseen.length >= count) return unseen.take(count).toList();

    final seen = _curatedVocabCards.where((v) => _viewedItemIds.contains(v.id)).toList();
    seen.shuffle(_random);
    return [...unseen, ...seen].take(count).toList();
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
