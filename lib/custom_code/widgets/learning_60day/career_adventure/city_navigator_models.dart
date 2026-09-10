import 'package:flutter/material.dart';
import 'adventure_models.dart';

/// 🏙️ City Landmark Model for 2D Metro World
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

/// 💎 Collectible Street Token (Briefcases & Energy Orbs)
class StreetToken {
  final String id;
  final String label;
  final Offset position;
  final String icon;
  final int xp;
  bool isCollected;

  StreetToken({
    required this.id,
    required this.label,
    required this.position,
    required this.icon,
    this.xp = 15,
    this.isCollected = false,
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

/// 🎯 LEVEL 2 CURRICULUM: City Navigator
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
    description: 'Fresh groceries, bakery, and convenience mart.',
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
    id: 'subway_station',
    name: 'Grand Metro Station',
    category: 'Transit',
    position: Offset(800, 150),
    size: Size(150, 100),
    signLabel: 'METRO STATION',
    icon: Icons.subway_rounded,
    primaryColor: Color(0xFF2563EB),
    description: 'Main underground rapid rail interchange and ticket gates.',
  ),
  CityLandmark(
    id: 'library',
    name: 'Public Library',
    category: 'Education',
    position: Offset(960, 360),
    size: Size(140, 100),
    signLabel: 'LIBRARY',
    icon: Icons.menu_book_rounded,
    primaryColor: Color(0xFF7C3AED),
    description: 'Grand civic library with quiet study archives.',
  ),
  CityLandmark(
    id: 'tech_office',
    name: 'City Business Center',
    category: 'Office',
    position: Offset(1180, 150),
    size: Size(160, 120),
    signLabel: 'TECH TOWER',
    icon: Icons.business_rounded,
    primaryColor: Color(0xFF0D9488),
    description: 'Executive corporate tower & dispatch delivery destination.',
  ),
];

/// 🚏 Visual Street Signs
const List<CitySign> kCitySigns = [
  CitySign(
    id: 'sign_bank',
    text: 'BANK ➔',
    position: Offset(440, 290),
    targetLandmarkId: 'bank',
  ),
  CitySign(
    id: 'sign_library',
    text: 'LIBRARY ➔',
    position: Offset(900, 290),
    targetLandmarkId: 'library',
  ),
  CitySign(
    id: 'sign_pharmacy',
    text: 'PHARMACY ➔',
    position: Offset(310, 290),
    targetLandmarkId: 'pharmacy',
  ),
  CitySign(
    id: 'sign_station',
    text: 'METRO ⬆',
    position: Offset(760, 290),
    targetLandmarkId: 'subway_station',
  ),
];

/// 🧩 10 Sequential Challenges for City Navigator
const List<AdventureChallenge> kCityChallenges = [
  // ── Challenge 1: Follow Written Directions ────────────────────────────
  AdventureChallenge(
    id: 1,
    type: AdventureChallengeType.directionHelp,
    title: 'Challenge 1: Decipher GPS Route',
    npcId: 'officer_harris',
    npcDialogue:
        'Officer Harris greets you: "Welcome to the City Center! The GPS note reads: \'Walk straight along Main Street, then turn right at the corner opposite the bus stop.\' Which direction should you take?"',
    question: 'According to the directions, where should you turn right?',
    options: [
      AdventureOption(
        text: 'At the corner opposite the bus stop',
        isCorrect: true,
        feedback:
            'Spot on! "Opposite" means facing directly across the street. Proceeding towards Central Bank.',
        reaction: 'Officer Harris nods: "Great eye! Keep moving forward."',
      ),
      AdventureOption(
        text: 'Inside the subway entrance',
        isCorrect: false,
        feedback:
            'The note says "turn right at the corner opposite the bus stop", not into the subway.',
      ),
      AdventureOption(
        text: 'Behind the supermarket parking lot',
        isCorrect: false,
        feedback:
            '"Behind" means at the back. The note explicitly states "opposite the bus stop".',
      ),
      AdventureOption(
        text: 'Turn left before the fountain',
        isCorrect: false,
        feedback:
            'The instruction is to turn right at the corner, not left before the fountain.',
      ),
    ],
    targetVocabulary: 'opposite',
    vocabularyMeaning: 'facing or on the other side of an area or street (എതിർവശത്ത്)',
    xpReward: 25,
  ),

  // ── Challenge 2: Spatial Landmark Identification ───────────────────────
  AdventureChallenge(
    id: 2,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 2: Locate the Pharmacy',
    npcId: 'officer_harris',
    npcDialogue:
        'Officer Harris points to the road map: "You need to collect courier documents from the Pharmacy. The city guide states: \'The Pharmacy is located between the Central Bank and City Square.\'"',
    question: 'Where is the Pharmacy situated according to the guide?',
    options: [
      AdventureOption(
        text: 'Between the Central Bank and City Square',
        isCorrect: true,
        feedback:
            'Correct! "Between" refers to the middle space separating two distinct places. Documents secured.',
        reaction: 'Officer Harris gives a thumbs-up: "Pharmacy location confirmed!"',
      ),
      AdventureOption(
        text: 'Opposite the high school football ground',
        isCorrect: false,
        feedback:
            'There is no school in this commercial district. The pharmacy is "between the Central Bank and City Square".',
      ),
      AdventureOption(
        text: 'Behind the underground subway terminal',
        isCorrect: false,
        feedback:
            'The pharmacy is on the south street front, not behind the subway.',
      ),
      AdventureOption(
        text: 'Next to the rooftop helipad',
        isCorrect: false,
        feedback:
            'The pharmacy is at ground level between the Bank and the Square.',
      ),
    ],
    targetVocabulary: 'between',
    vocabularyMeaning: 'in the space separating two points, objects, or places (ഇടയിൽ)',
    xpReward: 25,
  ),

  // ── Challenge 3: Listening Navigation ──────────────────────────────────
  AdventureChallenge(
    id: 3,
    type: AdventureChallengeType.listening,
    title: 'Challenge 3: Audio Transit Advisory',
    npcId: 'transit_elena',
    npcDialogue:
        'Elena Torres broadcasts an urgent transit update over the loudspeaker. Listen carefully to the audio clue:',
    audioPrompt:
        'Attention pedestrian! To reach Grand Metro Station, walk straight for two blocks and take the entrance on your left, beside the supermarket.',
    question: 'Where is the Grand Metro Station entrance according to Elena?',
    options: [
      AdventureOption(
        text: 'On your left, beside the supermarket',
        isCorrect: true,
        feedback:
            'Excellent listening! "Beside" means next to or at the side of. Station entrance located.',
        reaction: 'Elena smiles: "Great job! The metro line is operating smoothly."',
      ),
      AdventureOption(
        text: 'On your right, behind the central library',
        isCorrect: false,
        feedback:
            'Elena clearly said "on your left, beside the supermarket".',
      ),
      AdventureOption(
        text: 'Inside the underground parking garage',
        isCorrect: false,
        feedback:
            'The broadcast indicated the entrance is beside the supermarket.',
      ),
      AdventureOption(
        text: 'Across the river on North Boulevard',
        isCorrect: false,
        feedback:
            'Listen again — the station is two blocks ahead on your left.',
      ),
    ],
    targetVocabulary: 'beside',
    vocabularyMeaning: 'at the side of; next to (അടുത്ത് / തൊട്ടടുത്ത്)',
    xpReward: 30,
  ),

  // ── Challenge 4: Sign Hunt — Public Library ────────────────────────────
  AdventureChallenge(
    id: 4,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 4: Spot the Library Sign',
    npcId: 'transit_elena',
    npcDialogue:
        'Elena checks her tablet: "Before proceeding to Tech Tower, drop off the research ledger at the Public Library. Check the overhead city signboards."',
    question: 'Which sign indicates the direction toward the Public Library?',
    options: [
      AdventureOption(
        text: 'LIBRARY ➔ (Walk straight east toward the avenue)',
        isCorrect: true,
        feedback:
            'Correct! The purple landmark sign points directly toward the Public Library entrance.',
        reaction: 'Elena validates the route: "Ledger recorded. Keep going!"',
      ),
      AdventureOption(
        text: 'EXIT ⬇ (Underground maintenance tunnel)',
        isCorrect: false,
        feedback:
            'An "EXIT" sign marks a way out of an enclosed area, not the library direction.',
      ),
      AdventureOption(
        text: 'NO PARKING ⛔ (Tow-away zone)',
        isCorrect: false,
        feedback:
            'This is a parking traffic restriction, not a destination signboard.',
      ),
      AdventureOption(
        text: 'BUS STOP ➔ (Transit boarding bay)',
        isCorrect: false,
        feedback:
            'The bus stop sign points to transit, not the library.',
      ),
    ],
    targetVocabulary: 'library',
    vocabularyMeaning: 'a building containing collections of books and periodicals for reading or study (ലൈബ്രറി / വായനശാല)',
    xpReward: 25,
  ),

  // ── Challenge 5: Spatial Preposition Mastery ───────────────────────────
  AdventureChallenge(
    id: 5,
    type: AdventureChallengeType.vocabularyInContext,
    title: 'Challenge 5: Analyze the Street Layout',
    npcId: 'transit_elena',
    npcDialogue:
        'Elena asks you to verify your position: "Looking across the boulevard, Bistro Gourmet is located directly ___ the Central Bank."',
    question: 'Which preposition accurately describes Bistro Gourmet relative to Central Bank?',
    options: [
      AdventureOption(
        text: 'beside',
        isCorrect: true,
        feedback:
            'Perfect! Both Bistro Gourmet and Central Bank are adjacent along the southern side of the road.',
        reaction: 'Elena nods: "Exact spatial awareness!"',
      ),
      AdventureOption(
        text: 'inside',
        isCorrect: false,
        feedback:
            'Bistro Gourmet is an independent restaurant building, not located inside the bank.',
      ),
      AdventureOption(
        text: 'behind',
        isCorrect: false,
        feedback:
            '"Behind" means at the rear. Bistro Gourmet is right next to the bank along the street frontage.',
      ),
      AdventureOption(
        text: 'under',
        isCorrect: false,
        feedback:
            '"Under" implies beneath the ground. Both venues are street-level establishments.',
      ),
    ],
    targetVocabulary: 'beside',
    vocabularyMeaning: 'by the side of; adjacent to (തൊട്ടടുത്ത്)',
    xpReward: 25,
  ),

  // ── Challenge 6: Asking for Directions Politely ────────────────────────
  AdventureChallenge(
    id: 6,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 6: Inquire Politely',
    npcId: 'officer_harris',
    npcDialogue:
        'You approach Officer Harris at the intersection to ask how to reach the City Business Center. Which phrasing is most polite and professional?',
    question: 'Choose the most professional way to ask for directions:',
    options: [
      AdventureOption(
        text: 'Excuse me, could you please direct me to the City Business Center?',
        isCorrect: true,
        feedback:
            'Superb! Using "Excuse me", modal "could", and polite "please" is the gold standard of professional English.',
        reaction: 'Officer Harris smiles warmly: "Certainly! Cross the street and head straight ahead."',
      ),
      AdventureOption(
        text: 'Hey! Tell me where the business center is right now.',
        isCorrect: false,
        feedback:
            'This imperative command sounds demanding and rude in professional communication.',
      ),
      AdventureOption(
        text: 'Where business center? I need go fast.',
        isCorrect: false,
        feedback:
            'This lacks grammatical structure and essential polite modal phrases.',
      ),
      AdventureOption(
        text: 'Show road now, I am in hurry.',
        isCorrect: false,
        feedback:
            'Too abrupt and impolite. Always begin with "Excuse me" or "Pardon me".',
      ),
    ],
    targetVocabulary: 'straight',
    vocabularyMeaning: 'in a continuous line without curving or turning (നേരെ)',
    xpReward: 30,
  ),

  // ── Challenge 7: Interactive Route Builder ────────────────────────────
  AdventureChallenge(
    id: 7,
    type: AdventureChallengeType.sentenceBuilder,
    title: 'Challenge 7: Sequence the Route',
    npcId: 'transit_elena',
    npcDialogue:
        'Elena Chen asks you to organize the step-by-step route directions from Grand Metro Station to City Business Center:',
    question: 'Arrange the direction tiles in the logical sequence to reach the destination:',
    sentenceTiles: [
      'Exit the station',
      'turn right at the corner',
      'walk straight past the library',
      'and enter the main lobby',
    ],
    targetSentence:
        'Exit the station turn right at the corner walk straight past the library and enter the main lobby',
    options: [
      AdventureOption(
        text: 'Exit the station ➔ turn right at the corner ➔ walk straight past the library ➔ and enter the main lobby',
        isCorrect: true,
        feedback:
            'Flawless route sequencing! You have organized the multi-step navigation plan perfectly.',
        reaction: 'Elena cheers: "Route compiled! You are ready for the final rush."',
      ),
    ],
    targetVocabulary: 'corner',
    vocabularyMeaning: 'the place where two streets or edges meet (മൂല / തിരിവ്)',
    xpReward: 35,
  ),

  // ── Challenge 8: Timed Navigation Challenge ───────────────────────────
  AdventureChallenge(
    id: 8,
    type: AdventureChallengeType.quickResponse,
    title: 'Challenge 8: Rapid Transit Decision (15s)',
    npcId: 'transit_elena',
    npcDialogue:
        'RAPID DISPATCH ALERT: The delivery window closes in 15 seconds! The road sign flashes: "For City Business Center Lobby, proceed ___ across the pedestrian crossing."',
    question: 'Select the correct direction word before the timer expires:',
    timeLimitSeconds: 15,
    options: [
      AdventureOption(
        text: 'straight',
        isCorrect: true,
        feedback:
            'Brilliant quick reflex! "Proceed straight across" guides you directly to the entrance plaza on time.',
        reaction: 'Elena signals: "Dispatch on schedule! Proceed to security check."',
      ),
      AdventureOption(
        text: 'backward',
        isCorrect: false,
        feedback:
            '"Backward" would take you away from your destination.',
      ),
      AdventureOption(
        text: 'circle',
        isCorrect: false,
        feedback:
            'Walking in circles will cause you to miss the delivery window.',
      ),
    ],
    targetVocabulary: 'straight',
    vocabularyMeaning: 'moving in one direction without turning (നേരെ)',
    xpReward: 30,
  ),

  // ── Challenge 9: Security Entrance Interaction ────────────────────────
  AdventureChallenge(
    id: 9,
    type: AdventureChallengeType.conversationChoice,
    title: 'Challenge 9: Security Clearance',
    npcId: 'security_marcus',
    npcDialogue:
        'Chief Marcus greets you at the security desk: "Good morning. Please confirm which entrance and department you are visiting today."',
    question: 'How should you clearly and professionally state your arrival?',
    options: [
      AdventureOption(
        text: 'Good morning. I am delivering an encrypted dispatch to the executive boardroom on the 4th floor.',
        isCorrect: true,
        feedback:
            'Clear, courteous, and precise! Marcus validates your badge and unlocks the elevator gate.',
        reaction: 'Marcus swipes your pass: "Clearance approved. Elevator B is on your right."',
      ),
      AdventureOption(
        text: 'Open the gate, I have package.',
        isCorrect: false,
        feedback:
            'Unprofessional and abrupt. State your purpose with full courtesy.',
      ),
      AdventureOption(
        text: 'I just walk anywhere in this building.',
        isCorrect: false,
        feedback:
            'Security protocol requires a specific floor and purpose statement.',
      ),
    ],
    targetVocabulary: 'entrance',
    vocabularyMeaning: 'an opening, such as a door or gate, that allows access to a place (പ്രവേശന കവാടം)',
    xpReward: 25,
  ),

  // ── Challenge 10: Final Executive Dispatch Delivery ────────────────────
  AdventureChallenge(
    id: 10,
    type: AdventureChallengeType.finalInterview,
    title: 'Challenge 10: Executive Handover',
    npcId: 'security_marcus',
    npcDialogue:
        'Marcus accompanies you to the boardroom. The Executive Director requests a brief delivery summary: "Please explain your navigation route across the city."',
    question: 'Select the most articulate and complete summary of your journey:',
    options: [
      AdventureOption(
        text: 'I navigated from City Square, followed the road signs opposite the bus stop, passed beside the central bank, and arrived directly at the tech center entrance.',
        isCorrect: true,
        feedback:
            'Outstanding mastery of English spatial prepositions, directional flow, and professional vocabulary!',
        reaction: '🎉 City Navigator Complete! You are a certified Urban Navigation Specialist.',
      ),
      AdventureOption(
        text: 'I just walked on roads and found this big house.',
        isCorrect: false,
        feedback:
            'Lacks precision, spatial terms, and professional articulation.',
      ),
      AdventureOption(
        text: 'City was big and confusing so I ran fast.',
        isCorrect: false,
        feedback:
            'Demonstrate the specific navigation prepositions you learned throughout the city.',
      ),
    ],
    targetVocabulary: 'office',
    vocabularyMeaning: 'a room, set of rooms, or building used as a place for commercial or professional work (ഓഫീസ്)',
    xpReward: 40,
  ),
];

/// 🗺️ Complete Level Data for Day 2
const AdventureLevelData kMission02CityData = AdventureLevelData(
  levelNumber: 2,
  title: 'City Navigator',
  subtitle: 'Metro Pursuit & Urban Exploration',
  environmentName: 'Metro City Center – District 1',
  storyIntro:
      'You are on an urgent mission across the metropolis to deliver a critical encrypted dispatch to the Executive Boardroom at the City Business Center. Street signals are active, traffic is bustling, and directional signs will guide your way. Follow written directions, listen to transit alerts, ask for directions politely, and reach your destination on time!',
  objective:
      'Explore the 2D neon city, interact with guides, collect tokens, and solve 10 directional English navigation challenges.',
  targetVocabularyList: kCityTargetVocabulary,
  npcs: [
    kCityNpcOfficerHarris,
    kCityNpcElena,
    kCityNpcMarcus,
  ],
  challenges: kCityChallenges,
);
