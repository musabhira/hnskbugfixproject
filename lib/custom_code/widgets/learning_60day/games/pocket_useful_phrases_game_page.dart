import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_useful_phrases_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

/// 🧩 Tile Data representing an individual word chunk
class _PhraseTile {
  final int id;
  final String word;
  final int correctIndex;

  _PhraseTile({
    required this.id,
    required this.word,
    required this.correctIndex,
  });
}

/// 🌟 Dedicated Useful English Phrases Game Page (Step 6)
///
/// Features:
/// - Minimal, eye-pleasing modern deep navy/teal gradient
/// - Day-specific anchor phrase theme (How, Who, When, Where, Why, etc.) across all 90 Days
/// - Native translations across Malayalam, Tamil, Hindi, and Kannada
/// - Interactive word assembly, TTS pronunciation, hint system, and gamified XP rewards
class PocketUsefulPhrasesGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketUsefulPhrasesGamePage({
    super.key,
    required this.day,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketUsefulPhrasesGamePage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketUsefulPhrasesGamePage> createState() =>
      _PocketUsefulPhrasesGamePageState();
}

class _PocketUsefulPhrasesGamePageState
    extends State<PocketUsefulPhrasesGamePage> with SingleTickerProviderStateMixin {
  late DayUsefulPhrases _dayData;
  int _currentPhraseIdx = 0;

  final List<_PhraseTile> _placedTiles = [];
  final List<_PhraseTile> _bankTiles = [];

  bool _isRoundCompleted = false;
  int? _shakingTileId;
  int? _hintTileId;

  late AnimationController _shakeController;
  final FlutterTts _tts = FlutterTts();
  String _selectedLang = 'ml';

  @override
  void initState() {
    super.initState();
    _dayData = Pocket90DayUsefulPhrasesData.getDayPhrases(widget.day);
    _selectedLang = PocketLanguageService.languageCode;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initTts();
    _loadRound(_currentPhraseIdx);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  void _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _loadRound(int index) {
    if (index >= _dayData.phrases.length) return;
    final item = _dayData.phrases[index];
    final words = item.words;

    final tiles = <_PhraseTile>[];
    for (int i = 0; i < words.length; i++) {
      tiles.add(_PhraseTile(
        id: i,
        word: words[i],
        correctIndex: i,
      ));
    }

    // Shuffle for bank
    final shuffled = List<_PhraseTile>.from(tiles);
    final rand = math.Random();
    shuffled.shuffle(rand);
    // Guarantee shuffled isn't accidentally in exact solved order if length > 1
    if (tiles.length > 1 &&
        List.generate(tiles.length, (i) => tiles[i].id).toString() ==
            List.generate(shuffled.length, (i) => shuffled[i].id).toString()) {
      shuffled.shuffle(rand);
    }

    setState(() {
      _placedTiles.clear();
      _bankTiles.clear();
      _bankTiles.addAll(shuffled);
      _isRoundCompleted = false;
      _hintTileId = null;
      _shakingTileId = null;
    });
  }

  void _onBankTileTapped(_PhraseTile tile) {
    if (_isRoundCompleted) return;

    final expectedNextIndex = _placedTiles.length;
    if (tile.correctIndex == expectedNextIndex) {
      // Correct tile placement!
      PocketGameSfx.instance.playTilePop();
      HapticFeedback.lightImpact();

      setState(() {
        _bankTiles.remove(tile);
        _placedTiles.add(tile);
        _hintTileId = null;
        _shakingTileId = null;
      });

      // Check if phrase is complete
      final item = _dayData.phrases[_currentPhraseIdx];
      if (_placedTiles.length == item.words.length) {
        _handlePhraseCompleted();
      }
    } else {
      // Wrong tile tapped
      PocketGameSfx.instance.playErrorBuzz();
      HapticFeedback.heavyImpact();

      setState(() {
        _shakingTileId = tile.id;
      });
      _shakeController.forward(from: 0.0).then((_) {
        if (mounted) setState(() => _shakingTileId = null);
      });
    }
  }

  void _onPlacedTileTapped(_PhraseTile tile) {
    if (_isRoundCompleted) return;

    // Send back to bank
    PocketGameSfx.instance.playClick();
    HapticFeedback.selectionClick();

    setState(() {
      _placedTiles.remove(tile);
      _bankTiles.add(tile);
      _hintTileId = null;
    });
  }

  void _giveHint() {
    if (_isRoundCompleted || _bankTiles.isEmpty) return;
    PocketGameSfx.instance.playSnapCorrect();
    HapticFeedback.mediumImpact();

    final expectedIdx = _placedTiles.length;
    final hintTile = _bankTiles.firstWhere(
      (t) => t.correctIndex == expectedIdx,
      orElse: () => _bankTiles.first,
    );

    setState(() {
      _hintTileId = hintTile.id;
    });
  }

  void _handlePhraseCompleted() {
    _isRoundCompleted = true;
    PocketGameSfx.instance.playVictory();
    HapticFeedback.heavyImpact();

    final item = _dayData.phrases[_currentPhraseIdx];
    _speak(item.phraseEn);

    setState(() {});
  }

  void _onNextPhrase() {
    if (_currentPhraseIdx + 1 < _dayData.phrases.length) {
      _currentPhraseIdx++;
      _loadRound(_currentPhraseIdx);
    } else {
      _showAllCompletedDialog();
    }
  }

  Future<void> _showAllCompletedDialog() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    // Mark Step 6 completed for this day
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_6_done', true);
    if (uid != null) {
      await prefs.setBool('pocket_day_${uid}_${widget.day}_step_6_done', true);
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    } else {
      await prefs.setBool('pocket_day_guest_${widget.day}_step_6_done', true);
    }

    widget.onStepFinished?.call(6);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF06B6D4), width: 2),
        ),
        title: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Day ${widget.day} Useful Phrases Mastered!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Awesome work! You mastered all ${_dayData.phrases.length} practical English phrases starting with ${_dayData.anchorWord}!',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    '+30 Pocket Score Earned!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text(
              'CONTINUE ➔',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = _dayData.phrases[_currentPhraseIdx];

    return Scaffold(
      // Minimal, eye-soothing deep midnight slate/navy gradient
      backgroundColor: const Color(0xFF0A0F1D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Deep Slate Navy
              Color(0xFF131D31),
              Color(0xFF0E1626),
              Color(0xFF0A0F1D), // Bottom deep
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header with responsive center title and hint bulb
              _buildTopHeader(),

              const SizedBox(height: 8),

              // 2. Assembly Board (Native meaning & assembled phrase slots)
              Expanded(
                flex: 5,
                child: _buildTopAssemblyBoard(currentPhrase),
              ),

              // 3. Subtle Center Divider
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF06B6D4).withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 4. Bottom Word Bank with scrambled tiles
              Expanded(
                flex: 5,
                child: _buildBottomWordBank(),
              ),

              // 5. Completion Bottom Bar
              if (_isRoundCompleted) _buildCompletionFooter(currentPhrase),

              // 6. Zero-blank Banner Ad
              PocketBannerAdWidget(
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button ✕
          IconButton(
            onPressed: () {
              PocketGameSfx.instance.playClick();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
          ),

          // Title & Progress Dots
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAY ${widget.day} • USEFUL PHRASES 💬',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF06B6D4),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_dayData.phrases.length, (idx) {
                      final isDone = idx < _currentPhraseIdx;
                      final isCurrent = idx == _currentPhraseIdx;
                      return Row(
                        children: [
                          Container(
                            width: isCurrent ? 14 : 9,
                            height: isCurrent ? 14 : 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone || isCurrent
                                  ? const Color(0xFF06B6D4)
                                  : Colors.white24,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF06B6D4)
                                            .withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          if (idx < _dayData.phrases.length - 1)
                            Container(
                              width: 8,
                              height: 2,
                              color: isDone
                                  ? const Color(0xFF06B6D4)
                                  : Colors.white24,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Hint Bulb button 💡
          IconButton(
            onPressed: _giveHint,
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAssemblyBoard(UsefulPhraseItem phrase) {
    final nativeMeaning = _getTranslationForLang(phrase, _selectedLang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Anchor badge
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '${_dayData.emoji} ${_dayData.anchorTheme}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Native Meaning Card
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            nativeMeaning,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFF38BDF8),
                            size: 22,
                          ),
                          onPressed: () => _speak(phrase.phraseEn),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Language Switcher Chips
                    _buildLanguageSwitcher(),
                  ],
                ),
              ),

              // Dropped Phrase Word Tiles
              Wrap(
                spacing: 10,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _placedTiles.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            'Tap the words below to build the phrase',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ]
                    : _placedTiles.map((tile) {
                        return GestureDetector(
                          onTap: () => _onPlacedTileTapped(tile),
                          child: _buildTile(
                            tile: tile,
                            isPlaced: true,
                            isShaking: false,
                            isHint: false,
                          ),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    final langs = [
      {'code': 'ml', 'label': 'മലയാളം'},
      {'code': 'ta', 'label': 'தமிழ்'},
      {'code': 'hi', 'label': 'हिंदी'},
      {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: langs.map((l) {
        final isSelected = _selectedLang == l['code'];
        return GestureDetector(
          onTap: () {
            PocketGameSfx.instance.playClick();
            setState(() => _selectedLang = l['code']!);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF06B6D4).withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF06B6D4)
                    : Colors.white24,
                width: 1,
              ),
            ),
            child: Text(
              l['label']!,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTranslationForLang(UsefulPhraseItem p, String code) {
    switch (code) {
      case 'ta':
        return p.meaningTa;
      case 'hi':
        return p.meaningHi;
      case 'kn':
        return p.meaningKn;
      case 'ml':
      default:
        return p.meaningMl;
    }
  }

  Widget _buildBottomWordBank() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 12,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _bankTiles.map((tile) {
              final isShaking = _shakingTileId == tile.id;
              final isHint = _hintTileId == tile.id;

              return GestureDetector(
                onTap: () => _onBankTileTapped(tile),
                child: _buildTile(
                  tile: tile,
                  isPlaced: false,
                  isShaking: isShaking,
                  isHint: isHint,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required _PhraseTile tile,
    required bool isPlaced,
    required bool isShaking,
    required bool isHint,
  }) {
    Widget tileBox = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPlaced
            ? const Color(0xFF06B6D4)
            : isHint
                ? const Color(0xFFFFD700)
                : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaced
              ? const Color(0xFF22D3EE)
              : isHint
                  ? Colors.white
                  : const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: isPlaced || isHint ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPlaced ? const Color(0xFF06B6D4) : Colors.black)
                .withValues(alpha: isPlaced ? 0.35 : 0.25),
            blurRadius: isPlaced ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        tile.word,
        style: GoogleFonts.outfit(
          color: isPlaced || isHint ? Colors.black : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );

    if (isShaking) {
      return AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = math.sin(_shakeController.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: tileBox,
      );
    }

    return tileBox;
  }

  Widget _buildCompletionFooter(UsefulPhraseItem phrase) {
    final isLast = _currentPhraseIdx + 1 >= _dayData.phrases.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _speak(phrase.phraseEn),
            icon: const Icon(
              Icons.replay_rounded,
              color: Color(0xFF06B6D4),
              size: 26,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _onNextPhrase,
            child: Text(
              isLast ? 'COMPLETE ➔' : 'NEXT PHRASE ➔',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
