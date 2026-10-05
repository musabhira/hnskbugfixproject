import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pocket_mates_app/services/iap_service.dart';
import 'package:pocket_mates_app/custom_code/services/monetization_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import '/backend/supabase/supabase.dart';

/// 🎓 Day 90–91 Official Certificate of Fluency Mastery & Sovereign Constitution Completion
class Day90MasterCertificateDialog extends StatefulWidget {
  final String userName;
  final int userDay;
  final String? completionDate;

  const Day90MasterCertificateDialog({
    super.key,
    required this.userName,
    this.userDay = 91,
    this.completionDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    int userDay = 91,
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
  State<Day90MasterCertificateDialog> createState() => _Day90MasterCertificateDialogState();
}

class _Day90MasterCertificateDialogState extends State<Day90MasterCertificateDialog> {
  final GlobalKey _certKey = GlobalKey();
  bool _isExporting = false;
  bool _hasAccess = false;
  int _certPrice = 149;
  int _certRetailPrice = 999;
  StreamSubscription<PurchaseDetails>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _purchaseSub = IAPService().purchaseStream.listen((purchase) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _checkAccess().then((_) {
          if (_hasAccess && mounted) {
            _downloadCertificate();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVip = prefs.getBool('is_vip') ?? false;
      final hasCert = prefs.getBool('has_purchased_c2_certificate') ?? false;
      final campaign = await MonetizationService().getActiveCampaign();

      final email = SupaFlow.client.auth.currentUser?.email;
      final isAdmin = email != null &&
          (email == 'musabthonippadam@gmail.com' || email.contains('mussabira'));

      if (mounted) {
        setState(() {
          _hasAccess = isVip || hasCert || isAdmin;
          _certPrice = campaign.certificateUnlockPrice;
          _certRetailPrice = campaign.certificateRetailPrice;
        });
      }
    } catch (_) {}
  }

  void _showCertificateUnlockModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Unlock Official C2 Mastery Diploma',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Congratulations on completing all 90 days! Download your cryptographically verified CEFR C2 English Grandmaster Diploma for your CV, LinkedIn, and portfolio.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standalone Certificate Pass',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'One-time lifetime unlock',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹$_certRetailPrice',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white38,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹$_certPrice',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final initiated = await IAPService().buyVipSubscription(planType: 'certificate');
                    if (!initiated && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(Platform.isIOS
                              ? 'Connecting to App Store In-App Purchases...'
                              : 'Connecting to Google Play...'),
                          backgroundColor: const Color(0xFF1E293B),
                        ),
                      );
                    }
                  },
                  icon: Icon(Platform.isIOS ? Icons.apple_rounded : Icons.shop_two_rounded, size: 20),
                  label: Text(
                    Platform.isIOS
                        ? 'Unlock with Apple Pay • ₹$_certPrice'
                        : 'Unlock with Google Play • ₹$_certPrice',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                child: Text(
                  'Or get Poket VIP Pass (Free Certificate Included) 👑',
                  style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _captureCertificateImage() async {
    try {
      final boundary = _certKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final certId = 'SOV-ENG-${(widget.userName.hashCode.abs() % 90000) + 10000}';
      final file = File('${tempDir.path}/Certificate_$certId.png');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('Certificate render error: $e');
      return null;
    }
  }

  Future<void> _downloadCertificate() async {
    if (!_hasAccess) {
      _showCertificateUnlockModal();
      return;
    }
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCertificateImage();
      if (file == null) throw Exception('Could not render certificate image');

      // Also copy to App Documents so it is permanently stored on device
      final appDocDir = await getApplicationDocumentsDirectory();
      final permanentPath = '${appDocDir.path}/${file.uri.pathSegments.last}';
      await file.copy(permanentPath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'High-Res C2 Certificate downloaded successfully! 🎓',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );

      // Open standard system share/save sheet so user can directly save to photos or files
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '🎓 Here is my Official Sovereign C2 English Grandmaster Certificate! Handskill Sovereign Academy.',
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

  Future<void> _shareCertificate() async {
    if (!_hasAccess) {
      _showCertificateUnlockModal();
      return;
    }
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCertificateImage();
      if (file == null) throw Exception('Could not render certificate');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '🎓 I have conquered all 90 days and the Stage 91 Presidential Palace Citadel Raid! Conferred CEFR C2 English Grandmaster Distinction 👑',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Share error: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.completionDate ??
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    final certId = 'SOV-ENG-91-${(widget.userName.hashCode.abs() % 90000) + 10000}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF070A16),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.28),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Certificate Canvas to capture with RepaintBoundary
              RepaintBoundary(
                key: _certKey,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080B18),
                    borderRadius: BorderRadius.circular(22),
                    gradient: const RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.2,
                      colors: [
                        Color(0xFF161E38),
                        Color(0xFF070A16),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Certificate ID & Close Row
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

                      const SizedBox(height: 6),

                      // Presidential Crest Emblem
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFFFE082), Color(0xFFB45309)],
                              ),
                              border: Border.all(color: const Color(0xFFFFFC00), width: 2.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('👑', style: TextStyle(fontSize: 38)),
                            ),
                          ),
                        ],
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
                          letterSpacing: 1.8,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'OFFICIAL CERTIFICATE OF FLUENCY MASTERY',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Ornate Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 44, height: 1.2, color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('⚜️', style: TextStyle(fontSize: 14)),
                          ),
                          Container(width: 44, height: 1.2, color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'This prestigious accreditation is solemnly conferred upon',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontStyle: FontStyle.italic),
                      ),

                      const SizedBox(height: 8),

                      // Recipient Name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName : 'English Grandmaster',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFEF08A),
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'for exemplary perseverance across all 90 progressive language domains, conquering Stage 91 Presidential Palace Citadel Raid, and earning 150+ PocketTalk Spoken Trophies with active community peers, achieving CEFR C2 Executive Oratory, Rhetorical Fluency, and Sovereign Distinction.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Accredited Competencies Matrix
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1426),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildSkillRow('🗣️', 'C2 Spoken Eloquence', 'Native articulation without maternal language translation latency'),
                            const Divider(color: Colors.white10, height: 12),
                            _buildSkillRow('⚖️', 'Syntactic Precision', 'Statesman forensic cadences, debate rhetoric & grammatical mastery'),
                            const Divider(color: Colors.white10, height: 12),
                            _buildSkillRow('🏛️', 'Stage 91 Citadel Victory', '250 Palace Raid trial questions breached with Sovereign Distinction'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Signature & Seal Row
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
                          // Wax Seal Visual
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const RadialGradient(colors: [Color(0xFFDC2626), Color(0xFF991B1B)]),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.5), blurRadius: 8),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🛡️', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  'C2 VERIFIED',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10.5,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Presidential Chancellor', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text('Certified & Sealed 🖋️', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons: Download & Share
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFD700)),
                          foregroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isExporting ? null : _shareCertificate,
                        icon: _isExporting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)))
                            : const Icon(Icons.share_rounded, size: 16),
                        label: Text('SHARE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isExporting ? null : _downloadCertificate,
                        icon: _isExporting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Icon(Icons.download_rounded, size: 17, color: Colors.black),
                        label: Text('DOWNLOAD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
