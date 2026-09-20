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

/// ⚡ Slang to Smart English (നിത്യജീവിത ശൈലികൾ)
class PocketSlangSmartEnglishCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;

  const PocketSlangSmartEnglishCard({
    super.key,
    required this.day,
    required this.selectedLanguage,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
  });

  @override
  State<PocketSlangSmartEnglishCard> createState() =>
      _PocketSlangSmartEnglishCardState();
}

class _PocketSlangSmartEnglishCardState
    extends State<PocketSlangSmartEnglishCard> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFEC4899).withValues(alpha: 0.35),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '💬 SLANG ➔ SMART',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('⚡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Daily Slang to Smart English (നിത്യജീവിത ശൈലികൾ)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.isCompleted)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Replace native vernacular thoughts with native-sounding English reflex!',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),

          // Slang Items List
          Column(
            children: kSlangItems.map((item) {
              final vernacular = item.getVernacular(widget.selectedLanguage);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vernacular Thought
                    Row(
                      children: [
                        const Text('🗣️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            '"$vernacular"',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFDA4AF),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded,
                              color: Color(0xFFFFD700), size: 18),
                          onPressed: () => widget.onSpeak(item.englishPhrase),
                          tooltip: 'Listen to English reflex',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Smart English Equivalent
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '➔ ${item.englishPhrase}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '• ${item.context}',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onCompleted(true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '⚡ Native Slang Reflexes Practiced! Direct speech activated (+15 PTS) ✓'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                widget.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.auto_fix_high_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                widget.isCompleted
                    ? 'SLANG REFLEXES MASTERED ✓'
                    : 'I DRILLED THESE SMART SLANGS ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEC4899),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
