import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ───────────────────────── THEME & HELPERS ─────────────────────────
const kBg = Color(0xFF0B111E), kCard = Color(0xFF141C2F);
const kGold = Color(0xFFFFD700), kEm = Color(0xFF10B981), kCy = Color(0xFF38BDF8), kRed = Color(0xFFF87171);

TextStyle ts(double s, {FontWeight w = FontWeight.w600, Color c = Colors.white}) =>
    GoogleFonts.nunito(fontSize: s, fontWeight: w, color: c);
TextStyle hand(double s, {Color c = const Color(0xFF3B2F2F)}) =>
    GoogleFonts.caveat(fontSize: s, color: c, fontWeight: FontWeight.w600);

int score(int wrong) => math.max(10, 30 - wrong * 5);
void later(State s, VoidCallback f) => Future.delayed(const Duration(milliseconds: 700), () {
      if (s.mounted) f();
    });

Widget panel(Widget child, {Color c = kCy}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withValues(alpha: .35))),
    child: child);

Widget choices(List<String> o, void Function(String) f, Color c) =>
    Wrap(spacing: 8, runSpacing: 8, children: [for (final s in o) Pill(s, c: c, onTap: () => f(s))]);

Widget goldBtn(String t, VoidCallback? f) => FilledButton(
    onPressed: f,
    style: FilledButton.styleFrom(
        backgroundColor: kGold,
        disabledBackgroundColor: Colors.white12,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
    child: Text(t, style: ts(15, w: FontWeight.w800, c: f == null ? Colors.white38 : Colors.black)));

class Pill extends StatelessWidget {
  final String t;
  final Color c;
  final bool on;
  final VoidCallback? onTap;
  const Pill(this.t, {super.key, this.c = kCy, this.on = false, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: on ? c.withValues(alpha: .25) : kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? c : c.withValues(alpha: .4), width: on ? 2 : 1),
              boxShadow: on ? [BoxShadow(color: c.withValues(alpha: .5), blurRadius: 12)] : null),
          child: Text(t, style: ts(14, c: on ? Colors.white : c.withValues(alpha: .95))),
        ),
      );
}

class ShakeBox extends StatefulWidget {
  final int trigger;
  final Widget child;
  const ShakeBox({super.key, required this.trigger, required this.child});
  @override
  State<ShakeBox> createState() => _ShakeBoxState();
}

class _ShakeBoxState extends State<ShakeBox> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  @override
  void didUpdateWidget(ShakeBox o) {
    super.didUpdateWidget(o);
    if (o.trigger != widget.trigger) c.forward(from: 0);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: c,
      builder: (_, ch) => Transform.translate(
          offset: Offset(math.sin(c.value * math.pi * 6) * 7 * (1 - c.value), 0), child: ch),
      child: widget.child);
}

// ───────────────────────── 🔥 ANIMATED FLAME ─────────────────────────
class FlameIcon extends StatefulWidget {
  final double size;
  const FlameIcon({super.key, this.size = 30});
  @override
  State<FlameIcon> createState() => _FlameIconState();
}

class _FlameIconState extends State<FlameIcon> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: widget.size * .8,
      height: widget.size,
      child: AnimatedBuilder(animation: c, builder: (_, __) => CustomPaint(painter: _FlamePainter(c.value))));
}

class _FlamePainter extends CustomPainter {
  final double t;
  _FlamePainter(this.t);
  Path _drop(Size s, double w, double h, double sway) {
    final cx = s.width / 2, b = s.height;
    return Path()
      ..moveTo(cx + sway, b - h)
      ..cubicTo(cx + w * .2 + sway, b - h * .6, cx + w, b - h * .45, cx + w * .8, b - h * .2)
      ..quadraticBezierTo(cx + w * .5, b, cx, b)
      ..quadraticBezierTo(cx - w * .5, b, cx - w * .8, b - h * .2)
      ..cubicTo(cx - w, b - h * .45, cx - w * .2 + sway, b - h * .6, cx + sway, b - h);
  }

  @override
  void paint(Canvas cv, Size s) {
    final sway = math.sin(t * 2 * math.pi) * s.width * .08;
    final fl = 1 + .05 * math.sin(t * 4 * math.pi);
    void layer(double w, double h, Color col, {bool glow = false}) {
      final p = _drop(s, s.width * w, s.height * h * fl, sway * h);
      if (glow) {
        cv.drawPath(
            p,
            Paint()
              ..color = col.withValues(alpha: .6)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
      cv.drawPath(p, Paint()..color = col);
    }

    layer(.5, .9, const Color(0xFFFF4D1A), glow: true);
    layer(.36, .68, const Color(0xFFFFA726));
    layer(.2, .42, const Color(0xFFFFE066));
  }

  @override
  bool shouldRepaint(_FlamePainter o) => o.t != t;
}

// ───────────────────────── MODES ─────────────────────────
class Mode {
  final String e, t, d;
  final Color c;
  const Mode(this.e, this.t, this.d, this.c);
}

const modes = [
  Mode('✉️', 'Letter Writing Quest', 'Order the parts of a letter', kCy),
  Mode('📖', 'Diary Entry Adventure', 'Mood, date & guided sentences', kGold),
  Mode('👤', 'Legend Bio Creator', 'Build a hero profile card', kEm),
  Mode('📢', 'Notice Masterclass', 'Complete an official notice', kRed),
  Mode('📧', 'Email Etiquette', 'Write a polite email & send', kCy),
  Mode('🔍', 'Spelling Detective', 'Find & fix the mistakes', kGold),
  Mode('🧩', 'Smart Word Tap', 'Fill the blanks with words', kEm),
];
const cnt = [3, 2, 3, 2, 2, 3, 3];

// ───────────────────────── MAIN PAGE ─────────────────────────
class StudentCreativeWritingRealmPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentCreativeWritingRealmPage({
    super.key,
    this.day = 1,
    this.stepIndex = 6,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 6,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentCreativeWritingRealmPage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentCreativeWritingRealmPage> createState() => _RealmState();
}

class _RealmState extends State<StudentCreativeWritingRealmPage> {
  int xp = 0, stars = 0, streak = 0, ex = 0, rs = 0;
  int? mode;
  final List<Set<int>> done = List.generate(7, (_) => <int>{});

  void _open(int m, [int? e]) {
    HapticFeedback.lightImpact();
    int first = 0;
    while (first < cnt[m] - 1 && done[m].contains(first)) {
      first++;
    }
    setState(() {
      mode = m;
      ex = e ?? first;
      rs++;
    });
  }

  void _win(int g) {
    final m = mode!;
    final s = g >= 25
        ? 3
        : g >= 20
            ? 2
            : 1;
    HapticFeedback.mediumImpact();
    setState(() {
      xp += g;
      stars += s;
      streak++;
      done[m].add(ex);
    });

    // Notify parent open-world adventure step completion
    widget.onStepFinished?.call(widget.stepIndex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), side: const BorderSide(color: kGold, width: 2)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Transform.scale(
                    scale: v, child: const Text('🏆', style: TextStyle(fontSize: 64)))),
            const Text('🎉 ✨ ⭐ ✨ 🎉', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text('Quest Complete!', style: ts(22, w: FontWeight.w800, c: kGold)),
            const SizedBox(height: 4),
            Text('+$g XP   ${'⭐' * s}', style: ts(17, c: kEm)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    setState(() {
                      mode = null;
                    });
                  },
                  child: Text('🏠 Hub', style: ts(14, c: kCy))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    setState(() {
                      rs++;
                    });
                  },
                  child: Text('🔁 Replay', style: ts(14, c: kCy))),
              goldBtn(ex < cnt[m] - 1 ? 'Next ▶' : 'Finish', () {
                Navigator.pop(c);
                if (ex < cnt[m] - 1) {
                  setState(() {
                    ex++;
                    rs++;
                  });
                } else {
                  setState(() {
                    mode = null;
                  });
                  Navigator.of(context).maybePop();
                }
              }),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _topBar() => panel(
      Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('🎓 Level ${xp ~/ 100 + 1}', style: ts(16, w: FontWeight.w800, c: kGold)),
            SizedBox(
                width: 130,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                          value: (xp % 100) / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          color: kEm)),
                  const SizedBox(height: 2),
                  Text('$xp XP', style: ts(12, c: Colors.white70)),
                ])),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, color: kGold, size: 24),
              Text(' $stars', style: ts(16, w: FontWeight.w800)),
              const SizedBox(width: 12),
              const FlameIcon(size: 30),
              Text(' $streak', style: ts(16, w: FontWeight.w800, c: const Color(0xFFFFA726))),
            ]),
          ]),
      c: kGold);

  Widget _hub() => LayoutBuilder(builder: (_, bc) {
        final cols = bc.maxWidth > 900
            ? 4
            : bc.maxWidth > 600
                ? 3
                : 2;
        final w = (bc.maxWidth - 12 * (cols - 1)) / cols;
        return Wrap(spacing: 12, runSpacing: 12, children: [for (int i = 0; i < 7; i++) _card(i, w)]);
      });

  Widget _card(int i, double w) {
    final m = modes[i];
    return SizedBox(
      width: w,
      child: GestureDetector(
        onTap: () => _open(i),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: m.c.withValues(alpha: .6), width: 1.5),
              boxShadow: [BoxShadow(color: m.c.withValues(alpha: .2), blurRadius: 14)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.e, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 6),
            Text(m.t, style: ts(16, w: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(m.d, style: ts(12.5, c: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(children: [
              for (int k = 0; k < cnt[i]; k++)
                Icon(done[i].contains(k) ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 20, color: kGold)
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _activity() {
    final m = mode!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(
            onPressed: () => setState(() => mode = null),
            icon: const Icon(Icons.arrow_back_rounded, color: kCy)),
        Expanded(
            child: Text('${modes[m].e} ${modes[m].t}',
                style: ts(18, w: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis)),
        IconButton(
            tooltip: 'Reset',
            onPressed: () => setState(() => rs++),
            icon: const Icon(Icons.refresh_rounded, color: kGold)),
      ]),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (int i = 0; i < 7; i++)
              Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Pill(modes[i].e, c: modes[i].c, on: i == m, onTap: () => _open(i)))
          ])),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (int k = 0; k < cnt[m]; k++)
          Pill('${done[m].contains(k) ? '✅ ' : ''}Round ${k + 1}',
              c: kGold, on: k == ex, onTap: () => setState(() {
                    ex = k;
                    rs++;
                  }))
      ]),
      const SizedBox(height: 12),
      KeyedSubtree(key: ValueKey('$m-$ex-$rs'), child: _game(m)),
    ]);
  }

  Widget _game(int m) {
    switch (m) {
      case 0:
        return LetterGame(ex: ex, onDone: _win);
      case 1:
        return DiaryGame(ex: ex, onDone: _win);
      case 2:
        return BioGame(ex: ex, onDone: _win);
      case 3:
        return NoticeGame(ex: ex, onDone: _win);
      case 4:
        return EmailGame(ex: ex, onDone: _win);
      case 5:
        return SpellGame(ex: ex, onDone: _win);
      default:
        return FillGame(ex: ex, onDone: _win);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Creative Writing Realm ✍️',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(children: [
                Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 6), child: _topBar()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                    child: mode == null
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('✍️ Creative Writing Realm', style: ts(24, w: FontWeight.w800, c: kGold)),
                            Text('Choose a quest and earn XP, stars & flames!',
                                style: ts(14, c: Colors.white70)),
                            const SizedBox(height: 14),
                            _hub(),
                          ])
                        : _activity(),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

// ───────────────────────── 1. LETTER GAME ─────────────────────────
const _letters = [
  [
    'Formal letter to the Principal',
    [
      '12 Rose Lane, Pune\n12 March 2026',
      'Dear Sir,',
      "I respectfully request you to grant me two days' leave as I am unwell.",
      'Yours obediently,\nAarav Sharma'
    ]
  ],
  [
    'Informal letter to a friend',
    [
      '45 Lake Road, Goa\n5 May 2026',
      'Dear Riya,',
      'I had so much fun at your party! Thank you for the lovely gift.',
      'Your loving friend,\nMeera'
    ]
  ],
  [
    'Formal letter to the Editor',
    [
      '8 Park Street, Delhi\n20 June 2026',
      'The Editor,\nDaily News',
      'Our road has many potholes. Kindly draw the attention of the authorities to it.',
      'Yours faithfully,\nKabir Rao'
    ]
  ],
];
const _lLabels = ['Sender Address & Date', 'Salutation', 'Body Paragraph', 'Subscription & Sign-off'];

class LetterGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const LetterGame({super.key, required this.ex, required this.onDone});
  @override
  State<LetterGame> createState() => _LetterGameState();
}

class _LetterGameState extends State<LetterGame> {
  late final List<String> blocks = (_letters[widget.ex][1] as List).cast<String>();
  late final List<int> pool = List.generate(4, (i) => i)..shuffle();
  int placed = 0, wrong = 0, shake = 0;

  void tap(int i) {
    if (i < placed) return;
    if (i == placed) {
      setState(() => placed++);
      if (placed == 4) later(this, () => widget.onDone(score(wrong)));
    } else {
      setState(() {
        wrong++;
        shake++;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_letters[widget.ex][0] as String, style: ts(16, w: FontWeight.w800, c: kCy)),
        const SizedBox(height: 4),
        Text('Tap the blocks in the correct order 👇', style: ts(13, c: Colors.white70)),
        const SizedBox(height: 8),
        ShakeBox(
            trigger: shake,
            child: panel(Wrap(spacing: 8, runSpacing: 8, children: [
              for (final i in pool)
                Opacity(opacity: i < placed ? .3 : 1, child: Pill(blocks[i], c: kCy, onTap: () => tap(i)))
            ]))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: i == 0 ? Alignment.centerRight : Alignment.centerLeft,
                  child: i < placed
                      ? Text(blocks[i],
                          style: hand(20), textAlign: i == 0 ? TextAlign.right : TextAlign.left)
                      : Text('— ${_lLabels[i]} —', style: ts(12, c: Colors.black38)),
                ),
              ),
          ]),
        ),
      ]);
}

// ───────────────────────── 2. DIARY GAME ─────────────────────────
const _diary = [
  [
    'Today was unbelievable because...',
    ['I scored the winning goal.', 'I got full marks in my test.', 'my best friend surprised me.'],
    'The best part of my school day was...',
    ['the art class.', 'lunch with my friends.', 'the science experiment.']
  ],
  [
    'I felt thoughtful when...',
    ['I watched the rain from my window.', 'I read a story about courage.', 'I helped a classmate.'],
    'Tomorrow I hope to...',
    ['learn something new.', 'be kinder to everyone.', 'finish my project.']
  ],
];

class DiaryGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const DiaryGame({super.key, required this.ex, required this.onDone});
  @override
  State<DiaryGame> createState() => _DiaryGameState();
}

class _DiaryGameState extends State<DiaryGame> {
  static const moods = ['😄 Happy', '🤩 Excited', '🤔 Thoughtful'];
  static const mo = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  String? mood;
  DateTime? date;
  TimeOfDay? time;
  final List<int?> a = [null, null];
  bool stuck = false;
  List get d => _diary[widget.ex];
  bool get ready => mood != null && date != null && time != null && a[0] != null && a[1] != null;

  Future<void> pickDate() async {
    final r = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (c, w) => Theme(data: ThemeData.dark(), child: w!));
    if (r != null) setState(() => date = r);
  }

  Future<void> pickTime() async {
    final r = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (c, w) => Theme(data: ThemeData.dark(), child: w!));
    if (r != null) setState(() => time = r);
  }

  Widget stem(int k) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d[k * 2] as String, style: ts(15, w: FontWeight.w800, c: kGold)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (int i = 0; i < 3; i++)
            Pill((d[k * 2 + 1] as List)[i] as String,
                c: kGold, on: a[k] == i, onTap: () => setState(() => a[k] = i))
        ]),
        const SizedBox(height: 12),
      ]);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        panel(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('1. How do you feel?', style: ts(15, w: FontWeight.w800, c: kGold)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in moods)
                  Pill(m, c: kGold, on: mood == m, onTap: () => setState(() => mood = m))
              ]),
              const SizedBox(height: 12),
              Text('2. Date & time', style: ts(15, w: FontWeight.w800, c: kGold)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Pill(
                    date == null
                        ? '📅 Pick date'
                        : '📅 ${date!.day} ${mo[date!.month - 1]} ${date!.year}',
                    c: kCy,
                    on: date != null,
                    onTap: pickDate),
                Pill(time == null ? '🕒 Pick time' : '🕒 ${time!.format(context)}',
                    c: kCy, on: time != null, onTap: pickTime),
              ]),
              const SizedBox(height: 12),
              stem(0),
              stem(1),
            ]),
            c: kGold),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: const Border(left: BorderSide(color: Color(0xFFD32F2F), width: 4))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dear Diary, ${mood?.split(' ').first ?? '❓'}', style: hand(24)),
            Text(
                '${date == null ? '__ ___ ____' : '${date!.day} ${mo[date!.month - 1]} ${date!.year}'} · ${time?.format(context) ?? '__:__'}',
                style: hand(18, c: Colors.brown)),
            const SizedBox(height: 8),
            Text('${d[0]} ${a[0] == null ? '______' : (d[1] as List)[a[0]!]}', style: hand(21)),
            const SizedBox(height: 6),
            Text('${d[2]} ${a[1] == null ? '______' : (d[3] as List)[a[1]!]}', style: hand(21)),
            if (stuck) const Align(alignment: Alignment.centerRight, child: Text('🌟', style: TextStyle(fontSize: 46))),
          ]),
        ),
        const SizedBox(height: 12),
        goldBtn(
            'Paste golden sticker ⭐',
            ready && !stuck
                ? () {
                    setState(() => stuck = true);
                    later(this, () => widget.onDone(30));
                  }
                : null),
      ]);
}

// ───────────────────────── 3. BIO GAME ─────────────────────────
const _bioLabels = ['Name', 'Born', 'Profession', 'Greatest Achievement'];
const _bios = [
  [
    '🔬',
    'Famous Scientist',
    ['Marie Curie', 'Isaac Newton', 'C. V. Raman'],
    ['1867, Warsaw', '1643, England', '1888, India'],
    ['Physicist', 'Chemist', 'Astronomer'],
    ['Discovered radioactivity', 'Explained gravity', 'Won the Nobel Prize'],
    ['Curious', 'Hardworking', 'Brave', 'Humble', 'Lazy']
  ],
  [
    '🏏',
    'Sports Hero',
    ['Sachin Tendulkar', 'Mary Kom', 'Neeraj Chopra'],
    ['1973, Mumbai', '1983, Manipur', '1998, Haryana'],
    ['Cricketer', 'Boxer', 'Javelin Thrower'],
    ['100 international centuries', 'Six-time World Champion', 'Olympic gold medal'],
    ['Disciplined', 'Determined', 'Team player', 'Fearless', 'Rude']
  ],
  [
    '🛡️',
    'Fantasy Warrior',
    ['Aria Stormblade', 'Kael the Brave', 'Luna Shadowfox'],
    ['Year 1200, Emberfall', 'Year 1185, Skyreach', 'Year 1210, Moonwood'],
    ['Dragon Rider', 'Guardian Knight', 'Forest Archer'],
    ['Saved the kingdom', 'Tamed the fire dragon', 'Found the lost crystal'],
    ['Loyal', 'Fearless', 'Wise', 'Clever', 'Greedy']
  ],
];

class BioGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const BioGame({super.key, required this.ex, required this.onDone});
  @override
  State<BioGame> createState() => _BioGameState();
}

class _BioGameState extends State<BioGame> {
  final List<String?> sel = [null, null, null, null];
  final Set<String> traits = {};
  bool sealed = false;
  List get b => _bios[widget.ex];
  bool get ready => sel.every((e) => e != null) && traits.length >= 2;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        panel(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${b[0]} Create a ${b[1]}', style: ts(16, w: FontWeight.w800, c: kEm)),
              for (int i = 0; i < 4; i++) ...[
                const SizedBox(height: 10),
                Text(_bioLabels[i], style: ts(13, c: Colors.white70)),
                const SizedBox(height: 4),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final o in (b[2 + i] as List).cast<String>())
                    Pill(o, c: kEm, on: sel[i] == o, onTap: () => setState(() => sel[i] = o))
                ]),
              ],
              const SizedBox(height: 10),
              Text('Key Personality Traits (pick 2+)', style: ts(13, c: Colors.white70)),
              const SizedBox(height: 4),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final o in (b[6] as List).cast<String>())
                  Pill(o,
                      c: kGold,
                      on: traits.contains(o),
                      onTap: () => setState(
                          () => traits.contains(o) ? traits.remove(o) : traits.add(o)))
              ]),
            ]),
            c: kEm),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F3D33)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold, width: 2),
              boxShadow: [BoxShadow(color: kGold.withValues(alpha: .3), blurRadius: 16)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${b[0]} LEGEND CARD', style: ts(13, w: FontWeight.w800, c: kGold)),
            const SizedBox(height: 6),
            Text(sel[0] ?? '???', style: ts(24, w: FontWeight.w800)),
            const Divider(color: Colors.white24),
            for (int i = 1; i < 4; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${_bioLabels[i]}: ${sel[i] ?? '—'}', style: ts(14, c: Colors.white70))),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final t in traits)
                Chip(
                    label: Text(t, style: ts(12, c: Colors.black)),
                    backgroundColor: kEm,
                    visualDensity: VisualDensity.compact)
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        goldBtn(
            'Unlock Legend Card 🏅',
            ready && !sealed
                ? () {
                    setState(() => sealed = true);
                    later(this, () => widget.onDone(30));
                  }
                : null),
      ]);
}

// ───────────────────────── 4. NOTICE GAME ─────────────────────────
// each step: [label, correct, wrong1, wrong2]
const _notices = [
  [
    ['Name of Institution', 'GREENFIELD PUBLIC SCHOOL', 'greenfield public school', 'Sports Club'],
    ['NOTICE Header', 'NOTICE', 'Dear Students', 'Letter'],
    ['Event Date', '12 December 2026', 'Some day soon', 'Date: tomorrow-ish'],
    ['Headline', 'ANNUAL SPORTS MEET', 'We are playing', 'Come and play'],
    ['Audience & Time', 'For Classes 5–10 | 9:00 a.m. at the School Ground', 'Everyone should come', 'Time is morning'],
    ['Authorizing Signatory', 'Mr. S. Verma, Principal', 'Principal sir', 'From school'],
  ],
  [
    ['Name of Institution', 'SUNRISE INTERNATIONAL SCHOOL', 'sunrise school lost', 'Lost Office'],
    ['NOTICE Header', 'NOTICE', 'Hello Everyone', 'Request'],
    ['Event Date', '3 February 2027', 'Yesterday', 'Date: unknown'],
    ['Headline', 'LOST & FOUND: BLUE SCHOOL BAG', 'I lost my bag', 'Bag gone!!!'],
    ['Audience & Time', 'For all students | Contact Room 12 before 2:00 p.m.', 'Whoever finds it', 'Call me'],
    ['Authorizing Signatory', 'Ms. A. Nair, Student Council Secretary', 'Student', 'Nobody'],
  ],
];

class NoticeGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const NoticeGame({super.key, required this.ex, required this.onDone});
  @override
  State<NoticeGame> createState() => _NoticeGameState();
}

class _NoticeGameState extends State<NoticeGame> {
  late final List steps = _notices[widget.ex];
  late final List<List<String>> opts = [
    for (final s in steps) <String>[s[1], s[2], s[3]]..shuffle()
  ];
  int step = 0, wrong = 0, shake = 0;

  void pick(String s) {
    if (s == steps[step][1]) {
      setState(() => step++);
      if (step == 6) later(this, () => widget.onDone(score(wrong)));
    } else {
      setState(() {
        wrong++;
        shake++;
      });
    }
  }

  Widget slot(int i) {
    if (i >= step) return Text('[ ${steps[i][0]} ]', style: ts(12, c: Colors.black38), textAlign: TextAlign.center);
    final t = steps[i][1] as String;
    final st = [
      ts(15, w: FontWeight.w800, c: Colors.black),
      ts(24, w: FontWeight.w800, c: Colors.black),
      ts(14, c: Colors.black87),
      ts(17, w: FontWeight.w800, c: Colors.black),
      ts(14, c: Colors.black87),
      ts(14, w: FontWeight.w700, c: Colors.black)
    ][i];
    return Text(t,
        style: i == 1 ? st.copyWith(decoration: TextDecoration.underline) : st,
        textAlign: i == 5
            ? TextAlign.right
            : i == 2
                ? TextAlign.left
                : TextAlign.center);
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (step < 6) ...[
          Text('Choose: ${steps[step][0]}', style: ts(16, w: FontWeight.w800, c: kRed)),
          const SizedBox(height: 8),
          ShakeBox(trigger: shake, child: panel(choices(opts[step], pick, kRed), c: kRed)),
        ] else
          Text('📢 Notice complete!', style: ts(16, w: FontWeight.w800, c: kEm)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5), border: Border.all(color: Colors.black, width: 3)),
          child: Column(children: [
            for (int i = 0; i < 6; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: i == 5
                          ? Alignment.centerRight
                          : i == 2
                              ? Alignment.centerLeft
                              : Alignment.center,
                      child: slot(i)))
          ]),
        ),
      ]);
}

// ───────────────────────── 5. EMAIL GAME ─────────────────────────
// [to, subjects(correct first), greetings, bodies, signoff]
const _emails = [
  [
    'Class Teacher',
    ['Leave Application for 14 March', 'hi', 'URGENT!!! READ NOW'],
    ["Dear Ma'am,", 'Hey teacher!', 'Yo!'],
    [
      'I am unwell with a fever and request leave on 14 March. I will complete the missed work.',
      'i cant come tomorrow bye',
      'Give me leave.'
    ],
    'Regards,\nAarav, Class 7B'
  ],
  [
    'Dr. Mehta (Guest Speaker)',
    ['Invitation: Guest Talk on Space Science', 'Come to school', 'Hello'],
    ['Dear Dr. Mehta,', 'Hi Mehta,', "Hello sir what's up"],
    [
      'We would be honoured if you could speak to our students on 5 April at 10 a.m. in the school hall.',
      'You must come on 5 April.',
      'Please speak at our school sometime.'
    ],
    'Sincerely,\nMeera, Science Club'
  ],
];

class EmailGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const EmailGame({super.key, required this.ex, required this.onDone});
  @override
  State<EmailGame> createState() => _EmailGameState();
}

class _EmailGameState extends State<EmailGame> {
  late final List e = _emails[widget.ex];
  late final List<List<String>> o = [
    for (int i = 1; i <= 3; i++) List<String>.from(e[i] as List)..shuffle()
  ];
  static const lab = ['Subject Line', 'Greeting', 'Body'];
  final List<String?> got = [null, null, null];
  int step = 0, wrong = 0, shake = 0;
  bool sent = false;

  void pick(String s) {
    if (s == (e[step + 1] as List)[0]) {
      setState(() {
        got[step] = s;
        step++;
      });
    } else {
      setState(() {
        wrong++;
        shake++;
      });
    }
  }

  void send() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() => sent = true);
    later(this, () => widget.onDone(score(wrong)));
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (step < 3) ...[
          Text('Pick the best: ${lab[step]}', style: ts(16, w: FontWeight.w800, c: kCy)),
          const SizedBox(height: 8),
          ShakeBox(trigger: shake, child: panel(choices(o[step], pick, kCy))),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('To: ${e[0]}', style: ts(14, c: Colors.black54)),
            const Divider(),
            Text('Subject: ${got[0] ?? '—'}', style: ts(14, w: FontWeight.w800, c: Colors.black)),
            const Divider(),
            Text(got[1] ?? '…', style: ts(14, c: Colors.black87)),
            const SizedBox(height: 6),
            Text(got[2] ?? '…', style: ts(14, c: Colors.black87)),
            const SizedBox(height: 10),
            if (step == 3) Text(e[4] as String, style: ts(14, c: Colors.black87)),
            if (sent) Text('✅ Sent! 🎉', style: ts(16, w: FontWeight.w800, c: kEm)),
          ]),
        ),
        const SizedBox(height: 12),
        goldBtn('Send 🚀', step == 3 && !sent ? send : null),
      ]);
}

// ───────────────────────── 6. SPELLING DETECTIVE ─────────────────────────
const _spell = [
  [
    'The princpal gave a wonderfull speech today.',
    {
      'princpal': ['principal', 'principle', 'princaple'],
      'wonderfull': ['wonderful', 'wonderfal', 'wondeful']
    }
  ],
  [
    'My freind will recieve a prize.',
    {
      'freind': ['friend', 'freend', 'frend'],
      'recieve': ['receive', 'receeve', 'receve']
    }
  ],
  [
    'We went to the libary to borow books.',
    {
      'libary': ['library', 'librery', 'liberry'],
      'borow': ['borrow', 'borrough', 'borraw']
    }
  ],
];

class SpellGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const SpellGame({super.key, required this.ex, required this.onDone});
  @override
  State<SpellGame> createState() => _SpellGameState();
}

class _SpellGameState extends State<SpellGame> {
  late final List<String> toks = (_spell[widget.ex][0] as String).split(' ');
  late final Map<String, List<String>> w = Map<String, List<String>>.from((_spell[widget.ex][1] as Map)
      .map((k, v) => MapEntry(k as String, (v as List).cast<String>())));
  final Set<int> fixed = {};
  int? sel;
  List<String> opts = [];
  int wrong = 0, shake = 0;
  String msg = '🔎 Tap the misspelled word!';
  String key(String t) => t.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  void tapTok(int i) {
    if (fixed.contains(i)) return;
    final k = key(toks[i]);
    HapticFeedback.lightImpact();
    if (w.containsKey(k)) {
      setState(() {
        sel = i;
        opts = List<String>.from(w[k]!)..shuffle();
        msg = 'Choose the correct spelling:';
      });
    } else {
      setState(() {
        sel = null;
        wrong++;
        shake++;
        msg = '🙈 That word is fine! Keep looking.';
      });
    }
  }

  void choose(String s) {
    final k = key(toks[sel!]);
    if (s == w[k]![0]) {
      setState(() {
        fixed.add(sel!);
        toks[sel!] = toks[sel!].replaceFirst(RegExp(r'[A-Za-z]+'), s);
        sel = null;
        msg = '✅ Great catch!';
      });
      if (fixed.length == w.length) later(this, () => widget.onDone(score(wrong)));
    } else {
      setState(() {
        wrong++;
        shake++;
        msg = '❌ Not quite, try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(msg, style: ts(15, w: FontWeight.w800, c: kGold)),
        const SizedBox(height: 8),
        ShakeBox(
            trigger: shake,
            child: panel(
                Wrap(spacing: 8, runSpacing: 10, children: [
                  for (int i = 0; i < toks.length; i++)
                    GestureDetector(
                      onTap: () => tapTok(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                            color: fixed.contains(i) ? kEm.withValues(alpha: .25) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: sel == i
                                    ? kGold
                                    : fixed.contains(i)
                                        ? kEm
                                        : Colors.white12,
                                width: sel == i ? 2 : 1)),
                        child: Text(toks[i], style: ts(19, c: fixed.contains(i) ? kEm : Colors.white)),
                      ),
                    ),
                ]),
                c: kGold)),
        if (sel != null) ...[const SizedBox(height: 12), choices(opts, choose, kGold)],
        const SizedBox(height: 10),
        Text('Mistakes found: ${fixed.length}/${w.length}', style: ts(13, c: Colors.white70)),
      ]);
}

// ───────────────────────── 7. FILL IN THE BLANKS ─────────────────────────
const _fills = [
  [
    'Yesterday we ___ to the zoo and ___ many animals. Tomorrow we ___ visit the museum.',
    ['went', 'saw', 'will'],
    ['go', 'sees']
  ],
  [
    'She ___ a book when I called her. Birds ___ in the sky. He has ___ his homework already.',
    ['was reading', 'fly', 'finished'],
    ['reads', 'finish']
  ],
  [
    'The ___ weather made us wear sweaters. Our teacher was ___ when we won. The ___ boy shared his lunch.',
    ['chilly', 'delighted', 'generous'],
    ['scorching', 'gloomy']
  ],
];

class FillGame extends StatefulWidget {
  final int ex;
  final void Function(int) onDone;
  const FillGame({super.key, required this.ex, required this.onDone});
  @override
  State<FillGame> createState() => _FillGameState();
}

class _FillGameState extends State<FillGame> {
  late final List f = _fills[widget.ex];
  late final List<String> ans = (f[1] as List).cast<String>();
  late final List<String> chips = [...ans, ...(f[2] as List).cast<String>()]..shuffle();
  late final List<String?> filled = List.filled(ans.length, null);
  final Set<int> used = {};
  int wrong = 0, shake = 0;
  int get next => filled.indexOf(null);

  void tap(int ci) {
    if (used.contains(ci) || next < 0) return;
    if (chips[ci] == ans[next]) {
      setState(() {
        filled[next] = chips[ci];
        used.add(ci);
      });
      if (next < 0) later(this, () => widget.onDone(score(wrong)));
    } else {
      setState(() {
        wrong++;
        shake++;
      });
    }
  }

  Widget blank(int k) {
    final v = filled[k], cur = k == next;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: v != null ? kEm.withValues(alpha: .25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: v != null ? kEm : cur ? kCy : Colors.white38, width: cur ? 2 : 1),
          boxShadow: v != null ? [BoxShadow(color: kEm.withValues(alpha: .7), blurRadius: 12)] : null),
      child: Text(v ?? '[ ___ ]',
          textAlign: TextAlign.center, style: ts(18, c: v != null ? kEm : Colors.white54)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = (f[0] as String).split('___');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ShakeBox(
          trigger: shake,
          child: panel(
              Wrap(spacing: 6, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
                for (int k = 0; k < parts.length; k++) ...[
                  for (final word in parts[k].split(' ').where((e) => e.isNotEmpty)) Text(word, style: ts(18)),
                  if (k < parts.length - 1) blank(k),
                ]
              ]),
              c: kEm)),
      const SizedBox(height: 14),
      Text('Tap a word to snap it into the next blank 👇', style: ts(13, c: Colors.white70)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (int i = 0; i < chips.length; i++)
          Opacity(
              opacity: used.contains(i) ? .25 : 1,
              child: Pill(chips[i], c: kEm, onTap: () => tap(i)))
      ]),
    ]);
  }
}
