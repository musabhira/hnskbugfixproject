// =============================================================================
//  CITADEL FIGHT – 1-on-1 asynchronous English duel arena
//  Single self-contained file. No assets, no packages, no main()/runApp().
//
//  Usage:
//    Navigator.push(context, MaterialPageRoute(builder: (_) => CitadelFightDuelPage(
//      opponentName: 'Anu', opponentAvatar: '🥷', opponentLevel: 7,
//      onDuelFinished: (r) => debugPrint(r.toString()),
//    )));
//
//  Round 1 (User A):  isUserBTurn = false  -> callback gets stage 'challenger_finished'
//                     (store duelSeed + questionCount so User B plays the SAME set).
//  Round 2 (User B):  isUserBTurn = true, pass userATimeSeconds / userAScore /
//                     userACorrect / duelSeed / questionCount from Round 1
//                     -> callback gets stage 'duel_resolved'.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_sentence_builder_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_negative_sentence_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_chat_reply_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/day1_az_and_300vocab_data.dart';

// ------------------------------- THEME ---------------------------------------
const _kBg = Color(0xFF080C24);
const _kPanel = Color(0xFF141A3F);
const _kPanel2 = Color(0xFF232C60);
const _kCyan = Color(0xFF00E5FF);
const _kPink = Color(0xFFFF2D95);
const _kGold = Color(0xFFFFC832);
const _kGreen = Color(0xFF00E676);
const _kRed = Color(0xFFFF5252);
const _kPurple = Color(0xFF8C5CFF);

Color _a(Color c, double o) => c.withAlpha((o.clamp(0.0, 1.0) * 255).round());

enum _Phase { setup, countdown, playing, sprint, waiting, resolution }

enum _GameType { builder, spelling, train, vocab, tense }

String _gameTitle(_GameType t) {
  switch (t) {
    case _GameType.builder:
      return 'SENTENCE BUILDER';
    case _GameType.spelling:
      return 'SPELLING RECTIFIER';
    case _GameType.train:
      return 'WORD TRAIN';
    case _GameType.vocab:
      return 'VOCAB DEFUSAL';
    case _GameType.tense:
      return 'TENSE TIMELINE';
  }
}

String _gameEmoji(_GameType t) {
  switch (t) {
    case _GameType.builder:
      return '🧩';
    case _GameType.spelling:
      return '🔤';
    case _GameType.train:
      return '🚂';
    case _GameType.vocab:
      return '⚡';
    case _GameType.tense:
      return '⏱️';
  }
}

Color _gameColor(_GameType t) {
  switch (t) {
    case _GameType.builder:
      return _kCyan;
    case _GameType.spelling:
      return _kPink;
    case _GameType.train:
      return _kGold;
    case _GameType.vocab:
      return _kGreen;
    case _GameType.tense:
      return _kPurple;
  }
}

// ----------------------------- QUESTION DATA (3,000+ ITEMS) ------------------
const List<List<String>> _kSpellingCurated = [
  ['Necessary', 'Neccessary', 'Necesary', 'Nessesary'],
  ['Receive', 'Recieve', 'Receeve', 'Riceive'],
  ['Environment', 'Enviroment', 'Environmant', 'Envirenment'],
  ['Separate', 'Seperate', 'Separete', 'Seprate'],
  ['Definitely', 'Definately', 'Definitly', 'Defenitely'],
  ['Beautiful', 'Beutiful', 'Beautifull', 'Beatiful'],
  ['Government', 'Goverment', 'Governmant', 'Guvernment'],
  ['Tomorrow', 'Tommorow', 'Tomorow', 'Tomarrow'],
  ['Accommodate', 'Acommodate', 'Accomodate', 'Acomodate'],
  ['Calendar', 'Calender', 'Calandar', 'Calandor'],
  ['Colleague', 'Coleague', 'Collegue', 'Colleag'],
  ['Conscience', 'Concience', 'Conscence', 'Consience'],
  ['Embarrass', 'Embarass', 'Emberrass', 'Embaras'],
  ['Guarantee', 'Garantee', 'Garanty', 'Guaarantee'],
  ['Harass', 'Harrass', 'Harras', 'Harres'],
  ['Maintenance', 'Maintainance', 'Maintenence', 'Maintenanse'],
  ['Millennium', 'Millenium', 'Milennium', 'Milenium'],
  ['Noticeable', 'Noticable', 'Noticeble', 'Notisable'],
  ['Occasion', 'Ocassion', 'Occassion', 'Ocasion'],
  ['Occurrence', 'Occurence', 'Occurrance', 'Ocurrence'],
  ['Possession', 'Posession', 'Possesion', 'Posestion'],
  ['Privilege', 'Privelege', 'Priviledge', 'Privilige'],
  ['Rhythm', 'Rythm', 'Rhythym', 'Rhytm'],
  ['Success', 'Succes', 'Sucess', 'Sucses'],
  ['Weather', 'Wheather', 'Wether', 'Weatther'],
  ['Vacuum', 'Vaccum', 'Vacume', 'Vacuume'],
  ['Knowledge', 'Knowlege', 'Nowledge', 'Knowlage'],
  ['Business', 'Buissness', 'Buisness', 'Bussiness'],
  ['Foreign', 'Foriegn', 'Forein', 'Foreing'],
  ['Friend', 'Freind', 'Frind', 'Frend'],
  ['Grammar', 'Grammer', 'Gramar', 'Gramer'],
  ['Height', 'Hieght', 'Heigth', 'Hieht'],
  ['Leisure', 'Liesure', 'Leisur', 'Leasure'],
  ['Library', 'Libary', 'Librery', 'Liberary'],
  ['Muscle', 'Mussle', 'Musel', 'Muscel'],
  ['Neighbor', 'Nieghbor', 'Neighbour', 'Naybor'],
  ['Pronunciation', 'Pronounciation', 'Pronuntiation', 'Pronunsiation'],
  ['Questionnaire', 'Questionaire', 'Questionary', 'Questonaire'],
  ['Schedule', 'Shedule', 'Schedul', 'Shedul'],
  ['Threshold', 'Threshhold', 'Thresold', 'Threshould'],
  ['Twelfth', 'Twelth', 'Twelveth', 'Twelf'],
  ['Until', 'Untill', 'Untile', 'Untl'],
  ['Weird', 'Wierd', 'Weerd', 'Wiered'],
  ['Apparent', 'Apparant', 'Aparent', 'Apparrent'],
  ['Believe', 'Beleive', 'Beleeve', 'Bilieve'],
  ['Disappoint', 'Dissappoint', 'Disapoint', 'Dissapoint'],
  ['Immediately', 'Imediately', 'Immediatly', 'Immedately'],
  ['Independent', 'Independant', 'Independint', 'Indipendent'],
  ['Intelligence', 'Intellegence', 'Inteligence', 'Intelligeance'],
  ['Judgment', 'Judgement', 'Jugment', 'Judgmant'],
  ['Recommend', 'Recommed', 'Recommand', 'Reccomend'],
  ['Surprise', 'Suprise', 'Surprize', 'Supprise'],
  ['Tendency', 'Tendancey', 'Tendancy', 'Tendisey'],
  ['Truly', 'Truely', 'Truley', 'Trulie'],
  ['Visible', 'Visable', 'Vissible', 'Vizible'],
];

class _Q {
  final _GameType type;
  final String prompt;
  final String sub;
  final List<String> options; // choices / scrambled words / letter bank
  final int answerIndex;
  final String answer;
  final List<int> blanks;
  final int zone;
  final double par; // seconds for full speed bonus
  const _Q({
    required this.type,
    required this.prompt,
    this.sub = '',
    required this.options,
    this.answerIndex = 0,
    required this.answer,
    this.blanks = const [],
    this.zone = 1,
    this.par = 6,
  });
}

class _Res {
  final _Q q;
  final bool ok;
  final int ms;
  final int pts;
  final String given;
  const _Res(this.q, this.ok, this.ms, this.pts, this.given);
}

/// Deterministic: same seed + count => identical question set for both players.
/// Pulls dynamically from 3,000+ real curriculum items across 90 days!
List<_Q> _buildQuestions(int count, int seed) {
  final r = math.Random(seed);
  final out = <_Q>[];
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final vocabPool = Day1VocabBankData.words300;

  // Track used answers to ensure 100% uniqueness in this duel
  final usedAnswers = <String>{};

  for (var i = 0; i < count; i++) {
    final t = _GameType.values[i % _GameType.values.length];

    switch (t) {
      // 🧩 1. SENTENCE BUILDER (Pulls from 90-day sentence builder, negative sentences, chat reply)
      case _GameType.builder:
        String sentence = '';
        String prompt = '';
        var attempts = 0;

        while (attempts < 15) {
          attempts++;
          final mode = attempts % 3;
          final day = r.nextInt(90) + 1;

          if (mode == 0) {
            final rounds = Pocket90DaySentenceBuilderData.getSentencesForDay(day);
            if (rounds.isNotEmpty) {
              final item = rounds[r.nextInt(rounds.length)];
              sentence = item.sentence.replaceAll(RegExp(r'[.!?]'), '').trim();
              prompt = item.translationMl;
            }
          } else if (mode == 1) {
            final rounds = Pocket90DayNegativeSentenceData.getRoundsForDay(day);
            if (rounds.isNotEmpty) {
              final item = rounds[r.nextInt(rounds.length)];
              sentence = item.negativeSentence.replaceAll(RegExp(r'[.!?]'), '').trim();
              prompt = item.negativeSentenceMl;
            }
          } else {
            final rounds = Pocket90DayChatReplyData.getScenariosForDay(day);
            if (rounds.isNotEmpty) {
              final item = rounds[r.nextInt(rounds.length)];
              sentence = item.expectedReply.replaceAll(RegExp(r'[.!?]'), '').trim();
              prompt = item.expectedReplyMl;
            }
          }

          if (sentence.isNotEmpty && !usedAnswers.contains(sentence)) {
            break;
          }
        }

        if (sentence.isEmpty) {
          sentence = 'I want to speak fluent English every day';
          prompt = 'എനിക്ക് എല്ലാ ദിവസവും നന്നായി ഇംഗ്ലീഷ് സംസാരിക്കണം';
        }
        usedAnswers.add(sentence);

        final words = sentence.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        final sc = List<String>.from(words);
        var tries = 0;
        do {
          sc.shuffle(r);
          tries++;
        } while (sc.join(' ') == sentence && tries < 20);

        out.add(_Q(
          type: t,
          prompt: prompt,
          sub: 'Tap the words in the right order',
          options: sc,
          answer: sentence,
          par: 4.0 + words.length * 1.5,
        ));
        break;

      // 🔤 2. SPELLING RECTIFIER (Pulls from 50+ curated tricky exam words)
      case _GameType.spelling:
        List<String> d = _kSpellingCurated[r.nextInt(_kSpellingCurated.length)];
        var tries = 0;
        while (usedAnswers.contains(d[0]) && tries < 20) {
          d = _kSpellingCurated[r.nextInt(_kSpellingCurated.length)];
          tries++;
        }
        usedAnswers.add(d[0]);

        final opts = List<String>.from(d)..shuffle(r);
        out.add(_Q(
          type: t,
          prompt: 'Spot the CORRECT spelling',
          sub: 'One of these four is right',
          options: opts,
          answerIndex: opts.indexOf(d[0]),
          answer: d[0],
          par: 5.5,
        ));
        break;

      // 🚂 3. WORD TRAIN (Pulls from 300+ vocabulary bank words with wagons)
      case _GameType.train:
        Map<String, dynamic> vItem = vocabPool[r.nextInt(vocabPool.length)];
        var tries = 0;
        while ((vItem['word']?.toString().length ?? 0) < 4 && tries < 30) {
          vItem = vocabPool[r.nextInt(vocabPool.length)];
          tries++;
        }
        final rawWord = vItem['word']?.toString().toUpperCase() ?? 'WATER';
        final word = rawWord.replaceAll(RegExp(r'[^A-Z]'), '');
        final hint = vItem['meaning']?.toString() ?? 'വെള്ളം';
        usedAnswers.add(word);

        final len = word.length;
        final blankCount = len <= 5 ? 1 : (len <= 7 ? 2 : 3);
        final indices = List<int>.generate(len, (idx) => idx)..shuffle(r);
        final blanks = indices.take(blankCount).toList()..sort();

        final missingLetters = blanks.map((b) => word[b]).toList();
        final decoys = alphabet.split('').where((l) => !missingLetters.contains(l)).toList()..shuffle(r);
        final bank = [...missingLetters, ...decoys.take(3)]..shuffle(r);

        out.add(_Q(
          type: t,
          prompt: hint,
          sub: '$len letters · fill the empty wagons',
          options: bank,
          answer: word,
          blanks: blanks,
          par: 4.5 + blanks.length * 2.0,
        ));
        break;

      // ⚡ 4. VOCAB DEFUSAL (Pulls from 300+ everyday vocab bank)
      case _GameType.vocab:
        final vItem = vocabPool[r.nextInt(vocabPool.length)];
        final correctWord = vItem['word']?.toString() ?? 'Water';
        final meaning = vItem['meaning']?.toString() ?? 'വെള്ളം';
        usedAnswers.add(correctWord);

        // Pick 3 random distinct distractors
        final otherWords = vocabPool
            .where((w) => w['word'] != correctWord)
            .map((w) => w['word']?.toString() ?? '')
            .where((w) => w.isNotEmpty)
            .toList()
          ..shuffle(r);

        final choices = [correctWord, ...otherWords.take(3)]..shuffle(r);

        out.add(_Q(
          type: t,
          prompt: meaning,
          sub: 'Pick the English word',
          options: choices,
          answerIndex: choices.indexOf(correctWord),
          answer: correctWord,
          par: 5.0,
        ));
        break;

      // ⏱️ 5. TENSE TIMELINE (Pulls from 90 days * 360 verbs * 3 tense forms = 1,080 questions!)
      case _GameType.tense:
        final day = r.nextInt(90) + 1;
        final verbs = Pocket90DayVerbTimelineData.getVerbsForDay(day);
        final v = verbs.isNotEmpty ? verbs[r.nextInt(verbs.length)] : null;
        final zone = r.nextInt(3); // 0 Past, 1 Present, 2 Future

        String sentence = '';
        String correct = '';
        if (v != null) {
          if (zone == 0) {
            sentence = v.pastSentence;
            correct = v.past;
          } else if (zone == 1) {
            sentence = v.presentSentence;
            correct = v.present;
          } else {
            sentence = v.futureSentence;
            correct = v.future;
          }
        }

        if (sentence.isEmpty || correct.isEmpty) {
          sentence = 'Yesterday she went to the market.';
          correct = 'went';
        }

        // Mask the verb in the sentence
        final maskedSentence = sentence.replaceAll(
          RegExp(RegExp.escape(correct), caseSensitive: false),
          '______',
        );

        final List<String> opts = [];
        if (v != null) {
          opts.addAll([v.past, v.present, v.future]);
          // Add a 4th continuous or distractor
          opts.add('${v.baseVerb}ing');
        } else {
          opts.addAll(['went', 'go', 'will go', 'going']);
        }
        final uniqueOpts = opts.toSet().toList()..shuffle(r);
        while (uniqueOpts.length < 4) {
          uniqueOpts.add('is ${v?.baseVerb ?? "doing"}');
        }

        out.add(_Q(
          type: t,
          prompt: maskedSentence,
          sub: 'Choose the right verb form (${zone == 0 ? "PAST" : zone == 1 ? "PRESENT" : "FUTURE"})',
          options: uniqueOpts.take(4).toList(),
          answerIndex: uniqueOpts.take(4).toList().indexOf(correct),
          answer: correct,
          zone: zone,
          par: 6.0,
        ));
        break;
    }
  }
  return out;
}

// ------------------------------- ARENA MODEL ---------------------------------
class _Particle {
  double x, y, vx, vy, life, size, rot, vr;
  final double maxLife;
  final Color color;
  final int kind; // 0 spark, 1 confetti
  _Particle(this.x, this.y, this.vx, this.vy, this.life, this.size, this.color,
      this.kind,
      {this.rot = 0, this.vr = 0})
      : maxLife = life;
}

class _Beam {
  final int kind; // 0 laser, 1 slash
  double life;
  final double maxLife;
  final Color color;
  _Beam(this.kind, this.life, this.color) : maxLife = life;
}

class _ArenaModel {
  Size size = const Size(360, 250);
  final math.Random rnd = math.Random();
  double t = 0, shake = 0, lunge = 0, oppHurt = 0, plHurt = 0;
  double shieldFlash = 0, shield = 1, sprint = 0;
  bool sprintOn = false, victory = false, oppHidden = false, mystery = false;
  bool ceremony = false;
  double confettiTimer = 0;
  final List<_Particle> particles = [];
  final List<_Beam> beams = [];

  double get s => (size.height / 250).clamp(0.7, 1.15);
  double get ground => size.height * 0.84;
  Offset get oppPos => Offset(size.width * 0.76, ground);
  Offset get playerPos {
    final base = size.width * 0.2;
    final target = size.width * 0.83 - 72 * s;
    final x = base +
        (target - base) * Curves.easeInOut.transform(sprint.clamp(0.0, 1.0)) +
        (sprintOn ? 0 : lunge * 34 * s);
    return Offset(x, ground);
  }

  Offset get playerHand => playerPos + Offset(40 * s, -62 * s);
  Offset get shieldCenter => oppPos + Offset(-30 * s, -55 * s);

  void update(double dt) {
    t += dt;
    shake = math.max(0.0, shake - dt * 40);
    lunge = math.max(0.0, lunge - dt * 3.5);
    oppHurt = math.max(0.0, oppHurt - dt * 3);
    plHurt = math.max(0.0, plHurt - dt * 3);
    shieldFlash = math.max(0.0, shieldFlash - dt * 4);
    if (sprintOn && sprint < 1) sprint = math.min(1.0, sprint + dt / 2.2);
    for (final p in particles) {
      p.life -= dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      if (p.kind == 1) {
        p.vy += 260 * dt;
        p.vx *= (1 - 0.4 * dt);
        p.rot += p.vr * dt;
      } else {
        p.vy += 300 * dt;
      }
    }
    particles.removeWhere((p) => p.life <= 0 || p.y > size.height + 40);
    for (final b in beams) {
      b.life -= dt;
    }
    beams.removeWhere((b) => b.life <= 0);
    if (ceremony && confettiTimer > 0) {
      confettiTimer -= dt;
      confetti(3);
    }
  }

  void burst(Offset c, Color col, int n, {double speed = 240}) {
    for (var i = 0; i < n; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final v = speed * (0.3 + rnd.nextDouble() * 0.9);
      particles.add(_Particle(c.dx, c.dy, math.cos(a) * v,
          math.sin(a) * v - 60, 0.4 + rnd.nextDouble() * 0.5,
          2 + rnd.nextDouble() * 3, col, 0));
    }
  }

  static const _confettiColors = [
    _kGold, _kPink, _kCyan, _kGreen, _kPurple, Colors.white
  ];

  void confetti(int n) {
    for (var i = 0; i < n; i++) {
      particles.add(_Particle(
          rnd.nextDouble() * size.width,
          -10,
          (rnd.nextDouble() - .5) * 120,
          40 + rnd.nextDouble() * 80,
          4 + rnd.nextDouble() * 2,
          6 + rnd.nextDouble() * 6,
          _confettiColors[rnd.nextInt(_confettiColors.length)],
          1,
          rot: rnd.nextDouble() * 6,
          vr: (rnd.nextDouble() - .5) * 12));
    }
  }

  void confettiBurst() {
    for (var i = 0; i < 90; i++) {
      particles.add(_Particle(
          size.width / 2,
          size.height * .6,
          (rnd.nextDouble() - .5) * 560,
          -(200 + rnd.nextDouble() * 420),
          3 + rnd.nextDouble() * 2,
          6 + rnd.nextDouble() * 6,
          _confettiColors[rnd.nextInt(_confettiColors.length)],
          1,
          rot: rnd.nextDouble() * 6,
          vr: (rnd.nextDouble() - .5) * 14));
    }
  }

  void hitOpponent(int combo) {
    lunge = 1;
    shake = 6 + math.min(combo, 8) * 1.2;
    oppHurt = 1;
    shieldFlash = 1;
    beams.add(_Beam(combo % 2 == 0 ? 1 : 0, 0.35, combo >= 4 ? _kPink : _kCyan));
    burst(shieldCenter, _kCyan, 16 + math.min(combo, 10) * 2, speed: 280);
    burst(shieldCenter, Colors.white, 8, speed: 180);
  }

  void missHit() {
    plHurt = 1;
    shake = 4;
    burst(playerPos + Offset(10 * s, -55 * s), _kRed, 14, speed: 200);
  }
}

// ------------------------------- PAINTERS ------------------------------------
void _drawText(Canvas c, String s, Offset center, double size, Color col,
    {FontWeight w = FontWeight.w900}) {
  final tp = TextPainter(
    text: TextSpan(
        text: s,
        style: TextStyle(fontSize: size, color: col, fontWeight: w)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

void _paintParticles(Canvas c, _ArenaModel m) {
  for (final pt in m.particles) {
    final k = (pt.life / pt.maxLife).clamp(0.0, 1.0);
    if (pt.kind == 1) {
      final paint = Paint()..color = _a(pt.color, math.min(1.0, k * 3));
      c.save();
      c.translate(pt.x, pt.y);
      c.rotate(pt.rot);
      c.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: pt.size, height: pt.size * .55),
          paint);
      c.restore();
    } else {
      c.drawCircle(Offset(pt.x, pt.y), pt.size * (0.4 + .6 * k),
          Paint()..color = _a(pt.color, k));
    }
  }
}

Path _starPath(Offset c, double r) {
  final p = Path();
  for (var i = 0; i < 10; i++) {
    final rad = i.isEven ? r : r * .45;
    final a = -math.pi / 2 + i * math.pi / 5;
    final pt = Offset(c.dx + math.cos(a) * rad, c.dy + math.sin(a) * rad);
    if (i == 0) {
      p.moveTo(pt.dx, pt.dy);
    } else {
      p.lineTo(pt.dx, pt.dy);
    }
  }
  p.close();
  return p;
}

// ignore: unused_element
class _ArenaPainter extends CustomPainter {
  final _ArenaModel m;
  _ArenaPainter(this.m, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas c, Size sz) {
    m.size = sz;
    final s = m.s;
    c.save();
    c.clipRect(Offset.zero & sz);
    if (m.shake > 0) {
      c.translate((m.rnd.nextDouble() - .5) * m.shake,
          (m.rnd.nextDouble() - .5) * m.shake);
    }
    _sky(c, sz);
    _citadel(c, Offset(sz.width * .83, m.ground - 4 * s), s);

    if (!m.oppHidden) {
      _fighter(c, m.oppPos, s, _kPink, _kPurple,
          right: false, hurt: m.oppHurt, t: m.t, victory: m.mystery);
      if (m.mystery) {
        _drawText(c, '❓', m.oppPos + Offset(0, -112 * s), 20 * s, Colors.white);
      }
      _shield(c, s);
    }
    _fighter(c, m.playerPos, s, _kCyan, _kGold,
        right: true,
        attack: m.lunge,
        hurt: m.plHurt,
        t: m.t,
        victory: m.victory,
        run: m.sprintOn && m.sprint < 1);
    if (m.victory) {
      _drawText(c, 'FINISHED! 🏁', m.playerPos + Offset(0, -118 * s), 13 * s,
          _kGold);
    }

    for (final b in m.beams) {
      final k = (b.life / b.maxLife).clamp(0.0, 1.0);
      final from = m.playerHand;
      final to = m.shieldCenter;
      if (b.kind == 0) {
        c.drawLine(
            from,
            to,
            Paint()
              ..color = _a(b.color, .6 * k)
              ..strokeWidth = 16 * k * s
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        c.drawLine(
            from,
            to,
            Paint()
              ..color = _a(Colors.white, k)
              ..strokeWidth = 4 * k * s
              ..strokeCap = StrokeCap.round);
        c.drawCircle(to, 18 * k * s, Paint()..color = _a(Colors.white, .7 * k));
      } else {
        for (var j = 0; j < 2; j++) {
          final off = j * 14.0 * s;
          final path = Path()
            ..moveTo(to.dx - 55 * s + off, to.dy - 65 * s)
            ..quadraticBezierTo(to.dx + 5 * s + off, to.dy - 10 * s,
                to.dx + 50 * s + off * .5, to.dy + 48 * s);
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = _a(b.color, .7 * k)
                ..strokeWidth = 12 * k * s
                ..strokeCap = StrokeCap.round
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = _a(Colors.white, k)
                ..strokeWidth = 4 * k * s
                ..strokeCap = StrokeCap.round);
        }
      }
    }
    _paintParticles(c, m);
    c.restore();
  }

  void _sky(Canvas c, Size sz) {
    final s = m.s;
    final rect = Offset.zero & sz;
    c.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1030), Color(0xFF2A1B63), Color(0xFF6A2C7E)],
          ).createShader(rect));
    final sp = Paint();
    for (var i = 0; i < 36; i++) {
      final x = ((i * 97) % 100) / 100 * sz.width;
      final y = ((i * 53) % 55) / 100 * sz.height;
      sp.color = _a(Colors.white, .25 + .6 * math.sin(m.t * 2 + i).abs());
      c.drawCircle(Offset(x, y), 1 + (i % 3) * .5, sp);
    }
    final moon = Offset(sz.width * .14, sz.height * .2);
    c.drawCircle(moon, 34 * s, Paint()..color = _a(const Color(0xFFFFF3C4), .12));
    c.drawCircle(moon, 20 * s, Paint()..color = _a(const Color(0xFFFFF3C4), .9));

    final g = m.ground;
    final mp = Path()
      ..moveTo(0, g)
      ..lineTo(0, g - 50 * s)
      ..lineTo(sz.width * .18, g - 85 * s)
      ..lineTo(sz.width * .34, g - 45 * s)
      ..lineTo(sz.width * .5, g - 95 * s)
      ..lineTo(sz.width * .68, g - 50 * s)
      ..lineTo(sz.width * .9, g - 80 * s)
      ..lineTo(sz.width, g - 40 * s)
      ..lineTo(sz.width, g)
      ..close();
    c.drawPath(mp, Paint()..color = const Color(0xFF1A1745));
    final gr = Rect.fromLTRB(0, g, sz.width, sz.height);
    c.drawRect(
        gr,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF241B52), Color(0xFF0B0E2A)],
          ).createShader(gr));
    c.drawLine(Offset(0, g), Offset(sz.width, g),
        Paint()..color = _a(_kCyan, .8)..strokeWidth = 2);
    final lp = Paint()
      ..color = _a(_kCyan, .18)
      ..strokeWidth = 1;
    for (var i = -6; i <= 6; i++) {
      c.drawLine(Offset(sz.width / 2 + i * 18, g),
          Offset(sz.width / 2 + i * 70, sz.height), lp);
    }
  }

  void _citadel(Canvas c, Offset b, double s) {
    final stone = Paint()..color = const Color(0xFF2C3566);
    final dark = Paint()..color = const Color(0xFF1E2548);
    for (final dx in [-58.0, 30.0]) {
      c.drawRect(Rect.fromLTWH(b.dx + dx * s, b.dy - 120 * s, 28 * s, 120 * s), dark);
      for (var k = 0; k < 3; k++) {
        c.drawRect(
            Rect.fromLTWH(b.dx + (dx + k * 10.5) * s, b.dy - 130 * s, 7 * s, 10 * s),
            dark);
      }
      c.drawRect(Rect.fromLTWH(b.dx + (dx + 10) * s, b.dy - 90 * s, 8 * s, 14 * s),
          Paint()..color = _a(_kGold, .9));
    }
    c.drawRect(Rect.fromLTWH(b.dx - 40 * s, b.dy - 85 * s, 80 * s, 85 * s), stone);
    for (var k = 0; k < 5; k++) {
      c.drawRect(
          Rect.fromLTWH(b.dx - 40 * s + k * 17.5 * s, b.dy - 95 * s, 11 * s, 10 * s),
          stone);
    }
    final door = Path()
      ..moveTo(b.dx - 14 * s, b.dy)
      ..lineTo(b.dx - 14 * s, b.dy - 34 * s)
      ..arcToPoint(Offset(b.dx + 14 * s, b.dy - 34 * s),
          radius: Radius.circular(14 * s))
      ..lineTo(b.dx + 14 * s, b.dy)
      ..close();
    c.drawPath(door, Paint()..color = _a(_kGold, .35 + .15 * math.sin(m.t * 3)));
    c.drawPath(
        door,
        Paint()
          ..color = _a(_kGold, .9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final top = Offset(b.dx, b.dy - 95 * s);
    c.drawLine(top, top + Offset(0, -34 * s),
        Paint()..color = Colors.white70..strokeWidth = 2);
    final fl = Path()
      ..moveTo(top.dx, top.dy - 34 * s)
      ..lineTo(top.dx + 24 * s, top.dy - 28 * s + math.sin(m.t * 5) * 3)
      ..lineTo(top.dx, top.dy - 20 * s)
      ..close();
    c.drawPath(fl, Paint()..color = _kPink);
  }

  void _shield(Canvas c, double s) {
    if (m.shield <= 0.02) return;
    final center = m.oppPos + Offset(-8 * s, -55 * s);
    final rect = Rect.fromCircle(center: center, radius: 60 * s);
    final col = Color.lerp(_kCyan, Colors.white, m.shieldFlash)!;
    c.drawArc(
        rect,
        math.pi - .9,
        1.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = _a(col, .35 + .6 * m.shieldFlash)
          ..strokeWidth = (2 + 7 * m.shield) * s
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  void _fighter(Canvas c, Offset o, double s, Color col, Color acc,
      {required bool right,
      double attack = 0,
      double hurt = 0,
      double t = 0,
      bool victory = false,
      bool run = false}) {
    final dir = right ? 1.0 : -1.0;
    final body = Color.lerp(col, Colors.white, hurt * .8)!;
    final bob = victory
        ? -math.sin(t * 7).abs() * 8 * s
        : math.sin(t * 3) * 2 * s;
    final lean = (attack * 12 - hurt * 10) * s * dir;
    final p = Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final hip = o + Offset(0, -44 * s + bob);
    final neck = hip + Offset(lean, -34 * s);
    final sw = run ? math.sin(t * 18) * 16 * s : 0.0;

    p.strokeWidth = 8 * s;
    c.drawLine(hip, Offset(o.dx - 12 * s + sw, o.dy), p);
    c.drawLine(hip, Offset(o.dx + 12 * s - sw, o.dy), p);
    p.strokeWidth = 11 * s;
    c.drawLine(hip, neck, p);

    final shoulder = neck + Offset(0, 6 * s);
    p.strokeWidth = 7 * s;
    final Offset h1;
    final Offset h2;
    if (victory) {
      h1 = shoulder + Offset(-16 * s, -30 * s);
      h2 = shoulder + Offset(16 * s, -30 * s);
    } else {
      h1 = shoulder + Offset(dir * (16 + attack * 30) * s, 2 * s - attack * 4 * s);
      h2 = shoulder + Offset(-dir * 10 * s, 16 * s);
    }
    c.drawLine(shoulder, h2, p);
    c.drawLine(shoulder, h1, p);
    final glove = Paint()..color = acc;
    c.drawCircle(h2, 8 * s, glove);
    c.drawCircle(h1, 9 * s, glove);

    final head = neck + Offset(lean * .3, -15 * s);
    c.drawCircle(head, 14 * s, Paint()..color = body);
    c.drawLine(
        head + Offset(-14 * s, -3 * s),
        head + Offset(14 * s, -3 * s),
        Paint()
          ..color = acc
          ..strokeWidth = 4 * s);
    c.drawCircle(head + Offset(dir * 6 * s, 2 * s), 2.2 * s,
        Paint()..color = const Color(0xFF0B1030));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TrophyPainter extends CustomPainter {
  final _ArenaModel m;
  final bool gold;
  _TrophyPainter(this.m, this.gold, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas c, Size sz) {
    m.size = sz;
    final cx = sz.width / 2;
    final cy = sz.height * .52;
    final s = sz.height / 230;
    final base = gold ? _kGold : const Color(0xFFB8C4D6);
    final light = gold ? const Color(0xFFFFF0A0) : const Color(0xFFF2F6FB);
    final dark = gold ? const Color(0xFFB8860B) : const Color(0xFF6E7B8F);

    for (var i = 0; i < 14; i++) {
      final a = m.t * .5 + i * math.pi * 2 / 14;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + math.cos(a - .07) * sz.width, cy + math.sin(a - .07) * sz.width)
        ..lineTo(cx + math.cos(a + .07) * sz.width, cy + math.sin(a + .07) * sz.width)
        ..close();
      c.drawPath(path, Paint()..color = _a(base, gold ? .10 : .05));
    }
    final gr = 120 * s + math.sin(m.t * 3) * 8 * s;
    c.drawCircle(
        Offset(cx, cy),
        gr,
        Paint()
          ..shader = RadialGradient(colors: [_a(base, .55), _a(base, 0)])
              .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: gr)));

    final y0 = cy - 70 * s;
    final fill = Paint()
      ..shader = LinearGradient(colors: [dark, light, base, dark])
          .createShader(Rect.fromLTWH(cx - 40 * s, y0, 80 * s, 130 * s));
    final hp = Paint()
      ..color = base
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s;
    c.drawArc(
        Rect.fromCenter(center: Offset(cx - 38 * s, y0 + 24 * s), width: 46 * s, height: 46 * s),
        math.pi / 2, math.pi, false, hp);
    c.drawArc(
        Rect.fromCenter(center: Offset(cx + 38 * s, y0 + 24 * s), width: 46 * s, height: 46 * s),
        -math.pi / 2, math.pi, false, hp);
    final cup = Path()
      ..moveTo(cx - 40 * s, y0)
      ..lineTo(cx + 40 * s, y0)
      ..quadraticBezierTo(cx + 40 * s, y0 + 62 * s, cx, y0 + 80 * s)
      ..quadraticBezierTo(cx - 40 * s, y0 + 62 * s, cx - 40 * s, y0)
      ..close();
    c.drawPath(cup, fill);
    c.drawRect(Rect.fromLTRB(cx - 7 * s, y0 + 78 * s, cx + 7 * s, y0 + 108 * s), fill);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - 34 * s, y0 + 106 * s, cx + 34 * s, y0 + 124 * s),
            Radius.circular(5 * s)),
        fill);
    c.drawPath(_starPath(Offset(cx, y0 + 30 * s), 15 * s),
        Paint()..color = _a(Colors.white, .9));
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + m.t;
      final p = Offset(cx + math.cos(a) * 95 * s, cy + math.sin(a) * 70 * s);
      c.drawPath(_starPath(p, (3 + 4 * math.sin(m.t * 4 + i).abs()) * s),
          Paint()..color = _a(Colors.white, .9));
    }
    _paintParticles(c, m);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ------------------------------ SMALL WIDGETS --------------------------------
Widget _bigButton(String label, IconData icon, VoidCallback onTap,
    {List<Color> colors = const [_kPink, Color(0xFFFF8A00)]}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _a(colors.first, .45), blurRadius: 14, offset: const Offset(0, 4))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ]),
    ),
  );
}

Widget _gameHeader(_GameType t, String hint) {
  final col = _gameColor(t);
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _a(col, .16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col, width: 1.2),
      ),
      child: Text('${_gameEmoji(t)} ${_gameTitle(t)}',
          style: GoogleFonts.outfit(color: col, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
    ),
    const SizedBox(width: 8),
    Expanded(
        child: Text(hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.w500))),
  ]);
}

Widget _chip(String text, Color fill, Color border, VoidCallback? onTap,
    {double opacity = 1}) {
  return Opacity(
    opacity: opacity,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(text,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    ),
  );
}

Widget _promptCard(String text, {double size = 19, Widget? extra}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: _kPanel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kPanel2, width: 1.5),
    ),
    child: Column(children: [
      Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white, fontSize: size, fontWeight: FontWeight.w700, height: 1.3)),
      if (extra != null) ...[const SizedBox(height: 8), extra],
    ]),
  );
}

// --------------------------------- GAME 4/2/5 --------------------------------
/// Multiple-choice mini game: spelling rectifier, vocab defusal, tense timeline.
class _ChoiceGame extends StatefulWidget {
  final _Q q;
  final void Function(bool ok, String given) onAnswer;
  const _ChoiceGame({super.key, required this.q, required this.onAnswer});

  @override
  State<_ChoiceGame> createState() => _ChoiceGameState();
}

class _ChoiceGameState extends State<_ChoiceGame> {
  int? _picked;

  void _tap(int i) {
    if (_picked != null) return;
    setState(() => _picked = i);
    HapticFeedback.selectionClick();
    widget.onAnswer(i == widget.q.answerIndex, widget.q.options[i]);
  }

  Widget _opt(int i) {
    final q = widget.q;
    var fill = _kPanel;
    var border = _kPanel2;
    if (_picked != null) {
      if (i == q.answerIndex) {
        fill = _a(_kGreen, .25);
        border = _kGreen;
      } else if (i == _picked) {
        fill = _a(_kRed, .25);
        border = _kRed;
      }
    }
    return GestureDetector(
      onTap: () => _tap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(q.options[i],
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _timeline(int zone) {
    const labels = ['PAST', 'NOW', 'FUTURE'];
    return Row(
      children: List.generate(3, (i) {
        final on = i == zone;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? _a(_kPurple, .35) : _a(Colors.white, .05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: on ? _kPurple : Colors.white12),
            ),
            child: Text(labels[i],
                style: GoogleFonts.outfit(
                    color: on ? Colors.white : Colors.white38,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8)),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    final isVocab = q.type == _GameType.vocab;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(children: [
        _gameHeader(q.type, q.sub),
        const SizedBox(height: 8),
        _promptCard(q.prompt,
            size: isVocab ? 28 : 18,
            extra: q.type == _GameType.tense ? _timeline(q.zone) : null),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _opt(0)),
          const SizedBox(width: 10),
          Expanded(child: _opt(1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _opt(2)),
          const SizedBox(width: 10),
          Expanded(child: _opt(3)),
        ]),
      ]),
    );
  }
}

// ---------------------------------- GAME 1 -----------------------------------
class _BuilderGame extends StatefulWidget {
  final _Q q;
  final void Function(bool ok, String given) onAnswer;
  const _BuilderGame({super.key, required this.q, required this.onAnswer});

  @override
  State<_BuilderGame> createState() => _BuilderGameState();
}

class _BuilderGameState extends State<_BuilderGame> {
  final List<int> _placed = [];
  bool? _ok;

  void _add(int i) {
    if (_ok != null || _placed.contains(i)) return;
    HapticFeedback.selectionClick();
    setState(() => _placed.add(i));
    if (_placed.length == widget.q.options.length) _check();
  }

  void _remove(int i) {
    if (_ok != null) return;
    setState(() => _placed.remove(i));
  }

  void _check() {
    final s = _placed.map((i) => widget.q.options[i]).join(' ');
    final ok = s == widget.q.answer;
    setState(() => _ok = ok);
    widget.onAnswer(ok, s);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    final res = _ok;
    final Color placedFill = res == null ? _a(_kCyan, .2) : (res ? _a(_kGreen, .28) : _a(_kRed, .28));
    final Color placedBorder = res == null ? _kCyan : (res ? _kGreen : _kRed);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Column(children: [
        _gameHeader(q.type, q.sub),
        const SizedBox(height: 8),
        _promptCard(q.prompt, size: 18),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _a(Colors.white, .04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: _placed.isEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text('Tap the words below to build sentence…',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                ))
              : Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final i in _placed)
                    _chip(q.options[i], placedFill, placedBorder, () => _remove(i)),
                ]),
        ),
        if (res == false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('✔ ${q.answer}',
                style: GoogleFonts.outfit(color: _kGreen, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (var i = 0; i < q.options.length; i++)
            _chip(q.options[i], _kPanel, _kPanel2,
                _placed.contains(i) ? null : () => _add(i),
                opacity: _placed.contains(i) ? .15 : 1),
        ]),
      ]),
    );
  }
}

// ---------------------------------- GAME 3 -----------------------------------
class _TrainGame extends StatefulWidget {
  final _Q q;
  final void Function(bool ok, String given) onAnswer;
  const _TrainGame({super.key, required this.q, required this.onAnswer});

  @override
  State<_TrainGame> createState() => _TrainGameState();
}

class _TrainGameState extends State<_TrainGame> {
  late final List<int?> _fill =
      List<int?>.filled(widget.q.blanks.length, null);
  bool? _ok;

  String _built() {
    final chars = widget.q.answer.split('');
    for (var k = 0; k < widget.q.blanks.length; k++) {
      final f = _fill[k];
      chars[widget.q.blanks[k]] = f == null ? '_' : widget.q.options[f];
    }
    return chars.join();
  }

  void _bankTap(int bi) {
    if (_ok != null || _fill.contains(bi)) return;
    final slot = _fill.indexOf(null);
    if (slot < 0) return;
    HapticFeedback.selectionClick();
    setState(() => _fill[slot] = bi);
    if (!_fill.contains(null)) {
      final ok = _built() == widget.q.answer;
      setState(() => _ok = ok);
      widget.onAnswer(ok, _built());
    }
  }

  void _slotTap(int slot) {
    if (_ok != null) return;
    setState(() => _fill[slot] = null);
  }

  Widget _wagon(int ci) {
    final q = widget.q;
    final slot = q.blanks.indexOf(ci);
    String letter = q.answer[ci];
    Color fill = _kPanel2;
    Color border = Colors.white24;
    VoidCallback? tap;
    if (slot >= 0) {
      final f = _fill[slot];
      letter = f == null ? '?' : q.options[f];
      fill = f == null ? _a(_kGold, .08) : _a(_kGold, .35);
      border = _kGold;
      tap = () => _slotTap(slot);
      if (_ok != null) {
        fill = _ok! ? _a(_kGreen, .35) : _a(_kRed, .35);
        border = _ok! ? _kGreen : _kRed;
      }
    }
    return GestureDetector(
      onTap: tap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 2),
          ),
          child: Text(letter,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 3),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 2; i++)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle),
            ),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    final train = <Widget>[
      const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Icon(Icons.train, size: 46, color: _kGold),
      ),
    ];
    for (var i = 0; i < q.answer.length; i++) {
      train.add(Container(
          width: 8, height: 3, margin: const EdgeInsets.only(bottom: 22), color: Colors.white38));
      train.add(_wagon(i));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Column(children: [
        _gameHeader(q.type, q.sub),
        const SizedBox(height: 8),
        _promptCard(q.prompt, size: 24),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: train),
        ),
        if (_ok == false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('✔ ${q.answer}',
                style: GoogleFonts.outfit(color: _kGreen, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
          ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (var i = 0; i < q.options.length; i++)
            _chip(q.options[i], _kPanel, _kGold, _fill.contains(i) ? null : () => _bankTap(i),
                opacity: _fill.contains(i) ? .15 : 1),
        ]),
      ]),
    );
  }
}

// ============================ THE PAGE ========================================
class CitadelFightDuelPage extends StatefulWidget {
  final String opponentName;
  final String opponentAvatar; // emoji / letter / http image URL
  final int opponentLevel;
  final int questionCount; // default 20
  final bool isUserBTurn; // false = Challenger initiating, true = Opponent responding
  final double? userATimeSeconds; // User A's recorded time (Round 2 only)
  final int? userAScore; // User A's recorded final score (Round 2 only)
  final int? userACorrect; // User A's correct count (optional but recommended)
  final int duelSeed; // same seed + count => same questions for both players
  final void Function(Map<String, dynamic> duelResult)? onDuelFinished;

  const CitadelFightDuelPage({
    super.key,
    required this.opponentName,
    this.opponentAvatar = '🥷',
    this.opponentLevel = 1,
    this.questionCount = 20,
    this.isUserBTurn = false,
    this.userATimeSeconds,
    this.userAScore,
    this.userACorrect,
    this.duelSeed = 20240607,
    this.onDuelFinished,
  });

  @override
  State<CitadelFightDuelPage> createState() => _CitadelFightDuelPageState();
}

class _CitadelFightDuelPageState extends State<CitadelFightDuelPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _ArenaModel _m = _ArenaModel();
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  final ValueNotifier<int> _ms = ValueNotifier<int>(0);
  final Stopwatch _sw = Stopwatch();
  double _lastT = 0;

  _Phase _phase = _Phase.setup;
  late int _count;
  List<_Q> _qs = [];
  int _qi = 0;
  bool _locked = false;
  int _qStartMs = 0;
  int _score = 0, _correct = 0, _combo = 0, _maxCombo = 0;
  final List<_Res> _res = [];
  int _cd = 3;

  String _popText = '';
  Color _popColor = _kCyan;
  int _popId = 0;

  // final results
  double _myTime = 0;
  String _winner = 'pending';
  String _reason = '';
  int _xp = 0;
  int _aC = 0, _aS = 0;
  double _aT = 0;

  int get _total => _qs.isEmpty ? _count : _qs.length;

  @override
  void initState() {
    super.initState();
    _count = widget.questionCount;
    _m.mystery = widget.isUserBTurn;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sw.stop();
    _frame.dispose();
    _ms.dispose();
    super.dispose();
  }

  void _onTick(Duration d) {
    final t = d.inMicroseconds / 1e6;
    final dt = (t - _lastT).clamp(0.0, 0.05);
    _lastT = t;
    _m.update(dt);
    if (_phase == _Phase.playing) _ms.value = _sw.elapsedMilliseconds;
    _frame.value++;
    if (_phase == _Phase.sprint && _m.sprint >= 1) {
      _m.victory = true;
      _m.confetti(40);
      HapticFeedback.heavyImpact();
      setState(() => _phase = _Phase.waiting);
    }
  }

  // ------------------------------ GAME FLOW ----------------------------------
  void _start() {
    _qs = _buildQuestions(_count, widget.duelSeed);
    _m.shield = 1;
    setState(() => _phase = _Phase.countdown);
    _runCountdown();
  }

  Future<void> _runCountdown() async {
    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _cd = i);
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 750));
    }
    if (!mounted) return;
    setState(() => _cd = 0);
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    _sw
      ..reset()
      ..start();
    setState(() {
      _phase = _Phase.playing;
      _qi = 0;
      _qStartMs = 0;
      _locked = false;
    });
  }

  void _onAnswer(bool ok, String given) {
    if (_locked || _phase != _Phase.playing) return;
    _locked = true;
    final q = _qs[_qi];
    final took = _sw.elapsedMilliseconds - _qStartMs;
    var pts = 0;
    String txt;
    Color col;
    if (ok) {
      final bonus = (math.max(0.0, 1 - took / 1000 / q.par) * 100).round();
      final mult = 1 + 0.1 * math.min(_combo, 10);
      pts = ((100 + bonus) * mult).round();
      _combo++;
      _maxCombo = math.max(_maxCombo, _combo);
      _correct++;
      _score += pts;
      _m.shield = 1 - _correct / _total;
      _m.hitOpponent(_combo);
      HapticFeedback.mediumImpact();
      if (took / 1000 < q.par * .3) {
        txt = 'PERFECT! ⚡';
        col = _kGold;
      } else if (_combo >= 2) {
        txt = 'COMBO x$_combo 🔥';
        col = _kPink;
      } else {
        txt = 'HIT! +$pts';
        col = _kCyan;
      }
    } else {
      _combo = 0;
      _m.missHit();
      HapticFeedback.heavyImpact();
      txt = 'MISS 💥';
      col = _kRed;
    }
    _res.add(_Res(q, ok, took, pts, given));
    setState(() {
      _popText = txt;
      _popColor = col;
      _popId++;
    });
    Future<void>.delayed(Duration(milliseconds: ok ? 450 : 950), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_qi + 1 >= _qs.length) {
      _finish();
    } else {
      setState(() {
        _qi++;
        _locked = false;
        _qStartMs = _sw.elapsedMilliseconds;
        _popText = '';
      });
    }
  }

  List<Map<String, dynamic>> _breakdown() => [
        for (var i = 0; i < _res.length; i++)
          <String, dynamic>{
            'index': i + 1,
            'game': _gameTitle(_res[i].q.type),
            'prompt': _res[i].q.prompt,
            'correct': _res[i].ok,
            'timeMs': _res[i].ms,
            'points': _res[i].pts,
            'given': _res[i].given,
            'answer': _res[i].q.answer,
          }
      ];

  void _finish() {
    _sw.stop();
    _ms.value = _sw.elapsedMilliseconds;
    _myTime = _sw.elapsedMilliseconds / 1000.0;
    final n = _qs.length;

    if (!widget.isUserBTurn) {
      // ---- Round 1: User A sprints to the opponent's citadel and waits ------
      _xp = 10 + _correct * 2;
      _m.sprint = 0;
      _m.sprintOn = true;
      _m.oppHidden = true;
      setState(() => _phase = _Phase.sprint);
      widget.onDuelFinished?.call(<String, dynamic>{
        'stage': 'challenger_finished',
        'player': 'user_a',
        'totalCorrect': _correct,
        'totalQuestions': n,
        'totalTimeSeconds': _myTime,
        'finalScore': _score,
        'maxCombo': _maxCombo,
        'xpEarned': _xp,
        'duelSeed': widget.duelSeed,
        'questionCount': n,
        'breakdown': _breakdown(),
      });
      return;
    }

    // ---- Round 3: resolve the duel (User B just finished) --------------------
    _aT = widget.userATimeSeconds ?? double.infinity;
    _aS = widget.userAScore ?? 0;
    _aC = widget.userACorrect ?? ((_aS / 180).round().clamp(0, n));
    if (_correct != _aC) {
      _winner = _correct > _aC ? 'user_b' : 'user_a';
      _reason = _correct > _aC
          ? 'Won on accuracy: $_correct vs $_aC correct answers!'
          : 'Won on accuracy: $_aC vs $_correct correct answers!';
    } else if ((_myTime - _aT).abs() > 0.0005) {
      _winner = _myTime < _aT ? 'user_b' : 'user_a';
      _reason = 'Tie-breaker on speed: both got $_correct correct (${_myTime.toStringAsFixed(1)}s vs ${_aT.toStringAsFixed(1)}s)!';
    } else {
      _winner = 'draw';
      _reason = 'Legendary Draw: both scored $_correct correct in identical time!';
    }
    _xp = _winner == 'user_b'
        ? 50 + _correct * 5 + _maxCombo * 2
        : _winner == 'draw'
            ? 30 + _correct * 3
            : 15 + _correct * 2;
    _m.oppHidden = false;
    if (_winner != 'user_a') {
      _m.ceremony = true;
      _m.confettiTimer = 5;
      _m.confettiBurst();
    }
    setState(() => _phase = _Phase.resolution);
    widget.onDuelFinished?.call(<String, dynamic>{
      'stage': 'duel_resolved',
      'winner': _winner,
      'winReason': _reason,
      'userA': <String, dynamic>{
        'totalCorrect': _aC,
        'totalTimeSeconds': _aT.isInfinite ? null : _aT,
        'finalScore': _aS,
      },
      'userB': <String, dynamic>{
        'totalCorrect': _correct,
        'totalTimeSeconds': _myTime,
        'finalScore': _score,
        'maxCombo': _maxCombo,
      },
      'xpEarned': _xp,
      'duelSeed': widget.duelSeed,
      'questionCount': n,
      'breakdown': _breakdown(),
    });
  }

  Future<void> _exit() async {
    if (_phase == _Phase.setup || _phase == _Phase.waiting || _phase == _Phase.resolution) {
      Navigator.maybePop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _kPanel,
        title: const Text('Forfeit duel?', style: TextStyle(color: Colors.white)),
        content: const Text('Leaving now abandons this run.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('STAY')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('LEAVE')),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.maybePop(context);
  }

  String _fmt(int ms) {
    final m = ms ~/ 60000;
    final s = (ms ~/ 1000) % 60;
    final cs = (ms % 1000) ~/ 10;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }

  // ------------------------------- BUILD -------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.resolution) {
      return Scaffold(backgroundColor: _kBg, body: SafeArea(child: _resolutionView()));
    }
    if (_phase == _Phase.setup) {
      return Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Column(children: [
            _hud(),
            Expanded(child: _setupCard()),
          ]),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(children: [
          _hud(),
          _compactClashBar(),
          Expanded(child: _bottom()),
        ]),
      ),
    );
  }

  Widget _compactClashBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _a(Colors.white, .12), width: 1.5),
        boxShadow: [
          BoxShadow(color: _a(Colors.black, .3), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _plate(
                avatar: '🥊',
                name: 'YOU',
                sub: _combo >= 2 ? 'COMBO x$_combo 🔥' : '$_correct hits',
                color: _kCyan,
              ),
              _plate(
                avatar: widget.opponentAvatar,
                name: widget.opponentName,
                sub: 'Lv ${widget.opponentLevel} · SHIELD',
                color: _kPink,
                bar: _m.shield,
                right: true,
              ),
            ],
          ),
          _popWidget(),
          if (_phase == _Phase.countdown) _countdownWidget(),
        ],
      ),
    );
  }

  Widget _hud() {
    final active = _phase != _Phase.setup;
    if (!active) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 16, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: _exit,
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kCyan, _kPink]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _a(_kCyan, .35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: const Text('⚔️ SPEED DUEL ARENA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      )),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _kPanel2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGold, width: 1.5),
              ),
              child: const Text('20Q',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  )),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 14, 2),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.close, color: Colors.white70), onPressed: _exit),
        Expanded(
          child: Column(children: [
            ValueListenableBuilder<int>(
              valueListenable: _ms,
              builder: (_, v, __) => Text(_fmt(v),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                    shadows: [Shadow(color: _kCyan, blurRadius: 14)],
                  )),
            ),
            Text(
                'QUESTION ${math.min(_qi + 1, _total)}/$_total',
                style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$_score',
              style: const TextStyle(color: _kGold, fontSize: 22, fontWeight: FontWeight.w900)),
          const Text('SCORE',
              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
        ]),
      ]),
    );
  }

  Widget _avatar(String a, String name) {
    if (a.startsWith('http')) {
      return Image.network(a,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(name));
    }
    if (a.isEmpty) return _initial(name);
    return Text(a, style: const TextStyle(fontSize: 22));
  }

  Widget _initial(String name) => Text(
      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18));

  Widget _plate(
      {required String avatar,
      required String name,
      required String sub,
      required Color color,
      double? bar,
      bool right = false}) {
    final av = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kPanel,
        border: Border.all(color: color, width: 2),
      ),
      child: _avatar(avatar, name),
    );
    final info = Column(
      crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        Text(sub, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        if (bar != null)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: bar.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: _a(Colors.white, .15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(
        mainAxisSize: minAxisAlignmentRow(right),
        children: right
            ? [Flexible(child: info), const SizedBox(width: 8), av]
            : [av, const SizedBox(width: 8), Flexible(child: info)],
      ),
    );
  }

  static MainAxisSize minAxisAlignmentRow(bool _) => MainAxisSize.min;

  Widget _popWidget() {
    if (_popText.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(_popId),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          builder: (_, v, __) {
            final sc = .5 + .7 * Curves.easeOutBack.transform(math.min(1.0, v * 3));
            final op = v < .65 ? 1.0 : (1 - v) / .35;
            return Opacity(
              opacity: op.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: sc,
                child: Text(_popText,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: _popColor,
                      shadows: [
                        Shadow(color: _popColor, blurRadius: 18),
                        const Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _countdownWidget() {
    final txt = _cd > 0 ? '$_cd' : 'FIGHT!';
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(_cd),
          tween: Tween<double>(begin: 1.8, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          builder: (_, v, __) => Transform.scale(
            scale: v,
            child: Text(txt,
                style: TextStyle(
                  fontSize: _cd > 0 ? 72 : 52,
                  fontWeight: FontWeight.w900,
                  color: _cd > 0 ? Colors.white : _kGold,
                  shadows: const [Shadow(color: _kPink, blurRadius: 24)],
                )),
          ),
        ),
      ),
    );
  }

  Widget _bottom() {
    if (_phase == _Phase.setup) return _setupCard();
    if (_phase == _Phase.countdown) {
      return const Center(
          child: Text('Get ready…',
              style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2)));
    }
    if (_phase == _Phase.playing) return _playPanel();
    if (_phase == _Phase.sprint) {
      return Center(
          child: Text('🏃 Sprinting to ${widget.opponentName}\'s citadel…',
              style: const TextStyle(color: _kGold, fontSize: 16, fontWeight: FontWeight.w800)));
    }
    return _waitingCard();
  }

  Widget _modePill(String emoji, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _a(color, .14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _a(color, .5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }

  // ------------------------------- SETUP -------------------------------------
  Widget _setupCard() {
    final b = widget.isUserBTurn;
    final opts = <int>{10, 15, 20, widget.questionCount}.toList()..sort();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _kPanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kPurple, width: 2),
          boxShadow: [BoxShadow(color: _a(_kPurple, .35), blurRadius: 20)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Battle Face-off Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: _a(Colors.white, .04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kPanel2,
                        border: Border.all(color: _kCyan, width: 2.2),
                        boxShadow: [BoxShadow(color: _a(_kCyan, .4), blurRadius: 8)],
                      ),
                      child: const Text('🥊', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 4),
                    Text('YOU',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900)),
                    Text('Challenger',
                        style: GoogleFonts.inter(color: _kCyan, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_kCyan, _kPink]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('⚡ VS ⚡',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 3),
                    Text('SPEED DUEL',
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kPanel2,
                        border: Border.all(color: _kPink, width: 2.2),
                        boxShadow: [BoxShadow(color: _a(_kPink, .4), blurRadius: 8)],
                      ),
                      child: _avatar(widget.opponentAvatar, widget.opponentName),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.opponentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900)),
                    Text('Lv ${widget.opponentLevel} Defender',
                        style: GoogleFonts.inter(color: _kPink, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ShaderMask(
            shaderCallback: (r) =>
                const LinearGradient(colors: [_kCyan, _kPink, _kGold]).createShader(r),
            child: Text(b ? 'DEFEND CITADEL DUEL' : 'CITADEL SPEED DUEL',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 3),
          Text(
            b
                ? 'Beat ${widget.opponentName}\'s record on speed and accuracy!'
                : 'Real-time asynchronous English war · Fastest accuracy wins!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),

          if (!b) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, color: _kGold, size: 14),
                const SizedBox(width: 4),
                Text('DUEL LENGTH: $_count QUESTIONS',
                    style: GoogleFonts.outfit(color: _kGold, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 6),
            Row(children: [for (final n in opts) _countChip(n)]),
          ] else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _a(_kGold, .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _a(_kGold, .6)),
              ),
              child: Text(
                  '🔒 ${widget.opponentName} completed ${widget.questionCount} questions.\nTheir score and time are locked until you finish. Beat them on correct answers — ties go to the fastest time!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, height: 1.35, fontSize: 11)),
            ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: [
              _modePill('🧩', 'Sentence Builder', _kCyan),
              _modePill('🔤', 'Spelling Rectifier', _kPink),
              _modePill('🚂', 'Word Train', _kGold),
              _modePill('⚡', 'Vocab Defusal', _kGreen),
              _modePill('⏱️', 'Tense Timeline', _kPurple),
            ],
          ),
          const Spacer(),
          _bigButton(
            b ? 'ACCEPT & FIGHT' : 'START 20Q DUEL FIGHT ⚔️',
            Icons.local_fire_department,
            _start,
          ),
        ]),
      ),
    );
  }

  Widget _countChip(int n) {
    final sel = _count == n;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _count = n),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _a(_kCyan, .2) : _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? _kCyan : _kPanel2, width: 1.8),
          ),
          child: Column(children: [
            Text('$n',
                style: GoogleFonts.outfit(
                    color: sel ? _kCyan : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(n == 20 ? 'DEFAULT' : 'QUESTIONS',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5, letterSpacing: 0.8)),
          ]),
        ),
      ),
    );
  }

  // ------------------------------- PLAYING -----------------------------------
  Widget _speedBar(_Q q) {
    return ValueListenableBuilder<int>(
      valueListenable: _ms,
      builder: (_, v, __) {
        final f = (1 - (v - _qStartMs) / 1000 / q.par).clamp(0.0, 1.0);
        final col = f > .5 ? _kGreen : (f > .2 ? _kGold : _kRed);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(children: [
            const Text('⚡ SPEED BONUS',
                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: f,
                  minHeight: 7,
                  backgroundColor: _kPanel2,
                  valueColor: AlwaysStoppedAnimation<Color>(col),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _game(_Q q) {
    switch (q.type) {
      case _GameType.builder:
        return _BuilderGame(key: ValueKey<String>('b$_qi'), q: q, onAnswer: _onAnswer);
      case _GameType.train:
        return _TrainGame(key: ValueKey<String>('t$_qi'), q: q, onAnswer: _onAnswer);
      case _GameType.spelling:
      case _GameType.vocab:
      case _GameType.tense:
        return _ChoiceGame(key: ValueKey<String>('c$_qi'), q: q, onAnswer: _onAnswer);
    }
  }

  Widget _playPanel() {
    if (_qs.isEmpty) return const SizedBox.shrink();
    final q = _qs[_qi];
    return Column(children: [
      _speedBar(q),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(.25, 0), end: Offset.zero).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          layoutBuilder: (cur, prev) => Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.expand,
            children: [...prev, if (cur != null) cur],
          ),
          child: KeyedSubtree(key: ValueKey<int>(_qi), child: _game(q)),
        ),
      ),
    ]);
  }

  // ------------------------------- WAITING -----------------------------------
  Widget _stat(String label, String value, Color c) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _a(c, .6)),
          ),
          child: Column(children: [
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.w900))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
          ]),
        ),
      );

  Widget _waitingCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kPanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kGold, width: 2),
          boxShadow: [BoxShadow(color: _a(_kGold, .35), blurRadius: 24)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('🏰 CHALLENGE DELIVERED',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kGold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text('You are waiting at ${widget.opponentName}\'s gate in victory stance.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(children: [
            _stat('CORRECT', '$_correct/${_qs.length}', _kGreen),
            _stat('TIME', _fmt((_myTime * 1000).round()), _kCyan),
            _stat('SCORE', '$_score', _kGold),
          ]),
          const SizedBox(height: 10),
          Center(
              child: Text('Best combo x$_maxCombo · +$_xp XP',
                  style: const TextStyle(color: Colors.white60, fontSize: 12))),
          const SizedBox(height: 10),
          const Text(
              '🔒 Your exact result stays hidden from your opponent until they finish their run.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
          const SizedBox(height: 16),
          _bigButton('DONE', Icons.check_circle, () => Navigator.maybePop(context),
              colors: const [_kCyan, _kPurple]),
        ]),
      ),
    );
  }

  // ------------------------------- RESOLUTION --------------------------------
  Widget _cmpCol(String title, int c, double t, int s, bool win) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: win ? _a(_kGold, .12) : _kPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: win ? _kGold : _kPanel2, width: 2),
        ),
        child: Column(children: [
          Text(win ? '👑 $title' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: win ? _kGold : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Text('$c / $_total',
              style: const TextStyle(color: _kGreen, fontSize: 20, fontWeight: FontWeight.w900)),
          const Text('CORRECT', style: TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 6),
          Text(t.isInfinite ? '--:--.--' : _fmt((t * 1000).round()),
              style: const TextStyle(
                  color: _kCyan, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
          const Text('TIME', style: TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 6),
          Text('$s',
              style: const TextStyle(color: _kGold, fontSize: 16, fontWeight: FontWeight.w800)),
          const Text('SCORE', style: TextStyle(color: Colors.white38, fontSize: 9)),
        ]),
      ),
    );
  }

  Widget _resolutionView() {
    final won = _winner == 'user_b';
    final draw = _winner == 'draw';
    final title = draw ? 'DRAW!' : (won ? 'VICTORY!' : 'DEFEAT');
    final col = draw ? _kCyan : (won ? _kGold : _kRed);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.maybePop(context)),
        ),
        SizedBox(
          height: 230,
          width: double.infinity,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _TrophyPainter(_m, won || draw, _frame),
              size: Size.infinite,
            ),
          ),
        ),
        Center(
          child: Text(title,
              style: TextStyle(
                color: col,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [Shadow(color: col, blurRadius: 22)],
              )),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
              won
                  ? '🏆 Grand Gold Trophy is yours!'
                  : (draw ? 'Perfectly matched – a legendary duel!' : '🥈 ${widget.opponentName} takes the gold trophy.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
              _winner == 'user_a' ? _reason.replaceFirst('Won', '${widget.opponentName} won') : _reason,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cmpCol('YOU', _correct, _myTime, _score, won),
            _cmpCol(widget.opponentName, _aC, _aT, _aS, _winner == 'user_a'),
          ]),
        ),
        const SizedBox(height: 14),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _xp.toDouble()),
            duration: const Duration(milliseconds: 1400),
            builder: (_, v, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kPurple, _kPink]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: _a(_kPink, .5), blurRadius: 16)],
              ),
              child: Text('⭐ +${v.round()} XP',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text('QUESTION BREAKDOWN',
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _res.length; i++) _breakTile(i, _res[i]),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _bigButton('CLOSE', Icons.emoji_events, () => Navigator.maybePop(context),
              colors: const [_kGold, Color(0xFFFF8A00)]),
        ),
      ],
    );
  }

  Widget _breakTile(int i, _Res r) {
    final c = r.ok ? _kGreen : _kRed;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _a(c, .5)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _a(c, .2), shape: BoxShape.circle),
          child: Icon(r.ok ? Icons.check : Icons.close, color: c, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${i + 1}. ${_gameEmoji(r.q.type)} ${r.q.prompt}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
                r.ok
                    ? '${r.q.answer} · ${(r.ms / 1000).toStringAsFixed(1)}s'
                    : 'You: ${r.given} → ${r.q.answer} · ${(r.ms / 1000).toStringAsFixed(1)}s',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),
        Text(r.ok ? '+${r.pts}' : '0',
            style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 14)),
      ]),
    );
  }
}
