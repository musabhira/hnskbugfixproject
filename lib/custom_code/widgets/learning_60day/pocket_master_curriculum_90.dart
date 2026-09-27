import 'pocket_90day_vocab_curriculum.dart';
import 'pocket_master_curriculum_phase1.dart';
import 'pocket_master_curriculum_phase2.dart';
import 'pocket_master_curriculum_phase3.dart';

// 🏛️ Master 90-Day Progressive English Curriculum Engine
// Each day from 1 to 90 is individually crafted to ensure zero information overload,
// progressive difficulty scaling, and systematic coverage of all linguistic pillars.

class CurriculumVocabItem {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningMl;
  final String exampleEn;
  final String exampleMl;

  const CurriculumVocabItem({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningMl,
    required this.exampleEn,
    this.exampleMl = '',
  });
}

class MasterCurriculumDay {
  final int day;
  final String title;
  final String phaseName;
  final String focusArea;
  final String grammarConcept;
  final String speakingDrill;
  final String peerChatMission;
  final int targetMinutes;
  final int xpReward;
  final String milestoneReward;
  final String theoryConcept;
  final String theoryExplanationEn;
  final String theoryExplanationMl;
  final String whyItMatters;
  final List<String> commonMistakes;
  final List<String> mistakeCorrections;
  final List<CurriculumVocabItem> vocabulary;
  final List<String> sentenceEvolution;
  final String dailyChallenge;
  final String listeningGoal;

  const MasterCurriculumDay({
    required this.day,
    required this.title,
    required this.phaseName,
    required this.focusArea,
    required this.grammarConcept,
    required this.speakingDrill,
    required this.peerChatMission,
    this.targetMinutes = 75,
    this.xpReward = 50,
    this.milestoneReward = '',
    this.theoryConcept = '',
    this.theoryExplanationEn = '',
    this.theoryExplanationMl = '',
    this.whyItMatters = '',
    this.commonMistakes = const [],
    this.mistakeCorrections = const [],
    this.vocabulary = const [],
    this.sentenceEvolution = const [],
    this.dailyChallenge = '',
    this.listeningGoal = '',
  });

  MasterCurriculumDay copyWith({
    int? day,
    String? title,
    String? phaseName,
    String? focusArea,
    String? grammarConcept,
    String? speakingDrill,
    String? peerChatMission,
    int? targetMinutes,
    int? xpReward,
    String? milestoneReward,
    String? theoryConcept,
    String? theoryExplanationEn,
    String? theoryExplanationMl,
    String? whyItMatters,
    List<String>? commonMistakes,
    List<String>? mistakeCorrections,
    List<CurriculumVocabItem>? vocabulary,
    List<String>? sentenceEvolution,
    String? dailyChallenge,
    String? listeningGoal,
  }) {
    return MasterCurriculumDay(
      day: day ?? this.day,
      title: title ?? this.title,
      phaseName: phaseName ?? this.phaseName,
      focusArea: focusArea ?? this.focusArea,
      grammarConcept: grammarConcept ?? this.grammarConcept,
      speakingDrill: speakingDrill ?? this.speakingDrill,
      peerChatMission: peerChatMission ?? this.peerChatMission,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      xpReward: xpReward ?? this.xpReward,
      milestoneReward: milestoneReward ?? this.milestoneReward,
      theoryConcept: theoryConcept ?? this.theoryConcept,
      theoryExplanationEn: theoryExplanationEn ?? this.theoryExplanationEn,
      theoryExplanationMl: theoryExplanationMl ?? this.theoryExplanationMl,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      mistakeCorrections: mistakeCorrections ?? this.mistakeCorrections,
      vocabulary: vocabulary ?? this.vocabulary,
      sentenceEvolution: sentenceEvolution ?? this.sentenceEvolution,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      listeningGoal: listeningGoal ?? this.listeningGoal,
    );
  }
}

class PocketMasterCurriculum90 {
  static MasterCurriculumDay getDay(int day) {
    final base =
        _days.containsKey(day) ? _days[day]! : _generateDynamicDay(day);
    final dynamicVocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    if (dynamicVocab.isNotEmpty) {
      final convertedVocab = dynamicVocab
          .map((v) => CurriculumVocabItem(
                word: v.word,
                phonetic: v.phonetic,
                partOfSpeech: v.partOfSpeech,
                meaningEn: v.definition,
                meaningMl: v.malayalamMeaning,
                exampleEn: v.exampleSentence,
                exampleMl: '',
              ))
          .toList();
      return base.copyWith(vocabulary: convertedVocab);
    }
    return base;
  }

  static final Map<int, MasterCurriculumDay> _days = {
    ...masterPhase1Days,
    ...masterPhase2Days,
    ...masterPhase3Days,
  };

  static MasterCurriculumDay _generateDynamicDay(int day) {
    final phase = day <= 30 ? 1 : (day <= 60 ? 2 : 3);
    String phaseName;
    String title;
    String focus;
    String grammar;
    String drill;
    String peer;

    if (phase == 1) {
      phaseName = 'Phase 1: Foundation & Speech Mechanics (Days 1–30)';
      title = 'Day $day: Sentence Building & Speech Confidence';
      focus = 'SVO Sentence Patterns & Daily Action Verbs';
      grammar = 'Sentence Word Order & Auxiliary Agreement';
      drill = 'Speak for 60 seconds describing an activity you enjoy.';
      peer = 'Share one interesting daily habit with your Pocket Mate.';
    } else if (phase == 2) {
      phaseName = 'Phase 2: Functional English (Days 31–60)';
      title = 'Day $day: Real-World Communication & Situations';
      focus = 'Workplace Situations, Meetings & Descriptions';
      grammar = 'Complex Connectors & Conditionals';
      drill = 'Explain a solution to an unexpected problem in 90 seconds.';
      peer = 'Roleplay an interactive scenario with your study partner.';
    } else {
      phaseName = 'Phase 3: Fluency & Mastery (Days 61–90)';
      title = 'Day $day: Advanced Articulation & Oratory';
      focus = 'Executive Nuance, Debate & Presentations';
      grammar = 'Subtle Rhetoric, Emphasis & Cleft Sentences';
      drill =
          'Deliver a 2-minute persuasive impromptu speech on a chosen topic.';
      peer = 'Engage in a live intellectual debate round with your peer.';
    }

    final theoryConcept = 'Dynamic Cadence & Speech Flow (Day $day)';
    final theoryEn =
        'Fluency is built through continuous vocal repetition. Focus on smooth breath control, connected speech, and eliminating inner translation.';
    final theoryMl =
        'ദിവസേനയുള്ള കൃത്യമായ വോക്കൽ പ്രാക്ടീസിലൂടെ മാത്രമേ ഇംഗ്ലീഷ് സംസാരിക്കാനുള്ള മടി മാറുകയുള്ളൂ. വാക്കുകൾ മനസ്സിൽ തർജ്ജമ ചെയ്യാതെ നേരിട്ട് സംസാരിക്കാൻ ശ്രമിക്കുക.';
    final whyItMatters =
        'Consistent speech drills rewire vocal reflexes and build natural muscle memory.';

    final commonMistakes = phase == 1
        ? [
            '❌ "I am having two cars."',
            '❌ "He don\'t know the answer."',
          ]
        : (phase == 2
            ? [
                '❌ "I will explain you tomorrow."',
                '❌ "Despite of the rain, we went."',
              ]
            : [
                '❌ "I suggest you to do this."',
                '❌ "He discussed about the issue."',
              ]);

    final mistakeCorrections = phase == 1
        ? [
            '✅ "I have two cars."',
            '✅ "He doesn\'t know the answer."',
          ]
        : (phase == 2
            ? [
                '✅ "I will explain it to you tomorrow."',
                '✅ "Despite the rain, we went." (or "In spite of")',
              ]
            : [
                '✅ "I suggest that you do this."',
                '✅ "He discussed the issue."',
              ]);

    final defaultVocab = [
      const CurriculumVocabItem(
        word: 'ARTICULATE',
        phonetic: '/ɑːˈtɪk.jə.leɪt/',
        partOfSpeech: 'Verb',
        meaningEn: 'Express an idea or feeling fluently and coherently.',
        meaningMl: 'വ്യക്തമായും വ്യക്തതയോടെയും സംസാരിക്കുക',
        exampleEn: 'She was able to articulate her ideas clearly.',
        exampleMl: 'തന്റെ ആശയങ്ങൾ വ്യക്തമായി പ്രകടിപ്പിക്കാൻ അവൾക്ക് കഴിഞ്ഞു.',
      ),
      const CurriculumVocabItem(
        word: 'PERSISTENCE',
        phonetic: '/pəˈsɪs.təns/',
        partOfSpeech: 'Noun',
        meaningEn: 'Firm continuance in a course of action despite difficulty.',
        meaningMl: 'സ്ഥിരോത്സാഹം / ലക്ഷ്യബോധത്തോടെ തുടരൽ',
        exampleEn: 'Fluency demands persistence and daily voice repetition.',
        exampleMl: 'ഇംഗ്ലീഷ് പ്രാവീണ്യത്തിന് സ്ഥിരോത്സാഹം അത്യന്താപേക്ഷിതമാണ്.',
      ),
      const CurriculumVocabItem(
        word: 'CONVERSATION',
        phonetic: '/ˌkɒn.vəˈseɪ.ʃən/',
        partOfSpeech: 'Noun',
        meaningEn:
            'A talk, especially an informal one, between two or more people.',
        meaningMl: 'സംഭാഷണം',
        exampleEn: 'Start every conversation with warmth and eye contact.',
        exampleMl: 'ഊഷ്മളതയോടെ സംഭാഷണം ആരംഭിക്കുക.',
      ),
      const CurriculumVocabItem(
        word: 'PRACTICE',
        phonetic: '/ˈpræk.tɪs/',
        partOfSpeech: 'Noun / Verb',
        meaningEn:
            'Repeated exercise in an activity to acquire or maintain proficiency.',
        meaningMl: 'പരിശീലനം',
        exampleEn: 'Daily deliberate practice rewires speech reflexes.',
        exampleMl:
            'ദിവസേനയുള്ള കൃത്യമായ പരിശീലനം സംസാരശേഷി വർദ്ധിപ്പിക്കുന്നു.',
      ),
    ];

    return MasterCurriculumDay(
      day: day,
      title: title,
      phaseName: phaseName,
      focusArea: focus,
      grammarConcept: grammar,
      speakingDrill: drill,
      peerChatMission: peer,
      theoryConcept: theoryConcept,
      theoryExplanationEn: theoryEn,
      theoryExplanationMl: theoryMl,
      whyItMatters: whyItMatters,
      commonMistakes: commonMistakes,
      mistakeCorrections: mistakeCorrections,
      vocabulary: defaultVocab,
      sentenceEvolution: [
        '🟢 Basic: Practice daily sentences.',
        '🟡 Intermediate: Practice speaking English aloud for 15 minutes every morning.',
        '🟣 Advanced: By committing to consistent deliberate practice, you cultivate the vocal reflexes necessary for effortless spontaneous expression.',
      ],
      dailyChallenge:
          'Deliver a 2-minute spontaneous speech on today\'s focus topic.',
      listeningGoal: 'Listen to 10 minutes of authentic English audio.',
    );
  }
}
