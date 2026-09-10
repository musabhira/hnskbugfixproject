import 'package:flutter/material.dart';
import 'adventure_models.dart';

/// 🏙️ City Landmark Model
class CityLandmark {
  final String id;
  final String name;
  final String category;
  final Offset position; // World coordinate
  final Size size;
  final String signLabel;
  final IconData icon;
  final Color primaryColor;
  final String description;

  const CityLandmark({
    required this.id,
    required this.name,
    required this.category,
    required this.position,
    required this.size,
    required this.signLabel,
    required this.icon,
    required this.primaryColor,
    required this.description,
  });
}

/// 🚏 City Street Sign Model
class CitySign {
  final String id;
  final String text;
  final Offset position;
  final String targetLandmarkId;

  const CitySign({
    required this.id,
    required this.text,
    required this.position,
    required this.targetLandmarkId,
  });
}

/// 🧭 Route Builder Step Tile
class RouteTileStep {
  final String id;
  final String label;
  final IconData icon;

  const RouteTileStep({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// 🎯 LEVEL 2 CURRICULUM: Mission 02 – City Navigator
/// 20 target vocabulary words
const List<String> kCityTargetVocabulary = [
  'left',
  'right',
  'straight',
  'corner',
  'opposite',
  'beside',
  'between',
  'near',
  'behind',
  'across',
  'entrance',
  'exit',
  'station',
  'pharmacy',
  'supermarket',
  'bank',
  'restaurant',
  'library',
  'office',
  'bus stop',
];

/// 👤 City NPCs
const kCityNpcOfficerHarris = AdventureNpc(
  id: 'officer_harris',
  name: 'Officer Harris',
  role: 'Traffic & City Guide Officer',
  avatarEmoji: '👮‍♂️',
  worldX: 380,
  worldY: 300,
  greeting: 'Good morning! Stay on the crosswalks and follow the city road signs.',
);

const kCityNpcElena = AdventureNpc(
  id: 'transit_elena',
  name: 'Elena Torres',
  role: 'Transit Coordinator',
  avatarEmoji: '👩‍💼',
  worldX: 740,
  worldY: 210,
  greeting: 'Hello traveler! The metro and bus routes connect all major city hubs.',
);

const kCityNpcMarcus = AdventureNpc(
  id: 'security_marcus',
  name: 'Marcus Vance',
  role: 'Chief Security Officer',
  avatarEmoji: '💂‍♂️',
  worldX: 1140,
  worldY: 280,
  greeting: 'City Business Center security desk. State your destination, please.',
);

/// 🏛️ City Landmarks Dataset (Coherent explorable 2D world: 1600 x 600)
const List<CityLandmark> kCityLandmarks = [
  CityLandmark(
    id: 'start_plaza',
    name: 'City Square Plaza',
    category: 'Square',
    position: Offset(100, 360),
    size: Size(130, 90),
    signLabel: 'PLAZA',
    icon: Icons.park_rounded,
    primaryColor: Color(0xFF10B981),
    description: 'Central gathering square with fountain and directory.',
  ),
  CityLandmark(
    id: 'bus_stop',
    name: 'Metro Bus Stop',
    category: 'Transit',
    position: Offset(320, 160),
    size: Size(110, 80),
    signLabel: 'BUS STOP',
    icon: Icons.directions_bus_rounded,
    primaryColor: Color(0xFF0284C7),
    description: 'Rapid transit bus stop connecting to Grand Avenue.',
  ),
  CityLandmark(
    id: 'supermarket',
    name: 'Metro Supermarket',
    category: 'Shopping',
    position: Offset(480, 140),
    size: Size(140, 100),
    signLabel: 'SUPERMARKET',
    icon: Icons.shopping_cart_rounded,
    primaryColor: Color(0xFF16A34A),
    description: 'Fresh groceries, bakery, and pharmacy convenience mart.',
  ),
  CityLandmark(
    id: 'bank',
    name: 'City Central Bank',
    category: 'Finance',
    position: Offset(520, 370),
    size: Size(130, 95),
    signLabel: 'BANK',
    icon: Icons.account_balance_rounded,
    primaryColor: Color(0xFFD97706),
    description: 'Financial headquarters with ATM foyer and stone pillars.',
  ),
  CityLandmark(
    id: 'restaurant',
    name: 'Bistro Gourmet',
    category: 'Dining',
    position: Offset(670, 370),
    size: Size(120, 95),
    signLabel: 'RESTAURANT',
    icon: Icons.restaurant_rounded,
    primaryColor: Color(0xFFE11D48),
    description: 'Modern Italian bistro with outdoor patio seating.',
  ),
  CityLandmark(
    id: 'pharmacy',
    name: 'City Care Pharmacy',
    category: 'Healthcare',
    position: Offset(370, 370),
    size: Size(120, 95),
    signLabel: 'PHARMACY',
    icon: Icons.local_pharmacy_rounded,
    primaryColor: Color(0xFF059669),
    description: '24/7 medical store located right beside the Central Bank.',
  ),
  CityLandmark(
    id: 'library',
    name: 'Metropolitan Library',
    category: 'Education',
    position: Offset(840, 140),
    size: Size(150, 110),
    signLabel: 'LIBRARY',
    icon: Icons.local_library_rounded,
    primaryColor: Color(0xFF7C3AED),
    description: 'Grand public library with knowledge archives and quiet study zones.',
  ),
  CityLandmark(
    id: 'metro_station',
    name: 'Grand Central Station',
    category: 'Transit',
    position: Offset(1020, 140),
    size: Size(140, 105),
    signLabel: 'STATION',
    icon: Icons.train_rounded,
    primaryColor: Color(0xFF2563EB),
    description: 'Underground rail terminal with direct express lines.',
  ),
  CityLandmark(
    id: 'business_center',
    name: 'City Business Center',
    category: 'Workplace',
    position: Offset(1200, 350),
    size: Size(170, 120),
    signLabel: 'BUSINESS CENTER',
    icon: Icons.apartment_rounded,
    primaryColor: Color(0xFF0284C7),
    description: 'Glass-facade corporate headquarters where your 11:00 AM meeting is held.',
  ),
];

/// 🪧 City Road Signs
const List<CitySign> kCitySigns = [
  CitySign(
    id: 'sign_bank',
    text: 'BANK',
    position: Offset(530, 330),
    targetLandmarkId: 'bank',
  ),
  CitySign(
    id: 'sign_library',
    text: 'LIBRARY',
    position: Offset(850, 260),
    targetLandmarkId: 'library',
  ),
  CitySign(
    id: 'sign_pharmacy',
    text: 'PHARMACY',
    position: Offset(380, 330),
    targetLandmarkId: 'pharmacy',
  ),
  CitySign(
    id: 'sign_station',
    text: 'STATION',
    position: Offset(1030, 260),
    targetLandmarkId: 'metro_station',
  ),
];

/// 🧩 10 Sequential Challenges for Mission 02 – City Navigator
const List<AdventureChallenge> kMission02Challenges = [
  // Challenge 1: Follow Directions (Walking along the road)
  AdventureChallenge(
    id: 1,
    type: AdventureChallengeType.directionHelp,
    title: 'Challenge 1: Follow Written Directions',
    npcId: 'officer_harris',
    npcDialogue: 'Go straight and turn right at the next corner.',
    question: 'How should you navigate according to Officer Harris’s command?',
    options: [
      AdventureOption(
        text: 'Proceed straight, then make a right turn at the corner.',
        isCorrect: true,
        feedback:
            'Spot on! "Go straight" means maintain your current heading, and "turn right at the corner" guides you at the road intersection.',
        reaction: 'Safe travels! Watch for the pedestrian crossing.',
      ),
      AdventureOption(
        text: 'Turn left immediately and walk backwards.',
        isCorrect: false,
        feedback: 'Incorrect. The instruction states "turn right", not left or backwards.',
        reaction: 'Hold on! You are heading in the wrong direction.',
      ),
      AdventureOption(
        text: 'Stop and remain stationary in the middle of the street.',
        isCorrect: false,
        feedback: 'Incorrect. "Go straight" instructs continuous forward movement.',
        reaction: 'Please do not block traffic! Keep moving forward.',
      ),
    ],
    targetVocabulary: 'corner',
    vocabularyMeaning: 'The point or angle where two roads or streets meet.',
    xpReward: 20,
  ),

  // Challenge 2: Direction Choice (Map Location)
  AdventureChallenge(
    id: 2,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 2: Direction Choice',
    npcId: 'officer_harris',
    npcDialogue: 'Excuse me! Do you know where the pharmacy is located?',
    question: 'Select the correct, grammatically sound English response:',
    options: [
      AdventureOption(
        text: 'It is next to the bank.',
        isCorrect: true,
        feedback:
            'Perfect! "Next to" (or "beside") accurately describes two adjacent physical buildings.',
        reaction: 'Thank you very much! I see the green cross sign now.',
      ),
      AdventureOption(
        text: 'It is yesterday.',
        isCorrect: false,
        feedback: '"Yesterday" refers to time in the past, not a physical spatial location.',
        reaction: 'Pardon me? I asked where it is, not when.',
      ),
      AdventureOption(
        text: 'It is very quickly.',
        isCorrect: false,
        feedback: '"Quickly" is an adverb of speed, not a preposition of place.',
        reaction: 'That doesn’t help me find the location.',
      ),
    ],
    targetVocabulary: 'pharmacy',
    vocabularyMeaning: 'A store where medicines and healthcare items are prepared and sold.',
    xpReward: 20,
  ),

  // Challenge 3: Listening Navigation (Audio Clue)
  AdventureChallenge(
    id: 3,
    type: AdventureChallengeType.listening,
    title: 'Challenge 3: Listening Navigation',
    npcId: 'transit_elena',
    npcDialogue: 'Listen carefully to the audio directions from transit control.',
    audioPrompt: 'Walk past the restaurant and turn left after the bus stop.',
    question: 'What should you do after the bus stop?',
    options: [
      AdventureOption(
        text: 'Turn left',
        isCorrect: true,
        feedback:
            'Excellent listening! Elena clearly instructed: "turn left after the bus stop".',
        reaction: 'Great ear! You understood the spoken imperative.',
      ),
      AdventureOption(
        text: 'Turn right',
        isCorrect: false,
        feedback: 'Listen again. The prompt said "turn left", not right.',
        reaction: 'Check your audio direction again.',
      ),
      AdventureOption(
        text: 'Go back',
        isCorrect: false,
        feedback: 'Incorrect. The prompt instructed forward progress past the restaurant.',
        reaction: 'Going back would take you away from your destination.',
      ),
      AdventureOption(
        text: 'Stop and wait',
        isCorrect: false,
        feedback: 'Incorrect. You need to execute an active direction turn.',
        reaction: 'Do not stop yet! Turn left.',
      ),
    ],
    targetVocabulary: 'bus stop',
    vocabularyMeaning: 'A designated spot on the roadside where buses stop for passengers.',
    xpReward: 25,
  ),

  // Challenge 4: Sign Hunt (Locate the Library)
  AdventureChallenge(
    id: 4,
    type: AdventureChallengeType.information,
    title: 'Challenge 4: Sign Hunt – Find the Library',
    npcId: 'transit_elena',
    npcDialogue: 'Mission: Identify and reach the grand LIBRARY sign on North Avenue.',
    question: 'Which landmark sign corresponds to the public knowledge archive?',
    options: [
      AdventureOption(
        text: 'Look for the "LIBRARY" sign near North Avenue.',
        isCorrect: true,
        feedback:
            'Location found! Signs use bold capitalized English nouns to guide pedestrians.',
        reaction: 'You found the Library! 🏛️ Location recorded.',
      ),
      AdventureOption(
        text: 'Enter the "SUPERMARKET" to read books.',
        isCorrect: false,
        feedback: 'A supermarket sells groceries and food, not public book collections.',
        reaction: 'That is a grocery market, not the library.',
      ),
      AdventureOption(
        text: 'Walk towards the "STATION" tracks.',
        isCorrect: false,
        feedback: 'The station is for trains and transit.',
        reaction: 'That sign says STATION, not LIBRARY.',
      ),
    ],
    targetVocabulary: 'library',
    vocabularyMeaning: 'A building containing collections of books and periodicals for reading or borrowing.',
    xpReward: 30,
  ),

  // Challenge 5: Preposition Puzzle (Scene Analysis)
  AdventureChallenge(
    id: 5,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 5: Preposition Puzzle',
    npcId: 'officer_harris',
    npcDialogue: 'Observe the city street layout carefully.',
    question: 'Looking at the buildings, where is the bank located?',
    options: [
      AdventureOption(
        text: 'Beside the restaurant',
        isCorrect: true,
        feedback:
            'Correct! "Beside" means at the side of, or adjacent to another structure.',
        reaction: 'Accurate spatial awareness!',
      ),
      AdventureOption(
        text: 'Under the restaurant',
        isCorrect: false,
        feedback: '"Under" means beneath or at a lower level vertically.',
        reaction: 'The bank is a separate building on ground level.',
      ),
      AdventureOption(
        text: 'Inside the restaurant',
        isCorrect: false,
        feedback: '"Inside" indicates an interior room, but the bank is its own building.',
        reaction: 'No, they are two independent establishments.',
      ),
      AdventureOption(
        text: 'Behind the station',
        isCorrect: false,
        feedback: '"Behind" means at the back of. The bank is across the avenue from the station.',
        reaction: 'Check your map compass directions.',
      ),
    ],
    targetVocabulary: 'beside',
    vocabularyMeaning: 'At the side of; right next to someone or something.',
    xpReward: 25,
  ),

  // Challenge 6: Ask for Directions (Polite Spoken English)
  AdventureChallenge(
    id: 6,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 6: Ask for Directions',
    npcId: 'transit_elena',
    npcDialogue: 'Can I help you with city transit?',
    question: 'How do you ask for directions politely and professionally?',
    options: [
      AdventureOption(
        text: 'Yes. Could you tell me how to get to the station?',
        isCorrect: true,
        feedback:
            'Superb! "Could you tell me how to get to..." is standard, polite, professional English for asking directions.',
        reaction: 'Certainly! Walk straight down Grand Avenue and you will see the station on your right.',
      ),
      AdventureOption(
        text: 'Yes. Tell station where.',
        isCorrect: false,
        feedback: 'Too blunt and grammatically incomplete. Use a polite modal like "Could you please tell me...".',
        reaction: 'Could you rephrase that politely, please?',
      ),
      AdventureOption(
        text: 'I station going.',
        isCorrect: false,
        feedback: 'Broken grammar. The correct phrase is "I am going to the station" or "How do I get to the station?".',
        reaction: 'I am not sure what you mean.',
      ),
    ],
    targetVocabulary: 'station',
    vocabularyMeaning: 'A regular stopping place on a public transport route, especially for trains.',
    xpReward: 25,
  ),

  // Challenge 7: Route Builder Mini-Game
  AdventureChallenge(
    id: 7,
    type: AdventureChallengeType.sentenceBuilder,
    title: 'Challenge 7: Interactive Route Builder',
    npcId: 'officer_harris',
    npcDialogue: 'Construct the route sequence: "Go straight, turn right, then cross the road."',
    question: 'Arrange the navigation action tiles into the exact correct sequence:',
    options: [
      AdventureOption(
        text: 'GO STRAIGHT → TURN RIGHT → CROSS THE ROAD',
        isCorrect: true,
        feedback:
            'Brilliant navigation logic! You chained the three directional imperatives in exact chronological order.',
        reaction: 'Route unlocked! Proceed safely.',
      ),
      AdventureOption(
        text: 'TURN RIGHT → CROSS THE ROAD → GO STRAIGHT',
        isCorrect: false,
        feedback: 'Incorrect order. You must "go straight" first.',
      ),
      AdventureOption(
        text: 'CROSS THE ROAD → GO STRAIGHT → TURN RIGHT',
        isCorrect: false,
        feedback: 'Crossing the road occurs last in the given route.',
      ),
    ],
    sentenceTiles: [
      'GO STRAIGHT',
      'TURN RIGHT',
      'CROSS THE ROAD',
      'TURN LEFT',
    ],
    targetSentence: 'GO STRAIGHT TURN RIGHT CROSS THE ROAD',
    targetVocabulary: 'across',
    vocabularyMeaning: 'From one side to the other of a road, street, or area.',
    xpReward: 35,
  ),

  // Challenge 8: Time Pressure (60-second Countdown Navigation)
  AdventureChallenge(
    id: 8,
    type: AdventureChallengeType.quickResponse,
    title: 'Challenge 8: Timed Navigation – 60s to Meeting',
    npcId: 'security_marcus',
    npcDialogue: 'Your meeting is at 11:00 AM sharp! You have 60 seconds to reach the office entrance.',
    audioPrompt: 'Go straight, turn left at the bank, cross the road, and enter the building.',
    question: 'Follow the rapid navigation sequence:',
    options: [
      AdventureOption(
        text: 'Go straight → Turn left at the bank → Cross the road → Enter the building',
        isCorrect: true,
        feedback:
            'Fantastic speed and precision! You successfully followed all 4 directional steps under time pressure.',
        reaction: 'Access verified! The automatic security doors are opening.',
      ),
      AdventureOption(
        text: 'Turn right at the library → Stop at the cafe → Exit the city center',
        isCorrect: false,
        feedback: 'Incorrect! That route leads away from the Business Center.',
        reaction: 'Time is ticking! Wrong path.',
      ),
      AdventureOption(
        text: 'Walk backwards → Wait at the bus stop → Wander aimlessly',
        isCorrect: false,
        feedback: 'You will miss the 11:00 AM interview if you delay!',
        reaction: 'Hurry, the meeting is starting!',
      ),
    ],
    timeLimitSeconds: 60,
    targetVocabulary: 'entrance',
    vocabularyMeaning: 'An opening, such as a door or gate, that provides access to a building.',
    xpReward: 40,
  ),

  // Challenge 9: Workplace / Office NPC Interaction
  AdventureChallenge(
    id: 9,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 9: Security Check & Floor Directions',
    npcId: 'security_marcus',
    npcDialogue: 'Do you know where the conference meeting room is located?',
    question: 'Select the professional and concise English response:',
    options: [
      AdventureOption(
        text: 'Yes. It is on the second floor.',
        isCorrect: true,
        feedback:
            'Spot on! "On the [ordinal number] floor" is the standard English prepositional phrase for building levels.',
        reaction: 'Correct. Take elevator B on your right. Good luck with your meeting!',
      ),
      AdventureOption(
        text: 'Yes, I am meeting.',
        isCorrect: false,
        feedback: 'Grammatically confused. "Meeting" is an event you attend, not what you are.',
        reaction: 'I asked where the room is, not what you are doing.',
      ),
      AdventureOption(
        text: 'Second floor meeting?',
        isCorrect: false,
        feedback: 'Too informal for corporate check-in. Use a full affirmative sentence: "Yes, it is on the second floor."',
        reaction: 'Please confirm clearly for our guest visitor log.',
      ),
    ],
    targetVocabulary: 'office',
    vocabularyMeaning: 'A room, set of rooms, or building used as a place for commercial or professional work.',
    xpReward: 30,
  ),

  // Challenge 10: Final Challenge – City Escape & Master Navigation
  AdventureChallenge(
    id: 10,
    type: AdventureChallengeType.finalInterview,
    title: 'Final Challenge: Master City Navigator',
    npcId: 'security_marcus',
    npcDialogue: 'Listen to the 4-stage master navigation briefing to verify your city certification.',
    audioPrompt:
        'Go straight to the square. Turn left at the bank. Walk past the library. The office is opposite the restaurant.',
    question: 'Based on the multi-step spoken directions, where is the office located?',
    options: [
      AdventureOption(
        text: 'Opposite the restaurant',
        isCorrect: true,
        feedback:
            'Mission Accomplished! You have mastered city directions, street signs, listening comprehension, and spatial prepositions!',
        reaction: '🎉 City Navigator Certification unlocked! You navigated flawlessly!',
      ),
      AdventureOption(
        text: 'Inside the underground subway tunnel',
        isCorrect: false,
        feedback: 'The final spoken instruction stated: "The office is opposite the restaurant."',
      ),
      AdventureOption(
        text: 'Behind the pharmacy dumpster',
        isCorrect: false,
        feedback: 'Incorrect location.',
      ),
      AdventureOption(
        text: 'Under the fountain plaza',
        isCorrect: false,
        feedback: 'Incorrect location.',
      ),
    ],
    targetVocabulary: 'opposite',
    vocabularyMeaning: 'Situated directly on the other side of something or someone, usually separated by a space or street.',
    xpReward: 50,
  ),
];

/// 🗺️ Complete Level 2 Data Container
const AdventureLevelData kMission02CityData = AdventureLevelData(
  levelNumber: 2,
  title: 'Mission 02 – City Navigator',
  subtitle: 'Modern Explorable City Hub',
  environmentName: 'Metropolitan District & Grand Avenue',
  storyIntro:
      'Your crucial meeting starts at 11:00 AM at the City Business Center. Receive spoken instructions from city officers, read street signs, navigate bustling roads, and discover your destination!',
  objective:
      'Follow the English clues, read signs, ask and understand directions, and reach the City Business Center before 11:00 AM.',
  targetVocabularyList: kCityTargetVocabulary,
  npcs: [
    kCityNpcOfficerHarris,
    kCityNpcElena,
    kCityNpcMarcus,
  ],
  challenges: kMission02Challenges,
);
