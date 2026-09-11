import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// All challenge types supported by the Word Detective investigation system.
enum DetectiveChallengeType {
  readingComprehension,
  detailFinding,
  messageAnalysis,
  timelineReasoning,
  vocabularyContext,
  listeningClue,
  clueConnection,
  redHerring,
  npcQuestioning,
  caseSolution,
}

/// Journal tab identifiers.
enum JournalTab { caseFile, clues, timeline, people, locations }

// ─────────────────────────────────────────────────────────────────────────────
// CLUE DATA
// ─────────────────────────────────────────────────────────────────────────────

/// Importance of a clue to the main case.
enum ClueImportance { critical, supporting, irrelevant }

/// A single discovered clue stored in the Detective Journal.
class ClueData {
  final String id;
  final String icon;
  final String title;
  final String text;
  final String? personName;
  final String? locationName;
  final String? timeStamp;
  final ClueImportance importance;
  final List<String> relatedClueIds;

  const ClueData({
    required this.id,
    required this.icon,
    required this.title,
    required this.text,
    this.personName,
    this.locationName,
    this.timeStamp,
    this.importance = ClueImportance.critical,
    this.relatedClueIds = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMELINE EVENT
// ─────────────────────────────────────────────────────────────────────────────

/// One event the player discovers and places on the interactive timeline.
class TimelineEventData {
  final String id;
  final String time;
  final String description;
  final String? personName;
  final String? locationName;
  final bool isDiscovered;

  const TimelineEventData({
    required this.id,
    required this.time,
    required this.description,
    this.personName,
    this.locationName,
    this.isDiscovered = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ANSWER OPTION
// ─────────────────────────────────────────────────────────────────────────────

/// One selectable option in a detective challenge.
class DetectiveOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String explanation;
  final int xpReward;

  const DetectiveOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.explanation,
    this.xpReward = 20,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// INVESTIGATION CHALLENGE
// ─────────────────────────────────────────────────────────────────────────────

/// One interactive investigation challenge the player must solve.
class InvestigationChallenge {
  final int id;
  final DetectiveChallengeType type;
  final String areaId;
  final String areaTitle;
  final String title;
  final String clueBriefing;    // text displayed on the clue card
  final String spokenText;      // TTS spoken text
  final String question;
  final List<DetectiveOption> options;
  final int correctOptionIndex;
  final String hint1;
  final String hint2;
  final String hint3;
  final String? audioTranscript;  // for listeningClue type
  final ClueData? rewardClue;     // clue added to journal on success
  final int clueXpBonus;

  const InvestigationChallenge({
    required this.id,
    required this.type,
    required this.areaId,
    required this.areaTitle,
    required this.title,
    required this.clueBriefing,
    required this.spokenText,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.hint1,
    this.hint2 = '',
    this.hint3 = '',
    this.audioTranscript,
    this.rewardClue,
    this.clueXpBonus = 10,
  });

  DetectiveOption get correctOption => options[correctOptionIndex];
}

// ─────────────────────────────────────────────────────────────────────────────
// OFFICE AREA
// ─────────────────────────────────────────────────────────────────────────────

/// A connected area of the 2D office/co-working building.
class OfficeArea {
  final String id;
  final String name;
  final String icon;
  final double startX;
  final double endX;
  final Color primaryColor;
  final Color accentColor;

  const OfficeArea({
    required this.id,
    required this.name,
    required this.icon,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.accentColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SUSPECT DATA
// ─────────────────────────────────────────────────────────────────────────────

/// A person of interest in the investigation.
class SuspectData {
  final String id;
  final String name;
  final String role;
  final String icon;
  final String statement;

  const SuspectData({
    required this.id,
    required this.name,
    required this.role,
    required this.icon,
    required this.statement,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL DATA
// ─────────────────────────────────────────────────────────────────────────────

/// Complete curriculum and world data for Mission 10 – Word Detective.
class WordDetectiveLevelData {
  final String missionId;
  final String title;
  final String subtitle;
  final String tagline;
  final String caseTitle;
  final String missingObject;
  final String incidentLocation;
  final String incidentTimeRange;
  final String openingBriefing;
  final List<String> targetVocabulary;
  final List<OfficeArea> areas;
  final List<SuspectData> suspects;
  final List<TimelineEventData> masterTimeline;
  final List<InvestigationChallenge> challenges;
  final String finalSolution;
  final String finalRevealText;

  const WordDetectiveLevelData({
    required this.missionId,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.caseTitle,
    required this.missingObject,
    required this.incidentLocation,
    required this.incidentTimeRange,
    required this.openingBriefing,
    required this.targetVocabulary,
    required this.areas,
    required this.suspects,
    required this.masterTimeline,
    required this.challenges,
    required this.finalSolution,
    required this.finalRevealText,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 10 CURRICULUM DATA
// ─────────────────────────────────────────────────────────────────────────────

final kMission10WordDetectiveData = WordDetectiveLevelData(
  missionId: '10',
  title: 'Mission 10 – Word Detective',
  subtitle: '2D Mystery Investigation & Inference Game',
  tagline: 'Read the clues. Understand the English. Solve the mystery.',
  caseTitle: 'CASE #001 – Missing Prototype',
  missingObject: 'Prototype Device',
  incidentLocation: 'Meeting Room 3',
  incidentTimeRange: '2:00 PM – 4:00 PM',
  openingBriefing:
      'Something important is missing from Meeting Room 3. A small box containing a prototype device has disappeared. Find out what happened before the manager arrives.',
  targetVocabulary: const [
    'prototype',
    'missing',
    'access',
    'borrowed',
    'returned',
    'stored',
    'temporary',
    'available',
    'schedule',
    'confirm',
    'arrived',
    'left',
    'entered',
    'shortly',
    'before',
    'after',
    'during',
    'between',
    'evidence',
    'clue',
    'incident',
    'investigate',
    'suspect',
    'solution',
  ],
  areas: const [
    OfficeArea(
      id: 'lobby',
      name: 'Lobby',
      icon: '🏢',
      startX: 0,
      endX: 340,
      primaryColor: Color(0xFF1E3A5F),
      accentColor: Color(0xFF3B82F6),
    ),
    OfficeArea(
      id: 'reception',
      name: 'Reception',
      icon: '🗂',
      startX: 340,
      endX: 680,
      primaryColor: Color(0xFF1A3A2F),
      accentColor: Color(0xFF10B981),
    ),
    OfficeArea(
      id: 'corridor',
      name: 'Corridor',
      icon: '🚪',
      startX: 680,
      endX: 1020,
      primaryColor: Color(0xFF2D1B69),
      accentColor: Color(0xFF8B5CF6),
    ),
    OfficeArea(
      id: 'meeting_room_3',
      name: 'Meeting Room 3',
      icon: '📋',
      startX: 1020,
      endX: 1360,
      primaryColor: Color(0xFF3B1F1F),
      accentColor: Color(0xFFEF4444),
    ),
    OfficeArea(
      id: 'coffee_area',
      name: 'Coffee Area',
      icon: '☕',
      startX: 1360,
      endX: 1700,
      primaryColor: Color(0xFF3B2F1A),
      accentColor: Color(0xFFF59E0B),
    ),
    OfficeArea(
      id: 'storage_room',
      name: 'Storage Room',
      icon: '📦',
      startX: 1700,
      endX: 2040,
      primaryColor: Color(0xFF1A2B3B),
      accentColor: Color(0xFF06B6D4),
    ),
  ],
  suspects: const [
    SuspectData(
      id: 'daniel',
      name: 'Daniel',
      role: 'Project Lead',
      icon: '👨‍💼',
      statement: 'I entered Room 3 at 2:15 to set up for the client meeting.',
    ),
    SuspectData(
      id: 'sarah',
      name: 'Sarah',
      role: 'Sales Manager',
      icon: '👩‍💼',
      statement: 'I arrived around 2:30 and left before the client arrived.',
    ),
    SuspectData(
      id: 'manager',
      name: 'Manager (You)',
      role: 'Investigating',
      icon: '🕵️',
      statement: 'I checked the room at 3:15. The device was gone.',
    ),
  ],
  masterTimeline: const [
    TimelineEventData(
      id: 'te1',
      time: '2:00 PM',
      description: 'Team meeting begins in Room 3.',
      locationName: 'Meeting Room 3',
    ),
    TimelineEventData(
      id: 'te2',
      time: '2:10 PM',
      description: 'Daniel borrows the access card.',
      personName: 'Daniel',
    ),
    TimelineEventData(
      id: 'te3',
      time: '2:15 PM',
      description: 'Daniel enters Meeting Room 3.',
      personName: 'Daniel',
      locationName: 'Meeting Room 3',
    ),
    TimelineEventData(
      id: 'te4',
      time: '2:20 PM',
      description: 'Prototype device last seen on the table.',
      locationName: 'Meeting Room 3',
    ),
    TimelineEventData(
      id: 'te5',
      time: '2:30 PM',
      description: 'Sarah enters Meeting Room 3.',
      personName: 'Sarah',
      locationName: 'Meeting Room 3',
    ),
    TimelineEventData(
      id: 'te6',
      time: '2:40 PM',
      description: 'Coffee machine repaired.',
      locationName: 'Coffee Area',
    ),
    TimelineEventData(
      id: 'te7',
      time: '3:00 PM',
      description: 'Sarah leaves Meeting Room 3.',
      personName: 'Sarah',
      locationName: 'Corridor',
    ),
    TimelineEventData(
      id: 'te8',
      time: '3:05 PM',
      description: 'Daniel returns the access card.',
      personName: 'Daniel',
    ),
    TimelineEventData(
      id: 'te9',
      time: '3:15 PM',
      description: 'Manager discovers the device is missing.',
      locationName: 'Meeting Room 3',
    ),
  ],
  challenges: [
    // CHALLENGE 1 – Reading Comprehension: Room Schedule
    InvestigationChallenge(
      id: 1,
      type: DetectiveChallengeType.readingComprehension,
      areaId: 'reception',
      areaTitle: 'Reception Desk',
      title: 'Read the Meeting Schedule',
      clueBriefing:
          'ROOM 3 SCHEDULE\n\n2:00 PM — Team Meeting\n3:30 PM — Client Discussion\n4:00 PM — Room Closed',
      spokenText:
          'Room 3 schedule. Two PM: Team Meeting. Three thirty PM: Client Discussion. Four PM: Room Closed.',
      question: 'When was Room 3 scheduled to close?',
      options: [
        DetectiveOption(
          id: 'c1a',
          text: 'A. 2:00 PM',
          isCorrect: false,
          explanation: 'Incorrect. 2:00 PM is when the team meeting started.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c1b',
          text: 'B. 3:30 PM',
          isCorrect: false,
          explanation:
              'Incorrect. 3:30 PM is the client discussion, not closing time.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c1c',
          text: 'C. 4:00 PM ✓',
          isCorrect: true,
          explanation:
              'Correct! The schedule clearly states "4:00 PM — Room Closed". This is information scanning.',
          xpReward: 20,
        ),
        DetectiveOption(
          id: 'c1d',
          text: 'D. 5:00 PM',
          isCorrect: false,
          explanation: 'Incorrect. 5:00 PM is not mentioned on the schedule.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 2,
      hint1: 'Look at the last entry on the schedule.',
      hint2: 'The question asks about closing time, not the last meeting.',
      hint3: '"Room Closed" is the key phrase. What time is next to it?',
      rewardClue: ClueData(
        id: 'clue_01',
        icon: '📋',
        title: 'Room 3 Schedule',
        text: 'Meeting Room 3 was booked from 2:00 PM. The room was scheduled to close at 4:00 PM.',
        locationName: 'Meeting Room 3',
        timeStamp: '2:00 PM – 4:00 PM',
        importance: ClueImportance.supporting,
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 2 – Detail Finding: Access Card Note
    InvestigationChallenge(
      id: 2,
      type: DetectiveChallengeType.detailFinding,
      areaId: 'reception',
      areaTitle: 'Reception Logbook',
      title: 'Find the Key Detail',
      clueBriefing:
          'NOTE FOUND AT RECEPTION:\n\n"Daniel borrowed the access card at 2:10 PM and returned it at 3:05 PM."',
      spokenText:
          'Note found. Daniel borrowed the access card at two ten PM and returned it at three oh five PM.',
      question: 'When did Daniel return the access card?',
      options: [
        DetectiveOption(
          id: 'c2a',
          text: 'A. 2:10 PM',
          isCorrect: false,
          explanation:
              'Incorrect. 2:10 PM is when he borrowed it, not returned it.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c2b',
          text: 'B. 3:00 PM',
          isCorrect: false,
          explanation: 'Incorrect. The note says 3:05 PM, not 3:00 PM.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c2c',
          text: 'C. 3:05 PM ✓',
          isCorrect: true,
          explanation:
              'Correct! The note clearly states "returned it at 3:05 PM". Daniel had the card for nearly an hour.',
          xpReward: 25,
        ),
        DetectiveOption(
          id: 'c2d',
          text: 'D. 3:15 PM',
          isCorrect: false,
          explanation: 'Incorrect. 3:15 PM is not mentioned in this note.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 2,
      hint1: 'The note has two times. You need the second one.',
      hint2: '"Returned" means he gave it back. When did he give it back?',
      hint3: 'Look at "returned it at ___". What number fills that blank?',
      rewardClue: ClueData(
        id: 'clue_02',
        icon: '🔑',
        title: 'Access Card Record',
        text:
            'Daniel borrowed the access card at 2:10 PM and returned it at 3:05 PM.',
        personName: 'Daniel',
        timeStamp: '2:10 PM – 3:05 PM',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_01'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 3 – Message Analysis: Phone Message
    InvestigationChallenge(
      id: 3,
      type: DetectiveChallengeType.messageAnalysis,
      areaId: 'corridor',
      areaTitle: 'Corridor Notice Board',
      title: 'Analyse the Phone Message',
      clueBriefing:
          'PHONE MESSAGE FOUND:\n\n"Can you meet me near Room 3 after the client leaves?"',
      spokenText:
          'Phone message: Can you meet me near Room 3 after the client leaves?',
      question: 'Where should the person meet according to the message?',
      options: [
        DetectiveOption(
          id: 'c3a',
          text: 'A. Reception',
          isCorrect: false,
          explanation: 'Incorrect. The message says "near Room 3".',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c3b',
          text: 'B. Near Room 3 ✓',
          isCorrect: true,
          explanation:
              'Correct! The message says "meet me near Room 3." This message is suspicious — why meet there?',
          xpReward: 20,
        ),
        DetectiveOption(
          id: 'c3c',
          text: 'C. Café',
          isCorrect: false,
          explanation: 'Incorrect. The café is not mentioned.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c3d',
          text: 'D. Parking area',
          isCorrect: false,
          explanation: 'Incorrect. The parking area is not mentioned.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 1,
      hint1: 'The message uses the word "near". Near what location?',
      hint2: 'Find the words that name a place in the message.',
      hint3: '"Meet me near ___." What fills that space?',
      rewardClue: ClueData(
        id: 'clue_03',
        icon: '📱',
        title: 'Suspicious Phone Message',
        text:
            'An anonymous message asked someone to meet "near Room 3 after the client leaves."',
        locationName: 'Meeting Room 3',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_02'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 4 – Timeline Reasoning: Who was in Room 3 at 3:00 PM?
    InvestigationChallenge(
      id: 4,
      type: DetectiveChallengeType.timelineReasoning,
      areaId: 'meeting_room_3',
      areaTitle: 'Meeting Room 3',
      title: 'Analyse the Timeline',
      clueBriefing:
          'TIMELINE:\n\n2:00 PM — Meeting starts\n2:15 PM — Daniel enters\n2:30 PM — Sarah enters\n3:00 PM — Sarah leaves\n3:05 PM — Daniel leaves\n3:15 PM — Manager checks room',
      spokenText:
          'Timeline. Two PM: meeting starts. Two fifteen: Daniel enters. Two thirty: Sarah enters. Three PM: Sarah leaves. Three oh five: Daniel leaves. Three fifteen: Manager checks.',
      question: 'Who was still in the room at exactly 3:00 PM?',
      options: [
        DetectiveOption(
          id: 'c4a',
          text: 'A. Nobody',
          isCorrect: false,
          explanation:
              'Incorrect. Daniel had not yet left at 3:00 PM. He left at 3:05 PM.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c4b',
          text: 'B. Sarah only',
          isCorrect: false,
          explanation:
              'Incorrect. Sarah left at 3:00 PM. Daniel was still inside.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c4c',
          text: 'C. Daniel only ✓',
          isCorrect: true,
          explanation:
              'Correct! Sarah left at 3:00 PM. Daniel left at 3:05 PM. So Daniel was alone in the room at 3:00 PM.',
          xpReward: 30,
        ),
        DetectiveOption(
          id: 'c4d',
          text: 'D. Both Daniel and Sarah',
          isCorrect: false,
          explanation:
              'Incorrect. At 3:00 PM Sarah was leaving, and Daniel was still inside.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 2,
      hint1: 'Check the timeline carefully. When did each person leave?',
      hint2: 'Sarah leaves at 3:00. Daniel leaves at 3:05. Who is still inside at 3:00?',
      hint3: 'At exactly 3:00 PM, one person is still in the room for 5 more minutes.',
      rewardClue: ClueData(
        id: 'clue_04',
        icon: '⏰',
        title: 'Alone in Room 3',
        text:
            'Daniel was alone in Meeting Room 3 at 3:00 PM. He did not leave until 3:05 PM.',
        personName: 'Daniel',
        timeStamp: '3:00 PM – 3:05 PM',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_02', 'clue_03'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 5 – Vocabulary in Context
    InvestigationChallenge(
      id: 5,
      type: DetectiveChallengeType.vocabularyContext,
      areaId: 'meeting_room_3',
      areaTitle: 'Document on Table',
      title: 'Understand the Vocabulary',
      clueBriefing:
          'NOTE ON THE TABLE:\n\n"The device was stored in the cabinet temporarily."',
      spokenText:
          'Note on the table. The device was stored in the cabinet temporarily.',
      question: 'What does "temporarily" mean in this note?',
      options: [
        DetectiveOption(
          id: 'c5a',
          text: 'A. For a short time ✓',
          isCorrect: true,
          explanation:
              'Correct! "Temporarily" means for a limited period — not permanently. This means someone planned to move it.',
          xpReward: 20,
        ),
        DetectiveOption(
          id: 'c5b',
          text: 'B. Permanently',
          isCorrect: false,
          explanation:
              'Incorrect. "Permanently" means forever. "Temporarily" is the opposite.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c5c',
          text: 'C. Secretly',
          isCorrect: false,
          explanation:
              'Incorrect. "Secretly" relates to hidden action, not time duration.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c5d',
          text: 'D. Carefully',
          isCorrect: false,
          explanation:
              'Incorrect. "Carefully" describes how something is done, not for how long.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 0,
      hint1: 'Think about the opposite of "permanently".',
      hint2: '"Temporary" things do not last long. What does that mean here?',
      hint3: 'The device was put there for a short period, not forever.',
      rewardClue: ClueData(
        id: 'clue_05',
        icon: '📄',
        title: 'Temporary Storage Note',
        text:
            'A note confirms the device was stored in a cabinet temporarily — suggesting it was meant to be moved.',
        locationName: 'Meeting Room 3',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_04'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 6 – Listening Clue: Voice Message
    InvestigationChallenge(
      id: 6,
      type: DetectiveChallengeType.listeningClue,
      areaId: 'corridor',
      areaTitle: 'Corridor Voice Recorder',
      title: 'Listen to the Voice Message',
      clueBriefing: 'VOICE RECORDER – Play audio clue',
      spokenText:
          'I left the room shortly after Daniel arrived.',
      audioTranscript:
          '"I left the room shortly after Daniel arrived."',
      question: 'When did the speaker leave the room?',
      options: [
        DetectiveOption(
          id: 'c6a',
          text: 'A. Before Daniel arrived',
          isCorrect: false,
          explanation:
              'Incorrect. The speaker left AFTER Daniel arrived, not before.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c6b',
          text: 'B. Shortly after Daniel arrived ✓',
          isCorrect: true,
          explanation:
              'Correct! "Shortly after Daniel arrived" means soon after he came in. This places the speaker in the room around 2:15 PM.',
          xpReward: 25,
        ),
        DetectiveOption(
          id: 'c6c',
          text: 'C. The next day',
          isCorrect: false,
          explanation: 'Incorrect. The voice says "shortly after" — very soon.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c6d',
          text: 'D. At the end of the meeting',
          isCorrect: false,
          explanation:
              'Incorrect. The speaker left shortly after Daniel arrived at 2:15, not at the meeting end.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 1,
      hint1: 'Listen for the time word. "Shortly" means a very short time.',
      hint2: 'The speaker left AFTER Daniel arrived. Find his arrival time from your journal.',
      hint3: '"Shortly after Daniel arrived" = very soon after 2:15 PM.',
      rewardClue: ClueData(
        id: 'clue_06',
        icon: '🎙️',
        title: 'Voice Recording',
        text:
            'Unknown speaker confirms: "I left the room shortly after Daniel arrived." This was around 2:15–2:20 PM.',
        timeStamp: '2:15 – 2:20 PM',
        importance: ClueImportance.supporting,
        relatedClueIds: ['clue_04'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 7 – Clue Connection: Who saw the device after 2:20?
    InvestigationChallenge(
      id: 7,
      type: DetectiveChallengeType.clueConnection,
      areaId: 'meeting_room_3',
      areaTitle: 'Investigation Board',
      title: 'Connect the Clues',
      clueBriefing:
          'CLUE BOARD:\n\nCLUE A: Daniel entered at 2:15 PM.\nCLUE B: The device was last seen at 2:20 PM.\nCLUE C: Sarah arrived at 2:30 PM.',
      spokenText:
          'Clue A: Daniel entered at two fifteen. Clue B: The device was last seen at two twenty. Clue C: Sarah arrived at two thirty.',
      question: 'Who could have seen the device AFTER 2:20 PM?',
      options: [
        DetectiveOption(
          id: 'c7a',
          text: 'A. Only Daniel',
          isCorrect: false,
          explanation:
              'Incorrect. Daniel was present, but Sarah also arrived later and may have seen it.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c7b',
          text: 'B. Sarah ✓',
          isCorrect: true,
          explanation:
              'Correct! Sarah arrived at 2:30 — after the device was last seen at 2:20. She was in the room when the device was still potentially there.',
          xpReward: 30,
        ),
        DetectiveOption(
          id: 'c7c',
          text: 'C. Neither Daniel nor Sarah',
          isCorrect: false,
          explanation:
              'Incorrect. Sarah arrived at 2:30, after 2:20, so she could have seen it.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c7d',
          text: 'D. The manager',
          isCorrect: false,
          explanation:
              'Incorrect. The manager checked at 3:15, when the device was already gone.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 1,
      hint1: 'The device was last seen at 2:20. Who arrived after that?',
      hint2: 'Daniel was already there before 2:20. Sarah arrived at 2:30 — that is after 2:20.',
      hint3: 'Between 2:20 and 3:15 (when it went missing), Sarah and Daniel were both present.',
      rewardClue: ClueData(
        id: 'clue_07',
        icon: '🔗',
        title: 'Key Inference',
        text:
            'Sarah arrived at 2:30 PM, after the device was last seen at 2:20 PM. She was in the room during the critical window.',
        personName: 'Sarah',
        timeStamp: '2:30 PM',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_04', 'clue_05'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 8 – Red Herring: Coffee Machine
    InvestigationChallenge(
      id: 8,
      type: DetectiveChallengeType.redHerring,
      areaId: 'coffee_area',
      areaTitle: 'Coffee Area Notice',
      title: 'Evaluate This Clue',
      clueBriefing:
          'MAINTENANCE LOG:\n\n"Coffee machine was repaired at 2:40 PM."',
      spokenText: 'Maintenance log. Coffee machine was repaired at two forty PM.',
      question:
          'Is this clue important to the missing prototype device case?',
      options: [
        DetectiveOption(
          id: 'c8a',
          text: 'A. Yes – it shows someone was in the coffee area at 2:40',
          isCorrect: false,
          explanation:
              'Incorrect. A technician fixing the coffee machine has no connection to the missing device.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c8b',
          text: 'B. No – the coffee machine repair is not related ✓',
          isCorrect: true,
          explanation:
              'Correct! This is a red herring. The coffee machine repair has nothing to do with the missing prototype device. Good investigators filter irrelevant information.',
          xpReward: 20,
        ),
        DetectiveOption(
          id: 'c8c',
          text: 'C. Maybe – we need more information',
          isCorrect: false,
          explanation:
              'Incorrect. There is no evidence connecting the repair to the incident.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 1,
      hint1: 'Ask yourself: does this clue connect to the missing device?',
      hint2: 'The device went missing from Room 3. Does a coffee machine repair affect that?',
      hint3: 'Experienced detectives ignore clues that do not connect to the main case.',
      rewardClue: ClueData(
        id: 'clue_08',
        icon: '❌',
        title: 'Red Herring Identified',
        text:
            'Coffee machine repair at 2:40 PM. This is NOT relevant to the missing prototype case.',
        importance: ClueImportance.irrelevant,
        locationName: 'Coffee Area',
      ),
      clueXpBonus: 5,
    ),

    // CHALLENGE 9 – NPC Questioning: Interview Sarah
    InvestigationChallenge(
      id: 9,
      type: DetectiveChallengeType.npcQuestioning,
      areaId: 'corridor',
      areaTitle: 'Corridor – NPC Interview',
      title: 'Interview Sarah',
      clueBriefing:
          'SARAH SAYS:\n\n"I think Daniel was in the room around 2:30."',
      spokenText:
          'Sarah says: I think Daniel was in the room around two thirty.',
      question:
          'What is the most useful follow-up question to ask Sarah?',
      options: [
        DetectiveOption(
          id: 'c9a',
          text: 'A. "What time did she leave the room?" ✓',
          isCorrect: true,
          explanation:
              'Correct! This is a clear, natural question that will get useful information for the investigation.',
          xpReward: 25,
        ),
        DetectiveOption(
          id: 'c9b',
          text: 'B. "Sarah why?"',
          isCorrect: false,
          explanation:
              'Incorrect. This is too short and unclear. It is not a natural English question.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c9c',
          text: 'C. "She was room?"',
          isCorrect: false,
          explanation:
              'Incorrect. This is grammatically incorrect and confusing.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c9d',
          text: 'D. "Tell Sarah."',
          isCorrect: false,
          explanation:
              'Incorrect. This is not a question — it is an incomplete command.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 0,
      hint1: 'You need information about time. Which question asks about time?',
      hint2: 'A good question is clear, grammatically correct, and gets useful information.',
      hint3: '"What time did she leave the room?" is a natural past simple question.',
      rewardClue: ClueData(
        id: 'clue_09',
        icon: '💬',
        title: 'Sarah\'s Interview',
        text:
            'Sarah confirmed Daniel was in Room 3 around 2:30 PM when she arrived.',
        personName: 'Sarah',
        timeStamp: '2:30 PM',
        importance: ClueImportance.supporting,
        relatedClueIds: ['clue_04', 'clue_07'],
      ),
      clueXpBonus: 10,
    ),

    // CHALLENGE 10 – Final Case Solution
    InvestigationChallenge(
      id: 10,
      type: DetectiveChallengeType.caseSolution,
      areaId: 'storage_room',
      areaTitle: 'Final Investigation Board',
      title: 'Solve the Case',
      clueBriefing:
          'CASE SUMMARY:\nAll clues collected. Make your final deduction.',
      spokenText:
          'You have gathered all the evidence. It is time to solve the case. Choose the most likely explanation.',
      question: 'What most likely happened to the prototype device?',
      options: [
        DetectiveOption(
          id: 'c10a',
          text:
              'A. Daniel moved the device to the storage room before the client discussion. ✓',
          isCorrect: true,
          explanation:
              'CASE SOLVED! Daniel had the access card from 2:10 PM. He was alone in Room 3 from 3:00–3:05 PM. A note confirms the device was "temporarily stored." The storage room is the logical destination.',
          xpReward: 60,
        ),
        DetectiveOption(
          id: 'c10b',
          text: 'B. Sarah took the device when she left at 3:00 PM.',
          isCorrect: false,
          explanation:
              'Incorrect. Sarah left before Daniel, who was alone with the device afterward and had the access card.',
          xpReward: 0,
        ),
        DetectiveOption(
          id: 'c10c',
          text: 'C. The device was never in Room 3 to begin with.',
          isCorrect: false,
          explanation:
              'Incorrect. Clue #5 confirms the device was on the table and was stored "temporarily" — meaning it was there.',
          xpReward: 0,
        ),
      ],
      correctOptionIndex: 0,
      hint1: 'Check all your clues. Who had the most access and time alone with the device?',
      hint2: 'Daniel had the access card, was alone from 3:00–3:05 PM, and a note says the device was "temporarily stored".',
      hint3: 'The storage room is nearby. Daniel + access card + alone = most likely explanation.',
      rewardClue: ClueData(
        id: 'clue_10',
        icon: '🔎',
        title: 'Case Solved',
        text:
            'Daniel moved the prototype device to the storage room before the client discussion at 3:30 PM.',
        personName: 'Daniel',
        locationName: 'Storage Room',
        importance: ClueImportance.critical,
        relatedClueIds: ['clue_02', 'clue_04', 'clue_05'],
      ),
      clueXpBonus: 10,
    ),
  ],
  finalSolution:
      'Daniel moved the prototype device to the storage room before the client discussion.',
  finalRevealText:
      'The missing prototype device was found in the storage room. Daniel had temporarily moved it to keep it safe during the client visit. Case #001 is SOLVED!',
);
