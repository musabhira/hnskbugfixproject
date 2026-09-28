import 'daily_vocab_item.dart';

/// 🌟 Day-by-Day Elementary Curriculum Item (Day 1 to 90)
class ElementaryDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String reflexFocus;
  final String keyObjective;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> rapidDrillDialogues;
  final String hesitationBusterRule;
  final String dailySpeakingTask;

  const ElementaryDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.reflexFocus,
    required this.keyObjective,
    this.vocabularyItems = const [],
    this.rapidDrillDialogues = const [],
    required this.hesitationBusterRule,
    required this.dailySpeakingTask,
  });
}

/// 🏛️ Elementary Level 1 to 90 Master Database
/// Tailored for learners who know basic English grammar and vocabulary,
/// but experience hesitation, thinking gaps, and lack of speaking habits.
class ElementaryCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Instant Vocal Reflexes & Hesitation Breaker (Day 1 - 20)',
    21: 'Phase 2: Descriptive Vocabulary & Expressive Phrases (Day 21 - 45)',
    46: 'Phase 3: Phone Etiquette & Confident Question Framing (Day 46 - 70)',
    71: 'Phase 4: Unbroken 3-Minute Monologues & Speech Habit (Day 71 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static ElementaryDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, ElementaryDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: Breaking Vocal Inertia (The 1-Second Response Rule)
    // -------------------------------------------------------------------------
    1: const ElementaryDayPlan(
      day: 1,
      titleEn: 'Day 1: Instant 1-Second Vocal Reflex & Greeting',
      titleMl: 'ദിവസം 1: ഒരു സെക്കൻഡിൽ മറുപടി നൽകാനുള്ള സ്പീഡ് ഡ്രിൽ',
      phaseName: 'Phase 1: Instant Reflexes (മടി മാറ്റലും പെട്ടെന്നുള്ള മറുപടിയും)',
      reflexFocus: 'Eliminating the "ആലോചിച്ചു നിൽക്കൽ" gap when someone speaks to you.',
      keyObjective: 'Respond within 1 second using natural bridge phrases.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Hesitate',
          partOfSpeech: 'verb',
          definition: 'Pause in indecision before saying or doing something.',
          malayalamMeaning: 'മടിച്ചു നിൽക്കുക / സംശയിക്കുക',
          exampleSentence: 'Do not hesitate to speak up.',
          phonetic: '/ˈhez.ɪ.teɪt/',
        ),
        DailyVocabItem(
          word: 'Spontaneous',
          partOfSpeech: 'adjective',
          definition: 'Performed or occurring as a result of a sudden impulse.',
          malayalamMeaning: 'സ്വാഭാവികമായ / മുൻകൂട്ടി തയ്യാറാക്കാത്ത',
          exampleSentence: 'Her reply was natural and spontaneous.',
          phonetic: '/spɒnˈteɪ.ni.əs/',
        ),
        DailyVocabItem(
          word: 'Certainly',
          partOfSpeech: 'adverb',
          definition: 'Undoubtedly; definitely; used to express agreement.',
          malayalamMeaning: 'തീർച്ചയായും / സംശയമില്ലാതെ',
          exampleSentence: 'Certainly, I will help you with that.',
          phonetic: '/ˈsɜː.tən.li/',
        ),
      ],
      rapidDrillDialogues: [
        'Prompt: "Are you free right now?"\nInstant Reflex: "Certainly! What is on your mind?"',
        'Prompt: "Did you receive my message?"\nInstant Reflex: "Yes, I just saw it a moment ago."',
      ],
      hesitationBusterRule:
          '💡 സുവർണ്ണ നിയമം: "ആരെങ്കിലും ചോദിച്ചാൽ ആലോചിച്ചു നിൽക്കാതെ "Certainly", "Well", "To be honest" തുടങ്ങിയ ബ്രിഡ്ജ് വാക്കുകൾ ഉടൻ പുറത്തുവിടുക."',
      dailySpeakingTask:
          'ഈ 2 സംഭാഷണങ്ങൾ ഒരു സെക്കൻഡിൽ മറുപടി പറയുന്ന രീതിയിൽ വോയ്‌സിൽ റെക്കോർഡ് ചെയ്യുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: Expressing Agreement & Disagreement with Poise
    // -------------------------------------------------------------------------
    2: const ElementaryDayPlan(
      day: 2,
      titleEn: 'Day 2: Expressing Polite Agreement & Gentle Disagreement',
      titleMl: 'ദിവസം 2: മാന്യമായി യോജിക്കാനും വിയോജിക്കാനും ശീലിക്കൽ',
      phaseName: 'Phase 1: Instant Reflexes (മടി മാറ്റലും പെട്ടെന്നുള്ള മറുപടിയും)',
      reflexFocus: 'Replacing plain "Yes/No" with smart conversational phrases.',
      keyObjective: 'Master "I completely agree" and "I see your point, but..."',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Perspective',
          partOfSpeech: 'noun',
          definition: 'A particular attitude toward or way of regarding something.',
          malayalamMeaning: 'കാഴ്ചപ്പാട് / വീക്ഷണം',
          exampleSentence: 'From my perspective, this is a great idea.',
          phonetic: '/pəˈspek.tɪv/',
        ),
        DailyVocabItem(
          word: 'Concur',
          partOfSpeech: 'verb',
          definition: 'Be of the same opinion; agree.',
          malayalamMeaning: 'യോജിക്കുക / സമ്മതിക്കുക',
          exampleSentence: 'I fully concur with your decision.',
          phonetic: '/kənˈkɜːr/',
        ),
      ],
      rapidDrillDialogues: [
        'Agreement: "I completely agree with what you said."\nGentle Disagreement: "I see what you mean, but looking at it another way..."',
      ],
      hesitationBusterRule:
          '💡 ഒറ്റവാക്കിൽ "No" പറയുന്നതിന് പകരം "I see your point, but..." എന്ന് സൗമ്യമായി പറയുക.',
      dailySpeakingTask:
          'ഒരു വിഷയത്തോട് യോജിക്കുന്നതും വിയോജിക്കുന്നതുമായ 2 വാചകങ്ങൾ സംസാരിച്ചു പരിശീലിക്കുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: Asking for Clarification Without Feeling Embarrassed
    // -------------------------------------------------------------------------
    3: const ElementaryDayPlan(
      day: 3,
      titleEn: 'Day 3: Asking for Clarification with Poise',
      titleMl: 'ദിവസം 3: കേൾക്കാത്ത കാര്യങ്ങൾ വീണ്ടും ചോദിക്കാൻ മടിയില്ലാതെ പറയൽ',
      phaseName: 'Phase 1: Instant Reflexes (മടി മാറ്റലും പെട്ടെന്നുള്ള മറുപടിയും)',
      reflexFocus: 'Never say "What?" abruptly. Use polite clarification scripts.',
      keyObjective: 'Use "Could you please repeat that?" and "Pardon me?" effortlessly.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Clarify',
          partOfSpeech: 'verb',
          definition: 'Make a statement or situation less confused and more comprehensible.',
          malayalamMeaning: 'വ്യക്തമാക്കുക',
          exampleSentence: 'Could you clarify the second point, please?',
          phonetic: '/ˈklær.ɪ.faɪ/',
        ),
        DailyVocabItem(
          word: 'Pardon',
          partOfSpeech: 'noun / exclamation',
          definition: 'Used to ask someone to repeat what they just said.',
          malayalamMeaning: 'ക്ഷമിക്കണം (വീണ്ടും പറയൂ എന്ന് സൂചിപ്പിക്കാൻ)',
          exampleSentence: 'Pardon me, I didn\'t catch that.',
          phonetic: '/ˈpɑːr.dən/',
        ),
      ],
      rapidDrillDialogues: [
        'A: "The delivery is scheduled for Thursday afternoon."\nB: "Pardon me, did you say Thursday or Tuesday?"',
        'B: "Could you speak a little slower, please?"',
      ],
      hesitationBusterRule:
          '💡 മനസ്സിലായില്ലെങ്കിൽ മിണ്ടാതിരിക്കരുത്! "Pardon me, could you repeat that?" എന്ന് ധൈര്യമായി ചോദിക്കുക.',
      dailySpeakingTask:
          'വ്യക്തത ചോദിക്കുന്ന 2 വാചകങ്ങൾ വ്യക്തമായ ഉച്ചാരണത്തോടെ റെക്കോർഡ് ചെയ്യുക.',
    ),
  };

  /// Fallback generator creating rich, practical lessons for Days 4 through 90
  static ElementaryDayPlan _generateFallbackDay(int day) {
    if (day <= 20) {
      // Phase 1: Rapid Reflex Drills
      final drills = [
        'Small Talk on Weather & Weekend Plans (വാരാന്ത്യ പ്ലാനുകൾ പറയൽ)',
        'Reacting to Good & Bad News with Empathy (വാർത്തകളോട് പ്രതികരിക്കൽ)',
        'Expressing Gratitude & Genuine Appreciation (നന്ദി പ്രകടിപ്പിക്കൽ)',
        'Inviting Someone & Accepting/Declining with Grace (ക്ഷണിക്കലും നിരസിക്കലും)',
        'Giving Compliments on Work and Style (പ്രശംസകൾ നൽകൽ)',
        'Interrupting Politely in a Group Discussion (ഇടയിൽ കയറി സംസാരിക്കൽ)',
        'Ending a Conversation Warmly (സംഭാഷണം ഭംഗിയായി അവസാനിപ്പിക്കൽ)',
      ];
      final currentDrill = drills[(day - 4) % drills.length];
      return ElementaryDayPlan(
        day: day,
        titleEn: 'Day $day: Conversational Reflex - $currentDrill',
        titleMl: 'ദിവസം $day: പെട്ടെന്നുള്ള പ്രതികരണം - $currentDrill',
        phaseName: 'Phase 1: Instant Reflexes (മടി മാറ്റലും പെട്ടെന്നുള്ള മറുപടിയും)',
        reflexFocus: currentDrill,
        keyObjective: 'Respond naturally without hesitation or Malayalam mental translation',
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Appreciate' : (day == 5 ? 'Enthusiastic' : 'Delighted'),
            partOfSpeech: 'verb / adjective',
            definition: 'Recognize the full worth of; be grateful for.',
            malayalamMeaning: day == 4 ? 'വിലമതിക്കുക / നന്ദി പറയുക' : (day == 5 ? 'ഉത്സാഹമുള്ള' : 'വളരെ സന്തോഷമുള്ള'),
            exampleSentence: 'I truly appreciate your assistance.',
            phonetic: '/əˈpriː.ʃi.eɪt/',
          ),
        ],
        rapidDrillDialogues: [
          'A: "Thank you for taking the time to meet."\nB: "It was my absolute pleasure!"',
        ],
        hesitationBusterRule: '💡 മറുപടി തുടങ്ങാൻ "As a matter of fact" അല്ലെങ്കിൽ "To be honest" ഉപയോഗിക്കുക.',
        dailySpeakingTask: 'ഈ സംഭാഷണം യാതൊരു തടസ്സവുമില്ലാതെ വോയ്‌സിൽ റെക്കോർഡ് ചെയ്യുക.',
      );
    } else if (day <= 45) {
      // Phase 2: Descriptive Vocabulary
      return ElementaryDayPlan(
        day: day,
        titleEn: 'Day $day: Descriptive Vocabulary (Replacing Boring Words)',
        titleMl: 'ദിവസം $day: സാധാരണ വാക്കുകൾ മാറ്റി മികച്ച പദങ്ങൾ ഉപയോഗിക്കൽ',
        phaseName: 'Phase 2: Descriptive Words (വിവരണാത്മക പദസമ്പത്ത്)',
        reflexFocus: 'Saying "Exquisite" instead of "Very good", "Exhausted" instead of "Very tired".',
        keyObjective: 'Enrich spoken sentences with colorful, precise adjectives',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Fascinating',
            partOfSpeech: 'adjective',
            definition: 'Extremely interesting and captivating.',
            malayalamMeaning: 'വളരെ ആകർഷകമായ / കൗതുകകരമായ',
            exampleSentence: 'That was a fascinating story.',
            phonetic: '/ˈfæs.ɪ.neɪ.tɪŋ/',
          ),
        ],
        rapidDrillDialogues: [
          'Instead of: "The food was very good."\nSay: "The meal was truly exceptional!"',
        ],
        hesitationBusterRule: '💡 "Very" എന്ന വാക്ക് ഒഴിവാക്കി മികച്ച അഡ്ജക്ടീവുകൾ ഉപയോഗിക്കുക.',
        dailySpeakingTask: 'ഇന്ന് പഠിച്ച പുതിയ വാക്ക് ഉപയോഗിച്ച് 2 വാചകങ്ങൾ സംസാരിക്കുക.',
      );
    } else if (day <= 70) {
      // Phase 3: Phone Etiquette & Question Framing
      return ElementaryDayPlan(
        day: day,
        titleEn: 'Day $day: Professional Phone Calling & Question Framing',
        titleMl: 'ദിവസം $day: ഫോണിൽ മടിയില്ലാതെ സംസാരിക്കലും ചോദ്യങ്ങൾ ചോദിക്കലും',
        phaseName: 'Phase 3: Phone Etiquette (ഫോൺ സംഭാഷണങ്ങളും ചോദ്യങ്ങളും)',
        reflexFocus: 'Handling incoming/outgoing calls, leaving voicemails, making appointments.',
        keyObjective: 'Conduct a 3-minute telephone conversation with complete composure',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Inquire',
            partOfSpeech: 'verb',
            definition: 'Ask for information from someone.',
            malayalamMeaning: 'അന്വേഷിക്കുക / ചോദിച്ചറിയുക',
            exampleSentence: 'I am calling to inquire about the course details.',
            phonetic: '/ɪnˈkwaɪər/',
          ),
        ],
        rapidDrillDialogues: [
          'Caller: "Good morning, I am calling to inquire about my application status."\nReceiver: "Certainly, could you please provide your registration number?"',
        ],
        hesitationBusterRule: '💡 ഫോൺ എടുക്കുമ്പോൾ "Hello, this is [Name] speaking" എന്ന് മാന്യമായി തുടങ്ങുക.',
        dailySpeakingTask: 'ഫോൺ സംഭാഷണ മോഡലിൽ 2 മിനിറ്റ് റെക്കോർഡ് ചെയ്തു സമർപ്പിക്കുക.',
      );
    } else {
      // Phase 4: Unbroken 3-Minute Monologues
      return ElementaryDayPlan(
        day: day,
        titleEn: 'Day $day: 3-Minute Continuous Speech (Habit Lock-in)',
        titleMl: 'ദിവസം $day: 3 മിനിറ്റ് തടസ്സമില്ലാതെ സംസാരിക്കാനുള്ള ഫ്ലോ ട്രെയിനിംഗ്',
        phaseName: 'Phase 4: Unbroken Speech Flow (സംസാരത്തിലുള്ള തുടർച്ചയും ഒഴുക്കും)',
        reflexFocus: 'Unbroken speech stamina on everyday personal thoughts and memories.',
        keyObjective: 'Speak for 3 straight minutes without stalling or reverting to Malayalam',
        rapidDrillDialogues: [
          'Topic: "My Favorite Memory from Childhood"\nFlow: Introduction -> Core Story -> Lesson Learned -> Conclusion.',
        ],
        hesitationBusterRule: '💡 വാക്ക് കിട്ടിയില്ലെങ്കിലും നിർത്തിവെക്കരുത്; "What I mean to say is..." എന്ന് പറഞ്ഞ് തുടരുക.',
        dailySpeakingTask: 'നൽകിയ ടോപ്പിക്കിൽ 3 മിനിറ്റ് തടസ്സമില്ലാതെ സംസാരിച്ചു ഓഡിയോ സമർപ്പിക്കുക.',
      );
    }
  }
}
