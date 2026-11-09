import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';

/// 🎖️ Island Defense Profile Model
class IslandDefenseProfile {
  final String islandId;
  final String islandName;
  final String planetCode;
  final String planetName;
  final int wave;
  final int totalPlots;
  final int occupiedCount;
  final int totalHp; // Sum of resident day levels
  final int bountyPool; // Pocket Score bounty
  final List<CitizenPlot> residents;
  final bool isUnderShield;
  final int shieldMinutesRemaining;
  final bool isOwnIsland;

  const IslandDefenseProfile({
    required this.islandId,
    required this.islandName,
    required this.planetCode,
    required this.planetName,
    required this.wave,
    this.totalPlots = 25,
    required this.occupiedCount,
    required this.totalHp,
    required this.bountyPool,
    required this.residents,
    required this.isUnderShield,
    required this.shieldMinutesRemaining,
    required this.isOwnIsland,
  });
}

/// 📜 Island War Log Entry (Army Desk & Retaliation Engine)
class IslandWarLogEntry {
  final String id;
  final String attackerId;
  final String attackerName;
  final String attackerAvatar;
  final String targetIslandId;
  final String targetIslandName;
  final String targetPlanetCode;
  final String attackerPlanetCode;
  final int totalHp;
  final int damageDealt;
  final bool wasConquered;
  final int scoreLooted;
  final DateTime timestamp;
  final bool isMockAttack;
  final bool isTeamRaid;
  final int teamParticipantsCount;

  IslandWarLogEntry({
    required this.id,
    required this.attackerId,
    required this.attackerName,
    required this.attackerAvatar,
    required this.targetIslandId,
    required this.targetIslandName,
    required this.targetPlanetCode,
    required this.attackerPlanetCode,
    required this.totalHp,
    required this.damageDealt,
    required this.wasConquered,
    required this.scoreLooted,
    required this.timestamp,
    this.isMockAttack = false,
    this.isTeamRaid = false,
    this.teamParticipantsCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'attackerId': attackerId,
        'attackerName': attackerName,
        'attackerAvatar': attackerAvatar,
        'targetIslandId': targetIslandId,
        'targetIslandName': targetIslandName,
        'targetPlanetCode': targetPlanetCode,
        'attackerPlanetCode': attackerPlanetCode,
        'totalHp': totalHp,
        'damageDealt': damageDealt,
        'wasConquered': wasConquered,
        'scoreLooted': scoreLooted,
        'timestamp': timestamp.toIso8601String(),
        'isMockAttack': isMockAttack,
        'isTeamRaid': isTeamRaid,
        'teamParticipantsCount': teamParticipantsCount,
      };

  factory IslandWarLogEntry.fromJson(Map<String, dynamic> json) =>
      IslandWarLogEntry(
        id: json['id']?.toString() ?? '',
        attackerId: json['attackerId']?.toString() ?? '',
        attackerName: json['attackerName']?.toString() ?? 'Unknown Raider',
        attackerAvatar: json['attackerAvatar']?.toString() ?? '⚔️',
        targetIslandId: json['targetIslandId']?.toString() ?? '',
        targetIslandName: json['targetIslandName']?.toString() ?? 'Cosmic Island',
        targetPlanetCode: json['targetPlanetCode']?.toString() ?? 'EP',
        attackerPlanetCode: json['attackerPlanetCode']?.toString() ?? 'EP',
        totalHp: (json['totalHp'] as num?)?.toInt() ?? 25,
        damageDealt: (json['damageDealt'] as num?)?.toInt() ?? 0,
        wasConquered: json['wasConquered'] == true,
        scoreLooted: (json['scoreLooted'] as num?)?.toInt() ?? 0,
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        isMockAttack: json['isMockAttack'] == true,
        isTeamRaid: json['isTeamRaid'] == true,
        teamParticipantsCount:
            (json['teamParticipantsCount'] as num?)?.toInt() ?? 1,
      );
}

/// 👥 Island Team Raid Session
class IslandTeamRaidSession {
  final String raidCode; // e.g. "RAID-8421"
  final String targetIslandId;
  final String targetIslandName;
  final String targetPlanetCode;
  final int totalHp;
  int currentHp;
  final String leaderId;
  final String leaderName;
  final Map<String, int> participantDamage; // uid -> questions answered
  final Map<String, String> participantNames; // uid -> name
  final DateTime createdAt;
  bool isConquered;

  IslandTeamRaidSession({
    required this.raidCode,
    required this.targetIslandId,
    required this.targetIslandName,
    required this.targetPlanetCode,
    required this.totalHp,
    required this.currentHp,
    required this.leaderId,
    required this.leaderName,
    required this.participantDamage,
    required this.participantNames,
    required this.createdAt,
    this.isConquered = false,
  });

  Map<String, dynamic> toJson() => {
        'raidCode': raidCode,
        'targetIslandId': targetIslandId,
        'targetIslandName': targetIslandName,
        'targetPlanetCode': targetPlanetCode,
        'totalHp': totalHp,
        'currentHp': currentHp,
        'leaderId': leaderId,
        'leaderName': leaderName,
        'participantDamage': participantDamage,
        'participantNames': participantNames,
        'createdAt': createdAt.toIso8601String(),
        'isConquered': isConquered,
      };

  factory IslandTeamRaidSession.fromJson(Map<String, dynamic> json) =>
      IslandTeamRaidSession(
        raidCode: json['raidCode']?.toString() ?? '',
        targetIslandId: json['targetIslandId']?.toString() ?? '',
        targetIslandName: json['targetIslandName']?.toString() ?? '',
        targetPlanetCode: json['targetPlanetCode']?.toString() ?? 'EP',
        totalHp: (json['totalHp'] as num?)?.toInt() ?? 25,
        currentHp: (json['currentHp'] as num?)?.toInt() ?? 25,
        leaderId: json['leaderId']?.toString() ?? '',
        leaderName: json['leaderName']?.toString() ?? '',
        participantDamage:
            (json['participantDamage'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, (v as num).toInt()),
                ) ??
                {},
        participantNames:
            (json['participantNames'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, v.toString()),
                ) ??
                {},
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        isConquered: json['isConquered'] == true,
      );
}

/// ⚔️ Pocket Island Attack Service
/// Orchestrates Island Defense calculation, Mock Attacks, Team Raids,
/// 10-Hour Army Shields, and Emergency Siren Chat Alerts.
class PocketIslandAttackService {
  PocketIslandAttackService._();
  static final PocketIslandAttackService instance =
      PocketIslandAttackService._();

  static const Duration kArmyShieldDuration = Duration(hours: 10);
  static const String _kShieldPrefix = 'cosmos_island_shield_';
  static const String _kWarLogsKey = 'cosmos_island_war_logs_v1';
  static const String _kRaidSessionsKey = 'cosmos_island_team_raids_v1';

  // In-memory active raid sessions cache
  final Map<String, IslandTeamRaidSession> _activeRaids = {};

  // ---------------------------------------------------------------------------
  // 1. 🛡️ ISLAND DEFENSE & HP CALCULATION
  // ---------------------------------------------------------------------------

  /// Calculates total HP as the sum of all active resident day levels:
  /// Total HP = sum(resident.day) for all occupied plots on this island.
  Future<IslandDefenseProfile> calculateIslandDefense({
    required PoketCountryMap island,
    required List<CitizenPlot> plots,
    CelestialColonyInfo? colony,
    String? currentUserId,
  }) async {
    final myId = currentUserId ?? SupaFlow.client.auth.currentUser?.id ?? '';

    // Filter active occupied plots
    final activeResidents = plots.where((p) {
      final uid = p.userId.trim();
      return uid.isNotEmpty &&
          !uid.startsWith('vacant') &&
          !uid.startsWith('empty');
    }).toList();

    // Island HP = sum(resident.day)
    int totalHp = 0;
    if (activeResidents.isEmpty) {
      // Fallback baseline for pioneer/unfilled islands
      totalHp = 25;
    } else {
      for (final r in activeResidents) {
        totalHp += math.max(1, r.day);
      }
    }

    // Bounty pool scales with island HP (minimum 50 PS, max 2500 PS)
    final int bountyPool = math.max(50, totalHp * 8);

    // Check if this is the user's own island
    final bool isOwn = activeResidents.any((r) => r.userId == myId);

    // Check 10-Hour Army Shield status
    final shieldMinutes = await getShieldMinutesRemaining(island.id.toString());
    final bool isShieldActive = shieldMinutes > 0;

    final resolvedColony = colony ??
        PoketCosmosAllocationService.colonies.firstWhere(
          (c) => c.islandName == island.name,
          orElse: () => PoketCosmosAllocationService.colonies.first,
        );

    return IslandDefenseProfile(
      islandId: island.id.toString(),
      islandName: island.name,
      planetCode: resolvedColony.code,
      planetName: resolvedColony.planetName,
      wave: island.wave,
      totalPlots: 25,
      occupiedCount: activeResidents.length,
      totalHp: totalHp,
      bountyPool: bountyPool,
      residents: activeResidents,
      isUnderShield: isShieldActive,
      shieldMinutesRemaining: shieldMinutes,
      isOwnIsland: isOwn,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. 🛡️ 10-HOUR ARMY DEFENSE SHIELD
  // ---------------------------------------------------------------------------

  /// Checks if an island is currently protected by the 10-Hour Army Shield
  Future<bool> isIslandProtected(String islandId) async {
    final minutes = await getShieldMinutesRemaining(islandId);
    return minutes > 0;
  }

  /// Returns remaining minutes of 10-Hour Army Shield (0 if expired)
  Future<int> getShieldMinutesRemaining(String islandId) async {
    final prefs = await SharedPreferences.getInstance();
    final shieldExpiryStr = prefs.getString('$_kShieldPrefix$islandId');
    if (shieldExpiryStr == null || shieldExpiryStr.isEmpty) return 0;

    final expiry = DateTime.tryParse(shieldExpiryStr);
    if (expiry == null) return 0;

    final now = DateTime.now();
    if (now.isAfter(expiry)) {
      await prefs.remove('$_kShieldPrefix$islandId');
      return 0;
    }
    return expiry.difference(now).inMinutes;
  }

  /// Deploys 10-Hour Army Defense Shield upon Island Defeat
  Future<void> deployArmyShield(String islandId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(kArmyShieldDuration);
    await prefs.setString('$_kShieldPrefix$islandId', expiry.toIso8601String());
    debugPrint(
        '🛡️ [IslandAttackService] Deployed 10-Hour Army Shield for $islandId until $expiry');
  }

  /// Deactivate shield (for admin / testing)
  Future<void> removeArmyShield(String islandId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kShieldPrefix$islandId');
  }

  // ---------------------------------------------------------------------------
  // 3. 📜 ARMY DESK WAR LOGS & REVENGE ENGINE
  // ---------------------------------------------------------------------------

  /// Records an island battle log
  Future<void> recordWarLog(IslandWarLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWarLogs();
    logs.insert(0, entry);
    if (logs.length > 50) {
      logs.removeRange(50, logs.length);
    }
    final jsonList = logs.map((e) => e.toJson()).toList();
    await prefs.setString(_kWarLogsKey, jsonEncode(jsonList));

    // Also attempt to push to Supabase if table exists
    try {
      await SupaFlow.client.from('cosmos_island_war_logs').insert({
        'attacker_id': entry.attackerId,
        'attacker_name': entry.attackerName,
        'attacker_avatar': entry.attackerAvatar,
        'target_island_id': entry.targetIslandId,
        'target_island_name': entry.targetIslandName,
        'target_planet_code': entry.targetPlanetCode,
        'attacker_planet_code': entry.attackerPlanetCode,
        'total_hp': entry.totalHp,
        'damage_dealt': entry.damageDealt,
        'was_conquered': entry.wasConquered,
        'score_looted': entry.scoreLooted,
        'is_mock_attack': entry.isMockAttack,
        'is_team_raid': entry.isTeamRaid,
        'team_participants_count': entry.teamParticipantsCount,
        'created_at': entry.timestamp.toIso8601String(),
      });
    } catch (_) {}
  }

  /// Fetches all war logs
  Future<List<IslandWarLogEntry>> getWarLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kWarLogsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => IslandWarLogEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [IslandAttackService] Error reading war logs: $e');
      return [];
    }
  }

  /// Fetches war logs relevant to a specific island or planet
  Future<List<IslandWarLogEntry>> getWarLogsForIsland(String islandId) async {
    final all = await getWarLogs();
    return all.where((e) => e.targetIslandId == islandId).toList();
  }

  /// Fetches war logs relevant to current user's home island
  Future<List<IslandWarLogEntry>> getWarLogsForUserHome(String userId) async {
    final userPlot =
        await PoketCosmosAllocationService.instance.getUserPlot(userId: userId);
    if (userPlot == null) return await getWarLogs();

    final all = await getWarLogs();
    final userPlanetCode =
        PoketCosmosAllocationService.instance.getColonyByPlanetName(userPlot.planetName).code;

    final homeLogs = all.where((e) {
      return e.targetPlanetCode == userPlanetCode ||
          e.targetIslandId.contains(userPlanetCode);
    }).toList();

    return homeLogs.isNotEmpty ? homeLogs : all;
  }

  // ---------------------------------------------------------------------------
  // 4. 👥 TEAM RAID CAMPAIGN ENGINE
  // ---------------------------------------------------------------------------

  /// Creates a collaborative Team Raid session with a 6-character Raid Code
  Future<IslandTeamRaidSession> createTeamRaidSession({
    required PoketCountryMap targetIsland,
    required int totalHp,
    required String leaderId,
    required String leaderName,
    CelestialColonyInfo? colony,
  }) async {
    final random = math.Random();
    final codeNum = 1000 + random.nextInt(9000);
    final raidCode = 'RAID-$codeNum';

    final resolvedColony = colony ??
        PoketCosmosAllocationService.colonies.firstWhere(
          (c) => c.islandName == targetIsland.name,
          orElse: () => PoketCosmosAllocationService.colonies.first,
        );

    final session = IslandTeamRaidSession(
      raidCode: raidCode,
      targetIslandId: targetIsland.id.toString(),
      targetIslandName: targetIsland.name,
      targetPlanetCode: resolvedColony.code,
      totalHp: totalHp,
      currentHp: totalHp,
      leaderId: leaderId,
      leaderName: leaderName,
      participantDamage: {leaderId: 0},
      participantNames: {leaderId: leaderName},
      createdAt: DateTime.now(),
    );

    _activeRaids[raidCode] = session;
    await _persistRaidSessions();
    return session;
  }

  /// Joins an existing Team Raid session by Raid Code
  Future<IslandTeamRaidSession?> joinTeamRaidSession({
    required String raidCode,
    required String userId,
    required String userName,
  }) async {
    final cleanCode = raidCode.trim().toUpperCase();
    await _loadPersistedRaids();
    final session = _activeRaids[cleanCode];
    if (session == null || session.isConquered) return null;

    if (!session.participantDamage.containsKey(userId)) {
      session.participantDamage[userId] = 0;
      session.participantNames[userId] = userName;
      await _persistRaidSessions();
    }
    return session;
  }

  /// Records damage dealt by a player in a Team Raid session
  Future<Map<String, dynamic>> recordRaidDamage({
    required String raidCode,
    required String userId,
    required int damage,
    required int bountyPool,
  }) async {
    final cleanCode = raidCode.trim().toUpperCase();
    final session = _activeRaids[cleanCode];
    if (session == null) {
      return {'conquered': false, 'remainingHp': 0, 'rewards': {}};
    }

    final currentContrib = session.participantDamage[userId] ?? 0;
    session.participantDamage[userId] = currentContrib + damage;
    session.currentHp = math.max(0, session.currentHp - damage);

    final bool isDefeated = session.currentHp <= 0;
    session.isConquered = isDefeated;

    Map<String, int> rewards = {};
    if (isDefeated) {
      // Calculate fair split of bounty pool
      final totalDealt = session.participantDamage.values
          .fold<int>(0, (sum, d) => sum + d);
      final safeTotal = math.max(1, totalDealt);

      session.participantDamage.forEach((uid, dealt) {
        final double share = dealt / safeTotal;
        final int payout = (bountyPool * share).round();
        rewards[uid] = payout;
      });

      // Deploy 10-Hour Shield on defeated island
      await deployArmyShield(session.targetIslandId);
    }

    await _persistRaidSessions();
    return {
      'conquered': isDefeated,
      'remainingHp': session.currentHp,
      'rewards': rewards,
    };
  }

  Future<void> _persistRaidSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _activeRaids.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_kRaidSessionsKey, jsonEncode(map));
  }

  Future<void> _loadPersistedRaids() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRaidSessionsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      decoded.forEach((k, v) {
        _activeRaids[k] = IslandTeamRaidSession.fromJson(v);
      });
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // 5. ❓ DYNAMIC ISLAND QUESTION GENERATOR
  // ---------------------------------------------------------------------------

  /// Generates a sequenced challenge pool from all residents of the island
  Future<List<HouseShieldQuestion>> generateQuestionsForIsland({
    required List<CitizenPlot> residents,
    required int targetTotalQuestions,
  }) async {
    final List<HouseShieldQuestion> questions = [];
    final safeTotal = math.max(5, targetTotalQuestions);

    if (residents.isEmpty) {
      // Generate default cosmic island questions
      final dummyRandom = math.Random(42);
      return PocketCitadelChallengeGenerator.generateEscortTasks(
        safeTotal,
        dummyRandom,
      );
    }

    // Distribute questions across residents proportional to their Day level
    int questionsPerResident = (safeTotal / residents.length).ceil();
    for (final resident in residents) {
      final residentLevel = math.max(1, resident.day);
      final countForThisResident =
          math.min(residentLevel, questionsPerResident);

      final residentQuestions =
          PocketCitadelChallengeGenerator.generateChallengesForDefender(
        defenderLevel: residentLevel,
        defenderId: resident.userId,
        isPresident: resident.isPresident,
        isVip: resident.isVip,
      );

      for (int i = 0;
          i < countForThisResident && i < residentQuestions.length;
          i++) {
        questions.add(residentQuestions[i]);
        if (questions.length >= safeTotal) break;
      }
      if (questions.length >= safeTotal) break;
    }

    // If still short of questions, fill up with generator
    if (questions.length < safeTotal) {
      final needed = safeTotal - questions.length;
      final extraRandom = math.Random(residents.first.userId.hashCode);
      final extras = PocketCitadelChallengeGenerator.generateEscortTasks(
        needed,
        extraRandom,
      );
      questions.addAll(extras);
    }

    return questions.take(safeTotal).toList();
  }

  // ---------------------------------------------------------------------------
  // 6. 🚨 EMERGENCY SIREN CHAT BROADCAST SYSTEM
  // ---------------------------------------------------------------------------

  /// Broadcasts an Emergency Siren message to the Island Resident Group Chat
  Future<void> broadcastIslandSirenAlert({
    required String islandId,
    required String islandName,
    required String planetCode,
    required String attackerName,
    required int remainingHp,
    required int totalHp,
    required bool isConquered,
  }) async {
    try {
      final String alertText = isConquered
          ? '💥 ISLAND CONQUERED: Our Island ($islandName) defenses were breached by $attackerName! 10-Hour Army Defense Shield has been deployed. Regroup at the Army Desk! 🛡️'
          : '🚨 RED ALERT: Our Island ($islandName) is currently under siege by $attackerName! Defense HP: $remainingHp / $totalHp remaining. All residents defend! ⚔️';

      // Send to Cosmos Island group channel or general feed
      await SupaFlow.client.from('cosmos_island_alerts').insert({
        'island_id': islandId,
        'island_name': islandName,
        'planet_code': planetCode,
        'attacker_name': attackerName,
        'remaining_hp': remainingHp,
        'total_hp': totalHp,
        'is_conquered': isConquered,
        'alert_message': alertText,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('🚨 [IslandAttackService] Broadcast siren alert: $alertText');
    } catch (_) {
      // Fallback local logging
      debugPrint('🚨 [IslandAttackService] Local siren alert triggered');
    }
  }
}

