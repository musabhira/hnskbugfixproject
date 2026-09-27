import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'pocket_score_level_engine.dart';

/// 🏰 Ultra-Premium Animated House Evolution & Level Up Dialog
/// User Audio Directive:
/// "ഡിഫൻസ് ആഡ് ചെയ്ത് സേവ് കൊടുത്തു കഴിഞ്ഞാൽ ഓട്ടോമാറ്റിക്കലി അനിമേറ്റഡ് ആയിട്ട്
///  ഇവരുടെ രണ്ടാമത്തെ ലെവൽ അച്ചീവ് ചെയ്യുക. അനിമേറ്റഡ് ആയിട്ട് രണ്ടാമത്തെ ലെവലിലുള്ള വീട് കാണിക്കും
///  - ഫസ്റ്റത്തെ വീടിൽ നിന്ന് ഗ്രോത്ത് ആയതിന്റെ ഒരു ഫീൽ കിട്ടാൻ വേണ്ടിയിട്ട്! ആ ഒരു ഫീൽ കൊടുക്കണം."
class PocketHouseEvolutionDialog extends StatefulWidget {
  final int fromLevel;
  final int toLevel;
  final VoidCallback? onCompleted;

  const PocketHouseEvolutionDialog({
    super.key,
    required this.fromLevel,
    required this.toLevel,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int fromLevel,
    required int toLevel,
    VoidCallback? onCompleted,
  }) async {
    HapticFeedback.heavyImpact();
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'HouseEvolution',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) => PocketHouseEvolutionDialog(
        fromLevel: fromLevel,
        toLevel: toLevel,
        onCompleted: onCompleted,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PocketHouseEvolutionDialog> createState() => _PocketHouseEvolutionDialogState();
}

class _PocketHouseEvolutionDialogState extends State<PocketHouseEvolutionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isEvolved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.45, curve: Curves.easeInOut)),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));

    _controller.forward();

    // Trigger haptic and evolution switch at peak of sequence
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() => _isEvolved = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getHouseTitle(int lvl) {
    if (lvl <= 1) return 'Wooden Cabin';
    if (lvl <= 7) return 'Brick Villa';
    if (lvl <= 20) return 'Stone Fortress';
    if (lvl <= 45) return 'Imperial Manor';
    if (lvl <= 70) return 'Cyber Citadel';
    if (lvl <= 89) return 'Titanium Bastion';
    return 'Supreme Sovereign Palace';
  }

  String _getHouseEmoji(int lvl) {
    if (lvl <= 1) return '🌱';
    if (lvl <= 7) return '🏡';
    if (lvl <= 20) return '🏰';
    if (lvl <= 45) return '🏛️';
    if (lvl <= 70) return '💎';
    if (lvl <= 89) return '👑';
    return '⚔️';
  }

  @override
  Widget build(BuildContext context) {
    final fromAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(widget.fromLevel);
    final toAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(widget.toLevel);
    final oldTitle = _getHouseTitle(widget.fromLevel);
    final newTitle = _getHouseTitle(widget.toLevel);
    final oldEmoji = _getHouseEmoji(widget.fromLevel);
    final newEmoji = _getHouseEmoji(widget.toLevel);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: math.min(380, MediaQuery.of(context).size.width - 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E1B4B),
                Color(0xFF0F172A),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 36,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏆 Top Ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'FORTRESS DEFENSE ARMED!',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'HOUSE ARCHITECTURE EVOLVED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your fortress grew stronger after locking in your defense questions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // 🏡 Interactive House Morph Animation Stage
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radiant Golden Pulse Rings
                      Container(
                        width: 140 + (_glowAnimation.value * 24),
                        height: 140 + (_glowAnimation.value * 24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.3 * _glowAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      // Avatar container with bounce scale
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isEvolved ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                              width: 3,
                            ),
                            gradient: RadialGradient(
                              colors: [
                                (_isEvolved ? const Color(0xFFFFD700) : const Color(0xFF0284C7)).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: ClipOval(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder: (child, anim) {
                                return RotationTransition(
                                  turns: Tween<double>(begin: -0.15, end: 0.0).animate(anim),
                                  child: ScaleTransition(scale: anim, child: child),
                                );
                              },
                              child: _isEvolved
                                  ? VectorAvatarWidget(key: const ValueKey('evolved'), config: toAvatar, size: 108)
                                  : VectorAvatarWidget(key: const ValueKey('base'), config: fromAvatar, size: 108),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // 🏷️ Morph Level Label: Old -> New
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$oldEmoji Level ${widget.fromLevel} ($oldTitle)',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white38,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFD700), size: 16),
                    ),
                    Text(
                      '$newEmoji Level ${widget.toLevel} ($newTitle)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 📊 Stats Upgrade Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      icon: '🛡️',
                      label: 'Fortress Defense Gate',
                      value: 'Gate ${PocketScoreLevelEngine.getGatesCountForLevel(widget.toLevel)} Armed ✓',
                      color: const Color(0xFF10B981),
                    ),
                    const Divider(color: Colors.white10, height: 12),
                    _buildStatRow(
                      icon: '🪙',
                      label: 'Pocket Score Goal',
                      value: 'PS ${PocketScoreLevelEngine.getRequiredScoreForLevel(widget.toLevel)}',
                      color: const Color(0xFFFFD700),
                    ),
                    const Divider(color: Colors.white10, height: 12),
                    _buildStatRow(
                      icon: '🏰',
                      label: 'Architecture Tier',
                      value: newTitle,
                      color: const Color(0xFF38BDF8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 🚀 Proceed Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    widget.onCompleted?.call();
                  },
                  child: Text(
                    'ENTER LEVEL ${widget.toLevel} ADVENTURE 🚀',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(color: color, fontSize: 11.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
