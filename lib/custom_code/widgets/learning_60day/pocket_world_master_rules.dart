/// 🌍 POCKET WORLD MASTER GAME RULES & CONCEPTS
/// 
/// This file documents the definitive rules of Pocket World in code for quick developer & user reference.
/// See also: POCKET_WORLD_GAME_RULES.md for the full markdown manual.
class PocketWorldMasterRules {
  static const String gameTitle = 'Pocket World: 90-Day English Learning Game';
  static const String gamePhilosophy = 'Game with Education (EdTech Gaming)';
  static const int totalTargetDays = 90;

  /// Core Game Rules Summary
  static const Map<String, String> rulesSummary = {
    '1. English Homes':
        'Every player owns a virtual house in Pocket World where English is the universal currency and language.',
    '2. 1 Day = 1 Defense Slot':
        'Defense scales linearly from 1 slot on Day 1 to 90 slots across 9 gates on Day 90 (exactly 10 questions per gate).',
    '3. Direct Attacks':
        'No ringing doorbell required. Direct raid warfare in the Battle Arena against rival houses (+1 to +3 levels higher for combat growth).',
    '4. Pocket Robo Fallback 🤖':
        'If no active peer exists in the player\'s level bracket, Pocket Robo steps in automatically so attacks and rewards are always available.',
    '5. 48-Hour Presidential Police Protection':
        'When a house is breached, it immediately receives 48 hours of immunity with stationed police guards so the homeowner can recover and rebuild.',
    '6. President Call & Anti-Cheat Decrees':
        'Offensive or invalid user questions can be reported via President Call, leading to inspection, warning, suspension, or house condemnation.',
    '7. Activity-Powered Reinforcements (FDC)':
        'Voice calls, chats, and daily learning earn FDC to purchase Iron Dome shields (absorbing 100% breach damage).',
    '8. Daily Attack Limit':
        'Players can launch a maximum of 2 attacks per day to encourage deliberate, high-retention learning.',
  };

  /// 9 Defense Challenge Gates
  static const List<Map<String, dynamic>> defenseGates = [
    {'gate': 1, 'days': '1-10', 'id': 'vocab_gate', 'name': 'Vocabulary Gate (Synonyms & Antonyms)'},
    {'gate': 2, 'days': '11-20', 'id': 'grammar_sentry', 'name': 'Grammar Sentry (Agreement & Pronouns)'},
    {'gate': 3, 'days': '21-30', 'id': 'tense_fortress', 'name': 'Tense Fortress (Conditionals & Modals)'},
    {'gate': 4, 'days': '31-40', 'id': 'syntax_wall', 'name': 'Syntax Wall (Inversions & Cleft Sentences)'},
    {'gate': 5, 'days': '41-50', 'id': 'idiom_maze', 'name': 'Idiom Maze (Native Metaphors & Idioms)'},
    {'gate': 6, 'days': '51-60', 'id': 'rhetoric_bastion', 'name': 'Rhetoric Bastion (Chiasmus & Antithesis)'},
    {'gate': 7, 'days': '61-70', 'id': 'fallacy_redoubt', 'name': 'Fallacy Redoubt (Counter-Arguments & Debates)'},
    {'gate': 8, 'days': '71-80', 'id': 'executive_sanctum', 'name': 'Executive Sanctum (STAR Interviews & Negotiations)'},
    {'gate': 9, 'days': '81-90', 'id': 'sovereign_citadel', 'name': 'Sovereign Citadel (Universal Statecraft Accords)'},
  ];
}
