import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

/// 🎓 Day 90 Official Certificate of Fluency Mastery & Sovereign Constitution Completion
class Day90MasterCertificateDialog extends StatelessWidget {
  final String userName;
  final int userDay;
  final String? completionDate;

  const Day90MasterCertificateDialog({
    super.key,
    required this.userName,
    this.userDay = 90,
    this.completionDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    int userDay = 90,
    String? completionDate,
  }) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      builder: (ctx) => Day90MasterCertificateDialog(
        userName: userName,
        userDay: userDay,
        completionDate: completionDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = completionDate ??
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    final certId = 'SOV-ENG-90-${(userName.hashCode.abs() % 90000) + 10000}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF070A14),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Seal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                      ),
                      child: Text(
                        certId,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Presidential Crest Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFE082), Color(0xFFB45309)],
                    ),
                    border: Border.all(color: const Color(0xFFFFFC00), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 34)),
                  ),
                ),

                const SizedBox(height: 12),

                // Organization Title
                Text(
                  'SOVEREIGN ENGLISH CONSTITUTION & ACADEMY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'OFFICIAL CERTIFICATE OF FLUENCY MASTERY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 14),

                // Decorative Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('⚜️', style: TextStyle(fontSize: 14)),
                    ),
                    Container(width: 40, height: 1, color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  'This prestigious accreditation is conferred upon',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                ),

                const SizedBox(height: 8),

                // Recipient Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    userName.isNotEmpty ? userName : 'English Grandmaster',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFEF08A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'for exemplary perseverance across 90 progressive days of rigorous language synthesis, achieving highest distinction in CEFR C2 Executive Oratory, Rhetorical Balance, and Citadel Defense Mastery.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 16),

                // Accredited Competencies Matrix
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _buildSkillRow('🗣️', 'Spoken Eloquence', 'Spontaneous C2 articulation without native-tongue translation lag'),
                      const Divider(color: Colors.white10, height: 12),
                      _buildSkillRow('⚖️', 'Syntactic Parallelism', 'Balanced forensic cadences and classical statesman rhetoric'),
                      const Divider(color: Colors.white10, height: 12),
                      _buildSkillRow('🛡️', 'Citadel Defense Vault', '90 unique English challenges armed across all 9 gates'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Signature & Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date Awarded', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(dateStr, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Presidential Chancellor', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text('Certified & Sealed 🛡️', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons: Download & Share
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFD700)),
                          foregroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // ignore: deprecated_member_use
                          Share.share(
                            '🎓 I have officially graduated from the 90-Day English Transformation program with CEFR C2 Grandmaster Distinction! Certificate ID: $certId 👑',
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: Text('SHARE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  const Icon(Icons.download_done_rounded, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Certificate $certId downloaded to your device! 📜',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 16, color: Colors.black),
                        label: Text('DOWNLOAD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSkillRow(String icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
