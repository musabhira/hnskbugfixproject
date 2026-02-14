import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'webrtc_call_screen.dart';

class PocketMatesDashboard extends StatefulWidget {
  final double? width;
  final double? height;

  const PocketMatesDashboard({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<PocketMatesDashboard> createState() => _PocketMatesDashboardState();
}

class _PocketMatesDashboardState extends State<PocketMatesDashboard> {
  String? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo/Title area
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      FontAwesomeIcons.userGroup,
                      color: Colors.yellow,
                      size: 40,
                    ),
                  ).animate().scale(
                      delay: 200.ms,
                      duration: 600.ms,
                      curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text(
                    'Handskill Friends',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  Text(
                    'Your friends. Your pocket.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),

              const Spacer(),

              // Mode selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'Choose how you want to meet',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[300],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModeCard(
                            'Video',
                            FontAwesomeIcons.video,
                            Colors.yellow,
                            'Meet face-to-face',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModeCard(
                            'Voice',
                            FontAwesomeIcons.microphone,
                            Colors.yellow,
                            'Hear their voice',
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 900.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic)
                        .fadeIn(),
                    const SizedBox(height: 16),
                    _buildModeCard(
                      'Text',
                      FontAwesomeIcons.solidCommentDots,
                      Colors.yellow,
                      'Quick anonymous chatting',
                      isWide: true,
                    )
                        .animate()
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 1000.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic)
                        .fadeIn(),
                  ],
                ),
              ),

              const Spacer(),

              // Start Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _selectedMode == null ? null : _handleStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 12,
                    shadowColor: Colors.yellow.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    _selectedMode == null
                        ? 'Select a Mode'
                        : 'Match me with a Stranger!',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms),

              // Safety Note
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Temporary & Anonymous Connections',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildModeCard(
      String title, IconData icon, Color color, String subtitle,
      {bool isWide = false}) {
    bool isSelected = _selectedMode == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey[900]
              : Colors.grey[900]?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.grey[800]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.yellow : Colors.grey[400], size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
            if (isWide) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleStart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          mode: _selectedMode ?? 'Video',
        ),
      ),
    );
  }
}
