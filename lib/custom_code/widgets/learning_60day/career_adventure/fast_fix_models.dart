import 'package:flutter/material.dart';

/// Challenge types representing rapid diagnostics and repairs in Level 8.
enum FastFixChallengeType {
  spotError,
  missingWord,
  wordChoice,
  messageRepair,
  grammarTerminal,
  naturalResponse,
  documentDelivery,
  speedRepair,
  listenAndCorrect,
  systemOverride,
}

/// A specific repair option for the terminal.
class FixOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String explanation;
  final int xpReward;

  const FixOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.explanation,
    this.xpReward = 20,
  });
}

/// Individual sentence item evaluated during the 30-second Speed Repair (Challenge 8).
class SpeedSentenceItem {
  final String id;
  final String sentence;
  final bool hasError;
  final String correctedSentence;
  final String explanation;

  const SpeedSentenceItem({
    required this.id,
    required this.sentence,
    required this.hasError,
    required this.correctedSentence,
    required this.explanation,
  });
}

/// Operations document items for Challenge 7.
class OperationsDocumentItem {
  final String id;
  final String title;
  final String recipient;
  final bool isTarget;

  const OperationsDocumentItem({
    required this.id,
    required this.title,
    required this.recipient,
    required this.isTarget,
  });
}

/// Single problem in the final 60-second System Override (Challenge 10).
class SystemOverrideSubProblem {
  final String id;
  final String category;
  final String corruptedText;
  final List<String> choices;
  final String correctAnswer;
  final String explanation;

  const SystemOverrideSubProblem({
    required this.id,
    required this.category,
    required this.corruptedText,
    required this.choices,
    required this.correctAnswer,
    required this.explanation,
  });
}

/// A single challenge in the Operations Center.
class FastFixChallenge {
  final int id;
  final FastFixChallengeType type;
  final String terminalCode;
  final String zoneTitle;
  final String title;
  final String corruptedDisplay;
  final String spokenText;
  final String hint;
  final List<FixOption> options;
  final int correctOptionIndex;
  final int timeLimitSeconds;
  final List<SpeedSentenceItem>? speedSentences;
  final List<OperationsDocumentItem>? documentChoices;
  final List<SystemOverrideSubProblem>? overrideProblems;

  const FastFixChallenge({
    required this.id,
    required this.type,
    required this.terminalCode,
    required this.zoneTitle,
    required this.title,
    required this.corruptedDisplay,
    required this.spokenText,
    required this.hint,
    required this.options,
    required this.correctOptionIndex,
    this.timeLimitSeconds = 0,
    this.speedSentences,
    this.documentChoices,
    this.overrideProblems,
  });

  FixOption get correctOption => options[correctOptionIndex];
}

/// A connected operations zone in the 2D facility.
class OperationsFacilityZone {
  final String id;
  final String name;
  final double startX;
  final double endX;
  final Color primaryColor;
  final IconData icon;

  const OperationsFacilityZone({
    required this.id,
    required this.name,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.icon,
  });
}

/// Complete curriculum data structure for Mission 08.
class FastFixLevelData {
  final String missionId;
  final String title;
  final String subtitle;
  final String tagline;
  final List<String> targetVocabulary;
  final List<OperationsFacilityZone> zones;
  final List<FastFixChallenge> challenges;
  final String finalAlertMessage;

  const FastFixLevelData({
    required this.missionId,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.targetVocabulary,
    required this.zones,
    required this.challenges,
    required this.finalAlertMessage,
  });
}

/// Full Curriculum for Level 8 – Fast Fix
final kMission08FastFixData = FastFixLevelData(
  missionId: '08',
  title: 'Mission 08 – Fast Fix',
  subtitle: '2D Flame Grammar & Error Repair Operations',
  tagline: 'Spot the mistake. Fix the English. Save the day.',
  targetVocabulary: const [
    'updated',
    'confirm',
    'report',
    'appointment',
    'information',
    'document',
    'available',
    'request',
    'issue',
    'problem',
    'solution',
    'deadline',
    'schedule',
    'customer',
    'message',
    'repair',
    'terminal',
    'system',
    'control',
    'restore',
  ],
  zones: const [
    OperationsFacilityZone(
      id: 'reception',
      name: 'Reception & Mainframe',
      startX: 0,
      endX: 380,
      primaryColor: Color(0xFF0EA5E9),
      icon: Icons.monitor_heart_rounded,
    ),
    OperationsFacilityZone(
      id: 'customer_desk',
      name: 'Customer Service Desk',
      startX: 380,
      endX: 740,
      primaryColor: Color(0xFF10B981),
      icon: Icons.headset_mic_rounded,
    ),
    OperationsFacilityZone(
      id: 'office',
      name: 'Operations Office Area',
      startX: 740,
      endX: 1120,
      primaryColor: Color(0xFFF59E0B),
      icon: Icons.computer_rounded,
    ),
    OperationsFacilityZone(
      id: 'info_room',
      name: 'Information & Document Room',
      startX: 1120,
      endX: 1520,
      primaryColor: Color(0xFF6366F1),
      icon: Icons.folder_copy_rounded,
    ),
    OperationsFacilityZone(
      id: 'control_center',
      name: 'Communication Control Center',
      startX: 1520,
      endX: 1900,
      primaryColor: Color(0xFFEC4899),
      icon: Icons.dns_rounded,
    ),
  ],
  finalAlertMessage:
      'COMMUNICATION SYSTEM CRITICAL: Override all corrupt parameters before server shutdown!',
  challenges: [
    // Challenge 1: Spot the Error
    FastFixChallenge(
      id: 1,
      type: FastFixChallengeType.spotError,
      terminalCode: 'TERM-01',
      zoneTitle: 'Reception Terminal',
      title: 'Spot the Mistake: Preposition & Tense',
      corruptedDisplay: '“I am working here since two years.”',
      spokenText: 'I am working here since two years.',
      hint: "Use 'for' to describe a duration/period of time, and Present Perfect Continuous for an action continuing until now.",
      options: [
        FixOption(
          id: 'c1_opt_a',
          text: '“I have been working here for two years.”',
          isCorrect: true,
          explanation: "Correct! Use 'for' with a period of time (two years) and 'have been working' for continuous duration.",
          xpReward: 25,
        ),
        FixOption(
          id: 'c1_opt_b',
          text: '“I working here from two years.”',
          isCorrect: false,
          explanation: "Incorrect: missing auxiliary verb and wrong preposition.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c1_opt_c',
          text: '“I was work here since two years.”',
          isCorrect: false,
          explanation: "Incorrect grammar: 'was work' is invalid.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 2: Missing Word
    FastFixChallenge(
      id: 2,
      type: FastFixChallengeType.missingWord,
      terminalCode: 'TERM-02',
      zoneTitle: 'Customer Desk Gateway',
      title: 'Missing Word: Modal Verb Structure',
      corruptedDisplay: '“Could you ___ me the report?”',
      spokenText: 'Could you send me the report?',
      hint: 'After the modal verb could, always use the base form of the verb without -s, -ed, or -ing.',
      options: [
        FixOption(
          id: 'c2_opt_a',
          text: 'send',
          isCorrect: true,
          explanation: "Correct! Modal verbs like 'could' take the bare infinitive: 'Could you send...'",
          xpReward: 20,
        ),
        FixOption(
          id: 'c2_opt_b',
          text: 'sent',
          isCorrect: false,
          explanation: "Incorrect: 'sent' is the past form. Modals take the base form.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c2_opt_c',
          text: 'sending',
          isCorrect: false,
          explanation: "Incorrect: cannot use -ing participle directly after 'could you'.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c2_opt_d',
          text: 'sends',
          isCorrect: false,
          explanation: "Incorrect: third person -s is never used after modal verbs.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 3: Word Choice
    FastFixChallenge(
      id: 3,
      type: FastFixChallengeType.wordChoice,
      terminalCode: 'TERM-03',
      zoneTitle: 'Service Dispatch Terminal',
      title: 'Word Choice in Workplace Context',
      corruptedDisplay: '“Please ___ the meeting before 5 PM.”',
      spokenText: 'Please confirm the meeting before five PM.',
      hint: 'Choose the professional action meaning to verify or agree to attendance.',
      options: [
        FixOption(
          id: 'c3_opt_a',
          text: 'confirm',
          isCorrect: true,
          explanation: "Correct! 'Confirm the meeting' means to verify schedule attendance.",
          xpReward: 20,
        ),
        FixOption(
          id: 'c3_opt_b',
          text: 'consume',
          isCorrect: false,
          explanation: "Incorrect: 'consume' means to eat or use up resources, not schedule meetings.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c3_opt_c',
          text: 'connect',
          isCorrect: false,
          explanation: "Incorrect: 'connect' does not fit natural workplace meeting RSVP phrasing.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c3_opt_d',
          text: 'continue',
          isCorrect: false,
          explanation: "Incorrect: 'continue the meeting before 5 PM' is logically awkward.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 4: Message Repair
    FastFixChallenge(
      id: 4,
      type: FastFixChallengeType.messageRepair,
      terminalCode: 'TERM-04',
      zoneTitle: 'Customer Inquiries Screen',
      title: 'Infinitive Marker Repair',
      corruptedDisplay: '“Hi, I would like ___ change my appointment.”',
      spokenText: 'Hi, I would like to change my appointment.',
      hint: "'Would like' is followed by the full infinitive 'to + verb'.",
      options: [
        FixOption(
          id: 'c4_opt_a',
          text: 'to',
          isCorrect: true,
          explanation: "Correct! The structure is 'would like to do something'.",
          xpReward: 20,
        ),
        FixOption(
          id: 'c4_opt_b',
          text: 'for',
          isCorrect: false,
          explanation: "Incorrect: 'would like for change' is ungrammatical.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c4_opt_c',
          text: 'at',
          isCorrect: false,
          explanation: "Incorrect: 'at' indicates location or specific time, not infinitive action.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c4_opt_d',
          text: 'on',
          isCorrect: false,
          explanation: "Incorrect: 'on' cannot introduce a base verb.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 5: Grammar Terminal
    FastFixChallenge(
      id: 5,
      type: FastFixChallengeType.grammarTerminal,
      terminalCode: 'TERM-05',
      zoneTitle: 'Central Operations Workstation',
      title: 'Subject-Verb Agreement Repair',
      corruptedDisplay: '“She don’t have enough information.”',
      spokenText: 'She doesn’t have enough information.',
      hint: "Third-person singular pronouns (He, She, It) require 'doesn’t', not 'don’t'.",
      options: [
        FixOption(
          id: 'c5_opt_a',
          text: 'She doesn’t have enough information.',
          isCorrect: true,
          explanation: "Correct! Third-person singular uses 'doesn't' + base verb 'have'.",
          xpReward: 25,
        ),
        FixOption(
          id: 'c5_opt_b',
          text: 'She don’t has enough information.',
          isCorrect: false,
          explanation: "Incorrect: double error. 'Don't' is wrong, and 'has' after an auxiliary is wrong.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c5_opt_c',
          text: 'She not have enough information.',
          isCorrect: false,
          explanation: "Incorrect: missing the auxiliary verb 'does'.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c5_opt_d',
          text: 'She doesn’t has enough information.',
          isCorrect: false,
          explanation: "Incorrect: after 'doesn't', always use the base form 'have', never 'has'.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 6: Natural English
    FastFixChallenge(
      id: 6,
      type: FastFixChallengeType.naturalResponse,
      terminalCode: 'TERM-06',
      zoneTitle: 'Operations Desk Intercom',
      title: 'Natural Professional Workplace Response',
      corruptedDisplay: 'Colleague: “I need help with this problem.”',
      spokenText: 'I need help with this problem.',
      hint: "Choose the natural, fluent, helpful English offer.",
      options: [
        FixOption(
          id: 'c6_opt_a',
          text: '“Sure. Let me take a look.”',
          isCorrect: true,
          explanation: "Correct! 'Sure. Let me take a look' is the standard polite workplace response.",
          xpReward: 25,
        ),
        FixOption(
          id: 'c6_opt_b',
          text: '“Problem give me.”',
          isCorrect: false,
          explanation: "Incorrect: blunt, unnatural pidgin English.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c6_opt_c',
          text: '“I help later yesterday.”',
          isCorrect: false,
          explanation: "Incorrect: 'later' and 'yesterday' conflict completely.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c6_opt_d',
          text: '“Take problem.”',
          isCorrect: false,
          explanation: "Incorrect: fragmented and confusing.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 7: Message Match & Document Delivery
    FastFixChallenge(
      id: 7,
      type: FastFixChallengeType.documentDelivery,
      terminalCode: 'TERM-07',
      zoneTitle: 'Document Archive Terminal',
      title: 'Message Match & Delivery Task',
      corruptedDisplay: '“Please send the updated report to Sarah before 4 PM.”',
      spokenText: 'Please send the updated report to Sarah before four PM.',
      hint: 'Select the Updated Report (not Old Report or Invoice) and deliver it to Sarah.',
      documentChoices: const [
        OperationsDocumentItem(
          id: 'doc_invoice',
          title: 'Monthly Service Invoice',
          recipient: 'Accounting',
          isTarget: false,
        ),
        OperationsDocumentItem(
          id: 'doc_old_report',
          title: 'Q1 Outdated Report',
          recipient: 'Archive',
          isTarget: false,
        ),
        OperationsDocumentItem(
          id: 'doc_updated_report',
          title: 'Updated Operations Report',
          recipient: 'Sarah',
          isTarget: true,
        ),
      ],
      options: [
        FixOption(
          id: 'c7_opt_a',
          text: 'Deliver the Updated Operations Report to Sarah.',
          isCorrect: true,
          explanation: "Correct! Target document matched and delivered to Sarah.",
          xpReward: 30,
        ),
        FixOption(
          id: 'c7_opt_b',
          text: 'Deliver the Old Report to Sarah.',
          isCorrect: false,
          explanation: "Incorrect: the message specifically requested the updated report.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c7_opt_c',
          text: 'Deliver the Invoice to Michael.',
          isCorrect: false,
          explanation: "Incorrect document and recipient.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 8: Speed Repair
    FastFixChallenge(
      id: 8,
      type: FastFixChallengeType.speedRepair,
      terminalCode: 'TERM-08',
      zoneTitle: 'Rapid Diagnostics Screen',
      title: '30-Second Speed Repair: Scan 5 Sentences',
      corruptedDisplay: 'Diagnostic scan active: Identify sentences that contain errors!',
      spokenText: 'Diagnostic scan active. Identify the sentences that contain errors.',
      timeLimitSeconds: 30,
      hint: 'Look closely at subject-verb agreement and past tense time markers.',
      speedSentences: const [
        SpeedSentenceItem(
          id: 's1',
          sentence: 'He go to work every day.',
          hasError: true,
          correctedSentence: 'He goes to work every day.',
          explanation: "Subject 'He' takes 'goes', not 'go'.",
        ),
        SpeedSentenceItem(
          id: 's2',
          sentence: 'I have finished the work yesterday.',
          hasError: true,
          correctedSentence: 'I finished the work yesterday.',
          explanation: "Specific past time 'yesterday' requires Simple Past.",
        ),
        SpeedSentenceItem(
          id: 's3',
          sentence: 'Could you send me the file?',
          hasError: false,
          correctedSentence: 'Could you send me the file?',
          explanation: 'This sentence is already grammatically correct.',
        ),
        SpeedSentenceItem(
          id: 's4',
          sentence: 'She don’t understand.',
          hasError: true,
          correctedSentence: 'She doesn’t understand.',
          explanation: "'She' requires 'doesn’t', not 'don’t'.",
        ),
        SpeedSentenceItem(
          id: 's5',
          sentence: 'We are meeting at 3 PM.',
          hasError: false,
          correctedSentence: 'We are meeting at 3 PM.',
          explanation: 'This sentence is already grammatically correct.',
        ),
      ],
      options: [
        FixOption(
          id: 'c8_opt_a',
          text: 'Sentences 1, 2, and 4 need correction (3 and 5 are correct).',
          isCorrect: true,
          explanation: "Outstanding rapid diagnosis! You identified all 3 errors accurately.",
          xpReward: 35,
        ),
        FixOption(
          id: 'c8_opt_b',
          text: 'All 5 sentences contain errors.',
          isCorrect: false,
          explanation: "Incorrect: sentences 3 and 5 are completely correct.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c8_opt_c',
          text: 'None of the sentences contain errors.',
          isCorrect: false,
          explanation: "Incorrect: sentences 1, 2, and 4 have grammatical errors.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 9: Listen and Correct
    FastFixChallenge(
      id: 9,
      type: FastFixChallengeType.listenAndCorrect,
      terminalCode: 'TERM-09',
      zoneTitle: 'Audio Log Terminal',
      title: 'Listen & Correct: Past Simple vs Present Perfect',
      corruptedDisplay: 'Audio Playback: “I have sent the document yesterday.”',
      spokenText: 'I have sent the document yesterday.',
      hint: "When a sentence mentions a specific finished time (like 'yesterday'), use Simple Past.",
      options: [
        FixOption(
          id: 'c9_opt_a',
          text: '“I sent the document yesterday.”',
          isCorrect: true,
          explanation: "Correct! Finished time words (yesterday, last week) take Simple Past 'sent'.",
          xpReward: 25,
        ),
        FixOption(
          id: 'c9_opt_b',
          text: '“I have send the document yesterday.”',
          isCorrect: false,
          explanation: "Incorrect: 'have send' is double ungrammatical.",
          xpReward: 5,
        ),
        FixOption(
          id: 'c9_opt_c',
          text: '“I sending the document yesterday.”',
          isCorrect: false,
          explanation: "Incorrect: missing auxiliary verb.",
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 10: Final Challenge - System Override
    FastFixChallenge(
      id: 10,
      type: FastFixChallengeType.systemOverride,
      terminalCode: 'TERM-CORE',
      zoneTitle: 'Central Control Core',
      title: 'Final Override: 60-Second Full Diagnostics',
      corruptedDisplay: 'SYSTEM OVERRIDE ACTIVE: Solve all 6 diagnostic repairs to restore the center!',
      spokenText: 'System override active. Solve all six diagnostic repairs to restore the operations center.',
      timeLimitSeconds: 60,
      hint: 'Stay calm, focus on core grammar rules, and maintain your combo streak!',
      overrideProblems: const [
        SystemOverrideSubProblem(
          id: 'ov1',
          category: 'Subject-Verb',
          corruptedText: 'Every morning, the manager ___ the team.',
          choices: ['meets', 'meet', 'meeting'],
          correctAnswer: 'meets',
          explanation: 'Third-person singular present takes -s: meets.',
        ),
        SystemOverrideSubProblem(
          id: 'ov2',
          category: 'Preposition',
          corruptedText: 'The meeting is scheduled ___ 3:00 PM.',
          choices: ['at', 'in', 'on'],
          correctAnswer: 'at',
          explanation: 'Exact clock times take preposition at.',
        ),
        SystemOverrideSubProblem(
          id: 'ov3',
          category: 'Polite Request',
          corruptedText: '___ you please send the spreadsheet?',
          choices: ['Could', 'Can you did', 'Are'],
          correctAnswer: 'Could',
          explanation: 'Could you please is the professional polite formula.',
        ),
        SystemOverrideSubProblem(
          id: 'ov4',
          category: 'Infinitive',
          corruptedText: 'We agreed ___ complete the audit.',
          choices: ['to', 'for', 'with'],
          correctAnswer: 'to',
          explanation: 'Agree takes full infinitive: agree to complete.',
        ),
        SystemOverrideSubProblem(
          id: 'ov5',
          category: 'Tense',
          corruptedText: 'She ___ the email two hours ago.',
          choices: ['sent', 'has sent', 'send'],
          correctAnswer: 'sent',
          explanation: 'Ago marks finished past time: sent.',
        ),
        SystemOverrideSubProblem(
          id: 'ov6',
          category: 'Vocabulary',
          corruptedText: 'Please ___ the report before filing.',
          choices: ['update', 'undertake', 'uplink'],
          correctAnswer: 'update',
          explanation: 'Update means to make current.',
        ),
      ],
      options: [
        FixOption(
          id: 'c10_opt_a',
          text: 'Authorize Master Reboot & Restore System Integrity',
          isCorrect: true,
          explanation: 'ALL CORES RESTORED! System integrity verified at 100%.',
          xpReward: 50,
        ),
      ],
      correctOptionIndex: 0,
    ),
  ],
);
