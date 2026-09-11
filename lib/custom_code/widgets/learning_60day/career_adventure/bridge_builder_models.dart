import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum PartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  article,
  auxiliary,
  conjunction,
}

enum RepairType {
  bridge,
  platform,
  gate,
  elevator,
  terminal,
  controlTower,
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA STRUCTURES
// ─────────────────────────────────────────────────────────────────────────────

class WordBlock {
  final String id;
  final String text;
  final PartOfSpeech partOfSpeech;
  final int correctIndex;

  const WordBlock({
    required this.id,
    required this.text,
    required this.partOfSpeech,
    required this.correctIndex,
  });

  WordBlock copyWith({
    String? id,
    String? text,
    PartOfSpeech? partOfSpeech,
    int? correctIndex,
  }) {
    return WordBlock(
      id: id ?? this.id,
      text: text ?? this.text,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

class SentenceChallenge {
  final String id;
  final String prompt;
  final String instruction;
  final List<WordBlock> words;
  final String canonicalSentence;
  final List<String> acceptedSentences;
  final RepairType repairType;
  final String repairTargetName;
  final double worldX;
  final String grammarTip;
  final String audioText;
  final int xpReward;
  final List<String>? multiPartSubSentences; // For Grand Bridge

  const SentenceChallenge({
    required this.id,
    required this.prompt,
    required this.instruction,
    required this.words,
    required this.canonicalSentence,
    required this.acceptedSentences,
    required this.repairType,
    required this.repairTargetName,
    required this.worldX,
    required this.grammarTip,
    required this.audioText,
    this.xpReward = 25,
    this.multiPartSubSentences,
  });
}

class FacilityArea {
  final String id;
  final String name;
  final double worldX;
  final Color themeColor;
  final IconData icon;
  final String description;

  const FacilityArea({
    required this.id,
    required this.name,
    required this.worldX,
    required this.themeColor,
    required this.icon,
    required this.description,
  });
}

class BridgeBuilderLevelData {
  final String title;
  final String tagline;
  final List<FacilityArea> areas;
  final List<SentenceChallenge> challenges;
  final List<String> targetVocabulary;

  const BridgeBuilderLevelData({
    required this.title,
    required this.tagline,
    required this.areas,
    required this.challenges,
    required this.targetVocabulary,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// VALIDATION HELPER
// ─────────────────────────────────────────────────────────────────────────────

class SentenceValidationService {
  static bool validateSentence(String assembled, List<String> accepted) {
    final cleanAssembled = _normalize(assembled);
    for (final acc in accepted) {
      if (cleanAssembled == _normalize(acc)) {
        return true;
      }
    }
    return false;
  }

  static String _normalize(String s) {
    return s
        .replaceAll("’", "'")
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9']"), '')
        .trim();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURRICULUM DATA – LEVEL 13: BRIDGE BUILDER
// ─────────────────────────────────────────────────────────────────────────────

const kMission13BridgeBuilderData = BridgeBuilderLevelData(
  title: 'Level 13 – Bridge Builder',
  tagline: 'Build the sentence. Build the path.',
  areas: [
    FacilityArea(
      id: 'start_platform',
      name: 'Starting Platform',
      worldX: 120,
      themeColor: Color(0xFF38BDF8),
      icon: Icons.start_rounded,
      description: 'Initial entry point to the damaged transport facility.',
    ),
    FacilityArea(
      id: 'broken_bridge',
      name: 'Broken Bridge Alpha',
      worldX: 480,
      themeColor: Color(0xFF6366F1),
      icon: Icons.architecture_rounded,
      description: 'Collapsed holographic transit pathway.',
    ),
    FacilityArea(
      id: 'factory_zone',
      name: 'Factory Zone',
      worldX: 840,
      themeColor: Color(0xFFF59E0B),
      icon: Icons.precision_manufacturing_rounded,
      description: 'Automated assembly machines awaiting signal routing.',
    ),
    FacilityArea(
      id: 'elevator_shaft',
      name: 'Elevator Shaft',
      worldX: 1200,
      themeColor: Color(0xFF10B981),
      icon: Icons.elevator_rounded,
      description: 'Vertical lift with disabled energy grid.',
    ),
    FacilityArea(
      id: 'security_gate',
      name: 'Security Gate',
      worldX: 1560,
      themeColor: Color(0xFFEF4444),
      icon: Icons.lock_clock_rounded,
      description: 'High-voltage laser barrier requiring protocol code.',
    ),
    FacilityArea(
      id: 'comm_tower',
      name: 'Communication Tower',
      worldX: 1920,
      themeColor: Color(0xFF8B5CF6),
      icon: Icons.cell_tower_rounded,
      description: 'Relay antenna broadcasting across the transit network.',
    ),
    FacilityArea(
      id: 'control_platform',
      name: 'Control Platform',
      worldX: 2280,
      themeColor: Color(0xFF06B6D4),
      icon: Icons.settings_input_component_rounded,
      description: 'Central console restoring the entire district.',
    ),
  ],
  challenges: [
    // Challenge 1: Present Simple Habitual
    SentenceChallenge(
      id: 'sen_001',
      prompt: 'Repair the first light bridge segment.',
      instruction: 'Arrange the word blocks to build a correct sentence about daily routine:',
      words: [
        WordBlock(id: 'w1_1', text: 'go', partOfSpeech: PartOfSpeech.verb, correctIndex: 1),
        WordBlock(id: 'w1_2', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w1_3', text: 'work', partOfSpeech: PartOfSpeech.noun, correctIndex: 3),
        WordBlock(id: 'w1_4', text: 'to', partOfSpeech: PartOfSpeech.preposition, correctIndex: 2),
        WordBlock(id: 'w1_5', text: 'day', partOfSpeech: PartOfSpeech.noun, correctIndex: 5),
        WordBlock(id: 'w1_6', text: 'every', partOfSpeech: PartOfSpeech.adjective, correctIndex: 4),
      ],
      canonicalSentence: 'I go to work every day.',
      acceptedSentences: ['I go to work every day.'],
      repairType: RepairType.bridge,
      repairTargetName: 'Bridge Segment 1',
      worldX: 480,
      grammarTip: 'Subject (I) + Verb (go) + Prepositional phrase (to work) + Time (every day).',
      audioText: 'I go to work every day.',
      xpReward: 20,
    ),

    // Challenge 2: Past Simple
    SentenceChallenge(
      id: 'sen_002',
      prompt: 'Activate the floating transit platform.',
      instruction: "Complete yesterday's event sentence:",
      words: [
        WordBlock(id: 'w2_1', text: 'visited', partOfSpeech: PartOfSpeech.verb, correctIndex: 1),
        WordBlock(id: 'w2_2', text: 'office', partOfSpeech: PartOfSpeech.noun, correctIndex: 3),
        WordBlock(id: 'w2_3', text: 'She', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w2_4', text: 'yesterday', partOfSpeech: PartOfSpeech.adverb, correctIndex: 4),
        WordBlock(id: 'w2_5', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 2),
      ],
      canonicalSentence: 'She visited the office yesterday.',
      acceptedSentences: ['She visited the office yesterday.'],
      repairType: RepairType.platform,
      repairTargetName: 'Floating Platform A',
      worldX: 620,
      grammarTip: 'Use past form "visited" for completed actions in the past with "yesterday".',
      audioText: 'She visited the office yesterday.',
      xpReward: 20,
    ),

    // Challenge 3: Question Formation
    SentenceChallenge(
      id: 'sen_003',
      prompt: 'Unlock the terminal authentication prompt.',
      instruction: 'Form a grammatically correct workplace question:',
      words: [
        WordBlock(id: 'w3_1', text: 'work', partOfSpeech: PartOfSpeech.verb, correctIndex: 3),
        WordBlock(id: 'w3_2', text: 'Where', partOfSpeech: PartOfSpeech.adverb, correctIndex: 0),
        WordBlock(id: 'w3_3', text: 'you', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 2),
        WordBlock(id: 'w3_4', text: 'do', partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
      ],
      canonicalSentence: 'Where do you work?',
      acceptedSentences: ['Where do you work?'],
      repairType: RepairType.terminal,
      repairTargetName: 'Access Terminal 1',
      worldX: 840,
      grammarTip: 'Question word (Where) + Auxiliary (do) + Subject (you) + Base verb (work)?',
      audioText: 'Where do you work?',
      xpReward: 20,
    ),

    // Challenge 4: Present Perfect Auxiliary
    SentenceChallenge(
      id: 'sen_004',
      prompt: 'Restore power cells to the factory generator.',
      instruction: 'Select and assemble the correct auxiliary structure:',
      words: [
        WordBlock(id: 'w4_1', text: 'finished', partOfSpeech: PartOfSpeech.verb, correctIndex: 2),
        WordBlock(id: 'w4_2', text: 'You', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w4_3', text: 'report', partOfSpeech: PartOfSpeech.noun, correctIndex: 4),
        WordBlock(id: 'w4_4', text: 'have', partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
        WordBlock(id: 'w4_5', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 3),
      ],
      canonicalSentence: 'You have finished the report.',
      acceptedSentences: ['You have finished the report.'],
      repairType: RepairType.terminal,
      repairTargetName: 'Factory Generator Unit',
      worldX: 1020,
      grammarTip: 'Subject (You) + "have" + past participle (finished) for present perfect.',
      audioText: 'You have finished the report.',
      xpReward: 25,
    ),

    // Challenge 5: Preposition Placement
    SentenceChallenge(
      id: 'sen_005',
      prompt: 'Deploy the stepping platform.',
      instruction: 'Form the location sentence with correct preposition:',
      words: [
        WordBlock(id: 'w5_1', text: 'table', partOfSpeech: PartOfSpeech.noun, correctIndex: 5),
        WordBlock(id: 'w5_2', text: 'key', partOfSpeech: PartOfSpeech.noun, correctIndex: 1),
        WordBlock(id: 'w5_3', text: 'is', partOfSpeech: PartOfSpeech.verb, correctIndex: 2),
        WordBlock(id: 'w5_4', text: 'The', partOfSpeech: PartOfSpeech.article, correctIndex: 0),
        WordBlock(id: 'w5_5', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 4),
        WordBlock(id: 'w5_6', text: 'on', partOfSpeech: PartOfSpeech.preposition, correctIndex: 3),
      ],
      canonicalSentence: 'The key is on the table.',
      acceptedSentences: ['The key is on the table.'],
      repairType: RepairType.platform,
      repairTargetName: 'Stepping Platform B',
      worldX: 1200,
      grammarTip: 'Use "on" for items resting on a flat surface.',
      audioText: 'The key is on the table.',
      xpReward: 25,
    ),

    // Challenge 6: Negative Sentence with Contraction support
    SentenceChallenge(
      id: 'sen_006',
      prompt: 'Deactivate the security barrier.',
      instruction: 'Construct the negative clarification sentence:',
      words: [
        WordBlock(id: 'w6_1', text: 'understand', partOfSpeech: PartOfSpeech.verb, correctIndex: 3),
        WordBlock(id: 'w6_2', text: 'do', partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
        WordBlock(id: 'w6_3', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w6_4', text: 'question', partOfSpeech: PartOfSpeech.noun, correctIndex: 5),
        WordBlock(id: 'w6_5', text: 'not', partOfSpeech: PartOfSpeech.adverb, correctIndex: 2),
        WordBlock(id: 'w6_6', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 4),
      ],
      canonicalSentence: 'I do not understand the question.',
      acceptedSentences: [
        'I do not understand the question.',
        "I don't understand the question.",
      ],
      repairType: RepairType.gate,
      repairTargetName: 'Laser Security Barrier',
      worldX: 1560,
      grammarTip: 'Both full form "do not" and contracted "don\'t" are grammatically acceptable.',
      audioText: 'I do not understand the question.',
      xpReward: 25,
    ),

    // Challenge 7: Future Tense with Will
    SentenceChallenge(
      id: 'sen_007',
      prompt: 'Energize the elevator hoist motor.',
      instruction: "Create tomorrow's scheduling promise:",
      words: [
        WordBlock(id: 'w7_1', text: 'tomorrow', partOfSpeech: PartOfSpeech.adverb, correctIndex: 4),
        WordBlock(id: 'w7_2', text: 'call', partOfSpeech: PartOfSpeech.verb, correctIndex: 2),
        WordBlock(id: 'w7_3', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w7_4', text: 'you', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 3),
        WordBlock(id: 'w7_5', text: 'will', partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
      ],
      canonicalSentence: 'I will call you tomorrow.',
      acceptedSentences: [
        'I will call you tomorrow.',
        "I'll call you tomorrow.",
      ],
      repairType: RepairType.elevator,
      repairTargetName: 'Elevator Hoist Engine',
      worldX: 1740,
      grammarTip: 'Future modal "will" + base verb (call) + Object (you) + Time adverb (tomorrow).',
      audioText: 'I will call you tomorrow.',
      xpReward: 25,
    ),

    // Challenge 8: Third Person Singular Agreement
    SentenceChallenge(
      id: 'sen_008',
      prompt: 'Align the relay frequency dish.',
      instruction: 'Fix the subject-verb agreement for third person singular:',
      words: [
        WordBlock(id: 'w8_1', text: 'goes', partOfSpeech: PartOfSpeech.verb, correctIndex: 1),
        WordBlock(id: 'w8_2', text: 'day', partOfSpeech: PartOfSpeech.noun, correctIndex: 6),
        WordBlock(id: 'w8_3', text: 'office', partOfSpeech: PartOfSpeech.noun, correctIndex: 4),
        WordBlock(id: 'w8_4', text: 'She', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w8_5', text: 'to', partOfSpeech: PartOfSpeech.preposition, correctIndex: 2),
        WordBlock(id: 'w8_6', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 3),
        WordBlock(id: 'w8_7', text: 'every', partOfSpeech: PartOfSpeech.adjective, correctIndex: 5),
      ],
      canonicalSentence: 'She goes to the office every day.',
      acceptedSentences: ['She goes to the office every day.'],
      repairType: RepairType.terminal,
      repairTargetName: 'Relay Frequency Dish',
      worldX: 1920,
      grammarTip: 'She / He / It takes the "-es" inflection: "She goes", not "She go".',
      audioText: 'She goes to the office every day.',
      xpReward: 30,
    ),

    // Challenge 9: Complex Sentence with Conjunction "Because"
    SentenceChallenge(
      id: 'sen_009',
      prompt: 'Synchronize the tower control junction.',
      instruction: 'Build a natural workplace explanation using a causal conjunction:',
      words: [
        WordBlock(id: 'w9_1', text: 'meeting', partOfSpeech: PartOfSpeech.noun, correctIndex: 4),
        WordBlock(id: 'w9_2', text: "couldn't", partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
        WordBlock(id: 'w9_3', text: 'sick', partOfSpeech: PartOfSpeech.adjective, correctIndex: 8),
        WordBlock(id: 'w9_4', text: 'attend', partOfSpeech: PartOfSpeech.verb, correctIndex: 2),
        WordBlock(id: 'w9_5', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 0),
        WordBlock(id: 'w9_6', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 3),
        WordBlock(id: 'w9_7', text: 'because', partOfSpeech: PartOfSpeech.conjunction, correctIndex: 5),
        WordBlock(id: 'w9_8', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 6),
        WordBlock(id: 'w9_9', text: 'was', partOfSpeech: PartOfSpeech.verb, correctIndex: 7),
      ],
      canonicalSentence: "I couldn't attend the meeting because I was sick.",
      acceptedSentences: [
        "I couldn't attend the meeting because I was sick.",
        'I could not attend the meeting because I was sick.',
      ],
      repairType: RepairType.terminal,
      repairTargetName: 'Tower Control Junction',
      worldX: 2100,
      grammarTip: 'Main clause (I couldn\'t attend the meeting) + Conjunction (because) + Subordinate clause (I was sick).',
      audioText: "I couldn't attend the meeting because I was sick.",
      xpReward: 35,
    ),

    // Challenge 10: Grand Bridge Restoration (Multi-Sentence)
    SentenceChallenge(
      id: 'sen_010',
      prompt: 'GRAND RESTORATION: Complete the suspension span.',
      instruction: 'Build the master inquiry sentence to reconnect the central control tower:',
      words: [
        WordBlock(id: 'w10_1', text: 'find', partOfSpeech: PartOfSpeech.verb, correctIndex: 4),
        WordBlock(id: 'w10_2', text: 'manager', partOfSpeech: PartOfSpeech.noun, correctIndex: 6),
        WordBlock(id: 'w10_3', text: 'can', partOfSpeech: PartOfSpeech.auxiliary, correctIndex: 1),
        WordBlock(id: 'w10_4', text: 'Where', partOfSpeech: PartOfSpeech.adverb, correctIndex: 0),
        WordBlock(id: 'w10_5', text: 'the', partOfSpeech: PartOfSpeech.article, correctIndex: 5),
        WordBlock(id: 'w10_6', text: 'I', partOfSpeech: PartOfSpeech.pronoun, correctIndex: 2),
      ],
      canonicalSentence: 'Where can I find the manager?',
      acceptedSentences: ['Where can I find the manager?'],
      repairType: RepairType.controlTower,
      repairTargetName: 'Grand Suspension Bridge & Control Tower',
      worldX: 2280,
      grammarTip: 'Question word (Where) + Modal (can) + Subject (I) + Base verb (find) + Object (the manager)?',
      audioText: 'Where can I find the manager?',
      xpReward: 60,
      multiPartSubSentences: [
        'I have an appointment at 3 PM.',
        'Could you send me the report?',
        "I'll call you after lunch.",
        "I couldn't attend the meeting yesterday.",
        'Where can I find the manager?',
      ],
    ),
  ],
  targetVocabulary: [
    'appointment',
    'meeting',
    'report',
    'manager',
    'office',
    'schedule',
    'available',
    'understand',
    'attend',
    'because',
    'tomorrow',
    'yesterday',
    'usually',
    'already',
    'instead',
    'before',
    'after',
    'during',
    'important',
    'confirm',
  ],
);
