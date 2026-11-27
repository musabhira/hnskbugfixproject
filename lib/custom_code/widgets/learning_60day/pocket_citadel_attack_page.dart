import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../main_profile_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_score_level_engine.dart';
import 'pocket_world_street_page.dart';
import 'pocket_citadel_challenge_generator.dart';
import 'pocket_world_game_rules_modal.dart';
import 'pocket_citadel_fight_dialog.dart';
import 'games/pocket_essential_spelling_game_page.dart';
import 'games/pocket_citadel_runner_attack_page.dart';
import '../report_dailoge.dart';
import 'pocket_citadel_store_sheet.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_store_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_top_rank_theme.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_action_chat_service.dart';
import 'painters/citadel_scenic_landscape_painter.dart';
export 'painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_resident_island_view.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/president/presidential_palace_castle_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/president/presidential_security_forces.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'day90_master_certificate_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_saved_account_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/settings_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'pocket_citadel_story_share_page.dart';

/// ⚔️ Pocket Citadel Attack Page: Full-Screen Battle & Defense Raid
/// Audio Directive:
/// "അറ്റാക്ക് ചെയ്യുന്നത് അതിൽ ടാപ്പ് ചെയ്യുമ്പോൾ തന്നെ ഫുൾ സ്ക്രീൻ ആയിട്ട് പോണം...
/// ആപ്പിന്റെ ഫുൾ സ്ക്രീൻ ആയിട്ട് പോവുക, അടിയിൽ വീടായിട്ട് നിൽക്കുക.
/// അപ്പോ അറ്റാക്ക് ചെയ്യുമ്പോൾ ഉള്ള അറ്റാക്ക് ക്വസ്റ്റ്യൻസ് കറക്റ്റ് ആക്കി കഴിഞ്ഞു കഴിഞ്ഞാൽ അറ്റാക്ക് ഉള്ളതിൽ കാണും.
/// കറക്റ്റ് അതിൽ പോയി ടാപ്പ് ചെയ്യുക എന്നിട്ട് അറ്റാക്ക് ചെയ്യാൻ പറ്റണം.
/// അറ്റാക്ക് ചെയ്തത് ആരാണെന്നുള്ളത് അതിന്റെ മെയിൻ പ്രൊഫൈലിൽ കാണണം. അറ്റാക്കിങ് ഒന്ന് പവർഫുൾ ആക്ക് ട്ടോ."
class PocketCitadelAttackPage extends StatefulWidget {
  final PocketNeighbor neighbor;
  final int attackerDay;
  final int attackerStreak;
  final bool isDefenseMode;
  final bool isKidMode;
  final bool isRevenge;

  const PocketCitadelAttackPage({
    super.key,
    required this.neighbor,
    this.attackerDay = 1,
    this.attackerStreak = 0,
    this.isDefenseMode = false,
    this.isKidMode = false,
    this.isRevenge = false,
  });

  /// 🏰 Open Citadel / House Page for any user or robot from anywhere in the app
  static Future<dynamic> openForUser(
    BuildContext context, {
    required String userId,
    String? targetName,
    PocketNeighbor? neighbor,
    Map<String, dynamic>? preloadedProfile,
    int attackerDay = 1,
    int? targetDay,
    String? paletteId,
    bool isDefenseMode = false,
    bool isKidMode = false,
    bool isRevenge = false,
    String? preferredPlanetCode,
    String? preferredPlanetName,
    int? preferredPlotNumber,
    int? preferredWave,
  }) async {
    // 🏛️ If target is The President of Pocket World, open the Sovereign Citadel living world!
    if (PocketPresidentService.isPresidentId(userId) ||
        userId == 'pocket_president') {
      int effectiveAttackerDay = attackerDay;
      if (effectiveAttackerDay <= 1) {
        try {
          final myId = SupaFlow.client.auth.currentUser?.id;
          if (myId != null) {
            final myProf = await SupaFlow.client
                .from('profile')
                .select('learning_day')
                .eq('user_id', myId)
                .maybeSingle();
            if (myProf != null && myProf['learning_day'] != null) {
              effectiveAttackerDay = (myProf['learning_day'] as num).toInt();
            }
          }
        } catch (_) {}
      }

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: PocketNeighbor.createPresident(),
            attackerDay: effectiveAttackerDay,
            isKidMode: isKidMode,
          ),
        ),
      );
      return;
    }

    if (neighbor != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: neighbor,
            attackerDay: attackerDay,
            isDefenseMode: isDefenseMode,
            isKidMode: isKidMode,
          ),
        ),
      );
      return;
    }

    // 🐾 Check if target is a Kid Animal Robot (from PocketKidsRobotsData: kid_bot_1 to kid_bot_100)
    if (userId.startsWith('kid_bot_') ||
        PocketKidsRobotsData.getAnimalById(userId) != null) {
      final animal = PocketKidsRobotsData.getAnimalById(userId);
      final level = targetDay ?? animal?.dayLevel ?? 1;
      final palList = HousePalette.presets;
      final autoPal = palList[(level - 1) % palList.length].id;
      final cosmosMeta =
          PocketRobotService.getCosmosAddressForRobotId(userId, level: level);
      final animalNeighbor = PocketNeighbor(
        id: userId,
        name: animal?.name ?? targetName ?? 'Animal Companion',
        day: level,
        streak: level,
        rank: 'Level $level Pioneer',
        paletteId: paletteId ?? autoPal,
        isMe: false,
        hasActiveShield: true,
        statusMessage: animal?.bio ?? 'A loyal companion exploring day $level!',
        isPocketRobo: true,
        hp: 100,
        maxHp: 100,
        planetCode: cosmosMeta['planetCode'],
        planetName: cosmosMeta['planetName'],
        islandName: cosmosMeta['islandName'],
        streetName: cosmosMeta['streetName'],
        plotNumber: cosmosMeta['plotNumber'],
        cosmosPin: cosmosMeta['cosmosPin'],
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: animalNeighbor,
            attackerDay: attackerDay,
            isDefenseMode: isDefenseMode,
            isKidMode: true,
          ),
        ),
      );
      return;
    }

    // 🚀 Check if target is a Pioneer (e.g. pioneer_MER_257)
    if (userId.startsWith('pioneer_')) {
      final parts = userId.split('_');
      final pCode = parts.length >= 2 ? parts[1] : 'MER';
      final pGlobalPlot = parts.length >= 3 ? (int.tryParse(parts[2]) ?? 1) : 1;
      final pColony =
          PoketCosmosAllocationService.instance.getColonyByCode(pCode);
      final pParsed =
          PoketCosmosAllocationService.parseGlobalPlotNumber(pGlobalPlot);
      final pLocalPlot = pParsed['localPlotNumber'] as int;
      final pWave = pParsed['wave'] as int;
      final waveStr = pWave.toString().padLeft(2, '0');
      final plotStr = pGlobalPlot.toString().padLeft(3, '0');
      final pioneerNeighbor = PocketNeighbor(
        id: userId,
        name: targetName ?? 'Pioneer $pGlobalPlot',
        day: targetDay ?? (28 + (pLocalPlot * 5) % 60),
        streak: targetDay ?? (28 + (pLocalPlot * 5) % 60),
        rank: 'Cosmic Pioneer',
        paletteId: paletteId ?? 'warm_cottage',
        isMe: false,
        hasActiveShield: true,
        statusMessage: 'Cosmic Pioneer of ${pColony.planetName}',
        isPocketRobo: false,
        hp: 100,
        maxHp: 100,
        planetCode: pColony.code,
        planetName: pColony.planetName,
        islandName: pColony.islandName,
        streetName: pColony.streetName,
        plotNumber: pGlobalPlot,
        cosmosPin: 'PKT-W$waveStr-${pColony.code}-I$waveStr-P$plotStr',
      );
      if (!context.mounted) return null;
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: pioneerNeighbor,
            attackerDay: attackerDay,
            isDefenseMode: isDefenseMode,
            isKidMode: isKidMode,
            isRevenge: isRevenge,
          ),
        ),
      );
    }

    final isRobot = (PocketRobotService.isRobotId(userId) ||
            preloadedProfile?['is_robot'] == true ||
            (neighbor?.isPocketRobo ?? false)) &&
        !PocketPresidentService.isPresidentId(userId);

    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(targetDay ?? 1);
      final dynamicLevel =
          targetDay ?? PocketRobotService.getDynamicLevel(robot);
      final palList = HousePalette.presets;
      final autoPal = palList[(dynamicLevel - 1) % palList.length].id;
      final targetPlanetCode = (preferredPlanetCode != null &&
              preferredPlanetCode.isNotEmpty)
          ? preferredPlanetCode
          : (neighbor?.planetCode != null && neighbor!.planetCode!.isNotEmpty)
              ? neighbor.planetCode!
              : robot.planetCode;
      final colony = (targetPlanetCode.isNotEmpty)
          ? PoketCosmosAllocationService.instance
              .getColonyByCode(targetPlanetCode)
          : null;
      final targetPlanetName = preferredPlanetName ??
          neighbor?.planetName ??
          colony?.planetName ??
          robot.planetName;
      final targetIslandName =
          neighbor?.islandName ?? colony?.islandName ?? robot.islandName;
      final targetStreetName =
          neighbor?.streetName ?? colony?.streetName ?? robot.streetName;
      final targetPlotNumber =
          preferredPlotNumber ?? neighbor?.plotNumber ?? robot.plotNumber;
      final targetPin = (colony != null)
          ? 'PKT-W01-${colony.code}-I01-P${targetPlotNumber.toString().padLeft(2, '0')}'
          : (neighbor?.cosmosPin ?? robot.cosmosPin);

      final robotNeighbor = PocketNeighbor(
        id: robot.id,
        name: targetName ?? neighbor?.name ?? robot.name,
        day: dynamicLevel,
        streak: dynamicLevel,
        rank: robot.cefrRank,
        paletteId: paletteId ??
            neighbor?.paletteId ??
            (robot.housePalette.isNotEmpty ? robot.housePalette : autoPal),
        isMe: false,
        hasActiveShield: true,
        statusMessage: robot.bio,
        isPocketRobo: true,
        hp: 100,
        maxHp: 100,
        planetCode: colony?.code ?? targetPlanetCode,
        planetName: targetPlanetName,
        islandName: targetIslandName,
        streetName: targetStreetName,
        plotNumber: targetPlotNumber,
        cosmosPin: targetPin,
      );
      if (!context.mounted) return null;
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: robotNeighbor,
            attackerDay: attackerDay,
            isDefenseMode: isDefenseMode,
            isKidMode: isKidMode,
          ),
        ),
      );
    }

    Map<String, dynamic>? data = preloadedProfile;
    if (data == null || (data['first_name'] == null && data['name'] == null)) {
      try {
        final res = await SupaFlow.client
            .from('profile')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) {
          data = res;
        } else {
          final idRes = await SupaFlow.client
              .from('profile')
              .select()
              .eq('id', userId)
              .maybeSingle();
          if (idRes != null) data = idRes;
        }
      } catch (e) {
        debugPrint('PocketCitadelAttackPage.openForUser error: $e');
      }

      if (data == null) {
        try {
          final resPlural = await SupaFlow.client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
          if (resPlural != null) data = resPlural;
        } catch (_) {}
      }
    }

    // Secondary fallback: query 'users' table if profile returned no progression
    if (data == null ||
        (data['learning_day'] == null &&
            data['level'] == null &&
            data['pocket_score'] == null)) {
      try {
        final userRes = await SupaFlow.client
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (userRes != null) {
          data = {
            ...?data,
            ...userRes,
            'name': userRes['display_name'] ?? userRes['name'] ?? data?['name'],
          };
        }
      } catch (_) {}
    }

    // Tertiary fallback: check 'pocket_homes' table for stage / level / points
    if (data == null ||
        (data['learning_day'] == null && data['level'] == null)) {
      try {
        final homeRes = await SupaFlow.client
            .from('pocket_homes')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (homeRes != null) {
          data = {
            ...?data,
            'learning_day':
                data?['learning_day'] ?? homeRes['level'] ?? homeRes['day'],
            'level': data?['level'] ?? homeRes['level'],
            'pocket_score': data?['pocket_score'] ?? homeRes['points'],
          };
        }
      } catch (_) {}
    }

    final p = data ?? {};
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    final isMe =
        (userId == currentUserId) || isDefenseMode || (neighbor?.isMe ?? false);

    // Check local SharedPreferences cached stage for this user
    int? localCachedDay;
    try {
      final prefs = await SharedPreferences.getInstance();
      localCachedDay = prefs.getInt('pocket_learning_user_stage_$userId') ??
          prefs.getInt('learning_day_$userId') ??
          prefs.getInt('learning_stage_$userId') ??
          prefs.getInt('user_level_$userId');
    } catch (_) {}

    final rawCourseDay = targetDay ??
        (p['learning_day'] as num?)?.toInt() ??
        (p['learning_stage'] as num?)?.toInt() ??
        (p['stage'] as num?)?.toInt() ??
        (p['level'] as num?)?.toInt() ??
        (p['day'] as num?)?.toInt() ??
        localCachedDay ??
        1;
    final defenderScore = (p['pocket_score'] as num?)?.toInt() ?? 0;
    int effectiveDay = PocketScoreLevelEngine.calculateEffectiveLevel(
      day: rawCourseDay,
      pocketScore: defenderScore,
    );
    // 🛡️ User Direct Progress Protection: Never downgrade a remote user or valid profile below rawCourseDay
    if (rawCourseDay > effectiveDay) {
      effectiveDay = rawCourseDay;
    }
    if (effectiveDay < 1) effectiveDay = 1;
    final palList = HousePalette.presets;
    final autoPal = palList[(effectiveDay - 1) % palList.length].id;
    String chosenPalette = paletteId ?? p['palette_id']?.toString() ?? autoPal;
    if (chosenPalette == 'warm_cottage' ||
        !palList.any((pl) => pl.id == chosenPalette)) {
      chosenPalette = autoPal;
    }

    final bioStr = p['bio']?.toString() ?? '';
    final pinMatch =
        RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bioStr);
    String? userPlanetCode;
    String? userPlanetName;
    String? userIslandName;
    String? userStreetName;
    int? userPlotNum;
    String? userPin;

    final explicitPlanetCode =
        (preferredPlanetCode != null && preferredPlanetCode.isNotEmpty)
            ? preferredPlanetCode
            : (neighbor?.planetCode != null && neighbor!.planetCode!.isNotEmpty)
                ? neighbor.planetCode
                : null;

    if (explicitPlanetCode != null) {
      final colony = PoketCosmosAllocationService.instance
          .getColonyByCode(explicitPlanetCode);
      userPlanetCode = colony.code;
      userPlanetName =
          preferredPlanetName ?? neighbor?.planetName ?? colony.planetName;
      userIslandName = neighbor?.islandName ?? colony.islandName;
      userStreetName = neighbor?.streetName ?? colony.streetName;
      userPlotNum = preferredPlotNumber ??
          neighbor?.plotNumber ??
          ((userId.hashCode.abs() ~/ 10) %
                  PoketCosmosAllocationService.maxPlotsPerIsland) +
              1;
      final waveVal = preferredWave ?? neighbor?.effectiveWave ?? 1;
      userPin = neighbor?.cosmosPin ??
          'PKT-W${waveVal.toString().padLeft(2, '0')}-$userPlanetCode-I${waveVal.toString().padLeft(2, '0')}-P${userPlotNum.toString().padLeft(2, '0')}';
    } else if (pinMatch != null) {
      final waveNum = int.tryParse(pinMatch.group(1) ?? '1') ?? 1;
      final code = pinMatch.group(2) ?? 'EP';
      final localPlot = int.tryParse(pinMatch.group(4) ?? '1') ?? 1;
      final colony =
          PoketCosmosAllocationService.instance.getColonyByCode(code);
      userPlanetCode = colony.code;
      userPlanetName = colony.planetName;
      userIslandName = (waveNum == 1)
          ? colony.islandName
          : PoketCosmosAllocationService.generateInfiniteIslandName(
              colony.code, waveNum, waveNum);
      userStreetName = colony.streetName;
      // Guarantee TRUE global plot number
      userPlotNum =
          (localPlot <= PoketCosmosAllocationService.maxPlotsPerIsland)
              ? PoketCosmosAllocationService.calculateGlobalPlotNumber(
                  wave: waveNum,
                  planetCode: colony.code,
                  localPlotNumber: localPlot,
                )
              : localPlot;
      userPin = pinMatch.group(0);
    } else {
      // 🌌 Deterministic & Database-backed Cosmos Born Address Synchronization
      final resolvedPlot =
          await PoketCosmosAllocationService.instance.getUserPlot(
        userId: userId,
        fallbackName: p['first_name'] ?? p['name'] ?? targetName,
      );
      userPin = resolvedPlot.postalPinCode;
      final parts = resolvedPlot.postalPinCode.split('-');
      userPlanetCode = parts.length > 2 ? parts[2] : 'EP';
      userPlotNum = resolvedPlot.plotNumber;
      userPlanetName = resolvedPlot.planetName;
      userIslandName = resolvedPlot.countryName;
      userStreetName = resolvedPlot.streetName;
    }

    final bool targetIsVip = (p['is_vip'] == true) ||
        (p['is_premium'] == true) ||
        (p['verified'] == true) ||
        (neighbor?.isVip ?? false);

    final contactName =
        ContactsNameService().getDisplayName(userId: userId, fallbackName: '');
    String effectiveTargetName = '';
    if (targetName != null &&
        targetName.isNotEmpty &&
        targetName != 'Citadel Defender' &&
        targetName != 'User' &&
        targetName != 'Defender') {
      effectiveTargetName = targetName;
    } else if (contactName.isNotEmpty) {
      effectiveTargetName = contactName;
    }

    final userNeighbor = PocketNeighbor(
      id: userId,
      name: p['first_name'] ??
          p['name'] ??
          p['display_name'] ??
          (effectiveTargetName.isNotEmpty ? effectiveTargetName : null) ??
          (isMe
              ? (effectiveTargetName.isNotEmpty
                  ? effectiveTargetName
                  : 'Defender')
              : (contactName.isNotEmpty ? contactName : 'Pocket Learner')),
      day: effectiveDay,
      streak: (p['streak'] as num?)?.toInt() ?? effectiveDay,
      rank: p['rank']?.toString() ?? 'Citizen',
      paletteId: chosenPalette,
      isMe: isMe,
      hasActiveShield: true,
      statusMessage: (p['bio'] != null &&
              !p['bio'].toString().toUpperCase().startsWith('PKT-'))
          ? p['bio'].toString()
          : 'Learning English everyday!',
      isPocketRobo: p['is_pocket_robo'] == true,
      hp: 100,
      maxHp: 100,
      isVip: targetIsVip,
      planetCode: userPlanetCode,
      planetName: userPlanetName,
      islandName: userIslandName,
      streetName: userStreetName,
      plotNumber: userPlotNum,
      cosmosPin: userPin,
    );

    int effectiveAttackerDay = attackerDay;
    if (effectiveAttackerDay <= 1) {
      try {
        final myId = SupaFlow.client.auth.currentUser?.id;
        if (myId != null && myId.isNotEmpty) {
          final myScore =
              await PocketFortressDefenseService.getUnifiedScore(myId);
          final prefs = await SharedPreferences.getInstance();
          final myDay = prefs.getInt('day_$myId') ??
              prefs.getInt('learning_day_$myId') ??
              1;
          effectiveAttackerDay = PocketScoreLevelEngine.calculateEffectiveLevel(
            day: myDay,
            pocketScore: myScore,
          );
        }
      } catch (_) {}
    }

    if (!context.mounted) return null;
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketCitadelAttackPage(
          neighbor: neighbor ?? userNeighbor,
          attackerDay: effectiveAttackerDay,
          isDefenseMode: isDefenseMode,
          isKidMode: isKidMode,
        ),
      ),
    );
  }

  @override
  State<PocketCitadelAttackPage> createState() =>
      _PocketCitadelAttackPageState();
}

class _PocketCitadelAttackPageState extends State<PocketCitadelAttackPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _raidStep =
      0; // 0: Overview, 1: Defense Question, 2: Gate Breached (Attack button ready), 3: Victory, -1: Failed
  int _selectedOption = -1;
  bool _isStriking = false;
  bool _isQuestionSheetOpen = false;
  late bool _isDefenderDamaged;
  List<HouseShieldQuestion> _defenseQuestions = [];
  int _currentQIdx = 0;
  int _correctCount = 0;
  int _incorrectCount = 0;

  // 🏛️ Presidential Escort vs Core Fortress Modes (User Audio Directive!)
  bool _isDefenderVip = false;
  bool _isEscortMode = false;
  bool _isEscortDefeated = false;
  List<HouseShieldQuestion> _escortQuestions = [];
  List<HouseShieldQuestion> _fortressQuestions = [];

  // 🎮 Interactive Game States for Citadel Raid Challenges (Sentence Builder, Word Bank, Verb Timeline)
  List<String> _assembledWords = [];
  List<String> _availableWords = [];

  // 🔤 Interactive Spelling Challenge State (Matching Adult Day 1 Step 3 Exactly!)
  String _targetSpellingWord = '';
  List<String?> _spellingSlots = [];
  List<LetterTileItem> _spellingLetterBank = [];

  int _lastPreparedQIdx = -1;
  final FlutterTts _combatTts = FlutterTts();

  Future<void> _speakIndianEnglish(String text) async {
    try {
      await _combatTts.setLanguage('en-IN');
      await _combatTts.setSpeechRate(0.42);
      await _combatTts.speak(text);
    } catch (_) {}
  }

  void _prepareQuestionState(HouseShieldQuestion? q) {
    if (q == null || _lastPreparedQIdx == _currentQIdx) return;
    _lastPreparedQIdx = _currentQIdx;
    _selectedOption = -1;
    final isWordBankMode = q.gameFormat == 'sentence_builder' ||
        q.gameFormat == 'syntax_jigsaw' ||
        q.gameFormat == 'negative_sentence' ||
        q.gameFormat == 'chat_reply' ||
        q.gameFormat == 'spoken_whisper' ||
        q.gameFormat == 'grammar_defusal' ||
        q.gameFormat == 'idiom_maze';

    if (isWordBankMode) {
      _assembledWords = [];
      if (q.options.isNotEmpty &&
          !q.options.any((o) => o.split(' ').length > 3)) {
        _availableWords = List<String>.from(q.options);
      } else if (q.explanation.isNotEmpty) {
        final cleanWords = q.explanation
            .replaceAll(RegExp(r'[^\w\s\?]'), '')
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();
        cleanWords.shuffle();
        _availableWords = cleanWords;
      } else if (q.options.isNotEmpty) {
        final target = q.options[q.correctIndex.clamp(0, q.options.length - 1)];
        final cleanWords = target
            .replaceAll(RegExp(r'[^\w\s\?]'), '')
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();
        cleanWords.shuffle();
        _availableWords = cleanWords;
      } else {
        _availableWords = [];
      }
    } else {
      _assembledWords = [];
      _availableWords = [];
    }

    // 🔤 Prepare Step 3 Letter Slots and Letter Bank for Spelling Challenge
    if (q.gameFormat == 'spelling_challenge') {
      _targetSpellingWord =
          q.explanation.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (_targetSpellingWord.isEmpty) {
        _targetSpellingWord = 'ALWAYS';
      }
      _spellingSlots = List<String?>.filled(_targetSpellingWord.length, null);

      final List<String> letters;
      if (q.options.isNotEmpty && q.options.every((o) => o.length == 1)) {
        letters = List<String>.from(q.options);
      } else {
        letters = _targetSpellingWord.split('');
        const decoys = ['A', 'E', 'I', 'O', 'U', 'R', 'S', 'T'];
        final extra = decoys.where((d) => !letters.contains(d)).take(3);
        letters.addAll(extra);
        letters.shuffle();
      }

      const palette = [
        Color(0xFF38BDF8),
        Color(0xFF10B981),
        Color(0xFFF59E0B),
        Color(0xFFA855F7),
        Color(0xFFEC4899),
        Color(0xFF06B6D4),
        Color(0xFFF97316),
      ];

      _spellingLetterBank = List.generate(
        letters.length,
        (i) => LetterTileItem(
          id: '$i',
          letter: letters[i].toUpperCase(),
          color: palette[i % palette.length],
          isUsed: false,
        ),
      );
    } else {
      _targetSpellingWord = '';
      _spellingSlots = [];
      _spellingLetterBank = [];
    }
  }

  void _onSpellingSlotTapped(int slotIdx) {
    if (slotIdx < 0 || slotIdx >= _spellingSlots.length) return;
    final letter = _spellingSlots[slotIdx];
    if (letter == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _spellingSlots[slotIdx] = null;
      for (final tile in _spellingLetterBank) {
        if (tile.isUsed && tile.letter.toUpperCase() == letter.toUpperCase()) {
          tile.isUsed = false;
          break;
        }
      }
    });
  }

  void _onSpellingTileTapped(LetterTileItem tile) {
    if (tile.isUsed) return;
    final emptyIdx = _spellingSlots.indexOf(null);
    if (emptyIdx == -1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _spellingSlots[emptyIdx] = tile.letter.toUpperCase();
      tile.isUsed = true;
    });
  }

  void _onSpellingBackspace() {
    for (int i = _spellingSlots.length - 1; i >= 0; i--) {
      if (_spellingSlots[i] != null) {
        _onSpellingSlotTapped(i);
        break;
      }
    }
  }

  void _onSpellingShuffle() {
    HapticFeedback.selectionClick();
    setState(() {
      _spellingLetterBank.shuffle();
    });
  }

  void _onSpellingClear() {
    HapticFeedback.selectionClick();
    setState(() {
      for (final tile in _spellingLetterBank) {
        tile.isUsed = false;
      }
      for (int i = 0; i < _spellingSlots.length; i++) {
        _spellingSlots[i] = null;
      }
    });
  }

  // ⏱️ 45s Comfortable Combat Timer
  Timer? _combatTimer;
  int _secondsLeft = 45;
  static const int kMaxCombatSeconds = 45;
  bool _isAntiCheatTriggered = false;
  bool _isTimeoutTriggered = false;

  bool _isTargetProtected = false;
  double _protectionHoursLeft = 0;
  int _protectionSecondsRemaining = 0;
  Timer? _protectionCountdownTimer;
  bool _inCooldown = false;
  double _cooldownHoursLeft = 0;
  int _retriesRemaining =
      1; // User Audio Directive: Exactly 1 retry chance before 6h cooldown
  // ignore: unused_field
  bool _isDailyLimitReached = false;
  int _attacksUsed = 0;
  bool _hasAwardedAttackThisSession = false;
  late int _attackerDay;
  bool _canInitiatePocketTalk = true;

  // 🔍 Interactive Estate Zoom & Pan Controls: Spherical World / Rolling Hills
  int _defenderScore = 0;
  late final TransformationController _transformationController;
  final ValueNotifier<double> _zoomScaleNotifier = ValueNotifier<double>(1.0);
  bool _hasInitializedTransform = false;
  bool? _manualNightOverride;

  late AnimationController _shakeController;
  late AnimationController _beamController;
  late AnimationController _particleController;
  late AnimationController _coinController;
  late AnimationController _heroChargeController;
  late AnimationController _ambientController;
  late AnimationController _profileDrawerController;
  // ignore: unused_field
  bool _isIronDomeFiring = false;
  late AnimationController _ironDomeController;
  late final AnimationController _cameraAnimationController;
  Animation<Matrix4>? _cameraAnimation;
  bool _isVantageView = true;
  double _savedViewportW = 400.0;
  double _savedViewportH = 800.0;
  double _savedWorldW = 1200.0;
  double _savedWorldH = 3400.0;
  double _savedMinScale = 0.23;
  double _savedGroundY = 920.0;
  int? _fetchedDefenderGlobalRank;
  int? _dynamicDefenderLevel;
  int get _effectiveDefenderLevel =>
      _dynamicDefenderLevel ??
      (widget.neighbor.day > 0 ? widget.neighbor.day : 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attackerDay = widget.attackerDay;
    _isDefenderDamaged = widget.neighbor.isDamaged;
    _isDefenderVip = widget.neighbor.isVip;
    _retriesRemaining =
        PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(
            widget.neighbor.day);
    _checkPocketTalkCap();
    _loadDefenderGlobalRank();

    // ⚔️ Start energetic battle / raid music based on robot archetype & level!
    PocketGameAudioService.instance.playAttackTheme(
      targetId: widget.neighbor.id,
      targetDay: widget.neighbor.day,
    );

    _transformationController = TransformationController();

    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _heroChargeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ironDomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _profileDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _loadBattleState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PocketGameAudioService.instance.stop();
    _combatTimer?.cancel();
    _protectionCountdownTimer?.cancel();
    _transformationController.dispose();
    _cameraAnimationController.dispose();
    _zoomScaleNotifier.dispose();
    _shakeController.dispose();
    _beamController.dispose();
    _particleController.dispose();
    _coinController.dispose();
    _heroChargeController.dispose();
    _ironDomeController.dispose();
    _ambientController.dispose();
    _profileDrawerController.dispose();
    super.dispose();
  }

  void _togglePerspective() {
    HapticFeedback.lightImpact();
    setState(() => _isVantageView = !_isVantageView);

    final Matrix4 target = Matrix4.identity();
    if (_isVantageView) {
      // Long Vantage View: Overview of Sovereign Island Defenses
      final maxTx = 0.0;
      final minTx = -((_savedWorldW * _savedMinScale) - _savedViewportW);
      final safeMinTx = minTx < maxTx ? minTx : maxTx;
      final maxTy = 0.0;
      final minTy = -((_savedWorldH * _savedMinScale) - _savedViewportH);
      final safeMinTy = minTy < maxTy ? minTy : maxTy;
      target.setEntry(0, 0, _savedMinScale);
      target.setEntry(1, 1, _savedMinScale);
      target.setEntry(0, 3, safeMinTx / 2);
      target.setEntry(1, 3, safeMinTy / 2);
    } else {
      // Citadel Focus View (Close up on Palace Gates & Castle)
      final isLandscape = _savedViewportW > _savedViewportH;
      final closeScale = isLandscape
          ? (_savedViewportH / (410.0 * 1.25)).clamp(_savedMinScale, 3.5)
          : (_savedViewportW / (540.0 * 1.08)).clamp(_savedMinScale, 3.5);
      final houseCenterX = _savedWorldW / 2;
      final houseCenterY = _savedGroundY - 10.0 - (410.0 * 0.50);
      final maxTx = 0.0;
      final minTx = -((_savedWorldW * closeScale) - _savedViewportW);
      final safeMinTx = minTx < maxTx ? minTx : maxTx;
      final tx = ((_savedViewportW / 2) - (houseCenterX * closeScale))
          .clamp(safeMinTx, maxTx);
      final maxTy = 0.0;
      final minTy = -((_savedWorldH * closeScale) - _savedViewportH);
      final safeMinTy = minTy < maxTy ? minTy : maxTy;
      final targetTy = isLandscape
          ? ((_savedViewportH * 0.50) - (houseCenterY * closeScale))
          : ((_savedViewportH * 0.40) - (houseCenterY * closeScale));
      final ty = targetTy.clamp(safeMinTy, maxTy);
      target.setEntry(0, 0, closeScale);
      target.setEntry(1, 1, closeScale);
      target.setEntry(0, 3, tx);
      target.setEntry(1, 3, ty);
    }

    final start = _transformationController.value;
    _cameraAnimation = Matrix4Tween(begin: start, end: target).animate(
      CurvedAnimation(
          parent: _cameraAnimationController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        _transformationController.value = _cameraAnimation!.value;
      });
    _cameraAnimationController.forward(from: 0.0);
  }

  void _openDefenderProfile() {
    HapticFeedback.selectionClick();
    if (_profileDrawerController.value > 0.5) {
      _profileDrawerController.reverse();
    } else {
      _profileDrawerController.forward();
    }
  }

  void _navigateToDefenderPlotOnIsland() {
    HapticFeedback.lightImpact();
    final bool isPres = widget.neighbor.isPresident ||
        PocketPresidentService.isPresidentId(widget.neighbor.id) ||
        widget.neighbor.id == 'pocket_president';
    final int defPlot = isPres
        ? 1
        : ((widget.neighbor.plotNumber != null &&
                widget.neighbor.plotNumber! > 0)
            ? widget.neighbor.plotNumber!
            : widget.neighbor.effectivePlotNumber);
    final String defPlanet = isPres
        ? 'EP'
        : ((widget.neighbor.planetCode != null &&
                widget.neighbor.planetCode!.isNotEmpty)
            ? widget.neighbor.planetCode!
            : widget.neighbor.effectivePlanetCode);
    final int defWave = isPres ? 1 : widget.neighbor.effectiveWave;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PoketCosmosResidentIslandView(
          userId: widget.neighbor.id,
          userName: widget.neighbor.name,
          targetPlanetCode: defPlanet,
          targetPlotNumber: defPlot,
          targetWave: defWave,
          isPresidential: isPres,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Anti-Cheat: If user minimizes the app, switches to AI/Google Lens, or leaves screen during battle
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_raidStep == 1 && mounted) {
        _combatTimer?.cancel();
        PocketFortressDefenseService.recordFailedAttackCooldown(
            widget.neighbor.id,
            minutes: 30);
        setState(() {
          _isAntiCheatTriggered = true;
          _raidStep = -1; // Raid Failed!
        });
      }
    }
  }

  void _startCombatTimer() {
    _combatTimer?.cancel();
    setState(() {
      _secondsLeft = kMaxCombatSeconds;
      _isTimeoutTriggered = false;
      _isAntiCheatTriggered = false;
    });

    _combatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
        if (_secondsLeft <= 5) {
          HapticFeedback.lightImpact(); // Audible ticking warning
        }
      } else {
        timer.cancel();
        _handleCombatTimeout();
      }
    });
  }

  void _handleCombatTimeout() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    if (_retriesRemaining > 0) {
      setState(() {
        _retriesRemaining--;
        _selectedOption = -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('⚠️ Blitz timer expired! 1 Second Chance remaining. Hurry!'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 3),
        ),
      );
      _startCombatTimer();
    } else {
      PocketFortressDefenseService.recordFailedAttackCooldown(
          widget.neighbor.id,
          minutes: 30);
      setState(() {
        _secondsLeft = 0;
        _isTimeoutTriggered = true;
        _raidStep = -1; // Time expired -> Defeat!
      });
    }
  }

  void _startProtectionCountdownTimer() {
    _protectionCountdownTimer?.cancel();
    if (_protectionSecondsRemaining <= 0) return;
    _isTargetProtected = true;
    _protectionCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_protectionSecondsRemaining > 0) {
        setState(() {
          _protectionSecondsRemaining--;
          _protectionHoursLeft = _protectionSecondsRemaining / 3600.0;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTargetProtected = false;
          _protectionHoursLeft = 0;
        });
      }
    });
  }

  String _formatProtectionCountdown(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  Future<void> _loadBattleState() async {
    if (widget.neighbor.isMe || widget.isDefenseMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final myId = SupaFlow.client.auth.currentUser?.id ?? widget.neighbor.id;
        final localDay = (myId.isNotEmpty
                ? prefs.getInt('learning_day_$myId') ??
                    prefs.getInt('day_$myId')
                : null) ??
            prefs.getInt('learning_day') ??
            prefs.getInt('current_learning_day') ??
            prefs.getInt('day') ??
            prefs.getInt('kCurrentLearningDay');
        int? dbDay;
        try {
          final prof = await SupaFlow.client
              .from('profile')
              .select('learning_day, day, stage, level, pocket_score')
              .or('user_id.eq.$myId,id.eq.$myId')
              .maybeSingle();
          if (prof != null) {
            dbDay = (prof['learning_day'] as num?)?.toInt() ??
                (prof['day'] as num?)?.toInt() ??
                (prof['stage'] as num?)?.toInt() ??
                (prof['level'] as num?)?.toInt();
            if (prof['pocket_score'] != null) {
              final ps = (prof['pocket_score'] as num).toInt();
              if (ps > 0) _defenderScore = ps;
            }
          }
        } catch (_) {}
        final resolved = (dbDay != null && dbDay > 0)
            ? dbDay
            : ((localDay != null && localDay > 0)
                ? localDay
                : (widget.neighbor.day > 0 ? widget.neighbor.day : 1));
        if (mounted) {
          setState(() {
            _dynamicDefenderLevel = resolved;
            _attackerDay = resolved;
          });
        }
      } catch (_) {}
    } else if (_attackerDay <= 1) {
      try {
        final myId = SupaFlow.client.auth.currentUser?.id;
        if (myId != null) {
          final myProf = await SupaFlow.client
              .from('profile')
              .select('learning_day')
              .eq('user_id', myId)
              .maybeSingle();
          if (myProf != null && myProf['learning_day'] != null) {
            final ld = (myProf['learning_day'] as num).toInt();
            if (mounted) setState(() => _attackerDay = ld);
          }
        }
      } catch (_) {}
    }

    final targetId = widget.neighbor.id;
    final inCooldown =
        await PocketFortressDefenseService.isTargetInCooldown(targetId);
    final cooldownMinutes = inCooldown
        ? await PocketFortressDefenseService.getCooldownMinutesRemaining(
            targetId)
        : 0;

    // Check remote Supabase pocket_homes for damaged status
    try {
      final homeDoc = await SupaFlow.client
          .from('pocket_homes')
          .select('is_damaged, last_attacked_at')
          .or('user_id.eq.$targetId,id.eq.$targetId')
          .maybeSingle();
      if (homeDoc != null && homeDoc['is_damaged'] == true) {
        _isDefenderDamaged = true;
      }
    } catch (_) {}

    final isProtectedRaw =
        await PocketFortressDefenseService.isUnderPresidentialProtection(
            targetId);
    final protectionSecondsRaw = isProtectedRaw
        ? await PocketFortressDefenseService
            .getPresidentialProtectionSecondsRemaining(targetId)
        : 0;
    final isRobotDefender = widget.neighbor.isPocketRobo ||
        PocketRobotService.isRobotId(targetId) ||
        targetId.startsWith('kid_bot_') ||
        targetId.startsWith('rival_citadel');
    bool isProtected = isProtectedRaw;
    int protectionSeconds = protectionSecondsRaw;
    if (!isProtected &&
        (widget.neighbor.isDamaged || _isDefenderDamaged) &&
        !isRobotDefender &&
        !widget.neighbor.isPresident &&
        !widget.neighbor.isMe &&
        !widget.isDefenseMode) {
      isProtected = true;
      protectionSeconds = await PocketFortressDefenseService
          .getPresidentialProtectionSecondsRemaining(targetId);
      if (protectionSeconds <= 0) {
        protectionSeconds =
            PocketFortressDefenseService.kPresidentialProtectionHours * 3600;
      }
    }
    final protectionMinutes = (protectionSeconds / 60).ceil();
    final attacksUsed =
        await PocketFortressDefenseService.getDailyAttacksUsedToday();
    final isDailyLimitReached =
        attacksUsed >= PocketFortressDefenseService.kDailyMaxAttacks;

    // 🛡️ User Directive: Escort defense belongs EXCLUSIVELY to User B (Defender) if they are VIP/Premium/Verified!
    // The attacker's VIP status must NEVER trigger escort mode on a free or normal defender's house.
    bool isTargetVip = widget.neighbor.isVip;
    if (!isTargetVip &&
        !widget.neighbor.isMe &&
        !widget.neighbor.isPocketRobo &&
        !widget.neighbor.id.startsWith('kid_bot_') &&
        !widget.neighbor.id.startsWith('pioneer_') &&
        !widget.neighbor.id.startsWith('pocket_robo') &&
        !widget.neighbor.id.startsWith('rival_citadel')) {
      try {
        final prof = await SupaFlow.client
            .from('profile')
            .select('is_vip, is_premium, verified')
            .or('user_id.eq.${widget.neighbor.id},id.eq.${widget.neighbor.id}')
            .maybeSingle();
        if (prof != null) {
          isTargetVip = (prof['is_vip'] == true) ||
              (prof['is_premium'] == true) ||
              (prof['verified'] == true);
        }
      } catch (_) {}
    }
    final bool requireEscort = isTargetVip;
    final customArmed = await PocketFortressDefenseService.loadShieldQuestions(
      widget.neighbor.day,
      isNeighbor: true,
      targetUserId: widget.neighbor.id,
    );

    // 🛡️ 1. Load 10 VIP Escort Attack tasks (POKET VIP Member Escort Defense System)
    List<HouseShieldQuestion> escortQuestions = [];
    if (requireEscort) {
      final escortRandom = math.Random(
          (widget.neighbor.id.hashCode.abs() * 13) + (widget.neighbor.day * 7));
      escortQuestions =
          PocketCitadelChallengeGenerator.generateEscortTasks(10, escortRandom);
    }

    // 🛡️ Fetch equipped defenses for the defender from Citadel Store (Real military fortifications!)
    final defenderEquipped = await PocketCitadelStoreService.instance
        .getEquippedDefenses(userId: widget.neighbor.id);

    // 🏰 2. Load Core Fortress Defense Cards + Equipped Store Defenses (Strictly matching defenderLevel + store military gates)
    final fortressQuestions =
        PocketCitadelChallengeGenerator.generateChallengesForDefender(
      defenderLevel: widget.neighbor.day,
      defenderId: widget.neighbor.id,
      isPresident: widget.neighbor.isPresident,
      isVip: false,
      customArmedQuestions: customArmed,
      equippedDefenses: defenderEquipped,
    );

    final activeQuestions = (requireEscort && !_isEscortDefeated)
        ? escortQuestions
        : fortressQuestions;

    int defenderScore = widget.neighbor.isPresident
        ? 99999
        : PocketScoreLevelEngine.getRequiredScoreForLevel(widget.neighbor.day) +
            (widget.neighbor.streak * 15);
    try {
      if (widget.neighbor.isPresident) {
        defenderScore = 99999;
      } else if (!widget.neighbor.id.startsWith('pocket_robo') &&
          !widget.neighbor.id.startsWith('rival_citadel')) {
        // 1. Primary lookup: Real Global Pocket Score from profile table!
        final pRes = await SupaFlow.client
            .from('profile')
            .select('pocket_score, xp')
            .or('user_id.eq.${widget.neighbor.id},id.eq.${widget.neighbor.id}')
            .maybeSingle();
        if (pRes != null &&
            pRes['pocket_score'] != null &&
            (pRes['pocket_score'] as num).toInt() > 0) {
          defenderScore = (pRes['pocket_score'] as num).toInt();
        } else {
          final res = await SupaFlow.client
              .from('pocket_homes')
              .select('points, hp, stage')
              .eq('user_id', widget.neighbor.id)
              .maybeSingle();
          if (res != null && res['points'] != null) {
            defenderScore = (res['points'] as num).toInt();
          }
        }
      } else {
        final roboScore = await PocketFortressDefenseService.getRobotScore(
            widget.neighbor.id, widget.neighbor.day);
        defenderScore = roboScore;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _inCooldown = inCooldown;
        _cooldownHoursLeft = cooldownMinutes / 60.0;
        _isTargetProtected = isProtected;
        _protectionHoursLeft = protectionMinutes / 60.0;
        _protectionSecondsRemaining = protectionSeconds;
        if (isProtected) {
          _isDefenderDamaged = true;
        }
        _attacksUsed = attacksUsed;
        _isDailyLimitReached = isDailyLimitReached;
        _isDefenderVip = isTargetVip;
        _isEscortMode = (requireEscort && !_isEscortDefeated);
        _escortQuestions = escortQuestions;
        _fortressQuestions = fortressQuestions;
        _defenseQuestions = activeQuestions;
        _defenderScore = defenderScore;
      });
      _startProtectionCountdownTimer();
    }
  }

  Future<void> _executeCitadelAttack(
      {bool isPostRunnerAnimation = false}) async {
    if (_isStriking) return;
    if (isPostRunnerAnimation) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop({'passed': true});
        return;
      }
      setState(() {
        _raidStep = 3;
        _isDefenderDamaged = true;
      });
      _showVictoryDialog();
      return;
    }
    setState(() => _isStriking = true);

    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);

    // Phase 1: Hero rushes forward with charging battle sprint up to citadel steps (y=1100 -> 730)
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    _heroChargeController.forward(from: 0.0);

    // Wait for hero sprint to reach mansion front steps (~600ms)
    await Future.delayed(const Duration(milliseconds: 600));

    final bool isTargetPresident = widget.neighbor.isPresident;
    if (isTargetPresident) {
      // 🛡️ User Audio Directive: Iron Dome System actively intercepts incoming strikes!
      setState(() => _isIronDomeFiring = true);
      _ironDomeController.forward(from: 0.0);
      SystemSound.play(SystemSoundType.alert);
    }

    // Phase 2: Hero leaps & unleashes avatar-specific weapon strike
    HapticFeedback.heavyImpact();
    _beamController.forward(from: 0.0);

    // Strike travels and hits citadel mansion gates (~350ms)
    await Future.delayed(const Duration(milliseconds: 350));

    // Phase 3: Blast impact, screen shake & explosion debris
    _shakeController.forward(from: 0.0);
    _particleController.forward(from: 0.0);

    for (int i = 0; i < 4; i++) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 70));
    }
    HapticFeedback.vibrate();

    final myUser = SupaFlow.client.auth.currentUser;
    final myId = myUser?.id ?? 'me';
    String myName = 'Player';
    String? myAvatar;
    try {
      final myProfile = await SupaFlow.client
          .from('profile')
          .select('name, username, avatar_url, profile_image_url')
          .eq('user_id', myId)
          .maybeSingle();
      if (myProfile != null) {
        myName =
            (myProfile['name'] ?? myProfile['username'] ?? 'Player').toString();
        myAvatar = (myProfile['avatar_url'] ?? myProfile['profile_image_url'])
            ?.toString();
      }
    } catch (_) {}
    if (myName == 'Player' || myName.isEmpty) {
      final cachedName =
          myUser?.userMetadata?['name'] ?? myUser?.userMetadata?['full_name'];
      if (cachedName != null && cachedName.toString().isNotEmpty) {
        myName = cachedName.toString();
      }
    }

    final result = await PocketFortressDefenseService.processRaidBreach(
      defenderHouseId: widget.neighbor.id,
      attackerId: myId,
      damageHp: 60,
      attackerName: myName,
      attackerAvatar: myAvatar ?? '⚔️',
      attackerWeapon: perk.combatWeaponName,
      defenderHasIronDome: widget.neighbor.hasActiveShield,
    );

    // 🛡️ User Audio Directive: 6-Hour Police Protection activated after raid
    await PocketFortressDefenseService.placeUnderPresidentialProtection(
        widget.neighbor.id,
        hours: 6);
    await PocketPresidentService.notifyPresidentialProtection(
        widget.neighbor.id,
        hours: 6);

    // ⚔️ Audio Directive: Single attack count and single score addition per raid victory
    final looted = (result['lootedCoins'] as num? ?? 15).toInt();
    if (!_hasAwardedAttackThisSession) {
      _hasAwardedAttackThisSession = true;
      await PocketFortressDefenseService.recordTargetAttacked(
          widget.neighbor.id);
      await PocketFortressDefenseService.recordAttackLaunchedToday();
      if (widget.isKidMode) {
        await PocketKidsService.addStudentScore(looted > 0 ? looted : 15);
        await PocketKidsService.incrementAttackCount();
      } else {
        if (looted > 0) {
          await PocketFortressDefenseService.awardPoints(looted);
        }
        if (myId.isNotEmpty && myId != 'me') {
          await PocketTrophyService.recordSuccessfulAttack(myId);
          await PocketTrophyService.recordPactAttack(myId, widget.neighbor.id);
        }
      }

      // Automatically send system attack chat message between attacker and defender
      if (myId.isNotEmpty && widget.neighbor.id.isNotEmpty) {
        await PocketActionChatService.sendAttackActionMessage(
          attackerId: myId,
          defenderId: widget.neighbor.id,
          weapon: perk.combatWeaponName,
          damage: '60%',
          lootedCoins: looted > 0 ? looted : 15,
          attackerDay: widget.attackerDay,
          attackerName: myName,
          attackerAvatar: myAvatar,
          defenderName: widget.neighbor.name,
          defenderAvatar: null,
          isRevenge: widget.isRevenge,
        );
      }
    }

    // Phase 4: Fountain of looted coins exploding from citadel into player's grasp
    _coinController.forward(from: 0.0);
    setState(() {
      _defenderScore = math.max(0, _defenderScore - (looted > 0 ? looted : 15));
      _isDefenderDamaged = true;
      _isTargetProtected = true;
      _protectionHoursLeft = 24.0;
      _protectionSecondsRemaining = 24 * 3600;
    });
    _startProtectionCountdownTimer();

    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      setState(() {
        _isStriking = false;
        _isIronDomeFiring = false;
        _raidStep = 3; // Victory!
      });
      _showVictoryDialog();
    }
  }

  void _showReportDialog(HouseShieldQuestion currentQ) {
    String selectedReason = 'fake_english';
    final aiVerdict = PocketFortressDefenseService.validateQuestion(
      currentQ.question,
      currentQ.options,
      currentQ.correctIndex,
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🏛️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRESIDENT REPORT',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Report Fake / Invalid Question to The President',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question snippet
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUESTION UNDER SCRUTINY:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentQ.question,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 🤖 Automated AI Scan Result
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: aiVerdict.isApproved
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : (aiVerdict.isBanThreat
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : Colors.amber.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: aiVerdict.isApproved
                          ? const Color(0xFF10B981)
                          : (aiVerdict.isBanThreat
                              ? Colors.redAccent
                              : Colors.amber),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(aiVerdict.sealIcon,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI SCAN: ${aiVerdict.title}',
                              style: TextStyle(
                                color: aiVerdict.isApproved
                                    ? const Color(0xFF34D399)
                                    : (aiVerdict.isBanThreat
                                        ? Colors.redAccent
                                        : Colors.amber),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              aiVerdict.feedback,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Violation type selection
                Text(
                  'SELECT REPORT REASON:',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'fake_english',
                        child: Text('Fake / Gibberish English')),
                    DropdownMenuItem(
                        value: 'wrong_answer_key',
                        child: Text('Incorrect / Broken Answer Key')),
                    DropdownMenuItem(
                        value: 'impossible_puzzle',
                        child: Text('Unfair / Impossible Puzzle')),
                    DropdownMenuItem(
                        value: 'abusive_language',
                        child: Text('Inappropriate / Abusive Language')),
                    DropdownMenuItem(
                        value: 'unrelated_content',
                        child: Text('Not Educational English')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'The President and Supreme Court investigate fake questions. Fraudulent traps result in Citadel Demolition and Score Penalties.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.shield_rounded,
                  size: 16, color: Color(0xFFFFD700)),
              label: Text(
                'SUBMIT TO PRESIDENT 🏛️',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showPresidentialDispatchOverlay(
                  currentQ: currentQ,
                  reason: selectedReason,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPresidentialDispatchOverlay({
    required HouseShieldQuestion currentQ,
    required String reason,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PresidentialDispatchDialog(
        targetName: widget.neighbor.name,
        targetId: widget.neighbor.id,
        currentQ: currentQ,
        reason: reason,
      ),
    );
  }

  void _showCitadelReportOptions() {
    HapticFeedback.mediumImpact();
    ReportHelper.showReportDialog(
      context: context,
      contentType: 'citadel',
      contentId: widget.neighbor.id,
      contentTitle: "${widget.neighbor.name}'s Citadel",
      onReportSubmitted: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Report filed. The President & Safety Team will inspect this Citadel within 24h.'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _showBlockDefenderDialog() async {
    await ReportHelper.blockUser(
      context: context,
      targetUserId: widget.neighbor.id,
      targetUserName: widget.neighbor.name,
      onBlocked: () {
        if (mounted) {
          Navigator.pop(context, false);
        }
      },
    );
  }

  Future<void> _shareCitadelToVibes() async {
    try {
      final myUser = SupaFlow.client.auth.currentUser;
      final myId = myUser?.id;
      if (myId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to share to Vibes')),
        );
        return;
      }

      String? profileId;
      try {
        final pRes = await SupaFlow.client
            .from('profile')
            .select('id')
            .eq('user_id', myId)
            .maybeSingle();
        if (pRes != null) {
          profileId = pRes['id']?.toString();
        }
      } catch (_) {}

      final bool isPres = widget.neighbor.isPresident;
      final String defenderName = widget.neighbor.name;
      final int level = widget.neighbor.day;
      final String caption = isPres
          ? '🏛️ Sovereign Presidential Palace! Tap to visit or challenge ⚔️'
          : '🏰 Explore $defenderName\'s Level $level Citadel! Tap to visit or challenge ⚔️';

      final metadata = {
        'target_user_id': widget.neighbor.id,
        'target_user_name': defenderName,
        'is_president': isPres,
        'is_robot': widget.neighbor.isPocketRobo,
        'day': level,
        'cefr_rank': widget.neighbor.rank,
        'palette_id': widget.neighbor.paletteId,
        'hp': widget.neighbor.hp,
        'max_hp': widget.neighbor.maxHp,
      };

      await SupaFlow.client.from('statuses').insert({
        'user_id': myId,
        'profile_id': profileId,
        'media_type': 'citadel_fortress',
        'metadata': metadata,
        'media_url': '',
        'thumbnail_url': null,
        'caption': caption,
        'duration': 10,
        'expires_at':
            DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
        'is_active': true,
        'is_kid': PocketKidsService.isKidAccount,
      });

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFFFFD700)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Shared $defenderName\'s Citadel to Vibes! ✨',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E1B4B),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing citadel to vibes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share to Vibes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Audio directive: In a 24-hour day, night is ONLY at most 30 minutes (strictly 03:00 - 03:30 AM).
    // The other 23.5 hours are bright, radiant DAYLIGHT!
    final now = DateTime.now();
    final isNightByDefault = (now.hour == 3 && now.minute < 30);
    final isNight = _manualNightOverride ?? isNightByDefault;
    final hoursLeftIn6hBlock = 6 - (now.hour % 6);
    final cycleLabel = isNight
        ? '🌙 Night (${hoursLeftIn6hBlock}h left)'
        : '☀️ Day (${hoursLeftIn6hBlock}h left)';
    final isDay90 = widget.neighbor.day >= 90;

    final bool isPresident = widget.neighbor.isPresident;

    // 🌍 Virtual World Dimensions:
    // For President: Proportional to smartphone screen aspect ratio so that at max zoom-out
    // the world naturally and completely fills 100% of the screen, locked horizontally and vertically!
    final double worldW = 1200.0;
    const double houseW = 420.0;
    const double houseH = 380.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_profileDrawerController.value > 0.1) {
          _profileDrawerController.reverse();
          return;
        }
        if (_isQuestionSheetOpen) {
          setState(() => _isQuestionSheetOpen = false);
          return;
        }
        Navigator.of(context).pop(_raidStep == 3);
      },
      child: Scaffold(
        backgroundColor:
            isNight ? const Color(0xFF031024) : const Color(0xFF0284C7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final bottomPad = MediaQuery.of(context).padding.bottom;
            final collapsedH = 92.0 + bottomPad;
            final drawerMaxH = h * 0.92;
            final drawerCurrentH = ui.lerpDouble(
                collapsedH, drawerMaxH, _profileDrawerController.value)!;

            final isLandscape = w > h;
            final double worldH = 1600.0;
            final double groundY = 920.0;
            final double houseLeft = (worldW - houseW) / 2;
            final double houseTop = groundY - 14.0 - houseH;

            // 🏛️ Sovereign Presidential Palace Castle Dimensions
            final double palaceW = 540.0;
            final double palaceH = 410.0;
            final double palaceLeft = (worldW - palaceW) / 2;
            final double palaceTop =
                groundY - 14.0 - houseH + (houseH - palaceH);

            _savedViewportW = w;
            _savedViewportH = h;
            _savedWorldW = worldW;
            _savedWorldH = worldH;
            _savedGroundY = groundY;

            // 🛡️ Zoom Range:
            // Naturally align President House within the exact 90-level estate viewport & camera
            final double houseZoomScale = isPresident
                ? (isLandscape
                    ? math.min(w / (palaceW * 1.05), h / (palaceH * 1.15))
                    : (w / (houseW * 1.05)))
                : (w / (houseW * 1.05));

            final double baseMinScale = math.max(w / worldW, h / worldH);

            final minScale = (w <= 0) ? 0.30 : baseMinScale;
            _savedMinScale = minScale;
            const maxScale = 3.5;

            final defaultScale = (w <= 0)
                ? 1.0
                : math.min(maxScale, math.max(minScale, houseZoomScale));

            // 🏠 Default View: Camera smoothly focuses on the House centered on screen!
            if (!_hasInitializedTransform && w > 0 && h > 0) {
              _hasInitializedTransform = true;

              final houseCenterX = worldW / 2;
              final houseCenterY = houseTop + (houseH * 0.52);

              final maxTx = 0.0;
              final minTx = -((worldW * defaultScale) - w);
              final safeMinTx = minTx < maxTx ? minTx : maxTx;
              final tx = ((w / 2) - (houseCenterX * defaultScale))
                  .clamp(safeMinTx, maxTx);

              final maxTy = 0.0;
              final minTy = -((worldH * defaultScale) - h);
              final safeMinTy = minTy < maxTy ? minTy : maxTy;
              final targetTy = ((h * 0.42) - (houseCenterY * defaultScale));
              final ty = targetTy.clamp(safeMinTy, maxTy);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final initialMatrix = Matrix4.identity();
                  initialMatrix.setEntry(0, 0, defaultScale);
                  initialMatrix.setEntry(1, 1, defaultScale);
                  initialMatrix.setEntry(0, 3, tx);
                  initialMatrix.setEntry(1, 3, ty);
                  _transformationController.value = initialMatrix;
                }
              });
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 🌌 Infinite Cosmic Ocean & Sky Backdrop Matching Celestial Planet Colors
                Positioned.fill(
                  child: CustomPaint(
                    painter: CitadelInfiniteOceanSkyBackdropPainter(
                      isNight: isNight,
                      ambientProg: _ambientController.value,
                      planetCode: widget.neighbor.effectivePlanetCode,
                    ),
                  ),
                ),

                // 🔍 Interactive Estate Canvas with Smooth Pinch-to-Zoom & Pan (No letterbox, zero borders)
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: minScale,
                    maxScale: maxScale,
                    boundaryMargin: EdgeInsets.zero,
                    constrained: false,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: worldW,
                      height: worldH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Full-Screen 2D Open World Living Scenery (Animated with _ambientController)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _ambientController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: CitadelScenicLandscapePainter(
                                    isDamaged: _isDefenderDamaged,
                                    groundBaseY: groundY,
                                    isNight: isNight,
                                    isDay90: isDay90 || isPresident,
                                    ambientProg: _ambientController.value,
                                    isPresident: false,
                                    planetCode:
                                        widget.neighbor.effectivePlanetCode,
                                  ),
                                );
                              },
                            ),
                          ),

                          // 2. Central Estate: Flame English House (Day 90 + Presidential Upgrades for President)
                          if (isPresident)
                            Positioned(
                              left: palaceLeft,
                              top: palaceTop,
                              width: palaceW,
                              height: palaceH,
                              child: IgnorePointer(
                                child: RepaintBoundary(
                                  child: FlameEnglishHouseWidget(
                                    currentDay: 90,
                                    streak: 90,
                                    isDamaged: _isDefenderDamaged,
                                    houseId: 'pocket_president',
                                    paletteId: widget.neighbor.paletteId,
                                    isPresident: true,
                                    showTestingControls: false,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            Positioned(
                              left: houseLeft,
                              top: houseTop,
                              width: houseW,
                              height: houseH,
                              child: IgnorePointer(
                                child: RepaintBoundary(
                                  child: FlameEnglishHouseWidget(
                                    currentDay: widget.neighbor.day,
                                    streak: widget.neighbor.streak,
                                    isDamaged: _isDefenderDamaged,
                                    houseId: widget.neighbor.id,
                                    paletteId: widget.neighbor.paletteId,
                                    showTestingControls: false,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // 3. Post-Attack Battle Damage (Billowing dark smoke columns & fiery embers)
                          if (!isPresident &&
                              (_isDefenderDamaged || _isTargetProtected))
                            _buildPostAttackDamageEffects(
                                houseLeft, houseTop, houseW, houseH),

                          // 3B. Emergency Cordon & VIP Presidential Escort Guard
                          if (!isPresident &&
                              (_isDefenderDamaged ||
                                  _isTargetProtected ||
                                  _isDefenderVip))
                            _buildPresidentialSecurityLayer(houseLeft, houseTop,
                                houseW, houseH, groundY, worldW),

                          // 3D. 🛡️ Active Iron Dome Interception Missile & Blast Effect
                          if (isPresident)
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _ironDomeController,
                                builder: (context, _) {
                                  if (_ironDomeController.value <= 0.0 ||
                                      _ironDomeController.value >= 1.0) {
                                    return const SizedBox.shrink();
                                  }
                                  return IgnorePointer(
                                    child: CustomPaint(
                                      painter: CitadelIronDomeInterceptPainter(
                                        prog: _ironDomeController.value,
                                        source: Offset(350, groundY - 95),
                                        target:
                                            Offset(worldW / 2, palaceTop + 60),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // 4. Avatar-Specific Weapon Discharge & Particle Strike Layer
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_beamController, _particleController]),
                              builder: (context, _) {
                                if (_beamController.value <= 0 &&
                                    _particleController.value <= 0) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelAvatarStrikePainter(
                                      beamProg: _beamController.value,
                                      particleProg: _particleController.value,
                                      attackerDay: widget.attackerDay,
                                      perk: VectorAvatarConfig
                                          .getAvatarPerkForDay(
                                              widget.attackerDay),
                                      groundBaseY: groundY,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 5. Victory Coin Shower & Magnetic Loot Attraction Layer
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _coinController,
                              builder: (context, _) {
                                if (_coinController.value <= 0.0 ||
                                    _coinController.value >= 1.0) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelCoinShowerPainter(
                                      progress: _coinController.value,
                                      groundBaseY: groundY,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 6. 🥋 Attacking Hero Avatar Sprint & Leap Sprite during battle
                          if (_isStriking)
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_heroChargeController, _coinController]),
                              builder: (context, _) {
                                final prog = _heroChargeController.value;
                                // Running up the stone path towards the citadel steps
                                final runY = ui.lerpDouble(
                                    groundY + 180.0,
                                    groundY - 190.0,
                                    (prog / 0.55).clamp(0.0, 1.0))!;
                                // Parabolic leap during weapon strike
                                final leapY = (prog > 0.50 && prog < 0.88)
                                    ? -math.sin(
                                            (prog - 0.50) / 0.38 * math.pi) *
                                        48.0
                                    : 0.0;
                                final heroY = runY + leapY;
                                final heroX = worldW / 2;

                                final perk =
                                    VectorAvatarConfig.getAvatarPerkForDay(
                                        widget.attackerDay);
                                final isRunning = prog < 0.50;
                                final isStrikingAtGate =
                                    prog >= 0.50 && prog < 0.88;
                                final isCollectingLoot =
                                    _coinController.value > 0.15;

                                return Positioned(
                                  left: heroX - 42,
                                  top: heroY - 42,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Floating weapon badge with glowing aura
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A)
                                              .withValues(alpha: 0.94),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isStrikingAtGate
                                                ? Colors.redAccent
                                                : const Color(0xFFFFD700),
                                            width: 1.3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isStrikingAtGate
                                                      ? Colors.redAccent
                                                      : Colors.amber)
                                                  .withValues(alpha: 0.75),
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(perk.combatWeaponIcon,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                            const SizedBox(width: 4),
                                            Text(
                                              perk.combatWeaponName,
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFFD700),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Attacking Avatar with Radiant Pulsing Aura & Running tilt
                                      Transform.rotate(
                                        angle: isRunning
                                            ? math.sin(prog * 36) * 0.12
                                            : (isStrikingAtGate ? -0.18 : 0.0),
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isStrikingAtGate
                                                        ? const Color(
                                                            0xFFEF4444)
                                                        : (isCollectingLoot
                                                            ? const Color(
                                                                0xFFFFD700)
                                                            : const Color(
                                                                0xFF38BDF8)))
                                                    .withValues(alpha: 0.75),
                                                blurRadius: 18,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: VectorAvatarWidget(
                                              config: VectorAvatarConfig
                                                  .getEvolutionAvatarForStage(
                                                      widget.attackerDay),
                                              size: 64,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Running dust puff animation under feet
                                      if (isRunning) ...[
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                width: 8,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: Colors.white38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2))),
                                            const SizedBox(width: 5),
                                            Container(
                                                width: 14,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                    color: Colors.white60,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3))),
                                            const SizedBox(width: 5),
                                            Container(
                                                width: 8,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: Colors.white38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2))),
                                          ],
                                        ),
                                      ],
                                      // Open Treasure Chest when collecting coins
                                      if (isCollectingLoot) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A)
                                                .withValues(alpha: 0.95),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: const Color(0xFFFFD700),
                                                width: 1.4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD700)
                                                    .withValues(alpha: 0.65),
                                                blurRadius: 12,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🪙',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+15 PS LOOTED!',
                                                style: GoogleFonts.outfit(
                                                  color:
                                                      const Color(0xFFFFD700),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 7. Attack strike visual impact overlay
                if (_isStriking) _buildStrikeOverlay(),

                // 8. Floating Top Capsule Header (Back button + 6h Day/Night Cycle + Profile + Info)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHeaderCapsule(
                      isNight: isNight, cycleLabel: cycleLabel),
                ),

                // 9. Dimmed backdrop behind Profile Drawer
                if (!_isQuestionSheetOpen &&
                    _profileDrawerController.value > 0.02)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _profileDrawerController.reverse(),
                      child: Container(
                        color: Colors.black.withValues(
                            alpha: 0.65 * _profileDrawerController.value),
                      ),
                    ),
                  ),

                // 10. Bottom Stacked Small Red "Attack" Button with Level & PS Pill (sitting right above peek bar)
                if (!_isQuestionSheetOpen)
                  Positioned(
                    bottom: collapsedH + 10.0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: (1.0 - _profileDrawerController.value * 2.5)
                          .clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: _profileDrawerController.value > 0.1,
                        child: _buildBottomAttackSection(),
                      ),
                    ),
                  ),

                // 11. Draggable & Tappable Profile Bottom Sheet Drawer
                if (!_isQuestionSheetOpen)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: drawerCurrentH,
                    child:
                        _buildProfileDrawer(drawerMaxH, collapsedH, bottomPad),
                  ),

                // 12. Full-Screen Interactive Game Challenge Stage (when attack is active)
                if (_isQuestionSheetOpen)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildQuestionSheet(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 💣 Battle Aftermath: Billowing dark combat smoke columns & fiery embers rising from damaged citadel
  Widget _buildPostAttackDamageEffects(
      double houseLeft, double houseTop, double houseW, double houseH) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        return Positioned(
          left: houseLeft - 40,
          top: houseTop - 90,
          width: houseW + 80,
          height: houseH + 90,
          child: IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Smoke plume 1: Left roof breach
                Positioned(
                  left: 70,
                  top: 30,
                  child:
                      _buildBillowingSmokeColumn(prog, phase: 0.0, width: 62),
                ),
                // Smoke plume 2: Center gate blast point
                Positioned(
                  left: (houseW + 80) / 2 - 25,
                  top: 110,
                  child:
                      _buildBillowingSmokeColumn(prog, phase: 0.35, width: 78),
                ),
                // Smoke plume 3: Right tower / roof breach
                Positioned(
                  right: 70,
                  top: 40,
                  child:
                      _buildBillowingSmokeColumn(prog, phase: 0.70, width: 58),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillowingSmokeColumn(double prog,
      {double phase = 0.0, double width = 60}) {
    final t = (prog + phase) % 1.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final puffProg = (t + (index * 0.25)) % 1.0;
        final size = 16.0 + (puffProg * width * 0.55);
        final opacity = (1.0 - puffProg) * 0.65;
        final driftX = math.sin((puffProg + phase) * 2 * math.pi) * 14.0;
        return Transform.translate(
          offset: Offset(driftX, -puffProg * 45.0),
          child: Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B).withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF0F172A).withValues(alpha: opacity * 0.5),
                  blurRadius: 10,
                ),
                if (index == 3)
                  BoxShadow(
                    color: const Color(0xFFFF9800)
                        .withValues(alpha: opacity * 0.5),
                    blurRadius: 14,
                  ),
              ],
            ),
            child: (index == 3)
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            const Color(0xFFFFB74D).withValues(alpha: opacity),
                      ),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  /// 🏛️ Grand Sovereign Presidential Palace Castle (Flame Living Estate Component)
  // ignore: unused_element
  Widget _buildPresidentialPalaceCastle(
    double left,
    double top,
    double width,
    double height,
    double groundY,
  ) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        final flamePulse = math.sin(prog * 10 * math.pi);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Majestic Imperial Golden Glow Halo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: 0.30 + (flamePulse * 0.08)),
                      blurRadius: 55,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.20),
                      blurRadius: 75,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Procedural 2D Vector Presidential Palace Castle (Flame Living Canvas Component)
            Positioned.fill(
              child: PresidentialPalaceCastleWidget(
                width: width,
                height: height,
                animProg: prog,
              ),
            ),

            // 3. Sovereign Citadel Title Crest Plaque
            Positioned(
              left: width * 0.28,
              right: width * 0.28,
              bottom: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      'SOVEREIGN CITADEL',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🛡️ Presidential Protection Layer: Police Officers, Army Guards, Emergency Strobes, Hazard Barricade & Warning Sign
  Widget _buildPresidentialSecurityLayer(double houseLeft, double houseTop,
      double houseW, double houseH, double groundY,
      [double worldW = 1800.0]) {
    if (widget.neighbor.isPresident) {
      return _buildPresidentialSupremeSecurityPerimeter(groundY, worldW);
    }
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        final isRedFlash = math.sin(prog * 10 * math.pi) > 0;

        return Positioned(
          left: 900.0 - 240.0,
          top: houseTop + houseH - 95.0,
          width: 480.0,
          height: 190.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Flashing Red and Blue Police Emergency Beacon Halos on Ground (Only during active post-attack Police Protection)
              if (_isTargetProtected) ...[
                Positioned(
                  left: 35,
                  top: 30,
                  child: Container(
                    width: 90,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isRedFlash
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.30),
                      boxShadow: [
                        BoxShadow(
                          color: (isRedFlash
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF3B82F6))
                              .withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 35,
                  top: 30,
                  child: Container(
                    width: 90,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isRedFlash
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.30),
                      boxShadow: [
                        BoxShadow(
                          color: (isRedFlash
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFEF4444))
                              .withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 2. Two Police Officers Standing Guard (Left & Right of River/Entrance)
              Positioned(
                left: 36,
                top: _isDefenderVip ? 6 : 12,
                child: _buildPoliceOfficerSprite(
                    isLeft: true, hasEscortBoard: _isDefenderVip),
              ),
              Positioned(
                right: 36,
                top: _isDefenderVip ? 6 : 12,
                child: _buildPoliceOfficerSprite(
                    isLeft: false, hasEscortBoard: _isDefenderVip),
              ),

              // 3. Hazard Barricade & Police Protection Notice (Only during active post-attack Police Protection)
              if (_isTargetProtected)
                Positioned(
                  left: 80,
                  right: 80,
                  bottom: 6,
                  child: GestureDetector(
                    onTap: _showPresidentialProtectionInfoDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (isRedFlash
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF3B82F6))
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Striped Hazard Caution Bar
                        Container(
                          height: 7,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👮‍♂️', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'POLICE PROTECTION',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RESTRICTED SECURITY ZONE • ⏱️ ${_formatProtectionCountdown(_protectionSecondsRemaining)}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Guarded by Police & Army • Tap for Details',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 👮‍♂️ Detailed Police Officer Sprite
  Widget _buildPoliceOfficerSprite(
      {required bool isLeft, bool hasEscortBoard = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasEscortBoard) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 8)),
                const SizedBox(width: 2),
                Text(
                  'ESCORT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 4,
            color: const Color(0xFFFFD700),
          ),
        ],
        // Peaked Police Cap with Gold Badge
        Container(
          width: 22,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Head / Face
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDFBA),
            shape: BoxShape.circle,
          ),
        ),
        // Torso with High-Vis Safety Vest & Radio
        Container(
          width: 26,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // High-vis yellow safety vest
              Center(
                child: Container(
                  width: 16,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Text(
                      'POLICE',
                      style: TextStyle(
                        fontSize: 4.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Shoulder Radio / Badge
              Positioned(
                right: isLeft ? 1 : null,
                left: isLeft ? null : 1,
                top: 2,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Dark Pants
        Container(
          width: 18,
          height: 20,
          color: const Color(0xFF0F172A),
        ),
        // Polished Black Boots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 6, color: Colors.black),
            const SizedBox(width: 2),
            Container(width: 8, height: 6, color: Colors.black),
          ],
        ),
      ],
    );
  }

  /// 🪖 Detailed Presidential Defense Soldier Sprite
  Widget _buildMilitarySoldierSprite({required bool hasShield}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasShield)
          Container(
            width: 18,
            height: 48,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🛡️', style: TextStyle(fontSize: 10)),
                Text(
                  'GUARD',
                  style: TextStyle(
                    fontSize: 4,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Black Tactical Beret with Gold Badge
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF022C22),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Head
            Container(
              width: 14,
              height: 13,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDFBA),
                shape: BoxShape.circle,
              ),
            ),
            // Tactical Camo Armor Torso
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.shield, size: 12, color: Colors.white70),
              ),
            ),
            // Camo Combat Trousers
            Container(
              width: 18,
              height: 20,
              color: const Color(0xFF022C22),
            ),
            // Combat Boots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 6, color: const Color(0xFF1E293B)),
                const SizedBox(width: 2),
                Container(width: 8, height: 6, color: const Color(0xFF1E293B)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showPresidentialProtectionInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('👮‍♂️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'POLICE PROTECTION',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'PERIMETER SECURED BY POLICE FORCES',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Following a recent combat raid, this house has been placed under Police Protection to secure the resident and allow defense rebuilding.',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Active Protection: ${_formatProtectionCountdown(_protectionSecondsRemaining)} remaining',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              PocketLanguageService.localize(
                en: 'Raids are strictly prohibited during the 6-hour police protection period. Officers remain on duty until the countdown concludes.',
                ml: '6 മണിക്കൂർ പോലീസ് സുരക്ഷാ കാലയളവിൽ അറ്റാക്ക് ചെയ്യുന്നത് കർശനമായി നിരോധിച്ചിരിക്കുന്നു. സമയം തീരുന്നത് വരെ വീട് ലോക്ക് ചെയ്തിരിക്കും.',
                ta: '6 மணி நேர காவல் பாதுகாப்பு காலத்தில் தாக்குதல்கள் முற்றிலும் தடைசெய்யப்பட்டுள்ளன.',
                hi: '6 घंटे की पुलिस सुरक्षा अवधि के दौरान हमलों पर कड़ा प्रतिबंध है।',
              ),
              style: const TextStyle(color: Colors.white60, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Acknowledge Decree 📜'),
          ),
        ],
      ),
    );
  }

  /// 🛡️ Supreme Presidential Security Perimeter: Limousine, Honor Guards, Black Cat Commandos & Warning Cordon
  Widget _buildPresidentialSupremeSecurityPerimeter(double groundY,
      [double worldW = 1800.0]) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        final isRedFlash = math.sin(prog * 10 * math.pi) > 0;
        final vocalStep = (prog * 4).floor() % 4;

        return Positioned(
          left: (worldW - 1000.0) / 2,
          top: groundY - 145.0,
          width: 1000.0,
          height: 290.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Alternating Red & Blue Strobe Light Halos on Estate Courtyard
              Positioned(
                left: 120,
                top: 75,
                child: Container(
                  width: 90,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isRedFlash
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF3B82F6))
                        .withValues(alpha: 0.28),
                    boxShadow: [
                      BoxShadow(
                        color: (isRedFlash
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6))
                            .withValues(alpha: 0.40),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 120,
                top: 75,
                child: Container(
                  width: 90,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isRedFlash
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.28),
                    boxShadow: [
                      BoxShadow(
                        color: (isRedFlash
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.40),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // 2A. Official Police Interceptor Patrol Car with Flashing Blue/Red Lightbar
              Positioned(
                left: 80,
                top: 78,
                child: PoliceInterceptorCarWidget(animProg: prog),
              ),

              // 2B. The President's Official State Car (Armored Limousine) Parked in Driveway
              Positioned(
                right: 90,
                top: 78,
                child: GestureDetector(
                  onTap: _showPresidentialSecurityDecreeDialog,
                  child: _buildPresidentialOfficialLimousine(
                      prog: prog, isRedFlash: isRedFlash),
                ),
              ),

              // 3. Military Army Soldiers ("പട്ടാളക്കാർ") on Watch
              Positioned(
                left: 210,
                top: 48,
                child: ArmySoldierGuardWidget(
                  isLeft: false,
                  vocalText: vocalStep == 0
                      ? "ARMY UNIT 1: BARRICADE SECURE 🪖"
                      : null,
                ),
              ),
              Positioned(
                right: 220,
                top: 48,
                child: ArmySoldierGuardWidget(
                  isLeft: true,
                  vocalText:
                      vocalStep == 2 ? "DEFCON 1 MILITARY PROTOCOL 🛑" : null,
                ),
              ),

              // 4. Official Police Officers ("പോലീസുകാർ") Stationed at Courtyard
              Positioned(
                left: 310,
                top: 54,
                child: PoliceOfficerGuardWidget(
                  isLeft: false,
                  vocalText: vocalStep == 1
                      ? "POCKET POLICE: VIP CORRIDOR SEALED 🚔"
                      : null,
                ),
              ),
              Positioned(
                right: 320,
                top: 54,
                child: PoliceOfficerGuardWidget(
                  isLeft: true,
                  vocalText: vocalStep == 3
                      ? "POLICE INSPECTOR: CITIZENS STAY BACK 🛑"
                      : null,
                ),
              ),

              // 5. Ceremonial Armed Honor Guards Flanking Entrance
              Positioned(
                left: 410,
                top: 46,
                child: _buildArmedRifleHonorGuard(
                  isLeft: true,
                  vocalText:
                      vocalStep == 1 ? "SOVEREIGN CITADEL ON WATCH! 🫡" : null,
                ),
              ),
              Positioned(
                right: 410,
                top: 46,
                child: _buildArmedRifleHonorGuard(
                  isLeft: false,
                  vocalText:
                      vocalStep == 3 ? "HONOR GUARD POST SECURE! 🏛️" : null,
                ),
              ),

              // 6. Black Cat Commandos in Stealth Black Gear with Radio Chatter
              Positioned(
                left: 20,
                top: 92,
                child: _buildBlackCatCommando(
                  codeName: "CAT-1",
                  vocalText:
                      vocalStep == 0 ? "CAT-1: PERIMETER GREEN 📻" : null,
                ),
              ),
              Positioned(
                right: 20,
                top: 92,
                child: _buildBlackCatCommando(
                  codeName: "CAT-2",
                  vocalText: vocalStep == 2 ? "RADAR: AIRSPACE CLEAR 🎯" : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🚗 Official Presidential Armored Limousine with Fluttering Flags
  Widget _buildPresidentialOfficialLimousine(
      {required double prog, required bool isRedFlash}) {
    final flagFlutter = math.sin(prog * 8 * math.pi) * 2.0;

    return SizedBox(
      width: 154,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Headlight beam reflection on ground
          Positioned(
            left: -30,
            top: 28,
            child: Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFEF08A).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Ground shadow
          Positioned(
            left: 8,
            right: 8,
            bottom: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Main Armored Car Body
          Positioned(
            left: 0,
            top: 14,
            width: 154,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF090D16),
                    Color(0xFF020617)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(7),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(color: const Color(0xFF64748B), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Chrome side molding
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 9,
                    child: Container(
                      height: 1.5,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),

                  // Presidential Gold Crest on Rear Door Panel
                  Positioned(
                    right: 38,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '👑',
                          style: TextStyle(fontSize: 4),
                        ),
                      ),
                    ),
                  ),

                  // Concealed Red/Blue Emergency Grille Strobes
                  Positioned(
                    left: 2,
                    top: 11,
                    child: Container(
                      width: 5,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isRedFlash
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(1),
                        boxShadow: [
                          BoxShadow(
                            color: isRedFlash
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // License plate
                  Positioned(
                    left: 1,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: const Text(
                        'PRES 1',
                        style: TextStyle(
                            fontSize: 3.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tinted Bulletproof Windows Cabin Roof
          Positioned(
            left: 28,
            top: 2,
            width: 96,
            height: 15,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0F1D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  // Windshield
                  Container(
                    width: 18,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // Front passenger window
                  Container(
                    width: 20,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // VIP rear executive window (Extra dark)
                  Container(
                    width: 44,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: const Color(0xFF334155), width: 0.5),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Wheels
          Positioned(
            left: 20,
            bottom: 2,
            child: _buildLimousineWheel(),
          ),
          Positioned(
            right: 22,
            bottom: 2,
            child: _buildLimousineWheel(),
          ),

          // Dual Fluttering Presidential Fender Flags
          Positioned(
            left: 6,
            top: 2 + flagFlutter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 1.5, height: 14, color: const Color(0xFFFFD700)),
                Container(
                  width: 10,
                  height: 7,
                  color: const Color(0xFFDC2626),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 4)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 14,
            top: 2 - flagFlutter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 1.5, height: 14, color: const Color(0xFFFFD700)),
                Container(
                  width: 10,
                  height: 7,
                  color: const Color(0xFF1E3A8A),
                  child: const Center(
                    child: Text('🏛️', style: TextStyle(fontSize: 4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimousineWheel() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF475569), width: 2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFCBD5E1),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// 💂‍♂️ Armed Rifle Honor Guard Standing Post with Bayonet & Speech Bubble
  Widget _buildArmedRifleHonorGuard({required bool isLeft, String? vocalText}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vocal dialogue bubble if active
        if (vocalText != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              vocalText,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Officer Head with Peaked Navy Cap
        Container(
          width: 22,
          height: 9,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Face
        Container(
          width: 14,
          height: 13,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDFBA),
            shape: BoxShape.circle,
          ),
        ),
        // Navy Uniform Torso + Gold Epaulets + Upright Rifle
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left shoulder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Gold chest buttons
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle)),
                        const SizedBox(height: 2),
                        Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                  // Gold shoulder braid
                  Positioned(
                    left: 2,
                    top: 1,
                    child: Container(
                        width: 6, height: 2.5, color: const Color(0xFFFFD700)),
                  ),
                  Positioned(
                    right: 2,
                    top: 1,
                    child: Container(
                        width: 6, height: 2.5, color: const Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            // Upright Rifle held at attention
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bayonet tip
                Container(
                    width: 1.5, height: 8, color: const Color(0xFFCBD5E1)),
                // Rifle barrel
                Container(width: 3, height: 22, color: Colors.black87),
                // Rifle wooden stock
                Container(width: 4, height: 10, color: const Color(0xFF78350F)),
              ],
            ),
          ],
        ),
        // Navy Trousers
        Container(width: 18, height: 18, color: const Color(0xFF0F172A)),
        // Polished Black Dress Shoes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 5, color: Colors.black),
            const SizedBox(width: 2),
            Container(width: 8, height: 5, color: Colors.black),
          ],
        ),
      ],
    );
  }

  /// 🥷 Black Cat Commando in Tactical Stealth Black Gear & NVG Goggles
  Widget _buildBlackCatCommando({required String codeName, String? vocalText}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tactical Radio Chatter Bubble
        if (vocalText != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              vocalText,
              style: GoogleFonts.sourceCodePro(
                color: const Color(0xFF4ADE80),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Tactical Ballistic Helmet with Glowing Green NVG Goggles
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF090D16),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF334155), width: 0.8),
              ),
            ),
            // Glowing Quad-Tube Night Vision Goggles
            Positioned(
              left: 4,
              top: 5,
              child: Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.9),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 1.5),
                  Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.9),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 1.5),
                  Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.9),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Balaclava Mask Face
        Container(
          width: 14,
          height: 10,
          color: const Color(0xFF0F172A),
        ),

        // Tactical Kevlar Vest & Assault Carbine in ready stance
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF1E293B), width: 1),
              ),
              child: Center(
                child: Text(
                  codeName,
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 4.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            // Tactical assault carbine
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 3, color: const Color(0xFF334155)),
                Container(width: 5, height: 4, color: Colors.black),
              ],
            ),
          ],
        ),

        // Black Tactical Cargo Pants
        Container(width: 18, height: 18, color: const Color(0xFF020617)),
        // Tactical Combat Boots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 6, color: Colors.black),
            const SizedBox(width: 2),
            Container(width: 8, height: 6, color: Colors.black),
          ],
        ),
      ],
    );
  }

  /// 🔒 Level 90 Gate Lock Dialog: Displayed when attacking before Level 90
  void _showPresidentialLevelLockDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFFFD700), width: 1.2),
                            ),
                            child: const Text('🔒',
                                style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'President Challenge Locked',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pass Levels 1–19 to Unlock',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Notice Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🏛️',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Imperial Clearance Protocol',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete and pass Levels 1–19 to unlock the President Challenge. Once you have passed Level 19, you can challenge the President.',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Your Mastery Progress',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level $_attackerDay / 19',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_attackerDay / 19.0).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD700)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _attackerDay >= 20
                            ? 'Ready to challenge the President!'
                            : '${(20 - _attackerDay).clamp(1, 19)} level(s) remaining to unlock.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Button
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Understood, Sir! 🫡',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPresidentialSecurityDecreeDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🏛️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'IMPERIAL CITADEL DIRECTIVE',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SOVEREIGN ESTATE UNDER DEFCON 1 READINESS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The Sovereign Citadel of The President is safeguarded by the Black Cat Special Operations Group and Royal Honor Guards.\n\n• Security Clearance: Level 90+ Required\n• Gauntlet Trials: 200 English Mastery Challenges\n• Sovereign Boss Health: 10,000 HP',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFCBD5E1), fontSize: 12.5, height: 1.45),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Acknowledge Sovereign Orders 🫡',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 🛡️ Iron Dome Defense Matrix & Telemetry Modal
  // ignore: unused_element
  void _showPresidentialIronDomeModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0369A1).withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF38BDF8), width: 1.2),
                    ),
                    child: const Text('🛡️', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IRON DOME DEFENSE MATRIX',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Sovereign Citadel Active Air & Ground Defense System',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Threat Level & Radar HUD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Row(
                  children: [
                    // Radar Graphic Indicator
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF031525),
                        border: Border.all(
                            color: const Color(0xFF22C55E), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.radar,
                              color: Color(0xFF4ADE80), size: 28),
                          Positioned(
                            top: 8,
                            right: 12,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFEF4444),
                                      width: 1.0),
                                ),
                                child: const Text(
                                  'DEFCON 1 ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFFF87171),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'STATUS: ONLINE',
                                style: GoogleFonts.sourceCodePro(
                                  color: const Color(0xFF4ADE80),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EL/M-2084 Phased Array 360° Radar tracking 4 sky corridors across 3,600m perimeter territory.',
                            style: GoogleFonts.outfit(
                                color: const Color(0xFFCBD5E1), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Defense Telemetry Grid (6 Metrics)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.3,
                children: [
                  _buildDefenseMetricCard('🚀 Tamir Interceptors',
                      '20 / 20 READY', const Color(0xFF4ADE80)),
                  _buildDefenseMetricCard('⚡ Intercept Rate', '99.8% ACCURACY',
                      const Color(0xFF38BDF8)),
                  _buildDefenseMetricCard('🧱 Perimeter Blast Walls',
                      '3,600m HARDENED', const Color(0xFFFFD700)),
                  _buildDefenseMetricCard('🚧 Police Barricades',
                      '4 CHECKPOINTS', const Color(0xFFF97316)),
                  _buildDefenseMetricCard('🚔 SWAT & K9 Forces',
                      '12 UNITS ARMED', const Color(0xFFA78BFA)),
                  _buildDefenseMetricCard('👑 Sovereign Protocol',
                      'LVL 90 REQUIRED', const Color(0xFFFFD700)),
                ],
              ),

              const SizedBox(height: 18),

              // Test Fire Interceptor Action Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _testFireIronDome();
                      },
                      icon: const Text('🚀', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'Test Fire Interceptor',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefenseMetricCard(String title, String val, Color valColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 10.5,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: GoogleFonts.sourceCodePro(
                color: valColor, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _loadDefenderGlobalRank() {
    final isRobot = widget.neighbor.isPocketRobo ||
        PocketRobotService.isRobotId(widget.neighbor.id) ||
        !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.neighbor.id);
    if (!isRobot && !widget.neighbor.isPresident) {
      PocketRankingService.fetchUserGlobalRank(
        widget.neighbor.id,
        _defenderScore,
        widget.isKidMode,
      ).then((rank) {
        if (mounted && rank > 0) {
          setState(() {
            _fetchedDefenderGlobalRank = rank;
          });
        }
      }).catchError((_) {});
    }
  }

  /// 🏅 Get cached Global Rank of the defender (Audio Directive)
  int? get _defenderGlobalRank {
    final isRobot = widget.neighbor.isPocketRobo ||
        PocketRobotService.isRobotId(widget.neighbor.id) ||
        !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.neighbor.id);
    if (isRobot) {
      return widget.neighbor.day.clamp(1, 90);
    }
    if (widget.neighbor.isPresident) return 1;
    if (_fetchedDefenderGlobalRank != null && _fetchedDefenderGlobalRank! > 0) {
      return _fetchedDefenderGlobalRank;
    }
    return PocketRankingService.getCachedGlobalRank(widget.neighbor.id);
  }

  /// 🏅 Sleek Global Rank Badge Widget for Citadel Attack page
  Widget _buildGlobalRankBadge({double fontSize = 9.5}) {
    final isRobot = (widget.neighbor.isPocketRobo ||
            PocketRobotService.isRobotId(widget.neighbor.id)) &&
        !widget.neighbor.isPresident;
    final rank = _defenderGlobalRank;

    final rankText = isRobot
        ? '🤖 Robot Rank #${rank ?? widget.neighbor.day.clamp(1, 90)}'
        : (widget.neighbor.isPresident
            ? '👑 Global Rank #1'
            : (rank != null && rank > 0
                ? '🏆 Global Rank #$rank'
                : '🏆 Global Challenger'));

    final isTop3 = ((rank ?? 999) <= 3) || widget.neighbor.isPresident;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isTop3
            ? const Color(0xFFFFD700).withValues(alpha: 0.22)
            : (isRobot
                ? const Color(0xFF10B981).withValues(alpha: 0.20)
                : const Color(0xFF0284C7).withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTop3
              ? const Color(0xFFFFD700).withValues(alpha: 0.7)
              : (isRobot
                  ? const Color(0xFF34D399).withValues(alpha: 0.6)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.6)),
          width: 0.8,
        ),
      ),
      child: Text(
        rankText,
        style: GoogleFonts.outfit(
          color: isTop3
              ? const Color(0xFFFFD700)
              : (isRobot ? const Color(0xFFA7F3D0) : const Color(0xFFBAE6FD)),
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// 📸 Open High-Aesthetic Citadel Story Share / Preview Page
  void _openCitadelStoryShare(int effectiveDay, int psValue) {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final isNightByDefault = (now.hour == 3 && now.minute < 30);
    final isNight = _manualNightOverride ?? isNightByDefault;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketCitadelStorySharePage(
          neighbor: widget.neighbor,
          level: effectiveDay,
          pocketScore: psValue,
          globalRank: _defenderGlobalRank,
          isNight: isNight,
        ),
      ),
    );
  }

  Future<void> _testFireIronDome() async {
    if (_ironDomeController.isAnimating) return;
    setState(() => _isIronDomeFiring = true);
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'IRON DOME INTERCEPTOR LAUNCHED!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Tamir-1 missile tracking aerial threat. Intercept successful at 5,000m altitude!',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    _ironDomeController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isIronDomeFiring = false);
    }
  }

  /// 🎒 Kid Hero Drawer Content (Homestead House, 180x220 PopArt Card, Adventure Stats)
  Widget _buildKidHeroDrawerContent() {
    final day = widget.neighbor.day;
    final house = PocketKidsService.getHouseForDay(day);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Kids Hero Identity Card with Homestead House & 180x220 PopArt Collectible Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Flame Homestead House Showcase
                PocketAvatarHouseWidget(
                  day: day,
                  width: 260,
                  height: 180,
                  lightsOn: true,
                ),
                const SizedBox(height: 12),

                // House Tier & Title Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: house.themeColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: house.themeColor, width: 1.2),
                  ),
                  child: Text(
                    '${house.title} ${house.emoji} • Tier ${house.tier}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kid Avatar & Identity
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F172A),
                        border: Border.all(
                            color: const Color(0xFFFFD700), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.40),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: VectorAvatarWidget(
                          config:
                              PocketKidsAvatarSystem.getAvatarConfigForDay(day),
                          size: 52,
                          showAura: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.neighbor.name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'KID HERO 🎒',
                                  style: GoogleFonts.outfit(
                                    color: Colors.black,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.neighbor.statusMessage.isNotEmpty
                                ? widget.neighbor.statusMessage
                                : 'Exploring Day $day on the 100-Day Mountain Trail! 🏔️',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Kid Hero Adventure Stats Row
          Row(
            children: [
              _buildKidStatCard(
                  '🎯', 'Trail Level', 'Day $day', const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildKidStatCard('⭐', 'Star Coins', '${day * 40} PTS',
                  const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildKidStatCard('🏰', 'House Tier', 'Tier ${house.tier}',
                  const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 14),

          // 🛡️ Kid's Fortress Defense Cards (Instagram-Style 3-Column Grid)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🛡️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'DEFENSE CARDS',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF10B981), width: 0.8),
                      ),
                      child: Text(
                        '$day Shields Active',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF34D399),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'These collected cards defend ${widget.neighbor.name}\'s house with Sentence Builders, Spelling Bees, and Spoken English challenges!',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 12),

                // 3-Column Instagram-Style Grid for defender's cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: day.clamp(1, 15),
                  itemBuilder: (context, idx) {
                    final cardDay = idx + 1;
                    final isMaleKid = widget.neighbor.isMe
                        ? (PocketKidsService.kidGender == 'male')
                        : (PocketKidsService.kidGender == 'male');
                    final card = PopArtCardHelper.getCardForDay(cardDay,
                        isMale: isMaleKid);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final cardIdx =
                            kPopArt180Cards.indexWhere((c) => c.id == card.id);
                        PopArtAvatarCardsViewerPage.open(context,
                            initialIndex: cardIdx >= 0 ? cardIdx : 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.7),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.5),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomPaint(
                                painter: PopArtCardCustomPainter(data: card),
                              ),
                              Positioned(
                                top: 3,
                                left: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'D$cardDay',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Action Buttons: High-Five & Add Mate
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🖐️ High-five sent to ${widget.neighbor.name}!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Text('🖐️', style: TextStyle(fontSize: 16)),
                  label: Text('HIGH-FIVE',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    PocketKidsService.sendMateRequest(widget.neighbor.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🤝 Mate request sent to ${widget.neighbor.name}!'),
                        backgroundColor: const Color(0xFF0284C7),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Text('🤝', style: TextStyle(fontSize: 16)),
                  label: Text('ADD MATE',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKidStatCard(
      String emoji, String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              val,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📜 Sovereign Drawer Content for The President (Decrees, Hotline, Mateship, Boss Stats)
  Widget _buildPresidentialDrawerContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PocketPresidentService.getActivePresidentVibes(),
      builder: (context, snapshot) {
        final announcements = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Imperial Identity Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const PresidentAvatarWidget(size: 60, showGlow: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'The President',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFD700),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 12, color: Colors.black),
                              ),
                            ],
                          ),
                          Text(
                            'Supreme Sovereign of Pocket World',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFD700),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '👑 Level 90 Supreme Boss • 10,000 HP',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Action Buttons Row (Chat & Appeal)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 16),
                      label: Text('Chat',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WhatsAppGroupChat(
                              groupId:
                                  'p:${PocketPresidentService.presidentId}',
                              groupName: PocketPresidentService.presidentName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.mail_outline_rounded, size: 16),
                      label: Text('Petition Desk',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      onPressed: _showPresidentialPetitionDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Official Decrees & Announcements
              Row(
                children: [
                  const Text('📜', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Imperial Decrees & Directives',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (announcements.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'No active imperial decrees at this hour. The realm is peaceful.',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ),
                )
              else
                ...announcements.map((dec) {
                  final title = dec['title']?.toString() ?? 'Imperial Decree';
                  final body = dec['body']?.toString() ??
                      dec['message']?.toString() ??
                      '';
                  final mediaUrl = dec['media_url']?.toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 12),
                        ),
                        if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              mediaUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showPresidentialPetitionDialog() {
    final messageController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomInset + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PresidentAvatarWidget(size: 36, showGlow: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Petition to The President',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Direct hotline to the Supreme Citadel Desk',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(bContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText:
                        'State your petition or inquiry for The President...',
                    hintStyle:
                        GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD700), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final text = messageController.text.trim();
                            if (text.isEmpty) return;
                            setModalState(() => isSubmitting = true);
                            final uid =
                                SupaFlow.client.auth.currentUser?.id ?? 'guest';
                            await PocketPresidentService
                                .sendUserMessageToPresident(
                              userId: uid,
                              messageText: text,
                            );
                            if (context.mounted) {
                              Navigator.pop(bContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '🏛️ Petition delivered to The President!'),
                                  backgroundColor: Color(0xFF1E3A8A),
                                ),
                              );
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : Text('Send Petition 📜',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🌟 Top Floating Header: Minimal circular icon buttons (Back, Perspective Toggle, Day/Night Toggle, Profile, Info)
  Widget _buildTopHeaderCapsule(
      {bool isNight = false, String cycleLabel = ''}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Minimal Back button
            InkWell(
              onTap: () => Navigator.pop(context, _raidStep == 3),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
            ),

            // 👤 Username Dropdown Header for Logged-In User Profile, or 🪐 Cosmos Address Chip for other defenders
            if (widget.neighbor.isMe || widget.isDefenseMode)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    PocketSavedAccountService.showLoginInfoBottomSheet(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.20),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            (widget.neighbor.name.isNotEmpty &&
                                    widget.neighbor.name !=
                                        'Citadel Defender' &&
                                    widget.neighbor.name != 'Pocket Learner')
                                ? widget.neighbor.name
                                : (SupaFlow.client.auth.currentUser?.email
                                        ?.split('@')
                                        .first ??
                                    'My Profile'),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Color(0xFFFFD700),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 🪐 Minimal Cosmos Planetary Colony Address Chip
              Flexible(
                child: GestureDetector(
                  onTap: () => _showDefenderCosmosAddressSheet(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getPlanetEmoji(widget.neighbor.effectivePlanetCode),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${_getCleanPlanetName(widget.neighbor.effectivePlanetCode, widget.neighbor.effectivePlanetName)} • #${widget.neighbor.effectivePlotNumber}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.info_outline_rounded,
                            size: 11, color: Color(0xFF38BDF8)),
                      ],
                    ),
                  ),
                ),
              ),

            // Right Minimal Icon Button Group: No text to break/overflow on small screens!
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 🔭 / 🏰 Perspective Switcher Minimal Icon Button (President World)
                if (widget.neighbor.isPresident) ...[
                  InkWell(
                    onTap: _togglePerspective,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF4F46E5)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFD700), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4F46E5).withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isVantageView ? '🏰' : '🔭',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                // 2. ☀️ / 🌙 Day & Night Theme Toggle Minimal Icon Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _manualNightOverride = !isNight;
                    });
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isNight
                            ? const Color(0xFFFDE047).withValues(alpha: 0.7)
                            : const Color(0xFF38BDF8).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isNight
                                  ? const Color(0xFFFDE047)
                                  : const Color(0xFF38BDF8))
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isNight
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        color: isNight
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF38BDF8),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // 🔊 Music & Audio Speaker Toggle Button (User Audio Directive)
                ValueListenableBuilder<bool>(
                  valueListenable:
                      PocketGameAudioService.instance.isMutedNotifier,
                  builder: (context, isMuted, _) {
                    return InkWell(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        await PocketGameAudioService.instance.toggleMute();
                        if (mounted) setState(() {});
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isMuted
                                ? Colors.white30
                                : const Color(0xFFFFD700)
                                    .withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            if (!isMuted)
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: isMuted
                                ? Colors.white38
                                : const Color(0xFFFFD700),
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),

                // 👤 Defender Profile Icon Button
                InkWell(
                  onTap: _openDefenderProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF8B5CF6), width: 1.2),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded,
                          color: Color(0xFFA78BFA), size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // 🗺️ Citizen Island Plot Map Button (Direct jump to their home island plot)
                Tooltip(
                  message: "View Citizen's Island Plot 🗺️",
                  child: InkWell(
                    onTap: _navigateToDefenderPlotOnIsland,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF38BDF8), width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(Icons.map_rounded,
                            color: Color(0xFF38BDF8), size: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // 🛡️ Settings Button for own profile, OR Safety & Options Menu Button for other defenders
                if (widget.neighbor.isMe || widget.isDefenseMode)
                  Tooltip(
                    message: 'Settings ⚙️',
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.settings_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: 'Citadel Options',
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.70),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.more_vert_rounded,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onSelected: (val) {
                      if (val == 'citadel_stats') {
                        _showCitadelStatsSheet();
                      } else if (val == 'view_plot') {
                        _navigateToDefenderPlotOnIsland();
                      } else if (val == 'share_vibes') {
                        _shareCitadelToVibes();
                      } else if (val == 'report_citadel') {
                        _showCitadelReportOptions();
                      } else if (val == 'block_defender') {
                        _showBlockDefenderDialog();
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'citadel_stats',
                        child: Row(
                          children: [
                            Icon(Icons.shield_outlined,
                                color: Color(0xFFFDE047), size: 18),
                            SizedBox(width: 8),
                            Text('Citadel Info & Stats 🏰',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view_plot',
                        child: Row(
                          children: [
                            Icon(Icons.map_rounded,
                                color: Color(0xFF38BDF8), size: 18),
                            SizedBox(width: 8),
                            Text('View Island Plot 🏝️',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share_vibes',
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: Color(0xFFEC4899), size: 18),
                            SizedBox(width: 8),
                            Text('Share to Vibes',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report_citadel',
                        child: Row(
                          children: [
                            Icon(Icons.flag_rounded,
                                color: Colors.orangeAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Report Citadel / User',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block_defender',
                        child: Row(
                          children: [
                            Icon(Icons.block_rounded,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Block Defender',
                                style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanetEmoji(String code) {
    switch (code) {
      case 'EP':
        return '🌍';
      case 'MAR':
        return '🔴';
      case 'JUP':
        return '🪐';
      case 'SAT':
        return '🪐';
      case 'LUN':
        return '🌕';
      case 'EUR':
        return '🧊';
      case 'VEN':
        return '☀️';
      case 'TTN':
        return '🪐';
      case 'PLT':
        return '🌌';
      case 'NEP':
        return '🌊';
      default:
        return '🪐';
    }
  }

  String _getCleanPlanetName(String? code, String fullName) {
    switch (code?.toUpperCase()) {
      case 'EP':
        return 'Earth';
      case 'MAR':
        return 'Mars';
      case 'JUP':
        return 'Jupiter';
      case 'SAT':
        return 'Saturn';
      case 'LUN':
        return 'Moon';
      case 'EUR':
        return 'Europa';
      case 'VEN':
        return 'Venus';
      case 'TTN':
        return 'Titan';
      case 'PLT':
        return 'Pluto';
      case 'NEP':
        return 'Neptune';
      default:
        final lower = fullName.toLowerCase();
        if (lower.contains('moon')) return 'Moon';
        if (lower.contains('earth')) return 'Earth';
        if (lower.contains('mars')) return 'Mars';
        if (lower.contains('jupiter')) return 'Jupiter';
        if (lower.contains('saturn')) return 'Saturn';
        if (lower.contains('venus')) return 'Venus';
        if (lower.contains('europa')) return 'Europa';
        if (lower.contains('titan')) return 'Titan';
        if (lower.contains('neptune')) return 'Neptune';
        if (lower.contains('pluto')) return 'Pluto';
        String clean = fullName.replaceAll(RegExp(r'[^\w\s]'), '').trim();
        clean =
            clean.replaceFirst(RegExp(r'^The\s+', caseSensitive: false), '');
        return clean.split(' ').first;
    }
  }

  void _showDefenderCosmosAddressSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final n = widget.neighbor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF38BDF8), width: 2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF38BDF8), width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        _getPlanetEmoji(n.effectivePlanetCode),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${n.name}\'s Cosmos Residence',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          n.isPocketRobo
                              ? '🤖 Pocket Robot Citizen • Day ${n.day}'
                              : (n.isPresident
                                  ? '👑 Sovereign President of Pocket World'
                                  : '🏡 Verified Cosmos Citizen'),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF38BDF8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildAddressRow(
                        '🪐 Planet',
                        _getCleanPlanetName(
                            n.effectivePlanetCode, n.effectivePlanetName)),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAddressRow('🏝️ Island', n.effectiveIslandName),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAddressRow('🛣️ Street', n.effectiveStreetName),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAddressRow(
                        '📍 Plot Number', 'Plot #${n.effectivePlotNumber}'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAddressRow(
                        '📮 Born Address PIN', n.effectiveCosmosPin,
                        isHighlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: n.effectiveCosmosPin));
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Copied PIN ${n.effectiveCosmosPin} to clipboard!'),
                        backgroundColor: const Color(0xFF0284C7),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded,
                      size: 16, color: Color(0xFF38BDF8)),
                  label: Text('Copy Cosmos Address PIN',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToDefenderPlotOnIsland();
                  },
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: Text('View Island Plot On Map 🏝️',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToDefenderPlotOnIsland();
                  },
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: Text('View Island Plot On Map 🏝️',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? const Color(0xFF38BDF8) : Colors.white,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  /// 💥 Attack Strike Visual Impact Overlay
  Widget _buildStrikeOverlay() {
    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);
    return Positioned(
      top: 88,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(perk.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${perk.combatWeaponName.toUpperCase()} STRIKE! 💥',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '+15 PS LOOTED! • CITADEL BREACHED',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚔️ Minimal Unified Rectangular Attack Pod: Level + PS header row directly joined with red Attack button
  Widget _buildBottomAttackSection() {
    final effectiveDay = _effectiveDefenderLevel;
    final psValue = _defenderScore > 0
        ? _defenderScore
        : PocketScoreLevelEngine.getRequiredScoreForLevel(effectiveDay);
    final int defRank = _defenderGlobalRank ?? 0;
    final rankTheme = PocketTopRankTheme.getThemeForRank(defRank);
    final isRobot = widget.neighbor.isPocketRobo ||
        PocketRobotService.isRobotId(widget.neighbor.id);
    final bool isProtectedActive = _isTargetProtected ||
        ((_isDefenderDamaged || widget.neighbor.isDamaged) &&
            !isRobot &&
            !widget.neighbor.isMe &&
            !widget.isDefenseMode &&
            !widget.neighbor.isPresident);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isProtectedActive
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.85)
                  : (rankTheme != null
                      ? rankTheme.borderColor
                      : ((widget.neighbor.isMe || widget.isDefenseMode)
                          ? const Color(0xFF10B981).withValues(alpha: 0.8)
                          : const Color(0xFFEF4444).withValues(alpha: 0.8))),
              width: rankTheme != null ? 1.8 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: isProtectedActive
                    ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                    : (rankTheme != null
                        ? rankTheme.primaryColor.withValues(alpha: 0.35)
                        : ((widget.neighbor.isMe || widget.isDefenseMode)
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : const Color(0xFFEF4444).withValues(alpha: 0.25))),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Level & PS Minimal Row (User Directive: No "My Fortress" or "VS", strictly Level & PS & Global Rank)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level $effectiveDay',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildGlobalRankBadge(),
                    const SizedBox(width: 6),
                    Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$psValue PS',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              // Action Buttons Row:
              if (isProtectedActive)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showPresidentialProtectionInfoDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0369A1), Color(0xFF0C4A6E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👮‍♂️', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          'POLICE PROTECTION (${_formatProtectionCountdown(_protectionSecondsRemaining)})',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFBAE6FD),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.lock_rounded,
                            size: 12, color: Color(0xFF38BDF8)),
                      ],
                    ),
                  ),
                )
              else if (widget.neighbor.isMe || widget.isDefenseMode) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _onTapBottomAttack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFF60A5FA),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'MOCK ATTACK',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        PocketCitadelStoreSheet.show(
                          context,
                          onPurchased: _loadBattleState,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD97706), Color(0xFFB45309)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFFDE047),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706)
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'STORE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 📸 Minimal Citadel Story Card / Share Button
                    GestureDetector(
                      onTap: () =>
                          _openCitadelStoryShare(effectiveDay, psValue),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 7.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFC4B5FD),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (widget.neighbor.isPresident)
                GestureDetector(
                  onTap: _onTapBottomAttack,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _attackerDay <= 90
                            ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                            : [
                                const Color(0xFFDC2626),
                                const Color(0xFFB45309),
                                const Color(0xFFFFD700)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_attackerDay <= 19
                                  ? Colors.black
                                  : const Color(0xFFFFD700))
                              .withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_attackerDay <= 19 ? '🔒' : '👑',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _attackerDay <= 90
                                  ? 'LOCKED • PASS LVL 90'
                                  : 'CHALLENGE PRESIDENT ⚔️',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: _attackerDay <= 19 ? 11.5 : 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            if (_attackerDay <= 19)
                              Text(
                                'Day $_attackerDay / 19 Progress (Pass Lvl 19)',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isDefenderVip)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isEscortDefeated)
                      GestureDetector(
                        onTap: _onTapBottomAttack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFFB45309),
                                Color(0xFFD97706)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏛️', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ESCORT ATTACK',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      '10 Escort Tasks • Defeat to Unlock Attack',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_raidStep == 2)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _openHouseSiege2dBattle();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'STRIKE & CLAIM LOOT (+15 ${widget.isKidMode ? 'SS' : 'PS'})',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _onTapBottomAttack,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: rankTheme != null
                                  ? rankTheme.gradientColors
                                  : const [
                                      Color(0xFFEF4444),
                                      Color(0xFFB91C1C)
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: rankTheme != null
                                  ? rankTheme.borderColor
                                  : const Color(0xFFFFD700),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (rankTheme != null
                                        ? rankTheme.primaryColor
                                        : const Color(0xFFEF4444))
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⚔️', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                (_isDefenderVip && !_isEscortDefeated)
                                    ? 'ESCORT ATTACK'
                                    : 'ATTACK',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // 🥊 Fight Duel Button (Audio Directive!)
                    GestureDetector(
                      onTap: _onTapFightButton,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rankTheme != null
                                ? [
                                    rankTheme.accentColor,
                                    rankTheme.primaryColor
                                  ]
                                : const [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: rankTheme != null
                                ? rankTheme.borderColor
                                : const Color(0xFFFFD700),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (rankTheme != null
                                      ? rankTheme.accentColor
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🥊', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'FIGHT',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 📸 Minimal Citadel Story Card / Share Button (Raider mode)
                    GestureDetector(
                      onTap: () =>
                          _openCitadelStoryShare(effectiveDay, psValue),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFC4B5FD),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_raidStep == 2)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _executeCitadelAttack();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'STRIKE & CLAIM LOOT (+15 ${widget.isKidMode ? 'SS' : 'PS'})',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _onTapBottomAttack,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: rankTheme != null
                                  ? rankTheme.gradientColors
                                  : const [
                                      Color(0xFFEF4444),
                                      Color(0xFFB91C1C)
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: rankTheme != null
                                  ? rankTheme.borderColor
                                  : const Color(0xFFFFD700),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (rankTheme != null
                                        ? rankTheme.primaryColor
                                        : const Color(0xFFEF4444))
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⚔️', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                (_isDefenderVip && !_isEscortDefeated)
                                    ? 'ESCORT ATTACK'
                                    : 'ATTACK',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // 🥊 Fight Duel Button (Audio Directive!)
                    GestureDetector(
                      onTap: _onTapFightButton,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rankTheme != null
                                ? [
                                    rankTheme.accentColor,
                                    rankTheme.primaryColor
                                  ]
                                : const [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: rankTheme != null
                                ? rankTheme.borderColor
                                : const Color(0xFFFFD700),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (rankTheme != null
                                      ? rankTheme.accentColor
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🥊', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'FIGHT',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 📸 Minimal Citadel Story Card / Share Button (Raider mode)
                    GestureDetector(
                      onTap: () =>
                          _openCitadelStoryShare(effectiveDay, psValue),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFC4B5FD),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛡️ Check if Kids Hero Drawer should be shown instead of Adult MainProfileWidget
  bool get _shouldShowKidProfile {
    // 🏛️ Sovereign President citadel is always presidential
    if (widget.neighbor.isPresident) return false;

    // 🎒 If explicitly opened in Kid Mode (from Kid Hub, Kid Mates, Kid Home, etc.)
    if (widget.isKidMode) return true;

    // 🐾 Kid Animal Robots are kids-only companions (kid_bot_1 ... kid_bot_100)
    if (widget.neighbor.id.startsWith('kid_bot_') ||
        PocketKidsRobotsData.getAnimalById(widget.neighbor.id) != null) {
      return true;
    }

    // 🧒 Only if currently logged in as a kid account AND not an adult robot
    if (PocketKidsService.isKidAccount &&
        !PocketRobotService.isRobotId(widget.neighbor.id)) {
      return true;
    }

    // 🛡️ Adult mode: Real users and adult robots ALWAYS show Adult MainProfileWidget!
    return false;
  }

  /// 📇 Draggable & Tappable Bottom Sheet Drawer for Citadel Defender Profile
  Widget _buildProfileDrawer(
      double maxHeight, double collapsedH, double bottomPad) {
    final prog = _profileDrawerController.value;
    final isExpanded = prog > 0.5;
    final int defRank = _defenderGlobalRank ?? 0;
    final rankTheme = PocketTopRankTheme.getThemeForRank(defRank);

    return Container(
      decoration: BoxDecoration(
        color: rankTheme?.dominantBg ?? const Color(0xFF0F172A),
        gradient: rankTheme != null
            ? LinearGradient(
                colors: rankTheme.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(
          color: rankTheme != null
              ? rankTheme.borderColor.withValues(alpha: 0.7 + (prog * 0.3))
              : (widget.neighbor.isPresident
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF8B5CF6)
                      .withValues(alpha: 0.45 + (prog * 0.35))),
          width: rankTheme != null ? 1.8 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          if (prog > 0.15)
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.22 * prog),
              blurRadius: 24,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          children: [
            // Grab Header Bar (handles dragging and tapping)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0;
                final range = maxHeight - collapsedH;
                if (range > 0) {
                  _profileDrawerController.value -= delta / range;
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -250) {
                  _profileDrawerController.forward();
                } else if (velocity > 250) {
                  _profileDrawerController.reverse();
                } else if (_profileDrawerController.value > 0.35) {
                  _profileDrawerController.forward();
                } else {
                  _profileDrawerController.reverse();
                }
              },
              onTap: () {
                if (_profileDrawerController.value > 0.5) {
                  _profileDrawerController.reverse();
                } else {
                  _profileDrawerController.forward();
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    16, 4, 16, prog < 0.1 ? (4 + bottomPad) : 6),
                decoration: BoxDecoration(
                  color: rankTheme != null
                      ? rankTheme.dominantBg.withValues(alpha: 0.95)
                      : const Color(0xFF1E293B).withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: rankTheme != null
                          ? rankTheme.borderColor.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: prog * 0.12),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pull Handle Pill (User Directive: Slightly larger and easier to grab)
                    Container(
                      width: 44,
                      height: 4.0,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Row(
                      children: [
                        // Defender Avatar Bubble
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.neighbor.isPresident
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFA78BFA),
                              width: 1.4,
                            ),
                            color: const Color(0xFF0F172A),
                          ),
                          child: ClipOval(
                            child: widget.neighbor.isPresident
                                ? const PresidentAvatarWidget(
                                    size: 32, showGlow: false)
                                : VectorAvatarWidget(
                                    config: VectorAvatarConfig
                                        .getEvolutionAvatarForStage(
                                            _effectiveDefenderLevel),
                                    size: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.neighbor.isPresident
                                          ? 'The President\'s Sovereign Citadel'
                                          : ((widget.neighbor.isMe ||
                                                  widget.isDefenseMode)
                                              ? 'My Profile'
                                              : '${widget.neighbor.name}\'s Profile'),
                                      style: GoogleFonts.outfit(
                                        color: widget.neighbor.isPresident
                                            ? const Color(0xFFFFD700)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: (widget.neighbor.isPresident
                                              ? const Color(0xFFFFD700)
                                              : const Color(0xFF8B5CF6))
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (widget.neighbor.isPresident
                                                ? const Color(0xFFFFD700)
                                                : const Color(0xFFA78BFA))
                                            .withValues(alpha: 0.5),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      widget.neighbor.isPresident
                                          ? '👑 Sovereign Lvl 90'
                                          : 'Lvl $_effectiveDefenderLevel',
                                      style: GoogleFonts.outfit(
                                        color: widget.neighbor.isPresident
                                            ? const Color(0xFFFFD700)
                                            : const Color(0xFFDDD6FE),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: _navigateToDefenderPlotOnIsland,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38BDF8)
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF38BDF8)
                                              .withValues(alpha: 0.6),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on_rounded,
                                              color: Color(0xFF38BDF8),
                                              size: 10),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Plot #',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFBAE6FD),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              _buildGlobalRankBadge(fontSize: 8.5),
                              const SizedBox(height: 1),
                              Text(
                                prog > 0.5
                                    ? (widget.neighbor.isPresident
                                        ? 'Sovereign Head of Pocket World'
                                        : ((widget.neighbor.isMe ||
                                                widget.isDefenseMode)
                                            ? 'My Profile & Learning Journey 🌟'
                                            : (_shouldShowKidProfile
                                                ? 'Kid Hero Profile 🎒'
                                                : 'Citadel Defender Profile')))
                                    : ((widget.neighbor.isMe ||
                                            widget.isDefenseMode)
                                        ? 'Tap or swipe up to view full profile & stats ➔'
                                        : 'Swipe up or tap to explore profile'),
                                style: GoogleFonts.outfit(
                                  color: prog > 0.5
                                      ? (widget.neighbor.isPresident
                                          ? const Color(0xFFFFD700)
                                          : (_shouldShowKidProfile
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFFA78BFA)))
                                      : ((widget.neighbor.isMe ||
                                              widget.isDefenseMode)
                                          ? const Color(0xFFFFD700)
                                          : Colors.white60),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expand / Collapse Capsule Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFA78BFA)
                                  .withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Text(
                                    'Profile',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFDDD6FE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                color: const Color(0xFFA78BFA),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Profile View Body (Mounted only when drawer opens)
            if (prog > 0.05)
              Expanded(
                child: Container(
                  color: rankTheme?.dominantBg ?? const Color(0xFF0F172A),
                  child: widget.neighbor.isPresident
                      ? _buildPresidentialDrawerContent()
                      : (_shouldShowKidProfile
                          ? _buildKidHeroDrawerContent()
                          : MainProfileWidget(
                              userId: widget.neighbor.id,
                              hideAppBar: true,
                              preloadedProfile: {
                                'user_id': widget.neighbor.id,
                                'first_name': widget.neighbor.name,
                                'name': widget.neighbor.name,
                                'bio': (widget.neighbor.statusMessage
                                        .toUpperCase()
                                        .startsWith('PKT-'))
                                    ? ''
                                    : widget.neighbor.statusMessage,
                                'learning_day': widget.neighbor.day,
                                'day': widget.neighbor.day,
                                'level': widget.neighbor.day,
                                'pocket_score': _defenderScore > 0
                                    ? _defenderScore
                                    : PocketScoreLevelEngine
                                        .getRequiredScoreForLevel(
                                            widget.neighbor.day),
                                'streak': widget.neighbor.streak,
                                'rank': widget.neighbor.rank,
                                'palette_id': widget.neighbor.paletteId,
                                'is_pocket_robo': widget.neighbor.isPocketRobo,
                              },
                            )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNoticeDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK',
                style: TextStyle(
                    color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEscortDefeatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ESCORT DEFEATED!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PocketLanguageService.localize(
                en: '🏛️ PRESIDENTIAL ESCORT BROKEN!\n'
                    'All 10 Presidential Escort levels defeated successfully!\n\n'
                    '⚔️ Core House Attack unlocked. Now attack ${widget.neighbor.name}\'s ${widget.neighbor.day} defense cards (80% pass mark required).',
                ml: '🏛️ PRESIDENTIAL ESCORT BROKEN!\n'
                    'പ്രസിഡൻഷ്യൽ എസ്കോർട്ടിന്റെ 10 ലെവലുകളും വിജയകരമായി പരാജയപ്പെടുത്തി!\n\n'
                    '⚔️ കോർ ഹൗസ് അറ്റാക്ക് ബട്ടൺ അൺലോക്ക് ആയിരിക്കുന്നു. '
                    'ഇനി ${widget.neighbor.name}-ന്റെ ${widget.neighbor.day} ഡിഫൻസ് കാർഡുകൾ അറ്റാക്ക് ചെയ്യുക (80% പാസ് മാർക്ക് വേണം).',
                ta: '🏛️ PRESIDENTIAL ESCORT BROKEN!\n'
                    'தலைவரின் பாதுகாப்புப் படையின் 10 நிலைகளும் வெற்றிகரமாக முறியடிக்கப்பட்டன!\n\n'
                    '⚔️ பிரதான இல்லத் தாக்குதல் திறக்கப்பட்டது. இப்போது ${widget.neighbor.name}-ன் ${widget.neighbor.day} பாதுகாப்பு அட்டைகளைத் தாக்குங்கள் (80% மதிப்பெண் தேவை).',
                hi: '🏛️ PRESIDENTIAL ESCORT BROKEN!\n'
                    'राष्ट्रपति एस्कॉर्ट के सभी 10 स्तर सफलतापूर्वक पार कर लिए गए!\n\n'
                    '⚔️ मुख्य हाउस अटैक अनलॉक हो गया है। अब ${widget.neighbor.name} के ${widget.neighbor.day} रक्षा कार्डों पर हमला करें (80% अंक आवश्यक)।',
              ),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              'PROCEED TO HOUSE ATTACK ⚔️',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCitadelStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('🏰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.neighbor.name}\'s Citadel Info',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              ((widget.neighbor.isPocketRobo ||
                          PocketRobotService.isRobotId(widget.neighbor.id)) &&
                      !widget.neighbor.isPresident)
                  ? 'Robot Rank'
                  : 'Global Rank',
              ((widget.neighbor.isPocketRobo ||
                          PocketRobotService.isRobotId(widget.neighbor.id)) &&
                      !widget.neighbor.isPresident)
                  ? '🤖 Robot Rank #${_defenderGlobalRank ?? widget.neighbor.day.clamp(1, 90)}'
                  : (_defenderGlobalRank != null
                      ? '🏆 Global Rank #$_defenderGlobalRank'
                      : (widget.neighbor.isPresident
                          ? '👑 Global Rank #1'
                          : '🏆 Global Challenger')),
            ),
            _buildStatRow('Citadel Level', 'Level ${widget.neighbor.day}'),
            _buildStatRow('Pocket Score', 'PS $_defenderScore'),
            _buildStatRow('Study Streak', '🔥 ${widget.neighbor.streak} Days'),
            _buildStatRow(
              'Shield Status',
              widget.neighbor.hasActiveShield
                  ? '🛡️ Active Iron Dome'
                  : '🔓 Unshielded',
            ),
            _buildStatRow('Daily Attacks', '$_attacksUsed / 2 used'),
            if (_isTargetProtected)
              _buildStatRow(
                'Presidential Guard',
                '👮‍♂️ ${_formatProtectionCountdown(_protectionSecondsRemaining)} remaining',
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  PocketWorldGameRulesPage.show(context);
                },
                icon: const Text('📜', style: TextStyle(fontSize: 16)),
                label: Text(
                  'View Citadel Attack & Defense Rules',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _onTapFightButton() {
    HapticFeedback.mediumImpact();
    PocketCitadelFightModal.show(
      context,
      opponentId: widget.neighbor.id,
      opponentName: widget.neighbor.name,
      opponentAvatar: widget.neighbor.avatar,
      opponentDay: widget.neighbor.day,
      isKidMode: widget.isKidMode,
    );
  }

  void _showVictoryDialog() {
    if (widget.neighbor.isPresident) {
      PocketPresidentService.markPresidentialCitadelConquered();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2.0),
          ),
          title: Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOVEREIGN CITADEL CONQUERED!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'LEVEL 91 PRESIDENTIAL RAID COMPLETED!\nYou defeated the Sovereign Palace Citadel and proved C2 Mastery across all 250 Boss Trials.',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '🎓 Your Official Day 90 Fluency Certificate of Sovereign Mastery is now unlocked and ready for download!',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Day90MasterCertificateDialog.show(
                    context,
                    userName: 'Sovereign Grandmaster',
                    userDay: 91,
                  );
                },
                icon: const Text('🎓', style: TextStyle(fontSize: 18)),
                label: Text(
                  'CLAIM OFFICIAL CERTIFICATE 📜',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'CITADEL BREACHED!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You successfully attacked ${widget.neighbor.name}\'s citadel!',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isKidMode
                              ? '+15 STUDENT SCORE (SS) LOOTED! 🎓'
                              : '+15 POCKET SCORE (PS) LOOTED! 🪙',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isKidMode
                              ? '${widget.neighbor.name}\'s Fortress Breached & Marks Claimed!'
                              : 'Defender Citadel Breached & Plundered!',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Text('👮‍♂️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '6h Police Protection Activated for target to recover.',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await PocketAdMobService.instance.showInterstitialAd(
                  context: context,
                  placement: PocketAdPlacement.attack,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                'CLAIM REWARDS & RETURN 🏆',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkPocketTalkCap() {
    final myId = SupaFlow.client.auth.currentUser?.id;
    if (myId != null && myId.isNotEmpty) {
      PocketTrophyService.canInitiateNewPact(myId).then((can) {
        if (mounted && can != _canInitiatePocketTalk) {
          setState(() => _canInitiatePocketTalk = can);
        }
      });
    }
  }

  void _onTapBottomAttack() {
    HapticFeedback.heavyImpact();

    // 🎯 User Directive: Mock Attack on own profile has ZERO penalties, ZERO score lost, and does not break protections
    final bool isMock = widget.neighbor.isMe || widget.isDefenseMode;
    if (isMock) {
      PocketCitadelRunnerAttackPage.open(
        context,
        defenderName: '${widget.neighbor.name} (Trial Mock)',
        defenderLevel: widget.neighbor.day > 0 ? widget.neighbor.day : 1,
        defenderId: widget.neighbor.id,
        isKidMode: widget.isKidMode,
        isEscort: false,
      ).then((result) {
        if (result != null && result['passed'] == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '🎯 Mock Attack Completed! 0 points lost, your Citadel is battle-ready! 🛡️'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      });
      return;
    }
    if (widget.neighbor.isPresident) {
      if (_attackerDay <= 19) {
        _showPresidentialLevelLockDialog();
        return;
      }
    }
    if (_isTargetProtected) {
      _showPresidentialProtectionInfoDialog();
      return;
    }
    if (_inCooldown) {
      _showNoticeDialog(
        '⏳ Citadel Security Alert Active!',
        'This citadel is on high alert after recent combat. Re-attack available in ${_cooldownHoursLeft.toStringAsFixed(1)} hours.',
      );
      return;
    }

    if (_raidStep == 2) {
      _openHouseSiege2dBattle();
      return;
    }

    final bool isEscort = _isEscortMode && !_isEscortDefeated;
    final count = (isEscort && _escortQuestions.isNotEmpty)
        ? _escortQuestions.length
        : (isEscort ? 10 : widget.neighbor.day);

    // 🏃 Launch Subway-Surfers Style 2D Runner Citadel Attack Game!
    PocketCitadelRunnerAttackPage.open(
      context,
      defenderName: isEscort
          ? '${widget.neighbor.name} (VIP Escort Defense)'
          : widget.neighbor.name,
      defenderLevel: count > 0 ? count : (isEscort ? 10 : widget.neighbor.day),
      defenderId: widget.neighbor.id,
      isKidMode: widget.isKidMode,
      isEscort: isEscort,
    ).then((result) async {
      if (!mounted) return;
      if (result != null && result['passed'] == true) {
        if (isEscort) {
          setState(() {
            _isEscortDefeated = true;
            _isEscortMode = false;
            _defenseQuestions = _fortressQuestions;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '🛡️ VIP ESCORT DEFEATED! Main House Defenses Now Vulnerable! ⚔️'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else {
          // 🎉 Minimum 80% passing requirement satisfied!
          // Launch the Interactive Full-Screen 2D House Attack Game!
          await _openHouseSiege2dBattle();
        }
      }
    });
  }

  /// 🏰 Complete House Attack and Return to Previous Screen
  Future<void> _openHouseSiege2dBattle() async {
    // Execute the real backend attack and synchronization
    await _executeCitadelAttack();
  }

  /// 🔤 Step 3 Essential Spelling Challenge Playfield (Zero MCQs - Pure Interactive Letter Tiles)
  Widget _buildSpellingPlayfield(HouseShieldQuestion currentQ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sound and Hint Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _speakIndianEnglish(_targetSpellingWord);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Listen Word',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_targetSpellingWord.length} Letters',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Letter Slots (Step 3 Style)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(_spellingSlots.length, (slotIdx) {
            final letter = _spellingSlots[slotIdx];
            final isFilled = letter != null;
            return GestureDetector(
              onTap: () => _onSpellingSlotTapped(slotIdx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 50,
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFilled ? const Color(0xFFFFD700) : Colors.white24,
                    width: isFilled ? 2.0 : 1.2,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    letter ?? '_',
                    style: GoogleFonts.outfit(
                      color:
                          isFilled ? const Color(0xFFFFD700) : Colors.white24,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Letter Bank Chips (Step 3 Style)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _spellingLetterBank.map((tile) {
            final isUsed = tile.isUsed;
            return GestureDetector(
              onTap: isUsed ? null : () => _onSpellingTileTapped(tile),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isUsed ? 0.25 : 1.0,
                child: Container(
                  width: 42,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isUsed ? const Color(0xFF1E293B) : tile.color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUsed ? Colors.white12 : Colors.white,
                      width: 1.2,
                    ),
                    boxShadow: isUsed
                        ? null
                        : [
                            BoxShadow(
                              color: tile.color.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      tile.letter,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Controls Row: Backspace, Shuffle, Clear
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _onSpellingBackspace,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.backspace_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Backspace',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onSpellingShuffle,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shuffle_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Shuffle',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onSpellingClear,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📦 Stacked Expanded Question / Challenge Sheet (User Directive: "സ്റ്റാക്ക് ചെയ്തിട്ട് വലിയൊരു കണ്ടെയ്നർ ഇട്ടിട്ട് എക്സ്പാൻഡഡ് ആയിട്ട് അതിൽ ക്വസ്റ്റ്യൻസ് വന്നു...")
  Widget _buildQuestionSheet() {
    final currentQ = _defenseQuestions.isNotEmpty
        ? _defenseQuestions[_currentQIdx % _defenseQuestions.length]
        : null;

    if (currentQ != null) {
      _prepareQuestionState(currentQ);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: _raidStep == 2
              ? const Color(0xFFFFD700)
              : (_raidStep == -1
                  ? Colors.redAccent
                  : const Color(0xFF38BDF8).withValues(alpha: 0.6)),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title bar with close button & timer
              Row(
                children: [
                  Text(
                    widget.neighbor.isPresident
                        ? '🏛️ Presidential Trial (${_currentQIdx + 1}/200)'
                        : _isEscortMode
                            ? '🏛️ Presidential Escort (${_currentQIdx + 1}/10)'
                            : '🛡️ Fortress Shield (${_currentQIdx + 1}/${_defenseQuestions.length})',
                    style: GoogleFonts.outfit(
                      color: (widget.neighbor.isPresident || _isEscortMode)
                          ? const Color(0xFFFFD700)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_raidStep == 1) ...[
                    // ⏱️ 25s Blitz Countdown Combat Timer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _secondsLeft <= 5
                            ? Colors.red.withValues(alpha: 0.3)
                            : const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _secondsLeft <= 5
                              ? Colors.redAccent
                              : const Color(0xFFFFD700),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 13,
                            color: _secondsLeft <= 5
                                ? Colors.redAccent
                                : const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_secondsLeft}s',
                            style: GoogleFonts.outfit(
                              color: _secondsLeft <= 5
                                  ? Colors.redAccent
                                  : const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Close button to dismiss container and return to open world
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () =>
                        setState(() => _isQuestionSheetOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step 1: Answering Questions
              if (_raidStep == 1 && currentQ != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isEscortMode
                            ? const Color(0xFF7C3AED).withValues(alpha: 0.35)
                            : const Color(0xFF0284C7).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _isEscortMode
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF38BDF8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _isEscortMode
                            ? '👑 PRESIDENTIAL ESCORT ${_currentQIdx + 1}/10 • FAIL ON 2 ERRORS'
                            : (_defenseQuestions.length > 10
                                ? '🛡️ TASK ${_currentQIdx + 1} OF ${_defenseQuestions.length}: ${currentQ.trapType.toUpperCase()}'
                                : '🛡️ GATE ${_currentQIdx + 1} OF ${_defenseQuestions.length}: ${currentQ.trapType.toUpperCase()}'),
                        style: TextStyle(
                          color: _isEscortMode
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flag_outlined,
                          color: Colors.redAccent, size: 18),
                      tooltip: 'Report Fake Shield',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showReportDialog(currentQ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _isEscortMode
                            ? 'Errors: $_incorrectCount/2 (✓$_correctCount/10)'
                            : 'Pass: 80% (✓$_correctCount ✗$_incorrectCount/${_defenseQuestions.length})',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                // 🎴 Active PopArt Defense Card Banner (User Audio Directive!)
                // "ഒരു ഫുൾ സ്ക്രീൻ ആയിട്ടുള്ള ഒരു പേജ് വരും. അതിൽ ആ കാർഡ് ഉണ്ടാവും.
                // എന്നിട്ട് ആ കാർഡ് ഇങ്ങനെ സൈഡിൽ ഉണ്ടാവും റൈറ്റിൽ.
                // എന്നിട്ട് അവിടെ ഡിഫൻസ് ആക്ടീവേറ്റഡ്, പ്രൊട്ടക്ഷൻ ആക്ടീവ് എന്ന് കാണിക്കും.
                // എന്നിട്ട് ആ കാർഡിന് ഒരു ക്വസ്റ്റ്യൻ ആയിരിക്കും വരുക."
                Builder(
                  builder: (_) {
                    final isMaleKid = widget.neighbor.isMe
                        ? (PocketKidsService.kidGender == 'male')
                        : (PocketKidsService.kidGender == 'male');
                    final currentCardDay = (_currentQIdx + 1)
                        .clamp(1, widget.neighbor.day.clamp(1, 90));
                    final defenseCard = PopArtCardHelper.getCardForDay(
                        currentCardDay,
                        isMale: isMaleKid);
                    final info = PocketCitadelChallengeGenerator.getGameInfo(
                        currentQ.gameFormat);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0xFF10B981),
                                            width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🛡️',
                                              style: TextStyle(fontSize: 9)),
                                          const SizedBox(width: 3),
                                          Text(
                                            'DEFENSE ACTIVE',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF34D399),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SHIELD #$currentCardDay',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  defenseCard.title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${widget.neighbor.name}\'s Fortress Shield • ${info.title}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              final cardIdx = kPopArt180Cards
                                  .indexWhere((c) => c.id == defenseCard.id);
                              PopArtAvatarCardsViewerPage.open(context,
                                  initialIndex: cardIdx >= 0 ? cardIdx : 0);
                            },
                            child: Container(
                              width: 52,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.5),
                                child: CustomPaint(
                                  painter: PopArtCardCustomPainter(
                                      data: defenseCard),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // 🎮 Interactive Game Header Badge
                Builder(
                  builder: (_) {
                    final info = PocketCitadelChallengeGenerator.getGameInfo(
                        currentQ.gameFormat);
                    final diffColor = currentQ.difficulty == 'easy'
                        ? const Color(0xFF10B981)
                        : (currentQ.difficulty == 'hard'
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFFF59E0B));

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0284C7).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF38BDF8), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(info.icon,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Text(
                                info.title.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: diffColor, width: 0.8),
                          ),
                          child: Text(
                            currentQ.difficulty.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: diffColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (currentQ.gameFormat == 'spoken_whisper')
                          GestureDetector(
                            onTap: () =>
                                _speakIndianEnglish(currentQ.explanation),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1)
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF818CF8), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volume_up_rounded,
                                      color: Color(0xFF818CF8), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Listen',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Question Prompt / Target Malayalam Clue
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentQ.question,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (currentQ.gameFormat == 'spelling_challenge' ||
                          currentQ.gameFormat == 'spoken_whisper') ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            final speechWord =
                                currentQ.gameFormat == 'spelling_challenge'
                                    ? _targetSpellingWord
                                    : currentQ.explanation;
                            _speakIndianEnglish(speechWord);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFF818CF8)),
                            ),
                            child: const Icon(Icons.volume_up_rounded,
                                color: Color(0xFF818CF8), size: 20),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 🕹️ INTERACTIVE GAME PLAYFIELD
                Builder(
                  builder: (context) {
                    final isWordBankMode =
                        currentQ.gameFormat == 'sentence_builder' ||
                            currentQ.gameFormat == 'syntax_jigsaw' ||
                            currentQ.gameFormat == 'negative_sentence' ||
                            currentQ.gameFormat == 'chat_reply' ||
                            currentQ.gameFormat == 'spoken_whisper' ||
                            currentQ.gameFormat == 'grammar_defusal' ||
                            currentQ.gameFormat == 'idiom_maze';

                    final isVerbTimelineMode =
                        currentQ.gameFormat == 'verb_timeline' ||
                            currentQ.gameFormat == 'tense_fortress';

                    // 1. WORD BANK MODE (Sentence Builder, Chat Reply, Negative Sentence)
                    if (isWordBankMode) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assembled Sentence Drop Box / Runway
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 64),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF060911),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _assembledWords.isNotEmpty
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF00E5FF)
                                        .withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF)
                                      .withValues(alpha: 0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: _assembledWords.isEmpty
                                ? Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.touch_app_rounded,
                                            color: Colors.white24, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tap word blocks below in order ➔',
                                          style: GoogleFonts.inter(
                                            color: Colors.white38,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _assembledWords.map((w) {
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _assembledWords.remove(w);
                                            _availableWords.add(w);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E5FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF0284C7)
                                                    .withValues(alpha: 0.8),
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                w,
                                                style: GoogleFonts.outfit(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Icon(Icons.close_rounded,
                                                  size: 13,
                                                  color: Colors.black54),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // Word Bank Row Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'WORD BLOCKS (Tap to Assemble)',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (_assembledWords.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _availableWords.addAll(_assembledWords);
                                      _assembledWords.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFFFD700),
                                          width: 0.8),
                                    ),
                                    child: Text(
                                      '🔄 Reset',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Word Bank Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableWords.map((w) {
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _availableWords.remove(w);
                                    _assembledWords.add(w);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.6),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0F172A),
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    w,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }

                    // 2. VERB TIMELINE ARENA MODE
                    if (isVerbTimelineMode) {
                      return Row(
                        children:
                            List.generate(currentQ.options.length, (optIdx) {
                          final isSelected = _selectedOption == optIdx;
                          final opt = currentQ.options[optIdx];
                          final label = optIdx == 0
                              ? 'PAST'
                              : (optIdx == 1 ? 'PRESENT' : 'FUTURE');
                          final cleanWord = opt.split(' (').first;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedOption = optIdx);
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: optIdx < currentQ.options.length - 1
                                      ? 6
                                      : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0284C7)
                                          .withValues(alpha: 0.35)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white12,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        color: isSelected
                                            ? const Color(0xFFFFD700)
                                            : Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cleanWord,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }

                    // 2B. 🔤 ESSENTIAL SPELLING CHALLENGE (Adult Day 1 Step 3 Style - ZERO MCQs!)
                    if (currentQ.gameFormat == 'spelling_challenge') {
                      return _buildSpellingPlayfield(currentQ);
                    }

                    // 2C. 💣 SPOT THE ERROR BOMB DEFUSAL (Interactive phrase tiles, zero radio MCQs)
                    if (currentQ.gameFormat == 'spot_error') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('💣',
                                        style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'TAP FAULTY WORD BLOCK TO DEFUSE:',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFF87171),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                      currentQ.options.length, (optIdx) {
                                    final isSelected =
                                        _selectedOption == optIdx;
                                    return GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(
                                            () => _selectedOption = optIdx);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFEF4444)
                                                  .withValues(alpha: 0.3)
                                              : const Color(0xFF1E293B),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFFEF4444)
                                                : Colors.white24,
                                            width: isSelected ? 2.0 : 1.0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFFEF4444)
                                                            .withValues(
                                                                alpha: 0.3),
                                                    blurRadius: 8,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          currentQ.options[optIdx],
                                          style: GoogleFonts.outfit(
                                            color: isSelected
                                                ? const Color(0xFFFCA5A5)
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    // Fallback to Spelling Playfield (ZERO 4-OPTION MCQS ALLOWED!)
                    return _buildSpellingPlayfield(currentQ);
                  },
                ),
                const SizedBox(height: 14),

                // 🚀 VERIFY / SUBMIT BUTTON
                Builder(
                  builder: (context) {
                    final isSpellingMode =
                        currentQ.gameFormat == 'spelling_challenge';
                    final isWordBankMode =
                        currentQ.gameFormat == 'sentence_builder' ||
                            currentQ.gameFormat == 'syntax_jigsaw' ||
                            currentQ.gameFormat == 'negative_sentence' ||
                            currentQ.gameFormat == 'chat_reply' ||
                            currentQ.gameFormat == 'spoken_whisper' ||
                            currentQ.gameFormat == 'grammar_defusal' ||
                            currentQ.gameFormat == 'idiom_maze';
                    final isVerbTimelineMode =
                        currentQ.gameFormat == 'verb_timeline' ||
                            currentQ.gameFormat == 'tense_fortress';
                    final isSpotErrorMode = currentQ.gameFormat == 'spot_error';

                    final bool isReady;
                    if (isSpellingMode) {
                      isReady = _spellingSlots.isNotEmpty &&
                          !_spellingSlots.contains(null);
                    } else if (isWordBankMode) {
                      isReady = _assembledWords.isNotEmpty;
                    } else if (isVerbTimelineMode || isSpotErrorMode) {
                      isReady = _selectedOption != -1;
                    } else {
                      isReady =
                          _assembledWords.isNotEmpty || _selectedOption != -1;
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isReady
                              ? Colors.white12
                              : const Color(0xFF0284C7),
                          foregroundColor:
                              !isReady ? Colors.white38 : Colors.white,
                          elevation: isReady ? 4 : 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: !isReady
                            ? null
                            : () async {
                                HapticFeedback.mediumImpact();
                                _combatTimer?.cancel();

                                bool isCorrect = false;
                                if (isSpellingMode) {
                                  final spelled = _spellingSlots
                                      .map((s) => s ?? '')
                                      .join('')
                                      .toUpperCase();
                                  isCorrect = (spelled ==
                                      _targetSpellingWord.toUpperCase());
                                } else if (isWordBankMode) {
                                  String normalize(String s) => s
                                      .replaceAll(RegExp(r'[^\w\s]'), '')
                                      .replaceAll(RegExp(r'\s+'), ' ')
                                      .trim()
                                      .toLowerCase();
                                  final assembled =
                                      normalize(_assembledWords.join(' '));
                                  final expected =
                                      normalize(currentQ.explanation);
                                  isCorrect = (assembled == expected);
                                } else if (isVerbTimelineMode ||
                                    isSpotErrorMode) {
                                  isCorrect = (_selectedOption ==
                                      currentQ.correctIndex);
                                } else {
                                  isCorrect = (_selectedOption ==
                                      currentQ.correctIndex);
                                }

                                if (_isEscortMode) {
                                  // 🏛️ VIP Presidential Escort Mode (User Audio Directive: 10 tasks, fail on 2 errors)
                                  if (isCorrect) {
                                    _correctCount++;
                                    HapticFeedback.heavyImpact();
                                    if (_currentQIdx + 1 <
                                        _defenseQuestions.length) {
                                      final curTask = _currentQIdx + 1;
                                      setState(() {
                                        _currentQIdx++;
                                        _lastPreparedQIdx = -1;
                                        _selectedOption = -1;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '👑 Escort Task #$curTask Solved! ($_correctCount/10). Advancing...',
                                          ),
                                          backgroundColor:
                                              const Color(0xFF7C3AED),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      _startCombatTimer();
                                    } else {
                                      // 10th escort task defeated! Unlock core ATTACK button!
                                      setState(() {
                                        _isEscortDefeated = true;
                                        _isEscortMode = false;
                                        _isQuestionSheetOpen = false;
                                        _raidStep = 0;
                                        _defenseQuestions = _fortressQuestions;
                                      });
                                      _showEscortDefeatedDialog();
                                    }
                                  } else {
                                    _incorrectCount++;
                                    HapticFeedback.vibrate();
                                    if (_incorrectCount >= 2) {
                                      // 2 errors made -> Fail immediately! (User Audio Directive)
                                      setState(() => _raidStep = -1);
                                    } else {
                                      // 1 error made -> Warning and proceed
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            '⚠️ Escort Error! (1/2 errors). One more mistake will repel the raid!',
                                          ),
                                          backgroundColor: Colors.amber,
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      if (_currentQIdx + 1 <
                                          _defenseQuestions.length) {
                                        setState(() {
                                          _currentQIdx++;
                                          _lastPreparedQIdx = -1;
                                          _selectedOption = -1;
                                        });
                                        _startCombatTimer();
                                      } else {
                                        // Reached 10 with only 1 error (9/10 passed) -> Escort defeated!
                                        setState(() {
                                          _isEscortDefeated = true;
                                          _isEscortMode = false;
                                          _isQuestionSheetOpen = false;
                                          _raidStep = 0;
                                          _defenseQuestions =
                                              _fortressQuestions;
                                        });
                                        _showEscortDefeatedDialog();
                                      }
                                    }
                                  }
                                } else {
                                  // 🏰 House Defense Cards Mode (User Audio Directive: deferred check, 80% Pass Mark, smooth submit without vibration interrupts)
                                  if (isCorrect) {
                                    _correctCount++;
                                    HapticFeedback.heavyImpact();
                                  } else {
                                    _incorrectCount++;
                                    HapticFeedback.lightImpact();
                                  }

                                  if (_currentQIdx + 1 <
                                      _defenseQuestions.length) {
                                    setState(() {
                                      _currentQIdx++;
                                      _lastPreparedQIdx = -1;
                                      _selectedOption = -1;
                                    });
                                    _startCombatTimer();
                                  } else {
                                    // Finished all cards! Check 80% Pass Mark
                                    final total = _defenseQuestions.isNotEmpty
                                        ? _defenseQuestions.length
                                        : 1;
                                    final accuracy =
                                        (_correctCount / total) * 100.0;
                                    if (accuracy >= 80.0) {
                                      setState(() => _raidStep = 2);
                                    } else {
                                      setState(() => _raidStep = -1);
                                    }
                                  }
                                }
                              },
                        child: Text(
                          _currentQIdx + 1 < _defenseQuestions.length
                              ? (_isEscortMode
                                  ? 'VERIFY ESCORT TASK ${_currentQIdx + 1} 👑'
                                  : 'VERIFY & ADVANCE TO TASK ${_currentQIdx + 2} ➔')
                              : (_isEscortMode
                                  ? 'DEFEAT PRESIDENTIAL ESCORT 👑'
                                  : 'FINALIZE ${_defenseQuestions.length} CARDS & VERIFY PASS MARK (80%) ⚡'),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]

              // Step 2: Pass Mark Achieved -> Attack button ready
              else if (_raidStep == 2) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PASS MARK ACHIEVED! (${((_correctCount / (_defenseQuestions.isNotEmpty ? _defenseQuestions.length : 1)) * 100).toStringAsFixed(0)}% / 80%)',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Solved $_correctCount of ${_defenseQuestions.length} defense card tasks! Fortress defenses breached. Strike now to claim loot!',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _isQuestionSheetOpen = false);
                      _openHouseSiege2dBattle();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on_rounded,
                            size: 20, color: Color(0xFFFFD700)),
                        const SizedBox(width: 8),
                        Text(
                          'ATTACK & LOOT +15 ${widget.isKidMode ? 'SS' : 'PS'}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]

              // Step -1: Trap Triggered / Failed
              else if (_raidStep == -1) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDC2626)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💥', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isAntiCheatTriggered
                                  ? '🚨 ANTI-CHEAT TRIGGERED! RAID FAILED!'
                                  : (_isTimeoutTriggered
                                      ? '⌛ TIME EXPIRED! RAID DEFEATED!'
                                      : _isEscortMode
                                          ? '🏛️ PRESIDENTIAL ESCORT REPELLED RAID!'
                                          : 'TRAP TRIGGERED! ATTACK REPELLED!'),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF87171),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAntiCheatTriggered
                            ? 'You switched apps or minimized during combat! Cheating is strictly prohibited during Citadel Raids.'
                            : (_isTimeoutTriggered
                                ? 'The combat timer expired! The defender\'s automated security traps triggered.'
                                : _isEscortMode
                                    ? PocketLanguageService.localize(
                                        en: '🛑 PRESIDENTIAL ESCORT REPELLED RAID!\nThe 10 Presidential Escort tasks require near perfection (maximum 1 error allowed). You made 2 errors at task ${_currentQIdx + 1}/10. Practice and attack again!',
                                        ml: '🛑 PRESIDENTIAL ESCORT REPELLED RAID!\nപ്രസിഡൻഷ്യൽ എസ്കോർട്ട് അറ്റാക്ക് തടഞ്ഞു!\nThe 10 Presidential Escort tasks require near perfection (maximum 1 error allowed). You made 2 errors at task ${_currentQIdx + 1}/10. Practice and attack again!',
                                        ta: '🛑 PRESIDENTIAL ESCORT REPELLED RAID!\nபாதுகாப்புப் படை உங்கள் தாக்குதலைத் தடுத்தது!\n10 பணிகளில் அதிகபட்சம் 1 தவறு மட்டுமே அனுமதிக்கப்படும். பயிற்சி செய்து மீண்டும் தாக்கவும்!',
                                        hi: '🛑 PRESIDENTIAL ESCORT REPELLED RAID!\nएस्कॉर्ट सुरक्षा ने हमला रोक दिया!\n10 कार्यों में अधिकतम 1 गलती की अनुमति है। अभ्यास करें और पुनः प्रयास करें!',
                                      )
                                    : 'You solved $_correctCount of ${_defenseQuestions.length} defense tasks (${((_correctCount / (_defenseQuestions.isNotEmpty ? _defenseQuestions.length : 1)) * 100).toStringAsFixed(0)}%).\nA minimum Pass Mark of 80% is required to breach ${widget.neighbor.name}\'s citadel!\n\nThe defender\'s fortress held firm. Practice more daily lessons to conquer this house!'),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.35),
                      ),
                      if (currentQ != null &&
                          currentQ.explanation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Grammar Rule: ${currentQ.explanation}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      Text(_attackerDay <= 20 ? '🛡️' : '⏳',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attackerDay <= 20
                              ? 'Beginner Courage Pass! (Level $_attackerDay ≤ 20)\nYou bravely launched an attack on House #${widget.neighbor.day}! Attempting the raid builds confidence. +50 Pocket Score awarded! Step Passed! ✓'
                              : '6-Hour Citadel Lockdown Enforced!\nYou exhausted your second chance. Return after 6 hours to attack again.',
                          style: TextStyle(
                            color: _attackerDay <= 20
                                ? const Color(0xFF34D399)
                                : const Color(0xFFFCD34D),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _attackerDay <= 20
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isQuestionSheetOpen = false);
                      Navigator.pop(context, _attackerDay <= 20 ? true : false);
                    },
                    child: Text(
                      _attackerDay <= 20
                          ? 'CLAIM +50 PS & COMPLETE ATTACK QUEST ➔'
                          : 'ACKNOWLEDGE & RETREAT 🛡️',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ⚡ Avatar-Specific Elemental Combat Strike Painter
/// Renders unique weapon effects based on Attacker Perk & Weapon:
/// - Cannon / Mortar (SiegeDamage): Blazing artillery shells & fiery blast
/// - Plasma Blaster / Crossbow (VaultLoot): Dual rapid laser bolts & electric plasma
/// - Mystic Wand / Sonic Disruptor (FdcBoost): Runic magic spiral & cosmic lightning
/// - Chrono Katana / Blades (TimeFreeze): Supersonic X-blade slash & diamond glints
/// - Paladin Broadsword (ArmyKnights): Holy golden celestial light pillar from heaven
/// - Aegis Ram / Titanium Shield (IronDome/FortressShield): Ramming sonic shockwaves
class CitadelAvatarStrikePainter extends CustomPainter {
  final double beamProg;
  final double particleProg;
  final int attackerDay;
  final AvatarGamePerk perk;
  final double groundBaseY;

  CitadelAvatarStrikePainter({
    required this.beamProg,
    required this.particleProg,
    required this.attackerDay,
    required this.perk,
    this.groundBaseY = 920.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (beamProg <= 0 && particleProg <= 0) return;

    final gy = groundBaseY > 0 ? groundBaseY : 920.0;
    final target = Offset(size.width * 0.5, gy - 240.0); // Citadel entrance
    final source =
        Offset(size.width * 0.5, gy - 180.0); // Hero leap position at steps

    // ⚡ 1. Active Strike Trajectory / Projectile (beamProg > 0)
    if (beamProg > 0 && beamProg <= 1.0) {
      final fade = (1.0 - beamProg).clamp(0.0, 1.0);

      switch (perk.perkType) {
        // 💥 Cannon / Mortar: Heavy explosive shells launched in arc
        case PerkType.siegeDamage:
          // Heavy Cannon Muzzle Flash
          canvas.drawCircle(
            source,
            18.0 * fade,
            Paint()
              ..color = const Color(0xFFF59E0B).withValues(alpha: fade)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
          // Blazing projectile shell flying
          final projY = ui.lerpDouble(source.dy, target.dy, beamProg)!;
          final projX = source.dx + math.sin(beamProg * math.pi) * 24.0;
          final projPos = Offset(projX, projY);
          // Smoke and flame trail behind shell
          canvas.drawLine(
            source,
            projPos,
            Paint()
              ..color = const Color(0xFFEF4444).withValues(alpha: fade * 0.7)
              ..strokeWidth = 6.0 * fade
              ..strokeCap = StrokeCap.round,
          );
          // Glowing Artillery Shell
          canvas.drawCircle(
            projPos,
            9.0,
            Paint()
              ..color = const Color(0xFFFFB703)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
          canvas.drawCircle(projPos, 5.5, Paint()..color = Colors.white);
          break;

        // 🔫 Plasma Blaster / Crossbow: Twin high-energy laser blaster bolts
        case PerkType.vaultLoot:
          // Left & right twin laser beams
          for (final ox in [-12.0, 12.0]) {
            final s = Offset(source.dx + ox, source.dy);
            final t = Offset(target.dx + (ox * 0.6), target.dy);
            // Neon cyan outer plasma glow
            canvas.drawLine(
              s,
              t,
              Paint()
                ..color = const Color(0xFF00F0FF).withValues(alpha: fade * 0.7)
                ..strokeWidth = 10.0 * fade
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
            );
            // Core laser beam
            canvas.drawLine(
              s,
              t,
              Paint()
                ..color = Colors.white.withValues(alpha: fade)
                ..strokeWidth = 3.5 * fade
                ..strokeCap = StrokeCap.round,
            );
          }
          break;

        // ⚡ Mystic Wand / Sonic Disruptor: Spiral arcane cosmic runes & lightning
        case PerkType.fdcBoost:
          final auraPaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFFACC15), Color(0xFF38BDF8)],
            ).createShader(Rect.fromPoints(target, source))
            ..strokeWidth = 14.0 * fade
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
          canvas.drawLine(source, target, auraPaint);
          // Double helix twisting magic arcs
          for (int h = 0; h < 2; h++) {
            final sign = h == 0 ? 1.0 : -1.0;
            final arcPath = Path()..moveTo(source.dx, source.dy);
            for (int i = 1; i <= 6; i++) {
              final t = i / 6.0;
              final lx = source.dx +
                  math.sin(t * math.pi * 3 + beamProg * 8) * (18.0 * sign);
              final ly = ui.lerpDouble(source.dy, target.dy, t)!;
              arcPath.lineTo(lx, ly);
            }
            canvas.drawPath(
              arcPath,
              Paint()
                ..color =
                    (h == 0 ? const Color(0xFFFDE047) : const Color(0xFFE879F9))
                        .withValues(alpha: fade * 0.85)
                ..strokeWidth = 2.2
                ..style = PaintingStyle.stroke,
            );
          }
          break;

        // 🗡️ Chrono Katana / Blades: Sonic speed cross-slash lines
        case PerkType.timeFreeze:
          // X-Slash 1
          canvas.drawLine(
            Offset(target.dx - 36, target.dy - 36),
            Offset(target.dx + 36, target.dy + 36),
            Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: fade)
              ..strokeWidth = 4.5 * fade
              ..strokeCap = StrokeCap.round,
          );
          // X-Slash 2
          canvas.drawLine(
            Offset(target.dx + 36, target.dy - 36),
            Offset(target.dx - 36, target.dy + 36),
            Paint()
              ..color = Colors.white.withValues(alpha: fade)
              ..strokeWidth = 4.5 * fade
              ..strokeCap = StrokeCap.round,
          );
          // Blade glint diamond at center
          canvas.drawCircle(
            target,
            12.0 * fade,
            Paint()
              ..color = const Color(0xFF93C5FD).withValues(alpha: fade * 0.6)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
          break;

        // ⚔️ Paladin Broadsword: Golden Holy Light Pillar from the sky
        case PerkType.armyKnights:
          final skyOrigin = Offset(target.dx, target.dy - 320);
          canvas.drawLine(
            skyOrigin,
            target,
            Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFEF08A), Color(0xFFFFD700), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromPoints(skyOrigin, target))
              ..strokeWidth = 22.0 * fade
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
          );
          canvas.drawLine(
            skyOrigin,
            target,
            Paint()
              ..color = Colors.white.withValues(alpha: fade)
              ..strokeWidth = 6.0 * fade,
          );
          break;

        // 🛡️ Aegis Ram / Titanium Shield: Concentric sonic force ramming forward
        default:
          for (int r = 1; r <= 3; r++) {
            canvas.drawCircle(
              Offset(target.dx, target.dy + (20 * (1.0 - beamProg))),
              (18.0 * r) * beamProg,
              Paint()
                ..color = const Color(0xFF10B981).withValues(alpha: fade * 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0 * fade,
            );
          }
          break;
      }
    }

    // 💥 2. Citadel Impact Explosion & Expanding Shockwave (particleProg > 0)
    if (particleProg > 0 && particleProg <= 1.0) {
      final pFade = (1.0 - particleProg).clamp(0.0, 1.0);

      // Expanding Shockwave Ring
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: pFade * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * pFade;
      canvas.drawCircle(target, 68.0 * particleProg, ringPaint);

      // Blinding Impact Core Flash
      canvas.drawCircle(
        target,
        34.0 * (1.0 - particleProg),
        Paint()
          ..color = Colors.white.withValues(alpha: pFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Flying Explosion Sparks (28 directional particles)
      final sparkPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 28; i++) {
        final angle = (i / 28.0) * math.pi * 2;
        final speed = 45.0 + (i % 6) * 16.0;
        final px = target.dx + math.cos(angle) * speed * particleProg;
        final py = target.dy +
            math.sin(angle) * speed * particleProg -
            (12.0 * particleProg);

        sparkPaint.color =
            (i % 2 == 0 ? const Color(0xFFFFB703) : const Color(0xFFEF4444))
                .withValues(alpha: pFade);
        canvas.drawCircle(Offset(px, py),
            (3.8 - (particleProg * 1.6)).clamp(1.0, 4.0), sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CitadelAvatarStrikePainter oldDelegate) =>
      oldDelegate.beamProg != beamProg ||
      oldDelegate.particleProg != particleProg;
}

/// 🪙 Magnetic Coin Looting Shower Painter
/// Coins fountain out of the breached citadel doors and fly down directly into
/// the attacking hero's treasure chest/grasp!
class CitadelCoinShowerPainter extends CustomPainter {
  final double progress;
  final double groundBaseY;

  CitadelCoinShowerPainter({
    required this.progress,
    this.groundBaseY = 920.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final gy = groundBaseY > 0 ? groundBaseY : 920.0;
    final origin =
        Offset(size.width * 0.5, gy - 240.0); // Breached mansion doors
    final heroChest =
        Offset(size.width * 0.5, gy - 160.0); // Hero collection chest
    final coinPaint = Paint()..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFB45309);
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    // 🪙 24 Shimmering Gold Coins in Magnetic Trajectories
    for (int i = 0; i < 24; i++) {
      // Phase 1 (prog 0.0 -> 0.35): Erupting upward & outward fountain
      // Phase 2 (prog 0.35 -> 1.0): Pulled magnetically into heroChest!
      final burstSpreadX = math.sin(i * 1.5) * 160.0;
      final burstSpreadY = -80.0 - ((i % 5) * 22.0);
      final apex = Offset(origin.dx + burstSpreadX, origin.dy + burstSpreadY);

      double cx, cy;
      if (progress < 0.35) {
        final t = progress / 0.35;
        cx = ui.lerpDouble(origin.dx, apex.dx, t)!;
        cy = ui.lerpDouble(origin.dy, apex.dy, t)!;
      } else {
        final t = (progress - 0.35) / 0.65;
        // Curved cubic pull towards hero's chest
        final curvedT = Curves.easeInCubic.transform(t);
        cx = ui.lerpDouble(apex.dx, heroChest.dx, curvedT)!;
        cy = ui.lerpDouble(apex.dy, heroChest.dy, curvedT)!;
      }

      // Outer coin glow glint
      canvas.drawCircle(
        Offset(cx, cy),
        7.5,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: fade * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Gold Coin Face
      coinPaint.color = const Color(0xFFFFD700).withValues(alpha: fade);
      canvas.drawCircle(Offset(cx, cy), 5.5, coinPaint);
      canvas.drawCircle(Offset(cx, cy), 5.5,
          rimPaint..color = const Color(0xFFB45309).withValues(alpha: fade));

      // Shimmer highlight
      canvas.drawCircle(
        Offset(cx - 1.5, cy - 1.5),
        1.5,
        Paint()..color = Colors.white.withValues(alpha: fade * 0.9),
      );
    }

    // Chest Collection Sparkle Glints
    if (progress > 0.45) {
      final glintFade = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      canvas.drawCircle(
        heroChest,
        18.0 * (1.0 - glintFade),
        Paint()
          ..color =
              const Color(0xFFFFD700).withValues(alpha: (1.0 - glintFade) * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CitadelCoinShowerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 🛡️ Iron Dome Missile Interception & Kinetic Blast Painter
/// Tamir interceptor missile launches from the battery pad, arcs up across the sky,
/// collides with the incoming hostile strike in mid-air, and creates a blazing intercept fireball
/// with expanding shockwaves and forcefield deflection ring!
class CitadelIronDomeInterceptPainter extends CustomPainter {
  final double prog;
  final Offset source;
  final Offset target;

  CitadelIronDomeInterceptPainter({
    required this.prog,
    required this.source,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prog <= 0 || prog >= 1.0) return;

    // Phase 1: Missile Ascent (prog 0.0 -> 0.48)
    if (prog < 0.48) {
      final t = prog / 0.48;
      // High-arching parabolic trajectory
      final mx = ui.lerpDouble(source.dx, target.dx, t)!;
      final baseY = ui.lerpDouble(source.dy, target.dy, t)!;
      final arcHeight = -180.0 * math.sin(t * math.pi);
      final my = baseY + arcHeight;
      final missilePos = Offset(mx, my);

      // Rocket Exhaust Vapor & Smoke Trail
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFEF4444),
            const Color(0xFFF97316),
            const Color(0xFFFEF08A),
            Colors.white.withValues(alpha: 0.6),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromPoints(source, missilePos))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(source.dx, source.dy);
      path.quadraticBezierTo(
        (source.dx + target.dx) / 2,
        (source.dy + target.dy) / 2 - 200,
        missilePos.dx,
        missilePos.dy,
      );
      canvas.drawPath(path, trailPaint);

      // Blazing Interceptor Missile Head
      canvas.drawCircle(
        missilePos,
        14,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(missilePos, 4.5, Paint()..color = Colors.white);
    }
    // Phase 2: Mid-Air Interception & Fireball Detonation (prog 0.48 -> 1.0)
    else {
      final blastT = (prog - 0.48) / 0.52;
      final fade = (1.0 - blastT).clamp(0.0, 1.0);

      // Expanding Shockwave Kinetic Ring
      final shockwaveR = 25.0 + (blastT * 150.0);
      canvas.drawCircle(
        target,
        shockwaveR,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: fade * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * fade
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Core Fireball Blast
      final blastR = (38.0 * math.sin(blastT * math.pi)).clamp(0.0, 52.0);
      canvas.drawCircle(
        target,
        blastR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white,
              const Color(0xFFFEF08A),
              const Color(0xFFF97316),
              const Color(0xFFEF4444).withValues(alpha: fade),
              Colors.transparent,
            ],
            stops: const [0.0, 0.25, 0.55, 0.85, 1.0],
          ).createShader(Rect.fromCircle(center: target, radius: blastR + 12)),
      );

      // Exploding Intercept Sparks (18 particles)
      for (int i = 0; i < 18; i++) {
        final angle = (i * 20.0) * math.pi / 180;
        final speed = 42.0 + ((i % 5) * 24.0);
        final px = target.dx + math.cos(angle) * (speed * blastT);
        final py = target.dy + math.sin(angle) * (speed * blastT);
        canvas.drawCircle(
          Offset(px, py),
          2.6 * fade,
          Paint()
            ..color = (i % 2 == 0)
                ? const Color(0xFFFFD700)
                : const Color(0xFF38BDF8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CitadelIronDomeInterceptPainter oldDelegate) =>
      oldDelegate.prog != prog;
}

/// 🏛️ Animated Presidential Court Case Filing Dialog
class _PresidentialDispatchDialog extends StatefulWidget {
  final String targetName;
  final String targetId;
  final HouseShieldQuestion currentQ;
  final String reason;

  const _PresidentialDispatchDialog({
    required this.targetName,
    required this.targetId,
    required this.currentQ,
    required this.reason,
  });

  @override
  State<_PresidentialDispatchDialog> createState() =>
      _PresidentialDispatchDialogState();
}

class _PresidentialDispatchDialogState
    extends State<_PresidentialDispatchDialog> {
  bool _isDispatched = false;
  String _caseNumber = '';

  @override
  void initState() {
    super.initState();
    _caseNumber =
        'DEC-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';
    _performDispatch();
  }

  Future<void> _performDispatch() async {
    HapticFeedback.heavyImpact();
    // 1. File to Presidential Service and Supabase
    await PocketFortressDefenseService.fileDefenseReport(
      houseId: widget.targetId,
      houseOwnerName: widget.targetName,
      questionId: widget.currentQ.id,
      questionText: widget.currentQ.question,
      options: widget.currentQ.options,
      correctIndex: widget.currentQ.correctIndex,
      reporterId: 'attacker_me',
      reporterName: 'Citadel Raider',
      reason: widget.reason,
      details: 'Reported during live raid blitz combat.',
    );

    // 2. Direct log to President Desk registry for Admin Panel
    final uid = SupaFlow.client.auth.currentUser?.id ?? 'attacker_me';
    await PocketPresidentService.recordQuestionReportToPresident(
      reporterId: uid,
      reporterName: 'Citadel Raider',
      houseId: widget.targetId,
      houseOwnerName: widget.targetName,
      questionText: widget.currentQ.question,
      reason: widget.reason,
    );

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      HapticFeedback.lightImpact();
      setState(() => _isDispatched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isDispatched
                ? const Color(0xFF10B981)
                : const Color(0xFFFFD700),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isDispatched
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFD700))
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isDispatched
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700))
                    .withValues(alpha: 0.15),
                border: Border.all(
                  color: _isDispatched
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFD700),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _isDispatched ? '⚖️' : '🏛️',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isDispatched
                  ? 'CASE FILED WITH PRESIDENT & ADMIN!'
                  : 'DISPATCHING TO PRESIDENTIAL COURT...',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dossier #$_caseNumber • Target: ${widget.targetName}',
                style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            if (!_isDispatched) ...[
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Submitting encrypted fraud evidence to the Presidency...\nTarget citadel faces Pocket Score wipeout if confirmed guilty.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '✓ Formal Investigation Opened',
                      style: TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The Supreme Presidential Court & Admin inspect all fraudulent defense questions. Confirmed violations result in immediate Pocket Score deduction & citadel demotion to Level 1.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'RETURN TO COMBAT ⚔️',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
