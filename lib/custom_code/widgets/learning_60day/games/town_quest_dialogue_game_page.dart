// lib/custom_code/widgets/learning_60day/games/town_quest_dialogue_game_page.dart
//
// Pocket Mates - Town Quest (open-world dialogue mini-RPG)
//
// Dependencies: flutter_tts (only third-party package).
// Assets: assets/curriculum/day_{day}_curriculum.json (declared in pubspec.yaml).
//
// Curriculum loading:
//   * If [curriculumLoader] is supplied it is used first (plug in
//     PocketDayCurriculumService there, see example at the bottom of file).
//   * Otherwise the JSON is read straight from rootBundle.
//   * The JSON schema is parsed defensively (many key names / shapes are
//     understood). If nothing usable is found, built-in fallback dialogues are
//     used so the game never breaks.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

const int _kCoinsPerNpc = 10;
const int _kXpPerNpc = 20;

// ---------------------------------------------------------------------------
// PUBLIC WIDGET
// ---------------------------------------------------------------------------

class TownQuestDialogueGamePage extends StatefulWidget {
  const TownQuestDialogueGamePage({
    super.key,
    required this.day,
    this.nativeLanguage = 'Malayalam', // 'Malayalam', 'Hindi', 'Tamil'
    this.onGameFinished,
    this.onReward,
    this.curriculumLoader,
  });

  final int day;
  final String nativeLanguage;

  /// Called when the player finishes the whole Town Quest (all NPCs cleared)
  /// and taps "Finish". If null, the page simply pops itself.
  final VoidCallback? onGameFinished;

  /// Called every time an NPC conversation is solved (coins, xp).
  final void Function(int coins, int xp)? onReward;

  /// Optional injection point for your curriculum service, e.g.
  /// `(d) => PocketDayCurriculumService.instance.loadDay(d)` returning the raw
  /// decoded JSON map. Return null to fall back to rootBundle.
  final Future<Map<String, dynamic>?> Function(int day)? curriculumLoader;

  @override
  State<TownQuestDialogueGamePage> createState() =>
      _TownQuestDialogueGamePageState();
}

// ---------------------------------------------------------------------------
// MODELS
// ---------------------------------------------------------------------------

class _Scenario {
  const _Scenario({
    required this.npcLine,
    required this.correct,
    this.npcNative,
    this.correctNative,
    this.distractors = const <String>[],
  });

  final String npcLine;
  final String? npcNative;
  final String correct;
  final String? correctNative;
  final List<String> distractors;

  int get wordCount => correct.trim().split(RegExp(r'\s+')).length;
}

class _Npc {
  _Npc({
    required this.id,
    required this.name,
    required this.role,
    required this.emoji,
    required this.pos,
    required this.shirt,
    required this.accent,
    required this.hair,
    required this.useAssembler,
  });

  final String id;
  final String name;
  final String role;
  final String emoji;
  final Offset pos;
  final Color shirt;
  final Color accent;
  final Color hair;
  final bool useAssembler;
  bool done = false;
  _Scenario? scenario;
}

class _Building {
  const _Building(this.rect, this.wall, this.roof, this.sign);
  final Rect rect;
  final Color wall;
  final Color roof;
  final String sign;
}

class _Stall {
  const _Stall(this.rect, this.color);
  final Rect rect;
  final Color color;
}

class _Flower {
  const _Flower(this.pos, this.color);
  final Offset pos;
  final Color color;
}

class _Mote {
  const _Mote(this.x, this.y, this.phase, this.speed, this.r);
  final double x;
  final double y;
  final double phase;
  final double speed;
  final double r;
}

class _Drawable {
  _Drawable(this.y, this.draw);
  final double y;
  final VoidCallback draw;
}

// ---------------------------------------------------------------------------
// WORLD (mutable game state + movement/collision)
// ---------------------------------------------------------------------------

class _World {
  _World(this.npcs) {
    _build();
  }

  static const double worldW = 1400;
  static const double worldH = 1000;
  static const double speed = 200;
  static const Offset fountain = Offset(700, 500);

  final List<_Npc> npcs;

  Offset player = const Offset(700, 650);
  Offset facing = const Offset(0, 1);
  Offset joy = Offset.zero;
  Offset? target;
  bool moving = false;
  double walkPhase = 0;
  double time = 0;
  Size view = Size.zero;
  String? nearbyId;

  final List<Rect> roads = <Rect>[];
  final List<Rect> blockers = <Rect>[];
  final List<_Building> buildings = <_Building>[];
  final List<_Stall> stalls = <_Stall>[];
  final List<Offset> trees = <Offset>[];
  final List<_Flower> flowers = <_Flower>[];
  final List<_Mote> motes = <_Mote>[];

  void _build() {
    roads.addAll(const <Rect>[
      Rect.fromLTWH(0, 440, worldW, 120), // upper main road
      Rect.fromLTWH(0, 850, worldW, 100), // lower road
      Rect.fromLTWH(650, 0, 100, worldH), // vertical avenue
    ]);

    buildings.addAll(const <_Building>[
      _Building(Rect.fromLTWH(110, 110, 300, 220), Color(0xFFFFE0B2),
          Color(0xFFD9534F), '\u2615 CAFE'),
      _Building(Rect.fromLTWH(940, 110, 340, 220), Color(0xFFBBDEFB),
          Color(0xFF1E88E5), '\u{1F68C} BUS STATION'),
      _Building(Rect.fromLTWH(110, 590, 300, 210), Color(0xFFFFF3C4),
          Color(0xFF43A047), '\u{1F6D2} SHOP'),
      _Building(Rect.fromLTWH(980, 590, 300, 210), Color(0xFFD1C4E9),
          Color(0xFF3949AB), '\u{1F693} POLICE'),
    ]);

    stalls.addAll(const <_Stall>[
      _Stall(Rect.fromLTWH(470, 345, 110, 70), Color(0xFFEF5350)),
      _Stall(Rect.fromLTWH(820, 345, 110, 70), Color(0xFFFFA726)),
      _Stall(Rect.fromLTWH(470, 740, 110, 70), Color(0xFF42A5F5)),
      _Stall(Rect.fromLTWH(820, 740, 110, 70), Color(0xFFAB47BC)),
    ]);

    for (final b in buildings) {
      blockers.add(b.rect);
    }
    for (final s in stalls) {
      blockers.add(s.rect);
    }

    final rnd = math.Random(11);

    bool freeSpot(Offset p, double clearance) {
      if (p.dx < 40 || p.dx > worldW - 40 || p.dy < 50 || p.dy > worldH - 40) {
        return false;
      }
      for (final r in roads) {
        if (r.inflate(clearance).contains(p)) return false;
      }
      for (final r in blockers) {
        if (r.inflate(clearance).contains(p)) return false;
      }
      if ((p - fountain).distance < 170) return false;
      for (final n in npcs) {
        if ((p - n.pos).distance < 100) return false;
      }
      if ((p - player).distance < 100) return false;
      return true;
    }

    int attempts = 0;
    while (trees.length < 22 && attempts < 600) {
      attempts++;
      final p = Offset(
          40 + rnd.nextDouble() * (worldW - 80), 60 + rnd.nextDouble() * (worldH - 100));
      if (freeSpot(p, 50)) {
        bool crowded = false;
        for (final t in trees) {
          if ((t - p).distance < 90) crowded = true;
        }
        if (!crowded) trees.add(p);
      }
    }
    for (final t in trees) {
      blockers.add(Rect.fromCenter(center: t, width: 22, height: 16));
    }

    const flowerColors = <Color>[
      Color(0xFFFFFFFF),
      Color(0xFFFFEB3B),
      Color(0xFFFF80AB),
      Color(0xFFE040FB),
      Color(0xFFFF7043),
    ];
    attempts = 0;
    while (flowers.length < 140 && attempts < 1500) {
      attempts++;
      final p = Offset(
          20 + rnd.nextDouble() * (worldW - 40), 20 + rnd.nextDouble() * (worldH - 40));
      bool ok = true;
      for (final r in roads) {
        if (r.inflate(10).contains(p)) ok = false;
      }
      for (final r in blockers) {
        if (r.inflate(18).contains(p)) ok = false;
      }
      if ((p - fountain).distance < 135) ok = false;
      if (ok) {
        flowers.add(_Flower(p, flowerColors[rnd.nextInt(flowerColors.length)]));
      }
    }

    for (int i = 0; i < 45; i++) {
      motes.add(_Mote(
        rnd.nextDouble() * worldW,
        rnd.nextDouble() * worldH,
        rnd.nextDouble() * 6.28,
        0.5 + rnd.nextDouble() * 1.2,
        1.5 + rnd.nextDouble() * 2.2,
      ));
    }
  }

  Offset camera(Size s) {
    double cx;
    double cy;
    if (worldW <= s.width) {
      cx = -(s.width - worldW) / 2;
    } else {
      cx = (player.dx - s.width / 2).clamp(0.0, worldW - s.width).toDouble();
    }
    if (worldH <= s.height) {
      cy = -(s.height - worldH) / 2;
    } else {
      cy = (player.dy - s.height / 2).clamp(0.0, worldH - s.height).toDouble();
    }
    return Offset(cx, cy);
  }

  bool _blocked(Offset p) {
    if (p.dx < 30 || p.dx > worldW - 30 || p.dy < 45 || p.dy > worldH - 25) {
      return true;
    }
    for (final r in blockers) {
      if (r.inflate(14).contains(p)) return true;
    }
    if ((p - fountain).distance < 68) return true;
    return false;
  }

  void step(double dt) {
    Offset dir = Offset.zero;
    double mag = 0;
    if (joy.distance > 0.1) {
      dir = joy / joy.distance;
      mag = joy.distance.clamp(0.0, 1.0).toDouble();
      target = null;
    } else if (target != null) {
      final d = target! - player;
      final dist = d.distance;
      if (dist < 5) {
        target = null;
      } else {
        dir = d / dist;
        mag = 1;
      }
    }
    moving = false;
    if (mag > 0) {
      final delta = dir * (speed * mag * dt);
      Offset np = player;
      final tryX = Offset(player.dx + delta.dx, player.dy);
      if (!_blocked(tryX)) np = tryX;
      final tryY = Offset(np.dx, player.dy + delta.dy);
      if (!_blocked(tryY)) np = tryY;
      if ((np - player).distance < 0.01) {
        target = null;
      } else {
        moving = true;
        facing = dir;
      }
      player = np;
    }
    if (moving) walkPhase += dt * 12;
  }
}

// ---------------------------------------------------------------------------
// CURRICULUM PARSING (defensive)
// ---------------------------------------------------------------------------

class _Pair {
  const _Pair(this.prompt, this.reply, this.promptNative, this.replyNative);
  final String prompt;
  final String reply;
  final String? promptNative;
  final String? replyNative;
}

class _Line {
  const _Line(this.text, this.native);
  final String text;
  final String? native;
}

const List<String> _textKeys = <String>[
  'english',
  'en',
  'text',
  'sentence',
  'line',
  'message',
  'content',
  'phrase',
  'utterance',
];

const List<String> _genericWrong = <String>[
  'I am fine, thank you.',
  'See you tomorrow.',
  'No, I do not like it.',
  'It is very big.',
];

const List<_Scenario> _fallbackScenarios = <_Scenario>[
  _Scenario(
    npcLine: 'Good morning! What would you like to drink?',
    correct: 'I would like a cup of tea, please.',
    distractors: <String>['I am from Kerala.', 'Where is the bus station?'],
  ),
  _Scenario(
    npcLine: 'Hello! Can I help you?',
    correct: 'Yes, where is the bus stop?',
    distractors: <String>['I have a headache.', 'It is twenty rupees.'],
  ),
  _Scenario(
    npcLine: 'Hi there! How can I help you today?',
    correct: 'How much is this apple?',
    distractors: <String>['My name is Ravi.', 'The shop is closed.'],
  ),
  _Scenario(
    npcLine: 'Good afternoon. Are you lost?',
    correct: 'Yes, I am looking for the railway station.',
    distractors: <String>[
      'No, thank you. I am not hungry.',
      'I like playing cricket.'
    ],
  ),
];

Map<String, dynamic> _lc(Map<dynamic, dynamic> m) {
  final out = <String, dynamic>{};
  m.forEach((k, v) {
    out[k.toString().toLowerCase()] = v;
  });
  return out;
}

String? _textOf(dynamic v) {
  if (v is String) {
    var t = v.trim();
    t = t.replaceFirst(RegExp(r'^[A-Z][A-Za-z ]{0,18}:\s+'), '');
    return t.isEmpty ? null : t;
  }
  if (v is Map) {
    final lc = _lc(v);
    for (final k in _textKeys) {
      final x = lc[k];
      if (x is String && x.trim().isNotEmpty) return x.trim();
    }
  }
  return null;
}

String? _nativeOf(dynamic v, String lang) {
  if (v is! Map) return null;
  final l = lang.toLowerCase();
  final code = l.startsWith('mal')
      ? 'ml'
      : l.startsWith('hin')
          ? 'hi'
          : l.startsWith('tam')
              ? 'ta'
              : l;
  final lc = _lc(v);
  final keys = <String>[
    l,
    code,
    '${l}_translation',
    'translation_$l',
    '${code}_translation',
    'translation_$code',
    '${l}_text',
    'native',
    'translation',
    'meaning',
  ];
  for (final k in keys) {
    final x = lc[k];
    if (x is String && x.trim().isNotEmpty) return x.trim();
  }
  final tr = lc['translations'];
  if (tr is Map) {
    final t = _lc(tr);
    for (final k in <String>[l, code]) {
      final x = t[k];
      if (x is String && x.trim().isNotEmpty) return x.trim();
    }
  }
  return null;
}

List<dynamic> _findList(dynamic root, List<String> keys) {
  if (root is Map) {
    final lc = _lc(root);
    for (final k in keys) {
      final v = lc[k];
      if (v is List && v.isNotEmpty) return v;
    }
    for (final v in lc.values) {
      if (v is Map) {
        final r = _findList(v, keys);
        if (r.isNotEmpty) return r;
      }
    }
  }
  return const <dynamic>[];
}

String _norm(String s) {
  return s
      .replaceAll('\u2019', "'")
      .replaceAll('\u2018', "'")
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

void _pairTurns(List<dynamic> turns, String lang, List<_Pair> out) {
  final lines = <_Line>[];
  for (final t in turns) {
    final text = _textOf(t);
    if (text != null) lines.add(_Line(text, _nativeOf(t, lang)));
  }
  for (int i = 0; i + 1 < lines.length; i += 2) {
    out.add(_Pair(lines[i].text, lines[i + 1].text, lines[i].native,
        lines[i + 1].native));
  }
}

List<_Pair> _collectPairs(dynamic root, String lang) {
  final pairs = <_Pair>[];

  final dialogues = _findList(root, const <String>[
    'dialogues',
    'dialogue',
    'conversations',
    'conversation',
    'role_plays',
    'roleplays',
    'role_play',
    'scenarios',
  ]);

  for (final d in dialogues) {
    if (d is Map) {
      final lc = _lc(d);
      final qRaw = lc['question'] ?? lc['npc'] ?? lc['prompt'] ?? lc['a'];
      final aRaw = lc['answer'] ?? lc['reply'] ?? lc['response'] ?? lc['b'];
      final q = _textOf(qRaw);
      final a = _textOf(aRaw);
      if (q != null && a != null) {
        pairs.add(_Pair(q, a, _nativeOf(qRaw, lang), _nativeOf(aRaw, lang)));
        continue;
      }
      final turns = _findList(d, const <String>[
        'lines',
        'turns',
        'conversation',
        'dialogue',
        'messages',
        'exchanges',
        'dialogues',
      ]);
      _pairTurns(turns, lang, pairs);
    } else if (d is List) {
      _pairTurns(d, lang, pairs);
    }
  }

  final patterns = _findList(root, const <String>[
    'sentence_patterns',
    'patterns',
    'key_sentences',
    'sentences',
    'phrases',
    'useful_phrases',
    'expressions',
  ]);
  for (final p in patterns) {
    final text = _textOf(p);
    if (text == null) continue;
    final native = _nativeOf(p, lang);
    pairs.add(_Pair(
      native != null
          ? 'How do you say this in English?'
          : 'Repeat after me, and pick the right sentence!',
      text,
      native,
      native,
    ));
  }
  return pairs;
}

List<_Scenario> _buildScenarios(dynamic root, String lang, int day) {
  final pairs = root == null ? const <_Pair>[] : _collectPairs(root, lang);
  final good = <_Pair>[];
  final seen = <String>{};
  for (final p in pairs) {
    final wc = p.reply.split(RegExp(r'\s+')).length;
    if (wc < 2 || wc > 10) continue;
    if (p.prompt.length > 140) continue;
    if (seen.add(_norm(p.reply))) good.add(p);
  }

  final picked = <_Pair>[];
  if (good.length <= 4) {
    picked.addAll(good);
  } else {
    for (int i = 0; i < 4; i++) {
      picked.add(good[(i * good.length) ~/ 4]);
    }
  }

  final rnd = math.Random(day * 31 + 7);
  final replyPool = good.map((p) => p.reply).toList();
  final out = <_Scenario>[];
  for (int i = 0; i < 4; i++) {
    if (i < picked.length) {
      final p = picked[i];
      final others = replyPool.where((r) => _norm(r) != _norm(p.reply)).toList()
        ..shuffle(rnd);
      final d = <String>[...others.take(2)];
      for (final g in _genericWrong) {
        if (d.length >= 2) break;
        if (!d.contains(g) && _norm(g) != _norm(p.reply)) d.add(g);
      }
      out.add(_Scenario(
        npcLine: p.prompt,
        npcNative: p.promptNative,
        correct: p.reply,
        correctNative: p.replyNative,
        distractors: d,
      ));
    } else {
      out.add(_fallbackScenarios[i]);
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// STATE
// ---------------------------------------------------------------------------

class _TownQuestDialogueGamePageState extends State<TownQuestDialogueGamePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  final ValueNotifier<_Npc?> _nearby = ValueNotifier<_Npc?>(null);
  final FlutterTts _tts = FlutterTts();

  late final List<_Npc> _npcs;
  late final _World _world;

  bool _loading = true;
  bool _dialogOpen = false;
  bool _finished = false;
  int _coins = 0;
  int _xp = 0;
  int _keys = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _npcs = <_Npc>[
      _Npc(
        id: 'barista',
        name: 'Barista Maya',
        role: 'Cafe Barista',
        emoji: '\u2615',
        pos: const Offset(260, 385),
        shirt: const Color(0xFFD9534F),
        accent: const Color(0xFFD9534F),
        hair: const Color(0xFF5D4037),
        useAssembler: false,
      ),
      _Npc(
        id: 'guide',
        name: 'Guide Ravi',
        role: 'Bus Station Guide',
        emoji: '\u{1F68C}',
        pos: const Offset(1110, 385),
        shirt: const Color(0xFF1E88E5),
        accent: const Color(0xFF1E88E5),
        hair: const Color(0xFF212121),
        useAssembler: true,
      ),
      _Npc(
        id: 'shop',
        name: 'Shopkeeper Anna',
        role: 'Shopkeeper',
        emoji: '\u{1F6D2}',
        pos: const Offset(260, 835),
        shirt: const Color(0xFF43A047),
        accent: const Color(0xFF43A047),
        hair: const Color(0xFFBF360C),
        useAssembler: false,
      ),
      _Npc(
        id: 'police',
        name: 'Officer Sam',
        role: 'Police Officer',
        emoji: '\u{1F693}',
        pos: const Offset(1130, 835),
        shirt: const Color(0xFF3949AB),
        accent: const Color(0xFF3949AB),
        hair: const Color(0xFF4E342E),
        useAssembler: true,
      ),
    ];
    for (int i = 0; i < _npcs.length; i++) {
      _npcs[i].scenario = _fallbackScenarios[i];
    }
    _world = _World(_npcs);
    _initTts();
    _ticker = createTicker(_onTick)..start();
    _loadCurriculum();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _nearby.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _loadFromAssets() async {
    final padded = widget.day.toString().padLeft(2, '0');
    final names = <String>{
      'assets/curriculum/day_${widget.day}_curriculum.json',
      'assets/curriculum/day_${padded}_curriculum.json',
    };
    for (final path in names) {
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = json.decode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        if (decoded is List) return <String, dynamic>{'items': decoded};
      } catch (_) {}
    }
    return null;
  }

  Future<void> _loadCurriculum() async {
    Map<String, dynamic>? data;
    try {
      final loader = widget.curriculumLoader;
      if (loader != null) data = await loader(widget.day);
    } catch (_) {}
    data ??= await _loadFromAssets();

    List<_Scenario> scenarios;
    try {
      scenarios = _buildScenarios(data, widget.nativeLanguage, widget.day);
    } catch (_) {
      scenarios = List<_Scenario>.from(_fallbackScenarios);
    }
    for (int i = 0; i < _npcs.length && i < scenarios.length; i++) {
      _npcs[i].scenario = scenarios[i];
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _onTick(Duration elapsed) {
    final dt =
        ((elapsed - _last).inMicroseconds / 1000000.0).clamp(0.0, 0.05).toDouble();
    _last = elapsed;
    _world.time += dt;

    final active = !_loading && !_dialogOpen && !_finished;
    if (active) _world.step(dt);

    _Npc? best;
    if (active) {
      double bd = 80;
      for (final n in _npcs) {
        if (n.done) continue;
        final d = (n.pos - _world.player).distance;
        if (d < bd) {
          bd = d;
          best = n;
        }
      }
    }
    _world.nearbyId = best?.id;
    if (_nearby.value != best) _nearby.value = best;
    _frame.value++;
  }

  void _onWorldTap(TapDownDetails d) {
    if (_loading || _dialogOpen || _finished) return;
    final cam = _world.camera(_world.view);
    final p = d.localPosition + cam;
    _world.target = Offset(
      p.dx.clamp(30.0, _World.worldW - 30).toDouble(),
      p.dy.clamp(45.0, _World.worldH - 25).toDouble(),
    );
  }

  Future<void> _openDialogue(_Npc n) async {
    final sc = n.scenario;
    if (_dialogOpen || sc == null || n.done) return;
    setState(() => _dialogOpen = true);
    _world.joy = Offset.zero;
    _world.target = null;

    final assembler = n.useAssembler && sc.wordCount >= 3 && sc.wordCount <= 9;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DialogueSheet(
        npc: n,
        scenario: sc,
        assembler: assembler,
        nativeLanguage: widget.nativeLanguage,
        speak: _speak,
      ),
    );

    try {
      await _tts.stop();
    } catch (_) {}
    if (!mounted) return;
    _world.joy = Offset.zero;
    setState(() => _dialogOpen = false);
    if (result == true) _completeNpc(n);
  }

  void _completeNpc(_Npc n) {
    setState(() {
      n.done = true;
      _coins += _kCoinsPerNpc;
      _xp += _kXpPerNpc;
      _keys += 1;
    });
    widget.onReward?.call(_kCoinsPerNpc, _kXpPerNpc);
    _nearby.value = null;

    if (_npcs.every((e) => e.done)) {
      _finished = true;
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showFinishDialog();
      });
    }
  }

  Future<void> _showFinishDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text('\u{1F389} Town Quest Complete!',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Day ${widget.day} cleared! You talked to everyone in town.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _StatBadge(emoji: '\u{1FA99}', value: '$_coins', label: 'Coins'),
                _StatBadge(emoji: '\u26A1', value: '$_xp', label: 'XP'),
                _StatBadge(
                    emoji: '\u{1F5DD}\uFE0F',
                    value: '$_keys/${_npcs.length}',
                    label: 'Star Keys'),
              ],
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final cb = widget.onGameFinished;
              if (cb != null) {
                cb();
              } else if (mounted) {
                Navigator.of(context).maybePop();
              }
            },
            child: const Text('Finish',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7CC66B),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _onWorldTap,
              child: CustomPaint(
                painter: _TownPainter(_world, _frame),
                size: Size.infinite,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildHud()),
          ),
          Positioned(
            right: 16,
            bottom: 28,
            child: SafeArea(
              child: ValueListenableBuilder<_Npc?>(
                valueListenable: _nearby,
                builder: (context, npc, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: npc == null
                        ? const SizedBox(key: ValueKey<String>('none'))
                        : _buildTalkButton(npc),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 24,
            child: SafeArea(
              child: _Joystick(
                onChanged: (v) {
                  _world.joy = v;
                },
              ),
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: const Color(0xCC1B5E20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 14),
                    Text('Loading today\'s town...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTalkButton(_Npc npc) {
    return Material(
      key: ValueKey<String>(npc.id),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _openDialogue(npc),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: npc.accent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Color(0x55000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(npc.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('Talk to ${npc.name.split(' ').first}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Material(
                color: Colors.white.withAlpha(230),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Day ${widget.day} \u2022 Town Quest',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32))),
                ),
              ),
              const Spacer(),
              _HudPill(emoji: '\u{1FA99}', text: '$_coins'),
              const SizedBox(width: 6),
              _HudPill(emoji: '\u26A1', text: '$_xp'),
              const SizedBox(width: 6),
              _HudPill(
                  emoji: '\u{1F5DD}\uFE0F', text: '$_keys/${_npcs.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final n in _npcs)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: n.done
                        ? const Color(0xFF43A047)
                        : Colors.white.withAlpha(220),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${n.emoji} ${n.role}${n.done ? '  \u2713' : ''}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: n.done ? Colors.white : const Color(0xFF37474F),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SMALL UI WIDGETS
// ---------------------------------------------------------------------------

class _HudPill extends StatelessWidget {
  const _HudPill({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF37474F))),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(
      {required this.emoji, required this.value, required this.label});
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF78909C))),
      ],
    );
  }
}

class _Joystick extends StatefulWidget {
  const _Joystick({required this.onChanged});
  final ValueChanged<Offset> onChanged;

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  static const double _size = 140;
  static const double _knob = 56;
  Offset _k = Offset.zero;

  void _update(Offset local) {
    const c = Offset(_size / 2, _size / 2);
    Offset d = local - c;
    const maxR = (_size - _knob) / 2 + 8;
    final dist = d.distance;
    if (dist > maxR) d = d / dist * maxR;
    setState(() => _k = d);
    widget.onChanged(d / maxR);
  }

  void _end() {
    setState(() => _k = Offset.zero);
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _update(d.localPosition),
      onPanUpdate: (d) => _update(d.localPosition),
      onPanEnd: (_) => _end(),
      onPanCancel: _end,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(70),
                border: Border.all(color: Colors.white.withAlpha(190), width: 3),
              ),
            ),
            Transform.translate(
              offset: _k,
              child: Container(
                width: _knob,
                height: _knob,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(235),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.open_with_rounded,
                    color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOGUE SHEET
// ---------------------------------------------------------------------------

class _DialogueSheet extends StatefulWidget {
  const _DialogueSheet({
    required this.npc,
    required this.scenario,
    required this.assembler,
    required this.nativeLanguage,
    required this.speak,
  });

  final _Npc npc;
  final _Scenario scenario;
  final bool assembler;
  final String nativeLanguage;
  final Future<void> Function(String) speak;

  @override
  State<_DialogueSheet> createState() => _DialogueSheetState();
}

class _DialogueSheetState extends State<_DialogueSheet> {
  late final List<String> _options;
  late final List<String> _bank;
  final List<int> _picked = <int>[];
  final Set<String> _wrong = <String>{};
  bool _solved = false;
  bool _showHint = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    final sc = widget.scenario;
    _options = <String>[sc.correct, ...sc.distractors.take(2)]..shuffle(rnd);
    _bank = sc.correct.trim().split(RegExp(r'\s+'))..shuffle(rnd);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.speak(sc.npcLine);
    });
  }

  void _pickOption(String option) {
    if (_solved || _wrong.contains(option)) return;
    if (_norm(option) == _norm(widget.scenario.correct)) {
      setState(() {
        _solved = true;
        _message = null;
      });
      widget.speak(widget.scenario.correct);
    } else {
      widget.speak(option);
      setState(() {
        _wrong.add(option);
        _message = 'Not quite. Listen and try another reply!';
      });
    }
  }

  void _checkAssembled() {
    if (_solved || _picked.isEmpty) return;
    final built = _picked.map((i) => _bank[i]).join(' ');
    if (_norm(built) == _norm(widget.scenario.correct)) {
      setState(() {
        _solved = true;
        _message = null;
      });
      widget.speak(widget.scenario.correct);
    } else {
      setState(() => _message = 'Almost! Check the word order and try again.');
    }
  }

  String get _hintText {
    final native = widget.scenario.correctNative;
    if (native != null && native.isNotEmpty) return native;
    final words = widget.scenario.correct.trim().split(RegExp(r'\s+'));
    return 'It starts with: "${words.take(2).join(' ')} ..."';
  }

  @override
  Widget build(BuildContext context) {
    final sc = widget.scenario;
    final npc = widget.npc;
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7CCC8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: npc.accent.withAlpha(40),
                    child: Text(npc.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(npc.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(npc.role,
                            style: const TextStyle(
                                color: Color(0xFF78909C), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // NPC speech bubble
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: npc.accent, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(sc.npcLine,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25)),
                          if (sc.npcNative != null) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(sc.npcNative!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF607D8B),
                                    fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Listen',
                      icon: Icon(Icons.volume_up_rounded, color: npc.accent),
                      onPressed: () => widget.speak(sc.npcLine),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.assembler
                    ? 'Build your reply: tap the words in order'
                    : 'Choose the best spoken reply',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Color(0xFF455A64)),
              ),
              const SizedBox(height: 10),
              if (widget.assembler) _buildAssembler() else _buildOptions(),
              if (_message != null && !_solved) ...<Widget>[
                const SizedBox(height: 10),
                Text(_message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFFD84315), fontWeight: FontWeight.w700)),
              ],
              if (_showHint && !_solved) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('\u{1F4A1} $_hintText',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
              if (!_solved)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showHint = !_showHint),
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: const Text('Hint'),
                  ),
                ),
              if (_solved) ...<Widget>[
                const SizedBox(height: 12),
                _buildSuccess(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    final sc = widget.scenario;
    return Column(
      children: <Widget>[
        for (final o in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _optionTile(o, sc),
          ),
      ],
    );
  }

  Widget _optionTile(String o, _Scenario sc) {
    final isCorrect = _solved && _norm(o) == _norm(sc.correct);
    final isWrong = _wrong.contains(o);
    Color bg = Colors.white;
    Color border = const Color(0xFFCFD8DC);
    if (isCorrect) {
      bg = const Color(0xFFE8F5E9);
      border = const Color(0xFF43A047);
    } else if (isWrong) {
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFE57373);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _pickOption(o),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isWrong
                        ? Icons.cancel_rounded
                        : Icons.record_voice_over_rounded,
                color: isCorrect
                    ? const Color(0xFF43A047)
                    : isWrong
                        ? const Color(0xFFE57373)
                        : const Color(0xFF90A4AE),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(o,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isWrong
                            ? const Color(0xFF9E9E9E)
                            : const Color(0xFF263238))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssembler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _solved ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _solved
                    ? const Color(0xFF43A047)
                    : const Color(0xFFB0BEC5),
                width: 2),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final i in _picked)
                GestureDetector(
                  onTap: _solved
                      ? null
                      : () => setState(() {
                            _picked.remove(i);
                            _message = null;
                          }),
                  child: _wordChip(_bank[i], filled: true),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (int i = 0; i < _bank.length; i++)
              if (!_picked.contains(i))
                GestureDetector(
                  onTap: _solved
                      ? null
                      : () {
                          widget.speak(_bank[i]);
                          setState(() {
                            _picked.add(i);
                            _message = null;
                          });
                        },
                  child: _wordChip(_bank[i]),
                ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            TextButton.icon(
              onPressed: _solved
                  ? null
                  : () => setState(() {
                        _picked.clear();
                        _message = null;
                      }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.npc.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (_solved || _picked.isEmpty) ? null : _checkAssembled,
              child: const Text('Check',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _wordChip(String w, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: filled ? widget.npc.accent.withAlpha(35) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: filled ? widget.npc.accent : const Color(0xFFB0BEC5),
            width: 2),
        boxShadow: filled
            ? null
            : const <BoxShadow>[
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
      ),
      child: Text(w,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF43A047), width: 2),
      ),
      child: Column(
        children: <Widget>[
          const Text('\u{1F31F} Perfect reply!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32))),
          const SizedBox(height: 6),
          Text(widget.scenario.correct,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (widget.scenario.correctNative != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(widget.scenario.correctNative!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF607D8B), fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          const Text(
              '+$_kCoinsPerNpc \u{1FA99} Coins    +$_kXpPerNpc \u26A1 XP    +1 \u{1F5DD}\uFE0F Star Key',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: () => widget.speak(widget.scenario.correct),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Say it again'),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAINTER
// ---------------------------------------------------------------------------

class _TownPainter extends CustomPainter {
  _TownPainter(this.w, Listenable repaint) : super(repaint: repaint);

  final _World w;

  @override
  bool shouldRepaint(covariant _TownPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    w.view = size;
    final cam = w.camera(size);

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF3E8E41));

    canvas.save();
    canvas.translate(-cam.dx, -cam.dy);
    final vis = Rect.fromLTWH(cam.dx, cam.dy, size.width, size.height);

    _ground(canvas, vis);
    _roadsAndPlaza(canvas, vis);

    for (final b in w.buildings) {
      if (b.rect.inflate(60).overlaps(vis)) _building(canvas, b);
    }
    for (final s in w.stalls) {
      if (s.rect.inflate(40).overlaps(vis)) _stall(canvas, s);
    }

    final items = <_Drawable>[];
    for (final t in w.trees) {
      if (vis.inflate(80).contains(t)) {
        items.add(_Drawable(t.dy, () => _tree(canvas, t)));
      }
    }
    for (final n in w.npcs) {
      items.add(_Drawable(n.pos.dy, () => _npc(canvas, n)));
    }
    items.add(_Drawable(w.player.dy, () => _player(canvas)));
    items.sort((a, b) => a.y.compareTo(b.y));
    for (final d in items) {
      d.draw();
    }

    _motes(canvas, vis);
    canvas.restore();

    // Screen-space atmosphere
    final sun = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topRight,
        radius: 1.2,
        colors: <Color>[Color(0x55FFF3B0), Color(0x00FFF3B0)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sun);
    _clouds(canvas, size);
  }

  // ---- ground -------------------------------------------------------------

  void _ground(Canvas canvas, Rect vis) {
    const worldRect = Rect.fromLTWH(0, 0, _World.worldW, _World.worldH);
    final grass = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF8BD16F), Color(0xFF6DBE5B)],
      ).createShader(worldRect);
    canvas.drawRect(worldRect, grass);

    final band = Paint()..color = Colors.white.withAlpha(14);
    for (int i = 0; i < 14; i += 2) {
      canvas.drawRect(Rect.fromLTWH(i * 100.0, 0, 100, _World.worldH), band);
    }

    final petal = Paint();
    final center = Paint()..color = const Color(0xFFFFC107);
    final inflated = vis.inflate(10);
    for (final f in w.flowers) {
      if (!inflated.contains(f.pos)) continue;
      petal.color = f.color;
      canvas.drawCircle(f.pos + const Offset(-2.5, 0), 2.6, petal);
      canvas.drawCircle(f.pos + const Offset(2.5, 0), 2.6, petal);
      canvas.drawCircle(f.pos + const Offset(0, -2.5), 2.6, petal);
      canvas.drawCircle(f.pos + const Offset(0, 2.5), 2.6, petal);
      canvas.drawCircle(f.pos, 1.8, center);
    }

    // hedge border
    canvas.drawRect(
      worldRect.deflate(6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = const Color(0xFF2E7D32),
    );
  }

  void _cobbleFill(Canvas c, Rect area, Rect vis, Color base) {
    final r = area.intersect(vis.inflate(2));
    if (r.isEmpty) return;
    c.save();
    c.clipRect(r);
    c.drawRect(r, Paint()..color = base);
    const s = 24.0;
    final path = Path();
    final row0 = (r.top / s).floor();
    final row1 = (r.bottom / s).ceil();
    for (int row = row0; row <= row1; row++) {
      final y = row * s;
      path.moveTo(r.left, y);
      path.lineTo(r.right, y);
      final off = row.isEven ? 0.0 : s;
      final col0 = ((r.left - off) / (s * 2)).floor();
      final col1 = ((r.right - off) / (s * 2)).ceil();
      for (int col = col0; col <= col1; col++) {
        final x = col * s * 2 + off;
        path.moveTo(x, y);
        path.lineTo(x, y + s);
      }
    }
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFA8957A),
    );
    c.restore();
  }

  void _roadsAndPlaza(Canvas canvas, Rect vis) {
    const base = Color(0xFFCDBBA0);
    for (final r in w.roads) {
      _cobbleFill(canvas, r, vis, base);
    }
    final curb = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = const Color(0xFFEFE4CF);
    for (final r in w.roads) {
      if (r.overlaps(vis)) canvas.drawRect(r, curb);
    }
    // cover curb crossing at junctions with cobble
    const plazaCenter = _World.fountain;
    const plazaR = 125.0;
    final plazaRect = Rect.fromCircle(center: plazaCenter, radius: plazaR);
    if (plazaRect.overlaps(vis)) {
      canvas.save();
      canvas.clipPath(Path()..addOval(plazaRect));
      _cobbleFill(canvas, plazaRect, vis, const Color(0xFFD9C9AE));
      canvas.restore();
      canvas.drawCircle(plazaCenter, plazaR, curb);
      _fountain(canvas);
    }
  }

  void _fountain(Canvas canvas) {
    const c = _World.fountain;
    canvas.drawCircle(c + const Offset(5, 6), 58,
        Paint()..color = Colors.black.withAlpha(40));
    canvas.drawCircle(c, 58, Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawCircle(c, 50, Paint()..color = const Color(0xFF78909C));
    canvas.drawCircle(c, 46, Paint()..color = const Color(0xFF4FC3F7));
    for (int k = 0; k < 3; k++) {
      final rad = 14 + ((w.time * 18 + k * 10) % 30);
      final alpha = (200 * (1 - (rad - 14) / 30)).clamp(0, 255).toInt();
      canvas.drawCircle(
        c,
        rad,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withAlpha(alpha),
      );
    }
    canvas.drawCircle(c, 11, Paint()..color = const Color(0xFFCFD8DC));
    canvas.drawCircle(c + const Offset(0, -10), 6, Paint()..color = const Color(0xFFE1F5FE));
    final bob = math.sin(w.time * 4) * 2;
    canvas.drawCircle(c + Offset(0, -22 + bob), 3.2,
        Paint()..color = Colors.white.withAlpha(220));
  }

  // ---- structures ---------------------------------------------------------

  void _label(Canvas c, String t, Offset center,
      {double size = 12,
      Color color = Colors.white,
      FontWeight weight = FontWeight.w800,
      bool shadow = true}) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          shadows: shadow
              ? <Shadow>[Shadow(color: Colors.black.withAlpha(110), blurRadius: 3)]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _building(Canvas c, _Building b) {
    final r = b.rect;
    c.drawRRect(
      RRect.fromRectAndRadius(r.shift(const Offset(16, 12)), const Radius.circular(8)),
      Paint()..color = Colors.black.withAlpha(42),
    );

    final wallRect = Rect.fromLTRB(r.left, r.top + 50, r.right, r.bottom);
    c.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(6)),
      Paint()..color = b.wall,
    );
    c.drawRect(
      Rect.fromLTRB(wallRect.left, wallRect.bottom - 10, wallRect.right, wallRect.bottom),
      Paint()..color = Colors.black.withAlpha(25),
    );

    // roof
    final roofRect = Rect.fromLTRB(r.left - 10, r.top, r.right + 10, r.top + 70);
    c.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(12)),
      Paint()..color = b.roof,
    );
    final tiles = Paint()
      ..color = Colors.black.withAlpha(35)
      ..strokeWidth = 2;
    for (double y = roofRect.top + 14; y < roofRect.bottom - 4; y += 14) {
      c.drawLine(Offset(roofRect.left + 6, y), Offset(roofRect.right - 6, y), tiles);
    }
    c.drawRect(
      Rect.fromLTRB(roofRect.left, roofRect.bottom - 6, roofRect.right, roofRect.bottom + 4),
      Paint()..color = Colors.black.withAlpha(40),
    );

    // sign
    final signRect = Rect.fromCenter(
      center: Offset(r.center.dx, wallRect.top + 26),
      width: math.min(r.width - 60, 210),
      height: 28,
    );
    c.drawRRect(RRect.fromRectAndRadius(signRect, const Radius.circular(8)),
        Paint()..color = const Color(0xFF5D4037));
    c.drawRRect(
      RRect.fromRectAndRadius(signRect.deflate(2.5), const Radius.circular(6)),
      Paint()..color = const Color(0xFF8D6E63),
    );
    _label(c, b.sign, signRect.center, size: 14);

    // windows
    final winTop = wallRect.top + 56;
    for (final fx in <double>[0.2, 0.8]) {
      final wr = Rect.fromCenter(
          center: Offset(r.left + r.width * fx, winTop + 24), width: 54, height: 48);
      c.drawRRect(RRect.fromRectAndRadius(wr.inflate(4), const Radius.circular(6)),
          Paint()..color = Colors.white);
      c.drawRRect(
        RRect.fromRectAndRadius(wr, const Radius.circular(4)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFB3E5FC), Color(0xFF4FC3F7)],
          ).createShader(wr),
      );
      final frame = Paint()
        ..color = Colors.white
        ..strokeWidth = 3;
      c.drawLine(Offset(wr.center.dx, wr.top), Offset(wr.center.dx, wr.bottom), frame);
      c.drawLine(Offset(wr.left, wr.center.dy), Offset(wr.right, wr.center.dy), frame);
    }

    // door
    final doorRect = Rect.fromLTWH(r.center.dx - 27, r.bottom - 74, 54, 74);
    c.drawRRect(
      RRect.fromRectAndCorners(doorRect,
          topLeft: const Radius.circular(27), topRight: const Radius.circular(27)),
      Paint()..color = const Color(0xFF6D4C41),
    );
    c.drawRRect(
      RRect.fromRectAndCorners(doorRect.deflate(5),
          topLeft: const Radius.circular(22), topRight: const Radius.circular(22)),
      Paint()..color = const Color(0xFF8D6E63),
    );
    c.drawCircle(Offset(doorRect.right - 12, doorRect.center.dy + 6), 3.5,
        Paint()..color = const Color(0xFFFFD54F));
  }

  void _stall(Canvas c, _Stall s) {
    final r = s.rect;
    c.drawRRect(
      RRect.fromRectAndRadius(r.shift(const Offset(8, 8)), const Radius.circular(6)),
      Paint()..color = Colors.black.withAlpha(40),
    );
    // posts
    final post = Paint()..color = const Color(0xFF795548);
    c.drawRect(Rect.fromLTWH(r.left, r.top, 6, r.height), post);
    c.drawRect(Rect.fromLTWH(r.right - 6, r.top, 6, r.height), post);
    // counter
    final counter = Rect.fromLTRB(r.left, r.top + 34, r.right, r.bottom);
    c.drawRRect(RRect.fromRectAndRadius(counter, const Radius.circular(6)),
        Paint()..color = const Color(0xFFA1887F));
    c.drawRect(Rect.fromLTRB(counter.left, counter.top, counter.right, counter.top + 8),
        Paint()..color = const Color(0xFFBCAAA4));
    // produce
    const fruit = <Color>[
      Color(0xFFE53935),
      Color(0xFFFFB300),
      Color(0xFF7CB342),
      Color(0xFFFB8C00),
      Color(0xFFD81B60),
    ];
    for (int i = 0; i < 6; i++) {
      final fx = r.left + 14 + i * ((r.width - 28) / 5);
      c.drawCircle(Offset(fx, counter.top + 3),
          7, Paint()..color = fruit[i % fruit.length]);
    }
    // awning
    const stripes = 8;
    final aw = r.width + 12;
    final sw = aw / stripes;
    for (int i = 0; i < stripes; i++) {
      final rect = Rect.fromLTWH(r.left - 6 + i * sw, r.top - 4, sw, 30);
      c.drawRect(rect, Paint()..color = i.isEven ? s.color : Colors.white);
      c.drawCircle(Offset(rect.center.dx, rect.bottom), sw / 2,
          Paint()..color = i.isEven ? s.color : Colors.white);
    }
  }

  void _tree(Canvas c, Offset p) {
    c.drawOval(Rect.fromCenter(center: p + const Offset(4, 6), width: 54, height: 18),
        Paint()..color = Colors.black.withAlpha(45));
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: p + const Offset(0, -8), width: 14, height: 30),
          const Radius.circular(4)),
      Paint()..color = const Color(0xFF6D4C41),
    );
    final sway = math.sin(w.time * 1.4 + p.dx) * 1.5;
    c.drawCircle(p + Offset(-14 + sway, -34), 22, Paint()..color = const Color(0xFF2E7D32));
    c.drawCircle(p + Offset(14 + sway, -34), 22, Paint()..color = const Color(0xFF2E7D32));
    c.drawCircle(p + Offset(sway, -54), 26, Paint()..color = const Color(0xFF388E3C));
    c.drawCircle(p + Offset(sway - 8, -58), 12, Paint()..color = const Color(0xFF66BB6A));
  }

  // ---- characters ---------------------------------------------------------

  void _face(Canvas c, Offset head, Offset look) {
    final eye = Paint()..color = const Color(0xFF263238);
    c.drawCircle(head + Offset(-4.5 + look.dx * 2, 1 + look.dy * 1.5), 1.8, eye);
    c.drawCircle(head + Offset(4.5 + look.dx * 2, 1 + look.dy * 1.5), 1.8, eye);
    c.drawArc(
      Rect.fromCenter(center: head + Offset(look.dx * 2, 6), width: 8, height: 5),
      0.2,
      2.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF5D4037),
    );
  }

  void _npc(Canvas c, _Npc n) {
    final p = n.pos;
    final bob = math.sin(w.time * 3 + p.dx) * 3;

    if (w.nearbyId == n.id) {
      c.drawCircle(
        p + const Offset(0, 10),
        42 + math.sin(w.time * 5) * 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = n.accent.withAlpha(190),
      );
    }

    c.drawOval(Rect.fromCenter(center: p + const Offset(0, 17), width: 34, height: 11),
        Paint()..color = Colors.black.withAlpha(55));
    final shoe = Paint()..color = const Color(0xFF37474F);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: p + const Offset(-7, 15), width: 10, height: 7),
            const Radius.circular(3)),
        shoe);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: p + const Offset(7, 15), width: 10, height: 7),
            const Radius.circular(3)),
        shoe);

    final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: p + const Offset(0, 1), width: 28, height: 30),
        const Radius.circular(11));
    c.drawRRect(body, Paint()..color = n.shirt);
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: p + const Offset(0, 9), width: 28, height: 10),
          const Radius.circular(6)),
      Paint()..color = Colors.black.withAlpha(30),
    );
    _label(c, n.emoji, p + const Offset(0, 2), size: 13, shadow: false);

    final head = p + const Offset(0, -22);
    c.drawCircle(head, 13, Paint()..color = const Color(0xFFF2C29B));
    c.drawArc(Rect.fromCircle(center: head, radius: 13.5), math.pi, math.pi, true,
        Paint()..color = n.hair);
    _face(c, head, Offset.zero);

    // marker
    final mp = p + Offset(0, -58 + bob);
    if (!n.done) {
      final bubble = RRect.fromRectAndRadius(
          Rect.fromCenter(center: mp, width: 34, height: 26), const Radius.circular(13));
      c.drawRRect(bubble, Paint()..color = Colors.white);
      c.drawRRect(
        bubble,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = n.accent,
      );
      final tail = Path()
        ..moveTo(mp.dx - 5, mp.dy + 12)
        ..lineTo(mp.dx, mp.dy + 19)
        ..lineTo(mp.dx + 5, mp.dy + 12)
        ..close();
      c.drawPath(tail, Paint()..color = Colors.white);
      _label(c, '\u{1F4AC}', mp, size: 15, shadow: false);
    } else {
      c.drawCircle(mp, 13, Paint()..color = const Color(0xFF43A047));
      _label(c, '\u2713', mp, size: 16);
    }

    // name tag
    final tp = TextPainter(
      text: TextSpan(
        text: n.name,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tagRect = Rect.fromCenter(
        center: p + const Offset(0, 32), width: tp.width + 14, height: 17);
    c.drawRRect(RRect.fromRectAndRadius(tagRect, const Radius.circular(9)),
        Paint()..color = Colors.black.withAlpha(120));
    tp.paint(c, tagRect.center - Offset(tp.width / 2, tp.height / 2));
  }

  void _player(Canvas c) {
    final p = w.player;
    final leg = w.moving ? math.sin(w.walkPhase) * 4 : 0.0;
    final bounce = w.moving ? (math.sin(w.walkPhase * 2).abs()) * 2 : 0.0;

    c.drawOval(Rect.fromCenter(center: p + const Offset(0, 17), width: 34, height: 11),
        Paint()..color = Colors.black.withAlpha(60));

    final shoe = Paint()..color = const Color(0xFFFFFFFF);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: p + Offset(-7, 15 + leg), width: 10, height: 7),
            const Radius.circular(3)),
        shoe);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: p + Offset(7, 15 - leg), width: 10, height: 7),
            const Radius.circular(3)),
        shoe);

    final bp = p + Offset(0, -bounce);
    // backpack
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: bp + const Offset(0, 0), width: 34, height: 24),
            const Radius.circular(8)),
        Paint()..color = const Color(0xFFFFA000));
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: bp + const Offset(0, 1), width: 28, height: 30),
            const Radius.circular(11)),
        Paint()..color = const Color(0xFF2D7DFF));

    final head = bp + const Offset(0, -22);
    c.drawCircle(head, 13, Paint()..color = const Color(0xFFF2C29B));
    c.drawArc(Rect.fromCircle(center: head, radius: 13.5), math.pi, math.pi, true,
        Paint()..color = const Color(0xFF3E2723));
    // cap
    c.drawArc(Rect.fromCircle(center: head + const Offset(0, -1), radius: 14),
        math.pi, math.pi, true, Paint()..color = const Color(0xFFE53935));
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: head + Offset(w.facing.dx * 6, -1), width: 20, height: 4),
            const Radius.circular(2)),
        Paint()..color = const Color(0xFFC62828));
    _face(c, head, w.facing);
  }

  // ---- atmosphere ---------------------------------------------------------

  void _motes(Canvas c, Rect vis) {
    final paint = Paint();
    final inflated = vis.inflate(30);
    for (final m in w.motes) {
      final x = m.x + math.sin(w.time * m.speed + m.phase) * 22;
      final y = m.y + math.cos(w.time * m.speed * 0.8 + m.phase) * 16;
      final p = Offset(x, y);
      if (!inflated.contains(p)) continue;
      final a = (140 + 100 * math.sin(w.time * 2 * m.speed + m.phase))
          .clamp(30, 255)
          .toInt();
      paint.color = const Color(0xFFFFF59D).withAlpha(a);
      c.drawCircle(p, m.r, paint);
    }
  }

  void _clouds(Canvas canvas, Size size) {
    for (int i = 0; i < 6; i++) {
      final speed = 10.0 + i * 4.0;
      final span = size.width + 400;
      final x = ((i * 260.0 + w.time * speed) % span) - 200;
      final y = 40.0 + ((i * 53) % 160);
      final s = 0.8 + (i % 3) * 0.35;
      _cloud(canvas, Offset(x, y), s);
    }
  }

  void _cloud(Canvas c, Offset o, double s) {
    final p = Paint()..color = Colors.white.withAlpha(150);
    c.drawCircle(o + Offset(-30 * s, 6 * s), 18 * s, p);
    c.drawCircle(o + Offset(-8 * s, -6 * s), 24 * s, p);
    c.drawCircle(o + Offset(22 * s, 2 * s), 20 * s, p);
    c.drawCircle(o + Offset(44 * s, 8 * s), 14 * s, p);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: o + Offset(6 * s, 12 * s), width: 100 * s, height: 18 * s),
        Radius.circular(9 * s),
      ),
      p,
    );
  }
}
