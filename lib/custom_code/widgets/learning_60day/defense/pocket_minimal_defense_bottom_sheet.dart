import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pocket_fortress_defense_service.dart';
import '../pocket_defense_trap_modal.dart';

/// 🛡️ Pocket Minimal Defense Bottom Sheet
///
/// Implements User Audio Directive:
/// - Zero-complication, minimal UI (no jumping to attacking profile!).
/// - For Days 1 to 40: houses are automatically protected with curated traps.
/// - Shows 'Defense Added / Active' with a single clean confirmation button.
/// - Includes an optional minimal 'Edit / Reroll Traps' action for power users.
class PocketMinimalDefenseBottomSheet extends StatefulWidget {
  final int day;
  final VoidCallback? onConfirmed;

  const PocketMinimalDefenseBottomSheet({
    super.key,
    required this.day,
    this.onConfirmed,
  });

  static Future<bool?> show(BuildContext context, {required int day, VoidCallback? onConfirmed}) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketMinimalDefenseBottomSheet(
        day: day,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<PocketMinimalDefenseBottomSheet> createState() => _PocketMinimalDefenseBottomSheetState();
}

class _PocketMinimalDefenseBottomSheetState extends State<PocketMinimalDefenseBottomSheet> {
  bool _isLoading = true;
  List<HouseShieldQuestion> _traps = [];

  @override
  void initState() {
    super.initState();
    _loadDefense();
  }

  Future<void> _loadDefense() async {
    try {
      final list = await PocketFortressDefenseService.ensureAutoArmedDefense(widget.day);
      if (mounted) {
        setState(() {
          _traps = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDefense() {
    HapticFeedback.mediumImpact();
    widget.onConfirmed?.call();
    Navigator.of(context).pop(true);
  }

  Future<void> _openEditModal() async {
    Navigator.of(context).pop(false);
    await PocketDefenseTrapModal.show(context, widget.day);
    widget.onConfirmed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isAutoProtected = widget.day <= 40;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Cottage Shield Active',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isAutoProtected ? 'AUTO-ARMED' : 'LEVEL ${widget.day}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isAutoProtected
                            ? 'Protected with curated grammar traps against raids.'
                            : 'Set custom traps to defend your cottage.',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Active Traps Preview
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2),
                ),
              )
            else if (_traps.isNotEmpty) ...[
              Text(
                'ACTIVE GATE TRAPS (${_traps.length}):',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              ..._traps.take(3).map((q) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_rounded, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q.question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 14),

            // Minimal Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmDefense,
                    icon: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'CONFIRM SHIELD 🛡️',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _openEditModal,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'EDIT ✏️',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
