import 'package:flutter/foundation.dart';

/// 🎯 Challenge Types supported by the 2D Adventure Game Engine
enum AdventureChallengeType {
  conversation,
  information,
  vocabularyInContext,
  wordRepair,
  listening,
  conversationChoice,
  sentenceBuilder,
  quickResponse,
  directionHelp,
  finalInterview,
}

/// 👤 NPC Data Model
class AdventureNpc {
  final String id;
  final String name;
  final String role;
  final String avatarEmoji;
  final double worldX;
  final double worldY;
  final String greeting;

  const AdventureNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarEmoji,
    required this.worldX,
    required this.worldY,
    required this.greeting,
  });
}

/// 💬 Option Choice for Challenges
class AdventureOption {
  final String text;
  final bool isCorrect;
  final String feedback;
  final String? reaction;

  const AdventureOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
    this.reaction,
  });
}

/// 🧩 Single Challenge Definition
class AdventureChallenge {
  final int id;
  final AdventureChallengeType type;
  final String title;
  final String npcId;
  final String npcDialogue;
  final String question;
  final List<AdventureOption> options;
  final String? audioPrompt;
  final List<String>? sentenceTiles; // For Sentence Builder
  final String? targetSentence; // For Sentence Builder
  final int? timeLimitSeconds; // For Quick Response
  final String targetVocabulary;
  final String vocabularyMeaning;
  final int xpReward;

  const AdventureChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.npcId,
    required this.npcDialogue,
    required this.question,
    required this.options,
    this.audioPrompt,
    this.sentenceTiles,
    this.targetSentence,
    this.timeLimitSeconds,
    required this.targetVocabulary,
    required this.vocabularyMeaning,
    this.xpReward = 25,
  });
}

/// 🗺️ Reusable Level Data Container
class AdventureLevelData {
  final int levelNumber;
  final String title;
  final String subtitle;
  final String environmentName;
  final String storyIntro;
  final String objective;
  final List<AdventureNpc> npcs;
  final List<AdventureChallenge> challenges;
  final List<String> targetVocabularyList;

  const AdventureLevelData({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.environmentName,
    required this.storyIntro,
    required this.objective,
    required this.npcs,
    required this.challenges,
    required this.targetVocabularyList,
  });
}

/// 🏢 MISSION 01 CURRICULUM: The First Conversation (Modern Office & Career Center)
const kMission01NpcSarah = AdventureNpc(
  id: 'receptionist_sarah',
  name: 'Sarah Jenkins',
  role: 'Senior Reception Host',
  avatarEmoji: '👩‍💼',
  worldX: 380,
  worldY: 340,
  greeting: 'Good morning! Welcome to Apex Career Center.',
);

const kMission01NpcDavid = AdventureNpc(
  id: 'colleague_david',
  name: 'David Chen',
  role: 'Software Team Lead',
  avatarEmoji: '👨‍💻',
  worldX: 680,
  worldY: 260,
  greeting: 'Hey there! Are you here for the technical interview?',
);

const kMission01NpcMiller = AdventureNpc(
  id: 'director_miller',
  name: 'Director Arthur Miller',
  role: 'Hiring Director',
  avatarEmoji: '👨‍💼',
  worldX: 980,
  worldY: 280,
  greeting: 'Welcome. Please have a seat. Let us begin your interview.',
);

const kMission01LevelData = AdventureLevelData(
  levelNumber: 1,
  title: 'Mission 01 – The First Conversation',
  subtitle: 'Modern Office & Career Center',
  environmentName: 'Apex Headquarters, 14th Floor',
  storyIntro:
      'You have an important career appointment scheduled at 10:00 AM at Apex Corporate Tower. Enter the reception, navigate the office, communicate naturally with staff, and ace your first technical interview!',
  objective:
      'Explore the office, complete 10 real-world English communication challenges, and earn your Career Certification!',
  targetVocabularyList: [
    'appointment',
    'opportunity',
    'experience',
    'available',
    'schedule',
    'information',
    'communication',
    'position',
    'requirement',
    'confident',
    'improve',
    'responsible',
  ],
  npcs: [
    kMission01NpcSarah,
    kMission01NpcDavid,
    kMission01NpcMiller,
  ],
  challenges: [
    // Challenge 1: Reception Check-in
    AdventureChallenge(
      id: 1,
      type: AdventureChallengeType.conversation,
      title: 'Challenge 1: Reception Check-in',
      npcId: 'receptionist_sarah',
      npcDialogue: 'Good morning! Welcome to Apex. Do you have an appointment?',
      question: 'Choose the most natural and professional response:',
      options: [
        AdventureOption(
          text: 'Yes, I have an appointment at 10:00 AM.',
          isCorrect: true,
          feedback:
              'Excellent! "I have an appointment" is the natural, polite way to confirm scheduled meetings.',
          reaction: 'Wonderful! Let me look up your scheduled visit in our system.',
        ),
        AdventureOption(
          text: 'Yes, I am appointment.',
          isCorrect: false,
          feedback:
              'Incorrect. "Appointment" is an event or meeting, not a person. Use "I have an appointment".',
          reaction: 'Pardon? Do you have a meeting scheduled?',
        ),
        AdventureOption(
          text: 'Yes, yesterday.',
          isCorrect: false,
          feedback:
              '"Yesterday" refers to the past. Since your meeting is today, say "I have an appointment today at 10:00 AM".',
          reaction: 'Yesterday? But today is your scheduled appointment date.',
        ),
      ],
      targetVocabulary: 'appointment',
      vocabularyMeaning: 'An arrangement to meet someone at a particular time and place.',
      xpReward: 25,
    ),

    // Challenge 2: Information
    AdventureChallenge(
      id: 2,
      type: AdventureChallengeType.information,
      title: 'Challenge 2: Confirming Your Name',
      npcId: 'receptionist_sarah',
      npcDialogue: 'Could you please confirm your name for the visitor badge?',
      question: 'How should you naturally state your identity in a business setting?',
      options: [
        AdventureOption(
          text: 'My name is Alex. Nice to meet you.',
          isCorrect: true,
          feedback:
              'Perfect! "My name is [Name]" is polite, professional, and clear worldwide.',
          reaction: 'Pleasure to meet you, Alex. Here is your guest badge.',
        ),
        AdventureOption(
          text: 'I am name Alex.',
          isCorrect: false,
          feedback:
              'Incorrect. Saying "I am name Alex" is ungrammatical. Say "My name is Alex" or simply "I am Alex".',
        ),
        AdventureOption(
          text: 'Myself Alex name.',
          isCorrect: false,
          feedback:
              'Avoid using "Myself [Name]" in modern English. It is considered awkward in international business communication.',
        ),
      ],
      targetVocabulary: 'information',
      vocabularyMeaning: 'Facts or details provided or learned about something or someone.',
      xpReward: 25,
    ),

    // Challenge 3: Vocabulary in Context
    AdventureChallenge(
      id: 3,
      type: AdventureChallengeType.vocabularyInContext,
      title: 'Challenge 3: Workplace Context Clues',
      npcId: 'receptionist_sarah',
      npcDialogue:
          'Please take a seat in the waiting lounge. Director Miller will call you shortly.',
      question: 'In practical business English, what does "shortly" mean?',
      options: [
        AdventureOption(
          text: 'Very soon (in a few minutes)',
          isCorrect: true,
          feedback:
              'Spot on! "Shortly" means very soon or in a brief period of time.',
          reaction: 'Feel free to help yourself to coffee while you wait.',
        ),
        AdventureOption(
          text: 'Tomorrow morning',
          isCorrect: false,
          feedback:
              '"Shortly" refers to the immediate near future, not the next day.',
        ),
        AdventureOption(
          text: 'Very slowly',
          isCorrect: false,
          feedback:
              '"Shortly" refers to time ("soon"), not the speed or pace of movement.',
        ),
        AdventureOption(
          text: 'Never',
          isCorrect: false,
          feedback:
              'Incorrect. "Shortly" indicates an upcoming action that will happen soon.',
        ),
      ],
      targetVocabulary: 'schedule',
      vocabularyMeaning: 'A plan that gives expected times for different events.',
      xpReward: 25,
    ),

    // Challenge 4: Word & Tense Repair
    AdventureChallenge(
      id: 4,
      type: AdventureChallengeType.wordRepair,
      title: 'Challenge 4: Resume Tense Correction',
      npcId: 'colleague_david',
      npcDialogue:
          'I saw a draft line on your profile: "I am working here since three years." That needs a quick fix!',
      question: 'How should this sentence be correctly repaired?',
      options: [
        AdventureOption(
          text: 'I have been working here for three years.',
          isCorrect: true,
          feedback:
              'Outstanding! For ongoing duration spanning from the past until now, use the Present Perfect Continuous ("have been working") with "for [duration]".',
          reaction: 'Exactly right! That sounds clean and professional.',
        ),
        AdventureOption(
          text: 'I am work here three years.',
          isCorrect: false,
          feedback:
              'Incorrect grammar. "Am work" mixes auxiliary and base verb forms incorrectly.',
        ),
        AdventureOption(
          text: 'I working here since three years.',
          isCorrect: false,
          feedback:
              'Missing auxiliary verb, and "since" is for specific start points (e.g. "since 2021"), while "for" is for durations ("for three years").',
        ),
      ],
      targetVocabulary: 'experience',
      vocabularyMeaning: 'Practical contact with and observation of facts or events.',
      xpReward: 30,
    ),

    // Challenge 5: Listening Comprehension
    AdventureChallenge(
      id: 5,
      type: AdventureChallengeType.listening,
      title: 'Challenge 5: Audio Listening Clue',
      npcId: 'receptionist_sarah',
      npcDialogue: 'The hiring director is currently in a briefing. Let me check his calendar.',
      audioPrompt: 'The director is available after lunch.',
      question: 'Listen carefully: When is the director available?',
      options: [
        AdventureOption(
          text: 'Before lunch',
          isCorrect: false,
          feedback: 'The speaker said "after lunch", not before.',
        ),
        AdventureOption(
          text: 'After lunch',
          isCorrect: true,
          feedback:
              'Great listening! The sentence was: "The director is available after lunch."',
          reaction: 'Yes! He will be free right after 1:00 PM.',
        ),
        AdventureOption(
          text: 'Tomorrow evening',
          isCorrect: false,
          feedback: 'The speaker specifically mentioned after lunch today.',
        ),
        AdventureOption(
          text: 'Next Monday',
          isCorrect: false,
          feedback: 'Incorrect timeframe heard.',
        ),
      ],
      targetVocabulary: 'available',
      vocabularyMeaning: 'Able to be used or obtained; free to see someone or do something.',
      xpReward: 25,
    ),

    // Challenge 6: Conversation Choice
    AdventureChallenge(
      id: 6,
      type: AdventureChallengeType.conversationChoice,
      title: 'Challenge 6: Career Interest',
      npcId: 'colleague_david',
      npcDialogue: 'So Alex, what kind of work are you primarily interested in?',
      question: 'Select the most articulate and grammatically sound answer:',
      options: [
        AdventureOption(
          text: 'I am interested in software development and building scalable apps.',
          isCorrect: true,
          feedback:
              'Well said! The phrase "I am interested in [noun / gerund]" is the natural expression of professional interest.',
          reaction: 'Awesome! That is exactly what our engineering division focuses on.',
        ),
        AdventureOption(
          text: 'I interest software development.',
          isCorrect: false,
          feedback:
              'Incorrect. "Interest" is not used this way as a transitive verb for personal preferences. Say "I am interested in...".',
        ),
        AdventureOption(
          text: 'I am software interest.',
          isCorrect: false,
          feedback:
              'Ungrammatical and confusing to the listener.',
        ),
      ],
      targetVocabulary: 'opportunity',
      vocabularyMeaning: 'A set of circumstances that makes it possible to do something.',
      xpReward: 25,
    ),

    // Challenge 7: Interactive Sentence Builder
    AdventureChallenge(
      id: 7,
      type: AdventureChallengeType.sentenceBuilder,
      title: 'Challenge 7: Interactive Sentence Builder',
      npcId: 'colleague_david',
      npcDialogue: 'Show me how you articulate your background. Arrange the tiles into a cohesive sentence:',
      question: 'Arrange the tiles to formulate your qualification sentence:',
      sentenceTiles: [
        'have',
        'I',
        'experience',
        'three',
        'years',
        'of',
        'development',
      ],
      targetSentence: 'I have three years of development experience',
      options: [
        AdventureOption(
          text: 'I have three years of development experience.',
          isCorrect: true,
          feedback:
              'Brilliant formulation! Subject ("I") + Verb ("have") + Quantifier ("three years of") + Noun phrase ("development experience").',
          reaction: 'Impressive! Clear, concise, and impactful.',
        ),
      ],
      targetVocabulary: 'position',
      vocabularyMeaning: 'A post of employment; a job with specific responsibilities.',
      xpReward: 35,
    ),

    // Challenge 8: Quick Response (8 Seconds)
    AdventureChallenge(
      id: 8,
      type: AdventureChallengeType.quickResponse,
      title: 'Challenge 8: Quick Response (8s Timer)',
      npcId: 'director_miller',
      npcDialogue: 'Let us begin: Why do you want this job at our company?',
      question: 'Answer with clarity and confidence before the timer runs out!',
      timeLimitSeconds: 8,
      options: [
        AdventureOption(
          text: 'I want to learn, contribute my skills, and grow in this role.',
          isCorrect: true,
          feedback:
              'Superb quick response! Expresses motivation, willingness to contribute, and career growth.',
          reaction: 'Strong motivation. That is the exact mindset we appreciate.',
        ),
        AdventureOption(
          text: 'Because I need money only.',
          isCorrect: false,
          feedback:
              'Too blunt and lacks professional enthusiasm or alignment with the role.',
        ),
        AdventureOption(
          text: 'I don’t know, somebody told me to apply.',
          isCorrect: false,
          feedback:
              'Shows lack of initiative and low engagement.',
        ),
      ],
      targetVocabulary: 'confident',
      vocabularyMeaning: 'Feeling or showing certainty about something or one’s abilities.',
      xpReward: 30,
    ),

    // Challenge 9: Direction & Navigation Help
    AdventureChallenge(
      id: 9,
      type: AdventureChallengeType.directionHelp,
      title: 'Challenge 9: Workplace Navigation',
      npcId: 'colleague_david',
      npcDialogue: 'Excuse me Alex, do you know where Meeting Room 3 is located?',
      question: 'Select the polite, clear way to give directions:',
      options: [
        AdventureOption(
          text: 'Sure! It is down the corridor on your right, past the glass door.',
          isCorrect: true,
          feedback:
              'Perfect! Giving landmarks ("down the corridor", "on your right") makes directions intuitive and easy to follow.',
          reaction: 'Thanks a lot, Alex! Really appreciate your help.',
        ),
        AdventureOption(
          text: 'I am not room.',
          isCorrect: false,
          feedback:
              'Completely incorrect and illogical sentence.',
        ),
        AdventureOption(
          text: 'Room right go.',
          isCorrect: false,
          feedback:
              'Broken phrasing. Use full natural prepositional phrases.',
        ),
      ],
      targetVocabulary: 'communication',
      vocabularyMeaning: 'The successful conveying or sharing of ideas and feelings.',
      xpReward: 25,
    ),

    // Challenge 10: Executive Interview Room Finale
    AdventureChallenge(
      id: 10,
      type: AdventureChallengeType.finalInterview,
      title: 'Challenge 10: Executive Interview Finale',
      npcId: 'director_miller',
      npcDialogue:
          'Final Question: What makes you responsible and ready to improve our team?',
      question: 'Deliver your concluding closing statement to Director Miller:',
      options: [
        AdventureOption(
          text:
              'I am responsible, eager to improve through feedback, and committed to high-quality results.',
          isCorrect: true,
          feedback:
              'Phenomenal closing! You demonstrated accountability, adaptability, and dedication to excellence.',
          reaction:
              'Splendid interview, Alex. You have officially passed Mission 01 with flying colors!',
        ),
        AdventureOption(
          text: 'I am never make mistakes and I know everything already.',
          isCorrect: false,
          feedback:
              'Sounds arrogant and unrealistic. Employers value humility and continuous learning.',
        ),
        AdventureOption(
          text: 'Maybe I try if I have time.',
          isCorrect: false,
          feedback:
              'Sounds disengaged and uncommitted.',
        ),
      ],
      targetVocabulary: 'responsible',
      vocabularyMeaning: 'Having an obligation to do something, or having control over or care for someone.',
      xpReward: 40,
    ),
  ],
);
