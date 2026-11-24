import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_store_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

/// ⚔️ Citadel Military Defense Store Sheet (Clash of Clans Style Armory)
///
/// Features:
/// - Allows spending earned Pocket Score (PS) to purchase real Citadel Defenses
/// - Iron Dome Missile Defense, Gatling Gun Turrets, Tesla Barrier, Cyber Droid, Moat
/// - Equipping these adds extra defense gates to attackers in the Attack Runner Game
/// - Clean, dynamic, high-engagement gaming UI with Malayalam & English clarity
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
  State<PocketCitadelStoreSheet> createState() =>
      _PocketCitadelStoreSheetState();
}

class _PocketCitadelStoreSheetState extends State<PocketCitadelStoreSheet> {
  int _currentPS = 0;
  List<String> _ownedDefenses = [];
  List<String> _equippedDefenses = [];
  int _totalGates = 0;
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
    final equipped =
        await PocketCitadelStoreService.instance.getEquippedDefenses();
    final totalGates =
        await PocketCitadelStoreService.instance.getTotalEquippedGates();
    final eligibility =
        await PocketAdMobService.instance.checkRewardedAdEligibility();
    final remaining = eligibility['remaining'] as int? ?? 10;

    if (mounted) {
      setState(() {
        _currentPS = ps;
        _ownedDefenses = owned;
        _equippedDefenses = equipped;
        _totalGates = totalGates;
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
          content:
              Text('Daily sponsor video limit (5/5) reached. Resets tomorrow!'),
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
          final updatedPS =
              await PocketAdMobService.instance.grantRewardedPocketScore();
          final remaining =
              await PocketAdMobService.instance.getRewardedDailyRemaining();
          if (mounted) {
            setState(() {
              _currentPS = updatedPS;
              _rewardedRemaining = remaining;
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

    final success =
        await PocketCitadelStoreService.instance.purchaseDefense(item);
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
                    item.id == 'fortress_repair'
                        ? '🛠️ കോട്ട 100% നന്നാക്കി! (Citadel Repaired)'
                        : 'Unlocked & Equipped ${item.name}! 🛡️',
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
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'CITADEL DEFENSE STORE',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'യഥാർത്ഥ മിലിട്ടറി ഡിഫൻസ് ട്രാപ്പുകൾ സജ്ജീകരിക്കുക',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📺 Free PS via Ad
                    GestureDetector(
                      onTap: (_isWatchingAd || _rewardedRemaining <= 0)
                          ? null
                          : _watchRewardedAd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: _rewardedRemaining > 0
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _rewardedRemaining > 0
                                ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📺', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              _rewardedRemaining > 0 ? '+50 PS' : '5/5 Done',
                              style: GoogleFonts.outfit(
                                color: _rewardedRemaining > 0
                                    ? const Color(0xFF34D399)
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Balance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 3),
                          Text(
                            '$_currentPS PS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
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

          // 🛡️ Active Fortification Status Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🛡️', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'സജ്ജീകരിച്ച ഡിഫൻസ്: ${_equippedDefenses.length}/5 • അധിക ഗേറ്റുകൾ: +$_totalGates',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'റൈഡർമാർ നിങ്ങളുടെ വീട് ആക്രമിക്കുമ്പോൾ ഈ ട്രാപ്പുകൾ തകർക്കേണ്ടി വരും!',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📺 Prominent Rewarded Video Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _rewardedRemaining > 0
                    ? const Color(0xFF10B981)
                    : Colors.white24,
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (_rewardedRemaining > 0
                            ? const Color(0xFF10B981)
                            : Colors.white24)
                        .withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('📺', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch Video · +50 PS Free',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _rewardedRemaining > 0
                            ? 'Daily Reward ($_rewardedRemaining/5 available)'
                            : 'Daily Reward (5/5 Completed)',
                        style: GoogleFonts.inter(
                          color: _rewardedRemaining > 0
                              ? const Color(0xFF6EE7B7)
                              : Colors.white54,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: (_isWatchingAd || _rewardedRemaining <= 0)
                      ? null
                      : _watchRewardedAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rewardedRemaining > 0
                        ? const Color(0xFF10B981)
                        : Colors.white24,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: _isWatchingAd
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _rewardedRemaining > 0 ? 'CLAIM +50' : 'CLAIMED',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // List of Defense Weapons
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: PocketCitadelStoreService.catalog.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = PocketCitadelStoreService.catalog[index];
                      final isRepairKit = item.id == 'fortress_repair';
                      final isOwned = _ownedDefenses.contains(item.id);
                      final isEquipped = _equippedDefenses.contains(item.id);
                      final canAfford = _currentPS >= item.pricePS;

                      return Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131826),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isEquipped
                                ? item.themeColor.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.08),
                            width: isEquipped ? 1.6 : 1.0,
                          ),
                          boxShadow: isEquipped
                              ? [
                                  BoxShadow(
                                    color:
                                        item.themeColor.withValues(alpha: 0.22),
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
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: item.themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: item.themeColor.withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(item.icon,
                                    style: const TextStyle(fontSize: 24)),
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
                                            fontSize: 13.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.themeColor
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isRepairKit
                                              ? '100% HP'
                                              : '+${item.extraGates} Gates',
                                          style: GoogleFonts.outfit(
                                            color: item.themeColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  // Malayalam Benefit Highlight
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: item.themeColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '🛡️ ${item.benefitMl}',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFBAE6FD),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.inter(
                                      color: Colors.white60,
                                      fontSize: 10.5,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 9),

                                  // Action / Price Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Type: ${item.challengeType}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white38,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      // Button
                                      if (isRepairKit || !isOwned) ...[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canAfford
                                                ? const Color(0xFFFFFC00)
                                                : Colors.white12,
                                            foregroundColor: canAfford
                                                ? Colors.black
                                                : Colors.white38,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 13, vertical: 7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                            ),
                                          ),
                                          onPressed: () => _buyItem(item),
                                          child: Text(
                                            isRepairKit
                                                ? 'Repair · 🪙 ${item.pricePS} PS'
                                                : 'Buy · 🪙 ${item.pricePS} PS',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        GestureDetector(
                                          onTap: () => _toggleEquip(item.id),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isEquipped
                                                  ? const Color(0xFF10B981)
                                                  : Colors.white12,
                                              borderRadius:
                                                  BorderRadius.circular(9),
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
                                                  isEquipped
                                                      ? Icons.shield_rounded
                                                      : Icons
                                                          .add_moderator_rounded,
                                                  size: 13,
                                                  color: isEquipped
                                                      ? Colors.black
                                                      : Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isEquipped
                                                      ? 'EQUIPPED'
                                                      : 'EQUIP',
                                                  style: GoogleFonts.outfit(
                                                    color: isEquipped
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 10.5,
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
