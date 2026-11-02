import 'package:flutter/material.dart';

/// Supported primary Gang types for POKET PocketGang 2.0
enum PocketGangType {
  individual('individual', 'Individual Gang', 'Personal Workspace', Icons.person_rounded),
  couple('couple', 'Couple Gang', 'Shared Life & Romantic Workspace', Icons.favorite_rounded),
  friendsTeam('friends_team', 'Friends & Team', 'Collaboration & Project Workspace', Icons.groups_rounded);

  final String key;
  final String label;
  final String subtitle;
  final IconData icon;

  const PocketGangType(this.key, this.label, this.subtitle, this.icon);

  static PocketGangType fromKey(String? key) {
    if (key == 'individual') return PocketGangType.individual;
    if (key == 'couple') return PocketGangType.couple;
    return PocketGangType.friendsTeam;
  }
}

/// Purpose templates for Gangs
class PocketGangPurpose {
  final String key;
  final String label;
  final String icon;
  final PocketGangType type;
  final String description;

  const PocketGangPurpose({
    required this.key,
    required this.label,
    required this.icon,
    required this.type,
    required this.description,
  });

  static const List<PocketGangPurpose> allPurposes = [
    // Friends & Team
    PocketGangPurpose(
      key: 'general_friends',
      label: 'General Friends',
      icon: '🎉',
      type: PocketGangType.friendsTeam,
      description: 'Casual chat, hangouts, games, and memories with mates.',
    ),
    PocketGangPurpose(
      key: 'startup_business',
      label: 'Startup & Business',
      icon: '🚀',
      type: PocketGangType.friendsTeam,
      description: 'Lean canvas, product roadmap, launch checklist, and finances.',
    ),
    PocketGangPurpose(
      key: 'software_dev',
      label: 'Software / App Dev',
      icon: '💻',
      type: PocketGangType.friendsTeam,
      description: 'Sprints, architecture diagrams, bug tracking, and code reviews.',
    ),
    PocketGangPurpose(
      key: 'creative_team',
      label: 'Creative / Creators',
      icon: '🎨',
      type: PocketGangType.friendsTeam,
      description: 'Content calendar, moodboards, asset management, and design.',
    ),
    PocketGangPurpose(
      key: 'study_group',
      label: 'Study Group',
      icon: '📚',
      type: PocketGangType.friendsTeam,
      description: 'Exams, revision notes, group assignments, and syllabus tracks.',
    ),
    PocketGangPurpose(
      key: 'event_planning',
      label: 'Event Planning',
      icon: '🎪',
      type: PocketGangType.friendsTeam,
      description: 'Budgeting, guest lists, venues, itineraries, and vendors.',
    ),
    PocketGangPurpose(
      key: 'community_project',
      label: 'Community Project',
      icon: '🌱',
      type: PocketGangType.friendsTeam,
      description: 'Social causes, volunteering, timelines, and impact tracking.',
    ),

    // Individual
    PocketGangPurpose(
      key: 'personal_productivity',
      label: 'Personal Growth',
      icon: '🎯',
      type: PocketGangType.individual,
      description: 'Habits, daily planner, goals, focus timer, and self-review.',
    ),
    PocketGangPurpose(
      key: 'solopreneur',
      label: 'Solopreneur',
      icon: '⚡',
      type: PocketGangType.individual,
      description: 'Client tasks, invoices, personal mindmaps, and project goals.',
    ),
    PocketGangPurpose(
      key: 'exam_prep',
      label: 'Exam & Skill Mastery',
      icon: '🧠',
      type: PocketGangType.individual,
      description: 'Structured study planner, revision timetables, and notes.',
    ),

    // Couple
    PocketGangPurpose(
      key: 'shared_life',
      label: 'Shared Life',
      icon: '💑',
      type: PocketGangType.couple,
      description: 'Shared calendar, bucket lists, memories, and date planning.',
    ),
    PocketGangPurpose(
      key: 'wedding_prep',
      label: 'Wedding & Milestone',
      icon: '💍',
      type: PocketGangType.couple,
      description: 'Countdowns, checklists, honeymoon plans, and joint budgets.',
    ),
    PocketGangPurpose(
      key: 'long_distance',
      label: 'Long Distance Bond',
      icon: '💌',
      type: PocketGangType.couple,
      description: 'Letters, time-capsule notes, daily check-ins, and visits.',
    ),
  ];

  static List<PocketGangPurpose> getForType(PocketGangType type) {
    return allPurposes.where((p) => p.type == type).toList();
  }
}

/// Standardized language model with ISO language codes
class PocketGangLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const PocketGangLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<PocketGangLanguage> supportedLanguages = [
    PocketGangLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    PocketGangLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    PocketGangLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    PocketGangLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    PocketGangLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇦🇪'),
    PocketGangLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    PocketGangLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    PocketGangLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    PocketGangLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    PocketGangLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
  ];
}

