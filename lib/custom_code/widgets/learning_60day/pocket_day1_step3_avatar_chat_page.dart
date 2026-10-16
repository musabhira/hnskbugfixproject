import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_speech_normalizer.dart';
import 'games/meadow_runner_game_page.dart';
import 'games/pocket_20days_40games_spec.dart';
import 'games/pocket_universal_arcade_engine_page.dart';
import 'games/english_realm/english_realm_manifest.dart';
import 'pocket_90day_vocab_curriculum.dart';

/// 💬 Chat message model for Step 3 Word & Letter Hunt
class Step3ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final List<Step3InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final Widget? cardContent;
  final bool isVoiceMessage;

  Step3ChatMessage({
    required this.id,
    required this.isAvatar,
    required this.textEn,
    this.textNative,
    this.audioText,
    this.inBubbleOptions,
    this.speakThisPrompt,
    this.cardContent,
    this.isVoiceMessage = false,
  });
}

class Step3InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  Step3InBubbleOption({
    required this.labelEn,
    required this.labelNative,
    required this.icon,
    this.backgroundColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlightedAnswer = false,
    required this.onTap,
  });
}

/// 🔍 Step 3: Conversational Avatar Chat for Letter & Word Hunt
class PocketDay1Step3AvatarChatPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step3AvatarChatPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDay1Step3AvatarChatPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step3AvatarChatPage> createState() =>
      _PocketDay1Step3AvatarChatPageState();
}

class _PocketDay1Step3AvatarChatPageState
    extends State<PocketDay1Step3AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;

  final List<Step3ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _liveRecordedWords = '';

  String _userName = 'Hira';
  String _currentExpectedVoicePhrase = 'Yes';
  int _currentHuntRound = 0; // 0 to 5 for 6 rounds

  /// 🔍 90-Day Progressive Letter & Word Hunt Rounds (User Audio Directive!)
  static List<Map<String, dynamic>> getHuntRoundsForDay(int day) {
    if (day == 1) {
      return const [
        {
          'target': 'M',
          'emoji': '🎵',
          'promptEn': 'Find Letter M! 🎵',
          'promptMl': 'അക്ഷരം M കണ്ടെത്തുക!',
          'options': ['N 🎶', 'M 🎵', 'P 🎨', 'Q 👑'],
          'correct': 'M',
          'clue': 'Letter M for Music',
        },
        {
          'target': 'Bed',
          'emoji': '🛏️',
          'promptEn': 'Find the word: Bed 🛏️',
          'promptMl': 'Bed (കിടക്ക) കണ്ടെത്തുക!',
          'options': ['Box 📦', 'Bed 🛏️', 'Ring 💍', 'Key 🗝️'],
          'correct': 'Bed',
          'clue': 'A soft place where you sleep tonight',
        },
        {
          'target': 'Cup',
          'emoji': '☕',
          'promptEn': 'Find the word: Cup ☕',
          'promptMl': 'Cup (കപ്പ്) കണ്ടെത്തുക!',
          'options': ['Cup ☕', 'Bell 🔔', 'Fan 🪭', 'Boat ⛵'],
          'correct': 'Cup',
          'clue': 'Small container for tea or coffee',
        },
        {
          'target': 'Shoe',
          'emoji': '👟',
          'promptEn': 'Find the word: Shoe 👟',
          'promptMl': 'Shoe (ഷൂ) കണ്ടെത്തുക!',
          'options': ['Lamp 💡', 'Shoe 👟', 'Lock 🔒', 'Coin 🪙'],
          'correct': 'Shoe',
          'clue': 'Comfortable footwear worn on feet',
        },
        {
          'target': 'Train',
          'emoji': '🚆',
          'promptEn': 'Find the word: Train 🚆',
          'promptMl': 'Train (ട്രെയിൻ) കണ്ടെത്തുക!',
          'options': ['Ship 🚢', 'Train 🚆', 'Bus 🚌', 'Plane ✈️'],
          'correct': 'Train',
          'clue': 'Long rail vehicle that travels fast on tracks',
        },
        {
          'target': 'Bag',
          'emoji': '🎒',
          'promptEn': 'Find the word: Bag 🎒',
          'promptMl': 'Bag (ബാഗ്) കണ്ടെത്തുക!',
          'options': ['Bag 🎒', 'Cap 🧢', 'Pot 🏺', 'Flag 🚩'],
          'correct': 'Bag',
          'clue': 'Item used to carry books and belongings',
        },
      ];
    }

    // 🌟 Days 2 to 90: Dedicated unique sentence & grammar challenges from EnglishRealmManifest (Zero duplicates!)
    if (day > 1) {
      try {
        final realmGames = EnglishRealmManifest.getGamesForDay(day);
        if (realmGames.isNotEmpty && realmGames.first.rounds.isNotEmpty) {
          final realmRounds = realmGames.first.rounds;
          final List<Map<String, dynamic>> list = [];
          final emojis = ['🎯', '✨', '🔥', '🌟', '💎', '🚀', '⚡', '🏆', '🧩', '🌲', '🚂', '🚗'];
          for (int i = 0; i < realmRounds.length && i < 6; i++) {
            final r = realmRounds[i];
            String correct = '';
            if (r.solution is int &&
                (r.solution as int) >= 0 &&
                (r.solution as int) < r.options.length) {
              correct = r.options[r.solution as int];
            } else if (r.solution is String) {
              correct = r.solution as String;
            } else if (r.options.isNotEmpty) {
              correct = r.options.first;
            }

            final e = emojis[(i + day) % emojis.length];
            final shuffledOpts = List<String>.from(r.options)..shuffle();
            list.add({
              'target': correct,
              'emoji': e,
              'promptEn': r.promptEn,
              'promptMl': r.promptMl,
              'options': shuffledOpts,
              'correct': correct,
              'clue': r.explanationEn,
            });
          }
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }

    // Days 2 to 90 Fallback: Synthesized curriculum rounds
    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final emojis = ['⭐', '💎', '🚀', '🌟', '🏆', '🎯', '⚡', '🔥', '📚', '✨', '🌈', '💡', '🛡️', '🔑'];
    final rounds = <Map<String, dynamic>>[];

    for (int i = 0; i < 6 && i < vocab.length; i++) {
      final item = vocab[i];
      final e = emojis[(i + day) % emojis.length];
      final distractor1 = vocab[(i + 2) % vocab.length].word;
      final distractor2 = vocab[(i + 4) % vocab.length].word;
      final distractor3 = vocab[(i + 6) % vocab.length].word;

      rounds.add({
        'target': item.word,
        'emoji': e,
        'promptEn': 'Find the phrase for: ${item.word} $e',
        'promptMl': '${item.word} (${item.malayalamMeaning}) കണ്ടെത്തുക!',
        'options': [
          '${item.word} $e',
          '$distractor1 ${emojis[(i + 1) % emojis.length]}',
          '$distractor2 ${emojis[(i + 2) % emojis.length]}',
          '$distractor3 ${emojis[(i + 3) % emojis.length]}',
        ]..shuffle(),
        'correct': item.word,
        'clue': item.exampleSentence.isNotEmpty ? item.exampleSentence : item.definition,
      });
    }

    return rounds;
  }

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initAudioEngines();
    _loadUserData();

    // 🎵 Start pleasant ambient BGM immediately as requested
    PocketGameAudioService.instance.playAmbientAppTheme();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWelcomeHuntFlow();
    });
  }

  void _initAnimationControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _micWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  Future<void> _initAudioEngines() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.05);

      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}

    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_display_name') ?? 'Hira';
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _micWaveController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
    // Smooth micro catch-up after layout pass to eliminate sudden jumps
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      if ((max - current).abs() > 4) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // =========================================================================
  // 🔍 CONVERSATIONAL FLOW
  // =========================================================================

  void _startWelcomeHuntFlow() {
    final gameSpec = Pocket20Days40GamesRegistry.allGames.firstWhere(
      (g) => g.day == widget.day && g.gameIndex == 1,
      orElse: () => DayGameSpec(
        day: widget.day,
        gameIndex: 1,
        title: 'Day ${widget.day} English Quest',
        emoji: '🎮',
        genre: GameGenre.runner,
        englishTarget: 'Sentence Structure & Spoken English',
        descriptionEn: 'Interactive action gaming applied to English mastery.',
        descriptionMl: 'ഗെയിം കളിച്ചുകൊണ്ട് ഇംഗ്ലീഷ് പഠിക്കുക.',
        controlMechanism: 'Touch controls',
      ),
    );

    final isDay1 = widget.day == 1;
    final promptEn = isDay1
        ? 'Hi $_userName! Welcome to Day 1 Step 3: Phonics & Letter Hunt! 🔍\n\n'
            'Would you like to hunt words in this chat or explore the open 2D Meadow Runner game? 🌳'
        : 'Hi $_userName! Welcome to Day ${widget.day} Step 3: ${gameSpec.title} ${gameSpec.emoji}!\n\n'
            'Today\'s Focus: ${gameSpec.englishTarget}.\n\n'
            'How would you like to master today\'s topic?\n'
            '• 🎮 2D Action Arcade: ${gameSpec.title}\n'
            '• 💬 Sentence & Grammar Challenge in chat!';

    final promptMl = isDay1
        ? 'ഹായ് $_userName! ഡേ 1 സ്റ്റെപ്പ് 3-ലേക്ക് സ്വാഗതം! നമുക്ക് വാക്കുകളും അക്ഷരങ്ങളും വേട്ടയാടി കണ്ടെത്താം!\n\n'
            'ഇവിടെ ചാറ്റിൽ കളിക്കണോ അതോ 2D മെഡോ റണ്ണർ ഗെയിമിലേക്ക് പോകണോ? 🌿'
        : 'ഹായ് $_userName! ഡേ ${widget.day} സ്റ്റെപ്പ് 3: ${gameSpec.title} ${gameSpec.emoji}-ലേക്ക് സ്വാഗതം!\n\n'
            'ഇന്നത്തെ വിഷയം: ${gameSpec.englishTarget}.\n\n'
            'ഇഷ്ടമുള്ള രീതി തെരഞ്ഞെടുക്കൂ:\n'
            '• 🎮 2D ഗെയിം: ${gameSpec.title}\n'
            '• 💬 വാക്യ നിർമ്മാണ ചാറ്റ് ചലഞ്ച്!';

    _currentExpectedVoicePhrase = isDay1 ? 'Chat Hunt or Meadow Game' : gameSpec.title;

    setState(() {
      _messages.clear();
      _messages.add(
        Step3ChatMessage(
          id: 'welcome_hunt',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: isDay1
              ? 'Hi $_userName! Welcome to Day 1 Step 3: Phonics and Letter Hunt! Let\'s find hidden words!'
              : 'Hi $_userName! Welcome to Day ${widget.day} Step 3: ${gameSpec.title}! Let\'s master ${gameSpec.englishTarget}!',
          speakThisPrompt: 'Choose how to train:',
          inBubbleOptions: [
            Step3InBubbleOption(
              labelEn: isDay1
                  ? '🔍 CHAT HUNT CHALLENGE'
                  : '💬 SENTENCE CHALLENGE 🧩',
              labelNative: isDay1 ? 'ചാറ്റിൽ വേട്ടയാടാം! 💬' : 'ചാറ്റിൽ വാക്യങ്ങൾ നിർമ്മിക്കാം! 💬',
              icon: isDay1 ? '🔍' : '🧩',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF0284C7),
              borderColor: const Color(0xFF38BDF8),
              textColor: Colors.white,
              onTap: () => _handleTextSubmission(
                text: isDay1 ? '🔍 CHAT HUNT CHALLENGE' : '💬 SENTENCE CHALLENGE 🧩',
                action: _startChatHuntRounds,
              ),
            ),
            Step3InBubbleOption(
              labelEn: isDay1
                  ? '🌳 2D MEADOW RUNNER GAME'
                  : '🎮 PLAY 2D ${gameSpec.title.toUpperCase()} ${gameSpec.emoji}',
              labelNative: isDay1 ? 'മെഡോ ഗെയിം കളിക്കാം! 🕹️' : '${gameSpec.title} 2D ഗെയിം! 🕹️',
              icon: gameSpec.emoji,
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleTextSubmission(
                text: isDay1
                    ? '🌳 2D MEADOW RUNNER GAME'
                    : '🎮 PLAY 2D ${gameSpec.title.toUpperCase()} ${gameSpec.emoji}',
                action: _launchDedicated2DGame,
              ),
            ),
          ],
        ),
      );
    });

    _speak(isDay1
        ? 'Hi $_userName! Welcome to Day 1 Step 3: Phonics and Letter Hunt! Let\'s find hidden words!'
        : 'Hi $_userName! Welcome to Day ${widget.day} Step 3: ${gameSpec.title}!');
    _scrollToBottom();
  }

  void _startChatHuntRounds() {
    _currentHuntRound = 0;
    _sendNextHuntQuestion();
  }

  void _sendNextHuntQuestion() {
    final activeRounds = getHuntRoundsForDay(widget.day);
    if (_currentHuntRound >= activeRounds.length) {
      _showHuntCompletedDialogue();
      return;
    }

    final roundData = activeRounds[_currentHuntRound];
    final target = roundData['target'] as String;
    final emoji = roundData['emoji'] as String;
    final promptEn = roundData['promptEn'] as String;
    final promptMl = roundData['promptMl'] as String;
    final clue = roundData['clue'] as String;
    final options = (roundData['options'] as List).cast<String>();
    final correct = roundData['correct'] as String;

    _currentExpectedVoicePhrase = target;

    final isDay1 = widget.day == 1;
    final totalRounds = activeRounds.length;
    final questionTextEn =
        '🎯 Round ${_currentHuntRound + 1} of $totalRounds:\n$promptEn\nClue: "$clue" $emoji';
    final questionTextMl =
        'റൗണ്ട് ${_currentHuntRound + 1} / $totalRounds:\n$promptMl\nസൂചന: $clue';

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'hunt_q_$_currentHuntRound',
          isAvatar: true,
          textEn: questionTextEn,
          textNative: questionTextMl,
          audioText: promptEn,
          speakThisPrompt: isDay1
              ? 'Speak or Tap the Correct Item: "$target"'
              : 'Speak or Tap the correct answer 🎙️',
          inBubbleOptions: options.map((opt) {
            final cleanOpt = opt.replaceAll(RegExp(r'\s+[^\w\s].*'), '').trim().toLowerCase();
            final cleanCorrect = correct.replaceAll(RegExp(r'\s+[^\w\s].*'), '').trim().toLowerCase();
            final isCorrect = cleanOpt == cleanCorrect ||
                opt.trim().toLowerCase() == correct.trim().toLowerCase();

            return Step3InBubbleOption(
              labelEn: opt,
              labelNative: '',
              icon: isDay1 ? '🎯' : '🔘',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8).withValues(alpha: 0.6),
              textColor: Colors.white,
              onTap: () {
                _handleTextSubmission(
                  text: opt,
                  action: () => _handleHuntAnswer(isCorrect, opt),
                );
              },
            );
          }).toList(),
        ),
      );
    });

    _speak(promptEn);
    _scrollToBottom();
  }

  void _handleHuntAnswer(bool isCorrect, String selectedOption) {
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      PocketGameAudioService.instance.playCoinSound();
      _currentHuntRound++;

      final praiseEn = 'Spot on, $_userName! 🎉 You found $selectedOption!';
      final praiseMl = 'ഗംഭീരം, $_userName! കൃത്യമായി കണ്ടെത്തി!';

      setState(() {
        _messages.add(
          Step3ChatMessage(
            id: 'hunt_correct_$_currentHuntRound',
            isAvatar: true,
            textEn: praiseEn,
            textNative: praiseMl,
            audioText: praiseEn,
          ),
        );
      });

      _speak(praiseEn);
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        _sendNextHuntQuestion();
      });
    } else {
      HapticFeedback.lightImpact();
      final retryEn = 'Close! Look at the clue again, $_userName! Let\'s try! 💪';
      final retryMl = 'വീണ്ടും ഒന്നു ശ്രമിച്ച് നോക്കൂ!';

      setState(() {
        _messages.add(
          Step3ChatMessage(
            id: 'hunt_retry_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            textEn: retryEn,
            textNative: retryMl,
            audioText: retryEn,
          ),
        );
      });

      _speak(retryEn);
      _scrollToBottom();
    }
  }

  void _showHuntCompletedDialogue() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    final gameSpec = Pocket20Days40GamesRegistry.allGames.firstWhere(
      (g) => g.day == widget.day && g.gameIndex == 1,
      orElse: () => DayGameSpec(
        day: widget.day,
        gameIndex: 1,
        title: 'Day ${widget.day} English Quest',
        emoji: '🎮',
        genre: GameGenre.runner,
        englishTarget: 'Sentence Structure & Spoken English',
        descriptionEn: '',
        descriptionMl: '',
        controlMechanism: '',
      ),
    );

    final replyEn = widget.day == 1
        ? '🏆 OUTSTANDING, $_userName! You mastered all 6 rounds of Letter & Word Hunt!\n\n'
            'Step 3 is complete! Now let\'s proceed to Step 4: Spoken English Chat! 🎙️'
        : '🏆 OUTSTANDING, $_userName! You mastered Day ${widget.day} Step 3: ${gameSpec.title} ${gameSpec.emoji}!\n\n'
            'Target "${gameSpec.englishTarget}" is complete! Now let\'s proceed to Step 4: Spoken English Chat! 🎙️';

    final replyMl = widget.day == 1
        ? 'അഭിനന്ദനങ്ങൾ, $_userName! സ്റ്റെപ്പ് 3 പൂർത്തിയായി!\n\n'
            'ഇനി നമുക്ക് സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ് ചാറ്റിലേക്ക് കടക്കാം! 🎙️'
        : 'അഭിനന്ദനങ്ങൾ, $_userName! ഡേ ${widget.day} സ്റ്റെപ്പ് 3 (${gameSpec.title}) വിജയകരമായി പൂർത്തിയായി!\n\n'
            'ഇനി നമുക്ക് സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ് ചാറ്റിലേക്ക് കടക്കാം! 🎙️';

    _currentExpectedVoicePhrase = 'Proceed to Step 4';

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'hunt_finish',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText: 'Outstanding, $_userName! You completed Step 3! Let\'s go to Step 4 Spoken English!',
          speakThisPrompt: 'Tap below to enter Step 4: Spoken English 🎙️',
          inBubbleOptions: [
            Step3InBubbleOption(
              labelEn: 'Step 4: Spoken English ➔',
              labelNative: 'സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ്',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep3AndProceedToStep4,
            ),
          ],
        ),
      );
    });

    _speak('Outstanding, $_userName! You completed Step 3! Let\'s go to Step 4 Spoken English!');
    _scrollToBottom();
  }

  Future<void> _launchDedicated2DGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();

    if (widget.day == 1) {
      return _launchMeadowRunnerGame();
    }

    final gameSpec = Pocket20Days40GamesRegistry.allGames.firstWhere(
      (g) => g.day == widget.day && g.gameIndex == 1,
      orElse: () => DayGameSpec(
        day: widget.day,
        gameIndex: 1,
        title: 'Day ${widget.day} English Quest',
        emoji: '🎮',
        genre: GameGenre.runner,
        englishTarget: 'Sentence Structure & Spoken English',
        descriptionEn: 'Interactive action gaming applied to English mastery.',
        descriptionMl: 'ഗെയിം കളിച്ചുകൊണ്ട് ഇംഗ്ലീഷ് പഠിക്കുക.',
        controlMechanism: 'Touch controls',
      ),
    );

    if (!mounted) return;
    await PocketUniversalArcadeEnginePage.launch(
      context,
      day: widget.day,
      gameIndex: 1,
      spec: gameSpec,
      onCompleted: () {
        if (mounted) {
          _showHuntCompletedDialogue();
        }
      },
    );
  }

  Future<void> _launchMeadowRunnerGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();

    final activeRounds = getHuntRoundsForDay(widget.day);
    final roundsData = activeRounds.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final r = entry.value;
      final rawOptions = (r['options'] as List).map((o) {
        final str = o.toString();
        // Remove trailing emoji for cleaner tile text in 2D game
        return str.replaceAll(RegExp(r'\s+[^\w\s].*'), '').trim();
      }).toList();
      return {
        "round": idx,
        "target": r['target'],
        "prompt": {"en": r['promptEn'], "ml": r['promptMl']},
        "options": rawOptions,
        "correct": r['correct'],
      };
    }).toList();

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: Text('🌳 Meadow Hunt Quest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: MeadowRunnerGamePage(
            rounds: roundsData,
            initialRound: 0,
            nativeLanguage: 'Malayalam',
            isFullscreen: true,
            onAllCompleted: () {
              Navigator.pop(context);
              _showHuntCompletedDialogue();
            },
          ),
        ),
      ),
    );
  }

  void _completeStep3AndProceedToStep4() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(3);
    }
    Navigator.pop(context);
  }

  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      action();
    });
  }

  /// Handles text button selection submission (creates a clean USER TEXT message bubble)
  void _handleTextSubmission({
    required String text,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'user_text_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: text,
          isVoiceMessage: false,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      action();
    });
  }

  Future<void> _startListeningToCentralMic() async {
    HapticFeedback.heavyImpact();

    if (_isListening) {
      _onConfirmAndSendVoice();
      return;
    }

    _liveRecordedWords = '';
    setState(() => _isListening = true);

    if (!_speechAvailable) {
      if (mounted) {
        setState(() {
          _liveRecordedWords = _currentExpectedVoicePhrase;
        });
      }
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          final raw = result.recognizedWords.trim();
          if (raw.isNotEmpty && mounted) {
            setState(() {
              _liveRecordedWords = raw;
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveRecordedWords = _currentExpectedVoicePhrase;
        });
      }
    }
  }

  void _cancelRecording() async {
    HapticFeedback.lightImpact();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}
    setState(() {
      _isListening = false;
      _liveRecordedWords = '';
    });
  }

  void _onConfirmAndSendVoice() async {
    HapticFeedback.mediumImpact();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}

    setState(() => _isListening = false);

    final raw = _liveRecordedWords.trim();
    if (raw.isEmpty) {
      _speak('I could not hear you clearly. Tap the mic and speak aloud.');
      return;
    }

    final normalized = PocketSpeechNormalizer.normalize(raw);
    final finalSpoken = normalized.isEmpty ? raw : normalized;

    _handleVoiceSubmission(
      voiceText: finalSpoken,
      action: () {
        final activeRounds = getHuntRoundsForDay(widget.day);
        if (_currentHuntRound < activeRounds.length) {
          final roundData = activeRounds[_currentHuntRound];
          final correct = roundData['correct'] as String;
          final isMatch = PocketSpeechNormalizer.isMatch(
            spokenText: finalSpoken,
            targetSentence: correct,
            thresholdPercentage: 35,
          ) || finalSpoken.toLowerCase().contains(correct.toLowerCase()) || finalSpoken.isNotEmpty;
          _handleHuntAnswer(isMatch, finalSpoken);
        } else {
          _completeStep3AndProceedToStep4();
        }
      },
    );
  }

  // =========================================================================
  // 🎨 UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
            _buildMinimalFloatingMicBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final gameSpec = Pocket20Days40GamesRegistry.allGames.firstWhere(
            (g) => g.day == widget.day && g.gameIndex == 1,
            orElse: () => DayGameSpec(
              day: widget.day,
              gameIndex: 1,
              title: 'Day ${widget.day} English Quest',
              emoji: '🎮',
              genre: GameGenre.runner,
              englishTarget: 'Sentence Structure & Spoken English',
              descriptionEn: '',
              descriptionMl: '',
              controlMechanism: '',
            ),
          );
          final isDay1 = widget.day == 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(isDay1 ? '🔍' : gameSpec.emoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isDay1
                            ? 'DAY 1 STEP 3: PHONICS HUNT 🔤'
                            : 'DAY ${widget.day} STEP 3: ${gameSpec.title.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        isDay1
                            ? 'Phonics & Letter Hunt Quest'
                            : '${gameSpec.emoji} ${gameSpec.englishTarget}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
          // 🎵 BGM Music Toggle (User Audio Directive!)
          ValueListenableBuilder<bool>(
            valueListenable: PocketGameAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  PocketGameAudioService.instance.toggleMute();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isMuted ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: !isMuted ? const Color(0xFF10B981) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !isMuted ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        !isMuted ? 'BGM' : 'MUTED',
                        style: GoogleFonts.outfit(
                          color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(
              _isSoundMuted
                  ? Icons.volume_off_rounded
                  : (_isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
              color: _isSoundMuted ? Colors.white38 : const Color(0xFF38BDF8),
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSoundMuted = !_isSoundMuted;
                if (_isSoundMuted) _tts.stop();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Step3ChatMessage msg) {
    if (msg.isAvatar) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VectorAvatarWidget(
              config: VectorAvatarConfig.defaultConfig,
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.textEn,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (msg.textNative != null && msg.textNative!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            msg.textNative!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFBAE6FD),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                        if (msg.speakThisPrompt != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, color: Color(0xFFFFD700), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                msg.speakThisPrompt!,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (msg.inBubbleOptions != null && msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.inBubbleOptions!.map((opt) {
                        return GestureDetector(
                          onTap: opt.onTap,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 90,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: opt.backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: opt.borderColor, width: opt.isHighlightedAnswer ? 2 : 1),
                              boxShadow: opt.isHighlightedAnswer
                                  ? [
                                      BoxShadow(
                                        color: opt.borderColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(opt.icon, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          color: opt.textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        softWrap: true,
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.inter(
                                            color: opt.textColor.withValues(alpha: 0.8),
                                            fontSize: 10,
                                          ),
                                          softWrap: true,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // User Message Bubble: Either Text Bubble or Voice Note Bubble
      if (!msg.isVoiceMessage) {
        // 💬 User Text Bubble (When user taps an in-bubble option button)
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF075985)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.textEn,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      }

      // 🎙️ User Audio / Voice Note Message Bubble (WhatsApp style)
      // Strictly NO transcription text displayed inside or below the bubble!
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Play / Speak Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _speak(msg.textEn);
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Audio Waveform Visual Bars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final h in [6.0, 14.0, 20.0, 10.0, 16.0, 22.0, 12.0, 8.0, 18.0, 14.0, 7.0]) ...[
                          Container(
                            width: 3,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Duration & Voice Note Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0:02',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Voice Note 🎙️',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA7F3D0),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('👤', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMinimalFloatingMicBar() {
    if (_isListening) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF10B981), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RECORDING...',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '🎙️ Listening... Speak clearly into mic',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onConfirmAndSendVoice,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SEND',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.send_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tap mic below to speak your answer',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _startListeningToCentralMic,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
