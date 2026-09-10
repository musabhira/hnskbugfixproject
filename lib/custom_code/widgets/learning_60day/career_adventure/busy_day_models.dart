import 'package:flutter/material.dart';

/// Scene types representing everyday communication challenges in Level 7.
enum BusyDaySceneType {
  morningMessage,
  busStop,
  delayProblem,
  askForHelp,
  cafeOrder,
  wrongOrder,
  workMessage,
  interruption,
  folderDetail,
  priorityDecision,
}

/// Quality ranking of conversational choices to provide nuance beyond simple right/wrong.
enum ChoiceQuality {
  excellent,
  natural,
  acceptable,
  poor,
  incorrect,
}

/// A specific conversational or situational response choice.
class DialogueOption {
  final String id;
  final String text;
  final ChoiceQuality quality;
  final String feedback;
  final int xpReward;
  final double naturalnessScore; // 0.0 .. 1.0
  final double politenessScore;  // 0.0 .. 1.0
  final double accuracyScore;    // 0.0 .. 1.0

  const DialogueOption({
    required this.id,
    required this.text,
    required this.quality,
    required this.feedback,
    this.xpReward = 20,
    this.naturalnessScore = 1.0,
    this.politenessScore = 1.0,
    this.accuracyScore = 1.0,
  });

  bool get isSuccessful =>
      quality == ChoiceQuality.excellent ||
      quality == ChoiceQuality.natural ||
      quality == ChoiceQuality.acceptable;
}

/// Quest status for the Task Board.
enum QuestStatus {
  locked,
  available,
  active,
  completed,
  failed,
}

/// An everyday task on the player's Task Board.
class QuestItem {
  final String id;
  final String title;
  final String description;
  final String timeLabel;
  QuestStatus status;

  QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLabel,
    this.status = QuestStatus.active,
  });
}

/// A physical or digital folder item for Scene 9.
class FolderItem {
  final String id;
  final String label;
  final Color color;
  final bool isSmall;
  final bool isTarget;

  const FolderItem({
    required this.id,
    required this.label,
    required this.color,
    required this.isSmall,
    required this.isTarget,
  });
}

/// An urgent task for priority sorting in Scene 10.
class PriorityTask {
  final String id;
  final String title;
  final String deadlineText;
  final int correctOrder;

  const PriorityTask({
    required this.id,
    required this.title,
    required this.deadlineText,
    required this.correctOrder,
  });
}

/// A single scene / situation in the player's day.
class BusyDayScene {
  final int id;
  final BusyDaySceneType type;
  final String clockTime;
  final String locationTitle;
  final String npcName;
  final String npcSpeech;
  final String objective;
  final String spokenText;
  final List<DialogueOption> options;
  final int correctOptionIndex;
  final String hint;
  final String? relatedQuestId;
  final List<FolderItem>? folderChoices;
  final List<PriorityTask>? priorityTasks;

  const BusyDayScene({
    required this.id,
    required this.type,
    required this.clockTime,
    required this.locationTitle,
    required this.npcName,
    required this.npcSpeech,
    required this.objective,
    required this.spokenText,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    this.relatedQuestId,
    this.folderChoices,
    this.priorityTasks,
  });

  DialogueOption get correctOption => options[correctOptionIndex];
}

/// A connected zone in the 2D world.
class CitySceneZone {
  final String id;
  final String name;
  final double startX;
  final double endX;
  final Color primaryColor;
  final IconData icon;

  const CitySceneZone({
    required this.id,
    required this.name,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.icon,
  });
}

/// Complete curriculum data structure for Mission 07.
class BusyDayLevelData {
  final String missionId;
  final String title;
  final String subtitle;
  final String tagline;
  final List<String> targetVocabulary;
  final List<CitySceneZone> zones;
  final List<BusyDayScene> scenes;
  final List<QuestItem> initialQuests;
  final String finalMissionSummary;

  const BusyDayLevelData({
    required this.missionId,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.targetVocabulary,
    required this.zones,
    required this.scenes,
    required this.initialQuests,
    required this.finalMissionSummary,
  });
}

/// Full Curriculum for Level 7 – The Busy Day
final kMission07BusyDayData = BusyDayLevelData(
  missionId: '07',
  title: 'Mission 07 – The Busy Day',
  subtitle: '2D Flame Real-Life Decision & Communication Adventure',
  tagline: 'Your day. Your choices. Your English.',
  targetVocabulary: const [
    'meeting',
    'delay',
    'route',
    'station',
    'report',
    'folder',
    'manager',
    'order',
    'available',
    'message',
    'schedule',
    'appointment',
    'before',
    'after',
    'instead',
    'another',
    'interrupt',
    'send',
    'bring',
    'confirm',
    'urgent',
    'problem',
    'solution',
    'deadline',
  ],
  zones: const [
    CitySceneZone(
      id: 'home',
      name: 'Player Apartment',
      startX: 0,
      endX: 380,
      primaryColor: Color(0xFF6366F1),
      icon: Icons.home_rounded,
    ),
    CitySceneZone(
      id: 'transit',
      name: 'Market St Bus Stop & Metro',
      startX: 380,
      endX: 740,
      primaryColor: Color(0xFF0EA5E9),
      icon: Icons.directions_bus_rounded,
    ),
    CitySceneZone(
      id: 'cafe',
      name: 'Corner Brew Café',
      startX: 740,
      endX: 1120,
      primaryColor: Color(0xFFF59E0B),
      icon: Icons.coffee_rounded,
    ),
    CitySceneZone(
      id: 'office',
      name: 'Workplace Lobby & Desk',
      startX: 1120,
      endX: 1520,
      primaryColor: Color(0xFF10B981),
      icon: Icons.business_rounded,
    ),
    CitySceneZone(
      id: 'meeting_room',
      name: 'Floor 2 Executive Suite',
      startX: 1520,
      endX: 1900,
      primaryColor: Color(0xFF8B5CF6),
      icon: Icons.meeting_room_rounded,
    ),
  ],
  initialQuests: [
    QuestItem(
      id: 'q1',
      title: 'Reach Central Station',
      description: 'Find a reliable transit route to get to work on time.',
      timeLabel: '08:30 AM',
      status: QuestStatus.active,
    ),
    QuestItem(
      id: 'q2',
      title: 'Order lunch at Café',
      description: 'Order coffee and a sandwich, and verify the items.',
      timeLabel: '11:30 AM',
      status: QuestStatus.available,
    ),
    QuestItem(
      id: 'q3',
      title: 'Deliver work report',
      description: 'Submit the digital report before lunch.',
      timeLabel: '01:00 PM',
      status: QuestStatus.available,
    ),
    QuestItem(
      id: 'q4',
      title: 'Retrieve small blue folder',
      description: 'Assist your colleague with the exact requested document.',
      timeLabel: '03:30 PM',
      status: QuestStatus.available,
    ),
    QuestItem(
      id: 'q5',
      title: 'Attend 4:30 PM meeting',
      description: 'Prioritize the executive meeting before ending the day.',
      timeLabel: '04:30 PM',
      status: QuestStatus.available,
    ),
    QuestItem(
      id: 'q6',
      title: 'Send final email before 5 PM',
      description: 'Wrap up all open communication before 5:00 PM.',
      timeLabel: '04:55 PM',
      status: QuestStatus.available,
    ),
  ],
  finalMissionSummary:
      'The meeting has moved to 4 PM. Please come to the second floor. Bring the blue folder and send the report before 6.',
  scenes: [
    // Scene 1: Morning Message (08:00 AM)
    BusyDayScene(
      id: 1,
      type: BusyDaySceneType.morningMessage,
      clockTime: '08:00 AM',
      locationTitle: 'Apartment Bedroom',
      npcName: 'Sarah (Team Lead)',
      npcSpeech: 'Hi! Are you still coming to the meeting at 9?',
      objective: 'Reply to Sarah about the 9:00 AM meeting naturally.',
      spokenText: 'Hi! Are you still coming to the meeting at nine?',
      hint: "Use 'I'll be there' to state your future arrival naturally.",
      relatedQuestId: 'q1',
      options: [
        DialogueOption(
          id: 's1_opt_a',
          text: "Yes, I'll be there at 9.",
          quality: ChoiceQuality.excellent,
          feedback: 'Great! Sender replies: "Great. See you then."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's1_opt_b',
          text: 'Yes, I coming.',
          quality: ChoiceQuality.poor,
          feedback: "Grammatically awkward. Missing auxiliary 'am' and time expression.",
          xpReward: 10,
          naturalnessScore: 0.4,
          politenessScore: 0.7,
          accuracyScore: 0.5,
        ),
        DialogueOption(
          id: 's1_opt_c',
          text: 'I am there yesterday.',
          quality: ChoiceQuality.incorrect,
          feedback: "Incorrect tense! 'Yesterday' refers to the past, not 9:00 AM today.",
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.4,
          accuracyScore: 0.1,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 2: Bus Stop Uncertainty (08:30 AM)
    BusyDayScene(
      id: 2,
      type: BusyDaySceneType.busStop,
      clockTime: '08:30 AM',
      locationTitle: 'Market Street Bus Stop',
      npcName: 'Commuter',
      npcSpeech: 'Is this the bus to Central Station?',
      objective: 'Answer the commuter politely with realistic uncertainty.',
      spokenText: 'Excuse me, is this the bus to Central Station?',
      hint: "'I think so' expresses polite belief without making a 100% false guarantee.",
      relatedQuestId: 'q1',
      options: [
        DialogueOption(
          id: 's2_opt_a',
          text: 'Yes, I think so.',
          quality: ChoiceQuality.excellent,
          feedback: 'Perfect! The commuter smiles: "Thank you so much!"',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's2_opt_b',
          text: 'Yes, this bus is going yesterday.',
          quality: ChoiceQuality.incorrect,
          feedback: "Nonsensical grammar. 'Yesterday' cannot be used for a current journey.",
          xpReward: 5,
          naturalnessScore: 0.1,
          politenessScore: 0.4,
          accuracyScore: 0.2,
        ),
        DialogueOption(
          id: 's2_opt_c',
          text: 'This bus station Central.',
          quality: ChoiceQuality.poor,
          feedback: "Broken sentence structure lacking verbs and prepositions.",
          xpReward: 10,
          naturalnessScore: 0.3,
          politenessScore: 0.6,
          accuracyScore: 0.4,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 3: Delay Problem & Route Consequence (08:45 AM)
    BusyDayScene(
      id: 3,
      type: BusyDaySceneType.delayProblem,
      clockTime: '08:45 AM',
      locationTitle: 'Transit Notification',
      npcName: 'Transit Alert',
      npcSpeech: 'Transit Alert: Your bus is delayed by 15 minutes due to heavy traffic.',
      objective: 'Make an active decision to avoid missing your 9:00 AM meeting.',
      spokenText: 'Your bus is delayed by fifteen minutes.',
      hint: 'Choose the proactive response to find an alternative transit method.',
      relatedQuestId: 'q1',
      options: [
        DialogueOption(
          id: 's3_opt_a',
          text: 'Wait and miss the meeting.',
          quality: ChoiceQuality.poor,
          feedback: 'Passive choice. You will arrive late and lose professional credibility.',
          xpReward: 5,
          naturalnessScore: 0.4,
          politenessScore: 0.6,
          accuracyScore: 0.3,
        ),
        DialogueOption(
          id: 's3_opt_b',
          text: 'Check another route.',
          quality: ChoiceQuality.excellent,
          feedback: 'Proactive choice! You check the transit map and head to the train station.',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's3_opt_c',
          text: 'Ignore the message.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Ignoring alerts leads to unnecessary delays.',
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.5,
          accuracyScore: 0.2,
        ),
        DialogueOption(
          id: 's3_opt_d',
          text: 'Go home.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Giving up abandons your workday obligations.',
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.4,
          accuracyScore: 0.1,
        ),
      ],
      correctOptionIndex: 1,
    ),

    // Scene 4: Asking for Help (08:50 AM)
    BusyDayScene(
      id: 4,
      type: BusyDaySceneType.askForHelp,
      clockTime: '08:50 AM',
      locationTitle: 'Metro Station Entrance',
      npcName: 'Passerby',
      npcSpeech: 'Hello there, can I help you?',
      objective: 'Ask the passerby politely for an alternate route to Central Station.',
      spokenText: 'Hello there, can I help you?',
      hint: "Polite inquiries usually open with 'Excuse me, is there another way...?'",
      relatedQuestId: 'q1',
      options: [
        DialogueOption(
          id: 's4_opt_a',
          text: 'Excuse me, is there another way to get to Central Station?',
          quality: ChoiceQuality.excellent,
          feedback: 'Polite and fluent! Passerby: "Yes. You can take the train from the next station."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's4_opt_b',
          text: 'Where train go now?',
          quality: ChoiceQuality.poor,
          feedback: 'Blunt and grammatically fragmented.',
          xpReward: 10,
          naturalnessScore: 0.4,
          politenessScore: 0.5,
          accuracyScore: 0.5,
        ),
        DialogueOption(
          id: 's4_opt_c',
          text: 'Station Central me now.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Incomprehensible syntax.',
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.4,
          accuracyScore: 0.2,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 5: Café Order & Customization (11:30 AM)
    BusyDayScene(
      id: 5,
      type: BusyDaySceneType.cafeOrder,
      clockTime: '11:30 AM',
      locationTitle: 'Corner Brew Café',
      npcName: 'Barista',
      npcSpeech: 'Hi! What would you like today?',
      objective: 'Order a coffee and a sandwich politely.',
      spokenText: 'Hi! What would you like today?',
      hint: "Use 'I’d like... please' for polite, modern food ordering.",
      relatedQuestId: 'q2',
      options: [
        DialogueOption(
          id: 's5_opt_a',
          text: "I’d like a coffee and a sandwich, please.",
          quality: ChoiceQuality.excellent,
          feedback: 'Perfect! Barista smiles: "Sure thing. Would you like milk with that?"',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's5_opt_b',
          text: 'Give coffee sandwich.',
          quality: ChoiceQuality.poor,
          feedback: 'Lacks courtesy words. Sounds like an aggressive command.',
          xpReward: 10,
          naturalnessScore: 0.3,
          politenessScore: 0.2,
          accuracyScore: 0.6,
        ),
        DialogueOption(
          id: 's5_opt_c',
          text: 'I eat coffee tomorrow.',
          quality: ChoiceQuality.incorrect,
          feedback: "We drink coffee, we don't eat it; and 'tomorrow' makes no sense here.",
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.5,
          accuracyScore: 0.2,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 6: Wrong Order Problem Solving (11:45 AM)
    BusyDayScene(
      id: 6,
      type: BusyDaySceneType.wrongOrder,
      clockTime: '11:45 AM',
      locationTitle: 'Corner Brew Café Counter',
      npcName: 'Barista',
      npcSpeech: 'Here is your tea and sandwich. Is everything okay?',
      objective: 'Politely inform the barista that you ordered coffee, not tea.',
      spokenText: 'Here is your tea and sandwich. Is everything okay?',
      hint: "Start with 'Sorry, I ordered...' to point out a mistake constructively.",
      relatedQuestId: 'q2',
      options: [
        DialogueOption(
          id: 's6_opt_a',
          text: 'Sorry, I ordered a coffee, not tea.',
          quality: ChoiceQuality.excellent,
          feedback: 'Excellent! Barista: "Oh, my apologies! Let me swap that for a fresh coffee right away."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's6_opt_b',
          text: 'You made bad mistake!',
          quality: ChoiceQuality.poor,
          feedback: 'Overly combative. It creates hostility instead of solving the problem.',
          xpReward: 10,
          naturalnessScore: 0.4,
          politenessScore: 0.2,
          accuracyScore: 0.7,
        ),
        DialogueOption(
          id: 's6_opt_c',
          text: 'Tea is yesterday drink.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Irrelevant comment that fails to communicate the actual issue.',
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.4,
          accuracyScore: 0.2,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 7: Work / College Message & Report Delivery (01:00 PM)
    BusyDayScene(
      id: 7,
      type: BusyDaySceneType.workMessage,
      clockTime: '01:00 PM',
      locationTitle: 'Office Workspace',
      npcName: 'David (Colleague)',
      npcSpeech: 'Can you send me the report before lunch?',
      objective: 'Confirm that you will send the report before lunch.',
      spokenText: 'Can you send me the report before lunch?',
      hint: "Use 'Sure. I'll send it...' to offer a prompt, reliable workplace commitment.",
      relatedQuestId: 'q3',
      options: [
        DialogueOption(
          id: 's7_opt_a',
          text: 'Sure. I’ll send it before lunch.',
          quality: ChoiceQuality.excellent,
          feedback: 'Professional response! David nods: "Thanks, that helps a lot."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's7_opt_b',
          text: 'Yes, I send yesterday.',
          quality: ChoiceQuality.poor,
          feedback: "Confusing past tense. He asked for today's upcoming report.",
          xpReward: 10,
          naturalnessScore: 0.3,
          politenessScore: 0.7,
          accuracyScore: 0.4,
        ),
        DialogueOption(
          id: 's7_opt_c',
          text: 'I am report.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Grammatical nonsense: you are a human, not a document.',
          xpReward: 5,
          naturalnessScore: 0.1,
          politenessScore: 0.3,
          accuracyScore: 0.1,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 8: Interruption (02:30 PM)
    BusyDayScene(
      id: 8,
      type: BusyDaySceneType.interruption,
      clockTime: '02:30 PM',
      locationTitle: 'Office Open Desk Area',
      npcName: 'Elena (Project Assistant)',
      npcSpeech: 'Sorry to interrupt, but could you help me for a minute?',
      objective: 'Acknowledge the interruption helpfully and naturally.',
      spokenText: 'Sorry to interrupt, but could you help me for a minute?',
      hint: "'Sure. What do you need?' is the universal natural American/British office reply.",
      options: [
        DialogueOption(
          id: 's8_opt_a',
          text: 'Sure. What do you need?',
          quality: ChoiceQuality.excellent,
          feedback: 'Natural and collegial! Elena: "Thank you! I need to locate the project folders."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's8_opt_b',
          text: 'Why are you interrupt?',
          quality: ChoiceQuality.poor,
          feedback: 'Blunt, accusatory, and grammatically incomplete.',
          xpReward: 10,
          naturalnessScore: 0.3,
          politenessScore: 0.2,
          accuracyScore: 0.5,
        ),
        DialogueOption(
          id: 's8_opt_c',
          text: 'Help me later yesterday.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Conflicting time references and broken sentence.',
          xpReward: 5,
          naturalnessScore: 0.2,
          politenessScore: 0.3,
          accuracyScore: 0.1,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 9: Detail Misunderstanding (03:30 PM)
    BusyDayScene(
      id: 9,
      type: BusyDaySceneType.folderDetail,
      clockTime: '03:30 PM',
      locationTitle: 'Document Archive',
      npcName: 'Elena',
      npcSpeech: 'Could you bring the blue folder? Actually, make sure it’s the smaller blue folder.',
      objective: 'Select the exact folder requested: the smaller blue folder.',
      spokenText: 'Could you bring the blue folder? Actually, make sure it is the smaller blue folder.',
      hint: 'Look for both the correct color (BLUE) and the specific modifier (SMALLER).',
      relatedQuestId: 'q4',
      folderChoices: const [
        FolderItem(
          id: 'folder_black_large',
          label: 'Large Black Folder',
          color: Color(0xFF334155),
          isSmall: false,
          isTarget: false,
        ),
        FolderItem(
          id: 'folder_blue_large',
          label: 'Large Blue Folder',
          color: Color(0xFF2563EB),
          isSmall: false,
          isTarget: false,
        ),
        FolderItem(
          id: 'folder_blue_small',
          label: 'Small Blue Folder',
          color: Color(0xFF38BDF8),
          isSmall: true,
          isTarget: true,
        ),
      ],
      options: [
        DialogueOption(
          id: 's9_opt_a',
          text: 'Here is the small blue folder you asked for.',
          quality: ChoiceQuality.excellent,
          feedback: 'Exact item delivered! Elena: "Spot on! That has the budget sheets."',
          xpReward: 25,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's9_opt_b',
          text: 'Take this black one.',
          quality: ChoiceQuality.poor,
          feedback: 'Wrong color! Elena asked for the blue folder.',
          xpReward: 10,
          naturalnessScore: 0.4,
          politenessScore: 0.4,
          accuracyScore: 0.2,
        ),
        DialogueOption(
          id: 's9_opt_c',
          text: 'Any folder is fine.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Inattentive. Specific documents require the correct folder.',
          xpReward: 5,
          naturalnessScore: 0.3,
          politenessScore: 0.4,
          accuracyScore: 0.1,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Scene 10: Final Priority Decision (04:00 PM - 05:00 PM)
    BusyDayScene(
      id: 10,
      type: BusyDaySceneType.priorityDecision,
      clockTime: '04:00 PM',
      locationTitle: 'Floor 2 Executive Suite',
      npcName: 'Manager Marcus',
      npcSpeech:
          'You have two urgent items: attend the 4:30 PM meeting and send the client email before 5:00 PM.',
      objective: 'Prioritize your urgent tasks in the correct chronological order.',
      spokenText:
          'The meeting has moved to four PM. Please come to the second floor. Bring the blue folder and send the report before six.',
      hint: 'A meeting at 4:30 PM must happen before sending an email due at 5:00 PM.',
      relatedQuestId: 'q5',
      priorityTasks: const [
        PriorityTask(
          id: 'p1',
          title: 'Attend Executive Meeting with Manager',
          deadlineText: '4:30 PM (Mandatory)',
          correctOrder: 1,
        ),
        PriorityTask(
          id: 'p2',
          title: 'Send Final Client Email & Report',
          deadlineText: 'Before 5:00 PM',
          correctOrder: 2,
        ),
      ],
      options: [
        DialogueOption(
          id: 's10_opt_a',
          text: 'Attend the 4:30 PM meeting first, then send the email before 5:00 PM.',
          quality: ChoiceQuality.excellent,
          feedback: 'Outstanding prioritization! Both commitments are completed cleanly on time.',
          xpReward: 50,
          naturalnessScore: 1.0,
          politenessScore: 1.0,
          accuracyScore: 1.0,
        ),
        DialogueOption(
          id: 's10_opt_b',
          text: 'Skip the meeting and write the email all afternoon.',
          quality: ChoiceQuality.poor,
          feedback: 'Unprofessional! Skipping a confirmed manager meeting causes severe problems.',
          xpReward: 10,
          naturalnessScore: 0.4,
          politenessScore: 0.2,
          accuracyScore: 0.3,
        ),
        DialogueOption(
          id: 's10_opt_c',
          text: 'Do neither and leave early.',
          quality: ChoiceQuality.incorrect,
          feedback: 'Abandoning your obligations fails the entire workday.',
          xpReward: 5,
          naturalnessScore: 0.1,
          politenessScore: 0.1,
          accuracyScore: 0.0,
        ),
      ],
      correctOptionIndex: 0,
    ),
  ],
);
