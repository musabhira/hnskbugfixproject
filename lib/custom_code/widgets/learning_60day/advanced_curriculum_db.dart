import 'daily_vocab_item.dart';

/// 🌟 Day-by-Day Advanced Curriculum Item (Day 1 to 90)
class AdvancedDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String executiveScenario;
  final String keyObjective;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> boardroomPhrases;
  final String diplomaticFormula;
  final String dailySpeakingTask;

  const AdvancedDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.executiveScenario,
    required this.keyObjective,
    this.vocabularyItems = const [],
    this.boardroomPhrases = const [],
    required this.diplomaticFormula,
    required this.dailySpeakingTask,
  });
}

/// 🏛️ Advanced Workplace & Career English 1 to 90 Master Database
/// Designed for corporate leadership, global client interactions, STAR job interviews,
/// diplomatic negotiations, and high-impact boardroom presentations.
class AdvancedCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Executive Corporate Vocabulary & Diplomatic Protocol (Day 1 - 30)',
    31: 'Phase 2: High-Stakes Job Interviews & The STAR Method (Day 31 - 60)',
    61: 'Phase 3: Cross-Border Client Calls & Objection Handling (Day 61 - 75)',
    76: 'Phase 4: C-Suite Pitching & Keynote Leadership Delivery (Day 76 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static AdvancedDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, AdvancedDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: Executive Diplomacy & Soft Assertiveness
    // -------------------------------------------------------------------------
    1: const AdvancedDayPlan(
      day: 1,
      titleEn: 'Day 1: Executive Diplomacy & Soft Assertiveness',
      titleMl: 'ദിവസം 1: കോർപ്പറേറ്റ് ഡിപ്ലോമസിയും മാന്യമായ ദൃഢതയും',
      phaseName: 'Phase 1: Executive Protocol (കോർപ്പറേറ്റ് ഇംഗ്ലീഷ്)',
      executiveScenario: 'Steering high-stakes project discussions with overseas leadership.',
      keyObjective: 'Replace aggressive or overly timid statements with diplomatic assertion.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Leverage',
          partOfSpeech: 'verb / noun',
          definition: 'Use something to maximum advantage.',
          malayalamMeaning: 'പരമാവധി പ്രയോജനപ്പെടുത്തുക / ശേഷി ഉപയോഗിക്കുക',
          exampleSentence: 'We can leverage our AI capabilities to streamline customer onboarding.',
          phonetic: '/ˈlev.ər.ɪdʒ/',
        ),
        DailyVocabItem(
          word: 'Consensus',
          partOfSpeech: 'noun',
          definition: 'A general agreement among a group.',
          malayalamMeaning: 'സർവ്വ സമ്മതം / പൊതു അഭിപ്രായ ഐക്യം',
          exampleSentence: 'After extensive deliberation, the board reached a consensus.',
          phonetic: '/kənˈsen.səs/',
        ),
        DailyVocabItem(
          word: 'Viable',
          partOfSpeech: 'adjective',
          definition: 'Capable of working successfully; feasible.',
          malayalamMeaning: 'പ്രായോഗികമായ / വിജയസാധ്യതയുള്ള',
          exampleSentence: 'This remains the most commercially viable alternative.',
          phonetic: '/ˈvaɪ.ə.bəl/',
        ),
      ],
      boardroomPhrases: [
        'Direct / Blunt: "This plan will fail because your budget is too low."',
        'Executive Diplomatic: "I have some reservations regarding the proposed budget; perhaps we could explore alternative avenues to ensure commercial viability."',
      ],
      diplomaticFormula:
          'Formula: "I recognize the merit in [Idea A]; however, to mitigate [Risk B], might I propose [Solution C]?"',
      dailySpeakingTask:
          'ഒരു പ്രൊജക്റ്റ് റിവ്യൂ മീറ്റിംഗിൽ ക്ലയന്റിനോട് നയപരമായി വിയോജിപ്പ് പ്രകടിപ്പിക്കുന്ന രീതിയിൽ 2 മിനിറ്റ് സംസാരിക്കുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: The STAR Method for Behavioral Interviews
    // -------------------------------------------------------------------------
    2: const AdvancedDayPlan(
      day: 2,
      titleEn: 'Day 2: STAR Technique - Situation & Task Definition',
      titleMl: 'ദിവസം 2: ഇന്റർവ്യൂ മാസ്റ്ററി - STAR ടെക്നിക്ക് (Situation & Task)',
      phaseName: 'Phase 1: Executive Protocol (കോർപ്പറേറ്റ് ഇംഗ്ലീഷ്)',
      executiveScenario: 'Answering: "Tell me about a time you faced a critical roadblock at work."',
      keyObjective: 'Set up clear business context without getting lost in trivial details.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Contingency',
          partOfSpeech: 'noun',
          definition: 'A future event or circumstance which is possible but cannot be predicted with certainty.',
          malayalamMeaning: 'അപ്രതീക്ഷിത അടിയന്തര സാഹചര്യം / മുൻകരുതൽ',
          exampleSentence: 'We established a robust contingency plan to prevent downtime.',
          phonetic: '/kənˈtɪn.dʒən.si/',
        ),
        DailyVocabItem(
          word: 'Spearhead',
          partOfSpeech: 'verb',
          definition: 'Lead an attack or organized movement/project.',
          malayalamMeaning: 'നേതൃത്വം നൽകുക / മുന്നിൽ നിന്ന് നയിക്കുക',
          exampleSentence: 'She was chosen to spearhead the digital transformation initiative.',
          phonetic: '/ˈspɪr.hed/',
        ),
      ],
      boardroomPhrases: [
        'STAR Situation: "In my previous role as Senior Engineer, our primary production database suffered an unexpected outage during peak festive traffic."',
        'STAR Task: "My mandate was to restore service within twenty minutes while preserving all transactional data integrity."',
      ],
      diplomaticFormula:
          'Formula: "In my tenure at [Company], when faced with [Situation], my core responsibility was to [Task]..."',
      dailySpeakingTask:
          'നിങ്ങൾ നേരിട്ട ഒരു പ്രതിസന്ധിയും അത് പരിഹരിക്കാൻ എടുത്ത ഉത്തരവാദിത്തവും STAR രീതിയിൽ 90 സെക്കൻഡിൽ പറയുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: Conducting Overseas Client Discovery Calls
    // -------------------------------------------------------------------------
    3: const AdvancedDayPlan(
      day: 3,
      titleEn: 'Day 3: Global Client Discovery & Active Listening',
      titleMl: 'ദിവസം 3: വിദേശ ക്ലയന്റ് കോളുകൾ - കൃത്യമായ ചോദ്യങ്ങളും ലിസണിംഗും',
      phaseName: 'Phase 1: Executive Protocol (കോർപ്പറേറ്റ് ഇംഗ്ലീഷ്)',
      executiveScenario: 'Initial 30-minute discovery call with US/European enterprise clients.',
      keyObjective: 'Uncover pain points using open-ended executive questioning.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Bottleneck',
          partOfSpeech: 'noun',
          definition: 'A point of congestion or blockage in an operation or process.',
          malayalamMeaning: 'തടസ്സം / വളർച്ചയെ മുരടിപ്പിക്കുന്ന ഘടകം',
          exampleSentence: 'Identifying the operational bottleneck reduced turnaround time by 40%.',
          phonetic: '/ˈbɒt.əl.nek/',
        ),
        DailyVocabItem(
          word: 'Benchmark',
          partOfSpeech: 'noun / verb',
          definition: 'A standard or point of reference against which things may be compared.',
          malayalamMeaning: 'അളവുകോൽ / മാതൃകാ നിലവാരം',
          exampleSentence: 'We benchmark our delivery speeds against global industry leaders.',
          phonetic: '/ˈbentʃ.mɑːrk/',
        ),
      ],
      boardroomPhrases: [
        'Discovery Question: "Help me understand your current workflow: what is the single biggest bottleneck preventing your team from scaling?"',
        'Reflecting Value: "If I am hearing you correctly, your primary priority is not cost reduction, but rather time-to-market speed."',
      ],
      diplomaticFormula:
          'Formula: "If I am hearing you correctly, your overarching priority centers on [Key Need], is that an accurate reflection?"',
      dailySpeakingTask:
          'ഒരു വിദേശ ക്ലയന്റിനോട് അവരുടെ ബിസിനസ്സ് ആവശ്യങ്ങൾ ചോദിച്ചറിയുന്ന രീതിയിൽ 2 മിനിറ്റ് കോൾ റെക്കോർഡ് ചെയ്യുക.',
    ),
  };

  /// Fallback generator creating rich, practical lessons for Days 4 through 90
  static AdvancedDayPlan _generateFallbackDay(int day) {
    if (day <= 30) {
      // Phase 1: Corporate Protocol & Executive Fluency
      final topics = [
        'Chairing Agile Standups & Cross-Functional Syncs (മീറ്റിംഗ് ലീഡർഷിപ്പ്)',
        'Managing Upwards: Reporting to Directors & VPs (ഉന്നത ഉദ്യോഗസ്ഥരോട് സംസാരിക്കൽ)',
        'Delivering Constructive Feedback to Direct Reports (ഫീഡ്ബാക്ക് നൽകൽ)',
        'Handling Scope Creep & Politely Pushing Back (അധിക ജോലികൾ നയപരമായി നിരസിക്കൽ)',
        'Salary & Equity Appraisal Negotiations (ശമ്പള വർദ്ധന ചർച്ചകൾ)',
        'Crafting High-Impact Verbal Executive Summaries (പ്രസന്റേഷൻ തുടക്കങ്ങൾ)',
      ];
      final currentTopic = topics[(day - 4) % topics.length];
      return AdvancedDayPlan(
        day: day,
        titleEn: 'Day $day: Executive Nuance - $currentTopic',
        titleMl: 'ദിവസം $day: കോർപ്പറേറ്റ് സംസാര ശൈലി - $currentTopic',
        phaseName: 'Phase 1: Executive Protocol (കോർപ്പറേറ്റ് ഇംഗ്ലീഷ്)',
        executiveScenario: currentTopic,
        keyObjective: 'Deliver articulate, concise boardroom communication with executive presence',
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Prerogative' : (day == 5 ? 'Paradigm' : 'Scalable'),
            partOfSpeech: 'noun / adjective',
            definition: 'A right or privilege exclusive to a particular individual or class.',
            malayalamMeaning: day == 4 ? 'പ്രത്യേക അധികാരം' : (day == 5 ? 'ചിന്താ മാതൃക' : 'വലുതാക്കാൻ കഴിയുന്ന'),
            exampleSentence: 'It is the management\'s prerogative to decide on capital allocations.',
            phonetic: '/prɪˈrɒɡ.ə.tɪv/',
          ),
        ],
        boardroomPhrases: [
          'Executive Sync: "Let us ensure all stakeholders are aligned before committing to the Q3 deliverables."',
        ],
        diplomaticFormula: 'Formula: "To ensure seamless alignment across the board, let us establish that..."',
        dailySpeakingTask: 'ഈ വിഷയത്തിൽ മാനേജ്‌മെന്റിനോട് സംസാരിക്കുന്ന രീതിയിൽ 2 മിനിറ്റ് സ്പീച്ച് സമർപ്പിക്കുക.',
      );
    } else if (day <= 60) {
      // Phase 2: High-Stakes Job Interviews & The STAR Method
      return AdvancedDayPlan(
        day: day,
        titleEn: 'Day $day: Advanced Mock Interview - Complex Scenario Question',
        titleMl: 'ദിവസം $day: ഇന്റർവ്യൂ മാസ്റ്ററി - സങ്കീർണ്ണമായ ചോദ്യങ്ങൾക്ക് STAR മറുപടി',
        phaseName: 'Phase 2: Job Interviews & STAR Method (ഇന്റർവ്യൂ മോക്ക് കോളുകൾ)',
        executiveScenario: 'Handling high-level behavioral & situational architecture questions.',
        keyObjective: 'Articulate Action & Result with quantified business metrics (e.g. 30% increase)',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Streamline',
            partOfSpeech: 'verb',
            definition: 'Make an organization or system more efficient and effective by employing simpler methods.',
            malayalamMeaning: 'കാര്യക്ഷമമാക്കുക / എളുപ്പമുള്ളതാക്കുക',
            exampleSentence: 'Our intervention streamlined supply chain latency by 28%.',
            phonetic: '/ˈstriːm.laɪn/',
          ),
        ],
        boardroomPhrases: [
          'STAR Action: "I spearheaded a weekly peer code-review cadence which eliminated deployment regressions."',
          'STAR Result: "Consequently, client satisfaction scores improved from 72% to 94% within two quarters."',
        ],
        diplomaticFormula: 'Formula: "The measurable impact of this intervention was [Metric X], resulting in [Benefit Y]."',
        dailySpeakingTask: 'നിങ്ങളുടെ ഏറ്റവും വലിയ നേട്ടം കണക്കുകൾ സഹിതം STAR രീതിയിൽ വിവരിക്കുക.',
      );
    } else if (day <= 75) {
      // Phase 3: Cross-Border Client Calls & Objection Handling
      return AdvancedDayPlan(
        day: day,
        titleEn: 'Day $day: High-Stakes Contract Negotiation & Objections',
        titleMl: 'ദിവസം $day: കരാർ ചർച്ചകളും എതിർപ്പുകൾ മാന്യമായി മറികടക്കലും',
        phaseName: 'Phase 3: Client Calls & Negotiations (ക്ലയന്റ് കോളുകൾ & നെഗോഷ്യേഷൻസ്)',
        executiveScenario: 'Diffusing tense client disagreements on pricing, deliverables, or timelines.',
        keyObjective: 'Turn a defensive deadlock into a collaborative win-win partnership',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Compromise',
            partOfSpeech: 'noun / verb',
            definition: 'An agreement reached by each side making concessions.',
            malayalamMeaning: 'പരസ്പര വിട്ടുവീഴ്ച / ഒത്തുതീർപ്പ്',
            exampleSentence: 'We arrived at a pragmatic compromise that protected margins.',
            phonetic: '/ˈkɒm.prə.maɪz/',
          ),
        ],
        boardroomPhrases: [
          'Objection Handling: "I hear your concern on cost. However, if we trim that component, the security audits might fall below regulatory compliance."',
        ],
        diplomaticFormula: 'Formula: "Rather than treating this as an impasse, let us examine where we can introduce flexibility."',
        dailySpeakingTask: 'വില കൂടുതൽ എന്ന് പരാതിപ്പെടുന്ന ക്ലയന്റിനോട് സംസാരിക്കുന്ന രീതിയിൽ ഓഡിയോ സമർപ്പിക്കുക.',
      );
    } else {
      // Phase 4: C-Suite Pitching & Keynote Leadership Delivery
      return AdvancedDayPlan(
        day: day,
        titleEn: 'Day $day: Visionary Keynote Pitching & Inspiring Teams',
        titleMl: 'ദിവസം $day: ഉയർന്ന വേദികളിൽ പ്രസംഗിക്കലും ടീമുകളെ ആവേശം കൊള്ളിക്കലും',
        phaseName: 'Phase 4: Keynote Leadership (C-Suite പ്രസന്റേഷൻസ് & ലീഡർഷിപ്പ്)',
        executiveScenario: 'Pitching an innovative multi-million dollar business vision to investors or global teams.',
        keyObjective: 'Deliver commanding oratory that combines emotional resonance with hard metrics',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Catalyst',
            partOfSpeech: 'noun',
            definition: 'A person or thing that precipitates an event or radical change.',
            malayalamMeaning: 'മാറ്റത്തിന് വഴിയൊരുക്കുന്ന ഉത്തേജക ഘടകം',
            exampleSentence: 'This breakthrough will act as a catalyst for widespread industry adoption.',
            phonetic: '/ˈkæt.əl.ɪst/',
          ),
        ],
        boardroomPhrases: [
          'Visionary Pitch: "We are not merely building a product; we are rearchitecting how humans communicate in the AI era."',
        ],
        diplomaticFormula: 'Formula: "The true measure of leadership lies not in [Short-term metric], but in our capacity to [Transformational Vision]."',
        dailySpeakingTask: 'നിങ്ങളുടെ കമ്പനിയുടെയോ സ്വപ്ന പദ്ധതിയുടെയോ വിഷൻ 3 മിനിറ്റ് കീനോട്ടായി അവതരിപ്പിക്കുക.',
      );
    }
  }
}
