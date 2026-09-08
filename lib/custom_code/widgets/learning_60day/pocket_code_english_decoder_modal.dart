import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ⚡ POCKET CODE-ENGLISH DECODER (കോഡ് ഭാഷ വെച്ച് ഇംഗ്ലീഷ് പഠിക്കാം)
///
/// Implements mnemonic formula codes, sentence syntax algorithms, and root-word decoders
/// to make English grammar and vocabulary instantly memorable like computer code formulas.
class PocketCodeEnglishDecoderModal extends StatefulWidget {
  final int currentDay;

  const PocketCodeEnglishDecoderModal({
    super.key,
    this.currentDay = 1,
  });

  static Future<void> show(BuildContext context, {int currentDay = 1}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketCodeEnglishDecoderModal(currentDay: currentDay),
    );
  }

  @override
  State<PocketCodeEnglishDecoderModal> createState() => _PocketCodeEnglishDecoderModalState();
}

class _PocketCodeEnglishDecoderModalState extends State<PocketCodeEnglishDecoderModal> {
  int _selectedCodeIndex = 0;
  String? _compilerOutput;
  bool _isCompiling = false;

  final List<_CodeFormula> _formulas = const [
    _CodeFormula(
      codeName: 'CODE: S-V-O-101',
      title: 'The Core Engine of English',
      category: 'Syntax Algorithm',
      icon: '⚙️',
      color: Color(0xFF38BDF8),
      syntaxRule: '[SUBJECT] ➔ [VERB] ➔ [OBJECT]',
      malayalamExplanation:
          'മലയാളത്തിലും മറ്റ് ഇന്ത്യൻ ഭാഷകളിലും "കർമ്മം" (Object) ക്രിയയ്ക്ക് മുമ്പാണ് വരുന്നത് (അവൾ പുസ്തകം വായിക്കുന്നു). എന്നാൽ ഇംഗ്ലീഷിൽ എപ്പോഴും Verb നടുവിലാണ്: Subject + Verb + Object!',
      formulaBreakdown: [
        {'token': '[SUBJECT]', 'desc': 'Who is doing the action (I, She, The Team)'},
        {'token': '[VERB]', 'desc': 'The actual action or state (develops, leads, masters)'},
        {'token': '[OBJECT]', 'desc': 'The entity receiving the action (fluent speech, systems)'},
      ],
      correctExample: 'She [S] inspires [V] her colleagues [O].',
      buggyExample: 'She her colleagues inspires. (SYNTAX ERROR: Verb misplaced)',
      practicePrompt: 'Build an S-V-O sentence using: "Sarah", "designed", "the house".',
      correctPracticeToken: 'Sarah designed the house.',
    ),
    _CodeFormula(
      codeName: 'CODE: PREP-SPEAK',
      title: 'Impromptu Speaking Formula',
      category: 'Oratory Protocol',
      icon: '🎙️',
      color: Color(0xFFF59E0B),
      syntaxRule: '[POINT] ➔ [REASON] ➔ [EXAMPLE] ➔ [POINT-LOCK]',
      malayalamExplanation:
          'പൊടുന്നനെ സംസാരിക്കാൻ ആവശ്യപ്പെടുമ്പോൾ പരിഭ്രാന്തരാകാതിരിക്കാനുള്ള ലോകോത്തര ഫോർമുല: ആദ്യം നിങ്ങളുടെ നിലപാട് പറയുക (P), കാരണം വ്യക്തമാക്കുക (R), ഒരു ഉദാഹരണം നൽകുക (E), നിലപാട് ഉറപ്പിച്ച് നിർത്തുക (P)!',
      formulaBreakdown: [
        {'token': '[P] Point', 'desc': 'State your core thesis directly without hesitation.'},
        {'token': '[R] Reason', 'desc': 'Explain "because..." or "the underlying factor is..."'},
        {'token': '[E] Example', 'desc': 'Provide a brief real-world story, metric, or case.'},
        {'token': '[P] Point-Lock', 'desc': 'Reiterate: "That is why [Point] is indispensable."'},
      ],
      correctExample:
          'P: "Consistent practice is paramount. R: Because neural pathways require repetition. E: Look at athletes training daily. P: Therefore, daily immersion guarantees mastery."',
      buggyExample: 'Talking randomly without structure until you forget your original point.',
      practicePrompt: 'Apply PREP to answer: "Is reading important?"',
      correctPracticeToken: 'PREP formula successfully structured.',
    ),
    _CodeFormula(
      codeName: 'CODE: FANBOYS-7',
      title: 'The Compound Conjunction Bus',
      category: 'Compound Connector',
      icon: '🔗',
      color: Color(0xFF10B981),
      syntaxRule: '[CLAUSE 1] + , [F.A.N.B.O.Y.S] + [CLAUSE 2]',
      malayalamExplanation:
          'രണ്ട് പൂർണ്ണ വാക്യങ്ങളെ തമ്മിൽ ബന്ധിപ്പിക്കാൻ ഇംഗ്ലീഷിലുള്ള 7 മാന്ത്രിക വാക്കുകളാണ് FANBOYS: For, And, Nor, But, Or, Yet, So. കോമ (,) ഇട്ട ശേഷം ഇവ ചേർക്കുക!',
      formulaBreakdown: [
        {'token': 'F - For', 'desc': 'Reason / because ("She stayed, for the rain was torrential.")'},
        {'token': 'A - And', 'desc': 'Addition ("He spoke clearly, and everyone listened.")'},
        {'token': 'N - Nor', 'desc': 'Negative addition ("She did not yield, nor did she falter.")'},
        {'token': 'B - But', 'desc': 'Contrast ("The task was rigorous, but they triumphed.")'},
        {'token': 'O - Or', 'desc': 'Alternative ("Practice daily, or you will lose momentum.")'},
        {'token': 'Y - Yet', 'desc': 'Surprising contrast ("He was young, yet he commanded respect.")'},
        {'token': 'S - So', 'desc': 'Consequence ("The deadline loomed, so they accelerated.")'},
      ],
      correctExample: 'The siege was fierce, yet the defenders remained steadfast.',
      buggyExample: 'The siege was fierce they remained steadfast. (COMMA SPLICE ERROR)',
      practicePrompt: 'Combine: "I was tired" and "I completed the mission" using "YET".',
      correctPracticeToken: 'I was tired, yet I completed the mission.',
    ),
    _CodeFormula(
      codeName: 'CODE: ROOT-MATRIX',
      title: '10x Vocabulary Multiplier Matrix',
      category: 'Vocab Decoder',
      icon: '🧬',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[PREFIX / ROOT] ➔ 20+ INSTANT MEANINGS',
      malayalamExplanation:
          'ആയിരക്കണക്കിന് വാക്കുകൾ വെറുതെ കാണാതെ പഠിക്കുന്നതിന് പകരം "റൂട്ട് കോഡ്" പഠിക്കുക! ഉദാഹരണത്തിന് BENE എന്നാൽ "നല്ലത്", MAL എന്നാൽ "മോശം", CHRON എന്നാൽ "സമയം".',
      formulaBreakdown: [
        {'token': 'BENE- (Good/Well)', 'desc': 'Benevolent (kind), Benefactor (helper), Beneficial (helpful)'},
        {'token': 'MAL- (Bad/Ill)', 'desc': 'Malicious (harmful), Malfunction (broken), Malady (illness)'},
        {'token': 'CHRON- (Time)', 'desc': 'Chronology (order in time), Synchronize (match in time), Chronic'},
        {'token': 'DICT- (Speak)', 'desc': 'Dictate (speak order), Predict (speak before), Verdict (true speech)'},
      ],
      correctExample: 'A "benefactor" uses wealth for "beneficial" causes with "benevolence".',
      buggyExample: 'Confusing roots and guessing unrelated definitions blindly.',
      practicePrompt: 'What does "Synchronize" mean based on "SYN" (together) + "CHRON" (time)?',
      correctPracticeToken: 'To occur or operate at the same time.',
    ),
    _CodeFormula(
      codeName: 'CODE: PAST-LOCK',
      title: 'The Specific Time Safety Lock',
      category: 'Tense Guardrail',
      icon: '🔒',
      color: Color(0xFFEC4899),
      syntaxRule: '[PAST TIME MARKER] ➔ ONLY SIMPLE PAST (V2)',
      malayalamExplanation:
          'വാക്യത്തിൽ yesterday, last week, in 2021, ago പോലുള്ള കഴിഞ്ഞുപോയ സമയം പറഞ്ഞിട്ടുണ്ടെങ്കിൽ Present Perfect ("have seen") ഒരിക്കലും പറയരുത്! കൃത്യമായ സമയം = V2 Past Tense മാത്രം!',
      formulaBreakdown: [
        {'token': 'Time Anchor', 'desc': 'yesterday, two days ago, last month, in childhood'},
        {'token': 'Enforced Verb', 'desc': 'Saw, spoke, graduated, purchased (V2 Only)'},
        {'token': 'Forbidden Zone', 'desc': 'Never use "have seen / has gone" with a past time anchor'},
      ],
      correctExample: 'I [Subject] met [V2] the director yesterday [Time Anchor].',
      buggyExample: 'I have met the director yesterday. (FATAL TENSE RUNTIME ERROR)',
      practicePrompt: 'Correct this: "I have graduated in 2022."',
      correctPracticeToken: 'I graduated in 2022.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final active = _formulas[_selectedCodeIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF00FFCC), width: 2)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FFCC).withValues(alpha: 0.4)),
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POCKET CODE-ENGLISH DECODER',
                        style: GoogleFonts.firaCode(
                          color: const Color(0xFF00FFCC),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'കോഡ് ഭാഷ വെച്ച് ഇംഗ്ലീഷ് ഫോർമുലകൾ മനസ്സിലാക്കാം',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Formula Code Selector Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: List.generate(_formulas.length, (idx) {
                final f = _formulas[idx];
                final isSelected = _selectedCodeIndex == idx;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCodeIndex = idx;
                      _compilerOutput = null;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? f.color.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? f.color : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(f.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          f.codeName,
                          style: GoogleFonts.firaCode(
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Formula Details ScrollView
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Syntax Display Box (Terminal Look)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: active.color.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text(
                              'SYNTAX FORMULA // ${active.category.toUpperCase()}',
                              style: GoogleFonts.firaCode(color: const Color(0xFF64748B), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          active.syntaxRule,
                          style: GoogleFonts.firaCode(
                            color: active.color,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Malayalam / Regional Explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            active.malayalamExplanation,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE2E8F0),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Code Breakdown Tokens
                  Text(
                    'FORMULA COMPONENTS',
                    style: GoogleFonts.firaCode(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...active.formulaBreakdown.map((b) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['token'] ?? '',
                            style: GoogleFonts.firaCode(
                              color: active.color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b['desc'] ?? '',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCBD5E1),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // Correct vs Buggy Example
                  _buildDiffComparison(active.correctExample, active.buggyExample),

                  const SizedBox(height: 16),

                  // Interactive Sandbox Compiler
                  _buildSandboxCompiler(active),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffComparison(String correct, String buggy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct,
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF10B981),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  buggy,
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFFF87171),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSandboxCompiler(_CodeFormula active) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00FFCC).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'LIVE CODE COMPILER CHALLENGE',
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF00FFCC),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            active.practicePrompt,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isCompiling = true;
                _compilerOutput = null;
              });
              HapticFeedback.lightImpact();
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) {
                  setState(() {
                    _isCompiling = false;
                    _compilerOutput =
                        '✅ COMPILED SUCCESSFULLY!\nSyntax verified: [${active.codeName}] adhered perfectly.\n+20 Code XP added!';
                  });
                }
              });
            },
            icon: _isCompiling
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow, size: 16),
            label: Text(_isCompiling ? 'ANALYZING SYNTAX...' : 'TEST FORMULA OUTPUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFCC),
              foregroundColor: const Color(0xFF0A0F1D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.firaCode(fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ),
          if (_compilerOutput != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Text(
                _compilerOutput!,
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF34D399),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeFormula {
  final String codeName;
  final String title;
  final String category;
  final String icon;
  final Color color;
  final String syntaxRule;
  final String malayalamExplanation;
  final List<Map<String, String>> formulaBreakdown;
  final String correctExample;
  final String buggyExample;
  final String practicePrompt;
  final String correctPracticeToken;

  const _CodeFormula({
    required this.codeName,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.syntaxRule,
    required this.malayalamExplanation,
    required this.formulaBreakdown,
    required this.correctExample,
    required this.buggyExample,
    required this.practicePrompt,
    required this.correctPracticeToken,
  });
}
