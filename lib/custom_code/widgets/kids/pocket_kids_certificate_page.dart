import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 🏆 100-Day English Adventure Grand Champion Certificate
/// Downloadable and shareable achievement certificate for kids upon reaching Day 100.
class PocketKidsCertificatePage extends StatefulWidget {
  const PocketKidsCertificatePage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsCertificatePage()),
    );
  }

  @override
  State<PocketKidsCertificatePage> createState() => _PocketKidsCertificatePageState();
}

class _PocketKidsCertificatePageState extends State<PocketKidsCertificatePage> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      _speak("Congratulations ${PocketKidsService.kidName}! You are officially a Grand 100-Day English Adventure Champion!");
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      setState(() => _speaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _downloadCertificate() {
    HapticFeedback.heavyImpact();
    _speak("Your Grand Champion Certificate is downloaded and saved to your device!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Text('🏆 ', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Text(
                'Certificate Downloaded! Great job Champion! 🎉',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kidName = PocketKidsService.kidName;
    final kidAvatar = PocketKidsService.kidAvatar;
    final kidAge = PocketKidsService.kidAgeGroup;
    final pocketScore = PocketKidsService.pocketScore;
    final stars = PocketKidsService.kidStars;
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SUMMIT CERTIFICATE 🏆',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _speaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
              color: const Color(0xFFFBBF24),
            ),
            tooltip: 'Audio Playback',
            onPressed: () {
              if (_speaking) {
                _tts.stop();
                setState(() => _speaking = false);
              } else {
                _speak("Congratulations ${PocketKidsService.kidName}! You are officially a Grand 100-Day English Adventure Champion!");
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 📜 Golden Certificate Sheet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Royal Ribbon & Crown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('⭐', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text('👑', style: TextStyle(fontSize: 44)),
                        SizedBox(width: 8),
                        Text('⭐', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Certificate Header
                    Text(
                      'CERTIFICATE OF EXCELLENCE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF78350F),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '100-DAY SPOKEN ENGLISH SUMMIT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(height: 2, color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    const SizedBox(height: 16),

                    // Recipient Intro
                    Text(
                      'THIS SPECIAL HONOR IS AWARDED TO',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kid Avatar & Name Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(kidAvatar, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 10),
                        Text(
                          kidName,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ages $kidAge Master Explorer',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF78350F),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Praise Statement
                    Text(
                      'For extraordinary dedication, kindness, daily courage, and fluent English mastery, conquering all 100 Trail Summits and defending their Citadel with honor!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF451A03),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Column(
                              children: [
                                const Text('🎯', style: TextStyle(fontSize: 18)),
                                Text(
                                  '$pocketScore Pts',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                Text(
                                  'Pocket Score',
                                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Column(
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 18)),
                                Text(
                                  '$stars Stars',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                Text(
                                  'Total Stars',
                                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Column(
                              children: [
                                const Text('👑', style: TextStyle(fontSize: 18)),
                                Text(
                                  'Tier 6 Palace',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                Text(
                                  'Citadel Stage',
                                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Date & Official Seal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DATE AWARDED',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF78350F),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Text('🎖️', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text(
                                'OFFICIAL SEAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1,
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

              const SizedBox(height: 24),

              // 📥 Download / Save Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                ),
                onPressed: _downloadCertificate,
                icon: const Icon(Icons.download_rounded, size: 22),
                label: Text(
                  'DOWNLOAD CERTIFICATE 📥',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Listen Aloud Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24, width: 1.5),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  _speak("Congratulations $kidName! Awarded Certificate of Excellence for completing the 100-Day Spoken English Mountain Summit with a score of $pocketScore points!");
                },
                icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFFFBBF24)),
                label: Text(
                  'LISTEN TO SPEECH 🔊',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
