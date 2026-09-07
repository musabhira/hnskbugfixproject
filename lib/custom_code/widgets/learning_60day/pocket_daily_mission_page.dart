import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/stage_peer_matchmaker.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_battle_arena_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_library_page.dart';

/// 📚 Model for Daily 10 Vocabulary Words to Memorize (Multilingual Support)
class DailyVocabItem {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String malayalamMeaning;
  final String tamilMeaning;
  final String hindiMeaning;
  final String teluguMeaning;
  final String kannadaMeaning;
  final String exampleSentence;
  final String phonetic;

  const DailyVocabItem({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.malayalamMeaning,
    this.tamilMeaning = '',
    this.hindiMeaning = '',
    this.teluguMeaning = '',
    this.kannadaMeaning = '',
    required this.exampleSentence,
    required this.phonetic,
  });

  String getMeaning(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return tamilMeaning.isNotEmpty ? tamilMeaning : malayalamMeaning;
      case 'hindi':
        return hindiMeaning.isNotEmpty ? hindiMeaning : malayalamMeaning;
      case 'telugu':
        return teluguMeaning.isNotEmpty ? teluguMeaning : malayalamMeaning;
      case 'kannada':
        return kannadaMeaning.isNotEmpty ? kannadaMeaning : malayalamMeaning;
      case 'malayalam':
      default:
        return malayalamMeaning;
    }
  }
}

/// 🎯 Comprehensive Interactive Daily English Mission Experience
class PocketDailyMissionPage extends StatefulWidget {
  final int day;
  final VoidCallback? onMissionCompleted;

  const PocketDailyMissionPage({
    super.key,
    required this.day,
    this.onMissionCompleted,
  });

  @override
  State<PocketDailyMissionPage> createState() => _PocketDailyMissionPageState();
}

class _PocketDailyMissionPageState extends State<PocketDailyMissionPage> {
  final FlutterTts _tts = FlutterTts();

  // ⏱️ Shared 60-Minute Daily Practice Timer Service
  final PocketMissionTimerService _timerService = PocketMissionTimerService.instance;

  // Checklist Subtasks Progress
  bool _hubChatVerified = false;
  bool _peerCallVerified = false;
  bool _vocabMemorized = false;
  bool _readingNotesCompleted = false;
  bool _revisionQuizPassed = false;
  bool _defenseTrapArmed = false;
  bool _trialRaidLaunched = false;

  // Quiz state
  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  // 🌐 Multilingual Category Preferences (Audio Requirement)
  static const List<String> kSupportedLanguages = [
    'Malayalam',
    'Tamil',
    'Hindi',
    'Telugu',
    'Kannada',
  ];

  String _selectedLanguage = 'Malayalam';
  bool _isStorySpeaking = false;

  static const String _kDay1StoryText =
      'A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others. A wise mentor approached him and smiled. Look at this bamboo, the mentor said. For four years, its roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky! Your daily English practice is just like that seed. Every day you speak, read, and listen for sixty minutes, you are building unseen roots. Soon, your fluency will soar higher than you ever imagined. The student took a deep breath, spoke his first sentence with courage, and stepped fearlessly onto his ninety day path.';

  static const String _kDay1StoryFormatted =
      '🌱 Part 1: The Hesitant Learner\n'
      'A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others.\n\n'
      '🎋 Part 2: The Wisdom of the Bamboo\n'
      'A wise mentor approached him and smiled. "Look at this bamboo," the mentor said. "For four years, its roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky!"\n\n'
      '✨ Part 3: The 90-Day Secret\n'
      '"Your daily English practice is just like that seed. Every day you speak, read, and listen for sixty minutes, you are building unseen roots. Soon, your fluency will soar higher than you ever imagined."\n\n'
      '🚀 Part 4: The First Step\n'
      'The student took a deep breath, spoke his first sentence with courage, and stepped fearlessly onto his 90-day path.';

  static const String _kDay2StoryText =
      'Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow. One day, his grandfather handed him an empty notebook with golden edges. Marcus, the old man said gently, we do not decide our future. We decide our daily habits, and our habits decide our future. Dedicate the very first sixty minutes of your sunrise to what you wish to master. Marcus accepted the wisdom. He placed the notebook on his desk and woke up thirty minutes earlier each dawn. In the quiet morning, he read aloud, spoke to the mirror, and practiced his vocabulary sentences. Within weeks, what once felt impossible became effortless. Marcus realized that mastery does not require giant leaps, only unbroken daily rituals.';

  static const String _kDay2StoryFormatted =
      '🌅 Part 1: The Evening Struggle\n'
      'Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow.\n\n'
      '📖 Part 2: The Golden Notebook\n'
      'One day, his grandfather handed him an empty notebook with golden edges. "Marcus," the old man said gently, "we do not decide our future. We decide our daily habits, and our habits decide our future."\n\n'
      '☀️ Part 3: The Sunrise Rule\n'
      '"Dedicate the very first sixty minutes of your sunrise to what you wish to master." Marcus accepted the wisdom. He woke up thirty minutes earlier each dawn to read aloud and speak vocabulary sentences.\n\n'
      '🏆 Part 4: Unbroken Rituals\n'
      'Within weeks, what once felt impossible became effortless. Marcus realized that mastery does not require giant leaps, only unbroken daily rituals.';

  static const String _kDay3StoryText =
      'Elena felt overwhelmed by constant notifications and shallow digital noise. She tried studying English while scrolling through social media, but her mind remained scattered. One evening, an architect named Paul showed her the blueprints of a grand cathedral. Notice how thick the stone walls are, Paul said. Without silence and deep focus, monumental beauty cannot be constructed. Elena decided to become the architect of her own mind. She placed her phone in another room, entered her study chamber, and gave sixty minutes of unbroken concentration to English speech and debate. In that deep silence, her cognitive abilities flourished. She realized that shallow multitasking is worthless, but sustained immersion builds unstoppable fluency.';

  static const String _kDay3StoryFormatted =
      '📵 Part 1: The Scattered Mind\n'
      'Elena felt overwhelmed by constant notifications and shallow digital noise. She tried studying English while scrolling through social media, but her mind remained scattered.\n\n'
      '🏛️ Part 2: The Cathedral Blueprints\n'
      'An architect named Paul showed her the blueprints of a grand cathedral. "Notice how thick the stone walls are," Paul said. "Without silence and deep focus, monumental beauty cannot be constructed."\n\n'
      '🕯️ Part 3: Deep Immersion\n'
      'Elena decided to become the architect of her own mind. She placed her phone in another room and gave 60 minutes of unbroken concentration to English speech and debate.\n\n'
      '💎 Part 4: The Power of Focus\n'
      'In that deep silence, her cognitive abilities flourished. She realized that shallow multitasking is worthless, but sustained immersion builds unstoppable fluency.';

  static const String _kDay4StoryText =
      'In the town council assembly, young Kaelen was passionate about protecting the ancient forest. At first, he raised his voice, interrupted his opponents, and demanded immediate agreement. The council rejected his proposal. An elder diplomat pulled Kaelen aside and offered advice. Persuasion is not a battlefield of loud voices, Kaelen; it is a bridge built of diplomatic precision, careful listening, and eloquent concession. The next morning, Kaelen spoke calmly. He acknowledged the economic concerns of the council members before presenting his sustainable plan. By choosing articulate words over anger, he built consensus. The council unanimously approved the protection decree. Kaelen learned that true power in English communication lies not in shouting, but in the art of persuasive reasoning.';

  static const String _kDay4StoryFormatted =
      '⚡ Part 1: The Loud Approach\n'
      'In the town council assembly, young Kaelen was passionate about protecting the ancient forest. He raised his voice and interrupted opponents, but the council rejected his plea.\n\n'
      '🤝 Part 2: The Diplomat\'s Secret\n'
      'An elder diplomat offered advice: "Persuasion is not a battlefield of loud voices. It is a bridge built of diplomatic precision, careful listening, and eloquent concession."\n\n'
      '🕊️ Part 3: Articulate Reason\n'
      'The next morning, Kaelen spoke calmly. He acknowledged economic concerns before presenting his sustainable plan with poise and articulate clarity.\n\n'
      '🏆 Part 4: Unanimous Agreement\n'
      'The council unanimously approved the decree. Kaelen learned that true English mastery lies not in volume, but in persuasive empathy and reasoned dialogue.';

  static const String _kDay5StoryText =
      'The merchant galleon was trapped in a fierce midnight gale near treacherous coral reefs. Panic spread among the sailors as waves crashed over the wooden deck. Amidst the chaos, Captain Sarah climbed to the helm. She did not panic. With unwavering fortitude and decisive English commands, she directed the crew: Secure the main sail immediately! Man the bilge pumps! Navigator, plot the course toward Citadel Harbor! Her calm voice became a beacon of certainty in the dark. Every crew member executed their role with strategic precision. By dawn, the ship glided smoothly into the calm waters of the harbor. The sailors cheered. Sarah reminded them that in every great storm of life, decisive communication and resolute courage turn adversity into triumph.';

  static const String _kDay5StoryFormatted =
      '🌊 Part 1: Midnight Chaos\n'
      'The merchant galleon was trapped in a fierce midnight gale near treacherous reefs. Panic spread among the sailors as waves crashed over the wooden deck.\n\n'
      '⚓ Part 2: The Calm Commander\n'
      'Captain Sarah climbed to the helm with unwavering fortitude. She did not panic. With decisive English commands, she directed the crew through the howling storm.\n\n'
      '🧭 Part 3: Strategic Precision\n'
      '"Secure the main sail immediately! Man the bilge pumps! Navigator, plot the course toward Citadel Harbor!" Her calm voice became a beacon of certainty.\n\n'
      '🏰 Part 4: The Safe Harbor\n'
      'By dawn, the ship glided safely into Citadel Harbor. Sarah proved that in every storm, decisive communication and resolute courage turn adversity into triumph.';

  static const String _kDay6StoryText =
      'Two rival merchant syndicates gathered at the high mountain summit of Alveron to negotiate vital trade routes. An escalating dispute over waterway access threatened to plunge the valley into conflict. For hours, tempers flared and talks reached a tense impasse as each side made unilateral demands. Alistair, a seasoned diplomatic envoy, stepped between the opposing delegations. Instead of taking sides, he offered a pragmatic compromise: "If we had succumbed to anger, our ships would have remained stranded in harbor. But if we establish an equitable joint council with stipulated seasonal tariffs, both merchant houses will prosper." His measured cadence and precise legal clarity disarmed hostility. Both syndicates concurred, signing the Alveron Accord before nightfall. Alistair demonstrated that when the stakes are highest, articulate negotiation turns bitter deadlock into enduring partnership.';

  static const String _kDay6StoryFormatted =
      '🏔️ Part 1: The Mountain Impasse\n'
      'Two rival merchant syndicates gathered at the high summit of Alveron. An escalating dispute over waterway access reached a bitter deadlock as each side made unilateral demands.\n\n'
      '⚖️ Part 2: The Pragmatic Envoy\n'
      'Alistair, a seasoned diplomatic envoy, stepped forward with poise. Instead of matching hostility, he reframed the dispute with legal precision and unwavering neutrality.\n\n'
      '🤝 Part 3: The Art of Compromise\n'
      '"If we had succumbed to anger, our ships would have remained stranded. But if we establish an equitable joint council with stipulated tariffs, both houses will prosper."\n\n'
      '📜 Part 4: The Alveron Accord\n'
      'Both delegations concurred and signed the accord before nightfall. Alistair proved that articulate, high-stakes negotiation turns bitter gridlock into lasting victory.';

  static const String _kDay7StoryText =
      'Before the Great Academic Forum of Lysander, thousands of skeptical scholars waited in heavy silence. Young researcher Mira was tasked with presenting a revolutionary theory on sustainable clean energy. Never in history had a novice addressed this venerated council. As she stood before the podium, her heart raced, yet she channeled her nervous energy into profound rhetorical eloquence. "Rarely do we encounter moments where tradition and progress must forge a new alliance," Mira began, her voice resonating across the vaulted marble hall. She weaved rigorous empirical evidence with compelling moral purpose. Not only did she address every counter-argument with perspicacious clarity, but she also inspired the audience with a vision of global renewal. When she concluded, the once-hostile auditorium erupted into an overwhelming standing ovation. Mira proved that true eloquence is not ornamental vanity, but the courageous resonance of conviction and truth.';

  static const String _kDay7StoryFormatted =
      '🏛️ Part 1: The Skeptical Assembly\n'
      'Before the Great Academic Forum of Lysander, thousands of skeptical scholars waited in silence. Young researcher Mira was tasked with defending a revolutionary clean energy theory.\n\n'
      '⚡ Part 2: The Inverted Opening\n'
      'As she stood before the podium, she channeled nervous energy into rhetorical mastery: "Never in history have we stood at such a crossroads. Rarely do we encounter moments where tradition and progress must unite."\n\n'
      '🔬 Part 3: Logic and Ethos\n'
      'Mira weaved rigorous empirical proof with compelling moral purpose. Not only did she address every critique with perspicacious insight, but she also electrified the hall.\n\n'
      '🌟 Part 4: The Standing Ovation\n'
      'The once-cynical assembly erupted into an overwhelming standing ovation. Mira demonstrated that authentic eloquence is the courageous echo of conviction and truth.';

  static const String _kDay8StoryText =
      'At the International Symposium on Future Ethics in Geneva, world leaders struggled with a complex dilemma: balancing rapid artificial intelligence autonomy with human dignity. The debate was paralyzed by a false dichotomy between reckless technological velocity and rigid technological stagnation. Dr. Evelyn Vance, a philosopher and systems architect, approached the rostrum. "It is imperative that our generation synthesize visionary technological innovation with timeless ethical wisdom," Dr. Vance declared. She proposed an adaptive global governance framework that empowered autonomous systems while safeguarding human well-being as a paramount prerequisite. Rather than viewing machine intelligence as an adversary, she articulated an enlightened paradigm where technology acts as an amplifier of human compassion. Her address synthesized philosophy, law, and science with sublime intellectual rigor. The assembly adopted the Geneva Synthesis by acclamation, establishing an enduring blueprint for generations to come.';

  static const String _kDay8StoryFormatted =
      '🌐 Part 1: The Global Dilemma\n'
      'At the International Symposium on Future Ethics, global delegates were paralyzed by a false dichotomy: reckless technological speed versus rigid technological stagnation.\n\n'
      '🧠 Part 2: The Subjunctive Call\n'
      'Dr. Evelyn Vance approached the rostrum with sublime rigor: "It is imperative that our generation synthesize visionary innovation with timeless ethical wisdom."\n\n'
      '🛡️ Part 3: The Enlightened Paradigm\n'
      'She proposed an adaptive governance framework safeguarding human dignity as a prerequisite. Rather than fearing progress, she articulated a paradigm where innovation amplifies human compassion.\n\n'
      '✨ Part 4: The Geneva Synthesis\n'
      'The delegates adopted the charter by acclamation. Dr. Vance proved that visionary problem-solvers synthesize disparate complexities into a harmonious tomorrow.';

  String get _storyText {
    switch (widget.day) {
      case 2:
        return _kDay2StoryText;
      case 3:
        return _kDay3StoryText;
      case 4:
        return _kDay4StoryText;
      case 5:
        return _kDay5StoryText;
      case 6:
        return _kDay6StoryText;
      case 7:
        return _kDay7StoryText;
      case 8:
        return _kDay8StoryText;
      default:
        return _kDay1StoryText;
    }
  }

  String get _storyFormatted {
    switch (widget.day) {
      case 2:
        return _kDay2StoryFormatted;
      case 3:
        return _kDay3StoryFormatted;
      case 4:
        return _kDay4StoryFormatted;
      case 5:
        return _kDay5StoryFormatted;
      case 6:
        return _kDay6StoryFormatted;
      case 7:
        return _kDay7StoryFormatted;
      case 8:
        return _kDay8StoryFormatted;
      default:
        return _kDay1StoryFormatted;
    }
  }

  String get _storyTitle {
    switch (widget.day) {
      case 2:
        return 'DAY 2 STORY: THE MORNING RITUAL OF CHAMPIONS';
      case 3:
        return 'DAY 3 STORY: THE ARCHITECT OF SILENCE';
      case 4:
        return 'DAY 4 STORY: THE ART OF THE COUNTER-ARGUMENT';
      case 5:
        return 'DAY 5 STORY: THE BEACON IN THE STORM';
      case 6:
        return 'DAY 6 STORY: THE SUMMIT OF RESOLUTION';
      case 7:
        return 'DAY 7 STORY: THE ECHO OF AN IDEA';
      case 8:
        return 'DAY 8 STORY: THE CHRONICLE OF TOMORROW';
      default:
        return 'DAY 1 STORY: THE SEED OF CONFIDENCE';
    }
  }

  String get _storySubtitle {
    switch (widget.day) {
      case 2:
        return 'The Power of Habits & Morning Routine Practice';
      case 3:
        return 'Deep Work & Overcoming Digital Distractions';
      case 4:
        return 'Persuasive Reasoning & Diplomatic Debate';
      case 5:
        return 'Decisive Leadership & Resilience in Crisis';
      case 6:
        return 'High-Stakes Negotiation & Resolving Impasses';
      case 7:
        return 'Rhetorical Oratory & Swaying a Skeptical Assembly';
      case 8:
        return 'Complex Problem-Solving & Philosophical Synthesis';
      default:
        return 'Aloud Reading & Pronunciation Practice';
    }
  }

  String get _storyIcon {
    switch (widget.day) {
      case 2:
        return '⏰';
      case 3:
        return '🏛️';
      case 4:
        return '🤝';
      case 5:
        return '⚓';
      case 6:
        return '🏔️';
      case 7:
        return '🏛️';
      case 8:
        return '🌐';
      default:
        return '🎋';
    }
  }

  String get _storyQuotePreview {
    switch (widget.day) {
      case 2:
        return '"Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow. One day, his grandfather handed him an empty notebook: \'We do not decide our future. We decide our daily habits...\'"';
      case 3:
        return '"Elena felt overwhelmed by constant notifications and shallow digital noise. She tried studying English while scrolling through social media, but her mind remained scattered. One evening, an architect named Paul showed her the blueprints of a grand cathedral..."';
      case 4:
        return '"In the town council assembly, young Kaelen was passionate about protecting the ancient forest. He raised his voice and interrupted opponents, but the council rejected his plea. An elder diplomat offered advice: \'Persuasion is not a battlefield of loud voices...\'"';
      case 5:
        return '"The merchant galleon was trapped in a fierce midnight gale near treacherous coral reefs. Amidst the chaos, Captain Sarah climbed to the helm with unwavering fortitude: \'Secure the main sail immediately! Man the bilge pumps! Navigator, plot the course toward Citadel Harbor!\'"';
      case 6:
        return '"Two rival merchant syndicates gathered at the high summit of Alveron. Talks reached a tense impasse as each side made unilateral demands. Envoy Alistair stepped forward: \'If we had succumbed to anger, our ships would have remained stranded in harbor...\'"';
      case 7:
        return '"Before the Great Academic Forum of Lysander, thousands of skeptical scholars waited in silence. Mira stood before the podium: \'Rarely do we encounter moments where tradition and progress must unite. Not only did she address every critique with perspicacious clarity...\'"';
      case 8:
        return '"At the International Symposium on Future Ethics in Geneva, world leaders debated AI autonomy and human dignity. Dr. Vance approached the rostrum: \'It is imperative that our generation synthesize technological velocity with timeless ethical wisdom...\'"';
      default:
        return '"A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others. A wise mentor approached him: \'For four years, the bamboo roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky!\'"';
    }
  }

  String get _grammarRuleTitle {
    switch (widget.day) {
      case 2:
        return 'Rule 2: Adverbs of Frequency (Always, Usually...)';
      case 3:
        return 'Rule 3: Modals of Obligation (Must, Should, Ought to)';
      case 4:
        return 'Rule 4: First Conditional (If + Present, Will + Verb)';
      case 5:
        return 'Rule 5: Present Perfect vs Simple Past';
      case 6:
        return 'Rule 6: Third Conditional (Past Unreal Situations)';
      case 7:
        return 'Rule 7: Inversion for Rhetorical Emphasis (Rarely, Never)';
      case 8:
        return 'Rule 8: Subjunctive Mood & Formal Conditional Stems';
      default:
        return 'Rule 1: Sentence Structure (S + V + O)';
    }
  }

  String get _quizQuestion {
    switch (widget.day) {
      case 2:
        return 'Q: Which sentence uses the adverb of frequency correctly?';
      case 3:
        return 'Q: Which sentence expresses a strict obligation/necessity?';
      case 4:
        return 'Q: Which sentence correctly follows the First Conditional structure?';
      case 5:
        return 'Q: Which sentence uses the Present Perfect tense for ongoing experience?';
      case 6:
        return 'Q: Which sentence correctly uses the Third Conditional for an unreal past event?';
      case 7:
        return 'Q: Which sentence correctly uses grammatical inversion for rhetorical emphasis?';
      case 8:
        return 'Q: Which sentence correctly employs the Subjunctive Mood in formal English?';
      default:
        return 'Q: Which sentence follows the correct English "Subject + Verb + Object" order?';
    }
  }

  List<String> get _quizOptions {
    switch (widget.day) {
      case 2:
        return [
          'I always practice speaking in the morning.',
          'I practice always speaking in the morning.',
          'Always I practice in the morning speaking.',
        ];
      case 3:
        return [
          'You must eliminate distractions to achieve deep immersion.',
          'You might eliminate distractions to achieve deep immersion.',
          'You could eliminate distractions to achieve deep immersion.',
        ];
      case 4:
        return [
          'If you practice persuasive debate, you will build consensus.',
          'If you will practice persuasive debate, you build consensus.',
          'If you practiced persuasive debate, you will build consensus.',
        ];
      case 5:
        return [
          'I have mastered strategic leadership over five days of practice.',
          'I mastered strategic leadership since five days of practice.',
          'I have master strategic leadership over five days of practice.',
        ];
      case 6:
        return [
          'If we had acted sooner, we would have avoided the impasse.',
          'If we acted sooner, we would avoid the impasse.',
          'If we would have acted sooner, we had avoided the impasse.',
        ];
      case 7:
        return [
          'Rarely have I witnessed such profound and articulate eloquence.',
          'Rarely I have witnessed such profound and articulate eloquence.',
          'Rarely did I witnessed such profound and articulate eloquence.',
        ];
      case 8:
        return [
          'It is imperative that every leader be present at the summit.',
          'It is imperative that every leader is present at the summit.',
          'It is imperative that every leader was present at the summit.',
        ];
      default:
        return [
          'She reads books diligently.',
          'She books reads diligently.',
          'Reads she books diligently.',
        ];
    }
  }

  String _getGrammarRuleExplanation(String lang) {
    if (widget.day == 8) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'உயர்நிலை ஆங்கிலத்தில் Subjunctive Mood பயன்பாடு: "It is imperative that he be present." (is/was அல்ல!).\n• சரியான வாக்கியம்: "It is essential that our team synthesize ethical solutions."\n• சர்வதேச உயர்மட்ட மாநாடுகளிலும் ராஜதந்திர உரைகளிலும் இது பயன்படுத்தப்படுகிறது.';
        case 'hindi':
          return 'उच्च-स्तरीय और औपचारिक अंग्रेजी में Subjunctive Mood का प्रयोग होता है: "It is imperative that he be present." (is/was नहीं, मूल verb "be" लगाएं)।\n• सही वाक्य: "It is vital that our team synthesize visionary ideas."\n• राजनयिक सम्मेलनों और वैश्विक संवाद में यह अनिवार्य है।';
        case 'telugu':
          return 'అధికారిక మరియు ఉన్నత స్థాయి ఇంగ్లీషులో Subjunctive Mood (It is imperative that + Base Verb) వాడాలి.\n• సరైనది: "It is imperative that every leader be present." (is/was వాడకూడదు)\n• ఉన్నత సంభాషణల్లో మరియు సదస్సుల్లో ఇది అత్యంత ముఖ్యం.';
        case 'kannada':
          return 'ಅತ್ಯಂತ ಔಪಚಾರಿಕ ಹಾಗೂ ಉನ್ನತ ಮಟ್ಟದ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ Subjunctive Mood ಬಳಸಿ: "It is imperative that he be present."\n• ಸರಿಯಾದ ವಾಕ್ಯ: "It is essential that we synthesize new solutions."\n• ಅಧಿಕೃತ ಸಭೆಗಳಲ್ಲಿ ಪ್ರಭಾವಿ ಸಂವಾದಕ್ಕೆ ಇದು ನೆರವಾಗುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'The Subjunctive Mood expresses formal urgency, ethical commands, or visionary demands. Following "imperative / essential / vital that", always use the BASE VERB (be, speak, synthesize) without third-person -s.\n• Correct: "It is imperative that every leader be present." (NOT "is")\n• Correct: "It is vital that she speak with clarity." (NOT "speaks")';
      }
    }

    if (widget.day == 7) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'பேச்சிற்கு கம்பீரமும் அழுத்தமும் சேர்க்க Inversion (Rarely, Never, Seldom + Auxiliary Verb + Subject) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "Rarely have I witnessed such profound eloquence."\n• வழக்கமான வாக்கியத்தை விட பொது மேடைகளில் இது அதிக ஆளுமையைத் தரும்.';
        case 'hindi':
          return 'भाषण में गाम्भीर्य और प्रभाव डालने के लिए Inversion का प्रयोग करें: Rarely/Never + Auxiliary Verb + Subject + Main Verb.\n• सही वाक्य: "Rarely have I witnessed such profound eloquence."\n• यह सामान्य वाक्य की तुलना में अधिक गरिमामयी और प्रभावशाली लगता है।';
        case 'telugu':
          return 'మాట్లాడేటప్పుడు మాటలకు బలం మరియు గాంభీర్యం తెచ్చేందుకు Inversion (Rarely/Never + సహాయక క్రియ + కర్త) వాడతారు.\n• సరైనది: "Rarely have I witnessed such profound eloquence."\n• పెద్ద సభలలో మరియు ప్రభావవంతమైన సంభాషణల్లో ఇది ఉపయోగపడుతుంది.';
        case 'kannada':
          return 'ಭಾಷಣದಲ್ಲಿ ಗಾಂಭೀರ್ಯ ಮತ್ತು ಪ್ರಭಾವವನ್ನು ಹೆಚ್ಚಿಸಲು Inversion (Rarely/Never + Auxiliary Verb + Subject) ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "Rarely have I witnessed such profound eloquence."\n• ಸಾರ್ವಜನಿಕ ಭಾಷಣಗಳಲ್ಲಿ ಇದು ಆಕರ್ಷಕ ಶೈಲಿಯನ್ನು ನೀಡುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'Inversion places negative or limiting adverbs at the start of a sentence followed by the auxiliary verb and subject to create dramatic rhetorical power.\n• Normal: "I have rarely witnessed such eloquence."\n• Inverted (Rhetorical): "Rarely have I witnessed such profound eloquence."\n• Structure: Rarely / Never / Not only + Have/Did/Can + Subject + Verb.';
      }
    }

    if (widget.day == 6) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'கடந்த கால மாற்ற முடியாத அனுமானங்களுக்கு Third Conditional (If + Past Perfect, Would have + Verb3) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "If we had negotiated earlier, we would have avoided the impasse."\n• கடந்த கால அனுபவங்களை சாதுரியமாக ஆராய இது உதவுகிறது.';
        case 'hindi':
          return 'Third Conditional का प्रयोग भूतकाल की काल्पनिक स्थितियों के लिए होता है जो नहीं हो सकीं: If + Past Perfect (had + V3), Would have + V3.\n• सही वाक्य: "If we had negotiated earlier, we would have avoided the impasse."\n• यह भूतकाल के तार्किक विश्लेषण के लिए अत्यंत उपयोगी है।';
        case 'telugu':
          return 'గతంలో జరగని ఊహాత్మక సంఘటనలను తెలపడానికి Third Conditional (If + Past Perfect, Would have + V3) వాడాలి.\n• సరైనది: "If we had negotiated earlier, we would have avoided the impasse."\n• గత అనుభవాలను చాకచక్యంగా విశ్లేషించేందుకు ఇది ఉపయోగపడుతుంది.';
        case 'kannada':
          return 'ಹಿಂದೆ ನಡೆಯದ ಕಾಲ್ಪನಿಕ ಸನ್ನಿವೇಶಗಳನ್ನು ವ್ಯಕ್ತಪಡಿಸಲು Third Conditional (If + Past Perfect, Would have + V3) ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "If we had negotiated earlier, we would have avoided the impasse."\n• ಹಿಂದಿನ ತಪ್ಪುಗಳನ್ನು ಸರಿಪಡಿಸಲು ಇದು ನೆರವಾಗುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'Third Conditional expresses hypothetical past outcomes that did not occur: If + Past Perfect (had + V3), Would have + Past Participle (V3).\n• Correct: "If we had negotiated earlier, we would have avoided the impasse."\n• In Malayalam: "ഞങ്ങൾ നേരത്തെ സംസാരിച്ചിരുന്നെങ്കിൽ തർക്കം ഒഴിവാക്കാമായിരുന്നു." Reflecting on past learning with poise.';
      }
    }

    if (widget.day == 5) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'நிகழ்காலப் பயனுள்ள செயல்களுக்கு Present Perfect (Have/Has + Verb3) பயன்படுத்தவும். முடிந்துபோன குறிப்பிட்ட நேரச் செயல்களுக்கு Simple Past (Verb2) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "I have lived here for 5 years." vs "I lived in London in 2020."';
        case 'hindi':
          return 'जो कार्य भूतकाल में हुआ लेकिन उसका प्रभाव अब भी है, उसके लिए Present Perfect (have/has + V3) लगाएं। जो कार्य भूतकाल में समाप्त हो चुका, उसके लिए Simple Past (V2) लगाएं।\n• उदाहरण: "I have completed 5 missions." vs "I finished yesterday."';
        case 'telugu':
          return 'గతంలో జరిగి ప్రస్తుతం కూడా ప్రభావం ఉన్న పనులకు Present Perfect (Have/Has + V3) వాడాలి. గతంలోనే ముగిసిన నిర్దిష్ట సమయానికి Simple Past వాడాలి.\n• సరైనది: "I have completed 5 missions." vs "I completed it yesterday."';
        case 'kannada':
          return 'ಪ್ರಸ್ತುತಕ್ಕೆ ಸಂಬಂಧಿಸಿದ ಹಿಂದಿನ ಕ್ರಿಯೆಗೆ Present Perfect (Have/Has + V3) ಬಳಸಿ. ಮುಗಿದುಹೋದ ನಿರ್ದಿಷ್ಟ ಸಮಯದ ಕ್ರಿಯೆಗೆ Simple Past ಬಳಸಿ.\n• ಸರಿಯಾದ ರೂಪ: "I have learned 50 new words." vs "I learned it yesterday."';
        case 'malayalam':
        default:
          return 'Use Present Perfect (Have/Has + Past Participle) when a past action has relevance or continuity now. Use Simple Past when an action finished at a specific past time.\n• Correct: "I have completed 5 English missions this week." (Present relevance)\n• Correct: "I completed mission 1 yesterday." (Specific past time)';
      }
    }

    if (widget.day == 4) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'முதல் நிபந்தனை வாக்கியம் (First Conditional): நிஜமான சாத்தியக்கூറுகளைக் குறிக்க: If + Simple Present, Will + Base Verb.\n• சரியான வாக்கியம்: "If you practice speaking daily, you will achieve fluency."\n• "If" பகுதிக்குள் "will" பயன்படுத்தக் கூடாது!';
        case 'hindi':
          return 'First Conditional वास्तविक संभावनाओं के लिए: If + Simple Present, Will + Verb.\n• सही वाक्य: "If you practice speaking daily, you will achieve fluency."\n• याद रखें: If वाले भाग में "will" कभी न लगाएं!';
        case 'telugu':
          return 'First Conditional వాస్తవ అవకాశాలను తెలుపుతుంది: If + Simple Present, Will + Verb.\n• సరైనది: "If you practice speaking daily, you will achieve fluency."\n• గుర్తుంచుకోండి: If ఉన్న భాగంలో "will" వాడకూడదు!';
        case 'kannada':
          return 'First Conditional ನೈಜ ಸಾಧ್ಯತೆಗಳನ್ನು ತಿಳಿಸುತ್ತದೆ: If + Simple Present, Will + Verb.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "If you practice speaking daily, you will achieve fluency."\n• "If" ಭಾಗದಲ್ಲಿ "will" ಬಳಸಬೇಡಿ!';
        case 'malayalam':
        default:
          return 'First Conditional expresses real future possibilities: If + Simple Present, Will + Base Verb.\n• Correct: "If you practice speaking daily, you will achieve natural fluency."\n• Rule: Never put "will" inside the "if" clause!';
      }
    }

    if (widget.day == 3) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'கட்டாயத்திற்கு "Must", ஆலோசனைக்கு "Should", தார்மீகக் கடமைக்கு "Ought to" பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "You must focus for 60 minutes." (கட்டாயம்)\n• "You should practice aloud." (ஆலோசனை)';
        case 'hindi':
          return 'अनिवार्यता के लिए "Must", अच्छी सलाह के लिए "Should", और नैतिक कर्तव्य के लिए "Ought to" का प्रयोग करें।\n• सही: "You must focus for 60 minutes." (कड़ा नियम/जरूरत)\n• "You should practice daily." (सलाह)';
        case 'telugu':
          return 'ఖచ్చితమైన అవసరానికి "Must", మంచి సలహాకు "Should", నైతిక బాధ్యతకు "Ought to" వాడాలి.\n• సరైనది: "You must focus for 60 minutes." (తప్పనిసరి)\n• "You should practice daily." (మంచి సలహా)';
        case 'kannada':
          return 'ಖಚಿತ ಅಗತ್ಯಕ್ಕೆ "Must", ಒಳ್ಳೆಯ ಸಲಹೆಗೆ "Should", ನೈತಿಕ ಕರ್ತವ್ಯಕ್ಕೆ "Ought to" ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "You must focus for 60 minutes." (ಕಡ್ಡಾಯ)\n• "You should practice daily." (ಸಲಹೆ)';
        case 'malayalam':
        default:
          return 'Use "Must" for strict necessity/obligation, "Should" for sensible advice, and "Ought to" for moral duty.\n• Correct: "You must dedicate focused time to master English." (Necessity)\n• Correct: "You should turn off phone notifications." (Sensible advice)';
      }
    }

    if (widget.day == 2) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'செயல் எவ்வளவு முறை நடக்கிறது என்பதைக் குறிக்க Adverbs of Frequency பயன்படுகின்றன. இவை பொதுவாக முதன்மை வினைச்சொல்லுக்கு (main verb) முன்னால் வரும்.\n• சரியான வாக்கியம்: "I always practice English in the morning."\n• தமிழில்: "நான் எப்போதும் காலையில் பயிற்சி செய்கிறேன்." main verb-க்கு முன் "always, usually" வைக்க நினைவில் கொள்ளுங்கள்!';
        case 'hindi':
          return 'Adverbs of Frequency बताते हैं कि कोई काम कितनी बार होता है। ये मुख्य क्रिया (main verb) से ठीक पहले आते हैं।\n• सही वाक्य: "I always practice English in the morning."\n• हिंदी में: "मैं हमेशा सुबह अभ्यास करता हूँ।" Main verb से पहले always, usually का प्रयोग करें!';
        case 'telugu':
          return 'ఒక పని ఎంత తరచుగా జరుగుతుందో తెలిపేందుకు Adverbs of Frequency వాడతారు. ఇవి సాధారణంగా ప్రధాన క్రియకు (main verb) ముందే వస్తాయి.\n• సరైనది: "I always practice English in the morning."\n• తెలుగులో: "నేను ఎల్లప్పుడూ ఉదయం సాధన చేస్తాను." Main verb కు ముందుగా వీటిని ఉంచండి!';
        case 'kannada':
          return 'ಒಂದು ಕೆಲಸ ಎಷ್ಟು ಬಾರಿ ನಡೆಯುತ್ತದೆ ಎಂಬುದನ್ನು ತಿಳಿಸಲು Adverbs of Frequency ಬಳಸಲಾಗುತ್ತದೆ. ಇವು ಸಾಮಾನ್ಯವಾಗಿ ಮುಖ್ಯ ಕ್ರಿಯಾಪದದ ಮುಂಚೆ ಬರುತ್ತವೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "I always practice English in the morning."\n• ಕನ್ನಡದಲ್ಲಿ: "ನಾನು ಯಾವಾಗಲೂ ಬೆಳಗ್ಗೆ ಅಭ್ಯಾಸ ಮಾಡುತ್ತೇನೆ." Main verb ಗಿಂತ ಮೊದಲು ಇರಿಸಿ!';
        case 'malayalam':
        default:
          return 'Adverbs of Frequency show how often an action happens. They usually go BEFORE the main verb, but AFTER the verb "to be".\n• Correct: "I always practice English in the morning."\n• Correct with "be": "He is usually punctual."\n• In Malayalam: "ഞാൻ എപ്പോഴും രാവിലെ ഇംഗ്ലീഷ് പരിശീലിക്കുന്നു." പ്രധാന ക്രിയയ്ക്ക് (verb) തൊട്ടുമുമ്പായി "always, often, usually" ചേർക്കുക!';
      }
    }

    switch (lang.toLowerCase()) {
      case 'tamil':
        return 'ஆங்கிலத்தில் வாக்கிய அமைப்பு: எழுவாய் (Subject) + வினைச்சொல் (Verb) + செயப்படுபொருள் (Object).\n• சரியான வாக்கியம்: "She reads books."\n• தமிழில்: "அவள் புத்தகம் படிக்கிறாள்" (Subject + Object + Verb). ஆங்கிலத்தில் பேசுவதற்கு முன் வினையை (Verb) பொருளுக்கு முன்னால் வைக்க நினைவில் கொள்ளுங்கள்!';
      case 'hindi':
        return 'अंग्रेजी में वाक्य विन्यास: कर्ता (Subject) + क्रिया (Verb) + कर्म (Object) के क्रम में आता है।\n• सही: "She reads books."\n• हिंदी में: "वह किताब पढ़ती है" (Subject + Object + Verb)। अंग्रेजी में हमेशा क्रिया (Verb) को कर्म से पहले रखें!';
      case 'telugu':
        return 'ఇంగ్లీషులో వాక్య నిర్మాణం: కర్త (Subject) + క్రియ (Verb) + కర్మ (Object) క్రమంలో ఉంటుంది.\n• సరైనది: "She reads books."\n• తెలుగులో: "ఆమె పుస్తకం చదువుతుంది" (Subject + Object + Verb). ఇంగ్లీష్ మాట్లాడేటప్పుడు క్రియను కర్మకు ముందే ఉంచాలని గుర్తుంచుకోండి!';
      case 'kannada':
        return 'ಇಂಗ್ಲಿಷ್ ವಾಕ್ಯ ರಚನೆ: ಕರ್ತೃ (Subject) + ಕ್ರಿಯಾಪದ (Verb) + ಕರ್ಮ (Object) ಕ್ರಮದಲ್ಲಿ ಬರುತ್ತದೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "She reads books."\n• ಕನ್ನಡದಲ್ಲಿ: "ಅವಳು ಪುಸ್ತಕ ಓದುತ್ತಾಳೆ" (Subject + Object + Verb). ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಕ್ರಿಯಾಪದವನ್ನು (Verb) ಕರ್ಮಕ್ಕಿಂತ ಮೊದಲು ಇರಿಸಿ!';
      case 'malayalam':
      default:
        return 'English sentences follow the order: Subject (who) + Verb (action) + Object (what).\n• Correct: "She reads books."\n• In Malayalam: "അവൾ പുസ്തകം വായിക്കുന്നു" (Subject + Object + Verb). Remember to place the action verb BEFORE the object in English!';
    }
  }

  String _getStorySummary(String lang) {
    if (widget.day == 8) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "தொழில்நுட்ப வேகத்தையும் தார்மீக மனித விழுமியங்களையும் ஒருங்கிணைக்கும் தொலைநோக்குப் பார்வையே எதிர்காலத்தை வழிநடத்தும்."';
        case 'hindi':
          return '💡 सीख: "तकनीकी नवाचार और मानवीय नैतिकता का संतुलित समन्वय ही भविष्य को उज्ज्वल बनाता है।" समग्र दृष्टिकोण अपनाएं।';
        case 'telugu':
          return '💡 నీతి: "సాంకేతిక వేగాన్ని, నైతిక విలువలను సమన్వయం చేసే వివేకవంతమైన దృక్పథమే మానవాళి భవిష్యత్తుకు మార్గదర్శకం."';
        case 'kannada':
          return '💡 ನೀತಿ: "ತಂತ್ರಜ್ಞಾನ ಮತ್ತು ನೈತಿಕ ಮಾನವ ಮೌಲ್ಯಗಳನ್ನು ಸಮನ್ವಯಗೊಳಿಸುವ ದೂರದೃಷ್ಟಿಯೇ ಭವಿಷ್ಯದ ದಾರಿದೀಪ."';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "സാങ്കേതിക വിപ്ലവങ്ങളെയും ഉന്നതമായ മാനുഷിക ധാർമ്മികതയെയും സമന്വയിപ്പിക്കുന്ന ദീർഘവീക്ഷണമുള്ള ചിന്തകരാണ് ഭാവിയുടെ യഥാർത്ഥ ശില്പികൾ."';
      }
    }

    if (widget.day == 7) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "உண்மையான சொல்வன்மை வெறும் அலங்காரமல்ல; ஆழ்ந்த அறிவும் அசைக்க முடியாத தன்னம்பிக்கையுமே சபையை வெல்லும்."';
        case 'hindi':
          return '💡 सीख: "सच्ची वाक्पटुता केवल शब्दों का आडंबर नहीं, बल्कि गहरे ज्ञान और आत्मबल का प्रभावशाली प्रकटीकरण है।"';
        case 'telugu':
          return '💡 నీతి: "నిజమైన వాక్చాతుర్యం ఆడంబరం కాదు; లోతైన విజ్ఞానమూ, నిశ్చలమైన ఆత్మవిశ్వాసమే సభను మెప్పిస్తాయి."';
        case 'kannada':
          return '💡 ನೀತಿ: "ನಿಜವಾದ ವಾಕ್ಚಾತುರ್ಯವು ಕೇವಲ ಅಲಂಕಾರವಲ್ಲ; ಆಳವಾದ ಜ್ಞಾನ ಮತ್ತು ಅಚಲ ಆತ್ಮವಿಶ್ವಾಸವೇ ಸಭೆಯನ್ನು ಗೆಲ್ಲುತ್ತದೆ."';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "യഥാർത്ഥ വാക്ചാതുര്യം കേവലം വാക്കുകളുടെ അലങ്കാരമല്ല, മറിച്ച് സത്യസന്ധമായ ഉറച്ച ബോധ്യങ്ങളുടെയും ആഴത്തിലുള്ള അറിവിന്റെയും ധീരമായ പ്രതിധ്വനിയാണ്."';
      }
    }

    if (widget.day == 6) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "கடும் பதற்றமான சூழலிலும் நிதானமான சமரசமும் சட்டபூர்வமான தெளிவுமே முட்டுக்கட்டையை மாபெரும் வெற்றியாக்கும்."';
        case 'hindi':
          return '💡 सीख: "अत्यधिक दबाव में भी शांत और व्यावहारिक समझौता ही बड़े से बड़े गतिरोध को स्थायी साझेदारी में बदल देता है।"';
        case 'telugu':
          return '💡 నీతి: "తీవ్రమైన ఒత్తిడిలో కూడా ప్రశాంతమైన సమన్వయమూ, స్పష్టమైన చట్టబద్ధమైన ఆలోచనే ప్రతిష్టంభనను విజయంగా మారుస్తాయి."';
        case 'kannada':
          return '💡 ನೀತಿ: "ತೀವ್ರ ಒತ್ತಡದ ಪರಿಸ್ಥಿತಿಯಲ್ಲೂ ಶಾಂತ ರಾಜೀ ಮತ್ತು ಸ್ಪಷ್ಟ ಸಂವಹನವೇ ಬಿಕ್ಕಟ್ಟನ್ನು ಶಾಶ್ವತ ಪಾಲುದಾರಿಕೆಯನ್ನಾಗಿ ಪರಿವರ್ತಿಸುತ್ತದೆ."';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഉയർന്ന സമ്മർദ്ദത്തിലും ശാന്തമായ വിട്ടുവീഴ്ചകളും നിയമപരമായ വ്യക്തതയും ഏറ്റവും കടുത്ത തർക്കങ്ങളെയും പരസ്പര വിജയമാക്കി മാറ്റും."';
      }
    }

    if (widget.day == 5) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "புயலின் நடுவிலும் தெளிவான துணிச்சலான பேச்சு துன்பத்தை வெற்றியாக்கும்." இக்கட்டான நேரத்திலும் ஆங்கிலத்தில் உறுதியாகப் பேசுங்கள்.';
        case 'hindi':
          return '💡 सीख: "संकट के समय में शांत और निर्णायक संवाद ही सफलता का मार्ग है।" कठिन परिस्थितियों में आत्मविश्वास से बोलें।';
        case 'telugu':
          return '💡 నీతి: "తుఫాను వంటి ఆపదలో కూడా ప్రశాంతమైన, నిర్ణయాత్మకమైన మాటే విజయాన్ని తెస్తుంది." ఆత్మవిశ్వాసంతో మాట్లాడండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ಸಂಕಷ್ಟದ ಸಮಯದಲ್ಲಿ ಶಾಂತ ಹಾಗೂ ನಿರ್ಣಾಯಕ ಸಂವಹನವೇ ಯಶಸ್ಸಿನ ದಾರಿ." ಧೈರ್ಯದಿಂದ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಮಾತನಾಡಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "പ്രതിസന്ധികളുടെ കൊടുങ്കാറ്റിലും പതറാത്ത വ്യക്തമായ നേതൃത്വപരമായ ആശയവിനിമയം വിജയത്തിലേക്ക് നയിക്കും."';
      }
    }

    if (widget.day == 4) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "சத்தமாகப் பேசுவதை விட சாதுரியமான அர்த்தமுள்ள வாதமே பிறர் மனதை வெல்லும்." ஆங்கிலத்தில் நயமுடன் பேசப் பழகுங்கள்.';
        case 'hindi':
          return '💡 सीख: "चिल्लाने से नहीं, बल्कि शांत और तार्किक संवाद से ही दूसरों का दिल जीता जा सकता है।" कूटनीतिक संवाद सीखें।';
        case 'telugu':
          return '💡 నీతి: "అరవడం వల్ల కాదు, చాకచక్యమైన సహేతుకమైన వాదనతోనే ఎవరినైనా ఒప్పించవచ్చు." వివేకంతో మాట్లాడండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ಗಟ್ಟಿಯಾಗಿ ಕೂಗುವುದಕ್ಕಿಂತ ಜಾಣ್ಮೆಯ ಸಾರಯುತ ಮಾತುಗಳಿಂದಲೇ ಜನರನ್ನು ಒಲಿಸಿಕೊಳ್ಳಬಹುದು."';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഒച്ചവെച്ച് സംസാരിക്കുന്നതിലല്ല, മറിച്ച് വിവേകപൂർവ്വമായ യുക്തിസഹമായ സംഭാഷണത്തിലാണ് യഥാർത്ഥ സ്വാധീനശക്തി."';
      }
    }

    if (widget.day == 3) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "ஆழ்ந்த அமைதியும் இடைவிடாத கவனமுமே மகத்தான அறிவை உருவாக்கும்." கவனச்சிதறல்களைத் தவிர்த்து ஒருமுகப்பட்டுப் பயிற்சி செய்யுங்கள்.';
        case 'hindi':
          return '💡 सीख: "गहरी एकाग्रता और शांत मन ही महान ज्ञान की नींव है।" भटकावों को दूर रखकर पूरे ध्यान से अंग्रेजी सीखें।';
        case 'telugu':
          return '💡 నీతి: "ప్రశాంతమైన లోతైన ఏకాగ్రతతోనే అద్భుతమైన నైపుణ్యం సాధ్యమవుతుంది." పరధ్యానాలను పక్కనపెట్టి సాధన చేయండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ಆಳವಾದ ಏಕಾಗ್ರತೆ ಮತ್ತು ಶ್ರದ್ಧೆಯು ಅಸಾಧಾರಣ ಕೌಶಲ್ಯವನ್ನು ನೀಡುತ್ತದೆ." ವಿಚಲಿತರಾಗದೆ ಪೂರ್ಣ ಗಮನದಿಂದ ಅಭ್ಯಾಸ ಮಾಡಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ശ്രദ്ധതിരിക്കുന്ന ശബ്ദങ്ങളിൽ നിന്ന് മാറി 60 മിനിറ്റ് പൂർണ്ണ ശ്രദ്ധയോടെ പരിശീലിക്കുമ്പോൾ തലച്ചോറിന്റെ കഴിവുകൾ ഉണരും."';
      }
    }

    if (widget.day == 2) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "நமது பழக்கவழக்கங்களே நமது எதிர்காலத்தை உருவாக்குகின்றன." தினமும் விடாமல் செய்யும் சிறிய பயிற்சியே மாபெரும் வெற்றியைத் தரும்.';
        case 'hindi':
          return '💡 सीख: "हमारी आदतें ही हमारा भविष्य तय करती हैं।" प्रतिदिन का छोटा लेकिन अटूट अभ्यास ही महान सफलता की कुंजी है।';
        case 'telugu':
          return '💡 నీతి: "మన అలవాట్లే మన భవిష్యత్తును నిర్ణయిస్తాయి." ప్రతిరోజూ చేసే క్రమశిక్షణతో కూడిన సాధనే గొప్ప ఫలితాన్ని ఇస్తుంది.';
        case 'kannada':
          return '💡 ನೀತಿ: "ನಮ್ಮ ಅಭ್ಯಾಸಗಳೇ ನಮ್ಮ ಭವಿಷ್ಯವನ್ನು ನಿರ್ಧರಿಸುತ್ತವೆ." ಪ್ರತಿದಿನ ಮಾಡುವ ಸಣ್ಣ ಸತತ ಪ್ರಯತ್ನವೇ ದೊಡ್ಡ ಯಶಸ್ಸಿಗೆ ಕಾರಣವಾಗುತ್ತದೆ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "നമ്മുടെ ശീലങ്ങളാണ് നമ്മുടെ ഭാവിയെ നിർണയിക്കുന്നത്." ദിവസേനയുള്ള ചെറിയ ചിട്ടയായ പരിശീലനം വലിയ മാറ്റങ്ങൾ സൃഷ്ടിക്കും.';
      }
    }

    switch (lang.toLowerCase()) {
      case 'tamil':
        return '💡 நீதி: நமது ஆங்கிலப் பயிற்சி மூங்கில் விதை போன்றது. ஆரம்பத்தில் வெளியே தெரியாவிட்டாலும் உள்ளுக்குள் ஆழமான வேர்கள் உருவாகின்றன. 90 நாட்கள் தொடர் பயிற்சியால் உங்கள் சரளத்தன்மை வானளவிற்கு உயரும்.';
      case 'hindi':
        return '💡 सीख: हमारा अंग्रेजी अभ्यास बांस के बीज जैसा है। शुरुआत में भले ही बाहर कुछ न दिखे, लेकिन जड़ें गहराई तक फैलती हैं। 90 दिनों के नियमित अभ्यास से आपका आत्मविश्वास नई ऊंचाइयां छुएगा।';
      case 'telugu':
        return '💡 నీతి: మన ఇంగ్లీష్ సాధన వెదురు విత్తనం లాంటిది. మొదట్లో బయటకు కనిపించకపోయినా, లోపల వేర్లు బలంగా నాటుకుంటాయి. 90 రోజుల నిరంతర సాధనతో మీ ఆత్మవిశ్వాసం ఆకాశమంత ఎత్తుకు ఎదుగుతుంది.';
      case 'kannada':
        return '💡 ನೀತಿ: ನಮ್ಮ ಇಂಗ್ಲಿಷ್ ಅಭ್ಯಾಸವು ಬಿದಿರಿನ ಬೀಜದಂತಿದೆ. ಆರಂಭದಲ್ಲಿ ಮೇಲ್ನೋಟಕ್ಕೆ ಕಾಣಿಸದಿದ್ದರೂ, ಬೇರುಗಳು ಆಳವಾಗಿ ಬೆಳೆಯುತ್ತವೆ. 90 ದಿನಗಳ ನಿರಂತರ ಅಭ್ಯಾಸದಿಂದ ನಿಮ್ಮ ಆತ್ಮವಿಶ್ವಾಸವು ಎತ್ತರಕ್ಕೆ ಬೆಳೆಯುತ್ತದೆ.';
      case 'malayalam':
      default:
        return '💡 സന്ദേശം: നമ്മുടെ ഇംഗ്ലീഷ് പരിശീലനം മുളയുടെ വിത്ത് പോലെയാണ്. തുടക്കത്തിൽ പുറമെ വളർച്ച കാണുന്നില്ലെങ്കിലും വേരുകൾ ആഴത്തിൽ ഉറക്കുകയാണ്. 90 ദിവസത്തെ നിരന്തര പരിശീലനത്തിലൂടെ ആത്മവിശ്വാസം ഉയരങ്ങളിലേക്ക് വളരും.';
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _timerService.removeListener(_onTimerStateChanged);
    super.dispose();
  }

  void _loadVocabForDay() {
    if (widget.day == 2) {
      // 10 high-impact vocabulary words for Day 2 (Habits & Daily Routines) with Multilingual translations
      _vocabList = const [
        DailyVocabItem(
          word: 'Routine',
          partOfSpeech: 'noun',
          definition: 'A sequence of actions regularly followed.',
          malayalamMeaning: 'നിത്യകർമ്മം / ചിട്ടയായ ശീലം',
          tamilMeaning: 'வழக்கமான நடைமுறை',
          hindiMeaning: 'दिनचर्या / नियम',
          teluguMeaning: 'దినచర్య / నిత్యకృత్యం',
          kannadaMeaning: 'ದಿನಚರಿ / ವಾಡಿಕೆ',
          exampleSentence: 'A morning routine gives you focus for the entire day.',
          phonetic: '/ruːˈtiːn/',
        ),
        DailyVocabItem(
          word: 'Habit',
          partOfSpeech: 'noun',
          definition: 'A settled or regular tendency or practice.',
          malayalamMeaning: 'ശീലം / പതിവ്',
          tamilMeaning: 'பழக்கம் / வழக்கம்',
          hindiMeaning: 'आदत / स्वभाव',
          teluguMeaning: 'అలవాటు',
          kannadaMeaning: 'ಅಭ್ಯಾಸ / ರೂಢಿ',
          exampleSentence: 'Speaking English daily will soon become a natural habit.',
          phonetic: '/ˈhæb.ɪt/',
        ),
        DailyVocabItem(
          word: 'Chronological',
          partOfSpeech: 'adjective',
          definition: 'Arranged in the order of time of occurrence.',
          malayalamMeaning: 'കാലക്രമത്തിലുള്ള',
          tamilMeaning: 'காலவரிசைப்படி',
          hindiMeaning: 'कालक्रमानुसार',
          teluguMeaning: 'కాలక్రమానుసారమైన',
          kannadaMeaning: 'ಕಾಲಾನುಕ್ರಮದ',
          exampleSentence: 'Describe your daily activities in chronological order.',
          phonetic: '/ˌkrɒn.əˈlɒdʒ.ɪ.kəl/',
        ),
        DailyVocabItem(
          word: 'Frequently',
          partOfSpeech: 'adverb',
          definition: 'Regularly or with little time in between; often.',
          malayalamMeaning: 'അടിക്കടി / പലപ്പോഴും',
          tamilMeaning: 'அடிக்கடி',
          hindiMeaning: 'बार-बार / अक्सर',
          teluguMeaning: 'తరచుగా',
          kannadaMeaning: 'ಆಗಾಗ್ಗೆ / ಪದೇ ಪದೇ',
          exampleSentence: 'He frequently speaks with language mates to gain fluency.',
          phonetic: '/ˈfriː.kwənt.li/',
        ),
        DailyVocabItem(
          word: 'Seldom',
          partOfSpeech: 'adverb',
          definition: 'Not often; rarely.',
          malayalamMeaning: 'വല്ലപ്പോഴും മാത്രം / അപൂർവ്വമായി',
          tamilMeaning: 'எப்போதாவது / அரிதாக',
          hindiMeaning: 'कभी-कभार / शायद ही कभी',
          teluguMeaning: 'అరుదుగా',
          kannadaMeaning: 'ಅಪರೂಪವಾಗಿ',
          exampleSentence: 'Confident speakers seldom worry about little mistakes.',
          phonetic: '/ˈsel.dəm/',
        ),
        DailyVocabItem(
          word: 'Accomplish',
          partOfSpeech: 'verb',
          definition: 'To achieve or complete successfully.',
          malayalamMeaning: 'നിർവഹിക്കുക / പൂർത്തിയാക്കുക',
          tamilMeaning: 'சாதித்தல் / நிறைவேற்றுதல்',
          hindiMeaning: 'पूरा करना / हासिल करना',
          teluguMeaning: 'సాధించు / పూర్తిచేయు',
          kannadaMeaning: 'ಸಾಧಿಸು / ಪೂರೈಸು',
          exampleSentence: 'You will accomplish great fluency in 90 days.',
          phonetic: '/əˈkʌm.plɪʃ/',
        ),
        DailyVocabItem(
          word: 'Schedule',
          partOfSpeech: 'noun',
          definition: 'A plan of events or actions with specified times.',
          malayalamMeaning: 'സമയപ്പട്ടിക / നിശ്ചയിച്ച സമയം',
          tamilMeaning: 'கால அட்டவணை',
          hindiMeaning: 'समय सारणी / योजना',
          teluguMeaning: 'సమయ పట్టిక',
          kannadaMeaning: 'ವೇಳಾಪಟ್ಟಿ',
          exampleSentence: 'Set a daily schedule for reading and speaking practice.',
          phonetic: '/ˈʃedʒ.uːl/',
        ),
        DailyVocabItem(
          word: 'Prioritize',
          partOfSpeech: 'verb',
          definition: 'To designate or treat as more important than other things.',
          malayalamMeaning: 'മുൻഗണന നൽകുക',
          tamilMeaning: 'முன்னுரிமை அளித்தல்',
          hindiMeaning: 'प्राथमिकता देना',
          teluguMeaning: 'ప్రాధాన్యత ఇచ్చు',
          kannadaMeaning: 'ಆದ್ಯತೆ ನೀಡು',
          exampleSentence: 'Prioritize speaking over silent grammar memorization.',
          phonetic: '/praɪˈɒr.ɪ.taɪz/',
        ),
        DailyVocabItem(
          word: 'Productive',
          partOfSpeech: 'adjective',
          definition: 'Achieving or producing a significant or useful result.',
          malayalamMeaning: 'ഫലപ്രദമായ / കാര്യക്ഷമമായ',
          tamilMeaning: 'பയനുള്ള / ஆக்கபூர்வமான',
          hindiMeaning: 'उत्पादक / फलदायी',
          teluguMeaning: 'ఉత్పాదకమైన / ఉపయోగకరమైన',
          kannadaMeaning: 'ಉತ್ಪಾದಕ / ಪ್ರಯೋಜನಕಾರಿ',
          exampleSentence: 'Joining the audio call made my evening truly productive.',
          phonetic: '/prəˈdʌk.tɪv/',
        ),
        DailyVocabItem(
          word: 'Reflect',
          partOfSpeech: 'verb',
          definition: 'To think deeply or carefully about something.',
          malayalamMeaning: 'ചിന്തിച്ചുനോക്കുക / വിലയിരുത്തുക',
          tamilMeaning: 'ஆழமாக யோசித்தல் / பரிசீலித்தல்',
          hindiMeaning: 'विचार करना / मंथन करना',
          teluguMeaning: 'ఆలోచించు / సమీక్షించు',
          kannadaMeaning: 'ಆಲೋಚಿಸು / ಪರಿಶೀಲಿಸು',
          exampleSentence: 'Reflect on what you learned at the end of each mission.',
          phonetic: '/rɪˈflekt/',
        ),
      ];
      return;
    }

    if (widget.day == 3) {
      // 10 high-impact vocabulary words for Day 3 (Deep Focus & Overcoming Distractions)
      _vocabList = const [
        DailyVocabItem(
          word: 'Cognitive',
          partOfSpeech: 'adjective',
          definition: 'Related to mental processes of perception, memory, and judgment.',
          malayalamMeaning: 'വൈജ്ഞാനികമായ / ബുദ്ധിപരമായ',
          tamilMeaning: 'அறிவாற்றல் சார்ந்த',
          hindiMeaning: 'संज्ञानात्मक / मानसिक',
          teluguMeaning: 'జ్ఞాన సంబంధిత / మేధోపరమైన',
          kannadaMeaning: 'ಜ್ಞಾನಗ್ರಹಣದ / ಬುದ್ಧಿಶಕ್ತಿಯ',
          exampleSentence: 'Deep English reading strengthens your cognitive agility.',
          phonetic: '/ˈkɒɡ.nə.tɪv/',
        ),
        DailyVocabItem(
          word: 'Distraction',
          partOfSpeech: 'noun',
          definition: 'A thing that prevents someone from giving full attention to something.',
          malayalamMeaning: 'ശ്രദ്ധതിരിവ് / വ്യതിചലനം',
          tamilMeaning: 'கவனச்சிதறல்',
          hindiMeaning: 'ध्यान भटकाव',
          teluguMeaning: 'దృష్టి మళ్లింపు / అంతరాయం',
          kannadaMeaning: 'ಗಮನ ವಿಚಲನೆ',
          exampleSentence: 'Turn off notifications to eliminate every spoken distraction.',
          phonetic: '/dɪˈstræk.ʃən/',
        ),
        DailyVocabItem(
          word: 'Immersive',
          partOfSpeech: 'adjective',
          definition: 'Generating deep personal involvement or full mental absorption.',
          malayalamMeaning: 'പൂർണ്ണമായി മുഴുകിനിൽക്കുന്ന',
          tamilMeaning: 'ஆழ்ந்து ஈடுபடும்',
          hindiMeaning: 'तल्लीन करने वाला / गहरा',
          teluguMeaning: 'పూర్తిగా లీనమయ్యే',
          kannadaMeaning: 'ಸಂಪೂರ್ಣ ತೊಡಗಿಸಿಕೊಳ್ಳುವ',
          exampleSentence: 'An immersive 60-minute session accelerates conversational speed.',
          phonetic: '/ɪˈmɜː.sɪv/',
        ),
        DailyVocabItem(
          word: 'Meticulous',
          partOfSpeech: 'adjective',
          definition: 'Showing great attention to detail; very careful and precise.',
          malayalamMeaning: 'അതീവ സൂക്ഷ്മതയുള്ള',
          tamilMeaning: 'நுணுக்கமான / கவனமான',
          hindiMeaning: 'अत्यंत सावधान / सूक्ष्म',
          teluguMeaning: 'అత్యంత నిశితమైన',
          kannadaMeaning: 'ಅತೀವ ಜಾಗರೂಕತೆಯುಳ್ಳ',
          exampleSentence: 'He is meticulous about his English vowel pronunciation.',
          phonetic: '/məˈtɪk.jə.ləs/',
        ),
        DailyVocabItem(
          word: 'Procrastinate',
          partOfSpeech: 'verb',
          definition: 'To delay or postpone action; put off doing something.',
          malayalamMeaning: 'നീട്ടിവെക്കുക / മടിപിടിക്കുക',
          tamilMeaning: 'தள்ளிப்போடுதல்',
          hindiMeaning: 'टालमटोल करना',
          teluguMeaning: 'వాయిదా వేయు',
          kannadaMeaning: 'ಮುಂದೂಡುವುದು',
          exampleSentence: 'Do not procrastinate; start your speaking drill right now.',
          phonetic: '/prəˈkræs.tɪ.neɪt/',
        ),
        DailyVocabItem(
          word: 'Resilience',
          partOfSpeech: 'noun',
          definition: 'The capacity to withstand or recover quickly from difficulties.',
          malayalamMeaning: 'പ്രതിസന്ധികളെ അതിജീവിക്കാനുള്ള കരുത്ത്',
          tamilMeaning: 'மீண்டு வரும் திறன்',
          hindiMeaning: 'लचीलापन / सहनशक्ति',
          teluguMeaning: 'తట్టుకునే శక్తి / దృఢత్వం',
          kannadaMeaning: 'ಪುಟಿದೇಳುವ ಸಾಮರ್ಥ್ಯ',
          exampleSentence: 'Fluency requires resilience whenever you make grammar mistakes.',
          phonetic: '/rɪˈzɪl.jəns/',
        ),
        DailyVocabItem(
          word: 'Sustained',
          partOfSpeech: 'adjective',
          definition: 'Continuing for an extended period without interruption.',
          malayalamMeaning: 'നിരന്തരമായ / തുടർച്ചയായ',
          tamilMeaning: 'தொடர்ச்சியான',
          hindiMeaning: 'निरंतर / सतत',
          teluguMeaning: 'నిరంతరాయమైన',
          kannadaMeaning: 'ನಿರಂತರವಾದ',
          exampleSentence: 'Sustained focus for 60 minutes yields remarkable results.',
          phonetic: '/səˈsteɪnd/',
        ),
        DailyVocabItem(
          word: 'Superficial',
          partOfSpeech: 'adjective',
          definition: 'Existing or occurring at the surface; shallow.',
          malayalamMeaning: 'ഉപരിപ്ലവമായ / ആഴമില്ലാത്ത',
          tamilMeaning: 'மேலோட்டமான',
          hindiMeaning: 'सतही / उथला',
          teluguMeaning: 'పైపైన / లోతులేని',
          kannadaMeaning: 'ಮೇಲ್ನೋಟದ',
          exampleSentence: 'Superficial memorization cannot replace active conversation.',
          phonetic: '/ˌsuː.pəˈfɪʃ.əl/',
        ),
        DailyVocabItem(
          word: 'Discipline',
          partOfSpeech: 'noun',
          definition: 'The practice of training oneself to obey rules or codes of conduct.',
          malayalamMeaning: 'അച്ചടക്കം / ആത്മനിയന്ത്രണം',
          tamilMeaning: 'ஒழுக்கம் / சுயக்கட்டுப்பாடு',
          hindiMeaning: 'अनुशासन / आत्म-नियंत्रण',
          teluguMeaning: 'క్రమశిక్షణ',
          kannadaMeaning: 'ಶಿಸ್ತು / ಸ್ವಯಂ ನಿಯಂತ್ರಣ',
          exampleSentence: 'Daily discipline separates dreamers from fluent speakers.',
          phonetic: '/ˈdɪs.ə.plɪn/',
        ),
        DailyVocabItem(
          word: 'Velocity',
          partOfSpeech: 'noun',
          definition: 'The speed of something in a given direction; swift pace.',
          malayalamMeaning: 'വേഗത / ചലനവേഗം',
          tamilMeaning: 'வேகம் / விரைவு',
          hindiMeaning: 'वेग / गति',
          teluguMeaning: 'వేగము',
          kannadaMeaning: 'ವೇಗ / ಚಲನೆ',
          exampleSentence: 'Your speaking velocity improves as thinking in English becomes natural.',
          phonetic: '/vəˈlɒs.ə.ti/',
        ),
      ];
      return;
    }

    if (widget.day == 4) {
      // 10 high-impact vocabulary words for Day 4 (Persuasion & Diplomatic Debate)
      _vocabList = const [
        DailyVocabItem(
          word: 'Articulate',
          partOfSpeech: 'adjective',
          definition: 'Having or showing the ability to speak fluently and coherently.',
          malayalamMeaning: 'സ്പഷ്ടമായി വ്യക്തമാക്കുന്ന',
          tamilMeaning: 'தெளிவாகப் பேசும்',
          hindiMeaning: 'सुस्पष्ट / स्पष्ट बोलने वाला',
          teluguMeaning: 'స్పష్టంగా మాట్లాడే',
          kannadaMeaning: 'ಸ್ಪಷ್ಟವಾಗಿ ಅಭಿವ್ಯಕ್ತಿಸುವ',
          exampleSentence: 'An articulate leader explains complex plans with ease.',
          phonetic: '/ɑːˈtɪk.jə.lət/',
        ),
        DailyVocabItem(
          word: 'Concede',
          partOfSpeech: 'verb',
          definition: 'Admit that something is true or valid after first resisting it.',
          malayalamMeaning: 'സമ്മതിക്കുക / അംഗീകരിക്കുക',
          tamilMeaning: 'ஒப்புக்கொள்ளுதல்',
          hindiMeaning: 'स्वीकार करना / मान लेना',
          teluguMeaning: 'అంగీకరించు / ఒప్పుకొను',
          kannadaMeaning: 'ಒಪ್ಪಿಕೊಳ್ಳು',
          exampleSentence: 'A skilled negotiator knows when to concede minor points.',
          phonetic: '/kənˈsiːd/',
        ),
        DailyVocabItem(
          word: 'Diplomatic',
          partOfSpeech: 'adjective',
          definition: 'Skilled at dealing with sensitive situations and people.',
          malayalamMeaning: 'നയതന്ത്രപരമായ / വിവേകപൂർവ്വമായ',
          tamilMeaning: 'சாதுரியமான / நயமான',
          hindiMeaning: 'कूटनीतिक / व्यवहारकुशल',
          teluguMeaning: 'చాకచక్యమైన / సంభాషణా చాతుర్యం',
          kannadaMeaning: 'ರಾಜತಾಂತ್ರಿಕ / ಜಾಣ್ಮೆಯ',
          exampleSentence: 'Use diplomatic phrases to disagree politely without offense.',
          phonetic: '/ˌdɪp.ləˈmæt.ɪk/',
        ),
        DailyVocabItem(
          word: 'Eloquent',
          partOfSpeech: 'adjective',
          definition: 'Fluent or persuasive in speaking or writing.',
          malayalamMeaning: 'വാഗ്ധോരണിയുള്ള / ഹൃദ്യമായി സംസാരിക്കുന്ന',
          tamilMeaning: 'நாவன்மை மிக்க / சொல்வளமிக்க',
          hindiMeaning: 'वाक्पटु / प्रभावशाली',
          teluguMeaning: 'వాక్చాతుర్యం గల',
          kannadaMeaning: 'ವಾಕ್ಪಟುತ್ವವುಳ್ಳ / ಮಧುರಭಾಷಿ',
          exampleSentence: 'Her eloquent defense won over the entire audience.',
          phonetic: '/ˈel.ə.kwənt/',
        ),
        DailyVocabItem(
          word: 'Persuasive',
          partOfSpeech: 'adjective',
          definition: 'Good at convincing someone to agree through reasoning.',
          malayalamMeaning: 'പ്രേരിപ്പിക്കുന്ന / ബോധ്യപ്പെടുത്തുന്ന',
          tamilMeaning: 'வற்புறுத்தும் திறன்மிக்க',
          hindiMeaning: 'प्रेरक / समझाने वाला',
          teluguMeaning: 'ఒప్పించగల / మెప్పించగల',
          kannadaMeaning: 'ಮನವೊಲಿಸುವ',
          exampleSentence: 'Give persuasive reasons supported by real examples.',
          phonetic: '/pəˈsweɪ.sɪv/',
        ),
        DailyVocabItem(
          word: 'Consensus',
          partOfSpeech: 'noun',
          definition: 'A general agreement reached by a collective group.',
          malayalamMeaning: 'പൊതുസമ്മതി / ഏകാഭിപ്രായം',
          tamilMeaning: 'ஒருமித்த கருத்து',
          hindiMeaning: 'सर्वसम्मति / आम सहमति',
          teluguMeaning: 'ఏకాభిప్రాయం / సర్వసమ్మతి',
          kannadaMeaning: 'ಒಮ್ಮತ / ಸರ್ವಾನುಮತ',
          exampleSentence: 'The team reached a consensus after a productive discussion.',
          phonetic: '/kənˈsen.səs/',
        ),
        DailyVocabItem(
          word: 'Nuance',
          partOfSpeech: 'noun',
          definition: 'A subtle difference in meaning, opinion, or tone.',
          malayalamMeaning: 'നേർത്ത സൂക്ഷ്മവ്യത്യാസം',
          tamilMeaning: 'நுட்பமான வேறுபாடு',
          hindiMeaning: 'सूक्ष्म भेद / बारीकी',
          teluguMeaning: 'సూక్ష్మభేదం',
          kannadaMeaning: 'ಸೂಕ್ಷ್ಮ ವ್ಯತ್ಯಾಸ',
          exampleSentence: 'Mastering conversational tone requires understanding every nuance.',
          phonetic: '/ˈnjuː.ɑːns/',
        ),
        DailyVocabItem(
          word: 'Assertive',
          partOfSpeech: 'adjective',
          definition: 'Confidently and directly expressing thoughts and opinions.',
          malayalamMeaning: 'ദൃഢനിശ്ചയത്തോടെ സംസാരിക്കുന്ന',
          tamilMeaning: 'உறுதியான பேச்சுடைய',
          hindiMeaning: 'मुखर / दृढ़निश्चयी',
          teluguMeaning: 'దృఢమైన / స్పష్టమైన',
          kannadaMeaning: 'ದೃಢವಾದ / ನೇರವಾದ',
          exampleSentence: 'Speak in an assertive yet respectful manner.',
          phonetic: '/əˈsɜː.tɪv/',
        ),
        DailyVocabItem(
          word: 'Rebuttal',
          partOfSpeech: 'noun',
          definition: 'A contradiction or refutation of an opposing argument.',
          malayalamMeaning: 'ഖണ്ഡനം / മറുവാദം',
          tamilMeaning: 'மறுப்புரை',
          hindiMeaning: 'खंडन / प्रतिवाद',
          teluguMeaning: 'తిరస్కార వాదన / ప్రతిస్పందన',
          kannadaMeaning: 'ಖಂಡನೆ / ಮರುವಾದ',
          exampleSentence: 'He delivered a calm and reasoned rebuttal to the criticism.',
          phonetic: '/rɪˈbʌt.əl/',
        ),
        DailyVocabItem(
          word: 'Substantive',
          partOfSpeech: 'adjective',
          definition: 'Having a firm basis in reality; meaningful and significant.',
          malayalamMeaning: 'അർത്ഥവത്തായ / കാമ്പുള്ള',
          tamilMeaning: 'ஆழமான / அர்த்தமுள்ள',
          hindiMeaning: 'ठोस / सार्थक / मूल',
          teluguMeaning: 'అర్థవంతమైన / గట్టి పునాది గల',
          kannadaMeaning: 'ಸಾರಯುತವಾದ / ಮಹತ್ವದ',
          exampleSentence: 'Focus your speech on substantive insights rather than fluff.',
          phonetic: '/səbˈstæn.tɪv/',
        ),
      ];
      return;
    }

    if (widget.day == 5) {
      // 10 high-impact vocabulary words for Day 5 (Strategic Leadership & Crisis Resilience)
      _vocabList = const [
        DailyVocabItem(
          word: 'Decisive',
          partOfSpeech: 'adjective',
          definition: 'Having or showing the ability to make clear decisions quickly.',
          malayalamMeaning: 'നിർണായകമായ / ദൃഢമായ തീരുമാനം എടുക്കുന്ന',
          tamilMeaning: 'தீர்க்கமான முடிவெடுக்கும்',
          hindiMeaning: 'निर्णायक / दृढ़',
          teluguMeaning: 'నిర్ణయాత్మకమైన / స్పష్టమైన',
          kannadaMeaning: 'ನಿರ್ಣಾಯಕವಾದ',
          exampleSentence: 'In moments of crisis, a decisive speaker restores calm.',
          phonetic: '/dɪˈsaɪ.sɪv/',
        ),
        DailyVocabItem(
          word: 'Adversity',
          partOfSpeech: 'noun',
          definition: 'A difficult or unpleasant situation; hardship.',
          malayalamMeaning: 'പ്രതികൂലാവസ്ഥ / ദുരിതം',
          tamilMeaning: 'இன்னல்கள் / இடர்பாடு',
          hindiMeaning: 'विपत्ति / कठिनाई',
          teluguMeaning: 'ఆపద / ప్రతికూలత',
          kannadaMeaning: 'ಕಷ್ಟಕಾಲ / ವಿಪತ್ತು',
          exampleSentence: 'True leaders discover their voice during periods of adversity.',
          phonetic: '/ədˈvɜː.sə.ti/',
        ),
        DailyVocabItem(
          word: 'Fortitude',
          partOfSpeech: 'noun',
          definition: 'Courage in the face of pain, adversity, or danger.',
          malayalamMeaning: 'മനോധൈര്യം / സഹനശക്തി',
          tamilMeaning: 'மனோபலம் / விடாமுயற்சி',
          hindiMeaning: 'धैर्य / आत्मबल',
          teluguMeaning: 'మనోస్థైర్యం / ధైర్యం',
          kannadaMeaning: 'ಮನೋಧೈರ್ಯ / ಸಹನಶಕ್ತಿ',
          exampleSentence: 'She faced the difficult interview with quiet fortitude.',
          phonetic: '/ˈfɔː.tɪ.tʃuːd/',
        ),
        DailyVocabItem(
          word: 'Strategic',
          partOfSpeech: 'adjective',
          definition: 'Carefully planned to serve a major purpose or gain advantage.',
          malayalamMeaning: 'തന്ത്രപരമായ',
          tamilMeaning: 'வியூகரீதியான',
          hindiMeaning: 'रणनीतिक / योजनाबद्ध',
          teluguMeaning: 'వ్యూహాత్మక',
          kannadaMeaning: 'ಕಾರ್ಯತಂತ್ರದ',
          exampleSentence: 'Choose strategic vocabulary that elevates your spoken authority.',
          phonetic: '/strəˈtiː.dʒɪk/',
        ),
        DailyVocabItem(
          word: 'Unwavering',
          partOfSpeech: 'adjective',
          definition: 'Steady and resolute; not faltering.',
          malayalamMeaning: 'അചഞ്ചലമായ',
          tamilMeaning: 'அசைக்க முடியாத',
          hindiMeaning: 'अडिग / स्थिर',
          teluguMeaning: 'నిశ్చలమైన / స్థిరమైన',
          kannadaMeaning: 'ಅಚಲವಾದ / ದೃಢವಾದ',
          exampleSentence: 'Maintain an unwavering commitment to your 90-day goal.',
          phonetic: '/ʌnˈweɪ.vər.ɪŋ/',
        ),
        DailyVocabItem(
          word: 'Prerequisite',
          partOfSpeech: 'noun',
          definition: 'A required prior condition for something else to happen.',
          malayalamMeaning: 'മുൻവ്യവസ്ഥ / നിർബന്ധിത നിബന്ധന',
          tamilMeaning: 'முன்நிபந்தனை',
          hindiMeaning: 'अनिवार्य शर्त / पूर्वपेक्षा',
          teluguMeaning: 'ముందస్తు షరతు',
          kannadaMeaning: 'ಪೂರ್ವಭಾವಿ ಷರತ್ತು',
          exampleSentence: 'Active listening is a prerequisite for genuine fluency.',
          phonetic: '/ˌpriːˈrek.wɪ.zɪt/',
        ),
        DailyVocabItem(
          word: 'Contingency',
          partOfSpeech: 'noun',
          definition: 'A provision for an unforeseen event or circumstance.',
          malayalamMeaning: 'അപ്രതീക്ഷിത സംഭവങ്ങൾ നേരിടാനുള്ള മുന്നൊരുക്കം',
          tamilMeaning: 'எதிர்பாராத அவசரத் திட்டம்',
          hindiMeaning: 'आकस्मिक योजना',
          teluguMeaning: 'ఆకస్మిక ప్రణాళిక',
          kannadaMeaning: 'ತುರ್ತು ಸಿದ್ಧತೆ',
          exampleSentence: 'Always prepare a contingency response when speaking publicly.',
          phonetic: '/kənˈtɪn.dʒən.si/',
        ),
        DailyVocabItem(
          word: 'Paramount',
          partOfSpeech: 'adjective',
          definition: 'More important than anything else; supreme.',
          malayalamMeaning: 'പരമപ്രധാനമായ',
          tamilMeaning: 'தலையாய / மிக முக்கியமான',
          hindiMeaning: 'सर्वोपरि / अत्यधिक महत्वपूर्ण',
          teluguMeaning: 'అత్యంత ముఖ్యమైన / సర్వోన్నత',
          kannadaMeaning: 'ಅತ್ಯಂತ ಮುಖ್ಯವಾದ / ಅಗ್ರಗಣ್ಯ',
          exampleSentence: 'Consistency of daily effort is of paramount importance.',
          phonetic: '/ˈpær.ə.maʊnt/',
        ),
        DailyVocabItem(
          word: 'Catalyst',
          partOfSpeech: 'noun',
          definition: 'An agent that precipitates rapid change or progress.',
          malayalamMeaning: 'ഉത്തേജകം / മാറ്റത്തിന് വഴിയൊരുക്കുന്ന ഘടകം',
          tamilMeaning: 'மாற்றத்தை உந்துவிப்பவர்',
          hindiMeaning: 'उत्प्रेरक / गति देने वाला',
          teluguMeaning: 'ఉత్ప్రేరకం / మార్పుకు కారకం',
          kannadaMeaning: 'ವೇಗವರ್ಧಕ / ಪ್ರೇರಕ',
          exampleSentence: 'Peer conversations acted as a catalyst for his confidence.',
          phonetic: '/ˈkæt.əl.ɪst/',
        ),
        DailyVocabItem(
          word: 'Foresight',
          partOfSpeech: 'noun',
          definition: 'The ability to anticipate future needs or consequences.',
          malayalamMeaning: 'ദീർഘവീക്ഷണം',
          tamilMeaning: 'தொலைநோக்குப் பார்வை',
          hindiMeaning: 'दूरदर्शिता / भविष्य-दृष्टि',
          teluguMeaning: 'ముందుచూపు',
          kannadaMeaning: 'ದೂರದೃಷ್ಟಿ',
          exampleSentence: 'Great speakers use foresight to anticipate their listeners\' questions.',
          phonetic: '/ˈfɔː.saɪt/',
        ),
      ];
      return;
    }

    if (widget.day == 6) {
      // 10 high-impact vocabulary words for Day 6 (High-Stakes Negotiation & Resolving Impasses)
      _vocabList = const [
        DailyVocabItem(
          word: 'Compromise',
          partOfSpeech: 'noun',
          definition: 'An agreement or settlement of a dispute reached by mutual concession.',
          malayalamMeaning: 'വിട്ടുവീഴ്ച / ഒത്തുതീർപ്പ്',
          tamilMeaning: 'சமரச உடன்படிக்கை',
          hindiMeaning: 'समझौता / सुलह',
          teluguMeaning: 'రాజీ / సర్దుబాటు',
          kannadaMeaning: 'ರಾಜಿ / ಹೊಂದಾಣಿಕೆ',
          exampleSentence: 'A fair compromise protected the interests of both delegations.',
          phonetic: '/ˈkɒm.prə.maɪz/',
        ),
        DailyVocabItem(
          word: 'Equivocal',
          partOfSpeech: 'adjective',
          definition: 'Open to more than one interpretation; ambiguous.',
          malayalamMeaning: 'വ്യക്തതയില്ലാത്ത / അവ്യക്തമായ',
          tamilMeaning: 'தெளிவற்ற / இருபொருள் தரும்',
          hindiMeaning: 'अस्पष्ट / संदिग्ध',
          teluguMeaning: 'అస్పష్టమైన / సందేహాస్పద',
          kannadaMeaning: 'ಅಸ್ಪಷ್ಟ / ಸಂದಿಗ್ಧ',
          exampleSentence: 'Avoid equivocal phrasing when drafting formal agreements.',
          phonetic: '/ɪˈkwɪv.ə.kəl/',
        ),
        DailyVocabItem(
          word: 'Leverage',
          partOfSpeech: 'noun',
          definition: 'The power or influence to influence others and achieve a desired result.',
          malayalamMeaning: 'സ്വാധീനശക്തി / അനുകൂല നേട്ടം',
          tamilMeaning: 'சாதகமான செல்வாக்கு',
          hindiMeaning: 'रणनीतिक लाभ / प्रभाव',
          teluguMeaning: 'అనుకూల పరపతి / పలుకుబడి',
          kannadaMeaning: 'ಪ್ರಭಾವ / ಅನುಕೂಲಕರ ಶಕ್ತಿ',
          exampleSentence: 'Thorough preparation gives you leverage in difficult debates.',
          phonetic: '/ˈliː.vər.ɪdʒ/',
        ),
        DailyVocabItem(
          word: 'Pragmatic',
          partOfSpeech: 'adjective',
          definition: 'Dealing with things sensibly and realistically based on practical results.',
          malayalamMeaning: 'പ്രായോഗികമായ / കാര്യക്ഷമമായ',
          tamilMeaning: 'நடைமுறைக்கு ஏற்ற',
          hindiMeaning: 'व्यावहारिक / यथार्थवादी',
          teluguMeaning: 'ఆచరణాత్మకమైన',
          kannadaMeaning: 'ಪ್ರಾಯೋಗಿಕ / ವಾಸ್ತವಿಕ',
          exampleSentence: 'Adopt a pragmatic stance to overcome ideological division.',
          phonetic: '/præɡˈmæt.ɪk/',
        ),
        DailyVocabItem(
          word: 'Stipulate',
          partOfSpeech: 'verb',
          definition: 'Demand or specify a requirement typically as part of a formal bargain.',
          malayalamMeaning: 'വ്യവസ്ഥ ചെയ്യുക',
          tamilMeaning: 'நிபந்தனை விதித்தல்',
          hindiMeaning: 'शर्त लगाना / निर्धारित करना',
          teluguMeaning: 'నిబంధన విధించు',
          kannadaMeaning: 'ಷರತ್ತು ವಿಧಿಸು',
          exampleSentence: 'The treaty stipulations ensured safe passage for all traders.',
          phonetic: '/ˈstɪp.jə.leɪt/',
        ),
        DailyVocabItem(
          word: 'Concur',
          partOfSpeech: 'verb',
          definition: 'Be of the same opinion; agree.',
          malayalamMeaning: 'യോജിക്കുക / ഏകാഭിപ്രായത്തിലെത്തുക',
          tamilMeaning: 'ஒப்புக்கொள்ளுதல் / உடன்படுதல்',
          hindiMeaning: 'सहमत होना',
          teluguMeaning: 'ఏకీభవించు / అంగీకరించు',
          kannadaMeaning: 'ಒಪ್ಪಿಕೊಳ್ಳು / ಸಮ್ಮತಿಸು',
          exampleSentence: 'All committee members concurred with the proposed compromise.',
          phonetic: '/kənˈkɜːr/',
        ),
        DailyVocabItem(
          word: 'Impasse',
          partOfSpeech: 'noun',
          definition: 'A situation in which no progress is possible due to disagreement.',
          malayalamMeaning: 'പ്രതിസന്ധി / വഴിമുട്ടിയ അവസ്ഥ',
          tamilMeaning: 'முட்டுக்கட்டை / முடிவு காண முடியாத நிலை',
          hindiMeaning: 'गतिरोध / बंद गली',
          teluguMeaning: 'ప్రతిష్టంభన',
          kannadaMeaning: 'ಬಿಕ್ಕಟ್ಟು / ಕಗ್ಗಂಟು',
          exampleSentence: 'A skilled mediator can break an impasse and restore dialogue.',
          phonetic: '/æmˈpɑːs/',
        ),
        DailyVocabItem(
          word: 'Unilateral',
          partOfSpeech: 'adjective',
          definition: 'Performed by or affecting only one party without agreement from others.',
          malayalamMeaning: 'ഏകപക്ഷീയമായ',
          tamilMeaning: 'ஒருதலைப்பட்சமான',
          hindiMeaning: 'एकतरफा / एकपक्षीय',
          teluguMeaning: 'ఏకపక్ష',
          kannadaMeaning: 'ಏಕಪಕ್ಷೀಯ',
          exampleSentence: 'Unilateral decisions alienate partners and fracture trust.',
          phonetic: '/ˌjuː.nɪˈlæt.ər.əl/',
        ),
        DailyVocabItem(
          word: 'Arbitration',
          partOfSpeech: 'noun',
          definition: 'The use of an independent person to officially settle a dispute.',
          malayalamMeaning: 'മധ്യസ്ഥത / തർക്കപരിഹാരം',
          tamilMeaning: 'மத்தியஸ்தம் / நடுவர் தீர்ப்பு',
          hindiMeaning: 'मध्यस्थता / पंच फैसला',
          teluguMeaning: 'మధ్యవర్తిత్వం',
          kannadaMeaning: 'ಮಧ್ಯಸ್ಥಿಕೆ',
          exampleSentence: 'The dispute was successfully resolved through international arbitration.',
          phonetic: '/ˌɑː.bɪˈtreɪ.ʃən/',
        ),
        DailyVocabItem(
          word: 'Equitable',
          partOfSpeech: 'adjective',
          definition: 'Fair and impartial; just to all involved parties.',
          malayalamMeaning: 'നീതിപൂർവ്വമായ / സമത്വമുള്ള',
          tamilMeaning: 'நியாயமான / சமத்துவமான',
          hindiMeaning: 'न्यायसंगत / निष्पक्ष',
          teluguMeaning: 'సమన్యాయమైన / న్యాయబద్ధమైన',
          kannadaMeaning: 'ನ್ಯಾಯಸಮ್ಮತವಾದ',
          exampleSentence: 'They created an equitable distribution of resources across the region.',
          phonetic: '/ˈek.wɪ.tə.bəl/',
        ),
      ];
      return;
    }

    if (widget.day == 7) {
      // 10 high-impact vocabulary words for Day 7 (Rhetorical Oratory & Public Speaking)
      _vocabList = const [
        DailyVocabItem(
          word: 'Eloquent',
          partOfSpeech: 'adjective',
          definition: 'Fluent or persuasive in speaking or writing.',
          malayalamMeaning: 'വാഗ്മിയായ / വാക്ചാതുര്യമുള്ള',
          tamilMeaning: 'சொல்வன்மை மிக்க / நயமான',
          hindiMeaning: 'वाक्पटु / सुवक्ता',
          teluguMeaning: 'వాక్చాతుర్యం గల / మనోహరంగా మాట్లాడే',
          kannadaMeaning: 'ವಾಗ್ಮಿತ್ವದ / ಸ್ಪಷ್ಟ ವಾಕ್ಪಟುತ್ವದ',
          exampleSentence: 'Her eloquent address moved the entire international forum.',
          phonetic: '/ˈel.ə.kwənt/',
        ),
        DailyVocabItem(
          word: 'Perspicacious',
          partOfSpeech: 'adjective',
          definition: 'Having a ready insight into and deep understanding of things.',
          malayalamMeaning: 'സൂക്ഷ്മദൃഷ്ടിയുള്ള / കാര്യങ്ങൾ വേഗത്തിൽ ഗ്രഹിക്കുന്ന',
          tamilMeaning: 'கூர்மதி கொண்ட / ஆழமான அறிவுள்ள',
          hindiMeaning: 'कुशाग्रबुद्धि / तीक्ष्ण दृष्टि वाला',
          teluguMeaning: 'సూక్ష్మబుద్ధి గల / తీక్షణమైన అవగాహన గల',
          kannadaMeaning: 'ತೀಕ್ಷ್ಣಮತಿಯ / ಒಳನೋಟವುಳ್ಳ',
          exampleSentence: 'The perspicacious analyst uncovered the underlying trend.',
          phonetic: '/ˌpɜː.spɪˈkeɪ.ʃəs/',
        ),
        DailyVocabItem(
          word: 'Rhetoric',
          partOfSpeech: 'noun',
          definition: 'The art of effective or persuasive speaking or writing.',
          malayalamMeaning: 'ഭാഷണകലാ ചാതുര്യം / പ്രസംഗരീതി',
          tamilMeaning: 'சொற்பொழிவாற்றல் / நயவுரைக்கலை',
          hindiMeaning: 'वक्तृत्व कला / भाषा-कौशल',
          teluguMeaning: 'భాషణ కళా నైపుణ్యం',
          kannadaMeaning: 'ಭಾಷಣ ಕಲೆ / ವಾಕ್ಶೈಲಿ',
          exampleSentence: 'Master the principles of classical rhetoric to inspire crowds.',
          phonetic: '/ˈret.ər.ɪk/',
        ),
        DailyVocabItem(
          word: 'Resonate',
          partOfSpeech: 'verb',
          definition: 'Evoke or suggest images, memories, and emotions in listeners.',
          malayalamMeaning: 'മനസ്സിൽ പ്രതിധ്വനിക്കുക / സ്വാധീനിക്കുക',
          tamilMeaning: 'மனதில் எதிரொலித்தல்',
          hindiMeaning: 'गूंजना / मन को छू जाना',
          teluguMeaning: 'హృదయంలో ప్రతిధ్వనించు / ఆకట్టుకొను',
          kannadaMeaning: 'ಮನಸ್ಸಿನಲ್ಲಿ ಪ್ರತಿಧ್ವನಿಸು / ಪ್ರಭಾವಿಸು',
          exampleSentence: 'Her heartfelt words resonated with learners across every culture.',
          phonetic: '/ˈrez.ən.eɪt/',
        ),
        DailyVocabItem(
          word: 'Compelling',
          partOfSpeech: 'adjective',
          definition: 'Evoking interest, attention, or admiration powerfully.',
          malayalamMeaning: 'മനസ്സിനെ ആകർഷിക്കുന്ന / ശക്തമായ',
          tamilMeaning: 'ஈர்க்கும் ஆற்றல் மிக்க',
          hindiMeaning: 'सम्मोहक / अकाट्य / प्रभावशाली',
          teluguMeaning: 'బలమైన / ఆకట్టుకునే',
          kannadaMeaning: 'ಬಲವಾದ / ಸೆಳೆಯುವ',
          exampleSentence: 'She presented a compelling case for conversational immersion.',
          phonetic: '/kəmˈpel.ɪŋ/',
        ),
        DailyVocabItem(
          word: 'Discourse',
          partOfSpeech: 'noun',
          definition: 'Written or spoken communication or debate on an intellectual topic.',
          malayalamMeaning: 'പ്രഭാഷണം / വിജ്ഞാനപ്രദമായ ചർച്ച',
          tamilMeaning: 'உரையாடல் / கருத்தாடல்',
          hindiMeaning: 'प्रवचन / गंभीर विमर्श',
          teluguMeaning: 'విద్వత్ గోష్ఠి / చర్చ',
          kannadaMeaning: 'ಸಂವಾದ / ತಾತ್ವಿಕ ಚರ್ಚೆ',
          exampleSentence: 'Constructive discourse bridges cultural and linguistic divides.',
          phonetic: '/ˈdɪs.kɔːs/',
        ),
        DailyVocabItem(
          word: 'Vindicate',
          partOfSpeech: 'verb',
          definition: 'Clear of blame, suspicion, or show to be right through proof.',
          malayalamMeaning: 'ന്യായീകരിക്കുക / ശരിയാണെന്ന് തെളിയിക്കുക',
          tamilMeaning: 'உண்மையை நிரூபித்தல் / நியாயப்படுத்துதல்',
          hindiMeaning: 'दोषमुक्त करना / सत्य साबित करना',
          teluguMeaning: 'నిర్దోషిగా రుజువు చేయు / సమర్థించు',
          kannadaMeaning: 'ದೋಷಮುಕ್ತಗೊಳಿಸು / ಸರಿ ಎಂದು ತೋರಿಸು',
          exampleSentence: 'Rigorous empirical research vindicated her controversial thesis.',
          phonetic: '/ˈvɪn.dɪ.keɪt/',
        ),
        DailyVocabItem(
          word: 'Profound',
          partOfSpeech: 'adjective',
          definition: 'Having or showing great knowledge, insight, or emotional depth.',
          malayalamMeaning: 'ഗാഢമായ / അഗാധമായ',
          tamilMeaning: 'ஆழமான / மகத்தான',
          hindiMeaning: 'गहरा / गंभीर / प्रकांड',
          teluguMeaning: 'లోతైన / ప్రగాఢమైన',
          kannadaMeaning: 'ಆಳವಾದ / ಪ್ರಗಾಢ',
          exampleSentence: 'A profound understanding of phonetics refines native accents.',
          phonetic: '/prəˈfaʊnd/',
        ),
        DailyVocabItem(
          word: 'Exemplary',
          partOfSpeech: 'adjective',
          definition: 'Serving as a desirable model; representing the best of its kind.',
          malayalamMeaning: 'മാതൃകാപരമായ',
          tamilMeaning: 'முன்மாதிரியான / போற்றத்தக்க',
          hindiMeaning: 'अनुकरणीय / आदर्श',
          teluguMeaning: 'ఆదర్శవంతమైన / ఆదర్శప్రాయ',
          kannadaMeaning: 'ಮಾದರಿಯಾದ / ಆದರ್ಶಪ್ರಾಯ',
          exampleSentence: 'His exemplary dedication inspired every member of the hub.',
          phonetic: '/ɪɡˈzem.plər.i/',
        ),
        DailyVocabItem(
          word: 'Articulate',
          partOfSpeech: 'adjective',
          definition: 'Expressing oneself clearly, coherently, and effectively.',
          malayalamMeaning: 'വ്യക്തമായി ആശയങ്ങൾ പ്രകടിപ്പിക്കുന്ന',
          tamilMeaning: 'தெளிவாக எடுத்துரைக்கும்',
          hindiMeaning: 'स्पष्टवादी / सुस्पष्ट',
          teluguMeaning: 'స్పష్టంగా భావాలు తెలిపే',
          kannadaMeaning: 'ಸ್ಪಷ್ಟವಾಗಿ ಅಭಿವ್ಯಕ್ತಿಸುವ',
          exampleSentence: 'An articulate orator commands respect without raising their voice.',
          phonetic: '/ɑːˈtɪk.jə.lət/',
        ),
      ];
      return;
    }

    if (widget.day == 8) {
      // 10 high-impact vocabulary words for Day 8 (Complex Problem Solving & Global Philosophical Synthesis)
      _vocabList = const [
        DailyVocabItem(
          word: 'Paradigm',
          partOfSpeech: 'noun',
          definition: 'A distinct set of concepts, theories, or thought patterns.',
          malayalamMeaning: 'ചിന്താരീതി / മാതൃക',
          tamilMeaning: 'சிந்தனை மாதிரி / கோட்பாடு',
          hindiMeaning: 'विचारधारा / दृष्टिकोण का ढांचा',
          teluguMeaning: 'దృక్పథ నమూనా',
          kannadaMeaning: 'ಚಿಂತನಾ ಮಾದರಿ',
          exampleSentence: 'Interactive peer speaking created a new paradigm in language learning.',
          phonetic: '/ˈpær.ə.daɪm/',
        ),
        DailyVocabItem(
          word: 'Ubiquitous',
          partOfSpeech: 'adjective',
          definition: 'Present, appearing, or found everywhere simultaneously.',
          malayalamMeaning: 'സർവ്വവ്യാപിയായ',
          tamilMeaning: 'எங்கும் நிறைந்திருக்கின்ற',
          hindiMeaning: 'सर्वव्यापी',
          teluguMeaning: 'సర్వవ్యాప్తమైన',
          kannadaMeaning: 'ಸರ್ವವ್ಯಾಪಿ',
          exampleSentence: 'English has become a ubiquitous global bridge for knowledge.',
          phonetic: '/juːˈbɪk.wɪ.təs/',
        ),
        DailyVocabItem(
          word: 'Ephemeral',
          partOfSpeech: 'adjective',
          definition: 'Lasting for a very short time; transient.',
          malayalamMeaning: 'ക്ഷണികമായ / അല്പായുസ്സുള്ള',
          tamilMeaning: 'நிலையற்ற / கணநேர',
          hindiMeaning: 'क्षणिक / अल्पकालिक',
          teluguMeaning: 'క్షణికమైన / అల్పకాలిక',
          kannadaMeaning: 'ಕ್ಷಣಿಕವಾದ / ಅಲ್ಪಕಾಲದ',
          exampleSentence: 'Do not chase ephemeral applause; cultivate lasting speaking mastery.',
          phonetic: '/ɪˈfem.ər.əl/',
        ),
        DailyVocabItem(
          word: 'Dichotomy',
          partOfSpeech: 'noun',
          definition: 'A division or contrast between two things represented as opposed.',
          malayalamMeaning: 'വിഭജനം / വിരുദ്ധ ചേരിതിരിവ്',
          tamilMeaning: 'இருதுருவ வேறுபாடு',
          hindiMeaning: 'द्विभाजन / दो विपरीत पक्ष',
          teluguMeaning: 'ద్వైదీభావం / విభజన',
          kannadaMeaning: 'ದ್ವಿಮುಖತೆ / ವಿಭಜನೆ',
          exampleSentence: 'The debate dismantled the false dichotomy between speed and accuracy.',
          phonetic: '/daɪˈkɒt.ə.mi/',
        ),
        DailyVocabItem(
          word: 'Synthesize',
          partOfSpeech: 'verb',
          definition: 'Combine multiple ideas, elements, or systems into a coherent whole.',
          malayalamMeaning: 'സമന്വയിപ്പിക്കുക',
          tamilMeaning: 'ஒருங்கிணைத்தல் / தொகுத்தல்',
          hindiMeaning: 'संश्लेषण करना / जोड़ना',
          teluguMeaning: 'సమన్వయపరచు',
          kannadaMeaning: 'ಸಂಶ್ಲೇಷಿಸು / ಸಮನ್ವಯಗೊಳಿಸು',
          exampleSentence: 'Synthesize grammar rules with real conversation to achieve fluency.',
          phonetic: '/ˈsɪn.θə.saɪz/',
        ),
        DailyVocabItem(
          word: 'Autonomous',
          partOfSpeech: 'adjective',
          definition: 'Having the freedom or capacity to act independently.',
          malayalamMeaning: 'സ്വയംഭരണാധികാരമുള്ള / സ്വതന്ത്രമായ',
          tamilMeaning: 'சுயாட்சி கொண்ட / தன்னாட்சி',
          hindiMeaning: 'स्वायत्त / स्वतंत्र',
          teluguMeaning: 'స్వయంప్రతిపత్తి గల',
          kannadaMeaning: 'ಸ್ವಾಯತ್ತ / ಸ್ವತಂತ್ರ',
          exampleSentence: 'After 90 days, you will become an autonomous English communicator.',
          phonetic: '/ɔːˈtɒn.ə.məs/',
        ),
        DailyVocabItem(
          word: 'Omnipresent',
          partOfSpeech: 'adjective',
          definition: 'Widely or constantly encountered; common or widespread.',
          malayalamMeaning: 'എല്ലായിടത്തും സന്നിഹിതമായ',
          tamilMeaning: 'எல்லா இடங்களிலும் உள்ள',
          hindiMeaning: 'सर्वत्र विद्यमान',
          teluguMeaning: 'సర్వత్రా వ్యాపించియున్న',
          kannadaMeaning: 'ಎಲ್ಲೆಡೆ ಉಪಸ್ಥಿತವಿರುವ',
          exampleSentence: 'Technology is an omnipresent reality in modern communication.',
          phonetic: '/ˌɒm.nɪˈprez.ənt/',
        ),
        DailyVocabItem(
          word: 'Anachronistic',
          partOfSpeech: 'adjective',
          definition: 'Belonging to an earlier period; conspicuously out of date.',
          malayalamMeaning: 'കാലഹരണപ്പെട്ട',
          tamilMeaning: 'காலத்திற்கு ஒவ்வாத / பழமையான',
          hindiMeaning: 'पुराना / कालभ्रमित',
          teluguMeaning: 'కాలం చెల్లిన',
          kannadaMeaning: 'ಕಾಲಕ್ಕೆ ಹೊಂದದ / ಹಳತಾದ',
          exampleSentence: 'Passive rote learning is an anachronistic approach to spoken fluency.',
          phonetic: '/əˌnæk.rəˈnɪs.tɪk/',
        ),
        DailyVocabItem(
          word: 'Apex',
          partOfSpeech: 'noun',
          definition: 'The top or highest point of achievement or development.',
          malayalamMeaning: 'ഉന്നതി / പരമോന്നത സ്ഥാനം',
          tamilMeaning: 'உச்சி / உச்சக்கட்டம்',
          hindiMeaning: 'शीर्ष / सर्वोच्च शिखर',
          teluguMeaning: 'శిఖరాగ్రం / అత్యున్నత స్థానం',
          kannadaMeaning: 'ಶಿಖರ / ಪರಮೋಚ್ಛ ಹಂತ',
          exampleSentence: 'Confident international debate marks the apex of linguistic mastery.',
          phonetic: '/ˈeɪ.peks/',
        ),
        DailyVocabItem(
          word: 'Prerequisite',
          partOfSpeech: 'noun',
          definition: 'A thing required as a prior condition for something else to exist.',
          malayalamMeaning: 'മുൻവ്യവസ്ഥ',
          tamilMeaning: 'முன்நிபந்தனை',
          hindiMeaning: 'पूर्वपेक्षा / आवश्यक पूर्वशर्त',
          teluguMeaning: 'ముందస్తు షరతు',
          kannadaMeaning: 'ಪೂರ್ವಭಾವಿ ಷರತ್ತು',
          exampleSentence: 'Unbroken focus is a vital prerequisite for complex problem solving.',
          phonetic: '/ˌpriːˈrek.wɪ.zɪt/',
        ),
      ];
      return;
    }

    // 10 high-impact vocabulary words for Day 1 with Multilingual translations
    _vocabList = const [
      DailyVocabItem(
        word: 'Ambition',
        partOfSpeech: 'noun',
        definition: 'A strong desire to achieve success or greatness.',
        malayalamMeaning: 'ഉയർന്ന ലക്ഷ്യം / ആഗ്രഹം',
        tamilMeaning: 'உயர்ந்த லட்சியம் / விருப்பம்',
        hindiMeaning: 'महत्वाकांक्षा / बड़ा लक्ष्य',
        teluguMeaning: 'గొప్ప ఆశయం / ఆకాంక్ష',
        kannadaMeaning: 'ಉನ್ನತ ಆಕಾಂಕ್ಷೆ / ಗುರಿ',
        exampleSentence: 'Her ambition is to speak fluent English with confidence.',
        phonetic: '/æmˈbɪʃ.ən/',
      ),
      DailyVocabItem(
        word: 'Courage',
        partOfSpeech: 'noun',
        definition: 'The ability to do something that frightens you; bravery.',
        malayalamMeaning: 'ധൈര്യം',
        tamilMeaning: 'தைரியம் / துணிவு',
        hindiMeaning: 'साहस / हिम्मत',
        teluguMeaning: 'ధైర్యం',
        kannadaMeaning: 'ಧೈರ್ಯ / ಸಾಹಸ',
        exampleSentence: 'Have the courage to speak without fear of making mistakes.',
        phonetic: '/ˈkʌr.ɪdʒ/',
      ),
      DailyVocabItem(
        word: 'Diligent',
        partOfSpeech: 'adjective',
        definition: 'Showing careful and persistent work and effort.',
        malayalamMeaning: 'കഠിനാധ്വാനം ചെയ്യുന്ന / ശ്രദ്ധാലുവായ',
        tamilMeaning: 'விடாமுயற்சியுள்ள / கடின உழைப்பாளி',
        hindiMeaning: 'परिश्रमी / मेहनती',
        teluguMeaning: 'శ్రద్ధగల / కష్టపడి పనిచేసే',
        kannadaMeaning: 'ಪರಿಶ್ರಮಿ / ಜಾಗರೂಕ',
        exampleSentence: 'A diligent student practices English every single day.',
        phonetic: '/ˈdɪl.ə.dʒənt/',
      ),
      DailyVocabItem(
        word: 'Express',
        partOfSpeech: 'verb',
        definition: 'To convey feelings, thoughts, or ideas in words.',
        malayalamMeaning: 'വ്യക്തമാക്കുക / പ്രകടിപ്പിക്കുക',
        tamilMeaning: 'வெளிப்படுத்து / விளக்கு',
        hindiMeaning: 'व्यक्त करना / कहना',
        teluguMeaning: 'వ్యక్తీకరించు / తెలుపు',
        kannadaMeaning: 'ವ್ಯಕ್ತಪಡಿಸು / ಪ್ರಕಟಿಸು',
        exampleSentence: 'Reading books will help you express your thoughts easily.',
        phonetic: '/ɪkˈspres/',
      ),
      DailyVocabItem(
        word: 'Fluency',
        partOfSpeech: 'noun',
        definition: 'The ability to speak or write a language easily and accurately.',
        malayalamMeaning: 'സരളത / അനായാസമായ സംസാരം',
        tamilMeaning: 'சரளம் / தடையற்ற பேச்சு',
        hindiMeaning: 'धाराप्रवाह / सहज बोलना',
        teluguMeaning: 'ధారాళత / నిరాటంక సంభాషణ',
        kannadaMeaning: 'ನಿರರ್ಗಳತೆ / ಸರಾಗ ಮಾತು',
        exampleSentence: 'Consistency across 90 days creates unstoppable fluency.',
        phonetic: '/ˈfluː.ən.si/',
      ),
      DailyVocabItem(
        word: 'Grateful',
        partOfSpeech: 'adjective',
        definition: 'Feeling or showing appreciation for kindness received.',
        malayalamMeaning: 'നന്ദിയുള്ള',
        tamilMeaning: 'நன்றியுடைய / கடமைப்பட்ட',
        hindiMeaning: 'आभारी / कृतज्ञ',
        teluguMeaning: 'కృతజ్ఞత గల',
        kannadaMeaning: 'ಕೃತಜ್ಞ / ಧನ್ಯವಾದ',
        exampleSentence: 'I am grateful for every mate who helps me practice speaking.',
        phonetic: '/ˈɡreɪt.fəl/',
      ),
      DailyVocabItem(
        word: 'Hesitate',
        partOfSpeech: 'verb',
        definition: 'To pause before saying or doing something through uncertainty.',
        malayalamMeaning: 'മടിക്കുക / സംശയിച്ചു നിൽക്കുക',
        tamilMeaning: 'தயங்குதல் / தயக்கம்',
        hindiMeaning: 'हिचकिचाना / झिझकना',
        teluguMeaning: 'సంకోచించు / తటపటాయించు',
        kannadaMeaning: 'ಹಿಂಜರಿಯು / ಅನುಮಾನಿಸು',
        exampleSentence: 'Do not hesitate when speaking; just let the words flow.',
        phonetic: '/ˈhez.ə.teɪt/',
      ),
      DailyVocabItem(
        word: 'Inspire',
        partOfSpeech: 'verb',
        definition: 'To fill someone with the urge or ability to do something.',
        malayalamMeaning: 'പ്രചോദിപ്പിക്കുക',
        tamilMeaning: 'ஊக்கப்படுத்து / ஊக்கம் அளி',
        hindiMeaning: 'प्रेरित करना',
        teluguMeaning: 'ప్రేరేపించు / ఉత్సాహపరచు',
        kannadaMeaning: 'ಪ್ರೇರೇಪಿಸು / ಸ್ಪೂರ್ತಿ ನೀಡು',
        exampleSentence: 'Great communicators inspire people around the world.',
        phonetic: '/ɪnˈspaɪər/',
      ),
      DailyVocabItem(
        word: 'Journey',
        partOfSpeech: 'noun',
        definition: 'An act of traveling from one place or milestone to another.',
        malayalamMeaning: 'യാത്ര / ഘട്ടം',
        tamilMeaning: 'பயணம் / வளர்ச்சிப் பாதை',
        hindiMeaning: 'यात्रा / सफर',
        teluguMeaning: 'ప్రయాణం / ప్రస్థానం',
        kannadaMeaning: 'ಪ್ರಯಾಣ / ಹಂತ',
        exampleSentence: 'Your transformative 90-day English journey begins today.',
        phonetic: '/ˈdʒɜː.ni/',
      ),
      DailyVocabItem(
        word: 'Knowledge',
        partOfSpeech: 'noun',
        definition: 'Facts, information, and skills acquired through experience.',
        malayalamMeaning: 'അറിവ്',
        tamilMeaning: 'அறிவு / ஞானம்',
        hindiMeaning: 'ज्ञान / विद्या',
        teluguMeaning: 'జ్ఞానము',
        kannadaMeaning: 'ಜ್ಞಾನ / ತಿಳುವಳಿಕೆ',
        exampleSentence: 'Knowledge is gained by learning, and fluency by speaking.',
        phonetic: '/ˈnɒl.ɪdʒ/',
      ),
    ];
  }

  Future<void> _loadSavedMissionState() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    setState(() {
      _selectedLanguage = prefs.getString('pocket_mission_pref_lang') ?? 'Malayalam';
      _hubChatVerified = prefs.getBool('${dayKey}_hub_chat') ?? false;
      _peerCallVerified = prefs.getBool('${dayKey}_peer_call') ?? false;
      _vocabMemorized = prefs.getBool('${dayKey}_vocab_mem') ?? false;
      _readingNotesCompleted = prefs.getBool('${dayKey}_reading') ?? false;
      _revisionQuizPassed = prefs.getBool('${dayKey}_quiz') ?? false;
      _defenseTrapArmed = prefs.getBool('${dayKey}_defense') ?? false;
      _trialRaidLaunched = prefs.getBool('${dayKey}_raid') ?? false;
    });
  }

  Future<void> _saveSubtask(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    await prefs.setBool('${dayKey}_$key', value);
  }

  int get _completedSubtasksCount {
    int count = 0;
    if (_hubChatVerified) count++;
    if (_peerCallVerified) count++;
    if (_vocabMemorized) count++;
    if (_readingNotesCompleted) count++;
    if (_revisionQuizPassed) count++;
    if (_defenseTrapArmed) count++;
    if (_trialRaidLaunched) count++;
    return count;
  }

  bool get _isAllCompleted => _completedSubtasksCount >= 7;
  bool get _isTimerCompleted => _timerService.hasReachedTarget;
  bool get _canClaimAndAdvance => _isTimerCompleted && _isAllCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // Subtle dark vignette background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF070B14)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Deck
                _buildHeader(context),

                // Mission Body Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      // ⏱️ 60-Min Daily Practice Study Timer Card
                      _buildDailyStudyTimerCard(),

                      const SizedBox(height: 18),

                      // 📋 Mission Subtasks Tracker Header
                      _buildMissionProgressCard(),

                      const SizedBox(height: 18),

                      // Subtask 1: 💬 English Hub Group Practice
                      _buildSubtaskCard(
                        stepNumber: '1',
                        icon: '💬',
                        title: 'English Hub Group Practice',
                        description: 'Enter the active English Hub and send at least 10–15 English messages to fellow learners to build active muscle memory.',
                        isVerified: _hubChatVerified,
                        actionLabel: 'OPEN ENGLISH HUB CHAT',
                        actionColor: const Color(0xFFFFFC00),
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WhatsAppGroupChat(
                                groupId: 'english_hub',
                                groupName: 'English Hub',
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _hubChatVerified = true);
                              _saveSubtask('hub_chat', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _hubChatVerified = true);
                          _saveSubtask('hub_chat', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 2: 🎙️ Anonymous Peer Talk / Call
                      _buildSubtaskCard(
                        stepNumber: '2',
                        icon: '🎙️',
                        title: 'Peer Call / 1-on-1 English Talk',
                        description: 'Connect with 2 mates for live conversation practice to conquer speaking hesitation.',
                        isVerified: _peerCallVerified,
                        actionLabel: 'FIND 1-ON-1 PEERS',
                        actionColor: const Color(0xFF00E5FF),
                        onAction: () {
                          // Auto-start 60-min practice timer as instructed in audio
                          if (!_timerService.isRunning && !_timerService.hasReachedTarget) {
                            _timerService.toggleTimer();
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StagePeerMatchmakerPage(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _peerCallVerified = true);
                              _saveSubtask('peer_call', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _peerCallVerified = true);
                          _saveSubtask('peer_call', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 3: 🧠 10 Vocabulary Words to Memorize
                      _buildVocabDeckCard(),

                      const SizedBox(height: 14),

                      // Subtask 4: 📖 Core Notes & Reading Passage
                      _buildReadingNotesCard(),

                      const SizedBox(height: 14),

                      // Subtask 5: ✍️ Quick Revision Mini-Quiz
                      _buildRevisionQuizCard(),

                      const SizedBox(height: 14),

                      // Subtask 6: 🛡️ Craft Citadel Defense Trap
                      _buildSubtaskCard(
                        stepNumber: '6',
                        icon: '🛡️',
                        title: 'Add Day ${widget.day} Citadel Defense Shield',
                        description: 'Arm your front gate with 1 authentic English challenge to defend your house from raiders. (Shield Slot ${widget.day} of ${widget.day})',
                        isVerified: _defenseTrapArmed,
                        actionLabel: _defenseTrapArmed ? 'EDIT DEFENSE SHIELD 🛡️' : 'ADD DEFENSE SHIELD 🛡️',
                        actionColor: const Color(0xFF8B5CF6),
                        onAction: () {
                          PocketDefenseTrapModal.show(context, widget.day);
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                        onVerify: () {
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 7: ⚔️ Launch First Trial Raid
                      _buildSubtaskCard(
                        stepNumber: '7',
                        icon: '⚔️',
                        title: 'First Trial Siege Attack (Level 5 House)',
                        description: 'Launch your first raid against a Level 5 Neighbor Citadel in the Battle Arena to test your combat English!',
                        isVerified: _trialRaidLaunched,
                        actionLabel: 'LAUNCH BATTLE ARENA RAID',
                        actionColor: const Color(0xFFEF4444),
                        onAction: () {
                          final rival = PocketNeighbor(
                            id: 'trial_citadel_lvl5',
                            name: 'Shadow Sentinel Lvl 5',
                            day: 5,
                            streak: 8,
                            rank: 'Rival Fortress',
                            paletteId: 'regal_amethyst',
                            statusMessage: 'Can you breach my English gates?',
                            hasActiveShield: true,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PocketBattleArenaPage(
                                neighbor: rival,
                                userDay: widget.day,
                                userStreak: 1,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _trialRaidLaunched = true);
                              _saveSubtask('raid', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _trialRaidLaunched = true);
                          _saveSubtask('raid', true);
                        },
                      ),

                      const SizedBox(height: 20),

                      // 🛡️ House Defense Shield Banner (Audio Directive: Show right inside Day 1!)
                      _buildShieldUnlockBanner(),

                      const SizedBox(height: 10),

                      // 🏆 Final Mission Completion Button
                      _buildFinalClaimButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TOP APP BAR HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DAY ${widget.day}',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ENGLISH LEARNING MISSION',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stage ${widget.day}/90 • Reward: +${100 + (widget.day - 1) * 50} XP',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  '+${100 + (widget.day - 1) * 50} XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• $_completedSubtasksCount/7',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ⏱️ 60-MINUTE PRACTICE TIMER CARD ---
  Widget _buildDailyStudyTimerCard() {
    final isRunning = _timerService.isRunning;
    final isTargetMet = _timerService.hasReachedTarget;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRunning
              ? const Color(0xFFFFD700)
              : (isTargetMet ? const Color(0xFF10B981) : Colors.white12),
          width: (isRunning || isTargetMet) ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isRunning)
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          if (isTargetMet)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'DAILY 60-MIN PRACTICE TIMER',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isRunning
                      ? Colors.green.withValues(alpha: 0.2)
                      : (isTargetMet
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.white10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isRunning
                      ? 'ACTIVE'
                      : (isTargetMet
                          ? 'TARGET MET'
                          : _timerService.pauseReason.toUpperCase()),
                  style: TextStyle(
                    color: isRunning
                        ? Colors.greenAccent
                        : (isTargetMet ? const Color(0xFF10B981) : Colors.white54),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rule: Spend 60+ mins practicing English daily (chat, voice calls, drills). Pauses when leaving app.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _timerService.formatTime(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/ ${_timerService.formatTime(_timerService.targetSeconds)} Target',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _timerService.progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isTargetMet
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFFC00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (isTargetMet) {
                    _timerService.addAnotherHourPractice();
                  } else {
                    _timerService.toggleTimer();
                  }
                },
                icon: Icon(
                  isRunning
                      ? Icons.pause_rounded
                      : (isTargetMet ? Icons.add_alarm_rounded : Icons.play_arrow_rounded),
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  isRunning
                      ? 'PAUSE'
                      : (isTargetMet ? '+60m' : 'START'),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning
                      ? Colors.amberAccent
                      : (isTargetMet ? const Color(0xFF10B981) : const Color(0xFFFFFC00)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          // ⚠️ Extra Hour Prompt Banner when 60 minutes are met but subtasks remain
          if (isTargetMet && !_isAllCompleted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '60-Min Target Reached! (${7 - _completedSubtasksCount} subtasks pending)',
                          style: GoogleFonts.outfit(
                            color: Colors.amberAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice timer automatically stopped at 60:00. You must complete all 7 subtasks to advance to Day ${widget.day + 1}. Complete the tasks below, or add an extra 1-hour practice session.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.addAnotherHourPractice();
                          },
                          icon: const Icon(Icons.add_alarm_rounded, size: 16, color: Color(0xFFFFFC00)),
                          label: Text(
                            '+ ADD 1-HR PRACTICE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFFC00),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFFC00)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.restartPracticeSession();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                          label: Text(
                            'RESTART 1-HR RUN',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 📋 OVERALL MISSION PROGRESS CARD ---
  Widget _buildMissionProgressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎯', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${widget.day} Subtask Checklist',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete all 7 actions below to claim Day ${widget.day} rewards & badge.',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${((_completedSubtasksCount / 7) * 100).toInt()}%',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFFC00),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --- GENERIC SUBTASK CARD ---
  Widget _buildSubtaskCard({
    required String stepNumber,
    required String icon,
    required String title,
    required String description,
    required bool isVerified,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
    required VoidCallback onVerify,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFF10B981) : Colors.white12,
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP $stepNumber',
                  style: TextStyle(
                    color: isVerified ? Colors.black : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: actionColor,
                    side: BorderSide(color: actionColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onVerify,
                icon: Icon(isVerified ? Icons.check_rounded : Icons.done_all_rounded, color: Colors.black, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isVerified ? const Color(0xFF10B981) : Colors.white24,
                ),
                tooltip: 'Mark Complete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🌐 Language Category Selector Bar (Audio Directive)
  Widget _buildLanguageSelectorBar() {
    final languageFlags = {
      'Malayalam': 'മലയാളം',
      'Tamil': 'தமிழ்',
      'Hindi': 'हिन्दी',
      'Telugu': 'తెలుగు',
      'Kannada': 'ಕನ್ನಡ',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Translation Language:',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _selectedLanguage,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kSupportedLanguages.map((lang) {
                final isSelected = _selectedLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _onLanguageSelected(lang),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        languageFlags[lang] ?? lang,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 3: 🧠 10 VOCABULARY WORDS TO MEMORIZE CARD ---
  Widget _buildVocabDeckCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906).withValues(alpha: 0.5),
          width: _vocabMemorized ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('STEP 3', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '10 Core Vocabulary Words to Memorize',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_vocabMemorized)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Memorize all 10 words below (definitions, native meanings & audio pronunciation):',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // 🌐 Multilingual Category Switcher Bar (Audio Directive)
          _buildLanguageSelectorBar(),

          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vocabList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final v = _vocabList[idx];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${idx + 1}', style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.word,
                                style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.phonetic,
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${v.partOfSpeech})',
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📖 ${v.definition}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🗣️ Meaning ($_selectedLanguage): ${v.getMeaning(_selectedLanguage)}',
                            style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '💡 "${v.exampleSentence}"',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 20),
                      onPressed: () => _speakWord('${v.word}. ${v.exampleSentence}'),
                      tooltip: 'Pronounce',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _vocabMemorized = true);
                _saveSubtask('vocab_mem', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 10 Vocabulary Words memorized and recorded!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(_vocabMemorized ? Icons.check_circle_rounded : Icons.star_rounded, color: Colors.black),
              label: Text(
                _vocabMemorized ? '10 WORDS MEMORIZED ✓' : 'I MEMORIZED ALL 10 WORDS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 4: 📖 CORE NOTES & AUTHENTIC STORY READING CARD ---
  Widget _buildReadingNotesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
          width: _readingNotesCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 4', style: TextStyle(color: _readingNotesCompleted ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('📖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Grammar Notes & Authentic Story Reading',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_readingNotesCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),

          // Grammar Concept Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _grammarRuleTitle,
                      style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getGrammarRuleExplanation(_selectedLanguage),
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 📖 Authentic Story Card (Audio Directive: Authentic story with TTS speaker reader!)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_storyIcon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _storyTitle,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            _storySubtitle,
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isStorySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        color: _isStorySpeaking ? Colors.redAccent : const Color(0xFFFFFC00),
                        size: 22,
                      ),
                      tooltip: _isStorySpeaking ? 'Stop Reading' : 'Read Aloud (TTS)',
                      onPressed: () => _speakStory(_storyText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _storyQuotePreview,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStorySummary(_selectedLanguage),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Full Story Reader, Read Books, Read Aloud Done
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showStoryDetailModal,
                  icon: const Icon(Icons.menu_book_rounded, color: Colors.black, size: 15),
                  label: Text(
                    'STORY READER',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PocketLibraryPage()),
                    ).then((_) {
                      if (mounted) {
                        setState(() => _readingNotesCompleted = true);
                        _saveSubtask('reading', true);
                      }
                    });
                  },
                  icon: const Icon(Icons.auto_stories_rounded, color: Colors.black, size: 15),
                  label: Text(
                    'READ BOOKS 📚',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _readingNotesCompleted = true);
                    _saveSubtask('reading', true);
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(
                    _readingNotesCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
                    color: const Color(0xFFFFFC00),
                    size: 15,
                  ),
                  label: Text(
                    _readingNotesCompleted ? 'DONE ✓' : 'FINISHED',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFFC00)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📖 Full Interactive Story Reader Modal (Audio Directive: Story details view with TTS)
  void _showStoryDetailModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, modalSetState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _storyTitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _storySubtitle,
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () {
                        _tts.stop();
                        if (mounted) setState(() => _isStorySpeaking = false);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Audio Narrator Controller Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_isStorySpeaking) {
                            _tts.stop();
                            modalSetState(() => _isStorySpeaking = false);
                            setState(() => _isStorySpeaking = false);
                          } else {
                            modalSetState(() => _isStorySpeaking = true);
                            setState(() => _isStorySpeaking = true);
                            _tts.setCompletionHandler(() {
                              if (mounted) {
                                modalSetState(() => _isStorySpeaking = false);
                                setState(() => _isStorySpeaking = false);
                              }
                            });
                            _tts.speak(_storyText);
                          }
                        },
                        icon: Icon(
                          _isStorySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          _isStorySpeaking ? 'STOP NARRATOR' : 'LISTEN TO NARRATOR (TTS)',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _selectedLanguage,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            _storyFormatted,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _getStorySummary(_selectedLanguage),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6EE7B7),
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tts.stop();
                      setState(() {
                        _readingNotesCompleted = true;
                        _isStorySpeaking = false;
                      });
                      _saveSubtask('reading', true);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Day ${widget.day} Story Reading completed!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
                    label: Text(
                      'I FINISHED READING THIS STORY ✓',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SUBTASK 5: ✍️ QUICK REVISION MINI-QUIZ CARD ---
  Widget _buildRevisionQuizCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
          width: _revisionQuizPassed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 5', style: TextStyle(color: _revisionQuizPassed ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('✍️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quick Revision Mini-Quiz',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_revisionQuizPassed)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _quizQuestion,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (i) {
            final options = _quizOptions;
            final isCorrect = i == 0;
            final isSelected = _selectedQuizAnswer == i;

            Color optionBg = const Color(0xFF1E293B);
            if (_quizSubmitted) {
              if (isCorrect) optionBg = const Color(0xFF10B981).withValues(alpha: 0.3);
              if (isSelected && !isCorrect) optionBg = Colors.red.withValues(alpha: 0.3);
            } else if (isSelected) {
              optionBg = const Color(0xFFFFFC00).withValues(alpha: 0.2);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: optionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                ),
              ),
              child: ListTile(
                title: Text(
                  options[i],
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                onTap: _quizSubmitted
                    ? null
                    : () {
                        setState(() => _selectedQuizAnswer = i);
                        HapticFeedback.lightImpact();
                      },
                trailing: isSelected ? const Icon(Icons.radio_button_checked, color: Color(0xFFFFFC00), size: 18) : null,
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedQuizAnswer == -1
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = true;
                        if (_selectedQuizAnswer == 0) {
                          _revisionQuizPassed = true;
                          _saveSubtask('quiz', true);
                        }
                      });
                      HapticFeedback.mediumImpact();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _revisionQuizPassed ? 'QUIZ PASSED ✓' : 'SUBMIT ANSWER',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🛡️ HOUSE DEFENSE SHIELD UNLOCK BANNER ---
  Widget _buildShieldUnlockBanner() {
    final allSubtasksDone = _completedSubtasksCount >= 7;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _defenseTrapArmed
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : (allSubtasksDone
                  ? [const Color(0xFF3B0764), const Color(0xFF1E1B4B)]
                  : [const Color(0xFF1E293B), const Color(0xFF0F172A)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _defenseTrapArmed
              ? const Color(0xFF10B981)
              : (allSubtasksDone ? const Color(0xFFFFD700) : Colors.white12),
          width: 1.5,
        ),
        boxShadow: [
          if (allSubtasksDone && !_defenseTrapArmed)
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.3),
              blurRadius: 14,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _defenseTrapArmed
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFFFFFC00).withValues(alpha: 0.15),
              border: Border.all(
                color: _defenseTrapArmed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFFC00),
                width: 1.2,
              ),
            ),
            child: Text(
              _defenseTrapArmed ? '🛡️' : '⚔️',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DAY ${widget.day} DEFENSE SHIELD',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: _defenseTrapArmed
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _defenseTrapArmed ? 'ACTIVE ✓' : 'SLOT READY',
                        style: TextStyle(
                          color: _defenseTrapArmed
                              ? const Color(0xFF10B981)
                              : Colors.amberAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _defenseTrapArmed
                      ? 'House protection active! Question ${widget.day} is guarding your gate against raiders.'
                      : 'Craft 1 tricky English question to arm your house shield against raiders in Pocket World!',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              PocketDefenseTrapModal.show(context, widget.day);
              setState(() => _defenseTrapArmed = true);
              _saveSubtask('defense', true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _defenseTrapArmed
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFFFC00),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _defenseTrapArmed ? 'EDIT 🛡️' : 'ADD SHIELD',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🏆 FINAL CLAIM & ADVANCE BUTTON ---
  Widget _buildFinalClaimButton() {
    final isTimerMet = _isTimerCompleted;
    final isSubtasksMet = _isAllCompleted;
    final canClaim = _canClaimAndAdvance;

    String headerTitle;
    String description;
    String buttonText;

    if (canClaim) {
      headerTitle = '🎉 MISSION COMPLETED!';
      description =
          '60-Minute practice target met & all 7 subtasks verified! Claim +${100 + (widget.day - 1) * 50} XP, +40 Fortress Defense Coins and unlock Day ${widget.day + 1}!';
      buttonText = 'CLAIM DAY ${widget.day} REWARDS & ADVANCE 🚀';
    } else if (isTimerMet && !isSubtasksMet) {
      headerTitle = '⚠️ ${7 - _completedSubtasksCount} SUBTASKS REMAINING';
      description =
          'Practice time target (60m) completed! You must complete all 7 subtasks below before unlocking Day ${widget.day + 1}.';
      buttonText = 'FINISH ${7 - _completedSubtasksCount} MORE SUBTASKS TO ADVANCE';
    } else if (!isTimerMet && isSubtasksMet) {
      headerTitle = '⏱️ PRACTICE TIME TARGET PENDING';
      description =
          'All 7 subtasks are verified! Practice for ${_timerService.formatTime(_timerService.remainingSeconds)} more minutes in app chats, drills, or calls to complete the 60-min target.';
      buttonText = 'PRACTICE ${_timerService.formatTime(_timerService.remainingSeconds)} MORE TO ADVANCE';
    } else {
      headerTitle = 'PRACTICE TARGET & SUBTASKS PENDING';
      description =
          'Progress: ${_timerService.formatTime()}/${_timerService.formatTime(_timerService.targetSeconds)} practice time • $_completedSubtasksCount/7 subtasks verified.';
      buttonText = '${7 - _completedSubtasksCount} SUBTASKS & ${_timerService.formatTime(_timerService.remainingSeconds)} REMAINING';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim
              ? const [Color(0xFF10B981), Color(0xFF047857)]
              : const [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (canClaim)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            headerTitle,
            style: GoogleFonts.outfit(
              color: canClaim ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim
                  ? () async {
                      HapticFeedback.heavyImpact();
                      if (!_defenseTrapArmed) {
                        PocketDefenseTrapModal.show(context, widget.day);
                        setState(() => _defenseTrapArmed = true);
                        _saveSubtask('defense', true);
                      }
                      final uid = SupaFlow.client.auth.currentUser?.id;
                      if (uid != null) {
                        await Learning60DayService().completeTask(
                          userId: uid,
                          taskId: 'day_${widget.day}_mission',
                        );
                        await PocketFortressDefenseService.recordActivityPoints(
                          'daily_mission',
                        );
                      }
                      widget.onMissionCompleted?.call();
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 Day ${widget.day} English Mission Complete! +${100 + (widget.day - 1) * 50} XP Points Earned • Day ${widget.day + 1} Unlocked!',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.outfit(
                  color: canClaim ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
