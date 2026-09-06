import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flame_avatar_widget.dart';
import 'nft_trading_card_dialog.dart';
import 'vector_avatar_config.dart';
import 'jackie_chan_talisman_service.dart';
import '../learning_60day/learning_models.dart';

/// 🌟 Dynamic Flame-Powered Profile Banner Game Loop
/// Manages floating animated biome doodles, glowing ember particles,
/// and interactive tap bursts adapted to the user's active avatar!
class FlameProfileBannerGame extends FlameGame with TapCallbacks {
  VectorAvatarConfig config;
  final int stage;
  final VoidCallback? onBannerTapped;

  double _elapsedTime = 0.0;
  final List<_BannerDoodle> _doodles = [];
  final List<_BannerParticle> _particles = [];
  final math.Random _random = math.Random();

  FlameProfileBannerGame({
    required this.config,
    required this.stage,
    this.onBannerTapped,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  void updateData({required VectorAvatarConfig newConfig}) {
    config = newConfig;
  }

  @override
  void onMount() {
    super.onMount();
    _spawnInitialDoodles();
  }

  void _spawnInitialDoodles() {
    _doodles.clear();
    final count = 10;
    for (int i = 0; i < count; i++) {
      _doodles.add(
        _BannerDoodle(
          x: _random.nextDouble() * (size.x > 0 ? size.x : 380),
          y: _random.nextDouble() * (size.y > 0 ? size.y : 220),
          vx: (_random.nextDouble() - 0.5) * 16.0,
          vy: -8.0 - _random.nextDouble() * 12.0,
          size: 10.0 + _random.nextDouble() * 14.0,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 1.5,
          color: _getDoodleColor(),
          type: _getDoodleTypeForSpecies(config.species),
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  Color _getDoodleColor() {
    final accent = VectorAvatarConfig.parseHex(
      config.outfitAccentColor,
      fallback: const Color(0xFFFFFC00),
    );
    final aura = VectorAvatarConfig.parseHex(
      config.skinColor,
      fallback: const Color(0xFF38BDF8),
    );
    return (_random.nextBool()) ? accent : aura;
  }

  String _getDoodleTypeForSpecies(String species) {
    final s = species.toLowerCase();
    if (s.contains('cat') || s.contains('tiger') || s.contains('lion') || s.contains('leopard') || s.contains('cheetah') || s.contains('jaguar') || s.contains('panther')) {
      return 'paw';
    } else if (s.contains('wolf') || s.contains('fox') || s.contains('hound') || s.contains('cerberus')) {
      return 'paw';
    } else if (s.contains('eagle') || s.contains('falcon') || s.contains('owl') || s.contains('phoenix') || s.contains('pegasus') || s.contains('roc') || s.contains('bird')) {
      return 'feather';
    } else if (s.contains('shark') || s.contains('orca') || s.contains('kraken') || s.contains('ray') || s.contains('narwhal') || s.contains('walrus') || s.contains('seahorse') || s.contains('jellyfish')) {
      return 'bubble';
    } else if (s.contains('dragon') || s.contains('titan') || s.contains('hydra') || s.contains('chimera') || s.contains('basilisk') || stage >= 80) {
      return 'dragon_rune';
    } else if (s.contains('panda') || s.contains('sloth') || s.contains('bear') || s.contains('ape') || s.contains('gorilla')) {
      return 'zen_leaf';
    }
    return 'sparkle_star';
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    if (!hasLayout || size.x <= 0 || size.y <= 0) return;

    // Update floating doodles
    final w = size.x;
    final h = size.y;

    for (final d in _doodles) {
      d.x += (d.vx + math.sin(_elapsedTime * 1.5 + d.phase) * 10.0) * dt;
      d.y += d.vy * dt;
      d.rotation += d.rotationSpeed * dt;

      // Wrap around seamlessly
      if (d.y < -30) {
        d.y = h + 20;
        d.x = _random.nextDouble() * w;
      }
      if (d.x < -30) d.x = w + 20;
      if (d.x > w + 30) d.x = -20;
    }

    // Update tap & ember particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (!_particles[i].isAlive) {
        _particles.removeAt(i);
      }
    }

    // Ambient floating embers rising from the bottom
    if (_particles.length < 18 && _random.nextDouble() < 0.35) {
      final accent = VectorAvatarConfig.parseHex(
        config.outfitAccentColor,
        fallback: const Color(0xFFFFD700),
      );
      _particles.add(
        _BannerParticle(
          x: _random.nextDouble() * w,
          y: h + 10,
          vx: (_random.nextDouble() - 0.5) * 20.0,
          vy: -30.0 - _random.nextDouble() * 40.0,
          color: (_random.nextBool()) ? accent : Colors.white.withValues(alpha: 0.9),
          size: 2.0 + _random.nextDouble() * 3.5,
          lifespan: 1.2 + _random.nextDouble() * 1.0,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (!hasLayout || size.x <= 0 || size.y <= 0) return;

    super.render(canvas);

    // 1. Render Floating Biome Doodles
    for (final d in _doodles) {
      final alpha = (0.35 + math.sin(_elapsedTime * 2.0 + d.phase) * 0.15).clamp(0.1, 0.7);
      final paint = Paint()
        ..color = d.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(d.x, d.y);
      canvas.rotate(d.rotation);

      switch (d.type) {
        case 'paw':
          _drawPaw(canvas, d.size, paint);
          break;
        case 'feather':
          _drawFeather(canvas, d.size, paint);
          break;
        case 'bubble':
          _drawBubble(canvas, d.size, paint);
          break;
        case 'dragon_rune':
          _drawDragonRune(canvas, d.size, paint);
          break;
        case 'zen_leaf':
          _drawLeaf(canvas, d.size, paint);
          break;
        default:
          _drawStar(canvas, d.size, paint);
      }

      canvas.restore();
    }

    // 2. Render Flame Particles & Tap Bursts
    for (final p in _particles) {
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (p.lifeProgress * 0.85).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.lifeProgress, pPaint);
    }
  }

  void _drawPaw(Canvas canvas, double s, Paint paint) {
    final r = s * 0.38;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.6), paint);
    // 3 upper toe pads
    canvas.drawCircle(Offset(-r * 0.8, -r * 0.9), r * 0.35, paint);
    canvas.drawCircle(Offset(0, -r * 1.2), r * 0.38, paint);
    canvas.drawCircle(Offset(r * 0.8, -r * 0.9), r * 0.35, paint);
  }

  void _drawFeather(Canvas canvas, double s, Paint paint) {
    final path = Path();
    path.moveTo(0, -s);
    path.quadraticBezierTo(s * 0.5, -s * 0.2, 0, s);
    path.quadraticBezierTo(-s * 0.5, -s * 0.2, 0, -s);
    canvas.drawPath(path, paint);
  }

  void _drawBubble(Canvas canvas, double s, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.6;
    canvas.drawCircle(Offset.zero, s * 0.6, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-s * 0.2, -s * 0.2), s * 0.15, paint);
  }

  void _drawDragonRune(Canvas canvas, double s, Paint paint) {
    // Shimmering diamond rune
    final path = Path();
    path.moveTo(0, -s);
    path.lineTo(s * 0.65, 0);
    path.lineTo(0, s);
    path.lineTo(-s * 0.65, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLeaf(Canvas canvas, double s, Paint paint) {
    final path = Path();
    path.moveTo(0, -s);
    path.cubicTo(s * 0.8, -s * 0.5, s * 0.6, s * 0.5, 0, s);
    path.cubicTo(-s * 0.6, s * 0.5, -s * 0.8, -s * 0.5, 0, -s);
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, double s, Paint paint) {
    final path = Path();
    path.moveTo(0, -s);
    path.lineTo(s * 0.25, -s * 0.25);
    path.lineTo(s, 0);
    path.lineTo(s * 0.25, s * 0.25);
    path.lineTo(0, s);
    path.lineTo(-s * 0.25, s * 0.25);
    path.lineTo(-s, 0);
    path.lineTo(-s * 0.25, -s * 0.25);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    HapticFeedback.mediumImpact();

    if (!hasLayout || size.x <= 0 || size.y <= 0) return;

    final tapPos = Offset(event.localPosition.x, event.localPosition.y);
    final accent = VectorAvatarConfig.parseHex(
      config.outfitAccentColor,
      fallback: const Color(0xFFFFFC00),
    );

    // Burst 24 energetic Flame sparks
    for (int i = 0; i < 24; i++) {
      final angle = (i * math.pi * 2 / 24) + (_random.nextDouble() * 0.25);
      final speed = 40.0 + _random.nextDouble() * 90.0;
      _particles.add(
        _BannerParticle(
          x: tapPos.dx,
          y: tapPos.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: (i % 2 == 0) ? accent : const Color(0xFF00F0FF),
          size: 3.5 + _random.nextDouble() * 3.5,
          lifespan: 0.6 + _random.nextDouble() * 0.5,
        ),
      );
    }

    onBannerTapped?.call();
  }
}

class _BannerDoodle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  String type;
  double phase;

  _BannerDoodle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.type,
    required this.phase,
  });
}

class _BannerParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double lifespan;
  double remainingLife;

  _BannerParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.lifespan,
  }) : remainingLife = lifespan;

  bool get isAlive => remainingLife > 0;
  double get lifeProgress => (remainingLife / lifespan).clamp(0.0, 1.0);

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    remainingLife -= dt;
  }
}

/// 🌟 Flame-Powered Profile Banner Widget
/// Renders scenic landscape biome art overlaid with an interactive Flame game canvas,
/// dynamic avatar-themed floating doodles, and the active 90-day in-game fortress perk badge!
class FlameProfileBannerWidget extends StatefulWidget {
  final int day;
  final LearningMilestoneStage stage;
  final VectorAvatarConfig avatar;
  final String? userId;
  final bool isMe;
  final String? equippedTalismanId;
  final Function(String talismanId)? onTalismanChanged;
  final Widget? background;

  const FlameProfileBannerWidget({
    super.key,
    required this.day,
    required this.stage,
    required this.avatar,
    this.userId,
    this.isMe = false,
    this.equippedTalismanId,
    this.onTalismanChanged,
    this.background,
  });

  @override
  State<FlameProfileBannerWidget> createState() => _FlameProfileBannerWidgetState();
}

class _FlameProfileBannerWidgetState extends State<FlameProfileBannerWidget> {
  late FlameProfileBannerGame _game;

  @override
  void initState() {
    super.initState();
    _game = FlameProfileBannerGame(
      config: widget.avatar,
      stage: widget.day,
      onBannerTapped: () {},
    );
  }

  @override
  void didUpdateWidget(covariant FlameProfileBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar != widget.avatar || oldWidget.day != widget.day) {
      _game.updateData(newConfig: widget.avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final speciesTitle = widget.avatar.species
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.day);

    return Container(
      decoration: VectorAvatarConfig.getEvolutionBannerDecoration(widget.day),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 0. Scenic Biome Landscape Art Background (if provided)
          if (widget.background != null)
            Positioned.fill(child: widget.background!),

          // 1. Live Flame-Powered Canvas (Floating Biome Doodles & Embers)
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 2. Top Header HUD: Active Companion & Active Perk Badge
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Active Fortress Perk Pill
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          perk.badgeColor.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: perk.badgeColor.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: perk.badgeColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(perk.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            perk.shortBadgeText.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Active Companion Stage Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.stage.buttonColor.withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'DAY ${widget.day}/90',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Luxury Holographic Showcase Pedestal Card (Bottom)
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                NftTradingCardDialog.show(
                  context,
                  day: widget.day,
                  config: widget.avatar,
                  userId: widget.userId,
                  isOwner: widget.isMe,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.90),
                      const Color(0xFF0F172A).withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.stage.buttonColor.withValues(alpha: 0.8),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.stage.buttonColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Live Flame Engine Animated Avatar Preview
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.stage.buttonColor.withValues(alpha: 0.85),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.stage.buttonColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: FlameAvatarWidget(
                          config: widget.avatar,
                          size: 50,
                          showAura: true,
                          isInteractive: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Companion Name, Tier & Perk
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.stage.fluencyTier,
                                style: GoogleFonts.outfit(
                                  color: widget.stage.buttonColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: perk.badgeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  perk.title,
                                  style: TextStyle(
                                    color: perk.badgeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            speciesTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Actions: NFT Card & Jackie Chan Talisman
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View NFT Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            NftTradingCardDialog.show(
                              context,
                              day: widget.day,
                              config: widget.avatar,
                              userId: widget.userId,
                              isOwner: widget.isMe,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.stage.buttonColor.withValues(alpha: 0.85),
                                  const Color(0xFF0284C7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('💎', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'NFT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Zodiac Talisman Button
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await JackieChanTalismanVaultModal.show(context, currentDay: widget.day);
                            final talisman = await JackieChanTalismanService.getEquippedTalisman();
                            widget.onTalismanChanged?.call(talisman.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDC2626), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  kJackieChanTalismans.firstWhere(
                                    (t) => t.id == (widget.equippedTalismanId ?? 'rabbit'),
                                    orElse: () => kJackieChanTalismans.first,
                                  ).emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'VAULT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}
