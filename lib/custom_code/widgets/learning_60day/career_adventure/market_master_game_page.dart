import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'market_master_models.dart';

/// 2D Flame Supermarket Shopping & Communication Game Page for Level 9: Market Master
class MarketMasterGamePage extends StatefulWidget {
  final MarketMasterLevelData levelData;

  const MarketMasterGamePage({
    super.key,
    required this.levelData,
  });

  @override
  State<MarketMasterGamePage> createState() => _MarketMasterGamePageState();
}

class _MarketMasterGamePageState extends State<MarketMasterGamePage> {
  late final MarketMasterFlameGame _flameGame;
  late final FlutterTts _flutterTts;

  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _hintsUsed = 0;
  int _mistakesCount = 0;
  int _comboStreak = 0;
  int _bestCombo = 0;
  bool _audioMuted = false;
  bool _isOptionSelected = false;
  String? _lastExplanation;

  // Active Cart State
  final List<CartProductItem> _cartItems = [];

  // Challenge 11: 90s Shopping Rush Timer
  Timer? _rushTimer;
  int _rushSecondsRemaining = 90;

  // Evaluation Metrics
  int _vocabPoints = 0;
  int _readingPoints = 0;
  int _communicationPoints = 0;
  int _practicalPoints = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.48);
    _flutterTts.setPitch(1.0);
  }

  void _initFlameGame() {
    _flameGame = MarketMasterFlameGame(
      levelData: widget.levelData,
      onAisleInteract: () {
        // Shelf tap interaction
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentChallenge();
    });
  }

  void _speakCurrentChallenge() {
    if (_audioMuted) return;
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    _speak(challenge.spokenText);
  }

  Future<void> _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _rushTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _startRushTimer() {
    _rushTimer?.cancel();
    setState(() {
      _rushSecondsRemaining = 90;
    });
    _rushTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_rushSecondsRemaining > 1) {
        setState(() {
          _rushSecondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  int get _cartRunningTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _showHintDialog() {
    HapticFeedback.lightImpact();
    setState(() {
      _hintsUsed++;
      if (_scoreXp > 5) _scoreXp -= 5;
    });

    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded,
                color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              'Shopping Assistant Hint',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          challenge.hint,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CONTINUE SHOPPING',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0EA5E9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_rounded,
                        color: Color(0xFF0EA5E9), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Shopping Basket',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    '${_cartItems.length} items',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            if (_cartItems.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Your basket is currently empty.\nCollect required items from the market aisles!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 180,
                child: ListView.separated(
                  itemCount: _cartItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, i) {
                    final item = _cartItems[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(item.icon, color: const Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${item.quantityLabel} • ₹${item.unitPrice} each',
                                  style: GoogleFonts.inter(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.totalPrice}',
                            style: GoogleFonts.firaCode(
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RUNNING TOTAL',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '₹$_cartRunningTotal',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'BACK TO SUPERMARKET',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionSelected(MarketChallengeOption option) {
    if (_isOptionSelected) return;

    HapticFeedback.selectionClick();
    setState(() {
      _isOptionSelected = true;
      _lastExplanation = option.feedback;
    });

    if (option.isCorrect) {
      HapticFeedback.mediumImpact();
      final comboBonus = _comboStreak * 5;
      setState(() {
        _scoreXp += option.xpReward + comboBonus;
        _comboStreak++;
        if (_comboStreak > _bestCombo) _bestCombo = _comboStreak;

        final challenge = widget.levelData.challenges[_currentChallengeIndex];
        // Award cart item if present
        if (challenge.awardedCartItem != null) {
          final existingIdx = _cartItems.indexWhere((it) => it.id == challenge.awardedCartItem!.id);
          if (existingIdx == -1) {
            _cartItems.add(challenge.awardedCartItem!);
          }
        }

        // Categorize evaluation metrics
        switch (challenge.type) {
          case MarketChallengeType.understandList:
          case MarketChallengeType.quantityPickup:
            _readingPoints += 25;
            _practicalPoints += 20;
            break;
          case MarketChallengeType.productSearch:
          case MarketChallengeType.priceReading:
          case MarketChallengeType.comparison:
            _vocabPoints += 25;
            _practicalPoints += 25;
            break;
          case MarketChallengeType.askForHelp:
          case MarketChallengeType.listenToStaff:
          case MarketChallengeType.customerService:
          case MarketChallengeType.cashierDialogue:
            _communicationPoints += 25;
            _vocabPoints += 20;
            break;
          case MarketChallengeType.checkoutSum:
          case MarketChallengeType.shoppingRush:
            _practicalPoints += 30;
            _readingPoints += 20;
            break;
        }
      });

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _advanceToNextChallenge();
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _mistakesCount++;
        _comboStreak = 0;
      });

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _isOptionSelected = false;
          _lastExplanation = null;
        });
      });
    }
  }

  void _advanceToNextChallenge() {
    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _isOptionSelected = false;
        _lastExplanation = null;
      });

      final nextChallenge = widget.levelData.challenges[_currentChallengeIndex];
      if (nextChallenge.type == MarketChallengeType.shoppingRush) {
        _startRushTimer();
      }

      _flameGame.movePlayerToChallenge(_currentChallengeIndex);
      _speakCurrentChallenge();
    } else {
      _rushTimer?.cancel();
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    final vocabPct = math.min(100, 85 + (_vocabPoints ~/ 4)).clamp(75, 100);
    final readingPct = math.min(100, 84 + (_readingPoints ~/ 4)).clamp(75, 100);
    final commPct = math.min(100, 86 + (_communicationPoints ~/ 4)).clamp(75, 100);
    final practicalPct = math.min(100, 88 + (_practicalPoints ~/ 4)).clamp(75, 100);
    final shoppingAcc = math.max(75, 100 - (_mistakesCount * 4));

    final overall = ((vocabPct + readingPct + commPct + practicalPct + shoppingAcc) / 5).round();
    final stars = overall >= 90 ? 3 : (overall >= 75 ? 2 : 1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0EA5E9),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('🛒', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(
              'SHOPPING COMPLETE!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Family Guest Dinner List Fully Purchased & Verified.',
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isStar = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isStar ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isStar ? const Color(0xFFFFD700) : Colors.white24,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Score Metrics Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricStat('Vocabulary', '$vocabPct%'),
                      _metricStat('Reading', '$readingPct%'),
                      _metricStat('Communication', '$commPct%'),
                      _metricStat('Practical', '$practicalPct%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricStat('Shopping Accuracy', '$shoppingAcc%'),
                      _metricStat('XP Earned', '+$_scoreXp'),
                      _metricStat('Wrong/Hints', '$_mistakesCount / $_hintsUsed'),
                      _metricStat('Total Bill', '₹$_cartRunningTotal'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Unlocked Level 10 Note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_open_rounded,
                    color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Level 10 Unlocked • 9 / 90 Days Complete',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                child: Text(
                  'COMPLETE MISSION',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.firaCode(
            color: const Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Market Master',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        actions: [
          // Cart Button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF38BDF8)),
                onPressed: _showCartSheet,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: GoogleFonts.firaCode(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Audio Mute/Unmute
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF0EA5E9),
              size: 20,
            ),
            onPressed: () {
              setState(() => _audioMuted = !_audioMuted);
              if (!_audioMuted) _speakCurrentChallenge();
            },
          ),

          // Hint Button
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFFFFD700), size: 20),
            onPressed: _showHintDialog,
          ),

          // Score Indicator
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 4),
                Text(
                  '$_scoreXp',
                  style: GoogleFonts.firaCode(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar: Section, Progress, Rush Timer
            Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF0EA5E9)),
                    ),
                    child: Text(
                      challenge.aisleCode,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0EA5E9),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      challenge.sectionTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (challenge.type == MarketChallengeType.shoppingRush) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_rounded,
                              color: Color(0xFFEF4444), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${_rushSecondsRemaining}s',
                            style: GoogleFonts.firaCode(
                              color: const Color(0xFFEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${_currentChallengeIndex + 1}/${widget.levelData.challenges.length}',
                      style: GoogleFonts.firaCode(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Progress Bar
            LinearProgressIndicator(
              value: (_currentChallengeIndex + 1) /
                  widget.levelData.challenges.length,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
              minHeight: 2.5,
            ),

            // 2D Flame Supermarket Viewport
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  GameWidget(game: _flameGame),

                  // Tap/Drag instruction tooltip
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded,
                              color: Colors.white54, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Tap screen or use Walk buttons to browse aisles',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Challenge Interaction Bottom Section
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: _buildChallengePanel(challenge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengePanel(MarketMasterChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Title & Audio Speaker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF38BDF8), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _speak(challenge.spokenText),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Prompt Text Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
            ),
            child: Text(
              challenge.prompt,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),

          // Shelf Products Inspection (if present, e.g. Challenge 2)
          if (challenge.shelfProducts != null) ...[
            const SizedBox(height: 8),
            Text(
              'SHELF DISPLAY INSPECTION',
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            ...challenge.shelfProducts!.map((prod) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: prod.isTarget
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                          Text(
                            '${prod.brand} • ${prod.weightLabel}',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${prod.price}',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Feedback / Explanation Banner
          if (_lastExplanation != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _lastExplanation!.contains('Correct') ||
                          _lastExplanation!.contains('Spot on') ||
                          _lastExplanation!.contains('Exact') ||
                          _lastExplanation!.contains('Polite') ||
                          _lastExplanation!.contains('Excellent') ||
                          _lastExplanation!.contains('Math') ||
                          _lastExplanation!.contains('Courteous') ||
                          _lastExplanation!.contains('Great') ||
                          _lastExplanation!.contains('SUPERMARKET')
                      ? const Color(0xFF10B981)
                      : Colors.orangeAccent,
                ),
              ),
              child: Text(
                _lastExplanation!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Options
          ...challenge.options.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOptionSelected
                      ? null
                      : () => _handleOptionSelected(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt.id.split('_').last.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt.text,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 4),

          // Walk Controls & Cart Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerLeft(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK LEFT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerRight(),
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK RIGHT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _showCartSheet,
                  icon: const Icon(Icons.shopping_basket_rounded,
                      color: Colors.white, size: 14),
                  label: Text(
                    'CART (${_cartItems.length})',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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

/// 2D Flame Supermarket World for Level 9: Market Master
class MarketMasterFlameGame extends FlameGame with TapCallbacks {
  final MarketMasterLevelData levelData;
  final VoidCallback onAisleInteract;

  double playerX = 140.0;
  double targetPlayerX = 140.0;
  bool isMoving = false;
  bool facingRight = true;
  double walkCycle = 0.0;

  static const double worldWidth = 1900.0;
  static const double groundY = 270.0;

  MarketMasterFlameGame({
    required this.levelData,
    required this.onAisleInteract,
  });

  void movePlayerByPixels(double dx, double screenWidth) {
    targetPlayerX = (playerX + dx * (worldWidth / screenWidth)).clamp(40.0, worldWidth - 40.0);
    facingRight = dx >= 0;
    isMoving = true;
  }

  void movePlayerLeft() {
    targetPlayerX = (playerX - 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = false;
    isMoving = true;
  }

  void movePlayerRight() {
    targetPlayerX = (playerX + 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = true;
    isMoving = true;
  }

  void movePlayerToChallenge(int index) {
    final step = (worldWidth - 240.0) / (levelData.challenges.length - 1);
    targetPlayerX = (120.0 + (index * step)).clamp(40.0, worldWidth - 40.0);
    facingRight = targetPlayerX >= playerX;
    isMoving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((targetPlayerX - playerX).abs() > 2.0) {
      final direction = (targetPlayerX - playerX).sign;
      playerX += direction * 220.0 * dt;
      walkCycle += dt * 8.0;
      isMoving = true;
    } else {
      playerX = targetPlayerX;
      isMoving = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final viewWidth = size.x;
    final cameraX = (playerX - (viewWidth / 2))
        .clamp(0.0, math.max<double>(0.0, worldWidth - viewWidth));

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Supermarket Wall Background with subtle lighting
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), bgPaint);

    // 2. Continuous Ceramic Supermarket Tile Floor
    final floorPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), floorPaint);

    // Grid lines for supermarket clean tiles
    final tileLine = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;
    for (double gx = 0; gx < worldWidth; gx += 50) {
      canvas.drawLine(Offset(gx, groundY), Offset(gx, size.y), tileLine);
    }

    // 3. Render Supermarket Zones
    _renderEntranceZone(canvas);
    _renderBakeryZone(canvas);
    _renderGroceryAisleZone(canvas);
    _renderDrinksWallZone(canvas);
    _renderCustomerServiceZone(canvas);
    _renderCheckoutZone(canvas);

    // 4. Render Player with Shopping Cart
    _renderPlayerWithCart(canvas, playerX, groundY);

    canvas.restore();
  }

  void _renderEntranceZone(Canvas canvas) {
    // Supermarket Entrance Doors & Digital Kiosk (x: 0 .. 380)
    final doorFrame = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(60, 60, 140, 210), doorFrame);

    final glass = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.35);
    canvas.drawRect(const Rect.fromLTWH(70, 70, 120, 195), glass);

    // Shopping list terminal kiosk
    final kioskPaint = Paint()..color = const Color(0xFF0EA5E9);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(240, 140, 50, 130), const Radius.circular(6)), kioskPaint);
    final screenPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(const Rect.fromLTWH(245, 150, 40, 35), screenPaint);

    // Metal Cart Bay rack
    final cartRack = Paint()..color = Colors.white24..strokeWidth = 3;
    canvas.drawLine(const Offset(310, 210), Offset(360, 210), cartRack);
    canvas.drawLine(const Offset(310, 240), Offset(360, 240), cartRack);
  }

  void _renderBakeryZone(Canvas canvas) {
    // Fresh Bakery & Dairy Shelves (x: 380 .. 740)
    final bakeryDisplay = Paint()..color = const Color(0xFF78350F);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(420, 110, 140, 160), const Radius.circular(8)), bakeryDisplay);

    // Baguettes / Bread Loaves
    final breadPaint = Paint()..color = const Color(0xFFF59E0B);
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(435.0 + (i * 26), 130, 18, 38), const Radius.circular(8)),
        breadPaint,
      );
    }

    // Dairy Glass Fridge for Eggs
    final fridgePaint = Paint()..color = const Color(0xFF0F766E);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(590, 100, 120, 170), const Radius.circular(6)), fridgePaint);

    // Egg Cartons
    final eggPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRect(const Rect.fromLTWH(605, 150, 90, 22), eggPaint);
    canvas.drawRect(const Rect.fromLTWH(605, 190, 90, 22), eggPaint);
  }

  void _renderGroceryAisleZone(Canvas canvas) {
    // Grocery Gondola Aisle 3 (x: 740 .. 1120)
    final shelfWall = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(const Rect.fromLTWH(770, 70, 310, 200), shelfWall);

    // Basmati Rice Sacks & Cooking Oil Bottles
    final riceSack = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(800, 180, 55, 45), const Radius.circular(6)), riceSack);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(865, 180, 55, 45), const Radius.circular(6)), riceSack);

    // Cooking Oil Bottles
    final oilPaint = Paint()..color = const Color(0xFFFBBF24);
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(940.0 + (i * 18), 175, 12, 50), oilPaint);
    }

    // Store Clerk NPC Raj
    final rajBody = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1040, 200, 20, 42), const Radius.circular(4)), rajBody);
    final rajHead = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(1050, 188), 10, rajHead);

    // Aisle Sign "AISLE 3"
    final signPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(860, 45, 90, 24), const Radius.circular(4)), signPaint);
  }

  void _renderDrinksWallZone(Canvas canvas) {
    // Drinks & Beverage Wall (x: 1120 .. 1460)
    final drinkCase = Paint()..color = const Color(0xFF0369A1);
    canvas.drawRect(const Rect.fromLTWH(1160, 70, 260, 200), drinkCase);

    // Glowing Price Tag Board
    final tagBoard = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(1180, 85, 220, 20), tagBoard);

    // Water Bottles Rows
    final waterPaint = Paint()..color = const Color(0xFF38BDF8);
    for (int i = 0; i < 10; i++) {
      canvas.drawRect(Rect.fromLTWH(1175.0 + (i * 22), 125, 12, 38), waterPaint);
      canvas.drawRect(Rect.fromLTWH(1175.0 + (i * 22), 185, 12, 38), waterPaint);
    }
  }

  void _renderCustomerServiceZone(Canvas canvas) {
    // Customer Service Desk (x: 1460 .. 1680)
    final deskPaint = Paint()..color = const Color(0xFF6D28D9);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1480, 180, 180, 90), const Radius.circular(8)), deskPaint);

    // Helpdesk Clerk NPC Maya
    final mayaBody = Paint()..color = const Color(0xFF8B5CF6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1550, 140, 22, 44), const Radius.circular(4)), mayaBody);
    final mayaHead = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(1561, 128), 10, mayaHead);

    // Customer Service Sign
    final csSign = Paint()..color = const Color(0xFF8B5CF6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1500, 50, 140, 24), const Radius.circular(4)), csSign);
  }

  void _renderCheckoutZone(Canvas canvas) {
    // Checkout Counter & Cashier Lane (x: 1680 .. 1900)
    final counterPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1700, 190, 170, 80), const Radius.circular(6)), counterPaint);

    // Conveyor belt
    final beltPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(const Rect.fromLTWH(1710, 205, 100, 14), beltPaint);

    // POS Register Screen
    final posPaint = Paint()..color = const Color(0xFFEC4899);
    canvas.drawRect(const Rect.fromLTWH(1820, 170, 30, 25), posPaint);

    // Cashier NPC Leo
    final leoBody = Paint()..color = const Color(0xFFDB2777);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1825, 140, 20, 40), const Radius.circular(4)), leoBody);
    final leoHead = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(1835, 128), 10, leoHead);
  }

  void _renderPlayerWithCart(Canvas canvas, double x, double groundY) {
    canvas.save();
    canvas.translate(x, groundY);
    if (!facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    final swing = isMoving ? math.sin(walkCycle) * 10 : 0.0;

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-6, -18), Offset(-6 + swing, 0), legPaint);
    canvas.drawLine(const Offset(2, -18), Offset(2 - swing, 0), legPaint);

    // Shopper Body (Teal modern jacket)
    final bodyPaint = Paint()..color = const Color(0xFF0D9488);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -44, 20, 28), const Radius.circular(6)), bodyPaint);

    // Shopper Head
    final headPaint = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(0, -52), 10, headPaint);

    // Hair / Cap
    final hairPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawArc(const Rect.fromLTWH(-10, -62, 20, 16), math.pi, math.pi, true, hairPaint);

    // Shopping Cart Pushed in front (x: 10 .. 38)
    final cartFrame = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(12, -32, 26, 20), const Radius.circular(3)),
      cartFrame,
    );
    // Cart Handle
    canvas.drawLine(const Offset(6, -30), const Offset(12, -26), cartFrame);

    // Cart Wheels
    final wheelPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(const Offset(16, -4), 4, wheelPaint);
    canvas.drawCircle(const Offset(34, -4), 4, wheelPaint);

    canvas.restore();
  }
}
