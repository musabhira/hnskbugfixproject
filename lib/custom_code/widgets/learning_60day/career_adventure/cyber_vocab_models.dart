import 'package:flutter/material.dart';

/// ⚡ Power-Up Types for Cyber Vocab Striker
enum StrikerPowerUpType {
  slowMotion, // ⚡ Slows falling speed by 50%
  shieldBoost, // 🛡️ Adds 1 extra shield point
  clueMatrix, // 💡 Emits a scanning pulse highlighting the correct word
}

/// 📖 Individual Vocabulary Word Item
class VocabWordItem {
  final String word;
  final String phonetic;
  final String definition;
  final String malayalamMeaning;
  final String exampleSentence;
  final String category;
  final IconData icon;

  const VocabWordItem({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.malayalamMeaning,
    required this.exampleSentence,
    required this.category,
    this.icon = Icons.terminal_rounded,
  });
}

/// 🌊 Individual Wave in Cyber Vocab Striker
class VocabStrikerWave {
  final int waveNumber;
  final VocabWordItem target;
  final String cluePrompt;
  final List<String> distractorWords;
  final StrikerPowerUpType? bonusPowerUp;

  const VocabStrikerWave({
    required this.waveNumber,
    required this.target,
    required this.cluePrompt,
    required this.distractorWords,
    this.bonusPowerUp,
  });

  /// All 4 choices for this wave (target + 3 distractors)
  List<String> get allChoices {
    final list = [target.word, ...distractorWords];
    list.shuffle();
    return list;
  }
}

/// 🎯 Complete Level 2 Curriculum & Configuration
class VocabStrikerLevelData {
  final int levelNumber;
  final String title;
  final String subtitle;
  final String instructions;
  final List<VocabStrikerWave> waves;

  const VocabStrikerLevelData({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.instructions,
    required this.waves,
  });

  List<VocabWordItem> get allVocabulary =>
      waves.map((w) => w.target).toList(growable: false);
}

/// 🚀 Level 2 High-Impact Vocabulary Roster (10 Waves)
const kMission02VocabStrikerData = VocabStrikerLevelData(
  levelNumber: 2,
  title: 'Cyber Vocab Striker',
  subtitle: 'Flame Arcade Vocabulary Defense',
  instructions:
      'Pilot your Cyber Interceptor along the data corridor. Decrypt the target clue, aim laser beams at the matching word node, and blast it before it breaches the cyber firewall!',
  waves: [
    // Wave 1
    VocabStrikerWave(
      waveNumber: 1,
      target: VocabWordItem(
        word: 'NAVIGATE',
        phonetic: '/ˈnæv.ɪ.ɡeɪt/',
        definition: 'To plan and direct the course of travel or find one’s way.',
        malayalamMeaning: 'വഴികാട്ടുക / ലക്ഷ്യത്തിലേക്ക് നയിക്കുക',
        exampleSentence: 'Use the GPS system to navigate through heavy traffic.',
        category: 'Direction',
        icon: Icons.explore_rounded,
      ),
      cluePrompt: 'To plan and direct the route of travel or find one’s way',
      distractorWords: ['STAGNATE', 'SURRENDER', 'ISOLATE'],
      bonusPowerUp: StrikerPowerUpType.clueMatrix,
    ),

    // Wave 2
    VocabStrikerWave(
      waveNumber: 2,
      target: VocabWordItem(
        word: 'DESTINATION',
        phonetic: '/ˌdes.tɪˈneɪ.ʃən/',
        definition: 'The place to which someone or something is going.',
        malayalamMeaning: 'ലക്ഷ്യസ്ഥാനം / എത്തിച്ചേരേണ്ട സ്ഥലം',
        exampleSentence: 'After four hours of driving, they reached their final destination.',
        category: 'Travel',
        icon: Icons.pin_drop_rounded,
      ),
      cluePrompt: 'The place to which someone or something is travelling',
      distractorWords: ['DEPARTURE', 'BOUNDARY', 'EXPULSION'],
      bonusPowerUp: null,
    ),

    // Wave 3
    VocabStrikerWave(
      waveNumber: 3,
      target: VocabWordItem(
        word: 'TRANSIT',
        phonetic: '/ˈtræn.zɪt/',
        definition: 'The carrying of people or goods from one place to another.',
        malayalamMeaning: 'യാത്രാ സംവിധാനം / ചരക്കുനീക്കം',
        exampleSentence: 'The city boasts a modern and affordable public transit network.',
        category: 'Mobility',
        icon: Icons.directions_bus_rounded,
      ),
      cluePrompt: 'The carrying or movement of people from one place to another',
      distractorWords: ['RESIDENCE', 'STABILITY', 'QUARANTINE'],
      bonusPowerUp: StrikerPowerUpType.slowMotion,
    ),

    // Wave 4
    VocabStrikerWave(
      waveNumber: 4,
      target: VocabWordItem(
        word: 'CONVERGE',
        phonetic: '/kənˈvɜːdʒ/',
        definition: 'To move toward or meet at a common point.',
        malayalamMeaning: 'ഒരുമിച്ചു ചേരുക / ഒന്നിച്ചു വരിക',
        exampleSentence: 'Thousands of fans converge at the central stadium on weekends.',
        category: 'Meeting',
        icon: Icons.call_merge_rounded,
      ),
      cluePrompt: 'To come together or meet at a single point or intersection',
      distractorWords: ['DISPERSE', 'SCATTER', 'DIVERT'],
      bonusPowerUp: null,
    ),

    // Wave 5
    VocabStrikerWave(
      waveNumber: 5,
      target: VocabWordItem(
        word: 'EXPEDITE',
        phonetic: '/ˈek.spə.daɪt/',
        definition: 'To make an action or process happen sooner or be done more quickly.',
        malayalamMeaning: 'വേഗത്തിലാക്കുക / ത്വരിതപ്പെടുത്തുക',
        exampleSentence: 'Please expedite the shipment so it arrives before Monday.',
        category: 'Action',
        icon: Icons.bolt_rounded,
      ),
      cluePrompt: 'To speed up or accelerate the progress of a process',
      distractorWords: ['POSTPONE', 'IMPEDE', 'NEGLECT'],
      bonusPowerUp: StrikerPowerUpType.shieldBoost,
    ),

    // Wave 6
    VocabStrikerWave(
      waveNumber: 6,
      target: VocabWordItem(
        word: 'CONSENSUS',
        phonetic: '/kənˈsen.səs/',
        definition: 'A general agreement arrived at by all members of a group.',
        malayalamMeaning: 'പൊതുസമ്മതം / ഐക്യകണ്ഠമായ തീരുമാനം',
        exampleSentence: 'The board reached a consensus on the new project strategy.',
        category: 'Communication',
        icon: Icons.handshake_rounded,
      ),
      cluePrompt: 'General collective agreement reached by all members of a team',
      distractorWords: ['DISPUTE', 'FRICTION', 'CONFLICT'],
      bonusPowerUp: null,
    ),

    // Wave 7
    VocabStrikerWave(
      waveNumber: 7,
      target: VocabWordItem(
        word: 'MILESTONE',
        phonetic: '/ˈmaɪl.stəʊn/',
        definition: 'A significant stage or breakthrough in development.',
        malayalamMeaning: 'പ്രധാന നാഴികക്കല്ല് / വലിയ നേട്ടം',
        exampleSentence: 'Reaching one million active users was a massive company milestone.',
        category: 'Success',
        icon: Icons.flag_rounded,
      ),
      cluePrompt: 'A prominent turning point, breakthrough, or key stage in progress',
      distractorWords: ['OBSTACLE', 'SETBACK', 'TRIVIA'],
      bonusPowerUp: StrikerPowerUpType.clueMatrix,
    ),

    // Wave 8
    VocabStrikerWave(
      waveNumber: 8,
      target: VocabWordItem(
        word: 'DETOUR',
        phonetic: '/ˈdiː.tɔːr/',
        definition: 'A roundabout or indirect way taken when the main route is blocked.',
        malayalamMeaning: 'വഴിതിരിച്ചുവിടൽ / ബദൽ പാത',
        exampleSentence: 'Due to road construction, drivers had to follow a short detour.',
        category: 'Navigation',
        icon: Icons.alt_route_rounded,
      ),
      cluePrompt: 'An alternative or roundabout path used when direct road is blocked',
      distractorWords: ['SHORTCUT', 'CORRIDOR', 'HIGHWAY'],
      bonusPowerUp: null,
    ),

    // Wave 9
    VocabStrikerWave(
      waveNumber: 9,
      target: VocabWordItem(
        word: 'PROXIMITY',
        phonetic: '/prɒkˈsɪm.ə.ti/',
        definition: 'Nearness in space, time, or relationship.',
        malayalamMeaning: 'സാമീപ്യം / അടുപ്പം',
        exampleSentence: 'The hotel’s proximity to the airport makes it very convenient.',
        category: 'Distance',
        icon: Icons.near_me_rounded,
      ),
      cluePrompt: 'Closeness or nearness in space, distance, or time',
      distractorWords: ['DISTANCE', 'REMOTENESS', 'ABSENCE'],
      bonusPowerUp: StrikerPowerUpType.slowMotion,
    ),

    // Wave 10
    VocabStrikerWave(
      waveNumber: 10,
      target: VocabWordItem(
        word: 'EFFICIENT',
        phonetic: '/ɪˈfɪʃ.ənt/',
        definition: 'Achieving maximum productivity with minimum wasted effort or expense.',
        malayalamMeaning: 'കാര്യക്ഷമമായ / പാഴാക്കാതെ മികച്ച ഫലം തരുന്ന',
        exampleSentence: 'An efficient workflow saves time and minimizes operational stress.',
        category: 'Excellence',
        icon: Icons.speed_rounded,
      ),
      cluePrompt: 'Achieving maximum results and productivity with minimum wasted effort',
      distractorWords: ['WASTEFUL', 'SLUGGISH', 'CLUMSY'],
      bonusPowerUp: StrikerPowerUpType.shieldBoost,
    ),
  ],
);
