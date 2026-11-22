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
  final bool isLocked;

  _PhraseTile({
    required this.id,
    required this.word,
    required this.correctIndex,
    this.isLocked = false,
  });
}

/// 🌟 Dedicated Useful English Phrases Game Page (Step 6)
///
/// Features:
/// - Sentence-builder interactive game format
/// - Pre-placed & locked Anchor word (e.g. "How") as the conversational starter
/// - Global language synchronization (Malayalam, Tamil, Hindi, Kannada)
/// - Top Teacher's Concept Tip explaining the anchor phrase
/// - Rich visual glowing cards, empty word target slots, and tactile SFX/haptics
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
    extends State<PocketUsefulPhrasesGamePage>
    with SingleTickerProviderStateMixin {
  late DayUsefulPhrases _dayData;
  int _currentPhraseIdx = 0;

  final List<_PhraseTile> _placedTiles = [];
  final List<_PhraseTile> _bankTiles = [];

  bool _isRoundCompleted = false;
  int? _shakingTileId;
  int? _hintTileId;
  bool _isTipExpanded = false;

  late AnimationController _shakeController;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _dayData = Pocket90DayUsefulPhrasesData.getDayPhrases(widget.day);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _initTts();
    _loadRound(_currentPhraseIdx);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
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

    // Anchor word is the first word (words[0])
    // Pre-place words[0] as a locked starter tile in the assembly area
    final starterTile = _PhraseTile(
      id: 0,
      word: words.isNotEmpty ? words[0] : _dayData.anchorWord,
      correctIndex: 0,
      isLocked: true,
    );

    // Remaining words go into the bank
    final bankList = <_PhraseTile>[];
    for (int i = 1; i < words.length; i++) {
      bankList.add(_PhraseTile(
        id: i,
        word: words[i],
        correctIndex: i,
        isLocked: false,
      ));
    }

    // Shuffle bank tiles so they aren't in exact order
    final shuffled = List<_PhraseTile>.from(bankList);
    final rand = math.Random();
    shuffled.shuffle(rand);
    if (bankList.length > 1 &&
        List.generate(bankList.length, (i) => bankList[i].id).toString() ==
            List.generate(shuffled.length, (i) => shuffled[i].id).toString()) {
      shuffled.shuffle(rand);
    }

    setState(() {
      _placedTiles.clear();
      _placedTiles.add(starterTile);
      _bankTiles.clear();
      _bankTiles.addAll(shuffled);
      _isRoundCompleted = false;
      _hintTileId = null;
      _shakingTileId = null;
    });

    // If single-word phrase (rare edge case), auto-complete
    if (words.length <= 1) {
      _handlePhraseCompleted();
    }
  }

  void _onBankTileTapped(_PhraseTile tile) {
    if (_isRoundCompleted) return;

    final expectedNextIndex = _placedTiles.length;
    if (tile.correctIndex == expectedNextIndex) {
      // Correct tile selected!
      PocketGameSfx.instance.playTilePop();
      HapticFeedback.lightImpact();

      setState(() {
        _bankTiles.remove(tile);
        _placedTiles.add(tile);
        _hintTileId = null;
        _shakingTileId = null;
      });

      // Check if entire phrase is assembled
      final item = _dayData.phrases[_currentPhraseIdx];
      if (_placedTiles.length == item.words.length) {
        _handlePhraseCompleted();
      }
    } else {
      // Incorrect tile tapped
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

    // Anchor starter tile is permanently locked in place!
    if (tile.isLocked) {
      HapticFeedback.selectionClick();
      return;
    }

    // Return tapped tile back to bank
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
          side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
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
              'Awesome work! You completed all ${_dayData.phrases.length} practical English phrases starting with ${_dayData.anchorWord}!',
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
              backgroundColor: const Color(0xFF00E5FF),
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
      backgroundColor: const Color(0xFF070B14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B132B),
              Color(0xFF1C2541),
              Color(0xFF0B132B),
              Color(0xFF070B14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top App Header & Progress
              _buildTopHeader(),

              // 2. Anchor Lesson Banner (explaining the concept and why we use it)
              _buildAnchorLessonBanner(),

              const SizedBox(height: 6),

              // 3. Sentence Assembly Board (Meaning + Locked Anchor + Word Slots)
              Expanded(
                flex: 5,
                child: _buildAssemblyBoard(currentPhrase),
              ),

              // 4. Subtle Divider with neon cyan glow
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 5. Bottom Word Bank (only remaining words to complete the phrase)
              Expanded(
                flex: 5,
                child: _buildBottomWordBank(),
              ),

              // 6. Completion Footer
              if (_isRoundCompleted) _buildCompletionFooter(currentPhrase),

              // 7. Banner Ad
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button ✕
          IconButton(
            onPressed: () {
              PocketGameSfx.instance.playClick();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
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
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.8,
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
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white24,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF)
                                            .withValues(alpha: 0.7),
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
                                  ? const Color(0xFF00E5FF)
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
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFFD700),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnchorLessonBanner() {
    final isMl = PocketLanguageService.languageCode == 'ml';
    final note = isMl
        ? (_dayData.lessonNoteMl ?? _dayData.descriptionMl)
        : (_dayData.lessonNoteEn ?? _dayData.descriptionEn);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_dayData.emoji} ANCHOR: ${_dayData.anchorWord.toUpperCase()}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _isTipExpanded = !_isTipExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isTipExpanded ? 'Less' : 'Lesson Tip',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                    Icon(
                      _isTipExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note,
            maxLines: _isTipExpanded ? 8 : 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyBoard(UsefulPhraseItem phrase) {
    // Automatically uses global language setting (Malayalam, Tamil, Hindi, etc.)
    final nativeMeaning = phrase.getLocalizedMeaning();
    final totalWords = phrase.words.length;
    final remainingSlots = math.max(0, totalWords - _placedTiles.length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Meaning Card with Speaker Icon
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        nativeMeaning,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFF00E5FF),
                          size: 22,
                        ),
                      ),
                      onPressed: () => _speak(phrase.phraseEn),
                    ),
                  ],
                ),
              ),

              // 2. Sentence Construction Area (Locked Anchor + Placed Tiles + Dashed Empty Slots)
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Placed Tiles (Index 0 is locked Anchor)
                  ..._placedTiles.map((tile) {
                    return GestureDetector(
                      onTap: () => _onPlacedTileTapped(tile),
                      child: _buildTile(
                        tile: tile,
                        isPlaced: true,
                        isShaking: false,
                        isHint: false,
                      ),
                    );
                  }),

                  // Dashed Placeholder Slots for remaining words
                  ...List.generate(remainingSlots, (i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '••••',
                        style: GoogleFonts.outfit(
                          color: Colors.white24,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWordBank() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Word Bank Label
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'TAP WORDS TO COMPLETE PHRASE ⬇',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Word Bank Tiles
              Wrap(
                spacing: 10,
                runSpacing: 12,
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
            ],
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
    final isLockedStarter = tile.isLocked;

    Widget tileBox = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: isLockedStarter
            ? const Color(0xFF0284C7) // Anchor starter color
            : isPlaced
                ? const Color(0xFF00E5FF) // User placed tile
                : isHint
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLockedStarter
              ? const Color(0xFF38BDF8)
              : isPlaced
                  ? const Color(0xFF67E8F9)
                  : isHint
                      ? Colors.white
                      : const Color(0xFF00E5FF).withValues(alpha: 0.45),
          width: isPlaced || isHint || isLockedStarter ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLockedStarter
                    ? const Color(0xFF0284C7)
                    : isPlaced
                        ? const Color(0xFF00E5FF)
                        : Colors.black)
                .withValues(alpha: isPlaced || isLockedStarter ? 0.35 : 0.25),
            blurRadius: isPlaced || isLockedStarter ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLockedStarter) ...[
            const Icon(Icons.lock_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            tile.word,
            style: GoogleFonts.outfit(
              color: isLockedStarter
                  ? Colors.white
                  : isPlaced || isHint
                      ? const Color(0xFF070B14)
                      : Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
        color: const Color(0xFF0B132B),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
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
              color: Color(0xFF00E5FF),
              size: 26,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
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
