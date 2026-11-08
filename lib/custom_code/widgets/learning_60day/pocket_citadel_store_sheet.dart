import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_store_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

/// ⚔️ Citadel Military Defense Store Sheet (Clash of Clans Style Armory)
///
/// Features:
/// - Allows spending earned Pocket Score (PS) to purchase real Citadel Defenses
/// - Iron Dome Missile Defense, Gatling Gun Turrets, Tesla Barrier, Cyber Droid, Moat
/// - Equipping these adds extra defense gates to attackers in the Attack Runner Game
/// - Clean, dynamic, high-engagement gaming UI
class PocketCitadelStoreSheet extends StatefulWidget {
  final VoidCallback? onPurchased;

  const PocketCitadelStoreSheet({super.key, this.onPurchased});

  static Future<void> show(BuildContext context, {VoidCallback? onPurchased}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketCitadelStoreSheet(onPurchased: onPurchased),
    );
  }

  @override
  State<PocketCitadelStoreSheet> createState() => _PocketCitadelStoreSheetState();
}

class _PocketCitadelStoreSheetState extends State<PocketCitadelStoreSheet> {
  int _currentPS = 0;
  List<String> _ownedDefenses = [];
  List<String> _equippedDefenses = [];
  bool _isLoading = true;
  int _rewardedRemaining = 5;
  bool _isWatchingAd = false;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final ps = await PocketCitadelStoreService.instance.getUserPocketScore();
    final owned = await PocketCitadelStoreService.instance.getOwnedDefenses();
    final equipped = await PocketCitadelStoreService.instance.getEquippedDefenses();
    final eligibility = await PocketAdMobService.instance.checkRewardedAdEligibility();
    final remaining = eligibility['remaining'] as int? ?? 5;

    if (mounted) {
      setState(() {
        _currentPS = ps;
        _ownedDefenses = owned;
        _equippedDefenses = equipped;
        _rewardedRemaining = remaining;
        _isLoading = false;
      });
    }
  }

  Future<void> _watchRewardedAd() async {
    if (_isWatchingAd) return;
    if (_rewardedRemaining <= 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily sponsor video limit (5/5) reached. Resets tomorrow!'),
          backgroundColor: Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isWatchingAd = true);
    try {
      await PocketAdMobService.instance.showRewardedAd(
        context: context,
        onUserEarnedReward: (reward) async {
          final prefs = await SharedPreferences.getInstance();
          final newScore = _currentPS + 50;
          await prefs.setInt('pocket_score', newScore);
          final eligibility = await PocketAdMobService.instance.checkRewardedAdEligibility();
          if (mounted) {
            setState(() {
              _currentPS = newScore;
              _rewardedRemaining = eligibility['remaining'] as int? ?? (_rewardedRemaining - 1).clamp(0, 5);
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('+50 Pocket Score granted! 🛡️',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isWatchingAd = false);
      }
    }
  }

  Future<void> _buyItem(CitadelDefenseItem item) async {
    if (_currentPS < item.pricePS) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Need ${item.pricePS - _currentPS} more Pocket Score to unlock this!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '📺 +50 PS',
            textColor: const Color(0xFFFFD700),
            onPressed: _watchRewardedAd,
          ),
        ),
      );
      return;
    }

    final success = await PocketCitadelStoreService.instance.purchaseDefense(item);
    if (success) {
      widget.onPurchased?.call();
      await _loadStoreData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unlocked & Equipped ${item.name}! 🛡️',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleEquip(String id) async {
    await PocketCitadelStoreService.instance.toggleEquipped(id);
    await _loadStoreData();
    widget.onPurchased?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F19),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🏰', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          'CITADEL DEFENSE ARMORY',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Spend Pocket Score to fortify your Citadel gates',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📺 Free PS via Ad
                    GestureDetector(
                      onTap: (_isWatchingAd || _rewardedRemaining <= 0) ? null : _watchRewardedAd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _rewardedRemaining > 0
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _rewardedRemaining > 0
                                ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📺', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              _rewardedRemaining > 0 ? '+50 PS' : '5/5 Done',
                              style: GoogleFonts.outfit(
                                color: _rewardedRemaining > 0 ? const Color(0xFF34D399) : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Balance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentPS PS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📺 Prominent Rewarded Video Card (User Audio Directive: Easy to spot & Claim +50 PS)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _rewardedRemaining > 0 ? const Color(0xFF10B981) : Colors.white24,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_rewardedRemaining > 0 ? const Color(0xFF10B981) : Colors.white24).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('📺', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch Video · Earn +50 PS Free',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _rewardedRemaining > 0
                            ? 'Daily Sponsor Reward ($_rewardedRemaining/5 available)'
                            : 'Daily Sponsor Reward (5/5 Completed today)',
                        style: GoogleFonts.inter(
                          color: _rewardedRemaining > 0 ? const Color(0xFF6EE7B7) : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: (_isWatchingAd || _rewardedRemaining <= 0) ? null : _watchRewardedAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rewardedRemaining > 0 ? const Color(0xFF10B981) : Colors.white24,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isWatchingAd
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _rewardedRemaining > 0 ? 'CLAIM +50' : 'CLAIMED',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List of Defense Weapons
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: PocketCitadelStoreService.catalog.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = PocketCitadelStoreService.catalog[index];
                      final isOwned = _ownedDefenses.contains(item.id);
                      final isEquipped = _equippedDefenses.contains(item.id);
                      final canAfford = _currentPS >= item.pricePS;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131826),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isEquipped
                                ? item.themeColor.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.08),
                            width: isEquipped ? 1.5 : 1.0,
                          ),
                          boxShadow: isEquipped
                              ? [
                                  BoxShadow(
                                    color: item.themeColor.withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Emblem
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: item.themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: item.themeColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(item.icon, style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.themeColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '+${item.extraGates} Gates',
                                          style: GoogleFonts.outfit(
                                            color: item.themeColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.inter(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Action / Price Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Type: ${item.challengeType}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white38,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      // Button
                                      if (!isOwned) ...[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canAfford
                                                ? const Color(0xFFFFFC00)
                                                : Colors.white12,
                                            foregroundColor: canAfford
                                                ? Colors.black
                                                : Colors.white38,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => _buyItem(item),
                                          child: Text(
                                            'Buy · 🪙 ${item.pricePS} PS',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        GestureDetector(
                                          onTap: () => _toggleEquip(item.id),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isEquipped
                                                  ? const Color(0xFF10B981)
                                                  : Colors.white12,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isEquipped
                                                    ? const Color(0xFF34D399)
                                                    : Colors.white24,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isEquipped ? Icons.shield_rounded : Icons.add_moderator_rounded,
                                                  size: 14,
                                                  color: isEquipped ? Colors.black : Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isEquipped ? 'EQUIPPED' : 'EQUIP',
                                                  style: GoogleFonts.outfit(
                                                    color: isEquipped ? Colors.black : Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
