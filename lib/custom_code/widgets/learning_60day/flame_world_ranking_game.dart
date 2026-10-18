import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart'
    show HousePalette, HouseMasterComponent;

/// 🌦️ Atmosphere & Weather Presets for the Mountain Canyon
enum CanyonAtmosphere {
  auto,
  day,
  sunset,
  night,
  rain,
}

/// 🏡 Data Node for a Ranked Player's Mountain Cliff Terrace
class WorldRankingLedgeNode {
  final int index;
  final int rank;
  final int totalWorldUsers;
  final PocketRankedUser member;
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isLeft;
  final HouseMasterComponent houseComp;
  final double houseX;
  final double houseY;
  final double houseW;
  final double houseH;
  late Rect houseHitRect;
  late Rect fullHitRect;
  late Rect badgeHitRect; // User Audio Directive: Only badge tap opens profile

  // 🪵 Mountain Wooden Plank Descent Ramp (പലക) connecting down to next terrace (User Audio Directive)
  double rampStartX = 0.0;
  double rampStartY = 0.0;
  double rampEndX = 0.0;
  double rampEndY = 0.0;
  bool hasRamp = false;

  WorldRankingLedgeNode({
    required this.index,
    required this.rank,
    required this.totalWorldUsers,
    required this.member,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isLeft,
    required this.houseComp,
    required this.houseX,
    required this.houseY,
    required this.houseW,
    required this.houseH,
  }) {
    fullHitRect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );
    houseHitRect = Rect.fromLTWH(
      houseX - 10,
      houseY - 24,
      houseW + 20,
      houseH + 34,
    );
    badgeHitRect = Rect.fromCenter(
      center: Offset(houseX + houseW * 0.5, houseY - 14.0),
      width: (houseW + 60.0).clamp(130.0, 260.0),
      height: 44.0, // Generous hit area for mobile fingers
    );
  }

  int get altitudeMeters => math.max(100, (totalWorldUsers - rank + 1) * 100);
  int get floorNumber => (totalWorldUsers - rank + 1);
}

/// 💎 Floating English Vocabulary Gem for Canyon Trail Learning (User Audio Directive)
class CanyonVocabGem {
  final int id;
  final double x;
  final double y;
  final String word;
  final String phonetic;
  final String malayalam;
  final String spokenExample;
  final Color color;
  bool isCollected = false;

  CanyonVocabGem({
    required this.id,
    required this.x,
    required this.y,
    required this.word,
    required this.phonetic,
    required this.malayalam,
    required this.spokenExample,
    required this.color,
  });
}

final List<Map<String, String>> kCanyonVocabCatalog = [
  {
    'word': 'Summit',
    'phonetic': '/ˈsʌm.ɪt/',
    'malayalam': 'കൊടുമുടി',
    'example': 'We reached the summit before sunrise!',
  },
  {
    'word': 'Breeze',
    'phonetic': '/briːz/',
    'malayalam': 'ഇളംകാറ്റ്',
    'example': 'A gentle breeze cooled the afternoon.',
  },
  {
    'word': 'Courage',
    'phonetic': '/ˈkʌr.ɪdʒ/',
    'malayalam': 'ധൈര്യം',
    'example': 'Have the courage to speak up boldly.',
  },
  {
    'word': 'Ascend',
    'phonetic': '/əˈsend/',
    'malayalam': 'കയറുക',
    'example': 'Ascend step by step to fluency.',
  },
  {
    'word': 'Majestic',
    'phonetic': '/məˈdʒes.tɪk/',
    'malayalam': 'പ്രൗഢമായ',
    'example': 'The canyon cliffs are majestic and grand.',
  },
  {
    'word': 'Persevere',
    'phonetic': '/ˌpɜː.sɪˈvɪər/',
    'malayalam': 'സ്ഥിരോത്സാഹം കാട്ടുക',
    'example': 'Persevere daily to achieve your dreams.',
  },
  {
    'word': 'Triumph',
    'phonetic': '/ˈtraɪ.ʌmf/',
    'malayalam': 'വിജയം',
    'example': 'Practice will lead to your ultimate triumph.',
  },
  {
    'word': 'Horizon',
    'phonetic': '/həˈraɪ.zən/',
    'malayalam': 'ചക്രവാളം',
    'example': 'Keep your eyes fixed on the horizon.',
  },
  {
    'word': 'Velocity',
    'phonetic': '/vəˈlɒs.ə.ti/',
    'malayalam': 'വേഗത',
    'example': 'The dirt bike gained tremendous velocity.',
  },
  {
    'word': 'Trailblazer',
    'phonetic': '/ˈtreɪlˌbleɪ.zər/',
    'malayalam': 'വഴികാട്ടി',
    'example': 'Be an inspiring trailblazer for others.',
  },
  {
    'word': 'Resilience',
    'phonetic': '/rɪˈzɪl.jəns/',
    'malayalam': 'പ്രതിരോധശേഷി',
    'example': 'Resilience turns every mistake into learning.',
  },
  {
    'word': 'Stamina',
    'phonetic': '/ˈstæm.ɪ.nə/',
    'malayalam': 'സഹനശക്തി',
    'example': 'Build linguistic stamina by daily practice.',
  },
  {
    'word': 'Grit',
    'phonetic': '/ɡrɪt/',
    'malayalam': 'ഉറച്ച മനസ്സ്',
    'example': 'True champions win through pure grit.',
  },
  {
    'word': 'Pinnacle',
    'phonetic': '/ˈpɪn.ə.kəl/',
    'malayalam': 'ശിഖരം / ഉന്നതി',
    'example': 'Speaking fluently is the pinnacle of learning.',
  },
  {
    'word': 'Momentum',
    'phonetic': '/məˈmen.təm/',
    'malayalam': 'ആക്കം',
    'example': 'Keep the momentum going every single day.',
  },
  {
    'word': 'Zenith',
    'phonetic': '/ˈzen.ɪθ/',
    'malayalam': 'പാരമ്യം',
    'example': 'Your English fluency will reach its zenith.',
  },
];

/// ✨ Floating Text Particle for Score (+25 PTS)
class _FloatingScoreText {
  double x;
  double y;
  final String text;
  final Color color;
  double life = 1.0;
  final double maxLife = 1.0;

  _FloatingScoreText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
  });

  bool update(double dt) {
    life -= dt / maxLife;
    y -= 42.0 * dt;
    return life > 0;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final alpha = (life * 255).clamp(0, 255).toInt();
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: color.withAlpha(alpha),
          shadows: [
            Shadow(
              color: Colors.black.withAlpha((alpha * 0.85).toInt()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }
}

/// 🌟 Golden Star Spark Particle on Dirt Bike Cliff Landing
class _BounceSpark {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life = 1.0;
  final Color color;

  _BounceSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 85.0 * dt;
    life -= dt * 2.4;
    return life > 0;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final alpha = (life * 255).clamp(0, 255).toInt();
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), size * life, paint);
  }
}

/// 💨 Dynamic Dust Puff Particle Ejected by Dirt Bike Knobby Tire
class _DustPuff {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double life = 1.0;

  _DustPuff({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    radius += 6.5 * dt;
    life -= dt * 2.6;
    return life > 0;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final alpha = (life * 140).clamp(0, 255).toInt();
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withAlpha(alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}

/// 🎮 Flame Game Engine Implementation for World Ranking Mountain Canyon
/// Visuals & Gameplay:
/// - Majestic vertical mountain canyon with waterfalls & turquoise river floor
/// - Alternating left & right cliff terraces with lush green grass
/// - Tall, beautiful storybook cottages (185x140px) solidly seated on each plateau
/// - Deep open celestial sky with sun, moon, and drifting cumulus clouds
/// - Wooden waypoint signposts (👑 RANK 1, 🥈 RANK 2, etc.) on each cliff edge
/// - 🏍️ Interactive Mountain Trial Dirt Bike & Motocross Rider:
///   - Drive left & right across terraces with spinning wheels & dust puffs
///   - Launch parabolic cliff jumps across the canyon from terrace to terrace
///   - Smooth suspension spring bounce on landings with combo score bursts
class FlameWorldRankingGame extends FlameGame with TapCallbacks {
  List<PocketRankedUser> users;
  String currentUserId;
  final void Function(PocketRankedUser user)? onHouseTapped;
  final void Function(int rank, PocketRankedUser user)? onRankSelected;
  final void Function(String word, String malayalam, String example)? onVocabCollected;

  FlameWorldRankingGame({
    required this.users,
    this.currentUserId = '',
    this.onHouseTapped,
    this.onRankSelected,
    this.onVocabCollected,
  });

  // World & Camera State
  double cameraY = 0.0;
  double targetCameraY = 0.0;
  double velocityY = 0.0;
  bool isFollowingBike = true;
  CanyonAtmosphere atmosphere = CanyonAtmosphere.day;
  double gameTime = 0.0;

  // Ledges
  final List<WorldRankingLedgeNode> _ledgeNodes = [];
  double _totalWorldHeight = 1800.0;

  // 💎 Canyon English Vocabulary Gems (User Audio Directive: "kuraye vocabularies padikkan pattanam spoken englishum")
  final List<CanyonVocabGem> _vocabGems = [];
  String? _activeVocabWord;
  String? _activeVocabMalayalam;
  String? _activeVocabExample;
  double _activeVocabTimer = 0.0;

  // 🏍️ Mountain Trial Dirt Bike State & Physics (Audio Requirement)
  int _bikeNodeIndex = 0;
  double _bikeX = 200.0;
  double _bikeY = 320.0;
  double _bikeVx = 0.0;
  double _bikeTilt = 0.0;
  double _wheelRotation = 0.0;
  bool _isAirborne = false;
  bool _isFacingRight = true;
  double _arcProgress = 0.0;
  double _suspensionBounce = 1.0;
  double _idleDriveTimer = 0.0;
  double steerInput = 0.0;
  double _dustTimer = 0.0;
  int currentCombo = 0;
  bool _canyonConqueredCelebrated = false;

  final List<_FloatingScoreText> _floatingTexts = [];
  final List<_BounceSpark> _sparks = [];
  final List<_DustPuff> _dustPuffs = [];

  // Clouds & Ambient Details
  final List<Offset> _clouds = [];

  @override
  Color backgroundColor() => const Color(0xFF0284C7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initEnvironment();
    _buildWorldNodes();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _buildWorldNodes();
  }

  void _initEnvironment() {
    final rng = math.Random(101);
    _clouds.clear();
    for (int i = 0; i < 20; i++) {
      _clouds.add(Offset(rng.nextDouble() * 400.0, rng.nextDouble() * 3200.0));
    }
  }

  void updateUsers(List<PocketRankedUser> newUsers, {String? newCurrentUserId}) {
    users = newUsers;
    if (newCurrentUserId != null) {
      currentUserId = newCurrentUserId;
    }
    _buildWorldNodes();
  }

  void setAtmosphere(CanyonAtmosphere newAtmosphere) {
    atmosphere = newAtmosphere;
  }

  void setFollowBall(bool follow) {
    isFollowingBike = follow;
  }

  void setPlayMode(bool play) {}

  // 🕹️ Dirt Bike Steering & Jump Controls (Audio Directive)
  void steerLeft() {
    isFollowingBike = true;
    velocityY = 0.0;
    steerInput = -1.0;
    _isFacingRight = false;
    _idleDriveTimer = 0.0;
  }

  void steerRight() {
    isFollowingBike = true;
    velocityY = 0.0;
    steerInput = 1.0;
    _isFacingRight = true;
    _idleDriveTimer = 0.0;
  }

  void steerNeutral() {
    steerInput = 0.0;
  }

  void tapDriveLeft() {
    isFollowingBike = true;
    velocityY = 0.0;
    _idleDriveTimer = 0.0;
    _isFacingRight = false;
    _bikeVx = -240.0;
  }

  void tapDriveRight() {
    isFollowingBike = true;
    velocityY = 0.0;
    _idleDriveTimer = 0.0;
    _isFacingRight = true;
    _bikeVx = 240.0;
  }

  /// 🏎️ Drive towards the cliff edge of whichever terrace the player is currently on
  void driveForward() {
    driveDownhill();
  }

  /// 🏔️ Drive forward along current terrace or ramp down towards next terrace
  void driveDownhill() {
    if (_ledgeNodes.isEmpty) return;
    isFollowingBike = true;
    velocityY = 0.0;
    _idleDriveTimer = 0.0;
    final currentNode = _ledgeNodes[_bikeNodeIndex];
    final isLastNode = (_bikeNodeIndex >= _ledgeNodes.length - 1);
    if (isLastNode) {
      // On canyon floor, drive straight forward in facing direction (Audio directive: "ഡൗൺ ഒന്നുമില്ല ആക്ച്വലി, വണ്ടി ഇങ്ങനെ സ്ട്രെയിറ്റ് ആയിട്ട് മൂവ് ചെയ്ത് പോവുക")
      _bikeVx = _isFacingRight ? 240.0 : -240.0;
      steerInput = _isFacingRight ? 1.0 : -1.0;
    } else if (currentNode.isLeft) {
      // Downhill on left terrace is driving RIGHT towards cliff ramp
      _isFacingRight = true;
      _bikeVx = (_bikeVx.abs() < 120.0) ? 220.0 : math.min(380.0, _bikeVx + 110.0);
      steerInput = 1.0;
    } else {
      // Downhill on right terrace is driving LEFT towards cliff ramp
      _isFacingRight = false;
      _bikeVx = (_bikeVx.abs() < 120.0) ? -220.0 : math.max(-380.0, _bikeVx - 110.0);
      steerInput = -1.0;
    }
  }

  void steerBy(double deltaX) {
    isFollowingBike = true;
    velocityY = 0.0;
    _idleDriveTimer = 0.0;
    _bikeX = (_bikeX + deltaX).clamp(20.0, size.x - 20.0);
    if (deltaX > 0.5) _isFacingRight = true;
    if (deltaX < -0.5) _isFacingRight = false;
  }

  /// 🚀 Launch Dirt Bike into Parabolic Canyon Leap down to next terrace
  void jump() {
    if (_isAirborne || _ledgeNodes.length < 2) return;
    if (_bikeNodeIndex >= _ledgeNodes.length - 1) {
      // Small hop on canyon floor without looping back to top
      _suspensionBounce = 0.5;
      HapticFeedback.mediumImpact();
      _bikeVx = _isFacingRight ? 200.0 : -200.0;
      return;
    }
    _launchBikeJump();
  }

  double get _maxScrollY => math.max(0.0, _totalWorldHeight - size.y);

  /// 🏔️ Build Alternating Cliff Terraces with Large Architectural Houses
  /// User Audio Directive: "ആ വീട് കുറച്ച് വലുതാക്കിയിട്ട് തന്നെ പ്ലേസ് ചെയ്യാം. വീട് വലുതാക്കി കാണിക്കണം കേട്ടോ.
  /// ഇറങ്ങാൻ ആയിട്ട് ഒരു പലക പോലെ എന്തെങ്കിലും വെച്ചിട്ട്, ആ പലകയിൽ കൂടെ ഇറങ്ങിയിട്ട് അങ്ങനെ അങ്ങനെ ആക്കാൻ പറ്റുമോ?"
  /// - Grand Storybook Cottages: 180px wide x 135px tall (100% prominent & majestic)
  /// - Wooden Plank Descent Ramps (പലക): Connect each terrace down to the next terrace!
  void _buildWorldNodes() {
    if (size.x <= 0 || size.y <= 0) return;

    _ledgeNodes.clear();

    final screenW = size.x;
    const double startOffsetY = 320.0;
    const double stepY = 260.0; // Perfect vertical pitch for smooth downhill wooden plank descent
    double currentY = startOffsetY;
    final totalCount = users.length;

    // Storybook house size: BIG and prominent as requested by user ("വീട് വലുതാക്കി കാണിക്കണം കേട്ടോ")
    const double houseW = 180.0;
    const double houseH = 135.0;

    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final rank = i + 1;
      final isLast = (i == users.length - 1);

      // Alternating cliffs: Left (even) vs Right (odd)
      final bool isLeft = (i % 2 == 0);
      final double houseX;
      final double houseY = currentY - houseH - 2.0;

      // Wooden Plank Descent Ramp (പലക) geometry connecting to the next terrace below
      double rampStartX = 0.0;
      double rampStartY = currentY;
      double rampEndX = 0.0;
      double rampEndY = currentY + stepY;
      bool hasRamp = false;

      final double ledgeW;

      if (isLast) {
        // Canyon Floor: Spans full width
        houseX = (screenW - houseW) / 2.0;
        ledgeW = screenW;
        hasRamp = false;
      } else if (isLeft) {
        // Even Level: House on Left, Ramp starts after house and slopes down to right
        houseX = 12.0;
        rampStartX = math.max(houseX + houseW + 8.0, screenW * 0.44);
        final bool isNextLast = (i + 1 == totalCount - 1);
        final double nextHouseX = isNextLast ? (screenW - houseW) / 2.0 : (screenW - houseW - 12.0);
        // Step arrives right at the house entrance, NEVER continuing underneath or behind the house!
        rampEndX = nextHouseX - 6.0;
        hasRamp = true;
        ledgeW = rampStartX + 14.0;
      } else {
        // Odd Level: House on Right, Ramp starts before house and slopes down to left
        houseX = screenW - houseW - 12.0;
        rampStartX = math.min(houseX - 8.0, screenW * 0.56);
        final bool isNextLast = (i + 1 == totalCount - 1);
        final double nextHouseRight = isNextLast ? (screenW + houseW) / 2.0 : (12.0 + houseW);
        // Step arrives right at the house entrance, NEVER continuing underneath or behind the house!
        rampEndX = nextHouseRight + 6.0;
        hasRamp = true;
        ledgeW = screenW - (rampStartX - 14.0);
      }

      // Large, detailed architectural house component
      final palette =
          HousePalette.presets[(user.level - 1) % HousePalette.presets.length];
      final house = HouseMasterComponent(
        day: user.level,
        streak: math.max(1, (user.pocketScore ~/ 250).clamp(1, 99)),
        palette: palette,
        isPresident: user.isPrestigeSovereign || rank <= 3,
      );
      house.lightsOn = true;
      house.resize(Vector2(houseW, houseH));

      final node = WorldRankingLedgeNode(
        index: i,
        rank: rank,
        totalWorldUsers: totalCount,
        member: user,
        x: isLeft ? (ledgeW * 0.5) : (screenW - ledgeW * 0.5),
        y: currentY,
        width: ledgeW,
        height: 120.0,
        isLeft: isLeft,
        houseComp: house,
        houseX: houseX,
        houseY: houseY,
        houseW: houseW,
        houseH: houseH,
      );

      node.rampStartX = rampStartX;
      node.rampStartY = rampStartY;
      node.rampEndX = rampEndX;
      node.rampEndY = rampEndY;
      node.hasRamp = hasRamp;

      _ledgeNodes.add(node);
      currentY += stepY;
    }

    _totalWorldHeight = currentY + 380.0;

    // Populate Canyon Vocabulary & Spoken English Gems (User Audio Directive)
    _vocabGems.clear();
    final gemColors = [
      const Color(0xFF38BDF8), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFA855F7), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
    ];

    for (int i = 0; i < _ledgeNodes.length; i++) {
      final node = _ledgeNodes[i];
      final vocabData = kCanyonVocabCatalog[i % kCanyonVocabCatalog.length];
      final gemColor = gemColors[i % gemColors.length];

      // 1. Gem along the terrace road in front of the house
      final roadGemX = node.isLeft
          ? (node.houseX + 45.0)
          : (node.houseX + node.houseW - 45.0);
      _vocabGems.add(CanyonVocabGem(
        id: i * 2,
        x: roadGemX.clamp(32.0, screenW - 32.0),
        y: node.y - 18.0,
        word: vocabData['word']!,
        phonetic: vocabData['phonetic']!,
        malayalam: vocabData['malayalam']!,
        spokenExample: vocabData['example']!,
        color: gemColor,
      ));

      // 2. Gem placed directly on the wooden plank ramp (പലക)
      if (node.hasRamp) {
        final rampVocabData =
            kCanyonVocabCatalog[(i + 7) % kCanyonVocabCatalog.length];
        final midRampX = (node.rampStartX + node.rampEndX) / 2.0;
        final midRampY = (node.rampStartY + node.rampEndY) / 2.0 - 18.0;
        _vocabGems.add(CanyonVocabGem(
          id: i * 2 + 1,
          x: midRampX.clamp(36.0, screenW - 36.0),
          y: midRampY,
          word: rampVocabData['word']!,
          phonetic: rampVocabData['phonetic']!,
          malayalam: rampVocabData['malayalam']!,
          spokenExample: rampVocabData['example']!,
          color: const Color(0xFFFFD700), // Golden glowing gem on wooden plank ramp
        ));
      }
    }

    // Reset dirt bike at Rank 1 summit terrace road
    if (_ledgeNodes.isNotEmpty) {
      _bikeNodeIndex = 0;
      _arcProgress = 0.0;
      _isAirborne = false;
      final summit = _ledgeNodes[0];
      _bikeX = summit.houseX + 35.0;
      _bikeY = summit.y - 14.0;
      _isFacingRight = true;
    }
  }

  // ---------------------------------------------------------------------------
  // Touch & Camera Controls
  // ---------------------------------------------------------------------------

  void scrollBy(double dy) {
    isFollowingBike = false;
    cameraY = (cameraY + dy).clamp(0.0, _maxScrollY);
    targetCameraY = cameraY;
  }

  void fling(double vy) {
    isFollowingBike = false;
    velocityY = vy;
  }

  void panToRank(int targetRank) {
    isFollowingBike = false;
    if (_ledgeNodes.isEmpty) return;
    final index = _ledgeNodes.indexWhere((n) => n.rank == targetRank);
    if (index != -1) {
      final node = _ledgeNodes[index];
      targetCameraY = (node.y - size.y * 0.40).clamp(0.0, _maxScrollY);
    }
  }

  void panToUser(String uid) {
    isFollowingBike = false;
    if (_ledgeNodes.isEmpty) return;
    final index = _ledgeNodes.indexWhere((n) => n.member.userId == uid);
    if (index != -1) {
      final node = _ledgeNodes[index];
      targetCameraY = (node.y - size.y * 0.40).clamp(0.0, _maxScrollY);
    }
  }

  void panToTop() {
    isFollowingBike = false;
    targetCameraY = 0.0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final touchWorldX = event.localPosition.x;
    final touchWorldY = event.localPosition.y + cameraY;
    final touchPoint = Offset(touchWorldX, touchWorldY);

    // ONLY tap on the floating name/score badge container above the roof opens details (User Audio Directive)
    for (final node in _ledgeNodes) {
      if (node.badgeHitRect.contains(touchPoint)) {
        HapticFeedback.selectionClick();
        onHouseTapped?.call(node.member);
        return;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Game Loop: Update & Physics
  // ---------------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    gameTime += dt;

    // 1. Update visible houses (smoke particles, window glow)
    final viewTop = cameraY - 140.0;
    final viewBottom = cameraY + size.y + 140.0;
    for (final node in _ledgeNodes) {
      if (node.y >= viewTop && node.y <= viewBottom) {
        node.houseComp.update(dt);
      }
    }

    // 2. Update Mountain Trial Dirt Bike
    _updateMountainTrialBike(dt);

    // 3. Update Floating Texts, Sparks & Dust Puffs
    _floatingTexts.removeWhere((ft) => !ft.update(dt));
    _sparks.removeWhere((s) => !s.update(dt));
    _dustPuffs.removeWhere((dp) => !dp.update(dt));

    // 4. Active Vocab Toast Timer
    if (_activeVocabTimer > 0) {
      _activeVocabTimer -= dt;
      if (_activeVocabTimer <= 0) {
        _activeVocabWord = null;
      }
    }

    // 5. Continuous Camera Follow & Upward Atmosphere Movement (Audio Directive)
    if (velocityY.abs() > 10.0) {
      cameraY += velocityY * dt;
      cameraY = cameraY.clamp(0.0, _maxScrollY);
      targetCameraY = cameraY;
      velocityY *= math.pow(0.88, dt * 60);
      if (velocityY.abs() < 10.0) velocityY = 0.0;
    } else {
      if (isFollowingBike || _isAirborne) {
        targetCameraY = (_bikeY - size.y * 0.45).clamp(0.0, _maxScrollY);
      }
      final diff = targetCameraY - cameraY;
      if (diff.abs() > 0.5) {
        final followSpeed = _isAirborne ? 14.0 : 8.5;
        cameraY += diff * (dt * followSpeed).clamp(0.0, 1.0);
      } else {
        cameraY = targetCameraY;
      }
    }
  }

  /// 🏍️ Update Dirt Bike Physics, Driving, and Parabolic Cliff Jumping
  void _updateMountainTrialBike(double dt) {
    if (_ledgeNodes.isEmpty) return;

    // Collect Canyon English Vocabulary Gems (User Audio Directive)
    for (final gem in _vocabGems) {
      if (gem.isCollected) continue;
      final dist = (gem.x - _bikeX).abs() + (gem.y - _bikeY).abs();
      if (dist < 46.0) {
        gem.isCollected = true;
        _activeVocabWord = gem.word;
        _activeVocabMalayalam = gem.malayalam;
        _activeVocabExample = gem.spokenExample;
        _activeVocabTimer = 3.4;

        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);

        // Add floating text with score & vocabulary
        _floatingTexts.add(_FloatingScoreText(
          x: gem.x,
          y: gem.y - 18.0,
          text: '+15 PS • ${gem.word}!',
          color: const Color(0xFF38BDF8),
        ));

        // Add sparkling star burst
        final rng = math.Random();
        for (int s = 0; s < 10; s++) {
          final ang = rng.nextDouble() * 2 * math.pi;
          final spd = 45.0 + rng.nextDouble() * 80.0;
          _sparks.add(_BounceSpark(
            x: gem.x,
            y: gem.y,
            vx: math.cos(ang) * spd,
            vy: math.sin(ang) * spd,
            size: 3.8,
            color: gem.color,
          ));
        }

        onVocabCollected?.call(gem.word, gem.malayalam, gem.spokenExample);
      }
    }

    if (!_isAirborne) {
      final currentNode = _ledgeNodes[_bikeNodeIndex];
      final isLastNode = (_bikeNodeIndex >= _ledgeNodes.length - 1);
      final screenW = size.x;

      // Suspension spring recovery
      if (_suspensionBounce < 1.0) {
        _suspensionBounce = math.min(1.0, _suspensionBounce + dt * 4.5);
      }

      double groundY = currentNode.y - 14.0;
      double targetTilt = 0.0;

      // Surface geometry: terrace plateau vs. downhill wooden plank ramp (പലക)
      if (!isLastNode && currentNode.hasRamp) {
        if (currentNode.isLeft) {
          // Even Level (House on Left): Wooden plank ramp starts at rampStartX and slopes down to right to rampEndX
          if (_bikeX >= currentNode.rampStartX) {
            final rampSpan = (currentNode.rampEndX - currentNode.rampStartX).clamp(10.0, 1000.0);
            final t = ((_bikeX - currentNode.rampStartX) / rampSpan).clamp(0.0, 1.0);
            groundY = currentNode.rampStartY +
                t * (currentNode.rampEndY - currentNode.rampStartY) - 14.0;
            final angle = math.atan2(
              currentNode.rampEndY - currentNode.rampStartY,
              currentNode.rampEndX - currentNode.rampStartX,
            );
            targetTilt = _isFacingRight ? angle * 0.75 : -angle * 0.75;

            // Gravity assistance pulling dirt bike downhill down the wooden planks
            if (_isFacingRight) {
              _bikeVx += 240.0 * dt;
            }
          }
        } else {
          // Odd Level (House on Right): Wooden plank ramp starts at rampStartX and slopes down to left to rampEndX
          if (_bikeX <= currentNode.rampStartX) {
            final rampSpan = (currentNode.rampStartX - currentNode.rampEndX).clamp(10.0, 1000.0);
            final t = ((currentNode.rampStartX - _bikeX) / rampSpan).clamp(0.0, 1.0);
            groundY = currentNode.rampStartY +
                t * (currentNode.rampEndY - currentNode.rampStartY) - 14.0;
            final angle = math.atan2(
              currentNode.rampEndY - currentNode.rampStartY,
              currentNode.rampStartX - currentNode.rampEndX,
            );
            targetTilt = !_isFacingRight ? -angle * 0.75 : angle * 0.75;

            // Gravity assistance pulling dirt bike downhill down the wooden planks
            if (!_isFacingRight) {
              _bikeVx -= 240.0 * dt;
            }
          }
        }
      }

      _bikeY = groundY;
      _bikeTilt += (targetTilt - _bikeTilt) * (dt * 12.0).clamp(0.0, 1.0);

      // Handle drive input
      if (steerInput < -0.1) {
        _bikeVx -= 720.0 * dt;
        _isFacingRight = false;
        _idleDriveTimer = 0.0;
      } else if (steerInput > 0.1) {
        _bikeVx += 720.0 * dt;
        _isFacingRight = true;
        _idleDriveTimer = 0.0;
      } else {
        _bikeVx *= math.pow(0.85, dt * 60);
        _idleDriveTimer += dt;

        // Auto-cruise down canyon if idle for 2.0 seconds (keeps trail moving)
        if (_idleDriveTimer > 2.0 && _ledgeNodes.length > 1) {
          if (currentNode.isLeft) {
            _bikeVx = 160.0;
            _isFacingRight = true;
          } else {
            _bikeVx = -160.0;
            _isFacingRight = false;
          }
        }
      }

      _bikeVx = _bikeVx.clamp(-340.0, 340.0);
      _bikeX += _bikeVx * dt;
      _wheelRotation += (_bikeVx / 14.0) * dt;

      // Dust / Sawdust puffs from rear tire while driving on grass / timber planks
      _dustTimer += dt;
      if (_bikeVx.abs() > 30.0 && _dustTimer > 0.05) {
        _dustTimer = 0.0;
        final rng = math.Random();
        final rearX = _bikeX + (_isFacingRight ? -18.0 : 18.0);
        _dustPuffs.add(_DustPuff(
          x: rearX,
          y: _bikeY + 8.0,
          vx: -_bikeVx * 0.22 + (rng.nextDouble() - 0.5) * 20.0,
          vy: -15.0 - rng.nextDouble() * 25.0,
          radius: 3.5 + rng.nextDouble() * 2.0,
        ));
      }

      // Check Terrace transitions via Wooden Plank Ramps & Screen Boundary Wrap
      if (!isLastNode && currentNode.hasRamp) {
        if (currentNode.isLeft) {
          // Left mountain wall cushion
          if (_bikeX < 14.0) {
            _bikeX = 14.0;
            _bikeVx = 160.0;
            _isFacingRight = true;
            _triggerBikeWallCushion(_bikeX, _bikeY);
          }
          // Reached end of wooden plank ramp on the right -> Smoothly arrive at next terrace!
          if (_bikeX >= currentNode.rampEndX) {
            _bikeNodeIndex++;
            final nextNode = _ledgeNodes[_bikeNodeIndex];
            _bikeX = currentNode.rampEndX;
            _bikeY = nextNode.y - 14.0;
            _isFacingRight = false; // Turn left for next terrace
            _bikeVx = -220.0;
            _bikeTilt = 0.0;
            _suspensionBounce = 0.65;
            currentCombo++;
            _triggerBikeLandingImpact(_bikeX, _bikeY);
          }
        } else {
          // Right mountain wall cushion
          if (_bikeX > screenW - 14.0) {
            _bikeX = screenW - 14.0;
            _bikeVx = -160.0;
            _isFacingRight = false;
            _triggerBikeWallCushion(_bikeX, _bikeY);
          }
          // Reached end of wooden plank ramp on the left -> Smoothly arrive at next terrace!
          if (_bikeX <= currentNode.rampEndX) {
            _bikeNodeIndex++;
            final nextNode = _ledgeNodes[_bikeNodeIndex];
            _bikeX = currentNode.rampEndX;
            _bikeY = nextNode.y - 14.0;
            _isFacingRight = true; // Turn right for next terrace
            _bikeVx = 220.0;
            _bikeTilt = 0.0;
            _suspensionBounce = 0.65;
            currentCombo++;
            _triggerBikeLandingImpact(_bikeX, _bikeY);
          }
        }
      } else {
        // Last Node: Canyon Floor (User Audio Directive: stays at bottom, turns around automatically, no auto-reset!)
        if (_bikeX < 24.0) {
          _bikeX = 24.0;
          _bikeVx = 180.0;
          _isFacingRight = true;
          _triggerBikeWallCushion(_bikeX, _bikeY);
        } else if (_bikeX > screenW - 24.0) {
          _bikeX = screenW - 24.0;
          _bikeVx = -180.0;
          _isFacingRight = false;
          _triggerBikeWallCushion(_bikeX, _bikeY);
          if (!_canyonConqueredCelebrated) {
            _canyonConqueredCelebrated = true;
            _triggerCanyonConqueredCelebration();
          }
        }
      }
    } else {
      // 🚀 AIRBORNE: Gentle Downhill Canyon Leap
      const double leapDuration = 0.95;
      _arcProgress += dt / leapDuration;

      final fromNode = _ledgeNodes[_bikeNodeIndex];
      final nextIndex = (_bikeNodeIndex + 1) % _ledgeNodes.length;
      final toNode = _ledgeNodes[nextIndex];

      final startX = fromNode.isLeft ? fromNode.rampStartX : fromNode.rampStartX;
      final startY = fromNode.y - 14.0;
      final targetX = toNode.isLeft ? 24.0 : (size.x - 24.0);
      final targetY = toNode.y - 14.0;

      final t = _arcProgress.clamp(0.0, 1.0);
      final linearX = startX + (targetX - startX) * t;
      final linearY = startY + (targetY - startY) * t;
      const double peakHeight = 35.0; // Realistic downhill hop, NOT shooting into sky!
      final arcOffset = 4 * peakHeight * t * (1 - t);

      if (steerInput.abs() > 0.05) {
        _bikeX = linearX + steerInput * 20.0 * math.sin(t * math.pi);
      } else {
        _bikeX = linearX;
      }
      _bikeY = linearY - arcOffset;

      _wheelRotation += 16.0 * dt;
      final dirSign = (targetX >= startX) ? 1.0 : -1.0;
      if (t < 0.45) {
        _bikeTilt = -0.22 * dirSign;
      } else {
        _bikeTilt = 0.20 * dirSign;
      }

      // Smooth landing on destination terrace!
      if (_arcProgress >= 1.0) {
        _isAirborne = false;
        _arcProgress = 0.0;
        _bikeNodeIndex = nextIndex;
        _bikeX = targetX;
        _bikeY = targetY;
        _suspensionBounce = 0.65;
        _bikeTilt = 0.0;

        if (toNode.isLeft) {
          _isFacingRight = true;
          _bikeVx = 200.0;
        } else {
          _isFacingRight = false;
          _bikeVx = -200.0;
        }
        currentCombo++;
        _triggerBikeLandingImpact(targetX, targetY);
      }
    }
  }

  void _triggerBikeWallCushion(double x, double y) {
    HapticFeedback.lightImpact();
    final rng = math.Random();
    for (int i = 0; i < 4; i++) {
      final angle = rng.nextDouble() * math.pi;
      _sparks.add(_BounceSpark(
        x: x,
        y: y,
        vx: math.cos(angle) * 35.0,
        vy: -math.sin(angle) * 35.0,
        size: 2.4,
        color: const Color(0xFF38BDF8),
      ));
    }
  }

  void _launchBikeJump() {
    if (_isAirborne || _ledgeNodes.length < 2) return;
    _isAirborne = true;
    isFollowingBike = true;
    velocityY = 0.0;
    _arcProgress = 0.0;
    _idleDriveTimer = 0.0;
    final nextIndex = (_bikeNodeIndex + 1) % _ledgeNodes.length;
    final toNode = _ledgeNodes[nextIndex];
    _isFacingRight = (toNode.x > _bikeX);
    HapticFeedback.mediumImpact();
  }

  void _triggerBikeLandingImpact(double x, double y) {
    HapticFeedback.heavyImpact();

    // Floating score popup: "+25 PTS"
    _floatingTexts.add(
      _FloatingScoreText(
        x: x,
        y: y - 32.0,
        text: currentCombo > 1 ? '+25 (x$currentCombo!)' : '+25 PTS',
        color: const Color(0xFFFFD700),
      ),
    );

    // Golden star sparks on landing impact
    final rng = math.Random();
    for (int i = 0; i < 16; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final spd = 60.0 + rng.nextDouble() * 120.0;
      _sparks.add(
        _BounceSpark(
          x: x,
          y: y - 4.0,
          vx: math.cos(angle) * spd,
          vy: math.sin(angle) * spd - 40.0,
          size: 3.2 + rng.nextDouble() * 2.8,
          color: rng.nextBool()
              ? const Color(0xFFFFFC00)
              : const Color(0xFFFBBF24),
        ),
      );
    }
  }

  void _triggerCanyonConqueredCelebration() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);

    _floatingTexts.add(_FloatingScoreText(
      x: size.x * 0.5,
      y: _bikeY - 45.0,
      text: '🏆 CANYON CONQUERED! +250 PTS',
      color: const Color(0xFFFFD700),
    ));

    final rng = math.Random();
    for (int i = 0; i < 24; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final spd = 70.0 + rng.nextDouble() * 140.0;
      _sparks.add(_BounceSpark(
        x: _bikeX,
        y: _bikeY - 14.0,
        vx: math.cos(angle) * spd,
        vy: math.sin(angle) * spd - 30.0,
        size: 3.8 + rng.nextDouble() * 2.5,
        color: rng.nextBool() ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
      ));
    }
    // Bike stays at canyon floor, allowing player to cruise along the bottom without warping back to top!
  }

  // ---------------------------------------------------------------------------
  // Canvas Rendering Pipeline
  // ---------------------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;

    canvas.save();
    canvas.translate(0, -cameraY);

    final viewTop = cameraY;
    final viewBottom = cameraY + size.y;

    // 1. Sky Gradient, Sun, Moon & Puffy Clouds
    _renderCelestialSky(canvas, viewTop, viewBottom);

    // 2. Distant Misty Mountain Ridges
    _renderDistantMountainRidges(canvas, viewTop, viewBottom);

    // 3. Center Canyon Waterfalls & Turquoise River
    _renderCanyonWaterfallsAndRiver(canvas, viewTop, viewBottom);

    // 4. Rocky Cliff Terraces with Lush Overhanging Grass
    _renderRockyCliffsAndTerraces(canvas, viewTop, viewBottom);

    // 5. 🪵 Heavy Timber Wooden Plank Descent Ramps (പലക) connecting terraces
    _renderPlankRamps(canvas, viewTop, viewBottom);

    // 6. Parabolic Dashed Trajectory Trail & Target Landing Rings
    _renderDashedTrajectoryTrail(canvas, viewTop, viewBottom);

    // 7. Big, Beautiful Storybook Houses
    _renderPlayerHouses(canvas, viewTop, viewBottom);

    // 8. Ultra-Minimal House Badges: [ 👑 #1  Name  •  🪙 Score ]
    _renderMinimalHouseBadges(canvas, viewTop, viewBottom);

    // 9. 🚩 Storybook Wooden Waypoint Signboards in front of cottages (100% visible, no tree obstruction)
    _renderTerraceSignboards(canvas, viewTop, viewBottom);

    // 10. 💎 Floating English Vocabulary Gems along Canyon
    _renderCanyonVocabGems(canvas, viewTop, viewBottom);

    // 11. 💨 Dust Puffs from Bike Tires
    for (final dp in _dustPuffs) {
      dp.render(canvas);
    }

    // 12. 🏍️ Mountain Trial Dirt Bike & Motocross Rider
    _renderMountainTrialBike(canvas);

    for (final ft in _floatingTexts) {
      ft.render(canvas);
    }
    for (final spk in _sparks) {
      spk.render(canvas);
    }

    canvas.restore();

    // 13. 🌟 Active Spoken English Vocabulary Toast HUD (Screen Coordinates)
    _renderActiveVocabToastHUD(canvas);
  }

  // ---------------------------------------------------------------------------
  // 1. Celestial Sky, Sun, Moon & Soft Clouds
  // ---------------------------------------------------------------------------

  void _renderCelestialSky(Canvas canvas, double topY, double bottomY) {
    final screenW = size.x;

    // Vibrant sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0284C7), // Deep cerulean top
          Color(0xFF38BDF8), // Bright azure
          Color(0xFFBAE6FD), // Soft horizon mist
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, topY, screenW, size.y));

    canvas.drawRect(Rect.fromLTWH(0, topY, screenW, size.y), skyPaint);

    // Golden Radiant Sun (Top Right)
    final sunCenter = Offset(screenW * 0.82, topY + 110.0);
    final sunCorona = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36);
    canvas.drawCircle(sunCenter, 46, sunCorona);

    final sunCore = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(sunCenter, 22, sunCore);

    // Soft Silver Moon (Top Left)
    final moonCenter = Offset(screenW * 0.20, topY + 95.0);
    final moonCorona = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(moonCenter, 26, moonCorona);

    final moonCore = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawCircle(moonCenter, 16, moonCore);

    // Fluffy Puffy White Cumulus Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    final cloudShadowPaint = Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.45);

    for (int i = 0; i < 8; i++) {
      final cx = (screenW * 0.12 + i * 85.0 + math.sin(gameTime * 0.2 + i) * 15.0) % screenW;
      final cy = topY + 40.0 + (i % 3) * 60.0;

      canvas.drawCircle(Offset(cx, cy + 3), 22, cloudShadowPaint);
      canvas.drawCircle(Offset(cx - 16, cy + 3), 16, cloudShadowPaint);
      canvas.drawCircle(Offset(cx + 16, cy + 3), 17, cloudShadowPaint);

      canvas.drawCircle(Offset(cx, cy), 22, cloudPaint);
      canvas.drawCircle(Offset(cx - 16, cy + 1), 16, cloudPaint);
      canvas.drawCircle(Offset(cx + 16, cy + 1), 17, cloudPaint);
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Distant Misty Mountain Ridges
  // ---------------------------------------------------------------------------

  void _renderDistantMountainRidges(Canvas canvas, double topY, double bottomY) {
    final screenW = size.x;

    final ridgePaint1 = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.45);
    final ridgePaint2 = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.65);

    for (double y = ((topY ~/ 550) * 550).toDouble(); y < bottomY + 300; y += 500) {
      final p1 = Path();
      p1.moveTo(0, y + 260);
      p1.lineTo(screenW * 0.28, y + 170);
      p1.lineTo(screenW * 0.52, y + 230);
      p1.lineTo(screenW * 0.74, y + 155);
      p1.lineTo(screenW, y + 270);
      p1.lineTo(screenW, y + 500);
      p1.lineTo(0, y + 500);
      p1.close();
      canvas.drawPath(p1, ridgePaint1);

      final p2 = Path();
      p2.moveTo(0, y + 330);
      p2.lineTo(screenW * 0.36, y + 250);
      p2.lineTo(screenW * 0.64, y + 310);
      p2.lineTo(screenW, y + 340);
      p2.lineTo(screenW, y + 500);
      p2.lineTo(0, y + 500);
      p2.close();
      canvas.drawPath(p2, ridgePaint2);
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Center Canyon Waterfalls & Turquoise River
  // ---------------------------------------------------------------------------

  void _renderCanyonWaterfallsAndRiver(Canvas canvas, double topY, double bottomY) {
    final screenW = size.x;
    final cx = screenW / 2.0;

    // Cascading Waterfalls down the center gap
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(Rect.fromLTWH(cx - 28, topY, 56, size.y))
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mistPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    for (double y = ((topY ~/ 320) * 320).toDouble(); y < bottomY + 200; y += 320) {
      final waterPath = Path();
      final wave = math.sin(gameTime * 2.4 + y * 0.012) * 12.0;
      waterPath.moveTo(cx + wave, y);
      waterPath.quadraticBezierTo(
        cx - 18 + wave * 0.5,
        y + 150,
        cx + 8 - wave * 0.5,
        y + 320,
      );
      canvas.drawPath(waterPath, waterPaint);

      final foamPath = Path();
      foamPath.moveTo(cx + wave - 3, y);
      foamPath.quadraticBezierTo(
        cx - 15 + wave * 0.5,
        y + 150,
        cx + 5 - wave * 0.5,
        y + 320,
      );
      canvas.drawPath(foamPath, foamPaint);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + 4, y + 310),
          width: 74 + math.sin(gameTime * 3.2) * 10.0,
          height: 28,
        ),
        mistPaint,
      );
    }

    // Turquoise River at Canyon Floor
    final riverY = _totalWorldHeight - 180.0;
    if (bottomY >= riverY - 100.0) {
      final riverPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2), Color(0xFF0E7490)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, riverY, screenW, 250));

      final riverPath = Path();
      riverPath.moveTo(0, riverY + 30);
      riverPath.quadraticBezierTo(screenW * 0.35, riverY + 10, screenW * 0.65, riverY + 45);
      riverPath.quadraticBezierTo(screenW * 0.85, riverY + 20, screenW, riverY + 35);
      riverPath.lineTo(screenW, riverY + 250);
      riverPath.lineTo(0, riverY + 250);
      riverPath.close();
      canvas.drawPath(riverPath, riverPaint);

      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      for (double rx = 30; rx < screenW; rx += 70) {
        final rw = math.sin(gameTime * 3.0 + rx) * 14.0;
        canvas.drawLine(
          Offset(rx + rw, riverY + 80),
          Offset(rx + rw + 28, riverY + 80),
          ripplePaint,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Rocky Cliff Terraces with Lush Overhanging Grass & Wooden Waypoint Signs
  // ---------------------------------------------------------------------------

  void _renderRockyCliffsAndTerraces(Canvas canvas, double topY, double bottomY) {
    final screenW = size.x;

    for (final node in _ledgeNodes) {
      if (node.y + 160 < topY || node.y - 120 > bottomY) continue;

      final isLastNode = (node.index == _ledgeNodes.length - 1);
      final isLeft = node.isLeft;
      final ly = node.y;
      final lw = node.width;

      // 1. Chunky Rocky Cliff Wall
      final rockPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF334155),
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, ly - 20, screenW, 140));

      final rockPath = Path();
      if (isLastNode) {
        rockPath.moveTo(0, ly - 18);
        rockPath.lineTo(screenW, ly - 18);
        rockPath.lineTo(screenW, ly + 150);
        rockPath.lineTo(0, ly + 150);
      } else if (isLeft) {
        rockPath.moveTo(0, ly - 18);
        rockPath.lineTo(lw, ly - 18);
        rockPath.lineTo(lw - 22, ly + 45);
        rockPath.lineTo(lw - 55, ly + 95);
        rockPath.lineTo(lw - 110, ly + 140);
        rockPath.lineTo(0, ly + 150);
      } else {
        final startX = screenW - lw;
        rockPath.moveTo(screenW, ly - 18);
        rockPath.lineTo(startX, ly - 18);
        rockPath.lineTo(startX + 22, ly + 45);
        rockPath.lineTo(startX + 55, ly + 95);
        rockPath.lineTo(startX + 110, ly + 140);
        rockPath.lineTo(screenW, ly + 150);
      }
      rockPath.close();
      canvas.drawPath(rockPath, rockPaint);

      // Rock strata cracks & highlights
      final rockCrackPaint = Paint()
        ..color = const Color(0xFF0B1220).withValues(alpha: 0.70)
        ..strokeWidth = 2.0;
      if (isLastNode) {
        canvas.drawLine(Offset(screenW * 0.35, ly + 25), Offset(screenW * 0.30, ly + 85), rockCrackPaint);
        canvas.drawLine(Offset(screenW * 0.65, ly + 25), Offset(screenW * 0.70, ly + 85), rockCrackPaint);
      } else if (isLeft) {
        canvas.drawLine(Offset(lw * 0.75, ly + 15), Offset(lw * 0.65, ly + 75), rockCrackPaint);
        canvas.drawLine(Offset(lw * 0.45, ly + 35), Offset(lw * 0.40, ly + 95), rockCrackPaint);
      } else {
        final startX = screenW - lw;
        canvas.drawLine(Offset(startX + lw * 0.25, ly + 15), Offset(startX + lw * 0.35, ly + 75), rockCrackPaint);
        canvas.drawLine(Offset(startX + lw * 0.55, ly + 35), Offset(startX + lw * 0.60, ly + 95), rockCrackPaint);
      }

      // 2. Thick Grassy Terrace Plateau Top
      final grassCapPaint = Paint()..color = const Color(0xFF22C55E);
      final grassShadowPaint = Paint()..color = const Color(0xFF15803D);

      final grassPath = Path();
      if (isLastNode) {
        grassPath.moveTo(0, ly - 22);
        grassPath.lineTo(screenW, ly - 22);
        grassPath.lineTo(screenW, ly + 6);
        grassPath.lineTo(0, ly + 6);
      } else if (isLeft) {
        grassPath.moveTo(0, ly - 22);
        grassPath.lineTo(lw + 8, ly - 22);
        grassPath.quadraticBezierTo(lw + 14, ly - 8, lw + 4, ly + 6);
        grassPath.quadraticBezierTo(lw - 20, ly + 12, lw - 40, ly + 5);
        grassPath.lineTo(0, ly + 6);
      } else {
        final startX = screenW - lw;
        grassPath.moveTo(screenW, ly - 22);
        grassPath.lineTo(startX - 8, ly - 22);
        grassPath.quadraticBezierTo(startX - 14, ly - 8, startX - 4, ly + 6);
        grassPath.quadraticBezierTo(startX + 20, ly + 12, startX + 40, ly + 5);
        grassPath.lineTo(screenW, ly + 6);
      }
      grassPath.close();

      canvas.save();
      canvas.translate(0, 3.5);
      canvas.drawPath(grassPath, grassShadowPaint);
      canvas.restore();
      canvas.drawPath(grassPath, grassCapPaint);

      // Lush Grass Rim Highlight
      final highlightPaint = Paint()
        ..color = const Color(0xFF86EFAC)
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke;
      if (isLastNode) {
        canvas.drawLine(Offset(0, ly - 21), Offset(screenW, ly - 21), highlightPaint);
      } else if (isLeft) {
        canvas.drawLine(Offset(0, ly - 21), Offset(lw + 6, ly - 21), highlightPaint);
      } else {
        final startX = screenW - lw;
        canvas.drawLine(Offset(startX - 6, ly - 21), Offset(screenW, ly - 21), highlightPaint);
      }

      // 3. Lush Pine Trees (placed at mountain edge behind house to keep canyon runway open)
      if (isLeft) {
        _drawPineTree(canvas, node.houseX + 18.0, ly - 18.0, 26.0, 48.0);
        _drawPineTree(canvas, node.houseX - 4.0, ly - 18.0, 20.0, 36.0);
      } else {
        _drawPineTree(canvas, node.houseX + node.houseW - 18.0, ly - 18.0, 26.0, 48.0);
        _drawPineTree(canvas, node.houseX + node.houseW + 4.0, ly - 18.0, 20.0, 36.0);
      }

      // 4. Wooden Fence & Vintage Street Lamp
      _renderWoodenFence(canvas, node);
      _renderStreetLamp(canvas, node);
    }
  }

  // ---------------------------------------------------------------------------
  // 5. 🪵 Heavy Timber Wooden Plank Descent Ramps (പലക) connecting terraces
  // User Audio Directive: "ഒരു പലക പോലെ എന്തെങ്കിലും വെച്ചിട്ട്, ആ പലകയിൽ കൂടെ ഇറങ്ങിയിട്ട്
  // പിന്നെ ഇവിടുന്ന് അങ്ങോട്ട് പലക പോലെ വെച്ചിട്ട് അങ്ങനെ അങ്ങനെ ആക്കാൻ പറ്റുമോ?"
  // ---------------------------------------------------------------------------

  void _renderPlankRamps(Canvas canvas, double topY, double bottomY) {
    if (_ledgeNodes.length < 2) return;

    for (int i = 0; i < _ledgeNodes.length - 1; i++) {
      final node = _ledgeNodes[i];
      if (!node.hasRamp) continue;

      final sx = node.rampStartX;
      final sy = node.rampStartY;
      final ex = node.rampEndX;
      final ey = node.rampEndY;

      final minY = math.min(sy, ey);
      final maxY = math.max(sy, ey);
      if (maxY < topY - 120 || minY > bottomY + 120) continue;

      final dx = ex - sx;
      final dy = ey - sy;
      final rampLength = math.sqrt(dx * dx + dy * dy);
      if (rampLength < 10.0) continue;

      final rampAngle = math.atan2(dy, dx);
      final isCurrentRamp = (i == _bikeNodeIndex);

      // 1. Structural Timber Pillar Supports & Brackets anchored into rock
      _renderRampSupportPillars(canvas, sx, sy, ex, ey, rampAngle, rampLength);

      // 2. Heavy Timber Stringers (Base Under-Beams)
      final stringerPaint = Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;
      final stringerTopPaint = Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final nx = -math.sin(rampAngle);
      final ny = math.cos(rampAngle);

      // Bottom shadow stringer
      canvas.drawLine(
        Offset(sx + nx * 5.0, sy + ny * 5.0),
        Offset(ex + nx * 5.0, ey + ny * 5.0),
        stringerPaint,
      );
      // Main top stringer
      canvas.drawLine(
        Offset(sx, sy),
        Offset(ex, ey),
        stringerTopPaint,
      );

      // 3. Individual Heavy Wooden Cross Planks (പലകകൾ)
      const double plankSpacing = 13.0;
      final int plankCount = (rampLength / plankSpacing).floor();

      final plankWoodPaints = [
        Paint()..color = const Color(0xFF92400E), // Rich warm timber
        Paint()..color = const Color(0xFF78350F), // Dark rustic wood
        Paint()..color = const Color(0xFFB45309), // Amber cedar
        Paint()..color = const Color(0xFFA16207), // Golden teak
      ];

      final plankShadowPaint = Paint()..color = const Color(0xFF3B1804);
      final plankHighlightPaint = Paint()..color = const Color(0xFFD97706);
      final nailPaint = Paint()..color = const Color(0xFFE2E8F0);

      for (int p = 0; p <= plankCount; p++) {
        final t = p / plankCount;
        final px = sx + dx * t;
        final py = sy + dy * t;

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(rampAngle);

        // Drop shadow for each plank
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: const Offset(1.5, 2.5), width: 9.0, height: 26.0),
            const Radius.circular(1.5),
          ),
          plankShadowPaint,
        );

        // Main wood plank body
        final woodPaint = plankWoodPaints[(p + i * 3) % plankWoodPaints.length];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 9.0, height: 26.0),
            const Radius.circular(1.5),
          ),
          woodPaint,
        );

        // Plank top highlight grain line
        canvas.drawLine(
          const Offset(-3.5, -11.0),
          const Offset(-3.5, 11.0),
          plankHighlightPaint,
        );

        // Silver iron nail studs
        canvas.drawCircle(const Offset(0, -9.0), 1.2, nailPaint);
        canvas.drawCircle(const Offset(0, 9.0), 1.2, nailPaint);

        // Subtle downhill directional chevron indicator every 5th plank
        if (p > 2 && p < plankCount - 2 && p % 5 == 0) {
          final chevronPaint = Paint()
            ..color = isCurrentRamp ? const Color(0xFFFFD700) : Colors.white54
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          final chevronPath = Path()
            ..moveTo(-2, -5)
            ..lineTo(3, 0)
            ..lineTo(-2, 5);
          canvas.drawPath(chevronPath, chevronPaint);
        }

        // 4. Timber Guard Posts with Warm Lanterns every 8 planks
        if (p > 1 && p < plankCount && p % 8 == 0) {
          _renderRampLanternPost(canvas, isCurrentRamp);
        }

        canvas.restore();
      }

      // 5. Landing Target Star on the terrace where the ramp arrives
      _renderRampLandingMarker(canvas, ex, ey, isCurrentRamp);
    }
  }

  void _renderRampSupportPillars(
    Canvas canvas,
    double sx,
    double sy,
    double ex,
    double ey,
    double angle,
    double length,
  ) {
    final pillarPaint = Paint()
      ..color = const Color(0xFF2E1504)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final dx = ex - sx;
    final dy = ey - sy;

    final fractions = [0.25, 0.50, 0.75];
    for (final f in fractions) {
      final px = sx + dx * f;
      final py = sy + dy * f;
      final dropH = 35.0 + f * 25.0;
      canvas.drawLine(
        Offset(px, py),
        Offset(px, py + dropH),
        pillarPaint,
      );
      canvas.drawLine(
        Offset(px - 10, py + 12),
        Offset(px + 10, py + dropH * 0.8),
        bracePaint,
      );
    }
  }

  void _renderRampLanternPost(Canvas canvas, bool isCurrentRamp) {
    final postPaint = Paint()
      ..color = const Color(0xFF2E1504)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, -13.0), const Offset(0, -32.0), postPaint);

    final glowPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: isCurrentRamp ? 0.45 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(0, -30.0), 12.0, glowPaint);

    final lanternPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -30.0), width: 7.0, height: 9.0),
        const Radius.circular(1.5),
      ),
      lanternPaint,
    );
  }

  void _renderRampLandingMarker(Canvas canvas, double ex, double ey, bool isCurrentRamp) {
    final ringPaint = Paint()
      ..color = (isCurrentRamp ? const Color(0xFFFFD700) : Colors.white60)
          .withValues(alpha: isCurrentRamp ? 0.85 : 0.35)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = (isCurrentRamp ? const Color(0xFFFFD700) : Colors.white)
          .withValues(alpha: isCurrentRamp ? 0.40 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(ex, ey - 14.0), 15.0, glowPaint);
    canvas.drawCircle(Offset(ex, ey - 14.0), 13.0, ringPaint);

    if (isCurrentRamp) {
      final chevronPainter = TextPainter(
        text: const TextSpan(
          text: '⭐',
          style: TextStyle(fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      chevronPainter.paint(
        canvas,
        Offset(ex - chevronPainter.width / 2, ey - 14.0 - chevronPainter.height / 2),
      );
    }
  }

  void _renderTerraceSignboards(Canvas canvas, double topY, double bottomY) {
    for (final node in _ledgeNodes) {
      if (node.y + 160 < topY || node.y - 160 > bottomY) continue;
      _renderTerraceSignboard(canvas, node);
    }
  }

  /// 🚩 Storybook Wooden Waypoint Signpost in Front of Cottage (User Audio Directive: "veettinte munnilekku maatti vekkuka, ellarkkum kananam")
  void _renderTerraceSignboard(Canvas canvas, WorldRankingLedgeNode node) {
    final ly = node.y;

    // Position signboard directly in front of the cottage on open grass (Audio Directive)
    final double signX = node.isLeft
        ? (node.houseX + 32.0)
        : (node.houseX + node.houseW - 32.0);
    final double groundY = ly - 14.0;

    // 1. Rustic Timber Post
    final postPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(signX - 3.5, groundY - 36.0, 7.0, 36.0),
        const Radius.circular(2.0),
      ),
      postPaint,
    );

    // 2. Wooden Signboard Plank
    final isRank1 = node.rank == 1;
    final isRank2 = node.rank == 2;
    final isRank3 = node.rank == 3;

    final double plankW = 78.0;
    final double plankH = 24.0;
    final plankCenter = Offset(signX, groundY - 36.0);
    final plankRect = Rect.fromCenter(
      center: plankCenter,
      width: plankW,
      height: plankH,
    );

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plankRect.translate(0, 2.5), const Radius.circular(5)),
      shadowPaint,
    );

    // Wood Plank Background
    final woodPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF92400E), Color(0xFF78350F), Color(0xFF451A03)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(plankRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plankRect, const Radius.circular(5)),
      woodPaint,
    );

    // Border: Golden for Rank 1, Silver for Rank 2, Bronze for Rank 3, Cedar for others
    Color borderColor;
    double borderWidth;
    String signText;

    if (isRank1) {
      borderColor = const Color(0xFFFFD700);
      borderWidth = 2.0;
      signText = '👑 RANK 1';
    } else if (isRank2) {
      borderColor = const Color(0xFFE2E8F0);
      borderWidth = 1.6;
      signText = '🥈 RANK 2';
    } else if (isRank3) {
      borderColor = const Color(0xFFCD7F32);
      borderWidth = 1.6;
      signText = '🥉 RANK 3';
    } else {
      borderColor = const Color(0xFFB45309);
      borderWidth = 1.2;
      signText = '🚩 RANK #${node.rank}';
    }

    // Glow aura for top 3
    if (isRank1 || isRank2 || isRank3) {
      final glowPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(plankRect, const Radius.circular(5)),
        glowPaint,
      );
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(plankRect, const Radius.circular(5)),
      borderPaint,
    );

    // Corner brass nails
    final nailPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(plankRect.left + 4.0, plankRect.top + 4.0), 1.2, nailPaint);
    canvas.drawCircle(Offset(plankRect.right - 4.0, plankRect.top + 4.0), 1.2, nailPaint);
    canvas.drawCircle(Offset(plankRect.left + 4.0, plankRect.bottom - 4.0), 1.2, nailPaint);
    canvas.drawCircle(Offset(plankRect.right - 4.0, plankRect.bottom - 4.0), 1.2, nailPaint);

    // Text on wooden sign
    final textPainter = TextPainter(
      text: TextSpan(
        text: signText,
        style: GoogleFonts.outfit(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: isRank1 ? const Color(0xFFFFD700) : Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(plankCenter.dx - textPainter.width / 2, plankCenter.dy - textPainter.height / 2),
    );
  }

  /// 💎 Render Floating English Vocabulary Gems along Canyon (User Audio Directive)
  void _renderCanyonVocabGems(Canvas canvas, double topY, double bottomY) {
    for (final gem in _vocabGems) {
      if (gem.isCollected) continue;
      if (gem.y + 60 < topY || gem.y - 60 > bottomY) continue;

      final bobbing = math.sin(gameTime * 3.2 + gem.id) * 5.0;
      final gx = gem.x;
      final gy = gem.y + bobbing;

      // Glow aura
      final auraPaint = Paint()
        ..color = gem.color.withValues(alpha: 0.35 + math.sin(gameTime * 4.0 + gem.id) * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(Offset(gx, gy), 14.0, auraPaint);

      // Diamond Gem Shape
      final gemPath = Path();
      gemPath.moveTo(gx, gy - 12);
      gemPath.lineTo(gx + 10, gy);
      gemPath.lineTo(gx, gy + 12);
      gemPath.lineTo(gx - 10, gy);
      gemPath.close();

      final gemPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, gem.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: Offset(gx, gy), radius: 12));
      canvas.drawPath(gemPath, gemPaint);

      // Sparkling outline
      final edgePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(gemPath, edgePaint);

      // Word pill tag above gem
      final wordPainter = TextPainter(
        text: TextSpan(
          text: gem.word,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tagW = wordPainter.width + 10.0;
      final tagRect = Rect.fromCenter(
        center: Offset(gx, gy - 20.0),
        width: tagW,
        height: 15.0,
      );
      final tagBg = Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.85);
      final tagBorder = Paint()
        ..color = gem.color.withValues(alpha: 0.8)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(RRect.fromRectAndRadius(tagRect, const Radius.circular(4)), tagBg);
      canvas.drawRRect(RRect.fromRectAndRadius(tagRect, const Radius.circular(4)), tagBorder);
      wordPainter.paint(
        canvas,
        Offset(tagRect.center.dx - wordPainter.width / 2.0, tagRect.center.dy - wordPainter.height / 2.0),
      );
    }
  }

  /// 🌟 Spoken English Active Vocabulary Toast HUD (Screen Coordinates)
  void _renderActiveVocabToastHUD(Canvas canvas) {
    if (_activeVocabTimer <= 0 || _activeVocabWord == null) return;

    final alpha = (_activeVocabTimer / 0.5).clamp(0.0, 1.0);
    final hudW = math.min(size.x - 32.0, 340.0);
    final hudRect = Rect.fromCenter(
      center: Offset(size.x / 2.0, 68.0),
      width: hudW,
      height: 48.0,
    );

    // Background capsule with neon cyan & gold border
    final bgPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.92 * alpha);
    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.85 * alpha)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final shadowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawRRect(RRect.fromRectAndRadius(hudRect, const Radius.circular(24)), shadowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(hudRect, const Radius.circular(24)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(hudRect, const Radius.circular(24)), borderPaint);

    final titleSpan = TextSpan(
      children: [
        const TextSpan(text: '✨ '),
        TextSpan(
          text: _activeVocabWord!.toUpperCase(),
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFD700),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        TextSpan(
          text: ' • ${_activeVocabMalayalam ?? ""}',
          style: GoogleFonts.outfit(
            color: const Color(0xFFE2E8F0),
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text: '  (+15 PS)',
          style: GoogleFonts.outfit(
            color: const Color(0xFF34D399),
            fontSize: 11.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );

    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: hudW - 20);

    titlePainter.paint(
      canvas,
      Offset(hudRect.center.dx - titlePainter.width / 2.0, hudRect.top + 6.0),
    );

    final exampleSpan = TextSpan(
      text: '🗣️ "${_activeVocabExample ?? ""}"',
      style: GoogleFonts.inter(
        color: const Color(0xFF93C5FD),
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ),
    );

    final examplePainter = TextPainter(
      text: exampleSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: hudW - 20);

    examplePainter.paint(
      canvas,
      Offset(hudRect.center.dx - examplePainter.width / 2.0, hudRect.top + 26.0),
    );
  }

  /// 🌲 Stylized Layered Pine Tree
  void _drawPineTree(Canvas canvas, double tx, double groundY, double width, double height) {
    final trunkPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx - 3.5, groundY - 14.0, 7.0, 14.0),
        const Radius.circular(1.5),
      ),
      trunkPaint,
    );

    final tierShadow = Paint()..color = const Color(0xFF14532D);
    final tierMid = Paint()..color = const Color(0xFF16A34A);
    final tierHi = Paint()..color = const Color(0xFF4ADE80);

    final double tierH = height * 0.42;

    for (int t = 0; t < 3; t++) {
      final double tierY = groundY - 10.0 - t * (height * 0.28);
      final double tierW = width * (1.0 - t * 0.24);

      final p = Path();
      p.moveTo(tx, tierY - tierH);
      p.lineTo(tx + tierW * 0.5, tierY);
      p.lineTo(tx - tierW * 0.5, tierY);
      p.close();

      canvas.save();
      canvas.translate(0, 2);
      canvas.drawPath(p, tierShadow);
      canvas.restore();

      canvas.drawPath(p, tierMid);

      final hp = Path();
      hp.moveTo(tx, tierY - tierH);
      hp.lineTo(tx - tierW * 0.42, tierY - 2);
      hp.lineTo(tx, tierY - 4);
      hp.close();
      canvas.drawPath(hp, tierHi);
    }
  }

  void _renderWoodenFence(Canvas canvas, WorldRankingLedgeNode node) {
    final postPaint = Paint()..color = const Color(0xFF78350F);
    final railPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 2.6;

    final startX = node.isLeft ? (node.houseX - 8.0) : (node.houseX + node.houseW + 2.0);
    final endX = node.isLeft ? (node.houseX + 18.0) : (node.houseX + node.houseW + 28.0);
    final ly = node.y;

    canvas.drawLine(Offset(startX, ly - 14), Offset(endX, ly - 14), railPaint);
    canvas.drawLine(Offset(startX, ly - 7), Offset(endX, ly - 7), railPaint);

    for (double px = startX; px <= endX; px += 16) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px - 2, ly - 20, 4, 20),
          const Radius.circular(1.2),
        ),
        postPaint,
      );
    }
  }

  void _renderStreetLamp(Canvas canvas, WorldRankingLedgeNode node) {
    final lampX = node.isLeft
        ? node.houseX + node.houseW + 10.0
        : node.houseX - 10.0;
    final ly = node.y;

    final polePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(lampX, ly), Offset(lampX, ly - 36), polePaint);
    final armEnd = node.isLeft ? lampX - 7 : lampX + 7;
    canvas.drawLine(Offset(lampX, ly - 36), Offset(armEnd, ly - 36), polePaint);

    // Warm Lantern Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(armEnd, ly - 28), 14, glowPaint);

    final lanternPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(armEnd, ly - 28), width: 8, height: 10),
        const Radius.circular(1.5),
      ),
      lanternPaint,
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Parabolic Dashed Trajectory Trail & Star Target Landing Rings
  // ---------------------------------------------------------------------------

  void _renderDashedTrajectoryTrail(Canvas canvas, double topY, double bottomY) {
    if (_ledgeNodes.length < 2) return;

    for (int i = 0; i < _ledgeNodes.length - 1; i++) {
      final from = _ledgeNodes[i];
      final to = _ledgeNodes[i + 1];

      if (to.y < topY - 140 || from.y > bottomY + 140) continue;

      final startX = from.isLeft ? from.width - 8.0 : (size.x - from.width + 8.0);
      final startY = from.y - 14.0;
      final endX = to.isLeft
          ? (to.houseX + to.houseW + 48.0)
          : (to.houseX - 48.0);
      final endY = to.y - 14.0;

      final peakHeight = math.max(75.0, (endY - startY).abs() * 0.32 + 55.0);

      // Parabolic white dashed trail
      const int numDots = 15;
      for (int d = 1; d < numDots; d++) {
        final t = d / numDots;
        final lx = startX + (endX - startX) * t;
        final ly = startY + (endY - startY) * t;
        final arcY = ly - (4 * peakHeight * t * (1 - t));

        final dotGlow = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.40);
        canvas.drawCircle(Offset(lx, arcY), 4.2, dotGlow);

        final dotCore = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(lx, arcY), 2.2, dotCore);
      }

      // Star Landing Target Ring on Destination Ledge
      final isCurrentTarget = (i == _bikeNodeIndex);
      final targetGlow = Paint()
        ..color = (isCurrentTarget ? const Color(0xFFFFD700) : Colors.white)
            .withValues(alpha: isCurrentTarget ? 0.50 : 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(endX, endY), 16, targetGlow);

      final ringPaint = Paint()
        ..color = isCurrentTarget ? const Color(0xFFFFD700) : Colors.white60
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(endX, endY), 14, ringPaint);

      if (isCurrentTarget) {
        final starPainter = TextPainter(
          text: const TextSpan(
            text: '⭐',
            style: TextStyle(fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        starPainter.paint(
          canvas,
          Offset(endX - starPainter.width / 2, endY - starPainter.height / 2),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Big, Beautiful Storybook Houses
  // ---------------------------------------------------------------------------

  void _renderPlayerHouses(Canvas canvas, double topY, double bottomY) {
    for (final node in _ledgeNodes) {
      if (node.y + 160 < topY || node.y - 160 > bottomY) continue;

      canvas.save();
      canvas.translate(node.houseX, node.houseY);
      node.houseComp.resize(Vector2(node.houseW, node.houseH));
      node.houseComp.render(canvas);
      canvas.restore();
    }
  }

  // ---------------------------------------------------------------------------
  // 7. Ultra-Minimal House Badges: [ 👑 #1  Name  •  🪙 Score ]
  // ---------------------------------------------------------------------------

  void _renderMinimalHouseBadges(Canvas canvas, double topY, double bottomY) {
    for (final node in _ledgeNodes) {
      if (node.y + 160 < topY || node.y - 160 > bottomY) continue;

      final isRank1 = node.rank == 1;
      final isRank2 = node.rank == 2;
      final isRank3 = node.rank == 3;
      final isMe = node.member.isCurrentUser;

      final badgeCenter = Offset(
        node.houseX + node.houseW * 0.5,
        node.houseY - 14.0,
      );

      Color borderColor;
      double borderWidth = 1.2;
      String rankPrefix;

      if (isRank1) {
        borderColor = const Color(0xFFFFD700);
        borderWidth = 1.8;
        rankPrefix = '👑 #1';
      } else if (isRank2) {
        borderColor = const Color(0xFFE2E8F0);
        borderWidth = 1.5;
        rankPrefix = '🥈 #2';
      } else if (isRank3) {
        borderColor = const Color(0xFFCD7F32);
        borderWidth = 1.5;
        rankPrefix = '🥉 #3';
      } else if (isMe) {
        borderColor = const Color(0xFF22C55E);
        borderWidth = 1.6;
        rankPrefix = '#${node.rank}';
      } else {
        borderColor = Colors.white30;
        rankPrefix = '#${node.rank}';
      }

      final scoreVal = node.member.pocketScore;
      final String scoreStr = scoreVal >= 10000
          ? '${(scoreVal / 1000).toStringAsFixed(1)}K'
          : scoreVal.toString();

      final displayName = isMe ? 'YOU' : node.member.name;
      final badgeText = '$rankPrefix  $displayName • 🪙 $scoreStr';

      final textPainter = TextPainter(
        text: TextSpan(
          text: badgeText,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: [
              const Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      final badgeW = textPainter.width + 18.0;
      final badgeH = 22.0;

      final badgeRect = Rect.fromCenter(
        center: badgeCenter,
        width: badgeW,
        height: badgeH,
      );

      final badgeBg = Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.88);
      final borderPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        RRect.fromRectAndRadius(badgeRect, const Radius.circular(11)),
        badgeBg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(badgeRect, const Radius.circular(11)),
        borderPaint,
      );

      textPainter.paint(
        canvas,
        Offset(badgeCenter.dx - textPainter.width / 2, badgeCenter.dy - textPainter.height / 2),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 8. 🏍️ Mountain Trial Dirt Bike & Motocross Rider (Audio Directive)
  // ---------------------------------------------------------------------------

  void _renderMountainTrialBike(Canvas canvas) {
    if (_ledgeNodes.isEmpty) return;

    canvas.save();
    canvas.translate(_bikeX, _bikeY);
    canvas.rotate(_bikeTilt);
    canvas.scale(_isFacingRight ? 1.0 : -1.0, 1.0);

    final bounceOffset = (1.0 - _suspensionBounce) * 6.0;

    // A. Translucent Headlight Beam forward
    final headlightBeam = Path()
      ..moveTo(16, -10)
      ..lineTo(75, -28)
      ..lineTo(85, 8)
      ..close();
    final beamPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x77FEF08A), Color(0x00FEF08A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(16, -28, 70, 36));
    canvas.drawPath(headlightBeam, beamPaint);

    // B. Knobby Tires with Rims & Rotating Spokes
    _drawBikeWheel(canvas, Offset(-19, 10 + bounceOffset), _wheelRotation);
    _drawBikeWheel(canvas, Offset(19, 10 + bounceOffset), _wheelRotation);

    // C. Rear Swingarm & Yellow Coil Shock
    final swingarmPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 4), Offset(-19, 10 + bounceOffset), swingarmPaint);

    // Mono-shock spring
    final shockPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(-8, 1), Offset(-13, 7 + bounceOffset), shockPaint);

    // D. Front Telescopic Gold Suspension Forks
    final forkPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, -11), Offset(19, 10 + bounceOffset), forkPaint);

    // E. Chrome Engine Block & Exhaust System
    final enginePaint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 3), width: 13, height: 11),
        const Radius.circular(2.5),
      ),
      enginePaint,
    );

    // Exhaust pipe with expansion chamber & silencer
    final exhaustPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final exhaustPath = Path()
      ..moveTo(3, 4)
      ..quadraticBezierTo(7, 8, 3, 10)
      ..quadraticBezierTo(-6, 9, -12, 1)
      ..lineTo(-18, -4);
    canvas.drawPath(exhaustPath, exhaustPaint);

    // F. Geometric Lightweight Trellis Racing Frame (Neon Orange / Cyan)
    final framePaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-16, -2), const Offset(-2, -7), framePaint);
    canvas.drawLine(const Offset(-2, -7), const Offset(11, -11), framePaint);
    canvas.drawLine(const Offset(-2, -7), const Offset(0, 5), framePaint);
    canvas.drawLine(const Offset(11, -11), const Offset(0, 5), framePaint);

    // Trial seat
    final seatPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-16, -8, 18, 4),
        const Radius.circular(2),
      ),
      seatPaint,
    );

    // G. Handlebars & Front Number Plate
    final barPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, -11), const Offset(9, -18), barPaint);

    // Front number plate
    final platePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(13, -15), width: 8, height: 7),
        const Radius.circular(1.5),
      ),
      platePaint,
    );

    // H. Motocross Rider
    // Boots on footpegs
    final bootPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-3, 4, 7, 5),
        const Radius.circular(1.5),
      ),
      bootPaint,
    );

    // Racing Pants / Legs
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-10, -5), const Offset(-1, 5), legPaint);

    // Upper Torso / Racing Jersey (Vivid Emerald)
    final torsoPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-8, -10), const Offset(3, -17), torsoPaint);

    // Rider Arms gripping handlebars
    final armPaint = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(2, -16), const Offset(9, -17), armPaint);

    // Aerodynamic Motocross Helmet
    final helmetPaint = Paint()..color = const Color(0xFFFF5722);
    canvas.drawCircle(const Offset(2, -23), 5.5, helmetPaint);

    // Sun Peak / Visor
    final visorPath = Path()
      ..moveTo(2, -26)
      ..lineTo(8, -27)
      ..lineTo(6, -24)
      ..close();
    canvas.drawPath(visorPath, Paint()..color = const Color(0xFF0F172A));

    // Iridescent Mirrored Goggles
    final gogglePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3.5, -24.5, 4.2, 2.8),
        const Radius.circular(1),
      ),
      gogglePaint,
    );

    canvas.restore();
  }

  /// 🛞 Helper to render rubber knobby tire with spinning spokes
  void _drawBikeWheel(Canvas canvas, Offset center, double rotation) {
    // Outer Rubber Tire
    final tirePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6;
    canvas.drawCircle(center, 9.5, tirePaint);

    // Knobby Treads
    final treadPaint = Paint()
      ..color = const Color(0xFF020617)
      ..strokeWidth = 1.6;
    for (int k = 0; k < 8; k++) {
      final ang = rotation + k * (math.pi / 4);
      final p1 = center + Offset(math.cos(ang) * 9.0, math.sin(ang) * 9.0);
      final p2 = center + Offset(math.cos(ang) * 11.2, math.sin(ang) * 11.2);
      canvas.drawLine(p1, p2, treadPaint);
    }

    // Silver Alloy Rim
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 6.5, rimPaint);

    // Crossed Spokes rotating with wheel
    final spokePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;
    for (int s = 0; s < 4; s++) {
      final ang = rotation + s * (math.pi / 2);
      canvas.drawLine(
        center - Offset(math.cos(ang) * 6.0, math.sin(ang) * 6.0),
        center + Offset(math.cos(ang) * 6.0, math.sin(ang) * 6.0),
        spokePaint,
      );
    }

    // Gold Axle Hub
    final axlePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, 2.0, axlePaint);
  }
}
