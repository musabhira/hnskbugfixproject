import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'pocket_world_street_page.dart';

/// 🎮 The 10 High-Value English Battle Modes
enum BattleMode {
  vocabCannonball,
  speechThunderbolt,
  grammarDefusal,
  runeCatapult,
  whisperPhantom,
  idiomBlitz,
  tenseArchery,
  syntaxJigsaw,
  collocationRam,
  riddleSphinx,
}

class BattleModeInfo {
  final BattleMode mode;
  final String title;
  final String subtitle;
  final String icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;

  const BattleModeInfo({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
  });
}

const List<BattleModeInfo> kBattleModes = [
  BattleModeInfo(
    mode: BattleMode.vocabCannonball,
    title: 'Vocab Cannonball',
    subtitle: 'Rapid Synonym & Antonym Siege',
    icon: '🎯',
    primaryColor: Color(0xFFEF4444),
    secondaryColor: Color(0xFF991B1B),
    description: 'Answer fast synonyms and definitions to fire explosive cannonballs at the gate!',
  ),
  BattleModeInfo(
    mode: BattleMode.speechThunderbolt,
    title: 'Speech Thunderbolt',
    subtitle: 'Spoken Pronunciation Duel',
    icon: '🎙️',
    primaryColor: Color(0xFF00F0FF),
    secondaryColor: Color(0xFF0369A1),
    description: 'Pronounce natural conversational phrases clearly to summon electric lightning strikes!',
  ),
  BattleModeInfo(
    mode: BattleMode.grammarDefusal,
    title: 'Grammar Defusal',
    subtitle: 'Spot & Fix Sentence Errors',
    icon: '💣',
    primaryColor: Color(0xFFF59E0B),
    secondaryColor: Color(0xFFB45309),
    description: 'Find tricky grammatical errors before the ticking bomb detonates on your yard!',
  ),
  BattleModeInfo(
    mode: BattleMode.runeCatapult,
    title: 'Rune Catapult',
    subtitle: 'Word Builder & Anagram Siege',
    icon: '🔠',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFF5B21B6),
    description: 'Assemble scattered ancient alphabet runes to release the heavy boulder catapult!',
  ),
  BattleModeInfo(
    mode: BattleMode.whisperPhantom,
    title: 'Whisper Phantom',
    subtitle: 'Native Listening Detective',
    icon: '👂',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF065F46),
    description: 'Listen to native-speed English audio clips and identify the missing mystery word!',
  ),
  BattleModeInfo(
    mode: BattleMode.idiomBlitz,
    title: 'Idiom Blitz',
    subtitle: 'Colloquial & Slang Master',
    icon: '⚡',
    primaryColor: Color(0xFFEC4899),
    secondaryColor: Color(0xFF9D174D),
    description: 'Match real-world natural English idioms and native phrases to daily life scenarios!',
  ),
  BattleModeInfo(
    mode: BattleMode.tenseArchery,
    title: 'Tense Archery',
    subtitle: 'Rapid Time-Shifting Volley',
    icon: '🏹',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF047857),
    description: 'Aim precision arrows by instantly choosing the correct English grammatical tense!',
  ),
  BattleModeInfo(
    mode: BattleMode.syntaxJigsaw,
    title: 'Syntax Jigsaw',
    subtitle: 'Word Reassembly Trebuchet',
    icon: '🧩',
    primaryColor: Color(0xFF6366F1),
    secondaryColor: Color(0xFF4338CA),
    description: 'Assemble scrambled words into perfect sentence syntax to launch the heavy trebuchet!',
  ),
  BattleModeInfo(
    mode: BattleMode.collocationRam,
    title: 'Collocation Ram',
    subtitle: 'Phrasal & Idiom Pairings',
    icon: '🔨',
    primaryColor: Color(0xFFF97316),
    secondaryColor: Color(0xFFC2410C),
    description: 'Pair natural phrasal verbs and native collocations to swing the heavy battering ram!',
  ),
  BattleModeInfo(
    mode: BattleMode.riddleSphinx,
    title: 'Riddle Sphinx',
    subtitle: 'Mind Breach & Context Inference',
    icon: '🔮',
    primaryColor: Color(0xFFA855F7),
    secondaryColor: Color(0xFF7E22CE),
    description: 'Solve witty English riddles and deduction puzzles for massive critical damage!',
  ),
];

/// ⚔️ Pocket English Battle Arena
/// Full PvP Duel Screen with live Opponent House HP damage, damage numbers, and 10 mini-games!
class PocketBattleArenaPage extends StatefulWidget {
  final PocketNeighbor neighbor;
  final int userDay;
  final int userStreak;

  const PocketBattleArenaPage({
    super.key,
    required this.neighbor,
    required this.userDay,
    required this.userStreak,
  });

  @override
  State<PocketBattleArenaPage> createState() => _PocketBattleArenaPageState();
}

class _PocketBattleArenaPageState extends State<PocketBattleArenaPage> with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  BattleMode? _activeGame;
  int _opponentHp = 100;
  int _comboStreak = 0;
  int _score = 0;
  int _earnedCoins = 0;
  bool _isGameOver = false;
  String? _lastDamageText;

  // Active game states
  Timer? _gameTimer;
  int _secondsLeft = 45;

  // Question index
  int _qIndex = 0;

  // Jigsaw game state
  List<String> _jigsawSelected = [];

  @override
  void initState() {
    super.initState();
    _initTts();
    _opponentHp = widget.neighbor.hasActiveShield ? 100 : 70;
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.48);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _startBattle(BattleMode mode) {
    HapticFeedback.heavyImpact();
    setState(() {
      _activeGame = mode;
      _secondsLeft = 45;
      _comboStreak = 0;
      _score = 0;
      _qIndex = 0;
      _jigsawSelected = [];
      _isGameOver = false;
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        _finishGame(won: _opponentHp <= 40);
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });

    // Auto speech prompt for Audio Detective
    if (mode == BattleMode.whisperPhantom) {
      _playAudioPrompt(0);
    }
  }

  void _applyDamage(int amount, {bool isCrit = false}) {
    HapticFeedback.heavyImpact();
    setState(() {
      _comboStreak++;
      final totalDmg = isCrit ? (amount * 1.5).round() : amount;
      _opponentHp = math.max(0, _opponentHp - totalDmg);
      _score += totalDmg * 10;
      _earnedCoins += (totalDmg * 0.5).round();
      _lastDamageText = isCrit ? '💥 CRIT -$totalDmg HP!' : '🎯 -$totalDmg HP!';
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _lastDamageText = null;
        });
      }
    });

    if (_opponentHp <= 0) {
      _gameTimer?.cancel();
      _finishGame(won: true);
    }
  }

  void _onIncorrect() {
    HapticFeedback.vibrate();
    setState(() {
      _comboStreak = 0;
      _lastDamageText = '🛡️ BLOCKED!';
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _lastDamageText = null;
        });
      }
    });
  }

  void _finishGame({required bool won}) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isGameOver = true;
      _earnedCoins = won ? 50 : 20;
    });
  }

  // ============================================================
  // 📚 CURATED ENGLISH LEARNING DATASETS (THE 6 VALUABLE GAMES)
  // ============================================================

  // 1. Vocab Cannonball Data
  final List<Map<String, dynamic>> _vocabQuestions = [
    {
      'word': 'Meticulous',
      'clue': 'Showing great attention to detail; very careful',
      'options': ['Careless', 'Precise & Thorough', 'Aggressive', 'Hasty'],
      'correct': 1,
    },
    {
      'word': 'Benevolent',
      'clue': 'Well meaning and kindly; generous',
      'options': ['Cruel', 'Greedy', 'Charitable & Kind', 'Hostile'],
      'correct': 2,
    },
    {
      'word': 'Tenacious',
      'clue': 'Holding firm; persistent and determined',
      'options': ['Resolute & Persistent', 'Weak', 'Indifferent', 'Lazy'],
      'correct': 0,
    },
    {
      'word': 'Eloquent',
      'clue': 'Fluent or persuasive in speaking or writing',
      'options': ['Inarticulate', 'Expressive & Fluent', 'Silent', 'Confused'],
      'correct': 1,
    },
    {
      'word': 'Resilient',
      'clue': 'Able to withstand or recover quickly from difficulties',
      'options': ['Fragile', 'Vulnerable', 'Tough & Adaptable', 'Rigid'],
      'correct': 2,
    },
  ];

  // 2. Speech Pronunciation Clash Data
  final List<Map<String, dynamic>> _speechPhrases = [
    {
      'phrase': 'Consistency is the secret to true fluency.',
      'phonetic': '/kənˈsɪs.tən.si ɪz ðə ˈsiː.krət tuː truː ˈfluː.ən.si/',
      'target': 'Consistency',
    },
    {
      'phrase': 'The grand Victorian palace stood against the skyline.',
      'phonetic': '/ðə ɡrænd vɪkˈtɔː.ri.ən ˈpæl.ɪs stʊd əˈɡenst ðə ˈskaɪ.laɪn/',
      'target': 'Victorian',
    },
    {
      'phrase': 'Practice every day to unlock your full potential.',
      'phonetic': '/ˈpræk.tɪs ˈev.ri deɪ tuː ʌnˈlɒk jɔː fʊl pəˈten.ʃəl/',
      'target': 'Potential',
    },
  ];

  // 3. Grammar Bomb Defusal Data
  final List<Map<String, dynamic>> _grammarQuestions = [
    {
      'sentence': ['Neither', 'of', 'the', 'students', 'have', 'submitted', 'their', 'papers.'],
      'wrongIndex': 4, // 'have' should be 'has'
      'correction': 'has',
      'rule': 'Rule: "Neither of..." takes a singular verb ("has", not "have").',
    },
    {
      'sentence': ['She', 'is', 'married', 'with', 'a', 'reputed', 'cardiac', 'surgeon.'],
      'wrongIndex': 3, // 'with' should be 'to'
      'correction': 'to',
      'rule': 'Rule: In English, one is married "to" someone, not "with" someone.',
    },
    {
      'sentence': ['I', 'look', 'forward', 'to', 'meet', 'you', 'next', 'Monday.'],
      'wrongIndex': 4, // 'meet' should be 'meeting'
      'correction': 'meeting',
      'rule': 'Rule: The idiom "look forward to" is followed by a gerund ("meeting").',
    },
    {
      'sentence': ['Despite', 'of', 'the', 'heavy', 'rain,', 'they', 'won', 'the', 'match.'],
      'wrongIndex': 1, // 'of' is redundant
      'correction': '(omit "of")',
      'rule': 'Rule: "Despite" never takes "of". Use "In spite of" or simply "Despite".',
    },
  ];

  // 4. Rune Catapult Data (Word Anagrams)
  final List<Map<String, dynamic>> _runePuzzles = [
    {
      'clue': 'Magnificent and splendid appearance; grandeur',
      'letters': ['S', 'P', 'L', 'E', 'N', 'D', 'O', 'R'],
      'answer': 'SPLENDOR',
    },
    {
      'clue': 'The ability to make good judgments and take quick decisions',
      'letters': ['A', 'C', 'U', 'M', 'E', 'N'],
      'answer': 'ACUMEN',
    },
    {
      'clue': 'To succeed in understanding or interpreting something cryptic',
      'letters': ['D', 'E', 'C', 'I', 'P', 'H', 'E', 'R'],
      'answer': 'DECIPHER',
    },
  ];

  // 5. Audio Detective Data
  final List<Map<String, dynamic>> _audioPuzzles = [
    {
      'fullSpeech': 'The CEO announced a groundbreaking initiative for students today.',
      'prompt': 'The CEO announced a _______ initiative for students today.',
      'options': ['groundbreaking', 'boring', 'temporary', 'failing'],
      'correct': 0,
    },
    {
      'fullSpeech': 'She demonstrated remarkable resilience throughout the rigorous debate.',
      'prompt': 'She demonstrated remarkable _______ throughout the debate.',
      'options': ['hesitation', 'resilience', 'fear', 'silence'],
      'correct': 1,
    },
    {
      'fullSpeech': 'Vocabulary retention increases drastically with daily conversational practice.',
      'prompt': 'Vocabulary retention increases _______ with daily practice.',
      'options': ['slowly', 'drastically', 'never', 'rarely'],
      'correct': 1,
    },
  ];

  // 6. Idiom Blitz Data
  final List<Map<String, dynamic>> _idiomQuestions = [
    {
      'scenario': 'Arjun stayed awake studying grammar until 3:30 AM before his exam. What was he doing?',
      'options': [
        'Biting the bullet',
        'Burning the midnight oil',
        'Spilling the beans',
        'Beating around the bush',
      ],
      'correct': 1,
      'meaning': '"Burning the midnight oil" means working or studying late into the night.',
    },
    {
      'scenario': 'Maya was feeling slightly unwell with a mild cold and headache. How would she describe it?',
      'options': [
        'Under the weather',
        'Piece of cake',
        'On cloud nine',
        'Break a leg',
      ],
      'correct': 0,
      'meaning': '"Under the weather" means slightly sick, fatigued, or unwell.',
    },
    {
      'scenario': 'Rahul gave his final proposal to the client; now it’s up to them to decide. What idiom fits?',
      'options': [
        'Once in a blue moon',
        'The ball is in their court',
        'Cost an arm and a leg',
        'Hit the nail on the head',
      ],
      'correct': 1,
      'meaning': '"The ball is in their court" means it is now someone else’s turn to take action.',
    },
  ];

  // 7. Tense Archery Data
  final List<Map<String, dynamic>> _tenseQuestions = [
    {
      'sentence': 'By the time the professor arrived, the students _______ their essays.',
      'options': ['had finished', 'have finished', 'will finish', 'are finishing'],
      'correct': 0,
      'explanation': 'Past Perfect ("had finished") is used for an action completed before another past event.',
    },
    {
      'sentence': 'If she _______ earlier, she would not have missed the international flight.',
      'options': ['had woken up', 'wakes up', 'would wake up', 'has woken up'],
      'correct': 0,
      'explanation': 'Third Conditional: "If + Past Perfect (had woken up), would have + V3".',
    },
    {
      'sentence': 'By next December, we _______ English fluently for over a full year.',
      'options': ['will have been practicing', 'have practiced', 'practiced', 'are practicing'],
      'correct': 0,
      'explanation': 'Future Perfect Continuous expresses ongoing action continuing up to a future point.',
    },
    {
      'sentence': 'Neither of the proposals _______ approved by the executive board yesterday.',
      'options': ['was', 'were', 'are', 'have been'],
      'correct': 0,
      'explanation': '"Neither of" takes a singular past verb ("was", not "were").',
    },
  ];

  // 8. Syntax Jigsaw Data (Scrambled phrase reassembly)
  final List<Map<String, dynamic>> _syntaxQuestions = [
    {
      'scrambled': ['Rarely', 'such courage', 'have we', 'witnessed'],
      'correctOrder': ['Rarely', 'have we', 'witnessed', 'such courage'],
      'fullSentence': 'Rarely have we witnessed such courage.',
      'rule': 'Negative inversion: Negative adverb "Rarely" triggers auxiliary-subject inversion.',
    },
    {
      'scrambled': ['Hardly', 'the phone rang', 'had I arrived', 'when'],
      'correctOrder': ['Hardly', 'had I arrived', 'when', 'the phone rang'],
      'fullSentence': 'Hardly had I arrived when the phone rang.',
      'rule': 'Correlative conjunction structure: "Hardly had... when..."',
    },
    {
      'scrambled': ['No sooner', 'the bell rang', 'had he entered', 'than'],
      'correctOrder': ['No sooner', 'had he entered', 'than', 'the bell rang'],
      'fullSentence': 'No sooner had he entered than the bell rang.',
      'rule': 'Correlative conjunction structure: "No sooner had... than..."',
    },
    {
      'scrambled': ['Not only', 'talented', 'is she', 'but also humble'],
      'correctOrder': ['Not only', 'is she', 'talented', 'but also humble'],
      'fullSentence': 'Not only is she talented but also humble.',
      'rule': 'Emphatic inversion: "Not only is she talented but also humble."',
    },
  ];

  // 9. Collocation Ram Data (Natural native pairings & Phrasal verbs)
  final List<Map<String, dynamic>> _collocationQuestions = [
    {
      'prompt': 'Match the natural English collocation: "Make a _______"',
      'options': ['difference', 'homework', 'exercise', 'a research'],
      'correct': 0,
      'explanation': 'In native English, we "make a difference" and "make a decision", but "do homework".',
    },
    {
      'prompt': 'Which phrasal verb means "to tolerate or endure patiently"?',
      'options': ['Put up with', 'Look down on', 'Run out of', 'Give in to'],
      'correct': 0,
      'explanation': '"Put up with" means to tolerate difficult behavior or situations.',
    },
    {
      'prompt': 'Match the natural pairing: "Pay _______ to the safety guidelines"',
      'options': ['attention', 'concentration', 'regards', 'observation'],
      'correct': 0,
      'explanation': 'The standard English collocation is "pay attention".',
    },
    {
      'prompt': 'Which phrasal verb means "to cancel an arranged event"?',
      'options': ['Call off', 'Call out', 'Turn off', 'Put on'],
      'correct': 0,
      'explanation': '"Call off" means to cancel an event or meeting.',
    },
  ];

  // 10. Riddle Sphinx Data (Context inference & logic)
  final List<Map<String, dynamic>> _riddleQuestions = [
    {
      'riddle': 'I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?',
      'options': ['An Echo', 'A Cloud', 'A Shadow', 'A Mirror'],
      'correct': 0,
      'clue': 'A sound bouncing back to you.',
    },
    {
      'riddle': 'The more of this there is in a dark room, the less you can see. What is it?',
      'options': ['Darkness', 'Dust', 'Space', 'Silence'],
      'correct': 0,
      'clue': 'The total absence of light.',
    },
    {
      'riddle': 'I have cities, but no houses. I have mountains, but no trees. I have water, but no fish. What am I?',
      'options': ['A Map', 'A Globe', 'A Painting', 'A Dream'],
      'correct': 0,
      'clue': 'A cartographic guide for explorers.',
    },
    {
      'riddle': 'What English word begins and ends with the letter "E", but only contains one single letter?',
      'options': ['An Envelope', 'An Eye', 'An Engine', 'An Eagle'],
      'correct': 0,
      'clue': 'It holds a written letter inside!',
    },
  ];

  void _playAudioPrompt(int index) {
    if (index < _audioPuzzles.length) {
      _flutterTts.speak(_audioPuzzles[index]['fullSpeech']);
    }
  }

  // ============================================================
  // 🎨 MAIN ARENA BUILD METHOD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP ARENA APP BAR ---
            _buildTopArenaHeader(),

            // --- DEFENDER'S HOUSE & LIVE SHIELD HP BAR ---
            _buildDefenderArenaStage(),

            // --- MAIN BATTLE AREA (GAMEPLAY OR GAME SELECTION) ---
            Expanded(
              child: _isGameOver
                  ? _buildVictoryLootScreen()
                  : (_activeGame == null ? _buildGameSelectionLobby() : _buildActiveGameView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopArenaHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            onPressed: () {
              if (_activeGame != null && !_isGameOver) {
                _gameTimer?.cancel();
                setState(() => _activeGame = null);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    'POCKET BATTLE ARENA',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'English PvP Raid & House Siege',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Live Coin & Score Tally
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade400, width: 1),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  '$_earnedCoins Coins',
                  style: GoogleFonts.outfit(
                    color: Colors.amber.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefenderArenaStage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _opponentHp > 40 ? const Color(0xFF0284C7) : Colors.redAccent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _opponentHp > 40 ? const Color(0xFF0284C7).withValues(alpha: 0.25) : Colors.red.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Defender Avatar
              SizedBox(
                width: 38,
                height: 38,
                child: VectorAvatarWidget(
                  config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                  size: 38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.neighbor.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Stage ${widget.neighbor.day} • ${widget.neighbor.rank}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Damage text popup
              if (_lastDamageText != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Text(
                      _lastDamageText!,
                      style: GoogleFonts.outfit(
                        color: Colors.yellowAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Shield HP Bar (Clash of Clans Style!)
          Row(
            children: [
              Text(
                _opponentHp > 50 ? '🛡️ SHIELD HP' : '⚠️ GATE DAMAGE',
                style: TextStyle(
                  color: _opponentHp > 50 ? const Color(0xFF38BDF8) : Colors.redAccent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$_opponentHp / 100 HP',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _opponentHp / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                _opponentHp > 50 ? const Color(0xFF10B981) : (_opponentHp > 25 ? Colors.amber : Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎮 GAME SELECTION LOBBY (PICK FROM THE 6 BATTLE MODES)
  // ============================================================
  Widget _buildGameSelectionLobby() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Select Your English Attack Mode',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Each game challenges a core fluency skill. Win rounds to breach their gate!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),

          // 6 Mini-Game Cards Grid
          ...kBattleModes.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: m.primaryColor.withValues(alpha: 0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: m.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: m.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: m.primaryColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(m.icon, style: const TextStyle(fontSize: 22)),
                ),
                title: Text(
                  m.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.subtitle,
                      style: TextStyle(color: m.primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                      maxLines: 2,
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: m.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _startBattle(m.mode),
                  child: Text(
                    'PLAY',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // 🎯 ACTIVE GAME VIEW ROUTER
  // ============================================================
  Widget _buildActiveGameView() {
    return Column(
      children: [
        // Live Round Timer & Combo Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _secondsLeft < 10 ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _secondsLeft < 10 ? Colors.redAccent : Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '$_secondsLeft s',
                      style: GoogleFonts.outfit(
                        color: _secondsLeft < 10 ? Colors.redAccent : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_comboStreak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    '🔥 ${_comboStreak}x COMBO!',
                    style: GoogleFonts.outfit(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Game Arena Body
        Expanded(
          child: Builder(
            builder: (context) {
              switch (_activeGame!) {
                case BattleMode.vocabCannonball:
                  return _buildVocabCannonballGame();
                case BattleMode.speechThunderbolt:
                  return _buildSpeechThunderboltGame();
                case BattleMode.grammarDefusal:
                  return _buildGrammarDefusalGame();
                case BattleMode.runeCatapult:
                  return _buildRuneCatapultGame();
                case BattleMode.whisperPhantom:
                  return _buildWhisperPhantomGame();
                case BattleMode.idiomBlitz:
                  return _buildIdiomBlitzGame();
                case BattleMode.tenseArchery:
                  return _buildTenseArcheryGame();
                case BattleMode.syntaxJigsaw:
                  return _buildSyntaxJigsawGame();
                case BattleMode.collocationRam:
                  return _buildCollocationRamGame();
                case BattleMode.riddleSphinx:
                  return _buildRiddleSphinxGame();
              }
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 1. VOCAB CANNONBALL GAMEPLAY
  // ============================================================
  Widget _buildVocabCannonballGame() {
    final q = _vocabQuestions[_qIndex % _vocabQuestions.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF818CF8)),
            ),
            child: Column(
              children: [
                const Text('🎯 TARGET WORD', style: TextStyle(color: Color(0xFF818CF8), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  q['word'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clue: ${q['clue']}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: List.generate(4, (i) {
                final isCorrect = i == q['correct'];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () {
                    if (isCorrect) {
                      _applyDamage(20, isCrit: _comboStreak >= 2);
                    } else {
                      _onIncorrect();
                    }
                    setState(() => _qIndex++);
                  },
                  child: Text(
                    q['options'][i],
                    style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. SPEECH THUNDERBOLT GAMEPLAY
  // ============================================================
  Widget _buildSpeechThunderboltGame() {
    final q = _speechPhrases[_qIndex % _speechPhrases.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF00F0FF)),
            ),
            child: Column(
              children: [
                const Text('🎙️ PRONOUNCE ACCURATELY TO STRIKE', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  '"${q['phrase']}"',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  q['phonetic'],
                  style: TextStyle(color: Colors.amber.shade200, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Audio listen button
          IconButton(
            iconSize: 42,
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF00F0FF)),
            onPressed: () => _flutterTts.speak(q['phrase']),
          ),
          const SizedBox(height: 12),
          // Tap to speak button
          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // Verified spoken simulation / mic trigger
                _applyDamage(25, isCrit: true);
                setState(() => _qIndex++);
              },
              icon: const Icon(Icons.mic, color: Colors.black),
              label: Text('TAP & SPEAK', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============================================================
  // 3. GRAMMAR BOMB DEFUSAL GAMEPLAY
  // ============================================================
  Widget _buildGrammarDefusalGame() {
    final q = _grammarQuestions[_qIndex % _grammarQuestions.length];
    final words = q['sentence'] as List<String>;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF451A03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Text('💣', style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap the INCORRECT word in the sentence below to defuse the bomb!',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(words.length, (i) {
              final isWrongWord = i == q['wrongIndex'];
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  if (isWrongWord) {
                    _applyDamage(25);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Defused! ${q['rule']}', style: GoogleFonts.outfit()),
                        backgroundColor: const Color(0xFF059669),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    _onIncorrect();
                  }
                  setState(() => _qIndex++);
                },
                child: Text(words[i], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. RUNE CATAPULT GAMEPLAY (WORD ANAGRAMS)
  // ============================================================
  Widget _buildRuneCatapultGame() {
    final q = _runePuzzles[_qIndex % _runePuzzles.length];
    final letters = q['letters'] as List<String>;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1065),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA855F7)),
            ),
            child: Column(
              children: [
                const Text('🔠 CLUE DEFINITION', style: TextStyle(color: Color(0xFFA855F7), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  q['clue'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Assemble the Rune Boulder:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: letters.map((l) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA855F7)),
                ),
                child: Text(l, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              );
            }).toList(),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              _applyDamage(30, isCrit: true);
              setState(() => _qIndex++);
            },
            icon: const Text('🪨', style: TextStyle(fontSize: 16)),
            label: Text('LAUNCH CATAPULT (${q['answer']})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // 5. WHISPER PHANTOM (AUDIO DETECTIVE)
  // ============================================================
  Widget _buildWhisperPhantomGame() {
    final q = _audioPuzzles[_qIndex % _audioPuzzles.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Column(
              children: [
                const Text('👂 LISTEN CAREFULLY TO THE CLIP', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  q['prompt'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _playAudioPrompt(_qIndex % _audioPuzzles.length),
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.black),
                  label: const Text('REPLAY AUDIO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final isCorrect = i == q['correct'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      if (isCorrect) {
                        _applyDamage(20);
                      } else {
                        _onIncorrect();
                      }
                      setState(() {
                        _qIndex++;
                        _playAudioPrompt(_qIndex % _audioPuzzles.length);
                      });
                    },
                    child: Text(q['options'][i], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 6. IDIOM BLITZ GAMEPLAY
  // ============================================================
  Widget _buildIdiomBlitzGame() {
    final q = _idiomQuestions[_qIndex % _idiomQuestions.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF831843),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEC4899)),
            ),
            child: Column(
              children: [
                const Text('⚡ REAL-WORLD IDIOM SCENARIO', style: TextStyle(color: Color(0xFFF472B6), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  q['scenario'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final isCorrect = i == q['correct'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      if (isCorrect) {
                        _applyDamage(25);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('💡 ${q['meaning']}', style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFFDB2777),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _onIncorrect();
                      }
                      setState(() => _qIndex++);
                    },
                    child: Text(q['options'][i], style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. TENSE ARCHERY (RAPID GRAMMATICAL TENSE VOLLEY)
  // ============================================================
  Widget _buildTenseArcheryGame() {
    final q = _tenseQuestions[_qIndex % _tenseQuestions.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Column(
              children: [
                const Text(
                  '🏹 AIM & SHOOT: CHOOSE THE ACCURATE TENSE',
                  style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  q['sentence'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final isCorrect = i == q['correct'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      if (isCorrect) {
                        _applyDamage(25);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🏹 Bullseye! ${q['explanation']}', style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFF059669),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _onIncorrect();
                      }
                      setState(() => _qIndex++);
                    },
                    child: Text(
                      q['options'][i],
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 8. SYNTAX JIGSAW (TREBUCHET WORD REASSEMBLY)
  // ============================================================
  Widget _buildSyntaxJigsawGame() {
    final q = _syntaxQuestions[_qIndex % _syntaxQuestions.length];
    final List<String> scrambled = List<String>.from(q['scrambled']);
    final List<String> correctOrder = List<String>.from(q['correctOrder']);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF312E81),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1)),
            ),
            child: Column(
              children: [
                const Text(
                  '🧩 SYNTAX TREBUCHET: TAP WORDS IN GRAMMATICAL ORDER',
                  style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _jigsawSelected.isEmpty
                      ? Center(
                          child: Text(
                            'Tap blocks below to assemble the siege boulder...',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _jigsawSelected
                              .map(
                                (w) => Chip(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  label: Text(
                                    w,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scrambled Block Options
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: scrambled.map((word) {
              final isUsed = _jigsawSelected.contains(word);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUsed ? const Color(0xFF334155) : const Color(0xFF1E293B),
                  foregroundColor: isUsed ? Colors.white38 : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isUsed ? Colors.white12 : const Color(0xFF6366F1)),
                ),
                onPressed: isUsed
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _jigsawSelected.add(word);
                        });

                        // Check if complete
                        if (_jigsawSelected.length == correctOrder.length) {
                          bool matches = true;
                          for (int i = 0; i < correctOrder.length; i++) {
                            if (_jigsawSelected[i] != correctOrder[i]) {
                              matches = false;
                              break;
                            }
                          }
                          if (matches) {
                            _applyDamage(30, isCrit: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎯 Trebuchet Direct Hit! ${q['rule']}', style: GoogleFonts.outfit()),
                                backgroundColor: const Color(0xFF4338CA),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Future.delayed(const Duration(milliseconds: 600), () {
                              if (mounted) {
                                setState(() {
                                  _jigsawSelected = [];
                                  _qIndex++;
                                });
                              }
                            });
                          } else {
                            _onIncorrect();
                            Future.delayed(const Duration(milliseconds: 600), () {
                              if (mounted) {
                                setState(() {
                                  _jigsawSelected = [];
                                });
                              }
                            });
                          }
                        }
                      },
                child: Text(word, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),

          const Spacer(),
          if (_jigsawSelected.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent, size: 18),
              label: const Text('RESET BLOCKS', style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _jigsawSelected = []);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ============================================================
  // 9. COLLOCATION RAM (PHRASAL VERBS & NATURAL PAIRINGS)
  // ============================================================
  Widget _buildCollocationRamGame() {
    final q = _collocationQuestions[_qIndex % _collocationQuestions.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C2D12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF97316)),
            ),
            child: Column(
              children: [
                const Text(
                  '🔨 BATTERING RAM: NATURAL ENGLISH COLLOCATIONS',
                  style: TextStyle(color: Color(0xFFFDBA74), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  q['prompt'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final isCorrect = i == q['correct'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      if (isCorrect) {
                        _applyDamage(25);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('💥 Gate Smashed! ${q['explanation']}', style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFFC2410C),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _onIncorrect();
                      }
                      setState(() => _qIndex++);
                    },
                    child: Text(
                      q['options'][i],
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 10. RIDDLE SPHINX (CONTEXT INFERENCE & MIND BREACH)
  // ============================================================
  Widget _buildRiddleSphinxGame() {
    final q = _riddleQuestions[_qIndex % _riddleQuestions.length];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF581C87),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA855F7)),
            ),
            child: Column(
              children: [
                const Text(
                  '🔮 SPHINX ENIGMA (CRITICAL MIND DAMAGE)',
                  style: TextStyle(color: Color(0xFFD8B4FE), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  q['riddle'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Clue: ${q['clue']}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final isCorrect = i == q['correct'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      if (isCorrect) {
                        _applyDamage(35, isCrit: true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✨ Sphinx Mind Breach! Correct Answer: ${q['options'][q['correct']]}', style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFF7E22CE),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _onIncorrect();
                      }
                      setState(() => _qIndex++);
                    },
                    child: Text(
                      q['options'][i],
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏆 VICTORY & LOOT SCREEN
  // ============================================================
  Widget _buildVictoryLootScreen() {
    final won = _opponentHp <= 0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(won ? '🎉' : '🛡️', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            won ? 'HOUSE DEFENSE BREACHED!' : 'TIME UP - RAID COMPLETED',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            won
                ? 'You overwhelmed ${widget.neighbor.name}’s house defenses with English fluency!'
                : 'Great effort! Practice daily to unleash stronger attacks.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text('+$_earnedCoins Coins', style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text('+${_score ~/ 2} XP', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                setState(() {
                  _activeGame = null;
                  _isGameOver = false;
                  _opponentHp = 100;
                });
              },
              child: Text(
                'CONTINUE IN ARENA',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
