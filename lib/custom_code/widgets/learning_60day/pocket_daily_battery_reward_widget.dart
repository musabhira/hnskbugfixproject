import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_rewarded_score_alert_modal.dart';

/// 🔋 Futuristic Daily Battery Reward Widget (User Audio Directive!)
/// Placed above the "Mission" button on Target/Roadmap page.
/// Shows Battery Low (Red, 0-2) -> Recharging (Amber, 3-4) -> Full Battery (Green, 5/5),
/// with a 60-second live cooldown timer between sponsor videos.
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
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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

  void _onWidgetTapped() {
    HapticFeedback.mediumImpact();
    if (_isVip) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👑 VIP Gold Active: Unlimited ad-free energy!'),
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
                  'Battery recharging! Next video ready in ${_cooldownSeconds}s.',
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

    if (_dailyCount >= 5) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text('🔋', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily battery 100% full! 250 PS claimed today. Resets tomorrow ☀️',
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

    // Open the full interactive Alert Modal
    PocketRewardedScoreAlertModal.show(
      context,
      onRewardClaimed: () {
        _refreshState();
        widget.onRewardClaimed?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isVip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              'VIP Energy 100%',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Determine Color & Labels based on dailyCount
    Color batteryColor;
    String statusLabel;
    bool shouldPulse = false;

    if (_cooldownSeconds > 0) {
      batteryColor = const Color(0xFF38BDF8); // Cyan cooldown
      statusLabel = '⏳ ${_cooldownSeconds}s';
    } else if (_dailyCount == 0) {
      batteryColor = const Color(0xFFEF4444); // Red
      statusLabel = 'Battery Low ⚡ +50PS';
      shouldPulse = true;
    } else if (_dailyCount <= 2) {
      batteryColor = const Color(0xFFF97316); // Orange-Red
      statusLabel = '⚡ $_dailyCount/5 • +50PS';
      shouldPulse = true;
    } else if (_dailyCount <= 4) {
      batteryColor = const Color(0xFFEAB308); // Amber
      statusLabel = '⚡ $_dailyCount/5 • +50PS';
      shouldPulse = true;
    } else {
      batteryColor = const Color(0xFF10B981); // Emerald Green
      statusLabel = '🔋 5/5 Full!';
      shouldPulse = false;
    }

    Widget pillContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: batteryColor.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: batteryColor.withValues(alpha: shouldPulse ? 0.35 : 0.15),
            blurRadius: shouldPulse ? 8 : 4,
            spreadRadius: shouldPulse ? 1 : 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔋 Micro 5-Segment Battery Shell
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 14,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: batteryColor, width: 1.2),
                ),
                child: Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < _dailyCount;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 4 ? 1.0 : 0),
                        decoration: BoxDecoration(
                          color: isFilled ? batteryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Battery Terminal Tip
              Container(
                width: 2.5,
                height: 6,
                margin: const EdgeInsets.only(left: 1.5),
                decoration: BoxDecoration(
                  color: batteryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(1.5),
                    bottomRight: Radius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),

          // Status / Cooldown Label
          Text(
            statusLabel,
            style: GoogleFonts.outfit(
              color: batteryColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: _onWidgetTapped,
      borderRadius: BorderRadius.circular(14),
      child: shouldPulse
          ? ScaleTransition(
              scale: _pulseAnimation,
              child: pillContent,
            )
          : pillContent,
    );
  }
}
