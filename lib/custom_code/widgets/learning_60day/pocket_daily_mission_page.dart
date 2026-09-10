import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/stage_peer_matchmaker.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
// Redirected battle raids directly to PocketWorldStreetPage
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_vocabulary_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_library_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_game_rules_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_reading_library_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_code_english_decoder_modal.dart';

export 'daily_vocab_item.dart';
import 'daily_vocab_item.dart';
import 'pocket_mission_curriculum_registry.dart';
import 'day90_master_certificate_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'games/word_catcher_models.dart';
import 'games/word_catcher_game_page.dart';
import 'career_adventure/adventure_models.dart';
import 'career_adventure/career_adventure_game_page.dart';
import 'career_adventure/city_navigator_models.dart';
import 'career_adventure/city_navigator_game_page.dart';

/// 🎯 Comprehensive Interactive Daily English Mission Experience
class PocketDailyMissionPage extends StatefulWidget {
  final int day;
  final VoidCallback? onMissionCompleted;

  static const List<String> kSupportedLanguages = [
    'Malayalam',
    'Tamil',
    'Hindi',
    'Telugu',
    'Kannada',
  ];

  static const Map<String, String> kLanguageLabels = {
    'Malayalam': 'മലയാളം',
    'Tamil': 'தமிழ்',
    'Hindi': 'हिन्दी',
    'Telugu': 'తెలుగు',
    'Kannada': 'ಕನ್ನಡ',
    'English': 'English',
  };

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
  bool _dailyRuleCompleted = false;
  bool _hubChatVerified = false;
  bool _peerCallVerified = false;
  bool _vocabMemorized = false;
  bool _readingNotesCompleted = false;
  bool _revisionQuizPassed = false;
  bool _defenseTrapArmed = false;
  bool _trialRaidLaunched = false;
  bool _midAttackCompleted = false;
  bool _alphabetPhonicsCompleted = false;
  bool _sentencePatternCompleted = false;
  bool _pronunciationCompleted = false;
  bool _englishThinkingCompleted = false;
  bool _speakingChallengeCompleted = false;
  bool _wordCatcherCompleted = false;
  bool _careerAdventureCompleted = false;
  bool _cityNavigatorCompleted = false;
  bool _isSpeakingChallengeRecording = false;
  int _speakingChallengeSecondsRemaining = 30;
  Timer? _speakingTimer;
  bool _codeEnglishCompleted = false;
  String? _codeCompilerOutput;
  bool _isCodeCompiling = false;
  int _selectedPatternIndex = 0;
  int _activeStoryPageIndex = 0;
  double _ttsSpeechRate = 0.48;
  bool _isPocketVocabSaved = false;

  // Quiz state
  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  // 🌐 Multilingual Category Preferences (Audio Requirement)
  static List<String> get kSupportedLanguages => PocketDailyMissionPage.kSupportedLanguages;
  static Map<String, String> get kLanguageLabels => PocketDailyMissionPage.kLanguageLabels;

  String _selectedLanguage = 'Malayalam';
  bool _isStorySpeaking = false;
  List<DailyVocabItem> _vocabList = [];

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

  static const String _kDay9StoryText =
      'At the Oxford International Colloquium, scholars gathered to debate the ethical regulation of synthetic bio-engineering. While populist commentators demanded immediate simplistic bans or unchecked commercialization, Professor Julian Vance took the podium with dispassionate poise. "What we fail to comprehend in binary arguments," Julian asserted, "is that true wisdom lives in the crucible of nuance and ambiguity." He demonstrated that sweeping generalizations collapse under rigorous scrutiny. Through measured cleft sentences and empirical evidence, he juxtaposed potential agricultural breakthroughs against ecological vulnerabilities. Rather than offering superficial dogmas, he challenged the assembly to formulate nuanced, adaptable policy frameworks. His cognitive depth and articulate balance galvanized the scholars to abandon ideological polarization. Julian demonstrated that genuine English mastery is not merely fluency in straightforward opinions, but the intellectual stamina to navigate intricate grey areas with clarity and grace.';

  static const String _kDay9StoryFormatted =
      '⚖️ Part 1: The Binary Dilemma\n'
      'At the Oxford International Colloquium, scholars debated synthetic bio-engineering ethics. Populist speakers clashed violently with simplistic, all-or-nothing ultimatums.\n\n'
      '🔬 Part 2: The Cleft Assertion\n'
      'Professor Julian Vance took the podium with dispassionate poise: "What we fail to comprehend in loud binary debates is that true wisdom resides in the crucible of nuance and ambiguity."\n\n'
      '🔍 Part 3: Juxtaposing Evidence\n'
      'Through measured cleft sentences and empirical rigor, Julian juxtaposed revolutionary benefits against ecological risks, dismantling superficial dogmas with surgical precision.\n\n'
      '🌟 Part 4: Beyond the Obvious\n'
      'The assembly abandoned ideological polarization to draft an adaptable policy accord. Julian proved that linguistic mastery is the ability to navigate profound complexity with intellectual poise.';

  static const String _kDay10StoryText =
      'Inside the grand domed chamber of the Peace Palace in The Hague, delegations from fifty sovereign nations sat locked in acrimonious deadlock over maritime territorial boundaries. If the negotiators had not summoned extraordinary statesmanship, war would have erupted across the eastern straits. Ambassador Helena Vance was summoned as chief arbitrator. She recognized that every faction possessed legitimate historical grievances and strategic anxieties. Over seventy-two grueling hours, Helena orchestrated bilateral diplomacy with majestic English eloquence. She framed every concession not as a defeat, but as a reciprocal cornerstone for continental stability. "If we had succumbed to narrow nationalistic pride," she declared before the plenary session, "our borders would not be secure today, and our children would inherit conflict." Her mixed conditional reasoning dismantled intransigence. One by one, every prime minister signed the Hague Maritime Accord. Helena established that the apex of English communication is executive statesmanship: the rare art of constructing unanimous consensus out of deep discord.';

  static const String _kDay10StoryFormatted =
      '🏛️ Part 1: The Chamber of Factions\n'
      'Inside the Peace Palace in The Hague, delegations from 50 sovereign nations sat locked in acrimonious deadlock over maritime boundaries, on the brink of conflict.\n\n'
      '👑 Part 2: The Chief Arbitrator\n'
      'Ambassador Helena Vance was summoned to mediate. She recognized that every faction carried legitimate historical grievances that demand dignity and recognition.\n\n'
      '🤝 Part 3: Mixed Conditional Diplomacy\n'
      '"If we had succumbed to nationalistic pride," Helena declared, "our borders would not be secure today, and our children would inherit war."\n\n'
      '🏆 Part 4: The Milestone Accord\n'
      'One by one, all 50 nations signed the historic accord without a single dissenting vote. Helena proved that the apex of English communication is executive consensus built upon empathy and truth.';

  static const String _kDay11StoryText =
      'In an ancient stone library overlooking the Aegean Sea, bilingual philosopher Cassian reflected upon his lifelong transformation through language. Decades earlier, he had viewed English merely as a functional tool of trade—a mechanical code of nouns and verbs. However, having immersed himself in profound world literature and philosophical debate, an inexorable epiphany transformed his mind: language does not merely describe the world; it constructs the very boundaries of our perception. Having mastered the subtleties of English rhetoric, Cassian discovered that he could think in deeper dimensions of logic, empathy, and strategic foresight. Addressing a gathering of aspiring international scholars, Cassian spoke with sublime virtuosity: "Linguistic fluency is not a static destination you arrive at and abandon. It is an eternal odyssey of cognitive reinvention. Every new concept you assimilate expands the horizon of who you can become." His words electrified the hall, reminding each listener that the mastery of speech is the liberation of the human soul.';

  static const String _kDay11StoryFormatted =
      '🌊 Part 1: The Mechanical Illusion\n'
      'In a quiet stone library overlooking the Aegean Sea, philosopher Cassian reflected on his linguistic journey. He once treated English as a mere mechanical tool of trade.\n\n'
      '⚡ Part 2: The Inexorable Epiphany\n'
      'Having immersed himself in profound philosophy, an inexorable epiphany struck him: language does not merely describe reality—it sculpts the very architecture of thought.\n\n'
      '🌌 Part 3: Linguistic Virtuosity\n'
      '"Linguistic fluency is not a static destination," Cassian told the scholars. "Driven by curiosity, you embark upon an eternal odyssey of cognitive reinvention."\n\n'
      '✨ Part 4: The Liberation of Mind\n'
      'Cassian\'s address electrified the assembly. He proved that learning English is not an obligation, but a transformative journey that expands the horizons of human potential.';

  static const String _kDay12StoryText =
      'Within the historic debate chamber of the Oxford Union, hundreds of seasoned intellectuals gathered for the annual world championship of forensic dialectic. Scholar Rowan stood before the dispatched dispatch box, facing an opponent known for employing specious fallacies and intimidating rhetorical volume. Rather than matching the aggression, Rowan dismantled the opponent\'s argument with surgical calm. "Were it not for foundational logic and empirical integrity," Rowan declared, "even the most eloquent rhetoric would dissolve into empty deception. Be that as it may, we must examine the unexamined assumptions beneath this motion." Through masterful subjunctive structures and concessive refutations, Rowan isolated the logical contradiction in the opponent\'s premise. Rowan demonstrated that conceding minor points gracefully disarms adversaries, while holding firm on core truth commands universal respect. When Rowan concluded, the entire assembly erupted in admiration. Rowan established that true mastery in debate is not bluster, but perspicacious clarity that exposes specious claims and elevates reasoned dialogue.';

  static const String _kDay12StoryFormatted =
      '🏛️ Part 1: The Oxford Arena\n'
      'Within the Oxford Union debate chamber, hundreds of intellectuals convened. Rowan faced a formidable adversary renowned for aggressive, specious arguments.\n\n'
      '⚖️ Part 2: The Subjunctive Opening\n'
      'Stepping to the dispatch box, Rowan spoke with surgical composure: "Were it not for empirical rigor, eloquent rhetoric would collapse into hollow deception. Be that as it may, let us dissect the underlying premises."\n\n'
      '🔍 Part 3: Dismantling the Fallacy\n'
      'Through precise concessive reasoning, Rowan exposed the contradictions in the motion. Conceding trivial points disarmed the opposition while fortifying the core truth.\n\n'
      '🌟 Part 4: Triumph of Perspicacity\n'
      'The hall erupted in an overwhelming standing ovation. Rowan proved that dialectic mastery is not loud intimidation, but the luminous perspicacity that elevates truth over sophistry.';

  static const String _kDay13StoryText =
      'At the Cambridge Institute for Epistemic Inquiry, senior researcher Dr. Elena Rostova spent months investigating an anomalous paradox in quantum neural networks. Conventional academic wisdom dismissed the anomaly as mere experimental noise, urging her team to abandon the project. Unwavering in her scientific empiricism, Dr. Elena persisted. Addressing the international fellowship of scientists, she opened with commanding rhetorical inversion: "Not only did our control measurements fail to eliminate the anomaly, but never in modern computational history have we witnessed such reproducible defiance of classical theory. Under no circumstances should an investigator discard contradictory data simply because it disrupts a comfortable paradigm." By structuring her scientific argument with negative inversion, she infused her rigorous mathematical proofs with profound drama and gravitas. Her peer researchers scrutinized her findings and were compelled to corroborate her hypothesis. Elena proved that when profound intellectual rigor meets masterful English expression, an investigator can shift the paradigms of an entire generation.';

  static const String _kDay13StoryFormatted =
      '🔬 Part 1: The Quantum Paradox\n'
      'At the Cambridge Institute for Epistemic Inquiry, Dr. Elena Rostova unraveled an anomalous paradox dismissed by conventional scholars as experimental noise.\n\n'
      '⚡ Part 2: The Negative Inversion\n'
      'Addressing the world fellowship of scientists, she commanded the room: "Not only did our control trials confirm the anomaly, but never in modern history have we witnessed such reproducible defiance of classical models."\n\n'
      '📊 Part 3: The Gravitas of Evidence\n'
      'Using negative inversion for dramatic weight, Elena declared: "Under no circumstances shall an investigator discard data merely because it shatters a comfortable paradigm."\n\n'
      '🌌 Part 4: The Paradigm Shift\n'
      'The symposium unanimously corroborated her findings. Elena demonstrated that when profound scientific truth is articulated with oratorical gravitas, history bends to evidence.';

  static const String _kDay14StoryText =
      'At the Grand Multilateral Summit in Geneva, delegates from opposing geopolitical blocs confronted a critical deadline to prevent an international trade embargo. Seventy-two consecutive hours of tense negotiations had brought the delegates to the brink of utter exhaustion. As cynicism began to settle across the council, Ambassador Kaelen and Chief Counsel Lyra took the floor. They employed rhetorical fronting and exquisite syntactic cohesion to galvanize the plenary hall. "Exhausted though we all are," Kaelen began, "reach a durable accord we must. Far and wide, millions of families await the outcome of this room. At stake stands not our pride, but our collective prosperity." Lyra then introduced a balanced multilateral compromise, using fronted prepositional phrases to place the human stakes center stage. Recalcitrant delegates set aside their stubborn posturing. By midnight, the landmark Geneva Treaty of Mutual Sovereignty was signed by all ninety nations. Kaelen and Lyra proved that oratorical rhetoric, when tempered by genuine empathy and grammatical elegance, has the power to bridge the deepest chasms of human discord.';

  static const String _kDay14StoryFormatted =
      '🌐 Part 1: The Geneva Deadline\n'
      'At the Grand Multilateral Summit in Geneva, delegates faced an imminent midnight deadline on an international trade embargo after seventy-two hours of gridlock.\n\n'
      '⚡ Part 2: Rhetorical Fronting\n'
      'Ambassador Kaelen took the podium with electrifying presence: "Exhausted though we all are, reach a durable accord we must. Front and center stand not our egos, but our collective future."\n\n'
      '📜 Part 3: The Forensic Accord\n'
      'Chief Counsel Lyra presented the multilateral blueprint, placing common human prosperity ahead of narrow tactical gains through syntactic mastery.\n\n'
      '🏆 Part 4: The Milestone Treaty\n'
      'All ninety sovereign delegations signed the historic treaty before the midnight bell. Kaelen and Lyra proved that forensic rhetoric, fueled by empathy, can bridge any divide.';

  static const String _kDay15StoryText =
      'In the historic diplomatic halls of Vienna, young diplomat Maya recognized that true resonance demanded conversational register. At first, her proposals were delivered in stiff, scholastic decrees that alienated her counterparts. An elder ambassador observed her frustration and shared an invaluable insight: "True authority in English is not wielded through rigid ultimatums, Maya. It flourishes through diplomatic softeners, polite register, and subtle nuance." Taking this counsel to heart, Maya transformed her communication. Instead of commanding, she opened conversations with grace: "I was wondering if we might explore an interim custodial partnership," and "Would you happen to know if the energy council has finalized the draft parameters?" The atmosphere transformed instantly. Her conversational warmth and linguistic tact melted defensive barriers. The assembly reached a breakthrough consensus before dusk. Maya discovered that conversational register and diplomatic softeners build unbreakable bridges of international trust.';

  static const String _kDay15StoryFormatted =
      '🏛️ Part 1: The Formal Dilemma\n'
      'In the historic diplomatic halls of Vienna, young diplomat Maya faced stubborn resistance. Her rigid, scholastic speeches alienated foreign delegates and brought negotiations to a standstill.\n\n'
      '🕊️ Part 2: The Ambassador\'s Counsel\n'
      'An elder statesman shared an enduring secret: "True authority in English is not wielded through cold ultimatums. It flourishes through diplomatic softeners, conversational register, and subtle nuance."\n\n'
      '🤝 Part 3: The Conversational Pivot\n'
      'Maya softened her phrasing with consummate grace: "I was wondering if we might explore an interim partnership," and "Would you happen to know if the committee has finalized the draft parameters?"\n\n'
      '🌟 Part 4: The Harmonious Accord\n'
      'The assembly responded with warmth and trust, forging a unanimous consensus before dusk. Maya proved that conversational register and diplomatic tact turn cold impasses into enduring cooperation.';

  static const String _kDay16StoryText =
      'Before the Parliamentary Select Committee, Chief Architect Daniel faced an intense public inquiry regarding the national energy grid failure. Hostile questions echoed through the vaulted hearing room as committee members sought someone to blame. Rather than becoming defensive, Daniel deployed the surgical focus of cleft sentences. "It was not a deficit of capital that caused the blackout," Daniel declared with quiet authority; "it was our reluctance to modernize legacy transmission lines. What we must construct today is a resilient, decentralized grid that withstands severe meteorological shocks." His cleft structures cut through speculative rhetoric like a laser, fixing the committee\'s undivided attention on the systemic cause and its actionable remedy. Convinced by his lucid diagnostic precision, parliament unanimously approved a multi-billion-dollar modernization bill. Daniel demonstrated that cleft sentences wield unparalleled oratorical force when clarifying complex crises.';

  static const String _kDay16StoryFormatted =
      '⚡ Part 1: The Committee Crucible\n'
      'Before the Parliamentary Select Committee, Chief Architect Daniel faced a hostile inquiry regarding the national grid failure. Accusations flared as critics sought a scapegoat.\n\n'
      '🎯 Part 2: Surgical Cleft Focus\n'
      'Daniel deployed cleft precision to cut through noise: "It was not a deficit of capital that caused the blackout; it was our reluctance to modernize legacy transmission lines."\n\n'
      '💡 Part 3: What We Must Build\n'
      '"What we must construct today is a resilient, decentralized grid that withstands severe meteorological shocks." His laser focus disarmed speculative arguments.\n\n'
      '🏛️ Part 4: The Unanimous Mandate\n'
      'Parliament unanimously approved the full modernization bill. Daniel proved that cleft sentences command total attention and crystallize urgent truth under pressure.';

  static const String _kDay17StoryText =
      'In the High Court of Constitutional Appeals, Senior Advocate Samantha stepped forward to deliver closing arguments in a landmark civil liberties trial. Across the courtroom sat a formidable team of opposing counsel backed by vast institutional resources. Samantha recognized that only pristine rhetorical symmetry could elevate her legal arguments into timeless precedent. Harnessing syntactic parallelism, her cadence echoed across the marble bench: "The respondent has sought not clarity, but obfuscation; has offered not evidence, but speculation; and has delivered not remedy, but delay. To protect our constitutional charter, this court must speak with courage, decide with impartiality, and act with decisive rectitude." The rhythmic balance of her words left the bench captivated and the courtroom breathless. The presiding Chief Justice delivered a landmark unanimous verdict that very afternoon. Samantha proved that syntactic parallelism transforms spoken arguments into unforgettable monuments of justice.';

  static const String _kDay17StoryFormatted =
      '⚖️ Part 1: The Constitutional Arena\n'
      'In the High Court of Constitutional Appeals, Senior Advocate Samantha stepped forward in a landmark civil liberties trial, facing a formidable wall of institutional opposition.\n\n'
      '🏛️ Part 2: Flawless Parallel Cadence\n'
      'Samantha marshaled relentless syntactic triads: "The respondent has sought not clarity, but obfuscation; has offered not evidence, but speculation; and has delivered not remedy, but delay."\n\n'
      '⚡ Part 3: The Call to Rectitude\n'
      '"To protect our charter, this court must speak with courage, decide with impartiality, and act with decisive rectitude." Her symmetrical balance commanded profound reverence.\n\n'
      '🏆 Part 4: The Landmark Verdict\n'
      'The bench delivered a unanimous ruling in her favor. Samantha proved that syntactic parallelism endows legal and moral arguments with enduring oratorical immortality.';

  static const String _kDay18StoryText =
      'At the World Sovereign Economic Summit in Singapore, Chief Strategist Ronen took the podium before heads of state from forty nations. The global economy stood at a perilous crossroads between short-term isolationism and visionary multilateral investment. Synthesizing decades of historical data, Ronen delivered a masterclass in mixed conditional reasoning: "If our founding ministers had not invested courageously in renewable infrastructure thirty years ago, our economies would not enjoy sovereign energy independence today. If we had succumbed to protectionist fears in the previous decade, we would not stand here as collaborative equals now. What we decide today will determine our reality fifty years hence." His seamless bridge between past decisions and present reality galvanized the assembly. The leaders ratified the Sovereign Century Accord with resounding applause. Ronen proved that mixed conditionals are the ultimate linguistic instrument for strategic synthesis and visionary leadership.';

  static const String _kDay18StoryFormatted =
      '👑 Part 1: The Global Crossroads\n'
      'At the World Sovereign Economic Summit in Singapore, Chief Strategist Ronen addressed forty heads of state amidst volatile macroeconomic turbulence.\n\n'
      '🌉 Part 2: The Historical Bridge\n'
      'Ronen wielded mixed conditionals with sovereign mastery: "If our founding ministers had not invested courageously thirty years ago, our economies would not enjoy energy independence today."\n\n'
      '🌱 Part 3: Legacy and Vision\n'
      '"If we had succumbed to protectionist fears in the previous decade, we would not stand here as collaborative equals now. Past resolve fuels our present reality."\n\n'
      '📜 Part 4: The Sovereign Century Accord\n'
      'The leaders ratified the historic accord with standing ovations. Ronen proved that mixed conditionals crystallize strategic leadership and elevate rhetoric into timeless statecraft.';

  String get _storyText {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStoryText(widget.day);
    }
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
      case 9:
        return _kDay9StoryText;
      case 10:
        return _kDay10StoryText;
      case 11:
        return _kDay11StoryText;
      case 12:
        return _kDay12StoryText;
      case 13:
        return _kDay13StoryText;
      case 14:
        return _kDay14StoryText;
      case 15:
        return _kDay15StoryText;
      case 16:
        return _kDay16StoryText;
      case 17:
        return _kDay17StoryText;
      case 18:
        return _kDay18StoryText;
      default:
        return _kDay1StoryText;
    }
  }

  String get _storyFormatted {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStoryFormatted(widget.day);
    }
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
      case 9:
        return _kDay9StoryFormatted;
      case 10:
        return _kDay10StoryFormatted;
      case 11:
        return _kDay11StoryFormatted;
      case 12:
        return _kDay12StoryFormatted;
      case 13:
        return _kDay13StoryFormatted;
      case 14:
        return _kDay14StoryFormatted;
      case 15:
        return _kDay15StoryFormatted;
      case 16:
        return _kDay16StoryFormatted;
      case 17:
        return _kDay17StoryFormatted;
      case 18:
        return _kDay18StoryFormatted;
      default:
        return _kDay1StoryFormatted;
    }
  }

  String get _storyTitle {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStoryTitle(widget.day);
    }
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
      case 9:
        return 'DAY 9 STORY: THE CRUCIBLE OF AMBIGUITY';
      case 10:
        return 'DAY 10 MILESTONE: THE ARCHITECTURE OF CONSENSUS';
      case 11:
        return 'DAY 11 STORY: THE ODYSSEY OF REINVENTION';
      case 12:
        return 'DAY 12 STORY: THE DIALECTIC OF CONTRADICTION';
      case 13:
        return 'DAY 13 STORY: THE ALCHEMY OF INTELLECT';
      case 14:
        return 'DAY 14 MILESTONE: THE CITADEL OF RHETORIC';
      case 15:
        return 'DAY 15 MILESTONE: THE CRUCIBLE OF NUANCE';
      case 16:
        return 'DAY 16 STORY: THE CITADEL OF CLEFT SENTENCES';
      case 17:
        return 'DAY 17 STORY: THE BASTION OF PARALLELISM';
      case 18:
        return 'DAY 18 MILESTONE: THE GRAND EMPYREAN';
      default:
        return 'DAY 1 STORY: THE SEED OF CONFIDENCE';
    }
  }

  String get _storySubtitle {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStorySubtitle(widget.day);
    }
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
      case 9:
        return 'Navigating Complexity & Nuanced Intellectual Discourse';
      case 10:
        return 'Executive Statesmanship & Unifying Divergent Factions';
      case 11:
        return 'Linguistic Virtuosity & Cognitive Evolution';
      case 12:
        return 'Subjunctive Precision & Dissecting Sophistry in High Debate';
      case 13:
        return 'Negative Inversion & Epistemic Rigor in Advanced Inquiries';
      case 14:
        return 'Forensic Persuasion, Rhetorical Fronting & Multilateral Accords';
      case 15:
        return 'Conversational Register & Diplomatic Softeners';
      case 16:
        return 'Cleft Sentences & Dynamic Oratorical Focus';
      case 17:
        return 'Syntactic Parallelism & Forensic Rhetorical Balance';
      case 18:
        return 'Mixed Conditionals & Sovereign Dialectic Synthesis';
      default:
        return 'Aloud Reading & Pronunciation Practice';
    }
  }

  String get _storyIcon {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStoryIcon(widget.day);
    }
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
      case 9:
        return '🧭';
      case 10:
        return '👑';
      case 11:
        return '🌌';
      case 12:
        return '⚖️';
      case 13:
        return '🔬';
      case 14:
        return '🏛️';
      case 15:
        return '💎';
      case 16:
        return '⚡';
      case 17:
        return '⚖️';
      case 18:
        return '👑';
      default:
        return '🎋';
    }
  }

  String get _storyQuotePreview {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      return PocketMissionCurriculumRegistry.getStoryQuotePreview(widget.day);
    }
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
      case 9:
        return '"At the Oxford Colloquium, scholars debated bio-engineering ethics. Prof. Julian Vance took the podium with dispassionate poise: \'What we fail to comprehend in binary arguments is that true wisdom lives in the crucible of nuance and ambiguity...\'"';
      case 10:
        return '"Inside the Peace Palace in The Hague, 50 nations sat in acrimonious deadlock. Ambassador Helena Vance declared: \'If we had succumbed to narrow pride, our borders would not be secure today, and our children would inherit conflict...\'"';
      case 11:
        return '"In an ancient stone library, bilingual philosopher Cassian addressed young scholars: \'Linguistic fluency is not a static destination you arrive at and abandon. It is an eternal odyssey of cognitive reinvention...\'"';
      case 12:
        return '"Within the historic debate chamber of the Oxford Union, Rowan faced an opponent known for specious fallacies: \'Were it not for empirical integrity, even the most eloquent rhetoric would dissolve into empty deception. Be that as it may...\'"';
      case 13:
        return '"At the Cambridge Institute for Epistemic Inquiry, Dr. Elena Rostova commanded the world symposium: \'Not only did our controls confirm the anomaly, but never in modern history have we witnessed such reproducible defiance of classical theory...\'"';
      case 14:
        return '"At the Grand Multilateral Summit in Geneva, Ambassador Kaelen galvanized the exhausted council: \'Exhausted though we all are, reach a durable accord we must. Front and center stand not our egos, but our collective future...\'"';
      case 15:
        return '"In the historic diplomatic halls of Vienna, young diplomat Maya recognized that true resonance demanded conversational register: \'Would you happen to know if the draft is finalized? I was wondering if we might explore an interim custodial partnership...\'"';
      case 16:
        return '"Before the Parliamentary Select Committee, Chief Architect Daniel crystallized the issue with cleft precision: \'It was not a deficit of capital that caused the blackout; it was our reluctance to modernize. What we must construct today is a resilient grid...\'"';
      case 17:
        return '"In the High Court of Constitutional Appeals, Senior Advocate Samantha unleashed relentless syntactic triads: \'The respondent has sought not clarity, but obfuscation; has offered not evidence, but speculation; and has delivered not remedy, but delay...\'"';
      case 18:
        return '"At the World Sovereign Economic Summit in Singapore, Chief Strategist Ronen united divergent leaders: \'If our founding ministers had not invested courageously thirty years ago, our economies would not enjoy sovereign independence today...\'"';
      default:
        return '"A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others. A wise mentor approached him: \'For four years, the bamboo roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky!\'"';
    }
  }

  String get _grammarRuleTitle {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regTitle = PocketMissionCurriculumRegistry.getGrammarRuleTitle(widget.day);
      if (regTitle.isNotEmpty) return regTitle;
    }
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
      case 9:
        return 'Rule 9: Advanced Cleft Sentences (What we need is...)';
      case 10:
        return 'Rule 10: Mixed Conditionals (Past Choice -> Present Reality)';
      case 11:
        return 'Rule 11: Participial Clauses for Sophisticated Flow';
      case 12:
        return 'Rule 12: Formal Subjunctive & Concessive Inversion';
      case 13:
        return 'Rule 13: Negative & Restrictive Inversion for Gravitas';
      case 14:
        return 'Rule 14: Rhetorical Fronting, Ellipsis & Cohesion';
      case 15:
        return 'Rule 15: Conversational Register & Diplomatic Softeners';
      case 16:
        return 'Rule 16: It-Clefts & Wh-Clefts for Dynamic Focus';
      case 17:
        return 'Rule 17: Syntactic Parallelism & Symmetrical Balance';
      case 18:
        return 'Rule 18: Mixed Conditionals (Past Unreal -> Present Reality)';
      default:
        return 'Rule 1: Sentence Structure (S + V + O)';
    }
  }

  String get _quizQuestion {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regQ = PocketMissionCurriculumRegistry.getQuizQuestion(widget.day);
      if (regQ.isNotEmpty) return regQ;
    }
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
      case 9:
        return 'Q: Which sentence uses an advanced cleft sentence structure correctly to emphasize a key idea?';
      case 10:
        return 'Q: Which sentence correctly uses a Mixed Conditional (Past Action -> Present Result)?';
      case 11:
        return 'Q: Which sentence correctly uses a participial clause for sophisticated sentence flow?';
      case 12:
        return 'Q: Which sentence correctly uses the formal subjunctive and concessive structure in debate?';
      case 13:
        return 'Q: Which sentence correctly applies negative inversion to convey dramatic gravitas?';
      case 14:
        return 'Q: Which sentence uses rhetorical fronting correctly to elevate oratorical eloquence?';
      case 15:
        return 'Q: Which sentence uses diplomatic softeners and refined conversational register correctly?';
      case 16:
        return 'Q: Which sentence uses a cleft sentence correctly to emphasize the pivotal factor?';
      case 17:
        return 'Q: Which sentence demonstrates flawless syntactic parallelism in its structure?';
      case 18:
        return 'Q: Which sentence correctly implements a mixed conditional linking past action to present state?';
      default:
        return 'Q: Which sentence follows the correct English "Subject + Verb + Object" order?';
    }
  }

  List<String> get _quizOptions {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regOpts = PocketMissionCurriculumRegistry.getQuizOptions(widget.day);
      if (regOpts.isNotEmpty) return regOpts;
    }
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
      case 9:
        return [
          'What we require is articulate and dispassionate discourse.',
          'What that we require is articulate and dispassionate discourse.',
          'It is articulate discourse what we require.',
        ];
      case 10:
        return [
          'If we had invested in daily practice, we would be fluent today.',
          'If we invested in daily practice, we would have been fluent today.',
          'If we would have invested in daily practice, we are fluent today.',
        ];
      case 11:
        return [
          'Having analyzed the data, the ambassador presented a balanced proposal.',
          'After having analyze the data, the ambassador presented a balanced proposal.',
          'Having analyzing the data, the ambassador presented a balanced proposal.',
        ];
      case 12:
        return [
          'Were it not for our rigorous treaties, cross-border stability would collapse.',
          'Was it not for our rigorous treaties, cross-border stability would collapse.',
          'If it were not for that our treaties, cross-border stability collapsed.',
        ];
      case 13:
        return [
          'Seldom have empirical researchers witnessed such an astonishing scientific breakthrough.',
          'Seldom empirical researchers have witnessed such an astonishing scientific breakthrough.',
          'Seldom did empirical researchers witnessed such an astonishing scientific breakthrough.',
        ];
      case 14:
        return [
          'Exhausted though the envoys were, reach a historic consensus they did.',
          'Exhausted though were the envoys, reach a historic consensus they did.',
          'Though exhausted were the envoys, reached a historic consensus they did.',
        ];
      case 15:
        return [
          'I was wondering if you might happen to have the updated draft agreement available.',
          'Give me the updated draft agreement right now because I need it.',
          'You must give the updated draft agreement without asking questions.',
        ];
      case 16:
        return [
          'It was the architect\'s prompt vigilance that prevented catastrophic system failure.',
          'The architect vigilance that was preventing catastrophic system failure.',
          'Was the architect vigilance that prevented catastrophe prompt.',
        ];
      case 17:
        return [
          'She inspired her team through clear vision, empathetic listening, and courageous action.',
          'She inspired her team through clear vision, to listen empathetically, and acting courageously.',
          'She inspired her team through vision clear, empathetic listening, and to act courageous.',
        ];
      case 18:
        return [
          'If our founders had not fortified the citadel walls, we would not enjoy peace today.',
          'If our founders had not fortified the citadel walls, we will not enjoy peace today.',
          'If our founders did not fortified walls, we would not had enjoyed peace today.',
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
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regExp = PocketMissionCurriculumRegistry.getGrammarRuleExplanation(widget.day, lang);
      if (regExp.isNotEmpty) return regExp;
    }
    if (widget.day == 18) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'கடந்த கால நிகழ்வு நிகழ்காலத்தில் ஏற்படுத்திய தாக்கத்தை விவரிக்க Mixed Conditionals பயன்படுத்தவும்: If + had + V3, would + Base Verb (today/now).\n• சரியான வாக்கியம்: "If our founders had not fortified the citadel walls, we would not enjoy peace today."\n• வரலாற்றுத் தேர்வுகள் எவ்வாறு நிகழ்காலத்தை மாற்றுகின்றன என்பதை விளக்க இது உதவுகிறது.';
        case 'hindi':
          return 'अतीत के काल्पनिक कार्य और वर्तमान में उसके प्रत्यक्ष प्रभाव को जोड़ने के लिए Mixed Conditionals का प्रयोग करें: If + Past Perfect (had + V3), Would + Base Verb (today/now)।\n• सही वाक्य: "If our founders had not fortified the citadel walls, we would not enjoy peace today."\n• रणनीतिक विश्लेषण और ऐतिहासिक परिणामों की समीक्षा में यह संरचना अत्यंत प्रभावी है।';
        case 'telugu':
          return 'గతంలోని ఒక నిర్ణయం ప్రస్తుత వాస్తవాన్ని ఎలా మార్చిందో వివరించేందుకు Mixed Conditionals (If + had + V3, would + Base Verb) వాడతారు.\n• సరైనది: "If our founders had not fortified the citadel walls, we would not enjoy peace today."\n• వ్యూహాత్మక విశ్లేషణలకు మరియు చారిత్రక సంభాషణలకు ఇది కీలకం.';
        case 'kannada':
          return 'ಹಿಂದಿನ ನಿರ್ಧಾರವು ಪ್ರಸ್ತುತ ವಾಸ್ತವವನ್ನು ಹೇಗೆ ರೂಪಿಸಿದೆ ಎಂದು ವಿವರಿಸಲು Mixed Conditionals (If + had + V3, would + Base Verb) ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "If our founders had not fortified the citadel walls, we would not enjoy peace today."\n• ಐತಿಹಾಸಿಕ ವಿಶ್ಲೇಷಣೆ ಮತ್ತು ಕಾರ್ಯತಂತ್ರದ ಚರ್ಚೆಗಳಿಗೆ ಇದು ಅತ್ಯಗತ್ಯ.';
        case 'malayalam':
        default:
          return 'Mixed Conditionals connect an unrealized past condition directly to an ongoing present reality: If + Past Perfect (had + V3), would + Base Verb (now/today):\n• Standard: "If they had fortified the walls, they would have survived back then."\n• Mixed (Past -> Present): "If our founders had not fortified the citadel walls, we would not enjoy peace today."\n• Indispensable for sovereign policy analysis, strategic retrospectives, and geopolitical synthesis.';
      }
    }

    if (widget.day == 17) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'ஒரே அமைப்பிலான வாக்கியத் தொடர்களை (Syntactic Parallelism) பயன்படுத்தி பேசுவது கருத்துக்களுக்கு அசாதாரண தாளத்தையும் கம்பீரத்தையும் தரும்.\n• சரியான வாக்கியம்: "She inspired her team through clear vision, empathetic listening, and courageous action."\n• நீதிமன்ற வாதங்களிலும் பிரம்மாண்ட மேடைகளிலும் இது கேட்போரை பெரிதும் ஈர்க்கும்.';
        case 'hindi':
          return 'समान व्याकरणिक संरचनाओं (Syntactic Parallelism) का प्रयोग भाषण में लय और अविस्मरणीय शक्ति लाता है: समान संज्ञाएं, क्रियाएं या विशेषण जोड़ें।\n• सही वाक्य: "She inspired her team through clear vision, empathetic listening, and courageous action."\n• न्यायालयीन बहसों और ऐतिहासिक जनसभाओं में यह श्रोताओं को मंत्रमुग्ध कर देता है।';
        case 'telugu':
          return 'ఒకే విధమైన వ్యాకరణ నిర్మాణాలను (Syntactic Parallelism) వాడటం ప్రసంగానికి లయబద్ధమైన బలాన్ని చేకూరుస్తుంది.\n• సరైనది: "She inspired her team through clear vision, empathetic listening, and courageous action."\n• న్యాయస్థాన వాదనల్లో మరియు చారిత్రక ప్రసంగాల్లో ఇది తిరుగులేని సాధనం.';
        case 'kannada':
          return 'ಒಂದೇ ರೀತಿಯ ವ್ಯಾಕರಣ ರಚನೆಗಳನ್ನು (Syntactic Parallelism) ಬಳಸುವುದರಿಂದ ಭಾಷಣಕ್ಕೆ ಅದ್ಭುತ ಲಯ ಮತ್ತು ಪ್ರಭಾವ ಸಿಗುತ್ತದೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "She inspired her team through clear vision, empathetic listening, and courageous action."\n• ನ್ಯಾಯಾಲಯದ ವಾದಗಳಲ್ಲಿ ಹಾಗೂ ಪ್ರಮುಖ ಸಾರ್ವಜನಿಕ ಭಾಷಣಗಳಲ್ಲಿ ಇದು ಸಮ್ಮೋಹಕ ಶಕ್ತಿ ನೀಡುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'Syntactic Parallelism balances coordinate words, phrases, or clauses with identical grammatical rhythm to produce forensic cadence and unforgettable authority:\n• Flawed/Unbalanced: "She inspired her team through clear vision, to listen empathetically, and acting courageously."\n• Flawless Parallelism: "She inspired her team through clear vision, empathetic listening, and courageous action."\n• The hallmark of constitutional jurisprudence and timeless statesman eloquence.';
      }
    }

    if (widget.day == 16) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'வாக்கியத்தில் ஒரு குறிப்பிட்ட உண்மையை அல்லது காரணத்தை மையப்படுத்தி அழுத்தமாகச் சொல்ல Cleft Sentences ("It was... that...", "What we must achieve is...") பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "It was the architect\'s prompt vigilance that prevented catastrophic system failure."\n• சாதாரண வாக்கியத்தை விட இது கேட்போரின் கவனத்தை முக்கிய புள்ளியில் நிலைநிறுத்தும்.';
        case 'hindi':
          return 'किसी निश्चित बिंदु या कारण पर श्रोताओं का विशेष ध्यान आकर्षित करने के लिए Cleft Sentences ("It was... that...", "What we must construct is...") का प्रयोग करें।\n• सही वाक्य: "It was the architect\'s prompt vigilance that prevented catastrophic system failure."\n• यह सामान्य वाक्य की तुलना में मुख्य विचार को असाधारण रूप से प्रभावशाली बना देता है।';
        case 'telugu':
          return 'ముఖ్యమైన అంశాన్ని లేదా కారణాన్ని ప్రత్యేకంగా నొక్కి చెప్పేందుకు Cleft Sentences ("It was... that...", "What we must achieve is...") వాడతారు.\n• సరైనది: "It was the architect\'s prompt vigilance that prevented catastrophic system failure."\n• ఇది వినేవారి దృష్టిని నేరుగా ప్రధాన కారణం వైపు మళ్లిస్తుంది.';
        case 'kannada':
          return 'ಒಂದು ನಿರ್ದಿಷ್ಟ ಕಾರಣ ಅಥವಾ ವಿಷಯಕ್ಕೆ ವಿಶೇಷ ಪ್ರಾಮುಖ್ಯತೆ ನೀಡಲು Cleft Sentences ("It was... that...") ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "It was the architect\'s prompt vigilance that prevented catastrophic system failure."\n• ಭಾಷಣದಲ್ಲಿ ಪ್ರಮುಖ ಅಂಶವನ್ನು ಎತ್ತಿಹಿಡಿಯಲು ಇದು ಅತ್ಯುತ್ತಮ ತಂತ್ರ.';
        case 'malayalam':
        default:
          return 'Cleft Sentences restructure statements using "It was [X] that [Y]" or "What [X] is [Y]" to place unwavering focus on the catalyst of an event:\n• Standard: "The architect\'s prompt vigilance prevented catastrophic system failure."\n• Cleft Focus: "It was the architect\'s prompt vigilance that prevented catastrophic system failure."\n• Indispensable for parliamentary inquiries, investigative reporting, and high-impact oratory.';
      }
    }

    if (widget.day == 15) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'மரியாதையுடனும் இணக்கமாகவும் பேச Diplomatic Softeners ("I was wondering if...", "Would you happen to know...", "Perhaps we might...") பயன்படுத்தவும்.\n• நேரடி கட்டளைகளைத் தவிர்த்து, மென்மையான வார்த்தைகள் மூலம் மற்றவர்களை எளிதில் இணங்க வைக்கலாம்.\n• சரியான வாக்கியம்: "I was wondering if you might happen to have the updated draft agreement available."\n• சர்வதேச தூதரகப் பேச்சுக்களில் இது மிகவும் முக்கியம்.';
        case 'hindi':
          return 'सभ्य, विनम्र और प्रभावी संवाद के लिए Diplomatic Softeners का प्रयोग करें ("I was wondering if...", "Would you happen to know...", "Perhaps we could...")।\n• सीधे आदेश देने के बजाय विनम्र अनुरोध दूसरों को तुरंत आकर्षित करता है।\n• सही वाक्य: "I was wondering if you might happen to have the updated draft agreement available."\n• उच्च-स्तरीय कूटनीतिक और कॉर्पोरेट वार्तालाप का यह मूल आधार है।';
        case 'telugu':
          return 'మర్యాదపూర్వకంగా, ఆకట్టుకునేలా మాట్లాడేందుకు Diplomatic Softeners ("I was wondering if...", "Would you happen to know...") వాడతారు.\n• ప్రత్యక్ష ఆదేశాలకు బదులుగా గౌరవప్రదమైన అభ్యర్థనలు ఇతరులను సులభంగా ఒప్పిస్తాయి.\n• సరైనది: "I was wondering if you might happen to have the updated draft agreement available."\n• దౌత్యపరమైన మరియు ఉన్నత స్థాయి చర్చల్లో ఇది అత్యంత ప్రభావవంతమైనది.';
        case 'kannada':
          return 'ಗೌರವಯುತ ಹಾಗೂ ಸೌಮ್ಯ ಸಂಭಾಷಣೆಗೆ Diplomatic Softeners ("I was wondering if...", "Would you happen to know...") ಬಳಸಿ.\n• ನೇರ ಆದೇಶಗಳ ಬದಲು ವಿನಮ್ರ ಶಬ್ದಗಳು ಇತರರನ್ನು ಸುಲಭವಾಗಿ ಒಪ್ಪಿಸುತ್ತವೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "I was wondering if you might happen to have the updated draft agreement available."\n• ಉನ್ನತ ಮಟ್ಟದ ರಾಜತಾಂತ್ರಿಕ ಸಂವಾದಗಳಿಗೆ ಇದು ಕೀಲಿ ಕೈ.';
        case 'malayalam':
        default:
          return 'Diplomatic Softeners and conversational nuance soften direct commands into polite, persuasive invitations ("I was wondering if...", "Would you happen to know...", "Might we perhaps explore..."): \n• Direct/Blunt: "Give me the agreement now."\n• Diplomatic Nuance: "I was wondering if you might happen to have the updated draft agreement available."\n• Essential for executive negotiations, diplomatic accords, and elite social grace.';
      }
    }

    if (widget.day == 14) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'பேச்சில் முக்கிய கருத்தை முன்னிலைப்படுத்த Rhetorical Fronting (Exhausted though they were..., Front and center stood...) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "Exhausted though the envoys were, reach a historic consensus they did."\n• சர்வதேச மாநாடுகளில் கவனத்தை ஈர்க்க இது பயன்படுகிறது.';
        case 'hindi':
          return 'भाषण में विशेष भाव या तथ्य को सबसे आगे लाने के लिए Rhetorical Fronting का प्रयोग करें: Adjective + though + Subject + Verb ("Exhausted though they were...")।\n• सही वाक्य: "Exhausted though the envoys were, reach a historic consensus they did."\n• यह सामान्य वाक्य की तुलना में कहीं अधिक प्रभावशाली और राजसी लगता है।';
        case 'telugu':
          return 'మాట్లాడేటప్పుడు ప్రధానాంశాన్ని ముందుంచి ఆకట్టుకునేందుకు Rhetorical Fronting (Exhausted though they were...) వాడతారు.\n• సరైనది: "Exhausted though the envoys were, reach a historic consensus they did."\n• ఇది ఉన్నత స్థాయి సదస్సుల్లో మరియు చర్చల్లో ప్రసంగానికి ప్రత్యేక ఆకర్షణ తెస్తుంది.';
        case 'kannada':
          return 'ಭಾಷಣದಲ್ಲಿ ಮುಖ್ಯ ವಿಷಯವನ್ನು ಮುಂಚೂಣಿಗೆ ತರಲು Rhetorical Fronting (Exhausted though they were...) ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "Exhausted though the envoys were, reach a historic consensus they did."\n• ಜಾಗತಿಕ ವೇದಿಕೆಗಳಲ್ಲಿ ಪ್ರಭಾವಿ ಭಾಷಣಕ್ಕೆ ಇದು ಅತ್ಯುತ್ತಮ ಕಲೆ.';
        case 'malayalam':
        default:
          return 'Rhetorical Fronting moves key descriptive adjectives or adverbs to the absolute beginning of the sentence to command dramatic focus and oratorical authority ("Exhausted though they were...", "Front and center stood..."): \n• Normal: "Although the envoys were exhausted, they reached a consensus."\n• Fronted Rhetoric: "Exhausted though the envoys were, reach a historic consensus they did."\n• The gold standard of diplomatic statesmanship.';
      }
    }

    if (widget.day == 13) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'ஆழ்ந்த அறிவியலிலும் வாதங்களிலும் அழுத்தமான தாக்கத்தை உருவாக்க Negative Inversion (Seldom / Never / Under no circumstances + Auxiliary Verb + Subject) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "Seldom have empirical researchers witnessed such a breakthrough."\n• சாதாரண வாக்கியத்தை விட இது அசைக்க முடியாத அதிகாரபூர்வமான தொனியைத் தரும்.';
        case 'hindi':
          return 'वैज्ञानिक व अकादमिक विमर्श में गाम्भीर्य दर्शाने के लिए Negative Inversion का प्रयोग करें: Seldom/Never/Under no circumstances + Auxiliary Verb + Subject.\n• सही वाक्य: "Seldom have empirical researchers witnessed such an astonishing breakthrough."\n• यह वाक्य को एक अचूक और प्रभावशाली बौद्धिक वजन देता है।';
        case 'telugu':
          return 'శాస్త్రీయ మరియు మేధోపరమైన చర్చల్లో గాంభీర్యాన్ని పెంచేందుకు Negative Inversion (Seldom/Never + సహాయక క్రియ + కర్త) వాడతారు.\n• సరైనది: "Seldom have empirical researchers witnessed such a breakthrough."\n• ఇది పరిశోధనాత్మక ప్రసంగాలకు తిరుగులేని బలాన్ని ఇస్తుంది.';
        case 'kannada':
          return 'ವೈಜ್ಞಾನಿಕ ಮತ್ತು ಬೌದ್ಧಿಕ ಚರ್ಚೆಗಳಲ್ಲಿ ಗಾಂಭೀರ್ಯವನ್ನು ಹೆಚ್ಚಿಸಲು Negative Inversion ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "Seldom have empirical researchers witnessed such a breakthrough."\n• ಇದು ನಿಮ್ಮ ಇಂಗ್ಲಿಷ್‌ಗೆ ಅಪ್ರತಿಮ ಗಾಂಭೀರ್ಯವನ್ನು ನೀಡುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'Negative & Restrictive Inversion opens a sentence with limiting adverbs (Seldom, Never, Under no circumstances, Hardly) immediately followed by an auxiliary verb and subject to convey unshakeable intellectual gravitas:\n• Normal: "Researchers have seldom witnessed such a breakthrough."\n• Inverted (Academic Gravitas): "Seldom have empirical researchers witnessed such an astonishing breakthrough."\n• Essential for high-level scientific and philosophical discourse.';
      }
    }

    if (widget.day == 12) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'உயர்மட்ட விவாதங்களில் மறுக்க முடியாத தர்க்கத்தை முன்வைக்க Subjunctive & Concessive Inversion ("Were it not for...", "Be that as it may...") பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "Were it not for our rigorous treaties, cross-border stability would collapse."\n• இது எதிராளியின் வீண் வாதங்களை உடைத்து உண்மையை நிலைநாட்ட உதவுகிறது.';
        case 'hindi':
          return 'उच्च-स्तरीय वाद-विवाद में अचूक तर्कशीलता के लिए Formal Subjunctive एवं Concessive Inversion ("Were it not for...", "Be that as it may...") का प्रयोग करें।\n• सही वाक्य: "Were it not for our rigorous treaties, cross-border stability would collapse."\n• यह बिना आक्रामकता के तर्क की स्पष्टता से विपक्ष को निरुत्तर करने की कला है।';
        case 'telugu':
          return 'ఉన్నత స్థాయి చర్చల్లో సహేతుకమైన తర్కాన్ని నిలబెట్టేందుకు Formal Subjunctive & Concessive Inversion ("Were it not for...", "Be that as it may...") వాడాలి.\n• సరైనది: "Were it not for our rigorous treaties, cross-border stability would collapse."\n• ఇది వాదనలో అపరిమితమైన హుందాతనాన్ని మరియు స్పష్టతను ఇస్తుంది.';
        case 'kannada':
          return 'ಉನ್ನತ ಮಟ್ಟದ ಸಂವಾದಗಳಲ್ಲಿ ದೋಷರಹಿತ ತರ್ಕವನ್ನು ಮಂಡಿಸಲು Formal Subjunctive & Concessive Inversion ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "Were it not for our rigorous treaties, cross-border stability would collapse."\n• ಇದು ಎದುರಾಳಿಯ ಪೊಳ್ಳು ವಾದಗಳನ್ನು ಪುಡಿಗಟ್ಟಿ ಸತ್ಯವನ್ನು ಎತ್ತಿಹಿಡಿಯುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'The Formal Subjunctive with Concessive Inversion inverts standard "If it were not for" into "Were it not for..." and employs idioms like "Be that as it may..." to acknowledge an opposing argument before surgically dismantling its core fallacy:\n• Normal: "If it were not for our treaties, stability would collapse."\n• Subjunctive Debate Standard: "Were it not for our rigorous treaties, cross-border stability would collapse."\n• In Malayalam: "ഞങ്ങളുടെ കർശനമായ ഉടമ്പടികൾ ഇല്ലായിരുന്നുവെങ്കിൽ സമാധാനം തകരുമായിരുന്നു." Commands commanding intellectual respect.';
      }
    }

    if (widget.day == 11) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'வாக்கியங்களை நேர்த்தியாக இணைக்க Participial Clauses (Having + V3, Verb-ing) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "Having analyzed the empirical data, she presented her thesis."\n• இது நீண்ட வாக்கியங்களை சுருக்கமாகவும் கம்பீரமாகவும் மாற்றுகிறது.';
        case 'hindi':
          return 'वाक्यों को संक्षिप्त, परिष्कृत और प्रवाहमयी बनाने के लिए Participial Clauses (Having + V3 या V-ing) का प्रयोग करें।\n• सही वाक्य: "Having analyzed the empirical data, she presented her thesis."\n• यह सामान्य "After she had analyzed..." की तुलना में कहीं अधिक उच्च-स्तरीय शैली है।';
        case 'telugu':
          return 'వాక్యాలను సంక్షిప్తంగా, అందంగా అనుసంధానించేందుకు Participial Clauses (Having + V3) వాడాలి.\n• సరైనది: "Having analyzed the empirical data, she presented her thesis."\n• ఇది ఇంగ్లీష్ సంభాషణకు మరియు రచనకు అసాధారణమైన ప్రవాహాన్ని ఇస్తుంది.';
        case 'kannada':
          return 'ವಾಕ್ಯಗಳನ್ನು ಸಂಕ್ಷಿಪ್ತವಾಗಿ ಹಾಗೂ ಸುಲಲಿತವಾಗಿ ಜೋಡಿಸಲು Participial Clauses (Having + V3) ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "Having analyzed the empirical data, she presented her thesis."\n• ಉನ್ನತ ಮಟ್ಟದ ಭಾಷಾ ಪ್ರೌಢಿಮೆಗೆ ಇದು ಅತ್ಯಗತ್ಯ.';
        case 'malayalam':
        default:
          return 'Participial clauses connect ideas with sophisticated economy without repeating subjects or clunky conjunctions ("Having + Past Participle", "Driven by..."): \n• Normal: "After she had analyzed the data, she spoke."\n• Sophisticated: "Having analyzed the data, she delivered a compelling address."\n• Essential for academic debate and executive eloquence.';
      }
    }

    if (widget.day == 10) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'கடந்த காலச் செயலும் தற்கால விளைவும் இணையும் Mixed Conditionals (If + Past Perfect, Would + Base Verb) பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "If we had invested in speaking, we would be confident today."\n• இறந்த காலத்தின் முடிவு இன்றைய நிலையை எவ்வாறு மாற்றியது என்பதைக் குறிக்க இது உதவுகிறது.';
        case 'hindi':
          return 'Mixed Conditionals का प्रयोग भूतकाल के निर्णय का वर्तमान परिणाम दर्शाने के लिए होता है: If + Past Perfect (had + V3), Would + Base Verb.\n• सही वाक्य: "If we had practiced speaking daily, we would be completely confident today."\n• यह भूतकाल और वर्तमान के बीच के तार्किक संबंध को जोड़ता है।';
        case 'telugu':
          return 'గతంలో తీసుకున్న నిర్ణయం వర్తమానంలో ఎలాంటి ఫలితం ఇచ్చిందో తెలిపేందుకు Mixed Conditionals (If + Past Perfect, Would + Verb) వాడాలి.\n• సరైనది: "If we had practiced speaking daily, we would be fluent today."\n• నాయకత్వ సంభాషణల్లో ఇది విశేష పాత్ర పోషిస్తుంది.';
        case 'kannada':
          return 'ಹಿಂದಿನ ನಿರ್ಧಾರವು ಪ್ರಸ್ತುತದಲ್ಲಿ ತಂದ ಫಲಿತಾಂಶವನ್ನು ವ್ಯಕ್ತಪಡಿಸಲು Mixed Conditionals ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "If we had practiced speaking daily, we would be fluent today."\n• ಭೂತಕಾಲ ಮತ್ತು ವರ್ತಮಾನದ ನಡುವಿನ ತಾರ್ಕಿಕ ಸಂಬಂಧವನ್ನು ಇದು ಬೆಸೆಯುತ್ತದೆ.';
        case 'malayalam':
        default:
          return 'Mixed Conditionals bridge an unreal past action with its ongoing present result: If + Past Perfect (had + V3), Would + Base Verb (today/now).\n• Correct: "If we had practiced speaking daily, we would be completely fluent today."\n• Demonstrates executive strategic reasoning in debate.';
      }
    }

    if (widget.day == 9) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'முக்கியமான கருத்துக்கு அழுத்தம் கொடுக்க Cleft Sentences ("What we require is...", "It was through... that...") பயன்படுத்தவும்.\n• சரியான வாக்கியம்: "What we require is dispassionate and articulate discourse."\n• சாதாரண வாக்கியத்தை விட இது கேட்போரின் கவனத்தை உடனடியாக ஈர்க்கும்.';
        case 'hindi':
          return 'किसी विशेष विचार पर श्रोताओं का ध्यान केंद्रित करने के लिए Cleft Sentences ("What we need is...", "It is through... that...") का प्रयोग करें।\n• सही वाक्य: "What we require is dispassionate and articulate discourse."\n• यह संवाद को स्पष्ट और निर्णायक प्रभाव देता है।';
        case 'telugu':
          return 'ముఖ్యమైన భావాన్ని బలంగా నొక్కి చెప్పేందుకు Cleft Sentences ("What we need is...") వాడతారు.\n• సరైనది: "What we require is dispassionate and articulate discourse."\n• ఇది శ్రోతల దృష్టిని నేరుగా ప్రధానాంశం వైపు తిప్పుతుంది.';
        case 'kannada':
          return 'ಮುಖ್ಯವಾದ ಅಂಶಕ್ಕೆ ಹೆಚ್ಚಿನ ಒತ್ತು ನೀಡಲು Cleft Sentences ("What we need is...") ಬಳಸಿ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "What we require is articulate discourse."\n• ಭಾಷಣದಲ್ಲಿ ಶ್ರೋತೃಗಳ ಗಮನ ಸೆಳೆಯಲು ಇದು ಅದ್ಭುತ ಸಾಧನ.';
        case 'malayalam':
        default:
          return 'Cleft sentences split a standard statement to place powerful emphasis on the core message: "What we require is dispassionate and articulate discourse." or "It was through daily persistence that she achieved mastery."\n• Sharpens focus and commands listener attention in intellectual debates.';
      }
    }

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
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regSum = PocketMissionCurriculumRegistry.getStorySummary(widget.day, lang);
      if (regSum.isNotEmpty) return regSum;
    }
    if (widget.day == 18) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "கடந்த காலத்தின் துணிச்சலான அர்ப்பணிப்பே நிகழ்காலத்தின் சுதந்திரத்தையும் அமைதியையும் நிலைநிறுத்துகிறது." வரலாற்று சாதனை படைத்திடுங்கள்!';
        case 'hindi':
          return '💡 सीख: "अतीत में लिए गए साहसी और दूरदर्शी निर्णय ही आज के युग में संप्रभु स्वतंत्रता और शांति का आधार बनते हैं।" शिखर पर बने रहें!';
        case 'telugu':
          return '💡 నీతి: "గతంలో తీసుకున్న సాహసోపేతమైన నిర్ణయాలు మాత్రమే నేడు మనకు స్వేచ్ఛను, శాంతియుత భవిష్యత్తును ప్రసాదిస్తాయి." శిఖరాన్ని అధిరోహించండి!';
        case 'kannada':
          return '💡 ನೀತಿ: "ಹಿಂದೆ ತೆಗೆದುಕೊಂಡ ಧೈರ್ಯದ ನಿರ್ಧಾರಗಳೇ ಇಂದು ನಮ್ಮ ಶಾಂತಿ ಮತ್ತು ಸ್ವಾತಂತ್ರ್ಯಕ್ಕೆ ಭದ್ರ ಬುನಾದಿ." ಐತಿಹಾಸಿಕ ಸಾಧನೆ ಮುಂದುವರಿಸಿ!';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഭൂതകാലത്തിൽ സ്വീകരിച്ച ധീരവും ദീർഘവീക്ഷണമുള്ളതുമായ നിലപാടുകളാണ് വർത്തമാനകാലത്തെ നമ്മുടെ സ്വാതന്ത്ര്യത്തെയും സമാധാനത്തെയും സംരക്ഷിക്കുന്നത്." അഭിമാനത്തോടെ വിജയത്തിലേക്ക് കുതിക്കുക!';
      }
    }

    if (widget.day == 17) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "நீதியும் சத்தியமும் சமச்சீரான, நேர்த்தியான மொழியில் ஒலிக்கும் போது எவராலும் அதை மறுக்க முடியாது." உறுதியுடன் நில்லுங்கள்!';
        case 'hindi':
          return '💡 सीख: "जब सत्य और न्याय संतुलित, ओजस्वी और सुसंगत भाषा में प्रस्तुत किए जाते हैं, तो कोई भी उनका खंडन नहीं कर सकता।" अडिग रहें!';
        case 'telugu':
          return '💡 నీతి: "సత్యం మరియు న్యాయం సమతుల్యమైన, అందమైన భాషలో ప్రతిధ్వనించినప్పుడు ఎవరూ దానిని కాదనలేరు." స్థిరంగా నిలబడండి!';
        case 'kannada':
          return '💡 ನೀತಿ: "ಸತ್ಯ ಮತ್ತು ನ್ಯಾಯವು ಸಮತೋಲಿತ ಭಾಷೆಯಲ್ಲಿ ಮಂಡಿಸಲ್ಪಟ್ಟಾಗ ಯಾರೂ ಅದನ್ನು ಅಲ್ಲಗಳೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ." ದೃಢವಾಗಿರಿ!';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "സത്യവും നീതിയും സമതുലിതമായ താളബോധമുള്ള ഭാഷയിൽ മാറ്റൊലിക്കപ്പെടുമ്പോൾ ഏത് കടുത്ത എതിർപ്പുകളെയും നിഷ്പ്രഭമാക്കാൻ സാധിക്കും." മുന്നേറുക!';
      }
    }

    if (widget.day == 16) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "பிரச்சனையின் மூலக் காரணத்தை துல்லியமான மொழியால் அடையாளம் காண்பதே தீர்வுக்கான முதல் படியாகும்." தெளிவுடன் பேசுங்கள்!';
        case 'hindi':
          return '💡 सीख: "समस्या की मूल जड़ को स्पष्ट और अचूक भाषा से उजागर करना ही स्थायी समाधान का पहला कदम है।" आत्मविश्वास बनाए रखें!';
        case 'telugu':
          return '💡 నీతి: "సమస్య యొక్క మూల కారణాన్ని స్పష్టమైన భాషతో ఎత్తిచూపడమే శాశ్వత పరిష్కారానికి తొలి అడుగు." ఆత్మవిశ్వాసంతో మాట్లాడండి!';
        case 'kannada':
          return '💡 ನೀತಿ: "ಸಮಸ್ಯೆಯ ಮೂಲ ಕಾರಣವನ್ನು ನಿಖರ ಭಾಷೆಯಿಂದ ಗುರುತಿಸುವುದೇ ಶಾಶ್ವತ ಪರಿಹಾರದ ಮೊದಲ ಹೆಜ್ಜೆ." ಸ್ಪಷ್ಟತೆಯಿಂದ ಮಾತನಾಡಿ!';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "പ്രശ്നങ്ങളുടെ യഥാർത്ഥ കാരണത്തെ കൃത്യതയാർന്ന ഭാഷകൊണ്ട് ലക്ഷ്യകേന്ദ്രത്തിൽ എത്തിക്കുകയാണ് ശാശ്വത പരിഹാരത്തിലേക്കുള്ള ആദ്യ പടി." ആത്മവിശ്വാസത്തോടെ സംസാരിക്കുക!';
      }
    }

    if (widget.day == 15) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "எந்த ஒரு கடுமையான எதிர்ப்பையும் தூதரக மென்மொழியும் நயமான பேச்சுமே சுமுகமான இணக்கத்திற்கு இட்டுச்செல்லும்." தொடர்ந்து பேசுங்கள்!';
        case 'hindi':
          return '💡 सीख: "सख्त से सख्त गतिरोध को भी कूटनीतिक विनम्रता और शब्दों की नजाकत से सुलझाया जा सकता है।" निरंतर आगे बढ़ें!';
        case 'telugu':
          return '💡 నీతి: "ఎంతటి కఠినమైన పరిస్థితినైనా దౌత్యపరమైన మృదుభాష మరియు సమయస్ఫూర్తితో శాంతియుతంగా పరిష్కరించవచ్చు." ముందుకు సాగండి!';
        case 'kannada':
          return '💡 ನೀತಿ: "ಎಂತಹದೇ ಕಠಿಣ ಸನ್ನಿವೇಶವನ್ನೂ ಸೌಮ್ಯ ಮಾತುಗಾರಿಕೆ ಮತ್ತು ರಾಜತಾಂತ್ರಿಕ ಜಾಣ್ಮೆಯಿಂದ ಗೆಲ್ಲಬಹುದು." ಮುನ್ನಡೆಯಿರಿ!';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഏറ്റവും കടുത്ത വിയോജിപ്പുകളെപ്പോലും നയതന്ത്രജ്ഞതയോടുകൂടിയ മൃദുവായ സംഭാഷണ ശൈലികൊണ്ട് രമ്യമായി പരിഹരിക്കാൻ സാധിക്കും." മുന്നേറുക!';
      }
    }

    if (widget.day == 14) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "உண்மையான சொல்வன்மை மனிதர்களின் சுயமரியாதையை உயர்த்தும் போதே முட்டுக்கட்டையை உடைத்து வரலாற்று வெற்றியை உருவாக்கும்." தொடர்ந்து முன்னேறுங்கள்.';
        case 'hindi':
          return '💡 सीख: "सच्ची वाक्पटुता और सहानुभूति ही सबसे बड़े गतिरोध को तोड़कर सर्वसम्मत ऐतिहासिक संधि का मार्ग प्रशस्त करती है।" शिखर पर पहुंचें।';
        case 'telugu':
          return '💡 నీతి: "నిజమైన వాక్చాతుర్యం మరియు సానుభూతి మాత్రమే ఎంతటి ప్రతిష్టంభననైనా ఛేదించి చారిత్రక శాంతి ఒప్పందాన్ని సాధించగలవు." ముందుకు సాగండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ನಿಜವಾದ ವಾಕ್ಚಾತುರ್ಯ ಮತ್ತು ಸಹಾನುಭೂತಿಯು ಎಂತಹದೇ ಬಿಕ್ಕಟ್ಟನ್ನು ನಿವಾರಿಸಿ ಐತಿಹಾಸಿಕ ಒಪ್ಪಂದವನ್ನು ತರಬಲ್ಲದು." ಮುನ್ನಡೆಯಿರಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "സത്യസന്ധമായ അനുഭാവവും വാഗ്മിത്വവും സമന്വയിക്കുമ്പോൾ ഏറ്റവും കടുത്ത സ്തംഭനാവസ്ഥകളും ചരിത്രപരമായ വിജയ സമാധാന ഉടമ്പടികളായി രൂപാന്തരപ്പെടും." മുന്നേറുക!';
      }
    }

    if (widget.day == 13) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "ஆழ்ந்த அறிவியலும் உண்மையும் அசைக்க முடியாத மொழியாற்றலுடன் முன்வைக்கப்படும் போது புதிய வரலாற்றுப் பாதை உருவாகும்." தேடலைத் தொடருங்கள்.';
        case 'hindi':
          return '💡 सीख: "जब गहन वैज्ञानिक सत्य को ओजस्वी भाषा के साथ प्रस्तुत किया जाता है, तो पुरानी रूढ़िवादिता ध्वस्त हो जाती है और नई क्रांति जन्म लेती है।" ज्ञान की ज्योति जलाएं।';
        case 'telugu':
          return '💡 నీతి: "లోతైన శాస్త్రీయ సత్యాన్ని గంభీరమైన భాషతో వ్యక్తపరిచినప్పుడు పాత మూఢనమ్మకాలు తొలగి కొత్త విజ్ఞాన యుగం ఆవిష్కృతమవుతుంది." అన్వేషణ సాగించండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ಆಳವಾದ ವೈಜ್ಞಾನಿಕ ಸತ್ಯವನ್ನು ಗಾಂಭೀರ್ಯದ ಭಾಷೆಯಲ್ಲಿ ಮಂಡಿಸಿದಾಗ ಸಮಾಜದ ಹಳೆಯ ಚೌಕಟ್ಟುಗಳು ಮುರಿದು ಹೊಸ ಕ್ರಾಂತಿ ಆರಂಭವಾಗುತ್ತದೆ." ಅನ್ವೇಷಕರಾಗಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ആഴത്തിലുള്ള ശാസ്ത്രീയ സത്യങ്ങളെ ഗംഭീരമായ ഭാഷാപാടവത്തോടെ അവതരിപ്പിക്കുമ്പോൾ, നൂറ്റാണ്ടുകളുടെ തെറ്റായ ധാരണകളെപ്പോലും തകർത്തു പുതിയ ജ്ഞാനവിപ്ലവം സൃഷ്ടിക്കാൻ സാധിക്കും." അന്വേഷണം തുടരുക!';
      }
    }

    if (widget.day == 12) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "விவாதத்தில் வெல்வது என்பது பிறரை அடக்குவதல்ல; போலி வாதங்களை அறிவின் ஒளியால் விளக்கி உண்மையை நிலைநாட்டுவதாகும்." நிதானமாகப் பேசுங்கள்.';
        case 'hindi':
          return '💡 सीख: "वाद-विवाद में जीत दूसरों पर चिल्लाने से नहीं, बल्कि शांत बुद्धि और अकाट्य तर्कों से खोखले विचारों को बेनकाब करने से मिलती है।" विवेक से संवाद करें।';
        case 'telugu':
          return '💡 నీతి: "చర్చలో గెలవడం అంటే ఇతరులను అణగదొక్కడం కాదు; బోలు వాదనలను వివేకవంతమైన తర్కంతో తొలగించి సత్యాన్ని నిరూపించడమే." హుందాగా మాట్లాడండి.';
        case 'kannada':
          return '💡 ನೀತಿ: "ಸಂವಾದದಲ್ಲಿ ಗೆಲ್ಲುವುದು ಎಂದರೆ ಬೇರೆಯವರನ್ನು ಹತ್ತಿಕ್ಕುವುದಲ್ಲ; ಪೊಳ್ಳು ವಾದಗಳನ್ನು ವಿವೇಕಯುತ ತರ್ಕದಿಂದ ನಿವಾರಿಸಿ ಸತ್ಯವನ್ನು ಎತ್ತಿಹಿಡಿಯುವುದೇ ಆಗಿದೆ." ಶಾಂತಿಯಿಂದ ಮಾತನಾಡಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "സംവാദത്തിൽ ജയിക്കുക എന്നാൽ ഒച്ചവെച്ച് അപരനെ അടിച്ചമർത്തലല്ല, മറിച്ച് അന്ധമായ വാദങ്ങളെ വിവേകപൂർവ്വമായ യുക്തികൊണ്ട് തുറന്നുകാട്ടി പരമസത്യത്തെ സ്ഥാപിക്കലാണ്." ശാന്തമായി സംസാരിക്കുക!';
      }
    }

    if (widget.day == 11) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "மொழிப்புலமை என்பது முற்றுப்பெறும் இடமல்ல; அது அறிவையும் சிந்தனையையும் தொடர்ந்து புத்துயிர் பெறச் செய்யும் முடிவில்லாப் பயணம்." விழிப்புணர்வுடன் பயிலுங்கள்.';
        case 'hindi':
          return '💡 सीख: "भाषाई प्रवीणता कोई ठहरा हुआ पड़ाव नहीं है, बल्कि यह चेतना और सोच को निरंतर नया आयाम देने वाली एक अंतहीन यात्रा है।"';
        case 'telugu':
          return '💡 నీతి: "భాషా నైపుణ్యం అనేది ఒకసారి చేరుకుని ఆగిపోయే గమ్యం కాదు; అది ఆలోచనలను నిరంతరం పునర్నిర్మించే అంతులేని జ్ఞాన ప్రయాణం."';
        case 'kannada':
          return '💡 ನೀತಿ: "ಭಾಷಾ ಪ್ರೌಢಿಮೆಯು ಒಂದು ನಿಲ್ದಾಣವಲ್ಲ; ಅದು ಚಿಂತನೆಗಳನ್ನು ನಿರಂತರವಾಗಿ ಪರಿವರ್ತಿಸುವ ಅನಂತ ಜ್ಞಾನಯಾನ." ಶ್ರದ್ಧೆಯಿಂದ ಮುನ್ನಡೆಯಿರಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഭാഷാ പ്രാവീണ്യം എന്നത് എത്തിച്ചേർന്ന് നിർത്തേണ്ട ഒരു ലക്ഷ്യസ്ഥാനമല്ല; മറിച്ച് അത് ചിന്തകളെ നിരന്തരം നവീകരിക്കുന്ന അനന്തമായ ജ്ഞാനയാത്രയാണ്."';
      }
    }

    if (widget.day == 10) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "கடும் கருத்து வேறுபாடுகளுக்கு மத்தியிலும் பரஸ்பர மரியாதையுடன் அனைவரையும் ஒன்றிணைக்கும் ஒருமித்த கருத்தை உருவாக்குவதே தலைமைத்துவத்தின் உச்சகட்ட சாதனை." நிலைத்து நில்லுங்கள்.';
        case 'hindi':
          return '💡 सीख: "गंभीर मतभेदों के बीच भी परस्पर सम्मान से सर्वसम्मत समझौता बनाना ही नेतृत्वकारी अंग्रेजी की सर्वोच्च सफलता है।"';
        case 'telugu':
          return '💡 నీతి: "తీవ్ర విభేదాల మధ్య కూడా పరస్పర గౌరవంతో అందరినీ ఏకం చేసే ఏకాభిప్రాయాన్ని నిర్మించడమే నాయకత్వ ఇంగ్లీష్ యొక్క అత్యున్నత శిఖరం."';
        case 'kannada':
          return '💡 ನೀತಿ: "ತೀವ್ರ ಭಿನ್ನಾಭಿಪ್ರಾಯಗಳ ನಡುವೆಯೂ ಪರಸ್ಪರ ಗೌರವದಿಂದ ಸರ್ವಸಮ್ಮತ ನಿರ್ಧಾರಕ್ಕೆ ಎಲ್ಲರನ್ನೂ ತರುವುದೇ ನಾಯಕತ್ವದ ನಿಜವಾದ ಯಶಸ್ಸು." ಮುನ್ನಡೆಯಿರಿ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ഏറ്റവും കടുത്ത ഭിന്നതകളിൽ നിന്നും പരസ്പര ബഹുമാനത്തോടെ എല്ലാവരെയും ഒന്നിപ്പിക്കുന്ന സമവായം സൃഷ്ടിക്കുന്നതിലാണ് നേതൃത്വപരമായ ഇംഗ്ലീഷിന്റെ പരമോന്നത വിജയം."';
      }
    }

    if (widget.day == 9) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "எளிமையான சரி-தவறுகளுக்கு அப்பால், சிக்கலான நுண்ணிய கருத்துக்களை நிதானமாக ஆராய்வதே உண்மையான மொழி முதிர்ச்சியாகும்." தெளிவுடன் பேசுங்கள்.';
        case 'hindi':
          return '💡 सीख: "सरल हां-ना के परे, जीवन और संवाद की सूक्ष्म बारीकियों को शांत मन से समझना ही सच्ची भाषाई परिपक्वता है।" गहराई से सोचें।';
        case 'telugu':
          return '💡 నీతి: "సరళమైన మంచి-చెడులకు అతీతంగా, సంక్లిష్టమైన సూక్ష్మ అంశాలను ప్రశాంతంగా విశ్లేషించగలగడమే నిజమైన భాషా పరిపక్వత."';
        case 'kannada':
          return '💡 ನೀತಿ: "ಸರಳ ಸರಿ-ತಪ್ಪುಗಳಿಗಿಂತ ಮಿಗಿಲಾಗಿ, ಸಂಕೀರ್ಣ ಸೂಕ್ಷ್ಮತೆಗಳನ್ನು ಶಾಂತವಾಗಿ ವಿಶ್ಲೇಷಿಸುವುದೇ ನಿಜವಾದ ಭಾಷಾ ಪ್ರಬುದ್ಧತೆ."';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "ലളിതമായ ശരിതെറ്റുകൾക്കപ്പുറം സങ്കീർണ്ണമായ സൂക്ഷ്മതകളെ സമചിത്തതയോടെ വിലയിരുത്താൻ സാധിക്കുമ്പോഴാണ് യഥാർത്ഥ ഭാഷാ പക്വത തെളിയുന്നത്."';
      }
    }

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
  void initState() {
    super.initState();
    _loadVocabForDay();
    _loadSavedMissionState();
    _timerService.addListener(_onTimerStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final hasAccepted = prefs.getBool('pocket_world_rules_accepted_v1') ?? false;
        if (!hasAccepted && widget.day == 1 && mounted) {
          PocketWorldGameRulesModal.show(context, currentDay: widget.day);
        }
      } catch (_) {}
    });
  }

  void _onTimerStateChanged() {
    if (mounted) setState(() {});
  }

  void _onLanguageSelected(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  Future<void> _speakWord(String text) async {
    try {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _speakStory(String text) async {
    try {
      if (_isStorySpeaking) {
        await _tts.stop();
        if (mounted) setState(() => _isStorySpeaking = false);
        return;
      }
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isStorySpeaking = false);
      });
      if (mounted) setState(() => _isStorySpeaking = true);
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isStorySpeaking = false);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _speakingTimer?.cancel();
    _timerService.removeListener(_onTimerStateChanged);
    super.dispose();
  }

  void _loadVocabForDay() {
    if (PocketMissionCurriculumRegistry.hasDay(widget.day)) {
      final regVocab = PocketMissionCurriculumRegistry.getVocabItems(widget.day);
      if (regVocab.isNotEmpty) {
        _vocabList = regVocab;
        return;
      }
    }
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

    if (widget.day == 9) {
      // 10 high-impact vocabulary words for Day 9 (Nuanced Discourse & Critical Evaluation)
      _vocabList = const [
        DailyVocabItem(
          word: 'Nuance',
          partOfSpeech: 'noun',
          definition: 'A subtle difference in or shade of meaning, expression, or sound.',
          malayalamMeaning: 'സൂക്ഷ്മഭേദം / അർത്ഥവ്യത്യാസം',
          tamilMeaning: 'நுண்ணிய வேறுபாடு',
          hindiMeaning: 'सूक्ष्म भेद / बारीकी',
          teluguMeaning: 'సూక్ష్మ భేదం',
          kannadaMeaning: 'ಸೂಕ್ಷ್ಮ ವ್ಯತ್ಯಾಸ',
          exampleSentence: 'Master speakers appreciate the nuance between assertiveness and aggression.',
          phonetic: '/ˈnjuː.ɑːns/',
        ),
        DailyVocabItem(
          word: 'Paradox',
          partOfSpeech: 'noun',
          definition: 'A seemingly absurd or contradictory statement that may prove to be true.',
          malayalamMeaning: 'വിരോധാഭാസം',
          tamilMeaning: 'முரண்போலி',
          hindiMeaning: 'विरोधाभास',
          teluguMeaning: 'విరోధాభాసం',
          kannadaMeaning: 'ವಿರೋಧಾಭಾಸ',
          exampleSentence: 'The paradox of fluency is that making mistakes accelerates learning.',
          phonetic: '/ˈpær.ə.dɒks/',
        ),
        DailyVocabItem(
          word: 'Cognizant',
          partOfSpeech: 'adjective',
          definition: 'Having knowledge or being aware of something.',
          malayalamMeaning: 'വ്യക്തമായ ബോധ്യമുള്ള / അറിവുള്ള',
          tamilMeaning: 'நன்கு அறிந்த / உணர்ந்த',
          hindiMeaning: 'अवगत / जानकार',
          teluguMeaning: 'పూర్తి స్పృహ గల / తెలిసిన',
          kannadaMeaning: 'ಅರಿವುಳ್ಳ / ತಿಳಿದಿರುವ',
          exampleSentence: 'Be cognizant of your listener\'s background when speaking.',
          phonetic: '/ˈkɒɡ.nɪ.zənt/',
        ),
        DailyVocabItem(
          word: 'Plausible',
          partOfSpeech: 'adjective',
          definition: 'Seeming reasonable, probable, or worthy of approval.',
          malayalamMeaning: 'വിശ്വസനീയമായ / ന്യായമായ',
          tamilMeaning: 'நம்பத்தகுந்த / ஏற்றுக்கொள்ளக்கூடிய',
          hindiMeaning: 'विश्वसनीय / संभव',
          teluguMeaning: 'నమ్మదగిన / సమంజసమైన',
          kannadaMeaning: 'ನಂಬಲರ್ಹ / ಸಮಂಜಸವಾದ',
          exampleSentence: 'She formulated a plausible explanation grounded in empirical facts.',
          phonetic: '/ˈplɔː.zə.bəl/',
        ),
        DailyVocabItem(
          word: 'Ambiguity',
          partOfSpeech: 'noun',
          definition: 'The quality of being open to more than one interpretation; inexactness.',
          malayalamMeaning: 'അവ്യക്തത',
          tamilMeaning: 'தெளிவின்மை / குழப்பமான நிலை',
          hindiMeaning: 'अस्पष्टता / द्वयर्थकता',
          teluguMeaning: 'సందేహం / అస్పష్టత',
          kannadaMeaning: 'ಅಸ್ಪಷ್ಟತೆ',
          exampleSentence: 'Eliminate ambiguity by selecting precise, definitive adjectives.',
          phonetic: '/ˌæm.bɪˈɡjuː.ə.ti/',
        ),
        DailyVocabItem(
          word: 'Substantiate',
          partOfSpeech: 'verb',
          definition: 'Provide evidence to support or prove the truth of an assertion.',
          malayalamMeaning: 'തെളിവുകൾ നിരത്തി സ്ഥാപിക്കുക',
          tamilMeaning: 'ஆதாரத்துடன் நிரூபித்தல்',
          hindiMeaning: 'सिद्ध करना / पुष्ट करना',
          teluguMeaning: 'ఆధారాలతో నిరూపించు',
          kannadaMeaning: 'ಆಧಾರ ಸಹಿತ ಸಾಬೀತುಪಡಿಸು',
          exampleSentence: 'Always substantiate your debating points with real-world examples.',
          phonetic: '/səbˈstæn.ʃi.eɪt/',
        ),
        DailyVocabItem(
          word: 'Juxtapose',
          partOfSpeech: 'verb',
          definition: 'Place close together or side by side for contrasting effect.',
          malayalamMeaning: 'താരതമ്യത്തിനായി ചേർത്തുവെക്കുക',
          tamilMeaning: 'ஒப்பிட்டுப் பார்த்தல்',
          hindiMeaning: 'तुलना के लिए पास रखना',
          teluguMeaning: 'పోల్చి చూచు',
          kannadaMeaning: 'ಹೋಲಿಕೆಗಾಗಿ ಪಕ್ಕದಲ್ಲಿಡು',
          exampleSentence: 'The orator juxtaposed the ancient proverb with modern realities.',
          phonetic: '/ˈdʒʌk.stə.pəʊz/',
        ),
        DailyVocabItem(
          word: 'Dispassionate',
          partOfSpeech: 'adjective',
          definition: 'Not influenced by strong emotion, and so able to be rational and impartial.',
          malayalamMeaning: 'വികാരങ്ങൾക്ക് അടിപ്പെടാത്ത / നിഷ്പക്ഷമായ',
          tamilMeaning: 'உணர்ச்சிவசப்படாத / நடுநிலையான',
          hindiMeaning: 'निष्पक्ष / शांतचित्त',
          teluguMeaning: 'నిష్పాక్షిక / శాంతచిత్త',
          kannadaMeaning: 'ನಿರ್ಲಿಪ್ತ / ಶಾಂತಚಿತ್ತದ',
          exampleSentence: 'A dispassionate analysis enables fair resolution of heated disputes.',
          phonetic: '/dɪsˈpæʃ.ən.ət/',
        ),
        DailyVocabItem(
          word: 'Tenacious',
          partOfSpeech: 'adjective',
          definition: 'Tending to keep a firm hold of something; persisting.',
          malayalamMeaning: 'വിട്ടുകൊടുക്കാത്ത / കഠിനമായി പ്രയത്നിക്കുന്ന',
          tamilMeaning: 'விடாப்பிடியான / உறுதியான',
          hindiMeaning: 'दृढ़ / अटूट',
          teluguMeaning: 'పట్టువదలని',
          kannadaMeaning: 'ಛಲಬಿಡದ / ದೃಢವಾದ',
          exampleSentence: 'Tenacious students overcome initial hesitation and attain fluency.',
          phonetic: '/təˈneɪ.ʃəs/',
        ),
        DailyVocabItem(
          word: 'Discreet',
          partOfSpeech: 'adjective',
          definition: 'Careful and prudent in one\'s speech or actions to avoid offense.',
          malayalamMeaning: 'സൂക്ഷ്മതയോടെ പെരുമാറുന്ന',
          tamilMeaning: 'விவேகமுள்ள / அடக்கமான',
          hindiMeaning: 'विचारशील / चौकस',
          teluguMeaning: 'విచక్షణ గల',
          kannadaMeaning: 'ವಿವೇಚನಾಯುಕ್ತ / ಎಚ್ಚರಿಕೆಯ',
          exampleSentence: 'Diplomats remain discreet even when facing provocative questions.',
          phonetic: '/dɪˈskriːt/',
        ),
      ];
      return;
    }

    if (widget.day == 10) {
      // 10 high-impact vocabulary words for Day 10 (Executive Statesmanship & Strategic Influence)
      _vocabList = const [
        DailyVocabItem(
          word: 'Statesmanship',
          partOfSpeech: 'noun',
          definition: 'Skill in managing public affairs and conducting international relations.',
          malayalamMeaning: 'ഭരണതന്ത്രജ്ഞത / രാഷ്ട്രതന്ത്രജ്ഞത',
          tamilMeaning: 'அரசியல் சாதுரியம் / தலைமைப் பண்பு',
          hindiMeaning: 'राजमर्मज्ञता / कूटनीतिक कुशलता',
          teluguMeaning: 'రాజనీతిజ్ఞత',
          kannadaMeaning: 'ರಾಜನೀತಿಜ್ಞತೆ',
          exampleSentence: 'Executive statesmanship unites opposing factions toward common prosperity.',
          phonetic: '/ˈsteɪts.mən.ʃɪp/',
        ),
        DailyVocabItem(
          word: 'Unanimous',
          partOfSpeech: 'adjective',
          definition: 'Fully in agreement; held or carried by everyone involved.',
          malayalamMeaning: 'ഐകകണ്ഠ്യേനയുള്ള',
          tamilMeaning: 'ஒருமனதான',
          hindiMeaning: 'सर्वसम्मत / एकमत',
          teluguMeaning: 'ఏకగ్రీవమైన',
          kannadaMeaning: 'ಸರ್ವಾನುಮತದ',
          exampleSentence: 'The peace treaty received the unanimous approval of the general assembly.',
          phonetic: '/juːˈnæn.ɪ.məs/',
        ),
        DailyVocabItem(
          word: 'Cohesive',
          partOfSpeech: 'adjective',
          definition: 'Characterized by or causing parts to stick together in unity.',
          malayalamMeaning: 'കെട്ടുറപ്പുള്ള / ഒത്തൊരുമയുള്ള',
          tamilMeaning: 'ஒற்றுமையான / பிணைப்பான',
          hindiMeaning: 'सुगठित / एकजुट',
          teluguMeaning: 'సమైక్యమైన / కలసికట్టుగా ఉండే',
          kannadaMeaning: 'ಒಗ್ಗಟ್ಟಿನ / ಸುಸಂಬದ್ಧ',
          exampleSentence: 'A cohesive team navigates high-stakes challenges with confidence.',
          phonetic: '/kəʊˈhiː.sɪv/',
        ),
        DailyVocabItem(
          word: 'Concession',
          partOfSpeech: 'noun',
          definition: 'A thing that is granted, especially in response to demands.',
          malayalamMeaning: 'വിട്ടുവീഴ്ച / ഇളവ്',
          tamilMeaning: 'விட்டுக்கொடுத்தல் / சலுகை',
          hindiMeaning: 'रियायत / छूट',
          teluguMeaning: 'రాయితీ / సర్దుబాటు',
          kannadaMeaning: 'ರಿಯಾಯಿತಿ / ಸಡಿಲಿಕೆ',
          exampleSentence: 'Strategic concessions are sometimes required to unlock historic accords.',
          phonetic: '/kənˈseʃ.ən/',
        ),
        DailyVocabItem(
          word: 'Galvanize',
          partOfSpeech: 'verb',
          definition: 'Shock or excite someone into taking rapid, purposeful action.',
          malayalamMeaning: 'പ്രവർത്തന സജ്ജമാക്കുക / ഉണർത്തുക',
          tamilMeaning: 'செயல்படத் தூண்டுதல்',
          hindiMeaning: 'प्रेरित करना / जोश भरना',
          teluguMeaning: 'ఉత్తేజపరచు / కార్యోన్ముఖుడిని చేయు',
          kannadaMeaning: 'ಪ್ರೇರೇಪಿಸು / ಚುರುಕುಗೊಳಿಸು',
          exampleSentence: 'Her inspirational keynote galvanized the entire movement.',
          phonetic: '/ˈɡæl.və.naɪz/',
        ),
        DailyVocabItem(
          word: 'Imperative',
          partOfSpeech: 'adjective',
          definition: 'Of vital importance; crucial or indispensable.',
          malayalamMeaning: 'അത്യന്താപേക്ഷിതമായ',
          tamilMeaning: 'மிக அவசியமான',
          hindiMeaning: 'अति आवश्यक / अनिवार्य',
          teluguMeaning: 'అత్యవసరమైన / అనివార్యమైన',
          kannadaMeaning: 'ಅತ್ಯಗತ್ಯವಾದ / ಕಡ್ಡಾಯ',
          exampleSentence: 'Daily speaking practice is imperative for conversational naturalness.',
          phonetic: '/ɪmˈper.ə.tɪv/',
        ),
        DailyVocabItem(
          word: 'Benchmark',
          partOfSpeech: 'noun',
          definition: 'A standard or point of reference against which things may be compared.',
          malayalamMeaning: 'മാനദണ്ഡം',
          tamilMeaning: 'அளவுகோல்',
          hindiMeaning: 'मानक / पैमाना',
          teluguMeaning: 'ప్రామాణికం',
          kannadaMeaning: 'ಮಾನದಂಡ',
          exampleSentence: 'Completing Day 10 sets a golden benchmark for your 90-day journey.',
          phonetic: '/ˈbentʃ.mɑːk/',
        ),
        DailyVocabItem(
          word: 'Formidable',
          partOfSpeech: 'adjective',
          definition: 'Inspiring fear or respect through being impressively large or capable.',
          malayalamMeaning: 'ശക്തമായ / അതിശക്തമായ',
          tamilMeaning: 'அஞ்சத்தக்க / மாபெரும்',
          hindiMeaning: 'अजेय / दुर्जेय',
          teluguMeaning: 'అజేయమైన / బలమైన',
          kannadaMeaning: 'ಅಜೇಯ / ಪ್ರಬಲ',
          exampleSentence: 'With consistent dedication, you become a formidable communicator.',
          phonetic: '/fɔːˈmɪd.ə.bəl/',
        ),
        DailyVocabItem(
          word: 'Reconcile',
          partOfSpeech: 'verb',
          definition: 'Restore friendly relations between; harmonize conflicting elements.',
          malayalamMeaning: 'പൊരുത്തപ്പെടുത്തുക / രമ്യതയിലെത്തുക',
          tamilMeaning: 'சமாதானப்படுத்துதல் / இணைத்தல்',
          hindiMeaning: 'सामंजस्य बैठाना / समाधान करना',
          teluguMeaning: 'సమన్వయించు / రాజీ చేయు',
          kannadaMeaning: 'ಹೊಂದಾಣಿಕೆ ಮಾಡು / ಸಮಾಧಾನಗೊಳಿಸು',
          exampleSentence: 'The ambassador reconciled the contradictory trade proposals.',
          phonetic: '/ˈrek.ən.saɪl/',
        ),
        DailyVocabItem(
          word: 'Monumental',
          partOfSpeech: 'adjective',
          definition: 'Great in importance, extent, or size.',
          malayalamMeaning: 'ചരിത്രപ്രധാനമായ / മഹത്തായ',
          tamilMeaning: 'வரலாற்றுச் சிறப்புமிக்க / பிரம்மாண்ட',
          hindiMeaning: 'स्मरणीय / ऐतिहासिक / महान',
          teluguMeaning: 'అపూర్వమైన / చారిత్రాత్మక',
          kannadaMeaning: 'ಐತಿಹಾಸಿಕ / ಅದ್ಭುತ',
          exampleSentence: 'Reaching the 10-day milestone is a monumental achievement in fluency.',
          phonetic: '/ˌmɒn.jəˈmen.təl/',
        ),
      ];
      return;
    }

    if (widget.day == 18) {
      // 10 high-impact vocabulary words for Day 18 (Mixed Conditionals & Sovereign Synthesis)
      _vocabList = const [
        DailyVocabItem(
          word: 'Synthesis',
          partOfSpeech: 'noun',
          definition: 'The combination of ideas, principles, or elements into a coherent whole.',
          malayalamMeaning: 'സംയോജനം / സമന്വയം',
          tamilMeaning: 'ஒருங்கிணைப்பு / தொகுப்பு',
          hindiMeaning: 'संश्लेषण / संयोजन',
          teluguMeaning: 'సమన్వయం / సంశ్లేషణ',
          kannadaMeaning: 'ಸಂಶ್ಲೇಷಣೆ / ಸಂಯೋಜನೆ',
          exampleSentence: 'The treatise is an exquisite synthesis of classical and modern statecraft.',
          phonetic: '/ˈsɪn.θə.sɪs/',
        ),
        DailyVocabItem(
          word: 'Legacy',
          partOfSpeech: 'noun',
          definition: 'Something handed down from predecessors; enduring heritage.',
          malayalamMeaning: 'പൈതൃകം / പിന്തുടർച്ച',
          tamilMeaning: 'பாரம்பரியம் / வழிவழியாக வந்த சொத்து',
          hindiMeaning: 'विरासत / धरोहर',
          teluguMeaning: 'వారసత్వం',
          kannadaMeaning: 'ಪರಂಪರೆ / ಆಸ್ತಿ',
          exampleSentence: 'The peace treaty became the crown jewel of their historical legacy.',
          phonetic: '/ˈleɡ.ə.si/',
        ),
        DailyVocabItem(
          word: 'Retrospective',
          partOfSpeech: 'adjective',
          definition: 'Looking back on, contemplating, or dealing with past events.',
          malayalamMeaning: 'ഭൂതകാലാവലോകനപരമായ',
          tamilMeaning: 'பின்னோக்கிய / கடந்த காலத்தை நோக்கும்',
          hindiMeaning: 'भूतलक्षी / अतीतदर्शी',
          teluguMeaning: 'గతావలోకన',
          kannadaMeaning: 'ಸಿಂಹಾವಲೋಕನದ',
          exampleSentence: 'A retrospective audit proved that every sacrifice had been justified.',
          phonetic: '/ˌret.rəˈspek.tɪv/',
        ),
        DailyVocabItem(
          word: 'Sovereign',
          partOfSpeech: 'adjective',
          definition: 'Possessing supreme, independent authority and self-determination.',
          malayalamMeaning: 'പരമാധികാരമുള്ള / സ്വതന്ത്രമായ',
          tamilMeaning: 'இறையாண்மையுள்ள / தன்னாட்சி',
          hindiMeaning: 'संप्रभु / स्वायत्त',
          teluguMeaning: 'సార్వభౌమ / స్వతంత్ర',
          kannadaMeaning: 'ಸಾರ್ವಭೌಮ / ಸ್ವತಂತ್ರ',
          exampleSentence: 'Sovereign nations maintain the inalienable right to chart their destinies.',
          phonetic: '/ˈsɒv.rɪn/',
        ),
        DailyVocabItem(
          word: 'Fortification',
          partOfSpeech: 'noun',
          definition: 'A defensive wall or reinforcement built to safeguard against invasion.',
          malayalamMeaning: 'കോട്ടകെട്ടി സുരക്ഷിതമാക്കൽ / പ്രതിരോധം',
          tamilMeaning: 'கோட்டை கொத்தளம் / அரண்',
          hindiMeaning: 'किलेबंदी / मोर्चाबंदी',
          teluguMeaning: 'కోట రక్షణ / బలపరచడం',
          kannadaMeaning: 'ಕೋಟೆ ನಿರ್ಮಾಣ / ರಕ್ಷಣೆ',
          exampleSentence: 'Intellectual fortification shields the mind against deceptive fallacies.',
          phonetic: '/ˌfɔː.tɪ.fɪˈkeɪ.ʃən/',
        ),
        DailyVocabItem(
          word: 'Transcendent',
          partOfSpeech: 'adjective',
          definition: 'Beyond or above the range of normal, physical, or ordinary experience.',
          malayalamMeaning: 'അതീതമായ / പരമോന്നതമായ',
          tamilMeaning: 'அளப்பரிய / எல்லையைக் கடந்த',
          hindiMeaning: 'सर्वोत्कृष्ट / अतींद्रिय',
          teluguMeaning: 'అతీతమైన / సర్వోన్నత',
          kannadaMeaning: 'ಅತೀತವಾದ / ಶ್ರೇಷ್ಠ',
          exampleSentence: 'The poet captured a transcendent moment of human courage.',
          phonetic: '/trænˈsen.dənt/',
        ),
        DailyVocabItem(
          word: 'Epoch',
          partOfSpeech: 'noun',
          definition: 'A particular period of time in history characterized by notable events.',
          malayalamMeaning: 'യുഗം / ചരിത്രഘട്ടം',
          tamilMeaning: 'வரலாற்று சகாப்தம்',
          hindiMeaning: 'युग / नया दौर',
          teluguMeaning: 'యుగం / చారిత్రక ఘట్టம்',
          kannadaMeaning: 'ಯುಗ / ಹೊಸ ಕಾಲಘಟ್ಟ',
          exampleSentence: 'Their breakthrough inaugurated an epoch of interplanetary exploration.',
          phonetic: '/ˈiː.pɒk/',
        ),
        DailyVocabItem(
          word: 'Visionary',
          partOfSpeech: 'noun',
          definition: 'A person with original, far-seeing ideas about the future.',
          malayalamMeaning: 'ദീർഘദർശി / ഭാവനാസമ്പന്നൻ',
          tamilMeaning: 'தொலைநோக்கு சிந்தனையாளர்',
          hindiMeaning: 'दूरदर्शी / स्वप्नदृष्टा',
          teluguMeaning: 'దూరదృష్టిగల వ్యక్తి',
          kannadaMeaning: 'ದೂರದರ್ಶಿ / ಭವಿಷ್ಯ ಚಿಂತಕ',
          exampleSentence: 'Only a visionary could foresee how digital tools would empower voices.',
          phonetic: '/ˈvɪʒ.ən.ri/',
        ),
        DailyVocabItem(
          word: 'Inviolable',
          partOfSpeech: 'adjective',
          definition: 'Never to be broken, infringed, or dishonored; sacred and absolute.',
          malayalamMeaning: 'ലംഘിക്കാനാവാത്ത / പവിത്രമായ',
          tamilMeaning: 'மீற முடியாத / புனிதமான',
          hindiMeaning: 'अनुल्लंघनीय / पवित्र',
          teluguMeaning: 'ఉల్లంఘించలేని / పవిత్రమైన',
          kannadaMeaning: 'ಉಲ್ಲಂಘಿಸಲಾಗದ / ಪವಿತ್ರ',
          exampleSentence: 'The human rights treaty declared human dignity to be inviolable.',
          phonetic: '/ɪnˈvaɪ.ə.lə.bəl/',
        ),
        DailyVocabItem(
          word: 'Culmination',
          partOfSpeech: 'noun',
          definition: 'The highest, crowning point of something attained after protracted effort.',
          malayalamMeaning: 'പാരമ്യം / പരിസമാപ്തി',
          tamilMeaning: 'உச்சக்கட்டம் / நிறைவு',
          hindiMeaning: 'चरम सीमा / परिणति',
          teluguMeaning: 'పరాకాష్ట / ముగింపు',
          kannadaMeaning: 'ಪರಾಕಾಷ್ಠೆ / ಅಂತಿಮ ಹಂತ',
          exampleSentence: 'Day 18 marks the culmination of advanced grammatical mastery.',
          phonetic: '/ˌkʌl.mɪˈneɪ.ʃən/',
        ),
      ];
      return;
    }

    if (widget.day == 17) {
      // 10 high-impact vocabulary words for Day 17 (Syntactic Parallelism & Symmetrical Balance)
      _vocabList = const [
        DailyVocabItem(
          word: 'Symmetry',
          partOfSpeech: 'noun',
          definition: 'The quality of being made up of exactly similar parts facing each other or around an axis.',
          malayalamMeaning: 'സമമിതി / സന്തുലിതാവസ്ഥ',
          tamilMeaning: 'சமச்சீர்மை',
          hindiMeaning: 'समरूपता / संतुलन',
          teluguMeaning: 'సౌష్ఠవం / సమతుల్యత',
          kannadaMeaning: 'ಸಮಪಾತಳಿ / ಸಮರೂಪತೆ',
          exampleSentence: 'Syntactic symmetry renders political rhetoric impossible to forget.',
          phonetic: '/ˈsɪm.ə.tri/',
        ),
        DailyVocabItem(
          word: 'Cadence',
          partOfSpeech: 'noun',
          definition: 'A rhythmic sequence or flow of sounds in language.',
          malayalamMeaning: 'താളഭംഗി / സ്വരതാളം',
          tamilMeaning: 'குரல் ஏற்ற இறக்கம் / தாள லயம்',
          hindiMeaning: 'स्वर-लहरी / लयबद्धता',
          teluguMeaning: 'స్వర విన్యాసం / లయ',
          kannadaMeaning: 'ಧ್ವನಿ ಏರಿಳಿತ / ಲಯ',
          exampleSentence: 'The courtroom fell silent as the cadence of her argument gathered speed.',
          phonetic: '/ˈkeɪ.dəns/',
        ),
        DailyVocabItem(
          word: 'Obfuscation',
          partOfSpeech: 'noun',
          definition: 'The action of making something obscure, unclear, or unintelligible.',
          malayalamMeaning: 'അവ്യക്തതയുണ്ടാക്കൽ / പുകമറസൃഷ്ടിക്കൽ',
          tamilMeaning: 'குழப்பம் உண்டாக்குதல்',
          hindiMeaning: 'भ्रम पैदा करना / अस्पष्टता',
          teluguMeaning: 'గందరగోళ పరచడం',
          kannadaMeaning: 'ಗೊಂದಲ ಉಂಟುಮಾಡುವುದು',
          exampleSentence: 'The defense sought not justice, but deliberate obfuscation.',
          phonetic: '/ˌɒb.fʌsˈkeɪ.ʃən/',
        ),
        DailyVocabItem(
          word: 'Equanimity',
          partOfSpeech: 'noun',
          definition: 'Mental calmness, composure, and evenness of temper in difficult situations.',
          malayalamMeaning: 'സമചിത്തത / മനശാന്തി',
          tamilMeaning: 'மன அமைதி / சலனமற்ற நிலை',
          hindiMeaning: 'समभाव / मानसिक संतुलन',
          teluguMeaning: 'సమచిత్తత / ప్రశాంతత',
          kannadaMeaning: 'ಮನಸ್ಸಿನ ಶಾಂತಿ / ಸಮಾಧಾನ',
          exampleSentence: 'She received praise and condemnation with equal equanimity.',
          phonetic: '/ˌek.wəˈnɪm.ə.ti/',
        ),
        DailyVocabItem(
          word: 'Rectitude',
          partOfSpeech: 'noun',
          definition: 'Morally correct behaviour or thinking; unblemished integrity.',
          malayalamMeaning: 'ധാർമ്മികശുദ്ധി / നീതിനിഷ്ഠ',
          tamilMeaning: 'நேர்மை / அறநெறி',
          hindiMeaning: 'सदाचार / सत्यनिष्ठा',
          teluguMeaning: 'ధర్మనిష్ఠ / నిజాయితీ',
          kannadaMeaning: 'ಸದಾಚಾರ / ನಿಷ್ಠೆ',
          exampleSentence: 'The magistrate was revered for unflinching judicial rectitude.',
          phonetic: '/ˈrek.tɪ.tʃuːd/',
        ),
        DailyVocabItem(
          word: 'Juxtaposition',
          partOfSpeech: 'noun',
          definition: 'The fact of placing two or more things side by side to highlight comparison or contrast.',
          malayalamMeaning: 'താരതമ്യപ്പെടുത്തൽ / ഒരുമിച്ചു ചേർത്തുനിർത്തൽ',
          tamilMeaning: 'ஒப்பீடு செய்ய அருகருகே வைத்தல்',
          hindiMeaning: 'समीपस्थापन / तुलनात्मक मिलान',
          teluguMeaning: 'పోలిక కోసం పక్కపక్కనే ఉంచుట',
          kannadaMeaning: 'ಹೋಲಿಕೆಗಾಗಿ ಪಕ್ಕಪಕ್ಕದಲ್ಲಿ ಇಡುವುದು',
          exampleSentence: 'The juxtaposition of opulent promises and harsh reality exposed the deceit.',
          phonetic: '/ˌdʒʌk.stə.pəˈzɪʃ.ən/',
        ),
        DailyVocabItem(
          word: 'Eloquence',
          partOfSpeech: 'noun',
          definition: 'Fluent or persuasive speaking or writing.',
          malayalamMeaning: 'വാഗ്മിത്വം / ആശയപ്രകാശന സാമർത്ഥ്യം',
          tamilMeaning: 'சொல்வளம் / நாவன்மை',
          hindiMeaning: 'सुवक्तृत्व / वाक्पटुता',
          teluguMeaning: 'వాగ్ధాటి / ప్రావీణ్యం',
          kannadaMeaning: 'ಮಾತಿನ ಜಾಣ್ಮೆ / ವಾಗ್ಝರಿ',
          exampleSentence: 'Her natural eloquence stirred thousands into purposeful collective action.',
          phonetic: '/ˈel.ə.kwəns/',
        ),
        DailyVocabItem(
          word: 'Unflinching',
          partOfSpeech: 'adjective',
          definition: 'Not showing fear, hesitation, or compromise in facing difficulty.',
          malayalamMeaning: 'പതറാത്ത / അചഞ്ചലമായ',
          tamilMeaning: 'அஞ்சாத / உறுதியான',
          hindiMeaning: 'अडिग / निडर',
          teluguMeaning: 'అచంచలమైన / నిర్భయమైన',
          kannadaMeaning: 'ಅಚಲ / ಹೆದರದ',
          exampleSentence: 'She offered unflinching testimony before the constitutional bench.',
          phonetic: '/ʌnˈflɪn.tʃɪŋ/',
        ),
        DailyVocabItem(
          word: 'Triad',
          partOfSpeech: 'noun',
          definition: 'A group or set of three closely related elements.',
          malayalamMeaning: 'ത്രിത്വം / മൂന്നംഗക്കൂട്ടം',
          tamilMeaning: 'மூவர் கூட்டணி / மூவகை',
          hindiMeaning: 'त्रिमूर्ति / त्रिक',
          teluguMeaning: 'త్రిమూర్తి / మూడింటి సముదాయం',
          kannadaMeaning: 'ಮೂರರ ಗುಂಪು / ತ್ರಿವಳಿ',
          exampleSentence: 'Orators use the rhetorical triad: truth, clarity, and decisive action.',
          phonetic: '/ˈtraɪ.æd/',
        ),
        DailyVocabItem(
          word: 'Resonance',
          partOfSpeech: 'noun',
          definition: 'The quality in a sound or idea of being deep, full, and reverberating.',
          malayalamMeaning: 'അനുരണനം / പ്രതിധ്വനി',
          tamilMeaning: 'எதிரொலி / ஆழ்ந்த தாக்கம்',
          hindiMeaning: 'गूंज / गहरा प्रभाव',
          teluguMeaning: 'ప్రతిధ్వని / గాఢ ప్రభావం',
          kannadaMeaning: 'ಪ್ರತಿಧ್ವನಿ / ಆಳವಾದ ಪ್ರಭಾವ',
          exampleSentence: 'Her closing remarks achieved timeless emotional resonance.',
          phonetic: '/ˈrez.ən.əns/',
        ),
      ];
      return;
    }

    if (widget.day == 16) {
      // 10 high-impact vocabulary words for Day 16 (Cleft Sentences & Oratorical Focus)
      _vocabList = const [
        DailyVocabItem(
          word: 'Pivotal',
          partOfSpeech: 'adjective',
          definition: 'Of crucial importance in relation to the development or outcome of something.',
          malayalamMeaning: 'സുപ്രധാനമായ / നിർണ്ണായകമായ',
          tamilMeaning: 'முக்கியமான / திருப்புமுனையான',
          hindiMeaning: 'निर्णायक / आधारभूत',
          teluguMeaning: 'కీలకమైన',
          kannadaMeaning: 'ಪ್ರಮುಖ / ತಿರುವು ನೀಡುವ',
          exampleSentence: 'It was her pivotal intervention that restored parliamentary order.',
          phonetic: '/ˈpɪv.ə.təl/',
        ),
        DailyVocabItem(
          word: 'Catalyst',
          partOfSpeech: 'noun',
          definition: 'A person or event that precipitates significant change or action.',
          malayalamMeaning: 'ഉൽപ്രേരകം / മാറ്റത്തിനു കാരണമാകുന്ന ഘടകം',
          tamilMeaning: 'மாற்றத்தை தூண்டும் காரணி',
          hindiMeaning: 'उत्प्रेरक / बदलाव लाने वाला',
          teluguMeaning: 'ఉత్ప్రేరకం',
          kannadaMeaning: 'ಉತ್ಪ್ರೇರಕ',
          exampleSentence: 'What served as the true catalyst was public accountability.',
          phonetic: '/ˈkæt.əl.ɪst/',
        ),
        DailyVocabItem(
          word: 'Oratorical',
          partOfSpeech: 'adjective',
          definition: 'Relating to the art, practice, or style of public speaking.',
          malayalamMeaning: 'പ്രസംഗകലപരമായ / വാഗ്മിത്വമുള്ള',
          tamilMeaning: 'பேச்சாற்றல் சார்ந்த',
          hindiMeaning: 'वक्तृत्व संबंधी / भाषण कला',
          teluguMeaning: 'ఉపన్యాస కళకు చెందిన',
          kannadaMeaning: 'ಭಾಷಣ ಕಲೆಗೆ ಸಂಬಂಧಿಸಿದ',
          exampleSentence: 'Cleft sentences elevate oratorical speeches above ordinary chatter.',
          phonetic: '/ˌɒr.əˈtɒr.ɪ.kəl/',
        ),
        DailyVocabItem(
          word: 'Scrutiny',
          partOfSpeech: 'noun',
          definition: 'Critical observation or examination.',
          malayalamMeaning: 'സൂക്ഷ്മപരിശോധന',
          tamilMeaning: 'கூர்ந்து ஆராய்தல்',
          hindiMeaning: 'गहन जांच / सूक्ष्म निरीक्षण',
          teluguMeaning: 'సూక్ష్మ పరిశీలన',
          kannadaMeaning: 'ಸೂಕ್ಷ್ಮ ಪರಿಶೀಲನೆ',
          exampleSentence: 'It is under rigorous scrutiny that flawed policies crumble.',
          phonetic: '/ˈskruː.tɪ.ni/',
        ),
        DailyVocabItem(
          word: 'Salient',
          partOfSpeech: 'adjective',
          definition: 'Most noticeable, prominent, or important.',
          malayalamMeaning: 'പ്രധാനപ്പെട്ട / തെളിഞ്ഞുനിൽക്കുന്ന',
          tamilMeaning: 'முக்கியமான / வெளிப்படையான',
          hindiMeaning: 'प्रमुख / मुख्य',
          teluguMeaning: 'ప్రముఖమైన',
          kannadaMeaning: 'ಪ್ರಮುಖವಾದ',
          exampleSentence: 'What remains salient is our commitment to grid modernization.',
          phonetic: '/ˈseɪ.li.ənt/',
        ),
        DailyVocabItem(
          word: 'Elucidate',
          partOfSpeech: 'verb',
          definition: 'Make something clear; explain thoroughly.',
          malayalamMeaning: 'വ്യക്തമാക്കുക / വിശദീകരിക്കുക',
          tamilMeaning: 'தெளிவுபடுத்துதல் / விளக்குதல்',
          hindiMeaning: 'स्पष्ट करना / व्याख्या करना',
          teluguMeaning: 'స్పష్టం చేయు / వివరించు',
          kannadaMeaning: 'ಸ್ಪಷ್ಟಪಡಿಸು / ವಿವರಿಸು',
          exampleSentence: 'It was the engineer who elucidated the cascading transformer failure.',
          phonetic: '/ɪˈluː.sɪ.deɪt/',
        ),
        DailyVocabItem(
          word: 'Paradox',
          partOfSpeech: 'noun',
          definition: 'A statement that seems self-contradictory but in reality expresses a possible truth.',
          malayalamMeaning: 'വിരോധാഭാസം',
          tamilMeaning: 'முரண்போலி / முரண்பாடு',
          hindiMeaning: 'विरोधाभास',
          teluguMeaning: 'విరోధాభాసం',
          kannadaMeaning: 'ವಿರೋಧಾಭಾಸ',
          exampleSentence: 'It is a strange paradox that simpler words wield greater force.',
          phonetic: '/ˈpær.ə.dɒks/',
        ),
        DailyVocabItem(
          word: 'Resilience',
          partOfSpeech: 'noun',
          definition: 'The capacity to withstand or recover quickly from difficult conditions.',
          malayalamMeaning: 'പ്രതിരോധശേഷി / അതിജീവനക്കരുത്ത്',
          tamilMeaning: 'மீண்டெழும் திறன்',
          hindiMeaning: 'लचीलापन / प्रतिरोधक क्षमता',
          teluguMeaning: 'స్థితిస్థాపకత / పుంజుకునే శక్తి',
          kannadaMeaning: 'ಚೇತರಿಸಿಕೊಳ್ಳುವ ಶಕ್ತಿ',
          exampleSentence: 'What saved the city was the enduring resilience of its citizenry.',
          phonetic: '/rɪˈzɪl.jəns/',
        ),
        DailyVocabItem(
          word: 'Impervious',
          partOfSpeech: 'adjective',
          definition: 'Unable to be affected or influenced by criticism or harm.',
          malayalamMeaning: 'ബാധിക്കപ്പെടാത്ത / അടിയറവു പറയാത്ത',
          tamilMeaning: 'பாதிக்கப்படாத',
          hindiMeaning: 'अभैद्य / अप्रभावित',
          teluguMeaning: 'ప్రభావితం కాని',
          kannadaMeaning: 'ಅಭೇದ್ಯ / ಪ್ರಭಾವಕ್ಕೆ ಒಳಗಾಗದ',
          exampleSentence: 'The bedrock foundation proved impervious to seasonal tremors.',
          phonetic: '/ɪmˈpɜː.vi.əs/',
        ),
        DailyVocabItem(
          word: 'Vindication',
          partOfSpeech: 'noun',
          definition: 'Proof that someone or something is right, reasonable, or justified.',
          malayalamMeaning: 'സാധൂകരണം / നീതീകരണം',
          tamilMeaning: 'நிரூபணம் / நியாயப்படுத்தல்',
          hindiMeaning: 'पुष्टि / दोषमुक्ति',
          teluguMeaning: 'సమర్థన / నిరూపణ',
          kannadaMeaning: 'ಸಮರ್ಥನೆ / ದೋಷಮುಕ್ತಿ',
          exampleSentence: 'It was historical vindication that the banished scientist received.',
          phonetic: '/ˌvɪn.dɪˈkeɪ.ʃən/',
        ),
      ];
      return;
    }

    if (widget.day == 15) {
      // 10 high-impact vocabulary words for Day 15 (Conversational Register & Diplomatic Softeners)
      _vocabList = const [
        DailyVocabItem(
          word: 'Nuance',
          partOfSpeech: 'noun',
          definition: 'A subtle distinction or variation in meaning, expression, or tone.',
          malayalamMeaning: 'സൂക്ഷ്മഭേദം / അർത്ഥവ്യത്യാസം',
          tamilMeaning: 'நுட்பமான வேறுபாடு',
          hindiMeaning: 'सूक्ष्म भेद / बारीकी',
          teluguMeaning: 'సూక్ష్మ భేదం',
          kannadaMeaning: 'ಸೂಕ್ಷ್ಮ ವ್ಯತ್ಯಾಸ',
          exampleSentence: 'Mastering conversational register requires grasping linguistic nuance.',
          phonetic: '/ˈnjuː.ɑːns/',
        ),
        DailyVocabItem(
          word: 'Diplomatic',
          partOfSpeech: 'adjective',
          definition: 'Having or showing an ability to deal with people tactfully and sensitively.',
          malayalamMeaning: 'നയതന്ത്രപരമായ / വിവേകപൂർവ്വമായ',
          tamilMeaning: 'சமரச உணர்வுள்ள / ராஜதந்திர',
          hindiMeaning: 'कूटनीतिक / विनम्र',
          teluguMeaning: 'దౌత్యపరమైన',
          kannadaMeaning: 'ರಾಜತಾಂತ್ರಿಕ',
          exampleSentence: 'Her diplomatic reply eased the tension in the boardroom.',
          phonetic: '/ˌdɪp.ləˈmæt.ɪk/',
        ),
        DailyVocabItem(
          word: 'Hedging',
          partOfSpeech: 'noun',
          definition: 'The use of cautious, softening language to avoid direct assertion or offense.',
          malayalamMeaning: 'മയപ്പെടുത്തിയ ഭാഷാപ്രയോഗം',
          tamilMeaning: 'எச்சரிக்கையான நயவுரை',
          hindiMeaning: 'सतर्क भाषा-प्रयोग',
          teluguMeaning: 'హెడ్జింగ్ / మృదువైన వ్యక్తీకరణ',
          kannadaMeaning: 'ಎಚ್ಚರಿಕೆಯ ಭಾಷಾಪ್ರಯೋಗ',
          exampleSentence: 'Using modal verbs is an effective hedging strategy in British English.',
          phonetic: '/ˈhedʒ.ɪŋ/',
        ),
        DailyVocabItem(
          word: 'Tactful',
          partOfSpeech: 'adjective',
          definition: 'Showing sensitivity and skill in dealing with others or difficult issues.',
          malayalamMeaning: 'കൗശലപൂർവ്വമായ / സമയോചിതമായ',
          tamilMeaning: 'சாமர்த்தியமான / கனிவான',
          hindiMeaning: 'विनम्र / कुशल',
          teluguMeaning: 'సమయస్ఫూర్తిగల',
          kannadaMeaning: 'ಚತುರ / ಜಾಣ್ಮೆಯ',
          exampleSentence: 'A tactful question opens doors that aggressive demands shut.',
          phonetic: '/ˈtækt.fəl/',
        ),
        DailyVocabItem(
          word: 'Equivocal',
          partOfSpeech: 'adjective',
          definition: 'Open to more than one interpretation; deliberately ambiguous.',
          malayalamMeaning: 'വ്യക്തതയില്ലാത്ത / ഇരുതലവാചകമായ',
          tamilMeaning: 'இருபொருள் படத்தக்க',
          hindiMeaning: 'அस्पष्ट / संदिग्ध',
          teluguMeaning: 'సందిగ్ధమైన',
          kannadaMeaning: 'ಸಂದಿಗ್ಧವಾದ',
          exampleSentence: 'Diplomats sometimes prefer equivocal phrasing during early talks.',
          phonetic: '/ɪˈkwɪv.ə.kəl/',
        ),
        DailyVocabItem(
          word: 'Concur',
          partOfSpeech: 'verb',
          definition: 'Be of the same opinion; agree.',
          malayalamMeaning: 'യോജിക്കുക / സമ്മതിക്കുക',
          tamilMeaning: 'ஒப்புக்கொள்ளுதல் / உடன்படுதல்',
          hindiMeaning: 'सहमत होना',
          teluguMeaning: 'ఏకీభవించు',
          kannadaMeaning: 'ಒಪ್ಪಿಕೊ / ಸಮ್ಮತಿಸು',
          exampleSentence: 'I respectfully concur with your strategic evaluation.',
          phonetic: '/kənˈkɜːr/',
        ),
        DailyVocabItem(
          word: 'Pragmatic',
          partOfSpeech: 'adjective',
          definition: 'Dealing with matters sensibly and realistically based on practical considerations.',
          malayalamMeaning: 'പ്രായോഗികമായ / അനുഭവവേദ്യമായ',
          tamilMeaning: 'நடைமுறைக்குரிய / எதார்த்தமான',
          hindiMeaning: 'व्यावहारिक / यथार्थवादी',
          teluguMeaning: 'ఆచరణాత్మక',
          kannadaMeaning: 'ಪ್ರಾಯೋಗಿಕ',
          exampleSentence: 'We chose a pragmatic compromise to preserve goodwill.',
          phonetic: '/præɡˈmæt.ɪk/',
        ),
        DailyVocabItem(
          word: 'Deference',
          partOfSpeech: 'noun',
          definition: 'Polite submission and respectful regard shown to another.',
          malayalamMeaning: 'ആദരവ് / ബഹുമാനപൂർവ്വമായ വണക്കം',
          tamilMeaning: 'மரியாதை / அடிபணிவு',
          hindiMeaning: 'सम्मान / आदरभाव',
          teluguMeaning: 'గౌరవభావం',
          kannadaMeaning: 'ಗೌರವ / ಆದರ',
          exampleSentence: 'The junior delegate spoke with consummate deference to the elder statesman.',
          phonetic: '/ˈdef.ər.əns/',
        ),
        DailyVocabItem(
          word: 'Circumspect',
          partOfSpeech: 'adjective',
          definition: 'Wary and cautious; unwilling to take unnecessary conversational risks.',
          malayalamMeaning: 'ജാഗ്രതയുള്ള / കരുതലോടെയുള്ള',
          tamilMeaning: 'எச்சரிக்கையான / விழிப்புடைய',
          hindiMeaning: 'सावधान / सतर्क',
          teluguMeaning: 'జాగరూకత గల',
          kannadaMeaning: 'ಎಚ್ಚರಿಕೆಯುಳ್ಳ',
          exampleSentence: 'In tense negotiations, circumspect phrasing prevents diplomatic fallout.',
          phonetic: '/ˈsɜː.kəm.spekt/',
        ),
        DailyVocabItem(
          word: 'Cordially',
          partOfSpeech: 'adverb',
          definition: 'In a warm, friendly, and courteous manner.',
          malayalamMeaning: 'ഹൃദ്യമായി / സ്നേഹപൂർവ്വം',
          tamilMeaning: 'அன்புடன் / கனிவுடன்',
          hindiMeaning: 'सौहार्दपूर्वक / प्रेमपूर्वक',
          teluguMeaning: 'ఆప్యాయంగా / హృదయపూర్వకంగా',
          kannadaMeaning: 'ಆತ್ಮೀಯವಾಗಿ / ಸೌಹಾರ್ದಯುತವಾಗಿ',
          exampleSentence: 'We cordially invite your delegation to review our amendments.',
          phonetic: '/ˈkɔː.di.ə.li/',
        ),
      ];
      return;
    }

    if (widget.day == 14) {
      // 10 high-impact vocabulary words for Day 14 (Forensic Persuasion, Rhetoric & Multilateral Accords)
      _vocabList = const [
        DailyVocabItem(
          word: 'Rhetoric',
          partOfSpeech: 'noun',
          definition: 'The art of effective or persuasive speaking or writing.',
          malayalamMeaning: 'വാഗ്മിത്വം / വാക്ചാതുര്യം',
          tamilMeaning: 'சொல்வன்மை / சொல்லாற்றல்',
          hindiMeaning: 'वाक्पटुता / प्रभावकारी वक्तृत्व',
          teluguMeaning: 'వాక్చాతుర్యం / ఉపన్యాస కళ',
          kannadaMeaning: 'ವಾಕ್ಚಾತುರ್ಯ / ಭಾಷಣ ಕಲೆ',
          exampleSentence: 'Masterful rhetoric aligns divergent factions toward a noble common goal.',
          phonetic: '/ˈret.ər.ɪk/',
        ),
        DailyVocabItem(
          word: 'Acumen',
          partOfSpeech: 'noun',
          definition: 'The ability to make good judgements and take quick, accurate decisions.',
          malayalamMeaning: 'തീക്ഷ്ണബുദ്ധി / വിവേചനപാടവം',
          tamilMeaning: 'நுட்பமான மதிநுட்பம் / கூர்மை',
          hindiMeaning: 'कुशाग्रता / निर्णय क्षमता',
          teluguMeaning: 'సమయస్ఫూర్తి / తీక్షణ ప్రతిభ',
          kannadaMeaning: 'ಕುಶಾಗ್ರಮತಿ / ಚಾಣಾಕ್ಷತೆ',
          exampleSentence: 'Her diplomatic acumen prevented an imminent international breakdown.',
          phonetic: '/ˈæk.jə.mən/',
        ),
        DailyVocabItem(
          word: 'Multilateral',
          partOfSpeech: 'adjective',
          definition: 'Agreed upon or participated in by three or more parties or sovereign nations.',
          malayalamMeaning: 'ബഹുമുഖമായ / പല കക്ഷികൾ ചേർന്ന',
          tamilMeaning: 'பலதரப்பு உடன்படிக்கை சார்ந்த',
          hindiMeaning: 'बहुपक्षीय',
          teluguMeaning: 'బహుపాక్షిక',
          kannadaMeaning: 'ಬಹುಪಕ್ಷೀಯ',
          exampleSentence: 'The multilateral accord unified ninety nations in maritime protection.',
          phonetic: '/ˌmʌl.tiˈlæt.ər.əl/',
        ),
        DailyVocabItem(
          word: 'Concomitant',
          partOfSpeech: 'adjective',
          definition: 'Naturally accompanying or associated with something.',
          malayalamMeaning: 'അനുബന്ധമായ / കൂടെയുണ്ടാകുന്ന',
          tamilMeaning: 'தொடர்ந்து உடன் நிகழும்',
          hindiMeaning: 'सहगामी / सहवर्ती',
          teluguMeaning: 'సహజంగా తోడుండే',
          kannadaMeaning: 'ಜೊತೆಯಾಗಿ ಬರುವ',
          exampleSentence: 'Great executive influence carries concomitant moral responsibilities.',
          phonetic: '/kənˈkɒm.ɪ.tənt/',
        ),
        DailyVocabItem(
          word: 'Impasse',
          partOfSpeech: 'noun',
          definition: 'A situation in which no progress is possible, especially due to disagreement.',
          malayalamMeaning: 'സ്തംഭനാവസ്ഥ / വഴിമുട്ടിയ അവസ്ഥ',
          tamilMeaning: 'முட்டுக்கட்டை / முன்னேற முடியாத நிலை',
          hindiMeaning: 'गतिरोध / बंद गली',
          teluguMeaning: 'ప్రతిష్టంభన / అడ్డంకి',
          kannadaMeaning: 'ಬಿಕ್ಕಟ್ಟು / ಮುಗ್ಗಟ್ಟು',
          exampleSentence: 'Creative compromise broke the three-day diplomatic impasse in Geneva.',
          phonetic: '/ˈæm.pɑːs/',
        ),
        DailyVocabItem(
          word: 'Solicitous',
          partOfSpeech: 'adjective',
          definition: 'Characterized by showing sincere interest, care, or concern for others.',
          malayalamMeaning: 'ശ്രദ്ധാലുവായ / കരുതലുള്ള',
          tamilMeaning: 'அக்கறையுள்ள / பரிவுள்ள',
          hindiMeaning: 'चिंतित / हितैषी / परवाह करने वाला',
          teluguMeaning: 'శ్రద్ధాసక్తులు గల / సంరక్షించే',
          kannadaMeaning: 'ಕಾಳಜಿಯುಳ್ಳ / ಹಿತೈಷಿ',
          exampleSentence: 'A solicitous leader addresses the legitimate grievances of every citizen.',
          phonetic: '/səˈlɪs.ɪ.təs/',
        ),
        DailyVocabItem(
          word: 'Efficacy',
          partOfSpeech: 'noun',
          definition: 'The ability to produce a desired or intended result; effectiveness.',
          malayalamMeaning: 'ഫലപ്രാപ്തി / കാര്യക്ഷമത',
          tamilMeaning: 'செயல்திறன் / பலன் தரும் தன்மை',
          hindiMeaning: 'प्रभावोत्पादकता / प्रभावकारिता',
          teluguMeaning: 'ఫలిత సామర్థ్యం / కార్యాచరణ',
          kannadaMeaning: 'ಪರಿಣಾಮಕಾರಿತ್ವ / ಸಾಮರ್ಥ್ಯ',
          exampleSentence: 'The clinical efficacy of the protocol was established across three trials.',
          phonetic: '/ˈef.ɪ.kə.si/',
        ),
        DailyVocabItem(
          word: 'Recalcitrant',
          partOfSpeech: 'adjective',
          definition: 'Having an obstinately uncooperative attitude toward authority or consensus.',
          malayalamMeaning: 'വാശിയുള്ള / വഴങ്ങാത്ത',
          tamilMeaning: 'அடங்காத / வழிக்கு வராத',
          hindiMeaning: 'हठी / आज्ञा न मानने वाला',
          teluguMeaning: 'మొండిపట్టుదలగల / లొంగని',
          kannadaMeaning: 'ಹಟಮಾರಿ / ಒಪ್ಪಿಕೊಳ್ಳದ',
          exampleSentence: 'Lyra\'s eloquence swayed even the most recalcitrant ministers.',
          phonetic: '/rɪˈkæl.sɪ.trənt/',
        ),
        DailyVocabItem(
          word: 'Consensus',
          partOfSpeech: 'noun',
          definition: 'A general agreement among a group of people.',
          malayalamMeaning: 'സർവ്വ സമ്മതം / സമവായം',
          tamilMeaning: 'ஒருமித்த கருத்து / பொது இணக்கம்',
          hindiMeaning: 'सर्वसम्मति / आम सहमति',
          teluguMeaning: 'ఏకాభిప్రాయం',
          kannadaMeaning: 'ಸರ್ವಸಮ್ಮತಿ / ಒಮ್ಮತ',
          exampleSentence: 'Building consensus requires deep listening alongside persuasive speech.',
          phonetic: '/kənˈsen.səs/',
        ),
        DailyVocabItem(
          word: 'Sovereignty',
          partOfSpeech: 'noun',
          definition: 'Supreme power or authority of a state to govern itself.',
          malayalamMeaning: 'പരമാധികാരം',
          tamilMeaning: 'இறையாண்மை',
          hindiMeaning: 'संप्रभुता / सार्वभौमिकता',
          teluguMeaning: 'సార్వభౌమాధికారం',
          kannadaMeaning: 'ಸಾರ್ವಭೌಮತ್ವ',
          exampleSentence: 'The treaty firmly safeguarded the national sovereignty of each republic.',
          phonetic: '/ˈsɒv.rən.ti/',
        ),
      ];
      return;
    }

    if (widget.day == 13) {
      // 10 high-impact vocabulary words for Day 13 (Scientific Empiricism & Epistemic Inquiry)
      _vocabList = const [
        DailyVocabItem(
          word: 'Epistemological',
          partOfSpeech: 'adjective',
          definition: 'Relating to the theory of knowledge, its validity and methods.',
          malayalamMeaning: 'ജ്ഞാനശാസ്ത്രപരമായ',
          tamilMeaning: 'அறிவாராய்ச்சியியல் சார்ந்த',
          hindiMeaning: 'ज्ञानमीमांसीय / ज्ञान-सिद्धांत संबंधी',
          teluguMeaning: 'జ్ఞానమీమాంసకు సంబంధించిన',
          kannadaMeaning: 'ಜ್ಞಾನಮೀಮಾಂಸೆಯ',
          exampleSentence: 'The discovery triggered a deep epistemological shift across neuroscience.',
          phonetic: '/ɪˌpɪs.tə.məˈlɒdʒ.ɪ.kəl/',
        ),
        DailyVocabItem(
          word: 'Paradigm',
          partOfSpeech: 'noun',
          definition: 'A typical pattern, framework, or model of thought.',
          malayalamMeaning: 'മാതൃക / ചിന്താപദ്ധതി',
          tamilMeaning: 'சிந்தனை கட்டமைப்பு / மாதிரி',
          hindiMeaning: 'प्रतिमान / वैचारिक ढांचा',
          teluguMeaning: 'ఆదర్శ నమూనా / ఆలోచనా విధానం',
          kannadaMeaning: 'ಚಿಂತನೆಯ ಚೌಕಟ್ಟು / ಮಾದರಿ',
          exampleSentence: 'Quantum computing introduces a revolutionary paradigm to computation.',
          phonetic: '/ˈpær.ə.daɪm/',
        ),
        DailyVocabItem(
          word: 'Empiricism',
          partOfSpeech: 'noun',
          definition: 'The theory that all knowledge is derived from sense-experience and evidence.',
          malayalamMeaning: 'പ്രത്യക്ഷാനുഭവവാദം',
          tamilMeaning: 'அனுபவவாத உண்மை / ஆய்வு நெறி',
          hindiMeaning: 'अनुभववाद / प्रयोगमूलक प्रमाण',
          teluguMeaning: 'అనుభవవాదం / ప్రయోగాధారిత జ్ఞానం',
          kannadaMeaning: 'ಅನುಭವಜನ್ಯ ಸಿದ್ಧಾಂತ',
          exampleSentence: 'Scientific progress relies upon unyielding empiricism rather than superstition.',
          phonetic: '/ɪmˈpɪr.ɪ.sɪ.zəm/',
        ),
        DailyVocabItem(
          word: 'Corroborate',
          partOfSpeech: 'verb',
          definition: 'Confirm or give support to a statement, theory, or finding.',
          malayalamMeaning: 'സ്ഥിരീകരിക്കുക / തെളിവുനൽകി ഉറപ്പിക്കുക',
          tamilMeaning: 'உறுதிப்படுத்துதல் / சான்றுடன் மெய்ப்பித்தல்',
          hindiMeaning: 'पुष्टि करना / समर्थन देना',
          teluguMeaning: 'ధృవీకరించు / సమర్థించు',
          kannadaMeaning: 'ದೃಢೀಕರಿಸು / ಸಾಕ್ಷ್ಯಾಧಾರ ನೀಡು',
          exampleSentence: 'Subsequent independent trials corroborated Dr. Elena\'s radical thesis.',
          phonetic: '/kəˈrɒb.ə.reɪt/',
        ),
        DailyVocabItem(
          word: 'Incongruous',
          partOfSpeech: 'adjective',
          definition: 'Not in harmony or keeping with the surroundings or other aspects.',
          malayalamMeaning: 'പൊരുത്തമില്ലാത്ത / ചേർച്ചയില്ലാത്ത',
          tamilMeaning: 'பொருத்தமற்ற / முரண்பாடான',
          hindiMeaning: 'बेमेल / असंगत',
          teluguMeaning: 'పొంతనలేని / అసంగతమైన',
          kannadaMeaning: 'ಹೊಂದಿಕೆಯಾಗದ / ಅಸಂಗತ',
          exampleSentence: 'The anomalous data point seemed incongruous alongside classical models.',
          phonetic: '/ɪnˈkɒŋ.ɡru.əs/',
        ),
        DailyVocabItem(
          word: 'Juxtaposition',
          partOfSpeech: 'noun',
          definition: 'The fact of two things being placed close together with contrasting effect.',
          malayalamMeaning: 'താരതമ്യപ്പെടുത്തൽ / അടുത്തടുത്തുള്ള വെയ്ക്കൽ',
          tamilMeaning: 'முரண்களை ஒப்பிட்டு நோக்குதல்',
          hindiMeaning: 'तुलनात्मक सन्निकटता / विषमता दर्शाना',
          teluguMeaning: 'పోలిక కోసం పక్కపక్కన ఉంచడం',
          kannadaMeaning: 'ವ್ಯತ್ಯಾಸ ತೋರಲು ಅಕ್ಕಪಕ್ಕ ಇಡುವುದು',
          exampleSentence: 'The juxtaposition of ancient traditions and cybernetic tools was striking.',
          phonetic: '/ˌdʒʌk.stə.pəˈzɪʃ.ən/',
        ),
        DailyVocabItem(
          word: 'Anomaly',
          partOfSpeech: 'noun',
          definition: 'Something that deviates from what is standard, normal, or expected.',
          malayalamMeaning: 'അസ്വാഭാവികത / വ്യതിയാനം',
          tamilMeaning: 'வழக்கத்திற்கு மாறான நிகழ்வு',
          hindiMeaning: 'विसंगति / अनियमिता',
          teluguMeaning: 'అసాధారణ వైపరీత్యం',
          kannadaMeaning: 'ಅಸಹಜತೆ / ವಿಪರ್ಯಾಸ',
          exampleSentence: 'Investigating the gravitational anomaly led to the new physics breakthrough.',
          phonetic: '/əˈnɒm.ə.li/',
        ),
        DailyVocabItem(
          word: 'Lucid',
          partOfSpeech: 'adjective',
          definition: 'Expressed clearly; easy to understand; showing clear thought.',
          malayalamMeaning: 'വ്യക്തമായ / തെളിഞ്ഞ',
          tamilMeaning: 'தெளிவான / எளிதில் விளங்கும்',
          hindiMeaning: 'स्पष्ट / सुबोध',
          teluguMeaning: 'స్పష్టమైన / సులభగ్రాహ్య',
          kannadaMeaning: 'ಸ್ಪಷ್ಟವಾದ / ಸರಳ ತಿಳುವಳಿಕೆಯ',
          exampleSentence: 'Her lucid presentation made the intricate quantum formula crystal clear.',
          phonetic: '/ˈluː.sɪd/',
        ),
        DailyVocabItem(
          word: 'Disquisition',
          partOfSpeech: 'noun',
          definition: 'A long or elaborate essay or discussion on a particular subject.',
          malayalamMeaning: 'വിശദമായ പ്രബന്ധം / ശാസ്ത്രീയ ചർച്ച',
          tamilMeaning: 'ஆழ்ந்த விரிவுரை / விரிவான ஆய்வுக்கட்டுரை',
          hindiMeaning: 'गंभीर शोध प्रबंध / विस्तृत व्याख्या',
          teluguMeaning: 'విస్తృత పరిశోధనా వ్యాసం',
          kannadaMeaning: 'ವಿಸ್ತಾರವಾದ ಪ್ರಬಂಧ / ಗಂಭೀರ ಚರ್ಚೆ',
          exampleSentence: 'The professor published an authoritative disquisition on epistemic truth.',
          phonetic: '/ˌdɪs.kwɪˈzɪʃ.ən/',
        ),
        DailyVocabItem(
          word: 'Vindicate',
          partOfSpeech: 'verb',
          definition: 'Clear someone of blame or show/prove to be right and justified.',
          malayalamMeaning: 'ന്യായീകരിക്കുക / കുറ്റവിമുക്തനാക്കുക',
          tamilMeaning: 'நிரூபித்து நியாயப்படுத்துதல்',
          hindiMeaning: 'सही साबित करना / दोषमुक्त करना',
          teluguMeaning: 'సరైనదని నిరూపించు / నిర్దోషిగా తేల్చు',
          kannadaMeaning: 'ಸರಿಯೆಂದು ಸಾಬೀತುಪಡಿಸು',
          exampleSentence: 'Years of patient experimentation vindicated her disputed findings.',
          phonetic: '/ˈvɪn.dɪ.keɪt/',
        ),
      ];
      return;
    }

    if (widget.day == 12) {
      // 10 high-impact vocabulary words for Day 12 (Debate, Sophistry Dissection & Perspicacity)
      _vocabList = const [
        DailyVocabItem(
          word: 'Specious',
          partOfSpeech: 'adjective',
          definition: 'Superficially plausible, but actually wrong or deceptive.',
          malayalamMeaning: 'ബാഹ്യമായി ശരിയെന്നു തോന്നുന്ന എന്നാൽ തെറ്റായ',
          tamilMeaning: 'மேலோட்டமாக சரியெனத் தோன்றும் ஆனால் தவறான',
          hindiMeaning: 'दिखावटी / भ्रामक',
          teluguMeaning: 'పైకి నిజమనిపించే మోసపూరితమైన',
          kannadaMeaning: 'ಮೇಲ್ನೋಟಕ್ಕೆ ಸರಿ ಎನಿಸುವ ಆದರೆ ತಪ್ಪಾದ',
          exampleSentence: 'A master debater quickly dismantles specious arguments with hard facts.',
          phonetic: '/ˈspiː.ʃəs/',
        ),
        DailyVocabItem(
          word: 'Hegemony',
          partOfSpeech: 'noun',
          definition: 'Leadership or dominance, especially by one state or group over others.',
          malayalamMeaning: 'ആധിപത്യം / മേധാവിത്വം',
          tamilMeaning: 'மேலாதிக்கம் / தலைமைப்பீடம்',
          hindiMeaning: 'आधिपत्य / प्रभुत्व',
          teluguMeaning: 'ఆధిపత్యం / పెత్తనం',
          kannadaMeaning: 'ಮೇಲಾಧಿಪತ್ಯ / ಪ್ರಾಬಲ್ಯ',
          exampleSentence: 'The council challenged the corporate hegemony in global communications.',
          phonetic: '/hɪˈdʒem.ə.ni/',
        ),
        DailyVocabItem(
          word: 'Fallacious',
          partOfSpeech: 'adjective',
          definition: 'Based on a mistaken belief or unsound reasoning.',
          malayalamMeaning: 'യുക്തിരഹിതമായ / വഞ്ചനാപരമായ',
          tamilMeaning: 'தவறான தர்க்கம் கொண்ட',
          hindiMeaning: 'तर्कहीन / भ्रामक',
          teluguMeaning: 'తప్పుదోవ పట్టించే / దోషపూరిత',
          kannadaMeaning: 'ತರ್ಕಹೀನ / ದೋಷಯುಕ್ತ',
          exampleSentence: 'Rowan exposed the fallacious logic concealed within the draft motion.',
          phonetic: '/fəˈleɪ.ʃəs/',
        ),
        DailyVocabItem(
          word: 'Prevaricate',
          partOfSpeech: 'verb',
          definition: 'Speak or act in an evasive way in order to avoid telling the truth.',
          malayalamMeaning: 'വളച്ചൊടിച്ചു സംസാരിക്കുക / സത്യം മറച്ചുവെക്കുക',
          tamilMeaning: 'வார்த்தைகளை மாற்றிப் பேசுதல் / உண்மையை மறைத்தல்',
          hindiMeaning: 'टालमटोल करना / छल-कपट से बात घुमाना',
          teluguMeaning: 'దాటవేయు / మాటమార్చు',
          kannadaMeaning: 'ತಪ್ಪಿಸಿಕೊಳ್ಳುವಂತೆ ಮಾತನಾಡು / ವಿಷಯ ತಿರುಚು',
          exampleSentence: 'Instead of prevaricating under questioning, state your thesis directly.',
          phonetic: '/prɪˈvær.ɪ.keɪt/',
        ),
        DailyVocabItem(
          word: 'Equivocal',
          partOfSpeech: 'adjective',
          definition: 'Open to more than one interpretation; deliberately ambiguous.',
          malayalamMeaning: 'വ്യക്തതയില്ലാത്ത / രണ്ടർത്ഥമുള്ള',
          tamilMeaning: 'தெளிவற்ற / இருபொருள் தரும்',
          hindiMeaning: 'द्व्यर्थी / अस्पष्ट',
          teluguMeaning: 'ద్వంద్వార్థమిచ్చే / అస్పష్టమైన',
          kannadaMeaning: 'ದ್ವಂದ್ವಾರ್ಥದ / ಅಸ್ಪಷ್ಟ',
          exampleSentence: 'His equivocal response failed to reassure the international committee.',
          phonetic: '/ɪˈkwɪv.ə.kəl/',
        ),
        DailyVocabItem(
          word: 'Anathema',
          partOfSpeech: 'noun',
          definition: 'Something or someone vehemently disliked or completely opposed.',
          malayalamMeaning: 'പൂർണ്ണമായി എതിർക്കപ്പെടേണ്ട കാര്യം',
          tamilMeaning: 'முற்றிலும் வெறுக்கத்தக்க ஒன்று',
          hindiMeaning: 'अत्यंत घृणित / अभिशाप',
          teluguMeaning: 'తీవ్రంగా వ్యతిరేకించవలసినది',
          kannadaMeaning: 'ಅತ್ಯಂತ ಹೇಯವಾದದ್ದು',
          exampleSentence: 'Censorship of honest intellectual inquiry is anathema to free scholars.',
          phonetic: '/əˈnæθ.ə.mə/',
        ),
        DailyVocabItem(
          word: 'Pragmatic',
          partOfSpeech: 'adjective',
          definition: 'Dealing with things sensibly and realistically based on practical considerations.',
          malayalamMeaning: 'പ്രായോഗികമായ / അനുഭവവേദ്യമായ',
          tamilMeaning: 'நடைமுறைக்கு உகந்த / யதார்த்தமான',
          hindiMeaning: 'व्यावहारिक / यथार्थवादी',
          teluguMeaning: 'ఆచరణాత్మకమైన / వాస్తవిక',
          kannadaMeaning: 'ಪ್ರಾಯೋಗಿಕ / ವಾಸ್ತವಿಕ',
          exampleSentence: 'Diplomats require pragmatic solutions rather than rigid ideologies.',
          phonetic: '/præɡˈmæt.ɪk/',
        ),
        DailyVocabItem(
          word: 'Discomfit',
          partOfSpeech: 'verb',
          definition: 'Make someone feel uneasy, embarrassed, or confused in debate.',
          malayalamMeaning: 'പരുങ്ങലിലാക്കുക / ആശയക്കുഴപ്പത്തിലാക്കുക',
          tamilMeaning: 'சங்கடப்படுத்துதல் / குழப்பத்தில் ஆழ்த்துதல்',
          hindiMeaning: 'असमंजस में डालना / घबराना',
          teluguMeaning: 'ఇరకాటంలో పడేయు / తికమకపెట్టు',
          kannadaMeaning: 'ಇಕ್ಕಟ್ಟಿಗೆ ಸಿಲುಕಿಸು / ಕಸಿವಿಸಿಗೊಳಿಸು',
          exampleSentence: 'Sharp cross-examination discomfited the unprepared speaker.',
          phonetic: '/dɪsˈkʌm.fɪt/',
        ),
        DailyVocabItem(
          word: 'Perspicacity',
          partOfSpeech: 'noun',
          definition: 'The quality of having a ready insight into things; shrewd discernment.',
          malayalamMeaning: 'സൂക്ഷ്മബുദ്ധി / കാര്യഗ്രഹണശേഷി',
          tamilMeaning: 'கூர்மதி / நுண்ணறிவு',
          hindiMeaning: 'तीक्ष्ण बुद्धि / दूरदर्शिता',
          teluguMeaning: 'సూక్ష్మబుద్ధి / చురుకుదనం',
          kannadaMeaning: 'ತೀಕ್ಷ್ಣಮತಿ / ಸೂಕ್ಷ್ಮಗ್ರಹಿಕೆ',
          exampleSentence: 'Her perspicacity enabled her to foresee the economic crisis months ahead.',
          phonetic: '/ˌpɜː.spɪˈkæs.ə.ti/',
        ),
        DailyVocabItem(
          word: 'Concession',
          partOfSpeech: 'noun',
          definition: 'A thing that is granted, especially in response to demands.',
          malayalamMeaning: 'വിട്ടുവീഴ്ച / ഇളവ്',
          tamilMeaning: 'சமரசம் / விட்டுக்கொடுத்தல்',
          hindiMeaning: 'रियायत / समझौता',
          teluguMeaning: 'రాయితీ / సడలింపు',
          kannadaMeaning: 'ರಿಯಾಯಿತಿ / ಹೊಂದಾಣಿಕೆ',
          exampleSentence: 'Mutual concession is the fundamental cornerstone of every peace treaty.',
          phonetic: '/kənˈseʃ.ən/',
        ),
      ];
      return;
    }

    if (widget.day == 11) {
      // 10 high-impact vocabulary words for Day 11 (Linguistic Virtuosity & Cognitive Evolution)
      _vocabList = const [
        DailyVocabItem(
          word: 'Virtuosity',
          partOfSpeech: 'noun',
          definition: 'Great skill in music, speech, or another artistic pursuit.',
          malayalamMeaning: 'പ്രത്യേക പാടവം / വൈദഗ്ധ്യം',
          tamilMeaning: 'கைதேர்ந்த கலைத்திறன்',
          hindiMeaning: 'असाधारण प्रवीणता / कलात्मक कौशल',
          teluguMeaning: 'అద్భుత ప్రావీణ్యం',
          kannadaMeaning: 'ಅಸಾಧಾರಣ ಪಾಂಡಿತ್ಯ',
          exampleSentence: 'She commanded the podium with linguistic virtuosity and effortless charm.',
          phonetic: '/ˌvɜː.tʃuˈɒs.ə.ti/',
        ),
        DailyVocabItem(
          word: 'Metamorphosis',
          partOfSpeech: 'noun',
          definition: 'A change of the form or nature of a thing into a completely different one.',
          malayalamMeaning: 'രൂപാന്തരം / കാതലായ മാറ്റം',
          tamilMeaning: 'முழுமையான உருமாற்றம்',
          hindiMeaning: 'कायापलट / रूपांतरण',
          teluguMeaning: 'రూపాంతరం / సమూల మార్పు',
          kannadaMeaning: 'ಸಂಪೂರ್ಣ ರೂಪಾಂತರ',
          exampleSentence: 'Over 90 days, your speaking will undergo a radical metamorphosis.',
          phonetic: '/ˌmet.əˈmɔː.fə.sɪs/',
        ),
        DailyVocabItem(
          word: 'Inexorable',
          partOfSpeech: 'adjective',
          definition: 'Impossible to stop or prevent; relentlessly progressive.',
          malayalamMeaning: 'തടയാനാവാത്ത / അനിവാര്യമായ',
          tamilMeaning: 'தடுக்க முடியாத / தவிர்க்க இயலாத',
          hindiMeaning: 'अप्रतिरोध्य / जिसे रोका न जा सके',
          teluguMeaning: 'ఆపలేని / అనివార్యమైన',
          kannadaMeaning: 'ತಡೆಯಲಾಗದ / ಅನಿವಾರ್ಯ',
          exampleSentence: 'Consistent daily immersion produces an inexorable march toward fluency.',
          phonetic: '/ɪnˈek.sər.ə.bəl/',
        ),
        DailyVocabItem(
          word: 'Epiphany',
          partOfSpeech: 'noun',
          definition: 'A moment of sudden and profound revelation or realization.',
          malayalamMeaning: 'പെട്ടെന്നുണ്ടാകുന്ന ഉൾക്കാഴ്ച',
          tamilMeaning: 'திடீர் ஞானோதயம்',
          hindiMeaning: 'अचानक आत्मज्ञान / दिव्य दृष्टि',
          teluguMeaning: 'క్షణిక జ్ఞానోదయం',
          kannadaMeaning: 'ಕ್ಷಣಿಕ ಜ್ಞಾನೋದಯ',
          exampleSentence: 'His epiphany was that language is an extension of empathy.',
          phonetic: '/ɪˈpɪf.ən.i/',
        ),
        DailyVocabItem(
          word: 'Transcend',
          partOfSpeech: 'verb',
          definition: 'Be or go beyond the range or limits of something.',
          malayalamMeaning: 'പരിമിതികളെ അതിജീവിക്കുക',
          tamilMeaning: 'எல்லைகளைக் கடத்தல்',
          hindiMeaning: 'सीमाओं से परे जाना',
          teluguMeaning: 'పరిమితులను దాటిపోవు',
          kannadaMeaning: 'ಮಿತಿಗಳನ್ನು ಮೀರು',
          exampleSentence: 'Great literature allows human beings to transcend geographical borders.',
          phonetic: '/trænˈsend/',
        ),
        DailyVocabItem(
          word: 'Indomitable',
          partOfSpeech: 'adjective',
          definition: 'Impossible to subdue or defeat; brave and determined.',
          malayalamMeaning: 'അദമ്യമായ / തോൽപ്പിക്കാനാവാത്ത',
          tamilMeaning: 'வெல்ல முடியாத / அடக்க முடியாத',
          hindiMeaning: 'अदम्य / जिसे हराया न जा सके',
          teluguMeaning: 'లొంగని / అజేయమైన',
          kannadaMeaning: 'ಅದಮ್ಯ / ಸೋಲಿಸಲಾಗದ',
          exampleSentence: 'An indomitable spirit guarantees mastery in any global discipline.',
          phonetic: '/ɪnˈdɒm.ɪ.tə.bəl/',
        ),
        DailyVocabItem(
          word: 'Erudite',
          partOfSpeech: 'adjective',
          definition: 'Having or showing great knowledge or learning; scholarly.',
          malayalamMeaning: 'പണ്ഡിതോചിതമായ / അഗാധ ജ്ഞാനമുള്ള',
          tamilMeaning: 'கல்விச் செறிவுடைய / பாண்டித்தியம் மிக்க',
          hindiMeaning: 'विद्वत्तापूर्ण / ज्ञानी',
          teluguMeaning: 'విద్వత్సంపన్నమైన / విజ్ఞానవంతమైన',
          kannadaMeaning: 'ಪಾಂಡಿತ್ಯಪೂರ್ಣ / ಜ್ಞಾನಿ',
          exampleSentence: 'Her erudite lecture illuminated ancient linguistic evolution.',
          phonetic: '/ˈer.uː.daɪt/',
        ),
        DailyVocabItem(
          word: 'Quintessential',
          partOfSpeech: 'adjective',
          definition: 'Representing the most perfect or typical example of a quality or class.',
          malayalamMeaning: 'ഉത്തമോദാഹരണമായ',
          tamilMeaning: 'முழுமையான முன்மாதிரியான',
          hindiMeaning: 'सर्वोत्कृष्ट उदाहरण',
          teluguMeaning: 'సర్వోత్కృష్ట నిదర్శనమైన',
          kannadaMeaning: 'ಪರಿಪೂರ್ಣ ನಿದರ್ಶನವಾದ',
          exampleSentence: 'The speech was the quintessential blend of logic and emotion.',
          phonetic: '/ˌkwɪn.tɪˈsen.ʃəl/',
        ),
        DailyVocabItem(
          word: 'Perseverance',
          partOfSpeech: 'noun',
          definition: 'Persistence in doing something despite difficulty or delay in achieving success.',
          malayalamMeaning: 'സ്ഥിരോത്സാഹം / അക്ഷീണ പ്രയത്നം',
          tamilMeaning: 'விடாமுயற்சி / தளராத உழைப்பு',
          hindiMeaning: 'लगन / सतत प्रयास',
          teluguMeaning: 'పట్టుదల / అవిరళ కృషి',
          kannadaMeaning: 'ಅಚಲ ಪ್ರಯತ್ನ / ಛಲ',
          exampleSentence: 'Fluency is the natural reward of steady perseverance.',
          phonetic: '/ˌpɜː.sɪˈvɪə.rəns/',
        ),
        DailyVocabItem(
          word: 'Enlightened',
          partOfSpeech: 'adjective',
          definition: 'Having or showing a rational, modern, and well-informed outlook.',
          malayalamMeaning: 'പ്രബുദ്ധമായ / വിവേകമുള്ള',
          tamilMeaning: 'அறிவுக்கண் திறந்த / தெளிவடைந்த',
          hindiMeaning: 'प्रबुद्ध / विचारवान',
          teluguMeaning: 'ప్రబుద్ధ / జ్ఞానవంతమైన',
          kannadaMeaning: 'ಪ್ರಬುದ್ಧ / ವಿವೇಕಯುತ',
          exampleSentence: 'Enlightened communicators listen deeply before answering.',
          phonetic: '/ɪnˈlaɪ.tənd/',
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
      _dailyRuleCompleted = prefs.getBool('${dayKey}_daily_rule') ?? false;
      _hubChatVerified = prefs.getBool('${dayKey}_hub_chat') ?? false;
      _peerCallVerified = prefs.getBool('${dayKey}_peer_call') ?? false;
      _vocabMemorized = prefs.getBool('${dayKey}_vocab_mem') ?? false;
      _wordCatcherCompleted = prefs.getBool('${dayKey}_word_catcher') ?? false;
      _careerAdventureCompleted = prefs.getBool('${dayKey}_career_adventure') ?? _wordCatcherCompleted;
      _cityNavigatorCompleted = prefs.getBool('${dayKey}_city_navigator') ?? false;
      _readingNotesCompleted = prefs.getBool('${dayKey}_reading') ?? false;
      _codeEnglishCompleted = prefs.getBool('${dayKey}_code_english') ?? false;
      _revisionQuizPassed = prefs.getBool('${dayKey}_quiz') ?? false;
      _defenseTrapArmed = prefs.getBool('${dayKey}_defense') ?? false;
      _trialRaidLaunched = prefs.getBool('${dayKey}_raid') ?? false;
      _midAttackCompleted = prefs.getBool('${dayKey}_mid_attack') ?? false;
      _alphabetPhonicsCompleted = prefs.getBool('${dayKey}_alphabet_phonics') ?? false;
      _sentencePatternCompleted = prefs.getBool('${dayKey}_sentence_pattern') ?? false;
      _pronunciationCompleted = prefs.getBool('${dayKey}_pronunciation') ?? false;
      _englishThinkingCompleted = prefs.getBool('${dayKey}_english_thinking') ?? false;
      _speakingChallengeCompleted = prefs.getBool('${dayKey}_speaking_challenge') ?? false;
    });
  }

  Future<void> _saveSubtask(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    await prefs.setBool('${dayKey}_$key', value);
    final pts = _currentDayPoints;
    await prefs.setInt('${dayKey}_points', pts);

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid != null) {
      final oldBase = prefs.getInt('learning_points_$uid') ?? 0;
      await prefs.setInt('learning_points_$uid', oldBase > pts ? oldBase : pts);
    }
    if (mounted) setState(() {});
  }

  // 💬 Real Backend Verification for English Hub Chat in Supabase
  Future<void> _verifyEnglishHubChatWithBackend() async {
    final myId = SupaFlow.client.auth.currentUser?.id;
    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please sign in to verify your English Hub messages.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Verifying English Hub messages in Supabase...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1E293B),
      ),
    );

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

      // Query group_messages in Supabase for actual messages sent by this user today
      int serverCount = 0;
      try {
        final response = await SupaFlow.client
            .from('group_messages')
            .select('id')
            .eq('sender_id', myId)
            .gte('created_at', todayStart);
        serverCount = response.length;
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final localChatCount = prefs.getInt('english_hub_msgs_${myId}_${now.year}_${now.month}_${now.day}') ?? 0;
      final effectiveCount = math.max(serverCount, localChatCount);

      // User Audio Directive: "പത്തോ പതിനഞ്ചോ എന്നല്ല, 15 ഇംഗ്ലീഷ് മെസ്സേജസ് നിർബന്ധമായിട്ടും ചെയ്യണം. ഫസ്റ്റ് ഡേ വണ്ണിന്റെയാണ്."
      const int minRequiredMessages = 15;

      if (effectiveCount >= minRequiredMessages) {
        if (!mounted) return;
        setState(() => _hubChatVerified = true);
        _saveSubtask('hub_chat', true);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ English Hub Verified: $effectiveCount/15 English messages completed! (+25 PTS)'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!mounted) return;
        setState(() => _hubChatVerified = false);
        _saveSubtask('hub_chat', false);
        HapticFeedback.heavyImpact();
        final remaining = minRequiredMessages - effectiveCount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Only $effectiveCount/$minRequiredMessages English messages sent today. Send $remaining more messages in English Hub to complete!'),
            backgroundColor: const Color(0xFFB45309),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('English Hub verification error: $e');
    }
  }

  // 🎙️ Real Backend Verification for 1-on-1 Peer Calls in Supabase
  Future<void> _verifyPeerTalkWithBackend() async {
    final myId = SupaFlow.client.auth.currentUser?.id;
    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please sign in to verify peer conversation activity.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Verifying peer conversations in Supabase...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1E293B),
      ),
    );

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

      // Check messages table in Supabase for distinct peers messaged today
      int distinctServerPeers = 0;
      try {
        final response = await SupaFlow.client
            .from('messages')
            .select('receiver_id')
            .eq('sender_id', myId)
            .gte('created_at', todayStart);
        final distinctReceivers = response
            .map((m) => m['receiver_id']?.toString())
            .where((id) => id != null && id.isNotEmpty && id != myId)
            .toSet();
        distinctServerPeers = distinctReceivers.length;
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final todayChatKey = 'chat_goals_${myId}_${now.year}_${now.month}_${now.day}';
      final chatsCount = prefs.getInt(todayChatKey) ?? 0;
      final effectivePeers = math.max(distinctServerPeers, chatsCount);

      // User Audio Directive: "മിനിമം ഒരു മൂന്ന് ആളെ എങ്കിലും കണക്ട് ചെയ്യണം, തുടക്കത്തിൽ തന്നെ. എല്ലാ ദിവസവും മൂന്ന് ആളെ കണക്ട് ചെയ്യണം."
      const int minRequiredPeers = 3;

      if (effectivePeers >= minRequiredPeers) {
        if (!mounted) return;
        setState(() => _peerCallVerified = true);
        _saveSubtask('peer_call', true);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Peer Talk Verified: Connected with $effectivePeers/$minRequiredPeers mates today! (+25 PTS)'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!mounted) return;
        setState(() => _peerCallVerified = false);
        _saveSubtask('peer_call', false);
        HapticFeedback.heavyImpact();
        final remaining = minRequiredPeers - effectivePeers;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Connected with $effectivePeers/$minRequiredPeers mates today. Practice English with $remaining more mate(s) to complete!'),
            backgroundColor: const Color(0xFFB45309),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Peer talk verification error: $e');
    }
  }


  // 📖 Pocket Vocabulary Vault & Rewind Modal (Offline Local Storage)
  void _showPocketVocabularyModal() async {
    final savedWords = await PocketVocabularyService.instance.getSavedWords();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Color(0xFFFFFC00), width: 1.5)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('📖', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pocket Vocabulary Vault',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${savedWords.length} Offline Saved Words • Rewind Anytime',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFD700),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 20),
                if (savedWords.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'Your Pocket Vocabulary is Empty',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap "Save to Pocket Vocabulary" in Step 3 to store today\'s words on your device for offline review!',
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFC00),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final wordsMap = _vocabList.map((v) => v.toMap()).toList();
                                await PocketVocabularyService.instance.saveWords(widget.day, wordsMap);
                                final updated = await PocketVocabularyService.instance.getSavedWords();
                                setModalState(() {
                                  savedWords.clear();
                                  savedWords.addAll(updated);
                                });
                                setState(() {
                                  _vocabMemorized = true;
                                  _isPocketVocabSaved = true;
                                });
                                _saveSubtask('vocab_mem', true);
                              },
                              child: const Text('SAVE TODAY\'S 10 WORDS NOW'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: savedWords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final item = savedWords[idx];
                        final vocabItem = DailyVocabItem.fromMap(item);
                        final dayVal = item['day'] ?? widget.day;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('D$dayVal', style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          vocabItem.word,
                                          style: GoogleFonts.outfit(
                                            color: Colors.amberAccent,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          vocabItem.phonetic,
                                          style: GoogleFonts.inter(
                                            color: Colors.white54,
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${vocabItem.partOfSpeech})',
                                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '📖 ${vocabItem.definition}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '🗣️ Meaning ($_selectedLanguage): ${vocabItem.getMeaning(_selectedLanguage)}',
                                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.w600),
                                    ),
                                    if (vocabItem.exampleSentence.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '💡 "${vocabItem.exampleSentence}"',
                                        style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 20),
                                onPressed: () => _speakWord('${vocabItem.word}. ${vocabItem.exampleSentence}'),
                                tooltip: 'Listen',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool get _hasAlphabetPhonics => PocketMissionCurriculumRegistry.getAlphabetPhonics(widget.day).isNotEmpty;
  bool get _hasSentencePatterns => PocketMissionCurriculumRegistry.getSentencePatterns(widget.day).isNotEmpty;
  bool get _hasPronunciationClinic => PocketMissionCurriculumRegistry.getPronunciationClinic(widget.day).minimalPairs.isNotEmpty;
  bool get _hasEnglishThinking => PocketMissionCurriculumRegistry.getEnglishThinkingWorkout(widget.day).instantResponses.isNotEmpty;
  bool get _hasSpeakingChallenge => PocketMissionCurriculumRegistry.getSpeakingChallenge(widget.day).title.isNotEmpty;

  int get _totalSubtasksCount {
    int count = 8; // Rule + Hub + Peer Call + Vocab + Reading + Code English + Quiz + Defense Trap
    if (widget.day == 1 || widget.day == 2) count++; // 🕹️ Level 1 & Level 2 2D Adventure Game
    if (_hasAlphabetPhonics) count++;
    if (_hasSentencePatterns) count++;
    if (_hasPronunciationClinic) count++;
    if (_hasEnglishThinking) count++;
    if (_hasSpeakingChallenge) count++;
    if (widget.day >= 4) count++;
    return count;
  }

  int get _completedSubtasksCount {
    int count = 0;
    if (_dailyRuleCompleted) count++;
    if (_hasAlphabetPhonics && _alphabetPhonicsCompleted) count++;
    if (_hubChatVerified) count++;
    if (_peerCallVerified) count++;
    if (_vocabMemorized) count++;
    if (widget.day == 1 && (_careerAdventureCompleted || _wordCatcherCompleted)) count++; // 🏢 Level 1 Career Adventure Game
    if (widget.day == 2 && _cityNavigatorCompleted) count++; // 🏙️ Level 2 City Navigator Game
    if (_hasSentencePatterns && _sentencePatternCompleted) count++;
    if (_readingNotesCompleted) count++;
    if (_codeEnglishCompleted) count++;
    if (_hasPronunciationClinic && _pronunciationCompleted) count++;
    if (_hasEnglishThinking && _englishThinkingCompleted) count++;
    if (_hasSpeakingChallenge && _speakingChallengeCompleted) count++;
    if (_revisionQuizPassed) count++;
    if (_defenseTrapArmed) count++;
    if (widget.day >= 4 && _trialRaidLaunched) count++;
    return count;
  }

  int get _currentDayPoints {
    final total = _totalSubtasksCount;
    if (total == 0) return 0;
    if (_completedSubtasksCount >= total) return 200;
    return ((_completedSubtasksCount * 200) / total).round().clamp(0, 200);
  }

  bool get _hasPassedToday => _currentDayPoints >= 100;
  bool get _isAllCompleted => _completedSubtasksCount >= _totalSubtasksCount;
  bool get _isTimerCompleted => _timerService.hasReachedTarget;
  bool get _canClaimAndAdvance => _hasPassedToday;

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

                // Quick Sovereign Action Bar: Rules & 90d Guarantee, Reading Library, Code English
                _buildSovereignActionBar(),

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

                      // 🔤 Foundation: Alphabet & 44 Phonics Sound System (User Audio Directive)
                      if (_hasAlphabetPhonics) ...[
                        _buildAlphabetPhonicsCard(),
                        const SizedBox(height: 14),
                      ],

                      // Subtask 1: 💬 English Hub Group Practice
                      _buildSubtaskCard(
                        stepNumber: '1',
                        icon: '💬',
                        title: 'English Hub Group Practice',
                        description: 'Enter the active English Hub and send at least 15 English messages to fellow learners to build active muscle memory.',
                        isVerified: _hubChatVerified,
                        actionLabel: 'OPEN ENGLISH HUB CHAT',
                        actionColor: const Color(0xFFFFFC00),
                        onAction: () async {
                          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                          final nav = Navigator.of(context);
                          EnglishHubLevelGroup levelGroup;
                          if (currentUserId != null) {
                            levelGroup = await EnglishHubLevelGroupService.ensureUserInLevelGroup(
                              userLevel: widget.day,
                              userId: currentUserId,
                            );
                          } else {
                            levelGroup = await EnglishHubLevelGroupService.getGroupByLevel(widget.day);
                          }
                          if (!mounted) return;
                          await nav.push(
                            MaterialPageRoute(
                              builder: (_) => WhatsAppGroupChat(
                                groupId: levelGroup.groupId,
                                groupName: levelGroup.groupName,
                              ),
                            ),
                          );
                          if (mounted) {
                            _verifyEnglishHubChatWithBackend();
                          }
                        },
                        onVerify: () {
                          _verifyEnglishHubChatWithBackend();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 2: 🎙️ Anonymous Peer Talk / Call
                      _buildSubtaskCard(
                        stepNumber: '2',
                        icon: '🎙️',
                        title: 'Peer Call / 1-on-1 English Talk',
                        description: 'Connect with at least 3 mates for live conversation practice to conquer speaking hesitation.',
                        isVerified: _peerCallVerified,
                        actionLabel: 'FIND 1-ON-1 PEERS',
                        actionColor: const Color(0xFF00E5FF),
                        onAction: () async {
                          // Auto-start 40-min practice timer as instructed in audio
                          if (!_timerService.isRunning && !_timerService.hasReachedTarget) {
                            _timerService.toggleTimer();
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StagePeerMatchmakerPage(),
                            ),
                          );
                          if (mounted) {
                            _verifyPeerTalkWithBackend();
                          }
                        },
                        onVerify: () {
                          _verifyPeerTalkWithBackend();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 3: 🧠 10 Vocabulary Words to Memorize
                      _buildVocabDeckCard(),

                      const SizedBox(height: 14),

                      // Subtask 4: 🏢 Mission 01 – The First Conversation (2D Career Adventure Game)
                      if (widget.day == 1) ...[
                        _buildCareerAdventureCard(),
                        const SizedBox(height: 14),
                      ],

                      // Subtask 4: 🏙️ Mission 02 – City Navigator (2D City Navigation Game)
                      if (widget.day == 2) ...[
                        _buildCityNavigatorCard(),
                        const SizedBox(height: 14),
                      ],

                      // 📐 Sentence Pattern Practice (User Audio Directive)
                      if (_hasSentencePatterns) ...[
                        _buildSentencePatternCard(),
                        const SizedBox(height: 14),
                      ],

                      // ⚔️ In-Between Combat Attack Drill (Audio Directive: unlocks on Day 4+)
                      if (widget.day >= 4) ...[
                        _buildMidMissionCombatAttackCard(),
                        const SizedBox(height: 14),
                      ],

                      // Subtask 4: 📖 Core Notes & Multi-Page Authentic Story Reading
                      _buildReadingNotesCard(),

                      const SizedBox(height: 14),

                      // Subtask 5: ⚡ Pocket Code English Decoder (User Audio Directive)
                      _buildCodeEnglishDecoderCard(),

                      const SizedBox(height: 14),

                      // 🗣️ Dedicated Pronunciation & Sound Clinic (User Audio Directive)
                      if (_hasPronunciationClinic) ...[
                        _buildPronunciationClinicCard(),
                        const SizedBox(height: 14),
                      ],

                      // 🧠 English Thinking Workout (User Audio Directive)
                      if (_hasEnglishThinking) ...[
                        _buildEnglishThinkingCard(),
                        const SizedBox(height: 14),
                      ],

                      // 🎙️ In-Lesson Speaking Challenge (User Audio Directive)
                      if (_hasSpeakingChallenge) ...[
                        _buildSpeakingChallengeCard(),
                        const SizedBox(height: 14),
                      ],

                      // ⚡ Sovereign Fluency Shortcut / Kurukkuvazhi (User Audio Directive)
                      _buildFluencyShortcutCard(),

                      const SizedBox(height: 14),

                      // Subtask 6: ✍️ Quick Revision Mini-Quiz
                      _buildRevisionQuizCard(),

                      const SizedBox(height: 14),

                      // Subtask 7: 🛡️ Craft Citadel Defense Trap
                      _buildSubtaskCard(
                        stepNumber: '7',
                        icon: '🛡️',
                        title: 'Add Day ${widget.day} Home Defense',
                        description: 'Arm your front gate with 1 authentic English challenge to defend your house from raiders. (Shield Slot ${widget.day} of ${math.max(10, widget.day)})',
                        isVerified: _defenseTrapArmed,
                        actionLabel: 'ADD HOME DEFENSE 🛡️',
                        actionColor: const Color(0xFF8B5CF6),
                        onAction: () async {
                          await PocketDefenseTrapModal.show(context, widget.day);
                          if (mounted) {
                            setState(() => _defenseTrapArmed = true);
                            _saveSubtask('defense', true);
                          }
                        },
                        onVerify: () {
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 8: ⚔️ Pocket Battle Raid (Audio Directive: Routes directly to Pocket World to select & attack homes)
                      if (widget.day >= 4) ...[
                        _buildSubtaskCard(
                          stepNumber: '8',
                          icon: '⚔️',
                          title: 'Day ${widget.day} Pocket Battle Raid',
                          description: 'Enter Pocket World, inspect neighbor houses on the street, and launch an attack to breach their defense gates!',
                          isVerified: _trialRaidLaunched,
                          actionLabel: 'LAUNCH POCKET BATTLE ⚔️',
                          actionColor: const Color(0xFFEF4444),
                          onAction: () async {
                            final won = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PocketWorldStreetPage(
                                  currentDay: widget.day,
                                  streak: widget.day,
                                  autoRollRaid: true,
                                ),
                              ),
                            );
                            if (!mounted || !context.mounted) return;
                            if (won == true) {
                              setState(() => _trialRaidLaunched = true);
                              _saveSubtask('raid', true);
                              final uid = SupaFlow.client.auth.currentUser?.id;
                              if (uid != null) {
                                await Learning60DayService().completeTask(
                                  userId: uid,
                                  taskId: 'citadel_raid_attack',
                                );
                              }
                              if (!mounted || !context.mounted) return;
                              HapticFeedback.heavyImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🏰 House Breached in Pocket World! Day ${widget.day} Pocket Battle verified ✓ +50 Bonus Coins!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            } else {
                              if (!mounted || !context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Pocket Battle incomplete. Select and breach a house in Pocket World to verify this step!'),
                                  backgroundColor: Color(0xFFB45309),
                                ),
                              );
                            }
                          },
                          onVerify: () {
                            if (_trialRaidLaunched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ Day ${widget.day} Pocket Battle Raid already verified!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Launch Pocket Battle in Pocket World to verify Subtask 7!'),
                                  backgroundColor: Color(0xFFB45309),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('🔒', style: TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pocket Battle Raids Unlock at Level 4',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Complete Days 1–3 foundational English missions and arm your Home Defense first. Raid warfare unlocks on Day 4!',
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 🛡️ House Defense Shield Banner (Audio Directive: Show right inside Day 1!)
                      _buildShieldUnlockBanner(),

                      const SizedBox(height: 10),

                      // 🏆 Final Mission Completion Button
                      _buildFinalClaimButton(),

                      const SizedBox(height: 14),

                      // 🧪 DEV TEST: Complete & Advance to Next Day
                      _buildDevAdvanceButton(),
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

  // --- QUICK SOVEREIGN ACTION BAR: RULES, READING LIBRARY, CODE ENGLISH ---
  Widget _buildSovereignActionBar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionPill(
              icon: '📜',
              label: 'RULES & 90D GUARANTEE',
              color: const Color(0xFF38BDF8),
              onTap: () {
                HapticFeedback.lightImpact();
                PocketWorldGameRulesModal.show(context, currentDay: widget.day);
              },
            ),
            const SizedBox(width: 8),
            _buildActionPill(
              icon: '📚',
              label: 'READING LIBRARY',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                HapticFeedback.lightImpact();
                PocketReadingLibraryModal.show(context, currentDay: widget.day);
              },
            ),
            const SizedBox(width: 8),
            _buildActionPill(
              icon: '⚡',
              label: 'CODE ENGLISH',
              color: const Color(0xFF00FFCC),
              onTap: () {
                HapticFeedback.lightImpact();
                PocketCodeEnglishDecoderModal.show(context, currentDay: widget.day);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🧪 DEV TEST: FAST ADVANCE BUTTON ---
  Widget _buildDevAdvanceButton() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: OutlinedButton(
        onPressed: () async {
          HapticFeedback.heavyImpact();
          final nextDay = (widget.day < 90) ? widget.day + 1 : 90;
          final myId = SupaFlow.client.auth.currentUser?.id;
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('pocket_learning_user_stage', nextDay);
            await prefs.setBool('pocket_day_${widget.day}_completed', true);
            await prefs.setBool('pocket_day_${nextDay}_unlocked', true);
            await prefs.setString(
              'learning_day_${widget.day}_completed_date',
              '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
            );
            await prefs.setString('last_learning_date', DateTime.now().toIso8601String());
            await prefs.setInt('learning_last_completed_day', widget.day);
            await prefs.setBool('pocket_world_rules_accepted_v1', true);

            // 🪙 Award full 200 PTS to unified Pocket Score
            await PocketFortressDefenseService.awardPoints(200);

            // 🧬 Evolve Avatar for next stage and persist to profile
            final evolvedAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(nextDay);
            if (myId != null) {
              await prefs.setString('user_avatar_config_$myId', jsonEncode(evolvedAvatar.toMap()));
              await prefs.setInt('learning_day_$myId', nextDay);
              await prefs.setInt('learning_stage_$myId', nextDay);

              try {
                await SupaFlow.client.from('profile').update({
                  'learning_day': nextDay,
                  'learning_stage': nextDay,
                  'avatar_config': evolvedAvatar.toMap(),
                  'last_learning_date': DateTime.now().toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                }).eq('user_id', myId);

                await EnglishHubLevelGroupService.ensureUserInLevelGroup(
                  userLevel: nextDay,
                  userId: myId,
                  forceLevelMatch: true,
                );
              } catch (e) {
                debugPrint('Dev advance Supabase profile error: $e');
              }
            }
          } catch (e) {
            debugPrint('Dev advance error: $e');
          }

          widget.onMissionCompleted?.call();
          if (mounted) {
            if (widget.day == 90 && mounted) {
              final prefs = await SharedPreferences.getInstance();
              final userName = prefs.getString('user_name') ?? 'Pocket Scholar';
              if (mounted) {
                await Day90MasterCertificateDialog.show(
                  context,
                  userName: userName,
                  userDay: 90,
                );
              }
            }
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                content: Text(
                  '🧪 DEV: Day ${widget.day} completed (+200 PTS)! Evolved avatar & advancing to Day $nextDay...',
                  style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PocketDailyMissionPage(
                  day: nextDay,
                  onMissionCompleted: widget.onMissionCompleted,
                ),
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
          backgroundColor: Colors.amber.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧪', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              'DEV TEST: COMPLETE & ADVANCE TO DAY ${widget.day < 90 ? widget.day + 1 : 90}',
              style: GoogleFonts.firaCode(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
    final isTargetMet = _isTimerCompleted;

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
                    'DAILY 45-MIN PRACTICE TIMER',
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
            'Rule: Spend 45+ mins practicing English daily (chat, voice calls, drills). Pauses when leaving app.',
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
                      : (isTargetMet ? '+45m' : 'START'),
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

          // ⚠️ Extra Session Prompt Banner when 45 minutes are met but subtasks remain
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
                          '45-Min Target Reached! (${_totalSubtasksCount - _completedSubtasksCount} subtasks pending)',
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
                    'Practice timer automatically stopped at 45:00. Complete subtasks to reach at least 100 points to pass and unlock Day ${widget.day + 1}. Complete the tasks below, or add an extra 45-minute practice session.',
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
                            '+ ADD 45-MIN PRACTICE',
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
                            'RESTART 45-MIN RUN',
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

  // --- 📋 OVERALL MISSION PROGRESS CARD (200 Points Total, 100 Pass Mark) ---
  Widget _buildMissionProgressCard() {
    final points = _currentDayPoints;
    final passed = _hasPassedToday;
    final pct = points / 200.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: passed ? const Color(0xFF10B981) : const Color(0xFFFFFC00).withValues(alpha: 0.3),
          width: passed ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (passed)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              blurRadius: 14,
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(passed ? '🏆' : '🎯', style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Day ${widget.day} Learning Score',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: passed ? const Color(0xFF10B981) : Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            passed ? 'PASSED ✅' : 'PASS: 100 PTS',
                            style: GoogleFonts.outfit(
                              color: passed ? Colors.white : Colors.amberAccent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      passed
                          ? 'Passed ($points/200 PTS)! Claim rewards below to unlock Day ${widget.day + 1}!'
                          : 'Earn at least 100 points to pass and unlock Day ${widget.day + 1} (${100 - points} pts needed).',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$points',
                    style: GoogleFonts.outfit(
                      color: passed ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '/ 200 PTS',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                passed ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_completedSubtasksCount/$_totalSubtasksCount Subtasks Verified',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
              ),
              Text(
                'Pass Mark: 100 PTS (50%)',
                style: GoogleFonts.inter(
                  color: passed ? const Color(0xFF10B981) : Colors.amberAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final languageFlags = kLanguageLabels;

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
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final wordsMap = _vocabList.map((v) => v.toMap()).toList();
                    final count = await PocketVocabularyService.instance.saveWords(widget.day, wordsMap);
                    if (mounted) {
                      setState(() {
                        _vocabMemorized = true;
                        _isPocketVocabSaved = true;
                      });
                      _saveSubtask('vocab_mem', true);
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✨ Saved ${count > 0 ? count : 10} words to offline Pocket Vocabulary! Rewind anytime.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _isPocketVocabSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                  label: Text(
                    _isPocketVocabSaved ? 'SAVED TO VAULT ✓' : 'SAVE TO POCKET VOCABULARY',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 11.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showPocketVocabularyModal(),
                icon: const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD700), size: 16),
                label: Text(
                  'OPEN VAULT',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFFFD700), fontSize: 11.5),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD700)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                setState(() => _vocabMemorized = true);
                _saveSubtask('vocab_mem', true);
                // Also auto-save to local pocket vocabulary
                final wordsMap = _vocabList.map((v) => v.toMap()).toList();
                await PocketVocabularyService.instance.saveWords(widget.day, wordsMap);
                if (!mounted) return;
                setState(() => _isPocketVocabSaved = true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 10 Vocabulary Words memorized & saved to Pocket Vocabulary!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(_vocabMemorized ? Icons.check_circle_rounded : Icons.done_all_rounded, color: _vocabMemorized ? const Color(0xFF10B981) : Colors.white70, size: 16),
              label: Text(
                _vocabMemorized ? '10 WORDS VERIFIED ✓' : 'MARK ALL 10 WORDS MEMORIZED',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _vocabMemorized ? const Color(0xFF10B981) : Colors.white70, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _vocabMemorized ? const Color(0xFF10B981) : Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⚔️ In-Between Combat Attack Drill (Audio Directive: "idayil idayil attacking, oru attack okke kodukkaam")
  Widget _buildMidMissionCombatAttackCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _midAttackCompleted
              ? [const Color(0xFF064E3B).withValues(alpha: 0.6), const Color(0xFF022C22).withValues(alpha: 0.6)]
              : [const Color(0xFF450A0A).withValues(alpha: 0.8), const Color(0xFF180808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _midAttackCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _midAttackCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚔️ ', style: TextStyle(fontSize: 10)),
                    Text(
                      _midAttackCompleted ? 'COMBAT RAID CLEARED ✓' : 'RAPID COMBAT ATTACK',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _midAttackCompleted ? '+50 BONUS COINS EARNED' : '+50 BONUS COINS',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mid-Mission Pocket Battle Attack Drill',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter Pocket World to inspect neighbor houses and breach their gate shields to loot bonus coins and sharpen your speaking reaction under pressure.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final won = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PocketWorldStreetPage(
                      currentDay: widget.day,
                      streak: widget.day,
                      autoRollRaid: true,
                    ),
                  ),
                );
                if (mounted) {
                  if (won == true) {
                    setState(() => _midAttackCompleted = true);
                    _saveSubtask('mid_attack', true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚔️ Pocket Battle raid won! Bonus +50 coins registered.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Raid incomplete. Select and breach a house in Pocket World to earn bonus coins!'),
                        backgroundColor: Color(0xFFB45309),
                      ),
                    );
                  }
                }
              },
              icon: Icon(
                _midAttackCompleted ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                _midAttackCompleted ? 'LAUNCH ANOTHER POCKET BATTLE ⚔️' : 'LAUNCH POCKET BATTLE NOW ⚔️',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _midAttackCompleted ? const Color(0xFF059669) : const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🔤 ALPHABET & 44 PHONICS SOUND SYSTEM CARD ---
  Widget _buildAlphabetPhonicsCard() {
    final phonicsList = PocketMissionCurriculumRegistry.getAlphabetPhonics(widget.day);
    if (phonicsList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _alphabetPhonicsCompleted ? const Color(0xFF10B981) : const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: _alphabetPhonicsCompleted ? 1.5 : 1.0,
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
                  color: _alphabetPhonicsCompleted ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PHONICS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🔤', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Alphabet & 44 Phonics Sound System',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_alphabetPhonicsCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Master authentic mouth placements, vocal releases & acoustic IPA frequencies. Tap 🔊 on each word to tune your subconscious ear.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 12),

          // Grid of Phonics Sounds for today
          Column(
            children: phonicsList.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.letter,
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.phoneme,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF00E5FF),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Example: ${item.exampleWord}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '👄 ${item.pronunciationGuide}',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFDE68A),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _speakWord(item.exampleWord);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.exampleWord,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _alphabetPhonicsCompleted = true);
                _saveSubtask('alphabet_phonics', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔤 Phonics Sounds Mastered! Authentic mouth placement verified ✓'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                _alphabetPhonicsCompleted ? Icons.check_circle_rounded : Icons.record_voice_over_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                _alphabetPhonicsCompleted ? 'PHONICS MASTERED ✓' : 'PRACTICED SOUNDS & WORDS ALOUD ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _alphabetPhonicsCompleted ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 📐 SENTENCE PATTERN PRACTICE CARD ---
  Widget _buildSentencePatternCard() {
    final patterns = PocketMissionCurriculumRegistry.getSentencePatterns(widget.day);
    if (patterns.isEmpty) return const SizedBox.shrink();

    final pattern = patterns[_selectedPatternIndex.clamp(0, patterns.length - 1)];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _sentencePatternCompleted ? const Color(0xFF10B981) : const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: _sentencePatternCompleted ? 1.5 : 1.0,
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
                  color: _sentencePatternCompleted ? const Color(0xFF10B981) : const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PATTERN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('📐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Daily Sentence Pattern Practice',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_sentencePatternCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pattern.explanation,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 10),

          // Pattern selector tabs if multiple
          if (patterns.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: patterns.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final isSel = idx == _selectedPatternIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPatternIndex = idx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white24),
                        ),
                        child: Text(
                          'Pattern ${idx + 1}',
                          style: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 10),

          // Formula box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STRUCTURE FORMULA:',
                  style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  pattern.formula,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Master Sentences
          Column(
            children: pattern.masterSentences.map((sent) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF13172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sent,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 18),
                      onPressed: () => _speakWord(sent),
                      tooltip: 'Listen to pattern sentence',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _sentencePatternCompleted = true);
                _saveSubtask('sentence_pattern', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📐 Sentence Pattern Mastered! Direct structure practiced ✓'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                _sentencePatternCompleted ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                _sentencePatternCompleted ? 'PATTERN MASTERED ✓' : 'I PRACTICED THIS PATTERN ALOUD ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sentencePatternCompleted ? const Color(0xFF10B981) : const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- SUBTASK 4: 🏢 MISSION 01 CAREER ADVENTURE 2D GAME CARD (User Audio Directive: Mature Level 1 Game) ---
  Widget _buildCareerAdventureCard() {
    final isDone = _careerAdventureCompleted || _wordCatcherCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDone
              ? const [Color(0xFF0F172A), Color(0xFF064E3B)]
              : const [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.6),
          width: isDone ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP 4',
                  style: TextStyle(
                    color: isDone ? Colors.white : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🏢', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission 01 – The First Conversation',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '2D Career Adventure · Modern Office & Interview',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED',
                          style: TextStyle(
                              color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    '+50 PTS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Apex Corporate Tower, check in at reception, arrange sentence builder tiles, survive the 8s quick response, and pass your first job interview!',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '10 Workplace Vocabulary Words · Practical Spoken English',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final completed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CareerAdventureGamePage(
                      levelData: kMission01LevelData,
                    ),
                  ),
                );
                if (completed == true && mounted) {
                  setState(() {
                    _careerAdventureCompleted = true;
                    _wordCatcherCompleted = true;
                  });
                  _saveSubtask('career_adventure', true);
                  _saveSubtask('word_catcher', true);
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '🎉 Mission 01 Career Adventure Completed! Step 4 Verified ✓ +50 Points!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF1E293B) : const Color(0xFF0284C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDone ? const Color(0xFF10B981) : Colors.transparent,
                  ),
                ),
                elevation: isDone ? 0 : 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDone ? Icons.replay_rounded : Icons.sports_esports_rounded,
                    color: isDone ? const Color(0xFF10B981) : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                    Text(
                      isDone ? 'REPLAY MISSION 1 🔄' : 'PLAY MISSION 1 🎮',
                      style: GoogleFonts.outfit(
                        color: isDone ? const Color(0xFF10B981) : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 4: 🏙️ MISSION 02 CITY NAVIGATOR 2D GAME CARD (Day 2 Navigation) ---
  Widget _buildCityNavigatorCard() {
    final isDone = _cityNavigatorCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDone
              ? const [Color(0xFF0F172A), Color(0xFF064E3B)]
              : const [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.6),
          width: isDone ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP 4',
                  style: TextStyle(
                    color: isDone ? Colors.white : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🏙️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission 02 – City Navigator',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '2D City Navigation · Modern Map & Directions',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED',
                          style: TextStyle(
                              color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    '+50 PTS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Navigate Grand Avenue, read signs, follow spoken directions, build routes, and reach the City Business Center before 11:00 AM!',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.navigation_rounded, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '20 City Vocabulary Words · Practical Directions',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final completed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CityNavigatorGamePage(
                      levelData: kMission02CityData,
                    ),
                  ),
                );
                if (completed == true && mounted) {
                  setState(() {
                    _cityNavigatorCompleted = true;
                  });
                  _saveSubtask('city_navigator', true);
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '🎉 Mission 02 City Navigator Completed! Step 4 Verified ✓ +50 Points!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF1E293B) : const Color(0xFF0284C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDone ? const Color(0xFF10B981) : Colors.transparent,
                  ),
                ),
                elevation: isDone ? 0 : 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDone ? Icons.replay_rounded : Icons.explore_rounded,
                    color: isDone ? const Color(0xFF10B981) : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDone ? 'REPLAY MISSION 2 🔄' : 'PLAY MISSION 2 🎮',
                    style: GoogleFonts.outfit(
                      color: isDone ? const Color(0xFF10B981) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 4/5: 📖 CORE NOTES & AUTHENTIC MULTI-PAGE STORY READING CARD ---
  Widget _buildReadingNotesCard() {
    final storyPages = PocketMissionCurriculumRegistry.getStoryPages(widget.day);
    final hasPages = storyPages.isNotEmpty;
    final totalPages = hasPages ? storyPages.length : 1;
    final safePageIndex = _activeStoryPageIndex.clamp(0, totalPages - 1);
    final activePageText = hasPages ? storyPages[safePageIndex] : _storyText;

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
                child: Text(widget.day == 1 ? 'STEP 5' : 'STEP 4', style: TextStyle(color: _readingNotesCompleted ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
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
          const SizedBox(height: 10),

          // Multi-Language Switcher (Malayalam, Tamil, Telugu, Hindi, Kannada, English)
          Row(
            children: [
              Text(
                'EXPLANATION LANGUAGE:',
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const Spacer(),
              Text(
                _selectedLanguage,
                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
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
                        color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        kLanguageLabels[lang] ?? lang,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
          const SizedBox(height: 12),

          // 📖 Authentic Multi-Page Story Book Reader (Audio Directive: Full 2-4 pages of authentic reading directly in mission)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1527),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Header & TTS Speaker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF131D33),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  ),
                  child: Row(
                    children: [
                      Text(_storyIcon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _storyTitle,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF00E5FF),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
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
                        tooltip: _isStorySpeaking ? 'Stop Reading' : 'Read Active Page (TTS)',
                        onPressed: () => _speakStory(activePageText),
                      ),
                    ],
                  ),
                ),

                // Multi-Page Tab Selector (Page 1, Page 2, Page 3...)
                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F1A30),
                      border: Border(bottom: BorderSide(color: Colors.white10)),
                    ),
                    child: Row(
                      children: List.generate(totalPages, (idx) {
                        final isSel = idx == safePageIndex;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: idx < totalPages - 1 ? 6 : 0),
                            child: InkWell(
                              onTap: () {
                                _tts.stop();
                                setState(() {
                                  _activeStoryPageIndex = idx;
                                  _isStorySpeaking = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF00E5FF) : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Page ${idx + 1}',
                                  style: TextStyle(
                                    color: isSel ? Colors.black : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                // Book Page Reading Text Body
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '📖 CHAPTER PAGE ${safePageIndex + 1} OF $totalPages',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '~3 min read',
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070E1E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          activePageText,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.94),
                            fontSize: 13,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      // Previous / Next Page Navigation Controls
                      if (totalPages > 1) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: safePageIndex > 0
                                  ? () {
                                      _tts.stop();
                                      setState(() {
                                        _activeStoryPageIndex = safePageIndex - 1;
                                        _isStorySpeaking = false;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.arrow_back_rounded, size: 14),
                              label: const Text('PREV PAGE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                textStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '${safePageIndex + 1} / $totalPages',
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            OutlinedButton.icon(
                              onPressed: safePageIndex < totalPages - 1
                                  ? () {
                                      _tts.stop();
                                      setState(() {
                                        _activeStoryPageIndex = safePageIndex + 1;
                                        _isStorySpeaking = false;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                              label: const Text('NEXT PAGE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00E5FF),
                                side: const BorderSide(color: Color(0xFF00E5FF)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                textStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),
                      // Moral / Takeaway in selected language
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _getStorySummary(_selectedLanguage),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6EE7B7),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary Story Completion Verification Button + Library & Fullscreen Options
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _readingNotesCompleted = true);
                _saveSubtask('reading', true);
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Authentic Story ($totalPages Pages) verified as read! (+25 PTS)'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                _readingNotesCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                _readingNotesCompleted ? 'ALL $totalPages PAGES READ & VERIFIED ✓' : 'I HAVE READ ALL $totalPages PAGES OF TODAY\'S STORY ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _readingNotesCompleted ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showStoryDetailModal,
                  icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFF00E5FF), size: 15),
                  label: Text(
                    'FULLSCREEN READER',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PocketLibraryPage()),
                    );
                  },
                  icon: const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD700), size: 15),
                  label: Text(
                    'READ BOOKS 📚',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFD700)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
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

  // --- SUBTASK 5: ⚡ POCKET CODE ENGLISH DECODER CARD (User Audio Directive: Integrated Step 5) ---
  Widget _buildCodeEnglishDecoderCard() {
    final formula = PocketCodeEnglishDecoderModal.getFormulaForDay(widget.day);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _codeEnglishCompleted ? const Color(0xFF10B981) : const Color(0xFF00FFCC).withValues(alpha: 0.35),
          width: _codeEnglishCompleted ? 1.5 : 1.0,
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
                  color: _codeEnglishCompleted ? const Color(0xFF10B981) : const Color(0xFF00FFCC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.day == 1 ? 'STEP 6' : 'STEP 5',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('⚡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pocket Code English Decoder',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Mnemonic Syntax Algorithms (കോഡ് ഭാഷ വെച്ച് ഇംഗ്ലീഷ് പഠിക്കാം)',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (_codeEnglishCompleted)
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
          const SizedBox(height: 10),

          // Formula Header Badge Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: formula.color.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: formula.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: formula.color),
                      ),
                      child: Text(
                        formula.codeName,
                        style: GoogleFonts.firaCode(
                          color: formula.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formula.category,
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formula.title,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),

                // Monospace Syntax Rule Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYNTAX RULE:',
                        style: GoogleFonts.firaCode(color: const Color(0xFFFFD700), fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formula.syntaxRule,
                        style: GoogleFonts.firaCode(
                          color: const Color(0xFF00FFCC),
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Malayalam Explanation
                Text(
                  formula.malayalamExplanation,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.45),
                ),

                // Breakdown tokens
                if (formula.formulaBreakdown.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'ALGORITHM BREAKDOWN:',
                    style: GoogleFonts.firaCode(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...formula.formulaBreakdown.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: formula.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['token'] ?? '',
                            style: GoogleFonts.firaCode(color: formula.color, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['desc'] ?? '',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 8),

                // Correct Example vs Buggy Example
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              'Valid Code: "${formula.correctExample}"',
                              style: GoogleFonts.inter(color: const Color(0xFF6EE7B7), fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✗ ', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              'Syntax Bug: "${formula.buggyExample}"',
                              style: GoogleFonts.inter(color: const Color(0xFFFCA5A5), fontSize: 11.5, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Compiler Interactive Output
                if (_codeCompilerOutput != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Text(
                      _codeCompilerOutput!,
                      style: GoogleFonts.firaCode(color: const Color(0xFF34D399), fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Test Formula Compiler Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCodeCompiling ? null : () async {
                setState(() => _isCodeCompiling = true);
                await Future.delayed(const Duration(milliseconds: 300));
                if (!mounted) return;
                setState(() {
                  _isCodeCompiling = false;
                  _codeCompilerOutput = '⚡ [SYNTAX COMPILER] STATUS: PASS (0 ERRORS)\nAlgorithm validated: [${formula.codeName}] compiled successfully!\nRule: ${formula.syntaxRule}\nSample: "${formula.correctExample}"';
                });
                HapticFeedback.lightImpact();
              },
              icon: _isCodeCompiling
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                  : const Icon(Icons.play_arrow_rounded, color: Color(0xFF00FFCC), size: 16),
              label: Text(
                _isCodeCompiling ? 'ANALYZING SYNTAX...' : 'TEST FORMULA COMPILER ⚡',
                style: GoogleFonts.firaCode(color: const Color(0xFF00FFCC), fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00FFCC)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Primary Mark Complete & Open All Modal Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _codeEnglishCompleted = true);
                    _saveSubtask('code_english', true);
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚡ Code English Formula Mastered & Verified! (+25 PTS)'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: Icon(
                    _codeEnglishCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                  label: Text(
                    _codeEnglishCompleted ? 'FORMULA MASTERED ✓' : 'MARK FORMULA DECODED ✓',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _codeEnglishCompleted ? const Color(0xFF10B981) : const Color(0xFF00FFCC),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => PocketCodeEnglishDecoderModal.show(context, currentDay: widget.day),
                icon: const Icon(Icons.code_rounded, color: Colors.white70, size: 15),
                label: Text(
                  'ALL CODES',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          const SizedBox(height: 2),
                          Text(
                            _storyQuotePreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: const Color(0xFF00E5FF), fontSize: 10, fontStyle: FontStyle.italic),
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
                // Multi-Page Story Chapters Tab Bar
                Builder(
                  builder: (_) {
                    final pages = PocketMissionCurriculumRegistry.getStoryPages(widget.day);
                    if (pages.length <= 1) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: List.generate(pages.length, (idx) {
                          final isCurrent = idx == _activeStoryPageIndex;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: idx < pages.length - 1 ? 6 : 0),
                              child: InkWell(
                                onTap: () {
                                  _tts.stop();
                                  modalSetState(() {
                                    _activeStoryPageIndex = idx;
                                    _isStorySpeaking = false;
                                  });
                                  setState(() {
                                    _activeStoryPageIndex = idx;
                                    _isStorySpeaking = false;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCurrent ? const Color(0xFF00E5FF) : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isCurrent ? const Color(0xFF00E5FF) : Colors.white24),
                                  ),
                                  child: Text(
                                    'Page ${idx + 1}',
                                    style: TextStyle(
                                      color: isCurrent ? Colors.black : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                // Audio Narrator Controller Bar + Speed Control
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
                            _tts.setSpeechRate(_ttsSpeechRate);
                            _tts.setCompletionHandler(() {
                              if (mounted) {
                                modalSetState(() => _isStorySpeaking = false);
                                setState(() => _isStorySpeaking = false);
                              }
                            });
                            final pages = PocketMissionCurriculumRegistry.getStoryPages(widget.day);
                            final currentText = pages.isNotEmpty
                                ? pages[_activeStoryPageIndex.clamp(0, pages.length - 1)]
                                : _storyText;
                            _tts.speak(currentText);
                          }
                        },
                        icon: Icon(
                          _isStorySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          _isStorySpeaking ? 'STOP NARRATOR' : 'LISTEN (TTS)',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Speed toggles: 0.8x, 1.0x, 1.2x
                      ...[0.38, 0.48, 0.58].map((rate) {
                        final label = rate == 0.38 ? '0.8x' : (rate == 0.48 ? '1.0x' : '1.2x');
                        final isSel = (_ttsSpeechRate - rate).abs() < 0.05;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: InkWell(
                            onTap: () {
                              _ttsSpeechRate = rate;
                              _tts.setSpeechRate(rate);
                              modalSetState(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFFFFC00) : Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSel ? Colors.black : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kSupportedLanguages.map((lang) {
                      final isSelected = _selectedLanguage == lang;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            _onLanguageSelected(lang);
                            modalSetState(() {});
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              kLanguageLabels[lang] ?? lang,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
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
                            () {
                              final pages = PocketMissionCurriculumRegistry.getStoryPages(widget.day);
                              if (pages.isNotEmpty) {
                                return pages[_activeStoryPageIndex.clamp(0, pages.length - 1)];
                              }
                              return _storyFormatted;
                            }(),
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

  // --- 🗣️ DEDICATED PRONUNCIATION & SOUND CLINIC CARD ---
  Widget _buildPronunciationClinicCard() {
    final clinic = PocketMissionCurriculumRegistry.getPronunciationClinic(widget.day);
    if (clinic.minimalPairs.isEmpty && clinic.practicePhrases.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pronunciationCompleted ? const Color(0xFF10B981) : const Color(0xFFA855F7).withValues(alpha: 0.35),
          width: _pronunciationCompleted ? 1.5 : 1.0,
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
                  color: _pronunciationCompleted ? const Color(0xFF10B981) : const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CLINIC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🗣️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Dedicated Pronunciation & Accent Clinic',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_pronunciationCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            clinic.focusSound,
            style: GoogleFonts.inter(color: const Color(0xFFD8B4FE), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '👄 Position: ${clinic.mouthPositionTip}',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
          ),
          const SizedBox(height: 10),

          // Minimal Pairs Comparison Grid
          if (clinic.minimalPairs.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MINIMAL PAIRS COMPARISON (Acoustic Contrast):',
                    style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...clinic.minimalPairs.map((pair) {
                    final wordA = pair['wordA'] ?? pair['word1'] ?? '';
                    final ipaA = pair['ipaA'] ?? pair['ipa1'] ?? '';
                    final wordB = pair['wordB'] ?? pair['word2'] ?? '';
                    final ipaB = pair['ipaB'] ?? pair['ipa2'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _speakWord(wordA),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(wordA, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(ipaA, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10.5)),
                                    const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 13),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('vs', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _speakWord(wordB),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(wordB, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(ipaB, style: const TextStyle(color: Color(0xFFD8B4FE), fontSize: 10.5)),
                                    const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 13),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Practice Phrases
          if (clinic.practicePhrases.isNotEmpty)
            Column(
              children: clinic.practicePhrases.map((phrase) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          phrase,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 16),
                        onPressed: () => _speakWord(phrase),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _pronunciationCompleted = true);
                _saveSubtask('pronunciation', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗣️ Pronunciation Clinic Completed! Acoustic contrast drilled ✓'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                _pronunciationCompleted ? Icons.check_circle_rounded : Icons.record_voice_over_rounded,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                _pronunciationCompleted ? 'PRONUNCIATION CLINIC DONE ✓' : 'I CONTRASTED THESE SOUNDS ALOUD ✓',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _pronunciationCompleted ? const Color(0xFF10B981) : const Color(0xFFA855F7),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🧠 ENGLISH THINKING WORKOUT CARD ---
  Widget _buildEnglishThinkingCard() {
    final workout = PocketMissionCurriculumRegistry.getEnglishThinkingWorkout(widget.day);
    if (workout.instantResponses.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _englishThinkingCompleted ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: _englishThinkingCompleted ? 1.5 : 1.0,
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
                  color: _englishThinkingCompleted ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'REFLEX',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'English Thinking Workout (No Mother-Tongue Lag)',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_englishThinkingCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            workout.situation,
            style: GoogleFonts.inter(color: const Color(0xFFBAE6FD), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '⚠️ Avoid: ${workout.mentalTrapMalayalam}',
            style: GoogleFonts.inter(color: Colors.deepOrangeAccent, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 Thought: ${workout.directEnglishThought}',
            style: GoogleFonts.inter(color: const Color(0xFF34D399), fontSize: 11),
          ),
          const SizedBox(height: 10),

          // Instant Reflex Drills
          Column(
            children: workout.instantResponses.map((res) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '👉 $res',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 18),
                      onPressed: () => _speakWord(res),
                      tooltip: 'Listen to native reflex',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _englishThinkingCompleted = true);
                _saveSubtask('english_thinking', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧠 English Thinking Reflex Mastered! Zero translation lag verified ✓'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                _englishThinkingCompleted ? Icons.check_circle_rounded : Icons.psychology_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                _englishThinkingCompleted ? 'THINKING REFLEX MASTERED ✓' : 'I DRILLED DIRECT REFLEXES ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _englishThinkingCompleted ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎙️ IN-LESSON 30-SECOND SPEAKING CHALLENGE CARD ---
  Widget _buildSpeakingChallengeCard() {
    final challenge = PocketMissionCurriculumRegistry.getSpeakingChallenge(widget.day);
    if (challenge.title.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _speakingChallengeCompleted ? const Color(0xFF10B981) : const Color(0xFFF43F5E).withValues(alpha: 0.35),
          width: _speakingChallengeCompleted ? 1.5 : 1.0,
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
                  color: _speakingChallengeCompleted ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CHALLENGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🎙️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'In-Lesson 30s Solo Speaking Challenge',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_speakingChallengeCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.title,
            style: GoogleFonts.outfit(color: const Color(0xFFFDA4AF), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            challenge.contextScenario,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 10),

          // Speech structure scaffold bullets
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPEAKING FRAMEWORK (${challenge.targetSeconds} Seconds):',
                  style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...challenge.guidingPoints.map((guide) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(guide, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5)),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Interactive 30s Countdown timer button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    if (_isSpeakingChallengeRecording) {
                      _speakingTimer?.cancel();
                      setState(() => _isSpeakingChallengeRecording = false);
                    } else {
                      _speakingTimer?.cancel();
                      setState(() {
                        _isSpeakingChallengeRecording = true;
                        _speakingChallengeSecondsRemaining = 30;
                      });
                      _speakingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                        if (!mounted) {
                          t.cancel();
                          return;
                        }
                        if (_speakingChallengeSecondsRemaining <= 1) {
                          t.cancel();
                          HapticFeedback.heavyImpact();
                          setState(() {
                            _isSpeakingChallengeRecording = false;
                            _speakingChallengeCompleted = true;
                          });
                          _saveSubtask('speaking_challenge', true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 30s Speaking Challenge Finished! Vocal agility activated ✓'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } else {
                          setState(() {
                            _speakingChallengeSecondsRemaining--;
                          });
                        }
                      });
                    }
                  },
                  icon: Icon(
                    _isSpeakingChallengeRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    _isSpeakingChallengeRecording
                        ? 'SPEAKING ALOUD: ${_speakingChallengeSecondsRemaining}s'
                        : 'START 30s SPEAKING DRILL 🎙️',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSpeakingChallengeRecording ? Colors.redAccent : const Color(0xFFF43F5E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _speakingTimer?.cancel();
                  setState(() {
                    _isSpeakingChallengeRecording = false;
                    _speakingChallengeCompleted = true;
                  });
                  _saveSubtask('speaking_challenge', true);
                  HapticFeedback.lightImpact();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _speakingChallengeCompleted ? 'DONE ✓' : 'FINISH',
                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ⚡ SOVEREIGN FLUENCY SHORTCUT / KURUKKUVAZHI CARD ---
  Widget _buildFluencyShortcutCard() {
    final shortcut = PocketMissionCurriculumRegistry.getFluencyShortcut(widget.day);
    if (shortcut.title.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: 1.2,
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
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SHORTCUT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('⚡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shortcut.malyalamHeading,
                  style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortcut.ruleSummary,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🔑 Quick Hack: ${shortcut.quickHack}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFE082),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                if (shortcut.examples.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...shortcut.examples.map((ex) => Text(
                    '• $ex',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6EE7B7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- SUBTASK 6: ✍️ QUICK REVISION MINI-QUIZ CARD ---
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
                child: Text('STEP 6', style: TextStyle(color: _revisionQuizPassed ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
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
          if (_quizSubmitted) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedQuizAnswer == 0
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF78350F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedQuizAnswer == 0
                      ? const Color(0xFF10B981)
                      : Colors.amberAccent,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedQuizAnswer == 0 ? '✅' : '💡', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedQuizAnswer == 0
                              ? 'Spot on! Correct answer.'
                              : 'Keep learning! Correct answer is: "${_quizOptions[0]}"',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Step 5 verified ✓ You can proceed to the next subtask.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedQuizAnswer == -1
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = true;
                        _revisionQuizPassed = true;
                        _saveSubtask('quiz', true);
                      });
                      HapticFeedback.mediumImpact();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _revisionQuizPassed ? 'QUIZ COMPLETED ✓ NEXT' : 'SUBMIT ANSWER',
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
                      'DAY ${widget.day} HOME DEFENSE',
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
              _defenseTrapArmed ? 'HOME DEFENSE ACTIVE 🛡️' : 'ADD HOME DEFENSE',
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
    final canClaim = _canClaimAndAdvance;
    final points = _currentDayPoints;
    final total = _totalSubtasksCount;
    final remaining = (total - _completedSubtasksCount).clamp(0, total);

    String headerTitle;
    String description;
    String buttonText;

    if (canClaim) {
      headerTitle = '🎉 DAY ${widget.day} PASSED! ($points/200 PTS)';
      description =
          'Pass Mark achieved ($points/200 PTS)! 50 Bonus Coins awarded to your Vault Store. Day ${widget.day + 1} is now UNLOCKED!';
      buttonText = 'CLAIM REWARDS & COMPLETE DAY ${widget.day} MISSION 🚀';
    } else {
      final ptsNeeded = (100 - points).clamp(0, 100);
      headerTitle = '⏳ PASS MARK PENDING ($points/200 PTS)';
      description =
          'Earn at least 100 points across the subtasks to pass and unlock Day ${widget.day + 1}. ($ptsNeeded more points needed, $remaining subtasks remaining).';
      buttonText = 'EARN $ptsNeeded MORE PTS TO UNLOCK DAY ${widget.day + 1}';
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
                      final nextDay = (widget.day < 90) ? widget.day + 1 : 90;
                      if (uid != null) {
                        await Learning60DayService().completeDailyMission(
                          userId: uid,
                          day: widget.day,
                          earnedPoints: _currentDayPoints,
                          advanceToNextDay: true,
                        );
                        await PocketFortressDefenseService.recordActivityPoints(
                          'daily_mission',
                        );
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
                        await prefs.setBool('pocket_day_${widget.day}_completed', true);
                        await prefs.setString('learning_day_${widget.day}_completed_date', todayStr);
                        await prefs.setInt('learning_day_${widget.day}_completed_timestamp', DateTime.now().millisecondsSinceEpoch);
                        await prefs.setInt('learning_last_completed_day', widget.day);
                        await prefs.setBool('pocket_day_${nextDay}_unlocked', true);
                        await prefs.setInt('pocket_learning_user_stage', nextDay);
                      }
                      // Award 50 bonus coins to vault store
                      await PocketFortressDefenseService.awardRaidLoot(50);

                      final prefs = await SharedPreferences.getInstance();
                      final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
                      await prefs.setString('learning_day_${widget.day}_completed_date', todayStr);
                      await prefs.setInt('learning_last_completed_day', widget.day);
                      await prefs.setBool('pocket_day_${nextDay}_unlocked', true);
                      await prefs.setInt('pocket_learning_user_stage', nextDay);

                      if (uid != null) {
                        try {
                          await SupaFlow.client.from('profile').update({
                            'learning_day': nextDay,
                            'learning_stage': nextDay,
                            'updated_at': DateTime.now().toIso8601String(),
                          }).eq('user_id', uid);

                          await EnglishHubLevelGroupService.ensureUserInLevelGroup(
                            userLevel: nextDay,
                            userId: uid,
                            forceLevelMatch: true,
                          );
                        } catch (e) {
                          debugPrint('Error auto-migrating English Hub cohort on mission complete: $e');
                        }
                      }

                      widget.onMissionCompleted?.call();
                      if (mounted) {
                        if (widget.day == 90) {
                          final prefs = await SharedPreferences.getInstance();
                          final userName = prefs.getString('user_name') ?? 'Pocket Scholar';
                          if (mounted) {
                            await Day90MasterCertificateDialog.show(
                              context,
                              userName: userName,
                              userDay: 90,
                            );
                          }
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 Day ${widget.day} English Mission Complete! Earned $_currentDayPoints/200 Points! Day $nextDay is now UNLOCKED!',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  fontSize: 13.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
