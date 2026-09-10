import 'package:flutter/material.dart';
import 'adventure_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🏭 MISSION 04 – WORD FACTORY  ·  Curriculum Data
// ─────────────────────────────────────────────────────────────────────────────

/// Zone / Room definitions for the 2D factory world painter.
class FactoryZone {
  final String id;
  final String label;
  final String icon;
  final Offset position; // world-space top-left
  final Size size;
  final Color wallColor;
  final bool isLocked;

  const FactoryZone({
    required this.id,
    required this.label,
    required this.icon,
    required this.position,
    required this.size,
    required this.wallColor,
    this.isLocked = false,
  });
}

// ─── Factory Zones ─────────────────────────────────────────────────────────

const kFactoryZones = <FactoryZone>[
  FactoryZone(
    id: 'entrance',
    label: 'Entrance',
    icon: '🚪',
    position: Offset(60, 220),
    size: Size(160, 160),
    wallColor: Color(0xFF1E293B),
  ),
  FactoryZone(
    id: 'word_storage',
    label: 'Word Storage',
    icon: '📦',
    position: Offset(280, 180),
    size: Size(180, 180),
    wallColor: Color(0xFF0F2A1E),
  ),
  FactoryZone(
    id: 'sentence_workshop',
    label: 'Sentence Workshop',
    icon: '🔧',
    position: Offset(520, 160),
    size: Size(200, 200),
    wallColor: Color(0xFF1A1A0F),
  ),
  FactoryZone(
    id: 'communication_room',
    label: 'Communication Room',
    icon: '📡',
    position: Offset(780, 180),
    size: Size(190, 180),
    wallColor: Color(0xFF0F1A2A),
  ),
  FactoryZone(
    id: 'grammar_lab',
    label: 'Grammar Lab',
    icon: '⚗️',
    position: Offset(1030, 170),
    size: Size(180, 190),
    wallColor: Color(0xFF1A0F2A),
  ),
  FactoryZone(
    id: 'control_room',
    label: 'Control Room',
    icon: '🖥️',
    position: Offset(1290, 200),
    size: Size(210, 200),
    wallColor: Color(0xFF2A0F0F),
  ),
];

// ─── Target Vocabulary (20 words) ─────────────────────────────────────────

const kWordFactoryVocabulary = <String>[
  'communicate',
  'activate',
  'identify',
  'repair',
  'transmit',
  'efficient',
  'reliable',
  'generate',
  'complete',
  'assemble',
  'override',
  'confirm',
  'procedure',
  'terminal',
  'sequence',
  'malfunction',
  'diagnostic',
  'component',
  'protocol',
  'restore',
];

// ─── NPCs ──────────────────────────────────────────────────────────────────

const kMission04NpcAlex = AdventureNpc(
  id: 'tech_alex',
  name: 'Alex Rivera',
  role: 'Lead Systems Technician',
  avatarEmoji: '🧑‍💻',
  worldX: 200,
  worldY: 320,
  greeting: 'System error detected. We need you to repair the communication grid!',
);

const kMission04NpcMaya = AdventureNpc(
  id: 'engineer_maya',
  name: 'Maya Chen',
  role: 'Language Protocol Engineer',
  avatarEmoji: '👩‍🔬',
  worldX: 625,
  worldY: 280,
  greeting: 'The Sentence Workshop is ready. Rebuild those broken phrase modules!',
);

const kMission04NpcDirector = AdventureNpc(
  id: 'director_kai',
  name: 'Director Kai',
  role: 'Factory Control Director',
  avatarEmoji: '👨‍✈️',
  worldX: 1390,
  worldY: 300,
  greeting: 'Final system check. Authenticate and restore full communication protocol.',
);

// ─── Level Data ───────────────────────────────────────────────────────────

const kMission04WordFactoryData = AdventureLevelData(
  levelNumber: 4,
  title: 'Mission 04 – Word Factory',
  subtitle: 'Futuristic Language Repair Facility',
  environmentName: 'Word Factory, Grid Zone 7',
  storyIntro:
      'A critical system error has shut down the communication grid. The facility screens read: "COMMUNICATION SYSTEM OFFLINE." You have been called in as the Language Repair Specialist. Move through six factory zones, collect the right words, repair broken sentences, and restore the system before the shutdown cascade is complete.',
  objective:
      'Repair all communication systems by completing 10 English challenges. Unlock the Control Room and restore the grid.',
  targetVocabularyList: kWordFactoryVocabulary,
  npcs: [
    kMission04NpcAlex,
    kMission04NpcMaya,
    kMission04NpcDirector,
  ],
  challenges: [
    // ── Challenge 1: Vocabulary Identification ─────────────────────────
    AdventureChallenge(
      id: 1,
      type: AdventureChallengeType.vocabularyInContext,
      title: 'Challenge 1: Boot the Entrance Terminal',
      npcId: 'tech_alex',
      npcDialogue:
          'The entrance terminal needs a command. The screen reads: "We need to ___ the power grid before the backup systems fail."',
      question: 'Which word correctly completes the system message?',
      options: [
        AdventureOption(
          text: 'activate',
          isCorrect: true,
          feedback:
              'Correct! "Activate" means to make something start working. The base form is needed after "need to". Terminal boots successfully.',
          reaction: 'Grid activation confirmed. Entrance door unlocked!',
        ),
        AdventureOption(
          text: 'activating',
          isCorrect: false,
          feedback:
              'After "to", use the base form (infinitive): "to activate", not "to activating".',
        ),
        AdventureOption(
          text: 'activated',
          isCorrect: false,
          feedback:
              'The past participle does not fit here. "To activate" (base form) is required after the modal "need to".',
        ),
        AdventureOption(
          text: 'activation',
          isCorrect: false,
          feedback:
              '"Activation" is a noun. A verb is required here to complete the infinitive phrase "to ___".',
        ),
      ],
      targetVocabulary: 'activate',
      vocabularyMeaning: 'To make a device or system start working; to switch on.',
      xpReward: 25,
    ),

    // ── Challenge 2: Word Repair (Grammar Fix) ─────────────────────────
    AdventureChallenge(
      id: 2,
      type: AdventureChallengeType.wordRepair,
      title: 'Challenge 2: Repair the Storage Module',
      npcId: 'tech_alex',
      npcDialogue:
          'A corrupted line is blocking Word Storage access. The error reads: "The system have been running without interruption since three days."',
      question: 'How should this sentence be correctly repaired?',
      options: [
        AdventureOption(
          text: 'The system has been running without interruption for three days.',
          isCorrect: true,
          feedback:
              'Perfect! "Has" (not "have") for a singular subject. "For" (not "since") with a duration of time. Storage unlocked.',
          reaction: 'Storage module access granted. Word containers unlocked.',
        ),
        AdventureOption(
          text: 'The system have been run without interruption for three days.',
          isCorrect: false,
          feedback:
              '"Have" is incorrect for a singular subject. Use "has". Also "run" needs the continuous "-ing" form here.',
        ),
        AdventureOption(
          text: 'The system has been running without interruption since three days.',
          isCorrect: false,
          feedback:
              'Almost! "Since" is used for a specific start point (e.g., "since Monday"). For a duration, use "for three days".',
        ),
      ],
      targetVocabulary: 'reliable',
      vocabularyMeaning: 'Consistently good in quality or performance; dependable.',
      xpReward: 30,
    ),

    // ── Challenge 3: Sentence Builder ──────────────────────────────────
    AdventureChallenge(
      id: 3,
      type: AdventureChallengeType.sentenceBuilder,
      title: 'Challenge 3: Assemble the Phrase Module',
      npcId: 'tech_alex',
      npcDialogue:
          'The assembly line is scrambled! Rearrange these word tiles to build the correct operational phrase:',
      question: 'Arrange the tiles to form a correct English sentence:',
      sentenceTiles: [
        'efficiently',
        'can',
        'The',
        'only',
        'correct',
        'machine',
        'operate',
        'with',
        'input',
      ],
      targetSentence: 'The machine can only operate with correct input',
      options: [
        AdventureOption(
          text: 'The machine can only operate with correct input.',
          isCorrect: true,
          feedback:
              'Excellent! "The machine can only operate with correct input" — the adverb "only" precisely modifies "operate". Assembly complete.',
          reaction: 'Phrase Module online. Sentence Workshop access granted!',
        ),
      ],
      targetVocabulary: 'assemble',
      vocabularyMeaning: 'To bring together component parts to create a complete whole.',
      xpReward: 35,
    ),

    // ── Challenge 4: Vocabulary in Context ─────────────────────────────
    AdventureChallenge(
      id: 4,
      type: AdventureChallengeType.vocabularyInContext,
      title: 'Challenge 4: Decode the Workshop Message',
      npcId: 'engineer_maya',
      npcDialogue:
          'The workshop terminal displays: "Run a complete ___ to identify any faulty components in the system."',
      question: 'Which word fits this technical instruction correctly?',
      options: [
        AdventureOption(
          text: 'diagnostic',
          isCorrect: true,
          feedback:
              'Correct! A "diagnostic" is a test that identifies problems in a system — the exact technical term required here.',
          reaction: 'Diagnostic initiated. Faulty components detected and flagged.',
        ),
        AdventureOption(
          text: 'diagnosis',
          isCorrect: false,
          feedback:
              '"Diagnosis" is primarily medical. In technical settings, "diagnostic" is the correct term for system testing.',
        ),
        AdventureOption(
          text: 'diagnose',
          isCorrect: false,
          feedback:
              '"Diagnose" is a verb. A noun is needed here after the article "a complete ___".',
        ),
        AdventureOption(
          text: 'diagnosed',
          isCorrect: false,
          feedback:
              '"Diagnosed" is a past-tense verb. The sentence needs a noun after "a complete".',
        ),
      ],
      targetVocabulary: 'diagnostic',
      vocabularyMeaning: 'A test or analysis procedure used to identify the source of a problem.',
      xpReward: 25,
    ),

    // ── Challenge 5: Listening Comprehension ───────────────────────────
    AdventureChallenge(
      id: 5,
      type: AdventureChallengeType.listening,
      title: 'Challenge 5: Intercept the Audio Transmission',
      npcId: 'engineer_maya',
      npcDialogue:
          'An audio burst has come through the damaged speaker. Listen carefully — it contains the access code procedure.',
      audioPrompt:
          'To restore the system, first confirm the protocol, then generate a new security sequence.',
      question: 'According to the transmission, what must you do FIRST?',
      options: [
        AdventureOption(
          text: 'Confirm the protocol',
          isCorrect: true,
          feedback:
              'Correct! "First confirm the protocol, then generate a new sequence." Order is critical in technical procedures.',
          reaction: 'Protocol confirmed. Security sequence generation is next.',
        ),
        AdventureOption(
          text: 'Generate a new security sequence',
          isCorrect: false,
          feedback:
              'This is the second step. The transmission clearly said "first confirm the protocol".',
        ),
        AdventureOption(
          text: 'Shut down the communication room',
          isCorrect: false,
          feedback:
              'This was not mentioned in the transmission at all.',
        ),
        AdventureOption(
          text: 'Repair the damaged speaker',
          isCorrect: false,
          feedback:
              'The transmission gave procedural steps, not instructions to repair hardware.',
        ),
      ],
      targetVocabulary: 'protocol',
      vocabularyMeaning: 'A set of rules or procedures governing how a system or process operates.',
      xpReward: 25,
    ),

    // ── Challenge 6: Conversation Choice ──────────────────────────────
    AdventureChallenge(
      id: 6,
      type: AdventureChallengeType.conversationChoice,
      title: 'Challenge 6: Communication Room Handshake',
      npcId: 'engineer_maya',
      npcDialogue:
          'Remote technician on radio: "Confirm your status. Are you able to proceed with the repair?"',
      question: 'Select the most professional and grammatically correct response:',
      options: [
        AdventureOption(
          text: 'Confirmed. I am proceeding with the repair now.',
          isCorrect: true,
          feedback:
              'Excellent! "Confirmed" is the standard professional acknowledgment. Present continuous "am proceeding" correctly describes the ongoing action.',
          reaction: 'Copy that. Communication Room uplink established.',
        ),
        AdventureOption(
          text: 'Yes I proceed the repair.',
          isCorrect: false,
          feedback:
              '"Proceed" requires "with" — you "proceed with" something, not "proceed the repair". Also use present continuous for an action in progress.',
        ),
        AdventureOption(
          text: 'I am confirm the repair now.',
          isCorrect: false,
          feedback:
              '"Confirm" is a verb, not an adjective. You cannot use "I am confirm". Say "I confirm" or "I am confirming".',
        ),
      ],
      targetVocabulary: 'confirm',
      vocabularyMeaning: 'To state or show that something is definitively true or correct.',
      xpReward: 25,
    ),

    // ── Challenge 7: Quick Response (Timer) ────────────────────────────
    AdventureChallenge(
      id: 7,
      type: AdventureChallengeType.quickResponse,
      title: 'Challenge 7: Emergency Override (8s Timer)',
      npcId: 'engineer_maya',
      npcDialogue:
          'ALERT: Override window closing! The screen reads: "The component ___ (fail) at 02:14 AM due to voltage fluctuation." Fill the correct form fast!',
      question: 'Choose the correct tense form for "fail" in this technical report:',
      timeLimitSeconds: 8,
      options: [
        AdventureOption(
          text: 'failed',
          isCorrect: true,
          feedback:
              'Correct! Simple past "failed" is used for a completed action at a specific past time (02:14 AM). Override accepted.',
          reaction: 'Override successful! Grammar Lock disengaged.',
        ),
        AdventureOption(
          text: 'has failed',
          isCorrect: false,
          feedback:
              'Present perfect is for unspecified past events. When a specific past time is given ("at 02:14 AM"), use simple past.',
        ),
        AdventureOption(
          text: 'was failing',
          isCorrect: false,
          feedback:
              'Past continuous describes an ongoing interrupted action — not appropriate for a completed failure event at a specific time.',
        ),
      ],
      targetVocabulary: 'malfunction',
      vocabularyMeaning: 'A failure in the way a machine or system operates.',
      xpReward: 30,
    ),

    // ── Challenge 8: Word Repair (Preposition + Parallelism) ───────────
    AdventureChallenge(
      id: 8,
      type: AdventureChallengeType.wordRepair,
      title: 'Challenge 8: Grammar Lab — Phrase Reconstruction',
      npcId: 'director_kai',
      npcDialogue:
          'Grammar Lab detected a corrupted message: "The team is responsible of generating daily progress reports and to submit them before midnight."',
      question: 'Apply the correct repair to this professional sentence:',
      options: [
        AdventureOption(
          text: 'The team is responsible for generating daily progress reports and submitting them before midnight.',
          isCorrect: true,
          feedback:
              'Perfect! "Responsible for" (not "of") is correct. Both gerunds must be parallel: "generating" and "submitting".',
          reaction: 'Grammar module restored. Lab clearance approved!',
        ),
        AdventureOption(
          text: 'The team is responsible of generating daily reports and to submit them.',
          isCorrect: false,
          feedback:
              'Two errors remain: "responsible of" → "responsible for", and "to submit" breaks the parallelism with "generating".',
        ),
        AdventureOption(
          text: 'The team is responsible for generating daily reports and to submit them.',
          isCorrect: false,
          feedback:
              'The preposition is correct now, but parallel structure is broken. After "generating", use "submitting" not "to submit".',
        ),
      ],
      targetVocabulary: 'procedure',
      vocabularyMeaning: 'An established or official way of doing something; a set of steps to follow.',
      xpReward: 30,
    ),

    // ── Challenge 9: Conditional Reading ──────────────────────────────
    AdventureChallenge(
      id: 9,
      type: AdventureChallengeType.information,
      title: 'Challenge 9: Decode the Control Room Display',
      npcId: 'director_kai',
      npcDialogue:
          'The main screen shows: "Unless the operator enters the correct sequence, the system will not restore communication."',
      question: 'What does this conditional statement mean in plain English?',
      options: [
        AdventureOption(
          text: 'The system will only restore communication IF the operator enters the correct sequence.',
          isCorrect: true,
          feedback:
              'Correct! "Unless A, B will not happen" = "B will only happen IF A." This uses "unless" as a conditional trigger.',
          reaction: 'Conditional logic decoded. Sequence input panel is now available.',
        ),
        AdventureOption(
          text: 'The system will restore communication regardless of what is entered.',
          isCorrect: false,
          feedback:
              'This is the opposite meaning. "Unless" introduces a required condition that must be met.',
        ),
        AdventureOption(
          text: 'The operator has already entered the correct sequence.',
          isCorrect: false,
          feedback:
              'The sentence describes a future condition ("will not restore"), not a completed past action.',
        ),
        AdventureOption(
          text: 'The system will never restore communication.',
          isCorrect: false,
          feedback:
              'This ignores the conditional. The system WILL restore — only under the required condition.',
        ),
      ],
      targetVocabulary: 'sequence',
      vocabularyMeaning: 'A particular order in which related things follow each other.',
      xpReward: 25,
    ),

    // ── Challenge 10: Final System Restore ─────────────────────────────
    AdventureChallenge(
      id: 10,
      type: AdventureChallengeType.finalInterview,
      title: 'Challenge 10: Final System Restore',
      npcId: 'director_kai',
      npcDialogue:
          'Last step! Director Kai needs your official system restore report. Choose the most precise and professional phrasing:',
      question: 'Select the most articulate and grammatically accurate statement:',
      options: [
        AdventureOption(
          text: 'All components have been successfully repaired and the communication system has been fully restored.',
          isCorrect: true,
          feedback:
              'Outstanding! Present perfect passive ("have been repaired", "has been restored") is the professional standard for reporting completed actions with present results.',
          reaction:
              'Communication grid is ONLINE. Mission 04 complete! You are a certified Language Engineer.',
        ),
        AdventureOption(
          text: 'All components repaired and communication system restore.',
          isCorrect: false,
          feedback:
              'This sentence is incomplete and ungrammatical. Missing auxiliary verbs: "have been repaired" and "has been restored".',
        ),
        AdventureOption(
          text: 'We did repair everything and we did restore the system.',
          isCorrect: false,
          feedback:
              '"Did repair / did restore" (emphatic past) sounds awkward in a formal report. Present perfect passive is the professional standard.',
        ),
      ],
      targetVocabulary: 'restore',
      vocabularyMeaning: 'To return something to its original condition; to bring a system back to a working state.',
      xpReward: 40,
    ),
  ],
);
