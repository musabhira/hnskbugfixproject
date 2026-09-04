import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_fortress_defense_service.dart';

/// 🏆 Day 90 Master VIP Fleet & Victory Card Dialog
/// Displays the prestigious Day 90 achievement:
/// 1. The Sovereign Phantom VIP Limousine with 2 Armed Tactical Escort Vehicles (Strobe Lights!)
/// 2. Holographic Day 90 Master English Victory Card with Presidential Seal
class Day90VipMasterCardDialog extends StatefulWidget {
  final int userDay;
  final bool isPreview;

  const Day90VipMasterCardDialog({
    super.key,
    required this.userDay,
    this.isPreview = false,
  });

  static Future<void> show(BuildContext context, {required int userDay, bool isPreview = false}) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Day90Modal',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => Day90VipMasterCardDialog(
        userDay: userDay,
        isPreview: isPreview,
      ),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim.value),
          child: child,
        );
      },
    );
  }

  @override
  State<Day90VipMasterCardDialog> createState() => _Day90VipMasterCardDialogState();
}

class _Day90VipMasterCardDialogState extends State<Day90VipMasterCardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _strobeController;
  late Day90MasterCardData _cardData;

  @override
  void initState() {
    super.initState();
    _cardData = PocketFortressDefenseService.generateDay90MasterCard();
    _strobeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _strobeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.of(context).size.width * 0.92, 400),
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(0, -0.6),
              radius: 1.2,
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF020617)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            widget.isPreview ? 'DAY 90 MASTER PREVIEW' : 'DAY 90 MASTER CONQUERED!',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 🚗 VIP LIMOUSINE & DUAL ARMED ESCORTS FLEET
                _buildVipMotorcadeSection(),

                const SizedBox(height: 18),

                // 🏆 HOLOGRAPHIC MASTER NFT TRADING CARD
                _buildHolographicMasterCard(),

                const SizedBox(height: 18),

                // Close / Claim Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.isPreview ? 'CLOSE PREVIEW' : 'CLAIM MASTER HONORS 🎖️',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
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

  /// 🚗 The VIP Limousine with 2 Armed Tactical Escorts (Alpha & Bravo)
  Widget _buildVipMotorcadeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'PRESIDENTIAL MOTORCADE & ARMED ESCORTS',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Motorcade lineup: Left Escort + Center VIP Limousine + Right Escort
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🏍️ Left Armed Escort (Alpha)
              _buildEscortUnit(
                label: 'ESCORT ALPHA',
                icon: '🏍️',
                isLeft: true,
              ),

              // 🏎️ Central Sovereign Phantom VIP Limousine
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB45309)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏎️', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sovereign Phantom',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'VIP 24K Limousine',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 9),
                  ),
                ],
              ),

              // 🏍️ Right Armed Escort (Bravo)
              _buildEscortUnit(
                label: 'ESCORT BRAVO',
                icon: '🏍️',
                isLeft: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscortUnit({required String label, required String icon, required bool isLeft}) {
    return AnimatedBuilder(
      animation: _strobeController,
      builder: (context, _) {
        final strobeOn = _strobeController.value > 0.5;
        final lightColor = strobeOn
            ? (isLeft ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))
            : (isLeft ? const Color(0xFF3B82F6) : const Color(0xFFEF4444));

        return Column(
          children: [
            // Flashing Strobe Light
            Container(
              width: 12,
              height: 6,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: lightColor.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 1),
                ],
              ),
            ),
            Container(
              width: 58,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightColor.withValues(alpha: 0.6)),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 8.5,
              ),
            ),
            Text(
              'Armed Tactical',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 8),
            ),
          ],
        );
      },
    );
  }

  /// 🏆 Holographic Master NFT Trading Card
  Widget _buildHolographicMasterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    'SUPREME DAY 90 CARD',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '#90-VIP',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: const Text('🐉', style: TextStyle(fontSize: 44)),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              _cardData.title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              _cardData.rank,
              style: GoogleFonts.inter(
                color: const Color(0xFF38BDF8),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          _buildCardDetailRow('Fleet Vehicle', _cardData.limousineName),
          const SizedBox(height: 5),
          _buildCardDetailRow('Escort Detail', _cardData.escortSquad),
          const SizedBox(height: 5),
          _buildCardDetailRow('Issued Date', _cardData.issuedDate),
          const SizedBox(height: 5),
          _buildCardDetailRow('Serial No.', _cardData.serialNumber),

          const SizedBox(height: 12),

          // Presidential Holographic Seal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎩', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Text(
                  'CERTIFIED BY ${_cardData.presidentSignature.toUpperCase()}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
