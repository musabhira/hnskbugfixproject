import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum MessagePriority {
  normal,
  important,
  urgent,
}

enum MessageStatus {
  unread,
  read,
  inProgress,
  delivered,
  replied,
}

enum MessageActionType {
  deliverInfo,
  matchRecipients,
  typeReply,
  spellingCorrection,
  politeRewrite,
  urgentDelivery,
  sequenceDelivery,
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA STRUCTURES
// ─────────────────────────────────────────────────────────────────────────────

class CampusZone {
  final String id;
  final String name;
  final double worldX;
  final Color color;
  final IconData icon;
  final String description;

  const CampusZone({
    required this.id,
    required this.name,
    required this.worldX,
    required this.color,
    required this.icon,
    required this.description,
  });
}

class CampusNpc {
  final String id;
  final String name;
  final String role;
  final String zoneId;
  final double worldX;
  final String avatarSymbol;
  final Color badgeColor;

  const CampusNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.zoneId,
    required this.worldX,
    required this.avatarSymbol,
    required this.badgeColor,
  });
}

class MessageRunnerTask {
  final String id;
  final String sender;
  final String recipientId;
  final String recipientName;
  final String messageTitle;
  final String messageBody;
  final MessagePriority priority;
  final MessageActionType actionType;
  final String targetZoneId;
  final String prompt;
  final List<String> dialogueOptions;
  final int correctOptionIndex;
  final String referenceReply;
  final List<String> acceptedKeywords;
  final String? spellingPrompt;
  final String? misspelledWord;
  final String? correctWord;
  final Map<String, String>? matchPairs; // messageId -> recipientName
  final int timeLimitSeconds;
  final int xpReward;
  final String hint;

  const MessageRunnerTask({
    required this.id,
    required this.sender,
    required this.recipientId,
    required this.recipientName,
    required this.messageTitle,
    required this.messageBody,
    this.priority = MessagePriority.normal,
    required this.actionType,
    required this.targetZoneId,
    required this.prompt,
    this.dialogueOptions = const [],
    this.correctOptionIndex = 0,
    this.referenceReply = '',
    this.acceptedKeywords = const [],
    this.spellingPrompt,
    this.misspelledWord,
    this.correctWord,
    this.matchPairs,
    this.timeLimitSeconds = 0,
    this.xpReward = 25,
    required this.hint,
  });
}

class MessageEvaluationResult {
  final int score;
  final bool isAcceptable;
  final List<String> matchedKeywords;
  final String feedback;

  const MessageEvaluationResult({
    required this.score,
    required this.isAcceptable,
    required this.matchedKeywords,
    required this.feedback,
  });
}

class MessageRunnerLevelData {
  final String title;
  final String tagline;
  final List<CampusZone> zones;
  final List<CampusNpc> npcs;
  final List<MessageRunnerTask> tasks;
  final List<String> targetVocabulary;

  const MessageRunnerLevelData({
    required this.title,
    required this.tagline,
    required this.zones,
    required this.npcs,
    required this.tasks,
    required this.targetVocabulary,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// EVALUATION SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class MessageEvaluationService {
  static MessageEvaluationResult evaluateReply({
    required String input,
    required List<String> requiredKeywords,
    required String referenceAnswer,
    MessageActionType actionType = MessageActionType.typeReply,
  }) {
    final cleanInput = input.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    if (cleanInput.isEmpty) {
      return const MessageEvaluationResult(
        score: 0,
        isAcceptable: false,
        matchedKeywords: [],
        feedback: 'Please enter a reply before sending.',
      );
    }

    final matched = <String>[];
    for (final kw in requiredKeywords) {
      final cleanKw = kw.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      if (cleanInput.contains(cleanKw)) {
        matched.add(kw);
      }
    }

    // Keyword coverage ratio
    final keywordRatio = requiredKeywords.isEmpty
        ? 1.0
        : (matched.length / requiredKeywords.length).clamp(0.0, 1.0);

    // Contraction & Natural phrase leniency
    int baseScore = (keywordRatio * 80).round();

    // Check sentence length and basic structure
    final wordCount = cleanInput.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (wordCount >= 3) {
      baseScore += 15;
    } else if (wordCount >= 2) {
      baseScore += 8;
    }

    final score = baseScore.clamp(10, 100);
    final isAcceptable = requiredKeywords.isEmpty ? true : matched.isNotEmpty && score >= 60;

    String feedback = 'Good communication!';
    if (score >= 90) {
      feedback = 'Excellent workplace communication!';
    } else if (score >= 70) {
      feedback = 'Clear and understood message delivered.';
    } else if (score >= 50) {
      feedback = 'Understood, but try to include key details.';
    } else {
      feedback = 'Missing important key information. Try again.';
    }

    return MessageEvaluationResult(
      score: score,
      isAcceptable: isAcceptable,
      matchedKeywords: matched,
      feedback: feedback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURRICULUM DATA – LEVEL 12: MESSAGE RUNNER
// ─────────────────────────────────────────────────────────────────────────────

const kMission12MessageRunnerData = MessageRunnerLevelData(
  title: 'Level 12 – Message Runner',
  tagline: 'Read fast. Type smart. Deliver the right message.',
  zones: [
    CampusZone(
      id: 'reception',
      name: 'Reception',
      worldX: 120,
      color: Color(0xFF38BDF8),
      icon: Icons.meeting_room_rounded,
      description: 'Main lobby, visitor sign-in, and guest arrival desk.',
    ),
    CampusZone(
      id: 'open_office',
      name: 'Open Office',
      worldX: 380,
      color: Color(0xFF818CF8),
      icon: Icons.computer_rounded,
      description: 'Shared engineering & design desks with workstations.',
    ),
    CampusZone(
      id: 'meeting_rooms',
      name: 'Meeting Rooms',
      worldX: 650,
      color: Color(0xFF34D399),
      icon: Icons.groups_rounded,
      description: 'Glass-walled collaboration spaces for sprint planning.',
    ),
    CampusZone(
      id: 'cafeteria',
      name: 'Cafeteria',
      worldX: 920,
      color: Color(0xFFFBBF24),
      icon: Icons.coffee_rounded,
      description: 'Coffee machines, quick snack tables, and casual talks.',
    ),
    CampusZone(
      id: 'training_room',
      name: 'Training Room',
      worldX: 1200,
      color: Color(0xFFA78BFA),
      icon: Icons.school_rounded,
      description: 'Onboarding station and projection screens.',
    ),
    CampusZone(
      id: 'managers_office',
      name: "Manager's Office",
      worldX: 1480,
      color: Color(0xFFF87171),
      icon: Icons.badge_rounded,
      description: 'Executive suite and strategic operations.',
    ),
    CampusZone(
      id: 'waiting_area',
      name: 'Waiting Area',
      worldX: 1750,
      color: Color(0xFF2DD4BF),
      icon: Icons.chair_rounded,
      description: 'Client lounge with comfortable couches.',
    ),
    CampusZone(
      id: 'conference_room',
      name: 'Conference Room',
      worldX: 2020,
      color: Color(0xFFC084FC),
      icon: Icons.co_present_rounded,
      description: 'Grand boardroom for executive presentations.',
    ),
    CampusZone(
      id: 'comm_desk',
      name: 'Communication Desk',
      worldX: 2280,
      color: Color(0xFF60A5FA),
      icon: Icons.mark_email_read_rounded,
      description: 'Central message dispatch and logging station.',
    ),
  ],
  npcs: [
    CampusNpc(
      id: 'elena',
      name: 'Elena',
      role: 'Receptionist',
      zoneId: 'reception',
      worldX: 120,
      avatarSymbol: '👩‍💼',
      badgeColor: Color(0xFF38BDF8),
    ),
    CampusNpc(
      id: 'sarah',
      name: 'Sarah',
      role: 'Design Specialist',
      zoneId: 'open_office',
      worldX: 380,
      avatarSymbol: '👩‍💻',
      badgeColor: Color(0xFF818CF8),
    ),
    CampusNpc(
      id: 'daniel',
      name: 'Daniel',
      role: 'Project Lead',
      zoneId: 'meeting_rooms',
      worldX: 650,
      avatarSymbol: '👨‍💼',
      badgeColor: Color(0xFF34D399),
    ),
    CampusNpc(
      id: 'michael',
      name: 'Michael',
      role: 'Operations Coordinator',
      zoneId: 'training_room',
      worldX: 1200,
      avatarSymbol: '👨‍💻',
      badgeColor: Color(0xFFA78BFA),
    ),
    CampusNpc(
      id: 'maya',
      name: 'Maya',
      role: 'HR Manager',
      zoneId: 'managers_office',
      worldX: 1480,
      avatarSymbol: '👩‍💼',
      badgeColor: Color(0xFFF87171),
    ),
    CampusNpc(
      id: 'david',
      name: 'David',
      role: 'Senior Executive',
      zoneId: 'conference_room',
      worldX: 2020,
      avatarSymbol: '👨‍💼',
      badgeColor: Color(0xFFC084FC),
    ),
  ],
  tasks: [
    // Task 1: Basic Information Delivery
    MessageRunnerTask(
      id: 'msg_001',
      sender: 'Communications Lead',
      recipientId: 'daniel',
      recipientName: 'Daniel',
      messageTitle: 'Meeting Time Change',
      messageBody: 'Please tell Daniel that the meeting has been moved to 3 PM.',
      priority: MessagePriority.normal,
      actionType: MessageActionType.deliverInfo,
      targetZoneId: 'meeting_rooms',
      prompt: 'Deliver the meeting update to Daniel in the Meeting Rooms.',
      dialogueOptions: [
        'The meeting is moved to 3 PM.',
        'The meeting starts at 10 AM tomorrow.',
        'Daniel, can you cancel the meeting?',
      ],
      correctOptionIndex: 0,
      xpReward: 25,
      hint: 'Look for Daniel in the Meeting Rooms. The time is 3 PM.',
    ),

    // Task 2: Dialogue Selection
    MessageRunnerTask(
      id: 'msg_002',
      sender: 'Reception Desk',
      recipientId: 'sarah',
      recipientName: 'Sarah',
      messageTitle: 'Client Arrival Notice',
      messageBody: 'Tell Sarah that the client will arrive at 11:30 AM.',
      priority: MessagePriority.normal,
      actionType: MessageActionType.deliverInfo,
      targetZoneId: 'open_office',
      prompt: 'Find Sarah in the Open Office and tell her when the client arrives.',
      dialogueOptions: [
        'The client will arrive at 11:30 AM.',
        'The client has rescheduled to next Monday.',
        'Sarah, please prepare the invoices by 11:30 AM.',
      ],
      correctOptionIndex: 0,
      xpReward: 25,
      hint: 'Sarah is at Open Office. Key detail: Client arrives at 11:30 AM.',
    ),

    // Task 3: Multi-detail scanning
    MessageRunnerTask(
      id: 'msg_003',
      sender: 'Operations Team',
      recipientId: 'michael',
      recipientName: 'Michael',
      messageTitle: 'Presentation Folder Request',
      messageBody:
          'Please ask Michael to bring the blue presentation folder to Meeting Room 2 before lunch.',
      priority: MessagePriority.important,
      actionType: MessageActionType.deliverInfo,
      targetZoneId: 'training_room',
      prompt: 'Scan the message for: Person, Object, Location, and Time.',
      dialogueOptions: [
        'Please bring the blue presentation folder to Meeting Room 2 before lunch.',
        'Michael, please email the PDF presentation after lunch.',
        'Can you bring the red projector to the cafeteria?',
      ],
      correctOptionIndex: 0,
      xpReward: 30,
      hint: 'Key items: Blue presentation folder, Meeting Room 2, before lunch.',
    ),

    // Task 4: Drag & Drop 3-Way Recipient Match
    MessageRunnerTask(
      id: 'msg_004',
      sender: 'Office Dispatch',
      recipientId: 'multi',
      recipientName: 'Sarah, Michael & Daniel',
      messageTitle: 'Batch Dispatch Match',
      messageBody: 'Match each incoming message to its designated recipient.',
      priority: MessagePriority.important,
      actionType: MessageActionType.matchRecipients,
      targetZoneId: 'open_office',
      prompt: 'Match 3 messages with the correct team members.',
      matchPairs: {
        'Design asset review for mobile app': 'Sarah',
        'Check training projector HDMI cable': 'Michael',
        'Confirm sprint backlog deliverables': 'Daniel',
      },
      xpReward: 35,
      hint: 'Design -> Sarah, Training/Equipment -> Michael, Sprint -> Daniel.',
    ),

    // Task 5: Text Typing Response
    MessageRunnerTask(
      id: 'msg_005',
      sender: 'Manager David',
      recipientId: 'sarah',
      recipientName: 'Sarah',
      messageTitle: 'Delay Notification',
      messageBody: 'Please tell Sarah that I’ll be late by ten minutes.',
      priority: MessagePriority.normal,
      actionType: MessageActionType.typeReply,
      targetZoneId: 'open_office',
      prompt: 'Tell Sarah that you will arrive 10 minutes late.',
      referenceReply: "I'll be late by ten minutes.",
      acceptedKeywords: ['late', '10', 'ten', 'minutes'],
      xpReward: 35,
      hint: "Start with: I'll be... or I will be...",
    ),

    // Task 6: Workplace Spelling Correction
    MessageRunnerTask(
      id: 'msg_006',
      sender: 'HR Automated Bot',
      recipientId: 'maya',
      recipientName: 'Maya',
      messageTitle: 'Calendar Invite Correction',
      messageBody: 'The calendar system encountered a spelling error in a key term.',
      priority: MessagePriority.normal,
      actionType: MessageActionType.spellingCorrection,
      targetZoneId: 'managers_office',
      prompt: 'Correct the misspelled workplace term: "appointmnt"',
      spellingPrompt: 'appointmnt',
      misspelledWord: 'appointmnt',
      correctWord: 'appointment',
      xpReward: 25,
      hint: 'Remember the double "p" and the missing "e" before "ment".',
    ),

    // Task 7: Natural Reply to Meeting Invitation
    MessageRunnerTask(
      id: 'msg_007',
      sender: 'Daniel (Project Lead)',
      recipientId: 'daniel',
      recipientName: 'Daniel',
      messageTitle: 'Meeting Attendance Check',
      messageBody: 'Can you attend the meeting at 4 PM?',
      priority: MessagePriority.normal,
      actionType: MessageActionType.typeReply,
      targetZoneId: 'meeting_rooms',
      prompt: 'Type a polite reply confirming that you can attend.',
      referenceReply: 'Yes, I can attend the meeting.',
      acceptedKeywords: ['yes', 'attend', 'there', 'make', 'can'],
      xpReward: 30,
      hint: 'Accepted: "Yes, I can attend." or "Yes, I\'ll be there." or "Sure, I can make it."',
    ),

    // Task 8: Directory & Role Identification
    MessageRunnerTask(
      id: 'msg_008',
      sender: 'Senior Management',
      recipientId: 'maya',
      recipientName: 'Maya',
      messageTitle: 'HR Document Delivery',
      messageBody: 'Please send this confidential document to the HR manager.',
      priority: MessagePriority.important,
      actionType: MessageActionType.deliverInfo,
      targetZoneId: 'managers_office',
      prompt: 'Find the HR Manager using the campus directory.',
      dialogueOptions: [
        'Here is the confidential document for HR, Maya.',
        'Hello Elena, here is the HR document.',
        'Michael, can you sign this HR paper?',
      ],
      correctOptionIndex: 0,
      xpReward: 30,
      hint: 'Maya is the HR Manager. Her office is in the Manager’s Office zone.',
    ),

    // Task 9: Professional / Polite Rewrite
    MessageRunnerTask(
      id: 'msg_009',
      sender: 'Communications Coach',
      recipientId: 'david',
      recipientName: 'David',
      messageTitle: 'Polite Phrasing Practice',
      messageBody: 'Make this blunt request more natural and polite: "Hi, I want information about the meeting."',
      priority: MessagePriority.important,
      actionType: MessageActionType.politeRewrite,
      targetZoneId: 'conference_room',
      prompt: 'Type or choose the polite professional version.',
      dialogueOptions: [
        'Hi, I’d like some information about the meeting, please.',
        'Hey, tell me about the meeting now.',
        'Send meeting info quickly.',
      ],
      correctOptionIndex: 0,
      referenceReply: "Hi, I'd like some information about the meeting.",
      acceptedKeywords: ['like', 'information', 'about', 'meeting'],
      xpReward: 35,
      hint: 'Use "I would like..." or "I\'d like..." instead of "I want...".',
    ),

    // Task 10: 45-Second URGENT Final Delivery Rush
    MessageRunnerTask(
      id: 'msg_010',
      sender: 'Elena (Reception)',
      recipientId: 'david',
      recipientName: 'David (Senior Manager)',
      messageTitle: 'URGENT: Client Arrived',
      messageBody:
          'URGENT: Please tell the manager that the client has arrived and is waiting in Reception.',
      priority: MessagePriority.urgent,
      actionType: MessageActionType.urgentDelivery,
      targetZoneId: 'conference_room',
      prompt: 'URGENT: 45 SECONDS! Sprint to the Conference Room and notify Manager David!',
      dialogueOptions: [
        'David, the client has arrived and is waiting in Reception.',
        'David, the client cancelled their trip.',
        'The client will be here next hour.',
      ],
      correctOptionIndex: 0,
      timeLimitSeconds: 45,
      xpReward: 50,
      hint: 'Sprint to the Conference Room (x: 2020)! The client is in Reception.',
    ),
  ],
  targetVocabulary: [
    'message',
    'recipient',
    'deliver',
    'urgent',
    'delay',
    'arrive',
    'attend',
    'available',
    'confirm',
    'meeting',
    'manager',
    'client',
    'report',
    'document',
    'folder',
    'department',
    'reception',
    'deadline',
    'information',
    'schedule',
    'reschedule',
    'reply',
    'forward',
    'send',
    'receive',
  ],
);
