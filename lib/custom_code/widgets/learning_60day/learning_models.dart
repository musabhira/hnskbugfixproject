import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';

/// Distinct UI Themes that radically transform the Profile appearance at major milestones
enum ProfileUIThemeVariant {
  genesis, // Days 1–29: Sleek, clean modern cards
  silverKnight, // Days 30–59: Chrome-accented metallic capsules & frosted glass
  goldSovereign, // Days 60–89: 24K Gold luxury glowing badges & golden stat cards
  diamondCelestial // Day 90: Holographic diamond aura, obsidian glassmorphism & crown badge
}

/// Represents one of the 90 distinct daily stages in Pocket Mates
/// Internal blueprint for the 90 unique daily stage color palettes & metadata
class _StageDef {
  final int day;
  final String name;
  final String tier;
  final String emoji;
  final String desc;
  final Color bg;
  final Color secondBg;
  final Color btn;
  final Color tick;
  final ProfileUIThemeVariant variant;
  final bool isMajor;

  const _StageDef({
    required this.day,
    required this.name,
    required this.tier,
    required this.emoji,
    required this.desc,
    required this.bg,
    required this.secondBg,
    required this.btn,
    required this.tick,
    required this.variant,
    this.isMajor = false,
  });
}

class LearningMilestoneStage {
  final int stageNumber; // 1 to 90
  final int day; // 1 to 90
  final String stageName;
  final String fluencyTier;
  final String description;
  final String emoji;
  final bool isMajorGate; // Day 21, 30, 60, 90
  final Color bgColor;
  final Color textColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color tickColor; // Custom verified badge color
  final List<Color> gradientColors;
  final String bgHex;
  final String textHex;
  final String buttonHex;
  final String buttonTextHex;
  final ProfileUIThemeVariant uiThemeVariant;
  final VectorAvatarConfig avatarReward; // Prestigious NFT avatar unlocked on this day

  const LearningMilestoneStage({
    required this.stageNumber,
    required this.day,
    required this.stageName,
    required this.fluencyTier,
    required this.description,
    required this.emoji,
    this.isMajorGate = false,
    required this.bgColor,
    required this.textColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.tickColor,
    required this.gradientColors,
    required this.bgHex,
    required this.textHex,
    required this.buttonHex,
    required this.buttonTextHex,
    required this.uiThemeVariant,
    required this.avatarReward,
  });

  /// Factory generator producing all 90 unique stages with distinct color progressions
  static final List<LearningMilestoneStage> allStages = List.generate(90, (i) {
    final dayNum = i + 1;
    return _createStageForDay(dayNum);
  });

  static LearningMilestoneStage _createStageForDay(int day) {
    final clamped = day.clamp(1, 90);
    final def = _stageDefs[clamped - 1];

    // Intelligent high-contrast text calculation based on background luminance
    final bgLuminance = def.bg.computeLuminance();
    final Color textColor = bgLuminance > 0.45
        ? const Color(0xFF0F172A) // Crisp dark slate for light themes
        : (def.variant == ProfileUIThemeVariant.goldSovereign
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF8FAFC));

    final btnLuminance = def.btn.computeLuminance();
    final Color btnTextColor = btnLuminance > 0.45
        ? const Color(0xFF0F172A)
        : const Color(0xFFFFFFFF);

    final avatarReward = VectorAvatarConfig.getEvolutionAvatarForStage(clamped);

    return LearningMilestoneStage(
      stageNumber: clamped,
      day: clamped,
      stageName: def.name,
      fluencyTier: def.tier,
      description: def.desc,
      emoji: def.emoji,
      isMajorGate: def.isMajor,
      bgColor: def.bg,
      textColor: textColor,
      buttonColor: def.btn,
      buttonTextColor: btnTextColor,
      tickColor: def.tick,
      gradientColors: [def.bg, def.secondBg],
      bgHex: _colorToHex(def.bg),
      textHex: _colorToHex(textColor),
      buttonHex: _colorToHex(def.btn),
      buttonTextHex: _colorToHex(btnTextColor),
      uiThemeVariant: def.variant,
      avatarReward: avatarReward,
    );
  }

  static const List<_StageDef> _stageDefs = [
    _StageDef(
      day: 1,
      name: 'Genesis Tokyo Blue & Orange',
      tier: 'Beginner A1',
      emoji: '🐱',
      desc: 'Day 1 foundation kickoff. Cyber cat awakening & speech basics.',
      bg: Color(0xFF0A1426),
      secondBg: Color(0xFF112240),
      btn: Color(0xFFFF6B00),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 2,
      name: 'High-Voltage Volt & Black',
      tier: 'Beginner A1',
      emoji: '⚡',
      desc: 'Day 2 dynamic rhythm. Rapid response & ear tuning.',
      bg: Color(0xFF0D0F14),
      secondBg: Color(0xFF161A24),
      btn: Color(0xFFFFFC00),
      tick: Color(0xFFFFFC00),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 3,
      name: 'Imperial Crimson & Gold',
      tier: 'Beginner A1',
      emoji: '🔥',
      desc: 'Day 3 courage session. Speaking out loud with conviction.',
      bg: Color(0xFF240A12),
      secondBg: Color(0xFF38101C),
      btn: Color(0xFFFF2A55),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 4,
      name: 'Deep Glacier Navy & Ice Cyan',
      tier: 'Beginner A1',
      emoji: '🧊',
      desc: 'Day 4 crystal clarity. Pure pronunciation & active listening.',
      bg: Color(0xFF071426),
      secondBg: Color(0xFF0E223D),
      btn: Color(0xFF38BDF8),
      tick: Color(0xFF60A5FA),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 5,
      name: 'Royal Emerald Forest',
      tier: 'Beginner A1',
      emoji: '🌱',
      desc: 'Day 5 organic flow. Sentence building without hesitating.',
      bg: Color(0xFF081C15),
      secondBg: Color(0xFF0D2820),
      btn: Color(0xFF10B981),
      tick: Color(0xFF34D399),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 6,
      name: 'Dark Forest Jade & Mint',
      tier: 'Beginner A1',
      emoji: '🍃',
      desc: 'Day 6 natural ease. Daily greetings and effortless idioms.',
      bg: Color(0xFF051B14),
      secondBg: Color(0xFF0B2C21),
      btn: Color(0xFF34D399),
      tick: Color(0xFF6EE7B7),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 7,
      name: 'Tokyo Midnight & Cyan',
      tier: 'Beginner A1',
      emoji: '🔮',
      desc: 'Day 7 weekly milestone. Breakthrough in conversational speed.',
      bg: Color(0xFF120B24),
      secondBg: Color(0xFF1F123D),
      btn: Color(0xFF00F0FF),
      tick: Color(0xFFA855F7),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 8,
      name: 'Deep Royal Violet & Neon Orchid',
      tier: 'Beginner A1',
      emoji: '🌸',
      desc: 'Day 8 silky phonetics. Polishing natural English accents.',
      bg: Color(0xFF150A26),
      secondBg: Color(0xFF22113D),
      btn: Color(0xFFA855F7),
      tick: Color(0xFFC084FC),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 9,
      name: 'Sunset Amber & Coral',
      tier: 'Beginner A1',
      emoji: '🌅',
      desc: 'Day 9 warming momentum. Expressing feelings and opinions.',
      bg: Color(0xFF1C0F08),
      secondBg: Color(0xFF2C190D),
      btn: Color(0xFFFF5722),
      tick: Color(0xFFFB923C),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 10,
      name: 'Dark Terracotta & Molten Gold',
      tier: 'Beginner A1',
      emoji: '🏜️',
      desc: 'Day 10 milestone! 10-day streak unlocked with warm confidence.',
      bg: Color(0xFF1E0E08),
      secondBg: Color(0xFF30180E),
      btn: Color(0xFFEA580C),
      tick: Color(0xFFF97316),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 11,
      name: 'Electric Navy & Tangerine',
      tier: 'Elementary A2',
      emoji: '🌊',
      desc: 'Day 11 fluent expansion. Thinking directly in English thoughts.',
      bg: Color(0xFF071B2F),
      secondBg: Color(0xFF0F2E4F),
      btn: Color(0xFFF97316),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 12,
      name: 'Velvet Cherry & Rose Gold',
      tier: 'Elementary A2',
      emoji: '🍷',
      desc: 'Day 12 nuanced tone. Expressing subtlety with emotional warmth.',
      bg: Color(0xFF280712),
      secondBg: Color(0xFF3D0C1D),
      btn: Color(0xFFFB7185),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 13,
      name: 'Dark Gunmetal & Electric Indigo',
      tier: 'Elementary A2',
      emoji: '⚙️',
      desc: 'Day 13 structural precision. Advanced grammar feeling effortless.',
      bg: Color(0xFF0C101F),
      secondBg: Color(0xFF161D36),
      btn: Color(0xFF6366F1),
      tick: Color(0xFF818CF8),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 14,
      name: 'Cyber Bumblebee & Onyx',
      tier: 'Elementary A2',
      emoji: '🐝',
      desc: 'Day 14 two-week fortress. Instant spontaneous verbal reflexes.',
      bg: Color(0xFF090A0E),
      secondBg: Color(0xFF151821),
      btn: Color(0xFFFACC15),
      tick: Color(0xFFFDE047),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 15,
      name: 'Abyssal Aquamarine Deep',
      tier: 'Elementary A2',
      emoji: '🐬',
      desc: 'Day 15 deep dive. Full immersion conversations with zero fear.',
      bg: Color(0xFF041824),
      secondBg: Color(0xFF09293C),
      btn: Color(0xFF06B6D4),
      tick: Color(0xFF22D3EE),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 16,
      name: 'Dark Velvet Berry & Coral Pink',
      tier: 'Elementary A2',
      emoji: '🌷',
      desc: 'Day 16 elegance in cadence. Storytelling and narrating memories.',
      bg: Color(0xFF250814),
      secondBg: Color(0xFF3B0E21),
      btn: Color(0xFFF43F5E),
      tick: Color(0xFFFB7185),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 17,
      name: 'Volcanic Blood Orange',
      tier: 'Elementary A2',
      emoji: '🌋',
      desc: 'Day 17 erupting confidence. Fast debates and lively discussions.',
      bg: Color(0xFF141416),
      secondBg: Color(0xFF202024),
      btn: Color(0xFFFF4500),
      tick: Color(0xFFFF6B00),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 18,
      name: 'Neon Synthwave Pink',
      tier: 'Elementary A2',
      emoji: '💖',
      desc: 'Day 18 creative flair. Vibrant expressive colloquial vocabulary.',
      bg: Color(0xFF180A22),
      secondBg: Color(0xFF261036),
      btn: Color(0xFFEC4899),
      tick: Color(0xFFF472B6),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 19,
      name: 'Deep Twilight Abyss & Cyan Flare',
      tier: 'Elementary A2',
      emoji: '💠',
      desc: 'Day 19 clarity matrix. Perfect sentence links and transitions.',
      bg: Color(0xFF051528),
      secondBg: Color(0xFF0B2440),
      btn: Color(0xFF00F0FF),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 20,
      name: 'Solar Flare & Bronze',
      tier: 'Elementary A2',
      emoji: '☀️',
      desc: 'Day 20 eve of the Habit Anchor! Radiant linguistic readiness.',
      bg: Color(0xFF1A1307),
      secondBg: Color(0xFF2A1F0D),
      btn: Color(0xFFEAB308),
      tick: Color(0xFFFBBF24),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 21,
      name: 'Day 21 Habit Anchor Gate',
      tier: 'Intermediate B1',
      emoji: '🎯',
      desc: '🎯 DAY 21 HABIT FORMED! English thinking is now an involuntary habit.',
      bg: Color(0xFF2A0814),
      secondBg: Color(0xFF420D20),
      btn: Color(0xFFFF2D55),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.genesis,
      isMajor: true,
    ),
    _StageDef(
      day: 22,
      name: 'Dark Pine Emerald & Lime',
      tier: 'Intermediate B1',
      emoji: '🌿',
      desc: 'Day 22 effortless habit. Daily speaking flows like breathing.',
      bg: Color(0xFF051C12),
      secondBg: Color(0xFF0B2E1F),
      btn: Color(0xFF22C55E),
      tick: Color(0xFF4ADE80),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 23,
      name: 'Electric Cobalt & Lime',
      tier: 'Intermediate B1',
      emoji: '🧪',
      desc: 'Day 23 energy surge. Quick explanations and persuasive ideas.',
      bg: Color(0xFF0A1535),
      secondBg: Color(0xFF132252),
      btn: Color(0xFF84CC16),
      tick: Color(0xFFA3E635),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 24,
      name: 'Dark Amethyst & Golden Amber',
      tier: 'Intermediate B1',
      emoji: '🪞',
      desc: 'Day 24 reflective mastery. Self-correcting grammar effortlessly.',
      bg: Color(0xFF1B0C2E),
      secondBg: Color(0xFF2B1449),
      btn: Color(0xFFF59E0B),
      tick: Color(0xFFFBBF24),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 25,
      name: 'Hyperdrive Blue & Orange',
      tier: 'Intermediate B1',
      emoji: '🚀',
      desc: 'Day 25 hyperdrive. Rapid conversation with zero translation lag.',
      bg: Color(0xFF0C1938),
      secondBg: Color(0xFF142757),
      btn: Color(0xFFFF6600),
      tick: Color(0xFFFF8533),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 26,
      name: 'Dark Sahara Bronze & Amber',
      tier: 'Intermediate B1',
      emoji: '🐪',
      desc: 'Day 26 enduring grit. Long-form talks and structured stories.',
      bg: Color(0xFF1E1106),
      secondBg: Color(0xFF311C0B),
      btn: Color(0xFFD97706),
      tick: Color(0xFFF59E0B),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 27,
      name: 'Mystic Teal & Electric Cyan',
      tier: 'Intermediate B1',
      emoji: '🌌',
      desc: 'Day 27 philosophical depth. Engaging in abstract topics easily.',
      bg: Color(0xFF061E24),
      secondBg: Color(0xFF0E2E37),
      btn: Color(0xFF06B6D4),
      tick: Color(0xFF22D3EE),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 28,
      name: 'Carbon Hazard & Canary Yellow',
      tier: 'Intermediate B1',
      emoji: '⚠️',
      desc: 'Day 28 peak velocity. Real-time debate with native rhythm.',
      bg: Color(0xFF0B0D11),
      secondBg: Color(0xFF161A22),
      btn: Color(0xFFFFE600),
      tick: Color(0xFFFFEA2C),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 29,
      name: 'Dark Cyber Titanium & Periwinkle',
      tier: 'Intermediate B1',
      emoji: '✨',
      desc: 'Day 29 Silver Gate threshold! Poised for intermediate prestige.',
      bg: Color(0xFF0F1424),
      secondBg: Color(0xFF192038),
      btn: Color(0xFF818CF8),
      tick: Color(0xFFA5B4FC),
      variant: ProfileUIThemeVariant.genesis,
    ),
    _StageDef(
      day: 30,
      name: 'Day 30 Silver Gate',
      tier: 'Intermediate B1+',
      emoji: '🥈',
      desc: '🥈 30-DAY FIRST MAJOR GATE! Silver Metallic UI & Intermediate B1 Badge.',
      bg: Color(0xFF0F131C),
      secondBg: Color(0xFF1C2232),
      btn: Color(0xFFE2E8F0),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.silverKnight,
      isMajor: true,
    ),
    _StageDef(
      day: 31,
      name: 'Dark Cobalt Steel & Sapphire',
      tier: 'Intermediate B1+',
      emoji: '🛡️',
      desc: 'Day 31 Silver Knight journey begins. Polished tone & confidence.',
      bg: Color(0xFF0A1324),
      secondBg: Color(0xFF132240),
      btn: Color(0xFF3B82F6),
      tick: Color(0xFF60A5FA),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 32,
      name: 'Imperial Ruby Knight',
      tier: 'Intermediate B1+',
      emoji: '💎',
      desc: 'Day 32 ruby sharp logic. Constructing clear persuasive views.',
      bg: Color(0xFF260611),
      secondBg: Color(0xFF3E0B1D),
      btn: Color(0xFFFF2D55),
      tick: Color(0xFFFF4D6D),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 33,
      name: 'Dark Arctic Ocean & Neon Glacier',
      tier: 'Intermediate B1+',
      emoji: '🏔️',
      desc: 'Day 33 glacier cool poise. Navigating complex professional terms.',
      bg: Color(0xFF041924),
      secondBg: Color(0xFF09293B),
      btn: Color(0xFF00F0FF),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 34,
      name: 'Hazard Carbon & Volt',
      tier: 'Intermediate B1+',
      emoji: '⚡',
      desc: 'Day 34 high output. Continuous speech with natural fillers.',
      bg: Color(0xFF08090C),
      secondBg: Color(0xFF14161F),
      btn: Color(0xFFFFD600),
      tick: Color(0xFFFFDF33),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 35,
      name: 'Steel Blue & Neon Tangerine',
      tier: 'Intermediate B1+',
      emoji: '⚔️',
      desc: 'Day 35 sharp conversational tactics. Handling interruptions.',
      bg: Color(0xFF101B2E),
      secondBg: Color(0xFF1C2D4B),
      btn: Color(0xFFFF7700),
      tick: Color(0xFFFFA14D),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 36,
      name: 'Dark Mystic Plum & Electric Violet',
      tier: 'Intermediate B1+',
      emoji: '🪻',
      desc: 'Day 36 poetic expression. Metaphors and vivid verbal imagery.',
      bg: Color(0xFF1A0A28),
      secondBg: Color(0xFF2A1140),
      btn: Color(0xFFC084FC),
      tick: Color(0xFFE879F9),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 37,
      name: 'Malachite & Silver Mint',
      tier: 'Intermediate B1+',
      emoji: '🍃',
      desc: 'Day 37 natural rhythm. Speaking for minutes uninterrupted.',
      bg: Color(0xFF071F18),
      secondBg: Color(0xFF0E3228),
      btn: Color(0xFF6EE7B7),
      tick: Color(0xFF34D399),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 38,
      name: 'Dark Burnt Sienna & Solar Copper',
      tier: 'Intermediate B1+',
      emoji: '🏺',
      desc: 'Day 38 classic storytelling. Weaving narrative depth and humor.',
      bg: Color(0xFF1D0E07),
      secondBg: Color(0xFF2E170C),
      btn: Color(0xFFF97316),
      tick: Color(0xFFFB923C),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 39,
      name: 'Cobalt Storm & Sunset Flame',
      tier: 'Intermediate B1+',
      emoji: '⛈️',
      desc: 'Day 39 tempestuous speed. Thinking on your feet in rapid Q&A.',
      bg: Color(0xFF0A1836),
      secondBg: Color(0xFF122654),
      btn: Color(0xFFFF5500),
      tick: Color(0xFFFF884D),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 40,
      name: 'Dark Obsidian Slate & Electric Cyan',
      tier: 'Intermediate B1+',
      emoji: '🛡️',
      desc: 'Day 40 solid intermediate plateau conquered. Bulletproof grammar.',
      bg: Color(0xFF0C1322),
      secondBg: Color(0xFF152038),
      btn: Color(0xFF38BDF8),
      tick: Color(0xFF7DD3FC),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 41,
      name: 'Shadow Obsidian & Electric Amber',
      tier: 'Intermediate B1+',
      emoji: '🕯️',
      desc: 'Day 41 intense focus. Nuanced business and casual register shifts.',
      bg: Color(0xFF0C0C10),
      secondBg: Color(0xFF191922),
      btn: Color(0xFFF59E0B),
      tick: Color(0xFFFBBF24),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 42,
      name: 'Dark Forest Emerald & Mint',
      tier: 'Intermediate B1+',
      emoji: '🌲',
      desc: 'Day 42 calm natural ease. Sounding like a seasoned speaker.',
      bg: Color(0xFF061A10),
      secondBg: Color(0xFF0C2B1B),
      btn: Color(0xFF10B981),
      tick: Color(0xFF34D399),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 43,
      name: 'Cyber Magenta Blade',
      tier: 'Intermediate B1+',
      emoji: '🗡️',
      desc: 'Day 43 razor sharp articulation. Zero mumbling or hesitation.',
      bg: Color(0xFF24061A),
      secondBg: Color(0xFF3B0B2B),
      btn: Color(0xFFF43F5E),
      tick: Color(0xFFFB7185),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 44,
      name: 'Gunmetal Crimson Rose',
      tier: 'Intermediate B1+',
      emoji: '🌹',
      desc: 'Day 44 passionate delivery. Convincing speech that commands attention.',
      bg: Color(0xFF131720),
      secondBg: Color(0xFF1E2433),
      btn: Color(0xFFF43F5E),
      tick: Color(0xFFFB7185),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 45,
      name: 'Dark Oceanic Azure & Ice Blue',
      tier: 'Intermediate B1+',
      emoji: '🌊',
      desc: 'Day 45 halfway milestone! B2 Upper-Intermediate unlocked.',
      bg: Color(0xFF061830),
      secondBg: Color(0xFF0D2952),
      btn: Color(0xFF0284C7),
      tick: Color(0xFF38BDF8),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 46,
      name: 'Ultraviolet Neon Pulse',
      tier: 'Upper-Inter B2',
      emoji: '🔮',
      desc: 'Day 46 vibrant brain chemistry. Direct conceptual English thought.',
      bg: Color(0xFF19092F),
      secondBg: Color(0xFF29104A),
      btn: Color(0xFF22C55E),
      tick: Color(0xFF4ADE80),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 47,
      name: 'Blood Scarlet & Steel',
      tier: 'Upper-Inter B2',
      emoji: '🩸',
      desc: 'Day 47 high adrenaline verbal drills. Seamless tone control.',
      bg: Color(0xFF28070F),
      secondBg: Color(0xFF3E0D19),
      btn: Color(0xFFFF2A55),
      tick: Color(0xFFFF5C7A),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 48,
      name: 'Dark Crimson Velvet & Rose Quartz',
      tier: 'Upper-Inter B2',
      emoji: '🍑',
      desc: 'Day 48 warm social eloquence. Small talk transformed into deep talk.',
      bg: Color(0xFF240610),
      secondBg: Color(0xFF3A0B1A),
      btn: Color(0xFFFB7185),
      tick: Color(0xFFFDA4AF),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 49,
      name: 'Stealth Carbon & Cyber Gold',
      tier: 'Upper-Inter B2',
      emoji: '🪙',
      desc: 'Day 49 wealth of vocabulary. Precision word choices in every sentence.',
      bg: Color(0xFF0A0B0E),
      secondBg: Color(0xFF151820),
      btn: Color(0xFFFFD000),
      tick: Color(0xFFFFDC33),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 50,
      name: 'Deep Sea Navy & Coral',
      tier: 'Upper-Inter B2',
      emoji: '🪸',
      desc: 'Day 50 golden 50! Unshakable verbal stamina and clear diction.',
      bg: Color(0xFF07182C),
      secondBg: Color(0xFF0E2A4B),
      btn: Color(0xFFFF5C38),
      tick: Color(0xFFFF8066),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 51,
      name: 'Dark Midnight Indigo & Electric Violet',
      tier: 'Upper-Inter B2',
      emoji: '🕊️',
      desc: 'Day 51 effortless grace. Speaking with zero mental exhaustion.',
      bg: Color(0xFF0B0E24),
      secondBg: Color(0xFF13183D),
      btn: Color(0xFF6366F1),
      tick: Color(0xFF818CF8),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 52,
      name: 'Imperial Violet & Silver',
      tier: 'Upper-Inter B2',
      emoji: '👑',
      desc: 'Day 52 regal command. Articulate presentation skills.',
      bg: Color(0xFF1A0B30),
      secondBg: Color(0xFF281347),
      btn: Color(0xFFA855F7),
      tick: Color(0xFFC084FC),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 53,
      name: 'Dark Espresso Blaze',
      tier: 'Upper-Inter B2',
      emoji: '☕',
      desc: 'Day 53 rich caffeine energy. Engaging rapid-fire banter.',
      bg: Color(0xFF170F0A),
      secondBg: Color(0xFF271B12),
      btn: Color(0xFFFF6A00),
      tick: Color(0xFFFFA14D),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 54,
      name: 'Cyber Cobalt & Solar Orange',
      tier: 'Upper-Inter B2',
      emoji: '🎇',
      desc: 'Day 54 explosive fluency. Natural punchy English expressions.',
      bg: Color(0xFF081C38),
      secondBg: Color(0xFF102D57),
      btn: Color(0xFFFF7700),
      tick: Color(0xFFFFA347),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 55,
      name: 'Dark Cosmic Nebula & Royal Purple',
      tier: 'Upper-Inter B2',
      emoji: '🔮',
      desc: 'Day 55 luminous insight. Complex reasoning without pauses.',
      bg: Color(0xFF180A2E),
      secondBg: Color(0xFF271247),
      btn: Color(0xFFA855F7),
      tick: Color(0xFFC084FC),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 56,
      name: 'Forest Moss & Golden Topaz',
      tier: 'Upper-Inter B2',
      emoji: '🌲',
      desc: 'Day 56 grounded confidence. Natural intonation and pitch modulation.',
      bg: Color(0xFF091C14),
      secondBg: Color(0xFF112E21),
      btn: Color(0xFFF59E0B),
      tick: Color(0xFFFBBF24),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 57,
      name: 'Dark Imperial Scarlet & Gold',
      tier: 'Upper-Inter B2',
      emoji: '🪡',
      desc: 'Day 57 finely stitched eloquence. Seamless transitions in debate.',
      bg: Color(0xFF260712),
      secondBg: Color(0xFF3D0C1D),
      btn: Color(0xFFE11D48),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 58,
      name: 'Obsidian Rose Sovereign',
      tier: 'Upper-Inter B2',
      emoji: '🥀',
      desc: 'Day 58 eve of 60-day Sovereign gate! Elite fluency in sight.',
      bg: Color(0xFF20070E),
      secondBg: Color(0xFF330D18),
      btn: Color(0xFFF472B6),
      tick: Color(0xFFFF3366),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 59,
      name: 'Titanium Silver Blade',
      tier: 'Upper-Inter B2',
      emoji: '⚔️',
      desc: 'Day 59 Silver Knight climax! Unstoppable communicative force.',
      bg: Color(0xFF131A26),
      secondBg: Color(0xFF202A3D),
      btn: Color(0xFF38BDF8),
      tick: Color(0xFF60A5FA),
      variant: ProfileUIThemeVariant.silverKnight,
    ),
    _StageDef(
      day: 60,
      name: 'Day 60 Gold Sovereign Gate',
      tier: 'Advanced C1 Sovereign',
      emoji: '🥇',
      desc: '🥇 60-DAY MAJOR GATE! 24K Gold Sovereign Profile UI & Advanced C1 Badge.',
      bg: Color(0xFF120E05),
      secondBg: Color(0xFF1E1808),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
      isMajor: true,
    ),
    _StageDef(
      day: 61,
      name: 'Dark Sovereign Onyx & 24K Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🥂',
      desc: 'Day 61 Sovereign era begins. Prestigious C1 executive communication.',
      bg: Color(0xFF120D06),
      secondBg: Color(0xFF1E170B),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFFE033),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 62,
      name: 'Imperial Crimson Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '👑',
      desc: 'Day 62 regal authority. Speaking with commanding poise.',
      bg: Color(0xFF26060F),
      secondBg: Color(0xFF3B0B19),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 63,
      name: 'Dark Sovereign Jade & Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🌿',
      desc: 'Day 63 organic eloquence. Speaking with unhurried natural rhythm.',
      bg: Color(0xFF051C13),
      secondBg: Color(0xFF0B2D1F),
      btn: Color(0xFF10B981),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 64,
      name: 'Solar Amber Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '☀️',
      desc: 'Day 64 radiant vocabulary. Rich synonyms and expressive metaphors.',
      bg: Color(0xFF0F0B05),
      secondBg: Color(0xFF1C150B),
      btn: Color(0xFFF59E0B),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 65,
      name: 'Sovereign Volt Lightning',
      tier: 'Advanced C1 Sovereign',
      emoji: '⚡',
      desc: 'Day 65 lightning response. Flawless native-speed banter.',
      bg: Color(0xFF070709),
      secondBg: Color(0xFF131317),
      btn: Color(0xFFFFE500),
      tick: Color(0xFFFFEA33),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 66,
      name: 'Royal Sapphire Sunburst',
      tier: 'Advanced C1 Sovereign',
      emoji: '💎',
      desc: 'Day 66 crystalline structure. Delivering keynote-level talks.',
      bg: Color(0xFF081735),
      secondBg: Color(0xFF0E234F),
      btn: Color(0xFFFFC700),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 67,
      name: 'Abyss Cobalt & Neon Tangerine',
      tier: 'Advanced C1 Sovereign',
      emoji: '🐅',
      desc: 'Day 67 predatory fluency. Fast argumentative precision.',
      bg: Color(0xFF071C33),
      secondBg: Color(0xFF0E3054),
      btn: Color(0xFFFF6B00),
      tick: Color(0xFFFF944D),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 68,
      name: 'Dark Sovereign Crimson & Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🏰',
      desc: 'Day 68 fortress of knowledge. Cultured and refined phrasing.',
      bg: Color(0xFF24060E),
      secondBg: Color(0xFF390B17),
      btn: Color(0xFFFF2D55),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 69,
      name: 'Imperial Jade Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '🐉',
      desc: 'Day 69 mythical ease. Complex idioms mastered in daily speech.',
      bg: Color(0xFF061E16),
      secondBg: Color(0xFF0D2E23),
      btn: Color(0xFFFFD700),
      tick: Color(0xFF10B981),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 70,
      name: 'Dark Royal Indigo Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '🏛️',
      desc: 'Day 70 sovereign milestone! 70 days of relentless English habit.',
      bg: Color(0xFF0A0E26),
      secondBg: Color(0xFF12183F),
      btn: Color(0xFF818CF8),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 71,
      name: 'Scarlet Sovereign Flame',
      tier: 'Advanced C1 Sovereign',
      emoji: '🔥',
      desc: 'Day 71 passionate rhetoric. Inspiring others with spoken words.',
      bg: Color(0xFF28060D),
      secondBg: Color(0xFF3E0B17),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFF2D55),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 72,
      name: 'High-Voltage Carbon Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '⚡',
      desc: 'Day 72 raw cognitive power. Zero pause between thought and word.',
      bg: Color(0xFF08080C),
      secondBg: Color(0xFF14141A),
      btn: Color(0xFFFFCC00),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 73,
      name: 'Twilight Solar Flare',
      tier: 'Advanced C1 Sovereign',
      emoji: '🌌',
      desc: 'Day 73 cosmic breadth. Effortless vocabulary in any domain.',
      bg: Color(0xFF1A0A28),
      secondBg: Color(0xFF28113E),
      btn: Color(0xFFFF7A00),
      tick: Color(0xFFFFA84D),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 74,
      name: 'Dark Forest Sovereign & Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🏛️',
      desc: 'Day 74 calm authority. Leading group discussions naturally.',
      bg: Color(0xFF061D13),
      secondBg: Color(0xFF0C2F20),
      btn: Color(0xFF22C55E),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 75,
      name: 'Sovereign Ocean & Amber Flame',
      tier: 'Advanced C1 Sovereign',
      emoji: '🌊',
      desc: 'Day 75 oceanic depth. Grasping international English accents.',
      bg: Color(0xFF061E38),
      secondBg: Color(0xFF0C2F55),
      btn: Color(0xFFFF8000),
      tick: Color(0xFFFFAC4D),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 76,
      name: 'Royal Amethyst Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '👑',
      desc: 'Day 76 jewel-grade speech. Sophisticated vocabulary delivered smoothly.',
      bg: Color(0xFF1C092F),
      secondBg: Color(0xFF2D114B),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFA855F7),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 77,
      name: 'Imperial Ruby Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '🍷',
      desc: 'Day 77 vintage mastery. Rich idioms and historic cultural context.',
      bg: Color(0xFF2C0714),
      secondBg: Color(0xFF420D20),
      btn: Color(0xFFFF2D55),
      tick: Color(0xFFFF5C7A),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 78,
      name: 'Dark Imperial Orchid Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '🪻',
      desc: 'Day 78 delicate precision. Perfect nuance in sensitive talks.',
      bg: Color(0xFF1B082E),
      secondBg: Color(0xFF2B0E47),
      btn: Color(0xFFC084FC),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 79,
      name: 'Sovereign Canary & Carbon',
      tier: 'Advanced C1 Sovereign',
      emoji: '🦅',
      desc: 'Day 79 soaring fluency. Speaking on radio, stage, or mic with ease.',
      bg: Color(0xFF0A0A0E),
      secondBg: Color(0xFF16161E),
      btn: Color(0xFFFFE600),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 80,
      name: 'Sovereign Cobalt & Sunset Amber',
      tier: 'Advanced C1 Sovereign',
      emoji: '🌅',
      desc: 'Day 80 grand 80th milestone! Only 10 days to full graduation.',
      bg: Color(0xFF091C3F),
      secondBg: Color(0xFF112D61),
      btn: Color(0xFFFF6B00),
      tick: Color(0xFFFF994D),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 81,
      name: 'Dark Bloodstone Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '📜',
      desc: 'Day 81 written and spoken synchrony. Eloquence in all forms.',
      bg: Color(0xFF25060C),
      secondBg: Color(0xFF3B0B14),
      btn: Color(0xFFFF3366),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 82,
      name: 'Celestial Obsidian Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🪐',
      desc: 'Day 82 planetary orbit. Global mindset and multicultural speech.',
      bg: Color(0xFF0D0A05),
      secondBg: Color(0xFF1A150A),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 83,
      name: 'Electric Sapphire & Neon Orange',
      tier: 'Advanced C1 Sovereign',
      emoji: '⚡',
      desc: 'Day 83 electric resonance. Effortless native-like spontaneity.',
      bg: Color(0xFF071936),
      secondBg: Color(0xFF0F2B57),
      btn: Color(0xFFFF6600),
      tick: Color(0xFFFF944D),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 84,
      name: 'Dark Glacial Teal Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '🧊',
      desc: 'Day 84 immaculate clarity. Zero phonetic mistakes or hesitation.',
      bg: Color(0xFF041D20),
      secondBg: Color(0xFF082D32),
      btn: Color(0xFF14B8A6),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 85,
      name: 'Imperial Emerald Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🐉',
      desc: 'Day 85 dragon crown countdown. Unrivaled confidence and charm.',
      bg: Color(0xFF051F14),
      secondBg: Color(0xFF0B3020),
      btn: Color(0xFFFFD700),
      tick: Color(0xFF10B981),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 86,
      name: 'Blood Scarlet Sovereign',
      tier: 'Advanced C1 Sovereign',
      emoji: '⚔️',
      desc: 'Day 86 warrior fluency. Handling any high-stakes conversation.',
      bg: Color(0xFF2A060C),
      secondBg: Color(0xFF410C16),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFF3366),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 87,
      name: 'Dark Cobalt Sovereign & Gold',
      tier: 'Advanced C1 Sovereign',
      emoji: '🛡️',
      desc: 'Day 87 silver titanium crest. Complete mastery of English idioms.',
      bg: Color(0xFF071632),
      secondBg: Color(0xFF0E254E),
      btn: Color(0xFF38BDF8),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 88,
      name: 'Sovereign Violet & Radiant Amber',
      tier: 'Advanced C1 Sovereign',
      emoji: '👑',
      desc: 'Day 88 coronation approach. Effortless dual-language thinking.',
      bg: Color(0xFF1B082E),
      secondBg: Color(0xFF2C0F4A),
      btn: Color(0xFFFF8800),
      tick: Color(0xFFFFB366),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 89,
      name: 'Penultimate Sovereign Gate',
      tier: 'Advanced C1 Sovereign',
      emoji: '🗝️',
      desc: 'Day 89 eve of the Diamond Grandmaster! 89 days of sheer mastery.',
      bg: Color(0xFF0C0904),
      secondBg: Color(0xFF181308),
      btn: Color(0xFFFFD700),
      tick: Color(0xFFFFD700),
      variant: ProfileUIThemeVariant.goldSovereign,
    ),
    _StageDef(
      day: 90,
      name: 'Day 90 Diamond Master',
      tier: 'Grandmaster C2 Diamond',
      emoji: '💎',
      desc: '👑 90-DAY TRANSFORMATION COMPLETE! Full Native Mastery, Holographic Profile Aura & Astral Cosmic Dragon Crown.',
      bg: Color(0xFF03050C),
      secondBg: Color(0xFF0E1428),
      btn: Color(0xFFFFFC00),
      tick: Color(0xFF00F0FF),
      variant: ProfileUIThemeVariant.diamondCelestial,
      isMajor: true,
    ),
  ];


  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Resolves the stage matching a given learning day (1 to 90)
  static LearningMilestoneStage getStageForDay(int day) {
    final clampedDay = day.clamp(1, 90);
    return allStages[clampedDay - 1];
  }
}

/// Represents one daily practical English task for today's checklist
class DailyEnglishTask {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int points;
  final int targetMinutes;
  final bool isCompleted;
  final String? mediaType; // 'youtube', 'podcast', 'movie'
  final String? mediaUrl;
  final String? recommendedMovie;
  final List<String> keyListeningPhrases;

  const DailyEnglishTask({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    this.targetMinutes = 20,
    this.isCompleted = false,
    this.mediaType,
    this.mediaUrl,
    this.recommendedMovie,
    this.keyListeningPhrases = const [],
  });

  DailyEnglishTask copyWith({
    bool? isCompleted,
    String? mediaType,
    String? mediaUrl,
    String? recommendedMovie,
    List<String>? keyListeningPhrases,
  }) {
    return DailyEnglishTask(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      points: points,
      targetMinutes: targetMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      recommendedMovie: recommendedMovie ?? this.recommendedMovie,
      keyListeningPhrases: keyListeningPhrases ?? this.keyListeningPhrases,
    );
  }
}

/// User's overall 90-Day Progress Snapshot with Pocket Score and Inactivity Decay
class UserLearningProgress {
  final int currentDay; // 1 to 90 (also current stage)
  final int currentStage; // 1 to 90
  final int streakDays; // Consecutive active days
  final int totalPoints; // Pocket Score
  final int minutesPracticedToday; // 0 to 120 mins
  final int targetDailyMinutes; // 90 mins (1.5 hours)
  final int missedDaysCount; // Inactivity decay count
  final bool hasInactivityWarning;
  final DateTime lastActiveDate;
  final List<DailyEnglishTask> todayTasks;

  const UserLearningProgress({
    this.currentDay = 1,
    this.currentStage = 1,
    this.streakDays = 1,
    this.totalPoints = 0,
    this.minutesPracticedToday = 0,
    this.targetDailyMinutes = 90,
    this.missedDaysCount = 0,
    this.hasInactivityWarning = false,
    required this.lastActiveDate,
    this.todayTasks = const [],
  });

  double get progressPercentage => (currentDay / 90.0).clamp(0.0, 1.0);
  double get dailyTimePercentage =>
      (minutesPracticedToday / targetDailyMinutes.toDouble()).clamp(0.0, 1.0);
  LearningMilestoneStage get activeStage =>
      LearningMilestoneStage.getStageForDay(currentDay);
  LearningMilestoneStage? get nextStage =>
      currentDay < 90 ? LearningMilestoneStage.allStages[currentDay] : null;

  UserLearningProgress copyWith({
    int? currentDay,
    int? currentStage,
    int? streakDays,
    int? totalPoints,
    int? minutesPracticedToday,
    int? targetDailyMinutes,
    int? missedDaysCount,
    bool? hasInactivityWarning,
    DateTime? lastActiveDate,
    List<DailyEnglishTask>? todayTasks,
  }) {
    return UserLearningProgress(
      currentDay: currentDay ?? this.currentDay,
      currentStage: currentStage ?? this.currentStage,
      streakDays: streakDays ?? this.streakDays,
      totalPoints: totalPoints ?? this.totalPoints,
      minutesPracticedToday: minutesPracticedToday ?? this.minutesPracticedToday,
      targetDailyMinutes: targetDailyMinutes ?? this.targetDailyMinutes,
      missedDaysCount: missedDaysCount ?? this.missedDaysCount,
      hasInactivityWarning: hasInactivityWarning ?? this.hasInactivityWarning,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      todayTasks: todayTasks ?? this.todayTasks,
    );
  }

  String get currentPhaseTitle {
    if (currentDay < 30) return 'Phase 1: Genesis & Habit (Days 1–29)';
    if (currentDay < 60) return 'Phase 2: Silver Knight Fluency (Days 30–59)';
    if (currentDay < 90) return 'Phase 3: Gold Sovereign Mastery (Days 60–89)';
    return 'Phase 4: Diamond Grandmaster (Day 90)';
  }
}

/// Comprehensive pedagogical syllabus model for each of the 90 days
class EnglishCurriculumLesson {
  final int day;
  final String title;
  final String phaseName;
  final String focusArea;
  final String speakingDrill;
  final String grammarConcept;
  final String peerChatMission;
  final int targetMinutes;
  final int xpReward;
  final String milestoneReward;

  const EnglishCurriculumLesson({
    required this.day,
    required this.title,
    required this.phaseName,
    required this.focusArea,
    required this.speakingDrill,
    required this.grammarConcept,
    required this.peerChatMission,
    this.targetMinutes = 90,
    this.xpReward = 35,
    this.milestoneReward = '',
  });

  static EnglishCurriculumLesson getLessonForDay(int day) {
    if (day <= 30) {
      return _generatePhase1Lesson(day);
    } else if (day <= 60) {
      return _generatePhase2Lesson(day);
    } else {
      return _generatePhase3Lesson(day);
    }
  }

  static EnglishCurriculumLesson _generatePhase1Lesson(int day) {
    final List<Map<String, String>> p1Topics = [
      {
        'title': 'Breaking Voice Hesitation & Self-Intro',
        'focus': 'Confidence & Vocal Warmups',
        'drill': 'Record a 60s introduction without hesitation or fillers.',
        'grammar': 'Present Simple vs Present Continuous',
        'peer': 'Introduce yourself in 5 English sentences to a Pocket Mate.'
      },
      {
        'title': 'Describing Your Daily Life & Habits',
        'focus': 'Everyday Action Verbs',
        'drill': 'Narrate what you did since waking up in chronological order.',
        'grammar': 'Adverbs of Frequency (always, usually, seldom)',
        'peer':
            'Ask your partner 3 questions about their daily morning routine.'
      },
      {
        'title': 'Food, Flavors & Cooking Stories',
        'focus': 'Sensory & Descriptive Words',
        'drill': 'Describe your favorite dish using at least 4 adjectives.',
        'grammar': 'Countable vs Uncountable Nouns',
        'peer': 'Debate food preferences with your mate in English.'
      },
      {
        'title': 'Navigating Places & Asking Directions',
        'focus': 'Prepositions & Polite Requests',
        'drill':
            'Give step-by-step oral directions from your home to a nearby landmark.',
        'grammar': 'Prepositions of Place (opposite, adjacent, across)',
        'peer': 'Roleplay asking for directions in an unfamiliar city.'
      },
      {
        'title': 'Expressing Likes, Dislikes & Hobbies',
        'focus': 'Emotional Nuance & Phrasing',
        'drill': 'Talk for 90s about a hobby that excites you.',
        'grammar': 'Gerunds vs Infinitives (enjoy doing vs like to do)',
        'peer': 'Find 2 common interests with your peer mate.'
      },
      {
        'title': 'Past Experiences & Memorable Trips',
        'focus': 'Past Tense Narration',
        'drill': 'Tell a 2-min story about the best trip of your life.',
        'grammar': 'Irregular Past Tense Verbs & Pronunciation of "-ed"',
        'peer': 'Share an unforgettable travel memory with your mate.'
      },
      {
        'title': 'Week 1 Review & Fluency Check',
        'focus': 'Sentence Rhythm & Syllable Stress',
        'drill': 'Perform a 3-min continuous monologue without stopping.',
        'grammar': 'Sentence Structure & Conjunctions (although, because)',
        'peer': 'Do a 10-minute live voice chat with an English mate.'
      },
    ];

    final index = (day - 1) % p1Topics.length;
    final topic = p1Topics[index];
    final isDay21 = day == 21;
    final isDay30 = day == 30;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay21
          ? '🎯 Day 21 Habit Anchor: Uninterrupted Speech'
          : (isDay30
              ? '🥈 Day 30 Silver Knight Foundation Gate'
              : 'Day $day: ${topic['title']!}'),
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea:
          isDay21 ? 'Permanent Habit Formation & Flow State' : topic['focus']!,
      speakingDrill: isDay21
          ? 'Speak continuously for 5 full minutes without pausing or using native language.'
          : topic['drill']!,
      grammarConcept: isDay21
          ? 'Conditionals (If I practice daily, I will master English)'
          : topic['grammar']!,
      peerChatMission: isDay21
          ? 'Celebrate your 21-day streak with your Pocket Mate in an audio chat.'
          : topic['peer']!,
      targetMinutes: 90,
      xpReward: isDay21 ? 100 : (isDay30 ? 150 : 35),
      milestoneReward: isDay21
          ? '🎯 Habit Anchor Lock Badge & Red Verified Tick'
          : (isDay30 ? '🥈 Silver Knight Shield & Chrome Profile Theme' : ''),
    );
  }

  static EnglishCurriculumLesson _generatePhase2Lesson(int day) {
    final List<Map<String, String>> p2Topics = [
      {
        'title': 'Polite Disagreements & Debating Skills',
        'focus': 'Diplomatic Rhetoric',
        'drill':
            'Defend an unpopular opinion politely using "I see your point, however...".',
        'grammar': 'Modal Verbs of Deduction (must, might, can\'t be)',
        'peer': 'Debate "Remote Work vs Office" with your mate in English.'
      },
      {
        'title': 'Business & Professional Email Spoken Pitch',
        'focus': 'Workplace Vocabulary',
        'drill':
            'Deliver a 90s elevator pitch for a product or service you love.',
        'grammar': 'Passive Voice in Professional Contexts',
        'peer': 'Simulate a client interview call with your Pocket Mate.'
      },
      {
        'title': 'Mastering Common Native Idioms',
        'focus': 'Figurative Language',
        'drill':
            'Incorporate 3 idioms (e.g., "cut corners", "hit the nail") into a speech.',
        'grammar': 'Phrasal Verbs (look into, come across, put off)',
        'peer': 'Use 2 idioms naturally in your chat with your peer.'
      },
      {
        'title': 'Storytelling with Suspense & Climax',
        'focus': 'Narrative Arc & Pacing',
        'drill': 'Narrate a fictional thriller story with voice modulation.',
        'grammar': 'Past Perfect vs Past Perfect Continuous',
        'peer':
            'Take turns building a collaborative story sentence-by-sentence.'
      },
      {
        'title': 'Explaining Complex Ideas Simply',
        'focus': 'Clarity & Analogies',
        'drill':
            'Explain how AI or the Internet works to a 10-year-old in English.',
        'grammar': 'Relative Clauses (defining and non-defining)',
        'peer': 'Teach your mate a concept from your expertise.'
      },
      {
        'title': 'Spontaneous Question Answering',
        'focus': 'Zero Translation Lag',
        'drill':
            'Answer 5 random interview questions immediately without thinking in Malayalam.',
        'grammar': 'Indirect & Tag Questions (Isn\'t it, wouldn\'t you)',
        'peer': 'Rapid fire Q&A session with your peer mate.'
      },
    ];

    final index = (day - 31) % p2Topics.length;
    final topic = p2Topics[index];
    final isDay60 = day == 60;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay60
          ? '👑 Day 60 Gold Sovereign Fluency Gate'
          : 'Day $day: ${topic['title']!}',
      phaseName:
          'Phase 2: Intermediate Fluency & Complex Scenarios (Days 31–60)',
      focusArea:
          isDay60 ? '24K Professional Fluency & Leadership' : topic['focus']!,
      speakingDrill: isDay60
          ? 'Deliver a 5-minute keynote presentation in English on a topic you care about.'
          : topic['drill']!,
      grammarConcept: isDay60
          ? 'Mixed Conditionals & Inversion for Emphasis'
          : topic['grammar']!,
      peerChatMission: isDay60
          ? 'Conduct an in-depth 20-min discussion on global trends with your Pocket Mate.'
          : topic['peer']!,
      targetMinutes: 100,
      xpReward: isDay60 ? 250 : 50,
      milestoneReward:
          isDay60 ? '👑 24K Gold Sovereign Crown & Luxury Gold Theme' : '',
    );
  }

  static EnglishCurriculumLesson _generatePhase3Lesson(int day) {
    final List<Map<String, String>> p3Topics = [
      {
        'title': 'Impromptu Monologues & Thought Articulation',
        'focus': 'Instant Coherence',
        'drill':
            'Pick a random word and give a 3-minute structured speech on it immediately.',
        'grammar': 'Discourse Markers & Transition Hooks',
        'peer': 'Listen and provide critical feedback on your mate\'s speech.'
      },
      {
        'title': 'Nuance, Tone Modulation & Persuasion',
        'focus': 'Emotional Intelligence in Speech',
        'drill':
            'Deliver the same speech in three different tones: inspiring, urgent, calm.',
        'grammar': 'Subjunctive Mood & Advanced Rhetoric',
        'peer': 'Practice persuasive negotiation with your partner.'
      },
      {
        'title': 'Philosophical & Abstract Discussions',
        'focus': 'Abstract Vocabulary',
        'drill':
            'Analyze a famous proverb (e.g. "Action speaks louder than words") for 3 minutes.',
        'grammar':
            'Cleft Sentences for Focus (It is... that, What we need is...)',
        'peer': 'Discuss the future of human society in English.'
      },
      {
        'title': 'High-Stakes Interview & Q&A Mastery',
        'focus': 'Executive Presence',
        'drill':
            'Handle 3 tough behavioral questions ("Describe a major failure and what you learned").',
        'grammar': 'STAR Method Phrasing (Situation, Task, Action, Result)',
        'peer': 'Conduct a mock job interview with your mate.'
      },
      {
        'title': 'Humor, Sarcasm & Cultural Context',
        'focus': 'Native-Level Wit',
        'drill':
            'Tell a humorous anecdote in English and land the punchline naturally.',
        'grammar': 'Colloquial Expressions & Intonation Curves',
        'peer': 'Share jokes and funny real-life stories in English.'
      },
    ];

    final index = (day - 61) % p3Topics.length;
    final topic = p3Topics[index];
    final isDay90 = day == 90;

    return EnglishCurriculumLesson(
      day: day,
      title: isDay90
          ? '💎 Day 90 Diamond Master Capstone Graduation'
          : 'Day $day: ${topic['title']!}',
      phaseName: 'Phase 3: Advanced Mastery & Thought Leadership (Days 61–90)',
      focusArea: isDay90
          ? 'Native Fluency, Public Speaking & Mastery'
          : topic['focus']!,
      speakingDrill: isDay90
          ? 'Deliver your 10-Minute Capstone Graduation Speech in English without notes.'
          : topic['drill']!,
      grammarConcept: isDay90
          ? 'Mastery of all Advanced Rhetorical Devices'
          : topic['grammar']!,
      peerChatMission: isDay90
          ? 'Congratulate fellow learners and celebrate full English fluency graduation!'
          : topic['peer']!,
      targetMinutes: 120,
      xpReward: isDay90 ? 500 : 75,
      milestoneReward: isDay90
          ? '💎 Diamond Celestial Ring, Grandmaster Trophy & Verified Certificate'
          : '',
    );
  }
}