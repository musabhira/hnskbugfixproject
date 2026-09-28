import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎯 Represents the learner's determined starting proficiency level.
enum LearnerLevel {
  zero, // Absolute beginner (doesn't know ABC / letter sounds)
  beginner, // Knows some words & basic phrases
  intermediate, // Can form simple sentences, lacks grammar/confidence
  advanced, // Fluent, aims for career/interview & peak mastery
}

/// 📚 Model for a structured Syllabus Track Milestone
class SyllabusMilestone {
  final String dayRange;
  final String titleEn;
  final String titleNative;
  final String descriptionEn;
  final String descriptionNative;
  final String focusAreaEn;
  final String focusAreaNative;
  final IconData icon;
  final Color color;

  const SyllabusMilestone({
    required this.dayRange,
    required this.titleEn,
    required this.titleNative,
    required this.descriptionEn,
    required this.descriptionNative,
    required this.focusAreaEn,
    required this.focusAreaNative,
    required this.icon,
    required this.color,
  });
}

/// 🌟 Comprehensive 90-Day Curriculum Track Model
class SyllabusTrack {
  final LearnerLevel level;
  final String code;
  final String nameEn;
  final String nameNative;
  final String targetAudienceEn;
  final String targetAudienceNative;
  final String badgeText;
  final Color primaryColor;
  final IconData icon;
  final List<SyllabusMilestone> milestones;

  const SyllabusTrack({
    required this.level,
    required this.code,
    required this.nameEn,
    required this.nameNative,
    required this.targetAudienceEn,
    required this.targetAudienceNative,
    required this.badgeText,
    required this.primaryColor,
    required this.icon,
    required this.milestones,
  });
}

/// 🏛️ Central Repository of all 90-Day Syllabus Tracks for PoketMates
class PocketSyllabusRepository {
  static const String kPrefsLearnerLevel = 'pm_user_learner_level';
  static const String kPrefsGeneratedSyllabus = 'pm_generated_syllabus_v1';

  static final Map<LearnerLevel, SyllabusTrack> tracks = {
    // -------------------------------------------------------------
    // TRACK 0: Zero Foundation (Audio-First, for Absolute Beginners)
    // -------------------------------------------------------------
    LearnerLevel.zero: const SyllabusTrack(
      level: LearnerLevel.zero,
      code: 'zero_foundation',
      nameEn: 'Zero Foundation Track',
      nameNative: 'ശൂന്യത്തിൽ നിന്നുള്ള അടിത്തറ (Zero to Hero)',
      targetAudienceEn:
          'Absolute beginners starting from zero. No reading or spelling required — pure voice and sound.',
      targetAudienceNative:
          'ഇംഗ്ലീഷിൽ ABC അക്ഷരങ്ങളോ വാക്കുകളോ അറിയാത്തവർക്ക്. കേട്ടു പറഞ്ഞ് ശീലിക്കുന്ന ലളിതമായ വോയ്‌സ് രീതി.',
      badgeText: '🌱 LEVEL 0: ZERO FOUNDATION',
      primaryColor: Color(0xFF10B981),
      icon: Icons.record_voice_over_rounded,
      milestones: [
        SyllabusMilestone(
          dayRange: 'Day 1 - 15',
          titleEn: 'Letters, Phonics & Everyday Sounds',
          titleNative: 'ശബ്ദങ്ങളും അക്ഷരങ്ങളും (Phonics & Sounds)',
          descriptionEn:
              'Master all 26 letter sounds and mouth movements with native Malayalam guides. Tap, listen, and shadow pronounce.',
          descriptionNative:
              'A മുതൽ Z വരെയുള്ള അക്ഷരങ്ങളുടെ യഥാർത്ഥ ശബ്ദങ്ങൾ മലയാളത്തിൽ കേട്ടു പഠിക്കുക. ചിത്രങ്ങൾ കണ്ട് ഉച്ചാരണം ആവർത്തിക്കുക.',
          focusAreaEn: 'Pronunciation reflex & 50 basic objects',
          focusAreaNative: 'ഉച്ചാരണ ശുദ്ധിയും 50 നിത്യജീവിത വസ്തുക്കളുടെ പേരുകളും',
          icon: Icons.mic_rounded,
          color: Color(0xFF10B981),
        ),
        SyllabusMilestone(
          dayRange: 'Day 16 - 35',
          titleEn: '150 Household & Market Survival Words',
          titleNative: 'നിത്യോപയോഗ പദസമ്പത്ത് (150 Essential Words)',
          descriptionEn:
              'Water, Tea, Food, Money, Market, Hospital, Time, Family. Instant audio flashcards with picture association.',
          descriptionNative:
              'വീട്ടിലും കടകളിലും ആശുപത്രിയിലും ഉപയോഗിക്കുന്ന 150 അത്യാവശ്യ വാക്കുകൾ ഓഡിയോ സഹിതം കാണാതെ പഠിക്കുക.',
          focusAreaEn: 'Sight & sound word vocabulary',
          focusAreaNative: 'നിത്യജീവിത വാക്കുകൾ തിരിച്ചറിഞ്ഞ് പറയൽ',
          icon: Icons.storefront_rounded,
          color: Color(0xFF06B6D4),
        ),
        SyllabusMilestone(
          dayRange: 'Day 36 - 60',
          titleEn: '2-3 Word Daily Survival Phrases',
          titleNative: 'ലളിതമായ നിത്യജീവിത വാചകങ്ങൾ (Action Phrases)',
          descriptionEn:
              '"Give me water", "How much is this?", "I am going", "Call me". Express basic daily needs confidently.',
          descriptionNative:
              '2-3 വാക്കുകൾ ചേർത്തുള്ള അത്യാവശ്യ സംഭാഷണങ്ങൾ. ആരുടെയും സഹായമില്ലാതെ സ്വന്തമായി കാര്യങ്ങൾ പറയാൻ പ്രാപ്തരാവുക.',
          focusAreaEn: 'Need-based speech & simple answers',
          focusAreaNative: 'അത്യാവശ്യ കാര്യങ്ങൾ സംശയമില്ലാതെ പറയുക',
          icon: Icons.chat_bubble_outline_rounded,
          color: Color(0xFF3B82F6),
        ),
        SyllabusMilestone(
          dayRange: 'Day 61 - 90',
          titleEn: 'Friendly AI Robot Voice Conversations',
          titleNative: 'പോക്കറ്റ് റോബോട്ടുമൊത്തുള്ള സംസാരം (AI Voice Chat)',
          descriptionEn:
              'Speak 5 minutes daily with our friendly voice bot in Malayalam-English mix. Zero shame, infinite encouragement.',
          descriptionNative:
              'തെറ്റിയാലും ആരും കളിയാക്കാത്ത അന്തരീക്ഷത്തിൽ റോബോട്ടിനോട് സംസാരിച്ചു തുടങ്ങുക. ഭയം പൂർണ്ണമായി മാറുന്നു.',
          focusAreaEn: 'Speaking courage & daily habit',
          focusAreaNative: 'സംസാരിക്കാനുള്ള ഭയം മാറലും ആത്മവിശ്വാസവും',
          icon: Icons.smart_toy_rounded,
          color: Color(0xFFF59E0B),
        ),
      ],
    ),

    // -------------------------------------------------------------
    // TRACK 1: Daily Conversational Fluency (Beginner)
    // -------------------------------------------------------------
    LearnerLevel.beginner: const SyllabusTrack(
      level: LearnerLevel.beginner,
      code: 'daily_fluency',
      nameEn: 'Daily Conversational Track',
      nameNative: 'ദൈനംദിന സംഭാഷണ പാത (Daily Fluency)',
      targetAudienceEn:
          'Learners who know words and basic phrases, but struggle to frame sentences quickly.',
      targetAudienceNative:
          'ചെറിയ വാക്കുകൾ അറിയാം, പക്ഷേ പെട്ടെന്ന് വാചകം ഉണ്ടാക്കാനും മറ്റുള്ളവരോട് മറുപടി പറയാനും ബുദ്ധിമുട്ടുള്ളവർക്ക്.',
      badgeText: '💬 LEVEL 1: BEGINNER',
      primaryColor: Color(0xFF38BDF8),
      icon: Icons.forum_rounded,
      milestones: [
        SyllabusMilestone(
          dayRange: 'Day 1 - 20',
          titleEn: 'Everyday Situation Frameworks',
          titleNative: 'നിത്യജീവിത സാഹചര്യങ്ങൾ (Real Scenarios)',
          descriptionEn:
              'Master conversations in Restaurants, Shopping Malls, Cabs, Doctors, and Supermarkets without hesitation.',
          descriptionNative:
              'കടകളിൽ സാധനം വാങ്ങൽ, ഡോക്ടറോട് സംസാരിക്കൽ, യാത്രകൾ എന്നിവയിലെ യഥാർത്ഥ സംഭാഷണങ്ങൾ.',
          focusAreaEn: 'Real-world situational dialogues',
          focusAreaNative: 'സാഹചര്യങ്ങൾക്കനുസരിച്ച് മറുപടി നൽകൽ',
          icon: Icons.local_cafe_rounded,
          color: Color(0xFF38BDF8),
        ),
        SyllabusMilestone(
          dayRange: 'Day 21 - 45',
          titleEn: 'Natural Tense Shifting without Grammar Fatigue',
          titleNative: 'ടെൻസുകൾ സംസാരിച്ചു പഠിക്കൽ (Effortless Tenses)',
          descriptionEn:
              'Express Past, Present, and Future events naturally using Time Machine exercises instead of dry grammar rules.',
          descriptionNative:
              'കഴിഞ്ഞതും ഇപ്പൊഴുള്ളതും നാളെ നടക്കാനിരിക്കുന്നതും സ്വാഭാവികമായി തെറ്റില്ലാതെ സംസാരിക്കാൻ ശീലിക്കുക.',
          focusAreaEn: 'Did / Will / Is / Have usage in real flow',
          focusAreaNative: 'ടെൻസുകളുടെ സ്വാഭാവിക പ്രയോഗം',
          icon: Icons.history_rounded,
          color: Color(0xFF818CF8),
        ),
        SyllabusMilestone(
          dayRange: 'Day 46 - 70',
          titleEn: 'Common Spoken Errors & Mother Tongue Interference',
          titleNative: 'സാധാരണ തെറ്റുകൾ തിരുത്തൽ (Mistake Elimination)',
          descriptionEn:
              'Fix common literal Malayalam-to-English translations. Build idiomatic rhythm and natural connecting phrases.',
          descriptionNative:
              'നേരിട്ട് മലയാളത്തിൽ നിന്ന് ചിന്തിച്ചു പറയുമ്പോൾ വരുന്ന തെറ്റുകൾ ഒഴിവാക്കി ശുദ്ധമായ ശൈലി ഉണ്ടാക്കുക.',
          focusAreaEn: 'Sentence smoothness & thought bridges',
          focusAreaNative: 'ചിന്തയും വാക്കും തമ്മിലുള്ള സ്പീഡ് കൂട്ടൽ',
          icon: Icons.auto_fix_high_rounded,
          color: Color(0xFFA855F7),
        ),
        SyllabusMilestone(
          dayRange: 'Day 71 - 90',
          titleEn: 'Live Peer Practice & Speech Endurance',
          titleNative: 'ലൈവ് സംസാരവും ആത്മവിശ്വാസവും (Live Speaking)',
          descriptionEn:
              'Engage in 10-minute daily peer audio calls and coffee table rooms. Deliver spontaneous 2-minute talks.',
          descriptionNative:
              'മറ്റു പഠിതാക്കളുമായി ഫോണിൽ സംസാരിക്കൽ, കോഫി ടേബിളിൽ സ്വന്തം അഭിപ്രായങ്ങൾ വ്യക്തമായി പറയൽ.',
          focusAreaEn: 'Active speaking stamina & instant replies',
          focusAreaNative: 'മടിയേതുമില്ലാതെ ആത്മവിശ്വാസത്തോടെ സംസാരിക്കൽ',
          icon: Icons.people_alt_rounded,
          color: Color(0xFFEC4899),
        ),
      ],
    ),

    // -------------------------------------------------------------
    // TRACK 2: Intermediate Spoken Mastery
    // -------------------------------------------------------------
    LearnerLevel.intermediate: const SyllabusTrack(
      level: LearnerLevel.intermediate,
      code: 'intermediate_mastery',
      nameEn: 'Spoken Agility & Confidence Track',
      nameNative: 'ഫ്ലുവെൻസി & കോൺഫിഡൻസ് പാത (Intermediate)',
      targetAudienceEn:
          'Can hold simple conversations, but wants better sentence variety, speed, and grammatical polish.',
      targetAudienceNative:
          'ചിലതൊക്കെ സംസാരിക്കും, എന്നാൽ വലിയ ഗ്രൂപ്പുകളിൽ സംസാരിക്കാൻ പേടിയും വാക്കുകൾ ആലോചിച്ചു നിൽക്കേണ്ടിയും വരുന്നവർക്ക്.',
      badgeText: '⚡ LEVEL 2: INTERMEDIATE',
      primaryColor: Color(0xFFA855F7),
      icon: Icons.psychology_rounded,
      milestones: [
        SyllabusMilestone(
          dayRange: 'Day 1 - 25',
          titleEn: 'Complex Sentence Connectors & Nuance',
          titleNative: 'വാചകങ്ങൾ ഭംഗിയായി കൂട്ടിയോജിപ്പിക്കൽ (Connectors)',
          descriptionEn:
              'Utilize powerful transitional adverbs and conjunctions ("Although", "Furthermore", "As a matter of fact").',
          descriptionNative:
              'ചെറിയ വാചകങ്ങൾക്ക് പകരം കേൾക്കാൻ ഇമ്പമുള്ള വലിയ വാചകങ്ങൾ സുഗമമായി നിർമ്മിക്കാൻ പഠിക്കുക.',
          focusAreaEn: 'Transition words & sentence flow',
          focusAreaNative: 'സംസാരത്തിന് ഒരു സ്വാഭാവിക താളം നൽകൽ',
          icon: Icons.linear_scale_rounded,
          color: Color(0xFFA855F7),
        ),
        SyllabusMilestone(
          dayRange: 'Day 26 - 55',
          titleEn: 'Storytelling & Opinion Formulation',
          titleNative: 'കഥ പറച്ചിലും സ്വന്തം അഭിപ്രായങ്ങളും (Storytelling)',
          descriptionEn:
              'Narrate past memories, describe incidents vividly, and present structured personal arguments on hot topics.',
          descriptionNative:
              'ഒരു സംഭവം രസകരമായി വിവരിക്കാനും ചർച്ചകളിൽ സ്വന്തം അഭിപ്രായങ്ങൾ തറപ്പിച്ചു പറയാനും പരിശീലിക്കുക.',
          focusAreaEn: 'Spontaneous descriptive speaking',
          focusAreaNative: 'വിവരണാത്മകമായ സംസാര വൈഭവം',
          icon: Icons.auto_stories_rounded,
          color: Color(0xFFF43F5E),
        ),
        SyllabusMilestone(
          dayRange: 'Day 56 - 90',
          titleEn: 'Coffee Table Stage & Debate Arena',
          titleNative: 'കോഫി ടേബിൾ ലൈവ് ഡിബേറ്റുകൾ (Group Mastery)',
          descriptionEn:
              'Lead voice discussions in Coffee Table rooms, field counter-arguments, and express respectful disagreement.',
          descriptionNative:
              'ഗ്രൂപ്പ് ചർച്ചകൾ ലീഡ് ചെയ്യുക, മറ്റുള്ളവരോട് മാന്യമായി വിയോജിപ്പുകൾ പ്രകടിപ്പിക്കുക, ആവേശം നിലനിർത്തുക.',
          focusAreaEn: 'Leadership, debate & accent neutrality',
          focusAreaNative: 'നേതൃത്വ ഗുണവും വ്യക്തമായ സംഭാഷണ ശൈലിയും',
          icon: Icons.mic_external_on_rounded,
          color: Color(0xFFFFD700),
        ),
      ],
    ),

    // -------------------------------------------------------------
    // TRACK 3: Advanced Career & Peak Fluency
    // -------------------------------------------------------------
    LearnerLevel.advanced: const SyllabusTrack(
      level: LearnerLevel.advanced,
      code: 'advanced_peak',
      nameEn: 'Career & Executive Fluency Track',
      nameNative: 'പ്രൊഫഷണൽ & ഇന്റർവ്യൂ മാസ്റ്ററി (Peak Mastery)',
      targetAudienceEn:
          'Fluent speakers striving for corporate leadership, global client calls, and IELTS 8.0+ presentation ease.',
      targetAudienceNative:
          'നന്നായി സംസാരിക്കും, വിദേശ ജോലികൾ, ഇന്റർവ്യൂകൾ, ആഗോള പ്രസന്റേഷനുകൾ എന്നിവയിൽ മികച്ച മികവ് പുലർത്താൻ ആഗ്രഹിക്കുന്നവർക്ക്.',
      badgeText: '👑 LEVEL 3: PEAK MASTERY',
      primaryColor: Color(0xFFFFD700),
      icon: Icons.workspace_premium_rounded,
      milestones: [
        SyllabusMilestone(
          dayRange: 'Day 1 - 30',
          titleEn: 'Executive Vocabulary & Workplace Nuances',
          titleNative: 'കോർപ്പറേറ്റ് ഇംഗ്ലീഷ് (Executive Communication)',
          descriptionEn:
              'High-impact corporate phrasal verbs, diplomatic negotiations, and assertive communication protocols.',
          descriptionNative:
              'ബിസിനസ്സ് മീറ്റിംഗുകൾ, ക്ലയന്റ് കോളുകൾ, ഉന്നതതല ചർച്ചകൾ എന്നിവയിൽ ഉപയോഗിക്കേണ്ട സ്മാർട്ട് ശൈലികൾ.',
          focusAreaEn: 'Diplomacy & executive vocabulary',
          focusAreaNative: 'ഉന്നത നിലവാരത്തിലുള്ള ഓഫീസ് ഇംഗ്ലീഷ്',
          icon: Icons.business_center_rounded,
          color: Color(0xFFFFD700),
        ),
        SyllabusMilestone(
          dayRange: 'Day 31 - 60',
          titleEn: 'High-Stakes Job Interviews & Pitching',
          titleNative: 'ഇന്റർവ്യൂ മോക്ക് കോളുകൾ (Interview Mastery)',
          descriptionEn:
              'STAR technique responses, handling unexpected tricky questions, and delivering memorable personal pitches.',
          descriptionNative:
              'STAR രീതി ഉപയോഗിച്ച് ഇന്റർവ്യൂ ചോദ്യങ്ങൾക്ക് പെർഫെക്റ്റ് മറുപടി നൽകാൻ മോക്ക് ഡ്രില്ലുകൾ.',
          focusAreaEn: 'STAR storytelling & persuasion',
          focusAreaNative: 'ഇന്റർവ്യൂകളിൽ പൂർണ്ണ ആത്മവിശ്വാസം',
          icon: Icons.co_present_rounded,
          color: Color(0xFFF97316),
        ),
        SyllabusMilestone(
          dayRange: 'Day 61 - 90',
          titleEn: 'Global Stage Presence & Natural Rhythm',
          titleNative: 'ഗ്ലോബൽ പ്രസന്റേഷനുകൾ (Global Fluency)',
          descriptionEn:
              'Master intonation, connected speech assimilation, and effortless eloquence on international stages.',
          descriptionNative:
              'ഏതൊരു വിദേശിയോടും ഒഴുക്കോടെയും ആത്മവിശ്വാസത്തോടെയും സംസാരിക്കാൻ കഴിയുന്ന ഉന്നത നിലവാരം.',
          focusAreaEn: 'Global accent adaptability & eloquence',
          focusAreaNative: 'ആഗോള തലത്തിലുള്ള ഇംഗ്ലീഷ് ഫ്ലുവെൻസി',
          icon: Icons.public_rounded,
          color: Color(0xFF10B981),
        ),
      ],
    ),
  };

  /// Fetch track for a given level
  static SyllabusTrack getTrack(LearnerLevel level) {
    return tracks[level] ?? tracks[LearnerLevel.zero]!;
  }

  /// Resolve level from saved preferences or string
  static Future<LearnerLevel> getSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(kPrefsLearnerLevel);
    if (saved != null) {
      for (final lvl in LearnerLevel.values) {
        if (lvl.name.toLowerCase() == saved.toLowerCase()) return lvl;
      }
    }
    // Check old english level text if any
    final oldLevelText = prefs.getString('pm_english_level') ?? '';
    return resolveLevelFromText(oldLevelText);
  }

  /// Save selected level
  static Future<void> saveLevel(LearnerLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefsLearnerLevel, level.name);
    await prefs.setString('pm_english_level', getTrack(level).nameEn);
  }

  /// Heuristic to determine level from diagnostic answers
  static LearnerLevel resolveLevelFromText(String levelString) {
    final lower = levelString.toLowerCase();
    if (lower.contains('zero') ||
        lower.contains('fresh') ||
        lower.contains('starting fresh') ||
        lower.contains('abc') ||
        lower.contains('ഒന്നുമറിയില്ല')) {
      return LearnerLevel.zero;
    } else if (lower.contains('common words') ||
        lower.contains('basic') ||
        lower.contains('വാക്കുകൾ')) {
      return LearnerLevel.beginner;
    } else if (lower.contains('simple conversations') ||
        lower.contains('intermediate') ||
        lower.contains('ഫ്ലുവൻസി')) {
      return LearnerLevel.intermediate;
    } else if (lower.contains('advanced') ||
        lower.contains('fluent') ||
        lower.contains('job')) {
      return LearnerLevel.advanced;
    }
    return LearnerLevel.zero;
  }
}
