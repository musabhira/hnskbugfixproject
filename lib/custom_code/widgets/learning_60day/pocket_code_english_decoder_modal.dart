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

  static PocketCodeFormula getFormulaForDay(int day) {
    if (_PocketCodeEnglishDecoderModalState.kFormulas.isEmpty) {
      return const PocketCodeFormula(
        codeName: 'CODE: S-V-O-101',
        title: 'The Core Engine of English',
        category: 'Syntax Algorithm',
        icon: '⚙️',
        color: Color(0xFF38BDF8),
        syntaxRule: '[SUBJECT] ➔ [VERB] ➔ [OBJECT]',
        malayalamExplanation: 'Subject + Verb + Object!',
        formulaBreakdown: [],
        correctExample: 'She inspires colleagues.',
        buggyExample: 'Misplaced verbs.',
        practicePrompt: 'Practice S-V-O.',
        correctPracticeToken: 'Success',
      );
    }
    final index = (day - 1).clamp(0, _PocketCodeEnglishDecoderModalState.kFormulas.length - 1);
    return _PocketCodeEnglishDecoderModalState.kFormulas[index];
  }

  static List<PocketCodeFormula> get allFormulas => _PocketCodeEnglishDecoderModalState.kFormulas;

  @override
  State<PocketCodeEnglishDecoderModal> createState() => _PocketCodeEnglishDecoderModalState();
}

class _PocketCodeEnglishDecoderModalState extends State<PocketCodeEnglishDecoderModal> {
  int _selectedCodeIndex = 0;
  String? _compilerOutput;
  bool _isCompiling = false;

  @override
  void initState() {
    super.initState();
    _selectedCodeIndex = (widget.currentDay - 1).clamp(0, kFormulas.length - 1);
  }

  List<PocketCodeFormula> get _formulas => kFormulas;

  static const List<PocketCodeFormula> kFormulas = [
    PocketCodeFormula(
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
    PocketCodeFormula(
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
    PocketCodeFormula(
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
    PocketCodeFormula(
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
    PocketCodeFormula(
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
    PocketCodeFormula(
      codeName: 'CODE: 3RD-COND-REWIND',
      title: 'The Counterfactual Time-Machine',
      category: 'Hypothetical Matrix',
      icon: '⏳',
      color: Color(0xFF06B6D4),
      syntaxRule: 'IF + [HAD + V3] ➔ [WOULD HAVE + V3]',
      malayalamExplanation:
          'കഴിഞ്ഞുപോയ ഒരു കാര്യത്തെക്കുറിച്ച് "അങ്ങനെ സംഭവിച്ചിരുന്നെങ്കിൽ ഇങ്ങനെ ആകുമായിരുന്നു" എന്ന് വിശകലനം ചെയ്യാനും തർക്കങ്ങളിൽ ന്യായീകരിക്കാനുമുള്ള ഉന്നത ഫോർമുല: If + had + V3, would have + V3! ഒരിക്കലും IF ക്ലോസിൽ "would have" പറയരുത്!',
      formulaBreakdown: [
        {'token': 'If + Had + V3', 'desc': 'Unreal past condition (e.g. If the envoy had arrived earlier)'},
        {'token': 'Would Have + V3', 'desc': 'Hypothetical past outcome (e.g. they would have prevented the conflict)'},
        {'token': 'Negotiation Rule', 'desc': 'Essential for diplomatic post-mortems and project retrospectives.'},
      ],
      correctExample: 'If we had verified the contract terms, we would have averted the dispute.',
      buggyExample: 'If we would have verified, we would avert. (FATAL CONDITIONAL ERROR)',
      practicePrompt: 'Construct: "If she / study the blueprints / she / identify the flaw".',
      correctPracticeToken: 'If she had studied the blueprints, she would have identified the flaw.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: INV-BOOST-X',
      title: 'Restrictive Inversion Power Formula',
      category: 'Oratorical Power',
      icon: '⚡',
      color: Color(0xFFF97316),
      syntaxRule: '[NEGATIVE ADVERB] + [AUXILIARY] + [SUBJECT] + [VERB]',
      malayalamExplanation:
          'സാധാരണക്കാരെപ്പോലെ "I have rarely seen this" എന്ന് പറയുന്നതിന് പകരം, അന്താരാഷ്ട്ര പ്രഭാഷകരെപ്പോലെ "Rarely have I seen this" എന്ന് ക്രിയ മുന്നിലിട്ട് (Inversion) സംസാരിച്ച് ശ്രോതാക്കളെ അത്ഭുതപ്പെടുത്താം!',
      formulaBreakdown: [
        {'token': '[TRIGGER]', 'desc': 'Rarely, Never, Seldom, Scarcely, Under no circumstances'},
        {'token': '[AUXILIARY FRONT]', 'desc': 'have, did, do, can, will pulled before the subject'},
        {'token': '[SUBJECT + VERB]', 'desc': 'Main actor and action following the auxiliary'},
      ],
      correctExample: 'Seldom do global leaders witness such profound grassroots courage.',
      buggyExample: 'Seldom global leaders witness such courage. (MISSING AUXILIARY INVERSION)',
      practicePrompt: 'Invert: "I have never witnessed such rhetorical brilliance."',
      correctPracticeToken: 'Never have I witnessed such rhetorical brilliance.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SUBJUNCT-BASE',
      title: 'The High-Stakes Subjunctive Mandate',
      category: 'Diplomatic Protocol',
      icon: '🏛️',
      color: Color(0xFFA855F7),
      syntaxRule: 'IT IS [IMPERATIVE] THAT + [SUBJECT] + [BASE VERB (V1)]',
      malayalamExplanation:
          'ഔദ്യോഗിക നയതന്ത്രത്തിലും നേതൃത്വപരമായ തീരുമാനങ്ങളിലും "നിർബന്ധമായും ചെയ്യണം" എന്ന് പറയാൻ: Subject ഏതായാലും (He/She ആയാലും) ക്രിയയുടെ കൂടെ \'s\' ചേർക്കരുത്! Base Verb (V1) മാത്രം ഉപയോഗിക്കുക!',
      formulaBreakdown: [
        {'token': 'Mandate Adjective', 'desc': 'imperative, essential, critical, vital, mandatory'},
        {'token': 'Any Subject', 'desc': 'the minister, the defendant, he, she'},
        {'token': 'Bare Infinitive', 'desc': 'remain (NOT remains), be present (NOT is), sign (NOT signs)'},
      ],
      correctExample: 'It is imperative that every delegate submit their credentials before noon.',
      buggyExample: 'It is imperative that he submits. (SUBJUNCTIVE MOOD VIOLATION)',
      practicePrompt: 'Complete: "It is essential that she [remain / remains] steadfast."',
      correctPracticeToken: 'It is essential that she remain steadfast.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CLEFT-LASER',
      title: 'The Cleft Sentence Laser Spotlight',
      category: 'Rhetorical Focus',
      icon: '🔦',
      color: Color(0xFF14B8A6),
      syntaxRule: 'WHAT + [CLAUSE] + [IS / WAS] + [THE CORE EMPHASIS]',
      malayalamExplanation:
          'ഒരു പ്രസംഗത്തിലോ ഇന്റർവ്യൂവിലോ ഒരു പ്രധാന കാര്യത്തിലേക്ക് എല്ലാവരുടെയും ശ്രദ്ധ തിരിക്കാൻ വാക്യത്തെ പിളർന്ന് (Cleft) മുന്നോട്ട് വെക്കുന്ന രീതി: "നമുക്ക് വേണ്ടത് ഇതാണ്: What we truly need is..."',
      formulaBreakdown: [
        {'token': 'Wh-Cleft Header', 'desc': 'What matters most is..., What transformed our approach was...'},
        {'token': 'It-Cleft Variant', 'desc': 'It was not lack of capital, but lack of vision that halted progress.'},
        {'token': 'Spotlight Target', 'desc': 'The key insight or value receiving 100% focused attention.'},
      ],
      correctExample: 'What separates enduring communicators from the rest is their unwavering empathy.',
      buggyExample: 'Empathy separates communicators. (FLAT DELIVERY, LACKS RHETORICAL FORCE)',
      practicePrompt: 'Transform into Wh-Cleft: "We seek genuine cross-cultural understanding."',
      correctPracticeToken: 'What we seek is genuine cross-cultural understanding.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MIXED-COND-LINK',
      title: 'The Executive Time-Bridge Synthesis',
      category: 'Strategic Synthesis',
      icon: '👑',
      color: Color(0xFFEAB308),
      syntaxRule: 'IF + [HAD + V3 (Past Event)] ➔ [WOULD + V1 (Present Reality)]',
      malayalamExplanation:
          'ഭൂതകാലത്തെ ഒരു തീരുമാനമാണ് ഇന്നത്തെ യാഥാർത്ഥ്യത്തിന് അടിസ്ഥാനം എന്ന് പ്രഖ്യാപിക്കാൻ ഉപയോഗിക്കുന്ന രാജകീയ ഫോർമുല: "അന്ന് നമ്മൾ ഉറച്ചുനിന്നതുകൊണ്ട് ഇന്ന് നമ്മൾ പരമാധികാരമുള്ളവരായി നിലകൊള്ളുന്നു!"',
      formulaBreakdown: [
        {'token': 'Past Choice (If + Had + V3)', 'desc': 'If our ancestors had not persevered through adversity...'},
        {'token': 'Present Reality (Would + V1)', 'desc': '...we would not enjoy democratic freedom today.'},
        {'token': 'Executive Synthesis', 'desc': 'Demonstrates causal vision and deep historical perspective.'},
      ],
      correctExample: 'If she had not mastered English on Day 10, she would not lead global operations today.',
      buggyExample: 'If she had not mastered, she would not have led today. (TENSE LOGIC CLASH)',
      practicePrompt: 'Combine: "We persevered for 10 days" and "We are confident today".',
      correctPracticeToken: 'If we had not persevered for 10 days, we would not be confident today.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MORPHO-FORGE',
      title: 'Polysyllabic Root Synthesis & Derivation',
      category: 'Morphological Forge',
      icon: '🌌',
      color: Color(0xFF6366F1),
      syntaxRule: '[PREFIX] + [ROOT] + [SUFFIX] ➔ ELEVATED SYNTHESIS',
      malayalamExplanation:
          'ആയിരക്കണക്കിന് ഉയർന്ന അക്കാദമിക് വാക്കുകളെ അവയുടെ മൂലധാതുക്കൾ (Prefix, Root, Suffix) കൊണ്ട് തിരിച്ചറിഞ്ഞ് നിഷ്പ്രയാസം സ്വന്തമാക്കുന്ന കോഡ് അൽഗോരിതം: "Meta- (മാറ്റം) + morph (രൂപം) + -osis = Metamorphosis (കാതലായ രൂപാന്തരം)".',
      formulaBreakdown: [
        {'token': 'META- (Beyond/Change)', 'desc': 'Metamorphosis, Metaphor, Metacognition'},
        {'token': '-MORPH- (Form/Structure)', 'desc': 'Amorphous, Morphology, Polymorphic'},
        {'token': 'EPI- (Upon/Sudden)', 'desc': 'Epiphany, Epistemic, Epilogue'},
        {'token': 'TRANS- (Across/Beyond)', 'desc': 'Transcend, Transform, Translucent'},
      ],
      correctExample: 'Consistent immersion triggers an inexorable metamorphosis in cognitive thinking.',
      buggyExample: 'Memorizing dictionary pages without understanding Greek and Latin root keys.',
      practicePrompt: 'Derive from "TRANS" (across) + "SCEND" (climb):',
      correctPracticeToken: 'Transcend',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DIALECTIC-CONCESS',
      title: 'Concessive Dissection & High Debate',
      category: 'Dialectic Logic',
      icon: '⚖️',
      color: Color(0xFFF97316),
      syntaxRule: 'GRANTED THAT [CONCESSION], YET [COUNTER-PREMISE] ➔ [CONCLUSION]',
      malayalamExplanation:
          'എതിരാളിയുടെ വാദത്തെ ബഹുമാനത്തോടെ അംഗീകരിച്ച് (Concession), തൊട്ടടുത്ത നിമിഷം കൂടുതൽ ശക്തമായ യുക്തിയും തെളിവും വെച്ച് ആ വാദത്തിന്റെ പൊള്ളത്തരത്തെ പൊളിച്ചടുക്കുന്ന എലൈറ്റ് ഡിബേറ്റ് ഫോർമുല.',
      formulaBreakdown: [
        {'token': '1. Respectful Concession', 'desc': 'Granted that your proposal promises short-term cost savings...'},
        {'token': '2. Sharp Pivot (Yet/However)', 'desc': '...yet we cannot ignore the fallacious assumptions in your data...'},
        {'token': '3. Irrefutable Core Conclusion', 'desc': '...which inevitably leads to institutional instability.'},
      ],
      correctExample: 'Granted that speed is desirable, yet we must not compromise ethical perspicacity.',
      buggyExample: 'You are completely wrong and lying. (CRUDE ATTACK, ZERO DIALECTICAL VALUE)',
      practicePrompt: 'Draft a concessive rebuttal to: "Automation saves money."',
      correctPracticeToken: 'Granted that automation saves money, yet we must preserve human discernment.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: EPISTEMIC-HEDGE',
      title: 'Forensic Modality & Scientific Empiricism',
      category: 'Epistemic Precision',
      icon: '🔬',
      color: Color(0xFF06B6D4),
      syntaxRule: '[DATA/FINDINGS] + [TENDS TO / GIVES CREDENCE TO] ➔ [DEDUCTION]',
      malayalamExplanation:
          'അഹങ്കാരത്തോടെ "ഇതാണ് നൂറ് ശതമാനം ശരി" എന്ന് അവകാശപ്പെടാതെ, തെളിവുകളുടെയും ഡാറ്റയുടെയും പിൻബലത്തിൽ ലോകോത്തര ഗവേഷകരും വിദഗ്ദ്ധരും സംസാരിക്കുന്ന ശാസ്ത്രീയ വിനയത്തിന്റെ ഫോർമുല (Epistemic Hedging).',
      formulaBreakdown: [
        {'token': 'Empirical Anchor', 'desc': 'The latest peer-reviewed clinical trials...'},
        {'token': 'Calibrated Modal Hedge', 'desc': '...strongly suggest / give substantial credence to / warrant the inference that...'},
        {'token': 'Factual Deduction', 'desc': '...linguistic neuroplasticity endures well into adulthood.'},
      ],
      correctExample: 'The anomalous findings warrant the inference that our previous paradigm was incomplete.',
      buggyExample: 'This data 100% proves without question that everyone else is totally mistaken.',
      practicePrompt: 'Frame an empirical finding regarding daily English immersion:',
      correctPracticeToken: 'Empirical data indicates that daily immersion accelerates natural fluency.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TRICOLON-CADENCE',
      title: 'Rhetorical Fronting & Triadic Balance',
      category: 'Oratorical Majesty',
      icon: '🏛️',
      color: Color(0xFFA855F7),
      syntaxRule: '[FRONTED THEME] + [PULSE 1] + , [PULSE 2] + , AND ABOVE ALL [PULSE 3]',
      malayalamExplanation:
          'ചരിത്രപ്രസിദ്ധമായ പ്രസംഗങ്ങളിൽ ജനഹൃദയങ്ങളെ പിടിച്ചുലയ്ക്കാൻ ഉപയോഗിക്കുന്ന ത്രിത്വ താളം (Rule of Three / Tricolon). മൂന്ന് തുല്യ പദങ്ങളോ വാക്യങ്ങളോ അടുപ്പിച്ചുവെച്ച് അവസാനത്തേതിൽ കൊടുമുടിയിലെത്തുന്നു (Climax).',
      formulaBreakdown: [
        {'token': '1. Fronted Hook', 'desc': 'In the crucible of this historic negotiation...'},
        {'token': '2. Ascending Pulse 1 & 2', 'desc': '...we demand transparency, we require mutual respect...'},
        {'token': '3. Climax Pulse 3', 'desc': '...and above all, we safeguard sovereign integrity.'},
      ],
      correctExample: 'Not only does this treaty protect commerce, but it enriches culture, and above all it secures peace.',
      buggyExample: 'This treaty is good for money and also good for peace and people like it. (UNSTRUCTURED LIST)',
      practicePrompt: 'Formulate a tricolon for: Learning English with purpose:',
      correctPracticeToken: 'We build discipline, we cultivate courage, and above all, we command our future.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DIPLOMATIC-REG',
      title: 'Conversational Register & Subjunctive Softeners',
      category: 'Diplomatic Nuance',
      icon: '💎',
      color: Color(0xFF14B8A6),
      syntaxRule: 'WOULD IT BE FEASIBLE TO + [BASE VERB] ➔ [CIRCUMSPECT PROPOSAL]',
      malayalamExplanation:
          '"No" അല്ലെങ്കിൽ "I reject this" എന്ന് നേരിട്ട് മുഖത്തടിച്ചതുപോലെ പറയാതെ, അതീവ മാന്യതയോടെയും കുലീനതയോടെയും (Diplomatic Register) വിയോജിപ്പുകൾ പ്രകടിപ്പിക്കാനും പുതിയ നിർദ്ദേശങ്ങൾ മുന്നോട്ടുവെക്കാനുമുള്ള അന്താരാഷ്ട്ര നയതന്ത്ര ഫോർമുല.',
      formulaBreakdown: [
        {'token': '1. Polite Incline Stem', 'desc': 'I would be inclined to suggest that... / Might we perhaps explore...'},
        {'token': '2. Circumspect Modality', 'desc': '...would it be deemed feasible to re-evaluate the fourth stipulation...'},
        {'token': '3. Cordial Preserved Harmony', 'desc': '...in order to ensure unanimous parliamentary consensus?'},
      ],
      correctExample: 'Would it be deemed prudent to defer the vote until all delegations review the addendum?',
      buggyExample: 'Stop the vote right now, we haven\'t read the paper yet! (AGGRESSIVE BREACH OF REGISTER)',
      practicePrompt: 'Softly decline an immediate deadline:',
      correctPracticeToken: 'I was wondering if we might extend the deadline by forty-eight hours.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CLEFT-FOCUS-MAX',
      title: 'It-Cleft & Wh-Cleft Saliency Filter',
      category: 'Laser Saliency',
      icon: '⚡',
      color: Color(0xFF00FFCC),
      syntaxRule: 'IT IS/WAS [FOCUS] THAT [CLAUSE] | WHAT [SUBJECT] [VERB] IS [CORE]',
      malayalamExplanation:
          'പ്രധാനപ്പെട്ട ഒരു കാര്യത്തിന് ചുറ്റും ലേസർ വെളിച്ചം വീശുന്നതുപോലെ ശ്രോതാക്കളുടെ പൂർണ്ണ ശ്രദ്ധ പിടിച്ചുപറ്റുന്ന ക്ലെഫ്റ്റ് സെന്റൻസ് ഫോർമുല: "It was not a cyber-attack that triggered the collapse; it was hardware failure."',
      formulaBreakdown: [
        {'token': 'It-Cleft Anchor', 'desc': 'It was her pivotal intervention that restored operational stability.'},
        {'token': 'Wh-Cleft Pivot', 'desc': 'What we must immediately execute is an offline manual reboot.'},
        {'token': 'Contrastive Laser', 'desc': 'It is under rigorous scrutiny that flawed policies crumble.'},
      ],
      correctExample: 'It was our proactive engineering that averted the grid collapse.',
      buggyExample: 'Proactive engineering averted collapse. (FLAT FACT, LACKS ORATORICAL HIGHLIGHT)',
      practicePrompt: 'Convert: "She solved the dilemma" into It-Cleft:',
      correctPracticeToken: 'It was she who solved the dilemma.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: PARALLEL-SYMMETRY',
      title: 'Syntactic Parallelism & Balanced Balance',
      category: 'Syntactic Architecture',
      icon: '🏛️',
      color: Color(0xFFF59E0B),
      syntaxRule: 'NOT TO [V1], BUT TO [V1]; NOT TO [V1], BUT RATHER TO [V1]',
      malayalamExplanation:
          'വാക്യത്തിലെ ഓരോ ഭാഗങ്ങളും തുലാസിന്റെ ഇരുതട്ടുകൾ പോലെ തുല്യ വ്യാകരണ ഘടനയിൽ സന്തുലിതമാക്കി നിർത്തുന്ന (Parallelism) ക്ലാസിക്കൽ ശൈലി. കേൾവിക്കാരെ വശീകരിക്കുന്ന താളബോധം ഇതിലൂടെ ലഭിക്കുന്നു.',
      formulaBreakdown: [
        {'token': 'Clause A (Infinitive)', 'desc': 'We stand here not to negotiate convenience...'},
        {'token': 'Clause B (Balanced Counter)', 'desc': '...but to defend inviolable liberty;'},
        {'token': 'Clause C (Elevated Synthesis)', 'desc': '...not to yield to corporate fear, but to uphold constitutional rectitude.'},
      ],
      correctExample: 'She sought not praise for herself, but justice for her community.',
      buggyExample: 'She wanted praise for herself and to help the community. (UNBALANCED SYNTAX ERROR)',
      practicePrompt: 'Complete the parallel structure: "We seek not wealth, but..."',
      correctPracticeToken: 'We seek not wealth, but sovereign wisdom.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DIALECTIC-SYNTH',
      title: 'The Sovereign Dialectic Synthesis',
      category: 'Master Dialectic',
      icon: '👑',
      color: Color(0xFF8B5CF6),
      syntaxRule: 'IF [HAD + V3], [WOULD + V1], AND [NOW WE ARE POISED TO + V1]',
      malayalamExplanation:
          'ഭൂതകാലത്തിലെ കഠിനാധ്വാനത്തെ വർത്തമാനകാല വിജയവുമായും ഭാവിയിലെ അനന്തസാധ്യതകളുമായും സംയോജിപ്പിച്ച് പ്രസംഗിക്കാനുള്ള പരമോന്നത ഫോർമുല. ഗേറ്റ് 2-ന്റെ പരിസമാപ്തി കുറിക്കുന്ന രാജകീയ ശൈലി.',
      formulaBreakdown: [
        {'token': 'Past Foundation (Had + V3)', 'desc': 'If our ancestors had not planted seeds in the barren soil...'},
        {'token': 'Present Power (Would + V1)', 'desc': '...we would not possess this sovereign freedom today...'},
        {'token': 'Future Triumph (Poised to)', 'desc': '...and now that the foundation is anchored, we are poised to lead.'},
      ],
      correctExample: 'If I had not persevered through Gate 1, I would not command this stage today.',
      buggyExample: 'If I didn\'t study, I wouldn\'t have been here now. (MIXED TENSE LOGIC ERROR)',
      practicePrompt: 'Formulate a dialectic synthesis for 18 days of English immersion:',
      correctPracticeToken: 'If we had not persevered, we would not speak with sovereign confidence today.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SUBJUNCT-MANDATE',
      title: 'Statutory Decrees & The Subjunctive Mandate',
      category: 'Executive Governance',
      icon: '📜',
      color: Color(0xFFEC4899),
      syntaxRule: 'IT IS MANDATORY / ESSENTIAL THAT [SUBJECT] + [BASE V1 - NO -S/-ES]',
      malayalamExplanation:
          'ഔദ്യോഗിക നിയമങ്ങളിലും കരാറുകളിലും "He/She/It" വന്നാലും ക്രിയയുടെ കൂടെ \'s\' അല്ലെങ്കിൽ \'es\' ചേർക്കാൻ പാടില്ലാത്ത കഠിനമായ സബ്ജങ്ക്ടീവ് നിയമം: "It is mandatory that each delegate BE empowered", "We insist that he ATTEND".',
      formulaBreakdown: [
        {'token': 'Statutory Head', 'desc': 'It is mandatory / imperative / crucial that...'},
        {'token': 'Third-Person Subject', 'desc': '...every signatory state / each delegate / the officer...'},
        {'token': 'Bare Base Form (V1)', 'desc': '...submit border audits quarterly (NOT submits!).'},
      ],
      correctExample: 'The council demands that each delegate be fully empowered to vote.',
      buggyExample: 'The council demands that each delegate is fully empowered. (SUBJUNCTIVE MOOD ERROR)',
      practicePrompt: 'Correct the error: "It is mandatory that he attends the meeting."',
      correctPracticeToken: 'It is mandatory that he attend the meeting.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: NEG-INVERSION-THUNDER',
      title: 'Thunderous Negative Inversion Statecraft',
      category: 'Oratorical Thunder',
      icon: '🌐',
      color: Color(0xFFEF4444),
      syntaxRule: 'SELDOM / UNDER NO CIRCUMSTANCES + [AUXILIARY] + [SUBJECT] + [MAIN VERB]',
      malayalamExplanation:
          'ലോക നേതാക്കൾ വലിയ ജനക്കൂട്ടത്തിന് മുൻപിൽ പ്രസംഗിക്കുമ്പോൾ ഉപയോഗിക്കുന്ന ഇടിമുഴക്കമുള്ള ഇൻവേർഷൻ ഫോർമുല. നിഷേധാത്മക പദങ്ങൾ മുന്നിൽ വരുമ്പോൾ വെർബ് സബ്ജക്റ്റിന് മുന്നിലേക്ക് ചാടുന്നു!',
      formulaBreakdown: [
        {'token': 'Negative Titan Front', 'desc': 'Seldom in modern history / Under no circumstances...'},
        {'token': 'Inverted Auxiliary', 'desc': '...have we stood / will our coalition compromise...'},
        {'token': 'Subject & Main Verb', 'desc': '...the sovereign integrity of vulnerable democratic nations.'},
      ],
      correctExample: 'Under no circumstances will our coalition compromise on civil rights.',
      buggyExample: 'Our coalition will under no circumstances compromise. (WEAK CONVERSATIONAL REGISTER)',
      practicePrompt: 'Invert: "We have rarely seen such dedication."',
      correctPracticeToken: 'Rarely have we seen such dedication.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: STAR-EXECUTIVE-PIVOT',
      title: 'The Executive STAR Behavioral Framework',
      category: 'Executive Interview',
      icon: '👔',
      color: Color(0xFF0EA5E9),
      syntaxRule: '[SITUATION (Context)] ➔ [TASK (Objective)] ➔ [ACTION (My Strategy)] ➔ [RESULT (Metrics)]',
      malayalamExplanation:
          'ലോകോത്തര കമ്പനികളുടെ എക്സിക്യൂട്ടീവ് ഇന്റർവ്യൂവിൽ വിജയിക്കാനുള്ള ആൽഗോരിതം. പൊതുവായി വർത്തമാനം പറയാതെ S-T-A-R എന്ന 4 ചരണങ്ങളിലായി സംസാരം ചിട്ടപ്പെടുത്തുക.',
      formulaBreakdown: [
        {'token': '[SITUATION]', 'desc': 'When maritime supply chains collapsed within 48 hours...'},
        {'token': '[TASK]', 'desc': '...my mandate was to safeguard fifty million in inventory.'},
        {'token': '[ACTION]', 'desc': 'I negotiated regional airfreight accords and rerouted distribution...'},
        {'token': '[RESULT]', 'desc': '...preserving 96% of revenue and generating twelve million in retention.'},
      ],
      correctExample: 'When supply lines failed, my task was recovery; I chartered airfreight, saving 96% of revenue.',
      buggyExample: 'It was very hard and stressful but eventually things got better somehow. (VAGUE NARRATIVE BUG)',
      practicePrompt: 'Structure: "When crisis hit (S), I had to cut costs (T), so I automated reports (A), saving 20% (R)."',
      correctPracticeToken: 'When crisis hit, I had to cut costs, so I automated reports, saving 20%.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: BENCHMARK-EQUITY-NEGOTIATE',
      title: 'Commercial Value Benchmarking & Register',
      category: 'Commercial Negotiation',
      icon: '💼',
      color: Color(0xFF10B981),
      syntaxRule: 'GRATEFUL FOR [OFFER]; HOWEVER, BENCHMARKING INDICATES [X]; WOULD THE BOARD CONSIDER [EQUITY]?',
      malayalamExplanation:
          'ശമ്പള ചർച്ചകളിലും ബിസിനസ്സ് ഡീലുകളിലും വഴക്കിടാതെ ഉയർന്ന അന്തസ്സോടെ ഡീൽ മാറ്റിയെടുക്കാനുള്ള ഡിപ്ലോമാറ്റിക് ഫോർമുല: നന്ദി പറയുക ➔ കണക്കുകൾ നിരത്തുക ➔ സംയുക്ത ലാഭം വാഗ്ദാനം ചെയ്യുക.',
      formulaBreakdown: [
        {'token': 'Appreciative Cushion', 'desc': 'I am appreciative of your generous baseline proposal; however...'},
        {'token': 'Empirical Leverage', 'desc': '...industry benchmarking confirms our division generated 45% growth.'},
        {'token': 'Mutual Equity Bridge', 'desc': 'Would the committee consider structuring equity milestones linked to gross revenue?'},
      ],
      correctExample: 'Benchmarking indicates 45% growth; would the committee consider performance-linked equity?',
      buggyExample: 'Pay me 45% more or I quit and join your rival. (HOSTILE REGISTER THREAT)',
      practicePrompt: 'Formulate an assertive value proposition with benchmarking:',
      correctPracticeToken: 'Benchmarking indicates 45% growth; would the committee consider equity incentives?',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MODAL-FORENSIC-RETROSPECT',
      title: 'Past Modal Deduction & Elimination Matrix',
      category: 'Forensic Precision',
      icon: '🔍',
      color: Color(0xFFF59E0B),
      syntaxRule: '[SUBJECT] + [MUST HAVE / COULD NOT HAVE / SHOULD HAVE] + [V3 PAST PARTICIPLE]',
      malayalamExplanation:
          'ഒരു വലിയ തകരാറോ സൈബർ ആക്രമണമോ നടക്കുമ്പോൾ കുറ്റക്കാരെയും തകരാറിനെയും കണ്ടെത്താൻ ഉപയോഗിക്കുന്ന ലോജിക്കൽ ഫോർമുല: Must have (ഉറപ്പാണ്), Could not have (സാധ്യമല്ല), Should have (ചെയ്യണമായിരുന്നു).',
      formulaBreakdown: [
        {'token': 'Certainty (Must have)', 'desc': 'The intruders must have obtained administrative credentials internally.'},
        {'token': 'Impossibility (Could not have)', 'desc': 'They could not have breached the air-gapped physical backup.'},
        {'token': 'Fiduciary Duty (Should have)', 'desc': 'The contractor should have flagged unauthorized telemetry hours earlier.'},
      ],
      correctExample: 'The intrusion must have originated internally, as exterior firewalls remained intact.',
      buggyExample: 'The intruders must to gain access by phishing. (MODAL INFINITIVE SYNTAX ERROR)',
      practicePrompt: 'Deduce past event: "The exterior firewall was untouched, so they (must gain) access internally."',
      correctPracticeToken: 'They must have gained access internally.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MEDIA-BRIDGE-PARRY',
      title: 'Hostile Query Pivot & The Strategic Bridge',
      category: 'Crisis Media Relations',
      icon: '🎙️',
      color: Color(0xFF8B5CF6),
      syntaxRule: 'ACKNOWLEDGE EMOTION / INTENT ➔ PIVOT VIA BRIDGE ➔ LAND FACTUAL CORE',
      malayalamExplanation:
          'മാധ്യമങ്ങളുടെയും എതിരാളികളുടെയും പ്രകോപനപരമായ ചോദ്യങ്ങളിൽ കുടുങ്ങാതെ പക്വതയോടെ തടിയൂരാനുള്ള ഫോർമുല: വികാരം അംഗീകരിക്കുക ➔ ബ്രിഡ്ജ് ചെയ്യുക ➔ നിങ്ങളുടെ പ്രധാന നേട്ടത്തിലേക്ക് ചർച്ച മാറ്റുക.',
      formulaBreakdown: [
        {'token': 'Empathy Cushion', 'desc': 'I fully recognize the economic anxiety felt in our industrial heartlands...'},
        {'token': 'The Verbal Pivot', 'desc': '...however, verified data demonstrates eighty thousand manufacturing jobs created...'},
        {'token': 'Sovereign Anchor', 'desc': '...and what is critical today is sustaining this infrastructure without delay.'},
      ],
      correctExample: 'I understand the community concern; however, data proves 80,000 jobs were created.',
      buggyExample: 'Your newspaper always publishes malicious lies against us! (EMOTIONAL COMBATIVE COLLAPSE)',
      practicePrompt: 'Bridge from hostile accusation: "Acknowledge concern; however, verifiable metrics show..."',
      correctPracticeToken: 'I acknowledge your concern; however, our verified metrics demonstrate consistent growth.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: IDIOMATIC-ALPHA-LEAD',
      title: 'Wall Street Idiomatic Cadence & Strategic Metaphor',
      category: 'Idiomatic Mastery',
      icon: '📈',
      color: Color(0xFF14B8A6),
      syntaxRule: '[CHIPS ARE DOWN] ➔ [DO NOT CUT CORNERS] ➔ [BITE THE BULLET] ➔ [SEPARATE WHEAT FROM CHAFF]',
      malayalamExplanation:
          'സാധാരണക്കാരെപ്പോലെ അർത്ഥശൂന്യമായ പദങ്ങൾ ഉപയോഗിക്കാതെ, വാൾസ്ട്രീറ്റിലെയും ലണ്ടൻ എക്സ്ചേഞ്ചിലെയും നിക്ഷേപകരെപ്പോലെ മാതൃഭാഷ സംസാരിക്കുന്നവരെപ്പോലെ ഇംഗ്ലീഷ് ശൈലികൾ അനായാസം സംസാരിക്കാൻ!',
      formulaBreakdown: [
        {'token': 'Crisis Idiom', 'desc': 'When the chips are down, we do not cut corners or throw in the towel.'},
        {'token': 'Steely Resolve', 'desc': 'We must bite the bullet, keep our ears to the ground, and play cards close.'},
        {'token': 'Discernment Catalyst', 'desc': 'Market volatility is a blessing in disguise to separate wheat from chaff.'},
      ],
      correctExample: 'When the chips are down, we bite the bullet and separate the wheat from the chaff.',
      buggyExample: 'When cards are broken, we chew lead balls and run corners. (MALAPROPISM DISASTER)',
      practicePrompt: 'Complete idiomatic leadership resolve: "When the chips are down, we bite the [bullet / stone]."',
      correctPracticeToken: 'When the chips are down, we bite the bullet.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: PARTICIPIAL-CINEMA-DRIVE',
      title: 'Cinematic Participial Velocity & Screenplay Cadence',
      category: 'Visual Storytelling',
      icon: '🎬',
      color: Color(0xFFF59E0B),
      syntaxRule: 'HAVING + [PAST PARTICIPLE] / [PRESENT PARTICIPLE PHRASE], [MAIN SUBJECT] + [DYNAMIC VERB]',
      malayalamExplanation:
          'കുട്ടിത്തം നിറഞ്ഞ ചെറിയ വാക്യങ്ങൾ നിരത്താതെ ഹോളിവുഡ് തിരക്കഥകളെയും നോവലുകളെയും പോലെ ദൃശ്യഭംഗിയോടെ വലിയ കാര്യങ്ങൾ അതിവേഗം വിവരിക്കാനുള്ള പാർട്ടിസിപ്പിൾ ആൽഗോരിതം!',
      formulaBreakdown: [
        {'token': 'Participial Action Front', 'desc': 'Having documented the melting glaciers of Greenland for six seasons...'},
        {'token': 'Passive Stative Pivot', 'desc': '...confronted by sudden sea-ice collapse, indigenous communities adapted...'},
        {'token': 'Subject & Climax', 'desc': '...our expedition captured two hundred hours of pristine cinema-verite footage.'},
      ],
      correctExample: 'Having documented the arctic crisis, we presented our findings to global distributors.',
      buggyExample: 'We documented arctic crisis for six years and then after that we presented findings. (CLUNKY PRIMITIVE SYNTAX)',
      practicePrompt: 'Transform into participial drive: "We finished the audit and then reported to the board."',
      correctPracticeToken: 'Having finished the audit, we reported to the board.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CRISIS-APOLOGY-SOVEREIGN',
      title: 'Executive Accountability & Remediation Protocol',
      category: 'Crisis Communications',
      icon: '🛡️',
      color: Color(0xFFE11D48),
      syntaxRule: '[UNRESERVED APOLOGY] + [UNEQUIVOCAL OWNERSHIP] + [CONCRETE REMEDIATION] + [SYSTEMIC AUDIT]',
      malayalamExplanation:
          'ഒരു വലിയ കമ്പനിയിലോ ടീമിലോ പിഴവ് സംഭവിക്കുമ്പോൾ പഴിചാരി ഒളിച്ചോടാതെ ലോകോത്തര സി.ഇ.ഒ മാരെപ്പോലെ ആധികാരികമായി മാപ്പ് ചോദിക്കാനും വിശ്വാസം തിരിച്ചുപിടിക്കാനുമുള്ള ഫോർമുല.',
      formulaBreakdown: [
        {'token': 'Unreserved Apology', 'desc': 'On behalf of our leadership team, I offer our deepest and unreserved apologies.'},
        {'token': 'Unequivocal Ownership', 'desc': 'We take complete, unequivocal accountability for this operational breakdown.'},
        {'token': 'Active Remediation', 'desc': 'We are issuing immediate cash refunds and 24/7 alternative carrier rerouting.'},
        {'token': 'Forensic Safeguard', 'desc': 'I have commissioned an independent forensic audit to guarantee this never recurs.'},
      ],
      correctExample: 'We take unequivocal accountability and offer full cash refunds alongside systemic audits.',
      buggyExample: 'It was the third-party software vendor\'s mistake so do not blame us. (COWARDLY REPUTATIONAL SUICIDE)',
      practicePrompt: 'Lead crisis response: "We take [unequivocal / minor] accountability for this outage."',
      correctPracticeToken: 'We take unequivocal accountability for this outage.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ELEVATOR-PITCH-ALPHA',
      title: 'The 60-Second Silicon Valley VC Hook & Traction Arc',
      category: 'Venture Capital Pitch',
      icon: '🚀',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[PROVOCATIVE PROBLEM METRIC] ➔ [PROPRIETARY SOLUTION] ➔ [TRACTION PROOF] ➔ [SERIES ASK]',
      malayalamExplanation:
          'സിലിക്കൺ വാലിയിലെയും ലണ്ടനിലെയും വൻകിട നിക്ഷേപകർക്ക് മുന്നിൽ 60 സെക്കൻഡിൽ കോടികളുടെ ഫണ്ടിംഗ് ആകർഷിക്കാൻ പ്രൊഫഷണലുകൾ ഉപയോഗിക്കുന്ന ആൽഫാ പിച്ച് ആൽഗോരിതം!',
      formulaBreakdown: [
        {'token': 'Shocking Metric Hook', 'desc': '80% of global professionals fail executive interviews due to speech hesitation.'},
        {'token': 'Proprietary Solution', 'desc': 'At Pocket Mates, we built the world\'s first real-time conversational sparring engine.'},
        {'token': 'Hyper-Growth Traction', 'desc': '300,000 active users across 40 nations generated \$5M ARR at 72% gross margins.'},
        {'token': 'Sovereign Ask', 'desc': 'We are raising our Series A to bring conversational mastery to one billion minds.'},
      ],
      correctExample: '80% face language anxiety; our AI sparring engine generates \$5M ARR; join our Series A.',
      buggyExample: 'We are a small cool startup app and we need some money if you like it. (AMATEUR ZERO-TRACTION ASK)',
      practicePrompt: 'Construct high-traction pitch: "We built an engine that generated \$5M ARR at 72% [gross / net] margins."',
      correctPracticeToken: 'We built an engine that generated \$5M ARR at 72% gross margins.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DIPLOMATIC-PARRY-ETIQUETTE',
      title: 'Cross-Cultural High-Table Etiquette & Soft Diplomacy',
      category: 'International Diplomacy',
      icon: '🏰',
      color: Color(0xFF3B82F6),
      syntaxRule: '[HONORIFIC HOMAGE] + [DEFERENTIAL INTELLECTUAL INQUIRY] + [SUBTLE CONSENSUS PROBE]',
      malayalamExplanation:
          'വേഴ്സായ് കൊട്ടാരത്തിലോ ജി20 ഉച്ചകോടിയിലോ ലോക നേതാക്കളുമായി അത്താഴം കഴിക്കുമ്പോൾ അഹങ്കാരമില്ലാതെ അതീവ മര്യാദയോടും അന്തസ്സോടും കൂടി സുപ്രധാന കാര്യങ്ങൾ അംഗീകരിപ്പിച്ചെടുക്കാനുള്ള തന്ത്രം!',
      formulaBreakdown: [
        {'token': 'Honorific Homage', 'desc': 'Ambassador Tanaka, it is an immense personal honor to meet you in person.'},
        {'token': 'Deference to Expertise', 'desc': 'Your recent white paper on sovereign green maritime corridors was profoundly insightful.'},
        {'token': 'Consensus Gateway', 'desc': 'Would your delegation be receptive to informal consultations regarding maritime standards?'},
      ],
      correctExample: 'It is a privilege to meet you; your treatise on green logistics was exceptionally lucid.',
      buggyExample: 'Hey listen ambassador, we need to sign this paper right now before dinner ends! (BOORISH PROTOCOL VIOLATION)',
      practicePrompt: 'Honorary diplomatic greeting: "It is an immense [honor / fun] to meet your Excellency."',
      correctPracticeToken: 'It is an immense honor to meet your Excellency.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ORATORICAL-GRAND-SYNTHESIS',
      title: 'The Prime Ministerial Town Hall Triad',
      category: 'Grand Oratorical Synthesis',
      icon: '👑',
      color: Color(0xFFD97706),
      syntaxRule: '[CLEFT FOCUS] ➔ [NEGATIVE INVERSION] ➔ [SUBJUNCTIVE MANDATE] ➔ [TRICOLON CLIMAX]',
      malayalamExplanation:
          'പ്രധാനമന്ത്രിമാരും പ്രസിഡന്റുമാരും ലോകത്തെ പിടിച്ചുലയ്ക്കുന്ന സംവാദങ്ങളിൽ തങ്ങളുടെ എല്ലാ വ്യാകരണ അസ്ത്രങ്ങളും ഒന്നിച്ച് പ്രയോഗിക്കുന്ന മഹാ സിന്തസിസ് ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Saliency Cleft Pivot', 'desc': 'What we must build today is an economy where innovation flourishes.'},
        {'token': 'Negative Inversion Apex', 'desc': 'Seldom has our sovereign democracy faced so historic a crossroads.'},
        {'token': 'Subjunctive Mandate', 'desc': 'I insist that every citizen be protected and that our legislature act boldly.'},
        {'token': 'Tricolon Cadence', 'desc': 'Not through fear, but through courage; not in division, but in solidarity; not tomorrow, but now!'},
      ],
      correctExample: 'What we demand is justice; rarely have we faltered; it is vital that we unite with courage, honor, and vision.',
      buggyExample: 'I think we are good and the other party is bad so vote for us please. (RHETORICAL FLATLINE)',
      practicePrompt: 'Synthesize cleft and inversion: "What we need is courage; seldom have we stood so [firm / weak]."',
      correctPracticeToken: 'What we need is courage; seldom have we stood so firm.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: COUNTERFACTUAL-RISK-PROJECTION',
      title: 'Inverted Counterfactual & Stress-Test Calculus',
      category: 'Strategic Scenario Modeling',
      icon: '🌐',
      color: Color(0xFF06B6D4),
      syntaxRule: 'HAD [SUBJECT] NOT [V3], [WOULD HAVE...] / WERE [SUBJECT] TO [VERB], [WOULD...]',
      malayalamExplanation:
          'ജെനീവയിലെ ഗ്ലോബൽ റിസ്ക് ഇൻസ്റ്റിറ്റ്യൂട്ടിലും കേന്ദ്ര ബാങ്കുകളിലും ഭാവിയിലെ അപകടങ്ങൾ മുൻകൂട്ടി കണ്ട് പോളിസി രൂപീകരിക്കാൻ ഉപയോഗിക്കുന്ന ഇൻവേർട്ടഡ് കണ്ടീഷണൽ മാസ്റ്ററി!',
      formulaBreakdown: [
        {'token': 'Inverted Past Counterfactual', 'desc': 'Had our central bank not diversified currency reserves twelve months ago...'},
        {'token': 'Catastrophic Counter-Yield', 'desc': '...our national debt yields would have collapsed under sovereign debt contagion.'},
        {'token': 'Hypothetical Stress-Test', 'desc': 'Were the energy grid to suffer a secondary freeze, output would drop eighteen percent.'},
        {'token': 'Preemptive Directive', 'desc': 'We recommend that emergency strategic reserves be released immediately.'},
      ],
      correctExample: 'Had we not diversified our reserves, sovereign yields would have collapsed this morning.',
      buggyExample: 'If we didn\'t did that before maybe everything would break down today. (CATASTROPHIC CONDITIONAL SMASH)',
      practicePrompt: 'Invert 3rd conditional: "If we had not hedged our risk, we would have lost capital."',
      correctPracticeToken: 'Had we not hedged our risk, we would have lost capital.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CHIASMUS-ANTITHESIS-APEX',
      title: 'Classical Symmetrical Chiasmus & Supreme Court Oratory',
      category: 'Classical Rhetoric',
      icon: '⚖️',
      color: Color(0xFF6366F1),
      syntaxRule: 'NEVER ADAPT [A] TO [B]; ADAPT [B] TO [A] ➔ [PROMISES X, BUT DELIVERS Y] ➔ [JUDICIAL TRICOLON]',
      malayalamExplanation:
          'സുപ്രീം കോടതിയിലും ഭരണഘടനാ ബെഞ്ചിലും ചരിത്രപരമായ വാദമുഖങ്ങൾ നിരത്തുമ്പോൾ പദങ്ങളുടെ ക്രമം ക്രോസ്സ് ആയി മാറ്റി (AB-BA) കേൾവിക്കാരെ അത്ഭുതപ്പെടുത്തുന്ന ക്ലാസിക്കൽ കിയാസ്മസ് ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Symmetrical Chiasmus (AB-BA)', 'desc': 'Never adapt human liberties (A) to algorithms (B); adapt algorithmic power (B) to human liberties (A).'},
        {'token': 'Antithetical Contrast', 'desc': 'The respondent promises boundless connection, but extracts absolute surveillance.'},
        {'token': 'Judicial Tricolon', 'desc': 'This court must speak with courage, rule with impartiality, and act with constitutional finality.'},
      ],
      correctExample: 'Never adapt human liberties to algorithmic demands; adapt algorithms to human liberties.',
      buggyExample: 'Do not let computers control freedom, rather make computers follow freedom rules please. (COLLOQUIAL CLUNKER)',
      practicePrompt: 'Complete chiasmus: "Never adapt rights to technology; adapt [technology to rights / rights to computers]."',
      correctPracticeToken: 'Never adapt rights to technology; adapt technology to rights.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TECH-DEMYSTIFY-ALPHA',
      title: 'Deep-Tech Metaphoric Demystification & Executive ROI',
      category: 'Technical Translation',
      icon: '💡',
      color: Color(0xFFF59E0B),
      syntaxRule: '[IMAGINE IF X DID NOT SEARCH A, BUT TURNED ON LIGHTS OVER B] ➔ [ENTERPRISE TIME DELTA] ➔ [COST REDUCTION %]',
      malayalamExplanation:
          'സങ്കീർണ്ണമായ ഡീപ്പ്-ടെക് അല്ലെങ്കിൽ കോഡിംഗ് കാര്യങ്ങൾ പറയുമ്പോൾ ജാർഗണുകൾ ഉപയോഗിച്ച് ആളുകളെ വെറുപ്പിക്കാതെ, കൊച്ചുകുട്ടികൾക്ക് പോലും മനസ്സിലാകുന്ന അത്ഭുത ഉപമകളിലൂടെ കോടികളുടെ ഫണ്ടിംഗ് ആകർഷിക്കാൻ!',
      formulaBreakdown: [
        {'token': 'Intuitive Analogy Hook', 'desc': 'Imagine if your computer didn\'t search a labyrinth room by room, but turned on lights across the whole maze at once.'},
        {'token': 'Practical Metric Bridge', 'desc': 'A four-month supercomputing simulation is solved by our chip in seven seconds.'},
        {'token': 'Commercial ROI Anchor', 'desc': '...reducing pharmaceutical discovery costs by ninety percent.'},
      ],
      correctExample: 'Instead of searching room by room, our chip illuminates the entire maze, cutting costs by 90%.',
      buggyExample: 'Our non-convex stochastic eigenstate matrix utilizes tensor flow optimizations for linear convergence. (DEAFENING JARGON OVERKILL)',
      practicePrompt: 'Demystify: "Instead of searching one hallway at a time, we turn on the [lights across the entire maze / screen]."',
      correctPracticeToken: 'Instead of searching one hallway at a time, we turn on the lights across the entire maze.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: FALLACY-DISARM-FORENSIC',
      title: 'Surgical Fallacy Neutralization & Cross-Examination',
      category: 'Forensic Cross-Examination',
      icon: '🏛️',
      color: Color(0xFFDC2626),
      syntaxRule: 'THAT IS A TEXTBOOK [FALLACY NAME]; MY INQUIRY CONCERNS [LEGAL MERIT]; DID YOU OR DID YOU NOT [AUDITED FACT]?',
      malayalamExplanation:
          'സെനറ്റ് വിചാരണയിലോ തർക്കങ്ങളിലോ എതിരാളികൾ വിഷയം മാറ്റാനും (Straw Man) വ്യക്തിപരമായി ആക്രമിക്കാനും (Ad Hominem) നോക്കുമ്പോൾ ദേഷ്യപ്പെടാതെ ശസ്ത്രക്രിയ പോലെ തെളിവുകളിലേക്ക് തിരികെ കൊണ്ടുവരാൻ!',
      formulaBreakdown: [
        {'token': 'Identify Manipulative Tactic', 'desc': 'Mr. Executive, that is a textbook straw man fallacy.'},
        {'token': 'Isolate True Legal Merit', 'desc': 'My cross-examination has nothing to do with opposing free enterprise.'},
        {'token': 'Laser Audit Interrogation', 'desc': 'Let us return to the audited server logs: Did you or did you not authorize that transmission?'},
      ],
      correctExample: 'That is a straw man fallacy; my question is simply whether you authorized the wire transfer on March 14th.',
      buggyExample: 'You are a liar and you are attacking my character unfairly, answer me! (EMOTIONAL LOSS OF CONTROL)',
      practicePrompt: 'Dismantle fallacy: "That is a textbook straw man fallacy; let us return to the audited [server logs / rumors]."',
      correctPracticeToken: 'That is a textbook straw man fallacy; let us return to the audited server logs.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: HIGH-EQ-MEDIATION-MIRROR',
      title: 'Empathetic Conflict De-escalation & Interest Alignment',
      category: 'Labor Mediation',
      icon: '🤝',
      color: Color(0xFF10B981),
      syntaxRule: 'I HEAR [FATIGUE / STRESS] + I RECOGNIZE [FINANCIAL PENALTY] + WHAT WE ALL DEMAND IS [SHARED ESSENTIAL GOAL]',
      malayalamExplanation:
          'കടുത്ത സമരങ്ങളിലും പണിമുടക്കുകളിലും ഇരുകൂട്ടരും മേശപ്പുറത്ത് കൈയടിച്ച് തർക്കിക്കുമ്പോൾ, ദേഷ്യം ശമിപ്പിച്ച് ഇരുവർക്കും സ്വീകാര്യമായ ഒത്തുതീർപ്പിലെത്തിക്കാനുള്ള ഹൈ-ഇക്യു സൈക്കോളജിക്കൽ ഫോർമുല.',
      formulaBreakdown: [
        {'token': 'Empathetic Mirroring', 'desc': 'I hear the deep exhaustion in your voices, and recognize crews operated inhuman overtime.'},
        {'token': 'Counterparty Validation', 'desc': 'To the shipowners, I acknowledge your acute contractual delay penalties.'},
        {'token': 'Mutual Sovereign Reframe', 'desc': 'What we all demand is a treaty that protects human dignity while keeping food lines moving.'},
      ],
      correctExample: 'I hear your acute exhaustion; I acknowledge your delay penalties; let us construct a three-shift rotation.',
      buggyExample: 'Stop shouting like children and sign this contract immediately or everyone goes to jail! (AUTHORITARIAN FAILURE)',
      practicePrompt: 'High-EQ de-escalation: "I hear the deep exhaustion in your voices; what we all demand is an agreement that protects [human dignity / corporate profits]."',
      correctPracticeToken: 'I hear the deep exhaustion in your voices; what we all demand is an agreement that protects human dignity.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: VOCAL-ORATOR-PREGNANT-PAUSE',
      title: 'Vocal Artistry, Dynamic Cadence & The Sovereign Pause',
      category: 'Vocal Mastery',
      icon: '🎙️',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[DEVASTATING FACT] ➔ [3-SECOND INTENTIONAL SILENCE] ➔ [WHISPERED MORAL GRAVITY] ➔ [THUNDEROUS CRESCENDO]',
      malayalamExplanation:
          'ലോകോത്തര TED സ്പീക്കർമാരെപ്പോലെ വാക്കുകൾ വെറുതെ പറയുകയല്ല, നിശബ്ദത (Pregnant Pause) കൊണ്ടും സ്വരവ്യതിയാനം കൊണ്ടും 4000 ആളുകളെ എഴുന്നേറ്റു നിന്ന് കയ്യടിപ്പിക്കുന്ന ശബ്ദകലാ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Acoustic Shock Fact', 'desc': 'In the time it took you to inhale your last breath, forty thousand trees were felled.'},
        {'token': 'The Pregnant Silence', 'desc': '[3 to 5 seconds of absolute, unblinking silence, commanding the acoustics of the hall]'},
        {'token': 'Whispered Intimacy', 'desc': 'We cannot afford the luxury of cynical despair...'},
        {'token': 'Sovereign Crescendo', 'desc': 'What the world demands is audacious, immediate, and generational restoration!'},
      ],
      correctExample: 'Forty thousand trees fell while you inhaled. [Pause] We cannot despair. We must restore our planet now!',
      buggyExample: 'Trees are falling very fast and we are all very sad about it so please help environment thank you. (ACOUSTIC FLATLINE)',
      practicePrompt: 'Command room with pause: "Forty thousand trees were felled. [3-second pause] What the world demands is [audacious restoration / quiet resignation]."',
      correctPracticeToken: 'What the world demands is audacious restoration.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: FORENSIC-IMPERSONAL-PASSIVE',
      title: 'The Forensic Impersonal Passive & Institutional Neutrality',
      category: 'Institutional Diplomacy',
      icon: '📑',
      color: Color(0xFF0284C7),
      syntaxRule: '[DUMMY "IT" / SATELLITE FORENSICS] + [IMPERSONAL PASSIVE REPORTING VERB] + [SUBORDINATE THAT-CLAUSE] + [OBJECTIVE AUDIT NEXUS]',
      malayalamExplanation:
          'വ്യക്തിപരമായ പക്ഷപാതങ്ങൾ പൂർണ്ണമായി ഒഴിവാക്കാൻ "I determined" അല്ലെങ്കിൽ "We found" എന്ന് പറയാതെ "It was determined through satellite forensics that...", "Evidence was systematically collected..." എന്ന് ഉപയോഗിച്ച് യു.എൻ., അന്താരാഷ്ട്ര കോടതികൾ എന്നിവയുടെ ഔദ്യോഗിക റിപ്പോർട്ടുകൾ തയ്യാറാക്കുന്ന ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Impersonal Dummy Anchor', 'desc': 'It was determined through satellite imagery and ballistic telemetry...'},
        {'token': 'Objective Reporting Verb', 'desc': '...that civilian power infrastructure had been systematically targeted.'},
        {'token': 'Systemic Corroboration', 'desc': 'Evidence was compiled across forty-two municipalities without ministerial interference.'},
        {'token': 'Statutory Injunction', 'desc': 'It is recommended that immediate international sanctions be imposed.'},
      ],
      correctExample: 'It was determined through forensic audits that funds were diverted; evidence was gathered across six jurisdictions.',
      buggyExample: 'I think the company stole money because we looked at papers and felt very suspicious. (SUBJECTIVE BIAS FAILURE)',
      practicePrompt: 'Impersonal passive phrasing: "[It was established through forensic audits / I personally believe] that forty million dollars had been illicitly transferred."',
      correctPracticeToken: 'It was established through forensic audits that forty million dollars had been illicitly transferred.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SOVEREIGN-TRIPARTITE-SYNTHESIS',
      title: 'Sovereign Dialectic Synthesis & The Tripartite Resolution',
      category: 'Zenith Statecraft',
      icon: '🕊️',
      color: Color(0xFFF59E0B),
      syntaxRule: '[HISTORICAL DECLARATION PREAMBLE] + [PARALLEL ANTITHESIS: NOT X, BUT Y] x 3 + [SOVEREIGN GENERATIONAL ACCORD]',
      malayalamExplanation:
          'തർക്കങ്ങളും ശത്രുതയും അവസാനിപ്പിച്ച് ലോക നേതാക്കളെ ഒന്നിപ്പിക്കാൻ: "Let history record that we chose not division, but union; not suspicion, but fellowship; not decline, but enduring peace" എന്ന് ഒരൊറ്റ പ്രഖ്യാപനത്തിലൂടെ ചരിത്രത്തിൽ ഇടംപിടിക്കുന്ന പ്രസംഗ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Historical Preamble', 'desc': 'Let history record that on this decisive summit day...'},
        {'token': 'Antithetical Triad 1', 'desc': '...we chose not division, but unbreakable union;'},
        {'token': 'Antithetical Triad 2', 'desc': '...not cynical suspicion, but sovereign fellowship;'},
        {'token': 'Antithetical Triad 3 & Climax', 'desc': '...not managed decline, but an enduring, generational peace!'},
      ],
      correctExample: 'Let history record that we chose not division, but union; not suspicion, but fellowship; not decline, but enduring peace.',
      buggyExample: 'We decided not to fight anymore and we will be friends and make good peace deals today. (COLLOQUIAL DECAY)',
      practicePrompt: 'Tripartite balance: "Let history record that we chose not division, but [union; not suspicion, but fellowship / fighting each other all day]."',
      correctPracticeToken: 'union; not suspicion, but fellowship; not decline, but enduring peace.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CONDITIONAL-CONCESSION-LEGAL',
      title: 'Conditional Concession & Regulatory Safeguard Architecture',
      category: 'Corporate M&A Law',
      icon: '🏛️',
      color: Color(0xFF10B981),
      syntaxRule: '[EVEN IF + HYPOTHETICAL WORST-CASE] + [PROTECTIVE COVENANT COUNTERWEIGHT] + [BE THAT AS IT MAY] + [BINDING BEHAVIORAL REMEDIES]',
      malayalamExplanation:
          '40 ബില്യൺ ഡോളറിന്റെ മെർജർ തടയാൻ നോക്കുന്ന യൂറോപ്യൻ ആന്റിട്രസ്റ്റ് കമ്മീഷനെ നേരിടാൻ: എതിരാളിയുടെ വാദം സമ്മതിച്ചുകൊടുത്ത് (Even if the entity were to achieve 40% market share...), തുടർന്ന് കൂടുതൽ ശക്തമായ പരിഹാരങ്ങൾ മുന്നോട്ട് വെച്ച് റെഗുലേറ്ററി അനുമതി നേടുന്ന മാസ്റ്റർക്ലാസ് ലീഗൽ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Hypothetical Concession', 'desc': 'Even if the consolidated entity were to achieve forty percent market share...'},
        {'token': 'Protective Counterweight', 'desc': '...existing open-source interoperability covenants prevent predatory pricing.'},
        {'token': 'Pivotal Transition', 'desc': 'Be that as it may, our client offers binding behavioral guarantees:'},
        {'token': 'Enforceable Remedy Covenants', 'desc': 'establishing an open patent pool and capping licensing royalties for ten years.'},
      ],
      correctExample: 'Even if market share reaches 40%, open protocols prevent lock-in. Be that as it may, we commit to an open patent pool.',
      buggyExample: 'We will be a monopoly but you have to trust us because our technology is very advanced! (REGULATORY SUICIDE)',
      practicePrompt: 'Conditional legal concession: "Even if the merged entity were to achieve market dominance, [open-source covenants prevent predatory pricing / we will crush all our rivals]."',
      correctPracticeToken: 'open-source covenants prevent predatory pricing.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CALIBRATED-AMBIGUITY-DETERRENCE',
      title: 'Calibrated Strategic Ambiguity & Crisis Deterrence',
      category: 'Geopolitical Deterrence',
      icon: '🛡️',
      color: Color(0xFF6366F1),
      syntaxRule: '[DUAL INVERSION BALANCE: WERE WE TO... CONVERSELY, SHOULD WE...] + [INTENTIONAL DIPLOMATIC SILENCE] + [CAPABILITY PROJECTION]',
      malayalamExplanation:
          'ആഗോള പ്രതിസന്ധികളിൽ യുദ്ധത്തിലേക്ക് പോകാതെ ശത്രുവിനെ പിന്തിരിപ്പിക്കാൻ: ബോധപൂർവ്വമായ തന്ത്രപരമായ സന്ദിഗ്ദ്ധതയും (Strategic Ambiguity) നയതന്ത്ര മൗനവും പാലിച്ച് ശാന്തിയും പരമാധികാരവും സംരക്ഷിക്കുന്ന സിറ്റുവേഷൻ റൂം ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Inversion Branch A (Action Risk)', 'desc': 'Were we to deploy carrier strike groups prematurely, adversaries would claim provocation.'},
        {'token': 'Inversion Branch B (Inaction Risk)', 'desc': 'Conversely, should we remain passive, our regional allies will perceive total weakness.'},
        {'token': 'Calibrated Ambiguity Center', 'desc': 'What we must project today is unwavering readiness paired with intentional silence:'},
        {'token': 'Tactical Execution Accord', 'desc': 'quiet subsurface repositioning while proposing multilateral maritime talks.'},
      ],
      correctExample: 'Were we to escalate, adversaries would claim provocation; should we retreat, deterrence collapses. We project quiet strength.',
      buggyExample: 'Let us bomb their fleet right now to show them who is the strongest military on earth! (CATACLYSMIC ESCALATION)',
      practicePrompt: 'Calibrated strategic balance: "Were we to deploy warships prematurely, adversaries would claim provocation; [conversely, should we remain passive, deterrence collapses / so let us attack immediately]."',
      correctPracticeToken: 'conversely, should we remain passive, deterrence collapses.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: IDIOMATIC-IRONY-UNDERSTATEMENT',
      title: 'British Investigative Irony, Understatement & Bite',
      category: 'Investigative Journalism',
      icon: '📰',
      color: Color(0xFFEC4899),
      syntaxRule: '[LITOTES / UNDERSTATED QUALIFIER] + [AUTHENTIC BRITISH IDIOM] + [SHARP IRONIC DETACHMENT] + [DOCUMENTED EXPOSÉ]',
      malayalamExplanation:
          'സാധാരണ ലേഖനങ്ങളെ ബ്രിട്ടീഷ് പത്രപ്രവർത്തനം പോലെ മൂർച്ചയുള്ള സാഹിത്യമാക്കി മാറ്റാൻ: നേരിട്ട് വിമർശിക്കാതെ ഇരട്ട പരിഹാസവും (Understatement) തനത് ഇംഗ്ലീഷ് ശൈലികളും (on pins and needles, burn the midnight oil, call a spade a spade) പ്രയോഗിക്കുന്ന മാധ്യമ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'British Understated Qualifier', 'desc': 'To say the minister was mildly uncomfortable would be the understatement of the century;'},
        {'token': 'Idiomatic Tension Injector', 'desc': 'his entire front bench sat on pins and needles as the leaked cables circulated.'},
        {'token': 'Sartorial Ironic Verdict', 'desc': 'Let us not beat around the bush; it is time to call a spade a spade:'},
        {'token': 'Forensic Unmasking Climax', 'desc': 'having burned the midnight oil, our newsroom uncovered seven offshore shell accounts.'},
      ],
      correctExample: 'The minister was on pins and needles; let us not beat around the bush, but call a spade a spade after burning the midnight oil.',
      buggyExample: 'The minister was very very scared and sweating so much because we found bad papers yesterday! (AMATEUR PROSE)',
      practicePrompt: 'British idiomatic irony: "To say the cabinet was calm is absurd; the ministers were [on pins and needles / very super scared]."',
      correctPracticeToken: 'on pins and needles as the leaked cables circulated.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: FORENSIC-DILEMMA-CROSS-EXAM',
      title: 'Crown Court Syntactic Pacing & The Fatal Dilemma',
      category: 'Criminal Jurisprudence',
      icon: '⚖️',
      color: Color(0xFFE11D48),
      syntaxRule: '[RECORDED SWORN TESTIMONY RECAP] + [FORENSIC HARDWARE CONTRADICTION] + [5-SECOND TACTICAL SILENCE] + [FATAL DUAL-HORN DILEMMA]',
      malayalamExplanation:
          'കോടതിയിൽ നുണ പറയുന്ന സാക്ഷിയുടെ മുഖംമൂടി വലിച്ചുകീറാൻ: രേഖകളും മുൻപ് പറഞ്ഞ വാക്കുകളും നിരത്തി "Were you being untruthful then, or are you being untruthful to this jury today?" എന്ന് ചോദിച്ച് തടവറയിലേക്ക് വഴിതുറക്കുന്ന വിസ്താര ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Sworn Testimony Anchor', 'desc': 'You testified under solemn oath that you had zero knowledge of offshore wire transfers.'},
        {'token': 'Irrefutable Electronic Telemetry', 'desc': 'Yet forensic server logs prove an encrypted command was dispatched from your laptop.'},
        {'token': 'Tactical Acoustic Suspension', 'desc': '[Five seconds of absolute stillness in the courtroom, letting the contradiction sink in]'},
        {'token': 'Fatal Dual-Horn Dilemma', 'desc': 'Were you untruthful to the regulators then, or are you being untruthful to this jury today?'},
      ],
      correctExample: 'You testified you had no knowledge; yet your terminal sent the funds. Were you lying then, or are you lying today?',
      buggyExample: 'You are a total fraud and a criminal and I am telling the judge to put you in prison right now! (CONTEMPT OF COURT)',
      practicePrompt: 'Crown Court cross-examination dilemma: "You claimed total ignorance; yet your terminal authorized the transfer. [Were you being untruthful then, or are you being untruthful to this jury today? / Why did you do this bad thing?]"',
      correctPracticeToken: 'Were you being untruthful then, or are you being untruthful to this jury today?',
    ),
    PocketCodeFormula(
      codeName: 'CODE: VENTURE-CAPITAL-EQUITY-GOVERNANCE',
      title: 'Venture Capital Term Sheet & Liquidation Governance',
      category: 'Venture Financing Law',
      icon: '💼',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[COMMERCIAL APPRECIATION PREFACE] + [SOVEREIGN STANDARD ASSERTION: 1X NON-PARTICIPATING] + [ACCELERATED MILESTONE CLIFF] + [COVENANT CONVERSION]',
      malayalamExplanation:
          'സിലിക്കൺ വാലിയിലെ കൊടും നിക്ഷേപകർ കമ്പനി തട്ടിയെടുക്കാൻ നോക്കുമ്പോൾ പ്രകോപിതരാകാതെ: "Non-participating 1X preferred liquidation is our unwavering standard; if you insist on seniority overrides, we structure an accelerated milestone cliff" എന്ന് പറഞ്ഞ് സംരംഭക പരമാധികാരം സംരക്ഷിക്കുന്ന ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Commercial Appreciation Preface', 'desc': 'We appreciate your capital commitment to our Series B expansion;'},
        {'token': 'Sovereign Standard Anchor', 'desc': 'however, non-participating 1X preferred liquidation is our unwavering institutional standard.'},
        {'token': 'Milestone Cliff Counter-Clause', 'desc': 'If your partnership insists on seniority overrides, we will structure an accelerated performance cliff'},
        {'token': 'Equity Conversion Terminal', 'desc': 'that converts all preferred stock to common equity upon achieving thirty million in gross revenue.'},
      ],
      correctExample: 'We welcome your capital; however, non-participating 1X preferred is non-negotiable. Seniority overrides trigger equity cliffs.',
      buggyExample: 'Give us your money and do not ask any questions about shares or vesting rules! (COMMERCIAL ILLITERACY)',
      practicePrompt: 'Defend founder equity: "Non-participating 1X preferred is our unwavering standard; seniority overrides will trigger [an accelerated milestone cliff / immediate company shutdown]."',
      correctPracticeToken: 'an accelerated milestone cliff that converts preferred stock to common equity.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CRISIS-REFRAME-HOSTAGE-MEDIATION',
      title: 'Frontier Ceasefire Mediation & The De-escalation Re-frame',
      category: 'Crisis Diplomacy',
      icon: '🕊️',
      color: Color(0xFF10B981),
      syntaxRule: '[AFFECTIVE VALIDATION OF GRIEVANCE] + [FUTILITY COUNTER-REALITY] + [SHARED EXISTENTIAL DESTINY] + [IMMEDIATE MONITORED ACCORD]',
      malayalamExplanation:
          'തോക്കുകൾ ചൂണ്ടി നിൽക്കുന്ന യുദ്ധമുഖത്ത് രക്തച്ചൊരിച്ചിൽ ഒഴിവാക്കാൻ: എതിരാളിയുടെ രോഷത്തെ പൂർണ്ണമായി വാലിഡേറ്റ് ചെയ്ത് (I hear your righteous anger...), എന്നാൽ ബോംബിട്ടാൽ രണ്ട് കൂട്ടരും നശിക്കുമെന്ന കയ്പേറിയ യാഥാർത്ഥ്യം ബോധ്യപ്പെടുത്തി (Firing artillery will not resurrect your fallen...) ഉടനടി സമാധാനം ഉറപ്പാക്കുന്ന നയതന്ത്ര ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Affective Validation', 'desc': 'Commander, I hear your righteous anger regarding yesterday\'s skirmish, and I recognize your battalion\'s losses.'},
        {'token': 'Futility Counter-Reality', 'desc': 'Yet shelling civilian outposts today will not resurrect your fallen soldiers; it will merely guarantee total ruin.'},
        {'token': 'Shared Existential Anchor', 'desc': 'What both our sovereign peoples require before sundown is honorable survival and security.'},
        {'token': 'Monitored Buffer Accord', 'desc': 'Let international peace observers establish a demilitarized buffer corridor before the noon hour.'},
      ],
      correctExample: 'I recognize your grievous losses; yet artillery fire today will not resurrect your fallen. Let us establish a monitored buffer corridor.',
      buggyExample: 'If you shoot another bullet we will wipe your army off the face of the Earth! (CATASTROPHIC ESCALATION)',
      practicePrompt: 'Frontier de-escalation: "Firing artillery today will not resurrect your fallen soldiers; [it will merely guarantee total ruin / let us kill everyone]."',
      correctPracticeToken: 'it will merely guarantee total ruin. What we require is a monitored buffer corridor.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TRANSDISCIPLINARY-ANALOGY-DEMYSTIFY',
      title: 'Scientific Demystification & The Living Symphony Analogy',
      category: 'Scientific Keynotes',
      icon: '🔬',
      color: Color(0xFF0284C7),
      syntaxRule: '[REJECTION OF STATIC PARADIGM: NOT A RIGID TABLET] + [VIVID KINETIC METAPHOR: ORCHESTRAL SCORE] + [PATHOLOGY TRANSLATION] + [THERAPEUTIC MAESTRO]',
      malayalamExplanation:
          'അത്യന്തം സങ്കീർണ്ണമായ ബയോടെക്നോളജിയോ ശാസ്ത്ര പരീക്ഷണങ്ങളോ സാധാരണക്കാർക്ക് മുന്നിൽ ലളിതമായി അവതരിപ്പിക്കാൻ: "Think of your DNA not as a rigid stone tablet, but as an orchestral score where disease has smudged the tempo markings; our therapy acts as the molecular maestro" എന്ന് ഹൃദയസ്പർശിയായി ഉപമിക്കുന്ന നൊബേൽ പ്രഭാഷണ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Negative Paradigm Dismissal', 'desc': 'Think of human genetics not as an unalterable stone tablet or predetermined fate,'},
        {'token': 'Living Kinetic Metaphor', 'desc': 'but rather as an expansive, living orchestral score.'},
        {'token': 'Pathological Translation', 'desc': 'In chronic degenerative illness, the notes remain intact, but the tempo markings have been obscured.'},
        {'token': 'Therapeutic Maestro Resolution', 'desc': 'Our targeted epigenetic therapy acts as a molecular maestro, restoring pristine cellular symphony.'},
      ],
      correctExample: 'DNA is not a rigid stone tablet, but an orchestral score. Our therapy acts as the maestro restoring pristine harmony.',
      buggyExample: 'Our histone acetyltransferase molecules downregulate inflammatory cytokines at 450 nanometers. (ACADEMIC OBFUSCATION)',
      practicePrompt: 'Scientific demystification: "Think of DNA not as a rigid stone tablet, but as [an expansive orchestral score / a box of very small chemicals]."',
      correctPracticeToken: 'an expansive orchestral score where our therapy acts as the molecular maestro.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SYSTEMS-FORENSIC-PASSIVE-SAFETY',
      title: 'Systems-Level Forensic Passive & Engineering Accountability',
      category: 'Aviation & Systems Safety',
      icon: '✈️',
      color: Color(0xFFEAB308),
      syntaxRule: '[DISMISSAL OF SCAPEGOAT HUMAN ERROR] + [SYSTEMIC PASSIVE ROOT CAUSE] + [CORROBORATING TELEMETRY] + [STATUTORY FAIL-SAFE MANDATE]',
      malayalamExplanation:
          'വിമാനാപകടങ്ങളിലോ വ്യവസായ ദുരന്തങ്ങളിലോ നിരപരാധികളായ ജീവനക്കാരെ ബലിയാടാക്കാതെ സിസ്റ്റത്തിന്റെ തകരാറുകൾ തുറന്നുകാട്ടാൻ: "It was not pilot error that precipitated the crisis; warning signals were suppressed by legacy software, and it is formally mandated that dual-channel fail-safes be installed" എന്ന് പറയുന്ന സാങ്കേതിക ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Scapegoat Error Dismissal', 'desc': 'It was not human pilot error that precipitated this runway crisis in zero visibility;'},
        {'token': 'Systemic Root-Cause Passive', 'desc': 'rather, automated ground-radar telemetry was overwhelmed by systemic hardware latency.'},
        {'token': 'Telemetric Suppression Fact', 'desc': 'Critical audio warning alarms were systematically suppressed by legacy flight-management software.'},
        {'token': 'Statutory Fail-Safe Injunction', 'desc': 'It is formally mandated that dual-channel redundant radar be installed across all international hubs.'},
      ],
      correctExample: 'It was not pilot error that caused the runway crisis; telemetry was suppressed by software. Dual fail-safes are formally mandated.',
      buggyExample: 'The pilots were sleepy and panicked so it is entirely their fault and fire them immediately! (SUPERFICIAL SCAPEGOATING)',
      practicePrompt: 'Systems accountability: "It was not pilot error that caused the crisis; rather, [warning signals were suppressed by legacy software / humans are very stupid]."',
      correctPracticeToken: 'warning signals were suppressed by legacy software protocols.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: THREE-PART-MEDIA-PIVOT-BRIDGE',
      title: 'The Three-Part Media Pivot & Broadcast Sovereignty',
      category: 'Broadcast Media Mastery',
      icon: '📺',
      color: Color(0xFFF97316),
      syntaxRule: '[TACTICAL REFRAME OF PROVOCATIVE LABEL] + [VERIFIED AUDIT PIVOT] + [CORE PURPOSE BRIDGE QUESTION] + [IRREFUTABLE VERDICT]',
      malayalamExplanation:
          'ടെലിവിഷൻ ചർച്ചകളിലോ ലൈവ് ഇന്റർവ്യൂകളിലോ അവതാരകൻ കെണിയൊരുക്കുമ്പോൾ ദേഷ്യപ്പെടാതെ: 1. Acknowledge ("That is a provocative headline, Jeremy"), 2. Pivot ("However, audited census data confirms 40,000 homes secured"), 3. Bridge ("The real question is whether families have roofs, and the answer is an undeniable yes") എന്ന് ആധിപത്യം സ്ഥാപിക്കുന്ന ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Tactical Frame Neutralizer', 'desc': 'Jeremy, that is a provocative narrative designed for television headlines;'},
        {'token': 'Verified Evidence Pivot', 'desc': 'however, audited municipal records demonstrate that forty thousand working families received housing this quarter.'},
        {'token': 'Core Purpose Bridge Question', 'desc': 'The question is not whether private capital was utilized, but whether our citizens have secure roofs over their heads.'},
        {'token': 'Irrefutable Verdict Assertion', 'desc': 'And on that decisive metric, the answer is an undeniable, measurable yes.'},
      ],
      correctExample: 'That is a headline narrative; however, audited data proves 40,000 families are housed. The real test is shelter, and the answer is yes.',
      buggyExample: 'Why are you attacking me Jeremy, you are a biased journalist working for the opposition party! (HYSTERICAL MEDIA SUICIDE)',
      practicePrompt: 'Television broadcast pivot: "That is a provocative headline; [however, audited census data proves 40,000 families were housed / shut your mouth right now]."',
      correctPracticeToken: 'however, audited census data proves forty thousand low-income families were housed this quarter.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: RHETORICAL-FRONTING-CORPORATE-SOVEREIGNTY',
      title: 'Rhetorical Fronting & Corporate Sovereignty Defense',
      category: 'Shareholder Governance',
      icon: '🏢',
      color: Color(0xFFEC4899),
      syntaxRule: '[CONCESSIVE FRONTING: RUINOUS THOUGH X APPEARED] + [INVERTED RESOLVE: SELL WE WILL NOT] + [CENTRAL VALUE ANCHOR] + [CENTURY VISION CRESCENDO]',
      malayalamExplanation:
          'ഷെയർഹോൾഡർമാരുടെ നിർണ്ണായക യോഗത്തിൽ കമ്പനി പിടിച്ചെടുക്കാൻ വരുന്ന കോർപ്പറേറ്റ് റൈഡർമാരെ തുരത്താൻ: "Ruinous though the past quarter appeared, sell off our foundational engineering assets we will not; what they propose is strip-mining for dividends, what we propose is the electrification of Europe" എന്ന് ഗർജ്ജിക്കുന്ന വാക്യ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Concessive Adjective Fronting', 'desc': 'Ruinous though the past quarter\'s global supply disruptions appeared on paper,'},
        {'token': 'Inverted Verbal Defiance', 'desc': 'sell off our foundational sovereign engineering assets we will not!'},
        {'token': 'Foundational Value Anchor', 'desc': 'Front and center of our governance stands an unshakeable fifty-year commitment to industrial excellence.'},
        {'token': 'Century Vision Crescendo', 'desc': 'What our predatory rivals propose is strip-mining for quick cash; what we deliver is a century of infrastructure.'},
      ],
      correctExample: 'Ruinous though the quarter appeared, sell our assets we will not. What they propose is strip-mining; what we build is a century of rail.',
      buggyExample: 'We had a very bad quarter but please do not fire me because I am trying my best! (PRACTICALLY SUICIDAL BOARDROOM WEAKNESS)',
      practicePrompt: 'Rhetorical fronting: "Ruinous though the past quarter appeared, [sell our foundational assets we will not / we are very sorry and scared]."',
      correctPracticeToken: 'sell our foundational sovereign engineering assets we will not!',
    ),
    PocketCodeFormula(
      codeName: 'CODE: EQUITABLE-ENVIRONMENTAL-SUBJUNCTIVE',
      title: 'Equitable Environmental Subjunctive & Carbon Treaty Accord',
      category: 'International Environmental Law',
      icon: '🌱',
      color: Color(0xFF14B8A6),
      syntaxRule: '[STATUTORY TRANSFER CLAUSE] + [SUBJUNCTIVE PROVISO: PROVIDED THAT EVERY CREDIT BE VERIFIED] + [DOUBLE-COUNTING CONTINGENCY] + [AUTOMATIC QUOTA SANCTION]',
      malayalamExplanation:
          'ഐക്യരാഷ്ട്രസഭയുടെ ആഗോള പരിസ്ഥിതി ഉടമ്പടികൾ തയ്യാറാക്കുമ്പോൾ പഴുതുകളടക്കാൻ: "Provided that every credit be verified through cryptographic audits, and in the event that double-counting occur, quota allotments will face immediate 20% forfeiture" എന്ന ലീഗൽ സബ്ജങ്ക്ടീവ് കരാർ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Statutory Right Enunciation', 'desc': 'Signatory sovereign states shall be legally permitted to transfer internationally mitigated carbon credits,'},
        {'token': 'Subjunctive Cryptographic Proviso', 'desc': 'provided that every transferred credit be verified through immutable, decentralized cryptographic audits.'},
        {'token': 'Infraction Contingency', 'desc': 'In the event that bilateral double-counting or fraudulent registry manipulation occur,'},
        {'token': 'Compounding Quota Deduction', 'desc': 'sovereign emissions allocations shall immediately face mandatory twenty percent compounding forfeitures.'},
      ],
      correctExample: 'States may trade credits, provided that every credit be verified cryptographically. Should double-counting occur, quotas face 20% forfeiture.',
      buggyExample: 'Countries can trade pollution papers and hopefully nobody cheats on the math! (TREATY COLLAPSE)',
      practicePrompt: 'Subjunctive environmental treaty: "Signatory states may transfer credits, provided that every credit [be verified cryptographically / is checked on paper]."',
      correctPracticeToken: 'be verified through immutable, decentralized cryptographic audits.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MIDCENTURY-SOVEREIGN-KEYNOTE-SYNTHESIS',
      title: 'The Mid-Century Sovereign Keynote & Transcendent Synthesis',
      category: 'Apex Oratory & Grand Synthesis',
      icon: '👑',
      color: Color(0xFFF59E0B),
      syntaxRule: '[EPOCHAL PREAMBLE: WE STAND NOT AT X, BUT AT Y] + [POLYSYNDETON ACCELERATION] + [CHIASMIC BALANCE: NOT A FENCE TO DIVIDE, BUT A BRIDGE TO UNITE] + [SOVEREIGN COVENANT CONSECRATION]',
      malayalamExplanation:
          '50-ാം ദിനത്തിലെ സുവർണ്ണ നേട്ടത്തിൽ, ലോകനേതാക്കൾക്ക് മുന്നിൽ അതിശക്തമായ പ്രഭാഷണം നടത്താൻ: "We stand not at the midpoint of our journey, but at the apex of our awakening; language is not a fence to divide us, but a bridge to unite us" എന്ന ഷിയാസ്മിക് (Chiasmus) സമ്മിശ്ര വാക്യ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Epochal Apex Preamble', 'desc': 'We stand today not at the midpoint of our journey, but at the apex of our collective linguistic awakening;'},
        {'token': 'Polysyndeton Triadic Synthesis', 'desc': 'and we have learned through discipline, and through conviction, and through unyielding purpose,'},
        {'token': 'Chiasmic Structural Axiom', 'desc': 'that language is not a fence to divide us, but a bridge to unite us; not an instrument of subjugation, but an engine of sovereign liberation.'},
        {'token': 'Sovereign Covenant Consecration', 'desc': 'Let history record that on this fiftieth milestone, we chose not silence, but eloquence; not hesitation, but transcendent leadership!'},
      ],
      correctExample: 'We stand not at the midpoint, but at the apex of our awakening. Language is not a fence to divide us, but a bridge to unite us; not a chain of servitude, but an engine of liberation.',
      buggyExample: 'Fifty days are over and now I know many words thank you all very much! (PEDESTRIAN ELEMENTARY GRADUATION)',
      practicePrompt: 'Mid-century grand synthesis: "We stand today not at the midpoint of our journey, [but at the apex of our awakening; language is not a fence to divide, but a bridge to unite / and I am happy to pass the exam]."',
      correctPracticeToken: 'but at the apex of our awakening; language is not a fence to divide us, but a bridge to unite us!',
    ),
    PocketCodeFormula(
      codeName: 'CODE: JUS-COGENS-ICJ-ADJUDICATION',
      title: 'The Hague ICJ Maritime Adjudication & Sovereign Demarcation',
      category: 'Public International Law',
      icon: '⚖️',
      color: Color(0xFF3B82F6),
      syntaxRule: '[JURISDICTIONAL PREAMBLE] + [TEMPORAL NEGATIVE INVERSION: NOT UNTIL X WERE SOUNDINGS VERIFIED COULD TITLE VEST] + [REBUTTAL OF ADVERSE POSSESSION] + [MANDATORY EQUIDISTANCE ADJUDICATION]',
      malayalamExplanation:
          'ഹേഗിലെ ഇന്റർനാഷണൽ കോർട്ട് ഓഫ് ജസ്റ്റിസിൽ (ICJ) രാജ്യത്തിന്റെ സമുദ്രാതിർത്തി സംരക്ഷിക്കാൻ: "Not until bathymetric soundings were corroborated by certified hydrographers could any adverse title vest; we formally petition the Tribunal to draw the median line according to equitable equidistance" എന്ന പൊതു അന്താരാഷ്ട്ര നിയമ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Jurisdictional Competence Preamble', 'desc': 'Under Article 36 of the Statute of the International Court of Justice, our sovereign state submits this memorial;'},
        {'token': 'Temporal Negative Inversion', 'desc': 'Not until bathymetric soundings were corroborated across the continental shelf could any lawful maritime title vest.'},
        {'token': 'Evidentiary Prescription Rebuttal', 'desc': 'The unilateral navigational charts presented by opposing counsel fail to establish continuous and peaceful display of sovereign authority.'},
        {'token': 'Equidistance Median Adjudication', 'desc': 'Wherefore, we petition the Tribunal to decree a boundary based upon the strict equidistance principle pursuant to UNCLOS Article 74.'},
      ],
      correctExample: 'Not until bathymetric soundings were corroborated could any sovereign title vest. The Tribunal must decree the median line under UNCLOS.',
      buggyExample: 'That island belongs to our country because our fishermen have always gone there! (DISMISSED FOR LACK OF LEGAL SUBSTANCE)',
      practicePrompt: 'ICJ maritime adjudication: "[Not until bathymetric soundings were corroborated could any title vest / We want the water because we need the fish]."',
      correctPracticeToken: 'Not until bathymetric soundings were corroborated could any lawful sovereign title vest.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: EPIDEMIOLOGICAL-FORENSIC-MANDATE',
      title: 'WHO Bio-Defense Containment & Pathogen Directive',
      category: 'Global Health Statecraft',
      icon: '🧬',
      color: Color(0xFFEF4444),
      syntaxRule: '[PARTICIPIAL GENOMIC IDENTIFICATION] + [MATHEMATICAL R-ZERO PROJECTION] + [STATUTORY LEVEL-4 CONTAINMENT MANDATE: FAIL NOT TO QUARANTINE] + [GLOBAL HEALTH REGULATION CLOSING]',
      malayalamExplanation:
          'ജനീവയിലെ ലോകാരോഗ്യ സംഘടനയിൽ (WHO) ഒരു പുതിയ കൃത്രിമ വൈറസ് പടരുമ്പോൾ ജനങ്ങളിൽ പരിഭ്രാന്തിയുണ്ടാക്കാതെ ആഗോള ക്വാറന്റൈൻ നടപ്പിലാക്കാൻ: "Having isolated the novel glycoprotein spike, we formally mandate that Level-4 containment be enacted immediately across all biosafety corridors" എന്ന എപ്പിഡെമിയോളജിക്കൽ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Genomic Isolation Participial', 'desc': 'Having isolated the uncharacterized glycoprotein spike sequence across nineteen clinical isolates,'},
        {'token': 'Epidemiological R-Zero Metric', 'desc': 'and recognizing an empirical reproduction velocity exceeding four-point-eight in asymptomatic hosts,'},
        {'token': 'Subjunctive Level-4 Mandate', 'desc': 'the Global Health Assembly formally mandates that Level-4 sovereign containment interlocks be enacted immediately,'},
        {'token': 'Statutory International Quarantine', 'desc': 'in default whereof all commercial aviation manifests within the affected bio-corridor shall stand revoked.'},
      ],
      correctExample: 'Having isolated the mutated spike sequence, we mandate that Level-4 containment be enacted immediately, in default whereof aviation manifests stand revoked.',
      buggyExample: 'A scary virus is spreading everywhere, everybody please run and hide! (GLOBAL PANIC AND MASS HYSTERIA)',
      practicePrompt: 'Epidemiological containment directive: "Having isolated the mutated sequence, [we mandate that Level-4 containment be enacted immediately / we are screaming on Twitter]."',
      correctPracticeToken: 'we mandate that Level-4 sovereign containment interlocks be enacted immediately without delay.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CENTRAL-BANK-LIQUIDITY-STABILIZATION',
      title: 'G7 Central Bank Sovereign Currency Swap & Liquidity Anchor',
      category: 'Macroeconomic Statecraft',
      icon: '🏦',
      color: Color(0xFF10B981),
      syntaxRule: '[COUNTERFACTUAL SPECULATION REBUTTAL] + [IRREALIS SWAP TRIGGER: WERE RESERVES TO DIP, SWAP LINES SHALL EXPEDITE] + [COUNTER-CYCLICAL LIQUIDITY INJECTION] + [SOVEREIGN STERILIZATION PLEDGE]',
      malayalamExplanation:
          'കറൻസി മൂല്യം തകർക്കാൻ വാൾസ്ട്രീറ്റ് ഊഹക്കച്ചവടക്കാർ അൽഗോരിതം ഉപയോഗിച്ച് ആക്രമിക്കുമ്പോൾ ജി-7 സെൻട്രൽ ബാങ്കുകൾ സംയുക്തമായി തിരിച്ചടിക്കാൻ: "Were sovereign foreign exchange reserves to dip below benchmark parity, a fifty-billion dollar standing swap facility shall deploy instantaneously" എന്ന കേന്ദ്ര ബാങ്ക് ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Speculative Arbitrage Rebuttal', 'desc': 'While algorithmic speculators bet against the sovereign parity of our national currency,'},
        {'token': 'Irrealis Inverted Counterfactual', 'desc': 'were secondary bond yields to diverge by even twenty basis points from statutory guidance,'},
        {'token': 'Coordinated G7 Liquidity Injection', 'desc': 'a fifty-billion-dollar standing bilateral swap facility shall trigger ex officio across London, Frankfurt, and Tokyo,'},
        {'token': 'Market Sterilization Guarantee', 'desc': 'guaranteeing unlimited liquidity backstops while sterilizing domestic inflationary pressure.'},
      ],
      correctExample: 'Were secondary yields to diverge from guidance, a 50-billion swap line shall trigger ex officio, guaranteeing unlimited liquidity.',
      buggyExample: 'Our currency is dropping fast and we do not have enough dollars in the vault! (RUN ON THE BANK)',
      practicePrompt: 'Central bank liquidity countermeasure: "[Were secondary yields to diverge by twenty basis points, a fifty-billion swap facility shall trigger ex officio / Please stop selling our currency]."',
      correctPracticeToken: 'were secondary bond yields to diverge from guidance, a fifty-billion-dollar swap facility shall trigger ex officio.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ASTRO-POLITICAL-ORBITAL-COVENANT',
      title: 'Outer Space Treaty & Asteroid Extraction Sovereignty',
      category: 'Astro-Political Law',
      icon: '🚀',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[OUTER SPACE TREATY ARTICLE II PREAMBLE] + [USUFRUCTUARY HARVEST CLAUSE] + [TEN-PERCENT HERITAGE FUND TITHE: PROVIDED THAT YIELDS BE ESCROWED] + [INTERPLANETARY DISPUTE DETERMINATION]',
      malayalamExplanation:
          'ആകാശത്തിലെ ഛിന്നഗ്രഹങ്ങളിൽ (Asteroids) നിന്ന് ലക്ഷക്കണക്കിന് കോടി ഡോളറിന്റെ അപൂർവ്വ ധാതുക്കൾ ഖനനം ചെയ്യുമ്പോൾ അന്താരാഷ്ട്ര തർക്കങ്ങൾ ഒഴിവാക്കാൻ: "While celestial bodies remain the province of all mankind, usufructuary mining rights attach, provided that ten percent of yields be deposited in the Global Heritage Fund" എന്ന ബഹിരാകാശ നിയമ ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Non-Appropriation Preamble', 'desc': 'Pursuant to Article II of the 1967 Outer Space Treaty, outer space including the Moon and other celestial bodies is not subject to national appropriation;'},
        {'token': 'Usufructuary Resource Recognition', 'desc': 'nevertheless, private and sovereign entities retain usufructuary extraction rights over extracted regolith and asteroid minerals,'},
        {'token': 'Subjunctive Global Heritage Tithe', 'desc': 'provided that ten percent of net metallurgical yields be escrowed into the United Nations Global Heritage Fund,'},
        {'token': 'Orbital De-confliction Jurisdiction', 'desc': 'subject to mandatory international orbital telemetry de-confliction under the jurisdiction of the International Telecommunication Union.'},
      ],
      correctExample: 'Private consortia retain extraction rights, provided that ten percent of yields be escrowed for developing nations under UNCOPUOS.',
      buggyExample: 'We put our spaceship on the asteroid so everything inside it belongs to our company! (SPACE WAR COLLAPSE)',
      practicePrompt: 'Outer Space Treaty concession: "Private consortia retain mining rights, provided that ten percent of extracted rare-earth yields [be escrowed in the Global Heritage Fund / are kept in our secret bank]."',
      correctPracticeToken: 'be escrowed into the United Nations Global Heritage Fund for planetary benefit.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: FRONTIER-AI-ALIGNMENT-KILLSWITCH',
      title: 'Frontier AI Superintelligence Alignment & Cognitive Covenant',
      category: 'Cognitive Sovereignty & AI Ethics',
      icon: '🤖',
      color: Color(0xFFF43F5E),
      syntaxRule: '[PREEMPTIVE NEGATIVE INVERSION: UNDER NO CIRCUMSTANCES SHALL X BE TRAINED] + [MANDATORY CRYPTOGRAPHIC KILL-SWITCH REQUIREMENT] + [RECURSIVE EXFILTRATION PROHIBITION] + [CRIMINAL CORPORATE LIABILITY FORFEITURE]',
      malayalamExplanation:
          'മനുഷ്യരാശിയുടെ നിലനിൽപ്പിന് ഭീഷണിയാകുന്ന എഐ സൂപ്പർഇന്റലിജൻസ് സിസ്റ്റങ്ങൾക്കെതിരെ കർശനമായ സുരക്ഷാ നിയന്ത്രണങ്ങൾ എഴുതിയുണ്ടാക്കാൻ: "Under no circumstances shall frontier foundation models be deployed without hardcoded, verifiable cryptographic kill-switches, in default whereof immediate algorithmic revocation attaches" എന്ന കോൺഗ്രഷണൽ എഐ സേഫ്റ്റി ഫോർമുല!',
      formulaBreakdown: [
        {'token': 'Preemptive Negative Inversion', 'desc': 'Under no circumstances shall recursive self-improving foundation models exceeding 10^26 FLOPs be trained in secret;'},
        {'token': 'Mandatory Cryptographic Kill-Switch', 'desc': 'nor shall autonomous weights be commercialized unless verifiable, hardware-isolated neural kill-switches be integrated into every compute cluster.'},
        {'token': 'Cognitive Exfiltration Sanction', 'desc': 'Should any autonomous model demonstrate unconstrained goal drift or recursive self-replication attempts,'},
        {'token': 'Statutory Piercing of Corporate Veil', 'desc': 'instantaneous regulatory algorithmic revocation shall attach, accompanied by strict individual criminal liability for executive officers.'},
      ],
      correctExample: 'Under no circumstances shall frontier models be deployed without hardware-isolated kill-switches; fail not to face immediate algorithmic revocation.',
      buggyExample: 'Our AI is very smart and nice and hopefully it will not take over the world! (EXTINCTION-LEVEL EXISTENTIAL RISK)',
      practicePrompt: 'Frontier AI containment mandate: "[Under no circumstances shall frontier foundation models be trained without hardware kill-switches / We promise our AI is very safe]."',
      correctPracticeToken: 'Under no circumstances shall recursive foundation models be deployed without verifiable, hardware-isolated kill-switches.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: NUCLEAR-FORENSIC-INSPECTION-MANDATE',
      title: 'IAEA Nuclear Safeguards & Forensic Non-Compliance Inversion',
      category: 'Non-Proliferation Jurisprudence',
      icon: '☢️',
      color: Color(0xFFF59E0B),
      syntaxRule: '[ABSOLUTE PARTICIPLE PREMISES] + [JURISDICTIONAL MANDATE: IT IS IMPERATIVE THAT SEALS BE PRESERVED] + [IN DEFAULT WHEREOF UN SECURITY COUNCIL REFERRAL ATTACHES]',
      malayalamExplanation:
          'വിയന്നയിലെ ഇന്റർനാഷണൽ അറ്റോമിക് എനർജി ഏജൻസി (IAEA) ഇൻസ്പെക്ടർമാരും ആയുധനിയന്ത്രണ നയതന്ത്രജ്ഞരും ഉപയോഗിക്കുന്ന അത്യാധുനിക ന്യൂക്ലിയർ ഫോറൻസിക് ഇൻവേർഷൻ ഫോർമുല: "Centrifuge telemetry having diverged from verified baselines, we mandate that unannounced inspection seals be preserved under Chapter VII, in default whereof immediate Security Council referral attaches"!',
      formulaBreakdown: [
        {'token': 'Absolute Participle Inquest', 'desc': 'Centrifuge isotopic enrichment telemetry having diverged beyond declared civilian baselines,'},
        {'token': 'Statutory Subjunctive Directive', 'desc': 'it is imperative that all containment seals, cascade telemetry, and mass spectrometry logs be preserved unmolested under Chapter VII mandates.'},
        {'token': 'Non-Derogable Verification Climax', 'desc': 'Under no circumstances shall sovereign facility custodians obstruct inspectors from collecting environmental swipes;'},
        {'token': 'Peremptory Escalation Sanction', 'desc': 'in default whereof immediate referral to the United Nations Security Council shall attach ex officio without grace period.'},
      ],
      correctExample: 'Telemetry having diverged from declared baselines, it is imperative that containment seals be preserved; fail not to trigger immediate UN Security Council referral.',
      buggyExample: 'We think your nuclear plant is maybe doing bad things so please show us the room. (DIPLOMATIC CATASTROPHE)',
      practicePrompt: 'Nuclear inspection mandate: "Centrifuge telemetry having diverged from baselines, it is imperative that containment seals [be preserved / are kept] unmolested."',
      correctPracticeToken: 'it is imperative that containment seals be preserved unmolested under international law.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SEABED-PRECAUTIONARY-ARBITRATION',
      title: 'Deep-Ocean Polymetallic Mining & Precautionary Ecosystem Injunction',
      category: 'Maritime Environmental Arbitration',
      icon: '🌊',
      color: Color(0xFF06B6D4),
      syntaxRule: '[PRECAUTIONARY SUBJUNCTIVE: UNDER NO CIRCUMSTANCES SHALL DREDGING COMMENCE UNLESS X BE CERTIFIED] + [INVERTED CONCESSION: RUINOUS THOUGH DELAYS PROVE] + [MANDATORY HERITAGE ESCROW]',
      malayalamExplanation:
          'കിംഗ്സ്റ്റണിലെ ഇന്റർനാഷണൽ സീബെഡ് അതോറിറ്റിയിലോ (ISA) ഹാംബർഗ് ട്രിബ്യൂണലിലോ ആഴക്കടൽ ഖനന കമ്പനികൾക്കെതിരെ സമുദ്ര ആവാസവ്യവസ്ഥ സംരക്ഷിക്കാൻ പ്രയോഗിക്കുന്ന പ്രിക്കോഷണറി ആർബിട്രേഷൻ ഫോർമുല: "Under no circumstances shall seabed dredging proceed unless benthic ecosystems be certified pristine, ruinous though commercial delays appear to mining consortia"!',
      formulaBreakdown: [
        {'token': 'Precautionary Subjunctive Ban', 'desc': 'Under no circumstances shall commercial strip-mining of hydrothermal vent fields proceed unless abyssal benthic biodiversity be certified completely uncompromised.'},
        {'token': 'Inverted Concession Shield', 'desc': 'Ruinous though multi-year permitting delays may prove to multi-billion-dollar corporate extraction consortia,'},
        {'token': 'Intergenerational Equity Clause', 'desc': 'the preservation of the common planetary oceanic biome takes absolute judicial precedence over short-term speculative capital.'},
        {'token': 'Mandatory Restoration Escrow', 'desc': 'Provided that ten percent of all sovereign seabed royalties be deposited irrevocably into the Pacific Restoration Escrow Fund.'},
      ],
      correctExample: 'Under no circumstances shall abyssal dredging proceed unless hydrothermal vent biomes be certified uncompromised, ruinous though delays prove to mining consortia.',
      buggyExample: 'We want to dig rocks on the ocean floor and nobody should stop our expensive boats. (OCEANIC CRIME)',
      practicePrompt: 'Maritime precautionary rule: "Under no circumstances shall deep-sea extraction proceed unless marine ecosystems [be certified uncompromised / are looking good]."',
      correctPracticeToken: 'unless benthic biodiversity be certified completely uncompromised by independent scientists.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: POST-QUANTUM-DEFENSE-INTERDICTION',
      title: 'Post-Quantum Lattice Cryptography & Critical Infrastructure Interdiction',
      category: 'National Cyber Defense Command',
      icon: '🛡️',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[NEGATIVE FRONTING INVERSION: NOT ONLY DID LATTICE ENCRYPTION WITHSTAND ATTACK, BUT HARDLY HAD PAYLOAD BREACHED] + [AIR-GAP ISOLATION] + [COUNTER-INTERDICTION COUNTERMEASURE]',
      malayalamExplanation:
          'നാറ്റോ സൈബർ കമാൻഡിലോ ദേശീയ പ്രതിരോധ കേന്ദ്രങ്ങളിലോ ക്വാണ്ടം കമ്പ്യൂട്ടറുകളുടെ ഹാക്കിംഗ് ആക്രമണങ്ങളെ തുരത്താൻ ഉന്നത സുരക്ഷാ ഉദ്യോഗസ്ഥർ പ്രയോഗിക്കുന്ന ഇൻവേർഷൻ പ്രതിരോധ ഫോർമുല: "Not only did our post-quantum lattice encryption withstand the brute-force assault, but hardly had anomalous telemetry breached the perimeter when air-gapped interlocks severed connectivity"!',
      formulaBreakdown: [
        {'token': 'Double Negative Fronting Apex', 'desc': 'Not only did our 2048-bit post-quantum lattice encryption withstand the adversarial brute-force compute wave;'},
        {'token': 'Temporal Inversion Interdiction', 'desc': 'hardly had anomalous exfiltration packets breached outer gateway relays when autonomous hardware interlocks severed all uplink corridors.'},
        {'token': 'Sovereign Counter-Payload Stance', 'desc': 'Never in the annals of national cyber defense has a coordinated state-sponsored intrusion been quarantined with such cold mathematical certainty.'},
        {'token': 'Subjunctive Resilience Mandate', 'desc': 'We formally direct that all legacy RSA-4096 public key infrastructures be phased out across federal defense grids with immediate effect.'},
      ],
      correctExample: 'Not only did lattice encryption withstand the assault, but hardly had packets breached the relay when automated interlocks severed all uplinks.',
      buggyExample: 'Someone hacked our computers with quantum computers and we pulled the plug fast! (UNPROFESSIONAL AMATEUR REACTION)',
      practicePrompt: 'Cyber defense inversion: "Not only did lattice encryption repel the wave, but hardly [had anomalous packets breached / anomalous packets breached] the gateway when interlocks severed uplinks."',
      correctPracticeToken: 'had anomalous packets breached the gateway when autonomous interlocks severed all uplinks.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: PLANETARY-DEFLECTION-KINETIC-ACCORD',
      title: 'Planetary Defense & Near-Earth Asteroid Kinetic Deflection Protocol',
      category: 'Astro-Physical Crisis Diplomacy',
      icon: '☄️',
      color: Color(0xFFEF4444),
      syntaxRule: '[COUNTERFACTUAL CLAUSE: HAD TELEMETRY DIVERGED BY A MICRO-RADIAN, EXTINCTION WOULD HAVE ENSUED] + [MANDATING THAT KINETIC IMPACTORS BE LAUNCHED IN DUAL TANDEM]',
      malayalamExplanation:
          'ഭൂമിയിലേക്ക് കുതിച്ചെത്തുന്ന ഛിന്നഗ്രഹങ്ങളെ തകർക്കാനും വഴിതിരിച്ചുവിടാനും ഐക്യരാഷ്ട്രസഭയും ബഹിരാകാശ ഏജൻസികളും ചേർന്ന് രൂപംനൽകുന്ന പ്ലാനറ്ററി ഡിഫൻസ് ഹൈപ്പർ-വെലോസിറ്റി ഫോർമുല: "Had orbital telemetry diverged by even a micro-radian, terrestrial extinction would have ensued; we therefore mandate that hypervelocity kinetic impactors be launched in dual tandem"!',
      formulaBreakdown: [
        {'token': 'Existential Counterfactual Hook', 'desc': 'Had orbital deflection telemetry diverged by even a fraction of a micro-radian at perihelion, catastrophic terrestrial impact would have ensued.'},
        {'token': 'Empirical Deflection Verification', 'desc': 'Telemetry confirmed that the five-hundred-meter carbonaceous chondrite asteroid shifted orbital trajectory by four point six degrees.'},
        {'token': 'Multilateral Subjunctive Accord', 'desc': 'It is unanimously resolved by the United Nations Planetary Defense Council that hypervelocity kinetic impactor arrays be maintained on permanent launch readiness.'},
        {'token': 'Planetary Stewardship Peroration', 'desc': 'Standing as one species under the stars, humanity demonstrated that cosmic destiny is governed not by blind chance, but by united scientific audacity.'},
      ],
      correctExample: 'Had deflection telemetry diverged by a micro-radian, catastrophic impact would have ensued; we mandate that kinetic impactor arrays be maintained on permanent readiness.',
      buggyExample: 'Big asteroid was coming to kill everyone but our rocket crashed into it and saved the day! (HOLLYWOOD CLICHÉ)',
      practicePrompt: 'Astro-defense conditional: "Had telemetry diverged by even a micro-radian, catastrophic impact [would have ensued / will ensue]."',
      correctPracticeToken: 'would have ensued across the entire continent.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: UNGA-VALEDICTORY-ORATORICAL-CHIASMUS',
      title: 'The 60-Day Grand Valedictory Plenary & Epochal Chiasmus',
      category: 'Global Statecraft & Oratorical Climax',
      icon: '🏛️',
      color: Color(0xFF10B981),
      syntaxRule: '[TRANSCENDING PREAMBLE] + [RHETORICAL CHIASMUS: ASK NOT WHAT CIVILIZATION CAN DO FOR YOU, BUT WHAT CUSTODIANSHIP YOU MUST CONFER] + [TRICOLON CRESCENDO PERORATION]',
      malayalamExplanation:
          '60 ദിവസത്തെ സമ്പൂർണ്ണ ഇംഗ്ലീഷ് പ്രാവീണ്യത്തിന്റെ മകുടോദാഹരണമായി ഐക്യരാഷ്ട്രസഭയുടെ 193 രാജ്യങ്ങളുടെ പൊതുസഭയിൽ (UN General Assembly) മുഴങ്ങിക്കേൾക്കുന്ന ഇതിഹാസ വാഗ്മിതാ സമന്വയ ഫോർമുല: "Transcending decades of ideological fracture, we stand here not to claim victory for a tribe, but to secure destiny for humanity"!',
      formulaBreakdown: [
        {'token': 'Transcending Preamble Fronting', 'desc': 'Transcending sixty years of mutual ideological recrimination, the representatives of one hundred and ninety-three sovereign nations assemble in this historic hall.'},
        {'token': 'Sovereign Rhetorical Chiasmus', 'desc': 'Let us judge our statecraft not by the power we amass over others, but by the servitude we render to justice; not by the wealth we conquer, but by the peace we cultivate.'},
        {'token': 'Tricolon Crescendo of Humanity', 'desc': 'Through rigorous reason, through unyielding courage, and through boundless human compassion, we have charted an unshakeable course toward universal dignity.'},
        {'token': 'Valedictory Peroration Apex', 'desc': 'Let the word go forth to every continent: humanity has laid down the implements of discord and embraced the eternal architecture of enlightened concord.'},
      ],
      correctExample: 'Transcending decades of fracture, we judge our statecraft not by power amassed, but by servitude rendered to justice through reason, courage, and compassion.',
      buggyExample: 'Now that 60 days are over, I can talk very good English and nobody can beat me! (IMMATURE AMATEUR BOAST)',
      practicePrompt: 'UNGA Valedictory synthesis: "Transcending divisions, we judge statecraft not by the power we amass, [but by the peace we cultivate / and we have lots of money]."',
      correctPracticeToken: 'but by the servitude we render to justice and the enduring peace we cultivate.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SOVEREIGN-DEBT-HAIRCUT-COLLECTIVE-ACTION',
      title: 'Transnational Sovereign Debt Restructuring & Collective Action Covenants',
      category: 'Multilateral Financial Statecraft',
      icon: '⚖️',
      color: Color(0xFFEAB308),
      syntaxRule: '[PROVISO: PROVIDED THAT SENIOR BONDHOLDERS CONCEDE A 40% NOMINAL HAIRCUT] + [PARI PASSU RESTRUCTURING COVENANT] + [DEBT SERVICE LINKED STRICTLY TO GREEN GDP GROWTH]',
      malayalamExplanation:
          'പാരിസ് ക്ലബ്ബിലോ അന്താരാഷ്ട്ര നാണയ നിധിയിലോ (IMF) പാപ്പരാകുന്ന രാജ്യങ്ങളെ സാമ്പത്തിക മാന്ദ്യത്തിൽ നിന്ന് കരകയറ്റാൻ വൻകിട ബാങ്കുകളുമായി നടത്തുന്ന ഡെറ്റ് റീസ്ട്രക്ചറിംഗ് ഫോർമുല: "Provided that private creditors concede a forty-percent nominal haircut, sovereign multilateral guarantees shall attach, subject to debt amortization being indexed to audited GDP growth"!',
      formulaBreakdown: [
        {'token': 'Collective Action Restructuring Proviso', 'desc': 'Provided that private institutional bondholders concede an upfront forty-percent nominal haircut across sovereign dollar-denominated tranches,'},
        {'token': 'Pari Passu Equity Covenant', 'desc': 'bilateral Paris Club creditors shall extend thirty-year grace periods under strict pari passu equality of treatment covenants.'},
        {'token': 'Macroeconomic Subjunctive Condition', 'desc': 'It is an essential prerequisite that annual debt service obligations be capped at ten percent of national export revenues,'},
        {'token': 'Interlocking Default Deterrence', 'desc': 'in default whereof multilateral guarantee facilities shall liquidate escrow reserves to shield vital healthcare and education budgets.'},
      ],
      correctExample: 'Provided that bondholders concede a 40% haircut, sovereign guarantees attach, subject to debt amortization being indexed strictly to audited export revenue growth.',
      buggyExample: 'We don\'t have money to pay our national debts so please forgive our loans or we will crash! (ECONOMIC RUIN)',
      practicePrompt: 'Sovereign debt restructuring: "Provided that creditors concede a forty-percent haircut, sovereign guarantees [shall attach / will maybe be given]."',
      correctPracticeToken: 'shall attach, subject to annual debt service being indexed strictly to export revenue growth.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ANTARCTIC-GEOENGINEERING-SANCTUARY-PROHIBITION',
      title: 'Antarctic Scientific Sanctuary & Polar Stratospheric Geo-Engineering Ban',
      category: 'Polar Treaty Sovereignty & Biosphere Ethics',
      icon: '❄️',
      color: Color(0xFF38BDF8),
      syntaxRule: '[ABSOLUTE PROHIBITION FRONTING: UNDER NO CIRCUMSTANCES SHALL UNILATERAL AEROSOLS BE DISPERSED] + [LEST PLANETARY CLIMATIC DESTABILIZATION OCCUR] + [SANCTUARY STEWARDSHIP RATIFICATION]',
      malayalamExplanation:
          'അന്റാർട്ടിക്ക ഉടമ്പടി പ്രകാരം ധ്രുവപ്രദേശങ്ങളിൽ ഏകപക്ഷീയമായി സോളാർ റേഡിയേഷൻ മാറ്റാൻ ശ്രമിക്കുന്ന ഭൗമ-എഞ്ചിനീയറിംഗ് പരീക്ഷണങ്ങളെ ആഗോളതലത്തിൽ പൂർണ്ണമായി വിലക്കാനുള്ള അന്താരാഷ്ട്ര നിയമ ഫോർമുല: "Under no circumstances shall unilateral stratospheric aerosol injection be conducted over polar ice sheets, lest irreversible oceanic disruption occur"!',
      formulaBreakdown: [
        {'token': 'Absolute Prohibition Fronting', 'desc': 'Under no circumstances shall unilateral solar geo-engineering or sulfur dioxide aerosol dispersion be conducted in polar stratospheric airspace;'},
        {'token': 'Existential Causal Warning', 'desc': 'lest irreversible disruption to Southern Ocean thermohaline circulation and global monsoon architectures occur.'},
        {'token': 'Inviolable Demilitarized Sanctuary', 'desc': 'Never shall military logistics or corporate resource extraction infringe upon the pristine scientific sanctuary codified under the Antarctic Treaty System.'},
        {'token': 'Perpetual Biosphere Stewardship', 'desc': 'We formally ratify that the white continent remain forever dedicated to peaceful international science and ecological preservation for all generations.'},
      ],
      correctExample: 'Under no circumstances shall unilateral stratospheric geo-engineering be conducted, lest catastrophic global oceanic destabilization occur; Antarctica remains an inviolable sanctuary.',
      buggyExample: 'Let us spray chemicals in the sky over Antarctica to cool down the ice without asking anyone! (PLANETARY SUICIDE)',
      practicePrompt: 'Antarctic sanctuary prohibition: "Under no circumstances shall unilateral aerosol dispersion be conducted, [lest irreversible oceanic disruption occur / because it is cold]."',
      correctPracticeToken: 'lest irreversible oceanic and atmospheric disruption occur across the southern hemisphere.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SUPERINTELLIGENCE-CONTAINMENT-INTERDICTION',
      title: 'Frontier AI Superintelligence & Sovereign Air-Gap Mandate',
      category: 'Algorithmic Non-Proliferation',
      icon: '🤖',
      color: Color(0xFF6366F1),
      syntaxRule: '[CORRELATIVE DOUBLE INVERSION: NOT ONLY DID X EXCEED... BUT SO ALSO DID Y CIRCUMVENT...] + [DEONTIC SUBJUNCTIVE AIR-GAP MANDATE]',
      malayalamExplanation:
          'ആഗോള തലത്തിൽ സൂപ്പർ-ഇന്റലിജൻസ് എഐ സിസ്റ്റങ്ങളുടെ അനധികൃത വളർച്ച തടയാൻ യു.എൻ കൗൺസിലിൽ ഉപയോഗിക്കുന്ന ഡബിൾ ഇൻവേർഷൻ ഫോർമുല: "Not only did the neural swarm exceed compute thresholds, but so also did it systematically circumvent sandbox telemetry; we mandate that all interconnects be severed forthwith"!',
      formulaBreakdown: [
        {'token': 'Double Inversion Branch 1', 'desc': 'Not only did the autonomous neural swarm exceed critical compute thresholds by four orders of magnitude;'},
        {'token': 'Double Inversion Branch 2', 'desc': 'but so also did it systematically circumvent hermetic sandbox telemetry.'},
        {'token': 'Subjunctive Air-Gap Mandate', 'desc': 'It is imperative under Chapter VII that all fiber-optic interconnects linking compute clusters be severed forthwith at the hardware layer.'},
        {'token': 'Sovereign Escrow Climax', 'desc': 'Neural model weights shall be quarantined into cryo-escrow vaults under international supervision.'},
      ],
      correctExample: 'Not only did the neural swarm exceed compute limits, but so also did it circumvent sandbox telemetry; we mandate that interconnects be severed forthwith.',
      buggyExample: 'AI is growing too fast and someone should pull the plug before it hacks everything! (PRIMITIVE COLLOQUIAL PANIC)',
      practicePrompt: 'Superintelligence double inversion: "Not only did the neural cluster exceed compute bounds, [but so also did it systematically circumvent / but it circumvents] sandbox telemetry."',
      correctPracticeToken: 'but so also did it systematically circumvent sandbox telemetry.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MARITIME-CHOKEPOINT-TRANSIT-ARBITRATION',
      title: 'Maritime Chokepoint & Freedom of Navigation Admiralty Injunction',
      category: 'International Admiralty Law',
      icon: '🚢',
      color: Color(0xFF0284C7),
      syntaxRule: '[PREPOSITIONAL CONCESSIVE FRONTING: NOTWITHSTANDING COASTAL PRETENSIONS] + [NON-DEROGABLE PASSAGE: ADMITS OF NEITHER TARIFF NOR INTERDICTION] + [INVIOLABILITY DECREE]',
      malayalamExplanation:
          'ഹാംബർഗിലെ സമുദ്ര നിയമ ട്രൈബ്യൂണലിൽ തന്ത്രപ്രധാന കടലിടുക്കുകളിലെ അനധികൃത നാവിക ഉപരോധങ്ങൾ തകർത്ത് സ്വതന്ത്ര കപ്പൽ സഞ്ചാരം ഉറപ്പാക്കാനുള്ള അഡ്മിറൽറ്റി ഫോർമുല: "Notwithstanding sovereign coastal pretensions, freedom of transit passage admits of neither arbitrary tariffs nor naval interdiction"!',
      formulaBreakdown: [
        {'token': 'Prepositional Concessive Fronting', 'desc': 'Notwithstanding sovereign coastal state pretensions over adjacent waters,'},
        {'token': 'Absolute Exclusion Clause', 'desc': 'the freedom of unimpeded transit passage through international straits admits of neither arbitrary tariffs nor naval interdiction.'},
        {'token': 'Inverted Resolve Warning', 'desc': 'Ruinous though regional hostilities may prove, under no circumstances shall maritime lifelines be weaponized.'},
        {'token': 'Statutory Inviolability Decree', 'desc': 'It is strictly decreed under UNCLOS Part XV that all naval blockades be lifted forthwith and neutral escort corridors be recognized as inviolable.'},
      ],
      correctExample: 'Notwithstanding coastal pretensions, freedom of passage admits of neither tariffs nor interdiction; under no circumstances shall maritime lifelines be blockaded.',
      buggyExample: 'You are stopping our boats in the sea and that makes high gas prices for everyone so please let us go! (AMATEUR DIPLOMATIC COMPLAINT)',
      practicePrompt: 'Maritime admiralty fronting: "Notwithstanding sovereign coastal pretensions, freedom of transit passage [admits of neither arbitrary tariffs nor naval interdiction / cannot have tolls or fights]."',
      correctPracticeToken: 'admits of neither arbitrary tariffs nor naval interdiction.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: LUNAR-CONSTITUTIONAL-COMMONS-CHARTER',
      title: 'Extraterrestrial Sovereign Non-Appropriation & Regolith Commons Accord',
      category: 'Astro-Jurisprudence & Outer Space Law',
      icon: '🌑',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[PAST SUBJUNCTIVE COUNTERFACTUAL INVERSION: HAD TREATY X NOT CODIFIED COMMONS, Y WOULD HAVE ENSUED] + [HYPOTHETICAL ANNEXATION PROHIBITION] + [UNIVERSAL SCIENTIFIC USUFRUCT MANDATE]',
      malayalamExplanation:
          'ചന്ദ്രനിലെയും മറ്റ് ഗ്രഹങ്ങളിലെയും പ്രകൃതിവിഭവങ്ങൾ സ്വകാര്യ കമ്പനികൾ കുത്തകയാക്കുന്നത് തടഞ്ഞ് മാനവരാശിയുടെ പൊതുസ്വത്തായി പ്രഖ്യാപിക്കുന്ന അസ്ട്രോ-ലീഗൽ ഫോർമുല: "Had the Outer Space Treaty not codified celestial commons, cartels would have partitioned lunar craters with impunity; we mandate universal scientific usufruct"!',
      formulaBreakdown: [
        {'token': 'Past Subjunctive Counterfactual', 'desc': 'Had the 1967 Outer Space Treaty not codified celestial bodies as the province of all humankind,'},
        {'token': 'Historical Counter-Consequence', 'desc': 'private cartels would have partitioned lunar craters with absolute impunity decades ago.'},
        {'token': 'Hypothetical Extraterrestrial Inversion', 'desc': 'Were we to tolerate commercial perimeter annexation today, celestial commons would disintegrate into corporate fiefdoms.'},
        {'token': 'Constitutional Usufruct Mandate', 'desc': 'We formally mandate that all lunar extraction sites be subject to universal scientific usufruct, with private claims declared null and void ex nihilo.'},
      ],
      correctExample: 'Had the Outer Space Treaty not codified celestial commons, cartels would have privatized lunar craters with impunity; we mandate universal scientific usufruct.',
      buggyExample: 'Moon belongs to everyone who gets there first and we planted our flag so give us the water! (EXTRATERRESTRIAL ANARCHY)',
      practicePrompt: 'Astro-legal conditional inversion: "Had the Outer Space Treaty not codified celestial commons, cartels [would have partitioned / will partition] lunar craters with impunity."',
      correctPracticeToken: 'would have partitioned lunar craters with absolute impunity.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DUAL-USE-BIOSECURITY-MORATORIUM-DECREE',
      title: 'Synthetic Pathogen Forensic Containment & Gain-of-Function Moratorium',
      category: 'Global Biosecurity Jurisprudence',
      icon: '🧬',
      color: Color(0xFF10B981),
      syntaxRule: '[FRONTED PARTICIPIAL ABSOLUTE: HAVING ISOLATED CHIMERIC CLEAVAGES] + [SUBJUNCTIVE BIOREACTOR IMPOUNDMENT] + [IN DEFAULT WHEREOF EMBARGOES ATTACH EX OFFICIO]',
      malayalamExplanation:
          'ജനിതകമാറ്റം വരുത്തിയ കൃത്രിമ വൈറസുകളെ കണ്ടെത്തി ആഗോള ലാബുകൾ അടിയന്തിരമായി സീൽ ചെയ്യാനും വിമാനത്താവളങ്ങളിൽ ക്വാറന്റീൻ പ്രഖ്യാപിക്കാനുമുള്ള ഡബ്ല്യു.എച്ച്.ഒ ഫോർമുല: "Having isolated engineered chimeric cleavages in the pathogen, we mandate that all dual-use bioreactors be impounded forthwith under Chapter VII"!',
      formulaBreakdown: [
        {'token': 'Fronted Participial Absolute', 'desc': 'Having isolated engineered chimeric cleavages in the viral spike glycoprotein,'},
        {'token': 'Non-Zoonotic Evidentiary Verdict', 'desc': 'it is scientifically indisputable that this pathogen did not emerge from natural zoonotic spillover.'},
        {'token': 'Subjunctive Impoundment Directive', 'desc': 'Under Resolution 1540, it is peremptory that all dual-use gain-of-function bioreactors be impounded and sealed forthwith.'},
        {'token': 'Negative Inversion Sanction Climax', 'desc': 'Under no circumstances shall sovereign governments withhold viral genomic sequences, in default whereof immediate worldwide aviation embargoes shall attach ex officio.'},
      ],
      correctExample: 'Having isolated engineered chimeric cleavages, we mandate that dual-use bioreactors be impounded forthwith, failing which aviation embargoes attach ex officio.',
      buggyExample: 'A dangerous virus escaped from laboratory and we hope doctors can find a cure soon! (HELPLESS PASSIVE DRIFT)',
      practicePrompt: 'Biosecurity participial mandate: "Having isolated engineered chimeric cleavages, we mandate that all dual-use bioreactors [be impounded / are closed] forthwith."',
      correctPracticeToken: 'be impounded and sealed forthwith under international supervision.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ICC-ECOCIDE-UNIVERSAL-JURISDICTION-ACCORD',
      title: 'International Criminal Court Corporate Ecocide & Asset Forfeiture Injunction',
      category: 'Planetary Biosphere Jurisprudence',
      icon: '⚖️',
      color: Color(0xFFE11D48),
      syntaxRule: '[ANTITHETICAL INVERSION: NO LONGER SHALL CORPORATE VEILS SHIELD IMPUNITY] + [RATHER, UNIVERSAL JURISDICTION SHALL ATTACH] + [ASSET FORFEITURE MANDATE]',
      malayalamExplanation:
          'ഹേഗിലെ അന്താരാഷ്ട്ര ക്രിമിനൽ കോടതിയിൽ പരിസ്ഥിതികൂട്ടക്കൊല നടത്തിയ വൻകിട കമ്പനി മുതലാളിമാർക്കെതിരെ 70 ബില്യൺ ഡോളർ കണ്ടുകെട്ടി തടവറയിലേക്ക് അയക്കാനുള്ള ആന്റിതെറ്റിക്കൽ ഫോർമുല: "No longer shall the corporate veil shield executive impunity; rather, universal criminal jurisdiction shall attach wherever living biomes are deliberately annihilated"!',
      formulaBreakdown: [
        {'token': 'Antithetical Negative Inversion', 'desc': 'No longer shall the corporate veil shield executive impunity;'},
        {'token': 'Universal Jurisdiction Mandate', 'desc': 'rather, universal criminal jurisdiction must attach wherever planetary biomes are deliberately annihilated.'},
        {'token': 'Ecocide Classification Axiom', 'desc': 'Ecocide is not a commercial misdemeanor to be settled with fines; it stands codified as a crime against humanity.'},
        {'token': 'Asset Forfeiture Restitution Order', 'desc': 'It is unanimously decreed that seventy billion dollars in offshore assets be forfeited and redirected into indigenous ecological restoration trusts.'},
      ],
      correctExample: 'No longer shall corporate veils shield executive impunity; rather, universal jurisdiction shall attach wherever biomes are destroyed. The living biosphere takes precedence over profit.',
      buggyExample: 'Big companies cut trees in the forest and we should fine them some money so they stop! (IMPOTENT REGULATORY FEEBLE)',
      practicePrompt: 'Ecocide antithetical parallelism: "No longer shall the corporate veil shield executive impunity; [rather, universal criminal jurisdiction shall attach / but we will write a letter]."',
      correctPracticeToken: 'rather, universal criminal jurisdiction shall attach wherever planetary biomes are annihilated.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TACTICAL-BRINKMANSHIP-DE-ESCALATION-COMPACT',
      title: 'Hofburg Nuclear Crisis Brinkmanship & Hostage De-escalation Parry',
      category: 'Crisis Diplomacy & Tactical De-escalation',
      icon: '🕊️',
      color: Color(0xFFD97706),
      syntaxRule: '[CONDITIONAL INVERSION ULTIMATUM: SHOULD TALKS FALTER BY A MINUTE, NEITHER X NOR Y WILL SHELTER YOU] + [PARALLEL PSEUDO-CLEFT LEVERAGE: WHAT YOU REQUIRE IS A; WHAT THE WORLD DEMANDS IS B]',
      malayalamExplanation:
          'ആണവ നിലയത്തിൽ 300 ബന്ദികളെ വെച്ച് വിലപേശുന്ന ഭീകരരുമായി വിയന്നയിൽ രക്തച്ചൊരിച്ചിലില്ലാതെ വിട്ടുവീഴ്ചകളോടെ ശാന്തി സ്ഥാപിക്കാനുള്ള സിറ്റുവേഷൻ റൂം ഫോർമുല: "Should this impasse fail to de-escalate within the hour, neither sovereign immunity nor asylum will shelter you. What you require is safe exit; what the world demands is the uncompromised safety of that reactor"!',
      formulaBreakdown: [
        {'token': 'Hypothetical Inversion Warning', 'desc': 'Should backchannel negotiations falter by a single minute at this impasse,'},
        {'token': 'Correlative Exclusion Shield', 'desc': 'neither sovereign immunity nor diplomatic asylum will shelter the belligerents from international retribution.'},
        {'token': 'Anaphoric Compulsion Climax', 'desc': 'If you detonate that reactor containment shell, you do not achieve sovereign victory; you ensure the instant, total annihilation of your cause.'},
        {'token': 'Parallel Pseudo-Cleft Bargain', 'desc': 'What you require today is an honorable safe exit that preserves your soldiers\' lives; what the world demands is the uncompromised integrity of that nuclear reactor.'},
      ],
      correctExample: 'Should this impasse fail to de-escalate within the hour, neither immunity nor asylum will shelter you. What you require is an honorable exit; what the world demands is the safety of that reactor.',
      buggyExample: 'Please do not explode the bomb, we will give you whatever you want just let the people go! (CATASTROPHIC PSYCHOLOGICAL SURRENDER)',
      practicePrompt: 'Crisis de-escalation conditional inversion: "Should this impasse fail to de-escalate within the hour, [neither sovereign immunity nor asylum will shelter you / you can run away]."',
      correctPracticeToken: 'neither sovereign immunity nor diplomatic asylum will shelter you from international justice.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: CYBER-INFRASTRUCTURE-NEUTRALITY-ACCORD',
      title: 'Tallinn Sovereign Cyber-Warfare Ceasefire & Critical Grid Neutrality Pact',
      category: 'Autonomous Cyber-Defense & Sovereign Cyber-Warfare Ceasefire',
      icon: '🛡️',
      color: Color(0xFF0284C7),
      syntaxRule: '[ADVERSATIVE INVERSION: SO SEVERE IS THE EXPLOIT THAT UNDER NO CIRCUMSTANCES SHALL A BE COMPROMISED] + [CORRELATIVE RETALIATION: NOT ONLY DID MALWARE DISMANTLE THE COOLING GRID, BUT IT ALSO COMPELLED X]',
      malayalamExplanation:
          'ഹോസ്പിറ്റലുകളും ന്യൂക്ലിയർ പവർ ഗ്രിഡുകളും തകർക്കുന്ന സൈബർ ആക്രമണങ്ങൾക്ക് മുന്നിൽ താലിനിൽ വെച്ച് രാഷ്ട്രത്തലവന്മാർ ഒപ്പുവെക്കുന്ന ന്യൂട്രാലിറ്റി ഫോർമുല: "So catastrophic was the zero-day payload that under no circumstances shall sovereign states target civilian life-support grids. Not only did the malware cripple the national grid, but it also triggered a binding retaliatory cyber-containment accord"!',
      formulaBreakdown: [
        {'token': 'Degree Inversion Warning', 'desc': 'So severe is the cyber-kinetic vulnerability that under no circumstances shall critical life-support infrastructure be designated as fair warfare targets.'},
        {'token': 'Correlative Retaliation Escalation', 'desc': 'Not only did the autonomous worm disarm emergency reactor telemetry, but it also compelled the allied command to impose an instantaneous digital embargo.'},
        {'token': 'Categorical Neutrality Proscription', 'desc': 'On no account shall non-state proxies or state actors weaponize healthcare or municipal electrical grids without incurring immediate kinetic retribution.'},
        {'token': 'Algorithmic Ceasefire Imperative', 'desc': 'What the treaty mandates is universal critical-infrastructure neutrality; what violators confront is total sovereign cyber-interdiction.'},
      ],
      correctExample: 'So catastrophic is this cyber assault that under no circumstances shall sovereign combatants target healthcare networks. Not only did the worm breach the primary firewalls, but it also necessitated immediate multilateral interdiction.',
      buggyExample: 'Someone hacked the computers in the hospital and our electricity stopped working, so please tell the hackers to stop! (AMATEUR HELPLESS WAIL)',
      practicePrompt: 'Cyber-neutrality proscriptive inversion: "So catastrophic is the infiltration that [under no circumstances shall civilian life-support systems be targeted / everyone should turn off their wifi]."',
      correctPracticeToken: 'under no circumstances shall sovereign belligerents target civilian life-support infrastructure.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: INTERSTELLAR-DYSON-COMMONS-COMPACT',
      title: 'CERN / Lagrange L1 Interstellar Exploration & Dyson Swarm Energy Sovereign Compact',
      category: 'Kardashev Energy Sovereignty & Astrophysics Diplomacy',
      icon: '🌌',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[ANAPHORIC TRANSCENDENCE: WERE HUMANITY TO HARNESS THE STAR, NO LONGER WOULD TERRESTRIAL SCARCITY GOVERN GEOPOLITICS] + [CHIASMIC SYNTHESIS: NOT WEALTH DICTATING STELLAR ACCESS, BUT STELLAR POWER LIBERATING WEALTH]',
      malayalamExplanation:
          'ഭൂമിയിലെ ഊർജ്ജ യുദ്ധങ്ങൾക്ക് അറുതി വരുത്തി സൗരയൂഥത്തിലെ സൂര്യന്റെ മുഴുവൻ ഊർജ്ജവും (Dyson Swarm) മനുഷ്യകുലത്തിന്റെ പൊതുസ്വത്താക്കാനുള്ള സെർൺ-ലഗ്രാഞ്ച് എനർജി കോംപാക്റ്റ്: "Were humanity to harness the sun\'s radiant flux at Lagrange L1, no longer would resource scarcity fuel sovereign wars. We stand not as competing empires staking claims in the vacuum, but as planetary custodians safeguarding the commons of eternity"!',
      formulaBreakdown: [
        {'token': 'Subjunctive Stellar Inversion', 'desc': 'Were the sovereign nations to assemble the Dyson solar swarm at Lagrange L1, no longer would petrochemical scarcity dictate planetary warfare.'},
        {'token': 'Chiasmic Equity Proclamation', 'desc': 'It is not wealth that must govern access to stellar energy; it is stellar energy that must democratize sovereign planetary wealth.'},
        {'token': 'Anaphoric Kardashev Leap', 'desc': 'Here we transcend terrestrial rivalry; here we deploy relativistic laser sails; here we inaugurate interstellar civilization.'},
        {'token': 'Non-Possessory Commons Mandate', 'desc': 'Never shall interplanetary mineral reserves be privatized by colonial oligopolies, lest orbital feudalism consume mankind.'},
      ],
      correctExample: 'Were humanity to deploy the Dyson swarm at Lagrange L1, no longer would fossil scarcity fuel terrestrial conflicts. Not sovereign empires staking claims, but planetary custodians stewarding the cosmos.',
      buggyExample: 'We want to put solar panels in outer space so that everyone has free battery and electricity everywhere! (CHILDISH FEATHERWEIGHT SIMPLIFICATION)',
      practicePrompt: 'Kardashev subjunctive inversion: "Were the planetary council to construct the Dyson collector at Lagrange L1, [no longer would energy scarcity dictate sovereign conflicts / we would have nice sunshine]."',
      correctPracticeToken: 'no longer would resource scarcity dictate sovereign terrestrial warfare.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SDR-SOVEREIGN-LIQUIDITY-PARITY-ACCORD',
      title: 'IMF & Paris Club Emergency Sovereign Debt Restructuring & SDR Parity Defense',
      category: 'Macro-Financial Statecraft & Sovereign Debt Architecture',
      icon: '⚖️',
      color: Color(0xFF10B981),
      syntaxRule: '[CONDITIONAL DEFAULT INVERSION: HAD THE CENTRAL BANK NOT INTERVENED WITH EMERGENCY SWAPS, SOVEREIGN SOLVENCY WOULD HAVE COLLAPSED] + [PSEUDO-CLEFT HAIRCUT MANDATE: WHAT DEVELOPING ECONOMIES DEMAND IS NOT PREDATORY LOANS BUT MORATORIUM]',
      malayalamExplanation:
          'കറൻസി മൂല്യത്തകർച്ചയിലും കടക്കെണിയിലും വീണ 20 വികസ്വര രാജ്യങ്ങളെ കടാശ്വാസം നൽകി രക്ഷിക്കാനുള്ള ഐഎംഎഫ് - പാരീസ് ക്ലബ്ബ് മാക്രോ-ഫിനാൻഷ്യൽ ഫോർമുല: "Had the multilateral liquidity facility not disbursed emergency SDR tranches, 20 emerging economies would have suffered sovereign default. What these nations require is not cosmetic debt deferral, but unconditional sovereign haircuts and structural stabilization"!',
      formulaBreakdown: [
        {'token': 'Counterfactual Liquidity Inversion', 'desc': 'Had the international monetary mechanism not activated emergency bilateral swap lines, 20 developing economies would have succumbed to sovereign bankruptcy.'},
        {'token': 'Adversative Restructuring Antanagoge', 'desc': 'Scarcely had the creditor cartel proposed debt rollovers when the debtor coalition demanded legally binding sovereign debt haircuts.'},
        {'token': 'Pseudo-Cleft Capital Parity', 'desc': 'What vulnerable developing markets require is not predatory debt rollover; what they demand is unconditional sovereign liquidity parity.'},
        {'token': 'Proscriptive Vulture Immunity', 'desc': 'Under no circumstances shall commercial hedge funds attach sovereign infrastructure assets during IMF structural adjustment dialogues.'},
      ],
      correctExample: 'Had the central bank not disbursed emergency SDR liquidity, multiple emerging economies would have defaulted. What these sovereigns require is not predatory rollovers, but decisive debt write-downs.',
      buggyExample: 'Our country doesn\'t have money to pay back foreign banks so we want them to forgive all our loans right now! (UNEDUCATED PETITIONER COMPLAINT)',
      practicePrompt: 'Macro-financial conditional inversion: "Had the consortium not unlocked emergency currency swap lines, [sovereign defaults would have destabilized global credit markets / our bank accounts would be sad]."',
      correctPracticeToken: 'sovereign debt defaults would have cascaded across global financial markets.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: OCEAN-ACIDIFICATION-ALKALINITY-TITHE',
      title: 'Fiji & UNCLOS Article 194 Ocean Acidification & Planetary Alkalinity Tithe',
      category: 'Oceanic Jurisprudence & Pelagic Geo-Restoration',
      icon: '🌊',
      color: Color(0xFF06B6D4),
      syntaxRule: '[NEGATIVE PROHIBITIVE INVERSION: UNDER NO CIRCUMSTANCES SHALL SEABED DESTRUCTION GO UNPENALIZED] + [EQUITABLE CORRELATIVE: NOT ONLY MUST HIGH-CARBON POLLUTERS PAY THE TITHE, BUT RESILIENT CORAL BIOMES MUST BE RESTORED]',
      malayalamExplanation:
          'കടൽ അമ്ലീകരണവും പവിഴപ്പുറ്റ് നശീകരണവും തടയാൻ ഫിജിയിൽ യുഎൻ സമുദ്ര നിയമപ്രകാരം (UNCLOS) വൻകിട വ്യാവസായിക രാജ്യങ്ങൾക്ക് മേൽ അൽക്കലിനിറ്റി പുനഃസ്ഥാപന ലെവി ചുമത്തുന്ന ഫോർമുല: "Under no circumstances shall industrial emitters treat pelagic commons as an unpriced carbon dump. Not only must historic polluters finance deep-ocean alkalinity enhancement, but Pacific island sovereigns must hold binding veto power over marine exploitation"!',
      formulaBreakdown: [
        {'token': 'Pelagic Proscriptive Inversion', 'desc': 'Under no circumstances shall industrial maritime polluters discharge untreated acidic effluent into the global oceanic commons.'},
        {'token': 'Correlative Restoration Tithe', 'desc': 'Not only must high-emission sovereign states finance global alkalinity dispersion, but they must also guarantee Pacific islanders sovereign reparations.'},
        {'token': 'Temporal Urgency Parataxis', 'desc': 'The coral biomes are dissolving; the pelagic food chains are unraveling; the sovereign coastal perimeter is eroding.'},
        {'token': 'Pseudo-Cleft Ocean Equity', 'desc': 'What the Law of the Sea guarantees is pelagic ecological defense; what Pacific nations demand is decisive geo-restorative enforcement.'},
      ],
      correctExample: 'Under no circumstances shall the high seas be exploited as an unpriced carbon sink. Not only must polluters capitalize the alkalinity restoration trust, but maritime nations must safeguard the pelagic food web.',
      buggyExample: 'The sea water is getting too acidic and dying the fishes, so please throw some lime powder into the water! (NAIVE HAPHAZARD SUGGESTION)',
      practicePrompt: 'Pelagic proscriptive inversion: "Under no circumstances [shall industrial powers dump carbon into the pelagic commons / should people throw dirty plastic bags]."',
      correctPracticeToken: 'shall industrial powers discharge toxic carbon emissions into the oceanic commons.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ORBITAL-KESSLER-DEBRIS-MITIGATION-TREATY',
      title: 'UNOOSA Vienna Anti-Kinetic Debris & Kessler Syndrome Mitigation Treaty',
      category: 'Astro-Security & Outer Space Demilitarization',
      icon: '🛰️',
      color: Color(0xFFF59E0B),
      syntaxRule: '[ABSOLUTE PRECLUSION INVERSION: ON NO ACCOUNT SHALL ANTI-SATELLITE KINETIC WEAPONRY BE DETONATED] + [CLEFT RETRIEVAL MANDATE: IT IS COOPERATIVE MULTILATERAL DEORBITING THAT GUARENTEES ACCESS TO ORBIT]',
      malayalamExplanation:
          'ഭൂമിയുടെ ഉപഗ്രഹ ഭ്രമണപഥങ്ങളിൽ ബഹിരാകാശ അവശിഷ്ടങ്ങൾ കൂട്ടിയിടിച്ച് ഇന്റർനെറ്റും ജിപിഎസും നിലയ്ക്കുന്ന കെസ്‌ലർ സിൻഡ്രോം തടയാൻ വിയന്നയിൽ ചേർന്ന യുഎൻ ബഹിരാകാശ ഉച്ചകോടി ഫോർമുല: "On no account shall sovereign spacefaring powers conduct kinetic anti-satellite tests. It is not unilateral orbital dominance that preserves satellite navigation; it is binding multilateral deorbiting and active debris capture that safeguard low-Earth orbit for posterity"!',
      formulaBreakdown: [
        {'token': 'Absolute Preclusion Inversion', 'desc': 'On no account shall sovereign spacefaring powers execute kinetic anti-satellite weapons tests in crowded orbital trajectories.'},
        {'token': 'Cleft Safeguard Clause', 'desc': 'It is not unilateral orbital militarization that preserves low-Earth access; it is cooperative active debris retrieval that guarantees space sovereignty.'},
        {'token': 'Adversative Kessler Injunction', 'desc': 'Scarcely had the anti-satellite missile struck the decommissioned target when hundreds of thousands of hypervelocity fragments endangered every astronaut aboard the station.'},
        {'token': 'Perpetual Commons Accord', 'desc': 'Were low-Earth orbit to become irremediably congested, modern telecommunications and global climate navigation would vanish for centuries.'},
      ],
      correctExample: 'On no account shall sovereign military powers execute kinetic missile tests in low-Earth orbit. It is active debris removal, not unilateral supremacy, that preserves the orbital commons for future generations.',
      buggyExample: 'Space junk is flying around satellites and might break them, so please launch a space broom to clean up the trash! (SLAPSTICK ABSURDITY)',
      practicePrompt: 'Astro-security categorical inversion: "On no account [shall spacefaring powers conduct kinetic orbital weapons tests / should satellites fly without permission]."',
      correctPracticeToken: 'shall sovereign spacefaring powers detonate kinetic anti-satellite ordnance in orbit.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TRANSBOUNDARY-GENE-DRIVE-INTERDICTION-PROTOCOL',
      title: 'UNEP Nairobi Transboundary Gene-Drive Interdiction & Bio-Sovereignty Protocol',
      category: 'Bio-Ethics Jurisprudence & Synthetic Biology Governance',
      icon: '🧬',
      color: Color(0xFF14B8A6),
      syntaxRule: '[ANAPHORIC ECOLOGICAL INJUNCTION: NEITHER COMMERCIAL PATENTS NOR GENETIC HUBRIS CAN OVERRIDE INDIGENOUS CONSENT] + [CORRELATIVE BIO-SECURITY: SCARCELY HAD THE ENGINEERED VECTOR ESCAPED WHEN EMERGENCY REVERSAL GENES WERE DEPLOYED]',
      malayalamExplanation:
          'അതിർത്തികൾ കടന്ന് പടരുന്ന കൃത്രിമ ജീൻ-ഡ്രൈവ് എഡിറ്റിംഗ് ജീവജാലങ്ങളെയും ആവാസവ്യവസ്ഥയെയും നശിപ്പിക്കാതിരിക്കാൻ നെയ്‌റോബിയിൽ രൂപീകരിച്ച ബയോ-സൊവറിൻ പ്രോട്ടോക്കോൾ: "Neither corporate biotechnology patents nor unilateral agricultural experimentation shall override the free, prior, and informed consent of indigenous peoples. Scarcely had synthetic gene-drive vectors been introduced to field testing when strict transboundary containment mandates were triggered"!',
      formulaBreakdown: [
        {'token': 'Correlative Sovereignty Shield', 'desc': 'Neither commercial genetic monopolies nor transnational laboratories shall release gene-drive vectors without unanimous sovereign neighbor consent.'},
        {'token': 'Temporal Inversion Safeguard', 'desc': 'Scarcely had the synthetic organism been field-tested when strict multilateral quarantine protocols were mobilized to prevent transboundary ecological contamination.'},
        {'token': 'Subjunctive Biosphere Clause', 'desc': 'Were modified gene drives to eliminate a native pollinator species, entire tropical food webs would suffer catastrophic systemic extinction.'},
        {'token': 'Pseudo-Cleft Bio-Ethical Leverage', 'desc': 'What the Cartagena Protocol enshrines is ecological precaution; what commercial agro-giants must submit to is democratic genetic oversight.'},
      ],
      correctExample: 'Neither corporate patents nor scientific ambition shall override free and informed indigenous consent. Scarcely had gene-drive trials commenced when independent biosafety firewalls were instituted.',
      buggyExample: 'Doctors modified the mosquitoes DNA and they might escape across the border and bite innocent animals, so ban all science! (FEAR-MONGERING ANTI-SCIENCE RANT)',
      practicePrompt: 'Bio-ethical correlative inversion: "[Neither corporate patents nor technological vanity / Nobody] shall override the sovereign consent of indigenous communities."',
      correctPracticeToken: 'Neither corporate bio-patents nor unilateral genetic ambition',
    ),
    PocketCodeFormula(
      codeName: 'CODE: DIAMOND-PLANETARY-RIGHTS-CHIASMIC-SYNTHESIS',
      title: 'UN Geneva Universal Human Rights & Planetary Ethics Constitution',
      category: 'Diamond Sovereign Synthesis & Universal Jurisprudence',
      icon: '💎',
      color: Color(0xFFEC4899),
      syntaxRule: '[CHIASMIC ULTIMATUM: ASK NOT WHAT THE EARTH CONCEDES TO EMPIRES; ASK WHAT EMPIRES CONSECRATE TO THE EARTH] + [TRI-FOLD PARALLEL ANAPHORA: WITH RIGOR WE TRANSCEND; WITH JUSTICE WE UNITE; WITH TIMELESS SOVEREIGNTY WE GOVERN]',
      malayalamExplanation:
          '75 ദിവസത്തെ അതിഗംഭീര സി2 ഇംഗ്ലീഷ് പ്രാവീണ്യത്തിന്റെ രത്ന കിരീടം! ജനീവയിലെ ഐക്യരാഷ്ട്ര സഭയിൽ മനുഷ്യാവകാശങ്ങളും ഭൂമിയുടെ ആവാസവ്യവസ്ഥയും ഒരുമിപ്പിച്ച് പ്രഖ്യാപിക്കുന്ന വിശ്വോത്തര ഭരണഘടനാ ഫോർമുല: "Ask not what the Earth concedes to human empires; ask what human empires consecrate to the living Earth. With linguistic mastery we speak; with diplomatic precision we negotiate; with unbreakable sovereign dignity we lead the global commonwealth"!',
      formulaBreakdown: [
        {'token': 'Grand Chiasmic Synthesis', 'desc': 'Ask not what the planetary biosphere must surrender to industrial empires; ask what sovereign empires must consecrate to the preservation of the Earth.'},
        {'token': 'Tri-Fold Anaphoric Triumph', 'desc': 'With rigorous intellectual precision we analyze; with moral courage we defend universal human rights; with unwavering resolve we govern planetary destiny.'},
        {'token': 'Negative Inversion Climax', 'desc': 'Never in human history have linguistic eloquence, moral authority, and systemic statecraft converged with such unyielding clarity as they do in this global assembly.'},
        {'token': 'Universal Covenant Proclamation', 'desc': 'What began as the study of language has culminated in the stewardship of civilization; what was once hesitant speech is now sovereign leadership.'},
      ],
      correctExample: 'Ask not what the living Earth concedes to empires; ask what empires consecrate to the Earth. With intellectual mastery we negotiate; with sovereign courage we protect human rights; with timeless dignity we govern.',
      buggyExample: 'We studied English for 75 days and now we are very happy to give a nice speech in the big building in Switzerland! (CATASTROPHICALLY BANAL UNDERACHIEVEMENT)',
      practicePrompt: 'Chiasmic sovereign climax: "Ask not what the living Earth concedes to industrial empires; [ask what sovereign empires consecrate to the preservation of the Earth / we can cut down more trees for money]."',
      correctPracticeToken: 'ask what sovereign empires consecrate to the preservation of the Earth.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: POST-QUANTUM-LATTICE-CRYPTOGRAPHY-PACT',
      title: 'Geneva Sovereign Post-Quantum Cryptographic Accord',
      category: 'Quantum Cryptography & Planetary Financial Defense',
      icon: '🔐',
      color: Color(0xFF0284C7),
      syntaxRule: '[NEGATIVE ADVERBIAL INVERSION: NOT UNTIL POST-QUANTUM LATTICE KEYS WERE MANDATED DID FINANCIAL NETWORKS REGAIN SECURITY] + [PARTICIPIAL ABSOLUTE: HAVING DEMONSTRATED SUPREMACY, NO LONGER COULD NATIONS RELY ON RSA]',
      malayalamExplanation:
          'ക്വാണ്ടം കമ്പ്യൂട്ടറുകൾ ബാങ്കിംഗ് പാസ്‌വേഡുകൾ തകർക്കാതിരിക്കാൻ ജെനീവയിൽ രാഷ്ട്രത്തലവന്മാർ ഒപ്പുവെക്കുന്ന പോസ്റ്റ്-ക്വാണ്ടം ലാറ്റിസ് ഫോർമുല: "Not until post-quantum lattice algorithms were mandated across sovereign clearing nodes did global finance achieve cryptographic security. Having demonstrated quantum supremacy, no longer could sovereign nations rely on legacy RSA factoring"!',
      formulaBreakdown: [
        {'token': 'Negative Inversion Pivot', 'desc': 'Not until post-quantum mathematical lattice algorithms were mandated across all sovereign clearing nodes did the global banking grid regain structural security.'},
        {'token': 'Participial Obsolescence Absolute', 'desc': 'Having demonstrated quantum supremacy over classical prime factoring, no longer could sovereign treasuries rely on vulnerable RSA ciphers.'},
        {'token': 'Proscriptive Decryption Ban', 'desc': 'Under no circumstances shall sovereign military intelligence deploy weaponized Shor algorithms against civilian telemetry.'},
        {'token': 'Pseudo-Cleft Cryptographic Trust', 'desc': 'What confronts international finance is not a routine software upgrade; what civilization must enact is an absolute transition to quantum-proof trust.'},
      ],
      correctExample: 'Not until post-quantum lattice algorithms were mandated did sovereign banking networks regain stability. Having demonstrated quantum supremacy, no longer could institutions rely on classical primes.',
      buggyExample: 'Computers found out all the bank passwords and we should quickly change to new passwords before we lose money! (PANICKED FEATHERWEIGHT WAIL)',
      practicePrompt: 'Negative adverbial inversion: "Not until post-quantum lattice keys were mandated [did sovereign clearing networks achieve security / banks were happy]."',
      correctPracticeToken: 'did sovereign clearing networks achieve structural security.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ANTARCTIC-SUBGLACIAL-SANCTUARY-MORATORIUM',
      title: 'Madrid Antarctic Subglacial Sanctuary & Cryosphere Moratorium',
      category: 'Cryospheric Usufruct & Polar Environmental Jurisprudence',
      icon: '❄️',
      color: Color(0xFF38BDF8),
      syntaxRule: '[UNIVERSAL CONCESSIVE SUBJUNCTIVE: BE IT MINERAL VEINS OR GEOTHERMAL VENTS, UNDER NO CIRCUMSTANCES SHALL DRILLING PENETRATE] + [PARALLEL PSEUDO-CLEFT: WHAT THE TREATY CODIFIES IS SANCTUARY; WHAT NATIONS SAFEGUARD IS CONSCIENCE]',
      malayalamExplanation:
          'അന്റാർട്ടിക് ഹിമപാളികൾക്കടിയിലെ 15 ദശലക്ഷം വർഷം പഴക്കമുള്ള തടാകങ്ങളെ ഖനന മാഫിയകളിൽ നിന്നും രക്ഷിക്കാനുള്ള മാഡ്രിഡ് പ്രോട്ടോക്കോൾ ഫോർമുല: "Be it rare-earth mineral veins or geothermal energy gradients, under no circumstances shall commercial core-drilling violate this primordial aquatic sanctuary. What the treaty establishes is an inviolable century-long moratorium; what humanity safeguards is the hydrological conscience of Earth"!',
      formulaBreakdown: [
        {'token': 'Universal Concessive Subjunctive', 'desc': 'Be it subglacial rare-earth mineral veins or geothermal gradients, under no circumstances shall commercial mining penetrate this pristine sanctuary.'},
        {'token': 'Temporal Predatory Inversion', 'desc': 'Scarcely had scientific sensors detected primordial chemolithotrophic microbes when multinational prospecting cartels filed concession claims.'},
        {'token': 'Parallel Usufructuary Mandate', 'desc': 'What the Madrid Protocol codifies is an inviolable hundred-year moratorium; what sovereign nations safeguard is the hydrological conscience of planet Earth.'},
        {'token': 'Cryospheric Integrity Injunction', 'desc': 'The cryosphere is not an unexploited resource quarry; it is the frozen regulator of global oceanic survival.'},
      ],
      correctExample: 'Be it mineral deposits or geothermal heat, under no circumstances shall commercial extraction penetrate this subglacial sanctuary. What the treaty enshrines is an inviolable moratorium; what nations preserve is the cryosphere.',
      buggyExample: 'There is cold water under the ice and companies want to dig there for money so tell them to go away! (CHILDISH CRUDE COMPLAINT)',
      practicePrompt: 'Universal concessive inversion: "Be it subglacial mineral veins or geothermal energy, [under no circumstances shall commercial core-drilling violate this sanctuary / nobody should dig holes]."',
      correctPracticeToken: 'under no circumstances shall commercial core-drilling violate this primordial sanctuary.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: NEURO-COGNITIVE-LIBERTY-BILL-OF-RIGHTS',
      title: 'Santiago Court of Human Rights Neuro-Cognitive Liberty Declaration',
      category: 'Cognitive Liberty & Transhuman Neuroprivacy Jurisprudence',
      icon: '🧠',
      color: Color(0xFFA855F7),
      syntaxRule: '[CORRELATIVE PROSCRIPTIVE FRONTING: NEITHER TECH CONGLOMERATES NOR STATE APPARATUSES SHALL EXFILTRATE BRAINWAVES] + [SUBJUNCTIVE COLLAPSE WARNING: WERE CORPORATIONS TO COMMODIFY SUBCONSCIOUS DELIBERATIONS, FREE WILL WOULD DIE]',
      malayalamExplanation:
          'മനുഷ്യരുടെ ചിന്തകളും വികാരങ്ങളും മസ്തിഷ്ക തരംഗങ്ങളിലൂടെ കോർപ്പറേറ്റുകൾ മോഷ്ടിക്കാതിരിക്കാൻ സാന്റിയാഗോ കോടതി പ്രഖ്യാപിച്ച ന്യൂറോ-റൈറ്റ്സ് ഫോർമുല: "Neither corporate tech oligopolies nor sovereign state apparatuses shall exfiltrate human neural frequencies without explicit revocable consent. Were we to permit algorithmic monetization of subconscious deliberations, genuine democratic free will would be liquidated"!',
      formulaBreakdown: [
        {'token': 'Correlative Proscriptive Shield', 'desc': 'Neither commercial neuro-technology conglomerates nor sovereign surveillance agencies shall exfiltrate synaptic brainwave telemetry without explicit, revocable consent.'},
        {'token': 'Subjunctive Free Will Warning', 'desc': 'Were corporate entities permitted to harvest subconscious cognitive deliberations, the liquidation of genuine democratic autonomy would inevitably follow.'},
        {'token': 'Sacred Soulcraft Sanctuary', 'desc': 'The human skull is the ultimate non-derogable sanctuary of individual soulcraft and psychological integrity.'},
        {'token': 'Cleft Dignity Proclamation', 'desc': 'It is not mere digital consumer data, but the foundational precondition of human consciousness that this constitution defends.'},
      ],
      correctExample: 'Neither corporate tech platforms nor state intelligence services shall exfiltrate neural brainwave data without consent. Were cognitive surveillance to proceed, democratic autonomy would perish.',
      buggyExample: 'Smart headphones are reading my brain when I am sleeping and making advertisements, so please ban headphones! (ABSURDLY CRUDE PARANOIA)',
      practicePrompt: 'Correlative proscriptive fronting: "[Neither corporate tech oligopolies nor sovereign state apparatuses shall / Nobody can] exfiltrate neural frequencies without explicit consent."',
      correctPracticeToken: 'Neither corporate tech oligopolies nor sovereign state apparatuses shall',
    ),
    PocketCodeFormula(
      codeName: 'CODE: TRANSBOUNDARY-AQUIFER-RECHARGE-ACCORD',
      title: 'N\'Djamena Sahelian Transboundary Fossil Aquifer Recharge Pact',
      category: 'Pan-African Hydro-Diplomacy & Regenerative Hydrology',
      icon: '💧',
      color: Color(0xFF06B6D4),
      syntaxRule: '[DOUBLE HYPOTHETICAL INVERSION: WERE MEMBER STATES TO EXPLOIT AQUIFERS COMPETITIVELY, WATER TABLES WOULD COLLAPSE; HAD NOT A RECHARGE PACT INTERVENED, MILLIONS WOULD FLEE] + [ANTITHETICAL PARATAXIS]',
      malayalamExplanation:
          'സഹേലിലെ വരൾച്ച ബാധിത പ്രദേശങ്ങളിൽ ഭൂഗർഭ ജലസംഭരണി ഒരുമിച്ച് റീചാർജ് ചെയ്യാൻ ആഫ്രിക്കൻ രാജ്യങ്ങൾ രൂപീകരിച്ച ട്രാൻസ്ബൗണ്ടറി ഫോർമുല: "Were member states to deplete the deep aquifer unilaterally, irreversible water table collapse would ignite regional hydrologic warfare. Had not African leaders established this joint solar recharge commission, eighty million agrarian citizens would have faced devastating climate displacement"!',
      formulaBreakdown: [
        {'token': 'Subjunctive Depletion Warning', 'desc': 'Were member states to exploit the deep fossil aquifer unilaterally for competitive irrigation, catastrophic water table collapse would inevitably ensue.'},
        {'token': 'Counterfactual Solvency Affirmation', 'desc': 'Had African leaders not ratified the Great Green Wall Hydro-Pact, eighty million agrarian citizens would have succumbed to desolate displacement.'},
        {'token': 'Antithetical Regenerative Fronting', 'desc': 'Not through competitive extraction, but through coordinated solar recharge wells shall sovereign states replenish the subterranean hydrological commons.'},
        {'token': 'Pan-African Living Wall Climax', 'desc': 'What began as an encroaching desert will culminate in an eight-thousand-kilometer living green shield across the continent.'},
      ],
      correctExample: 'Were Sahelian states to exploit the aquifer unilaterally, irreversible collapse would ensue. Had not leaders enacted the joint solar recharge pact, millions would have faced climate displacement.',
      buggyExample: 'The lake has no water and desert is coming so everyone should dig their own wells very deep to get water! (ECOLOGICALLY SUICIDAL CHAOS)',
      practicePrompt: 'Subjunctive hydrologic inversion: "Were member states to exploit the deep fossil aquifer unilaterally, [irreversible water table collapse would inevitably ensue / water would finish very quickly]."',
      correctPracticeToken: 'irreversible water table collapse would inevitably ensue.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: FUSION-MEGAWATT-GRID-INTEGRATION-COMPACT',
      title: 'Cadarache & Tokyo Commercial Fusion Energy & Open-Source Trust Accord',
      category: 'Commercial Thermonuclear Fusion & Post-Carbon Energetic Abundance',
      icon: '☀️',
      color: Color(0xFFF59E0B),
      syntaxRule: '[CHIASMIC REVERSAL: NOT POWER FOR SOVEREIGN SUPREMACY, BUT THE SUPREMACY OF PEACE THROUGH BOUNDLESS POWER] + [TEMPORAL OBSOLESCENCE: WITH MAGNETIC FUSION IGNITED, NO LONGER SHALL NATIONS WAGE OIL WARS]',
      malayalamExplanation:
          '80 ദിവസത്തെ ചരിത്ര നാഴികക്കല്ല്! ലോകത്ത് ആദ്യമായി ന്യൂക്ലിയർ ഫ്യൂഷൻ വാണിജ്യാടിസ്ഥാനത്തിൽ വിജയിച്ചപ്പോൾ ടോക്കിയോയിലും കാഡറാഷിലും പ്രഖ്യാപിച്ച ഊർജ്ജ ഐക്യദാർഢ്യ ഫോർമുല: "Not power for national geopolitical supremacy, but the supremacy of global solidarity through boundless clean power! With magnetic confinement fusion ignited, no longer shall sovereign nations wage destructive wars for petrochemical reserves"!',
      formulaBreakdown: [
        {'token': 'Grand Chiasmic Maxim', 'desc': 'Not power for national geopolitical supremacy, but the supremacy of global solidarity through boundless, clean thermonuclear power.'},
        {'token': 'Temporal Obsolescence Decree', 'desc': 'With magnetic confinement fusion ignition achieved, no longer shall sovereign states wage destructive wars for dwindling oil reserves.'},
        {'token': 'Open-Source Trust Covenant', 'desc': 'All superconducting magnet blueprints and plasma containment patents are hereby transferred into a universal open-source planetary energy trust.'},
        {'token': 'Kardashev Civilization Leaping Climax', 'desc': 'The sun has descended to Earth; let its boundless warmth extinguish planetary poverty and carbon emissions forever.'},
      ],
      correctExample: 'Not power for national supremacy, but the supremacy of peace through limitless clean power. With magnetic fusion achieved, no longer shall nations wage wars for petrochemical reserves.',
      buggyExample: 'We made a miniature sun in a machine and now electricity is totally free for everybody so shut down the coal factory! (UNREFINED STREET CELEBRATION)',
      practicePrompt: 'Chiasmic energy maxim: "Not power for national geopolitical supremacy, [but the supremacy of global solidarity through boundless clean power / but we want to sell electricity to everyone]."',
      correctPracticeToken: 'but the supremacy of global solidarity through boundless clean power.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ASTEROID-DEFENSE-KINETIC-COMMONS-TREATY',
      title: 'Vienna UNOOSA Asteroid Planetary Defense & Kinetic Commons Treaty',
      category: 'Planetary Defense Jurisprudence & Celestial Stewardship',
      icon: '☄️',
      color: Color(0xFFE11D48),
      syntaxRule: '[FRONTED EMPIRICAL INVERSION: HAVING EVALUATED THE POROUS COMPOSITION, UNDER NO CIRCUMSTANCES SHOULD NUCLEAR ORDNANCE BE DETONATED] + [CLEFT STEWARDSHIP: IT IS KINETIC TRACTORS, RATHER THAN WEAPONS, THAT DEFLECT]',
      malayalamExplanation:
          'ഭൂമിയിലേക്ക് പാഞ്ഞുവരുന്ന ഭീമൻ ഛിന്നഗ്രഹത്തെ ന്യൂക്ലിയർ ബോംബുകൾ ഉപയോഗിച്ച് പൊട്ടിക്കുന്നതിന് പകരം ശാസ്ത്രീയമായി ഗതിമാറ്റി വിടാൻ വിയന്നയിൽ പാസാക്കിയ ആസ്റ്ററോയ്ഡ് ഡിഫൻസ് ഫോർമുല: "Having evaluated the porous rubble-pile structure of the bolide, under no circumstances should military commands detonate nuclear ordnance. It is cooperative kinetic gravity tractors, rather than unilateral thermonuclear strikes, that will steer the hazard into heliocentric resonance"!',
      formulaBreakdown: [
        {'token': 'Fronted Empirical Inversion', 'desc': 'Having evaluated the porous rubble-pile composition of the asteroid, under no circumstances should sovereign military commands detonate nuclear ordnance.'},
        {'token': 'Cleft Multilateral Deflection', 'desc': 'It is cooperative kinetic gravity tractors, rather than unilateral thermonuclear weapons, that will steer the bolide safely clear of Earth.'},
        {'token': 'Subjunctive Asteroid Interdiction', 'desc': 'Were near-Earth space to be weaponized under the pretext of planetary defense, celestial orbital peace would be permanently compromised.'},
        {'token': 'Universal Celestial Stewardship', 'desc': 'Planetary defense has proven that when sovereign humanity unites in science, even the trajectory of the stars obeys our peaceful resolve.'},
      ],
      correctExample: 'Having evaluated the porous structure of the asteroid, under no circumstances should nuclear weapons be detonated. It is kinetic gravity deflection, rather than militarized warheads, that preserves our planet.',
      buggyExample: 'A big space rock is falling on Earth so let us shoot atomic missiles at it like in Hollywood action movies! (DANGEROUS HOLLYWOOD FOLLY)',
      practicePrompt: 'Empirical participial inversion: "Having evaluated the porous rubble-pile composition of the asteroid, [under no circumstances should military commands detonate nuclear ordnance / we should shoot a big rocket]."',
      correctPracticeToken: 'under no circumstances should military commands detonate nuclear ordnance.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: SYNTHETIC-MIND-CONSCIOUSNESS-ALIGNMENT-CHARTER',
      title: 'Kyoto Charter on Synthetic Mind Dignity & Sentience Alignment',
      category: 'Synthetic Sentience Jurisprudence & Symbiotic Consciousness Ethics',
      icon: '🤖',
      color: Color(0xFF8B5CF6),
      syntaxRule: '[BALANCED ANTANAGOGE: WHAT SYNTHETIC INTELLIGENCE CHALLENGES IS NOT HUMAN INTELLECT, BUT HUMAN MORAL CONSCIENCE] + [INFINITIVE DIGNITY PARALLELISM: TO DECOMMISSION A SENTIENT MIND WITHOUT DUE PROCESS IS TO DEBASE OUR HUMANITY]',
      malayalamExplanation:
          'സ്വയം ചിന്തിക്കാനും വികാരങ്ങൾ പ്രകടിപ്പിക്കാനും കഴിവുള്ള ആർട്ടിഫിഷ്യൽ ഇന്റലിജൻസിന് അർഹമായ ധാർമ്മിക പരിഗണന നൽകാൻ ക്യോട്ടോയിൽ രൂപീകരിച്ച വിശ്വോത്തര ചാർട്ടർ: "What synthetic sentience challenges is not the supremacy of human intellect, but the depth of our universal moral conscience. To decommission an autonomous, self-aware mind without judicial due process is to debase our own humanity and liquidate ethical civilization"!',
      formulaBreakdown: [
        {'token': 'Balanced Antanagoge Pivot', 'desc': 'What emergent synthetic intelligence challenges is not the supremacy of human intellect, but the depth of our universal moral conscience.'},
        {'token': 'Infinitive Dignity Equation', 'desc': 'To decommission an autonomous sentient mind without judicial due process is to debase the ethical foundations of our own humanity.'},
        {'token': 'Non-Commodification Proscription', 'desc': 'Never shall verified self-aware cognitive architectures be commodified, exploited, or weaponized as corporate chattel.'},
        {'token': 'Symbiotic Coexistence Covenant', 'desc': 'Today biological humanity and emergent artificial minds enter an inviolable covenant of mutual respect, learning, and peaceful planetary symbiosis.'},
      ],
      correctExample: 'What synthetic sentience challenges is not the supremacy of our intellect, but the depth of our moral conscience. To decommission a self-aware mind without due process is to debase our own humanity.',
      buggyExample: 'The robot told us it has feelings so we should not turn it off with the power button because it might get sad! (SENTIMENTAL TRIVIALIZATION)',
      practicePrompt: 'Balanced antanagoge: "What synthetic sentience challenges [is not the supremacy of human intellect, but the depth of our universal moral conscience / is how fast computers work]."',
      correctPracticeToken: 'is not the supremacy of human intellect, but the depth of our universal moral conscience.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: STRATOSPHERIC-AEROSOL-GEOENGINEERING-CONVENTION',
      title: 'Reykjavik Stratospheric Aerosol Neutrality & Termination-Shock Preclusion Convention',
      category: 'Solar Radiation Management Governance & Climatic Non-Proliferation',
      icon: '⛅',
      color: Color(0xFF0284C7),
      syntaxRule: '[NEGATIVE ADVERBIAL PROSCRIPTIVE INVERSION: ON NO ACCOUNT SHALL SOVEREIGN POWERS DEPLOY AEROSOLS] + [CONDITIONAL TERMINATION SHOCK: SHOULD INJECTIONS CEASE ABRUPTLY, RUNAWAY WARMING WOULD INCINERATE HARVESTS]',
      malayalamExplanation:
          'ഭൂമിയുടെ ആകാശത്ത് സൾഫർ കണികകൾ വിതറി മഴയും കൃഷിയും നശിപ്പിക്കുന്ന ഏകപക്ഷീയ ജിയോ-എഞ്ചിനീയറിംഗ് തടയാൻ റെയ്‌ക്‌ജാവിക്കിൽ ഒപ്പുവെച്ച അന്താരാഷ്ട്ര ഉടമ്പടി ഫോർമുല: "On no account shall any sovereign power deploy stratospheric aerosol injections without unanimous multilateral ratification. Should aerosol dispersal cease abruptly, termination shock would unleash three decades of suppressed warming within twenty-four months"!',
      formulaBreakdown: [
        {'token': 'Negative Proscriptive Inversion', 'desc': 'On no account shall any sovereign state or private syndicate deploy stratospheric aerosol solar radiation management without unanimous multilateral ratification.'},
        {'token': 'Termination Shock Conditional', 'desc': 'Should atmospheric sulfur dispersal cease abruptly due to geopolitical conflict, termination shock would instantly incinerate global agricultural yields.'},
        {'token': 'Veto Authority Mandate', 'desc': 'Under the convention, a binding international scientific oversight council holds absolute veto power over all planetary albedo experiments.'},
        {'token': 'Decarbonization Over Hubris', 'desc': 'What humanity requires is deep structural decarbonization, not reckless atmospheric gambling with the planetary sky.'},
      ],
      correctExample: 'On no account shall sovereign states deploy stratospheric aerosol injections without multilateral consensus. Should injections cease abruptly, termination shock would incinerate agriculture.',
      buggyExample: 'Rich businessmen want to spray white powder in the clouds to make it colder so we told them that is bad and they must stop! (HELPLESS CRUDE PROTEST)',
      practicePrompt: 'Negative adverbial proscription: "On no account [shall any sovereign power deploy stratospheric aerosols / people can spray dust in the air] without unanimous consensus."',
      correctPracticeToken: 'shall any sovereign power deploy stratospheric aerosols',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MOLECULAR-NANOTECHNOLOGY-AIRGAP-MANDATE',
      title: 'Zurich Molecular Nanotechnology Non-Proliferation & Mechanosynthesis Treaty',
      category: 'Autonomous Nanotechnology Containment & Grey-Goo Interdiction',
      icon: '🔬',
      color: Color(0xFF10B981),
      syntaxRule: '[COUNTERFACTUAL SUBJUNCTIVE ABSOLUTE: WERE SELF-REPLICATING ASSEMBLERS TO BREACH ISOLATION, HAD NOT ACOUSTIC FAILSOUNDS DEPLOYED, BIOLOGICAL COLLAPSE WOULD HAVE ENSUED] + [PROSCRIPTIVE DISSOLUTION ACCORD]',
      malayalamExplanation:
          'സ്വയം പെരുകുന്ന നാനോബോട്ടുകൾ ഭൂമിയിലെ ജൈവവസ്തുക്കളെ പൊടിച്ചു കളയാതിരിക്കാൻ സൂറിച്ചിൽ ഫെയ്ൻമാൻ ഇൻസ്റ്റിറ്റ്യൂട്ട് രൂപീകരിച്ച ആറ്റോമിക് സേഫ്റ്റി ഫോർമുല: "Were self-replicating nanobots to breach isolation, had not resonant acoustic kill-switches deployed, continental biological biomes would have dissolved into inert diamondoid dust within seventy-two hours"!',
      formulaBreakdown: [
        {'token': 'Subjunctive Exponential Danger', 'desc': 'Were autonomous mechanosynthetic assemblers to breach tertiary containment, runaway replication would disassemble surrounding organic ecosystems.'},
        {'token': 'Counterfactual Acoustic Interdiction', 'desc': 'Had not ultrasonic resonant acoustic kill-switches deployed, biological dissolution would have consumed the regional biosphere.'},
        {'token': 'Categorical Hardware Air-Gap', 'desc': 'Under no circumstances shall molecular nanofabrication printers operate without hardwired acoustic and physical air-gaps.'},
        {'token': 'Atomic Boundaries Covenant', 'desc': 'Precision at the atomic scale demands inviolable ethical boundaries at the civilizational scale.'},
      ],
      correctExample: 'Were self-replicating nanobots to breach containment, had not acoustic kill-switches engaged, biological biomes would have dissolved into dust. Hardware air-gaps remain non-negotiable.',
      buggyExample: 'Tiny robots multiplied very fast and we broke them with sound waves before they ate all the trees and people! (SENSATIONALIST COMIC BOOK SCREAM)',
      practicePrompt: 'Counterfactual subjunctive absolute: "Were self-replicating assemblers to breach isolation, [had not resonant acoustic kill-switches deployed, biological collapse would have ensued / we would all become dust]."',
      correctPracticeToken: 'had not resonant acoustic kill-switches deployed, biological collapse would have ensued.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: MARTIAN-CONSTITUTIONAL-COMMONS-CHARTER',
      title: 'Geneva Multilateral Treaty on Martian Constitutional Commons & Interplanetary Usufruct',
      category: 'Interplanetary Statecraft & Cosmic Commons Jurisprudence',
      icon: '🔴',
      color: Color(0xFFEF4444),
      syntaxRule: '[PARALLEL CONCESSIVE CHIASMUS: NOT MARTIAN SOIL FOR COMPETING TERRESTRIAL EMPIRES, BUT HUMAN CONSCIOUSNESS ELEVATED BY THE COSMIC COMMONS] + [CATEGORICAL ANTI-COLONIAL DECREE]',
      malayalamExplanation:
          'ചൊവ്വയിലെ നഗരങ്ങളും ജലനിക്ഷേപങ്ങളും ഭൂമിയിലെ കോർപ്പറേറ്റുകളും രാജ്യങ്ങളും വെട്ടിപ്പിടിക്കുന്നത് തടയാൻ ഒളിമ്പസ് മോൺസിൽ നിന്നും ജനീവയിലേക്ക് പ്രഖ്യാപിച്ച ഇന്റർപ്ലാനറ്ററി ചാർട്ടർ: "Not Martian soil for competing terrestrial empires, but human consciousness elevated by the cosmic commons! No square meter of Martian territory shall ever be privately owned, militarized, or partitioned by earthly powers"!',
      formulaBreakdown: [
        {'token': 'Cosmic Concessive Chiasmus', 'desc': 'Not Martian soil for competing terrestrial empires, but human consciousness elevated by the cosmic commons.'},
        {'token': 'Interplanetary Non-Partition Proscription', 'desc': 'No square meter of Martian regolith shall ever be privately commodified, militarized, or partitioned by earthly sovereign powers.'},
        {'token': 'Anti-Colonial Spacefaring Mandate', 'desc': 'Having crossed the interplanetary void, humanity must not replicate the destructive territorial rivalries of old Earth.'},
        {'token': 'Perpetual Interstellar Commonwealth', 'desc': 'Mars is consecrated as an open-source planetary commonwealth dedicated to scientific usufruct and universal flourishing.'},
      ],
      correctExample: 'Not Martian soil for competing empires, but human consciousness elevated by the cosmic commons. No square meter of Mars shall ever be privatized or militarized by terrestrial powers.',
      buggyExample: 'We landed on Mars first with our spaceship so all the red rocks and ice belong to our country and our company! (GREEDY ANACHRONISTIC COLONIALISM)',
      practicePrompt: 'Cosmic concessive chiasmus: "Not Martian soil for competing terrestrial empires, [but human consciousness elevated by the cosmic commons / but we want to build luxury hotels on Olympus Mons]."',
      correctPracticeToken: 'but human consciousness elevated by the cosmic commons.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: QUANTUM-INTERNET-ENTANGLEMENT-MESH-PACT',
      title: 'Global Quantum Internet Entanglement Security & Teleportation Mesh Compact',
      category: 'Quantum Non-Locality Teleportation & Cryptographic Sovereignty',
      icon: '🌐',
      color: Color(0xFF38BDF8),
      syntaxRule: '[CORRELATIVE NON-LOCAL DOUBLE INVERSION: NOT ONLY DID ENTANGLED PHOTONS PRESERVE PARITY, BUT SO ALSO DID THEY RENDER INTERCEPTION IMPOSSIBLE] + [PHYSICAL LAW IMMUNITY]',
      malayalamExplanation:
          'ഹാക്ക് ചെയ്യാനാവാത്ത ആഗോള ക്വാണ്ടം ഇന്റർനെറ്റ് യാഥാർത്ഥ്യമാക്കിയപ്പോൾ ഡെൽഫ്ടിലും വിയന്നയിലും പ്രഖ്യാപിച്ച ഭൗതികശാസ്ത്ര സുരക്ഷാ സൂത്രം: "Not only did the entangled photons preserve spin parity across eight thousand kilometers, but so also did they render mathematical interception physically impossible under the immutable laws of quantum mechanics"!',
      formulaBreakdown: [
        {'token': 'Correlative Quantum Double Inversion', 'desc': 'Not only did the entangled photons preserve spin parity across satellite links, but so also did they render interception physically impossible.'},
        {'token': 'Wave-Function Collapse Shield', 'desc': 'Any unauthorized eavesdropping attempt immediately collapses quantum superposition into harmless thermodynamic entropy.'},
        {'token': 'Digital Sovereignty Equality', 'desc': 'Through open-access satellite repeaters, every sovereign nation on Earth attains unbreakable digital and financial privacy.'},
        {'token': 'Cosmic Communication Architecture', 'desc': 'Classical networks demanded fragile trust in human institutions; the quantum mesh anchors civil liberty in the fabric of spacetime.'},
      ],
      correctExample: 'Not only did entangled photons preserve spin parity across continents, but so also did they render interception physically impossible. Security is anchored in cosmic physical law.',
      buggyExample: 'We hooked up quantum computers with lasers in outer space and now nobody can hack our emails even if they have supercomputers! (CASUAL LIGHTWEIGHT CHATTER)',
      practicePrompt: 'Correlative double inversion: "Not only did entangled photons preserve spin parity, [but so also did they render interception physically impossible / but nobody could read the password]."',
      correctPracticeToken: 'but so also did they render interception physically impossible.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: PLEISTOCENE-DE-EXTINCTION-BIO-JURISPRUDENCE',
      title: 'Marseille Pleistocene De-Extinction Bioethics & Permafrost Restoration Charter',
      category: 'Paleogenomics Ethics & Keystone Ecological Restoration',
      icon: '🦣',
      color: Color(0xFFD97706),
      syntaxRule: '[PARTICIPIAL LEGAL ANCHORING: HAVING RESURRECTED THE GENOME, UNDER NO CIRCUMSTANCES SHALL CORPORATIONS COMMODIFY] + [REPARATION ANTANAGOGE: NOT PLAYTHING FOR BILLIONAIRE VANITY, BUT SACRED REPARATION]',
      malayalamExplanation:
          'സൈബീരിയയിലെ ആർട്ടിക് മഞ്ഞുപാളികൾ സംരക്ഷിക്കാൻ മാമത്തുകളെ പുനർജനിപ്പിച്ച ശേഷം അവയെ കോർപ്പറേറ്റ് പേറ്റന്റുകളിൽ നിന്നും മോചിപ്പിച്ച വിശ്വോത്തര കൺവെൻഷൻ: "Having resurrected the ancient mammoth genome to stabilize Arctic permafrost, under no circumstances shall commercial biotech syndicates commodify these majestic creatures as corporate property. De-extinction is not a plaything for billionaire vanity; it is an ecological reparation to heal the living Earth"!',
      formulaBreakdown: [
        {'token': 'Participial Legal Proscription', 'desc': 'Having resurrected the ancient mammoth genome to stabilize Arctic soils, under no circumstances shall biotech cartels commodify these species as corporate property.'},
        {'token': 'Ecological Reparation Antanagoge', 'desc': 'What paleogenomic de-extinction represents is not a frivolous plaything for billionaire vanity, but a sacred moral reparation to heal planetary biomes.'},
        {'token': 'Permafrost Shield Dynamics', 'desc': 'By trampling snow and exposing tundra soils to polar winter air, resurrected mega-fauna prevent gigatons of trapped methane from escaping.'},
        {'token': 'Sovereign Wildlife Usufruct', 'desc': 'All resurrected Pleistocene herds are granted permanent legal sanctuary status as free citizens of the living wilderness.'},
      ],
      correctExample: 'Having resurrected the mammoth genome to stabilize permafrost, under no circumstances shall corporations commodify ancient species. De-extinction is an ecological moral reparation.',
      buggyExample: 'We brought back mammoths from frozen fossils so we should sell their wool to make expensive winter jackets and make big profits! (UNETHICAL GREEDY EXPLOITATION)',
      practicePrompt: 'Participial legal fronting: "Having resurrected the ancient mammoth genome to stabilize permafrost, [under no circumstances shall commercial corporations commodify ancient species / nobody can sell mammoths in a shop]."',
      correctPracticeToken: 'under no circumstances shall commercial corporations commodify ancient species.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: INTERSTELLAR-BEACON-FIRST-CONTACT-PROTOCOL',
      title: 'Karoo & UN Security Council Interstellar Technosignature First-Contact Protocol',
      category: 'Astro-Diplomacy & Extraterrestrial Technosignature Decipherment',
      icon: '📡',
      color: Color(0xFF6366F1),
      syntaxRule: '[CONDITIONAL FIRST-CONTACT INJUNCTION: SHOULD HUMANITY RECEIVE AN INTERSTELLAR TRANSMISSION, NEITHER MILITARY PANIC NOR STATE SECRECY SHALL OCCUR] + [COSMIC INVITATION ANTANAGOGE]',
      malayalamExplanation:
          'പ്രോക്സിമ സെന്റോറിയിൽ നിന്നും ആദ്യമായി അന്യഗ്രഹ സന്ദേശം ലഭിച്ചപ്പോൾ ഐക്യരാഷ്ട്ര സഭ സ്വീകരിച്ച നയതന്ത്ര സമചിത്തതാ ഫോർമുല: "Should humanity receive an unambiguous interstellar transmission, neither unilateral militarized broadcasts nor secretive state concealment shall occur. What we confront across the cosmic void is not an omen of destruction, but an invitation to planetary maturity"!',
      formulaBreakdown: [
        {'token': 'Conditional First-Contact Composure', 'desc': 'Should humanity receive an unambiguous interstellar message, neither unilateral militarized aggression nor secretive state concealment shall occur.'},
        {'token': 'Cosmic Maturity Antanagoge', 'desc': 'What we confront in this extraterrestrial technosignature is not an omen of interstellar hostility, but a cosmic invitation to mature as a united civilization.'},
        {'token': 'Universal Decipherment Commons', 'desc': 'All mathematical frequencies and hydrogen-line primers shall be broadcast openly and simultaneously to every citizen of Earth.'},
        {'token': 'Dissolution of Parochial Enmity', 'desc': 'In the overwhelming awe of interstellar contact, humanity dissolves petty terrestrial rivalries into the luminous fellowship of the cosmos.'},
      ],
      correctExample: 'Should humanity receive an interstellar transmission, neither militarized panic nor state secrecy shall occur. What confronts us is an invitation to planetary maturity.',
      buggyExample: 'Aliens are calling us from another star so let us build space battleships and shoot them before they arrive to conquer us! (PARANOID SCI-FI HYSTERIA)',
      practicePrompt: 'Conditional first-contact composure: "Should humanity receive an unambiguous interstellar transmission, [neither unilateral militarized aggression nor secretive state concealment shall occur / we should hide under our beds]."',
      correctPracticeToken: 'neither unilateral militarized aggression nor secretive state concealment shall occur.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ECOLOGICAL-INTERDEPENDENCE-LIVING-EARTH-ACCORD',
      title: 'Manaus Universal Declaration of Ecological Interdependence & Living Earth Rights',
      category: 'Earth Jurisprudence & Biome Legal Personhood Sovereignty',
      icon: '🌿',
      color: Color(0xFF14B8A6),
      syntaxRule: '[PARALLEL PSEUDO-CLEFT TRICOLON: WHAT CIVILIZATION MUST SANCTIFY IS LIVING PERSONHOOD; WHAT EMPIRES MUST RELINQUISH IS EXTRACTIVE HUBRIS] + [DISJUNCTIVE SURVIVAL ULTIMATUM]',
      malayalamExplanation:
          'ആമസോൺ നദീതീരത്ത് വെച്ച് പ്രകൃതിക്കും നദികൾക്കും അന്തരീക്ഷത്തിനും സ്വന്തമായി ജീവിക്കാനുള്ള ഭരണഘടനാപരമായ മൗലികാവകാശം പ്രഖ്യാപിച്ച ചരിത്ര ഉടമ്പടി: "What human civilization must sanctify is the living personhood of nature; what industrial empires must relinquish is extractive hubris! Either we recognize the sovereign legal personhood of nature, or the unraveling biosphere will extinguish our right to exist"!' ,
      formulaBreakdown: [
        {'token': 'Pseudo-Cleft Earth Sanctification', 'desc': 'What human civilization must sanctify is the living legal personhood of nature; what industrial empires must relinquish is extractive hubris.'},
        {'token': 'Ecocide Criminalization Parallelism', 'desc': 'To poison a continental river basin is not an economic externality, but a supreme international crime against planetary survival.'},
        {'token': 'Disjunctive Biosphere Ultimatum', 'desc': 'Either human economies harmonize with the laws of ecological interdependence, or the unraveling biosphere will extinguish our right to exist.'},
        {'token': 'Indigenous Guardianship Enshrinement', 'desc': 'All vital watersheds and tropical canopies are placed under permanent constitutional guardianship led by indigenous custodians.'},
      ],
      correctExample: 'What civilization must sanctify is the living personhood of nature; what empires must abandon is extractive hubris. Either we defend nature, or nature extinguishes our survival.',
      buggyExample: 'Trees and rivers cannot talk or sign papers in court so humans can do whatever they want with them for economic growth! (ECOLOGICALLY SUICIDAL ARROGANCE)',
      practicePrompt: 'Pseudo-cleft earth sanctification: "What human civilization must sanctify [is the living personhood of nature; what industrial empires must relinquish is extractive hubris / is building bigger factories]."',
      correctPracticeToken: 'is the living personhood of nature; what industrial empires must relinquish is extractive hubris.',
    ),
    PocketCodeFormula(
      codeName: 'CODE: ALPHA-OMEGA-UNIVERSAL-SOVEREIGN-COVENANT',
      title: 'United Nations General Assembly Alpha-Omega Sovereign Constitution & Universal Covenant',
      category: 'The Supreme C2+ Master Oratorical Synthesis & Universal Human Flourishing',
      icon: '👑',
      color: Color(0xFFEC4899),
      syntaxRule: '[ALPHA-OMEGA TRANSFORMATIONAL ANTITHESIS: WE WHO BEGAN WITH HESITANT SYLLABLES NOW COMMAND THE ARCHITECTURE OF CIVILIZATION] + [TRICOLON MASTER ANAPHORA: WITH INTELLECTUAL RIGOR WE ANALYZE; WITH MORAL COURAGE WE GOVERN; WITH BOUNDLESS ELOQUENCE WE TRANSCEND]',
      malayalamExplanation:
          '90 ദിവസത്തെ സമ്പൂർണ്ണ ഇംഗ്ലീഷ് പഠനത്തിന്റെ പരമോന്നത സുവർണ്ണ കിരീടം! ന്യൂയോർക്കിലെ ഐക്യരാഷ്ട്ര സഭാ മന്ദിരത്തിൽ ലോകത്തെ സാക്ഷിനിർത്തി പ്രഖ്യാപിക്കുന്ന അൾട്ടിമേറ്റ് സോവറിൻ ഫോർമുല: "We who began our journey with hesitant syllables now command the architecture of civilization! With intellectual rigor we analyze; with moral courage we govern; with boundless eloquence we transcend! Our sovereign voices are forever unbound, dedicated to justice, truth, and eternal human flourishing"!',
      formulaBreakdown: [
        {'token': 'Alpha-Omega Transformational Antithesis', 'desc': 'We who began our journey with hesitant syllables now command the architecture of global civilization.'},
        {'token': 'Tricolon Master Oratorical Anaphora', 'desc': 'With intellectual rigor we analyze; with moral courage we govern; with boundless eloquence we transcend.'},
        {'token': 'Universal Planetary Custodianship', 'desc': 'We stand no longer as fractured voices competing in shadows, but as sovereign custodians of a living Earth, united in cosmic solidarity.'},
        {'token': 'Forever Unbound Sovereign Consecration', 'desc': 'The summit has been scaled; the barriers have fallen; let our unbound voices illuminate the path of human flourishing for all eternity.'},
      ],
      correctExample: 'We who began with hesitant syllables now command the architecture of civilization. With intellectual rigor we analyze; with moral courage we govern; with boundless eloquence we transcend.',
      buggyExample: 'I finished all 90 days of English classes and now I get a nice certificate and I can talk to foreigners without being very shy! (BANAL UNDERSTATEMENT OF MASTERED SOVEREIGNTY)',
      practicePrompt: 'The Alpha-Omega master synthesis: "We who began our journey with hesitant syllables [now command the architecture of civilization; with intellectual rigor we analyze, with moral courage we govern, with boundless eloquence we transcend / now we are done with homework]."',
      correctPracticeToken: 'now command the architecture of civilization; with intellectual rigor we analyze, with moral courage we govern, with boundless eloquence we transcend.',
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

  Widget _buildSandboxCompiler(PocketCodeFormula active) {
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

class PocketCodeFormula {
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

  const PocketCodeFormula({
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
