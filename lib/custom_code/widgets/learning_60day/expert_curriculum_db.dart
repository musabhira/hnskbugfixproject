import 'daily_vocab_item.dart';

/// 🌟 Day-by-Day Expert Peak Fluency Curriculum Item (Day 1 to 90)
class ExpertDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String rhetoricalDevice;
  final String keyObjective;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> nativeEloquenceLines;
  final String oratoryCadenceFormula;
  final String dailySpeakingTask;

  const ExpertDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.rhetoricalDevice,
    required this.keyObjective,
    this.vocabularyItems = const [],
    this.nativeEloquenceLines = const [],
    required this.oratoryCadenceFormula,
    required this.dailySpeakingTask,
  });
}

/// 🏛️ Expert Peak Fluency & Global Eloquence 1 to 90 Master Database
/// For master-level communicators, podcast hosts, keynote orators, diplomats, and international delegates.
/// Emphasizes vocal cadence, rhetorical tropes, rapid reframing, and native conversational wit.
class ExpertCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Spontaneous Oratory & Keynote Cadence (Day 1 - 30)',
    31: 'Phase 2: Live Debate Agility & Hostile Question Reframing (Day 31 - 60)',
    61: 'Phase 3: Native Idiomatic Wit, Nuance & Humor (Day 61 - 75)',
    76: 'Phase 4: Sovereign Global Eloquence & Accent Neutrality (Day 76 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static ExpertDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, ExpertDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: The Power of the Deliberate Pause & Tricolon (The Rule of Three)
    // -------------------------------------------------------------------------
    1: const ExpertDayPlan(
      day: 1,
      titleEn: 'Day 1: Keynote Cadence - The Rhetorical Tricolon & Strategic Pauses',
      titleMl: 'ദിവസം 1: വലിയ സദസ്സുകളെ ആകർഷിക്കുന്ന വാക്ചാതുരി (Tricolon & Strategic Pauses)',
      phaseName: 'Phase 1: Spontaneous Oratory (പബ്ലിക് സ്പീക്കിംഗ് & കീനോട്ടുകൾ)',
      rhetoricalDevice: 'Tricolon (The Rule of Three) combined with dramatic 2-second vocal pauses.',
      keyObjective: 'Deliver a commanding opening statement that silences a noisy hall without shouting.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Eloquence',
          partOfSpeech: 'noun',
          definition: 'Fluent or persuasive speaking or writing.',
          malayalamMeaning: 'വാക്ചാതുരി / ആകർഷകമായ സംസാരശൈലി',
          exampleSentence: 'His speech was marked by rare eloquence and emotional depth.',
          phonetic: '/ˈel.ə.kwəns/',
        ),
        DailyVocabItem(
          word: 'Cadence',
          partOfSpeech: 'noun',
          definition: 'A modulation or inflection of the voice; rhythm in speech.',
          malayalamMeaning: 'ശബ്ദ താളം / ആരോഹണാവരോഹണം',
          exampleSentence: 'The rhythmic cadence of her voice kept the auditorium mesmerized.',
          phonetic: '/ˈkeɪ.dəns/',
        ),
        DailyVocabItem(
          word: 'Resonate',
          partOfSpeech: 'verb',
          definition: 'Evoke images, memories, and emotions in the listener.',
          malayalamMeaning: 'മനസ്സിൽ തങ്ങിനിൽക്കുക / പ്രതിധ്വനിക്കുക',
          exampleSentence: 'The keynote resonated deeply with delegates from across the globe.',
          phonetic: '/ˈrez.ən.eɪt/',
        ),
      ],
      nativeEloquenceLines: [
        'Standard: "We must work hard, stay honest, and succeed together."',
        'Keynote Eloquence: "We stand today not merely to witness history... [pause]... but to shape it, to claim it, and to redeem it."',
      ],
      oratoryCadenceFormula:
          'Formula: "[Statement 1]... [1-sec pause]... [Statement 2 with higher pitch]... [2-sec pause]... and finally, [Statement 3 with resonant drop]."',
      dailySpeakingTask:
          'റൂൾ ഓഫ് ത്രീ (Tricolon) ഉപയോഗിച്ച് വലിയൊരു സദസ്സിനെ അഭിസംബോധന ചെയ്യുന്ന 2 മിനിറ്റ് കീനോട്ട് ഓഡിയോ സമർപ്പിക്കുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: Instant Rebuttal - Reframing Hostile Questions with Grace
    // -------------------------------------------------------------------------
    2: const ExpertDayPlan(
      day: 2,
      titleEn: 'Day 2: Debate Agility - Reframing Loaded Questions without Flinching',
      titleMl: 'ദിവസം 2: കുരുക്കുന്ന ചോദ്യങ്ങളെ തത്സമയം പതറാതെ വഴിതിരിച്ചുവിടൽ (Reframing)',
      phaseName: 'Phase 1: Spontaneous Oratory (പബ്ലിക് സ്പീക്കിംഗ് & കീനോട്ടുകൾ)',
      rhetoricalDevice: 'Pivot & Reframe (Transitioning from defense to an offensive moral high ground).',
      keyObjective: 'Neutralize aggressive journalists or debate opponents with unshakeable composure.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Equanimity',
          partOfSpeech: 'noun',
          definition: 'Mental calmness, composure, and evenness of temper, especially in a difficult situation.',
          malayalamMeaning: 'മനഃശാന്തി / സമചിത്തത',
          exampleSentence: 'She handled the hostile panel with extraordinary equanimity.',
          phonetic: '/ˌek.wəˈnɪm.ə.ti/',
        ),
        DailyVocabItem(
          word: 'Reframe',
          partOfSpeech: 'verb',
          definition: 'Frame or express something in a different, more favorable way.',
          malayalamMeaning: 'മറ്റൊരു രീതിയിൽ പുനരവതരിപ്പിക്കുക',
          exampleSentence: 'He cleverly reframed the loss as an essential stepping stone.',
          phonetic: '/ˌriːˈfreɪm/',
        ),
      ],
      nativeEloquenceLines: [
        'Hostile Attack: "Isn\'t your entire enterprise lagging far behind industry standards?"',
        'Expert Reframe: "That question assumes speed is the only metric of merit. But if you examine systemic sustainability, our architecture is lightyears ahead."',
      ],
      oratoryCadenceFormula:
          'Formula: "That question presupposes [Premise X]. But the fundamental question this panel must confront is [Core Truth Y]."',
      dailySpeakingTask:
          'നിങ്ങളെ പ്രകോപിപ്പിക്കുന്ന ഒരു ചോദ്യത്തിന് ശാന്തമായി കൗണ്ടർ നൽകുന്ന 90 സെക്കൻഡ് സ്പീച്ച് ചെയ്യുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: Subtle English Irony & High-Level Banter
    // -------------------------------------------------------------------------
    3: const ExpertDayPlan(
      day: 3,
      titleEn: 'Day 3: Conversational Wit - High-Level Banter & Self-Deprecation',
      titleMl: 'ദിവസം 3: സംസാരത്തിലെ ഇന്റർനാഷണൽ നർമ്മവും നയതന്ത്ര വിറ്റും (Subtle Wit)',
      phaseName: 'Phase 1: Spontaneous Oratory (പബ്ലിക് സ്പീക്കിംഗ് & കീനോട്ടുകൾ)',
      rhetoricalDevice: 'Understatement (Litotes) & self-deprecating diplomatic humor.',
      keyObjective: 'Lighten the mood of a tense international room with effortless native wit.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Banter',
          partOfSpeech: 'noun / verb',
          definition: 'The playful and friendly exchange of teasing remarks.',
          malayalamMeaning: 'രസകരമായ തമാശ സംഭാഷണം',
          exampleSentence: 'The two world leaders engaged in witty banter before the summit.',
          phonetic: '/ˈbæn.tər/',
        ),
        DailyVocabItem(
          word: 'Understatement',
          partOfSpeech: 'noun',
          definition: 'The presentation of something as being smaller or less important than it actually is.',
          malayalamMeaning: 'കാര്യങ്ങളുടെ ഗൗരവം കുറച്ചുകാട്ടിയുള്ള നർമ്മം',
          exampleSentence: 'To say it was raining hard would be a massive understatement.',
          phonetic: '/ˈʌn.dəˌsteɪt.mənt/',
        ),
      ],
      nativeEloquenceLines: [
        'Overstatement: "This was the absolute worst catastrophe in human history!"',
        'British Understatement: "Well, that was certainly not our finest hour, to put it mildly."',
      ],
      oratoryCadenceFormula:
          'Formula: "To describe this as [Minor adjective] would be, to put it very mildly, a modest understatement."',
      dailySpeakingTask:
          'ഒരു വലിയ തടസ്സത്തെ നർമ്മത്തിൽ പൊതിഞ്ഞ് അവതരിപ്പിക്കുന്ന രീതിയിൽ 2 മിനിറ്റ് സംസാരിക്കുക.',
    ),
  };

  /// Fallback generator creating rich, practical lessons for Days 4 through 90
  static ExpertDayPlan _generateFallbackDay(int day) {
    if (day <= 30) {
      // Phase 1: Keynote Oratory & Cadence
      final topics = [
        'Anaphora & Repetition for Climax ("We shall not sleep... We shall not surrender")',
        'Antithesis: Juxtaposing Two Opposites ("Ask not what your country can do...")',
        'Vocal Tone Shifting: Transitioning from Whispered Gravity to Resonant Thunder',
        'Metaphorical Worldbuilding (Painting Visual Allegories in Spoken Words)',
        'The Micro-Story Epiphany (A 45-Second Anecdote with Monumental Moral Weight)',
        'Closing Crescendos: Leaving an Auditorium in Absolute Electrified Silence',
      ];
      final currentTopic = topics[(day - 4) % topics.length];
      return ExpertDayPlan(
        day: day,
        titleEn: 'Day $day: Oratorical Mastery - $currentTopic',
        titleMl: 'ദിവസം $day: പ്രസംഗ കലയിലെ വിസ്മയം - $currentTopic',
        phaseName: 'Phase 1: Spontaneous Oratory (പബ്ലിക് സ്പീക്കിംഗ് & കീനോട്ടുകൾ)',
        rhetoricalDevice: currentTopic,
        keyObjective: 'Deliver unscripted spoken paragraphs that hold listeners completely spellbound',
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Magnanimous' : (day == 5 ? 'Paradox' : 'Perspicacious'),
            partOfSpeech: 'adjective / noun',
            definition: 'Very generous or forgiving, especially toward a rival or less powerful person.',
            malayalamMeaning: day == 4 ? 'വിശാലമനസ്കനായ' : (day == 5 ? 'വൈരുദ്ധ്യം' : 'സൂക്ഷ്മ ദൃഷ്ടിയുള്ള'),
            exampleSentence: 'He showed a magnanimous spirit in the face of bitter opposition.',
            phonetic: '/mæɡˈnæn.ɪ.məs/',
          ),
        ],
        nativeEloquenceLines: [
          'Oratory: "It is not the absence of fear, but the triumph over it, that defines human dignity."',
        ],
        oratoryCadenceFormula: 'Formula: "It is not [Superficial Trait A], but rather [Profound Reality B] that shapes our destiny."',
        dailySpeakingTask: 'ഈ ശൈലി ഉപയോഗിച്ച് ഒരു വലിയ സദസ്സിനോട് സംസാരിക്കുന്ന രീതിയിൽ 3 മിനിറ്റ് പ്രസംഗിക്കുക.',
      );
    } else if (day <= 60) {
      // Phase 2: Live Debate Agility & Hostility De-escalation
      return ExpertDayPlan(
        day: day,
        titleEn: 'Day $day: High-Pressure Panel Defense & Socratic Interrogation',
        titleMl: 'ദിവസം $day: സങ്കീർണ്ണ ചർച്ചകളിലെ സംയമനവും സോക്രട്ടിക് ചോദ്യങ്ങളും',
        phaseName: 'Phase 2: Debate Agility (തത്സമയ തർക്കങ്ങളും പ്രതികരണങ്ങളും)',
        rhetoricalDevice: 'Socratic Counter-Questioning (Guiding opponents into their own logical trap).',
        keyObjective: 'Dismantle contradictory arguments purely by posing calm, devastating inquiries',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Fallacy',
            partOfSpeech: 'noun',
            definition: 'A mistaken belief, especially one based on unsound arguments.',
            malayalamMeaning: 'തെറ്റായ യുക്തി / വ്യാജ വാദം',
            exampleSentence: 'The opposition\'s argument rests on a fundamental statistical fallacy.',
            phonetic: '/ˈfæl.ə.si/',
          ),
        ],
        nativeEloquenceLines: [
          'Socratic Trap: "If your premise holds true, how then do you account for the empirical data in Q4?"',
        ],
        oratoryCadenceFormula: 'Formula: "Would you concede that if [Condition X] occurs, your core argument inevitably collapses?"',
        dailySpeakingTask: 'ഒരു പാനൽ ചർച്ചയിൽ എതിർവാദത്തെ യുക്തിപൂർവ്വം ചോദ്യം ചെയ്യുന്ന 2 മിനിറ്റ് ഓഡിയോ സമർപ്പിക്കുക.',
      );
    } else if (day <= 75) {
      // Phase 3: Native Idiomatic Wit & Accent Neutrality
      return ExpertDayPlan(
        day: day,
        titleEn: 'Day $day: Conversational Spontaneity & Cultural Subtleties',
        titleMl: 'ദിവസം $day: വിദേശ സംസ്കാരങ്ങളിലെ ഭാഷാ സൂക്ഷ്മതകളും സ്വാഭാവിക നർമ്മവും',
        phaseName: 'Phase 3: Native Eloquence (നേറ്റീവ് സ്പീക്കർ ഒഴുക്ക്)',
        rhetoricalDevice: 'Cultural Nuance & Idiomatic Fluency without affected accents.',
        keyObjective: 'Converse with native Anglo/American executives on equal, culturally-fluent footing',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Uncanny',
            partOfSpeech: 'adjective',
            definition: 'Strange or mysterious, especially in an unsettling way.',
            malayalamMeaning: 'അസാധാരണമായ / വിചിത്രമായ',
            exampleSentence: 'He possessed an uncanny knack for reading room dynamics.',
            phonetic: '/ʌnˈkæn.i/',
          ),
        ],
        nativeEloquenceLines: [
          'Wit: "He has this uncanny ability to make a two-hour lecture feel like a twenty-minute fireside chat."',
        ],
        oratoryCadenceFormula: 'Formula: "To say they were surprised would be missing the mark; they were utterly flabbergasted."',
        dailySpeakingTask: 'നേറ്റീവ് ശൈലിയിൽ സുഹൃത്തുക്കളോട് സംസാരിക്കുന്നതുപോലെ സ്വാഭാവികമായി 2 മിനിറ്റ് സംസാരിക്കുക.',
      );
    } else {
      // Phase 4: Sovereign Global Eloquence
      return ExpertDayPlan(
        day: day,
        titleEn: 'Day $day: Sovereign Global Statesmanship & Legacy Oratory',
        titleMl: 'ദിവസം $day: ആഗോള നേതൃത്വവും അവിസ്മരണീയമായ ഭാഷാ സ്വാധീനവും',
        phaseName: 'Phase 4: Sovereign Peak Fluency (അതിരുകളില്ലാത്ത ഇംഗ്ലീഷ് സ്വാധീനം)',
        rhetoricalDevice: 'Sovereign Eloquence (Seamlessly blending logic, emotion, rhythm, and moral authority).',
        keyObjective: 'Deliver a timeless, unscripted 5-minute speech worthy of world summits',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Quintessential',
            partOfSpeech: 'adjective',
            definition: 'Representing the most perfect or typical example of a quality or class.',
            malayalamMeaning: 'തികഞ്ഞ ഉത്തമ മാതൃകയായ / അത്യുജ്ജ്വലമായ',
            exampleSentence: 'This presentation was the quintessential synthesis of intellect and passion.',
            phonetic: '/ˌkwɪn.tɪˈsen.ʃəl/',
          ),
        ],
        nativeEloquenceLines: [
          'Summit Climax: "History will not judge us by the eloquence of our intentions, but by the courage of our actions."',
        ],
        oratoryCadenceFormula: 'Formula: "Let future generations record that when the call came, we did not hesitate, we did not falter, and we did not fail."',
        dailySpeakingTask: 'നിങ്ങളുടെ ജീവിത ദൗത്യത്തെക്കുറിച്ചോ ആഗോള ഭാവിയെക്കുറിച്ചോ 5 മിനിറ്റ് പ്രചോദനാത്മകമായി പ്രസംഗിക്കുക.',
      );
    }
  }
}
