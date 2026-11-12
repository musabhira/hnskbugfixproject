import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

/// 🔋 Minimalist iPhone-Style Daily Battery Reward Button
/// Placed right above the "Mission" button with the exact same size & minimal setup.
/// Features 5 segments:
/// - 0/5: Red Battery Low
/// - 1/5: Red Low
/// - 2/5: Yellow/Amber
/// - 3/5 & 4/5: Green
/// - 5/5: 100% Full Charge
/// - Live 60-second cooldown timer between rewarded videos.
class PocketDailyBatteryRewardWidget extends StatefulWidget {
  final VoidCallback? onRewardClaimed;

  const PocketDailyBatteryRewardWidget({super.key, this.onRewardClaimed});

  @override
  State<PocketDailyBatteryRewardWidget> createState() =>
      _PocketDailyBatteryRewardWidgetState();
}

class _PocketDailyBatteryRewardWidgetState
    extends State<PocketDailyBatteryRewardWidget>
    with SingleTickerProviderStateMixin {
  int _dailyCount = 0;
  int _cooldownSeconds = 0;
  bool _isVip = false;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _refreshState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshState() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    final count = await PocketAdMobService.instance.getRewardedDailyCount();
    final cooldown =
        await PocketAdMobService.instance.getRewardedCooldownRemainingSeconds();

    if (mounted) {
      setState(() {
        _isVip = vip;
        _dailyCount = count;
        _cooldownSeconds = cooldown;
      });
      _startCountdownIfNeeded();
    }
  }

  void _startCountdownIfNeeded() {
    _countdownTimer?.cancel();
    if (_cooldownSeconds > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_cooldownSeconds > 1) {
            _cooldownSeconds--;
          } else {
            _cooldownSeconds = 0;
            timer.cancel();
          }
        });
      });
    }
  }

  Future<void> _onWidgetTapped() async {
    HapticFeedback.mediumImpact();

    if (_isVip) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👑 VIP Gold: Battery is permanently 100% full!'),
          backgroundColor: Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_cooldownSeconds > 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⏳', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Battery cooling down. Next recharge in ${_cooldownSeconds}s!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_dailyCount >= 10) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text('🔋', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily battery 100% full (10/10)! Resets tomorrow morning ☀️',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF065F46),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 👑 VIP Direct Instant Score Grant (No Ad required!)
    if (_isVip) {
      final newScore =
          await PocketAdMobService.instance.grantRewardedPocketScore();
      await _refreshState();
      widget.onRewardClaimed?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'VIP Instant Reward! +30 Pocket Score granted without ads (Total: $newScore PS) ⚡✨',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Directly launch Rewarded Video Ad cleanly for Free users
    await PocketAdMobService.instance.showRewardedAd(
      context: context,
      onUserEarnedReward: (reward) async {
        final newScore =
            await PocketAdMobService.instance.grantRewardedPocketScore();
        await _refreshState();
        widget.onRewardClaimed?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Battery recharged! +30 Pocket Score added (Total: $newScore PS) 🔋✨',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isVip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIP Gold',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '100% Full',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Determine colors and 2-line minimal texts
    Color batteryColor;
    String topTitle;
    String bottomSub;
    Color subColor;
    bool shouldPulse = false;

    if (_cooldownSeconds > 0) {
      batteryColor = const Color(0xFF38BDF8); // Cyan cooldown
      topTitle = 'Cooling ⏳';
      bottomSub = 'Wait ${_cooldownSeconds}s';
      subColor = const Color(0xFF38BDF8);
    } else if (_dailyCount >= 10) {
      batteryColor = const Color(0xFF22C55E); // Green Full
      topTitle = 'Daily Full 🔋';
      bottomSub = '10/10 • Reset ☀️';
      subColor = const Color(0xFF4ADE80);
    } else {
      // ⚡ Available to watch rewarded video for +50 PS!
      shouldPulse = true;
      if (_dailyCount == 0) {
        batteryColor = const Color(0xFFFFD700); // Golden Amber
      } else if (_dailyCount <= 3) {
        batteryColor = const Color(0xFFF59E0B);
      } else if (_dailyCount <= 6) {
        batteryColor = const Color(0xFFFBBF24);
      } else {
        batteryColor = const Color(0xFF10B981);
      }
      topTitle = _isVip ? 'Claim Reward' : 'Watch Reward';
      bottomSub = '+30 PS (${_dailyCount}/10)';
      subColor = const Color(0xFFFFD700); // Yellow/Golden score callout
    }

    Widget pillContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: batteryColor.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: [
          if (shouldPulse)
            BoxShadow(
              color: batteryColor.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔋 10-block battery icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 12,
                padding: const EdgeInsets.all(1.2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: batteryColor, width: 1.1),
                ),
                child: Row(
                  children: List.generate(10, (index) {
                    final isFilled = index < _dailyCount;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 9 ? 0.6 : 0),
                        decoration: BoxDecoration(
                          color: isFilled ? batteryColor : Colors.white12,
                          borderRadius: BorderRadius.circular(0.8),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Battery Terminal Tip
              Container(
                width: 2.0,
                height: 5.0,
                margin: const EdgeInsets.only(left: 1.0),
                decoration: BoxDecoration(
                  color: batteryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(1.0),
                    bottomRight: Radius.circular(1.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 7),

          // 2-Line Minimal Clean Text (Watch Reward / +50 PS)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topTitle,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                bottomSub,
                style: GoogleFonts.outfit(
                  color: subColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: _onWidgetTapped,
      borderRadius: BorderRadius.circular(12),
      child: shouldPulse
          ? ScaleTransition(
              scale: _pulseAnimation,
              child: pillContent,
            )
          : pillContent,
    );
  }
}
