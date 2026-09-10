import 'package:flutter/material.dart';

/// 🔍 Investigation Challenge Types in Level 6
enum LostPackageChallengeType {
  addressReading, // Challenge 1: Reading notice board for building & floor
  packageSearch, // Challenge 2: Finding package PK-4827 in storage
  informationScan, // Challenge 3: Scanning delivery note for collection deadline
  messageComprehension, // Challenge 4: Two-step text message comprehension (reception + valid ID)
  npcResponse, // Challenge 5: Natural dialogue with receptionist
  mismatchDetection, // Challenge 6: Spotting digits mistake (PK-4872 vs PK-4827)
  timeReading, // Challenge 7: Schedule time window evaluation
  instructionAction, // Challenge 8: Delivery note action puzzle
  contextVocabulary, // Challenge 9: Meaning of 'collect' in context
  lockerCode, // Challenge 10: Locker 24 PIN code 7316 entry
}

/// 📦 Individual Package Data
class PackageItemData {
  final String id;
  final String referenceNumber;
  final String recipientName;
  final String address;
  final String locationTag;
  final bool isTargetPackage;
  final Color boxColor;

  const PackageItemData({
    required this.id,
    required this.referenceNumber,
    required this.recipientName,
    required this.address,
    required this.locationTag,
    required this.isTargetPackage,
    this.boxColor = const Color(0xFFD97706),
  });
}

/// 📄 Interactive Document / Notice Card
class DeliveryDocumentData {
  final String id;
  final String title;
  final String subtitle;
  final String bodyText;
  final Map<String, String> keyFields;
  final String spokenText;

  const DeliveryDocumentData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.bodyText,
    required this.keyFields,
    required this.spokenText,
  });
}

/// 🎯 Single Option Choice
class LostPackageOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  const LostPackageOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

/// 🧩 Investigation Challenge Model
class LostPackageChallenge {
  final int id;
  final LostPackageChallengeType type;
  final String title;
  final String objective;
  final String? question;
  final List<LostPackageOption> options;
  final DeliveryDocumentData? document;
  final String? targetReference; // PK-4827
  final String? mismatchReference; // PK-4872
  final int? targetLockerNumber; // 24
  final String? targetLockerCode; // 7316
  final String hint1;
  final String hint2;
  final int xpReward;

  const LostPackageChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.objective,
    this.question,
    this.options = const [],
    this.document,
    this.targetReference,
    this.mismatchReference,
    this.targetLockerNumber,
    this.targetLockerCode,
    required this.hint1,
    required this.hint2,
    this.xpReward = 25,
  });
}

/// 🏙️ Level 6 2D City Zones
class CityInvestigationZone {
  final String id;
  final String name;
  final String tag;
  final double startX;
  final double endX;
  final Color primaryColor;
  final IconData icon;

  const CityInvestigationZone({
    required this.id,
    required this.name,
    required this.tag,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.icon,
  });
}

/// 🗺️ Complete Level 6 Dataset
class LostPackageLevelData {
  final int levelNumber;
  final String title;
  final String tagline;
  final String openingNotification;
  final String targetReference;
  final List<LostPackageChallenge> challenges;
  final List<PackageItemData> storagePackages;
  final List<CityInvestigationZone> zones;
  final List<String> targetVocabulary;

  const LostPackageLevelData({
    required this.levelNumber,
    required this.title,
    required this.tagline,
    required this.openingNotification,
    required this.targetReference,
    required this.challenges,
    required this.storagePackages,
    required this.zones,
    required this.targetVocabulary,
  });
}

/// 🚀 Complete Curriculum for Mission 06 – The Lost Package
const kMission06LostPackageData = LostPackageLevelData(
  levelNumber: 6,
  title: 'The Lost Package',
  tagline: 'Find the package. Read the clues. Make the right choice.',
  openingNotification:
      'Your package has arrived at Central Delivery Hub, but location status is unclear. Reference: PK-4827.',
  targetReference: 'PK-4827',
  zones: [
    CityInvestigationZone(
      id: 'street',
      name: 'Market Street Entrance',
      tag: 'STREET',
      startX: 0,
      endX: 380,
      primaryColor: Color(0xFF0284C7),
      icon: Icons.location_city_rounded,
    ),
    CityInvestigationZone(
      id: 'hub_directory',
      name: 'Building B Directory Board',
      tag: 'DIRECTORY',
      startX: 380,
      endX: 750,
      primaryColor: Color(0xFF10B981),
      icon: Icons.assignment_rounded,
    ),
    CityInvestigationZone(
      id: 'reception',
      name: 'Customer Reception Desk',
      tag: 'RECEPTION',
      startX: 750,
      endX: 1150,
      primaryColor: Color(0xFF8B5CF6),
      icon: Icons.person_rounded,
    ),
    CityInvestigationZone(
      id: 'storage_room',
      name: 'Parcel Storage Depot',
      tag: 'STORAGE',
      startX: 1150,
      endX: 1550,
      primaryColor: Color(0xFFD97706),
      icon: Icons.inventory_2_rounded,
    ),
    CityInvestigationZone(
      id: 'smart_lockers',
      name: 'Automated Locker Bay (Locker 24)',
      tag: 'LOCKERS',
      startX: 1550,
      endX: 1950,
      primaryColor: Color(0xFFEC4899),
      icon: Icons.lock_rounded,
    ),
  ],
  storagePackages: [
    PackageItemData(
      id: 'pkg_1',
      referenceNumber: 'PK-4817',
      recipientName: 'Sarah Jenkins',
      address: '10 Market Street',
      locationTag: 'Shelf A-1',
      isTargetPackage: false,
    ),
    PackageItemData(
      id: 'pkg_2',
      referenceNumber: 'PK-4827',
      recipientName: 'Alex Morgan',
      address: '14 Park Road',
      locationTag: 'Shelf B-2',
      isTargetPackage: true,
      boxColor: Color(0xFF10B981),
    ),
    PackageItemData(
      id: 'pkg_3',
      referenceNumber: 'PK-4872',
      recipientName: 'David Lee',
      address: '22 Elm Avenue',
      locationTag: 'Shelf B-3',
      isTargetPackage: false,
    ),
    PackageItemData(
      id: 'pkg_4',
      referenceNumber: 'PK-4287',
      recipientName: 'Emily Clark',
      address: '8 Sunset Boulevard',
      locationTag: 'Shelf C-1',
      isTargetPackage: false,
    ),
  ],
  targetVocabulary: [
    'package',
    'delivery',
    'collection',
    'reference',
    'recipient',
    'address',
    'reception',
    'locker',
    'label',
    'building',
    'floor',
    'available',
    'deadline',
    'confirm',
    'valid',
    'document',
    'code',
    'notice',
    'pick up',
    'return',
  ],
  challenges: [
    // ── Challenge 1: Read the Address ─────────────────────────────────────────
    LostPackageChallenge(
      id: 1,
      type: LostPackageChallengeType.addressReading,
      title: 'Challenge 1: Read the Address',
      objective: 'Inspect the Hub Directory Board to determine the correct building and floor.',
      document: DeliveryDocumentData(
        id: 'dir_board',
        title: 'CENTRAL DELIVERY HUB',
        subtitle: 'Directory Board',
        bodyText:
            '12 Market Street\nBuilding B\nSecond Floor\nParcel Pick-Up & Dispatch Desk',
        keyFields: {
          'Address': '12 Market Street',
          'Building': 'Building B',
          'Floor': 'Second Floor',
        },
        spokenText:
            'Central Delivery Hub. 12 Market Street, Building B, Second Floor.',
      ),
      question: 'According to the directory board, where should you go?',
      options: [
        LostPackageOption(
          text: 'Building B, Second Floor',
          isCorrect: true,
          feedback: 'Correct! The board specifies Building B on the Second Floor.',
        ),
        LostPackageOption(
          text: 'Building A, First Floor',
          isCorrect: false,
          feedback: 'The notice board clearly states Building B, not Building A.',
        ),
        LostPackageOption(
          text: 'Building C, Second Floor',
          isCorrect: false,
          feedback: 'The directory mentions Building B.',
        ),
        LostPackageOption(
          text: 'Building B, Ground Floor',
          isCorrect: false,
          feedback: 'The board directs visitors to the Second Floor.',
        ),
      ],
      hint1: 'Look at the Building letter on the directory board.',
      hint2: 'Check whether it indicates Ground Floor or Second Floor.',
      xpReward: 25,
    ),

    // ── Challenge 2: Find the Reference Number ────────────────────────────────
    LostPackageChallenge(
      id: 2,
      type: LostPackageChallengeType.packageSearch,
      title: 'Challenge 2: Find Package PK-4827',
      objective: 'Inspect the storage shelves and find your exact parcel: PK-4827.',
      targetReference: 'PK-4827',
      question: 'Which package reference matches your collection notice?',
      options: [
        LostPackageOption(
          text: 'PK-4827',
          isCorrect: true,
          feedback: 'Package Found! PK-4827 matches your collection reference.',
        ),
        LostPackageOption(
          text: 'PK-4817',
          isCorrect: false,
          feedback: 'This is not your package. Notice the digits: 4817 vs 4827.',
        ),
        LostPackageOption(
          text: 'PK-4872',
          isCorrect: false,
          feedback: 'This is PK-4872. The last two digits are transposed.',
        ),
        LostPackageOption(
          text: 'PK-4287',
          isCorrect: false,
          feedback: 'This is PK-4287. Double check your reference code.',
        ),
      ],
      hint1: 'Your reference number starts with PK-48.',
      hint2: 'The last two digits are two-seven (27).',
      xpReward: 25,
    ),

    // ── Challenge 3: Information Scan ─────────────────────────────────────────
    LostPackageChallenge(
      id: 3,
      type: LostPackageChallengeType.informationScan,
      title: 'Challenge 3: Information Scan',
      objective: 'Scan the delivery note to find the collection time deadline.',
      document: DeliveryDocumentData(
        id: 'del_note',
        title: 'PARCEL DELIVERY NOTE',
        subtitle: 'Official Dispatch Receipt',
        bodyText:
            'Recipient: Alex Morgan\nAddress: 14 Park Road\nCollection: Before 6:00 PM\nReference: PK-4827',
        keyFields: {
          'Recipient': 'Alex Morgan',
          'Address': '14 Park Road',
          'Collection': 'Before 6:00 PM',
          'Reference': 'PK-4827',
        },
        spokenText:
            'Recipient Alex Morgan. Address 14 Park Road. Collection before 6:00 PM. Reference PK-4827.',
      ),
      question: 'By what time must the package be collected?',
      options: [
        LostPackageOption(
          text: 'Before 6:00 PM',
          isCorrect: true,
          feedback: 'Accurate scan! The note explicitly states "Before 6:00 PM".',
        ),
        LostPackageOption(
          text: 'Before 5:00 PM',
          isCorrect: false,
          feedback: 'Check the collection line on the delivery note again.',
        ),
        LostPackageOption(
          text: 'After 6:00 PM',
          isCorrect: false,
          feedback: 'The note says "Before", not "After".',
        ),
        LostPackageOption(
          text: 'Tomorrow morning',
          isCorrect: false,
          feedback: 'Today before 6:00 PM is the required collection time.',
        ),
      ],
      hint1: 'Scan directly to the "Collection" field.',
      hint2: 'Look for the hour listed before PM.',
      xpReward: 20,
    ),

    // ── Challenge 4: Message Investigation ────────────────────────────────────
    LostPackageChallenge(
      id: 4,
      type: LostPackageChallengeType.messageComprehension,
      title: 'Challenge 4: Message Investigation',
      objective: 'Read the text message and identify the pickup desk and required item.',
      document: DeliveryDocumentData(
        id: 'phone_msg',
        title: 'SMS NOTIFICATION',
        subtitle: 'Courier Services',
        bodyText:
            'Hi Alex, your package is currently at the reception desk. Please bring a valid ID when collecting it.',
        keyFields: {
          'Location': 'Reception desk',
          'Requirement': 'Valid ID',
        },
        spokenText:
            'Hi Alex, your package is currently at the reception desk. Please bring a valid ID when collecting it.',
      ),
      question: 'Where is the package, and what must you bring to collect it?',
      options: [
        LostPackageOption(
          text: 'Reception desk · Valid ID',
          isCorrect: true,
          feedback: 'Great reading! The message mentions the reception desk and a valid ID.',
        ),
        LostPackageOption(
          text: 'Locker room · Credit card',
          isCorrect: false,
          feedback: 'The message mentions the reception desk and valid ID.',
        ),
        LostPackageOption(
          text: 'Security gate · Cash receipt',
          isCorrect: false,
          feedback: 'Read carefully: "at the reception desk. Please bring a valid ID".',
        ),
      ],
      hint1: 'Look at the sentence starting with "your package is currently at...".',
      hint2: 'Check what item is requested after "Please bring...".',
      xpReward: 20,
    ),

    // ── Challenge 5: NPC Conversation ─────────────────────────────────────────
    LostPackageChallenge(
      id: 5,
      type: LostPackageChallengeType.npcResponse,
      title: 'Challenge 5: Receptionist Conversation',
      objective: 'Communicate naturally and professionally with the receptionist.',
      question: 'Receptionist asks: "Can I help you?" How should you reply?',
      options: [
        LostPackageOption(
          text: '“Yes, I’m here to collect a package. My reference is PK-4827.”',
          isCorrect: true,
          feedback: 'Natural and professional! You clearly stated your purpose and reference.',
        ),
        LostPackageOption(
          text: '“Yes, package me now.”',
          isCorrect: false,
          feedback: 'This is not natural or polite English.',
        ),
        LostPackageOption(
          text: '“I package collect.”',
          isCorrect: false,
          feedback: 'Grammatically incomplete phrase.',
        ),
        LostPackageOption(
          text: '“I am package.”',
          isCorrect: false,
          feedback: 'You are collecting a package, not the package yourself!',
        ),
      ],
      hint1: 'Choose the complete sentence starting with "Yes, I\'m here to...".',
      hint2: 'State your purpose politely and provide your reference number.',
      xpReward: 20,
    ),

    // ── Challenge 6: Spot the Mistake ─────────────────────────────────────────
    LostPackageChallenge(
      id: 6,
      type: LostPackageChallengeType.mismatchDetection,
      title: 'Challenge 6: Spot the Mistake',
      objective: 'Compare the handed package label (PK-4872) with your reference (PK-4827).',
      targetReference: 'PK-4827',
      mismatchReference: 'PK-4872',
      question: 'The receptionist handed you PK-4872. What is different from your reference?',
      options: [
        LostPackageOption(
          text: 'The last two digits are swapped (72 instead of 27)',
          isCorrect: true,
          feedback: 'Sharp eye! PK-4872 ends in 72, whereas your reference is PK-4827 (ends in 27).',
        ),
        LostPackageOption(
          text: 'The letter prefix is different',
          isCorrect: false,
          feedback: 'Both have the prefix PK.',
        ),
        LostPackageOption(
          text: 'The first two digits are different',
          isCorrect: false,
          feedback: 'Both start with 48.',
        ),
      ],
      hint1: 'Compare PK-4827 and PK-4872 side-by-side.',
      hint2: 'Look closely at the final two numbers: 27 vs 72.',
      xpReward: 25,
    ),

    // ── Challenge 7: Date and Time Schedule ───────────────────────────────────
    LostPackageChallenge(
      id: 7,
      type: LostPackageChallengeType.timeReading,
      title: 'Challenge 7: Operating Hours Evaluation',
      objective: 'Evaluate whether given times fall inside the permitted collection window.',
      document: DeliveryDocumentData(
        id: 'schedule_notice',
        title: 'COLLECTION HOURS NOTICE',
        subtitle: 'Customer Service Window',
        bodyText:
            'Collection Date: Friday, September 11\nHours: 10:00 AM – 6:00 PM\nAfter-hours collection is strictly unavailable.',
        keyFields: {
          'Date': 'Friday, September 11',
          'Hours': '10:00 AM – 6:00 PM',
        },
        spokenText:
            'Collection date Friday, September 11. Hours 10:00 AM to 6:00 PM.',
      ),
      question: 'Can you collect the package at 4:30 PM? What about 8:00 PM?',
      options: [
        LostPackageOption(
          text: 'Yes at 4:30 PM (inside hours), but No at 8:00 PM (after closing)',
          isCorrect: true,
          feedback: 'Correct! 4:30 PM is between 10:00 AM and 6:00 PM, while 8:00 PM is closed.',
        ),
        LostPackageOption(
          text: 'Yes for both times',
          isCorrect: false,
          feedback: 'The desk closes at 6:00 PM, so 8:00 PM is closed.',
        ),
        LostPackageOption(
          text: 'No for both times',
          isCorrect: false,
          feedback: '4:30 PM is well within the 10:00 AM – 6:00 PM window.',
        ),
      ],
      hint1: 'Check if 4:30 PM is before 6:00 PM.',
      hint2: 'Check if 8:00 PM is after 6:00 PM.',
      xpReward: 20,
    ),

    // ── Challenge 8: Delivery Note Puzzle ─────────────────────────────────────
    LostPackageChallenge(
      id: 8,
      type: LostPackageChallengeType.instructionAction,
      title: 'Challenge 8: Delivery Note Instruction',
      objective: 'Select the proper contingency action stated on the delivery note.',
      document: DeliveryDocumentData(
        id: 'special_inst',
        title: 'SPECIAL DELIVERY INSTRUCTIONS',
        subtitle: 'Driver & Customer Protocol',
        bodyText:
            'Note: "Leave the package at reception if no one is available."',
        keyFields: {
          'Protocol': 'Leave package at reception',
          'Condition': 'If no one is available',
        },
        spokenText:
            'Leave the package at reception if no one is available.',
      ),
      question: 'According to the instruction, what should be done if no one is available?',
      options: [
        LostPackageOption(
          text: 'Leave it at reception',
          isCorrect: true,
          feedback: 'Exactly right! "Leave the package at reception if no one is available."',
        ),
        LostPackageOption(
          text: 'Put it in the mailbox outside',
          isCorrect: false,
          feedback: 'The note specifies leaving it at reception.',
        ),
        LostPackageOption(
          text: 'Return home immediately',
          isCorrect: false,
          feedback: 'The protocol is to leave it at reception.',
        ),
        LostPackageOption(
          text: 'Take it back to the airport',
          isCorrect: false,
          feedback: 'The instruction does not mention the airport.',
        ),
      ],
      hint1: 'Look at what comes after "Leave the package at...".',
      hint2: 'The destination is "reception".',
      xpReward: 20,
    ),

    // ── Challenge 9: Word Meaning in Context ──────────────────────────────────
    LostPackageChallenge(
      id: 9,
      type: LostPackageChallengeType.contextVocabulary,
      title: 'Challenge 9: Vocabulary in Context',
      objective: 'Determine the practical contextual meaning of the verb "collect".',
      question: 'In the sentence: "Please collect your package from the reception desk", what does "collect" mean?',
      options: [
        LostPackageOption(
          text: 'Pick up / Retrieve',
          isCorrect: true,
          feedback: 'Spot on! In delivery contexts, "collect" means to pick up or retrieve an item.',
        ),
        LostPackageOption(
          text: 'Send / Ship',
          isCorrect: false,
          feedback: 'Sending is dispatching; collecting is retrieving.',
        ),
        LostPackageOption(
          text: 'Open / Unbox',
          isCorrect: false,
          feedback: '"Collect" means obtaining the parcel, not unboxing it.',
        ),
        LostPackageOption(
          text: 'Sell / Purchase',
          isCorrect: false,
          feedback: '"Collect" does not mean buying or selling.',
        ),
      ],
      hint1: 'Think about what you do when you arrive at the reception desk.',
      hint2: 'You go there to "pick up" what was delivered for you.',
      xpReward: 20,
    ),

    // ── Challenge 10: Final Challenge – Package Locker ───────────────────────
    LostPackageChallenge(
      id: 10,
      type: LostPackageChallengeType.lockerCode,
      title: 'Challenge 10: Smart Locker 24 PIN Entry',
      objective: 'Locate Locker 24, enter the 4-digit code (7316), and collect your package.',
      targetLockerNumber: 24,
      targetLockerCode: '7316',
      document: DeliveryDocumentData(
        id: 'locker_pass',
        title: 'SMART LOCKER PASS',
        subtitle: 'Automated 24/7 Retrieval',
        bodyText:
            'Locker: 24\nAccess Code: 7316\nCollection Deadline: 5:30 PM',
        keyFields: {
          'Locker': '24',
          'Code': '7316',
          'Deadline': '5:30 PM',
        },
        spokenText:
            'Locker 24. Access Code 7316. Collection deadline 5:30 PM.',
      ),
      question: 'Enter the 4-digit code to unlock Locker 24:',
      options: [
        LostPackageOption(
          text: '7316',
          isCorrect: true,
          feedback: 'Locker 24 Unlocked! Package PK-4827 retrieved successfully! Mission Complete!',
        ),
        LostPackageOption(
          text: '7361',
          isCorrect: false,
          feedback: 'Incorrect code. Check the locker pass: 7316.',
        ),
        LostPackageOption(
          text: '3716',
          isCorrect: false,
          feedback: 'Code sequence mismatch. The code is 7316.',
        ),
      ],
      hint1: 'Check the "Access Code" field on the locker pass.',
      hint2: 'The 4 digits are 7, 3, 1, 6.',
      xpReward: 50,
    ),
  ],
);
