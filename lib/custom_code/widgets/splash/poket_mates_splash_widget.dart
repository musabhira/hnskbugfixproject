import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ⚡ Minimal, Curiosity-Driven Brand Splash Screen for Poket Mates
///
/// Visualizes the brand's core philosophy from the very first second:
/// "Notice something missing? Why did we drop the 'C'?"
/// - Strike through 'C'
/// - "No Classroom • No Comparison • Just Mates"
///
/// 100% Native 60/120 FPS Flutter animation with zero startup delay or external lag.
class PoketMatesBrandSplashScreen extends StatefulWidget {
  const PoketMatesBrandSplashScreen({super.key});

  @override
  State<PoketMatesBrandSplashScreen> createState() =>
      _PoketMatesBrandSplashScreenState();
}

class _PoketMatesBrandSplashScreenState
    extends State<PoketMatesBrandSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _strikeAnim;
  late Animation<double> _taglineFadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Phase 1 (0 -> 40%): Elements smoothly fade and slide up
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
    );

    // Phase 2 (40% -> 70%): Slashes across 'C' with tactile effect
    _strikeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.40, 0.70, curve: Curves.easeInOut),
    );

    // Phase 3 (65% -> 100%): Tagline reveals
    _taglineFadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A0E1A), // Deep immersive luxury midnight
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // 🌟 App Icon with soft ambient aura
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                            blurRadius: 36,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/pocket_mates_logo.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text('⚡', style: TextStyle(fontSize: 42)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🔤 Animated Wordmark: P O [C] K E T   M A T E S
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "PO"
                        Text(
                          'PO',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),

                        // Animated "[C]" with strike-through slash
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                'C',
                                style: GoogleFonts.outfit(
                                  color: Color.lerp(
                                    const Color(0xFFEF4444),
                                    Colors.white24,
                                    _strikeAnim.value,
                                  ),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            // Red strike-through line
                            CustomPaint(
                              size: const Size(22, 28),
                              painter: _StrikeLinePainter(progress: _strikeAnim.value),
                            ),
                          ],
                        ),

                        // "KET"
                        Text(
                          'KET',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),

                        const SizedBox(width: 10),

                        // "MATES"
                        Text(
                          'MATES',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFF59E0B),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 🌿 Minimal Curiosity Tagline
                  FadeTransition(
                    opacity: _taglineFadeAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'No Classroom • No Comparison • Just Mates',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // ⏳ Minimal Subtle Progress Indicator
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SizedBox(
                      width: 32,
                      height: 2.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          color: Color(0xFFF59E0B),
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter to draw an animated diagonal slash through the letter 'C'
class _StrikeLinePainter extends CustomPainter {
  final double progress;

  _StrikeLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final startX = size.width * 0.1;
    final startY = size.height * 0.85;

    final targetX = size.width * 0.9;
    final targetY = size.height * 0.15;

    final currentX = startX + (targetX - startX) * progress;
    final currentY = startY + (targetY - startY) * progress;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(currentX, currentY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikeLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
