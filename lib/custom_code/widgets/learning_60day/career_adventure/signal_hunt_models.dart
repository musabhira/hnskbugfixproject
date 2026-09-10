import 'package:flutter/material.dart';

/// 🎧 Type of Listening Challenges in Level 5
enum SignalHuntChallengeType {
  listenAndMove, // Challenge 1: Spoken direction navigation
  keyInformation, // Challenge 2: Extracting time & room number
  phoneCall, // Challenge 3: Realistic phone conversation
  numberListening, // Challenge 4: Identifying spoken ticket number
  itemSelection, // Challenge 5: Selecting café items from audio
  conversationResponse, // Challenge 6: Choosing natural conversational reply
  listeningMemory, // Challenge 7: Multi-part instructions recall
  distractionTest, // Challenge 8: Audio with environmental noise
  fastDecision, // Challenge 9: Timed 6-second decision
  signalMaster, // Challenge 10: Multi-stage master mission
}

/// 🗣️ Audio Dialogue & Speaker Metadata
class AudioDialogueData {
  final String id;
  final String speaker;
  final String avatarEmoji;
  final String spokenText;
  final String transcript;
  final double speechRate;

  const AudioDialogueData({
    required this.id,
    required this.speaker,
    required this.avatarEmoji,
    required this.spokenText,
    required this.transcript,
    this.speechRate = 0.46,
  });
}

/// 🎯 Single Option Choice for Listening Questions
class SignalHuntOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  const SignalHuntOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

/// 🧩 Individual Challenge Model for Signal Hunt
class SignalHuntChallenge {
  final int id;
  final SignalHuntChallengeType type;
  final String title;
  final String objective;
  final AudioDialogueData audio;
  final String? question;
  final List<SignalHuntOption> options;
  final int? targetNumber; // For Challenge 4: 78
  final List<int>? ticketOptions; // For Challenge 4: [68, 71, 78, 87]
  final List<String>? targetItems; // For Challenge 5: ['Chicken sandwich', 'Bottle of water']
  final List<String>? availableItems; // For Challenge 5: all items
  final String? targetZoneId; // For physical movement challenges
  final double? targetWorldX;
  final int? timeLimitSeconds; // For Challenge 9: 6 seconds
  final bool hasBackgroundNoise; // For Challenge 8: distraction noise
  final int xpReward;

  const SignalHuntChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.objective,
    required this.audio,
    this.question,
    this.options = const [],
    this.targetNumber,
    this.ticketOptions,
    this.targetItems,
    this.availableItems,
    this.targetZoneId,
    this.targetWorldX,
    this.timeLimitSeconds,
    this.hasBackgroundNoise = false,
    this.xpReward = 25,
  });
}

/// 🏙️ Landmark/Zone in the 2D City Communication Hub
class HubZone {
  final String id;
  final String name;
  final String tag;
  final double startX;
  final double endX;
  final Color primaryColor;
  final IconData icon;

  const HubZone({
    required this.id,
    required this.name,
    required this.tag,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.icon,
  });
}

/// 📦 Level 5 Complete Curriculum Data
class SignalHuntLevelData {
  final int levelNumber;
  final String title;
  final String tagline;
  final String missionBriefing;
  final List<SignalHuntChallenge> challenges;
  final List<HubZone> zones;
  final List<String> targetVocabulary;

  const SignalHuntLevelData({
    required this.levelNumber,
    required this.title,
    required this.tagline,
    required this.missionBriefing,
    required this.challenges,
    required this.zones,
    required this.targetVocabulary,
  });
}

/// 🗺️ Complete Level 5 "Signal Hunt" Dataset
const kMission05SignalHuntData = SignalHuntLevelData(
  levelNumber: 5,
  title: 'Signal Hunt',
  tagline: 'Listen carefully. Find the signal. Make the right move.',
  missionBriefing:
      'You have received an urgent message: "You have an important meeting today." Your phone rings with updated instructions. Listen to the spoken directions, filter out distractions, and navigate the City Communication Hub!',
  zones: [
    HubZone(
      id: 'street',
      name: 'Transit Plaza & Bus Stop',
      tag: 'OUTDOOR',
      startX: 0,
      endX: 380,
      primaryColor: Color(0xFF0284C7),
      icon: Icons.directions_bus_rounded,
    ),
    HubZone(
      id: 'cafe',
      name: 'Hub Café Express',
      tag: 'DINING',
      startX: 380,
      endX: 740,
      primaryColor: Color(0xFFD97706),
      icon: Icons.coffee_rounded,
    ),
    HubZone(
      id: 'building_entrance',
      name: 'Main Office Entrance',
      tag: 'BUILDING',
      startX: 740,
      endX: 1100,
      primaryColor: Color(0xFF10B981),
      icon: Icons.meeting_room_rounded,
    ),
    HubZone(
      id: 'information_desk',
      name: 'Information & Ticket Desk',
      tag: 'SERVICES',
      startX: 1100,
      endX: 1440,
      primaryColor: Color(0xFF8B5CF6),
      icon: Icons.confirmation_number_rounded,
    ),
    HubZone(
      id: 'executive_corridor',
      name: 'Floor 2 Executive Wing (Room 204 & 208)',
      tag: 'MEETING ROOMS',
      startX: 1440,
      endX: 1900,
      primaryColor: Color(0xFFEC4899),
      icon: Icons.business_rounded,
    ),
  ],
  targetVocabulary: [
    'appointment',
    'entrance',
    'receptionist',
    'available',
    'meeting',
    'manager',
    'schedule',
    'instead',
    'collect',
    'ticket',
    'information',
    'floor',
    'outside',
    'early',
    'later',
    'message',
    'confirm',
  ],
  challenges: [
    // ── Challenge 1: Listen and Move ──────────────────────────────────────────
    SignalHuntChallenge(
      id: 1,
      type: SignalHuntChallengeType.listenAndMove,
      title: 'Challenge 1: Spoken Navigation',
      objective: 'Follow spoken navigation directions to the correct building.',
      audio: AudioDialogueData(
        id: 'c1_audio',
        speaker: 'City Dispatcher',
        avatarEmoji: '👮‍♂️',
        spokenText: 'Walk past the café and enter the building on your left.',
        transcript: 'Walk past the café and enter the building on your left.',
      ),
      targetZoneId: 'building_entrance',
      targetWorldX: 860,
      xpReward: 25,
      question: 'Which destination matches the spoken direction?',
      options: [
        SignalHuntOption(
          text: 'Building on your left',
          isCorrect: true,
          feedback: 'Correct! You navigated past the café and entered the building on your left.',
        ),
        SignalHuntOption(
          text: 'Bus stop across the street',
          isCorrect: false,
          feedback: 'The dispatcher said to walk past the café into the building on the left.',
        ),
        SignalHuntOption(
          text: 'Inside the supermarket',
          isCorrect: false,
          feedback: 'Listen carefully: "enter the building on your left".',
        ),
      ],
    ),

    // ── Challenge 2: Key Information ──────────────────────────────────────────
    SignalHuntChallenge(
      id: 2,
      type: SignalHuntChallengeType.keyInformation,
      title: 'Challenge 2: Meeting Time & Room',
      objective: 'Detect critical schedule details (time and room number).',
      audio: AudioDialogueData(
        id: 'c2_audio',
        speaker: 'Executive Assistant',
        avatarEmoji: '👩‍💼',
        spokenText: 'The meeting starts at two-thirty in Room 204.',
        transcript: 'The meeting starts at two-thirty in Room 204.',
      ),
      question: 'What time does the meeting start, and in which room?',
      options: [
        SignalHuntOption(
          text: '2:30 PM in Room 204',
          isCorrect: true,
          feedback: 'Spot on! "two-thirty in Room 204" clearly gives the exact time and room.',
        ),
        SignalHuntOption(
          text: '1:30 PM in Room 204',
          isCorrect: false,
          feedback: 'You heard "two-thirty", which is 2:30 PM, not 1:30 PM.',
        ),
        SignalHuntOption(
          text: '2:00 PM in Room 104',
          isCorrect: false,
          feedback: 'Listen again: "two-thirty in Room 204".',
        ),
        SignalHuntOption(
          text: '3:30 PM in Room 208',
          isCorrect: false,
          feedback: 'The assistant explicitly stated two-thirty in Room 204.',
        ),
      ],
      xpReward: 20,
    ),

    // ── Challenge 3: Phone Call ───────────────────────────────────────────────
    SignalHuntChallenge(
      id: 3,
      type: SignalHuntChallengeType.phoneCall,
      title: 'Challenge 3: Urgent Phone Call',
      objective: 'Understand real-life conversation details during an incoming phone call.',
      audio: AudioDialogueData(
        id: 'c3_audio',
        speaker: 'Dr. Vance (Caller)',
        avatarEmoji: '📞',
        spokenText:
            'Hi, I am calling about your appointment. Could you come in on Thursday instead of Friday?',
        transcript:
            'Hi, I am calling about your appointment. Could you come in on Thursday instead of Friday?',
      ),
      question: 'What changed regarding your appointment?',
      options: [
        SignalHuntOption(
          text: 'The day (Thursday instead of Friday)',
          isCorrect: true,
          feedback: 'Excellent! "Thursday instead of Friday" means the day of the appointment changed.',
        ),
        SignalHuntOption(
          text: 'The location of the office',
          isCorrect: false,
          feedback: 'The caller did not mention moving to a new building or room.',
        ),
        SignalHuntOption(
          text: 'The appointment price',
          isCorrect: false,
          feedback: 'No fee or price change was discussed.',
        ),
        SignalHuntOption(
          text: 'The person you are meeting',
          isCorrect: false,
          feedback: 'The doctor is still meeting you; only the day changed.',
        ),
      ],
      xpReward: 20,
    ),

    // ── Challenge 4: Listen for the Number ─────────────────────────────────────
    SignalHuntChallenge(
      id: 4,
      type: SignalHuntChallengeType.numberListening,
      title: 'Challenge 4: Ticket Counter',
      objective: 'Distinguish spoken numbers accurately and collect the right ticket.',
      audio: AudioDialogueData(
        id: 'c4_audio',
        speaker: 'Automated Counter System',
        avatarEmoji: '🤖',
        spokenText:
            'Please collect ticket number seventy-eight from the information desk.',
        transcript:
            'Please collect ticket number seventy-eight from the information desk.',
      ),
      targetNumber: 78,
      ticketOptions: [68, 71, 78, 87],
      question: 'Which ticket number was announced?',
      options: [
        SignalHuntOption(
          text: 'Ticket 78 (Seventy-eight)',
          isCorrect: true,
          feedback: 'Correct! "Seventy-eight" corresponds to 78.',
        ),
        SignalHuntOption(
          text: 'Ticket 68 (Sixty-eight)',
          isCorrect: false,
          feedback: 'You heard "seventy-eight", not "sixty-eight".',
        ),
        SignalHuntOption(
          text: 'Ticket 87 (Eighty-seven)',
          isCorrect: false,
          feedback: 'Be careful with digit order! "Seventy-eight" is 78, not 87.',
        ),
        SignalHuntOption(
          text: 'Ticket 71 (Seventy-one)',
          isCorrect: false,
          feedback: 'The announcement specified ticket seventy-eight.',
        ),
      ],
      xpReward: 20,
    ),

    // ── Challenge 5: Listen and Choose Item ───────────────────────────────────
    SignalHuntChallenge(
      id: 5,
      type: SignalHuntChallengeType.itemSelection,
      title: 'Challenge 5: Café Order',
      objective: 'Select the exact items ordered by the NPC at the counter.',
      audio: AudioDialogueData(
        id: 'c5_audio',
        speaker: 'Colleague at Café',
        avatarEmoji: '🥪',
        spokenText: 'I would like a chicken sandwich and a bottle of water.',
        transcript: 'I would like a chicken sandwich and a bottle of water.',
      ),
      targetItems: ['Chicken sandwich', 'Bottle of water'],
      availableItems: [
        'Chicken sandwich',
        'Bottle of water',
        'Coffee',
        'Pizza',
        'Juice',
      ],
      question: 'Which two items did your colleague order?',
      options: [
        SignalHuntOption(
          text: 'Chicken sandwich and Bottle of water',
          isCorrect: true,
          feedback: 'Delicious! You picked both the chicken sandwich and bottle of water.',
        ),
        SignalHuntOption(
          text: 'Pizza and Coffee',
          isCorrect: false,
          feedback: 'Neither pizza nor coffee was requested.',
        ),
        SignalHuntOption(
          text: 'Chicken sandwich and Juice',
          isCorrect: false,
          feedback: 'They asked for a bottle of water, not juice.',
        ),
      ],
      xpReward: 25,
    ),

    // ── Challenge 6: Conversation Response ────────────────────────────────────
    SignalHuntChallenge(
      id: 6,
      type: SignalHuntChallengeType.conversationResponse,
      title: 'Challenge 6: Natural Conversation',
      objective: 'Select the most polite and natural response to an NPC inquiry.',
      audio: AudioDialogueData(
        id: 'c6_audio',
        speaker: 'Visitor in Lobby',
        avatarEmoji: '🙋‍♂️',
        spokenText: 'Excuse me, could you help me with this?',
        transcript: 'Excuse me, could you help me with this?',
      ),
      question: 'What is the most natural and polite response?',
      options: [
        SignalHuntOption(
          text: 'Sure. What do you need help with?',
          isCorrect: true,
          feedback: 'Perfect! "Sure. What do you need help with?" is natural, friendly, and professional.',
        ),
        SignalHuntOption(
          text: 'Yes, help.',
          isCorrect: false,
          feedback: '"Yes, help" sounds abrupt and grammatically incomplete.',
        ),
        SignalHuntOption(
          text: 'What you need?',
          isCorrect: false,
          feedback: '"What you need?" is too informal and lacks auxiliary "do" (What do you need?).',
        ),
        SignalHuntOption(
          text: 'No, I help.',
          isCorrect: false,
          feedback: 'Contradictory and confusing phrasing.',
        ),
      ],
      xpReward: 20,
    ),

    // ── Challenge 7: Listening Memory ─────────────────────────────────────────
    SignalHuntChallenge(
      id: 7,
      type: SignalHuntChallengeType.listeningMemory,
      title: 'Challenge 7: Multi-Part Memory',
      objective: 'Retain multiple sequential instructions without written subtitles.',
      audio: AudioDialogueData(
        id: 'c7_audio',
        speaker: 'Floor Supervisor',
        avatarEmoji: '👨‍💼',
        spokenText:
            'Go upstairs, turn left, and wait outside Room 204. The manager will meet you there after lunch.',
        transcript:
            'Go upstairs, turn left, and wait outside Room 204. The manager will meet you there after lunch.',
      ),
      question: 'Where should you wait according to the instruction?',
      options: [
        SignalHuntOption(
          text: 'Outside Room 204',
          isCorrect: true,
          feedback: 'Great listening retention! The instruction was to "wait outside Room 204".',
        ),
        SignalHuntOption(
          text: 'Inside the elevator',
          isCorrect: false,
          feedback: 'You were told to go upstairs, turn left, and wait outside Room 204.',
        ),
        SignalHuntOption(
          text: 'At the café downstairs',
          isCorrect: false,
          feedback: 'The meeting is upstairs on the left outside Room 204.',
        ),
        SignalHuntOption(
          text: 'In the lobby reception',
          isCorrect: false,
          feedback: 'Listen again: wait outside Room 204 after going upstairs.',
        ),
      ],
      xpReward: 25,
    ),

    // ── Challenge 8: Distraction Test (Noisy Listening) ───────────────────────
    SignalHuntChallenge(
      id: 8,
      type: SignalHuntChallengeType.distractionTest,
      title: 'Challenge 8: Filtering Background Noise',
      objective: 'Extract accurate information through realistic city background bustle.',
      audio: AudioDialogueData(
        id: 'c8_audio',
        speaker: 'Hub Public Announcement',
        avatarEmoji: '📢',
        spokenText:
            'The pharmacy closes at six, so please get there before then.',
        transcript:
            'The pharmacy closes at six, so please get there before then.',
      ),
      hasBackgroundNoise: true,
      question: 'What time does the pharmacy close?',
      options: [
        SignalHuntOption(
          text: '6:00 PM',
          isCorrect: true,
          feedback: 'Sharp ears! Even with background hub noise, you clearly identified 6:00 PM.',
        ),
        SignalHuntOption(
          text: '5:00 PM',
          isCorrect: false,
          feedback: 'The announcement clearly said "at six" (6:00 PM).',
        ),
        SignalHuntOption(
          text: '7:00 PM',
          isCorrect: false,
          feedback: 'You heard "six", not seven.',
        ),
        SignalHuntOption(
          text: '8:00 PM',
          isCorrect: false,
          feedback: 'The announcement stated that it closes at six.',
        ),
      ],
      xpReward: 25,
    ),

    // ── Challenge 9: Fast Decision (Timed 6-Second Decision) ──────────────────
    SignalHuntChallenge(
      id: 9,
      type: SignalHuntChallengeType.fastDecision,
      title: 'Challenge 9: Fast Decision (6s Timer)',
      objective: 'Process spoken dispatch immediately and choose the right location within 6 seconds.',
      audio: AudioDialogueData(
        id: 'c9_audio',
        speaker: 'Urgent Dispatch Audio',
        avatarEmoji: '⚡',
        spokenText: 'The manager is waiting for you at the office entrance.',
        transcript: 'The manager is waiting for you at the office entrance.',
      ),
      timeLimitSeconds: 6,
      question: 'Quick! Where is the manager waiting for you right now?',
      options: [
        SignalHuntOption(
          text: 'OFFICE ENTRANCE',
          isCorrect: true,
          feedback: 'Lightning fast! The manager was waiting right at the office entrance.',
        ),
        SignalHuntOption(
          text: 'BUS STOP',
          isCorrect: false,
          feedback: 'The dispatch said "office entrance", not the bus stop.',
        ),
        SignalHuntOption(
          text: 'RESTAURANT',
          isCorrect: false,
          feedback: 'The manager is at the office entrance.',
        ),
      ],
      xpReward: 30,
    ),

    // ── Challenge 10: Signal Master (Multi-Stage Listening Mission) ────────────
    SignalHuntChallenge(
      id: 10,
      type: SignalHuntChallengeType.signalMaster,
      title: 'Challenge 10: Signal Master Final Mission',
      objective:
          'Execute a 5-stage sequential physical mission based on a single comprehensive audio message.',
      audio: AudioDialogueData(
        id: 'c10_audio',
        speaker: 'Senior Coordinator',
        avatarEmoji: '🎖️',
        spokenText:
            'Your appointment is at 3 PM. Please enter through the main entrance, take the elevator to the second floor, and wait outside Room 208. If you arrive early, speak to the receptionist.',
        transcript:
            'Your appointment is at 3 PM. Please enter through the main entrance, take the elevator to the second floor, and wait outside Room 208. If you arrive early, speak to the receptionist.',
      ),
      question: 'Receptionist asks: "Are you here for the three o’clock appointment?" How do you respond?',
      options: [
        SignalHuntOption(
          text: 'Yes, I am.',
          isCorrect: true,
          feedback: 'Mission accomplished! "Yes, I am" is the natural, correct confirmation.',
        ),
        SignalHuntOption(
          text: 'No, I was.',
          isCorrect: false,
          feedback: '"No, I was" is grammatically mismatched to the question.',
        ),
        SignalHuntOption(
          text: 'Maybe yesterday.',
          isCorrect: false,
          feedback: 'Your appointment is today at 3 PM.',
        ),
      ],
      xpReward: 50,
    ),
  ],
);
