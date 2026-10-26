import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ⚡ High-Impact, Minimal Onboarding Component:
/// "Why is there NO 'C' in POKET MATES?"
///
/// Clean, minimal & instant understanding:
/// 1. Strikethrough Wordmark: PO [C] KET MATES
/// 2. 3 Clean, Minimal Pillars in a single sleek container
/// 3. Golden Punchline: "The only 'C' is CONFIDENCE!"
class WhyNoCWidget extends StatelessWidget {
  const WhyNoCWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔤 Compact Wordmark Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PO',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'C',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: const Color(0xFFEF4444),
                    decorationThickness: 2.5,
                  ),
                ),
                Text(
                  'KET',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MATES',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF59E0B),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 🎯 3 Minimal Pillars in a unified sleek card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMinimalRow(
                  tag: 'NO COMPARISON',
                  desc: 'Learn at your own pace',
                  color: const Color(0xFFEF4444),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFF1E293B), height: 1),
                ),
                _buildMinimalRow(
                  tag: 'NO CRITICISM',
                  desc: 'Zero judgment, safe to speak',
                  color: const Color(0xFFF97316),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFF1E293B), height: 1),
                ),
                _buildMinimalRow(
                  tag: 'NO CLASSROOM',
                  desc: 'Real talk, games & friends',
                  color: const Color(0xFF38BDF8),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🏆 Golden Punchline Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🦁', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'The only "C" you need is CONFIDENCE!',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalRow({
    required String tag,
    required String desc,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚫', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                tag,
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            desc,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
