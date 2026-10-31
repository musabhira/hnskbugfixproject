import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 🎓 Authentic Day 90 Master Graduate Diploma & Verification Card
///
/// Features:
/// - Prestigious, authentic certificate design (Ivory/Obsidian Gold border, official seal, verification ID)
/// - Shows Pocket Score, Day 90 Completion, and Master Distinction
/// - High-resolution capture and instant download/share
/// - Clean, minimal dialog without clutter or popup paywalls
class Day90MasterCertificateDialog extends StatefulWidget {
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
      barrierDismissible: true,
      builder: (ctx) => Day90MasterCertificateDialog(
        userName: userName,
        userDay: userDay,
        completionDate: completionDate,
      ),
    );
  }

  @override
  State<Day90MasterCertificateDialog> createState() => _Day90MasterCertificateDialogState();
}

class _Day90MasterCertificateDialogState extends State<Day90MasterCertificateDialog> {
  final GlobalKey _certKey = GlobalKey();
  bool _isExporting = false;

  Future<File?> _captureCertificateImage() async {
    try {
      final boundary = _certKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final certId = 'PM-90-MASTER-${(widget.userName.hashCode.abs() % 90000) + 10000}';
      final file = File('${tempDir.path}/Certificate_$certId.png');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('Certificate render error: $e');
      return null;
    }
  }

  Future<void> _downloadCertificate() async {
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCertificateImage();
      if (file == null) throw Exception('Could not render certificate image');

      final appDocDir = await getApplicationDocumentsDirectory();
      final permanentPath = '${appDocDir.path}/${file.uri.pathSegments.last}';
      await file.copy(permanentPath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Certificate saved successfully! 🎓',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '🎓 Here is my Official Pocket Mates 90-Day Spoken English Master Graduate Certificate!',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to export certificate: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final certId = 'PM-90-MASTER-${(widget.userName.hashCode.abs() % 90000) + 10000}';
    final issueDate = widget.completionDate ??
        '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF0F121A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded,
                            color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'MASTER GRADUATE CERTIFICATE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Certificate Card Canvas (Captured to high-res PNG)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RepaintBoundary(
                  key: _certKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141722),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Inner Fine Border Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emblem Icon
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFB45309)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.school_rounded, color: Colors.black, size: 28),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Institution
                              Text(
                                'POCKET MATES ACADEMY',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'DIPLOMA OF SPOKEN ENGLISH MASTERY',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                'THIS IS PROUDLY PRESENTED TO',
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Recipient Name
                              Text(
                                widget.userName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Description
                              Text(
                                'For successfully completing all 90 Days of immersive Spoken English, Citadel Defense challenges, and conversational mastery with Highest Distinction.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Meta Details Row
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text('GRADE',
                                            style: GoogleFonts.inter(
                                                color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('C2 Master',
                                            style: GoogleFonts.outfit(
                                                color: const Color(0xFF10B981),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                    Container(width: 1, height: 24, color: Colors.white12),
                                    Column(
                                      children: [
                                        Text('DATE',
                                            style: GoogleFonts.inter(
                                                color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(issueDate,
                                            style: GoogleFonts.outfit(
                                                color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Container(width: 1, height: 24, color: Colors.white12),
                                    Column(
                                      children: [
                                        Text('VERIFIED ID',
                                            style: GoogleFonts.inter(
                                                color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(certId,
                                            style: GoogleFonts.outfit(
                                                color: const Color(0xFFFFD700),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isExporting ? null : _downloadCertificate,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      _isExporting ? 'Generating...' : 'Download Certificate 📜',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
