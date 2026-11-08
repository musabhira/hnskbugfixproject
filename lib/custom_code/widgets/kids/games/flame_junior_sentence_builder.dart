import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

// ============================================================================
// 🚂 1. JUNIOR SENTENCE BUILDER DATA MODELS & 90-DAY CURRICULUM
// ============================================================================

class JuniorSentenceTile {
  final String id;
  final String text;
  final String emoji;
  final Color cardColor;

  const JuniorSentenceTile({
    required this.id,
    required this.text,
    required this.emoji,
    required this.cardColor,
  });
}

class JuniorSentenceChallenge {
  final int day;
  final String fullSentence;
  final String translationMl;
  final String? translationHi;
  final String? translationTa;
  final String? translationKn;
  final String hint;
  final List<JuniorSentenceTile> tiles;

  const JuniorSentenceChallenge({
    required this.day,
    required this.fullSentence,
    required this.translationMl,
    this.translationHi,
    this.translationTa,
    this.translationKn,
    required this.hint,
    required this.tiles,
  });

  String getLocalizedMeaning() {
    return PocketLanguageService.localize(
      en: fullSentence,
      ml: translationMl,
      hi: translationHi ?? translationMl,
      ta: translationTa ?? translationMl,
      kn: translationKn ?? translationMl,
    );
  }
}

/// 📚 Progressive 90-Day Junior Sentence Database for Young Learners
class KidsSentenceCurriculum {
  static final List<JuniorSentenceChallenge> challenges = [
    // --- DAY 1 ---
    JuniorSentenceChallenge(
      day: 1,
      fullSentence: "I see a cute cat",
      translationMl: "ഞാൻ ഒരു കൊച്ചു പൂച്ചയെ കാണുന്നു 🐱",
      translationTa: "நான் ஒரு அழகான பூனையைப் பார்க்கிறேன் 🐱",
      translationHi: "मुझे एक प्यारी बिल्ली दिख रही है 🐱",
      translationKn: "ನಾನು ಮುದ್ದಾದ ಬೆಕ್ಕನ್ನು ನೋಡುತ್ತಿದ್ದೇನೆ 🐱",
      hint: "Start with who is looking! (I see...)",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I see',
          emoji: '👁️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'a cute',
          emoji: '✨',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'cat',
          emoji: '🐱',
          cardColor: Color(0xFFFFCC00),
        ),
      ],
    ),

    // --- DAY 2 ---
    JuniorSentenceChallenge(
      day: 2,
      fullSentence: "The puppy can run fast",
      translationMl: "നായക്കുട്ടിക്ക് വേഗത്തിൽ ഓടാൻ കഴിയും 🐶",
      hint: "Who can run fast? The puppy!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'The puppy',
          emoji: '🐶',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'can run',
          emoji: '🏃',
          cardColor: Color(0xFF34C759),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'fast',
          emoji: '⚡',
          cardColor: Color(0xFFAF52DE),
        ),
      ],
    ),

    // --- DAY 3 ---
    JuniorSentenceChallenge(
      day: 3,
      fullSentence: "I love sweet red apples",
      translationMl: "എനിക്ക് ചുവന്ന മധുരമുള്ള ആപ്പിൾ ഇഷ്ടമാണ് 🍎",
      hint: "What sweet fruit do you love?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I love',
          emoji: '❤️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'sweet red',
          emoji: '🍓',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'apples',
          emoji: '🍎',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 4 ---
    JuniorSentenceChallenge(
      day: 4,
      fullSentence: "The bright sun is shining",
      translationMl: "ശോഭയുള്ള സൂര്യൻ പ്രകാശിക്കുന്നു ☀️",
      hint: "Look up at the sky!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'The bright sun',
          emoji: '☀️',
          cardColor: Color(0xFFFFCC00),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'is',
          emoji: '✨',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'shining',
          emoji: '🌟',
          cardColor: Color(0xFF00C7BE),
        ),
      ],
    ),

    // --- DAY 5 ---
    JuniorSentenceChallenge(
      day: 5,
      fullSentence: "This is my happy house",
      translationMl: "ഇത് എൻ്റെ സന്തോഷമുള്ള വീടാണ് 🏡",
      hint: "Welcome to your house!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'This is',
          emoji: '👉',
          cardColor: Color(0xFF5856D6),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'my happy',
          emoji: '😊',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'house',
          emoji: '🏡',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 10 ---
    JuniorSentenceChallenge(
      day: 10,
      fullSentence: "Birds fly high in the sky",
      translationMl: "പക്ഷികൾ ആകാശത്തിൽ ഉയരത്തിൽ പറക്കുന്നു 🕊️",
      hint: "Where do birds fly?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'Birds fly',
          emoji: '🕊️',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'high up',
          emoji: '☁️',
          cardColor: Color(0xFF00C7BE),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'in the sky',
          emoji: '🌈',
          cardColor: Color(0xFFAF52DE),
        ),
      ],
    ),

    // --- DAY 20 ---
    JuniorSentenceChallenge(
      day: 20,
      fullSentence: "Please give me cold water",
      translationMl: "ദയവായി എനിക്ക് തണുത്ത വെള്ളം തരുമോ 💧",
      hint: "Say the polite word first! (Please...)",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'Please give',
          emoji: '🙏',
          cardColor: Color(0xFF34C759),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'me some',
          emoji: '🤲',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'cold water',
          emoji: '💧',
          cardColor: Color(0xFF00C7BE),
        ),
      ],
    ),

    // --- DAY 30 ---
    JuniorSentenceChallenge(
      day: 30,
      fullSentence: "We play with good friends",
      translationMl: "ഞങ്ങൾ നല്ല കൂട്ടുകാരോടൊപ്പം കളിക്കുന്നു 👫",
      hint: "Who do you play with every day?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'We play',
          emoji: '⚽',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'together with',
          emoji: '🤝',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'good friends',
          emoji: '👫',
          cardColor: Color(0xFF5856D6),
        ),
      ],
    ),

    // --- DAY 60 ---
    JuniorSentenceChallenge(
      day: 60,
      fullSentence: "I can read stories nicely",
      translationMl: "എനിക്ക് കഥകൾ ഭംഗിയായി വായിക്കാൻ കഴിയും 📖",
      hint: "Show your story reading super power!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I can read',
          emoji: '📖',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'funny stories',
          emoji: '🎭',
          cardColor: Color(0xFFFFCC00),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'very nicely',
          emoji: '🌟',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 90 ---
    JuniorSentenceChallenge(
      day: 90,
      fullSentence: "I speak English with big joy",
      translationMl: "ഞാൻ വളരെ സന്തോഷത്തോടെ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു 🎓",
      hint: "The 90-Day Junior Diplomat Master motto!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I speak',
          emoji: '🗣️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'fluent English',
          emoji: '🇬🇧',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'with big joy',
          emoji: '🎉',
          cardColor: Color(0xFFFFD700),
        ),
      ],
    ),
  ];

  static JuniorSentenceChallenge getForDay(int day) {
    if (day <= 0) return challenges.first;
    // Find matching explicit challenge if defined
    for (final c in challenges) {
      if (c.day == day) return c;
    }
    // Dynamically construct from 100-Day syllabus so all 90 days have unique sentences
    try {
      final syl = PocketKids100DaySyllabusDB.getSyllabusForDay(day);
      final parts = syl.dialogueSentence.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final third = (parts.length / 3).ceil();
        final part1 = parts.sublist(0, third).join(' ');
        final part2 = parts.sublist(third, math.min(third * 2, parts.length)).join(' ');
        final part3 = parts.sublist(math.min(third * 2, parts.length)).join(' ');

        return JuniorSentenceChallenge(
          day: day,
          fullSentence: syl.dialogueSentence,
          translationMl: "${syl.title} - ${syl.gameDescription}",
          hint: syl.gameTitle,
          tiles: [
            JuniorSentenceTile(
              id: '1',
              text: part1,
              emoji: syl.gameIcon,
              cardColor: const Color(0xFFFF2D55),
            ),
            JuniorSentenceTile(
              id: '2',
              text: part2,
              emoji: '✨',
              cardColor: const Color(0xFF007AFF),
            ),
            JuniorSentenceTile(
              id: '3',
              text: part3.isNotEmpty ? part3 : 'together',
              emoji: '🌟',
              cardColor: const Color(0xFF10B981),
            ),
          ],
        );
      }
    } catch (_) {}

    return challenges[(day - 1) % challenges.length];
  }

  /// 🚂 Guarantees 10 progressive rich rounds per day for substantial gameplay!
  static List<JuniorSentenceChallenge> getRoundsForDay(int day) {
    final List<JuniorSentenceChallenge> list = [];

    // 1. Primary day challenge
    list.add(getForDay(day));

    // 2. Syllabus rounds converted to kid sentence blocks
    try {
      final syl = PocketKids100DaySyllabusDB.getSyllabusForDay(day);
      for (int i = 0; i < syl.rounds.length; i++) {
        final r = syl.rounds[i];
        list.add(
          JuniorSentenceChallenge(
            day: day,
            fullSentence: "I see the ${r.targetWord}",
            translationMl: "${r.targetWord} ഞാൻ കാണുന്നു ${r.emoji}",
            hint: r.prompt,
            tiles: [
              const JuniorSentenceTile(
                id: '1',
                text: 'I see',
                emoji: '👀',
                cardColor: Color(0xFFFF2D55),
              ),
              const JuniorSentenceTile(
                id: '2',
                text: 'the cute',
                emoji: '✨',
                cardColor: Color(0xFF007AFF),
              ),
              JuniorSentenceTile(
                id: '3',
                text: r.targetWord,
                emoji: r.emoji,
                cardColor: const Color(0xFF10B981),
              ),
            ],
          ),
        );
      }
    } catch (_) {}

    // 3. Extra fun sentences pool to guarantee at least 10 rounds per day!
    final List<List<String>> extraSentences = [
      ["The sun", "is shining", "brightly", "സൂര്യൻ തിളങ്ങുന്നു ☀️", "☀️"],
      ["Little puppy", "can run", "very fast", "നായക്കുട്ടി വേഗത്തിൽ ഓടുന്നു 🐶", "🐶"],
      ["Birds can", "sing a", "sweet song", "പക്ഷികൾ മനോഹരമായി പാടുന്നു 🐦", "🐦"],
      ["We love to", "play in", "the park", "ഞങ്ങൾ പാർക്കിൽ കളിക്കുന്നു 🏞️", "🏞️"],
      ["Fish can", "swim in", "the water", "മത്സ്യം വെള്ളത്തിൽ നീന്തുന്നു 🐟", "🐟"],
      ["I have a", "small red", "ball", "എനിക്ക് ചെറിയൊരു പന്തുണ്ട് ⚽", "⚽"],
      ["The car goes", "fast on", "the road", "വണ്ടി റോഡിൽ ഓടുന്നു 🚗", "🚗"],
      ["She has an", "apple and", "orange", "ആപ്പിളും ഓറഞ്ചും ഉണ്ട് 🍎", "🍎"],
      ["Let us go", "to the", "garden", "നമുക്ക് പൂന്തോട്ടത്തിൽ പോകാം 🌸", "🌸"],
      ["The stars are", "shining in", "the night", "നക്ഷത്രങ്ങൾ മിന്നുന്നു ⭐", "⭐"],
      ["We are happy", "every single", "day", "ഞങ്ങൾ എപ്പോഴും സന്തോഷവന്മാരാണ് 😊", "😊"],
      ["Look at the", "big yellow", "moon", "വലിയ മഞ്ഞ ചന്ദ്രൻ 🌙", "🌙"],
    ];

    int poolIdx = (day * 3) % extraSentences.length;
    final colors = [
      const Color(0xFFFF2D55),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF007AFF),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    while (list.length < 10) {
      final item = extraSentences[poolIdx % extraSentences.length];
      list.add(JuniorSentenceChallenge(
        day: day,
        fullSentence: "${item[0]} ${item[1]} ${item[2]}",
        translationMl: item[3],
        hint: "Tap train blocks in the right order!",
        tiles: [
          JuniorSentenceTile(
            id: '1',
            text: item[0],
            emoji: '🚂',
            cardColor: colors[poolIdx % colors.length],
          ),
          JuniorSentenceTile(
            id: '2',
            text: item[1],
            emoji: '✨',
            cardColor: colors[(poolIdx + 1) % colors.length],
          ),
          JuniorSentenceTile(
            id: '3',
            text: item[2],
            emoji: item[4],
            cardColor: colors[(poolIdx + 2) % colors.length],
          ),
        ],
      ));
      poolIdx++;
    }

    return list.take(10).toList();
  }
}

// ============================================================================
// 🔥 2. FLAME PARTICLES & TOY TRAIN LOCOMOTIVE FX
// ============================================================================

/// Floating candy sparkle & train smoke particle
class CandySmokeParticle extends Component {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double radius;
  double life;
  double decay;

  CandySmokeParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.radius = 12.0,
    this.life = 1.0,
    this.decay = 1.5,
  });

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.x += 10.0 * dt; // gentle breeze
    radius += 4.0 * dt; // expanding smoke puff
    life -= decay * dt;
    if (life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: life.clamp(0.0, 0.8))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(position.x, position.y), radius, paint);
  }
}

/// Flame Game managing drifting sky clouds, train smoke puffs and fireworks
class SentenceBuilderFlameEngine extends FlameGame {
  final math.Random _rng = math.Random();
  double _smokeTimer = 0.0;
  bool isTrainChugging = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    _smokeTimer += dt;
    if (_smokeTimer > 0.25) {
      _smokeTimer = 0;
      // Ambient drifting floating star
      if (children.whereType<CandySmokeParticle>().length < 25) {
        add(
          CandySmokeParticle(
            position: Vector2(_rng.nextDouble() * size.x, size.y + 10),
            velocity: Vector2(
              (_rng.nextDouble() - 0.5) * 20,
              -30 - _rng.nextDouble() * 30,
            ),
            color: [
              const Color(0xFFFF9500),
              const Color(0xFFFFCC00),
              const Color(0xFF00C7BE),
              const Color(0xFFFF2D55),
              const Color(0xFFAF52DE),
            ][_rng.nextInt(5)],
            radius: 5.0 + _rng.nextDouble() * 4.0,
            life: 1.4,
            decay: 0.6,
          ),
        );
      }
    }
  }

  /// Puff cartoon smoke from locomotive stack
  void puffTrainSmoke(Offset stackPos) {
    for (int i = 0; i < 6; i++) {
      add(
        CandySmokeParticle(
          position: Vector2(stackPos.dx, stackPos.dy),
          velocity: Vector2(
            -20.0 - _rng.nextDouble() * 40.0,
            -40.0 - _rng.nextDouble() * 50.0,
          ),
          color: Colors.white.withValues(alpha: 0.8),
          radius: 8.0 + _rng.nextDouble() * 6.0,
          life: 1.2,
          decay: 1.1,
        ),
      );
    }
  }

  /// Celebration firework shower on sentence completed
  void burstVictoryConfetti() {
    for (int i = 0; i < 50; i++) {
      final origin = Vector2(
        size.x * 0.2 + _rng.nextDouble() * size.x * 0.6,
        size.y * 0.2 + _rng.nextDouble() * size.y * 0.3,
      );
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 80.0 + _rng.nextDouble() * 220.0;
      final colors = [
        const Color(0xFFFF2D55),
        const Color(0xFFFF9500),
        const Color(0xFFFFCC00),
        const Color(0xFF34C759),
        const Color(0xFF007AFF),
        const Color(0xFFAF52DE),
        const Color(0xFFFFD700),
      ];

      add(
        CandySmokeParticle(
          position: origin,
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[_rng.nextInt(colors.length)],
          radius: 8.0 + _rng.nextDouble() * 6.0,
          life: 1.5,
          decay: 0.8,
        ),
      );
    }
  }
}

// ============================================================================
// 🧩 3. FULL-SCREEN JUNIOR SENTENCE BUILDER INTERACTIVE PAGE
// ============================================================================

class PocketKidsSentenceBuilderPage extends StatefulWidget {
  final int initialDay;
  final VoidCallback? onCompleted;

  const PocketKidsSentenceBuilderPage({
    super.key,
    this.initialDay = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsSentenceBuilderPage(
          initialDay: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsSentenceBuilderPage> createState() =>
      _PocketKidsSentenceBuilderPageState();
}

class _PocketKidsSentenceBuilderPageState
    extends State<PocketKidsSentenceBuilderPage>
    with SingleTickerProviderStateMixin {
  late final SentenceBuilderFlameEngine _flameGame;
  final FlutterTts _tts = FlutterTts();

  late int _currentDay;
  late List<JuniorSentenceChallenge> _rounds;
  int _currentRoundIndex = 0;
  JuniorSentenceChallenge get _currentChallenge =>
      _rounds[_currentRoundIndex.clamp(0, _rounds.length - 1)];

  // Snapped Slots & Tray State
  final List<JuniorSentenceTile?> _placedTiles = [];
  final List<JuniorSentenceTile> _availableTrayTiles = [];

  bool _isCompleted = false;
  bool _hasMistake = false;
  int _highlightedWordIndex = -1; // For karaoke spoken highlight effect

  late AnimationController _trainWheelsController;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay;
    _rounds = KidsSentenceCurriculum.getRoundsForDay(_currentDay);
    _currentRoundIndex = 0;
    _flameGame = SentenceBuilderFlameEngine();

    _trainWheelsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _initTts();
    _setupRound();

    // Spoken Intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak("Let's build a sentence! ${_currentChallenge.hint}");
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.40);
  }

  void _setupRound() {
    _isCompleted = false;
    _highlightedWordIndex = -1;
    _placedTiles.clear();
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      _placedTiles.add(null);
    }

    // Scramble tiles for the tray
    _availableTrayTiles.clear();
    _availableTrayTiles.addAll(_currentChallenge.tiles);
    _availableTrayTiles.shuffle(math.Random());
  }

  void _switchDay(int newDay) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentDay = newDay;
      _rounds = KidsSentenceCurriculum.getRoundsForDay(_currentDay);
      _currentRoundIndex = 0;
      _setupRound();
    });
    _tts.speak("Level $_currentDay! ${_currentChallenge.hint}");
  }

  // --- 🧩 Tactile Tap / Snapping Mechanics ---
  void _onTapTrayTile(JuniorSentenceTile tile) {
    if (_isCompleted) return;

    // Single tap sounds out word for pre-readers
    _tts.speak(tile.text);
    HapticFeedback.lightImpact();

    // Find first empty slot in train
    final emptySlotIdx = _placedTiles.indexOf(null);
    if (emptySlotIdx != -1) {
      setState(() {
        _availableTrayTiles.remove(tile);
        _placedTiles[emptySlotIdx] = tile;
      });

      // Puff locomotive smoke
      _flameGame.puffTrainSmoke(const Offset(80, 220));

      // Check if all slots filled!
      if (!_placedTiles.contains(null)) {
        _checkSentenceSolution();
      }
    }
  }

  void _onTapPlacedSlot(int slotIndex) {
    if (_isCompleted) return;
    final tile = _placedTiles[slotIndex];
    if (tile != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _placedTiles[slotIndex] = null;
        _availableTrayTiles.add(tile);
      });
    }
  }

  void _checkSentenceSolution() {
    bool isCorrect = true;
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      if (_placedTiles[i]?.id != _currentChallenge.tiles[i].id) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        _hasMistake = false;
      });
      _onRoundWon();
    } else {
      setState(() {
        _hasMistake = true;
      });
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playIncorrectSound();
    }
  }

  void _onRoundWon() {
    setState(() {
      _isCompleted = true;
    });

    // Reward points & star cookies
    PocketKidsService.addKidsScore(15);
    PocketGameAudioService.instance.playVictorySfx();
    HapticFeedback.heavyImpact();

    // Flame fireworks!
    _flameGame.burstVictoryConfetti();

    // Karaoke Spoken Read-Aloud
    _playKaraokeReading().then((_) {
      if (!mounted) return;
      if (_currentRoundIndex + 1 < _rounds.length) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          _advanceToNextRound();
        });
      } else {
        widget.onCompleted?.call();
        _showGrandVictoryDialog();
      }
    });
  }

  void _advanceToNextRound() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _setupRound();
      });
      _tts.speak("Round ${_currentRoundIndex + 1}! ${_currentChallenge.hint}");
    }
  }

  void _showGrandVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚂🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Train Builder Champion! 🏆',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You built all ${_rounds.length} sentences today!\n+150 Kids Score & 3 Stars ⭐⭐⭐',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Awesome! 🚀',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playKaraokeReading() async {
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      if (!mounted) return;
      setState(() {
        _highlightedWordIndex = i;
      });
      await _tts.speak(_currentChallenge.tiles[i].text);
      await Future.delayed(const Duration(milliseconds: 650));
    }
    if (!mounted) return;
    setState(() {
      _highlightedWordIndex = -1;
    });
    // Speak full sentence cleanly
    await _tts.speak(_currentChallenge.fullSentence);
  }

  @override
  void dispose() {
    _trainWheelsController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 🌌 1. Flame Interactive Particles & Atmospheric Clouds
          Positioned.fill(
            child: GameWidget(game: _flameGame),
          ),

          // 🌟 2. Gentle Ambient Colorful Glow
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 1.1,
                    colors: [
                      Color(0x2238BDF8), // sky blue glow
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 📱 3. Responsive Scroll-Safe Layout (No Overlaps on any phone screen!)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Back Button, Day/Round Badge, Sound Out Prompt
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF00C7BE)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🚂", style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              "Day $_currentDay • Round ${_currentRoundIndex + 1}/${_rounds.length}",
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _tts.speak(_currentChallenge.fullSentence);
                        },
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFFFFD700),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🌟 Progress Dots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_rounds.length, (idx) {
                      final isPassed = idx < _currentRoundIndex ||
                          (idx == _currentRoundIndex && _isCompleted);
                      final isCurrent = idx == _currentRoundIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: isCurrent ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isPassed
                              ? const Color(0xFF10B981)
                              : (isCurrent
                                  ? const Color(0xFFFFD700)
                                  : Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 10),

                // Scrollable Central Game Section (Train Track + Hint + Word Depot)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🚂 Cartoon Choo-Choo Train & Wagon Tracks
                        _buildChooChooTrainTrack(),

                        const SizedBox(height: 14),

                        // 💡 Native Translation & Hint Card
                        _buildHintAndMeaningCard(),

                        const SizedBox(height: 16),

                        // 🍬 Scrambled Word Depot Platform (Station Word Blocks)
                        _buildWordDepotPlatform(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ⏭️ Bottom Navigation & Level Actions Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                    border: const Border(
                      top: BorderSide(color: Colors.white12, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentDay > 1
                            ? () => _switchDay(_currentDay - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(
                          "PREV",
                          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _setupRound();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _currentDay < 300
                            ? () => _switchDay(_currentDay + 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                        ),
                        label: Text(
                          "NEXT ➔",
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        icon: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🎉 Celebratory Card when Round Completed
          if (_isCompleted)
            Positioned.fill(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34C759), Color(0xFF00C7BE)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34C759).withValues(alpha: 0.6),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🚂💨 ⭐⭐⭐", style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        _currentRoundIndex + 1 < _rounds.length
                            ? "ROUND ${_currentRoundIndex + 1} CLEARED!"
                            : "ALL ABOARD CHAMPION!",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\"${_currentChallenge.fullSentence}\"",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "+15 KS Points & Golden Star Cookie 🍪",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_currentRoundIndex + 1 < _rounds.length) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _advanceToNextRound();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Next Sentence 🚂',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFFFFD700),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🚂 Cartoon Choo-Choo Locomotive & Connected Wagons on Track
  Widget _buildChooChooTrainTrack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hasMistake
              ? const Color(0xFFEF4444)
              : const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: _hasMistake ? 2.0 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Scrollable Train Track with Locomotive & Wagons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 🚂 Cartoon Locomotive Engine
                  _buildLocomotiveEngine(),

                  const SizedBox(width: 4),

                  // Wagons connected in order
                  ...List.generate(_placedTiles.length, (idx) {
                    final tile = _placedTiles[idx];
                    final isHighlighted = (_highlightedWordIndex == idx);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Coupler chain between cars
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            '🔗',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Wagon Car
                        _buildTrainWagonCar(idx, tile, isHighlighted),
                        const SizedBox(width: 4),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Steel Railway Tracks & Cross Ties
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFFCBD5E1), Color(0xFF64748B)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚂 Cartoon Locomotive Engine with Puffing Steam & Spinning Wheels
  Widget _buildLocomotiveEngine() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _tts.speak("Choo-Choo! All aboard!");
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Steam Clouds Puffing from Chimney
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 22),
              AnimatedBuilder(
                animation: _trainWheelsController,
                builder: (context, child) {
                  final s = 0.8 + (_trainWheelsController.value * 0.4);
                  return Transform.scale(
                    scale: s,
                    child: const Text('💨', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ],
          ),
          Container(
            width: 100,
            height: 85,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2D55), Color(0xFFFF9500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white70, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🚂', style: TextStyle(fontSize: 26)),
                      Text(
                        'EXPRESS',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Spinning Locomotive Wheels
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _trainWheelsController,
                child: const Text('⚙️', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 20),
              RotationTransition(
                turns: _trainWheelsController,
                child: const Text('⚙️', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🚃 Tactile Train Wagon Car Slot (Accommodates words smoothly without overflow)
  Widget _buildTrainWagonCar(int index, JuniorSentenceTile? tile, bool isHighlighted) {
    return GestureDetector(
      onTap: () => _onTapPlacedSlot(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 105,
            height: 85,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: tile != null
                  ? tile.cardColor
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFFFFD700)
                    : (tile != null
                        ? Colors.white
                        : Colors.white30),
                width: isHighlighted ? 3.0 : 1.8,
              ),
              boxShadow: isHighlighted
                  ? [
                      const BoxShadow(
                        color: Color(0xFFFFD700),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : (tile != null
                      ? [
                          BoxShadow(
                            color: tile.cardColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : []),
            ),
            child: tile != null
                ? Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(tile.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                tile.text,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Wagon ${index + 1}",
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          // Wagon Wheels
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _trainWheelsController,
                child: const Text('⚙️', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 22),
              RotationTransition(
                turns: _trainWheelsController,
                child: const Text('⚙️', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💡 Native Malayalam Translation & Interactive Hint Card
  Widget _buildHintAndMeaningCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _hasMistake ? const Color(0xFFEF4444) : Colors.white12,
          width: _hasMistake ? 1.6 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("💡", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _currentChallenge.getLocalizedMeaning(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (_hasMistake) ...[
            const SizedBox(height: 6),
            Text(
              "⚠️ Tap any wagon to unhook and swap blocks 😊",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFCA5A5),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🍬 Word Depot Platform: Magnetic Scrambled Word Chips
  Widget _buildWordDepotPlatform() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "CHOO-CHOO WORD DEPOT 🚂",
            style: GoogleFonts.fredoka(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap a block to hook it to the train!",
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),

          // Available Word Blocks
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _availableTrayTiles.map((tile) {
              return GestureDetector(
                onTap: () => _onTapTrayTile(tile),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tile.cardColor,
                        tile.cardColor.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white70, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: tile.cardColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tile.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        tile.text,
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
