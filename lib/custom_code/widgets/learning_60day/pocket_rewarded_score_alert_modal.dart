import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';

/// 🎬 Interactive Alert Modal for Daily Rewarded Video (+50 Pocket Score) with VIP Card CTA
class PocketRewardedScoreAlertModal extends StatefulWidget {
  final VoidCallback? onRewardClaimed;

  const PocketRewardedScoreAlertModal({super.key, this.onRewardClaimed});

  /// 🌟 Shows the modal directly
  static Future<void> show(BuildContext context,
      {VoidCallback? onRewardClaimed}) async {
    final isVip = await PocketAdMobService.instance.isUserVip();
    if (isVip) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '👑 VIP Gold Active: You enjoy 100% ad-free maximum energy!'),
            backgroundColor: Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    PocketAdMobService.instance.preloadRewardedAd();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          PocketRewardedScoreAlertModal(onRewardClaimed: onRewardClaimed),
    );
  }

  /// ⏱️ Periodically checks and gracefully prompts the user (max once every 15-20 min, non-annoying)
  static Future<void> checkAndShowPeriodic(BuildContext context,
      {VoidCallback? onRewardClaimed}) async {
    final isVip = await PocketAdMobService.instance.isUserVip();
    if (isVip) return;

    final remaining =
        await PocketAdMobService.instance.getRewardedDailyRemaining();
    if (remaining <= 0) return;

    final cooldown =
        await PocketAdMobService.instance.getRewardedCooldownRemainingSeconds();
    if (cooldown > 0) return;

    final prefs = await SharedPreferences.getInstance();
    final lastModalTs = prefs.getInt('last_rewarded_modal_ts') ?? 0;
    final nowTs = DateTime.now().millisecondsSinceEpoch;

    // Throttle: Minimum 18 minutes (1080000 ms) between automatic periodic popups
    if (nowTs - lastModalTs < 18 * 60 * 1000) return;

    await prefs.setInt('last_rewarded_modal_ts', nowTs);

    if (context.mounted) {
      PocketAdMobService.instance.preloadRewardedAd();
      await show(context, onRewardClaimed: onRewardClaimed);
    }
  }

  @override
  State<PocketRewardedScoreAlertModal> createState() =>
      _PocketRewardedScoreAlertModalState();
}

class _PocketRewardedScoreAlertModalState
    extends State<PocketRewardedScoreAlertModal> {
  int _dailyCount = 0;
  int _cooldownSeconds = 0;
  bool _isLoading = true;
  bool _isWatching = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    PocketAdMobService.instance.preloadRewardedAd();
    _loadStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final count = await PocketAdMobService.instance.getRewardedDailyCount();
    final cooldown =
        await PocketAdMobService.instance.getRewardedCooldownRemainingSeconds();

    if (mounted) {
      setState(() {
        _dailyCount = count;
        _cooldownSeconds = cooldown;
        _isLoading = false;
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

  Future<void> _watchAdNow() async {
    if (_isWatching) return;
    if (_cooldownSeconds > 0) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏳ Recharging energy! Ready in ${_cooldownSeconds}s.'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_dailyCount >= 5) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔋 Daily battery 100% full (5/5)! Resets tomorrow ☀️'),
          backgroundColor: Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isWatching = true);
    HapticFeedback.mediumImpact();

    try {
      await PocketAdMobService.instance.showRewardedAd(
        context: context,
        onUserEarnedReward: (reward) async {
          final updatedPS =
              await PocketAdMobService.instance.grantRewardedPocketScore();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '+50 Pocket Score added! Total: $updatedPS PS 🛡️',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            widget.onRewardClaimed?.call();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isWatching = false);
        _loadStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (5 - _dailyCount).clamp(0, 5);

    // Color theme based on charge
    Color batteryColor;
    String statusTitle;
    if (_dailyCount == 0) {
      batteryColor = const Color(0xFFEF4444); // Red
      statusTitle = 'Battery Low ⚠️ (0/5 Charged)';
    } else if (_dailyCount <= 2) {
      batteryColor = const Color(0xFFF97316); // Orange-Red
      statusTitle = 'Low Battery ⚡ ($_dailyCount/5 Charged)';
    } else if (_dailyCount <= 4) {
      batteryColor = const Color(0xFFEAB308); // Amber/Yellow
      statusTitle = 'Recharging 🔋 ($_dailyCount/5 Charged)';
    } else {
      batteryColor = const Color(0xFF10B981); // Emerald Green
      statusTitle = 'Full Battery 🔋 (5/5 Complete!)';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: batteryColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: batteryColor.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row with Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: batteryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: batteryColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _dailyCount == 5
                                ? Icons.battery_charging_full_rounded
                                : Icons.battery_alert_rounded,
                            size: 15,
                            color: batteryColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusTitle,
                            style: GoogleFonts.outfit(
                              color: batteryColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Center Icon with Glowing Radial Aura
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: batteryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      Icon(
                        Icons.play_circle_filled_rounded,
                        size: 58,
                        color: batteryColor,
                      ),
                      Positioned(
                        right: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt_rounded,
                              size: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  '⚡ Recharge Your Pocket Score!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  'Watch a short sponsor video to earn +50 Pocket Score instantly! Daily energy provides up to 5 videos (+250 PS total) for Citadels, games & tools.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔋 5-Segment Battery Visual Indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Energy Tank',
                            style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$_dailyCount / 5 Complete ($remaining left)',
                            style: GoogleFonts.inter(
                                color: batteryColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Battery Shell & 5 Segments
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: batteryColor, width: 1.5),
                              ),
                              child: Row(
                                children: List.generate(5, (index) {
                                  final isFilled = index < _dailyCount;
                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: index < 4 ? 3.0 : 0),
                                      decoration: BoxDecoration(
                                        color: isFilled
                                            ? batteryColor
                                            : Colors.white
                                                .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: isFilled
                                            ? [
                                                BoxShadow(
                                                  color: batteryColor
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 4,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          // Positive (+) Terminal
                          Container(
                            width: 5,
                            height: 10,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                              color: batteryColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(3),
                                bottomRight: Radius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 🎬 Main Watch Video Action Button
                if (_dailyCount < 5)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _cooldownSeconds > 0
                              ? const Color(0xFF334155)
                              : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: _cooldownSeconds > 0 ? 0 : 4,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading || _isWatching ? null : _watchAdNow,
                        icon: _isWatching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                _cooldownSeconds > 0
                                    ? Icons.timer_outlined
                                    : Icons.play_arrow_rounded,
                                size: 20,
                              ),
                        label: Text(
                          _isWatching
                              ? 'Loading Video...'
                              : (_cooldownSeconds > 0
                                  ? 'Next Video in ${_cooldownSeconds}s ⏳'
                                  : 'WATCH VIDEO (+50 PS) 🎬'),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Clean User-Facing Sponsor Tag (No backend ad names shown to normal users)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.more_horiz_rounded,
                            size: 14,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Sponsor Energy Video • Slot ${_dailyCount + 1}/5 (+50 PS)',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Max Claimed (+250 PS) 🌟',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                // 👑 Minimal VIP Card CTA at the Bottom (Audio Directive!)
                // User Audio: "പിന്നെ അടിയിൽ വിഐപി കാർഡിന് വിഐപി എന്ന് കൊടുത്താൽ വിഐപിയിൽ ടാപ്പ് ചെയ്തു കഴിഞ്ഞു കഴിഞ്ഞാൽ വിഐപിക്ക് പോകുന്ന ഒരു മിനിമൽ ആയിട്ട് കാണിക്കണം."
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E293B),
                          const Color(0xFF2A2210),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Text('👑', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Want Zero Ads & Unlimited PS?',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Upgrade to VIP Gold for instant +500 PS',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIP ➔',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
