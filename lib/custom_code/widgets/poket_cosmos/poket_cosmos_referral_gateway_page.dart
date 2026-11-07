import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'poket_cosmos_born_address_page.dart';

/// 🌌 Full-Screen Gateway: Citizen Referral Verification & Destiny Entry
/// Prompts the user before the 4-Stage Born Ceremony:
/// - "DO YOU HAVE AN ISLAND REFERRAL CODE?"
/// - If YES: Verifies host's exact Planet, Island & reserves adjacent Neighbor Plot.
/// - If NO: Automatically routes through the 100-Crore "House Full" Wave Engine.
class PoketCosmosReferralGatewayPage extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final int? userAge;

  const PoketCosmosReferralGatewayPage({
    super.key,
    required this.userName,
    this.userAvatar = '🦁',
    this.userAge,
  });

  static Future<void> launch(
    BuildContext context, {
    required String userName,
    String userAvatar = '🦁',
    int? userAge,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim, _) => FadeTransition(
          opacity: anim,
          child: PoketCosmosReferralGatewayPage(
            userName: userName,
            userAvatar: userAvatar,
            userAge: userAge,
          ),
        ),
      ),
    );
  }

  @override
  State<PoketCosmosReferralGatewayPage> createState() =>
      _PoketCosmosReferralGatewayPageState();
}

class _PoketCosmosReferralGatewayPageState
    extends State<PoketCosmosReferralGatewayPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _starAnimController;

  bool _isCheckingCode = false;
  bool _showCodeInput = false;
  String? _validationError;
  NeighborReservationPass? _resolvedPass;

  @override
  void initState() {
    super.initState();
    _starAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}
  }

  @override
  void dispose() {
    _codeController.dispose();
    _starAnimController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndEnter() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _validationError = 'Please enter a referral code');
      return;
    }

    setState(() {
      _isCheckingCode = true;
      _validationError = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final pass = await PoketCosmosAllocationService.instance
          .validateNeighborInviteCode(code);

      if (pass != null) {
        PocketGameAudioService.instance.playVictorySfx();
        setState(() {
          _resolvedPass = pass;
          _isCheckingCode = false;
        });

        // Quick 700ms success presentation before entering ceremony
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;

        _proceedToCeremony(inviteCode: pass.code);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _validationError = 'Invalid or expired code. Try PKT-TEST or PKT-JUPITER!';
          _isCheckingCode = false;
        });
      }
    } catch (e) {
      setState(() {
        _validationError = 'Verification failed. Please try again.';
        _isCheckingCode = false;
      });
    }
  }

  void _proceedToCeremony({String? inviteCode}) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, anim, _) => FadeTransition(
          opacity: anim,
          child: PoketCosmosBornAddressPage(
            userName: widget.userName,
            userAvatar: widget.userAvatar,
            userAge: widget.userAge,
            initialInviteCode: inviteCode,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Animated Cosmic Starlight & Deep Space Atmosphere
          AnimatedBuilder(
            animation: _starAnimController,
            builder: (context, _) {
              return CustomPaint(
                painter: _CosmicGatewayBackdropPainter(
                  animValue: _starAnimController.value,
                ),
              );
            },
          ),

          // 2. Top Navigation Bar (Close Chevron & Audio BGM Toggle)
          Positioned(
            top: topPad + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable:
                      PocketGameAudioService.instance.isMutedNotifier,
                  builder: (context, isMuted, _) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        PocketGameAudioService.instance.toggleMute();
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !isMuted
                                ? const Color(0xFF38BDF8)
                                : Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            !isMuted
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: !isMuted
                                ? const Color(0xFF38BDF8)
                                : Colors.white60,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Central Interactive Content Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cosmic Floating Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF34D399).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪐', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'POCKET COSMOS • CITIZEN LEDGER',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF86EFAC),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      'DO YOU HAVE A\nREFERRAL CODE?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Got an invite from a friend? Enter their code to be born on their exact planet & reserve an adjacent neighbor plot!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Interactive Verification Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _showCodeInput
                              ? const Color(0xFF10B981).withValues(alpha: 0.8)
                              : Colors.white12,
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!_showCodeInput) ...[
                            // Button A: "YES, I HAVE A CODE"
                            _buildChoiceButton(
                              label: 'YES, I HAVE A CODE 🎟️',
                              isPrimary: true,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _showCodeInput = true);
                              },
                            ),
                            const SizedBox(height: 12),
                            // Button B: "NO, ASSIGN MY DESTINY ➔"
                            _buildChoiceButton(
                              label: 'NO, ASSIGN MY DESTINY ➔',
                              isPrimary: false,
                              onTap: () => _proceedToCeremony(),
                            ),
                          ] else ...[
                            // Code Input Field
                            TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF86EFAC),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'E.G. PKT-TEST',
                                hintStyle: GoogleFonts.outfit(
                                  color: Colors.white24,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF050B14),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF10B981), width: 1.2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.6),
                                      width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF34D399), width: 2.0),
                                ),
                              ),
                              onSubmitted: (_) => _verifyAndEnter(),
                            ),

                            if (_validationError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _validationError!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFEF4444),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            if (_resolvedPass != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF065F46).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF34D399), width: 1.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF86EFAC), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Neighbor Slot: ${_resolvedPass!.planetName} • Plot #${_resolvedPass!.plotNumber}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Submit Button
                            _buildChoiceButton(
                              label: _isCheckingCode
                                  ? 'VERIFYING DESTINY...'
                                  : 'VERIFY & ENTER COSMOS 🚀',
                              isPrimary: true,
                              isLoading: _isCheckingCode,
                              onTap: _isCheckingCode ? null : _verifyAndEnter,
                            ),

                            const SizedBox(height: 10),

                            // Quick test pills
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTestPill('PKT-TEST'),
                                const SizedBox(width: 8),
                                _buildTestPill('PKT-JUPITER'),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Back to "I don't have a code"
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showCodeInput = false;
                                  _validationError = null;
                                });
                              },
                              child: Text(
                                'I don\'t have a code — Assign my destiny',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool isPrimary,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPrimary ? const Color(0xFF1E293B) : null,
        border: Border.all(
          color: isPrimary ? const Color(0xFF34D399) : Colors.white24,
          width: 1.4,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildTestPill(String code) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _codeController.text = code;
          _validationError = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Text(
          'Try: $code',
          style: GoogleFonts.outfit(
            color: const Color(0xFF38BDF8),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 🎨 Cosmic Deep-Space Backdrop Painter with Animated Twinkling Stars
class _CosmicGatewayBackdropPainter extends CustomPainter {
  final double animValue;

  _CosmicGatewayBackdropPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // Deep Obsidian Radial Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 1.1,
        colors: const [
          Color(0xFF0F172A), // Cosmic Slate
          Color(0xFF090E17),
          Color(0xFF030712), // Abyssal Space
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Cosmic Stars
    final starPaint = Paint()..color = Colors.white;
    final r = math.Random(1337);
    for (int i = 0; i < 90; i++) {
      final sx = r.nextDouble() * w;
      final sy = r.nextDouble() * h;
      final rad = 0.6 + r.nextDouble() * 1.4;
      final twinkle = 0.3 + 0.7 * math.sin(animValue * 2 * math.pi + i * 0.4).abs();
      canvas.drawCircle(
        Offset(sx, sy),
        rad,
        starPaint..color = Colors.white.withValues(alpha: (0.2 + 0.6 * twinkle).clamp(0.1, 0.9)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicGatewayBackdropPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}
