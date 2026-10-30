// pocket_citadel_runner_attack_page.dart
//
// ⚔️ Pocket Mates – CITADEL ATTACK (Subway-Surfers-style 2D Runner)
// Complete gamified attack arena:
// - Subway-Surfers-style 2D runner physics (jump, slide, obstacle crates, bars, gems)
// - Gate-by-gate Defense Card assault (e.g. Day 30 user has 30 Defense Gates)
// - Gate 1 is Sentence Builder (Malayalam prompt -> build English sentence)
// - Gates feature 4 interactive challenge types: Sentence Builder, 4-Word Spelling Rectifier,
//   Word Bank Train Wagons, and Voice Echo Listening / Speaking
// - 80% Pass Mark Gatekeeper with Early Repel: If at any gate (e.g. gate 4 or 5) it becomes
//   mathematically impossible to reach 80% accuracy, the raid is immediately REPELLED with sirens
//   and a return-to-base option, saving the player's time
// - Defenders' House is at the very end of the trail: Only reachable after breaching ALL gates!
// - Courtyard assault: "ATTACK & LOOT HOUSE" fires projectiles, cracks castle walls, and bursts victory confetti
// - Full Post-Raid Report Card with detailed question-by-question mistake analysis and correct answers

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_sentence_builder_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_negative_sentence_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/day1_az_and_300vocab_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/spellings_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

enum _Ph {
  ready,
  running,
  approach,
  engage,
  challenge,
  passing,
  toHouse,
  courtyard,
  attacking,
  report,
  repelled,
}

class _Ob {
  _Ob(this.kind, this.x, [this.y = 0]);
  final int kind; // 0 crate (jump) · 1 overhead bar (slide) · 2 gem
  final double x;
  final double y;
  bool taken = false;
}

class _Pt {
  _Pt(this.kind, this.x, this.y, this.vx, this.vy, double l, this.size, this.c)
      : life = l,
        max = l;
  final int kind; // 0 confetti · 1 projectile · 2 spark
  double x, y, vx, vy, life, size, rot = 0;
  final double max;
  final Color c;
}

class _Ch {
  _Ch({
    required this.type,
    required this.instruction,
    required this.correct,
    this.prompt = '',
    this.chips = const <String>[],
    this.target = const <String>[],
    this.options = const <List<String>>[],
    this.correctIdx = const <int>[],
    this.word = '',
    this.blanks = const <int>[],
    this.emoji = '',
  });
  final int type; // 0 sentence · 1 spelling · 2 word train · 3 voice echo
  final String instruction, prompt, correct, word, emoji;
  final List<String> chips, target;
  final List<List<String>> options;
  final List<int> correctIdx, blanks;
}

class _Gr {
  _Gr(this.gate, this.type, this.question, this.mine, this.correct, this.earned,
      this.lines);
  final int gate, type;
  final String question, mine, correct;
  final double earned;
  final List<String> lines;
}

class PocketCitadelRunnerAttackPage extends StatefulWidget {
  const PocketCitadelRunnerAttackPage({
    super.key,
    required this.defenderName,
    required this.defenderLevel,
    this.defenderId,
    this.isKidMode = false,
    this.passMark = 0.8,
    this.customSentences,
    this.cardBuilder,
    this.houseBuilder,
    this.onSfx,
    this.onSpeak,
    this.onListen,
    this.onRaidFinished,
  });

  final String defenderName;
  final int defenderLevel;
  final String? defenderId;
  final bool isKidMode;
  final double passMark;
  final List<Map<String, String>>? customSentences;
  final Widget Function(BuildContext context, int day)? cardBuilder;
  final WidgetBuilder? houseBuilder;
  final void Function(String name)? onSfx;
  final Future<void> Function(String text)? onSpeak;
  final Future<String?> Function(String expected)? onListen;
  final void Function(Map<String, dynamic> result)? onRaidFinished;

  /// 🚀 Static convenient launcher from anywhere in the app
  static Future<Map<String, dynamic>?> open(
    BuildContext context, {
    required String defenderName,
    required int defenderLevel,
    String? defenderId,
    bool isKidMode = false,
    double passMark = 0.8,
    List<Map<String, String>>? customSentences,
  }) {
    return Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PocketCitadelRunnerAttackPage(
          defenderName: defenderName,
          defenderLevel: defenderLevel,
          defenderId: defenderId,
          isKidMode: isKidMode,
          passMark: passMark,
          customSentences: customSentences,
        ),
      ),
    );
  }

  @override
  State<PocketCitadelRunnerAttackPage> createState() =>
      _PocketCitadelRunnerAttackPageState();
}

class _PocketCitadelRunnerAttackPageState
    extends State<PocketCitadelRunnerAttackPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _defaultTts = FlutterTts();

  // ═══════════════════════ CHALLENGE DATA BANKS ═══════════════════════
  static const List<List<String>> _sentences = [
    ['ഞാൻ ഒരു വിദ്യാർത്ഥിയാണ്.', 'I am a student.'],
    ['എന്റെ പേര് അനു ആണ്.', 'My name is Anu.'],
    ['അവൻ എല്ലാ ദിവസവും സ്കൂളിൽ പോകുന്നു.', 'He goes to school every day.'],
    ['എനിക്ക് വെള്ളം വേണം.', 'I want water.'],
    ['നീ എവിടെ താമസിക്കുന്നു?', 'Where do you live?'],
    ['അവൾ ഒരു പുസ്തകം വായിക്കുന്നു.', 'She is reading a book.'],
    ['ഞങ്ങൾ നാളെ കൊച്ചിയിൽ പോകും.', 'We will go to Kochi tomorrow.'],
    ['ഇന്ന് വളരെ ചൂടാണ്.', 'It is very hot today.'],
    ['എനിക്ക് ഇംഗ്ലീഷ് പഠിക്കണം.', 'I want to learn English.'],
    ['അവർ ഫുട്ബോൾ കളിക്കുന്നു.', 'They are playing football.'],
    ['നിങ്ങൾ എവിടെ നിന്നാണ്?', 'Where are you from?'],
    ['ഞാൻ രാവിലെ ചായ കുടിക്കുന്നു.', 'I drink tea in the morning.'],
    ['അമ്മ അടുക്കളയിൽ പാചകം ചെയ്യുന്നു.', 'Mother is cooking in the kitchen.'],
    ['എന്റെ സഹോദരൻ ഡോക്ടറാണ്.', 'My brother is a doctor.'],
    ['ദയവായി വാതിൽ അടയ്ക്കൂ.', 'Please close the door.'],
    ['ഞാൻ ഇന്നലെ സിനിമ കണ്ടു.', 'I watched a movie yesterday.'],
    ['അവൾക്ക് പാട്ട് ഇഷ്ടമാണ്.', 'She likes songs.'],
    ['നമുക്ക് ഒരുമിച്ച് പോകാം.', 'Let us go together.'],
    ['എന്റെ അച്ഛൻ ജോലിക്ക് പോയി.', 'My father went to work.'],
    ['ബസ് എപ്പോൾ വരും?', 'When will the bus come?'],
    ['ഞാൻ തിരക്കിലാണ്.', 'I am busy.'],
    ['ഈ പുസ്തകം വളരെ രസകരമാണ്.', 'This book is very interesting.'],
    ['അവൻ വേഗത്തിൽ ഓടുന്നു.', 'He runs fast.'],
    ['നിനക്ക് എത്ര വയസ്സായി?', 'How old are you?'],
    ['ഞാൻ ഒരു മാങ്ങ തിന്നുന്നു.', 'I eat a sweet mango.'],
    ['അവൻ വലിയ വീട് പണിതു.', 'He built a grand house.'],
    ['നമ്മൾ പുതിയ ഭാഷ പഠിക്കുന്നു.', 'We learn English happily.'],
    ['സൂര്യൻ കിഴക്ക് ഉദിക്കുന്നു.', 'The sun rises in the east.'],
    ['പക്ഷികൾ ആകാശത്ത് പറക്കുന്നു.', 'Birds fly high in the sky.'],
    ['എനിക്ക് കഥ കേൾക്കാൻ ഇഷ്ടമാണ്.', 'I love to hear stories.'],
  ];

  static const List<String> _distract = [
    'the', 'a', 'is', 'are', 'to', 'in', 'very', 'not', 'does', 'was', 'were', 'will'
  ];

  // [correct, wrong1, wrong2]
  static const List<List<String>> _spell = [
    ['receive', 'recieve', 'receve'],
    ['beautiful', 'beutiful', 'beautifull'],
    ['because', 'becuase', 'becouse'],
    ['friend', 'freind', 'frend'],
    ['different', 'diffrent', 'diferent'],
    ['tomorrow', 'tommorow', 'tomorow'],
    ['school', 'scool', 'shcool'],
    ['people', 'peple', 'poeple'],
    ['family', 'famly', 'familly'],
    ['weather', 'wether', 'weathar'],
    ['library', 'libary', 'librery'],
    ['necessary', 'neccessary', 'necesary'],
    ['separate', 'seperate', 'separete'],
    ['address', 'adress', 'addres'],
    ['government', 'goverment', 'govrnment'],
    ['knowledge', 'knowlege', 'nolege'],
    ['interesting', 'intresting', 'interesing'],
    ['question', 'questoin', 'quesion'],
    ['breakfast', 'brekfast', 'breakfst'],
    ['vegetable', 'vegtable', 'vegetible'],
    ['important', 'importent', 'inportant'],
    ['language', 'langauge', 'languege'],
    ['Wednesday', 'Wensday', 'Wednsday'],
    ['calendar', 'calender', 'calandar'],
    ['defend', 'defant', 'difend'],
    ['castle', 'cassel', 'casstle'],
    ['warrior', 'warior', 'warrier'],
    ['shield', 'sheild', 'shild'],
    ['courage', 'currage', 'coradge'],
  ];

  // [word, malayalam meaning, emoji]
  static const List<List<String>> _words = [
    ['apple', 'ആപ്പിൾ', '🍎'],
    ['water', 'വെള്ളം', '💧'],
    ['school', 'സ്കൂൾ', '🏫'],
    ['mother', 'അമ്മ', '👩'],
    ['teacher', 'അധ്യാപകൻ', '🧑‍🏫'],
    ['flower', 'പൂവ്', '🌸'],
    ['window', 'ജനൽ', '🪟'],
    ['market', 'ചന്ത', '🛒'],
    ['river', 'പുഴ', '🏞️'],
    ['garden', 'തോട്ടം', '🌳'],
    ['doctor', 'ഡോക്ടർ', '🩺'],
    ['yellow', 'മഞ്ഞ', '💛'],
    ['table', 'മേശ', '🍽️'],
    ['chair', 'കസേര', '🪑'],
    ['kitchen', 'അടുക്കള', '🍳'],
    ['friend', 'സുഹൃത്ത്', '🤝'],
    ['monkey', 'കുരങ്ങ്', '🐒'],
    ['elephant', 'ആന', '🐘'],
    ['banana', 'വാഴപ്പഴം', '🍌'],
    ['coconut', 'തേങ്ങ', '🥥'],
    ['tiger', 'കടുവ', '🐅'],
    ['lion', 'സിംഹം', '🦁'],
    ['castle', 'കോട്ട', '🏰'],
    ['bridge', 'പാലം', '🌉'],
  ];

  // [correct, wrong1, wrong2]
  static const List<List<String>> _voice = [
    ['Hello, my name is Anu.', 'Hello, my name is Manu.', 'Hello, his name is Anu.'],
    ['I am from Kerala.', 'I am from Kollam.', 'I was from Kerala.'],
    ['I live in a small town.', 'I live in a small tower.', 'I leave in a small town.'],
    ['I am twelve years old.', 'I am twenty years old.', 'I am eleven years old.'],
    ['I like to play cricket.', 'I like to watch cricket.', 'I liked to play cricket.'],
    ['My favourite colour is blue.', 'My favourite colour is green.', 'My favourite colour is black.'],
    ['I study in class seven.', 'I study in class eleven.', 'I studied in class seven.'],
    ['Nice to meet you.', 'Nice to see you.', 'Nice to greet you.'],
    ['I have one brother and one sister.', 'I have one brother and two sisters.', 'I have one mother and one sister.'],
    ['Thank you for your help.', 'Thank you for your health.', 'Thanks for your help.'],
    ['I want to speak fluent English.', 'I want to speak funny English.', 'I want to speak fluently English.'],
  ];

  // Defense card themes (cycled by day)
  static const List<String> _thName = [
    'Iron Shield', 'Fire Moat', 'Ice Wall', 'Thunder Trap', 'Dragon Guard',
    'Magic Mirror', 'Giant Cannon', 'Ghost Knight', 'Star Barrier', 'Crown Vault'
  ];
  static const List<String> _thEmoji = [
    '🛡️', '🔥', '❄️', '⚡', '🐉', '🪞', '💥', '👻', '🌟', '👑'
  ];
  static const List<String> _thPower = [
    'Blocks the first strike', 'Burns intruders', 'Freezes the path',
    'Shocks attackers', 'Breathes fire', 'Reflects attacks', 'Blasts the road',
    'Haunts the walls', 'Blinds the enemy', 'Guards the treasure'
  ];
  static const List<Color> _thCol = [
    Color(0xFF42A5F5), Color(0xFFFF7043), Color(0xFF26C6DA), Color(0xFFFFCA28),
    Color(0xFF66BB6A), Color(0xFFAB47BC), Color(0xFFEF5350), Color(0xFF78909C),
    Color(0xFFFFA726), Color(0xFFEC407A),
  ];
  static const List<String> _typeTitle = [
    'Sentence Builder',
    'Spelling Detective',
    'Word Bank Train',
    'Voice Echo (Audio)',
    'Negative Sentence',
  ];

  // ═══════════════════════ STATE ═══════════════════════
  Random _rnd = Random();
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  _Ph _phase = _Ph.ready;
  late int _total;
  int _gate = 0;
  int _gems = 0;
  double _tt = 0,
      _dist = 0,
      _speed = 0,
      _lift = 0,
      _vy = 0,
      _slideT = 0,
      _hitCd = 0,
      _stumble = 0,
      _zoom = 1,
      _shake = 0,
      _runPh = 0,
      _gateOpen = 0,
      _passT = 0,
      _atkT = 0;
  bool _shattered = false, _victory = false, _won = false;
  int _atkSpawned = 0, _dmg = 0;

  static const double _baseSpeed = 330;
  static const double _approachDist = 380;
  static const double _stopGap = 165;
  static const double _houseGap = 200;

  final List<_Ob> _obs = [];
  final List<_Pt> _pts = [];

  // Challenge engine state
  late List<List<String>> _sentBank;
  late List<int> _plan;
  final List<int> _qA = [], _qB = [], _qC = [], _qD = [];
  _Ch? _cur;
  final List<_Gr> _results = [];
  double _earned = 0;
  List<int> _selA = [];
  List<int?> _pickB = [];
  List<int?> _slotC = [];
  int? _pickD;
  String? _heardD;
  bool _listening = false;

  // ═══════════════════════ LIFECYCLE ═══════════════════════
  @override
  void initState() {
    super.initState();
    _initTts();
    _newRaid();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _initTts() async {
    try {
      await _defaultTts.setLanguage('en-US');
      await _defaultTts.setPitch(1.1);
      await _defaultTts.setSpeechRate(0.44);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _defaultTts.stop();
    super.dispose();
  }

  void _newRaid() {
    _total = max(1, widget.defenderLevel);
    // Unique seed per defender and raid attempt so different defenders and re-raids have distinct questions
    final seed = (widget.defenderId?.hashCode ?? 0) ^ (widget.defenderLevel * 10007) ^ DateTime.now().minute;
    _rnd = Random(seed);

    final custom = widget.customSentences
            ?.where((m) => m['ml'] != null && m['en'] != null)
            .map((m) => <String>[m['ml']!, m['en']!])
            .toList() ??
        <List<String>>[];
    _sentBank = [..._sentences, ...custom];

    // Gate 1 = Sentence Builder (Peak Simplicity, Day 1)
    // Other gates = progressive mix among [0: Sentence, 1: Spelling, 2: Train, 3: Voice Echo, 4: Negative Sentence]
    _plan = [];
    var prev = -1;
    for (var i = 0; i < _total; i++) {
      int t;
      if (i == 0) {
        t = 0; // Sentence Builder
      } else {
        final bag = [0, 1, 2, 3, 4].where((x) => x != prev).toList();
        t = bag[_rnd.nextInt(bag.length)];
      }
      _plan.add(t);
      prev = t;
    }
    _buildTrack();
  }

  int _next(List<int> q, int n) {
    if (q.isEmpty) {
      q.addAll(List<int>.generate(n, (i) => i)..shuffle(_rnd));
    }
    return q.removeLast();
  }

  // ═══════════════════════ WORLD / TRACK ═══════════════════════
  double _gateX(int i) => 1500.0 + i * 1500.0;
  double get _houseX => _gateX(_total - 1) + 1150;

  double _cl(double v, double a, double b) => v < a ? a : (v > b ? b : v);

  double get _scale => _cl(_size.shortestSide / 400, 0.8, 1.5);
  double get _groundY =>
      _size.height * (_size.height > _size.width ? 0.66 : 0.76);
  double get _playerX =>
      _size.width * (_size.height > _size.width ? 0.24 : 0.22);
  Offset get _focal => Offset(_playerX + 95 * _scale, _groundY - 120 * _scale);

  Offset _toScreen(double wx, double wy) {
    final p = Offset(_playerX + (wx - _dist) * _scale, _groundY + wy * _scale);
    final f = _focal;
    return f + (p - f) * _zoom;
  }

  void _buildTrack() {
    _obs.clear();
    final end = _houseX - 700;
    var x = 650.0;
    while (x < end) {
      var nearGate = false;
      for (var i = 0; i < _total; i++) {
        if ((x - _gateX(i)).abs() < 560) {
          nearGate = true;
          break;
        }
      }
      if (nearGate) {
        x += 140;
        continue;
      }
      final r = _rnd.nextDouble();
      if (r < 0.42) {
        _obs.add(_Ob(0, x));
        _obs.add(_Ob(2, x - 44, -70));
        _obs.add(_Ob(2, x, -105));
        _obs.add(_Ob(2, x + 44, -70));
      } else if (r < 0.74) {
        _obs.add(_Ob(1, x));
        for (var k = -1; k <= 1; k++) {
          _obs.add(_Ob(2, x + k * 36, -22));
        }
      } else {
        for (var k = 0; k < 5; k++) {
          _obs.add(_Ob(2, x + k * 34, -26));
        }
      }
      x += 300 + _rnd.nextDouble() * 260;
    }
  }

  // ═══════════════════════ CHALLENGE ENGINE ═══════════════════════
  _Ch _makeChallenge(int g) {
    // Progressive Difficulty Scaling across the gates:
    // Gate 0 corresponds to Day 1 (Peak Simplicity).
    // As gate g approaches _total - 1, targetDay climbs towards defenderLevel (clamped to 90).
    final double progress = _total <= 1 ? 0.0 : (g / (_total - 1)).clamp(0.0, 1.0);
    final int maxLevel = max(1, min(widget.defenderLevel, 90));
    final int targetDay = (1 + (progress * (maxLevel - 1))).round().clamp(1, 90);

    switch (_plan[g]) {
      case 0:
        {
          // ── 0. SENTENCE BUILDER ──
          String mal = '';
          String eng = '';
          if (widget.isKidMode) {
            final pData = StudentCreativeWriting90DayCurriculum.getProfileData(targetDay);
            if (pData.sentences.isNotEmpty) {
              final sList = pData.sentences[_rnd.nextInt(pData.sentences.length)];
              eng = sList.join(' ');
              mal = 'Build the sentence: $eng (${pData.heroName})';
            }
          }
          if (eng.isEmpty) {
            final rounds = Pocket90DaySentenceBuilderData.getSentencesForDay(targetDay);
            if (rounds.isNotEmpty) {
              final item = rounds[_rnd.nextInt(rounds.length)];
              eng = item.sentence;
              mal = item.translationMl;
            }
          }
          if (eng.isEmpty) {
            final s = _sentBank[_next(_qA, _sentBank.length)];
            mal = s[0];
            eng = s[1];
          }

          final words = eng
              .replaceAll(RegExp(r'[.?!]+$'), '')
              .split(' ')
              .where((w) => w.isNotEmpty)
              .toList();
          final lower = words.map((w) => w.toLowerCase()).toSet();
          final extra = _distract.where((d) => !lower.contains(d)).toList()..shuffle(_rnd);
          final chips = <String>[...words, ...extra.take(min(3, max(1, 1 + g ~/ 20)))]..shuffle(_rnd);

          return _Ch(
            type: 0,
            instruction: PocketLanguageService.localize(
              en: 'Build the sentence in English (Day $targetDay)',
              ml: 'ഇംഗ്ലീഷിൽ വാക്യം ഉണ്ടാക്കൂ (Day $targetDay)',
              ta: 'ஆங்கிலத்தில் வாக்கியத்தை உருவாக்கவும் (நாள் $targetDay)',
              hi: 'अंग्रेजी में वाक्य बनाएं (दिन $targetDay)',
            ),
            prompt: PocketLanguageService.isMalayalam
                ? mal
                : PocketLanguageService.localize(
                    en: 'Assemble the sentence in English:',
                    ml: mal,
                    ta: 'ஆங்கில வாக்கியத்தை உருவாக்கவும்:',
                    hi: 'अंग्रेजी वाक्य बनाएं:',
                  ),
            correct: eng,
            chips: chips,
            target: words,
          );
        }

      case 1:
        {
          // ── 1. SPELLING DETECTIVE / RECTIFIER ──
          final opts = <List<String>>[];
          final ci = <int>[];
          final used = <String>{};

          if (targetDay <= k90UniqueSpellings.length) {
            final sp = k90UniqueSpellings[targetDay - 1];
            final correct = sp['correct']?.toString().toUpperCase() ?? 'SCHOOL';
            final wrong = sp['wrong']?.toString().toUpperCase() ?? 'SCHOL';
            final opt = [correct, wrong, '${wrong}E', '${correct}S']..shuffle(_rnd);
            opts.add(opt);
            ci.add(opt.indexOf(correct));
            used.add(correct.toLowerCase());
          }

          while (opts.length < 4) {
            final e = _spell[_next(_qB, _spell.length)];
            if (!used.add(e[0].toLowerCase())) continue;
            final o = [...e]..shuffle(_rnd);
            opts.add(o);
            ci.add(o.indexOf(e[0]));
          }

          return _Ch(
            type: 1,
            instruction: PocketLanguageService.localize(
              en: 'Spot the correct spelling (Day $targetDay)',
              ml: 'ശരിയായ സ്പെല്ലിംഗ് കണ്ടെത്തൂ (Day $targetDay)',
              ta: 'சரியான எழுத்துப்பிழையைக் கண்டறியவும் (நாள் $targetDay)',
              hi: 'सही वर्तनी पहचानें (दिन $targetDay)',
            ),
            correct: [for (var k = 0; k < 4; k++) opts[k][ci[k]]].join(', '),
            options: opts,
            correctIdx: ci,
          );
        }

      case 2:
        {
          // ── 2. WORD TRAIN WAGONS ──
          String w = '';
          String rawMeaning = '';
          String emoji = '🚂';

          final vocabPool = Day1VocabBankData.words300;
          if (vocabPool.isNotEmpty) {
            final filtered = vocabPool.where((item) {
              final len = item['word']?.toString().length ?? 0;
              return targetDay <= 20 ? (len >= 3 && len <= 5) : (len >= 5);
            }).toList();
            final item = (filtered.isNotEmpty ? filtered : vocabPool)[_rnd.nextInt(filtered.isNotEmpty ? filtered.length : vocabPool.length)];
            rawMeaning = item['meaning']?.toString() ??
                (PocketLanguageService.isMalayalam
                    ? 'ആപ്പിൾ'
                    : (PocketLanguageService.isTamil ? 'ஆப்பிள்' : 'Apple'));
            emoji = item['emoji']?.toString() ?? '🍎';
          }

          if (w.isEmpty) {
            final e = _words[_next(_qC, _words.length)];
            w = e[0];
            rawMeaning = e[1];
            emoji = e[2];
          }

          final displayMeaning = PocketLanguageService.getVocabMeaning(w, defaultFallback: rawMeaning);

          final n = w.length;
          final bc = min(max(1, (targetDay / 30).ceil()), n - 1);
          final idx = List<int>.generate(n, (i) => i)..shuffle(_rnd);
          final blanks = idx.take(bc).toList()..sort();
          final letters = blanks.map((i) => w[i]).toList();
          const abc = 'abcdefghijklmnopqrstuvwxyz';
          final decoys = <String>[];
          while (decoys.length < 3) {
            final d = abc[_rnd.nextInt(26)];
            if (!w.contains(d) && !decoys.contains(d)) decoys.add(d);
          }
          final chips = <String>[...letters, ...decoys]..shuffle(_rnd);

          return _Ch(
            type: 2,
            instruction: PocketLanguageService.localize(
              en: 'Fill the train wagons (Day $targetDay)',
              ml: 'ഒഴിഞ്ഞ അക്ഷരങ്ങൾ നിറയ്ക്കൂ (Day $targetDay)',
              ta: 'ரயில் பெட்டிகளில் விடுபட்ட எழுத்துக்களை நிரப்பவும் (நாள் $targetDay)',
              hi: 'रेलगाड़ी के डिब्बों में अक्षर भरें (दिन $targetDay)',
            ),
            prompt: displayMeaning,
            emoji: emoji,
            correct: w,
            word: w,
            blanks: blanks,
            chips: chips,
          );
        }

      case 3:
        {
          // ── 3. VOICE ECHO (AUDIO LISTENING) ──
          // NEVER show answer text on screen! User listens to spoken audio and chooses sentence!
          String spoken = '';
          String alt1 = '';
          String alt2 = '';

          final rounds = Pocket90DaySentenceBuilderData.getSentencesForDay(targetDay);
          if (rounds.isNotEmpty) {
            final item = rounds[_rnd.nextInt(rounds.length)];
            spoken = item.sentence.replaceAll(RegExp(r'[.!?]'), '').trim();
            final words = spoken.split(' ');
            if (words.length >= 3) {
              final wordsAlt1 = List<String>.from(words);
              wordsAlt1[words.length - 1] = '${words.last}s';
              alt1 = wordsAlt1.join(' ');

              final wordsAlt2 = List<String>.from(words);
              wordsAlt2[0] = words[0] == 'I' ? 'He' : 'I';
              alt2 = wordsAlt2.join(' ');
            }
          }

          if (spoken.isEmpty) {
            final e = _voice[_next(_qD, _voice.length)];
            spoken = e[0];
            alt1 = e[1];
            alt2 = e[2];
          }

          final optsList = [spoken, alt1.isNotEmpty ? alt1 : '$spoken now', alt2.isNotEmpty ? alt2 : 'Then $spoken']..shuffle(_rnd);

          return _Ch(
            type: 3,
            instruction: PocketLanguageService.localize(
              en: '🎧 Listen to audio & choose sentence (Day $targetDay)',
              ml: '🎧 കേട്ടിട്ട് വാക്യം തിരഞ്ഞെടുക്കൂ (Day $targetDay)',
              ta: '🎧 ஒலியைக் கேட்டு சரியான வாக்கியத்தைத் தேர்வுசெய்க (நாள் $targetDay)',
              hi: '🎧 ऑडियो सुनें और सही वाक्य चुनें (दिन $targetDay)',
            ),
            prompt: PocketLanguageService.localize(
              en: 'Listen to the audio clip carefully',
              ml: 'ഓഡിയോ ശ്രദ്ധിച്ചു കേൾക്കുക',
              ta: 'ஒலிப்பதிவை கவனமாகக் கேளுங்கள்',
              hi: 'ऑडियो को ध्यान से सुनें',
            ),
            correct: spoken,
            options: [optsList],
            correctIdx: [optsList.indexOf(spoken)],
          );
        }

      case 4:
      default:
        {
          // ── 4. NEGATIVE SENTENCE BUILDER ──
          String positive = '';
          String negative = '';
          String translation = '';

          final negRounds = Pocket90DayNegativeSentenceData.getRoundsForDay(targetDay);
          if (negRounds.isNotEmpty) {
            final item = negRounds[_rnd.nextInt(negRounds.length)];
            positive = item.positiveSentence.replaceAll(RegExp(r'[.!?]'), '').trim();
            negative = item.negativeSentence.replaceAll(RegExp(r'[.!?]'), '').trim();
            translation = item.negativeSentenceMl;
          }

          if (negative.isEmpty) {
            positive = 'He runs fast';
            negative = 'He does not run fast';
            translation = 'അവൻ വേഗത്തിൽ ഓടുന്നില്ല';
          }

          final targetWords = negative
              .split(' ')
              .where((w) => w.isNotEmpty)
              .toList();
          final distractors = ['is', 'was', 'did', 'not', 'are'].where((d) => !targetWords.contains(d)).take(2).toList();
          final allChips = <String>[...targetWords, ...distractors]..shuffle(_rnd);

          return _Ch(
            type: 4,
            instruction: PocketLanguageService.localize(
              en: 'Convert to Negative Sentence (Day $targetDay)',
              ml: 'നിഷേധ വാക്യമാക്കൂ (Day $targetDay)',
              ta: 'எதிர்மறை வாக்கியமாக மாற்றவும் (நாள் $targetDay)',
              hi: 'नकारात्मक वाक्य बनाएं (दिन $targetDay)',
            ),
            prompt: PocketLanguageService.isMalayalam
                ? '$positive\n($translation)'
                : PocketLanguageService.localize(
                    en: 'Transform to negative: "$positive"',
                    ml: '$positive\n($translation)',
                    ta: 'எதிர்மறையாக மாற்றவும்: "$positive"',
                    hi: 'नकारात्मक में बदलें: "$positive"',
                  ),
            correct: negative,
            chips: allChips,
            target: targetWords,
          );
        }
    }
  }

  bool _canSubmit(_Ch ch) {
    switch (ch.type) {
      case 0:
      case 4:
        return _selA.isNotEmpty;
      case 1:
        return !_pickB.contains(null);
      case 2:
        return !_slotC.contains(null);
      default:
        return _pickD != null;
    }
  }

  void _submit() {
    final ch = _cur!;
    var earned = 0.0;
    var mine = '';
    var question = '';
    final lines = <String>[];

    switch (ch.type) {
      case 0:
      case 4:
        {
          mine = _selA.map((i) => ch.chips[i]).join(' ');
          final ok = mine.toLowerCase().trim() == ch.target.join(' ').toLowerCase().trim();
          earned = ok ? 1 : 0;
          question = ch.prompt;
          break;
        }
      case 1:
        {
          final m = <String>[];
          for (var k = 0; k < 4; k++) {
            final pick = _pickB[k]!;
            final ok = pick == ch.correctIdx[k];
            final right = ch.options[k][ch.correctIdx[k]];
            final got = ch.options[k][pick];
            if (ok) earned += 0.25;
            m.add(got);
            lines.add(ok ? '✔ $got' : '✖ $got  →  $right');
          }
          mine = m.join(', ');
          question = 'Pick the correct spelling (4 words)';
          break;
        }
      case 2:
        {
          final chars = ch.word.split('');
          for (var b = 0; b < ch.blanks.length; b++) {
            chars[ch.blanks[b]] = ch.chips[_slotC[b]!];
          }
          mine = chars.join();
          earned = mine == ch.word ? 1 : 0;
          question = '${ch.emoji} ${ch.prompt}';
          break;
        }
      default:
        {
          final o = ch.options[0];
          mine = o[_pickD!];
          earned = _pickD == ch.correctIdx[0] ? 1 : 0;
          question = 'Voice Echo – choose the sentence you heard';
          break;
        }
    }

    _results.add(_Gr(_gate, ch.type, question, mine, ch.correct, earned, lines));
    _earned += earned;

    // 🛡️ 80% Gatekeeper check:
    // If it becomes mathematically impossible to reach 80% (failed too many),
    // stop immediately and repel the raid.
    final remaining = _total - _results.length;
    final impossible = _earned + remaining < widget.passMark * _total - 1e-9;

    HapticFeedback.mediumImpact();
    setState(() {
      _cur = null;
      if (impossible) {
        _phase = _Ph.repelled;
        _won = false;
        _sfx('alarm');
        _alarmBuzz();
      } else {
        // Gate opens smoothly, no spoiler interruptions, resumes running to next gate!
        _phase = _Ph.passing;
        _passT = 0;
        _gateOpen = 0;
        _shattered = false;
      }
    });
  }

  Future<void> _alarmBuzz() async {
    for (var i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 220));
    }
  }

  void _afterGate() {
    _gate++;
    _gateOpen = 0;
    _passT = 0;
    _shattered = false;
    setState(() {
      _phase = _gate >= _total ? _Ph.toHouse : _Ph.running;
    });
  }

  double get _acc => _earned / _total;
  int get _xp => _won ? 50 + (_acc * 100).round() + _gems : (_acc * 20).round();
  int get _stars => !_won ? 0 : (_acc >= 0.999 ? 3 : (_acc >= 0.9 ? 2 : 1));
  int get _loot => _won ? (_earned * 10).round() : 0;

  // ═══════════════════════ SFX ENGINE ═══════════════════════
  void _sfx(String n) {
    if (widget.onSfx != null) {
      widget.onSfx!(n);
      return;
    }
    // High-performance built-in SFX fallbacks
    switch (n) {
      case 'jump':
      case 'slide':
        PocketGameSfx.instance.playTilePop();
        break;
      case 'gem':
        PocketGameSfx.instance.playSnapCorrect();
        break;
      case 'hit':
      case 'alarm':
        PocketGameSfx.instance.playErrorBuzz();
        break;
      case 'victory':
        PocketGameSfx.instance.playVictory();
        break;
      case 'fire':
      case 'impact':
      case 'card_shatter':
        PocketGameSfx.instance.playTilePop();
        break;
    }
  }

  // ═══════════════════════ INPUT ═══════════════════════
  bool get _canMove =>
      _phase == _Ph.running || _phase == _Ph.approach || _phase == _Ph.toHouse;

  void _jump() {
    if (!_canMove) return;
    if (_lift <= 0.01 && _slideT <= 0) {
      _vy = 900;
      _sfx('jump');
      HapticFeedback.selectionClick();
    }
  }

  void _slide() {
    if (!_canMove) return;
    if (_lift <= 0.01) {
      _slideT = 0.65;
      _sfx('slide');
      HapticFeedback.selectionClick();
    } else {
      _vy = -1300; // fast-fall
    }
  }

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowUp ||
        e.logicalKey == LogicalKeyboardKey.space) {
      _jump();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      _slide();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _startRun() {
    setState(() => _phase = _Ph.running);
    HapticFeedback.mediumImpact();
  }

  void _engageTap() {
    final ch = _makeChallenge(_gate);
    setState(() {
      _cur = ch;
      _selA = [];
      _pickB = List<int?>.filled(4, null);
      _slotC = List<int?>.filled(ch.blanks.length, null);
      _pickD = null;
      _heardD = null;
      _listening = false;
      _phase = _Ph.challenge;
    });
    if (ch.type == 3) {
      Future.delayed(const Duration(milliseconds: 350), () => _speak(ch));
    }
  }

  void _startAttack() {
    HapticFeedback.heavyImpact();
    setState(() {
      _phase = _Ph.attacking;
      _atkT = 0;
      _atkSpawned = 0;
      _dmg = 0;
      _victory = false;
    });
  }

  Future<void> _speak(_Ch ch) async {
    HapticFeedback.selectionClick();
    _sfx('speak');
    if (widget.onSpeak != null) {
      await widget.onSpeak!(ch.correct);
    } else {
      try {
        await _defaultTts.speak(ch.correct);
      } catch (_) {}
    }
  }

  Future<void> _speakBack(_Ch ch) async {
    if (widget.onListen == null) return;
    setState(() => _listening = true);
    String? heard;
    try {
      heard = await widget.onListen!(ch.correct);
    } catch (_) {
      heard = null;
    }
    if (!mounted) return;
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r"[^a-z0-9' ]"), '').trim();
    final exp = norm(ch.correct).split(' ');
    final got = norm(heard ?? '').split(' ').toSet();
    final hit = exp.where(got.contains).length / exp.length;
    setState(() {
      _listening = false;
      _heardD = heard;
      if (hit >= 0.8) _pickD = ch.correctIdx[0];
    });
  }

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: const Text('Abort the citadel raid?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Your running and card breach progress on this citadel will be discarded.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('KEEP RUNNING',
                style: TextStyle(color: Color(0xFF38BDF8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('ABORT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.of(context).pop();
  }

  Map<String, dynamic> _resultMap() => {
        'passed': _won,
        'accuracy': _acc,
        'gatesAttempted': _results.length,
        'totalGates': _total,
        'gems': _gems,
        'xp': _xp,
        'stars': _stars,
        'lootPoints': _loot,
        'defenderId': widget.defenderId,
        'defenderName': widget.defenderName,
        'gates': [
          for (final r in _results)
            {
              'gate': r.gate + 1,
              'type': _typeTitle[r.type],
              'question': r.question,
              'yourAnswer': r.mine,
              'correctAnswer': r.correct,
              'score': r.earned,
            }
        ],
      };

  Future<void> _finish() async {
    final m = _resultMap();
    if (_won) {
      if (widget.isKidMode) {
        await PocketKidsService.addStars(15);
      }
    }
    widget.onRaidFinished?.call(m);
    if (mounted) Navigator.of(context).pop(m);
  }

  // ═══════════════════════ GAME LOOP ═══════════════════════
  void _onTick(Duration el) {
    final dt = _cl((el - _last).inMicroseconds / 1e6, 0, 0.05);
    _last = el;
    _update(dt);
    _frame.value++;
  }

  void _update(double dt) {
    if (_size.isEmpty) return;
    _tt += dt;
    if (_shake > 0) _shake = max(0.0, _shake - dt);
    if (_hitCd > 0) _hitCd -= dt;

    final zt = (_phase == _Ph.engage ||
            _phase == _Ph.challenge ||
            _phase == _Ph.passing)
        ? 1.28
        : 1.0;
    _zoom += (zt - _zoom) * _cl(dt * 4.5, 0, 1);

    _physics(dt);

    switch (_phase) {
      case _Ph.running:
      case _Ph.approach:
      case _Ph.toHouse:
        _runStep(dt);
        break;
      case _Ph.passing:
        _speed = max(0.0, _speed - 900 * dt);
        _passT += dt;
        _gateOpen = _cl(_passT / 0.6, 0, 1);
        if (!_shattered && _passT > 0.12) {
          _shattered = true;
          final col = _thCol[_gate % _thCol.length];
          _burst(_toScreen(_gateX(_gate), -130), 28,
              [col, Colors.white, const Color(0xFFFFD600)],
              speed: 280, kind: 0, size: 9, life: 1.1);
          _sfx('card_shatter');
          HapticFeedback.heavyImpact();
        }
        if (_passT >= 0.85) _afterGate();
        break;
      case _Ph.courtyard:
        _speed = max(0.0, _speed - 900 * dt);
        if (_rnd.nextDouble() < 0.6) {
          final w = _size.width;
          final by = _size.height - 90;
          final at = Offset(w / 2 + (_rnd.nextDouble() - 0.5) * 260,
              by + (_rnd.nextDouble() - 0.5) * 30);
          final a = -pi / 2 + (_rnd.nextDouble() - 0.5) * 1.6;
          final v = 90 + _rnd.nextDouble() * 160;
          _pts.add(_Pt(
              2,
              at.dx,
              at.dy,
              cos(a) * v,
              sin(a) * v,
              0.6 + _rnd.nextDouble() * 0.4,
              3 + _rnd.nextDouble() * 3,
              _rnd.nextBool()
                  ? const Color(0xFFFFEA00)
                  : const Color(0xFFFF6D00)));
        }
        break;
      case _Ph.attacking:
        _speed = max(0.0, _speed - 900 * dt);
        _atkT += dt;
        while (_atkSpawned < 8 && _atkT >= _atkSpawned * 0.2) {
          _fire();
          _atkSpawned++;
        }
        if (!_victory && _atkT >= 2.0) {
          _victory = true;
          _won = true;
          _sfx('victory');
          HapticFeedback.heavyImpact();
          _confetti(140);
        }
        if (_victory && _atkT < 3.4 && _rnd.nextDouble() < 0.5) _confetti(4);
        if (_atkT >= 3.6) setState(() => _phase = _Ph.report);
        break;
      default:
        _speed = max(0.0, _speed - 900 * dt);
        break;
    }

    _dist += _speed * dt;
    _runPh += _speed * dt * 0.05;
    _updateParticles(dt);
  }

  void _physics(double dt) {
    if (_slideT > 0) _slideT -= dt;
    if (_lift > 0 || _vy > 0) {
      _vy -= 2600 * dt;
      _lift += _vy * dt;
      if (_lift <= 0) {
        _lift = 0;
        _vy = 0;
      }
    }
  }

  void _runStep(double dt) {
    var target = _baseSpeed;

    if (_phase == _Ph.running) {
      if (_gate < _total && _gateX(_gate) - _dist <= _approachDist) {
        _phase = _Ph.approach;
        _sfx('gate_approach');
        HapticFeedback.lightImpact();
        setState(() {});
      }
    }
    if (_phase == _Ph.approach) {
      final stopAt = _gateX(_gate) - _stopGap;
      final remain = stopAt - _dist;
      target = _cl(remain * 2.4, 45, _baseSpeed);
      if (remain <= 1.5) {
        _dist = stopAt;
        _speed = 0;
        _phase = _Ph.engage;
        _sfx('gate_engage');
        HapticFeedback.mediumImpact();
        setState(() {});
        return;
      }
    } else if (_phase == _Ph.toHouse) {
      final stopAt = _houseX - _houseGap;
      final remain = stopAt - _dist;
      target = _cl(remain * 2.4, 45, _baseSpeed);
      if (remain <= 1.5) {
        _dist = stopAt;
        _speed = 0;
        _phase = _Ph.courtyard;
        HapticFeedback.mediumImpact();
        setState(() {});
        return;
      }
    }

    if (_stumble > 0) {
      target *= 0.55;
      _stumble -= dt;
    }
    _speed += _cl(target - _speed, -900 * dt, 600 * dt);
    _collide();
  }

  void _collide() {
    final standing = _slideT > 0 ? 28.0 : 68.0;
    final pr = Rect.fromLTRB(-9, -(_lift + standing) + 4, 9, -_lift);
    for (final o in _obs) {
      if (o.taken) continue;
      final dx = o.x - _dist;
      if (dx < -60 || dx > 60) continue;
      if (o.kind == 2) {
        final gr =
            Rect.fromCenter(center: Offset(dx, o.y), width: 24, height: 24);
        if (gr.overlaps(pr)) {
          o.taken = true;
          _gems++;
          _sfx('gem');
          HapticFeedback.selectionClick();
          _burst(_toScreen(o.x, o.y), 6,
              [const Color(0xFF18FFFF), Colors.white],
              speed: 120, size: 3, life: 0.4);
        }
      } else if (_hitCd <= 0) {
        final r = o.kind == 0
            ? Rect.fromLTRB(dx - 19, -38, dx + 19, 0)
            : Rect.fromLTRB(dx - 22, -72, dx + 22, -50);
        if (r.overlaps(pr)) {
          _hitCd = 1.1;
          _stumble = 0.6;
          _gems = max(0, _gems - 2);
          _shake = 0.3;
          _sfx('hit');
          HapticFeedback.heavyImpact();
        }
      }
    }
  }

  void _burst(Offset at, int n, List<Color> cols,
      {double speed = 200, int kind = 2, double size = 4, double life = 0.7}) {
    if (_pts.length > 500) return;
    for (var i = 0; i < n; i++) {
      final a = _rnd.nextDouble() * pi * 2;
      final v = speed * (0.35 + _rnd.nextDouble() * 0.65);
      _pts.add(_Pt(
          kind,
          at.dx,
          at.dy,
          cos(a) * v,
          sin(a) * v - 40,
          life * (0.7 + _rnd.nextDouble() * 0.5),
          size * (0.6 + _rnd.nextDouble() * 0.8),
          cols[_rnd.nextInt(cols.length)]));
    }
  }

  void _confetti(int n) {
    if (_pts.length > 500) return;
    const cols = [
      Color(0xFFFF1744), Color(0xFFFFEA00), Color(0xFF00E676),
      Color(0xFF2979FF), Color(0xFFD500F9), Color(0xFFFF9100)
    ];
    for (var i = 0; i < n; i++) {
      _pts.add(_Pt(
          0,
          _rnd.nextDouble() * _size.width,
          -10,
          (_rnd.nextDouble() - 0.5) * 120,
          80 + _rnd.nextDouble() * 200,
          3 + _rnd.nextDouble(),
          8 + _rnd.nextDouble() * 6,
          cols[_rnd.nextInt(cols.length)]));
    }
  }

  void _fire() {
    final from = _toScreen(_dist + 15, -55);
    final to = _toScreen(
        _houseX + (_rnd.nextDouble() - 0.5) * 80, -90 - _rnd.nextDouble() * 50);
    const t = 0.55;
    _pts.add(_Pt(
        1,
        from.dx,
        from.dy,
        (to.dx - from.dx) / t,
        (to.dy - from.dy) / t,
        t,
        9,
        const Color(0xFFFFEB3B)));
    _sfx('fire');
    HapticFeedback.lightImpact();
  }

  void _updateParticles(double dt) {
    if (_pts.isEmpty) return;
    for (final p in _pts) {
      p.life -= dt;
      if (p.kind == 1) {
        p.x += p.vx * dt;
        p.y += p.vy * dt;
      } else {
        p.vy += (p.kind == 0 ? 500 : 220) * dt;
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.rot += dt * 6;
      }
    }
    final impacts = <Offset>[
      for (final p in _pts)
        if (p.life <= 0 && p.kind == 1) Offset(p.x, p.y)
    ];
    _pts.removeWhere((p) => p.life <= 0);
    for (final at in impacts) {
      _burst(
          at, 22, [const Color(0xFFFF6D00), const Color(0xFFFFEA00), Colors.white],
          speed: 300, size: 5, life: 0.7);
      _dmg++;
      _shake = 0.25;
      _sfx('impact');
      HapticFeedback.mediumImpact();
    }
  }

  // ═══════════════════════ CANVAS PAINTING ═══════════════════════
  double _hash(int n) {
    final v = sin(n * 12.9898 + 78.233) * 43758.5453;
    return v - v.floor();
  }

  Paint _stroke([double w = 3]) => Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void _box(Canvas c, Rect r, Color fill, {double rad = 0, double sw = 3}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(rad));
    c.drawRRect(rr, Paint()..color = fill);
    c.drawRRect(rr, _stroke(sw));
  }

  void _txt(Canvas c, String t, Offset center, double size, Color col,
      {bool bold = true, double maxW = 300}) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: size,
          color: col,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black54, offset: Offset(1.5, 1.5))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxW);
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintScene(Canvas c, Size size) {
    final w = size.width, h = size.height;
    final s = _scale, gy = _groundY, px = _playerX;

    // Sky gradient
    c.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E9BF0), Color(0xFF9EDBFF), Color(0xFFFFF1C1)],
        ).createShader(Offset.zero & size),
    );
    c.drawCircle(
        Offset(w * 0.82, gy * 0.3), 34 * s, Paint()..color = const Color(0xFFFFD54F));
    for (var i = 0; i < 4; i++) {
      final cx = w + 120 - ((i * 190.0 + _dist * 0.05 + _tt * 6) % (w + 240));
      final cy = gy * (0.18 + 0.12 * i);
      final p = Paint()..color = Colors.white.withValues(alpha: 0.9);
      c.drawCircle(Offset(cx, cy), 20 * s, p);
      c.drawCircle(Offset(cx + 22 * s, cy + 4 * s), 16 * s, p);
      c.drawCircle(Offset(cx - 22 * s, cy + 5 * s), 14 * s, p);
    }

    // World transform
    c.save();
    if (_shake > 0) {
      c.translate((_rnd.nextDouble() - 0.5) * 18 * _shake,
          (_rnd.nextDouble() - 0.5) * 18 * _shake);
    }
    final f = _focal;
    c.translate(f.dx, f.dy);
    c.scale(_zoom);
    c.translate(-f.dx, -f.dy);
    c.translate(px, gy);
    c.scale(s);

    final left = -px / s - 20,
        right = (w - px) / s + 20,
        bottom = (h - gy) / s + 20;

    // Far skyline
    {
      final off = _dist * 0.15;
      for (var i = ((left + off) / 80).floor();
          i <= ((right + off) / 80).ceil();
          i++) {
        final x = i * 80 - off;
        final hh = 50 + _hash(i) * 120;
        c.drawRect(
            Rect.fromLTWH(x, -hh, 70, hh), Paint()..color = const Color(0xFF8FB8D9));
        c.drawRect(
            Rect.fromLTWH(x, -hh, 70, 6), Paint()..color = const Color(0xFF6E9CC0));
        for (var wy = 18.0; wy < hh - 10; wy += 24) {
          c.drawRect(Rect.fromLTWH(x + 12, -hh + wy, 10, 10),
              Paint()..color = const Color(0xFFDCEEFF));
          c.drawRect(Rect.fromLTWH(x + 40, -hh + wy, 10, 10),
              Paint()..color = const Color(0xFFDCEEFF));
        }
      }
    }
    // Mid trees
    {
      final off = _dist * 0.45;
      for (var i = ((left + off) / 110).floor();
          i <= ((right + off) / 110).ceil();
          i++) {
        final x = i * 110 - off + _hash(i + 99) * 30;
        final r = 26 + _hash(i + 7) * 14;
        c.drawRect(Rect.fromLTWH(x - 5, -50, 10, 50),
            Paint()..color = const Color(0xFF6D4C41));
        c.drawCircle(
            Offset(x, -62), r, Paint()..color = const Color(0xFF43A047));
        c.drawCircle(Offset(x - r * 0.4, -70), r * 0.6,
            Paint()..color = const Color(0xFF66BB6A));
      }
    }
    // Ground
    for (var i = ((left + _dist) / 80).floor();
        i <= ((right + _dist) / 80).ceil();
        i++) {
      final x = i * 80 - _dist;
      c.drawRect(
          Rect.fromLTWH(x, 46, 80, bottom),
          Paint()
            ..color = i.isEven
                ? const Color(0xFF7CC86B)
                : const Color(0xFF6DBB5C));
    }
    c.drawRect(
        Rect.fromLTRB(left, 0, right, 46), Paint()..color = const Color(0xFFB07A4F));
    final brick = Paint()
      ..color = const Color(0xFF8D5B36)
      ..strokeWidth = 2;
    for (var i = ((left + _dist) / 48).floor();
        i <= ((right + _dist) / 48).ceil();
        i++) {
      final x = i * 48 - _dist;
      c.drawLine(Offset(x, 0), Offset(x, 23), brick);
      c.drawLine(Offset(x + 24, 23), Offset(x + 24, 46), brick);
    }
    c.drawLine(Offset(left, 23), Offset(right, 23), brick);
    c.drawLine(Offset(left, 0), Offset(right, 0), _stroke(3));
    c.drawLine(Offset(left, 46), Offset(right, 46), _stroke(3));

    // Gates
    for (var i = 0; i < _total; i++) {
      final gx = _gateX(i) - _dist;
      if (gx < left - 140 || gx > right + 140) continue;
      _drawGate(c, i, gx);
    }
    // House at the very end
    final hx = _houseX - _dist;
    if (!_hasCustomHouse && hx > left - 260 && hx < right + 260) {
      _drawHouse(c, hx);
    }
    // Obstacles + gems
    for (final o in _obs) {
      final x = o.x - _dist;
      if (x < left - 60 || x > right + 60 || o.taken) continue;
      if (o.kind == 0) {
        _drawCrate(c, x);
      } else if (o.kind == 1) {
        _drawBar(c, x);
      } else {
        _drawGem(c, x, o.y + sin(_tt * 4 + o.x) * 3);
      }
    }
    _drawPlayer(c);
    c.restore();

    // Screen-space particles
    for (final p in _pts) {
      final a = _cl(p.life / p.max, 0, 1);
      final paint = Paint()..color = p.c.withValues(alpha: _cl(a * 1.3, 0, 1));
      if (p.kind == 0) {
        c.save();
        c.translate(p.x, p.y);
        c.rotate(p.rot);
        c.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.55),
            paint);
        c.restore();
      } else if (p.kind == 1) {
        c.drawCircle(Offset(p.x, p.y), p.size * 1.7,
            Paint()..color = const Color(0x66FF9800));
        c.drawCircle(
            Offset(p.x, p.y), p.size, Paint()..color = const Color(0xFFFFEB3B));
        c.drawCircle(
            Offset(p.x, p.y), p.size * 0.45, Paint()..color = Colors.white);
      } else {
        c.drawCircle(Offset(p.x, p.y), max(0.5, p.size * a), paint);
      }
    }
    // Hit flash
    if (_hitCd > 0.9) {
      c.drawRect(
          Offset.zero & size,
          Paint()..color = Colors.red.withValues(alpha: (_hitCd - 0.9) * 1.6));
    }
  }

  void _drawCrate(Canvas c, double x) {
    _box(c, Rect.fromLTWH(x - 20, -40, 40, 40), const Color(0xFFD7933F), rad: 3);
    final l = _stroke(2);
    c.drawLine(Offset(x - 20, -40), Offset(x + 20, 0), l);
    c.drawLine(Offset(x + 20, -40), Offset(x - 20, 0), l);
  }

  void _drawBar(Canvas c, double x) {
    _box(c, Rect.fromLTWH(x - 24, -72, 6, 72), const Color(0xFF9E9E9E));
    _box(c, Rect.fromLTWH(x + 18, -72, 6, 72), const Color(0xFF9E9E9E));
    _box(c, Rect.fromLTWH(x - 28, -72, 56, 22), const Color(0xFFFFD600),
        rad: 3);
    for (var k = 0; k < 4; k++) {
      c.drawRect(Rect.fromLTWH(x - 24 + k * 14, -72, 7, 22),
          Paint()..color = Colors.black87);
    }
  }

  void _drawGem(Canvas c, double x, double y) {
    final p = Path()
      ..moveTo(x, y - 11)
      ..lineTo(x + 10, y)
      ..lineTo(x, y + 11)
      ..lineTo(x - 10, y)
      ..close();
    c.drawPath(p, Paint()..color = const Color(0xFF18FFFF));
    c.drawPath(p, _stroke(2));
    c.drawCircle(Offset(x - 3, y - 3), 2.2, Paint()..color = Colors.white);
  }

  void _drawPlayer(Canvas c) {
    c.drawOval(
        Rect.fromCenter(
            center: const Offset(0, 2),
            width: max(10.0, 34 - _lift * 0.12),
            height: 8),
        Paint()..color = Colors.black26);
    if (_hitCd > 0 && ((_tt * 18).floor() % 2 == 0)) return;

    c.save();
    c.translate(0, -_lift);
    final sliding = _slideT > 0;
    if (sliding) c.rotate(-1.35);
    final moving = _speed > 20;
    final air = _lift > 1;
    final sw = air ? 0.7 : (moving ? sin(_runPh) : 0.0);
    final double bob = (air || sliding)
        ? 0.0
        : (moving ? -sin(_runPh * 2).abs() * 2.5 : sin(_tt * 3) * 1.2);
    c.translate(0, bob);

    void leg(double a, Color col) {
      final foot = Offset(sin(a) * 14, -28 + cos(a) * 26);
      c.drawLine(
          const Offset(0, -28),
          foot,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 11
            ..strokeCap = StrokeCap.round);
      c.drawLine(
          const Offset(0, -28),
          foot,
          Paint()
            ..color = col
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round);
      c.drawCircle(
          foot + const Offset(3, 0), 6, Paint()..color = const Color(0xFFE53935));
      c.drawCircle(foot + const Offset(3, 0), 6, _stroke(2));
    }

    void arm(double b, Color col) {
      final hand = Offset(sin(b) * 15, -50 + cos(b) * 18);
      c.drawLine(
          const Offset(0, -50),
          hand,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round);
      c.drawLine(
          const Offset(0, -50),
          hand,
          Paint()
            ..color = col
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round);
    }

    final legA = sliding ? 0.3 : sw * 0.9;
    final legB = sliding ? 0.5 : (air ? -0.7 : -sw * 0.9);
    arm(sliding ? -0.4 : -sw * 0.9, const Color(0xFFFF7043));
    leg(legB, const Color(0xFF1E3A8A));
    _box(c, Rect.fromLTRB(-19, -54, -9, -34), const Color(0xFF7E57C2), rad: 4);
    leg(legA, const Color(0xFF1E3A8A));
    _box(c, Rect.fromLTRB(-11, -58, 11, -26), const Color(0xFFFF7043), rad: 7);
    arm(sliding ? 0.4 : sw * 0.9, const Color(0xFFFF7043));
    c.drawCircle(
        const Offset(0, -68), 12, Paint()..color = const Color(0xFFFFCC99));
    c.drawCircle(const Offset(0, -68), 12, _stroke(3));
    _box(c, Rect.fromLTRB(-12, -83, 12, -73), const Color(0xFFE53935), rad: 5);
    _box(c, Rect.fromLTRB(4, -76, 20, -72), const Color(0xFFB71C1C),
        rad: 2, sw: 2);
    c.drawCircle(const Offset(6, -67), 2, Paint()..color = Colors.black);
    c.restore();
  }

  void _drawGate(Canvas c, int i, double x) {
    final col = _thCol[i % _thCol.length];
    final open = i < _gate ? 1.0 : (i == _gate ? _gateOpen : 0.0);
    final current =
        i == _gate && (_phase == _Ph.engage || _phase == _Ph.approach);

    // Passage backdrop
    c.drawRect(
        Rect.fromLTRB(x - 58, -234, x + 58, 0),
        Paint()..color = const Color(0xFF263238));
    // Bars (slide up when breached)
    c.save();
    c.clipRect(Rect.fromLTRB(x - 58, -234, x + 58, 0));
    c.translate(0, -open * 236);
    final bar = Paint()..color = const Color(0xFF90A4AE);
    for (var bx = x - 52; bx <= x + 52; bx += 14) {
      c.drawRect(Rect.fromLTWH(bx, -234, 6, 234), bar);
    }
    c.drawRect(Rect.fromLTWH(x - 58, -120, 116, 6), bar);
    c.restore();

    // Pillars + lintel
    _box(c, Rect.fromLTWH(x - 78, -240, 20, 240), const Color(0xFFBDBDBD));
    _box(c, Rect.fromLTWH(x + 58, -240, 20, 240), const Color(0xFFBDBDBD));
    _box(c, Rect.fromLTWH(x - 86, -266, 172, 28), const Color(0xFF9E9E9E),
        rad: 4);
    for (var k = 0; k < 5; k++) {
      _box(c, Rect.fromLTWH(x - 82 + k * 36, -280, 18, 14),
          const Color(0xFF9E9E9E), sw: 2);
    }
    _txt(c, 'DAY ${i + 1}', Offset(x, -252), 15, Colors.white);

    // Defense Card suspended at the gate
    if (open < 0.25) {
      final sc = 1 - open * 4;
      if (current) {
        final g = 0.5 + 0.5 * sin(_tt * 6);
        c.drawCircle(
            Offset(x, -130),
            84 + g * 8,
            Paint()
              ..color =
                  const Color(0xFFFFEA00).withValues(alpha: 0.25 + 0.2 * g));
      }
      c.save();
      c.translate(x, -130);
      c.scale(sc);
      final r = Rect.fromCenter(center: Offset.zero, width: 92, height: 132);
      c.drawRRect(
          RRect.fromRectAndRadius(
              r.shift(const Offset(5, 5)), const Radius.circular(10)),
          Paint()..color = Colors.black);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(10));
      c.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(col, Colors.white, 0.45)!, col],
            ).createShader(r));
      c.drawRRect(rr, _stroke(4));
      _txt(c, 'DAY ${i + 1}', const Offset(0, -50), 16, Colors.white);
      _txt(c, _thEmoji[i % _thEmoji.length], const Offset(0, -6), 44,
          Colors.white);
      _txt(c, _thName[i % _thName.length], const Offset(0, 40), 11,
          Colors.white, maxW: 84);
      _txt(c, _thPower[i % _thPower.length], const Offset(0, 56), 8,
          Colors.white, bold: false, maxW: 84);
      c.restore();
    }
  }

  void _drawHouse(Canvas c, double x) {
    c.drawOval(
        Rect.fromCenter(center: Offset(x, 4), width: 300, height: 16),
        Paint()..color = Colors.black26);
    // Bushes
    for (final bx in [x - 170, x + 170, x - 200, x + 200]) {
      c.drawCircle(Offset(bx, -14), 20, Paint()..color = const Color(0xFF2E7D32));
      c.drawCircle(Offset(bx, -14), 20, _stroke(2));
    }
    // Towers
    for (final tx in [x - 140, x + 90]) {
      _box(c, Rect.fromLTWH(tx, -210, 50, 210), const Color(0xFFFFE0B2));
      for (var k = 0; k < 3; k++) {
        _box(c, Rect.fromLTWH(tx + k * 19, -222, 12, 12),
            const Color(0xFFFFE0B2), sw: 2);
      }
      _box(c, Rect.fromLTWH(tx + 17, -170, 16, 28), const Color(0xFF4FC3F7),
          rad: 8, sw: 2);
    }
    // Walls
    _box(c, Rect.fromLTWH(x - 110, -150, 220, 150), const Color(0xFFFFF3E0));
    // Roof
    final roof = Path()
      ..moveTo(x - 124, -150)
      ..lineTo(x, -236)
      ..lineTo(x + 124, -150)
      ..close();
    c.drawPath(roof, Paint()..color = const Color(0xFFE53935));
    c.drawPath(roof, _stroke(3.5));
    // Door
    _box(c, Rect.fromLTWH(x - 24, -72, 48, 72), const Color(0xFF6D4C41),
        rad: 22);
    c.drawCircle(
        Offset(x + 12, -34), 3, Paint()..color = const Color(0xFFFFD600));
    // Windows
    for (final wx in [x - 84, x + 52]) {
      _box(c, Rect.fromLTWH(wx, -118, 32, 34), const Color(0xFF81D4FA),
          rad: 3);
      c.drawLine(Offset(wx + 16, -118), Offset(wx + 16, -84), _stroke(2));
      c.drawLine(Offset(wx, -101), Offset(wx + 32, -101), _stroke(2));
    }
    // Flag
    c.drawLine(Offset(x, -236), Offset(x, -282), _stroke(3));
    final flag = Path()
      ..moveTo(x, -282)
      ..lineTo(x + 38, -273 + sin(_tt * 6) * 3)
      ..lineTo(x, -264)
      ..close();
    c.drawPath(flag, Paint()..color = const Color(0xFFFFD600));
    c.drawPath(flag, _stroke(2));
    _txt(c, '👑', Offset(x, -190), 30, Colors.white);
    // Cracks after attacks
    if (_dmg > 0) {
      final cr = _stroke(2.5);
      c.drawLine(Offset(x - 60, -150), Offset(x - 40, -120), cr);
      c.drawLine(Offset(x - 40, -120), Offset(x - 52, -96), cr);
      if (_dmg > 3) {
        c.drawLine(Offset(x + 70, -150), Offset(x + 50, -110), cr);
        c.drawLine(Offset(x + 50, -110), Offset(x + 64, -86), cr);
      }
    }
  }

  // ═══════════════════════ UI HELPERS ═══════════════════════
  BoxDecoration _pop(Color c, {double r = 18, double sh = 5}) => BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [BoxShadow(color: Colors.black, offset: Offset(sh, sh))],
      );

  Widget _popBtn(String label, VoidCallback? onTap,
      {Color color = const Color(0xFFFFD600),
      Color fg = Colors.black,
      double fs = 18}) {
    final cb = onTap;
    return GestureDetector(
      onTap: cb == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              cb();
            },
      child: Opacity(
        opacity: cb == null ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: _pop(color),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: fg,
                  fontSize: fs,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _chipW(String t,
      {bool on = false, bool dim = false, Color? color, VoidCallback? tap}) {
    final cb = tap;
    final bg = on ? (color ?? const Color(0xFFFFD600)) : Colors.white;
    return GestureDetector(
      onTap: (dim || cb == null)
          ? null
          : () {
              HapticFeedback.selectionClick();
              cb();
            },
      child: Opacity(
        opacity: dim ? 0.3 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _pop(bg, r: 12, sh: 3),
          child: Text(t,
              style: const TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _label(String t,
          {double fs = 13, Color c = const Color(0xFFFFF59D)}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: TextStyle(
                color: c, fontSize: fs, fontWeight: FontWeight.w800)),
      );

  // ═══════════════════════ BUILD ═══════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: LayoutBuilder(builder: (ctx, cons) {
            _size = Size(cons.maxWidth, cons.maxHeight);
            return Stack(fit: StackFit.expand, children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _jump,
                onHorizontalDragUpdate: (d) {
                  if (_phase == _Ph.courtyard) {
                    setState(() {
                      // Allow panning left/right around the house to inspect the estate!
                      _dist = (_dist - d.primaryDelta! / _scale).clamp(
                        _houseX - 380.0,
                        _houseX - 60.0,
                      );
                    });
                  }
                },
                onVerticalDragEnd: (d) {
                  final v = d.velocity.pixelsPerSecond.dy;
                  if (v < -150) {
                    _jump();
                  } else if (v > 150) {
                    _slide();
                  }
                },
                child: CustomPaint(
                    painter: _RunnerPainter(this), size: Size.infinite),
              ),
              if (_hasCustomHouse)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _frame,
                      builder: (c, _, __) {
                        final sx = _playerX + (_houseX - _dist) * _scale;
                        if (sx < -400 || sx > _size.width + 400) {
                          return const SizedBox.shrink();
                        }
                        final wv = 280 * _scale, hv = 280 * _scale;
                        return Stack(children: [
                          Positioned(
                            left: sx - wv / 2,
                            top: _groundY - hv + 8 * _scale,
                            width: wv,
                            height: hv,
                            child: _buildHouseWidget(c),
                          ),
                        ]);
                      },
                    ),
                  ),
                ),
              _hud(),
              _buildOverlay(),
            ]);
          }),
        ),
      ),
    );
  }

  bool get _hasCustomHouse => true;

  Widget _buildHouseWidget(BuildContext c) {
    if (widget.houseBuilder != null) return widget.houseBuilder!(c);
    final day = widget.defenderLevel.clamp(1, 100);
    return PocketAvatarHouseWidget(
      day: day,
      isDamaged: _dmg > 0,
      width: 280 * _scale,
      height: 280 * _scale,
      lightsOn: true,
    );
  }

  Widget _hud() {
    final pad = MediaQuery.of(context).padding;
    return Positioned(
      top: pad.top + 8,
      left: 10,
      right: 10,
      child: ValueListenableBuilder<int>(
        valueListenable: _frame,
        builder: (_, __, ___) =>
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: _confirmExit,
            child: Container(
              width: 40,
              height: 40,
              decoration: _pop(const Color(0xFFFF5252), r: 12, sh: 3),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: _pop(Colors.black.withValues(alpha: 0.55), r: 12, sh: 3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    "🏰 ${widget.defenderName}'s CITADEL · need ${(widget.passMark * 100).round()}%",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Wrap(spacing: 4, runSpacing: 4, children: [
                  for (var i = 0; i < _total; i++)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                        color: i < _results.length
                            ? const Color(0xFFFFD600)
                            : (i == _gate ? Colors.white : Colors.white24),
                      ),
                    ),
                ]),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: _pop(const Color(0xFF00BCD4), r: 12, sh: 3),
            child: Text('💎 $_gems',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black)),
          ),
        ]),
      ),
    );
  }

  Widget _buildOverlay() {
    switch (_phase) {
      case _Ph.ready:
        return _readyOverlay();
      case _Ph.engage:
        return _engageOverlay();
      case _Ph.challenge:
        return _challengeOverlay();
      case _Ph.courtyard:
        return _courtyardOverlay();
      case _Ph.repelled:
        return _repelOverlay();
      case _Ph.report:
        return _reportOverlay();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _readyOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: _pop(const Color(0xFF5E35B1), r: 24, sh: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚔️', style: TextStyle(fontSize: 54)),
            Text("RAID ${widget.defenderName.toUpperCase()}'S CITADEL",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
                '$_total defense gates · score ${(widget.passMark * 100).round()}% or more to breach',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFF59D),
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
                '👆 Tap / swipe UP = JUMP crates\n👇 Swipe DOWN = SLIDE under bars\n💎 Grab gems · beat each gate\'s card challenge',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 18),
            _popBtn('START RUN 🏃', _startRun, color: const Color(0xFF69F0AE)),
          ]),
        ),
      ),
    );
  }

  Widget _engageOverlay() {
    final pad = MediaQuery.of(context).padding;
    return Positioned(
      left: 16,
      right: 16,
      bottom: pad.bottom + 30,
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: _frame,
          builder: (_, __, ___) => Transform.scale(
            scale: 1 + 0.05 * sin(_tt * 7),
            child: _popBtn('👆 TAP TO ENGAGE DEFENSE GATE', _engageTap, fs: 16),
          ),
        ),
      ),
    );
  }

  Widget _challengeOverlay() {
    final ch = _cur;
    if (ch == null) return const SizedBox.shrink();
    final i = _gate;
    final col = _thCol[i % _thCol.length];
    final pad = MediaQuery.of(context).padding;

    // Resolve PopArt Card if available
    final cardDay = (i + 1).clamp(1, 90);
    final popCard = PopArtCardHelper.getCardForDay(cardDay,
        isMale: PocketKidsService.kidGender == 'male');

    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1446), Color(0xFF3B1E78)],
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, pad.top + 10, 16, pad.bottom + 12),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: _pop(col, r: 16, sh: 4),
            child: Row(children: [
              if (widget.cardBuilder != null) ...[
                SizedBox(
                  width: 58,
                  height: 82,
                  child: FittedBox(child: widget.cardBuilder!(context, i + 1)),
                ),
                const SizedBox(width: 10),
              ] else ...[
                // Built-in PopArt custom painter card
                Container(
                  width: 52,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomPaint(
                      painter: PopArtCardCustomPainter(data: popCard),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('GATE ${i + 1} / $_total · DAY ${i + 1} DEFENSE',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.black)),
                  Text(
                      '${_thName[i % _thName.length]} — ${_thPower[i % _thPower.length]}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.black87)),
                  Text(_typeTitle[ch.type].toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.white)),
                ]),
              ),
              Text(_thEmoji[i % _thEmoji.length], style: const TextStyle(fontSize: 38)),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(child: SingleChildScrollView(child: _challengeBody(ch, col))),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _popBtn('SUBMIT / FIRE 🚀', _canSubmit(ch) ? _submit : null,
                color: const Color(0xFF69F0AE)),
          ),
        ]),
      ),
    );
  }

  Widget _challengeBody(_Ch ch, Color col) {
    switch (ch.type) {
      case 0:
      case 4:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _label(ch.instruction),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _pop(Colors.white, r: 16, sh: 4),
            child: Text(ch.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.3)),
          ),
          const SizedBox(height: 14),
          _label('YOUR SENTENCE (tap a word to remove)',
              fs: 11, c: Colors.white70),
          Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final idx in _selA)
                _chipW(ch.chips[idx],
                    on: true,
                    color: const Color(0xFFFFD600),
                    tap: () => setState(() => _selA.remove(idx))),
            ]),
          ),
          const SizedBox(height: 16),
          _label('WORD BLOCKS', fs: 11, c: Colors.white70),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var k = 0; k < ch.chips.length; k++)
              _chipW(ch.chips[k],
                  dim: _selA.contains(k),
                  tap: () => setState(() => _selA.add(k))),
          ]),
        ]);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _label(ch.instruction),
          for (var k = 0; k < ch.options.length; k++)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white38, width: 2),
              ),
              child: Row(children: [
                Text('${k + 1}.',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    for (var j = 0; j < ch.options[k].length; j++)
                      _chipW(ch.options[k][j],
                          on: _pickB[k] == j,
                          color: const Color(0xFF80D8FF),
                          tap: () => setState(() => _pickB[k] = j)),
                  ]),
                ),
              ]),
            ),
        ]);
      case 2:
        {
          final n = ch.word.length;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _label(ch.instruction),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _pop(Colors.white, r: 16, sh: 4),
              child: Column(children: [
                Text(ch.emoji, style: const TextStyle(fontSize: 54)),
                Text(ch.prompt,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                const Text('🚂', style: TextStyle(fontSize: 40)),
                for (var p = 0; p < n; p++) ...[
                  Container(width: 8, height: 4, color: Colors.white70),
                  Builder(builder: (_) {
                    final b = ch.blanks.indexOf(p);
                    if (b < 0) {
                      return Container(
                        width: 40,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: _pop(col, r: 8, sh: 2),
                        child: Text(ch.word[p].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black)),
                      );
                    }
                    final v = _slotC[b];
                    return GestureDetector(
                      onTap: v == null
                          ? null
                          : () => setState(() => _slotC[b] = null),
                      child: Container(
                        width: 40,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: _pop(
                            v == null
                                ? Colors.white24
                                : const Color(0xFFFFD600),
                            r: 8,
                            sh: 2),
                        child: Text(v == null ? '?' : ch.chips[v].toUpperCase(),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: v == null
                                    ? Colors.white70
                                    : Colors.black)),
                      ),
                    );
                  }),
                ],
              ]),
            ),
            const SizedBox(height: 18),
            _label('LETTER BANK (tap a filled wagon to remove)',
                fs: 11, c: Colors.white70),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var k = 0; k < ch.chips.length; k++)
                _chipW(ch.chips[k].toUpperCase(),
                    dim: _slotC.contains(k), tap: () {
                  final free = _slotC.indexOf(null);
                  if (free >= 0) setState(() => _slotC[free] = k);
                }),
            ]),
          ]);
        }
      default:
        {
          final o = ch.options[0];
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _label(ch.instruction),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _pop(Colors.white, r: 16, sh: 4),
              child: Column(children: [
                Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _popBtn('🔊 REPLAY AUDIO', () => _speak(ch),
                          color: const Color(0xFF80D8FF), fs: 16),
                      if (widget.onListen != null)
                        _popBtn(_listening ? '👂 LISTENING…' : '🎤 SPEAK IT',
                            _listening ? null : () => _speakBack(ch),
                            color: const Color(0xFFFF8A80), fs: 16),
                    ]),
                const SizedBox(height: 12),
                const Text(
                  '🎧 Listen carefully to the spoken audio above!\nChoose the matching sentence you heard:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700),
                ),
                if (_heardD != null) ...[
                  const SizedBox(height: 8),
                  Text('Heard: "$_heardD"',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            for (var j = 0; j < o.length; j++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _pickD = j);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _pop(
                        _pickD == j ? const Color(0xFFFFD600) : Colors.white,
                        r: 14,
                        sh: 3),
                    child: Text(o[j],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
          ]);
        }
    }
  }

  Widget _courtyardOverlay() {
    final pad = MediaQuery.of(context).padding;
    final houseTitle = widget.defenderLevel >= 90
        ? '👑 Sovereign Palace Citadel (Day ${widget.defenderLevel})'
        : '🏡 ${widget.defenderName}\'s Estate (Day ${widget.defenderLevel})';
    return Positioned(
      left: 16,
      right: 16,
      bottom: pad.bottom + 20,
      child: ValueListenableBuilder<int>(
        valueListenable: _frame,
        builder: (_, __, ___) {
          final g = 0.5 + 0.5 * sin(_tt * 6);
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: _pop(Colors.black.withValues(alpha: 0.75), r: 14, sh: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🏰 ALL $_total GATES BREACHED · SCORE ${(_acc * 100).round()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF69F0AE)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    houseTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PocketLanguageService.localize(
                      en: '↔️ Swipe left / right to inspect full house',
                      ml: '↔️ സ്ക്രോൾ ചെയ്ത് വീട് കാണാം',
                      ta: '↔️ முழு வீட்டையும் பார்க்க இடது / வலதுபுறம் ஸ்வைப் செய்யவும்',
                      hi: '↔️ पूरा घर देखने के लिए बाएँ / दाएँ स्वाइप करें',
                    ),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 10.5, color: Color(0xFFFFF59D)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _startAttack,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF6D00), Color(0xFFFFD600)]),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFFF9100)
                            .withValues(alpha: 0.55 + 0.35 * g),
                        blurRadius: 20 + 16 * g,
                        spreadRadius: 3 + 4 * g),
                    const BoxShadow(color: Colors.black, offset: Offset(5, 5)),
                  ],
                ),
                child: const Text('⚔️ ATTACK & LOOT HOUSE',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _repelOverlay() {
    final done = _results.length;
    final best = ((_earned + (_total - done)) / _total * 100).round();
    return Positioned.fill(
      child: Stack(children: [
        IgnorePointer(
          child: ValueListenableBuilder<int>(
            valueListenable: _frame,
            builder: (_, __, ___) => Container(
              color: const Color(0xFFB71C1C)
                  .withValues(alpha: 0.35 + 0.25 * sin(_tt * 9).abs()),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.all(22),
            padding: const EdgeInsets.all(22),
            decoration: _pop(const Color(0xFF212121), r: 24, sh: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🚨', style: TextStyle(fontSize: 56)),
              const Text('CITADEL DEFENSES REPELLED!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF5252))),
              const Text('Raid Defeated!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 14),
              Text(
                'Gates attempted: $done / $_total\n'
                'Score so far: ${_earned.toStringAsFixed(1)} / $done\n'
                'Best possible score now: $best%  ·  needed ${(widget.passMark * 100).round()}%\n\n'
                'The citadel shields repelled the attack before reaching the inner house!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, height: 1.6, color: Colors.white70),
              ),
              const SizedBox(height: 18),
              _popBtn('RETURN TO BASE', _finish,
                  color: const Color(0xFFFF5252), fg: Colors.white),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _phase = _Ph.report),
                child: const Text('See my mistakes & answers',
                    style: TextStyle(
                        color: Color(0xFFFFF59D),
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _reportOverlay() {
    final pad = MediaQuery.of(context).padding;
    final pct = (_acc * 100).round();
    final pass = _won;
    Widget stat(String a, String b) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: _pop(Colors.white, r: 12, sh: 3),
            child: Column(children: [
              Text(a,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Text(b,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        );
    return Positioned.fill(
      child: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1446), Color(0xFF3B1E78)],
            ),
          ),
          padding: EdgeInsets.fromLTRB(16, pad.top + 14, 16, pad.bottom + 12),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: _pop(
                  pass ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                  r: 18,
                  sh: 5),
              child: Column(children: [
                Text(pass ? '🏆 RAID COMPLETE' : '💥 RAID DEFEATED',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                Text(
                    '$pct% ${pass ? 'PASS' : 'FAIL'}  ·  need ${(widget.passMark * 100).round()}%',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                if (pass)
                  Text('⭐' * _stars, style: const TextStyle(fontSize: 26)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              stat('+$_xp', 'XP'),
              const SizedBox(width: 8),
              stat('$_gems', '💎 GEMS'),
              const SizedBox(width: 8),
              stat(pass ? '+$_loot' : '0', 'LOOT PTS'),
              const SizedBox(width: 8),
              stat('${_results.length}/$_total', 'GATES'),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, k) {
                  final r = _results[k];
                  final good = r.earned >= 0.999;
                  final bad = r.earned <= 0.001;
                  final c = good
                      ? const Color(0xFF69F0AE)
                      : (bad
                          ? const Color(0xFFFF8A80)
                          : const Color(0xFFFFE57F));
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: _pop(Colors.white, r: 14, sh: 3),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(width: 2)),
                              child: Text(
                                  good
                                      ? '✔ RIGHT'
                                      : (bad ? '✖ WRONG' : '◐ PARTIAL'),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  'Gate ${r.gate + 1} · Day ${r.gate + 1} · ${_typeTitle[r.type]}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13)),
                            ),
                            Text('${(r.earned * 100).round()}%',
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w900)),
                          ]),
                          const SizedBox(height: 6),
                          Text(r.question,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          if (r.lines.isNotEmpty)
                            for (final l in r.lines)
                              Text(l,
                                  style: TextStyle(
                                      color: l.startsWith('✔')
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.w700))
                          else ...[
                            Text('Your answer: ${r.mine}',
                                style: TextStyle(
                                    color: good
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontWeight: FontWeight.w700)),
                            if (!good)
                              Text('Correct: ${r.correct}',
                                  style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w900)),
                          ],
                        ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _popBtn('RETURN TO BASE', _finish,
                  color: const Color(0xFFFFD600)),
            ),
          ]),
        ),
        if (pass)
          IgnorePointer(
            child: ValueListenableBuilder<int>(
              valueListenable: _frame,
              builder: (_, __, ___) => CustomPaint(
                  painter: _ConfettiPainter(this), size: Size.infinite),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _RunnerPainter extends CustomPainter {
  _RunnerPainter(this.st) : super(repaint: st._frame);
  final _PocketCitadelRunnerAttackPageState st;

  @override
  void paint(Canvas canvas, Size size) => st._paintScene(canvas, size);

  @override
  bool shouldRepaint(covariant _RunnerPainter old) => false;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.st) : super(repaint: st._frame);
  final _PocketCitadelRunnerAttackPageState st;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in st._pts) {
      if (p.kind != 0) continue;
      final a = st._cl(p.life / p.max, 0, 1);
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rot);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.55),
        Paint()..color = p.c.withValues(alpha: st._cl(a * 1.3, 0, 1)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
}
