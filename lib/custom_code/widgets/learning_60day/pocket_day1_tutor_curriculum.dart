import 'package:flutter/material.dart';
import 'pocket_syllabus_repository.dart';
import 'pocket_90day_vocab_curriculum.dart';
import 'daily_vocab_item.dart';
import 'pocket_master_curriculum_90.dart';
import 'curriculum_data/day_1_curriculum_data.dart';
import 'curriculum_data/pocket_day_curriculum_service.dart';

/// 🎯 3 Clear Syllabus Tracks for Day 1
/// User Directive:
/// - 1. Zero Level — ABC മുതൽ
/// - 2. Middle Level — basic English അറിയാം
/// - 3. Higher Level — English അറിയാം, പക്ഷേ vocabulary + natural communication improve ചെയ്യണം
/// - Main Topic: "ME + BASIC ENGLISH"
/// - 8 Core Steps per track
enum Day1Track {
  zero,
  middle,
  higher;

  static Day1Track fromLevel(LearnerLevel level) {
    switch (level) {
      case LearnerLevel.zero:
        return Day1Track.zero;
      case LearnerLevel.beginner:
      case LearnerLevel.elementary:
      case LearnerLevel.middle:
        return Day1Track.middle;
      case LearnerLevel.advanced:
      case LearnerLevel.expert:
        return Day1Track.higher;
    }
  }

  static Day1Track fromLearnerLevel(LearnerLevel level) => fromLevel(level);

  LearnerLevel toLearnerLevel() {
    switch (this) {
      case Day1Track.zero:
        return LearnerLevel.zero;
      case Day1Track.middle:
        return LearnerLevel.middle;
      case Day1Track.higher:
        return LearnerLevel.advanced;
    }
  }

  String get displayNameEn {
    switch (this) {
      case Day1Track.zero:
        return 'Zero Level (ABC & Phonics)';
      case Day1Track.middle:
        return 'Middle Level (Self Introduction)';
      case Day1Track.higher:
        return 'Higher Level (Natural Communication)';
    }
  }

  String get displayNameMl {
    switch (this) {
      case Day1Track.zero:
        return 'Zero Level (ABC മുതൽ)';
      case Day1Track.middle:
        return 'Middle Level (സ്വന്തം കാര്യം പറയൽ)';
      case Day1Track.higher:
        return 'Higher Level (സ്വാഭാവിക സംഭാഷണം)';
    }
  }

  String get badge {
    switch (this) {
      case Day1Track.zero:
        return '🌱 Zero Level';
      case Day1Track.middle:
        return '💬 Middle Level';
      case Day1Track.higher:
        return '💎 Higher Level';
    }
  }

  Color get color {
    switch (this) {
      case Day1Track.zero:
        return const Color(0xFF10B981);
      case Day1Track.middle:
        return const Color(0xFF38BDF8);
      case Day1Track.higher:
        return const Color(0xFFA855F7);
    }
  }

  String get topicEn {
    switch (this) {
      case Day1Track.zero:
        return 'ME + BASIC ENGLISH';
      case Day1Track.middle:
        return 'SELF INTRODUCTION';
      case Day1Track.higher:
        return 'NATURAL SELF-INTRODUCTION + BETTER VOCABULARY';
    }
  }

  String get topicMl {
    switch (this) {
      case Day1Track.zero:
        return 'ഞാനും അടിസ്ഥാന ഇംഗ്ലീഷും';
      case Day1Track.middle:
        return 'സ്വയം പരിചയപ്പെടുത്തൽ';
      case Day1Track.higher:
        return 'സ്വാഭാവികമായ സ്വയം പരിചയപ്പെടുത്തൽ & മികച്ച പദാവലി';
    }
  }

  String get goalEn {
    switch (this) {
      case Day1Track.zero:
        return 'Learn your first English letters and words';
      case Day1Track.middle:
        return 'I can introduce myself in simple English';
      case Day1Track.higher:
        return 'I can introduce myself naturally and with better English';
    }
  }

  String get goalMl {
    switch (this) {
      case Day1Track.zero:
        return 'ആദ്യത്തെ ഇംഗ്ലീഷ് അക്ഷരങ്ങളും വാക്കുകളും പഠിക്കുക';
      case Day1Track.middle:
        return 'സ്വന്തം കാര്യം ലളിതമായ ഇംഗ്ലീഷിൽ പറയാൻ കഴിയുക';
      case Day1Track.higher:
        return 'കൂടുതൽ സ്വാഭാവികമായും മികച്ച വാക്കുകളോടെയും സംസാരിക്കുക';
    }
  }
}

/// 📋 Model for each of the 9 Core Steps in Day 1 (User Audio Directive: 9 Steps per Day)
class Day1StepModel {
  final int stepNumber; // 1 to 9
  final String titleEn;
  final String titleMl;
  final String icon;
  final String type; // 'enter', 'tutor', 'game_hunt', 'game_match', 'reading', 'vocab', 'chat', 'community_chat', 'defense'
  final String descriptionEn;
  final String descriptionMl;
  final Map<String, dynamic> data;

  const Day1StepModel({
    required this.stepNumber,
    required this.titleEn,
    required this.titleMl,
    required this.icon,
    required this.type,
    required this.descriptionEn,
    required this.descriptionMl,
    required this.data,
  });

  String get title => titleEn;
  String get description => descriptionEn;
  Color get color {
    switch (stepNumber) {
      case 1:
        return const Color(0xFF38BDF8); // Sky blue
      case 2:
        return const Color(0xFF3B82F6); // Royal blue
      case 3:
        return const Color(0xFFF59E0B); // Amber
      case 4:
        return const Color(0xFF10B981); // Emerald
      case 5:
        return const Color(0xFF06B6D4); // Cyan (Reading)
      case 6:
        return const Color(0xFFEC4899); // Pink (Vocab)
      case 7:
        return const Color(0xFF8B5CF6); // Purple (Voice)
      case 8:
        return const Color(0xFF6366F1); // Indigo (Community Chat)
      case 9:
        return const Color(0xFFE11D48); // Crimson Rose (House Defense)
      case 10:
        return const Color(0xFFF59E0B); // Golden Amber (Gate Exam)
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

/// 📖 Model for Day 1 Gamified Reading Challenge
class Day1ReadingPassage {
  final String titleEn;
  final String titleMl;
  final String contentEn;
  final String contentMl;
  final List<String> sentencesEn;
  final List<String> sentencesMl;
  final String questionEn;
  final String questionMl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanationEn;
  final String explanationMl;

  const Day1ReadingPassage({
    required this.titleEn,
    required this.titleMl,
    required this.contentEn,
    required this.contentMl,
    required this.sentencesEn,
    required this.sentencesMl,
    required this.questionEn,
    required this.questionMl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanationEn,
    required this.explanationMl,
  });
}

/// 🛡️ Model for Day 1 House Defense Question
class Day1DefenseQuestion {
  final String questionEn;
  final String questionMl;
  final List<String> options;
  final int correctIndex;
  final String explanationEn;
  final String explanationMl;

  const Day1DefenseQuestion({
    required this.questionEn,
    required this.questionMl,
    required this.options,
    required this.correctIndex,
    required this.explanationEn,
    required this.explanationMl,
  });
}

/// 📚 Model for Day 1 Daily Vocabulary Word
class Day1VocabWord {
  final String word;
  final String phonetic;
  final String emoji;
  final String meaningEn;
  final String meaningMl;
  final String meaningHi;
  final String meaningTa;
  final String exampleEn;
  final String exampleMl;
  final String? contextQuestion;
  final String? contextAnswer;

  const Day1VocabWord({
    required this.word,
    required this.phonetic,
    required this.emoji,
    required this.meaningEn,
    required this.meaningMl,
    this.meaningHi = '',
    this.meaningTa = '',
    required this.exampleEn,
    required this.exampleMl,
    this.contextQuestion,
    this.contextAnswer,
  });

  String getMeaningForLang(String lang) {
    final l = lang.toLowerCase();
    if (l.contains('malay') || l == 'ml') return meaningMl;
    if (l.contains('hind') || l == 'hi') return meaningHi.isNotEmpty ? meaningHi : meaningEn;
    if (l.contains('tamil') || l == 'ta') return meaningTa.isNotEmpty ? meaningTa : meaningEn;
    return meaningEn;
  }
}

/// 🎓 Model for Day 1 Final Exam Question
class Day1ExamQuestion {
  final int index;
  final String questionEn;
  final String questionMl;
  final String type; // 'audio_choice', 'find_object', 'match', 'build', 'listen_word', 'speak_phrase', 'choice', 'fill', 'arrange'
  final String? audioText;
  final List<String> options;
  final dynamic correctAnswer;
  final String explanationEn;
  final String explanationMl;

  const Day1ExamQuestion({
    required this.index,
    required this.questionEn,
    required this.questionMl,
    required this.type,
    this.audioText,
    required this.options,
    required this.correctAnswer,
    required this.explanationEn,
    required this.explanationMl,
  });
}

/// ⚔️ Model for Day 1 Attack & Defense Revision Challenge
class Day1AttackChallenge {
  final String promptEn;
  final String promptMl;
  final String type; // 'find', 'match', 'complete', 'choice'
  final List<String> options;
  final String correctAnswer;
  final String explanationEn;
  final String explanationMl;

  const Day1AttackChallenge({
    required this.promptEn,
    required this.promptMl,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.explanationEn,
    required this.explanationMl,
  });
}

/// 🌟 Central Day 1 Master Curriculum Repository (100% JSON-Driven)
/// User Audio Directive:
/// - Single track! No Expert/Zero distinction anymore.
/// - Pre-check allows skipping Step 1 (Alphabet) & Step 2 (Vocab).
/// - 100% of data (steps, vocab, games, reading, combat, and exam) lives in JSON.
/// - Day 2 can be passed as a matching JSON.
class Day1Curriculum {
  /// 🎙️ Synthesizes a rich, multi-sentence Spoken English Workout (4–6 challenges)
  /// User Audio Directive:
  /// - High priority across all 90 days / levels
  /// - Distinct rich content for Zero, Middle, and Higher levels
  /// - Students & Job-Seeker practical situations, interview Q&As, and everyday speaking drills
  static List<Map<String, dynamic>> synthesizeSpokenWorkoutChallenges({
    required Day1Track track,
    required int day,
    required Map<String, dynamic> dayData,
    Map<String, dynamic>? existingStepData,
  }) {
    // 1. Check if existingStepData already has multiple challenges defined for the active track
    final currentTrackKey = track == Day1Track.zero ? 'zero' : (track == Day1Track.higher ? 'higher' : 'middle');
    final existingTrack = existingStepData?['appliedTrack']?.toString();
    if (existingTrack == currentTrackKey) {
      final existingChallenges = (existingStepData?['challenges'] as List?)?.cast<Map<String, dynamic>>();
      if (existingChallenges != null && existingChallenges.length >= 5) {
        return existingChallenges;
      }
    }

    final voiceTasks = (existingStepData?['voiceTasks'] as Map<String, dynamic>?) ??
        (dayData['steps'] as List?)?.firstWhere(
          (s) => s['id'] == 'step_6_spoken_lab' || s['stepNumber'] == 6,
          orElse: () => const <String, dynamic>{},
        )?['voiceTasks'] as Map<String, dynamic>? ??
        const {};

    final trackKey = currentTrackKey;
    final primaryTask = (voiceTasks[trackKey] ?? voiceTasks['middle'] ?? voiceTasks.values.firstOrNull) as Map<String, dynamic>? ?? const {};
    final primarySentence = primaryTask['targetSentence']?.toString() ?? primaryTask['prompt']?.toString() ?? 'I practice spoken English daily.';
    final primaryPrompt = primaryTask['prompt']?.toString() ?? primarySentence;

    final challengePatterns = (dayData['steps'] as List?)
        ?.firstWhere((s) => s['id'] == 'step_4_game_builder' || s['stepNumber'] == 4, orElse: () => const <String, dynamic>{})?['challengePatterns'] as List? ??
        [];

    final readingSentences = (dayData['steps'] as List?)
        ?.firstWhere((s) => s['id'] == 'step_5_reading_room' || s['stepNumber'] == 5, orElse: () => const <String, dynamic>{})?['sentences'] as List? ??
        [];

    final result = <Map<String, dynamic>>[];
    final dIdx = (day - 1).abs() % 15;

    // 🎯 Challenge 1: Core Daily Focus Target
    result.add({
      'avatarPrompt': "Tutor Maya: 'Listen carefully, then speak today\\'s core focus phrase!'",
      'avatarPromptMl': 'ട്യൂട്ടർ മായ: ഇന്നത്തെ പ്രധാന വാചകം എന്നോടൊപ്പം ഉറക്കെ പറയൂ!',
      'phrase': primarySentence,
      'phonetic': '/$primarySentence/',
      'meaning': {'en': primarySentence, 'ml': primaryPrompt},
      'tag': '🎯 Daily Core Target',
      'tagMl': 'പ്രധാന വാചകം',
    });

    // 🎯 Challenge 2: Track-Specific Conversational / Situational Drill (15 Progressive Scenarios)
    if (track == Day1Track.zero) {
      const zeroConversations = [
        {'avatar': 'Friendly Neighbor', 'prompt': 'Good morning! How are you doing today?', 'ml': 'സുപ്രഭാതം! എങ്ങനെയുണ്ട് ഇന്ന്?', 'phrase': 'Good morning, I am doing fine.', 'meaning': 'സുപ്രഭാതം, എനിക്ക് സുഖമാണ്.', 'tag': '🌱 Basic Greeting'},
        {'avatar': 'Campus Help Desk', 'prompt': 'May I assist you with finding your class?', 'ml': 'ക്ലാസ്സ് കണ്ടെത്താൻ സഹായിക്കണോ?', 'phrase': 'Yes, where is the main library?', 'meaning': 'അതെ, പ്രധാന ലൈബ്രറി എവിടെയാണ്?', 'tag': '🏫 Campus Direction'},
        {'avatar': 'Bus Conductor', 'prompt': 'Which ticket do you need today?', 'ml': 'എങ്ങോട്ടുള്ള ടിക്കറ്റ് വേണം?', 'phrase': 'One ticket to Central Station, please.', 'meaning': 'സെൻട്രൽ സ്റ്റേഷനിലേക്ക് ഒരു ടിക്കറ്റ് തരൂ.', 'tag': '🚌 Public Transit'},
        {'avatar': 'Office Receptionist', 'prompt': 'Hello! Who are you here to meet?', 'ml': 'ഹലോ, ആരെ കാണാനാണ് വന്നത്?', 'phrase': 'I have an appointment with Mr. Roy.', 'meaning': 'എനിക്ക് മിസ്റ്റർ റോയിയുമായി അപ്പോയിന്റ്മെന്റുണ്ട്.', 'tag': '🏢 Office Visitor'},
        {'avatar': 'Cafe Barista', 'prompt': 'What would you like to order today?', 'ml': 'എന്താണ് ഓർഡർ ചെയ്യാൻ ആഗ്രഹിക്കുന്നത്?', 'phrase': 'A hot cup of tea, please.', 'meaning': 'ഒരു ചൂടുള്ള ചായ തരൂ.', 'tag': '☕ Ordering Drink'},
        {'avatar': 'Classmate Rahul', 'prompt': 'Do you have a spare pen with you?', 'ml': 'കയ്യിൽ ഒരു അധിക പേന ഉണ്ടോ?', 'phrase': 'Yes, you can take this pen.', 'meaning': 'അതെ, ഈ പേന എടുത്തോളൂ.', 'tag': '🤝 Helping a Peer'},
        {'avatar': 'Shopkeeper', 'prompt': 'Are you looking for anything specific?', 'ml': 'എന്തെങ്കിലും നോക്കുന്നുണ്ടോ?', 'phrase': 'How much does this book cost?', 'meaning': 'ഈ പുസ്തകത്തിന് എത്ര രൂപയാണ്?', 'tag': '🛍️ Shopping Query'},
        {'avatar': 'HR Assistant', 'prompt': 'Welcome! Did you bring your resume?', 'ml': 'സ്വാഗതം! റെസ്യൂമെ കൊണ്ടുവന്നോ?', 'phrase': 'Yes, here is my updated resume.', 'meaning': 'അതെ, ഇതാണ് എന്റെ റെസ്യൂമെ.', 'tag': '📄 Job Document'},
        {'avatar': 'Trainer Maya', 'prompt': 'Can you tell me about your hobby?', 'ml': 'നിങ്ങളുടെ ഹോബിയെ കുറിച്ച് പറയാമോ?', 'phrase': 'I like reading and learning English.', 'meaning': 'എനിക്ക് വായനയും ഇംഗ്ലീഷ് പഠനവും ഇഷ്ടമാണ്.', 'tag': '🌟 Simple Self-Intro'},
        {'avatar': 'Friend Priya', 'prompt': 'Will you come with us for lunch?', 'ml': 'ഉച്ചഭക്ഷണത്തിന് ഞങ്ങളോടൊപ്പം വരുന്നോ?', 'phrase': 'Yes, I will join you now.', 'meaning': 'അതെ, ഞാനും ഇപ്പോൾ വരാം.', 'tag': '🍽️ Lunch Invitation'},
        {'avatar': 'Doctor Clinic', 'prompt': 'What seems to be the problem today?', 'ml': 'എന്താണ് ബുദ്ധിമുട്ട്?', 'phrase': 'I have a mild fever since yesterday.', 'meaning': 'എനിക്ക് ഇന്നലെ മുതൽ ചെറിയ പനിയുണ്ട്.', 'tag': '🩺 Clinic Visit'},
        {'avatar': 'Interviewer Assistant', 'prompt': 'Please wait here until your name is called.', 'ml': 'പേര് വിളിക്കുന്നത് വരെ ഇവിടെ ഇരിക്കൂ.', 'phrase': 'Sure, thank you for guiding me.', 'meaning': 'ശരി, എന്നെ സഹായിച്ചതിന് നന്ദി.', 'tag': '🎯 Interview Waiting'},
        {'avatar': 'Team Lead', 'prompt': 'Did you understand today\'s task?', 'ml': 'ഇന്നത്തെ ജോലി മനസ്സിലായോ?', 'phrase': 'Yes, I understand what to do.', 'meaning': 'അതെ, എന്താണ് ചെയ്യേണ്ടതെന്ന് മനസ്സിലായി.', 'tag': '💼 Work Clarity'},
        {'avatar': 'Delivery Agent', 'prompt': 'Is this address correct for your parcel?', 'ml': 'ഈ വിലാസം ശരിയാണോ?', 'phrase': 'Yes, that is my correct house address.', 'meaning': 'അതെ, അത് എന്റെ ശരിയായ വീട്ടുപേരാണ്.', 'tag': '📦 Delivery Confirm'},
        {'avatar': 'Teacher Maya', 'prompt': 'You are making steady progress every single day!', 'ml': 'ദിവസവും നിങ്ങൾ മികച്ച പുരോഗതി നേടുന്നുണ്ട്!', 'phrase': 'Thank you, I will keep practicing.', 'meaning': 'നന്ദി, ഞാൻ തുടർന്നും പരിശീലിക്കും.', 'tag': '🔥 Daily Growth'},
      ];
      final item = zeroConversations[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '🌱 Basic Conversation',
        'tagMl': 'സംഭാഷണ പരിശീലനം',
      });
    } else if (track == Day1Track.middle) {
      const middleConversations = [
        {'avatar': 'Classroom Professor', 'prompt': 'Did anyone have a doubt regarding today\'s lecture?', 'ml': 'ക്ലാസിൽ ആർക്കെങ്കിലും സംശയമുണ്ടോ?', 'phrase': 'Could you please explain that concept once more?', 'meaning': 'ഇതൊന്ന് കൂടി വിശദീകരിക്കാമോ?', 'tag': '🎓 Student Campus Drill'},
        {'avatar': 'Campus Placement Head', 'prompt': 'How would you introduce yourself in one concise sentence?', 'ml': 'സ്വയം എങ്ങനെ ഒറ്റ വാചകത്തിൽ പരിചയപ്പെടുത്തും?', 'phrase': 'I am a dedicated graduate eager to build my professional career.', 'meaning': 'ഞാൻ കരിയർ വളർത്തിയെടുക്കാൻ ആഗ്രഹിക്കുന്ന സമർപ്പിതനായ ബിരുദധാരിയാണ്.', 'tag': '🎯 Fresher Self-Pitch'},
        {'avatar': 'Project Guide', 'prompt': 'What is the current status of your final-year module?', 'ml': 'പ്രൊജക്റ്റിന്റെ ഇപ്പോഴത്തെ അവസ്ഥ എന്താണ്?', 'phrase': 'We have finalized the core architecture and are testing edge cases.', 'meaning': 'ഞങ്ങൾ കോർ ആർക്കിടെക്ചർ പൂർത്തിയാക്കി ടെസ്റ്റിംഗ് നടത്തുകയാണ്.', 'tag': '💻 College Project Update'},
        {'avatar': 'HR Manager', 'prompt': 'Why did you choose our company for this role?', 'ml': 'എന്തുകൊണ്ട് ഞങ്ങളുടെ കമ്പനി തിരഞ്ഞെടുത്തു?', 'phrase': 'Your company\'s innovation culture aligns perfectly with my career goals.', 'meaning': 'നിങ്ങളുടെ കമ്പനിയുടെ നൂതന സംസ്കാരം എന്റെ ലക്ഷ്യങ്ങളുമായി പൊരുത്തപ്പെടുന്നു.', 'tag': '💼 HR Round Response'},
        {'avatar': 'GD Moderator', 'prompt': 'The floor is open for candidates to present their arguments.', 'ml': 'അഭിപ്രായങ്ങൾ പറയാൻ സമയം തുറന്നിരിക്കുന്നു.', 'phrase': 'I would like to add an important perspective to this discussion.', 'meaning': 'ഈ ചർച്ചയിലേക്ക് ഒരു പ്രധാന വീക്ഷണം കൂടി ഞാൻ ചേർക്കാൻ ആഗ്രഹിക്കുന്നു.', 'tag': '🗣️ Group Discussion Entry'},
        {'avatar': 'Team Member Ananya', 'prompt': 'Can we schedule a quick call to divide the project tasks?', 'ml': 'പങ്കുവെക്കാൻ ഒരു കോൾ വിളിക്കാമോ?', 'phrase': 'Certainly, let us connect around three in the afternoon.', 'meaning': 'തീർച്ചയായും, ഉച്ചകഴിഞ്ഞ് 3 മണിക്ക് നമുക്ക് കണക്റ്റ് ചെയ്യാം.', 'tag': '📞 Scheduling Collab'},
        {'avatar': 'Department Head', 'prompt': 'Are you comfortable working in rotating shifts or teams?', 'ml': 'ഷിഫ്റ്റുകളിൽ ജോലി ചെയ്യാൻ തയ്യാറാണോ?', 'phrase': 'Yes, I am fully flexible and adapt quickly to team schedules.', 'meaning': 'അതെ, ഞാൻ പൂർണ്ണമായും ഫ്ലെക്സിബിൾ ആണ്, ടീമുമായി പെട്ടെന്ന് പൊരുത്തപ്പെടും.', 'tag': '🏢 Flexibility Q&A'},
        {'avatar': 'Seminar Host', 'prompt': 'Would you like to summarize the key takeaway of your paper?', 'ml': 'പ്രബന്ധത്തിന്റെ പ്രധാന രത്നച്ചുരുക്കം പറയാമോ?', 'phrase': 'In summary, early preparation directly amplifies student confidence.', 'meaning': 'ചുരുക്കത്തിൽ, നേരത്തെയുള്ള തയ്യാറെടുപ്പ് ആത്മവിശ്വാസം ഇരട്ടിയാക്കുന്നു.', 'tag': '🎤 Seminar Summary'},
        {'avatar': 'Tech Lead', 'prompt': 'How do you handle unexpected bugs right before submission?', 'ml': 'സമർപ്പണത്തിന് തൊട്ടുമുൻപ് വരുന്ന പ്രശ്നങ്ങൾ എങ്ങനെ പരിഹരിക്കും?', 'phrase': 'I stay calm, isolate the root cause, and apply systematic fixes.', 'meaning': 'ഞാൻ പ്രശ്നത്തിന്റെ യഥാർത്ഥ കാരണം കണ്ടെത്തി ശാന്തമായി പരിഹരിക്കുന്നു.', 'tag': '⚡ Problem Solving Q&A'},
        {'avatar': 'Client Liaison', 'prompt': 'Could you brief us on the client feedback from yesterday?', 'ml': 'ഇന്നലത്തെ ക്ലയന്റ് പ്രതികരണം എങ്ങനെയായിരുന്നു?', 'phrase': 'The client appreciated our speed and requested one minor adjustment.', 'meaning': 'ക്ലയന്റ് നമ്മുടെ വേഗതയെ അഭിനന്ദിക്കുകയും ചെറിയ മാറ്റം ആവശ്യപ്പെടുകയും ചെയ്തു.', 'tag': '📊 Client Follow-up'},
        {'avatar': 'Interviewer John', 'prompt': 'What would you say is your greatest professional strength?', 'ml': 'നിങ്ങളുടെ ഏറ്റവും വലിയ പ്രൊഫഷണൽ ശക്തി എന്താണ്?', 'phrase': 'My biggest strength is my quick learning ability and consistency.', 'meaning': 'എന്റെ ഏറ്റവും വലിയ ശക്തി വേഗത്തിൽ കാര്യങ്ങൾ പഠിക്കാനുള്ള കഴിവും സ്ഥിരതയുമാണ്.', 'tag': '🌟 Strength Analysis'},
        {'avatar': 'Peer Collaborator', 'prompt': 'I have a different view on this design proposal.', 'ml': 'എനിക്ക് ഈ പ്രൊപ്പോസലിൽ മറ്റൊരു അഭിപ്രായമുണ്ട്.', 'phrase': 'I appreciate your input, let us compare both alternatives objectively.', 'meaning': 'നിങ്ങളുടെ അഭിപ്രായത്തെ ഞാൻ മാനിക്കുന്നു, രണ്ട് വഴികളും താരതമ്യം ചെയ്യാം.', 'tag': '🤝 Constructive Debate'},
        {'avatar': 'Recruiter Pooja', 'prompt': 'What are your salary and joining expectations?', 'ml': 'പ്രതീക്ഷിക്കുന്ന ശമ്പളവും ജോയിനിംഗ് തീയതിയും?', 'phrase': 'I am open to industry-standard compensation for this position.', 'meaning': 'ഈ തസ്തികയ്ക്ക് അനുയോജ്യമായ നിലവാരമുള്ള ശമ്പളം ഞാൻ പ്രതീക്ഷിക്കുന്നു.', 'tag': '💼 Offer Discussion'},
        {'avatar': 'Placement Officer', 'prompt': 'Remember to maintain solid posture and eye contact today.', 'ml': 'ശരിയായ പോസ്റ്ററും ഐ-കോണ്ടാക്റ്റും ഉറപ്പാക്കൂ.', 'phrase': 'Thank you for the guidance, I will give my absolute best.', 'meaning': 'നിർദ്ദേശങ്ങൾക്ക് നന്ദി, ഞാൻ എന്റെ ഏറ്റവും മികച്ച പ്രകടനം കാഴ്ചവെക്കും.', 'tag': '🎯 Placement Motivation'},
        {'avatar': 'Maya Tutor', 'prompt': 'You have developed remarkable fluency and natural cadence!', 'ml': 'നിങ്ങൾക്ക് അത്ഭുതകരമായ ഫ്ലുവെൻസി കൈവന്നിരിക്കുന്നു!', 'phrase': 'Consistent daily practice has truly transformed my spoken English.', 'meaning': 'ദിവസേനയുള്ള ചിട്ടയായ പരിശീലനം എന്റെ ഇംഗ്ലീഷ് സംസാരത്തെ മാറ്റിമറിച്ചു.', 'tag': '🏆 Fluency Transformation'},
      ];
      final item = middleConversations[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '🎓 Campus & Career Drill',
        'tagMl': 'ക്ലാസ്റൂം & ഇന്റർവ്യൂ',
      });
    } else {
      const higherConversations = [
        {'avatar': 'Managing Director', 'prompt': 'How will your team safeguard our strategic milestones this quarter?', 'ml': 'ഈ ക്വാർട്ടറിലെ ലക്ഷ്യങ്ങൾ ടീം എങ്ങനെ കൈവരിക്കും?', 'phrase': 'In my perspective, this strategy will drive immediate measurable results.', 'meaning': 'എന്റെ കാഴ്ചപ്പാടിൽ, ഈ രീതി അളക്കാവുന്ന മികച്ച ഫലം ഉടനടി തരും.', 'tag': '💼 Executive Strategy Pitch'},
        {'avatar': 'Executive Panel Chair', 'prompt': 'Walk us through a high-stakes crisis you navigated in the past.', 'ml': 'മുൻപ് നേരിട്ട ഒരു വലിയ പ്രതിസന്ധിയെക്കുറിച്ച് പറയൂ.', 'phrase': 'When faced with an unexpected outage, I prioritized critical customer flows first.', 'meaning': 'പ്രതിസന്ധി ഘട്ടത്തിൽ ഏറ്റവും നിർണ്ണായകമായ സേവനങ്ങൾക്കാണ് ഞാൻ മുൻഗണന നൽകിയത് (STAR).', 'tag': '🎯 STAR Method: Crisis Resolution'},
        {'avatar': 'Global Stakeholder', 'prompt': 'What is your justification for increasing capital expenditure here?', 'ml': 'ഈ ചെലവ് വർദ്ധിപ്പിക്കുന്നതിനുള്ള ന്യായീകരണം എന്താണ്?', 'phrase': 'The projected return on investment substantially outweighs short-term overhead.', 'meaning': 'പ്രതീക്ഷിക്കുന്ന ലാഭവിഹിതം ഹ്രസ്വകാല ചെലവുകളേക്കാൾ വളരെ കൂടുതലാണ്.', 'tag': '📈 ROI & Business Case'},
        {'avatar': 'Cross-Functional Lead', 'prompt': 'Our engineering and product timelines appear to be misaligned.', 'ml': 'ടൈംലൈനുകൾ തമ്മിൽ വ്യത്യാസങ്ങൾ കാണുന്നുണ്ട്.', 'phrase': 'Let us align on shared deliverables to preserve our release trajectory.', 'meaning': 'റിലീസ് സമയം കൃത്യമാക്കാൻ നമുക്ക് ഒരുമിച്ച് മുൻഗണനകൾ നിശ്ചയിക്കാം.', 'tag': '🤝 Cross-Functional Synergy'},
        {'avatar': 'Talent Director', 'prompt': 'Why are you the ideal executive to lead this global initiative?', 'ml': 'ഈ പദ്ധതി നയിക്കാൻ നിങ്ങളാണ് ഏറ്റവും അനുയോജ്യൻ എന്ന് എന്തുകൊണ്ട് കരുതുന്നു?', 'phrase': 'I have a proven track record of solving complex problems efficiently.', 'meaning': 'സങ്കീർണ്ണമായ പ്രശ്നങ്ങൾ കാര്യക്ഷമമായി പരിഹരിച്ച ശക്തമായ മുൻപരിചയം എനിക്കുണ്ട്.', 'tag': '🏆 Executive Candidate Pitch'},
        {'avatar': 'Venture Partner', 'prompt': 'How scalable is your operational model over the next eighteen months?', 'ml': 'അടുത്ത 18 മാസത്തേക്ക് ബിസിനസ്സ് സ്കെയിൽ ചെയ്യാൻ സാധിക്കുമോ?', 'phrase': 'Our modular framework is designed to scale horizontally with zero downtime.', 'meaning': 'തടസ്സങ്ങളില്ലാതെ ബിസിനസ്സ് വ്യാപിപ്പിക്കാൻ പാകത്തിലാണ് നമ്മുടെ സിസ്റ്റം രൂപകൽപ്പന ചെയ്തിരിക്കുന്നത്.', 'tag': '🚀 Scalability & Architecture'},
        {'avatar': 'Client Executive', 'prompt': 'We are considering alternate vendors due to contract pricing concerns.', 'ml': 'വില കാരണം ഞങ്ങൾ മറ്റ് വെണ്ടർമാരെ ആലോചിക്കുന്നു.', 'phrase': 'Our value proposition delivers unmatched reliability and dedicated technical support.', 'meaning': 'നമ്മുടെ സേവനം നൽകുന്ന വിശ്വസനീയതയും സപ്പോർട്ടും മറ്റൊരു വെണ്ടർക്കും നൽകാനാവില്ല.', 'tag': '🤝 Client Retention Pitch'},
        {'avatar': 'Chief Operating Officer', 'prompt': 'How do you foster psychological safety across distributed teams?', 'ml': 'വിവിധ ടീമുകളിൽ സുരക്ഷിതമായ അന്തരീക്ഷം എങ്ങനെ ഉറപ്പാക്കുന്നു?', 'phrase': 'I encourage open critique while ensuring full accountability for outcomes.', 'meaning': 'തുറന്ന ചർച്ചകളെ പ്രോത്സാഹിപ്പിക്കുമ്പോൾ തന്നെ ഉത്തരവാദിത്തം ഉറപ്പാക്കാൻ ഞാൻ ശ്രദ്ധിക്കുന്നു.', 'tag': '👑 Leadership Philosophy'},
        {'avatar': 'Senior Vice President', 'prompt': 'What trade-offs did you make to deliver ahead of the quarter end?', 'ml': 'സമയത്തിന് മുൻപ് ഡെലിവറി ചെയ്യാൻ എന്ത് വിട്ടുവീഴ്ചകൾ ചെയ്തു?', 'phrase': 'We scoped down secondary enhancements without compromising system integrity.', 'meaning': 'പ്രധാന സുരക്ഷ വിട്ടുവീഴ്ച ചെയ്യാതെ ചെറിയ ഫീച്ചറുകൾ അടുത്ത ഘട്ടത്തിലേക്ക് മാറ്റി.', 'tag': '⚖️ Strategic Trade-offs'},
        {'avatar': 'Negotiation Counterpart', 'prompt': 'We cannot concede on these service-level agreement benchmarks.', 'ml': 'ഈ നിബന്ധനകളിൽ വിട്ടുവീഴ്ച ചെയ്യാൻ കഴിയില്ല.', 'phrase': 'We can agree to these metrics provided escalation protocols are streamlined.', 'meaning': 'സഹകരണ വ്യവസ്ഥകൾ സുതാര്യമാക്കിയാൽ ഈ നിബന്ധനകൾ ഞങ്ങൾ അംഗീകരിക്കാം.', 'tag': '🤝 High-Stakes Negotiation'},
        {'avatar': 'Board Member', 'prompt': 'What is the biggest operational risk confronting our enterprise?', 'ml': 'സ്ഥാപനം നേരിടുന്ന ഏറ്റവും വലിയ റിസ്ക് എന്താണ്?', 'phrase': 'Technological obsolescence and cybersecurity latency require proactive mitigation.', 'meaning': 'സാങ്കേതിക മാറ്റങ്ങളും സൈബർ സുരക്ഷാ വെല്ലുവിളികളും മുൻകൂട്ടി തടയേണ്ടതുണ്ട്.', 'tag': '🛡️ Enterprise Risk Assessment'},
        {'avatar': 'Hiring Committee', 'prompt': 'Describe a scenario where you convinced skeptical leadership.', 'ml': 'നേതൃത്വത്തെ തെളിവുകൾ നിരത്തി ബോധ്യപ്പെടുത്തിയ അനുഭവം പറയൂ.', 'phrase': 'I leveraged empirical performance data to build unanimous stakeholder consensus.', 'meaning': 'കൃത്യമായ തെളിവുകളും ഡാറ്റയും നിരത്തിയാണ് ഞാൻ മാനേജ്‌മെന്റിനെ ബോധ്യപ്പെടുത്തിയത്.', 'tag': '📊 Influence with Data'},
        {'avatar': 'Product Architect', 'prompt': 'Should we proceed with the refactor or push user-facing features?', 'ml': 'റിഫാക്ടറിംഗ് ചെയ്യണോ പുതിയ ഫീച്ചറുകൾ നൽകണോ?', 'phrase': 'Stabilizing technical debt now accelerates our long-term delivery velocity.', 'meaning': 'ഇപ്പോൾ ടെക്നിക്കൽ പ്രശ്നങ്ങൾ പരിഹരിക്കുന്നത് ഭാവിയിലെ വളർച്ചയെ ത്വരിതപ്പെടുത്തും.', 'tag': '⚡ Technical Vision'},
        {'avatar': 'Keynote Moderator', 'prompt': 'What message would you leave with young leaders aspiring for impact?', 'ml': 'യുവ നേതാക്കൾക്ക് നൽകാനുള്ള സന്ദേശം എന്താണ്?', 'phrase': 'Clarity of thought and authentic communication are the cornerstones of influence.', 'meaning': 'ചിന്തയിലെ വ്യക്തതയും ആത്മാർത്ഥമായ ആശയവിനിമയവുമാണ് സ്വാധീനത്തിന്റെ അടിസ്ഥാനം.', 'tag': '🎤 Keynote Address'},
        {'avatar': 'Grandmaster Mentor', 'prompt': 'You possess sovereign executive presence and command over English!', 'ml': 'നിങ്ങൾക്ക് അതിശക്തമായ എക്സിക്യൂട്ടീവ് പ്രസൻസും ഭാഷാ പ്രാവീണ്യവുമുണ്ട്!', 'phrase': 'I communicate with precision, authority, and empathy across all global stages.', 'meaning': 'ഏത് ആഗോള വേദിയിലും കൃത്യതയോടും അധികാരത്തോടും സഹാനുഭൂതിയോടും ഞാൻ സംസാരിക്കുന്നു.', 'tag': '👑 Sovereign Leadership'},
      ];
      final item = higherConversations[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '💼 Executive Corporate Pitch',
        'tagMl': 'എക്സിക്യൂട്ടീവ് പ്രസന്റേഷൻ',
      });
    }

    // 🎯 Challenge 3: Fast Reflex Sentence Constructor Pattern (Step 4 Pattern)
    if (challengePatterns.isNotEmpty) {
      final pat = challengePatterns.first.toString().replaceAll('"', '').trim();
      result.add({
        'avatarPrompt': "Study Partner Alex: 'Can you say this assembled phrase with zero hesitation?'",
        'avatarPromptMl': 'സ്റ്റഡി പാർട്ണർ അലക്സ്: തടസ്സമില്ലാതെ ഈ വാചകം വേഗത്തിൽ പറയൂ:',
        'phrase': pat,
        'phonetic': '/$pat/',
        'meaning': {'en': pat, 'ml': 'വേഗത്തിൽ പറഞ്ഞു ശീലിക്കുക.'},
        'tag': '⚡ Sentence Reflex Drill',
        'tagMl': 'വാചക നിർമ്മാണം',
      });
    } else if (readingSentences.isNotEmpty) {
      final r1 = readingSentences.first;
      final text = (r1 is Map ? r1['text']?.toString() : r1.toString()) ?? primarySentence;
      final ml = (r1 is Map ? r1['meaningMl']?.toString() : '') ?? '';
      result.add({
        'avatarPrompt': "Tutor Maya: 'Shadow read this sentence after me with natural cadence!'",
        'avatarPromptMl': 'ട്യൂട്ടർ മായ: എന്റെ ഒപ്പം അതേ താളത്തിൽ വായിക്കൂ:',
        'phrase': text,
        'phonetic': '/$text/',
        'meaning': {'en': text, 'ml': ml.isNotEmpty ? ml : text},
        'tag': '📖 Fluency Shadowing',
        'tagMl': 'ഫ്ലുവെൻസി ഷാഡോയിംഗ്',
      });
    } else {
      final reflexFallback = track == Day1Track.zero
          ? 'I can speak simple English words.'
          : (track == Day1Track.middle
              ? 'I can express my thoughts clearly and fluently.'
              : 'I articulate complex strategies with authority and clarity.');
      final reflexMl = track == Day1Track.zero
          ? 'എനിക്ക് ലളിതമായ ഇംഗ്ലീഷ് വാക്കുകൾ പറയാൻ സാധിക്കും.'
          : (track == Day1Track.middle
              ? 'എന്റെ ചിന്തകൾ വ്യക്തമായി പ്രകടിപ്പിക്കാൻ എനിക്ക് സാധിക്കും.'
              : 'സങ്കീർണ്ണമായ ആശയങ്ങൾ ആത്മവിശ്വാസത്തോടെ ഞാൻ വ്യക്തമാക്കുന്നു.');
      result.add({
        'avatarPrompt': "Study Partner Alex: 'Fast tongue reflex! Speak this line with zero hesitation:'",
        'avatarPromptMl': 'സ്റ്റഡി പാർട്ണർ അലക്സ്: തടസ്സമില്ലാതെ ഈ വാചകം വേഗത്തിൽ പറയൂ:',
        'phrase': reflexFallback,
        'phonetic': '/$reflexFallback/',
        'meaning': {'en': reflexFallback, 'ml': reflexMl},
        'tag': '⚡ Tongue Reflex Drill',
        'tagMl': 'സംസാര വേഗത',
      });
    }

    // 🎯 Challenge 4: Career / Job Interview Practical Placement Drill (15 Progressive Scenarios)
    if (track == Day1Track.zero) {
      const zeroInterviewDrills = [
        {'avatar': 'HR Assistant', 'prompt': 'Can you tell me your name and qualification?', 'ml': 'നിങ്ങളുടെ പേരും യോഗ്യതയും പറയാമോ?', 'phrase': 'My name is Rahul and I am a graduate.', 'meaning': 'എന്റെ പേര് രാഹുൽ, ഞാൻ ഒരു ഗ്രാജ്വേറ്റ് ആണ്.', 'tag': '📄 Simple Interview Intro'},
        {'avatar': 'Store Manager', 'prompt': 'What hours are you available to work?', 'ml': 'ഏതൊക്കെ സമയങ്ങളിൽ ജോലി ചെയ്യാൻ സാധിക്കും?', 'phrase': 'I am available to work full time.', 'meaning': 'എനിക്ക് ഫുൾ ടൈം ജോലി ചെയ്യാൻ സാധിക്കും.', 'tag': '⏰ Availability Drill'},
        {'avatar': 'Team Supervisor', 'prompt': 'Can you operate a computer and send emails?', 'ml': 'കമ്പ്യൂട്ടറും ഇമെയിലും ഉപയോഗിക്കാൻ അറിയാമോ?', 'phrase': 'Yes, I know how to use a computer.', 'meaning': 'അതെ, എനിക്ക് കമ്പ്യൂട്ടർ ഉപയോഗിക്കാൻ അറിയാം.', 'tag': '💻 Basic Computer Skill'},
        {'avatar': 'Office Admin', 'prompt': 'When can you join our organization?', 'ml': 'എപ്പോൾ ജോലിയിൽ പ്രവേശിക്കാം?', 'phrase': 'I can join starting tomorrow.', 'meaning': 'എനിക്ക് നാളെ മുതൽ ജോലിയിൽ പ്രവേശിക്കാം.', 'tag': '🗓️ Joining Date'},
        {'avatar': 'Senior Colleague', 'prompt': 'Do you need help with this form?', 'ml': 'ഫോം പൂരിപ്പിക്കാൻ സഹായം വേണോ?', 'phrase': 'Yes, please show me how to fill this.', 'meaning': 'അതെ, ഇത് എങ്ങനെ പൂരിപ്പിക്കണമെന്ന് കാണിച്ചുതരൂ.', 'tag': '📝 Form Filling'},
        {'avatar': 'Trainer Maya', 'prompt': 'Tell me one thing you like about this job.', 'ml': 'ഈ ജോലിയിൽ ഏറ്റവും ഇഷ്ടപ്പെട്ട കാര്യം എന്താണ്?', 'phrase': 'I want to learn new skills here.', 'meaning': 'എനിക്ക് ഇവിടെ പുതിയ കാര്യങ്ങൾ പഠിക്കണം.', 'tag': '🌟 Learning Motivation'},
        {'avatar': 'Front Desk Officer', 'prompt': 'Please sign your name in the visitor book.', 'ml': 'വിസിറ്റർ ബുക്കിൽ പേര് ഒപ്പിടൂ.', 'phrase': 'Sure, where should I sign?', 'meaning': 'തീർച്ചയായും, എവിടെയാണ് ഒപ്പിടേണ്ടത്?', 'tag': '✍️ Workplace Signature'},
        {'avatar': 'Team Leader', 'prompt': 'Can you work with our other team members?', 'ml': 'മറ്റ് അംഗങ്ങളോടൊപ്പം ഒത്തുപ്രവർത്തിക്കാമോ?', 'phrase': 'Yes, I enjoy working in a team.', 'meaning': 'അതെ, എനിക്ക് ടീമായി പ്രവർത്തിക്കാൻ ഇഷ്ടമാണ്.', 'tag': '🤝 Team Player Basic'},
        {'avatar': 'Manager Anil', 'prompt': 'How will you travel to the office daily?', 'ml': 'ഓഫീസിലേക്ക് എങ്ങനെയാണ് യാത്ര ചെയ്യുന്നത്?', 'phrase': 'I will come by bus every day.', 'meaning': 'ഞാൻ ദിവസവും ബസ്സിൽ വരും.', 'tag': '🚌 Commute Answer'},
        {'avatar': 'Customer Service Lead', 'prompt': 'How do you greet an incoming customer?', 'ml': 'വരുന്ന കസ്റ്റമറെ എങ്ങനെ അഭിവാദ്യം ചെയ്യും?', 'phrase': 'Good morning, how can I help you today?', 'meaning': 'സുപ്രഭാതം, ഇന്ന് ഞാൻ എങ്ങനെ സഹായിക്കണം?', 'tag': '🤝 Customer Greeting'},
        {'avatar': 'Interview Panel', 'prompt': 'Why do you want this entry-level job?', 'ml': 'എന്തുകൊണ്ട് ഈ ജോലി ആഗ്രഹിക്കുന്നു?', 'phrase': 'I want to work hard and support my family.', 'meaning': 'കഠിനാധ്വാനം ചെയ്ത് കുടുംബത്തെ സഹായിക്കാൻ ഞാൻ ആഗ്രഹിക്കുന്നു.', 'tag': '💼 Work Intent'},
        {'avatar': 'Office Manager', 'prompt': 'Do you have any questions for us today?', 'ml': 'ഞങ്ങളോട് എന്തെങ്കിലും ചോദിക്കാനുണ്ടോ?', 'phrase': 'What are the daily working hours?', 'meaning': 'ദിവസേനയുള്ള ജോലി സമയം എത്രയാണ്?', 'tag': '❓ Asking Work Hours'},
        {'avatar': 'HR Coordinator', 'prompt': 'We will email you your confirmation letter.', 'ml': 'സ്ഥിരീകരണ കത്ത് ഇമെയിലിൽ അയക്കാം.', 'phrase': 'Thank you, I will check my email.', 'meaning': 'നന്ദി, ഞാൻ എന്റെ ഇമെയിൽ പരിശോധിക്കാം.', 'tag': '📧 Email Acknowledgment'},
        {'avatar': 'Mentor Deepa', 'prompt': 'Are you ready for your practical training?', 'ml': 'പ്രാക്ടിക്കൽ ട്രെയിനിംഗിന് തയ്യാറാണോ?', 'phrase': 'Yes, I am excited and ready to learn.', 'meaning': 'അതെ, ഞാൻ പഠിക്കാൻ തയ്യാറാണ്.', 'tag': '🔥 Training Readiness'},
        {'avatar': 'Director Roy', 'prompt': 'Welcome aboard to our company team!', 'ml': 'ഞങ്ങളുടെ കമ്പനി ടീമിലേക്ക് സ്വാഗതം!', 'phrase': 'Thank you very much for this wonderful opportunity.', 'meaning': 'ഈ മികച്ച അവസരത്തിന് വളരെ നന്ദി.', 'tag': '🎉 Welcome Onboarding'},
      ];
      final item = zeroInterviewDrills[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '💼 Entry Job Drill',
        'tagMl': 'തൊഴിൽ സംഭാഷണം',
      });
    } else if (track == Day1Track.middle) {
      const middleInterviewDrills = [
        {'avatar': 'Campus Placement Head', 'prompt': 'Walk me through your educational background.', 'ml': 'വിദ്യാഭ്യാസ പശ്ചാത്തലം വിശദീകരിക്കാമോ?', 'phrase': 'I recently graduated with a degree in science and technology.', 'meaning': 'ഞാൻ അടുത്തിടെ സയൻസ് & ടെക്നോളജിയിൽ ബിരുദം പൂർത്തിയാക്കി.', 'tag': '🎓 Degree & Education'},
        {'avatar': 'Technical Recruiter', 'prompt': 'What technical or practical tools are you proficient in?', 'ml': 'ഏതൊക്കെ സാങ്കേതിക വിദ്യകളിലാണ് പ്രാവീണ്യമുള്ളത്?', 'phrase': 'I am proficient in problem solving and core programming tools.', 'meaning': 'പ്രശ്നപരിഹാരത്തിലും അടിസ്ഥാന പ്രോഗ്രാമിംഗിലും എനിക്ക് നല്ല പ്രാവീണ്യമുണ്ട്.', 'tag': '💻 Technical Competency'},
        {'avatar': 'HR Panelist', 'prompt': 'How do you prioritize your time during semester exams?', 'ml': 'പരീക്ഷാ സമയത്ത് സമയം എങ്ങനെ ക്രമീകരിക്കുന്നു?', 'phrase': 'I prepare structured study schedules and stick to deadlines.', 'meaning': 'ഞാൻ കൃത്യമായ ടൈംടേബിൾ തയ്യാറാക്കി സമയപരിധി പാലിക്കുന്നു.', 'tag': '⏰ Time Management'},
        {'avatar': 'Group Discussion Lead', 'prompt': 'Do you agree that practical experience beats rote learning?', 'ml': 'പ്രായോഗിക പരിചയമാണോ കാണാപാഠം പഠിക്കുന്നതിനേക്കാൾ നല്ലത്?', 'phrase': 'Hands-on experience provides practical insights that textbooks cannot teach.', 'meaning': 'പ്രായോഗിക പരിചയം പുസ്തകങ്ങൾക്ക് നൽകാൻ കഴിയാത്ത ഉൾക്കാഴ്ച നൽകുന്നു.', 'tag': '🗣️ GD Persuasion'},
        {'avatar': 'Internship Manager', 'prompt': 'What was your primary responsibility during your internship?', 'ml': 'ഇന്റേൺഷിപ്പ് കാലയളവിലെ പ്രധാന ചുമതല എന്തായിരുന്നു?', 'phrase': 'I collaborated with the senior team to streamline data entry.', 'meaning': 'ഡാറ്റ ശേഖരണം കാര്യക്ഷമമാക്കാൻ ഞാൻ സീനിയർ ടീമിനൊപ്പം പ്രവർത്തിച്ചു.', 'tag': '💼 Internship Role'},
        {'avatar': 'College Dean', 'prompt': 'How do you handle constructive criticism on your project?', 'ml': 'പ്രൊജക്റ്റിലെ വിമർശനങ്ങളെ എങ്ങനെ സ്വീകരിക്കുന്നു?', 'phrase': 'I treat constructive feedback as a stepping stone to excellence.', 'meaning': 'വിമർശനങ്ങളെ കൂടുതൽ മികച്ചതാകാനുള്ള അവസരമായി ഞാൻ കാണുന്നു.', 'tag': '📈 Growth Mindset'},
        {'avatar': 'Hiring Manager Vikram', 'prompt': 'Where do you see yourself in the next three years?', 'ml': 'അടുത്ത മൂന്ന് വർഷത്തിൽ താങ്കളെ എവിടെ കാണുന്നു?', 'phrase': 'I aim to grow into a dependable domain specialist in this field.', 'meaning': 'അടുത്ത മൂന്ന് വർഷത്തിനുള്ളിൽ ഈ മേഖലയിലെ വിദഗ്ദ്ധനാകാൻ ഞാൻ ലക്ഷ്യമിടുന്നു.', 'tag': '🎯 Career Vision'},
        {'avatar': 'Tech Interviewer', 'prompt': 'Can you explain the main challenge in your capstone project?', 'ml': 'പ്രൊജക്റ്റിലെ പ്രധാന വെല്ലുവിളി എന്തായിരുന്നു?', 'phrase': 'Our primary hurdle was data latency, which we resolved by caching.', 'meaning': 'പ്രധാന വെല്ലുവിളി ഡാറ്റാ വേഗതയായിരുന്നു, അത് കാഷിംഗ് വഴി ഞങ്ങൾ പരിഹരിച്ചു.', 'tag': '🛠️ Project Deep-Dive'},
        {'avatar': 'HR Lead Meera', 'prompt': 'Are you willing to relocate to a different metropolitan branch?', 'ml': 'മറ്റൊരു നഗരത്തിലേക്ക് മാറാൻ തയ്യാറാണോ?', 'phrase': 'Yes, I am enthusiastic about exploring new cities and cultures.', 'meaning': 'അതെ, പുതിയ നഗരങ്ങളിലേക്ക് മാറാൻ എനിക്ക് പൂർണ്ണ സന്തോഷമേയുള്ളൂ.', 'tag': '🌍 Relocation Flexibility'},
        {'avatar': 'Client Project Lead', 'prompt': 'How do you communicate complex ideas to non-technical users?', 'ml': 'സാങ്കേതിക കാര്യങ്ങൾ സാധാരണക്കാരോട് എങ്ങനെ പറയും?', 'phrase': 'I break down technical terms into relatable real-world analogies.', 'meaning': 'സാങ്കേതിക പദങ്ങളെ ലളിതമായ ഉദാഹരണങ്ങളിലൂടെ ഞാൻ വിശദീകരിക്കുന്നു.', 'tag': '💡 Clear Articulation'},
        {'avatar': 'Placement Trainer', 'prompt': 'What distinguishes you from other shortlisted candidates?', 'ml': 'മറ്റുള്ളവരിൽ നിന്ന് താങ്കളെ വ്യത്യസ്തനാക്കുന്നത് എന്താണ്?', 'phrase': 'My blend of strong discipline and quick adaptability sets me apart.', 'meaning': 'എന്റെ അച്ചടക്കവും പെട്ടെന്ന് പഠിക്കാനുള്ള കഴിവും എന്നെ വ്യത്യസ്തനാക്കുന്നു.', 'tag': '🌟 Candidate Differentiation'},
        {'avatar': 'Seminar Chairperson', 'prompt': 'Any concluding remarks for our campus delegation?', 'ml': 'സെമിനാറിന് ഉപസംഹാരമായി എന്താണ് പറയാനുള്ളത്?', 'phrase': 'Consistent effort and clear communication unlock unlimited doors.', 'meaning': 'നിരന്തരമായ പരിശ്രമവും നല്ല സംഭാഷണവും അനന്തമായ അവസരങ്ങൾ തുറന്നുതരുന്നു.', 'tag': '🎤 Campus Concluding Words'},
        {'avatar': 'HR Business Partner', 'prompt': 'How do you maintain high energy across intense work days?', 'ml': 'ജോലിഭാരമുള്ള ദിവസങ്ങളിൽ ഊർജ്ജം എങ്ങനെ നിലനിർത്തുന്നു?', 'phrase': 'I stay motivated by focusing on milestone accomplishments.', 'meaning': 'ഓരോ ഘട്ടങ്ങളും വിജയകരമായി പൂർത്തിയാക്കി ഞാൻ ആവേശം നിലനിർത്തുന്നു.', 'tag': '⚡ Motivation & Stamina'},
        {'avatar': 'Team Lead Karthik', 'prompt': 'How will you collaborate with teammates from different states?', 'ml': 'മറ്റ് സംസ്ഥാനങ്ങളിലുള്ള ടീമംഗങ്ങളുമായി എങ്ങനെ ഒത്തുപ്രവർത്തിക്കും?', 'phrase': 'English enables seamless teamwork and bridge-building across diverse groups.', 'meaning': 'വിവിധ സംസ്കാരങ്ങളിലുള്ള സഹപ്രവർത്തകരുമായി ഒത്തുപ്രവർത്തിക്കാൻ ഇംഗ്ലീഷ് സഹായിക്കുന്നു.', 'tag': '🤝 Cross-Culture Collaboration'},
        {'avatar': 'Senior Interviewer', 'prompt': 'Congratulations, your communication skills are thoroughly impressive!', 'ml': 'അഭിനന്ദനങ്ങൾ, നിങ്ങളുടെ ആശയവിനിമയ മികവ് മികച്ചതാണ്!', 'phrase': 'Thank you, I am thrilled to contribute my best to the team.', 'meaning': 'വളരെ നന്ദി, ടീമിന് എന്റെ ഏറ്റവും മികച്ച സംഭാവന നൽകാൻ ഞാൻ ആവേശഭരിതനാണ്.', 'tag': '🏆 Interview Success'},
      ];
      final item = middleInterviewDrills[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '🎯 Campus Placement Q&A',
        'tagMl': 'ക്യാമ്പസ് ഇന്റർവ്യൂ',
      });
    } else {
      const higherInterviewDrills = [
        {'avatar': 'Executive Hiring Panel', 'prompt': 'Describe a Situation where you turned around an underperforming initiative (STAR - S).', 'ml': 'പ്രതീക്ഷിച്ച ഫലം കിട്ടാത്ത പ്രൊജക്റ്റ് വിജയകരമാക്കിയ സാഹചര്യം വിവരിക്കൂ (STAR).', 'phrase': 'When project velocity dropped by thirty percent, I audited our delivery pipeline.', 'meaning': 'പ്രൊജക്റ്റ് വേഗത 30% കുറഞ്ഞപ്പോൾ, ഞാൻ ഡെലിവറി പ്രക്രിയ നേരിട്ട് പരിശോധിച്ചു (STAR - S).', 'tag': '🎯 STAR Method: Situation'},
        {'avatar': 'Chief Technology Officer', 'prompt': 'What Task did you undertake to restore stakeholder confidence? (STAR - T)', 'ml': 'വിശ്വാസം വീണ്ടെടുക്കാൻ എന്തായിരുന്നു നിങ്ങളുടെ പ്രധാന ചുമതല?', 'phrase': 'My core objective was re-establishing transparent milestone reporting.', 'meaning': 'സുതാര്യമായ റിപ്പോർട്ടിംഗ് പുനഃസ്ഥാപിക്കുക എന്നതായിരുന്നു എന്റെ പ്രധാന ചുമതല (STAR - T).', 'tag': '🎯 STAR Method: Task'},
        {'avatar': 'Board Chairman', 'prompt': 'What decisive Action did you execute under that pressure? (STAR - A)', 'ml': 'ആ സമ്മർദ്ദത്തിൽ എന്ത് ശക്തമായ നടപടിയാണ് എടുത്തത്?', 'phrase': 'I reallocated high-priority engineering pods and streamlined daily standups.', 'meaning': 'ഞാൻ പ്രധാന എഞ്ചിനീയറിംഗ് ടീമുകളെ പുനഃക്രമീകരിക്കുകയും മീറ്റിംഗുകൾ കാര്യക്ഷമമാക്കുകയും ചെയ്തു (STAR - A).', 'tag': '🎯 STAR Method: Action'},
        {'avatar': 'Senior Partner', 'prompt': 'What was the quantifiable Result of that strategic intervention? (STAR - R)', 'ml': 'ആ തന്ത്രത്തിന്റെ അളക്കാവുന്ന ഫലം എന്തായിരുന്നു?', 'phrase': 'We delivered two weeks ahead of schedule and expanded client retention by forty percent.', 'meaning': 'രണ്ടാഴ്ച മുൻപേ ഡെലിവറി പൂർത്തിയാക്കുകയും ക്ലയന്റ് നിലനിർത്തൽ 40% വർദ്ധിപ്പിക്കുകയും ചെയ്തു (STAR - R).', 'tag': '🎯 STAR Method: Result'},
        {'avatar': 'Chief Executive Officer', 'prompt': 'How do you articulate our market differentiation to enterprise clients?', 'ml': 'വലിയ ക്ലയന്റുകളോട് നമ്മുടെ പ്രത്യേകത എങ്ങനെ ബോധ്യപ്പെടുത്തും?', 'phrase': 'We combine enterprise-grade security with unparalleled user agility.', 'meaning': 'ഏറ്റവും മികച്ച സുരക്ഷയും ഉപയോക്തൃ സൗകര്യവും ഞങ്ങൾ ഒരുമിച്ച് നൽകുന്നു.', 'tag': '💼 Enterprise Value Pitch'},
        {'avatar': 'Strategy Director', 'prompt': 'How do you handle disagreement with executive board members?', 'ml': 'ബോർഡ് അംഗങ്ങളുമായി അഭിപ്രായവ്യത്യാസം ഉണ്ടായാൽ എങ്ങനെ നേരിടും?', 'phrase': 'I ground my counterproposals in rigorous competitive benchmarks.', 'meaning': 'കൃത്യമായ വിപണി വിശകലനങ്ങളും തെളിവുകളും അടിസ്ഥാനമാക്കിയാണ് ഞാൻ സംസാരിക്കുന്നത്.', 'tag': '📊 Boardroom Influence'},
        {'avatar': 'Global VP of HR', 'prompt': 'What is your operational approach to talent retention during mergers?', 'ml': 'കമ്പനി ലയന സമയത്ത് ജീവനക്കാരെ നിലനിർത്താൻ എന്ത് സമീപനമാണ് സ്വീകരിക്കുന്നത്?', 'phrase': 'Transparent communication and career path clarity mitigate attrition risks.', 'meaning': 'സുതാര്യമായ സംഭാഷണവും വ്യക്തമായ കരിയർ വഴികളും കൊഴിഞ്ഞുപോക്ക് തടയുന്നു.', 'tag': '👥 Leadership Retention'},
        {'avatar': 'Procurement Head', 'prompt': 'The counterparty demands a twenty-percent discount on the multi-year SLA.', 'ml': 'ക്ലയന്റ് 20% ഡിസ്കൗണ്ട് ആവശ്യപ്പെടുന്നു.', 'phrase': 'We can tier the pricing based on committed volume thresholds instead.', 'meaning': 'വില കുറയ്ക്കുന്നതിന് പകരം വോളിയം അനുസരിച്ചുള്ള നിരക്ക് നിശ്ചയിക്കാം.', 'tag': '🤝 Contract Negotiation'},
        {'avatar': 'Chief Risk Officer', 'prompt': 'How do you manage regulatory compliance without stifling innovation?', 'ml': 'നൂതന ആശയങ്ങളെ തടയാതെ നിയമപരമായ സുരക്ഷ എങ്ങനെ ഉറപ്പാക്കാം?', 'phrase': 'We bake compliance checkpoints directly into our automated continuous delivery pipeline.', 'meaning': 'നിയമപരമായ മാനദണ്ഡങ്ങൾ ഓട്ടോമേറ്റഡ് സിസ്റ്റത്തിൽ തന്നെ ഉൾപ്പെടുത്തിയിരിക്കുന്നു.', 'tag': '🛡️ Regulatory Compliance'},
        {'avatar': 'Venture Capitalist', 'prompt': 'Why should our syndicate lead your Series B funding round?', 'ml': 'ഞങ്ങളുടെ ഫണ്ട് എന്തിന് നിങ്ങളുടെ കമ്പനിയിൽ നിക്ഷേപിക്കണം?', 'phrase': 'Our capital efficiency and month-on-month compounding growth speak for themselves.', 'meaning': 'നമ്മുടെ മികച്ച മൂലധനക്ഷമതയും തുടർച്ചയായ വളർച്ചയും ബിസിനസ്സിന്റെ കരുത്ത് തെളിയിക്കുന്നു.', 'tag': '🚀 Investor Pitch'},
        {'avatar': 'Keynote Chair', 'prompt': 'How will artificial intelligence reshape human collaboration in the enterprise?', 'ml': 'AI മനുഷ്യന്റെ പ്രവർത്തനങ്ങളെ എങ്ങനെ മാറ്റിമറിക്കും?', 'phrase': 'AI amplifies human ingenuity by automating routine operational cognitive friction.', 'meaning': 'സാധാരണ ജോലികൾ ഓട്ടോമേറ്റ് ചെയ്ത് മനുഷ്യന്റെ ക്രിയാത്മകത വർദ്ധിപ്പിക്കാൻ AI സഹായിക്കുന്നു.', 'tag': '🧠 Thought Leadership'},
        {'avatar': 'Head of Engineering', 'prompt': 'How do you mentor mid-level engineers into autonomous leaders?', 'ml': 'എഞ്ചിനീയർമാരെ സ്വതന്ത്ര ലീഡർമാരായി എങ്ങനെ വളർത്തിയെടുക്കുന്നു?', 'phrase': 'I assign high-visibility ownership while providing a psychological safety net.', 'meaning': 'സ്വതന്ത്രമായി കാര്യങ്ങൾ ചെയ്യാനുള്ള പൂർണ്ണ ചുമതലയും പിന്തുണയും ഞാൻ നൽകുന്നു.', 'tag': '🌱 Talent Mentorship'},
        {'avatar': 'Crisis Management Lead', 'prompt': 'A major client experienced unexpected latency during holiday peak traffic.', 'ml': 'ക്ലയന്റിന് തടസ്സം നേരിട്ടപ്പോൾ എന്ത് നടപടി എടുത്തു?', 'phrase': 'I issued an immediate post-mortem, owned the error, and shipped permanent redundancy.', 'meaning': 'ഉടനടി അന്വേഷണം നടത്തി തെറ്റ് അംഗീകരിക്കുകയും സ്ഥിരമായ പരിഹാരം കാണുകയും ചെയ്തു.', 'tag': '⚡ Accountability & Crisis'},
        {'avatar': 'Presidential Envoy', 'prompt': 'What core value governs every decision you make in executive leadership?', 'ml': 'നേതൃത്വത്തിൽ താങ്കളെ നയിക്കുന്ന അടിസ്ഥാന മൂല്യം എന്താണ്?', 'phrase': 'Radical integrity, uncompromising excellence, and deep empathy for end users.', 'meaning': 'സത്യസന്ധതയും വിട്ടുവീഴ്ചയില്ലാത്ത ഗുണമേന്മയും ഉപയോക്താക്കളോടുള്ള കരുതലും.', 'tag': '👑 Executive Character'},
        {'avatar': 'Grandmaster Examiner', 'prompt': 'You have demonstrated the pinnacle of English articulation and mastery!', 'ml': 'ഇംഗ്ലീഷ് ഭാഷയിലെ ഏറ്റവും മികച്ച പ്രാവീണ്യമാണ് നിങ്ങൾ കാഴ്ചവെച്ചത്!', 'phrase': 'I command the English language as an effortless instrument of global impact.', 'meaning': 'ആഗോള തലത്തിൽ സ്വാധീനം ചെലുത്താനുള്ള ശക്തമായ മാധ്യമമായി ഇംഗ്ലീഷിനെ ഞാൻ ഉപയോഗിക്കുന്നു.', 'tag': '🏆 Sovereign Capstone'},
      ];
      final item = higherInterviewDrills[dIdx];
      result.add({
        'avatarPrompt': "${item['avatar']}: '${item['prompt']}'",
        'avatarPromptMl': item['ml'] ?? '',
        'phrase': item['phrase'] ?? '',
        'phonetic': '/${item['phrase']}/',
        'meaning': {'en': item['phrase'] ?? '', 'ml': item['meaning'] ?? ''},
        'tag': item['tag'] ?? '🎯 Executive Behavioral Drill',
        'tagMl': 'എക്സിക്യൂട്ടീവ് ഇന്റർവ്യൂ',
      });
    }

    // 🎯 Challenge 5: Reading Passage Shadowing or Second Cadence Pattern
    bool challenge5Added = false;
    if (readingSentences.length > 1) {
      final r2 = readingSentences[1];
      final text = (r2 is Map ? r2['text']?.toString() : r2.toString()) ?? '';
      final ml = (r2 is Map ? r2['meaningMl']?.toString() : '') ?? '';
      if (text.isNotEmpty) {
        result.add({
          'avatarPrompt': "Cyber Cat Mascot: 'Final milestone! Speak this with absolute boldness!'",
          'avatarPromptMl': 'സൈബർ ക്യാറ്റ്: അവസാനത്തെ പവർ വാചകം! ഉറക്കെ ധൈര്യത്തോടെ പറയൂ:',
          'phrase': text,
          'phonetic': '/$text/',
          'meaning': {'en': text, 'ml': ml.isNotEmpty ? ml : text},
          'tag': '🎙️ Aloud Reading Drill',
          'tagMl': 'ഉറക്കെ വായിക്കൽ',
        });
        challenge5Added = true;
      }
    } else if (challengePatterns.length > 1) {
      final pat2 = challengePatterns[1].toString().replaceAll('"', '').trim();
      result.add({
        'avatarPrompt': "Maya Tutor: 'Fast reflex challenge! Speak without translating in your head!'",
        'avatarPromptMl': 'ട്യൂട്ടർ മായ: മലയാളത്തിൽ ചിന്തിക്കാതെ നേരിട്ട് ഇംഗ്ലീഷിൽ മറുപടി പറയൂ:',
        'phrase': pat2,
        'phonetic': '/$pat2/',
        'meaning': {'en': pat2, 'ml': 'സ്വാഭാവികമായി സംസാരിക്കുക.'},
        'tag': '⚡ Speed & Cadence Drill',
        'tagMl': 'സംസാര വേഗത',
      });
      challenge5Added = true;
    }

    if (!challenge5Added) {
      final cadenceFallback = track == Day1Track.zero
          ? 'Practice makes my English better every day.'
          : (track == Day1Track.middle
              ? 'Confidence in spoken English unlocks limitless career opportunities.'
              : 'Commanding professional communication elevates leadership presence.');
      final cadenceMl = track == Day1Track.zero
          ? 'സ്ഥിരമായ പരിശീലനം ദിവസവും എന്റെ ഇംഗ്ലീഷ് മെച്ചപ്പെടുത്തുന്നു.'
          : (track == Day1Track.middle
              ? 'ഇംഗ്ലീഷ് സംസാരിക്കാനുള്ള ആത്മവിശ്വാസം പുതിയ കരിയർ വഴികൾ തുറക്കുന്നു.'
              : 'മികച്ച ആശയവിനിമയം നേതൃത്വപാടവം വർദ്ധിപ്പിക്കുന്നു.');
      result.add({
        'avatarPrompt': "Maya Tutor: 'Final milestone! Speak this out loud with complete confidence!'",
        'avatarPromptMl': 'ട്യൂട്ടർ മായ: അവസാനത്തെ പവർ വാചകം! ഉറക്കെ ധൈര്യത്തോടെ പറയൂ:',
        'phrase': cadenceFallback,
        'phonetic': '/$cadenceFallback/',
        'meaning': {'en': cadenceFallback, 'ml': cadenceMl},
        'tag': '🎙️ Aloud Power Drill',
        'tagMl': 'ആത്മവിശ്വാസ വാചകം',
      });
    }

    if (existingStepData != null) {
      existingStepData['appliedTrack'] = currentTrackKey;
    }

    return result;
  }

  // -------------------------------------------------------------
  // 1. STEPS (100% JSON-Driven from Day1CurriculumJsonData)
  // -------------------------------------------------------------
  static List<Day1StepModel> getSteps([Day1Track? track, int day = 1]) {
    final currentTrack = track ?? Day1Track.middle;

    final cachedDay = PocketDayCurriculumService.getCachedDay(day) ?? (day == 1 ? Day1CurriculumJsonData.rawMap : null);
    if (cachedDay != null && cachedDay['steps'] != null) {
        final rawSteps = cachedDay['steps'] as List<dynamic>? ?? [];
        return rawSteps.map((s) {
          final map = Map<String, dynamic>.from(s as Map<String, dynamic>);
          final stepNum = map['stepNumber'] as int? ?? 1;
          var titleEn = PocketDayCurriculumService.getLocalizedText(map['title'], lang: 'en');
          var titleMl = PocketDayCurriculumService.getLocalizedText(map['title'], lang: 'ml');
          var descEn = PocketDayCurriculumService.getLocalizedText(map['description'], lang: 'en');
          var descMl = PocketDayCurriculumService.getLocalizedText(map['description'], lang: 'ml');
          var icon = map['icon']?.toString() ?? '📚';
          var gameType = map['gameType']?.toString() ?? 'generic';

          // Step 3 Meadow runner hunt synthesis
          if (stepNum == 3 && (map['rounds'] == null || (map['rounds'] as List).isEmpty)) {
            final targetObjects = (map['targetObjects'] as List?)?.map((e) => e.toString()).toList() ?? [];
            final nounsList = (cachedDay['vocabulary']?['nouns'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final nounMeaningMap = {
              for (final n in nounsList)
                n['word']?.toString().toLowerCase(): PocketDayCurriculumService.getLocalizedText(n['meaning'], lang: 'ml'),
            };
            final synthesizedRounds = <Map<String, dynamic>>[];
            for (int i = 0; i < targetObjects.length; i++) {
              final obj = targetObjects[i];
              final meaning = nounMeaningMap[obj.toLowerCase()] ?? obj;
              synthesizedRounds.add({
                'targetLetter': obj.isNotEmpty ? obj[0].toUpperCase() : 'A',
                'targetWord': obj,
                'meaning': meaning,
                'prompt': 'Catch "$obj" ($meaning)',
                'options': [
                  obj,
                  if (i + 1 < targetObjects.length) targetObjects[i + 1] else 'Book',
                  'Water',
                  'House',
                ]..shuffle(),
                'correct': obj,
              });
            }
            map['rounds'] = synthesizedRounds;
          }

          // Step 4 Word catcher & sentence builder synthesis
          if (stepNum == 4 && (map['rounds'] == null || (map['rounds'] as List).isEmpty)) {
            final challengePatterns = (map['challengePatterns'] as List?)?.map((e) => e.toString()).toList() ?? [];
            final verbsList = (cachedDay['vocabulary']?['verbs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final synthesizedRounds = <Map<String, dynamic>>[];
            for (final v in verbsList.take(2)) {
              final v1 = v['v1']?.toString() ?? '';
              final meaning = PocketDayCurriculumService.getLocalizedText(v['meaning'], lang: 'ml');
              synthesizedRounds.add({
                'type': 'match',
                'prompt': 'Find the meaning of "$v1":',
                'options': [meaning, 'പോവുക', 'വരുക', 'ഓടുക']..shuffle(),
                'correct': meaning,
              });
            }
            for (final pat in challengePatterns) {
              final clean = pat.replaceAll('.', '').trim();
              final words = clean.split(' ').where((w) => w.isNotEmpty).toList();
              synthesizedRounds.add({
                'type': 'sentence',
                'prompt': 'Build the sentence: "$clean."',
                'scrambled': (List<String>.from(words)..shuffle()),
                'expected': words.join(' '),
              });
            }
            map['rounds'] = synthesizedRounds;
          }

          // Step 5 Reading room synthesis
          if (stepNum == 5) {
            final sentences = (map['sentences'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            map['passage'] = {
              'bookTitle': cachedDay['course']?['topic'] ?? {'en': 'Daily Reading', 'ml': 'ദിവസേന വായന'},
              'sentences': sentences.map((e) => {'en': e['text'] ?? '', 'ml': e['meaningMl'] ?? ''}).toList(),
              'comprehensionQuestions': [
                if (sentences.isNotEmpty) {
                  'question': {'en': 'What did we practice today?', 'ml': 'ഇന്ന് നമ്മൾ എന്താണ് പരിശീലിച്ചത്?'},
                  'options': [sentences.first['text']?.toString() ?? '', 'Fly away', 'Sleep now'],
                  'correctIndex': 0,
                  'explanation': {'en': 'Today focus sentence.', 'ml': 'ഇന്നത്തെ പാഠം.'},
                }
              ],
            };
          }

          // Step 6 Spoken English Vocal Gym synthesis (User Audio Directive: High priority, rich multi-sentence challenges for Zero, Middle, Higher across all 90 days)
          if (stepNum == 6) {
            titleEn = '🎙️ Spoken English Vocal Gym';
            titleMl = '🎙️ സ്പോക്കൺ ഇംഗ്ലീഷ് വോക്കൽ ജിം';
            descEn = 'Speak out loud into the microphone across practical conversational, student & job interview drills!';
            descMl = 'മൈക്കിലൂടെ ഉറക്കെ സംസാരിച്ച് ഇന്റർവ്യൂ, സംഭാഷണ ചോദ്യങ്ങൾ പ്രാക്ടീസ് ചെയ്യുക!';
            icon = '🎙️';
            gameType = 'speech_analyzer';

            map['challenges'] = synthesizeSpokenWorkoutChallenges(
              track: currentTrack,
              day: day,
              dayData: cachedDay,
              existingStepData: map,
            );
          }

          // Zero track safe options (User Audio Directive: Up to Day 10, Zero learners get safe non-social steps)
          if (currentTrack == Day1Track.zero && day <= 10) {
            if (stepNum == 7) {
              titleEn = 'Tutor Robot Voice Practice';
              titleMl = 'ട്യൂട്ടർ റോബോട്ടിനൊപ്പമുള്ള സംസാരം 🤖';
              descEn = 'Practice repeating simple words with your private AI Robot without any fear or embarrassment!';
              descMl = 'ലളിതമായ വാക്കുകൾ റോബോട്ടിനൊപ്പം പറഞ്ഞു ശീലിക്കുക. ആരും കേൾക്കില്ല, പേടിയില്ലാതെ സംസാരിക്കാം!';
              icon = '🤖';
              gameType = 'spoken_robot';
            } else if (stepNum == 8) {
              titleEn = 'Phonics & Object Memory Match';
              titleMl = 'അക്ഷര-വസ്തു മാച്ചിംഗ് ഗെയിം 🧩';
              descEn = 'Match letters with their correct picture objects to build strong recognition.';
              descMl = 'പഠിച്ച അക്ഷരങ്ങളും ചിത്രങ്ങളും കൂട്ടിയോജിപ്പിച്ച് മെമ്മറി ഉറപ്പിക്കുക.';
              icon = '🧩';
              gameType = 'memory_match';
            } else if (stepNum == 9) {
              titleEn = 'AI Tutor Private Audio Lab';
              titleMl = 'സ്വകാര്യ ഓഡിയോ ലാബ് 🎧';
              descEn = 'Listen to native pronunciation and practice speaking safely in private.';
              descMl = 'സ്വകാര്യമായി കേട്ടു പഠിച്ച് പേടിയില്ലാതെ സംസാരിക്കുക.';
              icon = '🎧';
              gameType = 'audio_listening_lab';
            }
          }

          return Day1StepModel(
            stepNumber: stepNum,
            titleEn: titleEn,
            titleMl: titleMl,
            icon: icon,
            type: gameType,
            descriptionEn: descEn,
            descriptionMl: descMl,
            data: map,
          );
        }).toList();
      }

    final rawSteps = Day1CurriculumJsonData.rawMap['steps'] as List<dynamic>? ?? [];

    return rawSteps.map((s) {
      final map = s as Map<String, dynamic>;
      final stepNum = map['stepNumber'] as int? ?? 1;
      var titleEn = Day1CurriculumJsonData.getLocalizedString(map['title'], lang: 'en');
      var titleMl = Day1CurriculumJsonData.getLocalizedString(map['title'], lang: 'ml');
      var descEn = Day1CurriculumJsonData.getLocalizedString(map['description'], lang: 'en');
      var descMl = Day1CurriculumJsonData.getLocalizedString(map['description'], lang: 'ml');
      var icon = map['icon']?.toString() ?? '📚';
      var gameType = map['gameType']?.toString() ?? 'generic';

      // 🛡️ User Audio Directive: Zero Foundation learners (like Father) MUST NOT be forced
      // to make real stranger phone calls, PocketTalk requests, or group chats on Days 1-10!
      if (currentTrack == Day1Track.zero) {
        if (stepNum == 7) {
          titleEn = 'Tutor Robot Voice Practice';
          titleMl = 'ട്യൂട്ടർ റോബോട്ടിനൊപ്പമുള്ള സംസാരം 🤖';
          descEn = 'Practice repeating simple words with your private AI Robot without any fear or embarrassment!';
          descMl = 'ലളിതമായ വാക്കുകൾ റോബോട്ടിനൊപ്പം പറഞ്ഞു ശീലിക്കുക. ആരും കേൾക്കില്ല, പേടിയില്ലാതെ സംസാരിക്കാം!';
          icon = '🤖';
          gameType = 'spoken_robot';
        } else if (stepNum == 8) {
          titleEn = 'Phonics & Object Memory Match';
          titleMl = 'അക്ഷര-വസ്തു മാച്ചിംഗ് ഗെയിം 🧩';
          descEn = 'Match letters A-F with their correct picture objects to build strong recognition.';
          descMl = 'പഠിച്ച അക്ഷരങ്ങളും ചിത്രങ്ങളും കൂട്ടിയോജിപ്പിച്ച് മെമ്മറി ഉറപ്പിക്കുക.';
          icon = '🧩';
          gameType = 'memory_match';
        } else if (stepNum == 9) {
          titleEn = 'AI Tutor Private Audio Lab';
          titleMl = 'സ്വകാര്യ ഓഡിയോ ലാബ് 🎧';
          descEn = 'Listen to native pronunciation and practice speaking safely in private.';
          descMl = 'സ്വകാര്യമായി കേട്ടു പഠിച്ച് പേടിയില്ലാതെ സംസാരിക്കുക.';
          icon = '🎧';
          gameType = 'audio_listening_lab';
        }
      }

      // Step 6 Spoken English Vocal Gym synthesis (User Audio Directive: High priority, rich multi-sentence challenges for Zero, Middle, Higher)
      if (stepNum == 6) {
        titleEn = '🎙️ Spoken English Vocal Gym';
        titleMl = '🎙️ സ്പോക്കൺ ഇംഗ്ലീഷ് വോക്കൽ ജിം';
        descEn = 'Speak out loud into the microphone across practical conversational, student & job interview drills!';
        descMl = 'മൈക്കിലൂടെ ഉറക്കെ സംസാരിച്ച് ഇന്റർവ്യൂ, സംഭാഷണ ചോദ്യങ്ങൾ പ്രാക്ടീസ് ചെയ്യുക!';
        icon = '🎙️';
        gameType = 'speech_analyzer';

        map['challenges'] = synthesizeSpokenWorkoutChallenges(
          track: currentTrack,
          day: 1,
          dayData: Day1CurriculumJsonData.rawMap,
          existingStepData: map,
        );
      }

      return Day1StepModel(
        stepNumber: stepNum,
        titleEn: titleEn,
        titleMl: titleMl,
        icon: icon,
        type: gameType,
        descriptionEn: descEn,
        descriptionMl: descMl,
        data: Map<String, dynamic>.from(map),
      );
    }).toList();
  }

  // -------------------------------------------------------------
  // 2. READING PASSAGE (From Step 5 in JSON)
  // -------------------------------------------------------------
  static Day1ReadingPassage getReadingPassage([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final cachedDay = PocketDayCurriculumService.getCachedDay(day);
      if (cachedDay != null) {
        final rawSteps = cachedDay['steps'] as List<dynamic>? ?? [];
        final step5 = rawSteps.firstWhere(
          (s) => s['id'] == 'step_5_reading_room' || s['stepNumber'] == 5,
          orElse: () => <String, dynamic>{},
        ) as Map<String, dynamic>;
        final rawSentences = step5['sentences'] as List<dynamic>? ?? [];
        final sentencesEn = rawSentences.map((e) => e is Map ? (e['text']?.toString() ?? '') : e.toString()).toList();
        final sentencesMl = rawSentences.map((e) => e is Map ? (e['meaningMl']?.toString() ?? '') : '').toList();
        final topic = cachedDay['course']?['topic'];
        final bookTitleEn = PocketDayCurriculumService.getLocalizedText(topic, lang: 'en', fallback: 'Day $day Reading');
        final bookTitleMl = PocketDayCurriculumService.getLocalizedText(topic, lang: 'ml', fallback: 'ഡേ $day വായന');
        return Day1ReadingPassage(
          titleEn: bookTitleEn,
          titleMl: bookTitleMl,
          contentEn: sentencesEn.join(' '),
          contentMl: sentencesMl.join(' '),
          sentencesEn: sentencesEn,
          sentencesMl: sentencesMl,
          questionEn: 'Which sentence matches today\'s lesson?',
          questionMl: 'ഇന്നത്തെ പാഠവുമായി ചേരുന്ന വാചകം ഏതാണ്?',
          options: sentencesEn.isNotEmpty ? sentencesEn : ['Option A', 'Option B', 'Option C'],
          correctOptionIndex: 0,
          explanationEn: 'Practiced in today\'s core lesson.',
          explanationMl: 'ഇന്നത്തെ പാഠത്തിൽ പഠിച്ചത്.',
        );
      }
    }

    final rawSteps = Day1CurriculumJsonData.rawMap['steps'] as List<dynamic>? ?? [];
    final step5 = rawSteps.firstWhere(
      (s) => s['id'] == 'step_5_reading_book' || s['stepNumber'] == 5,
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;
    final passage = step5['passage'] as Map<String, dynamic>? ?? {};
    final bookTitleEn = Day1CurriculumJsonData.getLocalizedString(passage['bookTitle'], lang: 'en');
    final bookTitleMl = Day1CurriculumJsonData.getLocalizedString(passage['bookTitle'], lang: 'ml');
    final rawSentences = passage['sentences'] as List<dynamic>? ?? [];
    final sentencesEn = rawSentences.map((e) => Day1CurriculumJsonData.getLocalizedString(e, lang: 'en')).toList();
    final sentencesMl = rawSentences.map((e) => Day1CurriculumJsonData.getLocalizedString(e, lang: 'ml')).toList();

    final questions = passage['comprehensionQuestions'] as List<dynamic>? ?? [];
    final q1 = (questions.isNotEmpty ? questions[0] : {}) as Map<String, dynamic>;
    final qEn = Day1CurriculumJsonData.getLocalizedString(q1['question'], lang: 'en');
    final qMl = Day1CurriculumJsonData.getLocalizedString(q1['question'], lang: 'ml');
    final options = (q1['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final correctIdx = q1['correctIndex'] as int? ?? 0;
    final expEn = Day1CurriculumJsonData.getLocalizedString(q1['explanation'], lang: 'en');
    final expMl = Day1CurriculumJsonData.getLocalizedString(q1['explanation'], lang: 'ml');

    return Day1ReadingPassage(
      titleEn: bookTitleEn,
      titleMl: bookTitleMl,
      contentEn: sentencesEn.join(' '),
      contentMl: sentencesMl.join(' '),
      sentencesEn: sentencesEn,
      sentencesMl: sentencesMl,
      questionEn: qEn,
      questionMl: qMl,
      options: options.isNotEmpty ? options : ['A', 'B', 'C'],
      correctOptionIndex: correctIdx,
      explanationEn: expEn,
      explanationMl: expMl,
    );
  }

  // -------------------------------------------------------------
  // 3. DEFENSE QUESTIONS (From Step 10 defenseTraps in JSON)
  // -------------------------------------------------------------
  static List<Day1DefenseQuestion> getDefenseQuestions([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final cachedDay = PocketDayCurriculumService.getCachedDay(day);
      if (cachedDay != null) {
        final rawSteps = cachedDay['steps'] as List<dynamic>? ?? [];
        final step7 = rawSteps.firstWhere(
          (s) => s['id'] == 'step_7_house_defense' || s['gameType'] == 'house_defense_trap_builder' || s['stepNumber'] == 7,
          orElse: () => <String, dynamic>{},
        ) as Map<String, dynamic>;
        final traps = step7['traps'] as List<dynamic>? ?? [];
        if (traps.isNotEmpty) {
          return traps.map((t) {
            final map = t as Map<String, dynamic>;
            final q = map['question']?.toString() ?? '';
            final options = (map['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
            final ans = map['answer']?.toString() ?? '';
            final correctIdx = options.indexOf(ans);
            final exp = map['explanation']?.toString() ?? '';
            return Day1DefenseQuestion(
              questionEn: q,
              questionMl: q,
              options: options,
              correctIndex: correctIdx >= 0 ? correctIdx : 0,
              explanationEn: exp,
              explanationMl: exp,
            );
          }).toList();
        }
      }
    }

    final rawSteps = Day1CurriculumJsonData.rawMap['steps'] as List<dynamic>? ?? [];
    final step10 = rawSteps.firstWhere(
      (s) => s['id'] == 'step_9_house_defense' || s['id'] == 'step_10_house_defense' || s['gameType'] == 'house_defense' || s['stepNumber'] == 9 || s['stepNumber'] == 10,
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;
    final traps = step10['defenseTraps'] as List<dynamic>? ?? [];
    return traps.map((t) {
      final map = t as Map<String, dynamic>;
      final qEn = Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'en');
      final qMl = Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'ml');
      final options = (map['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      final correctIdx = map['correctIndex'] as int? ?? 0;
      final expEn = Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'en');
      final expMl = Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'ml');
      return Day1DefenseQuestion(
        questionEn: qEn,
        questionMl: qMl,
        options: options,
        correctIndex: correctIdx,
        explanationEn: expEn,
        explanationMl: expMl,
      );
    }).toList();
  }

  // -------------------------------------------------------------
  // 4. VOCABULARY (50+ words from Step 2 in JSON)
  // -------------------------------------------------------------
  static List<Day1VocabWord> getVocabulary([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final cachedDay = PocketDayCurriculumService.getCachedDay(day);
      if (cachedDay != null && cachedDay.containsKey('vocabulary')) {
        final vocab = cachedDay['vocabulary'] as Map<String, dynamic>? ?? {};
        final verbs = vocab['verbs'] as List<dynamic>? ?? [];
        final nouns = vocab['nouns'] as List<dynamic>? ?? [];
        final list = <Day1VocabWord>[];
        for (final v in verbs) {
          if (v is Map<String, dynamic>) {
            final word = v['v1']?.toString() ?? '';
            final meaning = v['meaning'] as Map<String, dynamic>? ?? {};
            list.add(Day1VocabWord(
              word: word,
              phonetic: 'V1: ${v['v1']} • V2: ${v['v2']} • V3: ${v['v3']}',
              emoji: '⚡',
              meaningEn: word,
              meaningMl: meaning['ml']?.toString() ?? '',
              meaningHi: meaning['hi']?.toString() ?? '',
              meaningTa: meaning['ta']?.toString() ?? '',
              exampleEn: v['example']?.toString() ?? '',
              exampleMl: v['exampleMl']?.toString() ?? '',
            ));
          }
        }
        for (final n in nouns) {
          if (n is Map<String, dynamic>) {
            final word = n['word']?.toString() ?? '';
            final meaning = n['meaning'] as Map<String, dynamic>? ?? {};
            list.add(Day1VocabWord(
              word: word,
              phonetic: 'Noun',
              emoji: '🏷️',
              meaningEn: word,
              meaningMl: meaning['ml']?.toString() ?? '',
              meaningHi: meaning['hi']?.toString() ?? '',
              meaningTa: meaning['ta']?.toString() ?? '',
              exampleEn: n['example']?.toString() ?? '',
              exampleMl: '',
            ));
          }
        }
        if (list.isNotEmpty) return list;
      }
    }

    final rawSteps = Day1CurriculumJsonData.rawMap['steps'] as List<dynamic>? ?? [];
    final step2 = rawSteps.firstWhere(
      (s) => s['id'] == 'step_2_vocab_50' || s['stepNumber'] == 2,
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;
    final words = step2['words'] as List<dynamic>? ?? [];
    return words.map((w) {
      final map = w as Map<String, dynamic>;
      final word = map['word']?.toString() ?? '';
      final phonetic = map['phonetic']?.toString() ?? '';
      final emoji = map['emoji']?.toString() ?? '✨';
      final meaning = map['meaning'] as Map<String, dynamic>? ?? {};
      final meaningEn = meaning['en']?.toString() ?? word;
      final meaningMl = meaning['ml']?.toString() ?? '';
      final meaningHi = meaning['hi']?.toString() ?? '';
      final meaningTa = meaning['ta']?.toString() ?? '';
      final example = map['example'];
      final exampleEn = example is Map ? (example['en']?.toString() ?? '') : (example?.toString() ?? '');
      final exampleMl = example is Map ? (example['ml']?.toString() ?? '') : '';

      return Day1VocabWord(
        word: word,
        phonetic: phonetic,
        emoji: emoji,
        meaningEn: meaningEn,
        meaningMl: meaningMl,
        meaningHi: meaningHi,
        meaningTa: meaningTa,
        exampleEn: exampleEn,
        exampleMl: exampleMl,
      );
    }).toList();
  }

  // -------------------------------------------------------------
  // 5. HOUSE 1 GATE EXAM (8 questions from JSON)
  // -------------------------------------------------------------
  static List<Day1ExamQuestion> getExam([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final cachedDay = PocketDayCurriculumService.getCachedDay(day);
      if (cachedDay != null) {
        final rawSteps = cachedDay['steps'] as List<dynamic>? ?? [];
        final step10 = rawSteps.firstWhere(
          (s) => s['id'] == 'step_daily_exam' || s['gameType'] == 'daily_exam' || s['stepNumber'] == 10,
          orElse: () => <String, dynamic>{},
        ) as Map<String, dynamic>;
        final examQs = step10['examQuestions'] as List<dynamic>? ?? [];
        if (examQs.isNotEmpty) {
          return examQs.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final map = entry.value as Map<String, dynamic>;
            final q = map['q']?.toString() ?? '';
            final options = (map['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
            final ans = map['answer']?.toString() ?? '';
            final correctIdx = options.indexOf(ans);
            return Day1ExamQuestion(
              index: idx,
              questionEn: q,
              questionMl: q,
              type: 'choice',
              options: options,
              correctAnswer: correctIdx >= 0 ? correctIdx : 0,
              explanationEn: 'Correct answer: $ans',
              explanationMl: 'ശരിയായ ഉത്തരം: $ans',
            );
          }).toList();
        }
      }
    }

    final examMap = Day1CurriculumJsonData.rawMap['houseGateExam'] as Map<String, dynamic>? ?? {};
    final questions = examMap['questions'] as List<dynamic>? ?? [];
    return questions.map((q) {
      final map = q as Map<String, dynamic>;
      final id = map['id'] as int? ?? 1;
      final qEn = Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'en');
      final qMl = Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'ml');
      final options = (map['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      final correctIdx = map['correctIndex'] as int? ?? 0;
      final expEn = Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'en');
      final expMl = Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'ml');
      return Day1ExamQuestion(
        index: id,
        questionEn: qEn,
        questionMl: qMl,
        type: 'choice',
        options: options,
        correctAnswer: correctIdx,
        explanationEn: expEn,
        explanationMl: expMl,
      );
    }).toList();
  }

  // -------------------------------------------------------------
  // 6. ATTACK CHALLENGES (Citadel Combat + Traps from JSON)
  // -------------------------------------------------------------
  static List<Day1AttackChallenge> getAttackChallenges([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final traps = getDefenseQuestions(track, day);
      if (traps.isNotEmpty) {
        return traps.map((t) => Day1AttackChallenge(
          promptEn: t.questionEn,
          promptMl: t.questionMl,
          type: 'choice',
          options: t.options,
          correctAnswer: t.options.isNotEmpty && t.correctIndex < t.options.length ? t.options[t.correctIndex] : '',
          explanationEn: t.explanationEn,
          explanationMl: t.explanationMl,
        )).toList();
      }
    }

    final rawSteps = Day1CurriculumJsonData.rawMap['steps'] as List<dynamic>? ?? [];
    final step10 = rawSteps.firstWhere(
      (s) => s['id'] == 'step_9_house_defense' || s['id'] == 'step_10_house_defense' || s['gameType'] == 'house_defense' || s['stepNumber'] == 9 || s['stepNumber'] == 10,
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;
    final combat = step10['combatTest'] as Map<String, dynamic>? ?? {};
    final list = <Day1AttackChallenge>[];
    if (combat.isNotEmpty) {
      list.add(Day1AttackChallenge(
        promptEn: Day1CurriculumJsonData.getLocalizedString(combat['challenge'], lang: 'en'),
        promptMl: Day1CurriculumJsonData.getLocalizedString(combat['challenge'], lang: 'ml'),
        type: 'choice',
        options: (combat['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        correctAnswer: combat['correct']?.toString() ?? '',
        explanationEn: 'Hit the opponent citadel!',
        explanationMl: 'എതിരാളിയെ കൃത്യമായി അറ്റാക്ക് ചെയ്യുക!',
      ));
    }
    final traps = step10['defenseTraps'] as List<dynamic>? ?? [];
    for (final t in traps) {
      final map = t as Map<String, dynamic>;
      final opts = (map['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      final cIdx = map['correctIndex'] as int? ?? 0;
      final correctStr = cIdx < opts.length ? opts[cIdx] : '';
      list.add(Day1AttackChallenge(
        promptEn: Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'en'),
        promptMl: Day1CurriculumJsonData.getLocalizedString(map['question'], lang: 'ml'),
        type: 'choice',
        options: opts,
        correctAnswer: correctStr,
        explanationEn: Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'en'),
        explanationMl: Day1CurriculumJsonData.getLocalizedString(map['explanation'], lang: 'ml'),
      ));
    }
    return list;
  }

  // -------------------------------------------------------------
  // 7. COMPLETION SUMMARY (Day 1 Achievement feel)
  // -------------------------------------------------------------
  static Map<String, dynamic> getCompletionSummary([Day1Track? track, int day = 1]) {
    if (day > 1) {
      final cachedDay = PocketDayCurriculumService.getCachedDay(day);
      final topic = cachedDay != null ? PocketDayCurriculumService.getLocalizedText(cachedDay['course']?['topic'], lang: 'en') : 'Daily Lesson';
      return {
        'title': '🎉 YOU COMPLETED DAY $day!',
        'badge': '🏆 DAY $day MASTERED',
        'points': '+250 XP',
        'learnedBullets': [
          'Grammar Rule & Spoken Formula: $topic',
          'Vocabulary Verbs & Core Nouns (Step 2)',
          '2D Meadow Runner Hunt & Sentence Constructor',
          'Daily Reading Room & Audio Mic Practice',
          'Spoken Speech Lab Fluency Analyzer',
          'Community Chat & Partner Practice',
          'Citadel Defense Traps & House Protection',
          'Day $day Gate Exam Passed!',
        ],
      };
    }
    return {
      'title': '🎉 YOU COMPLETED DAY 1!',
      'badge': '🏆 HOUSE 1 MASTERED',
      'points': '+200 PS',
      'learnedBullets': [
        'Letters & Phonics Foundation (Step 1)',
        '50+ Everyday Vocabularies (Apple, Book, Water, Grapes, Bed, Crow...)',
        'Word Hunt & Sentence Construction Puzzles',
        'Story Reading & Voice Practice',
        'Live Random Call & PocketTalk Mate Pact',
        'Community Chat Group Intro',
        'House Defense Traps & Iron Citadel Combat',
        'House 1 Gate Exam Passed ➔ House 2 Unlocked!',
      ],
      'messageEn': "Congratulations! You have mastered Day 1 through games, real speaking, and social interactions. House 2 is now unlocked!",
      'messageMl': "അഭിനന്ദനങ്ങൾ! ഗെയിമുകളിലൂടെയും സംസാരത്തിലൂടെയും നിങ്ങൾ ഡേ 1 പൂർത്തിയാക്കി. ഇനി അടുത്ത വീട് (ഹൗസ് 2) നിങ്ങൾക്കായി തുറന്നു!",
      'nextDayStatus': 'House 2 (Day 2) ➔ Unlocked! 🔓',
    };
  }
}

enum Day1GameType {
  soundBubblePop, // Level 1 (Zero): Tap floating sound bubbles & voice shadow
  sentenceTrainPuzzle, // Level 2 (Beginner): Train bogie word ordering & speak
  rapidReflexTimer, // Level 3 (Elementary): 3-second rapid-fire vocal reflex
  bridgeConnector, // Level 4 (Middle): Choose connector bridge to connect clauses
  boardroomDiplomacy, // Level 5 (Advanced): Convert blunt statement into executive phrasing
  debateRebuttalArena, // Level 6 (Expert): 30-sec rhetorical counter-argument
}

/// 🧱 Visual Formula Brick model
class FormulaBrickData {
  final String title;
  final String subtitle;
  final Color color;

  const FormulaBrickData({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// 📚 Comprehensive Day Tutor & Game Lesson Definition for all 6 Tracks
class Day1TutorLesson {
  final int day;
  final LearnerLevel level;
  final String levelBadge;
  final String levelNameEn;
  final String levelNameMl;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  // Tutor Greetings
  final String teacherGreetingEn;
  final String teacherGreetingMl;

  // Turn 0: Warmup / Identity / Diagnostic check
  final String turn0PromptEn;
  final String turn0PromptMl;
  final String turn0HintEn;
  final List<String> turn0Suggestions;
  final List<String> turn0ExpectedKeywords;

  // Turn 1: Formula / Concept Breakdown
  final String turn1TitleEn;
  final String turn1TitleMl;
  final String turn1TeacherVoiceEn;
  final String turn1TeacherVoiceMl;
  final List<FormulaBrickData> turn1FormulaBricks;
  final String turn1InsightEn;
  final String turn1InsightMl;

  // Turn 2: Real Usage & Deepening
  final String turn2TitleEn;
  final String turn2TitleMl;
  final String turn2TeacherVoiceEn;
  final String turn2TeacherVoiceMl;
  final List<Map<String, String>> turn2Examples;

  // Turn 3: Spoken Repeat Challenge
  final String turn3TargetPhrase;
  final String turn3DisplayPhraseMl;
  final List<String> turn3RecognizedKeywords;
  final String turn3PraiseEn;

  // Turn 4: Game Challenge (Flame / Interactive game mechanics)
  final Day1GameType gameType;
  final String gameTitle;
  final String gameInstructionEn;
  final String gameInstructionMl;
  final Map<String, dynamic> gameData;

  // Coached Safari Stages (for interactive multi-round letter / word / phrase games)
  final List<Map<String, dynamic>> safariStages;

  // Turn 5: Victory Celebration
  final String victoryTitle;
  final String victorySubtitleEn;
  final String victorySubtitleMl;

  const Day1TutorLesson({
    this.day = 1,
    required this.level,
    required this.levelBadge,
    required this.levelNameEn,
    required this.levelNameMl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.teacherGreetingEn,
    required this.teacherGreetingMl,
    required this.turn0PromptEn,
    required this.turn0PromptMl,
    required this.turn0HintEn,
    required this.turn0Suggestions,
    required this.turn0ExpectedKeywords,
    required this.turn1TitleEn,
    required this.turn1TitleMl,
    required this.turn1TeacherVoiceEn,
    required this.turn1TeacherVoiceMl,
    required this.turn1FormulaBricks,
    required this.turn1InsightEn,
    required this.turn1InsightMl,
    required this.turn2TitleEn,
    required this.turn2TitleMl,
    required this.turn2TeacherVoiceEn,
    required this.turn2TeacherVoiceMl,
    required this.turn2Examples,
    required this.turn3TargetPhrase,
    required this.turn3DisplayPhraseMl,
    required this.turn3RecognizedKeywords,
    required this.turn3PraiseEn,
    required this.gameType,
    required this.gameTitle,
    required this.gameInstructionEn,
    required this.gameInstructionMl,
    required this.gameData,
    this.safariStages = const [],
    required this.victoryTitle,
    required this.victorySubtitleEn,
    required this.victorySubtitleMl,
  });
}

typedef DayTutorLesson = Day1TutorLesson;

/// 🏛️ Central Repository of Day 1 Lessons for each of the 6 Syllabuses
class PocketDay1TutorCurriculum {
  static final Map<LearnerLevel, Day1TutorLesson> lessons = {
    // -------------------------------------------------------------
    // TRACK 1: Zero Foundation (ABCD & Phonics with CyberCat!)
    // -------------------------------------------------------------
    LearnerLevel.zero: const Day1TutorLesson(
      level: LearnerLevel.zero,
      levelBadge: '🌱 1. ZERO FOUNDATION',
      levelNameEn: 'Zero Foundation Track (ABCD & Phonics)',
      levelNameMl: 'ശൂന്യത്തിൽ നിന്നുള്ള അടിത്തറ (ABCD & ഫോണിക്സ്)',
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
      icon: Icons.abc_rounded,
      teacherGreetingEn: "This is A. A for Apple! What is A for?",
      teacherGreetingMl: "ഇത് A. A ഫോർ ആപ്പിൾ! A ഫോർ എന്താണ്?",
      turn0PromptEn:
          "This is A. A for Apple! What is A for? Tap the microphone and say: 'Apple'!",
      turn0PromptMl:
          "ഇത് A. A ഫോർ ആപ്പിൾ! A ഫോർ എന്താണ്? മൈക്കിൽ 'Apple' എന്ന് പറയൂ:",
      turn0HintEn: 'What is A for? Say: "Apple" 🍎',
      turn0Suggestions: ['Apple 🍎', 'A for Apple 🍎', 'Letter A 🅰️'],
      turn0ExpectedKeywords: ['apple', 'a for apple', 'a', 'for apple', 'app'],
      turn1TitleEn: '3 Magic Letters: A, B, C!',
      turn1TitleMl: '3 മാന്ത്രിക അക്ഷരങ്ങൾ: A, B, C!',
      turn1TeacherVoiceEn:
          "Watch these three friendly letters: 'A' says /æ/ for Apple 🍎, 'B' says /b/ for Ball ⚽, and 'C' says /k/ for Cat 🐱!",
      turn1TeacherVoiceMl:
          "ഈ മൂന്ന് അക്ഷരങ്ങൾ ശ്രദ്ധിക്കൂ: A ഫോർ ആപ്പിൾ 🍎, B ഫോർ ബോൾ ⚽, C ഫോർ ക്യാറ്റ് 🐱!",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: '🅰️ Letter A',
          subtitle: 'Apple 🍎 /æ/ ശബ്ദം',
          color: Color(0xFF10B981),
        ),
        FormulaBrickData(
          title: '🅱️ Letter B',
          subtitle: 'Ball ⚽ /b/ ശബ്ദം',
          color: Color(0xFF06B6D4),
        ),
        FormulaBrickData(
          title: '🅲 Letter C',
          subtitle: 'Cat 🐱 /k/ ശബ്ദം',
          color: Color(0xFF3B82F6),
        ),
      ],
      turn1InsightEn:
          "Every big English word starts with friendly letter sounds like A, B, and C!",
      turn1InsightMl:
          "അക്ഷരങ്ങളുടെ യഥാർത്ഥ ശബ്ദം മനസ്സിലാക്കിയാൽ ഇംഗ്ലീഷ് സംസാരിക്കാൻ യാതൊരു ഭയവും തോന്നില്ല!",
      turn2TitleEn: 'A is for Apple • B is for Ball',
      turn2TitleMl: 'A ഫോർ ആപ്പിൾ • B ഫോർ ബോൾ',
      turn2TeacherVoiceEn:
          "Now repeat after CyberCat: 'A is for Apple'! And 'I see a Cat'!",
      turn2TeacherVoiceMl:
          "CyberCat-നൊപ്പം പറഞ്ഞു നോക്കൂ: 'A ഫോർ ആപ്പിൾ', 'I see a Cat' (ഞാൻ ഒരു പൂച്ചയെ കാണുന്നു)!",
      turn2Examples: [
        {'en': 'A is for Apple 🍎', 'ml': 'A എന്നാൽ ആപ്പിൾ'},
        {'en': 'B is for Ball ⚽', 'ml': 'B എന്നാൽ ബോൾ (പന്ത്)'},
        {'en': 'C is for Cat 🐱', 'ml': 'C എന്നാൽ ക്യാറ്റ് (പൂച്ച)'},
        {'en': 'I see a Cat 🐱', 'ml': 'ഞാൻ ഒരു പൂച്ചയെ കാണുന്നു'},
      ],
      turn3TargetPhrase: 'A is for Apple',
      turn3DisplayPhraseMl: '"A ഫോർ ആപ്പിൾ 🍎"',
      turn3RecognizedKeywords: ['a is for apple', 'apple', 'is for apple', 'a', 'a for apple', 'apple apple'],
      turn3PraiseEn: 'Purr-fect! You pronounced Letter A like a true champion! 🎉',
      gameType: Day1GameType.soundBubblePop,
      gameTitle: '🫧 Alphabet Bubble Pop Game',
      gameInstructionEn:
          'Tap the bubble with Letter A (Apple 🍎) and speak "Apple" into the microphone!',
      gameInstructionMl:
          'Letter A (Apple 🍎) ഉള്ള ബബിളിൽ തൊട്ട് മൈക്കിൽ "Apple" എന്ന് പറയുക:',
      gameData: {
        'targetWord': 'Apple',
        'targetEmoji': '🍎',
        'bubbles': [
          {'id': 'b', 'label': '🅱️ Ball ⚽', 'isTarget': false},
          {'id': 'a', 'label': '🅰️ Apple 🍎', 'isTarget': true},
          {'id': 'c', 'label': '🅲 Cat 🐱', 'isTarget': false},
          {'id': 'd', 'label': '🅳 Dog 🐶', 'isTarget': false},
        ],
      },
      victoryTitle: 'Alphabet Champion! 🌟',
      victorySubtitleEn:
          'You mastered your first English letters & sounds with CyberCat!',
      victorySubtitleMl:
          'നിങ്ങൾ ആദ്യ അക്ഷരങ്ങളും ശബ്ദങ്ങളും CyberCat-നൊപ്പം സംസാരിച്ചു വിജയിച്ചു! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),

    // -------------------------------------------------------------
    // TRACK 2: Beginner Track (Common Words Known)
    // -------------------------------------------------------------
    LearnerLevel.beginner: const Day1TutorLesson(
      level: LearnerLevel.beginner,
      levelBadge: '💬 2. BEGINNER',
      levelNameEn: 'Beginner Daily Conversational Track',
      levelNameMl: 'ബിഗിനർ സംഭാഷണ പാത',
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF0284C7),
      icon: Icons.forum_rounded,
      teacherGreetingEn:
          "Hello! Today we build real 3-word sentences to express your daily needs smoothly.",
      teacherGreetingMl:
          "ഹായ്! ഇന്ന് നമ്മൾ 3 വാക്കുകൾ ചേർത്ത് ഒരു വാചകം ഉണ്ടാക്കാൻ പഠിക്കുന്നു.",
      turn0PromptEn:
          "Let's get introduced! What is your name? Say: 'My name is...'",
      turn0PromptMl:
          "നിങ്ങളുടെ പേരെന്താണ്? 'My name is...' എന്ന് പറഞ്ഞ് മൈക്കിൽ പറയുകയോ താഴെ നൽകുകയോ ചെയ്യുക:",
      turn0HintEn: 'Say: "My name is Rahul"',
      turn0Suggestions: ['Rahul', 'Fathima', 'Musab', 'John'],
      turn0ExpectedKeywords: ['name', 'my name', 'i am'],
      turn1TitleEn: 'The Master Sentence Formula: S + V + O',
      turn1TitleMl: 'വാചക നിർമ്മാണ സൂത്രം (ആര് + എന്ത് ചെയ്യുന്നു + കാര്യം)',
      turn1TeacherVoiceEn:
          "In English: YOU are the Subject, what you DO is the Verb in the middle, and WHAT you need is the Object!",
      turn1TeacherVoiceMl:
          "മലയാളത്തിൽ ക്രിയ ഒടുവിലാണ് വരുന്നത്. എന്നാൽ ഇംഗ്ലീഷിൽ എപ്പോഴും പ്രവൃത്തി നടുവിൽ വരുന്നു: I want tea!",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: 'I',
          subtitle: 'Subject (ആര്?)',
          color: Color(0xFF2563EB),
        ),
        FormulaBrickData(
          title: 'want',
          subtitle: 'Verb (പ്രവൃത്തി)',
          color: Color(0xFF059669),
        ),
        FormulaBrickData(
          title: 'tea',
          subtitle: 'Object (എന്തിനെ?)',
          color: Color(0xFFD97706),
        ),
      ],
      turn1InsightEn:
          "English puts the action verb right in the center: Subject + Action + Object.",
      turn1InsightMl:
          "ആക്ഷൻ വേർഡ് എപ്പോഴും നടുവിൽ വെച്ചാൽ ഏത് വാചകവും പെട്ടെന്ന് പറയാം!",
      turn2TitleEn: 'Swap the Object Instantly',
      turn2TitleMl: 'അവസാന വാക്ക് മാറ്റി പുതിയ വാചകങ്ങൾ ഉണ്ടാക്കുക',
      turn2TeacherVoiceEn:
          "Once you know 'I want', you can ask for anything by changing just the last word!",
      turn2TeacherVoiceMl:
          "'I want' എന്നതിനൊപ്പം ചായയോ വെള്ളമോ സഹായമോ ചേർത്ത് എന്ത് കാര്യവും പറയാം:",
      turn2Examples: [
        {'en': 'I want tea', 'ml': 'എനിക്ക് ചായ വേണം'},
        {'en': 'I want water', 'ml': 'എനിക്ക് വെള്ളം വേണം'},
        {'en': 'I need help', 'ml': 'എനിക്ക് സഹായം വേണം'},
        {'en': 'I am ready', 'ml': 'ഞാൻ തയ്യാറാണ്'},
      ],
      turn3TargetPhrase: 'I want tea',
      turn3DisplayPhraseMl: '"എനിക്ക് ചായ വേണം"',
      turn3RecognizedKeywords: ['i want tea', 'want tea', 'i want', 'tea'],
      turn3PraiseEn: 'Spot on! You framed a complete, natural English sentence!',
      gameType: Day1GameType.sentenceTrainPuzzle,
      gameTitle: '🚂 Sentence Train Puzzle Game',
      gameInstructionEn:
          'Tap the train cars in order: [I] -> [want] -> [tea] to build the sentence!',
      gameInstructionMl:
          'ട്രെയിൻ ബോഗികൾ ശരിയായ ക്രമത്തിൽ തൊട്ട് വാചകം നിർമ്മിക്കുക:',
      gameData: {
        'targetSentence': 'I want tea',
        'shuffledWords': ['tea', 'I', 'want'],
        'correctOrder': ['I', 'want', 'tea'],
      },
      victoryTitle: 'Sentence Maker Master! 💬',
      victorySubtitleEn:
          'You built and voiced real 3-word sentences without relying on theory!',
      victorySubtitleMl:
          'നിങ്ങൾ സ്വന്തമായി ഇംഗ്ലീഷ് വാചകങ്ങൾ സംസാരിക്കാൻ തുടങ്ങി! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),

    // -------------------------------------------------------------
    // TRACK 3: Elementary Track (Hesitation Breaker)
    // -------------------------------------------------------------
    LearnerLevel.elementary: const Day1TutorLesson(
      level: LearnerLevel.elementary,
      levelBadge: '🧭 3. ELEMENTARY',
      levelNameEn: 'Elementary Confidence & Speech Habit Track',
      levelNameMl: 'ഏകദേശ ജ്ഞാനമുള്ളവർക്കുള്ള പാത',
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFF0F766E),
      icon: Icons.psychology_outlined,
      teacherGreetingEn:
          "Welcome! The secret to speaking is zero hesitation. Stop translating from Malayalam—reply in under two seconds!",
      teacherGreetingMl:
          "മനസ്സിൽ മലയാളത്തിൽ ചിന്തിച്ചു നിൽക്കരുത്! 2 സെക്കൻഡിനുള്ളിൽ ആലോചിക്കാതെ മറുപടി നൽകാൻ ശീലിക്കാം.",
      turn0PromptEn:
          "When a friend greets you with 'How are you doing?', what is your fastest natural response?",
      turn0PromptMl:
          "'How are you doing?' എന്ന് ആരെങ്കിലും ചോദിച്ചാൽ ആലോചിച്ചു നിൽക്കാതെ പറയുക:",
      turn0HintEn: 'Say: "Doing great!" or "Pretty good!"',
      turn0Suggestions: ['Doing great!', 'Pretty good!', 'Never better!'],
      turn0ExpectedKeywords: ['great', 'doing', 'good', 'pretty', 'fine'],
      turn1TitleEn: 'Instant Conversational Vocal Reflexes',
      turn1TitleMl: 'ആലോചിക്കാതെ പെട്ടെന്ന് പറയാവുന്ന 3 പ്രതികരണങ്ങൾ',
      turn1TeacherVoiceEn:
          "Native speakers don't translate—they use instant vocal reflex phrases to keep conversations rolling!",
      turn1TeacherVoiceMl:
          "നേറ്റീവ് സ്പീക്കർമാർ വാക്കുകൾ തിരഞ്ഞു നിൽക്കാറില്ല; ഇത്തരം ഓട്ടോമാറ്റിക് ശൈലികളാണ് ഉപയോഗിക്കുന്നത്.",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: 'Sounds great!',
          subtitle: 'Agreement reflex (നന്നായിരിക്കുന്നു!)',
          color: Color(0xFF0D9488),
        ),
        FormulaBrickData(
          title: 'Count me in!',
          subtitle: 'Enthusiasm reflex (ഞാനും കൂടുന്നു!)',
          color: Color(0xFF10B981),
        ),
        FormulaBrickData(
          title: 'How about you?',
          subtitle: 'Ball-back reflex (നിങ്ങളുടെ കാര്യമോ?)',
          color: Color(0xFFF59E0B),
        ),
      ],
      turn1InsightEn:
          "Using ready-made reflex phrases completely eliminates the awkward thinking pause!",
      turn1InsightMl:
          "റെഡിമെയ്ഡ് ശൈലികൾ ഉപയോഗിച്ചാൽ സംസാരത്തിനിടയിലെ പരുങ്ങലും മടിയും പൂർണ്ണമായി മാറും!",
      turn2TitleEn: 'Keep the Conversation Ball Rolling',
      turn2TitleMl: 'സംഭാഷണം തുടർന്നു കൊണ്ടുപോകാനുള്ള വഴികൾ',
      turn2TeacherVoiceEn:
          "Always return the serve! When someone invites you, agree enthusiastically and throw the ball back.",
      turn2TeacherVoiceMl:
          "മറുപടി നൽകിയ ശേഷം 'How about you?' എന്ന് ചോദിച്ച് സംഭാഷണം സജീവമായി നിർത്തുക:",
      turn2Examples: [
        {'en': 'Sounds great!', 'ml': 'നന്നായിരിക്കുന്നു!'},
        {'en': 'I would love that!', 'ml': 'തീർച്ചയായും, എനിക്കിഷ്ടമായി!'},
        {'en': 'Count me in!', 'ml': 'ഞാനും കൂടുന്നു!'},
        {'en': 'How about you?', 'ml': 'നിങ്ങളുടെ കാര്യമോ?'},
      ],
      turn3TargetPhrase: 'Sounds great, count me in!',
      turn3DisplayPhraseMl: '"നന്നായിരിക്കുന്നു, ഞാനും കൂടുന്നു!"',
      turn3RecognizedKeywords: [
        'sounds great',
        'count me in',
        'great',
        'sounds',
        'count'
      ],
      turn3PraiseEn: 'Flawless cadence! That was completely hesitation-free!',
      gameType: Day1GameType.rapidReflexTimer,
      gameTitle: '⚡ 3-Second Rapid Reflex Gym',
      gameInstructionEn:
          'A friend asks: "We are grabbing lunch, coming?" Reply with "Count me in!" before the 3-second timer runs out!',
      gameInstructionMl:
          '3 സെക്കൻഡ് തീരുന്നതിന് മുൻപ് "Count me in!" എന്ന് ടാപ്പ് ചെയ്ത് പറയുക:',
      gameData: {
        'scenario': 'Hey! We are going for lunch, want to join us? 🍕',
        'timerSeconds': 3,
        'correctAnswer': 'Count me in!',
        'options': ['Count me in! 🔥', 'Wait I am thinking', 'No English now'],
      },
      victoryTitle: 'Hesitation Broken! 🧭',
      victorySubtitleEn:
          'You eliminated the translation delay and fired back answers with zero pause!',
      victorySubtitleMl:
          'നിങ്ങൾ ആലോചിച്ചു നിൽക്കാതെ അതിവേഗത്തിൽ മറുപടി നൽകാൻ തുടങ്ങി! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),

    // -------------------------------------------------------------
    // TRACK 4: Middle / Intermediate Track
    // -------------------------------------------------------------
    LearnerLevel.middle: const Day1TutorLesson(
      level: LearnerLevel.middle,
      levelBadge: '⚡ 4. MIDDLE LEVEL',
      levelNameEn: 'Middle / Intermediate Spoken Agility Track',
      levelNameMl: 'മിഡിൽ ലെവൽ ഫ്ലുവെൻസി പാത',
      primaryColor: Color(0xFFA855F7),
      secondaryColor: Color(0xFF7E22CE),
      icon: Icons.psychology_rounded,
      teacherGreetingEn:
          "Welcome to Middle Fluency! To sound natural and mature, we connect thoughts smoothly with conversational transitions.",
      teacherGreetingMl:
          "ചെറിയ വാചകങ്ങൾക്ക് പകരം കേൾക്കാൻ ഇമ്പമുള്ള കണക്ടറുകൾ ഉപയോഗിച്ച് സംസാരിക്കാൻ ശീലിക്കാം.",
      turn0PromptEn:
          "How would you connect two contrasting thoughts? For example: 'I wanted to come, but I got busy'?",
      turn0PromptMl:
          "'വരണമെന്നുണ്ടായിരുന്നു, പക്ഷെ തിരക്കായിപ്പോയി' എന്നതിന് കേൾക്കാൻ ഇമ്പമുള്ള ശൈലി എന്താണ്?",
      turn0HintEn: 'Use: "To be honest..." or "Actually..."',
      turn0Suggestions: [
        'To be honest...',
        'Actually...',
        'As a matter of fact...'
      ],
      turn0ExpectedKeywords: ['honest', 'actually', 'matter', 'fact'],
      turn1TitleEn: 'Master Transitional Connectors',
      turn1TitleMl: 'വാചകങ്ങൾ ഭംഗിയായി ബന്ധിപ്പിക്കുന്ന കണക്ടറുകൾ',
      turn1TeacherVoiceEn:
          "Connectors give your brain an extra second to structure your next point without awkward silences.",
      turn1TeacherVoiceMl:
          "കണക്ടറുകൾ ഉപയോഗിക്കുമ്പോൾ അടുത്ത വാക്ക് ആലോചിക്കാൻ സമയം ലഭിക്കുകയും സംസാരം സ്മാർട്ടാവുകയും ചെയ്യും.",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: 'To be honest,',
          subtitle: 'Frank opinion bridge (തുറന്നു പറഞ്ഞാൽ)',
          color: Color(0xFF9333EA),
        ),
        FormulaBrickData(
          title: 'Actually,',
          subtitle: 'Nuanced clarification (യഥാർത്ഥത്തിൽ)',
          color: Color(0xFFC026D3),
        ),
        FormulaBrickData(
          title: 'Nevertheless,',
          subtitle: 'Contrast bridge (എന്നിരുന്നാലും)',
          color: Color(0xFFE11D48),
        ),
      ],
      turn1InsightEn:
          "Transitions transform robotic short sentences into eloquent conversational storytelling.",
      turn1InsightMl:
          "ഒറ്റപ്പെട്ട വാചകങ്ങളെ കോർത്തിണക്കി ആകർഷകമായ ഒഴുക്കുള്ള സംഭാഷണമാക്കി മാറ്റാൻ കണക്ടറുകൾ സഹായിക്കുന്നു.",
      turn2TitleEn: 'Bridging Clauses with Poise',
      turn2TitleMl: 'രണ്ട് ആശയങ്ങളെ മനോഹരമായി കൂട്ടിച്ചേർക്കൽ',
      turn2TeacherVoiceEn:
          "Listen to how 'Nevertheless' bridges two opposite thoughts effortlessly.",
      turn2TeacherVoiceMl:
          "വിപരീതമായ രണ്ട് കാര്യങ്ങളെ ഒരുമിപ്പിച്ചു പറയാൻ 'Nevertheless' ഉപയോഗിക്കുക:",
      turn2Examples: [
        {
          'en': 'To be honest, that sounds like a great plan!',
          'ml': 'തുറന്നു പറഞ്ഞാൽ, അതൊരു മികച്ച പ്ലാൻ ആയി തോന്നുന്നു!'
        },
        {
          'en': 'Actually, that works perfectly for my schedule.',
          'ml': 'യഥാർത്ഥത്തിൽ അത് എന്റെ സമയത്തിന് തികച്ചും അനുയോജ്യമാണ്.'
        },
        {
          'en': 'I was exhausted, nevertheless I finished on time.',
          'ml': 'ഞാൻ ക്ഷീണിതനായിരുന്നു, എന്നിരുന്നാലും കൃത്യസമയത്ത് തീർത്തു.'
        },
      ],
      turn3TargetPhrase: 'To be honest, that sounds like a great plan!',
      turn3DisplayPhraseMl: '"തുറന്നു പറഞ്ഞാൽ, അതൊരു മികച്ച പ്ലാൻ ആയി തോന്നുന്നു!"',
      turn3RecognizedKeywords: [
        'to be honest',
        'great plan',
        'sounds like',
        'honest',
        'plan'
      ],
      turn3PraiseEn:
          'Superb rhythm and transition! Your speech sounds wonderfully articulated!',
      gameType: Day1GameType.bridgeConnector,
      gameTitle: '🌉 Bridge Connector Arcade Game',
      gameInstructionEn:
          'Connect the two clauses: "I was exhausted..." and "...I finished the project on time."',
      gameInstructionMl:
          'രണ്ട് വാക്യങ്ങളെ ബന്ധിപ്പിക്കാൻ അനുയോജ്യമായ കണക്ടർ തെരഞ്ഞെടുത്ത് സംസാരിക്കുക:',
      gameData: {
        'clause1': 'I was exhausted after the long journey,',
        'clause2': 'I finished the presentation on time.',
        'correctConnector': 'nevertheless',
        'options': ['nevertheless', 'because', 'so that'],
      },
      victoryTitle: 'Fluency Bridge Built! ⚡',
      victorySubtitleEn:
          'You elevated your conversational flow using mature transitional connectors!',
      victorySubtitleMl:
          'നിങ്ങൾ വാചകങ്ങളെ ഭംഗിയായി ബന്ധിപ്പിച്ച് സ്വാഭാവിക ഒഴുക്കിൽ സംസാരിക്കാൻ തുടങ്ങി! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),

    // -------------------------------------------------------------
    // TRACK 5: Advanced Workplace & Career English
    // -------------------------------------------------------------
    LearnerLevel.advanced: const Day1TutorLesson(
      level: LearnerLevel.advanced,
      levelBadge: '💼 5. ADVANCED',
      levelNameEn: 'Advanced Workplace & Career Track',
      levelNameMl: 'അഡ്വാൻസ്ഡ് ജോലി & കരിയർ പാത',
      primaryColor: Color(0xFF0EA5E9),
      secondaryColor: Color(0xFF0369A1),
      icon: Icons.business_center_rounded,
      teacherGreetingEn:
          "Good day! In executive environments, high-stakes communication requires diplomatic phrasing and assertive clarity.",
      teacherGreetingMl:
          "ഓഫീസ് മീറ്റിംഗുകളിലും ഇന്റർവ്യൂകളിലും പക്വതയോടും ഡിപ്ലോമാറ്റിക് ആയും സംസാരിക്കാൻ പഠിക്കാം.",
      turn0PromptEn:
          "When a stakeholder proposes an unrealistic deadline, how do you politely push back?",
      turn0PromptMl:
          "അപ്രായോഗികമായ ഒരു ഡെഡ്‌ലൈൻ വരുമ്പോൾ വഴക്കിടാതെ നയപരമായി എങ്ങനെ എതിർക്കാം?",
      turn0HintEn: 'Use: "I see your perspective, however..."',
      turn0Suggestions: [
        'I see your perspective, however...',
        'Could we align on priorities?',
        'Let us mitigate the risks first.'
      ],
      turn0ExpectedKeywords: ['perspective', 'align', 'mitigate', 'however'],
      turn1TitleEn: 'Executive Diplomatic Framing',
      turn1TitleMl: 'ബ്ലണ്ട് ആയ സംസാരത്തിന് പകരം എക്സിക്യൂട്ടീവ് ശൈലി',
      turn1TeacherVoiceEn:
          "Never say 'You are wrong' in a boardroom. Validate the intent, then pivot to operational realities.",
      turn1TeacherVoiceMl:
          "'ഇത് നടക്കില്ല' എന്ന് പരുഷമായി പറയുന്നതിന് പകരം, കാര്യങ്ങൾ വസ്തുനിഷ്ഠമായി അവതരിപ്പിക്കുക.",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: 'I appreciate the intent,',
          subtitle: 'Validation & alignment (അഭിപ്രായത്തെ മാനിക്കൽ)',
          color: Color(0xFF0284C7),
        ),
        FormulaBrickData(
          title: 'however,',
          subtitle: 'Diplomatic pivot (നയപരമായ മാറ്റം)',
          color: Color(0xFFF97316),
        ),
        FormulaBrickData(
          title: 'we must mitigate risks.',
          subtitle: 'Constructive solution (പരിഹാരം നിർദ്ദേശിക്കൽ)',
          color: Color(0xFF10B981),
        ),
      ],
      turn1InsightEn:
          "Diplomatic language disarms conflict and establishes leadership presence in client interactions.",
      turn1InsightMl:
          "നയപരമായ ഇംഗ്ലീഷ് തർക്കങ്ങൾ ഒഴിവാക്കുകയും നിങ്ങളുടെ ലീഡർഷിപ്പ് മികവ് എടുത്തുകാണിക്കുകയും ചെയ്യുന്നു.",
      turn2TitleEn: 'Blunt vs Executive Contrast',
      turn2TitleMl: 'പരുഷമായതും പ്രൊഫഷണലായതുമായ ശൈലികൾ തമ്മിലുള്ള വ്യത്യാസം',
      turn2TeacherVoiceEn:
          "Notice how replacing blunt phrases with executive wording completely alters stakeholder perception.",
      turn2TeacherVoiceMl:
          "വാക്കുകൾ മാറ്റുമ്പോൾ കേൾവിക്കാരന് ഉണ്ടാകുന്ന മതിപ്പ് ശ്രദ്ധിക്കുക:",
      turn2Examples: [
        {
          'en': 'Blunt: That idea will fail ❌',
          'ml': 'Executive: We might encounter operational bottlenecks ✅'
        },
        {
          'en': 'Blunt: Explain it again ❌',
          'ml': 'Executive: Could you unpack that specific rationale? ✅'
        },
        {
          'en': 'Blunt: I don\'t agree ❌',
          'ml': 'Executive: I see it from a slightly different angle ✅'
        },
      ],
      turn3TargetPhrase:
          'I see your perspective, however we should mitigate the risks first.',
      turn3DisplayPhraseMl:
          '"നിങ്ങളുടെ കാഴ്ചപ്പാട് മനസ്സിലാക്കുന്നു, എന്നിരുന്നാലും അപകടസാധ്യതകൾ ആദ്യം ഒഴിവാക്കണം."',
      turn3RecognizedKeywords: [
        'perspective',
        'mitigate',
        'risks',
        'however',
        'see your'
      ],
      turn3PraiseEn:
          'Outstanding corporate diplomacy! That commands respect and leadership.',
      gameType: Day1GameType.boardroomDiplomacy,
      gameTitle: '🏢 Boardroom Diplomacy Simulator',
      gameInstructionEn:
          'Client says: "Deliver all features by Friday or we cancel the contract!" Select and speak the executive response:',
      gameInstructionMl:
          'വെല്ലുവിളി നിറഞ്ഞ സാഹചര്യത്തിൽ ഏറ്റവും ഡിപ്ലോമാറ്റിക് ആയ മറുപടി തെരഞ്ഞെടുത്ത് സംസാരിക്കുക:',
      gameData: {
        'clientStatement':
            '"We need the entire app live by Friday morning, zero excuses!"',
        'options': [
          'That is impossible, you are being unreasonable.',
          'Understood. Let us deliver the core modules Friday and the rest Monday to ensure flawless stability.',
          'Okay fine, whatever you say.',
        ],
        'correctIndex': 1,
      },
      victoryTitle: 'Executive Presence Mastered! 💼',
      victorySubtitleEn:
          'You commanded boardroom poise with polished diplomacy and assertive framing!',
      victorySubtitleMl:
          'നിങ്ങൾ കോർപ്പറേറ്റ് നിലവാരത്തിലുള്ള ഇംഗ്ലീഷ് ശൈലി സ്വായത്തമാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),

    // -------------------------------------------------------------
    // TRACK 6: Expert Peak Fluency & Global Eloquence
    // -------------------------------------------------------------
    LearnerLevel.expert: const Day1TutorLesson(
      level: LearnerLevel.expert,
      levelBadge: '👑 6. EXPERT / PEAK',
      levelNameEn: 'Expert Peak Fluency Track',
      levelNameMl: 'എക്സ്പെർട്ട് പീക്ക് ഫ്ലുവെൻസി',
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFB45309),
      icon: Icons.workspace_premium_rounded,
      teacherGreetingEn:
          "Welcome to Peak Oratory. Mastery is not merely about fluency; it is about rhetorical cadence, strategic pauses, and spontaneous wit.",
      teacherGreetingMl:
          "വേദിയിൽ പ്രസംഗിക്കാനും തത്സമയ സംവാദങ്ങളിൽ ചടുലമായി മറുപടി നൽകാനുമുള്ള ഉന്നത പരിശീലനം.",
      turn0PromptEn:
          "How would you summarize the paradox of modern productivity in one sharp, memorable aphorism?",
      turn0PromptMl:
          "ഒരു ഉന്നത വേദിയിൽ സംസാരിക്കുമ്പോൾ ഒരു വിരോധാഭാസത്തെ ഒറ്റ വാചകത്തിൽ എങ്ങനെ പ്രസംഗിച്ചു തുടങ്ങാം?",
      turn0HintEn: 'Use: "Paradoxically speaking..."',
      turn0Suggestions: [
        'Paradoxically speaking...',
        'While plausible in theory...',
        'Let us not conflate correlation with causation.'
      ],
      turn0ExpectedKeywords: [
        'paradoxically',
        'plausible',
        'theory',
        'conflate',
        'causation'
      ],
      turn1TitleEn: 'Rhetorical Antithesis & Vocal Cadence',
      turn1TitleMl: 'വാക്ചാതുര്യവും ശബ്ദ നിയന്ത്രണവും (Rhetoric & Cadence)',
      turn1TeacherVoiceEn:
          "Observe the rhythm of antithesis: pairing opposites creates an unforgettable cognitive resonance in the listener.",
      turn1TeacherVoiceMl:
          "വിരുദ്ധ ആശയങ്ങളെ ഭംഗിയായി ഒന്നിച്ച് നിർത്തുമ്പോൾ പ്രസംഗത്തിന് വലിയൊരു ആകർഷണീയത കൈവരുന്നു.",
      turn1FormulaBricks: [
        FormulaBrickData(
          title: 'Paradoxically speaking,',
          subtitle: 'Rhetorical hook (ശ്രദ്ധ പിടിച്ചുപറ്റൽ)',
          color: Color(0xFFD97706),
        ),
        FormulaBrickData(
          title: 'true simplicity',
          subtitle: 'Concept subject (ആശയം)',
          color: Color(0xFFB45309),
        ),
        FormulaBrickData(
          title: 'demands peak sophistication.',
          subtitle: 'Antithesis punch (ശക്തമായ പഞ്ച് ലൈൻ)',
          color: Color(0xFF78350F),
        ),
      ],
      turn1InsightEn:
          "A deliberate 0.5-second pregnant pause before your punchline doubles its psychological authority.",
      turn1InsightMl:
          "പ്രധാനപ്പെട്ട വാക്കിന് തൊട്ടു മുൻപുള്ള ചെറിയൊരു നിശബ്ദത കേൾവിക്കാരിൽ വലിയൊരു ആകാംഷയുണർത്തും.",
      turn2TitleEn: 'Native Wit & Counter-Framing',
      turn2TitleMl: 'തത്സമയ വാദമുഖങ്ങളും നർമ്മവും',
      turn2TeacherVoiceEn:
          "When challenged during public debate, instantly reframe the premise rather than defending defensively.",
      turn2TeacherVoiceMl:
          "തർക്കങ്ങളിൽ പ്രതിരോധിച്ചു നിൽക്കാതെ ചോദ്യത്തിന്റെ കാതൽ തന്നെ തിരിച്ചു ചോദിക്കുക:",
      turn2Examples: [
        {
          'en': 'Paradoxically speaking, constraints breed creativity.',
          'ml': 'വിരോധാഭാസമെന്നു തോന്നാമെങ്കിലും നിയന്ത്രണങ്ങളാണ് സർഗ്ഗാത്മകത കൂട്ടുന്നത്.'
        },
        {
          'en': 'While plausible on paper, reality dictates otherwise.',
          'ml': 'പേപ്പറിൽ ശരിയെന്നു തോന്നാമെങ്കിലും യാഥാർത്ഥ്യം മറ്റൊന്നാണ്.'
        },
        {
          'en': 'Let us not conflate correlation with causation.',
          'ml': 'കാര്യകാരണങ്ങളെ പരസ്പരം കൂട്ടിക്കുഴക്കരുത്.'
        },
      ],
      turn3TargetPhrase:
          'Paradoxically speaking, true simplicity requires the highest sophistication.',
      turn3DisplayPhraseMl:
          '"വിരോധാഭാസമെന്നു തോന്നാമെങ്കിലും, യഥാർത്ഥ ലാളിത്യത്തിന് ഉന്നതമായ പക്വത ആവശ്യമാണ്."',
      turn3RecognizedKeywords: [
        'paradoxically',
        'simplicity',
        'sophistication',
        'highest',
        'true'
      ],
      turn3PraiseEn:
          'Incredible oratory poise! Your vocal cadence and delivery were majestic!',
      gameType: Day1GameType.debateRebuttalArena,
      gameTitle: '🎙️ Live Debate Rebuttal Arena',
      gameInstructionEn:
          'AI Debater asserts: "Artificial intelligence will render human artists completely obsolete!" Deliver your sharp rebuttal:',
      gameInstructionMl:
          'AI ഉന്നയിക്കുന്ന വാദത്തിനെതിരെ 30 സെക്കൻഡിൽ ചടുലമായ ഇംഗ്ലീഷിൽ ലൈവ് മറുപടി നൽകുക:',
      gameData: {
        'opponentAssertion':
            '"Artificial intelligence will render human writers and creators utterly obsolete."',
        'recommendedRebuttal':
            'While valid superficially, technology automates data, whereas authentic emotional resonance remains uniquely human.',
        'keywords': ['human', 'valid', 'technology', 'emotion', 'resonance'],
      },
      victoryTitle: 'Apex Orator Crowned! 👑',
      victorySubtitleEn:
          'You demonstrated master-level rhetoric, cadence, and debate agility!',
      victorySubtitleMl:
          'നിങ്ങൾ അന്താരാഷ്ട്ര നിലവാരത്തിലുള്ള വാക്ചാതുര്യത്തോടെ സംസാരിച്ചു കഴിഞ്ഞു! +30 പോക്കറ്റ് സ്കോർ നേടി!',
    ),
  };

  /// Fetch lesson for a specific level and day (1 to 90)
  static DayTutorLesson getLesson(LearnerLevel level, [int day = 1]) {
    if (day <= 1) {
      final base = lessons[level] ?? lessons[LearnerLevel.zero]!;
      if (level == LearnerLevel.zero && base.safariStages.isEmpty) {
        return _attachDay1ZeroSafari(base);
      }
      return base;
    }
    return _generateDayLesson(level, day);
  }

  static DayTutorLesson _attachDay1ZeroSafari(DayTutorLesson base) {
    return DayTutorLesson(
      day: 1,
      level: base.level,
      levelBadge: base.levelBadge,
      levelNameEn: base.levelNameEn,
      levelNameMl: base.levelNameMl,
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      icon: base.icon,
      teacherGreetingEn: base.teacherGreetingEn,
      teacherGreetingMl: base.teacherGreetingMl,
      turn0PromptEn: base.turn0PromptEn,
      turn0PromptMl: base.turn0PromptMl,
      turn0HintEn: base.turn0HintEn,
      turn0Suggestions: base.turn0Suggestions,
      turn0ExpectedKeywords: base.turn0ExpectedKeywords,
      turn1TitleEn: base.turn1TitleEn,
      turn1TitleMl: base.turn1TitleMl,
      turn1TeacherVoiceEn: base.turn1TeacherVoiceEn,
      turn1TeacherVoiceMl: base.turn1TeacherVoiceMl,
      turn1FormulaBricks: base.turn1FormulaBricks,
      turn1InsightEn: base.turn1InsightEn,
      turn1InsightMl: base.turn1InsightMl,
      turn2TitleEn: base.turn2TitleEn,
      turn2TitleMl: base.turn2TitleMl,
      turn2TeacherVoiceEn: base.turn2TeacherVoiceEn,
      turn2TeacherVoiceMl: base.turn2TeacherVoiceMl,
      turn2Examples: base.turn2Examples,
      turn3TargetPhrase: base.turn3TargetPhrase,
      turn3DisplayPhraseMl: base.turn3DisplayPhraseMl,
      turn3RecognizedKeywords: base.turn3RecognizedKeywords,
      turn3PraiseEn: base.turn3PraiseEn,
      gameType: base.gameType,
      gameTitle: base.gameTitle,
      gameInstructionEn: base.gameInstructionEn,
      gameInstructionMl: base.gameInstructionMl,
      gameData: base.gameData,
      safariStages: const [
        {
          'letter': 'A',
          'badge': '🅰️',
          'word': 'Apple',
          'emoji': '🍎',
          'phonics': '/æ/ sound',
          'introVoice': "This is A. A for Apple! What is A for? Say 'Apple'!",
          'introVoiceMl': "ഇത് A. A ഫോർ ആപ്പിൾ! 'Apple' എന്ന് മൈക്കിൽ പറയൂ!",
          'praiseVoice': "Purr-fect! You said Apple! Now pop the 🍎 Apple balloon in the sky!",
          'praiseVoiceMl': "ആകാശത്തിലെ ആപ്പിൾ 🍎 ബലൂണിൽ തൊട്ട് പൊട്ടിക്കുക!",
          'color': Color(0xFFEF4444),
          'bubbles': [
            {'id': 'a', 'label': '🅰️ Apple 🍎', 'isTarget': true},
            {'id': 'b', 'label': '🅱️ Ball ⚽', 'isTarget': false},
            {'id': 'c', 'label': '🅲 Cat 🐱', 'isTarget': false},
            {'id': 'd', 'label': '🅳 Dog 🐶', 'isTarget': false},
          ],
        },
        {
          'letter': 'B',
          'badge': '🅱️',
          'word': 'Ball',
          'emoji': '⚽',
          'phonics': '/b/ sound',
          'introVoice': "Look! This is Letter B! B says /b/ for Ball! What is B for? Say 'Ball'!",
          'introVoiceMl': "ഇത് B. B ഫോർ ബോൾ! 'Ball' എന്ന് പറയൂ!",
          'praiseVoice': "Bingo! You said Ball! Now pop the ⚽ Ball balloon in the sky!",
          'praiseVoiceMl': "ബോൾ ⚽ ബലൂണിൽ തൊട്ട് പൊട്ടിക്കുക!",
          'color': Color(0xFF0284C7),
          'bubbles': [
            {'id': 'b', 'label': '🅱️ Ball ⚽', 'isTarget': true},
            {'id': 'a', 'label': '🅰️ Apple 🍎', 'isTarget': false},
            {'id': 'c', 'label': '🅲 Cat 🐱', 'isTarget': false},
            {'id': 'e', 'label': '🅴 Elephant 🐘', 'isTarget': false},
          ],
        },
        {
          'letter': 'C',
          'badge': '🅲',
          'word': 'Cat',
          'emoji': '🐱',
          'phonics': '/k/ sound',
          'introVoice': "Look at Letter C! C says /k/ for Cat, like me CyberCat! What is C for? Say 'Cat'!",
          'introVoiceMl': "ഇത് C. C ഫോർ ക്യാറ്റ്! 'Cat' എന്ന് പറയൂ!",
          'praiseVoice': "Meow-velous! You said Cat! Now pop the 🐱 Cat balloon in the sky!",
          'praiseVoiceMl': "ക്യാറ്റ് 🐱 ബലൂണിൽ തൊട്ട് പൊട്ടിക്കുക!",
          'color': Color(0xFF10B981),
          'bubbles': [
            {'id': 'c', 'label': '🅲 Cat 🐱', 'isTarget': true},
            {'id': 'b', 'label': '🅱️ Ball ⚽', 'isTarget': false},
            {'id': 'a', 'label': '🅰️ Apple 🍎', 'isTarget': false},
            {'id': 'f', 'label': '🅵 Fish 🐟', 'isTarget': false},
          ],
        },
      ],
      victoryTitle: base.victoryTitle,
      victorySubtitleEn: base.victorySubtitleEn,
      victorySubtitleMl: base.victorySubtitleMl,
    );
  }

  static const List<Map<String, String>> _allAlphabetData = [
    {'letter': 'A', 'badge': '🅰️', 'word': 'Apple', 'emoji': '🍎', 'phonics': '/æ/ sound'},
    {'letter': 'B', 'badge': '🅱️', 'word': 'Ball', 'emoji': '⚽', 'phonics': '/b/ sound'},
    {'letter': 'C', 'badge': '🅲', 'word': 'Cat', 'emoji': '🐱', 'phonics': '/k/ sound'},
    {'letter': 'D', 'badge': '🅳', 'word': 'Dog', 'emoji': '🐶', 'phonics': '/d/ sound'},
    {'letter': 'E', 'badge': '🅴', 'word': 'Elephant', 'emoji': '🐘', 'phonics': '/e/ sound'},
    {'letter': 'F', 'badge': '🅵', 'word': 'Fish', 'emoji': '🐟', 'phonics': '/f/ sound'},
    {'letter': 'G', 'badge': '🅶', 'word': 'Grapes', 'emoji': '🍇', 'phonics': '/ɡ/ sound'},
    {'letter': 'H', 'badge': '🅷', 'word': 'Hat', 'emoji': '🎩', 'phonics': '/h/ sound'},
    {'letter': 'I', 'badge': '🅸', 'word': 'Ice Cream', 'emoji': '🍦', 'phonics': '/aɪ/ sound'},
    {'letter': 'J', 'badge': '🅹', 'word': 'Jug', 'emoji': '🏺', 'phonics': '/dʒ/ sound'},
    {'letter': 'K', 'badge': '🅺', 'word': 'Kite', 'emoji': '🪁', 'phonics': '/k/ sound'},
    {'letter': 'L', 'badge': '🅻', 'word': 'Lion', 'emoji': '🦁', 'phonics': '/l/ sound'},
    {'letter': 'M', 'badge': '🅼', 'word': 'Mango', 'emoji': '🥭', 'phonics': '/m/ sound'},
    {'letter': 'N', 'badge': '🅽', 'word': 'Net', 'emoji': '🥅', 'phonics': '/n/ sound'},
    {'letter': 'O', 'badge': '🅾️', 'word': 'Orange', 'emoji': '🍊', 'phonics': '/ɒ/ sound'},
    {'letter': 'P', 'badge': '🅿️', 'word': 'Parrot', 'emoji': '🦜', 'phonics': '/p/ sound'},
    {'letter': 'Q', 'badge': '🆀', 'word': 'Queen', 'emoji': '👑', 'phonics': '/kw/ sound'},
    {'letter': 'R', 'badge': '🆁', 'word': 'Ring', 'emoji': '💍', 'phonics': '/r/ sound'},
    {'letter': 'S', 'badge': '🆂', 'word': 'Sun', 'emoji': '☀️', 'phonics': '/s/ sound'},
    {'letter': 'T', 'badge': '🆃', 'word': 'Tree', 'emoji': '🌳', 'phonics': '/t/ sound'},
    {'letter': 'U', 'badge': '🆄', 'word': 'Umbrella', 'emoji': '☂️', 'phonics': '/ʌ/ sound'},
    {'letter': 'V', 'badge': '🆅', 'word': 'Van', 'emoji': '🚐', 'phonics': '/v/ sound'},
    {'letter': 'W', 'badge': '🆆', 'word': 'Watch', 'emoji': '⌚', 'phonics': '/w/ sound'},
    {'letter': 'X', 'badge': '🆇', 'word': 'Xylophone', 'emoji': '🎼', 'phonics': '/z/ sound'},
    {'letter': 'Y', 'badge': '🆈', 'word': 'Yak', 'emoji': '🐂', 'phonics': '/j/ sound'},
    {'letter': 'Z', 'badge': '🆉', 'word': 'Zebra', 'emoji': '🦓', 'phonics': '/z/ sound'},
  ];

  static DayTutorLesson _generateDayLesson(LearnerLevel level, int day) {
    final vocabList = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final track = PocketSyllabusRepository.getTrack(level);
    const mentorName = 'CyberCat';
    final masterDay = PocketMasterCurriculum90.getDay(day);

    switch (level) {
      case LearnerLevel.zero:
        return _generateZeroFoundationLesson(day, track, vocabList, mentorName, masterDay);
      case LearnerLevel.beginner:
        return _generateBeginnerLesson(day, track, vocabList, mentorName, masterDay);
      case LearnerLevel.elementary:
        return _generateElementaryLesson(day, track, vocabList, mentorName, masterDay);
      case LearnerLevel.middle:
        return _generateMiddleLesson(day, track, vocabList, mentorName, masterDay);
      case LearnerLevel.advanced:
        return _generateAdvancedLesson(day, track, vocabList, mentorName, masterDay);
      case LearnerLevel.expert:
        return _generateExpertLesson(day, track, vocabList, mentorName, masterDay);
    }
  }

  // -------------------------------------------------------------
  // TRACK 1: Zero Foundation Generator (Phonics & Visual Safari)
  // -------------------------------------------------------------
  static DayTutorLesson _generateZeroFoundationLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final List<Map<String, dynamic>> stages = [];

    if (day <= 9) {
      // Letters 3 per day
      final start = ((day - 1) * 3) % _allAlphabetData.length;
      for (int i = 0; i < 3; i++) {
        final item = _allAlphabetData[(start + i) % _allAlphabetData.length];
        final l = item['letter']!;
        final w = item['word']!;
        final e = item['emoji']!;
        final p = item['phonics']!;
        final other1 = _allAlphabetData[(start + i + 1) % _allAlphabetData.length];
        final other2 = _allAlphabetData[(start + i + 2) % _allAlphabetData.length];
        final other3 = _allAlphabetData[(start + i + 3) % _allAlphabetData.length];

        stages.add({
          'letter': l,
          'badge': item['badge'] ?? '🔤',
          'word': w,
          'emoji': e,
          'phonics': p,
          'introVoice': "This is Letter $l. $l is for $w $e! What is $l for? Say '$w'!",
          'introVoiceMl': "ഇത് $l. $l ഫോർ $w $e! '$w' എന്ന് മൈക്കിൽ പറയൂ!",
          'praiseVoice': "Great job! You said $w! Now pop the $w $e balloon in the sky!",
          'praiseVoiceMl': "ആകാശത്തിലെ $w $e ബലൂണിൽ തൊട്ട് പൊട്ടിക്കുക!",
          'color': i == 0
              ? const Color(0xFFEF4444)
              : (i == 1 ? const Color(0xFF0284C7) : const Color(0xFF10B981)),
          'bubbles': [
            {'id': l.toLowerCase(), 'label': '${item['badge']} $w $e', 'isTarget': true},
            {'id': other1['letter']!.toLowerCase(), 'label': '${other1['badge']} ${other1['word']} ${other1['emoji']}', 'isTarget': false},
            {'id': other2['letter']!.toLowerCase(), 'label': '${other2['badge']} ${other2['word']} ${other2['emoji']}', 'isTarget': false},
            {'id': other3['letter']!.toLowerCase(), 'label': '${other3['badge']} ${other3['word']} ${other3['emoji']}', 'isTarget': false},
          ],
        });
      }
    } else {
      // Days 10–90: Use Vocabulary items from Pocket90DayVocabCurriculum
      for (int i = 0; i < 3 && i < vocabList.length; i++) {
        final v = vocabList[i];
        final w = v.word;
        final ml = v.malayalamMeaning;
        final d = v.definition;
        final o1 = vocabList[(i + 1) % vocabList.length];
        final o2 = vocabList[(i + 2) % vocabList.length];
        final o3 = vocabList[(i + 3) % vocabList.length];

        stages.add({
          'letter': w.substring(0, 1).toUpperCase(),
          'badge': '⭐',
          'word': w,
          'emoji': '✨',
          'phonics': v.phonetic,
          'introVoice': "Word ${i + 1} is '$w'! $w means $d. Say '$w' with CyberCat!",
          'introVoiceMl': "വാക്ക് ${i + 1}: '$w' ($ml). '$w' എന്ന് ഉറക്കെ പറയൂ!",
          'praiseVoice': "Excellent! You said $w! Now tap and pop the $w balloon!",
          'praiseVoiceMl': "ആകാശത്തിലെ '$w' ബലൂണിൽ തൊട്ട് പൊട്ടിക്കുക!",
          'color': i == 0
              ? const Color(0xFFEF4444)
              : (i == 1 ? const Color(0xFF0284C7) : const Color(0xFF10B981)),
          'bubbles': [
            {'id': 'w_$i', 'label': '⭐ $w ✨', 'isTarget': true},
            {'id': 'o1_$i', 'label': '🔹 ${o1.word}', 'isTarget': false},
            {'id': 'o2_$i', 'label': '🔸 ${o2.word}', 'isTarget': false},
            {'id': 'o3_$i', 'label': '▫️ ${o3.word}', 'isTarget': false},
          ],
        });
      }
    }

    final targetWord = stages.isNotEmpty ? stages[0]['word'] as String : 'English';
    final targetLetter = stages.isNotEmpty ? stages[0]['letter'] as String : 'A';
    final targetEmoji = stages.isNotEmpty ? stages[0]['emoji'] as String : '🍎';

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.zero,
      levelBadge: '🌱 1. ZERO FOUNDATION',
      levelNameEn: 'Zero Foundation Track • Day $day',
      levelNameMl: 'ശൂന്യത്തിൽ നിന്നുള്ള അടിത്തറ • ദിവസം $day',
      primaryColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF047857),
      icon: Icons.abc_rounded,
      teacherGreetingEn: "This is Letter $targetLetter. $targetLetter for $targetWord! What is $targetLetter for?",
      teacherGreetingMl: "ഇത് $targetLetter. $targetLetter ഫോർ $targetWord $targetEmoji! $targetLetter ഫോർ എന്താണ്?",
      turn0PromptEn: "This is Letter $targetLetter. $targetLetter is for $targetWord! What is $targetLetter for? Tap the microphone and say: '$targetWord'!",
      turn0PromptMl: "ഇത് $targetLetter. $targetLetter ഫോർ $targetWord $targetEmoji! മൈക്കിൽ '$targetWord' എന്ന് പറയൂ:",
      turn0HintEn: 'Say: "$targetWord"',
      turn0Suggestions: [targetWord, 'Day $day Champion'],
      turn0ExpectedKeywords: [targetWord.toLowerCase()],
      turn1TitleEn: 'Day $day: ${masterDay.grammarConcept}',
      turn1TitleMl: 'ദിവസം $day അക്ഷര ശബ്ദങ്ങളും കളികളും',
      turn1TeacherVoiceEn: "Listen closely as $mentorName guides you through each sound! Today we focus on: ${masterDay.focusArea}.",
      turn1TeacherVoiceMl: "ഓരോ ശബ്ദവും ശ്രദ്ധയോടെ കേൾക്കുക!",
      turn1FormulaBricks: stages.map((s) {
        return FormulaBrickData(
          title: '${s['badge']} ${s['letter']}',
          subtitle: s['word'] as String,
          color: s['color'] as Color,
        );
      }).toList(),
      turn1InsightEn: "Speaking every day removes hesitation completely!",
      turn1InsightMl: "ദിവസവും കുറച്ചുനേരം സംസാരിച്ചാൽ ഇംഗ്ലീഷ് ഭയം മാറും!",
      turn2TitleEn: 'Daily Spoken Practice • Day $day',
      turn2TitleMl: 'നിത്യജീവിത സംഭാഷണ ശീലം',
      turn2TeacherVoiceEn: "Repeat with me aloud: '$targetWord'!",
      turn2TeacherVoiceMl: "'$targetWord' എന്ന് ഉറക്കെ പറഞ്ഞു ശീലിക്കുക!",
      turn2Examples: stages.map((s) => {'en': s['word'] as String, 'ml': s['phonics'] as String}).toList(),
      turn3TargetPhrase: targetWord,
      turn3DisplayPhraseMl: '"$targetWord"',
      turn3RecognizedKeywords: [targetWord.toLowerCase()],
      turn3PraiseEn: "Purr-fect! You pronounced Day $day like a champion! 🎉",
      gameType: Day1GameType.soundBubblePop,
      gameTitle: '🫧 Day $day Bubble Safari',
      gameInstructionEn: "Tap the floating balloon for '$targetWord'!",
      gameInstructionMl: "ആകാശത്തിലെ '$targetWord' ബലൂൺ പൊട്ടിക്കുക:",
      gameData: {
        'targetWord': targetWord,
        'bubbles': stages.isNotEmpty ? stages[0]['bubbles'] : [],
      },
      safariStages: stages,
      victoryTitle: 'Day $day Mastered! 🌟',
      victorySubtitleEn: "You conquered Day $day with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day വിജയകരമായി പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }

  // -------------------------------------------------------------
  // TRACK 2: Beginner Spoken English Generator (S+V+O Sentence Train)
  // -------------------------------------------------------------
  static DayTutorLesson _generateBeginnerLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final v1 = vocabList.isNotEmpty ? vocabList[0] : const DailyVocabItem(
      word: 'Practice', partOfSpeech: 'verb', definition: 'To do repeatedly',
      malayalamMeaning: 'പരിശീലിക്കുക', exampleSentence: 'I practice English.', phonetic: '/ˈpræk.tɪs/',
    );
    final v2 = vocabList.length > 1 ? vocabList[1] : const DailyVocabItem(
      word: 'Daily', partOfSpeech: 'adverb', definition: 'Every day',
      malayalamMeaning: 'ദിവസേന', exampleSentence: 'Study daily.', phonetic: '/ˈdeɪ.li/',
    );

    final isVerb = v1.partOfSpeech.toLowerCase().contains('verb');
    final targetSentence = isVerb
        ? 'I ${v1.word.toLowerCase()} English every day'
        : 'I use ${v1.word.toLowerCase()} in my daily life';
    final sentenceMl = isVerb
        ? 'ഞാൻ എല്ലാ ദിവസവും ഇംഗ്ലീഷ് ${v1.malayalamMeaning} ചെയ്യുന്നു.'
        : 'ഞാൻ എന്റെ നിത്യജീവിതത്തിൽ ${v1.malayalamMeaning} ഉപയോഗിക്കുന്നു.';

    final words = targetSentence.split(' ');
    // Deterministic shuffle for train
    final shuffled = List<String>.from(words);
    if (shuffled.length > 2) {
      final first = shuffled.removeAt(0);
      shuffled.add(first);
    }

    final contrastExamples = <Map<String, String>>[];
    if (masterDay.commonMistakes.isNotEmpty && masterDay.mistakeCorrections.isNotEmpty) {
      for (int i = 0; i < masterDay.commonMistakes.length && i < masterDay.mistakeCorrections.length && i < 2; i++) {
        contrastExamples.add({
          'en': masterDay.commonMistakes[i],
          'ml': masterDay.mistakeCorrections[i],
        });
      }
    } else {
      contrastExamples.add({'en': 'Direct Trap: I am agree ❌', 'ml': 'Natural English: I agree with you ✅'});
      contrastExamples.add({'en': 'Direct Trap: She don\'t know ❌', 'ml': 'Natural English: She doesn\'t know ✅'});
    }
    contrastExamples.add({'en': 'Day $day Practice: $targetSentence ✅', 'ml': sentenceMl});

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.beginner,
      levelBadge: track.badgeText,
      levelNameEn: '${track.nameEn} • Day $day',
      levelNameMl: '${track.nameNative} • ദിവസം $day',
      primaryColor: track.primaryColor,
      secondaryColor: const Color(0xFF0284C7),
      icon: track.icon,
      teacherGreetingEn: "Hello! I am $mentorName. Today on Day $day, we master '${masterDay.grammarConcept}' with '${v1.word}'!",
      teacherGreetingMl: "സ്വാഗതം! ഇന്ന് ഡേ $day-ൽ നമ്മൾ '${v1.word}' ഉപയോഗിച്ച് വാചകങ്ങൾ ഉണ്ടാക്കുന്നു.",
      turn0PromptEn: "Warm-up: Say '${v1.word}' loud and clear into your microphone!",
      turn0PromptMl: "'${v1.word}' എന്ന് ഉറക്കെ പറയൂ:",
      turn0HintEn: 'Say: "${v1.word}"',
      turn0Suggestions: [v1.word, 'I ${v1.word.toLowerCase()}'],
      turn0ExpectedKeywords: [v1.word.toLowerCase()],
      turn1TitleEn: 'Day $day Formula: ${masterDay.grammarConcept}',
      turn1TitleMl: 'ശരിയായ വാചക നിർമ്മാണ ക്രമം (Subject + Verb + Object)',
      turn1TeacherVoiceEn: masterDay.theoryExplanationEn.isNotEmpty
          ? masterDay.theoryExplanationEn
          : "In English, never think in Malayalam word order. Keep Subject first, Action second, Context third!",
      turn1TeacherVoiceMl: masterDay.theoryExplanationMl.isNotEmpty
          ? masterDay.theoryExplanationMl
          : "മലയാളത്തിലെ പോലെ ക്രിയ അവസാനം പറയരുത്. കർത്താവ്, തുടർന്ന് പ്രവൃത്തി, അവസാനം ബാക്കി വിവരങ്ങൾ ചേർക്കുക!",
      turn1FormulaBricks: [
        FormulaBrickData(title: 'Subject: I', subtitle: 'ആര് (ഞാൻ)', color: track.primaryColor),
        FormulaBrickData(title: 'Action: ${v1.word}', subtitle: v1.malayalamMeaning, color: const Color(0xFF06B6D4)),
        FormulaBrickData(title: 'Context: ${v2.word}', subtitle: v2.malayalamMeaning, color: const Color(0xFF10B981)),
      ],
      turn1InsightEn: "Following S-V-O breaks Malayalam sentence translation habits immediately!",
      turn1InsightMl: "ഇംഗ്ലീഷിൽ നേരിട്ട് ചിന്തിക്കാൻ S-V-O ഫോർമുല സഹായിക്കുന്നു!",
      turn2TitleEn: 'Malayalam Direct Translation Trap vs Natural English',
      turn2TitleMl: 'സാധാരണ സംഭവിക്കുന്ന തെറ്റുകളും ശരിയായ രീതിയും',
      turn2TeacherVoiceEn: "Watch how direct Malayalam thinking leads to errors, and how we fix it:",
      turn2TeacherVoiceMl: "നേരിട്ട് വിവർത്തനം ചെയ്യുമ്പോൾ സംഭവിക്കുന്ന പിഴവുകൾ ഒഴിവാക്കുക:",
      turn2Examples: contrastExamples,
      turn3TargetPhrase: targetSentence,
      turn3DisplayPhraseMl: '"$sentenceMl"',
      turn3RecognizedKeywords: [v1.word.toLowerCase(), 'every', 'day', 'english', 'i'],
      turn3PraiseEn: "Outstanding pronunciation! You constructed that full sentence flawlessly! 🎉",
      gameType: Day1GameType.sentenceTrainPuzzle,
      gameTitle: '🚂 Day $day Sentence Train Builder',
      gameInstructionEn: "Arrange the train cars in grammatical order to form: '$targetSentence'!",
      gameInstructionMl: "ട്രെയിൻ ബോഗികൾ ശരിയായ ക്രമത്തിൽ ടാപ്പ് ചെയ്ത് വാചകം പൂർത്തിയാക്കുക:",
      gameData: {
        'shuffledWords': shuffled,
        'correctOrder': words,
      },
      victoryTitle: 'Beginner Builder Leveled Up! 🚂',
      victorySubtitleEn: "You mastered Day $day sentence structure with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day വാചക നിർമ്മാണം വിജയകരമായി പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }

  // -------------------------------------------------------------
  // TRACK 3: Elementary Daily Reflex Generator (Rapid Q&A Timer)
  // -------------------------------------------------------------
  static DayTutorLesson _generateElementaryLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final v1 = vocabList.isNotEmpty ? vocabList[0] : const DailyVocabItem(
      word: 'Respond', partOfSpeech: 'verb', definition: 'To answer promptly',
      malayalamMeaning: 'പ്രതികരിക്കുക', exampleSentence: 'Respond quickly.', phonetic: '/rɪˈspɒnd/',
    );

    final reflexQuestion = "Do you ${v1.word.toLowerCase()} every single day?";
    final reflexAnswer = "Yes, I ${v1.word.toLowerCase()} every single day!";
    final questionMl = "നിങ്ങൾ എല്ലാ ദിവസവും ${v1.malayalamMeaning} ചെയ്യാറുണ്ടോ?";

    final contrastExamples = <Map<String, String>>[];
    if (masterDay.commonMistakes.isNotEmpty && masterDay.mistakeCorrections.isNotEmpty) {
      for (int i = 0; i < masterDay.commonMistakes.length && i < masterDay.mistakeCorrections.length && i < 2; i++) {
        contrastExamples.add({
          'en': masterDay.commonMistakes[i],
          'ml': masterDay.mistakeCorrections[i],
        });
      }
    } else {
      contrastExamples.add({'en': 'Q: Are you ready to begin? ⚡', 'ml': 'A: Absolutely, let\'s dive right in! ✅'});
      contrastExamples.add({'en': 'Q: Did you check the update? ⚡', 'ml': 'A: Yes, looked at it just now! ✅'});
    }
    contrastExamples.add({'en': 'Q: $reflexQuestion ⚡', 'ml': 'A: $reflexAnswer ✅'});

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.elementary,
      levelBadge: track.badgeText,
      levelNameEn: '${track.nameEn} • Day $day',
      levelNameMl: '${track.nameNative} • ദിവസം $day',
      primaryColor: track.primaryColor,
      secondaryColor: const Color(0xFFD97706),
      icon: track.icon,
      teacherGreetingEn: "Welcome to Day $day Reflex Arena with $mentorName! Today's rule: ${masterDay.grammarConcept}. True fluency is speed without hesitation.",
      teacherGreetingMl: "സ്വാഗതം! ഇന്ന് ഡേ $day-ൽ ആലോചിച്ചു നിൽക്കാതെ ഞൊടിയിടയിൽ മറുപടി പറയാൻ പരിശീലിക്കാം!",
      turn0PromptEn: "Reflex check! Answer immediately: Say 'Yes, absolutely!'",
      turn0PromptMl: "'Yes, absolutely!' എന്ന് വേഗത്തിൽ പറയൂ:",
      turn0HintEn: 'Say: "Yes, absolutely!"',
      turn0Suggestions: ['Yes, absolutely!', 'Right away'],
      turn0ExpectedKeywords: ['yes', 'absolutely'],
      turn1TitleEn: '3-Second Reflex: ${masterDay.grammarConcept}',
      turn1TitleMl: '3 സെക്കൻഡ് റിഫ്ലെക്സ് സൂത്രം',
      turn1TeacherVoiceEn: masterDay.theoryExplanationEn.isNotEmpty
          ? masterDay.theoryExplanationEn
          : "When asked a question, do not pause to translate. Fire back with an auxiliary verb confirmation immediately!",
      turn1TeacherVoiceMl: masterDay.theoryExplanationMl.isNotEmpty
          ? masterDay.theoryExplanationMl
          : "ചോദ്യം കേൾക്കുമ്പോൾ മലയാളത്തിൽ ചിന്തിച്ചു നിൽക്കരുത്. ഉടനടി 'Yes, I...' എന്ന് തുടങ്ങി പൂർത്തിയാക്കുക!",
      turn1FormulaBricks: [
        FormulaBrickData(title: 'Trigger: Do you...', subtitle: 'ചോദ്യ തുടക്കം', color: track.primaryColor),
        FormulaBrickData(title: 'Action: ${v1.word}', subtitle: v1.malayalamMeaning, color: const Color(0xFF0284C7)),
        FormulaBrickData(title: 'Reflex: Yes, I always...', subtitle: 'തൽക്ഷണ മറുപടി', color: const Color(0xFF10B981)),
      ],
      turn1InsightEn: "Instant spoken replies build neural muscle memory for spontaneous English!",
      turn1InsightMl: "പെട്ടെന്നുള്ള മറുപടികൾ വഴി മനസ്സ് ഇംഗ്ലീഷിനെ ഒരു സ്വഭാവിക പ്രതികരണമായി മാറ്റുന്നു!",
      turn2TitleEn: 'Hesitant Pauses vs Instant Daily Reflexes',
      turn2TitleMl: 'ആലോചിച്ചു നിൽക്കുന്നതിന് പകരം പെട്ടെന്ന് പറയേണ്ട ശൈലികൾ',
      turn2TeacherVoiceEn: "Notice the difference between awkward pauses and crisp spoken reflexes:",
      turn2TeacherVoiceMl: "നിത്യജീവിതത്തിലെ ചടുലമായ സംഭാഷണ രീതികൾ:",
      turn2Examples: contrastExamples,
      turn3TargetPhrase: reflexAnswer,
      turn3DisplayPhraseMl: '"അതെ, ഞാൻ ദിവസവും ${v1.malayalamMeaning} ചെയ്യുന്നു!"',
      turn3RecognizedKeywords: ['yes', v1.word.toLowerCase(), 'every', 'single', 'day'],
      turn3PraiseEn: "Incredible quick reflex! You spoke without a microsecond of hesitation! ⚡",
      gameType: Day1GameType.rapidReflexTimer,
      gameTitle: '⚡ Day $day Rapid Spoken Reflex',
      gameInstructionEn: "The timer is running! Tap and speak the natural instant response within 5 seconds:",
      gameInstructionMl: "5 സെക്കൻഡിനുള്ളിൽ ശരിയായ മറുപടി തെരഞ്ഞെടുക്കുക ($questionMl):",
      gameData: {
        'prompt': reflexQuestion,
        'options': [
          reflexAnswer,
          "No, I am ${v1.word.toLowerCase()}ing not today.",
          "Yesterday I will ${v1.word.toLowerCase()} maybe.",
        ],
        'correctIndex': 0,
      },
      victoryTitle: 'Lightning Reflex Mastered! ⚡',
      victorySubtitleEn: "You crushed Day $day rapid responses with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day തൽക്ഷണ ഇംഗ്ലീഷ് മറുപടി പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }

  // -------------------------------------------------------------
  // TRACK 4: Middle Fluency Bridge Generator (Bridge Connectors)
  // -------------------------------------------------------------
  static DayTutorLesson _generateMiddleLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final v1 = vocabList.isNotEmpty ? vocabList[0] : const DailyVocabItem(
      word: 'Collaborate', partOfSpeech: 'verb', definition: 'To work together',
      malayalamMeaning: 'ഒരുമിച്ച് പ്രവർത്തിക്കുക', exampleSentence: 'We collaborate daily.', phonetic: '/kəˈlæb.ə.reɪt/',
    );

    // Rotate connector based on day
    final connectors = ['Because', 'Although', 'Therefore', 'Since'];
    final selectedConnector = connectors[day % connectors.length];

    String clause1;
    String clause2;
    String targetPhrase;

    switch (selectedConnector) {
      case 'Although':
        clause1 = "Although ${v1.word.toLowerCase()} takes consistent effort";
        clause2 = "it produces remarkable results for our team";
        targetPhrase = "Although ${v1.word.toLowerCase()} takes effort, it produces remarkable results.";
        break;
      case 'Therefore':
        clause1 = "We prioritized effective ${v1.word.toLowerCase()}";
        clause2 = "therefore our communication improved tremendously";
        targetPhrase = "We prioritized ${v1.word.toLowerCase()}, therefore our communication improved.";
        break;
      case 'Since':
        clause1 = "Since ${v1.word.toLowerCase()} is essential for progress";
        clause2 = "we allocate dedicated time for it";
        targetPhrase = "Since ${v1.word.toLowerCase()} is essential, we allocate dedicated time for it.";
        break;
      case 'Because':
      default:
        clause1 = "Our team succeeded in this milestone";
        clause2 = "because we decided to ${v1.word.toLowerCase()} actively";
        targetPhrase = "Our team succeeded because we decided to ${v1.word.toLowerCase()} actively.";
        break;
    }

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.middle,
      levelBadge: track.badgeText,
      levelNameEn: '${track.nameEn} • Day $day',
      levelNameMl: '${track.nameNative} • ദിവസം $day',
      primaryColor: track.primaryColor,
      secondaryColor: const Color(0xFF7C3AED),
      icon: track.icon,
      teacherGreetingEn: "Welcome to Day $day Bridge Architecture with $mentorName! Today we command: ${masterDay.grammarConcept}.",
      teacherGreetingMl: "സ്വാഗതം! ഇന്ന് ഡേ $day-ൽ ചെറിയ ചെറിയ വാചകങ്ങൾ ഒഴിവാക്കി കണക്റ്ററുകൾ വഴി ഒഴുക്കോടെ സംസാരിക്കാം.",
      turn0PromptEn: "Warm-up: Say the bridge word '$selectedConnector' into your microphone!",
      turn0PromptMl: "'$selectedConnector' എന്ന് ഉറക്കെ പറയൂ:",
      turn0HintEn: 'Say: "$selectedConnector"',
      turn0Suggestions: [selectedConnector, 'Bridge Flow'],
      turn0ExpectedKeywords: [selectedConnector.toLowerCase()],
      turn1TitleEn: 'Clause Architecture: ${masterDay.grammarConcept}',
      turn1TitleMl: 'രണ്ട് ആശയങ്ങളെ ഭംഗിയായി ബന്ധിപ്പിക്കുന്ന ബ്രിഡ്ജ് രീതി',
      turn1TeacherVoiceEn: masterDay.theoryExplanationEn.isNotEmpty
          ? masterDay.theoryExplanationEn
          : "Intermediate speakers get trapped speaking in short, choppy sentences. Bridges like '$selectedConnector' create smooth conversational rhythm.",
      turn1TeacherVoiceMl: masterDay.theoryExplanationMl.isNotEmpty
          ? masterDay.theoryExplanationMl
          : "മുറിഞ്ഞുപോകാതെ തുടർച്ചയായി സംസാരിക്കാൻ കണക്റ്ററുകൾ അത്യന്താപേക്ഷിതമാണ്.",
      turn1FormulaBricks: [
        FormulaBrickData(title: 'Clause 1: Foundation', subtitle: 'ആദ്യ ആശയം', color: track.primaryColor),
        FormulaBrickData(title: 'Bridge: $selectedConnector', subtitle: 'ബന്ധിപ്പിക്കുന്ന വാക്ക്', color: const Color(0xFFF59E0B)),
        FormulaBrickData(title: 'Clause 2: Extension', subtitle: 'കാരണം / ഫലം', color: const Color(0xFF10B981)),
      ],
      turn1InsightEn: "Connectors elevate your conversational flow from basic to natural intermediate fluency!",
      turn1InsightMl: "കണക്റ്ററുകൾ ഉപയോഗിച്ച് സംസാരിക്കുമ്പോൾ ശ്രോതാവിന് കൂടുതൽ വ്യക്തത ലഭിക്കുന്നു!",
      turn2TitleEn: 'Choppy Short Phrases vs Smooth Bridge Flow',
      turn2TitleMl: 'ചെറിയ വാചകങ്ങളും ഒഴുക്കുള്ള സംസാരവും തമ്മിലുള്ള വ്യത്യാസം',
      turn2TeacherVoiceEn: "Observe how a bridge connector upgrades basic sentences into professional speech:",
      turn2TeacherVoiceMl: "വാചകങ്ങൾ കൂടുതൽ നിലവാരമുള്ളതാക്കുന്ന രീതി ശ്രദ്ധിക്കൂ:",
      turn2Examples: [
        {'en': 'Choppy: It was difficult. We did it. ❌', 'ml': 'Bridge: Although it was difficult, we achieved the target. ✅'},
        {'en': 'Choppy: I was busy. I missed the call. ❌', 'ml': 'Bridge: Because my schedule was packed, I couldn\'t answer. ✅'},
        {'en': 'Day $day Synthesis: $targetPhrase ✅', 'ml': 'കണക്റ്റർ ചേർത്തുള്ള പൂർണ്ണ വാചകം.'},
      ],
      turn3TargetPhrase: targetPhrase,
      turn3DisplayPhraseMl: '"$targetPhrase"',
      turn3RecognizedKeywords: [selectedConnector.toLowerCase(), v1.word.toLowerCase()],
      turn3PraiseEn: "Splendid bridge flow! That compound sentence rolled off your tongue with natural elegance! 🌉",
      gameType: Day1GameType.bridgeConnector,
      gameTitle: '🌉 Day $day Bridge Connector Puzzle',
      gameInstructionEn: "Connect the two ideas into one unified thought. Pick the best connector:",
      gameInstructionMl: "രണ്ട് ആശയങ്ങളെ ബന്ധിപ്പിക്കാൻ ഏറ്റവും അനുയോജ്യമായ കണക്റ്റർ തെരഞ്ഞെടുക്കുക:",
      gameData: {
        'clause1': clause1,
        'clause2': clause2,
        'connectors': ['Because', 'Although', 'Therefore', 'However'],
        'correctConnector': selectedConnector,
      },
      victoryTitle: 'Fluency Bridge Built! 🌉',
      victorySubtitleEn: "You mastered Day $day complex sentence linking with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day കണക്റ്റിംഗ് വാചകങ്ങൾ പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }

  // -------------------------------------------------------------
  // TRACK 5: Advanced Workplace / Corporate Fluency (Boardroom Diplomacy)
  // -------------------------------------------------------------
  static DayTutorLesson _generateAdvancedLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final v1 = vocabList.isNotEmpty ? vocabList[0] : const DailyVocabItem(
      word: 'Strategic', partOfSpeech: 'adjective', definition: 'Carefully designed for long-term advantage',
      malayalamMeaning: 'തന്ത്രപരമായ', exampleSentence: 'A strategic approach.', phonetic: '/strəˈtiː.dʒɪk/',
    );

    final clientChallenge = '"Why wasn\'t the ${v1.word.toLowerCase()} deliverable completed before our morning call?"';
    final executiveResponse = "I understand the urgency regarding ${v1.word.toLowerCase()}; let us review the key priorities together so we can align on immediate delivery.";

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.advanced,
      levelBadge: track.badgeText,
      levelNameEn: '${track.nameEn} • Day $day',
      levelNameMl: '${track.nameNative} • ദിവസം $day',
      primaryColor: track.primaryColor,
      secondaryColor: const Color(0xFF0369A1),
      icon: track.icon,
      teacherGreetingEn: "Welcome to Day $day Executive Chamber with $mentorName! Focus: ${masterDay.grammarConcept}. Leaders do not react; they frame, steer, and align.",
      teacherGreetingMl: "സ്വാഗതം! ഇന്ന് ഡേ $day-ൽ ബോർഡ്റൂമിലും മീറ്റിംഗുകളിലും ആത്മവിശ്വാസത്തോടെയുള്ള എക്സിക്യൂട്ടീവ് ശൈലി പരിശീലിക്കാം.",
      turn0PromptEn: "Warm-up: Say 'I see your perspective' into your microphone!",
      turn0PromptMl: "'I see your perspective' എന്ന് പക്വതയോടെ പറയൂ:",
      turn0HintEn: 'Say: "I see your perspective"',
      turn0Suggestions: ['I see your perspective', 'Let us align'],
      turn0ExpectedKeywords: ['perspective', 'see your'],
      turn1TitleEn: 'Executive Framing: ${masterDay.grammarConcept}',
      turn1TitleMl: 'എക്സിക്യൂട്ടീവ് ഡിപ്ലോമസി ഫോർമുല',
      turn1TeacherVoiceEn: masterDay.theoryExplanationEn.isNotEmpty
          ? masterDay.theoryExplanationEn
          : "Never say 'That is wrong' or get defensive in professional negotiations. Validate the intent, pivot diplomatically, and propose a solution.",
      turn1TeacherVoiceMl: masterDay.theoryExplanationMl.isNotEmpty
          ? masterDay.theoryExplanationMl
          : "'അത് ഞങ്ങളുടെ കുഴപ്പമല്ല' എന്ന് പരുഷമായി പറയുന്നതിന് പകരം, കാര്യങ്ങൾ ഡിപ്ലോമാറ്റിക് ആയി അവതരിപ്പിക്കുക.",
      turn1FormulaBricks: [
        FormulaBrickData(title: 'I understand the urgency,', subtitle: 'Validation (സാഹചര്യത്തെ മാനിക്കൽ)', color: const Color(0xFF0284C7)),
        FormulaBrickData(title: 'let us review priorities,', subtitle: 'Tactical Pivot (ശ്രദ്ധ തിരിക്കൽ)', color: const Color(0xFFF97316)),
        FormulaBrickData(title: 'so we can align on delivery.', subtitle: 'Constructive Solution (പരിഹാരം)', color: const Color(0xFF10B981)),
      ],
      turn1InsightEn: "Diplomatic assertion commands boardroom respect and prevents unnecessary conflicts!",
      turn1InsightMl: "നയപരമായ ഇംഗ്ലീഷ് സംഭാഷണം നിങ്ങളുടെ ലീഡർഷിപ്പ് മികവ് എടുത്തുകാണിക്കുന്നു!",
      turn2TitleEn: 'Blunt Responses vs Polished Executive Phrasing',
      turn2TitleMl: 'പരുഷമായതും പ്രൊഫഷണലായതുമായ ശൈലികൾ തമ്മിലുള്ള വ്യത്യാസം',
      turn2TeacherVoiceEn: "Observe how executive phrasing changes how clients perceive your capability:",
      turn2TeacherVoiceMl: "കോർപ്പറേറ്റ് നിലവാരത്തിലുള്ള സംഭാഷണ മാതൃകകൾ:",
      turn2Examples: [
        {'en': 'Blunt: That deadline is impossible. ❌', 'ml': 'Executive: To safeguard quality, let us phase the launch into two sprints. ✅'},
        {'en': 'Blunt: You never explained that. ❌', 'ml': 'Executive: Could you unpack that specific requirement in more detail? ✅'},
        {'en': 'Blunt: That won\'t work with ${v1.word.toLowerCase()}. ❌', 'ml': 'Executive: We might encounter operational bottlenecks with ${v1.word.toLowerCase()}. ✅'},
      ],
      turn3TargetPhrase: executiveResponse,
      turn3DisplayPhraseMl: '"സാഹചര്യത്തിന്റെ ഗൗരവം മനസ്സിലാക്കുന്നു; ഉടൻ തന്നെ കാര്യങ്ങൾ പൂർത്തിയാക്കാൻ നമുക്ക് ഒരുമിച്ച് മുൻഗണനകൾ നിശ്ചയിക്കാം."',
      turn3RecognizedKeywords: ['urgency', v1.word.toLowerCase(), 'priorities', 'align', 'delivery'],
      turn3PraiseEn: "Masterful corporate diplomacy! That commands executive presence and stakeholder trust! 💼",
      gameType: Day1GameType.boardroomDiplomacy,
      gameTitle: '🏢 Day $day Boardroom Diplomacy Simulator',
      gameInstructionEn: 'Stakeholder challenges you: $clientChallenge Select and speak the diplomatic executive response:',
      gameInstructionMl: 'വെല്ലുവിളി നിറഞ്ഞ സാഹചര്യത്തിൽ ഏറ്റവും ഡിപ്ലോമാറ്റിക് ആയ മറുപടി തെരഞ്ഞെടുക്കുക:',
      gameData: {
        'clientStatement': clientChallenge,
        'options': [
          "That was not in our scope, so please do not blame us.",
          executiveResponse,
          "Sorry, we will just do whatever you say right now.",
        ],
        'correctIndex': 1,
      },
      victoryTitle: 'Executive Poise Mastered! 💼',
      victorySubtitleEn: "You negotiated Day $day high-stakes diplomacy with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day കോർപ്പറേറ്റ് ഇംഗ്ലീഷ് ശൈലി വിജയകരമായി സ്വായത്തമാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }

  // -------------------------------------------------------------
  // TRACK 6: Expert Peak Fluency Generator (Debate Rebuttal Arena)
  // -------------------------------------------------------------
  static DayTutorLesson _generateExpertLesson(
      int day, SyllabusTrack track, List<DailyVocabItem> vocabList, String mentorName, MasterCurriculumDay masterDay) {
    final v1 = vocabList.isNotEmpty ? vocabList[0] : const DailyVocabItem(
      word: 'Paradigm', partOfSpeech: 'noun', definition: 'A typical example or pattern of something',
      malayalamMeaning: 'മാതൃക / കാഴ്ചപ്പാട്', exampleSentence: 'A new paradigm shift.', phonetic: '/ˈpær.ə.daɪm/',
    );

    final opponentAssertion = '"In this era of hyper-automation, human expertise in ${v1.word.toLowerCase()} is fundamentally obsolete."';
    final recommendedRebuttal = "While superficially persuasive, that assertion conflates automated mechanical execution with authentic human discernment.";

    return DayTutorLesson(
      day: day,
      level: LearnerLevel.expert,
      levelBadge: track.badgeText,
      levelNameEn: '${track.nameEn} • Day $day',
      levelNameMl: '${track.nameNative} • ദിവസം $day',
      primaryColor: track.primaryColor,
      secondaryColor: const Color(0xFFB45309),
      icon: track.icon,
      teacherGreetingEn: "Welcome to Day $day Apex Oratory with $mentorName! Rhetorical dialectic: ${masterDay.grammarConcept}. True eloquence is spontaneous, nuanced, and rhetorically devastating.",
      teacherGreetingMl: "സ്വാഗതം! ഇന്ന് ഡേ $day-ൽ അന്താരാഷ്ട്ര നിലവാരത്തിലുള്ള ലൈവ് ഡിബേറ്റ് വാക്ചാതുര്യം പരിശീലിക്കാം.",
      turn0PromptEn: "Warm-up: Say 'While superficially persuasive' into your microphone!",
      turn0PromptMl: "'While superficially persuasive' എന്ന് ഗാംഭീര്യത്തോടെ പറയൂ:",
      turn0HintEn: 'Say: "While superficially persuasive"',
      turn0Suggestions: ['While superficially persuasive', 'Paradoxically speaking'],
      turn0ExpectedKeywords: ['superficially', 'persuasive', 'while'],
      turn1TitleEn: 'Apex Rhetoric: ${masterDay.grammarConcept}',
      turn1TitleMl: 'വാദമുഖങ്ങളെ യുക്തിസഹമായി നേരിടുന്ന വാക്ചാതുര്യ തന്ത്രം',
      turn1TeacherVoiceEn: masterDay.theoryExplanationEn.isNotEmpty
          ? masterDay.theoryExplanationEn
          : "Apex orators never shout down opposition. Concede the surface appearance, deconstruct the underlying fallacy, and deliver the synthesized truth.",
      turn1TeacherVoiceMl: masterDay.theoryExplanationMl.isNotEmpty
          ? masterDay.theoryExplanationMl
          : "എതിർവാദത്തെ നേരിട്ട് എതിർക്കാതെ, അതിലെ യുക്തിപരമായ പോരായ്മകളെ നയപരമായി തുറന്നുകാട്ടുക.",
      turn1FormulaBricks: [
        FormulaBrickData(title: 'While superficially persuasive,', subtitle: 'Rhetorical Concession (പ്രാഥമിക അനുവാദം)', color: const Color(0xFFFFD700)),
        FormulaBrickData(title: 'that assertion conflates...', subtitle: 'Analytical Deconstruction (വിശകലനം)', color: const Color(0xFFF59E0B)),
        FormulaBrickData(title: '...with authentic discernment.', subtitle: 'Definitive Synthesis (നിഗമനം)', color: const Color(0xFF10B981)),
      ],
      turn1InsightEn: "Nuanced rhetoric commands respect on global stages, academic panels, and international keynotes!",
      turn1InsightMl: "ആഴത്തിലുള്ള ഭാഷാപ്രയോഗങ്ങൾ നിങ്ങളുടെ സംസാരത്തിന് അന്താരാഷ്ട്ര നിലവാരം നൽകുന്നു!",
      turn2TitleEn: 'Pedestrian Disagreement vs Apex Rhetorical Poise',
      turn2TitleMl: 'സാധാരണ തർക്കവും പ്രഗത്ഭമായ വാദപ്രതിവാദ ശൈലിയും തമ്മിലുള്ള അന്തരം',
      turn2TeacherVoiceEn: "Notice how high-level rhetoric reframes heated arguments into intellectual mastery:",
      turn2TeacherVoiceMl: "വാക്ചാതുര്യത്തിന്റെ ഉയർന്ന തലങ്ങൾ:",
      turn2Examples: [
        {'en': 'Pedestrian: I totally disagree with your point. ❌', 'ml': 'Apex: That premise rests upon an unsubstantiated foundation. ✅'},
        {'en': 'Pedestrian: Everyone knows that is wrong. ❌', 'ml': 'Apex: Popular consensus cannot substitute for rigorous empirical inquiry. ✅'},
        {'en': 'Pedestrian: You are wrong about ${v1.word.toLowerCase()}. ❌', 'ml': 'Apex: That perspective conflates correlation with causation in ${v1.word.toLowerCase()}. ✅'},
      ],
      turn3TargetPhrase: recommendedRebuttal,
      turn3DisplayPhraseMl: '"മേൽനോട്ടത്തിൽ ആകർഷകമെന്നു തോന്നാമെങ്കിലും, ആ വാദം യഥാർത്ഥ തിരിച്ചറിവിനെ വെറും സാങ്കേതികതയുമായി കൂട്ടിക്കുഴയ്ക്കുന്നു."',
      turn3RecognizedKeywords: ['persuasive', 'assertion', 'conflates', 'human', 'discernment'],
      turn3PraiseEn: "Mesmerizing oratorical cadence! Your delivery was majestic, nuanced, and intellectually piercing! 👑",
      gameType: Day1GameType.debateRebuttalArena,
      gameTitle: '🎙️ Day $day Live Debate Rebuttal Arena',
      gameInstructionEn: 'AI Debater asserts: $opponentAssertion Deliver your sharp 30-second rhetorical counter-argument:',
      gameInstructionMl: 'AI ഉന്നയിക്കുന്ന വാദത്തിനെതിരെ ലൈവ് മൈക്കിൽ ചടുലമായ ഇംഗ്ലീഷിൽ മറുപടി നൽകുക:',
      gameData: {
        'opponentAssertion': opponentAssertion,
        'recommendedRebuttal': recommendedRebuttal,
        'keywords': ['persuasive', 'assertion', 'conflates', 'human', 'discernment'],
      },
      victoryTitle: 'Apex Orator Crowned! 👑',
      victorySubtitleEn: "You commanded Day $day rhetoric and live debate with $mentorName! +30 Score Earned!",
      victorySubtitleMl: "നിങ്ങൾ ദിവസം $day വാക്ചാതുര്യത്തോടെ വിജയകരമായി പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!",
    );
  }
}

typedef Pocket90DayTutorCurriculum = PocketDay1TutorCurriculum;
