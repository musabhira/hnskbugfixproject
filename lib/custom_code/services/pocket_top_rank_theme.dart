import 'package:flutter/material.dart';

/// 👑 Dedicated Luxury Theme Definition for Global Top 10 Rankers
///
/// Features:
/// - Distinct, non-repeating 3-stop dreamy luxury gradients for Ranks 1 to 10
/// - Ultra-high contrast readable typography
/// - Seamless visual consistency across Main Profile and Citadel Attacking Sheet
class PocketTopRankTheme {
  final int rank;
  final List<Color> gradientColors;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
  final List<Color> btnGradient;
  final Color btnColor;
  final Color btnTextColor;
  final Color borderColor;
  final String title;

  final Color? ringColor;
  final Color? ringGlowColor;

  const PocketTopRankTheme({
    required this.rank,
    required this.gradientColors,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.btnGradient,
    required this.btnColor,
    required this.btnTextColor,
    required this.borderColor,
    required this.title,
    this.ringColor,
    this.ringGlowColor,
  });

  Color get dominantBg => gradientColors.first;

  static PocketTopRankTheme? getThemeForRank(int rank) {
    switch (rank) {
      case 1:
        // 👑 Rank 1: Mystical Velvet Amethyst & Royal Lilac (Swapped from Rank 4 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 1,
          gradientColors: [Color(0xFF250D3E), Color(0xFF461775), Color(0xFF19072A)],
          primaryColor: Color(0xFFC084FC),
          accentColor: Color(0xFFFFD700),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFE9D5FF),
          btnGradient: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
          btnColor: Color(0xFFF3E8FF),
          btnTextColor: Color(0xFF581C87),
          borderColor: Color(0xFFA855F7),
          title: 'Imperial Champion #1',
          ringColor: Color(0xFFFFD700), // 🥇 Exclusive Pure Gold Ring for Rank 1
          ringGlowColor: Color(0xFFFBBF24),
        );
      case 2:
        // 🌊 Rank 2: Oceanic Teal & Deep Sea Aquamarine (Swapped from Rank 8 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 2,
          gradientColors: [Color(0xFF052B2E), Color(0xFF0A4A50), Color(0xFF031B1D)],
          primaryColor: Color(0xFF2DD4BF),
          accentColor: Color(0xFF5EEAD4),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFCCFBF1),
          btnGradient: [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
          btnColor: Color(0xFFF0FDFA),
          btnTextColor: Color(0xFF115E59),
          borderColor: Color(0xFF14B8A6),
          title: 'Grand Sovereign #2',
          ringColor: Color(0xFFE2E8F0), // 🥈 Exclusive Silver Ring for Rank 2
          ringGlowColor: Color(0xFF94A3B8),
        );
      case 3:
        // 🌌 Rank 3: Cosmic Midnight Indigo & Starfield (Swapped from Rank 9 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 3,
          gradientColors: [Color(0xFF0E133D), Color(0xFF1C276E), Color(0xFF080B26)],
          primaryColor: Color(0xFF818CF8),
          accentColor: Color(0xFFA5B4FC),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFC7D2FE),
          btnGradient: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          btnColor: Color(0xFFEEF2FF),
          btnTextColor: Color(0xFF3730A3),
          borderColor: Color(0xFF6366F1),
          title: 'Celestial Titan #3',
          ringColor: Color(0xFFCD7F32), // 🥉 Exclusive Imperial Bronze Ring for Rank 3
          ringGlowColor: Color(0xFFB45309),
        );
      case 4:
        // 🌸 Rank 4: Radiant Orchid Pink & Champagne (Swapped from Rank 1 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 4,
          gradientColors: [Color(0xFF381528), Color(0xFF5E1B43), Color(0xFF2B0E1E)],
          primaryColor: Color(0xFFF472B6),
          accentColor: Color(0xFFFBCFE8),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFFBCFE8),
          btnGradient: [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
          btnColor: Color(0xFFFFE4E6),
          btnTextColor: Color(0xFF881337),
          borderColor: Color(0xFFF472B6),
          title: 'High Vanguard #4',
          ringColor: Color(0xFFF472B6),
          ringGlowColor: Color(0xFFFBCFE8),
        );
      case 5:
        // 🍃 Rank 5: Deep Emerald Jade & Mint Silk (100% Lush Green)
        return const PocketTopRankTheme(
          rank: 5,
          gradientColors: [Color(0xFF062B1D), Color(0xFF0F4E36), Color(0xFF031C13)],
          primaryColor: Color(0xFF34D399),
          accentColor: Color(0xFF6EE7B7),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFA7F3D0),
          btnGradient: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          btnColor: Color(0xFFECFDF5),
          btnTextColor: Color(0xFF065F46),
          borderColor: Color(0xFF10B981),
          title: 'Emerald Guardian #5',
          ringColor: Color(0xFF10B981),
          ringGlowColor: Color(0xFF6EE7B7),
        );
      case 6:
        // 🍯 Rank 6: Solar Amber Gold & Warm Bronze (100% Rich Gold)
        return const PocketTopRankTheme(
          rank: 6,
          gradientColors: [Color(0xFF332004), Color(0xFF5C3C08), Color(0xFF241602)],
          primaryColor: Color(0xFFFBBF24),
          accentColor: Color(0xFFFDE68A),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFFEF3C7),
          btnGradient: [Color(0xFFFEFCE8), Color(0xFFFEF08A)],
          btnColor: Color(0xFFFEFCE8),
          btnTextColor: Color(0xFF78350F),
          borderColor: Color(0xFFF59E0B),
          title: 'Solar Paladin #6',
          ringColor: Color(0xFFF59E0B),
          ringGlowColor: Color(0xFFFDE68A),
        );
      case 7:
        // 🌅 Rank 7: Sunset Tangerine Coral (100% Vibrant Orange)
        return const PocketTopRankTheme(
          rank: 7,
          gradientColors: [Color(0xFF3B1506), Color(0xFF66270E), Color(0xFF260D03)],
          primaryColor: Color(0xFFFB923C),
          accentColor: Color(0xFFFDBA74),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFFFEDD5),
          btnGradient: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          btnColor: Color(0xFFFFF7ED),
          btnTextColor: Color(0xFF9A3412),
          borderColor: Color(0xFFEA580C),
          title: 'Flaming Commander #7',
          ringColor: Color(0xFFEA580C),
          ringGlowColor: Color(0xFFFDBA74),
        );
      case 8:
        // 🍷 Rank 8: Royal Crimson Wine & Velvet Maroon (Swapped from Rank 2 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 8,
          gradientColors: [Color(0xFF340D18), Color(0xFF521424), Color(0xFF22060E)],
          primaryColor: Color(0xFFFB7185),
          accentColor: Color(0xFFFDA4AF),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFFECDD3),
          btnGradient: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          btnColor: Color(0xFFFFF1F2),
          btnTextColor: Color(0xFF9F1239),
          borderColor: Color(0xFFF43F5E),
          title: 'Crimson Marshal #8',
          ringColor: Color(0xFFF43F5E),
          ringGlowColor: Color(0xFFFDA4AF),
        );
      case 9:
        // 💎 Rank 9: Radiant Sapphire & Celestial Azure (Swapped from Rank 3 per User Audio Directive)
        return const PocketTopRankTheme(
          rank: 9,
          gradientColors: [Color(0xFF0A1B38), Color(0xFF163E78), Color(0xFF061124)],
          primaryColor: Color(0xFF60A5FA),
          accentColor: Color(0xFF93C5FD),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFBFDBFE),
          btnGradient: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          btnColor: Color(0xFF2563EB),
          btnTextColor: Color(0xFFFFFFFF),
          borderColor: Color(0xFF3B82F6),
          title: 'Sapphire Knight #9',
          ringColor: Color(0xFF3B82F6),
          ringGlowColor: Color(0xFF93C5FD),
        );
      case 10:
        // ⚡ Rank 10: Cyber Neon Magenta & Electric Fuchsia (100% Magenta)
        return const PocketTopRankTheme(
          rank: 10,
          gradientColors: [Color(0xFF380933), Color(0xFF611158), Color(0xFF240420)],
          primaryColor: Color(0xFFE879F9),
          accentColor: Color(0xFFF0ABFC),
          textColor: Color(0xFFFFFFFF),
          secondaryTextColor: Color(0xFFF5D0FE),
          btnGradient: [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
          btnColor: Color(0xFFFDF4FF),
          btnTextColor: Color(0xFF86198F),
          borderColor: Color(0xFFD946EF),
          title: 'Cyber Valkyrie #10',
          ringColor: Color(0xFFD946EF),
          ringGlowColor: Color(0xFFF0ABFC),
        );
      default:
        return null;
    }
  }
}
