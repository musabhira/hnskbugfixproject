import 'package:flutter/material.dart';
import 'adventure_models.dart';

/// 🏷️ Interactive Memory Object in the Room
class MemoryObjectData {
  final String id;
  final String word;
  final String label;
  final Offset position; // Coordinate in the 2D room
  final String zone; // Descriptive location e.g. "on the desk"
  final IconData icon;
  final Color color;
  final String category;
  final String audioPrompt;

  const MemoryObjectData({
    required this.id,
    required this.word,
    required this.label,
    required this.position,
    required this.zone,
    required this.icon,
    required this.color,
    required this.category,
    required this.audioPrompt,
  });
}

/// 📐 Room Area/Zone
class RoomAreaZone {
  final String id;
  final String name;
  final Rect bounds;
  final Color color;

  const RoomAreaZone({
    required this.id,
    required this.name,
    required this.bounds,
    required this.color,
  });
}

/// 🎯 LEVEL 3 VOCABULARY: 15 Practical Real-World Terms
const List<String> kMemoryTargetVocabulary = [
  'appointment',
  'calendar',
  'document',
  'wallet',
  'headphones',
  'notebook',
  'schedule',
  'meeting',
  'keys',
  'laptop',
  'charger',
  'receipt',
  'folder',
  'message',
  'package',
];

/// 🛋️ 12 Interactive Objects in the Workspace Room (World size: 1000 x 540)
const List<MemoryObjectData> kRoomMemoryObjects = [
  MemoryObjectData(
    id: 'laptop',
    word: 'Laptop',
    label: 'LAPTOP',
    position: Offset(360, 220),
    zone: 'on the desk',
    icon: Icons.laptop_mac_rounded,
    color: Color(0xFF38BDF8),
    category: 'electronics',
    audioPrompt: 'Laptop: A portable computer for workplace tasks.',
  ),
  MemoryObjectData(
    id: 'notebook',
    word: 'Notebook',
    label: 'NOTEBOOK',
    position: Offset(300, 230),
    zone: 'on the desk',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFF59E0B),
    category: 'stationery',
    audioPrompt: 'Notebook: Used for writing meeting notes and appointments.',
  ),
  MemoryObjectData(
    id: 'keys',
    word: 'Keys',
    label: 'KEYS',
    position: Offset(420, 230),
    zone: 'beside the laptop',
    icon: Icons.vpn_key_rounded,
    color: Color(0xFFEAB308),
    category: 'personal',
    audioPrompt: 'Keys: Brass office keys beside the laptop.',
  ),
  MemoryObjectData(
    id: 'headphones',
    word: 'Headphones',
    label: 'HEADPHONES',
    position: Offset(620, 310),
    zone: 'on the sofa',
    icon: Icons.headphones_rounded,
    color: Color(0xFFEC4899),
    category: 'audio',
    audioPrompt: 'Headphones: Wireless headset resting on the sofa cushion.',
  ),
  MemoryObjectData(
    id: 'backpack',
    word: 'Backpack',
    label: 'BACKPACK',
    position: Offset(130, 390),
    zone: 'near the door',
    icon: Icons.backpack_rounded,
    color: Color(0xFF6366F1),
    category: 'travel',
    audioPrompt: 'Backpack: Work bag placed near the room entrance.',
  ),
  MemoryObjectData(
    id: 'bottle',
    word: 'Bottle',
    label: 'BOTTLE',
    position: Offset(840, 220),
    zone: 'in the kitchen corner',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF06B6D4),
    category: 'kitchen',
    audioPrompt: 'Bottle: Reusable water flask on the kitchen counter.',
  ),
  MemoryObjectData(
    id: 'calendar',
    word: 'Calendar',
    label: 'CALENDAR',
    position: Offset(510, 120),
    zone: 'on the wall',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFFEF4444),
    category: 'organization',
    audioPrompt: 'Calendar: Monthly wall schedule marked with deadlines.',
  ),
  MemoryObjectData(
    id: 'phone',
    word: 'Phone',
    label: 'PHONE',
    position: Offset(680, 310),
    zone: 'on the sofa',
    icon: Icons.smartphone_rounded,
    color: Color(0xFF10B981),
    category: 'electronics',
    audioPrompt: 'Phone: Mobile smartphone on the right armrest.',
  ),
  MemoryObjectData(
    id: 'wallet',
    word: 'Wallet',
    label: 'WALLET',
    position: Offset(340, 260),
    zone: 'on the desk',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF8B5CF6),
    category: 'personal',
    audioPrompt: 'Wallet: Leather card wallet left on the lower desk ledge.',
  ),
  MemoryObjectData(
    id: 'camera',
    word: 'Camera',
    label: 'CAMERA',
    position: Offset(710, 160),
    zone: 'on the bookshelf',
    icon: Icons.camera_alt_rounded,
    color: Color(0xFF14B8A6),
    category: 'electronics',
    audioPrompt: 'Camera: Compact digital camera on the second shelf.',
  ),
  MemoryObjectData(
    id: 'folder',
    word: 'Folder',
    label: 'FOLDER',
    position: Offset(770, 160),
    zone: 'on the bookshelf',
    icon: Icons.folder_rounded,
    color: Color(0xFFF97316),
    category: 'organization',
    audioPrompt: 'Folder: Document dossier stored in the bookcase.',
  ),
  MemoryObjectData(
    id: 'charger',
    word: 'Charger',
    label: 'CHARGER',
    position: Offset(410, 360),
    zone: 'under the desk',
    icon: Icons.power_rounded,
    color: Color(0xFF64748B),
    category: 'electronics',
    audioPrompt: 'Charger: Power adapter plugged in beneath the desk.',
  ),
];

/// 🏢 Room Architectural Zones
const List<RoomAreaZone> kRoomZones = [
  RoomAreaZone(
    id: 'entrance',
    name: 'Entrance Vestibule',
    bounds: Rect.fromLTWH(80, 280, 140, 180),
    color: Color(0xFF1E293B),
  ),
  RoomAreaZone(
    id: 'workstation',
    name: 'Main Workstation Desk',
    bounds: Rect.fromLTWH(260, 170, 220, 150),
    color: Color(0xFF334155),
  ),
  RoomAreaZone(
    id: 'sofa_lounge',
    name: 'Reception Sofa Lounge',
    bounds: Rect.fromLTWH(580, 260, 170, 140),
    color: Color(0xFF1E293B),
  ),
  RoomAreaZone(
    id: 'bookshelf_unit',
    name: 'Archive Bookshelf',
    bounds: Rect.fromLTWH(680, 120, 140, 90),
    color: Color(0xFF334155),
  ),
  RoomAreaZone(
    id: 'kitchen_counter',
    name: 'Coffee & Kitchen Corner',
    bounds: Rect.fromLTWH(810, 170, 130, 120),
    color: Color(0xFF1E293B),
  ),
];

/// 👤 Level 3 Host NPC: Inspector Miller / Detective Vance
const kLevel3Npc = AdventureNpc(
  id: 'mentor_vance',
  name: 'Specialist Vance',
  role: 'Observation Supervisor',
  avatarEmoji: '🕵️‍♂️',
  worldX: 200,
  worldY: 260,
  greeting: 'You have 60 seconds to inspect this room. Observe every object, label, and location.',
);

/// 🧩 10 Sequential Memory Challenges
const List<AdventureChallenge> kMission03Challenges = [
  // Challenge 1: Object Match
  AdventureChallenge(
    id: 1,
    type: AdventureChallengeType.information,
    title: 'Challenge 1: Object Match',
    npcId: 'mentor_vance',
    npcDialogue: 'First verification: What primary computer equipment was on the main desk?',
    question: 'What was placed on the desk?',
    options: [
      AdventureOption(
        text: 'Laptop',
        isCorrect: true,
        feedback: 'Correct! The laptop was centered on the main workstation desk.',
        reaction: 'Sharp visual memory! Keep focused.',
      ),
      AdventureOption(
        text: 'Umbrella',
        isCorrect: false,
        feedback: 'There was no umbrella in the room.',
        reaction: 'Incorrect. Look back in your mental photograph.',
      ),
      AdventureOption(
        text: 'Helmet',
        isCorrect: false,
        feedback: 'A helmet was never placed in this office.',
        reaction: 'Not in this workspace.',
      ),
      AdventureOption(
        text: 'Bicycle',
        isCorrect: false,
        feedback: 'Bicycles are not kept inside this workstation.',
        reaction: 'Incorrect item.',
      ),
    ],
    targetVocabulary: 'laptop',
    vocabularyMeaning: 'A portable computer suitable for mobile workspace tasks.',
    xpReward: 20,
  ),

  // Challenge 2: Word Memory
  AdventureChallenge(
    id: 2,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 2: Word Recognition Memory',
    npcId: 'mentor_vance',
    npcDialogue: 'Which of the following equipment words did you actually observe in the room?',
    question: 'Select the English word from the room:',
    options: [
      AdventureOption(
        text: 'Laptop',
        isCorrect: true,
        feedback: 'Excellent! "Laptop" was labeled right on the workstation.',
        reaction: 'Word recognition confirmed.',
      ),
      AdventureOption(
        text: 'Printer',
        isCorrect: false,
        feedback: 'There was no printer in the workspace.',
      ),
      AdventureOption(
        text: 'Keyboard',
        isCorrect: false,
        feedback: 'A standalone keyboard was not present.',
      ),
      AdventureOption(
        text: 'Monitor',
        isCorrect: false,
        feedback: 'A desktop monitor was not in the room.',
      ),
    ],
    targetVocabulary: 'document',
    vocabularyMeaning: 'A piece of written, printed, or electronic matter that provides information.',
    xpReward: 20,
  ),

  // Challenge 3: Spelling Memory (HEADPHONES)
  AdventureChallenge(
    id: 3,
    type: AdventureChallengeType.sentenceBuilder,
    title: 'Challenge 3: Spelling Memory – Audio Gear',
    npcId: 'mentor_vance',
    npcDialogue: 'Remember the audio device on the sofa: 🎧 Spell its full name correctly.',
    question: 'Arrange the letter tiles to spell the object name:',
    options: [
      AdventureOption(
        text: 'H E A D P H O N E S',
        isCorrect: true,
        feedback: 'Flawless spelling! H-E-A-D-P-H-O-N-E-S.',
        reaction: 'Perfect spelling recall!',
      ),
      AdventureOption(
        text: 'H E D P H O N E S',
        isCorrect: false,
        feedback: 'Missing the "A" in "HEAD".',
      ),
      AdventureOption(
        text: 'H E A D F O N E S',
        isCorrect: false,
        feedback: 'Spelled with "PH", not "F".',
      ),
    ],
    sentenceTiles: [
      'H',
      'E',
      'A',
      'D',
      'P',
      'H',
      'O',
      'N',
      'E',
      'S',
    ],
    targetSentence: 'H E A D P H O N E S',
    targetVocabulary: 'headphones',
    vocabularyMeaning: 'A pair of earphones joined by a band placed over the head.',
    xpReward: 30,
  ),

  // Challenge 4: Position Memory (Preposition Check)
  AdventureChallenge(
    id: 4,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 4: Spatial Position Memory',
    npcId: 'mentor_vance',
    npcDialogue: 'Where was the lined notebook located?',
    question: 'Select the exact spatial preposition phrase:',
    options: [
      AdventureOption(
        text: 'On the desk',
        isCorrect: true,
        feedback: 'Correct! The notebook was placed on the desk to the left of the laptop.',
        reaction: 'Precise spatial recall!',
      ),
      AdventureOption(
        text: 'Near the door',
        isCorrect: false,
        feedback: 'Near the door was the backpack, not the notebook.',
      ),
      AdventureOption(
        text: 'On the sofa',
        isCorrect: false,
        feedback: 'On the sofa were the headphones and phone.',
      ),
      AdventureOption(
        text: 'Beside the kitchen',
        isCorrect: false,
        feedback: 'Beside the kitchen was the water bottle.',
      ),
    ],
    targetVocabulary: 'notebook',
    vocabularyMeaning: 'A book with blank or ruled pages for notes and reminders.',
    xpReward: 25,
  ),

  // Challenge 5: Sentence Memory
  AdventureChallenge(
    id: 5,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 5: Sentence Memory',
    npcId: 'mentor_vance',
    npcDialogue: 'Recall the room note: "The keys are beside the laptop."',
    question: 'Where were the keys located?',
    options: [
      AdventureOption(
        text: 'Beside the laptop',
        isCorrect: true,
        feedback: 'Accurate! "Beside the laptop" was the exact sentence.',
        reaction: 'Memory confirmed!',
      ),
      AdventureOption(
        text: 'Under the chair',
        isCorrect: false,
        feedback: 'Incorrect position.',
      ),
      AdventureOption(
        text: 'Near the door',
        isCorrect: false,
        feedback: 'The keys were on the desk.',
      ),
      AdventureOption(
        text: 'Inside the drawer',
        isCorrect: false,
        feedback: 'The keys were in plain sight on the desk.',
      ),
    ],
    targetVocabulary: 'keys',
    vocabularyMeaning: 'Small metal instruments used to open locks.',
    xpReward: 25,
  ),

  // Challenge 6: Listening Memory
  AdventureChallenge(
    id: 6,
    type: AdventureChallengeType.listening,
    title: 'Challenge 6: Spoken Audio Memory',
    npcId: 'mentor_vance',
    npcDialogue: 'Recall the spoken observation: "The blue notebook is on the table."',
    audioPrompt: 'The blue notebook is on the table.',
    question: 'What item was specified in the spoken audio?',
    options: [
      AdventureOption(
        text: 'Blue notebook',
        isCorrect: true,
        feedback: 'Great audio memory! You remembered both the object and its color modifier.',
        reaction: 'Sharp listening retention!',
      ),
      AdventureOption(
        text: 'Black phone',
        isCorrect: false,
        feedback: 'Incorrect audio memory.',
      ),
      AdventureOption(
        text: 'Red wallet',
        isCorrect: false,
        feedback: 'The wallet was leather, not mentioned in the audio.',
      ),
      AdventureOption(
        text: 'White bottle',
        isCorrect: false,
        feedback: 'Incorrect.',
      ),
    ],
    targetVocabulary: 'schedule',
    vocabularyMeaning: 'A plan for carrying out a process or procedure with intended times.',
    xpReward: 30,
  ),

  // Challenge 7: Word Intruder (Spot the fake item)
  AdventureChallenge(
    id: 7,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 7: Word Intruder',
    npcId: 'mentor_vance',
    npcDialogue: 'Five words are shown: Laptop, Notebook, Wallet, Camera, Banana.',
    question: 'Which word was NOT in the workspace room?',
    options: [
      AdventureOption(
        text: 'Banana',
        isCorrect: true,
        feedback: 'Spot on! "Banana" is an intruder that was never present in the room.',
        reaction: 'Intruder successfully identified!',
      ),
      AdventureOption(
        text: 'Laptop',
        isCorrect: false,
        feedback: 'The laptop was on the desk.',
      ),
      AdventureOption(
        text: 'Wallet',
        isCorrect: false,
        feedback: 'The wallet was on the desk.',
      ),
      AdventureOption(
        text: 'Camera',
        isCorrect: false,
        feedback: 'The camera was on the bookshelf.',
      ),
    ],
    targetVocabulary: 'wallet',
    vocabularyMeaning: 'A pocket-sized flat folding case for holding money and plastic cards.',
    xpReward: 25,
  ),

  // Challenge 8: Fast Memory (5-Second Flash)
  AdventureChallenge(
    id: 8,
    type: AdventureChallengeType.quickResponse,
    title: 'Challenge 8: Fast Memory – Time Concepts',
    npcId: 'mentor_vance',
    npcDialogue: 'From the room items: appointment, calendar, wallet, notebook, keys, document.',
    question: 'Which word was directly related to time and dates?',
    options: [
      AdventureOption(
        text: 'CALENDAR',
        isCorrect: true,
        feedback: 'Rapid recall! The calendar displays days, dates, and appointments.',
        reaction: 'Quick thinking verified under 8 seconds!',
      ),
      AdventureOption(
        text: 'WALLET',
        isCorrect: false,
        feedback: 'A wallet is related to money, not dates.',
      ),
      AdventureOption(
        text: 'KEYS',
        isCorrect: false,
        feedback: 'Keys are related to access and locks.',
      ),
      AdventureOption(
        text: 'DOCUMENT',
        isCorrect: false,
        feedback: 'Documents contain text, but calendar specifically tracks time.',
      ),
    ],
    timeLimitSeconds: 8,
    targetVocabulary: 'calendar',
    vocabularyMeaning: 'A chart or series of pages showing the days, weeks, and months of a year.',
    xpReward: 35,
  ),

  // Challenge 9: Sentence Rebuild
  AdventureChallenge(
    id: 9,
    type: AdventureChallengeType.sentenceBuilder,
    title: 'Challenge 9: Sentence Reconstruction',
    npcId: 'mentor_vance',
    npcDialogue: 'Reconstruct the statement: "I left my wallet on the desk."',
    question: 'Tap the words into the correct grammatical sequence:',
    options: [
      AdventureOption(
        text: 'I left my wallet on the desk.',
        isCorrect: true,
        feedback: 'Superb! Subject + Verb (past) + Object + Prepositional Phrase.',
        reaction: 'Complete grammatical structure restored!',
      ),
      AdventureOption(
        text: 'My wallet left on I the desk.',
        isCorrect: false,
        feedback: 'Incorrect word order.',
      ),
      AdventureOption(
        text: 'The desk left on my wallet I.',
        isCorrect: false,
        feedback: 'Scrambled syntax.',
      ),
    ],
    sentenceTiles: [
      'I',
      'left',
      'my',
      'wallet',
      'on',
      'the',
      'desk.',
    ],
    targetSentence: 'I left my wallet on the desk.',
    targetVocabulary: 'appointment',
    vocabularyMeaning: 'An arrangement to meet someone at a particular time and place.',
    xpReward: 35,
  ),

  // Challenge 10: Final Challenge – Master Memory Certification
  AdventureChallenge(
    id: 10,
    type: AdventureChallengeType.finalInterview,
    title: 'Final Challenge: Master Memory Certification',
    npcId: 'mentor_vance',
    npcDialogue: 'Synthesize your entire room inspection to prove master observation accuracy.',
    question: 'Which comprehensive summary precisely matches the room layout?',
    options: [
      AdventureOption(
        text: 'Headphones on sofa, calendar on wall, laptop and wallet on desk.',
        isCorrect: true,
        feedback:
            '🎉 Mission 03 Complete! You achieved Master Memory Certification with outstanding observation skills!',
        reaction: 'Outstanding performance! Level 4 Unlocked!',
      ),
      AdventureOption(
        text: 'All items were locked away in metal cabinets.',
        isCorrect: false,
        feedback: 'Incorrect. The objects were visible throughout the workstation zones.',
      ),
      AdventureOption(
        text: 'Only a single bicycle was present in the room.',
        isCorrect: false,
        feedback: 'Incorrect.',
      ),
      AdventureOption(
        text: 'The room was completely empty.',
        isCorrect: false,
        feedback: 'Incorrect.',
      ),
    ],
    targetVocabulary: 'meeting',
    vocabularyMeaning: 'An assembly of people for a discussion or commercial transaction.',
    xpReward: 50,
  ),
];

/// 🗺️ Level 3 Data Container
const AdventureLevelData kMission03MemoryData = AdventureLevelData(
  levelNumber: 3,
  title: 'Mission 03 – Memory Break-In',
  subtitle: 'Modern Workspace Memory Puzzle',
  environmentName: 'Apex Creative Loft & Workstation',
  storyIntro:
      'You have 60 seconds to inspect the modern workspace. Walk through the room, memorize every labeled object, location, and spoken hint. Once the timer ends, the labels vanish and your memory will be put to the test!',
  objective:
      'Memorize 12 workplace objects, master spelling and prepositions, and score over 70% to claim your Memory Certification.',
  targetVocabularyList: kMemoryTargetVocabulary,
  npcs: [kLevel3Npc],
  challenges: kMission03Challenges,
);
