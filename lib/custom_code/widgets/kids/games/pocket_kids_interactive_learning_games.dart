import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

// ============================================================================
// 1. 🚗 VEHICLES & SPEED WHEELS GARAGE GAME
// ============================================================================
class PocketKidsVehiclesAndWheelsGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsVehiclesAndWheelsGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsVehiclesAndWheelsGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsVehiclesAndWheelsGame> createState() =>
      _PocketKidsVehiclesAndWheelsGameState();
}

class _VehicleItem {
  final String name;
  final String emoji;
  final String sound;
  final String descriptionEn;
  final String meaningMl;
  final Color color;

  const _VehicleItem({
    required this.name,
    required this.emoji,
    required this.sound,
    required this.descriptionEn,
    required this.meaningMl,
    required this.color,
  });
}

class _PocketKidsVehiclesAndWheelsGameState
    extends State<PocketKidsVehiclesAndWheelsGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _driveController;

  static const List<_VehicleItem> _allVehicles = [
    _VehicleItem(name: "CAR", emoji: "🚗", sound: "Vroom vroom!", descriptionEn: "The shiny car zooms on the road.", meaningMl: "റോഡിലൂടെ ഓടുന്ന കാർ", color: Color(0xFFEF4444)),
    _VehicleItem(name: "BUS", emoji: "🚌", sound: "Honk honk!", descriptionEn: "The big yellow school bus carries students.", meaningMl: "കുട്ടികളെ കൊണ്ടുപോകുന്ന സ്കൂൾ ബസ്", color: Color(0xFFF59E0B)),
    _VehicleItem(name: "TRAIN", emoji: "🚂", sound: "Choo-choo!", descriptionEn: "The locomotive train chugs on the steel tracks.", meaningMl: "പാളത്തിലൂടെ പായുന്ന തീവണ്ടി", color: Color(0xFF06B6D4)),
    _VehicleItem(name: "AIRPLANE", emoji: "✈️", sound: "Whoosh!", descriptionEn: "The jet airplane flies high in the blue sky.", meaningMl: "ആകാശത്ത് പറക്കുന്ന വിമാനം", color: Color(0xFF3B82F6)),
    _VehicleItem(name: "HELICOPTER", emoji: "🚁", sound: "Chop-chop!", descriptionEn: "Spinning rotor blades lift the helicopter up.", meaningMl: "ഹെലികോപ്റ്റർ", color: Color(0xFF8B5CF6)),
    _VehicleItem(name: "BOAT", emoji: "⛵", sound: "Splash splash!", descriptionEn: "The sailboat glides smoothly across the lake.", meaningMl: "തടാകത്തിലൂടെ നീങ്ങുന്ന ബോട്ട്", color: Color(0xFF10B981)),
    _VehicleItem(name: "ROCKET", emoji: "🚀", sound: "Blast off!", descriptionEn: "The space rocket zooms to the moon.", meaningMl: "ബഹിരാകാശ റോക്കറ്റ്", color: Color(0xFFEC4899)),
    _VehicleItem(name: "FIRE TRUCK", emoji: "🚒", sound: "Wee-woo wee-woo!", descriptionEn: "Firefighters spray water from the fire engine.", meaningMl: "തീയണയ്ക്കുന്ന ഫയർ എഞ്ചിൻ", color: Color(0xFFDC2626)),
    _VehicleItem(name: "AMBULANCE", emoji: "🚑", sound: "Emergency siren!", descriptionEn: "The ambulance helps sick people reach the hospital.", meaningMl: "ആശുപത്രി ആംബുലൻസ്", color: Color(0xFF14B8A6)),
    _VehicleItem(name: "BICYCLE", emoji: "🚲", sound: "Ring ring!", descriptionEn: "Pedal the two-wheel bicycle in the park.", meaningMl: "സൈക്കിൾ", color: Color(0xFF6366F1)),
  ];

  late List<_VehicleItem> _rounds;
  int _roundIndex = 0;
  List<String> _shuffledOptions = [];
  bool _isAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _driveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initTts();
    _prepareRounds();
  }

  void _prepareRounds() {
    final startIdx = ((widget.day - 1) * 3) % _allVehicles.length;
    _rounds = [
      _allVehicles[startIdx],
      _allVehicles[(startIdx + 1) % _allVehicles.length],
      _allVehicles[(startIdx + 2) % _allVehicles.length],
    ];
    _setupCurrentRound();
  }

  void _setupCurrentRound() {
    _isAnswered = false;
    _isCorrect = false;
    final current = _rounds[_roundIndex];

    final distractors = _allVehicles
        .where((v) => v.name != current.name)
        .map((v) => v.name)
        .toList()
      ..shuffle();

    _shuffledOptions = [current.name, distractors[0], distractors[1]]..shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Find the ${current.name}!");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _driveController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onOptionSelected(String option) async {
    if (_isAnswered) return;
    final current = _rounds[_roundIndex];
    final correct = option == current.name;

    setState(() {
      _isAnswered = true;
      _isCorrect = correct;
    });

    if (correct) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      _driveController.forward(from: 0.0);
      await _tts.stop();
      await _tts.speak("${current.name}! ${current.sound}");

      Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_roundIndex + 1 < _rounds.length) {
          setState(() {
            _roundIndex++;
            _setupCurrentRound();
          });
        } else {
          _finishGame();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Try again! Look for the ${current.name}");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finishGame() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 4);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildVictoryDialog('GARAGE MASTER! 🚗', '+20 KS ⭐'),
      );
    }
  }

  Widget _buildVictoryDialog(String title, String reward) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.fredoka(
                color: const Color(0xFFFFD700),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You mastered vehicles today! $reward',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close page
                widget.onCompleted?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('AWESOME! 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF), // Pastel sky blue
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VEHICLES & WHEELS GARAGE 🚗',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Round ${_roundIndex + 1} of ${_rounds.length}',
                          style: GoogleFonts.fredoka(
                            color: const Color(0xFF1E293B),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_roundIndex + 1}/3 ⭐',
                      style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Vehicle Runway Stage
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Vehicle Display
                    AnimatedBuilder(
                      animation: _driveController,
                      builder: (context, _) {
                        final offset = _driveController.value * 300;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: current.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: current.color, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: current.color.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(current.emoji, style: const TextStyle(fontSize: 70)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sound badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            current.sound,
                            style: GoogleFonts.fredoka(color: const Color(0xFF2563EB), fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Malayalam Hint
                    Text(
                      PocketLanguageService.localize(
                        en: current.descriptionEn,
                        ml: current.meaningMl,
                      ),
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Option Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: _shuffledOptions.map((opt) {
                  final isTarget = opt == current.name;
                  Color btnColor = Colors.white;
                  Color textColor = const Color(0xFF1E293B);

                  if (_isAnswered) {
                    if (isTarget) {
                      btnColor = const Color(0xFF10B981);
                      textColor = Colors.white;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _onOptionSelected(opt),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isTarget && _isAnswered ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
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
      ),
    );
  }
}

// ============================================================================
// 2. 🦁 SAFARI ANIMAL FEEDER & SOUNDS GAME
// ============================================================================
class PocketKidsSafariAnimalFeederGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsSafariAnimalFeederGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsSafariAnimalFeederGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsSafariAnimalFeederGame> createState() =>
      _PocketKidsSafariAnimalFeederGameState();
}

class _AnimalFeederItem {
  final String animal;
  final String emoji;
  final String food;
  final String foodEmoji;
  final String sound;
  final String meaningMl;

  const _AnimalFeederItem({
    required this.animal,
    required this.emoji,
    required this.food,
    required this.foodEmoji,
    required this.sound,
    required this.meaningMl,
  });
}

class _PocketKidsSafariAnimalFeederGameState
    extends State<PocketKidsSafariAnimalFeederGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<_AnimalFeederItem> _animals = [
    _AnimalFeederItem(animal: "LION", emoji: "🦁", food: "Meat", foodEmoji: "🥩", sound: "Roar!", meaningMl: "സിംഹം മാംസം കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "MONKEY", emoji: "🐒", food: "Banana", foodEmoji: "🍌", sound: "Ooh ooh aah aah!", meaningMl: "കുരങ്ങൻ പഴം കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "PANDA", emoji: "🐼", food: "Bamboo", foodEmoji: "🎋", sound: "Munch munch!", meaningMl: "പാണ്ട മുള കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "RABBIT", emoji: "🐰", food: "Carrot", foodEmoji: "🥕", sound: "Hop hop!", meaningMl: "മുയൽ കാരറ്റ് കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "ELEPHANT", emoji: "🐘", food: "Leaves", foodEmoji: "🌿", sound: "Trumpet pawoo!", meaningMl: "ആന ഇലകൾ തിന്നുന്നു"),
    _AnimalFeederItem(animal: "BEAR", emoji: "🐻", food: "Honey", foodEmoji: "🍯", sound: "Grrr!", meaningMl: "കരടി തേൻ കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "DOG", emoji: "🐶", food: "Bone", foodEmoji: "🦴", sound: "Woof woof!", meaningMl: "പട്ടി എല്ല് കഴിക്കുന്നു"),
    _AnimalFeederItem(animal: "CAT", emoji: "🐱", food: "Fish", foodEmoji: "🐟", sound: "Meow meow!", meaningMl: "പൂച്ച മീൻ കഴിക്കുന്നു"),
  ];

  late List<_AnimalFeederItem> _rounds;
  int _roundIndex = 0;
  List<_AnimalFeederItem> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setupRounds();
  }

  void _setupRounds() {
    final startIdx = ((widget.day - 1) * 2) % _animals.length;
    _rounds = [
      _animals[startIdx],
      _animals[(startIdx + 1) % _animals.length],
      _animals[(startIdx + 2) % _animals.length],
    ];
    _prepareRound();
  }

  void _prepareRound() {
    _isAnswered = false;
    final target = _rounds[_roundIndex];
    final others = _animals.where((a) => a.animal != target.animal).toList()..shuffle();
    _options = [target, others[0], others[1]]..shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Feed the ${target.animal} its favorite food!");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _selectFood(_AnimalFeederItem item) async {
    if (_isAnswered) return;
    final current = _rounds[_roundIndex];
    final isCorrect = item.animal == current.animal;

    setState(() => _isAnswered = true);

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      await _tts.speak("Yummy! The ${current.animal} loves ${current.food}! ${current.sound}");

      Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_roundIndex + 1 < _rounds.length) {
          setState(() {
            _roundIndex++;
            _prepareRound();
          });
        } else {
          _finish();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Oops, that is for the ${item.animal}. Try again!");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 5);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF34D399), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦁', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text(
                  'SAFARI FEEDER MASTER! 🍖',
                  style: GoogleFonts.fredoka(color: const Color(0xFF34D399), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('All animals are full and happy! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('GREAT! 🌿', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5), // Soft pastel jungle mint
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SAFARI ANIMAL FEAST 🦁', style: GoogleFonts.outfit(color: const Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Round ${_roundIndex + 1} of 3', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981), width: 3),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.2), blurRadius: 16),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(current.emoji, style: const TextStyle(fontSize: 70)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'I am hungry! Feed me! 😋',
                      style: GoogleFonts.fredoka(color: const Color(0xFF047857), fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PocketLanguageService.localize(
                        en: "Feed the ${current.animal}",
                        ml: current.meaningMl,
                      ),
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: _options.map((opt) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => _selectFood(opt),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(opt.foodEmoji, style: const TextStyle(fontSize: 34)),
                              const SizedBox(height: 6),
                              Text(
                                opt.food,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
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
      ),
    );
  }
}

// ============================================================================
// 3. 🍎 FRUITS, VEGGIES & YUMMY BAKERY MARKET GAME
// ============================================================================
class PocketKidsFruitBakeryMarketGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsFruitBakeryMarketGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsFruitBakeryMarketGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsFruitBakeryMarketGame> createState() =>
      _PocketKidsFruitBakeryMarketGameState();
}

class _PocketKidsFruitBakeryMarketGameState
    extends State<PocketKidsFruitBakeryMarketGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<Map<String, String>> _foods = [
    {"name": "APPLE", "emoji": "🍎", "color": "Red", "meaning": "ആപ്പിൾ"},
    {"name": "BANANA", "emoji": "🍌", "color": "Yellow", "meaning": "പഴം"},
    {"name": "MANGO", "emoji": "🥭", "color": "Orange", "meaning": "മാങ്ങ"},
    {"name": "STRAWBERRY", "emoji": "🍓", "color": "Red", "meaning": "സ്ട്രോബെറി"},
    {"name": "WATERMELON", "emoji": "🍉", "color": "Green", "meaning": "തണ്ണിമത്തൻ"},
    {"name": "CUPCAKE", "emoji": "🧁", "color": "Pink", "meaning": "കേക്ക്"},
    {"name": "COOKIE", "emoji": "🍪", "color": "Brown", "meaning": "കുക്കി"},
    {"name": "PIZZA", "emoji": "🍕", "color": "Golden", "meaning": "പിസ്സ"},
  ];

  late List<Map<String, String>> _rounds;
  int _roundIndex = 0;
  List<Map<String, String>> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setupRounds();
  }

  void _setupRounds() {
    final startIdx = ((widget.day - 1) * 2) % _foods.length;
    _rounds = [
      _foods[startIdx],
      _foods[(startIdx + 1) % _foods.length],
      _foods[(startIdx + 2) % _foods.length],
    ];
    _prepare();
  }

  void _prepare() {
    _isAnswered = false;
    final target = _rounds[_roundIndex];
    final others = _foods.where((f) => f['name'] != target['name']).toList()..shuffle();
    _options = [target, others[0], others[1]]..shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Put the ${target['name']} into the market cart!");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _pickItem(Map<String, String> item) async {
    if (_isAnswered) return;
    final current = _rounds[_roundIndex];
    final correct = item['name'] == current['name'];

    setState(() => _isAnswered = true);

    if (correct) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      await _tts.speak("Delicious! Fresh ${current['name']} added!");

      Timer(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        if (_roundIndex + 1 < _rounds.length) {
          setState(() {
            _roundIndex++;
            _prepare();
          });
        } else {
          _finish();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Look for the ${current['name']}!");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 6);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF78350F),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFBBF24), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛒', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text(
                  'BAKERY CART FULL! 🥖',
                  style: GoogleFonts.fredoka(color: const Color(0xFFFBBF24), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('You collected all delicious treats! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  child: const Text('YUMMY! 🍎', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Pastel warm bakery yellow
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FRUIT & BAKERY MARKET 🍎', style: GoogleFonts.outfit(color: const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Round ${_roundIndex + 1} of 3', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), blurRadius: 16),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🛒', style: TextStyle(fontSize: 60)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Find: ${current['name']}!',
                      style: GoogleFonts.fredoka(color: const Color(0xFFB45309), fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PocketLanguageService.localize(
                        en: current['name'] ?? '',
                        ml: current['meaning'] ?? '',
                      ),
                      style: GoogleFonts.inter(color: const Color(0xFF78350F), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: _options.map((opt) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => _pickItem(opt),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFCD34D), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(opt['emoji'] ?? '🍎', style: const TextStyle(fontSize: 34)),
                              const SizedBox(height: 6),
                              Text(
                                opt['name'] ?? '',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
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
      ),
    );
  }
}

// ============================================================================
// 4. 🔢 NUMBER MAGIC & STAR COUNTING GAME (1-20)
// ============================================================================
class PocketKidsNumberMagicCountingGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsNumberMagicCountingGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsNumberMagicCountingGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsNumberMagicCountingGame> createState() =>
      _PocketKidsNumberMagicCountingGameState();
}

class _PocketKidsNumberMagicCountingGameState
    extends State<PocketKidsNumberMagicCountingGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<Map<String, dynamic>> _numbers = [
    {"num": 1, "word": "ONE", "emoji": "⭐"},
    {"num": 2, "word": "TWO", "emoji": "🎈"},
    {"num": 3, "word": "THREE", "emoji": "🍎"},
    {"num": 4, "word": "FOUR", "emoji": "🐶"},
    {"num": 5, "word": "FIVE", "emoji": "🌟"},
    {"num": 6, "word": "SIX", "emoji": "🌸"},
    {"num": 7, "word": "SEVEN", "emoji": "🌈"},
    {"num": 8, "word": "EIGHT", "emoji": "🍓"},
    {"num": 9, "word": "NINE", "emoji": "🚀"},
    {"num": 10, "word": "TEN", "emoji": "👑"},
  ];

  late List<Map<String, dynamic>> _rounds;
  int _roundIndex = 0;
  List<String> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setup();
  }

  void _setup() {
    final startIdx = ((widget.day - 1) * 2) % _numbers.length;
    _rounds = [
      _numbers[startIdx],
      _numbers[(startIdx + 1) % _numbers.length],
      _numbers[(startIdx + 2) % _numbers.length],
    ];
    _prepare();
  }

  void _prepare() {
    _isAnswered = false;
    final target = _rounds[_roundIndex];
    final others = _numbers.where((n) => n['word'] != target['word']).map((n) => n['word'] as String).toList()..shuffle();
    _options = [target['word'] as String, others[0], others[1]]..shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Count the items! How many do you see?");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _choose(String word) async {
    if (_isAnswered) return;
    final current = _rounds[_roundIndex];
    final isCorrect = word == current['word'];

    setState(() => _isAnswered = true);

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      await _tts.speak("Correct! ${current['num']} is spelled ${current['word']}!");

      Timer(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        if (_roundIndex + 1 < _rounds.length) {
          setState(() {
            _roundIndex++;
            _prepare();
          });
        } else {
          _finish();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Count again carefully!");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 7);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF818CF8), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔢', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('NUMBER WIZARD! ⭐', style: GoogleFonts.fredoka(color: const Color(0xFF818CF8), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You counted like a champion! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  child: const Text('SUPER! 🚀', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_roundIndex];
    final count = current['num'] as int;
    final emoji = current['emoji'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF), // Pastel lavender
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NUMBER MAGIC & COUNTING 🔢', style: GoogleFonts.outfit(color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Round ${_roundIndex + 1} of 3', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display N items
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(count, (i) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFA78BFA), width: 2),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 32)),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'How many do you see?',
                      style: GoogleFonts.fredoka(color: const Color(0xFF5B21B6), fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: _options.map((opt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _choose(opt),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC4B5FD), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: GoogleFonts.outfit(color: const Color(0xFF5B21B6), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. 🦸 SUPERHERO ACTION VERBS ARENA GAME
// ============================================================================
class PocketKidsActionSuperheroJumpGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsActionSuperheroJumpGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsActionSuperheroJumpGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsActionSuperheroJumpGame> createState() =>
      _PocketKidsActionSuperheroJumpGameState();
}

class _PocketKidsActionSuperheroJumpGameState
    extends State<PocketKidsActionSuperheroJumpGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<Map<String, String>> _verbs = [
    {"verb": "JUMP", "emoji": "🦘", "phrase": "Jump high in the air!", "meaning": "ഉയരത്തിൽ ചാടുക"},
    {"verb": "RUN", "emoji": "🏃", "phrase": "Run fast like the wind!", "meaning": "വേഗത്തിൽ ഓടുക"},
    {"verb": "SING", "emoji": "🎤", "phrase": "Sing a cheerful song!", "meaning": "പാട്ട് പാടുക"},
    {"verb": "DANCE", "emoji": "💃", "phrase": "Dance to the happy rhythm!", "meaning": "നൃത്തം ചെയ്യുക"},
    {"verb": "FLY", "emoji": "🦸", "phrase": "Fly up to the clouds!", "meaning": "ആകാശത്തേക്ക് പറക്കുക"},
    {"verb": "SWIM", "emoji": "🏊", "phrase": "Swim in the cool river!", "meaning": "നദിയിൽ നീന്തുക"},
    {"verb": "CLAP", "emoji": "👏", "phrase": "Clap your hands together!", "meaning": "കൈയടിക്കുക"},
    {"verb": "SLEEP", "emoji": "😴", "phrase": "Sleep under the twinkling stars!", "meaning": "ഉറങ്ങുക"},
  ];

  late List<Map<String, String>> _rounds;
  int _roundIndex = 0;
  List<String> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setup();
  }

  void _setup() {
    final startIdx = ((widget.day - 1) * 2) % _verbs.length;
    _rounds = [
      _verbs[startIdx],
      _verbs[(startIdx + 1) % _verbs.length],
      _verbs[(startIdx + 2) % _verbs.length],
    ];
    _prepare();
  }

  void _prepare() {
    _isAnswered = false;
    final target = _rounds[_roundIndex];
    final others = _verbs.where((v) => v['verb'] != target['verb']).map((v) => v['verb']!).toList()..shuffle();
    _options = [target['verb']!, others[0], others[1]]..shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Show me the action: ${target['phrase']}!");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _choose(String verb) async {
    if (_isAnswered) return;
    final current = _rounds[_roundIndex];
    final correct = verb == current['verb'];

    setState(() => _isAnswered = true);

    if (correct) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      await _tts.speak("Super! ${current['phrase']}");

      Timer(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        if (_roundIndex + 1 < _rounds.length) {
          setState(() {
            _roundIndex++;
            _prepare();
          });
        } else {
          _finish();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Try again!");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 8);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF831843),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF472B6), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦸', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('ACTION HERO MASTER! ⚡', style: GoogleFonts.fredoka(color: const Color(0xFFF472B6), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You mastered power action verbs! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
                  child: const Text('POWER UP! ⚡', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8), // Pastel pink
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACTION VERBS ARENA 🦸', style: GoogleFonts.outfit(color: const Color(0xFFDB2777), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Round ${_roundIndex + 1} of 3', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEC4899), width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(current['emoji']!, style: const TextStyle(fontSize: 60)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      current['phrase']!,
                      style: GoogleFonts.fredoka(color: const Color(0xFF9D174D), fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PocketLanguageService.localize(
                        en: current['phrase'] ?? '',
                        ml: current['meaning'] ?? '',
                      ),
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: _options.map((opt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _choose(opt),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF9A8D4), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: GoogleFonts.outfit(color: const Color(0xFF9D174D), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. 🐸 RHYME TIME LILYPAD FROG HOPPER GAME
// ============================================================================
class PocketKidsRhymeFrogHopperGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsRhymeFrogHopperGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsRhymeFrogHopperGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsRhymeFrogHopperGame> createState() =>
      _PocketKidsRhymeFrogHopperGameState();
}

class _PocketKidsRhymeFrogHopperGameState
    extends State<PocketKidsRhymeFrogHopperGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<Map<String, dynamic>> _rhymes = [
    {"target": "CAT", "rhymes": ["HAT", "BAT", "MAT"], "nonRhymes": ["DOG", "SUN"]},
    {"target": "SUN", "rhymes": ["RUN", "FUN", "BUN"], "nonRhymes": ["CAR", "TREE"]},
    {"target": "CAR", "rhymes": ["STAR", "JAR", "FAR"], "nonRhymes": ["FISH", "BIRD"]},
    {"target": "FISH", "rhymes": ["WISH", "DISH"], "nonRhymes": ["FROG", "LION"]},
    {"target": "BED", "rhymes": ["RED", "FED"], "nonRhymes": ["BLUE", "DUCK"]},
  ];

  late Map<String, dynamic> _current;
  late List<String> _lilypads;
  int _hopCount = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setup();
  }

  void _setup() {
    _current = _rhymes[(widget.day - 1) % _rhymes.length];
    final all = [...(_current['rhymes'] as List<String>), ...(_current['nonRhymes'] as List<String>)]..shuffle();
    _lilypads = all;
    _hopCount = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Help the frog hop on words that rhyme with ${_current['target']}!");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _hopOn(String word) async {
    final rhymes = _current['rhymes'] as List<String>;
    if (rhymes.contains(word)) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      setState(() => _hopCount++);
      await _tts.speak("Ribbit! $word rhymes with ${_current['target']}!");

      if (_hopCount >= 2) {
        _finish();
      }
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Splash! $word does not rhyme. Try another lilypad!");
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 9);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF34D399), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐸', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('RIVER CROSSED! 🌊', style: GoogleFonts.fredoka(color: const Color(0xFF34D399), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You hopped safely across the rhyme river! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('RIBBIT! 🐸', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE), // Soft water blue
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RHYME TIME LILYPAD HOPPER 🐸', style: GoogleFonts.outfit(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Target: Rhymes with ${_current['target']}!', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🐸', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 10),
                    Text(
                      'Hop on words that rhyme with "${_current['target']}"',
                      style: GoogleFonts.fredoka(color: const Color(0xFF0369A1), fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: _lilypads.map((w) {
                        return GestureDetector(
                          onTap: () => _hopOn(w),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF047857), width: 3),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              w,
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. ⚖️ OPPOSITES SEESAW BALANCE SCALE GAME
// ============================================================================
class PocketKidsOppositesSeesawGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsOppositesSeesawGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsOppositesSeesawGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsOppositesSeesawGame> createState() =>
      _PocketKidsOppositesSeesawGameState();
}

class _PocketKidsOppositesSeesawGameState
    extends State<PocketKidsOppositesSeesawGame> {
  final FlutterTts _tts = FlutterTts();

  static const List<Map<String, String>> _pairs = [
    {"word": "BIG", "opposite": "SMALL", "wordEmoji": "🐘", "oppEmoji": "🐭", "meaning": "വലുതും ചെറുതും"},
    {"word": "HOT", "opposite": "COLD", "wordEmoji": "🔥", "oppEmoji": "❄️", "meaning": "ചൂടും തണുപ്പും"},
    {"word": "FAST", "opposite": "SLOW", "wordEmoji": "🐆", "oppEmoji": "🐢", "meaning": "വേഗവും വേഗക്കുറവും"},
    {"word": "UP", "opposite": "DOWN", "wordEmoji": "🎈", "oppEmoji": "⚓", "meaning": "മുകളിലും താഴെയും"},
    {"word": "HAPPY", "opposite": "SAD", "wordEmoji": "😄", "oppEmoji": "😢", "meaning": "സന്തോഷവും സങ്കടവും"},
  ];

  late Map<String, String> _current;
  late List<String> _options;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setup();
  }

  void _setup() {
    _current = _pairs[(widget.day - 1) % _pairs.length];
    final others = _pairs.where((p) => p['opposite'] != _current['opposite']).map((p) => p['opposite']!).toList()..shuffle();
    _options = [_current['opposite']!, others[0], others[1]]..shuffle();
    _isAnswered = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("What is the opposite of ${_current['word']}?");
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.4);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _pick(String opp) async {
    if (_isAnswered) return;
    final isCorrect = opp == _current['opposite'];
    setState(() => _isAnswered = true);

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      await _tts.speak("Balanced! The opposite of ${_current['word']} is ${_current['opposite']}!");

      Timer(const Duration(milliseconds: 1400), () {
        _finish();
      });
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Think again!");
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
  }

  void _finish() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    await PocketKidsService.addKidsScore(20);
    await PocketKidsService.addStars(1);
    await PocketKidsService.markDayStepCompleted(widget.day, 10);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚖️', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('SEESAW BALANCED! ⚖️', style: GoogleFonts.fredoka(color: const Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You know your opposites! +20 KS ⭐', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                  child: const Text('GREAT! ⚖️', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OPPOSITES SEESAW ⚖️', style: GoogleFonts.outfit(color: const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('What is the opposite?', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(_current['wordEmoji']!, style: const TextStyle(fontSize: 48)),
                              const SizedBox(height: 8),
                              Text(_current['word']!, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 18)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                          ),
                          child: Column(
                            children: [
                              const Text('❓', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 8),
                              Text('Opposite', style: GoogleFonts.outfit(fontSize: 18, color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: _options.map((opt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _pick(opt),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF94A3B8), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: GoogleFonts.outfit(color: const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
