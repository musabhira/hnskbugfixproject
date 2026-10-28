import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔒 3x3 Parental Pattern Lock for Kids Mode Security
/// Prevents children from exiting to Adult mode without parent's drawn pattern.
/// Persisted locally in SharedPreferences: 'pocket_parent_pattern_lock'.
enum PatternLockMode {
  verify,
  setup,
}

class PocketParentalPatternLock extends StatefulWidget {
  final PatternLockMode mode;
  final String? title;
  final String? subtitle;
  final ValueChanged<bool>? onResult;

  const PocketParentalPatternLock({
    super.key,
    this.mode = PatternLockMode.verify,
    this.title,
    this.subtitle,
    this.onResult,
  });

  static const String _prefKeyPattern = 'pocket_parent_pattern_lock';

  /// Check if a pattern is already saved
  static Future<bool> hasPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getString(_prefKeyPattern);
    return p != null && p.trim().isNotEmpty;
  }

  /// Get saved pattern string
  static Future<String?> getSavedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyPattern);
  }

  /// Save new pattern
  static Future<bool> savePattern(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_prefKeyPattern, pattern);
  }

  /// Verify entered pattern against saved pattern
  static Future<bool> checkPattern(String pattern) async {
    final saved = await getSavedPattern();
    if (saved == null || saved.isEmpty) return false;
    return saved.trim() == pattern.trim();
  }

  /// Remove/clear saved pattern lock (for reset)
  static Future<bool> clearPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_prefKeyPattern);
  }

  /// Shows the pattern dialog. If no pattern has been set yet, prompts to set one!
  /// Returns `true` if successfully verified/set, `false` otherwise.
  static Future<bool> verifyOrSetup(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    final hasSet = await hasPattern();
    if (!context.mounted) return false;

    if (!hasSet) {
      // Prompt parent to setup their 3x3 pattern lock
      return await showSetupDialog(
        context,
        title: title ?? 'Set Parent Pattern Lock 🔒',
        subtitle: subtitle ?? 'Draw a 3x3 pattern to protect Kids Mode from unauthorized switching.',
      );
    } else {
      // Verify existing pattern lock
      return await showVerifyDialog(
        context,
        title: title ?? 'Parent Verification 🔒',
        subtitle: subtitle ?? 'Draw your pattern lock to switch to Adult Mode.',
      );
    }
  }

  /// Displays the verification modal dialog
  static Future<bool> showVerifyDialog(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        content: PocketParentalPatternLock(
          mode: PatternLockMode.verify,
          title: title ?? 'Parent Pattern Lock 🔒',
          subtitle: subtitle ?? 'Draw your pattern to unlock Adult Mode',
          onResult: (success) => Navigator.pop(ctx, success),
        ),
      ),
    );
    return res ?? false;
  }

  /// Displays the setup modal dialog
  static Future<bool> showSetupDialog(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        content: PocketParentalPatternLock(
          mode: PatternLockMode.setup,
          title: title ?? 'Create Parent Pattern 🔒',
          subtitle: subtitle ?? 'Draw a 3x3 pattern (connect at least 4 dots)',
          onResult: (success) => Navigator.pop(ctx, success),
        ),
      ),
    );
    return res ?? false;
  }

  @override
  State<PocketParentalPatternLock> createState() =>
      _PocketParentalPatternLockState();
}

class _PocketParentalPatternLockState
    extends State<PocketParentalPatternLock> {
  final List<int> _selectedDots = [];
  Offset? _currentTouch;
  bool _isError = false;
  bool _isSuccess = false;
  String _statusMessage = '';

  // Setup state machine
  int _setupStep = 1; // 1: First draw, 2: Confirm draw
  String _firstDrawnPattern = '';

  @override
  void initState() {
    super.initState();
    _resetStatus();
  }

  void _resetStatus() {
    if (widget.mode == PatternLockMode.setup) {
      if (_setupStep == 1) {
        _statusMessage = 'Connect at least 4 dots to create pattern';
      } else {
        _statusMessage = 'Draw pattern again to confirm';
      }
    } else {
      _statusMessage = 'Connect your pattern to continue';
    }
    _isError = false;
    _isSuccess = false;
  }

  String _patternToString(List<int> dots) => dots.join('-');

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_isSuccess) return;
    setState(() {
      _isError = false;
      _selectedDots.clear();
      _currentTouch = details.localPosition;
    });

    final dot = _getDotAtPosition(details.localPosition, constraints);
    if (dot != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedDots.add(dot);
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isSuccess) return;
    setState(() {
      _currentTouch = details.localPosition;
    });

    final dot = _getDotAtPosition(details.localPosition, constraints);
    if (dot != null && !_selectedDots.contains(dot)) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedDots.add(dot);
      });
    }
  }

  Future<void> _handlePanEnd(DragEndDetails details) async {
    if (_selectedDots.isEmpty || _isSuccess) return;

    setState(() {
      _currentTouch = null;
    });

    final patternStr = _patternToString(_selectedDots);

    if (widget.mode == PatternLockMode.setup) {
      if (_selectedDots.length < 4) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _statusMessage = 'Connect at least 4 dots!';
          _selectedDots.clear();
        });
        return;
      }

      if (_setupStep == 1) {
        HapticFeedback.mediumImpact();
        setState(() {
          _firstDrawnPattern = patternStr;
          _setupStep = 2;
          _statusMessage = 'Draw the same pattern to confirm!';
          _selectedDots.clear();
        });
      } else {
        // Confirmation step
        if (patternStr == _firstDrawnPattern) {
          HapticFeedback.mediumImpact();
          await PocketParentalPatternLock.savePattern(patternStr);
          setState(() {
            _isSuccess = true;
            _statusMessage = 'Pattern Lock Saved Successfully! ✅';
          });
          await Future.delayed(const Duration(milliseconds: 600));
          widget.onResult?.call(true);
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _isError = true;
            _setupStep = 1;
            _firstDrawnPattern = '';
            _statusMessage = 'Patterns did not match. Draw again!';
            _selectedDots.clear();
          });
        }
      }
    } else {
      // Verify mode
      final isMatch = await PocketParentalPatternLock.checkPattern(patternStr);
      if (isMatch) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSuccess = true;
          _statusMessage = 'Pattern Verified! Unlocking... 🔓';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onResult?.call(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _statusMessage = 'Incorrect Pattern! Try again.';
          _selectedDots.clear();
        });
      }
    }
  }

  int? _getDotAtPosition(Offset pos, BoxConstraints constraints) {
    final size = math.min(constraints.maxWidth, constraints.maxHeight);
    final dotRadius = size / 7; // touch target threshold

    for (int i = 0; i < 9; i++) {
      final center = _getDotCenter(i, size);
      if ((pos - center).distance <= dotRadius) {
        return i;
      }
    }
    return null;
  }

  Offset _getDotCenter(int index, double size) {
    final col = index % 3;
    final row = index ~/ 3;
    final step = size / 3;
    return Offset(
      col * step + step / 2,
      row * step + step / 2,
    );
  }

  void _showMathFallbackDialog() {
    final rand = math.Random();
    final a = rand.nextInt(9) + 7;
    final b = rand.nextInt(8) + 6;
    final correct = a * b;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🧮 ', style: TextStyle(fontSize: 22)),
            Text(
              'Parent Math Verification',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parent verification question:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$a × $b = ?',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Enter answer',
                hintStyle: GoogleFonts.inter(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (int.tryParse(controller.text.trim()) == correct) {
                Navigator.pop(ctx);
                widget.onResult?.call(true);
              } else {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect answer!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Text('VERIFY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.mode == PatternLockMode.setup
                    ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.mode == PatternLockMode.setup
                    ? Icons.lock_reset_rounded
                    : Icons.lock_outline_rounded,
                color: widget.mode == PatternLockMode.setup
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF38BDF8),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.title ?? (widget.mode == PatternLockMode.setup ? 'Parent Pattern' : 'Verify Pattern'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.subtitle ?? 'Draw pattern to continue',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),

        // Status banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _isError
                ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                : (_isSuccess
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : const Color(0xFF1E293B)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isError
                  ? const Color(0xFFEF4444)
                  : (_isSuccess
                      ? const Color(0xFF10B981)
                      : Colors.white12),
              width: 1,
            ),
          ),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: _isError
                  ? const Color(0xFFFCA5A5)
                  : (_isSuccess
                      ? const Color(0xFF6EE7B7)
                      : const Color(0xFF38BDF8)),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Interactive 3x3 pattern grid
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: (d) => _handlePanStart(d, constraints),
                  onPanUpdate: (d) => _handlePanUpdate(d, constraints),
                  onPanEnd: _handlePanEnd,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _PatternLockPainter(
                      selectedDots: _selectedDots,
                      currentTouch: _currentTouch,
                      isError: _isError,
                      isSuccess: _isSuccess,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Actions: Cancel & Forgot / Reset
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => widget.onResult?.call(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (widget.mode == PatternLockMode.verify)
              TextButton.icon(
                onPressed: _showMathFallbackDialog,
                icon: const Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
                label: Text(
                  'Parent Math Pass',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    _setupStep = 1;
                    _firstDrawnPattern = '';
                    _selectedDots.clear();
                    _resetStatus();
                  });
                },
                child: Text(
                  'Reset',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PatternLockPainter extends CustomPainter {
  final List<int> selectedDots;
  final Offset? currentTouch;
  final bool isError;
  final bool isSuccess;

  _PatternLockPainter({
    required this.selectedDots,
    required this.currentTouch,
    required this.isError,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double step = size.width / 3;

    Color themeColor;
    if (isError) {
      themeColor = const Color(0xFFEF4444);
    } else if (isSuccess) {
      themeColor = const Color(0xFF10B981);
    } else {
      themeColor = const Color(0xFF38BDF8);
    }

    final linePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.85)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotCenters = List.generate(9, (index) {
      final col = index % 3;
      final row = index ~/ 3;
      return Offset(col * step + step / 2, row * step + step / 2);
    });

    // 1. Draw connecting lines between selected dots
    if (selectedDots.length > 1) {
      final path = Path();
      path.moveTo(dotCenters[selectedDots[0]].dx, dotCenters[selectedDots[0]].dy);
      for (int i = 1; i < selectedDots.length; i++) {
        path.lineTo(dotCenters[selectedDots[i]].dx, dotCenters[selectedDots[i]].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 2. Draw line from last selected dot to current touch position
    if (selectedDots.isNotEmpty && currentTouch != null) {
      final last = dotCenters[selectedDots.last];
      canvas.drawLine(last, currentTouch!, linePaint);
    }

    // 3. Draw dots
    for (int i = 0; i < 9; i++) {
      final center = dotCenters[i];
      final isSelected = selectedDots.contains(i);

      if (isSelected) {
        // Glowing halo
        final haloPaint = Paint()
          ..color = themeColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 24, haloPaint);

        // Ring
        final ringPaint = Paint()
          ..color = themeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, 18, ringPaint);

        // Inner solid dot
        final activeDotPaint = Paint()
          ..color = themeColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 7.5, activeDotPaint);
      } else {
        // Inactive subtle dot
        final outerRing = Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 14, outerRing);

        final dotPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 5.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternLockPainter oldDelegate) {
    return oldDelegate.selectedDots != selectedDots ||
        oldDelegate.currentTouch != currentTouch ||
        oldDelegate.isError != isError ||
        oldDelegate.isSuccess != isSuccess;
  }
}
