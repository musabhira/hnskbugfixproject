import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📜 Day 90 Sovereign Graduation Certificate Dialog
/// Conferred upon completing the 90-Day Pocket World English Mastery Journey.
class Day90GraduationCertificateDialog extends StatelessWidget {
  final String studentName;
  final String completionDate;
  final String certificateId;

  const Day90GraduationCertificateDialog({
    super.key,
    this.studentName = 'Sovereign Scholar',
    this.completionDate = 'September 2026',
    this.certificateId = 'PW-90-MASTER-CELESTIAL',
  });

  static Future<void> show(
    BuildContext context, {
    String studentName = 'Sovereign Scholar',
    String? completionDate,
    String? certificateId,
  }) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GraduationCertificateModal',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => Day90GraduationCertificateDialog(
        studentName: studentName,
        completionDate: completionDate ?? '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}',
        certificateId: certificateId ?? 'PW-90-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      ),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim.value),
          child: child,
        );
      },
    );
  }

  static String _monthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 380;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: math.min(size.width * 0.94, 460),
            maxHeight: size.height * 0.92,
          ),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFB45309), Color(0xFFFFE57F), Color(0xFFB45309)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 36,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 24,
              vertical: isCompact ? 20 : 28,
            ),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.3,
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF030712)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.5),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Academy Crest
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'POCKET WORLD SOVEREIGN ACADEMY',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Main Heading
                  Text(
                    'CERTIFICATE OF MASTERY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: isCompact ? 19 : 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SOVEREIGN ENGLISH FLUENCY & LEADERSHIP',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: isCompact ? 11 : 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Divider with Ornament
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: Colors.amber.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('✦ ⚜️ ✦', style: TextStyle(color: Colors.amber.shade300, fontSize: 12)),
                      ),
                      Expanded(child: Container(height: 1, color: Colors.amber.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Conferred text
                  Text(
                    'This is to certify that',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Student Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      studentName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFE082),
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'has successfully completed the intensive 90-Day English Curriculum across 9 Sovereign Challenge Gates, demonstrating mastery in Executive Job Interviews, High-Stakes Negotiations, Classical Rhetoric, Forensic Debate, and Sovereign Statesmanship.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seal and Details Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Presidential Gold Seal
                        Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFFFFE57F), Color(0xFFB45309)],
                                ),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.6),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🎖️', style: TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'VERIFIED SEAL',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        // Signature & Verification Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFICATION ID',
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              certificateId,
                              style: GoogleFonts.robotoMono(
                                color: const Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'CONFERRED ON',
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              completionDate,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Actions: Share / Close
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '🎓 Verified Day 90 Sovereign English Fluency Certificate | $certificateId'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Certificate Verification ID copied to clipboard! 📋'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, color: Color(0xFFFFD700), size: 16),
                          label: Text(
                            'COPY ID',
                            style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                          label: Text(
                            'CLOSE',
                            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
