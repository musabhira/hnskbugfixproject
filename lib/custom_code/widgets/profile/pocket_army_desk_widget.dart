import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_attack_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_island_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_navigator_page.dart';

/// 🎖️ Army War Desk Widget (ആർമി ഡെസ്ക്)
/// Positioned in the Main Profile Page alongside the Police Crime Desk.
/// Displays:
/// - 🛡️ 10-Hour Army Protection Shield countdown timer
/// - 📜 Island War Log / Invasion history
/// - ⚔️ Revenge Attack retaliation button
/// - 👥 Team Raid code joiner & Mock Attack sparring
class PocketArmyDeskWidget extends StatefulWidget {
  final String userId;

  const PocketArmyDeskWidget({
    super.key,
    required this.userId,
  });

  @override
  State<PocketArmyDeskWidget> createState() => _PocketArmyDeskWidgetState();
}

class _PocketArmyDeskWidgetState extends State<PocketArmyDeskWidget> {
  bool _isLoading = true;
  List<IslandWarLogEntry> _warLogs = [];
  int _shieldMinutesLeft = 0;
  String _homeIslandName = 'Home Island';
  String _homePlanetCode = 'EP';

  @override
  void initState() {
    super.initState();
    _loadArmyDeskData();
  }

  Future<void> _loadArmyDeskData() async {
    setState(() => _isLoading = true);

    try {
      final userPlot =
          await PoketCosmosAllocationService.instance.getUserPlot(userId: widget.userId);
      if (userPlot != null) {
        _homeIslandName = userPlot.postOffice.isNotEmpty
            ? userPlot.postOffice
            : '${userPlot.planetName.split(" ").first} Prime Island';
        final colony = PoketCosmosAllocationService.instance
            .getColonyByPlanetName(userPlot.planetName);
        _homePlanetCode = colony.code;

        // Check 10-Hour Shield for home island
        final homeIslandId = 'W01_${colony.code}_01';
        _shieldMinutesLeft = await PocketIslandAttackService.instance
            .getShieldMinutesRemaining(homeIslandId);
      }

      // Fetch war logs
      _warLogs = await PocketIslandAttackService.instance
          .getWarLogsForUserHome(widget.userId);
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showJoinRaidDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('👥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'JOIN TEAM RAID',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-character Raid Code (e.g. RAID-8421) shared by your clan leader:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'RAID-XXXX',
                hintStyle: GoogleFonts.outfit(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final code = textController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connecting to Raid Campaign ($code)...'),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              }
            },
            child:
                const Text('Join Raid', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _triggerRevenge(IslandWarLogEntry log) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚔️ Revenge protocol locked onto ${log.attackerName} (${log.attackerPlanetCode})!',
        ),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );

    // Navigate to Cosmos Navigator to target attacker
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PoketCosmosNavigatorPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎖️ Header Banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0369A1).withValues(alpha: 0.28),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.22),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Text('🎖️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARMY WAR DESK',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cosmic Island Invasions, 10H Shield & Retaliation',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action Buttons: Join Raid
                IconButton(
                  icon: const Icon(Icons.group_add_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                  tooltip: 'Join Team Raid',
                  onPressed: _showJoinRaidDialog,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🛡️ 10-Hour Army Defense Shield Status Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _shieldMinutesLeft > 0
                        ? const Color(0xFF0369A1).withValues(alpha: 0.20)
                        : const Color(0xFF065F46).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _shieldMinutesLeft > 0
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                          : const Color(0xFF34D399).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _shieldMinutesLeft > 0 ? '🛡️' : '🟢',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _shieldMinutesLeft > 0
                                  ? '10H ARMY PROTECTION SHIELD'
                                  : 'DEFENSE GRID ONLINE',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _shieldMinutesLeft > 0
                                  ? '${(_shieldMinutesLeft / 60.0).toStringAsFixed(1)} hrs left • All enemy raids blocked!'
                                  : '$_homeIslandName ($_homePlanetCode) • Standing guard',
                              style: GoogleFonts.inter(
                                color: _shieldMinutesLeft > 0
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 📜 Island War Logs Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT ISLAND SIEGES',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: _loadArmyDeskData,
                      child: Text(
                        'Refresh',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(
                        color: Color(0xFF38BDF8),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_warLogs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text('🕊️', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          'No recent incursions against your island!',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._warLogs.take(4).map((log) => _buildWarLogTile(log)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarLogTile(IslandWarLogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: log.wasConquered
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Attacker Avatar
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(
                color: log.wasConquered
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF38BDF8),
              ),
            ),
            child: Text(
              log.attackerAvatar.isNotEmpty ? log.attackerAvatar : '⚔️',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),

          // Log Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.attackerName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      log.wasConquered ? '💥 BREACHED' : '🛡️ DEFENDED',
                      style: GoogleFonts.outfit(
                        color: log.wasConquered
                            ? const Color(0xFFF87171)
                            : const Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Target: ${log.targetIslandName} • HP: ${log.damageDealt}/${log.totalHp}',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ⚔️ Revenge Retaliation Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            onPressed: () => _triggerRevenge(log),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on_rounded, size: 14),
                const SizedBox(width: 2),
                Text(
                  'REVENGE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

