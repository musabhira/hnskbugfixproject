import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// Types of speaking challenges in the café mission.
enum SpeakingChallengeType {
  greeting,
  placeOrder,
  yesNoResponse,
  askQuestion,
  clarifyRequest,
  handleMistake,
  askPrice,
  freeSpeaking,
  multiTurn,
}

/// Evaluation result for a spoken response.
enum SpeechResult { excellent, good, needsPractice, retry }

/// State of the microphone interaction.
enum MicState { idle, listening, processing, done }

// ─────────────────────────────────────────────────────────────────────────────
// SPEAKING CHALLENGE DATA
// ─────────────────────────────────────────────────────────────────────────────

/// Accepted keyword cluster. Any one word from the list counts as a match.
class KeywordCluster {
  final String groupName;
  final List<String> keywords;
  final bool isRequired;

  const KeywordCluster({
    required this.groupName,
    required this.keywords,
    this.isRequired = true,
  });
}

/// A single speaking challenge in the Voice Café.
class SpeakingChallenge {
  final int id;
  final SpeakingChallengeType type;
  final String npcDialogue;       // what NPC says
  final String missionInstruction; // small instruction shown to player
  final String referenceResponse;  // example / reference sentence
  final List<String> acceptedKeywords;
  final List<String> altAcceptedPhrases; // semantic alternatives
  final List<KeywordCluster> keywordClusters;
  final int timeLimitSeconds;
  final double pronunciationWeight;
  final double grammarWeight;
  final double communicationWeight;
  final String hint;
  final int xpReward;
  final bool allowFreeResponse; // true = score on attempt, no fixed answer

  const SpeakingChallenge({
    required this.id,
    required this.type,
    required this.npcDialogue,
    required this.missionInstruction,
    required this.referenceResponse,
    required this.acceptedKeywords,
    this.altAcceptedPhrases = const [],
    this.keywordClusters = const [],
    this.timeLimitSeconds = 15,
    this.pronunciationWeight = 0.25,
    this.grammarWeight = 0.25,
    this.communicationWeight = 0.5,
    this.hint = '',
    this.xpReward = 25,
    this.allowFreeResponse = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SPEAKING EVALUATION OUTPUT
// ─────────────────────────────────────────────────────────────────────────────

/// Result returned by SpeakingEvaluationService.
class SpeakingEvaluationResult {
  final String recognizedText;
  final int pronunciationScore;
  final int grammarScore;
  final int keywordScore;
  final int communicationScore;
  final int fluencyScore;
  final int overallScore;
  final SpeechResult result;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final String feedback;

  const SpeakingEvaluationResult({
    required this.recognizedText,
    required this.pronunciationScore,
    required this.grammarScore,
    required this.keywordScore,
    required this.communicationScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.result,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.feedback,
  });

  factory SpeakingEvaluationResult.empty() => const SpeakingEvaluationResult(
        recognizedText: '',
        pronunciationScore: 0,
        grammarScore: 0,
        keywordScore: 0,
        communicationScore: 0,
        fluencyScore: 0,
        overallScore: 0,
        result: SpeechResult.retry,
        matchedKeywords: [],
        missingKeywords: [],
        feedback: '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CAFÉ AREA
// ─────────────────────────────────────────────────────────────────────────────

/// A 2D physical area inside the café world.
class CafeArea {
  final String id;
  final String name;
  final String icon;
  final double startX;
  final double endX;
  final Color primaryColor;
  final Color accentColor;

  const CafeArea({
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
// NPC DATA
// ─────────────────────────────────────────────────────────────────────────────

/// An NPC in the café with a role and personality.
class CafeNpc {
  final String id;
  final String name;
  final String role;
  final String icon;
  final Color accentColor;

  const CafeNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.icon,
    required this.accentColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AGGREGATE SCORE
// ─────────────────────────────────────────────────────────────────────────────

/// Rolling speaking score across all challenges.
class VoiceCafeScore {
  int totalPronunciationScore;
  int totalGrammarScore;
  int totalCommunicationScore;
  int totalFluencyScore;
  int challengesAttempted;
  int challengesSucceeded;
  int totalXp;
  int hintsUsed;
  int retriesUsed;

  VoiceCafeScore()
      : totalPronunciationScore = 0,
        totalGrammarScore = 0,
        totalCommunicationScore = 0,
        totalFluencyScore = 0,
        challengesAttempted = 0,
        challengesSucceeded = 0,
        totalXp = 0,
        hintsUsed = 0,
        retriesUsed = 0;

  void addResult(SpeakingEvaluationResult r) {
    totalPronunciationScore += r.pronunciationScore;
    totalGrammarScore += r.grammarScore;
    totalCommunicationScore += r.communicationScore;
    totalFluencyScore += r.fluencyScore;
    challengesAttempted++;
    if (r.result != SpeechResult.retry) challengesSucceeded++;
  }

  int get avgPronunciation =>
      challengesAttempted == 0 ? 0 : (totalPronunciationScore / challengesAttempted).round();
  int get avgGrammar =>
      challengesAttempted == 0 ? 0 : (totalGrammarScore / challengesAttempted).round();
  int get avgCommunication =>
      challengesAttempted == 0 ? 0 : (totalCommunicationScore / challengesAttempted).round();
  int get avgFluency =>
      challengesAttempted == 0 ? 0 : (totalFluencyScore / challengesAttempted).round();
  int get overall =>
      ((avgPronunciation + avgGrammar + avgCommunication + avgFluency) / 4).round();
  int get confidence =>
      challengesAttempted == 0
          ? 0
          : ((challengesSucceeded / challengesAttempted) * 100 -
                  (retriesUsed * 3).clamp(0, 20))
              .round()
              .clamp(0, 100);
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL DATA
// ─────────────────────────────────────────────────────────────────────────────

/// Complete curriculum and world data for Mission 11 – Voice Café.
class VoiceCafeLevelData {
  final String missionId;
  final String title;
  final String subtitle;
  final String tagline;
  final String missionObjective;
  final List<String> targetVocabulary;
  final List<CafeArea> areas;
  final List<CafeNpc> npcs;
  final List<SpeakingChallenge> challenges;
  final String finalConversationTitle;

  const VoiceCafeLevelData({
    required this.missionId,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.missionObjective,
    required this.targetVocabulary,
    required this.areas,
    required this.npcs,
    required this.challenges,
    required this.finalConversationTitle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SPEAKING EVALUATION SERVICE (Abstraction Layer)
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract interface for speech recognition / evaluation.
/// Decoupled from the Flame game loop and any specific package.
abstract class SpeechRecognitionService {
  Future<void> startListening();
  Future<String> stopListening();
  Future<void> cancelListening();
  bool get isAvailable;
  bool get isListening;
  void dispose();
}

/// Evaluates recognized speech against a challenge.
/// Separated from rendering for testability and future AI replacement.
class SpeakingEvaluationService {
  /// Evaluate recognized text vs. expected challenge.
  /// This is a rule-based implementation for offline use.
  /// Can be replaced with a cloud AI evaluator without touching game code.
  static SpeakingEvaluationResult evaluate({
    required String recognizedText,
    required SpeakingChallenge challenge,
  }) {
    if (recognizedText.trim().isEmpty) {
      return SpeakingEvaluationResult.empty();
    }

    final normalized = recognizedText.toLowerCase().trim();
    final ref = challenge.referenceResponse.toLowerCase();

    // ── Keyword matching ─────────────────────────────────────────────────
    final List<String> matched = [];
    final List<String> missing = [];
    for (final kw in challenge.acceptedKeywords) {
      if (normalized.contains(kw.toLowerCase())) {
        matched.add(kw);
      } else {
        missing.add(kw);
      }
    }

    // Alt phrase bonus
    bool altMatch = false;
    for (final alt in challenge.altAcceptedPhrases) {
      if (normalized.contains(alt.toLowerCase())) {
        altMatch = true;
        break;
      }
    }

    // ── Scoring ─────────────────────────────────────────────────────────
    final requiredCount =
        challenge.acceptedKeywords.isEmpty ? 1 : challenge.acceptedKeywords.length;
    final matchRate =
        challenge.acceptedKeywords.isEmpty ? 1.0 : matched.length / requiredCount;

    // Free response: always count as a communicative attempt
    final keywordScore = challenge.allowFreeResponse
        ? 75
        : (matchRate * 100).round().clamp(0, 100);

    // Grammar heuristic: punish very short or incoherent responses
    final wordCount = normalized.split(' ').length;
    final grammarScore = (wordCount >= 3
            ? 78 + (wordCount.clamp(3, 10) - 3) * 2
            : 60)
        .clamp(60, 100);

    // Pronunciation score: approximate by checking if response is English-looking
    final pronunciationScore = (normalized.contains(' ')
        ? 75 + (altMatch ? 10 : 0) + (matchRate * 15).round()
        : 60)
        .clamp(60, 100);

    // Communication score: weighted by keyword match + reference similarity
    final refWords = ref.split(' ');
    final norWords = normalized.split(' ');
    final commonWords =
        refWords.where((w) => norWords.contains(w) && w.length > 2).length;
    final similarity = refWords.isEmpty ? 0.5 : commonWords / refWords.length;
    final communicationScore =
        ((similarity * 0.4 + matchRate * 0.6) * 100).round().clamp(60, 100);

    // Fluency: approximated by response length
    final fluencyScore = (wordCount >= 5 ? 80 : wordCount >= 3 ? 72 : 60)
        .clamp(60, 100);

    final overall = (pronunciationScore * challenge.pronunciationWeight +
            grammarScore * challenge.grammarWeight +
            communicationScore * challenge.communicationWeight +
            fluencyScore * 0.1)
        .round()
        .clamp(0, 100);

    SpeechResult result;
    String feedback;
    if (overall >= 85) {
      result = SpeechResult.excellent;
      feedback = '🌟 Excellent! Natural and clear.';
    } else if (overall >= 70) {
      result = SpeechResult.good;
      feedback = '✅ Good response! Communicatively effective.';
    } else if (overall >= 55) {
      result = SpeechResult.needsPractice;
      feedback = '💡 Needs Practice – try again or see the example.';
    } else {
      result = SpeechResult.retry;
      feedback = '🔄 Try again. Listen to the reference and repeat.';
    }

    return SpeakingEvaluationResult(
      recognizedText: recognizedText,
      pronunciationScore: pronunciationScore,
      grammarScore: grammarScore,
      keywordScore: keywordScore,
      communicationScore: communicationScore,
      fluencyScore: fluencyScore,
      overallScore: overall,
      result: result,
      matchedKeywords: matched,
      missingKeywords: missing,
      feedback: feedback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 11 CURRICULUM DATA
// ─────────────────────────────────────────────────────────────────────────────

final kMission11VoiceCafeData = VoiceCafeLevelData(
  missionId: '11',
  title: 'Mission 11 – Voice Café',
  subtitle: '2D Speaking Adventure – Café Edition',
  tagline: 'Speak clearly. Be understood. Complete the order.',
  missionObjective:
      'Order your food and prepare for the meeting. You have 20 minutes before it starts.',
  targetVocabulary: const [
    'order',
    'menu',
    'receipt',
    'bill',
    'cashier',
    'takeaway',
    'available',
    'fresh',
    'sparkling',
    'still',
    'sugar',
    'sandwich',
    'coffee',
    'juice',
    'price',
    'total',
    'extra',
    'anything',
    'instead',
    'repeat',
    'appointment',
  ],
  areas: const [
    CafeArea(
      id: 'entrance',
      name: 'Café Entrance',
      icon: '🚪',
      startX: 0,
      endX: 280,
      primaryColor: Color(0xFF1A1207),
      accentColor: Color(0xFFF59E0B),
    ),
    CafeArea(
      id: 'counter',
      name: 'Counter',
      icon: '🍽',
      startX: 280,
      endX: 680,
      primaryColor: Color(0xFF1A0F07),
      accentColor: Color(0xFFEF4444),
    ),
    CafeArea(
      id: 'menu_area',
      name: 'Menu Board',
      icon: '📋',
      startX: 680,
      endX: 1000,
      primaryColor: Color(0xFF0A1520),
      accentColor: Color(0xFF3B82F6),
    ),
    CafeArea(
      id: 'waiting',
      name: 'Waiting Spot',
      icon: '⏳',
      startX: 1000,
      endX: 1300,
      primaryColor: Color(0xFF0F1A10),
      accentColor: Color(0xFF10B981),
    ),
    CafeArea(
      id: 'table',
      name: 'Seating Area',
      icon: '🪑',
      startX: 1300,
      endX: 1600,
      primaryColor: Color(0xFF1A0A1E),
      accentColor: Color(0xFF8B5CF6),
    ),
  ],
  npcs: const [
    CafeNpc(
      id: 'barista',
      name: 'Alex',
      role: 'Barista',
      icon: '☕',
      accentColor: Color(0xFFF59E0B),
    ),
    CafeNpc(
      id: 'cashier',
      name: 'Priya',
      role: 'Cashier',
      icon: '💳',
      accentColor: Color(0xFFEC4899),
    ),
  ],
  finalConversationTitle: '6-Turn Café Conversation',
  challenges: [
    // Challenge 1 – Greeting
    SpeakingChallenge(
      id: 1,
      type: SpeakingChallengeType.greeting,
      npcDialogue: 'Good morning! Welcome to The Brew & Bites.',
      missionInstruction: 'Greet the staff naturally.',
      referenceResponse: 'Good morning! Thank you.',
      acceptedKeywords: ['morning', 'hello', 'hi', 'good', 'thanks', 'thank'],
      altAcceptedPhrases: ['good morning', 'hi there', 'hey good morning'],
      timeLimitSeconds: 10,
      pronunciationWeight: 0.35,
      grammarWeight: 0.20,
      communicationWeight: 0.45,
      hint: 'Say something like "Good morning!" or "Hi, good morning!"',
      xpReward: 20,
    ),

    // Challenge 2 – Place an order
    SpeakingChallenge(
      id: 2,
      type: SpeakingChallengeType.placeOrder,
      npcDialogue: 'What can I get for you today?',
      missionInstruction: 'Order: Coffee + Chicken sandwich.',
      referenceResponse: "I'd like a coffee and a chicken sandwich, please.",
      acceptedKeywords: ['coffee', 'sandwich', 'chicken', 'like', 'please', 'want', 'have'],
      altAcceptedPhrases: [
        'can i have',
        'i would like',
        'could i get',
        'i will have',
        'give me',
      ],
      keywordClusters: [
        KeywordCluster(groupName: 'Drink', keywords: ['coffee', 'espresso'], isRequired: true),
        KeywordCluster(groupName: 'Food', keywords: ['sandwich', 'chicken sandwich'], isRequired: true),
      ],
      timeLimitSeconds: 15,
      pronunciationWeight: 0.25,
      grammarWeight: 0.25,
      communicationWeight: 0.50,
      hint: 'Try: "I\'d like a coffee and a chicken sandwich, please."',
      xpReward: 25,
    ),

    // Challenge 3 – Yes/No response
    SpeakingChallenge(
      id: 3,
      type: SpeakingChallengeType.yesNoResponse,
      npcDialogue: 'Would you like sugar in your coffee?',
      missionInstruction: 'Respond yes or no naturally.',
      referenceResponse: 'No, thank you.',
      acceptedKeywords: ['yes', 'no', 'please', 'thank', 'thanks', 'sure', 'not'],
      altAcceptedPhrases: ['yes please', 'no thank you', 'no thanks', 'yes thank you'],
      timeLimitSeconds: 8,
      pronunciationWeight: 0.30,
      grammarWeight: 0.20,
      communicationWeight: 0.50,
      hint: 'Say "Yes, please." or "No, thank you."',
      xpReward: 20,
      allowFreeResponse: true,
    ),

    // Challenge 4 – Ask a question
    SpeakingChallenge(
      id: 4,
      type: SpeakingChallengeType.askQuestion,
      npcDialogue: 'Would you like anything else?',
      missionInstruction: 'Ask if fresh juice is available.',
      referenceResponse: 'Do you have fresh juice?',
      acceptedKeywords: ['juice', 'fresh', 'have', 'do', 'any', 'available'],
      altAcceptedPhrases: [
        'do you have fresh juice',
        'is fresh juice available',
        'any fresh juice',
        'do you sell juice',
      ],
      timeLimitSeconds: 12,
      pronunciationWeight: 0.25,
      grammarWeight: 0.30,
      communicationWeight: 0.45,
      hint: 'Ask: "Do you have fresh juice?" or "Is fresh juice available?"',
      xpReward: 25,
    ),

    // Challenge 5 – Clarify / request repeat
    SpeakingChallenge(
      id: 5,
      type: SpeakingChallengeType.clarifyRequest,
      npcDialogue: 'Would you like sparkling water or still water?',
      missionInstruction: 'You didn\'t catch that. Ask to repeat.',
      referenceResponse: 'Could you repeat that, please?',
      acceptedKeywords: ['repeat', 'again', 'sorry', 'pardon', 'could', 'please', 'say'],
      altAcceptedPhrases: [
        'could you repeat',
        'say that again',
        'pardon',
        'sorry could you',
        'say again',
        'repeat please',
      ],
      timeLimitSeconds: 10,
      pronunciationWeight: 0.30,
      grammarWeight: 0.25,
      communicationWeight: 0.45,
      hint: 'Ask politely: "Could you repeat that, please?" or "Sorry, can you say that again?"',
      xpReward: 25,
    ),

    // Challenge 6 – Handle mistake (wrong order)
    SpeakingChallenge(
      id: 6,
      type: SpeakingChallengeType.handleMistake,
      npcDialogue: 'Here is your tea. Enjoy!',
      missionInstruction: 'That\'s wrong! You ordered coffee. Correct it politely.',
      referenceResponse: 'Sorry, I ordered a coffee, not tea.',
      acceptedKeywords: ['sorry', 'coffee', 'ordered', 'asked', 'wanted', 'not', 'tea'],
      altAcceptedPhrases: [
        'i ordered a coffee',
        'i asked for coffee',
        'i think i ordered',
        'sorry i wanted coffee',
        'that should be coffee',
      ],
      timeLimitSeconds: 15,
      pronunciationWeight: 0.25,
      grammarWeight: 0.25,
      communicationWeight: 0.50,
      hint: 'Say: "Sorry, I ordered a coffee." or "I think I asked for a coffee, not tea."',
      xpReward: 25,
    ),

    // Challenge 7 – Ask price
    SpeakingChallenge(
      id: 7,
      type: SpeakingChallengeType.askPrice,
      npcDialogue: 'That will be ₹320 in total.',
      missionInstruction: 'Ask how much the sandwich costs separately.',
      referenceResponse: 'How much is the sandwich?',
      acceptedKeywords: ['much', 'sandwich', 'cost', 'price', 'how', 'pay'],
      altAcceptedPhrases: [
        'how much is the sandwich',
        'how much does the sandwich cost',
        'what is the price of the sandwich',
        'sandwich price',
      ],
      timeLimitSeconds: 12,
      pronunciationWeight: 0.25,
      grammarWeight: 0.30,
      communicationWeight: 0.45,
      hint: 'Ask: "How much is the sandwich?" or "How much does the sandwich cost?"',
      xpReward: 25,
    ),

    // Challenge 8 – Free speaking: first time here?
    SpeakingChallenge(
      id: 8,
      type: SpeakingChallengeType.freeSpeaking,
      npcDialogue: 'Is this your first time at our café?',
      missionInstruction: 'Answer naturally. There\'s no single right answer.',
      referenceResponse: 'Yes, it\'s my first time here. It looks great!',
      acceptedKeywords: ['yes', 'no', 'first', 'time', 'come', 'visit', 'often'],
      altAcceptedPhrases: [
        'yes it is',
        'yes this is my first',
        'no i come here',
        'no i visit often',
        'first time',
      ],
      timeLimitSeconds: 15,
      pronunciationWeight: 0.25,
      grammarWeight: 0.20,
      communicationWeight: 0.55,
      hint: 'Say "Yes, it is." or "No, I come here often." — anything natural works!',
      xpReward: 25,
      allowFreeResponse: true,
    ),

    // Challenge 9 – Quick response under pressure
    SpeakingChallenge(
      id: 9,
      type: SpeakingChallengeType.freeSpeaking,
      npcDialogue: 'You look busy! Are you in a hurry today?',
      missionInstruction: 'Quick! You have a meeting. Respond naturally.',
      referenceResponse: 'Yes, I have a meeting at 10.',
      acceptedKeywords: ['yes', 'meeting', 'hurry', 'late', 'busy', 'appointment', 'rush'],
      altAcceptedPhrases: [
        'yes i have a meeting',
        'yes a bit late',
        'yes i am in a hurry',
        'yes i have an appointment',
      ],
      timeLimitSeconds: 8,
      pronunciationWeight: 0.20,
      grammarWeight: 0.20,
      communicationWeight: 0.60,
      hint: 'Try: "Yes, I have a meeting at 10." or "Yes, I\'m a little late."',
      xpReward: 25,
    ),

    // Challenge 10 – Final multi-turn conversation
    SpeakingChallenge(
      id: 10,
      type: SpeakingChallengeType.multiTurn,
      npcDialogue: 'Thank you so much! Have a great meeting!',
      missionInstruction:
          'Complete the final conversation turn. Close the interaction politely.',
      referenceResponse: 'Thank you! Have a good day.',
      acceptedKeywords: ['thank', 'thanks', 'great', 'good', 'bye', 'day', 'see'],
      altAcceptedPhrases: [
        'thank you',
        'thanks a lot',
        'have a good day',
        'goodbye',
        'see you',
        'take care',
      ],
      timeLimitSeconds: 10,
      pronunciationWeight: 0.25,
      grammarWeight: 0.25,
      communicationWeight: 0.50,
      hint: 'Say "Thank you! Have a good day." or "Thanks! Bye!"',
      xpReward: 40,
    ),
  ],
);
