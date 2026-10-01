import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 🌐 Interactive Native Language Selection Modal
/// Persists the user's choice to SharedPreferences globally across all learning screens.
class PocketLanguageSelectionDialog extends StatefulWidget {
  final String currentLanguage;
  final bool isFirstLaunch;

  const PocketLanguageSelectionDialog({
    super.key,
    required this.currentLanguage,
    this.isFirstLaunch = false,
  });

  static const String kPrefLangKey = 'pocket_mission_pref_lang';
  static const String kHasChosenLangKey = 'pocket_user_has_selected_lang';

  static const List<Map<String, String>> kLanguages = [
    {
      'code': 'Hindi',
      'name': 'हिन्दी',
      'englishName': 'Hindi',
      'flag': '🇮🇳',
      'desc': 'सरल हिन्दी में सम्पूर्ण व्याख्या और अभ्यास',
    },
    {
      'code': 'Tamil',
      'name': 'தமிழ்',
      'englishName': 'Tamil',
      'flag': '🇮🇳',
      'desc': 'தமிழ் மூலமாக எளிய ஆங்கிலப் பயிற்சி',
    },
    {
      'code': 'Malayalam',
      'name': 'മലയാളം',
      'englishName': 'Malayalam',
      'flag': '🇮🇳',
      'desc': 'മാതൃഭാഷയിലൂടെ ഇംഗ്ലീഷ് വേഗത്തിൽ സംസാരിക്കാൻ പഠിക്കാം',
    },
    {
      'code': 'Telugu',
      'name': 'తెలుగు',
      'englishName': 'Telugu',
      'flag': '🇮🇳',
      'desc': 'తెలుగు ద్వారా స్పష్టమైన ఆంగ్ల సంభాషణ',
    },
    {
      'code': 'Kannada',
      'name': 'ಕನ್ನಡ',
      'englishName': 'Kannada',
      'flag': '🇮🇳',
      'desc': 'ಕನ್ನಡದ ಮೂಲಕ ಸುಲಭ ಇಂಗ್ಲಿಷ್ ಕಲಿಕೆ',
    },
    {
      'code': 'English',
      'name': 'English',
      'englishName': 'Direct English',
      'flag': '🇬🇧',
      'desc': '100% Direct English immersion without translation',
    },
  ];

  static Future<String?> show(
    BuildContext context, {
    String? currentLanguage,
    bool isFirstLaunch = false,
  }) async {
    final active = currentLanguage ?? PocketLanguageService.currentLanguage;

    if (!context.mounted) return null;

    return showDialog<String>(
      context: context,
      barrierDismissible: !isFirstLaunch,
      builder: (_) => PocketLanguageSelectionDialog(
        currentLanguage: active,
        isFirstLaunch: isFirstLaunch,
      ),
    );
  }

  @override
  State<PocketLanguageSelectionDialog> createState() =>
      _PocketLanguageSelectionDialogState();
}

class _PocketLanguageSelectionDialogState
    extends State<PocketLanguageSelectionDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLanguage;
  }

  Future<void> _confirmAndSave() async {
    HapticFeedback.heavyImpact();
    try {
      await PocketLanguageService.setNativeLanguage(_selected);
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 24,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF00FFCC), width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with glowing icon
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FFCC), Color(0xFF3B82F6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFCC).withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌐', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isFirstLaunch
                            ? 'CHOOSE YOUR NATIVE LANGUAGE'
                            : 'SELECT EXPLANATION LANGUAGE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00FFCC),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'മാതൃഭാഷ തിരഞ്ഞെടുക്കുക',
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isFirstLaunch)
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Select your native tongue for grammar tips, vocabulary definitions, and voice breakdowns. Applied globally across all mission detail pages.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 16),

            // Language Options List
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: PocketLanguageSelectionDialog.kLanguages.map((item) {
                    final code = item['code']!;
                    final isSelected = _selected == code;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = code);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF0B1120),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white12,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                item['flag']!,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item['name']!,
                                          style: GoogleFonts.outfit(
                                            color: isSelected
                                                ? const Color(0xFFFFD700)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${item['englishName']})',
                                          style: GoogleFonts.inter(
                                            color: Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.white38,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFFFFD700)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white38,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.black)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _confirmAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.black, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'APPLY GLOBALLY ✓',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
