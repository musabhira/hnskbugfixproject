import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model representing a Secret Code Grammar Formula
class SecretCodeFormulaItem {
  final String codeId;
  final String codeName;
  final String category;
  final String icon;
  final Color color;
  final String formula;
  final String buggyExample;
  final String correctExample;
  final Map<String, String> localizedRules;

  const SecretCodeFormulaItem({
    required this.codeId,
    required this.codeName,
    required this.category,
    required this.icon,
    required this.color,
    required this.formula,
    required this.buggyExample,
    required this.correctExample,
    required this.localizedRules,
  });

  String getRule(String language) {
    return localizedRules[language] ??
        localizedRules['Malayalam'] ??
        localizedRules['English'] ??
        '';
  }
}

/// ⚡ Secret Code Grammar Matrix (കോഡ് ഭാഷ വെച്ച് ഇംഗ്ലീഷ് ഫോർമുലകൾ)
class PocketSecretCodeGrammarCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketSecretCodeGrammarCard({
    super.key,
    required this.day,
    required this.selectedLanguage,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '2',
  });

  @override
  State<PocketSecretCodeGrammarCard> createState() =>
      _PocketSecretCodeGrammarCardState();
}

class _PocketSecretCodeGrammarCardState
    extends State<PocketSecretCodeGrammarCard> {
  int _selectedCodeIndex = 0;

  static const List<SecretCodeFormulaItem> kCheatCodes = [
    SecretCodeFormulaItem(
      codeId: 'D-1',
      codeName: 'CODE [D-1]: The Did-Eraser',
      category: 'Past Question Code',
      icon: '⏪',
      color: Color(0xFFF43F5E),
      formula: 'DID + [SUBJECT] + [BASE VERB (V1)]',
      buggyExample: 'Did you went to the office yesterday? ❌',
      correctExample: 'Did you GO to the office yesterday? ✅',
      localizedRules: {
        'Malayalam':
            '⚠️ രഹസ്യ കോഡ് റൂൾ: "Did" വാചകത്തിൽ കയറിയ നിമിഷം അത് കഴിഞ്ഞകാലത്തെ (Past Tense) മായ്ക്കും! പിന്നീട് ഒരിക്കലും "went", "saw", "came" എന്ന് പറയരുത്. ആദ്യ രൂപം (V1: go, see, come) മാത്രമേ വരാവൂ.',
        'Hindi':
            '⚠️ गुप्त कोड नियम: जब वाक्य में "Did" आ जाता है, तो क्रिया का Past Tense मिट जाता है! कभी भी 2nd form (went/saw) न लगाएं, हमेशा Base Verb (go/see) ही लगाएं।',
        'Tamil':
            '⚠️ ரகசிய குறியீடு விதி: வாக்கியத்தில் "Did" வந்தவுடன், அது Past Tense-ஐ அழித்துவிடும்! எனவே "went/saw" சொல்லக்கூடாது, எப்போதும் Base Verb (go/see) மட்டுமே வர வேண்டும்.',
        'Telugu':
            '⚠️ సీక్రెట్ కోడ్ రూల్: వాక్యంలో "Did" వచ్చిన వెంటనే అది Past Tense ని తొలగిస్తుంది! అందుకే "went/saw" అనకూడదు, కేవలం Base Verb (go/see) మాత్రమే వాడాలి.',
        'Kannada':
            '⚠️ ಸೀಕ್ರೆಟ್ ಕೋಡ್ ನಿಯಮ: ವಾಕ್ಯದಲ್ಲಿ "Did" ಬಂದಾಗ ಅದು Past Tense ಅನ್ನು ಅಳಿಸುತ್ತದೆ! ಆದ್ದರಿಂದ "went/saw" ಬಳಸಬೇಡಿ, ಕೇವಲ Base Verb (go/see) ಮಾತ್ರ ಬಳಸಿ.',
        'English':
            '⚠️ Secret Code Rule: The moment "Did" enters the sentence, it erases the past tense from the main verb. Always use Base Verb V1 (e.g. Did you GO, NOT went)!',
      },
    ),
    SecretCodeFormulaItem(
      codeId: 'F-1',
      codeName: 'CODE [F-1]: The Will-Laser',
      category: 'Instant Future Projection',
      icon: '⏩',
      color: Color(0xFF00E5FF),
      formula: 'WILL + [BASE VERB (V1)]',
      buggyExample: 'I will going tomorrow. / I will went. ❌',
      correctExample: 'I will GO tomorrow at 9 AM. ✅',
      localizedRules: {
        'Malayalam':
            '⚡ ഭാവി കാര്യങ്ങൾക്ക് തട്ടിത്തടയാതെ ഉപയോഗിക്കാവുന്ന ലേസർ കോഡ്. "Will" കഴിഞ്ഞാൽ നേരെ സിമ്പിൾ വെർബ് (I will call / She will finish).',
        'Hindi':
            '⚡ भविष्य की बातों के लिए सीधा लेजर कोड। "Will" के बाद हमेशा साधारण क्रिया लगाएं (I will call / She will finish).',
        'Tamil':
            '⚡ எதிர்கால விஷயங்களை தயக்கமின்றி பேச லேசர் கோட். "Will" பின் எப்போதும் எளிய வினைச்சொல் மட்டுமே (I will call / She will finish).',
        'Telugu':
            '⚡ భవిష్యత్ పనులను తడబాటు లేకుండా చెప్పే లేజర్ కోడ్. "Will" తర్వాత నేరుగా సాధారణ క్రియ మాత్రమే వాడాలి.',
        'Kannada':
            '⚡ ಭವಿಷ್ಯದ ಮಾತುಗಳನ್ನು ನೇರವಾಗಿ ಹೇಳಲು ಲೇಸರ್ ಕೋಡ್. "Will" ನಂತರ ನೇರವಾಗಿ ಸರಳ ಕ್ರಿಯಾಪದ ಬಳಸಿ.',
        'English':
            '⚡ Future Projection Code: Use "WILL + Base Verb" for instantaneous decision without grammatical lag.',
      },
    ),
    SecretCodeFormulaItem(
      codeId: 'H-3',
      codeName: 'CODE [H-3]: The Pocket-Memory',
      category: 'Present Effect Code',
      icon: '📦',
      color: Color(0xFFFFD700),
      formula: 'HAVE / HAS + [V3 PAST PARTICIPLE]',
      buggyExample: 'I lost my phone. (Maybe you found it yesterday) ❓',
      correctExample: 'I have lost my phone! (It is still lost right now) ✅',
      localizedRules: {
        'Malayalam':
            '📦 സംഭവം കഴിഞ്ഞതാണെങ്കിലും അതിന്റെ ഫലം അല്ലെങ്കിൽ പ്രശ്നം ഇപ്പോഴും നിങ്ങളുടെ പോക്കറ്റിൽ ഉണ്ടെങ്കിൽ ഈ കോഡ് ഉപയോഗിക്കുക (Have + V3). ഉദാ: "I have eaten" = ഭക്ഷണം കഴിച്ചു കഴിഞ്ഞു, ഇപ്പോൾ വിശപ്പില്ല.',
        'Hindi':
            '📦 काम भले ही पहले हो चुका हो, पर उसका असर अभी भी वर्तमान में मौजूद हो तो [Have/Has + V3] लगाएं। जैसे: "I have eaten" = खा चुका हूँ, अभी भूख नहीं है।',
        'Tamil':
            '📦 செயல் முடிந்துவிட்டாலும் அதன் தாக்கம் இப்போது இருக்கும்போது இந்த கோட் பயன்படுத்தவும் (Have + V3). உதா: "I have eaten" = சாப்பிட்டுவிட்டேன், இப்போது பசியில்லை.',
        'Telugu':
            '📦 పని జరిగిపోయినా దాని ప్రభావం ఇప్పుడు కూడా ఉంటే [Have/Has + V3] వాడాలి.',
        'Kannada':
            '📦 ಕೆಲಸ ಮುಗಿದಿದ್ದರೂ ಅದರ ಪರಿಣಾಮ ಈಗಲೂ ಪ್ರಸ್ತುತವಾಗಿದ್ದರೆ [Have/Has + V3] ಬಳಸಿ.',
        'English':
            '📦 Completed action with present impact: Use Have/Has + V3 when the result is alive right now in the present moment.',
      },
    ),
    SecretCodeFormulaItem(
      codeId: 'NOW-ING',
      codeName: 'CODE [NOW-ING]: The Motion Radar',
      category: 'Live Motion Tracker',
      icon: '🔄',
      color: Color(0xFF10B981),
      formula: 'IS / AM / ARE + [VERB-ING]',
      buggyExample: 'I am work in Bangalore. ❌',
      correctExample: 'I am WORKING right now. / I work in Bangalore. ✅',
      localizedRules: {
        'Malayalam':
            '🔄 നിങ്ങളുടെ കൺമുന്നിൽ ഇപ്പോൾ ചലിച്ചുകൊണ്ടിരിക്കുന്ന കാര്യങ്ങൾക്ക് മാത്രം "ING" നൽകുക. സ്ഥിരമായ കാര്യങ്ങൾക്ക് ING വേണ്ട (I live here, not I am living here).',
        'Hindi':
            '🔄 जो काम आपकी आँखों के सामने अभी चल रहा हो, सिर्फ उसमें "ING" लगाएं। सामान्य सच के लिए ING न लगाएं (I work here, not I am working here).',
        'Tamil':
            '🔄 உங்கள் கண்முன்னே இப்போது நடக்கும் செயல்களுக்கு மட்டுமே "ING" பயன்படுத்தவும்.',
        'Telugu':
            '🔄 మీ కళ్ళముందు ఇప్పుడు జరుగుతున్న పనులకే "ING" వాడాలి.',
        'Kannada':
            '🔄 ನಿಮ್ಮ ಕಣ್ಣೆದುರು ಈಗ ನಡೆಯುತ್ತಿರುವ ಕೆಲಸಗಳಿಗೆ ಮಾತ್ರ "ING" ಸೇರಿಸಿ.',
        'English':
            '🔄 Motion Radar: Only use "IS/AM/ARE + ING" for real-time live ongoing actions, not permanent habits.',
      },
    ),
    SecretCodeFormulaItem(
      codeId: '1-2-3',
      codeName: 'CODE [1-2-3]: The Sentence Flip',
      category: 'Structural Alignment Code',
      icon: '🔀',
      color: Color(0xFFA855F7),
      formula: '[1: SUBJECT] ➔ [2: ACTION/VERB] ➔ [3: TARGET/OBJECT]',
      buggyExample: 'I tea drank. (Native Indian 1-3-2 Order) ❌',
      correctExample: 'I [1] DRANK [2] tea [3]. (English 1-2-3 Flip) ✅',
      localizedRules: {
        'Malayalam':
            '🔀 മലയാളത്തിൽ "ഞാൻ (1) ചായ (3) കുടിച്ചു (2)" എന്ന് പറയുമ്പോൾ, ഇംഗ്ലീഷിൽ ആക്ഷൻ എപ്പോഴും നടുവിലേക്ക് ചാടണം: "I (1) drank (2) tea (3)"!',
        'Hindi':
            '🔀 हिन्दी में "मैंने (1) चाय (3) पी (2)" होता है, पर अंग्रेजी में क्रिया बीच में आ जाती है: "I (1) drank (2) tea (3)"!',
        'Tamil':
            '🔀 தமிழில் "நான் (1) டீ (3) குடித்தேன் (2)" என்பது ஆங்கிலத்தில்: "I (1) drank (2) tea (3)" என்று நடுவில் வரும்!',
        'Telugu':
            '🔀 తెలుగులో "నేను (1) టీ (3) తాగాను (2)" అనేది ఇంగ్లీషులో "I (1) drank (2) tea (3)" గా మారుతుంది!',
        'Kannada':
            '🔀 ಕನ್ನಡದಲ್ಲಿ "ನಾನು (1) ಚಹಾ (3) ಕುಡಿದೆ (2)" ಎನ್ನುವುದು ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ "I (1) drank (2) tea (3)" ಆಗುತ್ತದೆ!',
        'English':
            '🔀 Structural Flip: Flip from native SOV (1-3-2) to clean English SVO (1-2-3: Subject ➔ Verb ➔ Object)!',
      },
    ),
    SecretCodeFormulaItem(
      codeId: 'CW',
      codeName: 'CODE [CW]: Polite Supercharger',
      category: 'Diplomatic Aura Code',
      icon: '🎩',
      color: Color(0xFFEC4899),
      formula: 'COULD YOU / WOULD YOU + [BASE VERB]?',
      buggyExample: 'Give me that file right now! (Sounds rude/bossy) ❌',
      correctExample: 'Could you please share that file? (Gentleman aura) ✅',
      localizedRules: {
        'Malayalam':
            '🎩 ഓർഡർ ഇടുന്നതിന് പകരം "Could you / Would you" ചേർത്താൽ ആ നിമിഷം നിങ്ങളുടെ സംസാരം 10x പ്രൊഫഷണലും മാന്യവുമാകും.',
        'Hindi':
            '🎩 सीधे हुक्म देने के बजाय "Could you / Would you" लगाएं, आपकी बात में तुरंत विनम्रता और प्रोफेशनलिज्म आ जाएगा।',
        'Tamil':
            '🎩 கட்டளையிடுவதற்கு பதிலாக "Could you / Would you" சேர்த்தால் பேச்சு மிகவும் மரியாதையாக மாறும்.',
        'Telugu':
            '🎩 ఆర్డర్ వేసే బదులు "Could you / Would you" కలిపితే మాట చాలా హుందాగా మారుతుంది.',
        'Kannada':
            '🎩 ಆಜ್ಞೆ ಮಾಡುವ ಬದಲಿಗೆ "Could you / Would you" ಬಳಸಿದರೆ ನಿಮ್ಮ ಮಾತು ಹೆಚ್ಚು ಗೌರವಯುತವಾಗುತ್ತದೆ.',
        'English':
            '🎩 Instant Politeness Supercharger: Prepend "Could you / Would you" to convert blunt commands into high-EQ requests.',
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final code = kCheatCodes[_selectedCodeIndex.clamp(0, kCheatCodes.length - 1)];
    final ruleText = code.getRule(widget.selectedLanguage);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFFFD700).withValues(alpha: 0.35),
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
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber}'
                      : '⚡ CHEAT CODES',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🔐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Secret Code Grammar (കോഡ് ഭാഷാ ഇംഗ്ലീഷ്)',
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
            'No-Jargon Cheat Codes to master Tenses & Sentence Order instantly!',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Code Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kCheatCodes.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isSelected = idx == _selectedCodeIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCodeIndex = idx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withValues(alpha: 0.25)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? item.color : Colors.white12,
                          width: isSelected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            item.codeId,
                            style: GoogleFonts.firaCode(
                              color: isSelected ? item.color : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Code Formula Banner Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: code.color.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: code.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: code.color, width: 0.8),
                      ),
                      child: Text(
                        code.category.toUpperCase(),
                        style: GoogleFonts.firaCode(
                          color: code.color,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFFFD700), size: 18),
                      onPressed: () => widget.onSpeak(code.correctExample),
                      tooltip: 'Listen to native code execution',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  code.codeName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Monospace Formula
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code.formula,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Localized Secret Explanation
                Text(
                  ruleText,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFBAE6FD),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Buggy vs Correct Side-by-Side
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code.buggyExample,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFCA5A5),
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code.correctExample,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6EE7B7),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Completion Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onCompleted(true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '⚡ ${code.codeName} Locked into Memory! Zero grammar lag verified (+20 PTS) ✓'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(
                widget.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.bolt_rounded,
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                widget.isCompleted
                    ? 'ALL CHEAT CODES VERIFIED ✓'
                    : 'I DRILLED THIS CODE FORMULA ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFD700),
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
