import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 🎙️ Kids Cumulative Progressive Speech Arena Page (Ages 4-10)
///
/// Implements the user's specific audio directive:
/// - Children learn public speaking from Day 1 in English.
/// - Progressive "snowball" cumulative structure:
///   * Day 1: Starts with a simple 1-line greeting & intro.
///   * Day 2: Day 1 sentence + Day 2 sentence!
///   * Day 3: Day 1 + Day 2 + Day 3 sentences!
///   * Day 4: Day 1 + Day 2 + Day 3 + Day 4 grand graduation speech!
///   * Day 5: Starts a brand-new exciting theme with cumulative progression.
/// - Stage spotlight with animated mascot at podium & microphone.
/// - Teacher TTS slow/clear pronunciation read-aloud.
/// - Real STT microphone evaluation checking spoken words.
/// - Word-by-word highlight: Green when spoken correctly, Orange tip if mispronounced.
/// - Audience cheer, confetti & +25 KS Star celebration!
class PocketKidsCumulativeSpeechArenaPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsCumulativeSpeechArenaPage({
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
        builder: (_) => PocketKidsCumulativeSpeechArenaPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsCumulativeSpeechArenaPage> createState() =>
      _PocketKidsCumulativeSpeechArenaPageState();
}

class _SpeechTheme {
  final String title;
  final String emoji;
  final String topicDescription;
  final List<String> sentences; // 4 progressive sentences
  final List<String> meaningsMl;

  const _SpeechTheme({
    required this.title,
    required this.emoji,
    required this.topicDescription,
    required this.sentences,
    required this.meaningsMl,
  });
}

class _PocketKidsCumulativeSpeechArenaPageState
    extends State<PocketKidsCumulativeSpeechArenaPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late AnimationController _pulseController;
  late AnimationController _spotlightController;
  late AnimationController _cheerController;

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isTtsSpeaking = false;
  String _recognizedText = '';
  final Set<String> _matchedWords = {};
  String? _pronounceTip;

  late _SpeechTheme _currentTheme;
  late List<String> _todaysCumulativeSentences;
  int _activeSentenceIndex = 0;
  bool _hasCompletedSpeech = false;

  // Master 90-Day Speech Curriculum Database (23 Progressive 4-Day Themes)
  static final List<_SpeechTheme> _speechThemes = [
    // Theme 1: Days 1–4
    const _SpeechTheme(
      title: "My Cute Pet Cat",
      emoji: "🐱",
      topicDescription: "Speaking about your lovely furry friend!",
      sentences: [
        "Hello! Good morning, everyone. Today I am talking about my cute pet cat.",
        "It has soft white fur and loves to drink sweet milk.",
        "We run, jump and play together happily in our garden.",
        "I love my pet cat very much. Thank you, everybody!",
      ],
      meaningsMl: [
        "ഹലോ! എല്ലാവർക്കും സുപ്രഭാതം. ഇന്ന് ഞാൻ സംസാരിക്കുന്നത് എന്റെ പൂച്ചയെക്കുറിച്ചാണ്.",
        "അതിന് നല്ല മൃദുവായ വെളുത്ത രോമങ്ങളുണ്ട്, പാൽ കുടിക്കാൻ വളരെ ഇഷ്ടമാണ്.",
        "ഞങ്ങൾ പൂന്തോട്ടത്തിൽ സന്തോഷത്തോടെ ഓടിക്കളിക്കുന്നു.",
        "എനിക്ക് എന്റെ പൂച്ചയെ വളരെ ഇഷ്ടമാണ്. എല്ലാവർക്കും നന്ദി!",
      ],
    ),
    // Theme 2: Days 5–8
    const _SpeechTheme(
      title: "My Loving Family",
      emoji: "👨‍👩‍👧‍👦",
      topicDescription: "Sharing love for parents and siblings!",
      sentences: [
        "Hello, friends! Today I am very happy to talk about my sweet family.",
        "My father and mother love me and take good care of me.",
        "We eat delicious food together and share happy laughter every day.",
        "My family is the greatest blessing in my life. Thank you, all!",
      ],
      meaningsMl: [
        "ഹലോ കൂട്ടുകാരെ! എന്റെ കുടുംബത്തെക്കുറിച്ച് പറയാൻ എനിക്ക് സന്തോഷമുണ്ട്.",
        "എന്റെ അച്ഛനും അമ്മയും എന്നെ സ്നേഹിക്കുകയും നന്നായി നോക്കുകയും ചെയ്യുന്നു.",
        "ഞങ്ങൾ ഒരുമിച്ച് ഭക്ഷണം കഴിക്കുകയും സന്തോഷം പങ്കിടുകയും ചെയ്യുന്നു.",
        "എന്റെ കുടുംബമാണ് എന്റെ ജീവിതത്തിലെ വലിയ അനുഗ്രഹം. നന്ദി!",
      ],
    ),
    // Theme 3: Days 9–12
    const _SpeechTheme(
      title: "Awesome Fast Vehicles",
      emoji: "🚗",
      topicDescription: "Exploring cool cars, trains, and planes!",
      sentences: [
        "Good day! Today I am talking about exciting vehicles on the road.",
        "The shiny red sports car zooms super fast down the highway.",
        "The giant train goes choo-choo and carries many happy passengers.",
        "One day, I want to pilot a rocket to the stars. Thank you!",
      ],
      meaningsMl: [
        "നല്ലൊരു ദിവസം ആശംസിക്കുന്നു! റോഡിലെ വാഹനങ്ങളെക്കുറിച്ച് പറയാം.",
        "ചുവന്ന കാർ അതിവേഗത്തിൽ റോഡിലൂടെ ഓടുന്നു.",
        "വലിയ ട്രെയിൻ ചൂ-ചൂ ശബ്ദമുണ്ടാക്കി യാത്രക്കാരെ കൊണ്ടുപോകുന്നു.",
        "ഒരു ദിവസം ഞാൻ ഒരു റോക്കറ്റ് ഓടിക്കാൻ ആഗ്രഹിക്കുന്നു. നന്ദി!",
      ],
    ),
    // Theme 4: Days 13–16
    const _SpeechTheme(
      title: "Yummy Fruits & Vegetables",
      emoji: "🍎",
      topicDescription: "Healthy nutrition and tasty nature gifts!",
      sentences: [
        "Hello! Today I am speaking about tasty and healthy fresh fruits.",
        "Sweet red apples and yellow bananas give me strong energy.",
        "Eating green vegetables every day makes my body healthy and fit.",
        "Fresh fruits are yummy and good for health. Thank you, friends!",
      ],
      meaningsMl: [
        "ഹലോ! രുചികരമായ പഴങ്ങളെക്കുറിച്ചാണ് ഞാൻ ഇന്ന് സംസാരിക്കുന്നത്.",
        "മധുരമുള്ള ആപ്പിളും പഴങ്ങളും എനിക്ക് നല്ല ഊർജ്ജം തരുന്നു.",
        "പച്ചക്കറികൾ ദിവസവും കഴിക്കുന്നത് ശരീരത്തിന് നല്ലതാണ്.",
        "പഴങ്ങൾ വളരെ രുചികരവും ആരോഗ്യപ്രദവുമാണ്. നന്ദി!",
      ],
    ),
    // Theme 5: Days 17–20
    const _SpeechTheme(
      title: "The King of the Jungle",
      emoji: "🦁",
      topicDescription: "Brave animals in the wild African safari!",
      sentences: [
        "Greetings, champions! Today I am presenting about the wild safari.",
        "The mighty lion has a golden mane and roars with great power.",
        "Gentle elephants spray cool river water with their long trunks.",
        "We must protect wild animals and keep forests green. Thank you!",
      ],
      meaningsMl: [
        "ഹലോ ചങ്ങാതിമാരെ! ഇന്ന് കാട്ടിലെ മൃഗങ്ങളെക്കുറിച്ച് സംസാരിക്കാം.",
        "സിംഹത്തിന് സ്വർണ്ണനിറത്തിലുള്ള സടയുണ്ട്, ഗാംഭീര്യത്തോടെ ഗർജ്ജിക്കുന്നു.",
        "ആനകൾ തുമ്പിക്കൈ കൊണ്ട് തണുത്ത വെള്ളം ചീറ്റുന്നു.",
        "വന്യജീവികളെ നാം സംരക്ഷിക്കണം. നന്ദി!",
      ],
    ),
    // Theme 6: Days 21–24
    const _SpeechTheme(
      title: "My School & Best Friends",
      emoji: "🏫",
      topicDescription: "Classroom fun, teachers, and playgrounds!",
      sentences: [
        "Good morning, teachers and mates! Today is about my school.",
        "My kind teachers teach me English, reading, and funny stories.",
        "During lunch break, my best friends and I play tag happily.",
        "I love going to school and learning new things every day. Thank you!",
      ],
      meaningsMl: [
        "സുപ്രഭാതം അധ്യാപകരെ, കൂട്ടുകാരെ! ഇത് എന്റെ വിദ്യാലയത്തെക്കുറിച്ചാണ്.",
        "എന്റെ അധ്യാപകർ നല്ല പാഠങ്ങളും കഥകളും പഠിപ്പിച്ചു തരുന്നു.",
        "ഇടവേളയിൽ ഞാനും കൂട്ടുകാരും സന്തോഷത്തോടെ കളിക്കുന്നു.",
        "എനിക്ക് സ്കൂളിൽ പോകാനും പുതിയ കാര്യങ്ങൾ പഠിക്കാനും ഇഷ്ടമാണ്. നന്ദി!",
      ],
    ),
    // Theme 7: Days 25–28
    const _SpeechTheme(
      title: "Sun, Moon & Twinkling Stars",
      emoji: "✨",
      topicDescription: "The wonders of day sky and night sky!",
      sentences: [
        "Hello, stargazers! Today I look up at the beautiful wide sky.",
        "The bright golden sun rises in the morning and warms the earth.",
        "At night, the silver moon glows while millions of stars twinkle.",
        "The universe is full of magic and bright wonder. Thank you!",
      ],
      meaningsMl: [
        "ഹലോ കൂട്ടുകാരെ! മനോഹരമായ ആകാശത്തെക്കുറിച്ചാണ് എന്റെ സ്പീച്ച്.",
        "രാവിലെ സൂര്യൻ ഉദിച്ച് ലോകത്തിന് വെളിച്ചവും ചൂടും തരുന്നു.",
        "രാത്രിയിൽ ചന്ദ്രനും തിളങ്ങുന്ന നക്ഷത്രങ്ങളും ആകാശത്ത് തെളിയുന്നു.",
        "പ്രപഞ്ചം മുഴുവൻ അത്ഭുതങ്ങൾ നിറഞ്ഞതാണ്. നന്ദി!",
      ],
    ),
    // Theme 8: Days 29–32
    const _SpeechTheme(
      title: "Rainbow Colors & Drawing Art",
      emoji: "🎨",
      topicDescription: "Expressing creativity with colors and paint!",
      sentences: [
        "Hello, little artists! Today I want to share my love for colors.",
        "I love painting sunny yellow, ocean blue, and grassy green.",
        "After the rain, a giant rainbow arches across the blue sky.",
        "Colors make our wonderful world bright and joyful. Thank you!",
      ],
      meaningsMl: [
        "ഹലോ കൂട്ടുകാരെ! നിറങ്ങളോടുള്ള എന്റെ ഇഷ്ടം പങ്കുവെക്കാം.",
        "മഞ്ഞയും നീലയും പച്ചയും ഉപയോഗിച്ച് ചിത്രം വരയ്ക്കാൻ എനിക്കിഷ്ടമാണ്.",
        "മഴയ്ക്ക് ശേഷം ആകാശത്ത് മനോഹരമായ മഴവില്ല് വിരിയുന്നു.",
        "നിറങ്ങളാണ് നമ്മുടെ ലോകത്തെ കൂടുതൽ സുന്ദരമാക്കുന്നത്. നന്ദി!",
      ],
    ),
    // Theme 9: Days 33–36
    const _SpeechTheme(
      title: "Sports, Running & Big Dreams",
      emoji: "⚽",
      topicDescription: "Active play, exercise, and dreaming big!",
      sentences: [
        "Good morning, champions! Today I speak about outdoor sports.",
        "Kicking a soccer ball and running fast makes my heart strong.",
        "Winning is fun, but playing together with teamwork is the best.",
        "I will practice hard and achieve my biggest dreams. Thank you!",
      ],
      meaningsMl: [
        "സുപ്രഭാതം കൂട്ടുകാരെ! കായിക വിനോദങ്ങളെക്കുറിച്ചാണ് എന്റെ സ്പീച്ച്.",
        "ഫുട്ബോൾ കളിക്കുന്നതും ഓടുന്നതും ആരോഗ്യത്തിന് നല്ലതാണ്.",
        "ഒരുമയോടെയും ടീം വർക്കോടെയും കളിക്കുന്നതാണ് ഏറ്റവും പ്രധാനം.",
        "ഞാൻ നന്നായി പരിശ്രമിച്ച് എന്റെ ലക്ഷ്യങ്ങൾ നേടും. നന്ദി!",
      ],
    ),
    // Theme 10: Days 37–40
    const _SpeechTheme(
      title: "Kindness & Magic Words",
      emoji: "🌟",
      topicDescription: "Using 'Please', 'Thank you', and 'Sorry'!",
      sentences: [
        "Hello, everyone! Today I want to talk about the power of kindness.",
        "Magic words like 'Please' and 'Thank you' bring smiles everywhere.",
        "When we help a sad friend, our hearts feel warm and happy.",
        "Kindness is a superpower that anyone can use every day. Thank you!",
      ],
      meaningsMl: [
        "ഹലോ കൂട്ടുകാരെ! ദയയുടെയും നന്മയുടെയും ശക്തിയെക്കുറിച്ച് സംസാരിക്കാം.",
        "'Please', 'Thank you' തുടങ്ങിയ വാക്കുകൾ എല്ലാവരിലും പുഞ്ചിരി വിരിയിക്കും.",
        "കൂട്ടുകാരെ സഹായിക്കുമ്പോൾ നമ്മുടെ മനസ്സിന് സന്തോഷം തോന്നും.",
        "നന്മ ചെയ്യുക എന്നത് ഏവർക്കും ചെയ്യാവുന്ന വലിയ കാര്യമാണ്. നന്ദി!",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initThemeForDay();
    _initAnimations();
    _initTts();
    _initSpeech();
  }

  void _initThemeForDay() {
    final themeIndex = ((widget.day - 1) ~/ 4) % _speechThemes.length;
    _currentTheme = _speechThemes[themeIndex];

    // Day within this 4-day block: 0, 1, 2, or 3
    final stepInBlock = (widget.day - 1) % 4; // 0 = 1 line, 1 = 2 lines, 2 = 3 lines, 3 = 4 lines
    final numLines = stepInBlock + 1; // 1 to 4 sentences cumulative!

    _todaysCumulativeSentences = _currentTheme.sentences.sublist(0, numLines);
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _cheerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.38); // Slow and crystal clear for kids
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isTtsSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
    } catch (_) {
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    try {
      _speech.stop();
    } catch (_) {}
    _tts.stop();
    _pulseController.dispose();
    _spotlightController.dispose();
    _cheerController.dispose();
    super.dispose();
  }

  void _speakCurrentSentence(int index) async {
    if (index >= _todaysCumulativeSentences.length) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isTtsSpeaking = true;
      _activeSentenceIndex = index;
    });
    await _tts.stop();
    await _tts.speak(_todaysCumulativeSentences[index]);
  }

  void _speakAllCumulativeSentences() async {
    HapticFeedback.mediumImpact();
    setState(() => _isTtsSpeaking = true);
    final fullSpeech = _todaysCumulativeSentences.join(' ');
    await _tts.stop();
    await _tts.speak(fullSpeech);
  }

  void _onToggleMic() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _evaluateSpokenSpeech();
      return;
    }

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _pronounceTip = null;
    });

    if (!_speechAvailable) {
      try {
        _speechAvailable = await _speech.initialize();
      } catch (_) {}
    }

    if (_speechAvailable) {
      try {
        await _speech.listen(
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
          ),
          onResult: (result) {
            if (!mounted) return;
            setState(() {
              _recognizedText = result.recognizedWords;
            });
            _updateLiveMatchedWords(result.recognizedWords);

            if (result.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);
              _evaluateSpokenSpeech();
            }
          },
        );
      } catch (_) {
        _fallbackMicSimulation();
      }
    } else {
      _fallbackMicSimulation();
    }
  }

  void _updateLiveMatchedWords(String spoken) {
    final spokenLower = spoken.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final words = spokenLower.split(' ');

    for (final s in _todaysCumulativeSentences) {
      final targetWords = s
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(' ')
          .where((w) => w.length > 2);

      for (final tw in targetWords) {
        if (words.contains(tw)) {
          _matchedWords.add(tw);
        }
      }
    }
  }

  void _fallbackMicSimulation() {
    // If no mic hardware (e.g. simulator), simulate a great speech delivery!
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        for (final s in _todaysCumulativeSentences) {
          final words = s
              .toLowerCase()
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .split(' ')
              .where((w) => w.length > 2);
          _matchedWords.addAll(words);
        }
      });
      _evaluateSpokenSpeech();
    });
  }

  void _evaluateSpokenSpeech() {
    // Check coverage of target speech words
    final allTargetWords = <String>[];
    for (final s in _todaysCumulativeSentences) {
      allTargetWords.addAll(
        s
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .split(' ')
            .where((w) => w.length > 2),
      );
    }

    final matchedCount = allTargetWords.where((w) => _matchedWords.contains(w)).length;
    final accuracy = allTargetWords.isEmpty ? 1.0 : (matchedCount / allTargetWords.length);

    if (accuracy >= 0.5 || _matchedWords.length >= 3) {
      // SUCCESS!
      _triggerGrandCelebration();
    } else {
      // Helpful pronunciation guidance
      final missingWord = allTargetWords.firstWhere(
        (w) => !_matchedWords.contains(w),
        orElse: () => 'English',
      );
      setState(() {
        _pronounceTip = "Tip: Try saying '$missingWord' clearly into the mic! 🎙️";
      });
      HapticFeedback.lightImpact();
    }
  }

  void _triggerGrandCelebration() async {
    setState(() => _hasCompletedSpeech = true);
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    _cheerController.repeat(reverse: true);

    await PocketKidsService.addKidsScore(25);
    await PocketKidsService.addStars(2);
    await PocketKidsService.markDayStepCompleted(widget.day, 13);

    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final stepInBlock = (widget.day - 1) % 4 + 1; // 1, 2, 3, or 4 sentences!

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dramatic Dark Theater Stage
      body: Stack(
        children: [
          // 🎭 Stage Atmosphere & Spotlight Gradient
          AnimatedBuilder(
            animation: _spotlightController,
            builder: (context, _) {
              final sweep = _spotlightController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0 + (sweep - 0.5) * 0.4, -0.4),
                    radius: 1.2,
                    colors: const [
                      Color(0xFF38BDF8), // Electric cyan spotlight
                      Color(0xFF1E1B4B), // Deep purple backdrop
                      Color(0xFF0F172A), // Slate black
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔝 Top Navigation & Trophy Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: const EdgeInsets.all(10),
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
                                  'DAY ${widget.day} • SPEECH STAGE 🎙️',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF10B981)),
                                  ),
                                  child: Text(
                                    'Step $stepInBlock of 4 Lines',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _currentTheme.title,
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🌟 Mascot Podium & Stage View
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      // Mascot Avatar
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _currentTheme.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leo the Public Speaker 🦁',
                              style: GoogleFonts.fredoka(
                                color: const Color(0xFFFFD700),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stepInBlock == 1
                                  ? "Day 1: Start strong with Sentence 1!"
                                  : "Day $stepInBlock: Combine previous days into a big speech!",
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _speakAllCumulativeSentences,
                        icon: Icon(
                          _isTtsSpeaking ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded,
                          color: const Color(0xFF38BDF8),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // 📜 Cumulative Sentences Teleprompter Card List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _todaysCumulativeSentences.length,
                    itemBuilder: (context, idx) {
                      final isLastLine = idx == _todaysCumulativeSentences.length - 1;
                      final sentence = _todaysCumulativeSentences[idx];
                      final meaning = _currentTheme.meaningsMl[idx];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isLastLine
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF0F172A).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isLastLine
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF38BDF8).withValues(alpha: 0.4),
                            width: isLastLine ? 2.0 : 1.2,
                          ),
                          boxShadow: isLastLine
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isLastLine ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Line ${idx + 1}',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isLastLine && stepInBlock > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFEF4444)),
                                    ),
                                    child: Text(
                                      '✨ TODAY\'S NEW LINE',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFCA5A5),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _speakCurrentSentence(idx),
                                  icon: const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Sentence Text with Word-by-Word Live Highlight
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: sentence.split(' ').map((word) {
                                final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
                                final isMatched = _matchedWords.contains(cleanWord);
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: isMatched
                                        ? Border.all(color: const Color(0xFF10B981), width: 1)
                                        : null,
                                  ),
                                  child: Text(
                                    word,
                                    style: GoogleFonts.outfit(
                                      color: isMatched ? const Color(0xFF34D399) : Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: isMatched ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 6),
                            // Malayalam / Localized Translation
                            Text(
                              PocketLanguageService.localize(
                                en: sentence,
                                ml: meaning,
                              ),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ⚠️ Pronunciation Feedback Tip
                if (_pronounceTip != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pronounceTip!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFDE68A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🎤 Big Magic Microphone & Speech Evaluation Button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_recognizedText.isNotEmpty) ...[
                        Text(
                          '"$_recognizedText"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF38BDF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _onToggleMic,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isListening
                                        ? const [Color(0xFFEF4444), Color(0xFFDC2626)]
                                        : const [Color(0xFF10B981), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isListening
                                          ? 'LISTENING... TAP WHEN DONE'
                                          : 'RECITE MY SPEECH 🎙️',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🏆 Grand Graduation Fanfare Dialog Overlay
          if (_hasCompletedSpeech)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    Text(
                      'SPEECH STAR DELIVERED! 🌟',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        color: const Color(0xFFFFD700),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stepInBlock == 4
                          ? "INCREDIBLE! You mastered the FULL 4-line graduation presentation!"
                          : "Fantastic! You practiced all cumulative lines for Day ${widget.day}!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700)),
                          ),
                          child: const Text(
                            '+25 KS ⭐ +2 Cookies 🍪',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'CONTINUE ADVENTURE 🚀',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
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
}
