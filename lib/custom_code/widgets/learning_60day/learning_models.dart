import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';

/// Distinct UI Themes that radically transform the Profile appearance at major milestones
enum ProfileUIThemeVariant {
  genesis, // Days 1–29: Sleek, clean modern cards
  silverKnight, // Days 30–59: Chrome-accented metallic capsules & frosted glass
  goldSovereign, // Days 60–89: 24K Gold luxury glowing badges & golden stat cards
  diamondCelestial // Day 90: Holographic diamond aura, obsidian glassmorphism & crown badge
}

/// Represents one of the 90 distinct daily stages in Pocket Mates
class LearningMilestoneStage {
  final int stageNumber; // 1 to 90
  final int day; // 1 to 90
  final String stageName;
  final String fluencyTier;
  final String description;
  final String emoji;
  final bool isMajorGate; // Day 21, 30, 60, 90
  final Color bgColor;
  final Color textColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color tickColor; // Custom verified badge color
  final List<Color> gradientColors;
  final String bgHex;
  final String textHex;
  final String buttonHex;
  final String buttonTextHex;
  final ProfileUIThemeVariant uiThemeVariant;
  final VectorAvatarConfig avatarReward; // Prestigious NFT avatar unlocked on this day

  const LearningMilestoneStage({
    required this.stageNumber,
    required this.day,
    required this.stageName,
    required this.fluencyTier,
    required this.description,
    required this.emoji,
    this.isMajorGate = false,
    required this.bgColor,
    required this.textColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.tickColor,
    required this.gradientColors,
    required this.bgHex,
    required this.textHex,
    required this.buttonHex,
    required this.buttonTextHex,
    required this.uiThemeVariant,
    required this.avatarReward,
  });

  /// Factory generator producing all 90 unique stages with distinct color progressions
  static final List<LearningMilestoneStage> allStages = List.generate(90, (i) {
    final dayNum = i + 1;
    return _createStageForDay(dayNum);
  });

  static LearningMilestoneStage _createStageForDay(int day) {
    // ----------------------------------------------------
    // PHASE 1: DAYS 1 TO 29 (Genesis & Habit Building)
    // ----------------------------------------------------
    if (day < 30) {
      final isDay21 = day == 21;
      final tier = day <= 10
          ? 'Beginner A1'
          : (day <= 20 ? 'Elementary A2' : 'Intermediate B1');

      // Interpolate hue from slate blue (210) to cyan (180) to emerald (150) to amber (35)
      final progressRatio = (day - 1) / 28.0;
      final bgLuminance = (0.05 + progressRatio * 0.03).clamp(0.04, 0.10);
      final hue = (210.0 - progressRatio * 170.0 + 360.0) % 360.0;

      final primaryColor = HSLColor.fromAHSL(1.0, hue, 0.85, 0.55).toColor();
      final darkBg = HSLColor.fromAHSL(1.0, hue, 0.40, bgLuminance).toColor();
      final secondBg =
          HSLColor.fromAHSL(1.0, hue, 0.50, bgLuminance + 0.05).toColor();

      final stageEmoji = isDay21
          ? '🎯'
          : (day <= 7 ? '🌱' : (day <= 14 ? '🍃' : (day <= 20 ? '⚡' : '🔥')));
      final name = isDay21 ? 'Day 21 Habit Anchor' : 'Genesis Tier $day';

      final avatarReward = VectorAvatarConfig.getEvolutionAvatarForStage(day);

      return LearningMilestoneStage(
        stageNumber: day,
        day: day,
        stageName: name,
        fluencyTier: tier,
        description: isDay21
            ? '🎯 DAY 21 HABIT FORMED! English thinking is now an involuntary habit.'
            : 'Day $day foundation practice. Daily speech & chat fluency growing.',
        emoji: stageEmoji,
        isMajorGate: isDay21,
        bgColor: darkBg,
        textColor: const Color(0xFFF8FAFC),
        buttonColor: primaryColor,
        buttonTextColor: const Color(0xFF0F172A),
        tickColor: isDay21 ? const Color(0xFFFF5252) : const Color(0xFF38BDF8),
        gradientColors: [darkBg, secondBg],
        bgHex: _colorToHex(darkBg),
        textHex: '#F8FAFC',
        buttonHex: _colorToHex(primaryColor),
        buttonTextHex: '#0F172A',
        uiThemeVariant: ProfileUIThemeVariant.genesis,
        avatarReward: avatarReward,
      );
    }

    // ----------------------------------------------------
    // PHASE 2: DAYS 30 TO 59 (Silver Knight & Intermediate Mastery)
    // ----------------------------------------------------
    if (day < 60) {
      final isDay30 = day == 30;
      final tier = day <= 45 ? 'Intermediate B1+' : 'Upper-Inter B2';

      final progressRatio = (day - 30) / 29.0;
      final hue = (240.0 + progressRatio * 90.0) %
          360.0; // Lavender -> Purple -> Magenta -> Ruby

      final primaryColor = isDay30
          ? const Color(0xFFE2E8F0) // Silver Platinum for Day 30
          : HSLColor.fromAHSL(1.0, hue, 0.80, 0.60).toColor();

      final darkBg = isDay30
          ? const Color(0xFF13141C) // Gunmetal Obsidian
          : HSLColor.fromAHSL(1.0, hue, 0.35, 0.07).toColor();

      final secondBg = isDay30
          ? const Color(0xFF27293D)
          : HSLColor.fromAHSL(1.0, hue, 0.45, 0.14).toColor();

      final stageEmoji = isDay30
          ? '🥈'
          : (day <= 38
              ? '🔮'
              : (day <= 45 ? '🛡️' : (day <= 52 ? '💎' : '🍷')));
      final name = isDay30 ? 'Day 30 Silver Gate' : 'Silver Tier $day';

      final avatarReward = VectorAvatarConfig.getEvolutionAvatarForStage(day);

      return LearningMilestoneStage(
        stageNumber: day,
        day: day,
        stageName: name,
        fluencyTier: tier,
        description: isDay30
            ? '🥈 30-DAY FIRST MAJOR GATE! Silver Metallic UI & Intermediate B1 Badge.'
            : 'Day $day advanced expression. Idioms and voice spontaneity in flow.',
        emoji: stageEmoji,
        isMajorGate: isDay30,
        bgColor: darkBg,
        textColor: const Color(0xFFFAFAFA),
        buttonColor: primaryColor,
        buttonTextColor:
            isDay30 ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
        tickColor: isDay30 ? const Color(0xFFE2E8F0) : const Color(0xFFA855F7),
        gradientColors: [darkBg, secondBg],
        bgHex: _colorToHex(darkBg),
        textHex: '#FAFAFA',
        buttonHex: _colorToHex(primaryColor),
        buttonTextHex: isDay30 ? '#0F172A' : '#FFFFFF',
        uiThemeVariant: ProfileUIThemeVariant.silverKnight,
        avatarReward: avatarReward,
      );
    }

    // ----------------------------------------------------
    // PHASE 3: DAYS 60 TO 89 (Gold Sovereign & Advanced C1)
    // ----------------------------------------------------
    if (day < 90) {
      final isDay60 = day == 60;
      final tier = 'Advanced C1 Sovereign';

      final progressRatio = (day - 60) / 29.0;
      final hue = (45.0 -
          progressRatio * 25.0); // 24K Gold -> Solar Amber -> Crimson Gold

      final primaryColor = isDay60
          ? const Color(0xFFFFD700) // 24K Gold
          : HSLColor.fromAHSL(1.0, hue.clamp(15.0, 50.0), 0.95, 0.52).toColor();

      final darkBg = isDay60
          ? const Color(0xFF161103)
          : HSLColor.fromAHSL(1.0, hue.clamp(15.0, 50.0), 0.60, 0.05).toColor();

      final secondBg = isDay60
          ? const Color(0xFF382905)
          : HSLColor.fromAHSL(1.0, hue.clamp(15.0, 50.0), 0.70, 0.12).toColor();

      final stageEmoji = isDay60
          ? '🥇'
          : (day <= 68 ? '👑' : (day <= 75 ? '🏰' : (day <= 82 ? '🐉' : '⚔️')));
      final name =
          isDay60 ? 'Day 60 Gold Sovereign' : 'Gold Sovereign Tier $day';

      final avatarReward = VectorAvatarConfig.getEvolutionAvatarForStage(day);

      return LearningMilestoneStage(
        stageNumber: day,
        day: day,
        stageName: name,
        fluencyTier: tier,
        description: isDay60
            ? '🥇 60-DAY MAJOR GATE! 24K Gold Sovereign Profile UI & Advanced C1 Badge.'
            : 'Day $day high-level fluency. Natural tone and persuasive speaking.',
        emoji: stageEmoji,
        isMajorGate: isDay60,
        bgColor: darkBg,
        textColor: const Color(0xFFFFFBEB),
        buttonColor: primaryColor,
        buttonTextColor: const Color(0xFF1A1400),
        tickColor: const Color(0xFFFFD700), // Pure Gold Verified Tick
        gradientColors: [darkBg, secondBg],
        bgHex: _colorToHex(darkBg),
        textHex: '#FFFBEB',
        buttonHex: _colorToHex(primaryColor),
        buttonTextHex: '#1A1400',
        uiThemeVariant: ProfileUIThemeVariant.goldSovereign,
        avatarReward: avatarReward,
      );
    }

    // ----------------------------------------------------
    // PHASE 4: DAY 90 (Diamond Master Peak & Grandmaster C2)
    // ----------------------------------------------------
    const diamondBg = Color(0xFF020205);
    const diamondSecondary = Color(0xFF13172E);
    const diamondGold = Color(0xFFFFFC00);

    // 🐉 Ultimate Day 90 NFT Avatar: Astral Cosmic Dragon Grandmaster
    final grandmasterDragonAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(90);

    return LearningMilestoneStage(
      stageNumber: 90,
      day: 90,
      stageName: '💎 Day 90 Diamond Master',
      fluencyTier: 'Grandmaster C2 Diamond',
      description:
          '👑 90-DAY TRANSFORMATION COMPLETE! Full Native Mastery, Holographic Profile Aura & Astral Cosmic Dragon Crown.',
      emoji: '💎',
      isMajorGate: true,
      bgColor: diamondBg,
      textColor: const Color(0xFFFFFFFF),
      buttonColor: diamondGold,
      buttonTextColor: const Color(0xFF000000),
      tickColor: const Color(0xFF00F0FF), // Holographic Electric Diamond Tick
      gradientColors: const [diamondBg, diamondSecondary],
      bgHex: '#020205',
      textHex: '#FFFFFF',
      buttonHex: '#FFFC00',
      buttonTextHex: '#000000',
      uiThemeVariant: ProfileUIThemeVariant.diamondCelestial,
      avatarReward: grandmasterDragonAvatar,
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Resolves the stage matching a given learning day (1 to 90)
  static LearningMilestoneStage getStageForDay(int day) {
    final clampedDay = day.clamp(1, 90);
    return allStages[clampedDay - 1];
  }
}

/// Represents one daily practical English task for today's checklist
class DailyEnglishTask {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int points;
  final int targetMinutes;
  final bool isCompleted;

  const DailyEnglishTask({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    this.targetMinutes = 20,
    this.isCompleted = false,
  });

  DailyEnglishTask copyWith({bool? isCompleted}) {
    return DailyEnglishTask(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      points: points,
      targetMinutes: targetMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// User's overall 90-Day Progress Snapshot with Pocket Score and Inactivity Decay
class UserLearningProgress {
  final int currentDay; // 1 to 90 (also current stage)
  final int currentStage; // 1 to 90
  final int streakDays; // Consecutive active days
  final int totalPoints; // Pocket Score
  final int minutesPracticedToday; // 0 to 120 mins
  final int targetDailyMinutes; // 90 mins (1.5 hours)
  final int missedDaysCount; // Inactivity decay count
  final bool hasInactivityWarning;
  final DateTime lastActiveDate;
  final List<DailyEnglishTask> todayTasks;

  const UserLearningProgress({
    this.currentDay = 1,
    this.currentStage = 1,
    this.streakDays = 1,
    this.totalPoints = 0,
    this.minutesPracticedToday = 0,
    this.targetDailyMinutes = 90,
    this.missedDaysCount = 0,
    this.hasInactivityWarning = false,
    required this.lastActiveDate,
    this.todayTasks = const [],
  });

  double get progressPercentage => (currentDay / 90.0).clamp(0.0, 1.0);
  double get dailyTimePercentage =>
      (minutesPracticedToday / targetDailyMinutes.toDouble()).clamp(0.0, 1.0);
  LearningMilestoneStage get activeStage =>
      LearningMilestoneStage.getStageForDay(currentDay);
  LearningMilestoneStage? get nextStage =>
      currentDay < 90 ? LearningMilestoneStage.allStages[currentDay] : null;

  String get currentPhaseTitle {
    if (currentDay < 30) return 'Phase 1: Genesis & Habit (Days 1–29)';
    if (currentDay < 60) return 'Phase 2: Silver Knight Fluency (Days 30–59)';
    if (currentDay < 90) return 'Phase 3: Gold Sovereign Mastery (Days 60–89)';
    return 'Phase 4: Diamond Grandmaster (Day 90)';
  }
}

/// Comprehensive pedagogical syllabus model for each of the 90 days
class EnglishCurriculumLesson {
  final int day;
  final String title;
  final String phaseName;
  final String focusArea;
  final String speakingDrill;
  final String grammarConcept;
  final String peerChatMission;
  final int targetMinutes;
  final int xpReward;
  final String milestoneReward;

  const EnglishCurriculumLesson({
    required this.day,
    required this.title,
    required this.phaseName,
    required this.focusArea,
    required this.speakingDrill,
    required this.grammarConcept,
    required this.peerChatMission,
    this.targetMinutes = 90,
    this.xpReward = 35,
    this.milestoneReward = '',
  });

  static EnglishCurriculumLesson getLessonForDay(int day) {
    if (day <= 30) {
      return _generatePhase1Lesson(day);
    } else if (day <= 60) {
      return _generatePhase2Lesson(day);
    } else {
      return _generatePhase3Lesson(day);
    }
  }

  static EnglishCurriculumLesson _generatePhase1Lesson(int day) {
    final List<Map<String, String>> p1Topics = [
      {
        'title': 'Breaking Voice Hesitation & Self-Intro',
        'focus': 'Confidence & Vocal Warmups',
        'drill': 'Record a 60s introduction without hesitation or fillers.',
        'grammar': 'Present Simple vs Present Continuous',
        'peer': 'Introduce yourself in 5 English sentences to a Pocket Mate.'
      },
      {
        'title': 'Describing Your Daily Life & Habits',
        'focus': 'Everyday Action Verbs',
        'drill': 'Narrate what you did since waking up in chronological order.',
        'grammar': 'Adverbs of Frequency (always, usually, seldom)',
        'peer':
            'Ask your partner 3 questions about their daily morning routine.'
      },
      {
        'title': 'Food, Flavors & Cooking Stories',
        'focus': 'Sensory & Descriptive Words',
        'drill': 'Describe your favorite dish using at least 4 adjectives.',
        'grammar': 'Countable vs Uncountable Nouns',
        'peer': 'Debate food preferences with your mate in English.'
      },
      {
        'title': 'Navigating Places & Asking Directions',
        'focus': 'Prepositions & Polite Requests',
        'drill':
            'Give step-by-step oral directions from your home to a nearby landmark.',
        'grammar': 'Prepositions of Place (opposite, adjacent, across)',
        'peer': 'Roleplay asking for directions in an unfamiliar city.'
      },
      {
        'title': 'Expressing Likes, Dislikes & Hobbies',
        'focus': 'Emotional Nuance & Phrasing',
        'drill': 'Talk for 90s about a hobby that excites you.',
        'grammar': 'Gerunds vs Infinitives (enjoy doing vs like to do)',
        'peer': 'Find 2 common interests with your peer mate.'
      },
      {
        'title': 'Past Experiences & Memorable Trips',
        'focus': 'Past Tense Narration',
        'drill': 'Tell a 2-min story about the best trip of your life.',
        'grammar': 'Irregular Past Tense Verbs & Pronunciation of "-ed"',
        'peer': 'Share an unforgettable travel memory with your mate.'
      },
      {
        'title': 'Week 1 Review & Fluency Check',
        'focus': 'Sentence Rhythm & Syllable Stress',
        'drill': 'Perform a 3-min continuous monologue without stopping.',
        'grammar': 'Sentence Structure & Conjunctions (although, because)',
        'peer': 'Do a 10-minute live voice chat with an English mate.'
      },
    ];

    final index = (day - 1) % p1Topics.length;
    final topic = p1Topics[index];
    final isDay21 = day == 21;
    final isDay30 = day == 30;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay21
          ? '🎯 Day 21 Habit Anchor: Uninterrupted Speech'
          : (isDay30
              ? '🥈 Day 30 Silver Knight Foundation Gate'
              : 'Day $day: ${topic['title']!}'),
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea:
          isDay21 ? 'Permanent Habit Formation & Flow State' : topic['focus']!,
      speakingDrill: isDay21
          ? 'Speak continuously for 5 full minutes without pausing or using native language.'
          : topic['drill']!,
      grammarConcept: isDay21
          ? 'Conditionals (If I practice daily, I will master English)'
          : topic['grammar']!,
      peerChatMission: isDay21
          ? 'Celebrate your 21-day streak with your Pocket Mate in an audio chat.'
          : topic['peer']!,
      targetMinutes: 90,
      xpReward: isDay21 ? 100 : (isDay30 ? 150 : 35),
      milestoneReward: isDay21
          ? '🎯 Habit Anchor Lock Badge & Red Verified Tick'
          : (isDay30 ? '🥈 Silver Knight Shield & Chrome Profile Theme' : ''),
    );
  }

  static EnglishCurriculumLesson _generatePhase2Lesson(int day) {
    final List<Map<String, String>> p2Topics = [
      {
        'title': 'Polite Disagreements & Debating Skills',
        'focus': 'Diplomatic Rhetoric',
        'drill':
            'Defend an unpopular opinion politely using "I see your point, however...".',
        'grammar': 'Modal Verbs of Deduction (must, might, can\'t be)',
        'peer': 'Debate "Remote Work vs Office" with your mate in English.'
      },
      {
        'title': 'Business & Professional Email Spoken Pitch',
        'focus': 'Workplace Vocabulary',
        'drill':
            'Deliver a 90s elevator pitch for a product or service you love.',
        'grammar': 'Passive Voice in Professional Contexts',
        'peer': 'Simulate a client interview call with your Pocket Mate.'
      },
      {
        'title': 'Mastering Common Native Idioms',
        'focus': 'Figurative Language',
        'drill':
            'Incorporate 3 idioms (e.g., "cut corners", "hit the nail") into a speech.',
        'grammar': 'Phrasal Verbs (look into, come across, put off)',
        'peer': 'Use 2 idioms naturally in your chat with your peer.'
      },
      {
        'title': 'Storytelling with Suspense & Climax',
        'focus': 'Narrative Arc & Pacing',
        'drill': 'Narrate a fictional thriller story with voice modulation.',
        'grammar': 'Past Perfect vs Past Perfect Continuous',
        'peer':
            'Take turns building a collaborative story sentence-by-sentence.'
      },
      {
        'title': 'Explaining Complex Ideas Simply',
        'focus': 'Clarity & Analogies',
        'drill':
            'Explain how AI or the Internet works to a 10-year-old in English.',
        'grammar': 'Relative Clauses (defining and non-defining)',
        'peer': 'Teach your mate a concept from your expertise.'
      },
      {
        'title': 'Spontaneous Question Answering',
        'focus': 'Zero Translation Lag',
        'drill':
            'Answer 5 random interview questions immediately without thinking in Malayalam.',
        'grammar': 'Indirect & Tag Questions (Isn\'t it, wouldn\'t you)',
        'peer': 'Rapid fire Q&A session with your peer mate.'
      },
    ];

    final index = (day - 31) % p2Topics.length;
    final topic = p2Topics[index];
    final isDay60 = day == 60;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay60
          ? '👑 Day 60 Gold Sovereign Fluency Gate'
          : 'Day $day: ${topic['title']!}',
      phaseName:
          'Phase 2: Intermediate Fluency & Complex Scenarios (Days 31–60)',
      focusArea:
          isDay60 ? '24K Professional Fluency & Leadership' : topic['focus']!,
      speakingDrill: isDay60
          ? 'Deliver a 5-minute keynote presentation in English on a topic you care about.'
          : topic['drill']!,
      grammarConcept: isDay60
          ? 'Mixed Conditionals & Inversion for Emphasis'
          : topic['grammar']!,
      peerChatMission: isDay60
          ? 'Conduct an in-depth 20-min discussion on global trends with your Pocket Mate.'
          : topic['peer']!,
      targetMinutes: 100,
      xpReward: isDay60 ? 250 : 50,
      milestoneReward:
          isDay60 ? '👑 24K Gold Sovereign Crown & Luxury Gold Theme' : '',
    );
  }

  static EnglishCurriculumLesson _generatePhase3Lesson(int day) {
    final List<Map<String, String>> p3Topics = [
      {
        'title': 'Impromptu Monologues & Thought Articulation',
        'focus': 'Instant Coherence',
        'drill':
            'Pick a random word and give a 3-minute structured speech on it immediately.',
        'grammar': 'Discourse Markers & Transition Hooks',
        'peer': 'Listen and provide critical feedback on your mate\'s speech.'
      },
      {
        'title': 'Nuance, Tone Modulation & Persuasion',
        'focus': 'Emotional Intelligence in Speech',
        'drill':
            'Deliver the same speech in three different tones: inspiring, urgent, calm.',
        'grammar': 'Subjunctive Mood & Advanced Rhetoric',
        'peer': 'Practice persuasive negotiation with your partner.'
      },
      {
        'title': 'Philosophical & Abstract Discussions',
        'focus': 'Abstract Vocabulary',
        'drill':
            'Analyze a famous proverb (e.g. "Action speaks louder than words") for 3 minutes.',
        'grammar':
            'Cleft Sentences for Focus (It is... that, What we need is...)',
        'peer': 'Discuss the future of human society in English.'
      },
      {
        'title': 'High-Stakes Interview & Q&A Mastery',
        'focus': 'Executive Presence',
        'drill':
            'Handle 3 tough behavioral questions ("Describe a major failure and what you learned").',
        'grammar': 'STAR Method Phrasing (Situation, Task, Action, Result)',
        'peer': 'Conduct a mock job interview with your mate.'
      },
      {
        'title': 'Humor, Sarcasm & Cultural Context',
        'focus': 'Native-Level Wit',
        'drill':
            'Tell a humorous anecdote in English and land the punchline naturally.',
        'grammar': 'Colloquial Expressions & Intonation Curves',
        'peer': 'Share jokes and funny real-life stories in English.'
      },
    ];

    final index = (day - 61) % p3Topics.length;
    final topic = p3Topics[index];
    final isDay90 = day == 90;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay90
          ? '💎 Day 90 Diamond Master Capstone Graduation'
          : 'Day $day: ${topic['title']!}',
      phaseName: 'Phase 3: Advanced Mastery & Thought Leadership (Days 61–90)',
      focusArea: isDay90
          ? 'Native Fluency, Public Speaking & Mastery'
          : topic['focus']!,
      speakingDrill: isDay90
          ? 'Deliver your 10-Minute Capstone Graduation Speech in English without notes.'
          : topic['drill']!,
      grammarConcept: isDay90
          ? 'Mastery of all Advanced Rhetorical Devices'
          : topic['grammar']!,
      peerChatMission: isDay90
          ? 'Congratulate fellow learners and celebrate full English fluency graduation!'
          : topic['peer']!,
      targetMinutes: 120,
      xpReward: isDay90 ? 500 : 75,
      milestoneReward: isDay90
          ? '💎 Diamond Celestial Ring, Grandmaster Trophy & Verified Certificate'
          : '',
    );
  }
}
