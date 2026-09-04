import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_fortress_defense_service.dart';

/// 🏪 Pocket Fortress Arsenal & Defense Store
/// Players can spend their hard-earned English raid & task coins to repair house HP,
/// upgrade the Iron Dome shield, enlist army guards, and equip armed escort vehicles!
class PocketArsenalStoreModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onPurchased;

  const PocketArsenalStoreModal({
    super.key,
    required this.currentDay,
    this.onPurchased,
  });

  static Future<void> show(BuildContext context, {required int currentDay, VoidCallback? onPurchased}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketArsenalStoreModal(
        currentDay: currentDay,
        onPurchased: onPurchased,
      ),
    );
  }

  @override
  State<PocketArsenalStoreModal> createState() => _PocketArsenalStoreModalState();
}

class _PocketArsenalStoreModalState extends State<PocketArsenalStoreModal> {
  HouseDefenseStatus _status = const HouseDefenseStatus();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final s = await PocketFortressDefenseService.getHouseStatus();
    if (mounted) {
      setState(() {
        _status = s;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEmergencyRepair() async {
    HapticFeedback.selectionClick();
    final ok = await PocketFortressDefenseService.repairHouse(healAmount: 25, coinCost: 20);
    if (!ok && mounted) {
      _showToast('❌ Not enough Coins! Win battle raids or finish daily missions to earn more.');
      return;
    }
    _showToast('🔧 Emergency patch applied! +25 House HP');
    await _loadStatus();
    widget.onPurchased?.call();
  }

  Future<void> _handleFullRepair() async {
    HapticFeedback.selectionClick();
    final ok = await PocketFortressDefenseService.repairHouse(healAmount: 100, coinCost: 50);
    if (!ok && mounted) {
      _showToast('❌ Not enough Coins! Win battle raids or finish daily missions to earn more.');
      return;
    }
    _showToast('🔨 Full restoration complete! 100/100 House HP Restored!');
    await _loadStatus();
    widget.onPurchased?.call();
  }

  Future<void> _handleBuyIronDome(int tier, int cost) async {
    HapticFeedback.selectionClick();
    final ok = await PocketFortressDefenseService.purchaseIronDome(tier: tier, coinCost: cost);
    if (!ok && mounted) {
      _showToast('❌ Not enough Coins! Win battle raids or finish daily missions to earn more.');
      return;
    }
    _showToast('🛡️ Iron Dome Tier $tier Activated! Raid damage will be absorbed.');
    await _loadStatus();
    widget.onPurchased?.call();
  }

  Future<void> _handleEnlistGuards(int count, int cost) async {
    HapticFeedback.selectionClick();
    final ok = await PocketFortressDefenseService.enlistArmyKnights(count: count, coinCost: cost);
    if (!ok && mounted) {
      _showToast('❌ Not enough Coins! Win battle raids or finish daily missions to earn more.');
      return;
    }
    _showToast('⚔️ +$count Royal Army Guards stationed at your fortress gates!');
    await _loadStatus();
    widget.onPurchased?.call();
  }

  Future<void> _handleBuyEscorts() async {
    HapticFeedback.selectionClick();
    final ok = await PocketFortressDefenseService.purchaseArmedEscorts(coinCost: 120);
    if (!ok && mounted) {
      _showToast('❌ Not enough Coins! Win battle raids or finish daily missions to earn more.');
      return;
    }
    _showToast('🚗 Dual Armed Tactical Escort Patrol en route to your Estate!');
    await _loadStatus();
    widget.onPurchased?.call();
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with Live Coins
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                const Text('🏪', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FORTRESS ARSENAL STORE',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Spend earned coins on House repairs, Army, & Shield upgrades',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 5),
                      Text(
                        '${_status.totalCoins}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                    children: [
                      // House HP Status Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _status.isDamaged ? Colors.redAccent : const Color(0xFF10B981),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _status.isDamaged ? '🏚️' : '🏰',
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _status.isDamaged ? 'HOUSE DAMAGED' : 'FORTRESS IN FULL HEALTH',
                                        style: GoogleFonts.outfit(
                                          color: _status.isDamaged ? Colors.redAccent : const Color(0xFF10B981),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        '❤️ ${_status.currentHp}/100 HP',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: _status.hpPercentage,
                                      minHeight: 7,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _status.hpPercentage > 0.5
                                            ? const Color(0xFF10B981)
                                            : (_status.hpPercentage > 0.25 ? Colors.amber : Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SECTION 1: HOUSE REPAIR SERVICES
                      _buildSectionHeader('🔧 HOUSE REPAIR & RESTORATION'),
                      const SizedBox(height: 8),
                      _buildStoreItem(
                        icon: '🩹',
                        title: 'Emergency Patch (+25 HP)',
                        desc: 'Quick structural reinforcement to restore partial fortress integrity.',
                        cost: 20,
                        actionLabel: 'REPAIR',
                        onTap: _status.currentHp < 100 ? _handleEmergencyRepair : null,
                        disabledText: _status.currentHp >= 100 ? 'HP FULL' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildStoreItem(
                        icon: '🔨',
                        title: 'Full Fortress Restoration (100 HP)',
                        desc: 'Restores all walls, roofs, and gates to pristine 100% condition.',
                        cost: 50,
                        actionLabel: 'RESTORE',
                        isHighlight: true,
                        onTap: _status.currentHp < 100 ? _handleFullRepair : null,
                        disabledText: _status.currentHp >= 100 ? 'HP FULL' : null,
                      ),

                      const SizedBox(height: 20),

                      // SECTION 2: DEFENSE TECHNOLOGY & GUARDS
                      _buildSectionHeader('🛡️ DEFENSE ARSENAL & ARMY'),
                      const SizedBox(height: 8),
                      _buildStoreItem(
                        icon: '⚡',
                        title: 'Iron Dome Shield (Tier 1)',
                        desc: 'Automated forcefield absorbing up to 35% of incoming English raid damage.',
                        cost: 60,
                        actionLabel: _status.hasIronDome ? 'ACTIVE' : 'PURCHASE',
                        onTap: !_status.hasIronDome ? () => _handleBuyIronDome(1, 60) : null,
                        disabledText: _status.hasIronDome ? 'INSTALLED' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildStoreItem(
                        icon: '🔮',
                        title: 'Titanium Dome Core (Tier 2)',
                        desc: 'Supercharged Obsidian shield absorbing 60% of all enemy airstrikes & bombs.',
                        cost: 120,
                        actionLabel: _status.ironDomeTier >= 2 ? 'MAX TIER' : 'UPGRADE',
                        onTap: _status.ironDomeTier < 2 ? () => _handleBuyIronDome(2, 120) : null,
                        disabledText: _status.ironDomeTier >= 2 ? 'ACTIVE' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildStoreItem(
                        icon: '⚔️',
                        title: 'Enlist Royal Knights (+2 Guards)',
                        desc: 'Station armored English knights at your front steps to counter-attack invaders.',
                        cost: 40,
                        actionLabel: 'ENLIST',
                        badge: '${_status.armyKnightsCount} Stationed',
                        onTap: _status.armyKnightsCount < 10 ? () => _handleEnlistGuards(2, 40) : null,
                        disabledText: _status.armyKnightsCount >= 10 ? 'MAX ARMY' : null,
                      ),

                      const SizedBox(height: 20),

                      // SECTION 3: VIP MOTORCADE & ESCORTS
                      _buildSectionHeader('🚗 VIP MOTORCADE & ESCORT PATROLS'),
                      const SizedBox(height: 8),
                      _buildStoreItem(
                        icon: '🚔',
                        title: 'Dual Armed Tactical Escorts (Alpha & Bravo)',
                        desc: 'Station 2 armed escort vehicles with flashing strobe lights to patrol your estate perimeter.',
                        cost: 120,
                        actionLabel: _status.hasArmedEscorts ? 'PATROLLING' : 'DISPATCH',
                        isGold: true,
                        onTap: !_status.hasArmedEscorts ? _handleBuyEscorts : null,
                        disabledText: _status.hasArmedEscorts ? 'DISPATCHED' : null,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: const Color(0xFFFFD700),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildStoreItem({
    required String icon,
    required String title,
    required String desc,
    required int cost,
    required String actionLabel,
    String? badge,
    String? disabledText,
    bool isHighlight = false,
    bool isGold = false,
    VoidCallback? onTap,
  }) {
    final canAfford = _status.totalCoins >= cost;
    final isAvailable = onTap != null && canAfford;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGold
              ? const Color(0xFFFFD700)
              : (isHighlight ? const Color(0xFF38BDF8) : Colors.white12),
          width: isGold || isHighlight ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$cost Coins',
                          style: GoogleFonts.outfit(
                            color: canAfford ? const Color(0xFFFFD700) : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                            ? (isGold ? const Color(0xFFFFD700) : const Color(0xFF0284C7))
                            : Colors.white12,
                        foregroundColor: isGold && isAvailable ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: isAvailable ? 3 : 0,
                      ),
                      onPressed: isAvailable ? onTap : null,
                      child: Text(
                        disabledText ?? actionLabel,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
