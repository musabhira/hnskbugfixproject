import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SlangPairItem {
  final String englishPhrase;
  final String context;
  final Map<String, String> vernacularTranslations;

  const SlangPairItem({
    required this.englishPhrase,
    required this.context,
    required this.vernacularTranslations,
  });

  String getVernacular(String language) {
    return vernacularTranslations[language] ??
        vernacularTranslations['Malayalam'] ??
        vernacularTranslations['English'] ??
        '';
  }
}

/// ⚡ Minimal Arcade Slang-to-Smart Reflex Game (നിത്യജീവിത ശൈലികൾ)
/// 1-card-at-a-time reflex arena with tap-to-reveal native English,
/// audio pronunciation on demand, and seamless side navigation.
class PocketSlangSmartEnglishCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketSlangSmartEnglishCard({
    super.key,
    required this.day,
    required this.selectedLanguage,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '4',
  });

  @override
  State<PocketSlangSmartEnglishCard> createState() =>
      _PocketSlangSmartEnglishCardState();
}

class _PocketSlangSmartEnglishCardState
    extends State<PocketSlangSmartEnglishCard> {
  int _currentIndex = 0;
  final Set<int> _revealedCards = {};

  static const List<SlangPairItem> kSlangItems = [
    SlangPairItem(
      englishPhrase: "It's no big deal! / Don't sweat it.",
      context: 'When something minor happens and you want to reassure them',
      vernacularTranslations: {
        'Malayalam': 'അത് വലിയ സീനൊന്നുമില്ല / സാരമില്ല',
        'Hindi': 'कोई बड़ी बात नहीं है / ज्यादा मत सोचो',
        'Tamil': 'அது பெரிய விஷயம் இல்ல / கவலைப்படாதே',
        'Telugu': 'అంత పెద్ద విషయమేమీ కాదు / చింతించకండి',
        'Kannada': 'ಅದೇನು ದೊಡ್ಡ ವಿಷಯವಲ್ಲ / ಚಿಂತಿಸಬೇಡಿ',
        'English': 'No serious problem, do not worry.',
      },
    ),
    SlangPairItem(
      englishPhrase: "Don't make things up! / Cut to the chase.",
      context: 'When someone is exaggerating or talking around in circles',
      vernacularTranslations: {
        'Malayalam': 'വെറുതെ ഓരോന്ന് ഉണ്ടാക്കല്ലേ / നേരെ കാര്യത്തിലേക്ക് വാ',
        'Hindi': 'फालतू की बातें मत बनाओ / सीधे मुद्दे पर आओ',
        'Tamil': 'சுற்றி வளைக்காமல் நேரா விஷயத்துக்கு வா',
        'Telugu': 'అడ్డదిడ్డంగా మాట్లాడకు / నేరుగా విషయానికి రా',
        'Kannada': 'ಸುಳ್ಳು ಕಥೆ ಕಟ್ಟಬೇಡಿ / ನೇರವಾಗಿ ವಿಷಯಕ್ಕೆ ಬನ್ನಿ',
        'English': 'Do not fabricate stories, speak directly.',
      },
    ),
    SlangPairItem(
      englishPhrase: "I'm losing my cool! / I'm so frustrated.",
      context: 'When you are extremely angry or irritated with a situation',
      vernacularTranslations: {
        'Malayalam': 'എനിക്ക് നല്ല കലിപ്പ് വരുന്നുണ്ട് / നിയന്ത്രണം വിടുന്നു',
        'Hindi': 'मुझे बहुत गुस्सा आ रहा है / मेरा दिमाग खराब हो रहा है',
        'Tamil': 'எனக்கு ரொம்ப கோபம் வருது / கடுப்பாகுது',
        'Telugu': 'నాకు చాలా కోపం వస్తోంది',
        'Kannada': 'ನನಗೆ ತುಂಬಾ ಕೋಪ ಬರುತ್ತಿದೆ',
        'English': 'I am getting very angry and irritated.',
      },
    ),
    SlangPairItem(
      englishPhrase: "Let me freshen up real quick.",
      context: 'When you arrive somewhere and need 5 minutes to wash your face',
      vernacularTranslations: {
        'Malayalam': 'ഞാൻ ഒന്ന് ഫ്രഷായി വരാം',
        'Hindi': 'मैं जरा फ्रेश होकर आता हूँ',
        'Tamil': 'நான் கொஞ்சம் ஃப்ரெஷ் ஆகிட்டு வரேன்',
        'Telugu': 'నేను కాస్త ఫ్రెష్ అయి వస్తాను',
        'Kannada': 'ನಾನು ಸ್ವಲ್ಪ ಫ್ರೆಶ್ ಆಗಿ ಬರುತ್ತೇನೆ',
        'English': 'Let me wash up and get ready quickly.',
      },
    ),
    SlangPairItem(
      englishPhrase: "Let's catch up later / I'll circle back to you.",
      context: 'When you need to end a conversation politely and talk later',
      vernacularTranslations: {
        'Malayalam': 'നമുക്ക് പിന്നെ സംസാരിക്കാം / ഞാൻ തിരിച്ചു വിളിക്കാം',
        'Hindi': 'हम बाद में बात करते हैं',
        'Tamil': 'நாம் அப்புறம் பேசலாம்',
        'Telugu': 'మనం తర్వాత మాట్లాడదాం',
        'Kannada': 'ನಾವು ನಂತರ ಮಾತನಾಡೋಣ',
        'English': 'We will talk later, I will contact you soon.',
      },
    ),
  ];

  void _revealCurrent() {
    HapticFeedback.lightImpact();
    setState(() {
      _revealedCards.add(_currentIndex);
    });
    if (_revealedCards.length >= 3 && !widget.isCompleted) {
      widget.onCompleted(true);
    }
  }

  void _nextCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex + 1) % kSlangItems.length;
    });
  }

  void _prevCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + kSlangItems.length) % kSlangItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = kSlangItems[_currentIndex];
    final vernacular = item.getVernacular(widget.selectedLanguage);
    final isRevealed = _revealedCards.contains(_currentIndex);
    final totalCards = kSlangItems.length;
    final cardNum = _currentIndex + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17), // Minimal, plain dark game canvas
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFEC4899).withValues(alpha: 0.4),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEC4899))
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP GAME HUD ─────────────────────────────────────────────────
          Row(
            children: [
              // Step Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber} • GAME'
                      : 'SLANG ARENA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Card Counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'CARD $cardNum / $totalCards',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF472B6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Quick Side Navigation Controls in HUD
              InkWell(
                onTap: _prevCard,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white70, size: 18),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _nextCard,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── TITLE & SUBTITLE ─────────────────────────────────────────────
          Text(
            _getTitle(widget.selectedLanguage),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getSubtitle(widget.selectedLanguage),
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 14),

          // ── HERO FLASHCARD (CASUAL GAME CARD) ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRevealed
                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                    : const Color(0xFFEC4899).withValues(alpha: 0.3),
                width: isRevealed ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isRevealed
                      ? const Color(0xFF10B981).withValues(alpha: 0.08)
                      : const Color(0xFFEC4899).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Context Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.context,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFBCFE8),
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Vernacular Thought Bubble
                Text(
                  '🗣️ Vernacular Thought:',
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vernacular,
                  style: GoogleFonts.notoSans(
                    color: const Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                // ── REVEALED RESULT OR REVEAL BUTTON ───────────────────────
                if (isRevealed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              'Smart English Reflex:',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF6EE7B7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // Audio Speaker button on demand
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded,
                                  color: Color(0xFFFFD700), size: 20),
                              onPressed: () =>
                                  widget.onSpeak(item.englishPhrase),
                              tooltip: 'Listen to pronunciation',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.englishPhrase,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Tap to Reveal Neon Arcade Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _revealCurrent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFEC4899),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.flash_on_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        '⚡ TAP TO REVEAL SMART ENGLISH',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── PROGRESS CAPSULES (1 TO 5) ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalCards, (idx) {
              final isCurrent = idx == _currentIndex;
              final isRev = _revealedCards.contains(idx);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 24 : 10,
                height: 6,
                decoration: BoxDecoration(
                  color: isRev
                      ? const Color(0xFF10B981)
                      : (isCurrent
                          ? const Color(0xFFEC4899)
                          : Colors.white24),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // ── BOTTOM SIDE NAVIGATION DECK ──────────────────────────────────
          Row(
            children: [
              // PREV BUTTON
              OutlinedButton.icon(
                onPressed: _prevCard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: Text(
                  'PREV',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // NEXT CARD or VERIFY BUTTON
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (cardNum < totalCards) {
                      _nextCard();
                    } else {
                      widget.onCompleted(true);
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '⚡ Smart Slangs Mastered! Reflex speaking unlocked (+25 PTS) ✓'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    cardNum < totalCards
                        ? Icons.arrow_forward_rounded
                        : Icons.check_circle_rounded,
                    size: 16,
                  ),
                  label: Text(
                    cardNum < totalCards
                        ? 'NEXT SLANG (${cardNum + 1}/$totalCards) ➔'
                        : _getButtonLabel(
                            widget.selectedLanguage, widget.isCompleted),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'Daily Slang to Smart English (அன்றாட பயன்பாடு)';
      case 'telugu':
        return 'Daily Slang to Smart English (నిత్యజీవిత శైలులు)';
      case 'hindi':
        return 'Daily Slang to Smart English (दैनिक बोलचाल)';
      case 'kannada':
        return 'Daily Slang to Smart English (ದೈನಂದಿನ ಶೈಲಿಗಳು)';
      case 'malayalam':
        return 'Daily Slang to Smart English (നിത്യജീവിത ശൈലികൾ)';
      default:
        return 'Daily Slang to Smart English (Real-Life Spoken Reflex)';
    }
  }

  String _getSubtitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'பேச்சுவழக்கு எண்ணங்களை இயல்பான ஆங்கிலமாக மாற்றுங்கள்!';
      case 'telugu':
        return 'స్థానిక భావాలను సహజమైన ఆంగ్ల ప్రతిస్పందనగా మార్చండి!';
      case 'hindi':
        return 'अपनी क्षेत्रीय सोच को धाराप्रवाह अंग्रेजी में बदलें!';
      case 'kannada':
        return 'ಸ್ಥಳೀಯ ಯೋಚನೆಗಳನ್ನು ಸಹಜ ಇಂಗ್ಲಿಷ್ ಶೈಲಿಗೆ ಬದಲಾಯಿಸಿ!';
      case 'malayalam':
        return 'പ്രാദേശിക ചിന്തകളെ സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലിയിലേക്ക് മാറ്റുക!';
      default:
        return 'Replace native vernacular thoughts with native-sounding English reflex!';
    }
  }

  String _getButtonLabel(String language, bool isCompleted) {
    if (isCompleted) {
      switch (language.toLowerCase()) {
        case 'tamil':
          return 'நடைமுறை ஆங்கிலம் கற்றேன் ✓';
        case 'telugu':
          return 'స్లాంగ్స్ నేర్చుకున్నాను ✓';
        case 'hindi':
          return 'दैनिक बोलचाल पूरी हुई ✓';
        case 'kannada':
          return 'ಶೈಲಿಗಳನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿದೆ ✓';
        case 'malayalam':
          return 'ശൈലികൾ പരിശീലിച്ചു കഴിഞ്ഞു ✓';
        default:
          return 'SLANG REFLEXES MASTERED ✓';
      }
    } else {
      switch (language.toLowerCase()) {
        case 'tamil':
          return 'இந்த நடைமுறை ஆங்கிலத்தைப் பழகினேன் ✓';
        case 'telugu':
          return 'స్మార్ట్ స్లాంగ్స్ సాధన చేశాను ✓';
        case 'hindi':
          return 'दैनिक बोलचाल का अभ्यास किया ✓';
        case 'kannada':
          return 'ಈ ಶೈಲಿಗಳನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿದೆ ✓';
        case 'malayalam':
          return 'ഈ ശൈലികൾ സംസാരിച്ചു ശീലിച്ചു ✓';
        default:
          return 'I DRILLED THESE SMART SLANGS ✓';
      }
    }
  }
}
