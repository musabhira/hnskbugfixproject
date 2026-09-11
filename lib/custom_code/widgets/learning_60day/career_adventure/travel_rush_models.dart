import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum TravelStatus {
  onTime,
  boarding,
  delayed,
  gateChanged,
  finalCall,
  cancelled,
}

enum TravelChallengeType {
  ticketReading,
  gateNavigation,
  departureBoardScan,
  announcementListening,
  directionRequest,
  seatFinding,
  luggageIdentification,
  delayUnderstanding,
  gateChangeAdjustment,
  staffConversation,
  travelRequest,
  finalBoardingRush,
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA STRUCTURES
// ─────────────────────────────────────────────────────────────────────────────

class TravelHubZone {
  final String id;
  final String name;
  final double worldX;
  final Color themeColor;
  final IconData icon;
  final String description;

  const TravelHubZone({
    required this.id,
    required this.name,
    required this.worldX,
    required this.themeColor,
    required this.icon,
    required this.description,
  });
}

class DepartureBoardFlight {
  final String flightNumber;
  final String destination;
  final String departureTime;
  final String gate;
  final TravelStatus status;

  const DepartureBoardFlight({
    required this.flightNumber,
    required this.destination,
    required this.departureTime,
    required this.gate,
    required this.status,
  });
}

class TravelCard {
  final String passengerName;
  final String destination;
  final String departureTime;
  final String gate;
  final String seat;
  final String coach;
  final String referenceId;
  final String flightNumber;

  const TravelCard({
    required this.passengerName,
    required this.destination,
    required this.departureTime,
    required this.gate,
    required this.seat,
    required this.coach,
    required this.referenceId,
    required this.flightNumber,
  });

  TravelCard copyWith({
    String? gate,
    String? departureTime,
  }) {
    return TravelCard(
      passengerName: passengerName,
      destination: destination,
      departureTime: departureTime ?? this.departureTime,
      gate: gate ?? this.gate,
      seat: seat,
      coach: coach,
      referenceId: referenceId,
      flightNumber: flightNumber,
    );
  }
}

class TravelRushChallenge {
  final String id;
  final TravelChallengeType type;
  final String question;
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String targetZoneId;
  final String audioAnnouncement;
  final int? delayMinutes;
  final String? updatedGate;
  final int timeLimitSeconds;
  final int xpReward;
  final String hint;

  const TravelRushChallenge({
    required this.id,
    required this.type,
    required this.question,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.targetZoneId,
    required this.audioAnnouncement,
    this.delayMinutes,
    this.updatedGate,
    this.timeLimitSeconds = 0,
    this.xpReward = 20,
    required this.hint,
  });
}

class TravelRushLevelData {
  final String title;
  final String tagline;
  final List<TravelHubZone> zones;
  final List<DepartureBoardFlight> flights;
  final TravelCard initialTravelCard;
  final List<TravelRushChallenge> challenges;
  final List<String> targetVocabulary;

  const TravelRushLevelData({
    required this.title,
    required this.tagline,
    required this.zones,
    required this.flights,
    required this.initialTravelCard,
    required this.challenges,
    required this.targetVocabulary,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CURRICULUM DATA – LEVEL 14: TRAVEL RUSH
// ─────────────────────────────────────────────────────────────────────────────

const kMission14TravelRushData = TravelRushLevelData(
  title: 'Level 14 – Travel Rush',
  tagline: 'Understand the journey. Make the right move. Reach your destination.',
  zones: [
    TravelHubZone(
      id: 'entrance',
      name: 'Hub Entrance',
      worldX: 120,
      themeColor: Color(0xFF38BDF8),
      icon: Icons.door_front_door_rounded,
      description: 'Glass automatic doors and initial arrival hallway.',
    ),
    TravelHubZone(
      id: 'info_desk',
      name: 'Information Desk',
      worldX: 380,
      themeColor: Color(0xFF818CF8),
      icon: Icons.info_rounded,
      description: 'Helpdesk with service agents and directional maps.',
    ),
    TravelHubZone(
      id: 'ticket_area',
      name: 'Ticket Area',
      worldX: 640,
      themeColor: Color(0xFF34D399),
      icon: Icons.confirmation_number_rounded,
      description: 'Automated kiosks and check-in luggage desks.',
    ),
    TravelHubZone(
      id: 'waiting_hall',
      name: 'Waiting Hall',
      worldX: 900,
      themeColor: Color(0xFFFBBF24),
      icon: Icons.airline_seat_recline_extra_rounded,
      description: 'Seating benches and digital departure display boards.',
    ),
    TravelHubZone(
      id: 'security_area',
      name: 'Security Check',
      worldX: 1160,
      themeColor: Color(0xFFEF4444),
      icon: Icons.security_rounded,
      description: 'Baggage scanners and boarding pass checkpoints.',
    ),
    TravelHubZone(
      id: 'food_court',
      name: 'Food Court',
      worldX: 1420,
      themeColor: Color(0xFFA78BFA),
      icon: Icons.fastfood_rounded,
      description: 'Cafés and quick grab-and-go bakeries.',
    ),
    TravelHubZone(
      id: 'gates_main',
      name: 'Gates 8–14 Concourse',
      worldX: 1680,
      themeColor: Color(0xFF0D9488),
      icon: Icons.flight_takeoff_rounded,
      description: 'Main departure walkway leading to Gate 12.',
    ),
    TravelHubZone(
      id: 'luggage_area',
      name: 'Luggage Carousel 3',
      worldX: 1940,
      themeColor: Color(0xFFD97706),
      icon: Icons.luggage_rounded,
      description: 'Rotating baggage claim carousel.',
    ),
    TravelHubZone(
      id: 'gate_18',
      name: 'Gate 18 (Terminal B)',
      worldX: 2200,
      themeColor: Color(0xFFC084FC),
      icon: Icons.meeting_room_rounded,
      description: 'Updated departure gate for Bengaluru passengers.',
    ),
    TravelHubZone(
      id: 'boarding_jetway',
      name: 'Boarding Jetway',
      worldX: 2450,
      themeColor: Color(0xFF10B981),
      icon: Icons.airplane_ticket_rounded,
      description: 'Final boarding tunnel onto the Bengaluru express.',
    ),
  ],
  flights: [
    DepartureBoardFlight(
      flightNumber: 'TR-204',
      destination: 'Bengaluru',
      departureTime: '4:30 PM',
      gate: '12',
      status: TravelStatus.boarding,
    ),
    DepartureBoardFlight(
      flightNumber: 'AI-412',
      destination: 'Chennai',
      departureTime: '4:15 PM',
      gate: '6',
      status: TravelStatus.onTime,
    ),
    DepartureBoardFlight(
      flightNumber: 'UK-850',
      destination: 'Mumbai',
      departureTime: '5:00 PM',
      gate: '4',
      status: TravelStatus.onTime,
    ),
    DepartureBoardFlight(
      flightNumber: '6E-310',
      destination: 'Delhi',
      departureTime: '5:20 PM',
      gate: '9',
      status: TravelStatus.onTime,
    ),
  ],
  initialTravelCard: TravelCard(
    passengerName: 'Alex Morgan',
    destination: 'Bengaluru',
    departureTime: '4:30 PM',
    gate: '12',
    seat: '18A',
    coach: 'B',
    referenceId: 'TR-4827',
    flightNumber: 'TR-204',
  ),
  challenges: [
    // 1. Ticket Reading & Initial Gate
    TravelRushChallenge(
      id: 'tr_001',
      type: TravelChallengeType.ticketReading,
      question: 'Check your travel confirmation. Which gate is assigned for departure?',
      prompt: 'Inspect your travel card and locate Gate 12.',
      options: ['Gate 12', 'Gate 6', 'Gate 18', 'Gate 4'],
      correctOptionIndex: 0,
      targetZoneId: 'gates_main',
      audioAnnouncement: 'Welcome to the transit hub. Boarding for Bengaluru will commence at Gate 12.',
      xpReward: 20,
      hint: 'Open your travel card in the top right to verify your assigned gate.',
    ),

    // 2. Departure Board Scan
    TravelRushChallenge(
      id: 'tr_002',
      type: TravelChallengeType.departureBoardScan,
      question: 'According to the central departure board, when does the Bengaluru trip depart?',
      prompt: 'Read the digital departure board in the Waiting Hall.',
      options: ['4:30 PM', '4:15 PM', '5:00 PM', '5:20 PM'],
      correctOptionIndex: 0,
      targetZoneId: 'waiting_hall',
      audioAnnouncement: 'Passengers are advised to check electronic departure screens for flight status.',
      xpReward: 20,
      hint: 'Find "Bengaluru" on the departure board. Departure time is 4:30 PM.',
    ),

    // 3. Announcement Listening
    TravelRushChallenge(
      id: 'tr_003',
      type: TravelChallengeType.announcementListening,
      question: 'Listen to the public announcement: Which gate are Bengaluru passengers requested to proceed to?',
      prompt: 'Tap the audio button to hear the airport broadcast.',
      options: ['Gate 12', 'Gate 14', 'Gate 8', 'Gate 20'],
      correctOptionIndex: 0,
      targetZoneId: 'gates_main',
      audioAnnouncement:
          'Passengers travelling to Bengaluru on flight TR-204 are requested to proceed to Gate 12.',
      xpReward: 25,
      hint: 'Listen closely: "...flight 204 are requested to proceed to Gate 12."',
    ),

    // 4. Asking for Directions at Info Desk
    TravelRushChallenge(
      id: 'tr_004',
      type: TravelChallengeType.directionRequest,
      question: 'You approach the Information Desk. How do you politely ask for directions to Gate 12?',
      prompt: 'Select the polite, natural workplace inquiry:',
      options: [
        'Could you tell me where Gate 12 is?',
        'Where is gate twelve quickly?',
        'I demand to see Gate 12 now.',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'info_desk',
      audioAnnouncement: 'Go straight and take the escalator on your right.',
      xpReward: 25,
      hint: 'Use polite modals: "Could you tell me where...?"',
    ),

    // 5. Seat Finding
    TravelRushChallenge(
      id: 'tr_005',
      type: TravelChallengeType.seatFinding,
      question: 'Check your travel card: Which seat should you take on the express?',
      prompt: 'Extract the designated seat number from your reservation:',
      options: ['18A', '18B', '28A', '8A'],
      correctOptionIndex: 0,
      targetZoneId: 'waiting_hall',
      audioAnnouncement: 'Please have your seat assignment ready for verification.',
      xpReward: 20,
      hint: 'Your travel card specifies Seat 18A in Coach B.',
    ),

    // 6. Luggage Identification
    TravelRushChallenge(
      id: 'tr_006',
      type: TravelChallengeType.luggageIdentification,
      question: 'Your notification states: "Your blue suitcase is ready for collection." Which bag do you pick?',
      prompt: 'Identify the correct luggage on Carousel 3:',
      options: [
        'Blue suitcase',
        'Black backpack',
        'Grey rolling duffel',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'luggage_area',
      audioAnnouncement: 'Baggage claim carousel 3 is now delivering luggage for flight TR-204.',
      xpReward: 25,
      hint: 'Select the Blue suitcase as specified in your delivery notification.',
    ),

    // 7. Delay Understanding
    TravelRushChallenge(
      id: 'tr_007',
      type: TravelChallengeType.delayUnderstanding,
      question: 'Announcement: "Due to a technical issue, departure has been delayed by 30 minutes." How long is the delay?',
      prompt: 'Calculate the adjusted time and duration:',
      options: ['30 minutes', '10 minutes', '20 minutes', '60 minutes'],
      correctOptionIndex: 0,
      targetZoneId: 'waiting_hall',
      audioAnnouncement: 'Due to a technical issue, departure has been delayed by 30 minutes.',
      delayMinutes: 30,
      xpReward: 20,
      hint: 'The announcer clearly stated: "...delayed by 30 minutes."',
    ),

    // 8. Gate Change Adjustment
    TravelRushChallenge(
      id: 'tr_008',
      type: TravelChallengeType.gateChangeAdjustment,
      question: 'ALERT: Departure gate has changed from Gate 12 to Gate 18! Where must you navigate now?',
      prompt: 'Adjust your route immediately toward Terminal B:',
      options: [
        'Gate 18',
        'Gate 12',
        'Gate 8',
        'Gate 10',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'gate_18',
      updatedGate: '18',
      audioAnnouncement: 'Attention passengers: Departure for Bengaluru has been relocated to Gate 18.',
      xpReward: 30,
      hint: 'Ignore Gate 12! Follow signs toward Gate 18 in Terminal B.',
    ),

    // 9. Staff Conversation
    TravelRushChallenge(
      id: 'tr_009',
      type: TravelChallengeType.staffConversation,
      question: 'Gate Agent: "May I see your ticket, please?" What is your natural response?',
      prompt: 'Respond naturally to the staff member:',
      options: [
        'Sure. Here you are.',
        'Why do you want my ticket?',
        'I do not have anything for you.',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'gate_18',
      audioAnnouncement: 'May I see your ticket and boarding pass, please?',
      xpReward: 25,
      hint: 'Polite English handoff: "Sure. Here you are." or "Of course. Here you go."',
    ),

    // 10. Travel Request
    TravelRushChallenge(
      id: 'tr_010',
      type: TravelChallengeType.travelRequest,
      question: 'How do you ask the gate staff if there is a charging station nearby?',
      prompt: 'Select the natural conversational request:',
      options: [
        'Is there a charging station nearby?',
        'Give me phone battery now.',
        'Electricity is needed here.',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'gate_18',
      audioAnnouncement: 'Yes, charging stations are located directly behind row 4.',
      xpReward: 25,
      hint: 'Use: "Is there a charging station nearby?" or "Could you tell me where...?"',
    ),

    // 11. Final Boarding Sprint (90s)
    TravelRushChallenge(
      id: 'tr_011',
      type: TravelChallengeType.finalBoardingRush,
      question: 'FINAL CALL: "Final boarding call for passengers to Bengaluru. Please proceed to Gate 18 immediately!"',
      prompt: 'SPRINT! Reach Gate 18, confirm destination, and board before the door closes!',
      options: [
        'Yes, I am travelling to Bengaluru. (Show Ticket)',
        'I am going to Delhi.',
        'Please wait, I forgot my bag.',
      ],
      correctOptionIndex: 0,
      targetZoneId: 'boarding_jetway',
      timeLimitSeconds: 90,
      audioAnnouncement:
          'Final boarding call for passengers travelling to Bengaluru. Please proceed to Gate 18 immediately.',
      xpReward: 60,
      hint: '90-second rush! Head to Gate 18 Jetway and confirm "Yes, I am travelling to Bengaluru."',
    ),
  ],
  targetVocabulary: [
    'departure',
    'arrival',
    'boarding',
    'gate',
    'platform',
    'ticket',
    'seat',
    'passenger',
    'luggage',
    'suitcase',
    'backpack',
    'destination',
    'delay',
    'announcement',
    'terminal',
    'security',
    'check-in',
    'information desk',
    'escalator',
    'entrance',
    'exit',
    'reference',
    'reservation',
    'boarding pass',
    'departure time',
  ],
);
