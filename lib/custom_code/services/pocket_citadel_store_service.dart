import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';

/// 🛡️ Citadel Store Defense Item Model (Clash of Clans Military Armory)
class CitadelDefenseItem {
  final String id;
  final String name;
  final String icon;
  final int pricePS;
  final int extraGates;
  final String challengeType;
  final String description;
  final Color themeColor;

  const CitadelDefenseItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.pricePS,
    required this.extraGates,
    required this.challengeType,
    required this.description,
    required this.themeColor,
  });
}

/// ⚔️ Central Service managing Citadel Store Purchases & Equipped Defenses
class PocketCitadelStoreService {
  static final PocketCitadelStoreService instance = PocketCitadelStoreService._internal();
  factory PocketCitadelStoreService() => instance;
  PocketCitadelStoreService._internal();

  /// 🏛️ Official Catalog of Citadel Defenses available for purchase with Pocket Score
  static const List<CitadelDefenseItem> catalog = [
    CitadelDefenseItem(
      id: 'iron_dome',
      name: 'Iron Dome Missile Shield',
      icon: '🚀',
      pricePS: 500,
      extraGates: 3,
      challengeType: 'Radar Intercept',
      description: 'Air-defense radar system that fires interceptor missiles. Adds 3 high-speed interception gates to invaders!',
      themeColor: Color(0xFF38BDF8),
    ),
    CitadelDefenseItem(
      id: 'gatling_turret',
      name: 'Dual Gatling Plasma Turret',
      icon: '🔫',
      pricePS: 350,
      extraGates: 2,
      challengeType: 'Rapid-Fire Vocab',
      description: 'Automated twin-barrel rampart turret firing laser rounds. Forces attackers through 2 rapid-fire vocabulary gates.',
      themeColor: Color(0xFFEF4444),
    ),
    CitadelDefenseItem(
      id: 'tesla_barrier',
      name: 'Tesla High-Voltage Fence',
      icon: '⚡',
      pricePS: 250,
      extraGates: 2,
      challengeType: 'EMP Shockwave',
      description: 'Electric shock perimeter. Hits invading attackers with 2 high-voltage grammar puzzle traps.',
      themeColor: Color(0xFFFBBF24),
    ),
    CitadelDefenseItem(
      id: 'cyber_droid',
      name: 'Cyber Sentinel Air Droid',
      icon: '🤖',
      pricePS: 400,
      extraGates: 2,
      challengeType: 'Drone Audio Scan',
      description: 'Autonomous aerial guardian patrolling the citadel skies. Challenges invaders with 2 voice audio verification gates.',
      themeColor: Color(0xFFA855F7),
    ),
    CitadelDefenseItem(
      id: 'fortress_moat',
      name: 'Deep Bastion Moat & Spikes',
      icon: '🏰',
      pricePS: 200,
      extraGates: 2,
      challengeType: 'Drawbridge Riddle',
      description: 'Heavy spiked trench defending the citadel entrance. Requires answering 2 gatekeeper sentence traps to cross.',
      themeColor: Color(0xFF10B981),
    ),
  ];

  /// 📦 Fetch owned defense IDs for a user
  Future<List<String>> getOwnedDefenses({String? userId}) async {
    try {
      final uid = userId ?? SupaFlow.client.auth.currentUser?.id ?? '';
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('owned_citadel_defenses_$uid') ?? [];
    } catch (_) {
      return [];
    }
  }

  /// 🎯 Fetch equipped defense IDs for a user
  Future<List<String>> getEquippedDefenses({String? userId}) async {
    try {
      final uid = userId ?? SupaFlow.client.auth.currentUser?.id ?? '';
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('equipped_citadel_defenses_$uid');
      if (list != null && list.isNotEmpty) return list;

      // Default: If they own items, equip them
      final owned = await getOwnedDefenses(userId: uid);
      return owned;
    } catch (_) {
      return [];
    }
  }

  /// 🪙 Check if user can afford an item
  Future<bool> canAfford(int pricePS) async {
    final currentScore = await getUserPocketScore();
    return currentScore >= pricePS;
  }

  /// 🪙 Get current user's Pocket Score
  Future<int> getUserPocketScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getInt('user_pocket_score');
      if (local != null && local > 0) return local;

      final uid = SupaFlow.client.auth.currentUser?.id;
      if (uid != null) {
        final res = await SupaFlow.client
            .from('users')
            .select('pocket_score')
            .eq('id', uid)
            .maybeSingle();
        if (res != null && res['pocket_score'] != null) {
          final score = (res['pocket_score'] as num).toInt();
          await prefs.setInt('user_pocket_score', score);
          return score;
        }
      }
      return 150; // Base starting score
    } catch (_) {
      return 150;
    }
  }

  /// 🛍️ Purchase a defense item with Pocket Score
  Future<bool> purchaseDefense(CitadelDefenseItem item) async {
    final uid = SupaFlow.client.auth.currentUser?.id ?? '';
    final currentScore = await getUserPocketScore();
    if (currentScore < item.pricePS) return false;

    try {
      final newScore = currentScore - item.pricePS;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_pocket_score', newScore);

      // Add to owned
      final owned = prefs.getStringList('owned_citadel_defenses_$uid') ?? [];
      if (!owned.contains(item.id)) {
        owned.add(item.id);
        await prefs.setStringList('owned_citadel_defenses_$uid', owned);
      }

      // Automatically equip newly purchased defense
      final equipped = prefs.getStringList('equipped_citadel_defenses_$uid') ?? [];
      if (!equipped.contains(item.id)) {
        equipped.add(item.id);
        await prefs.setStringList('equipped_citadel_defenses_$uid', equipped);
      }

      // Sync to Supabase in background
      if (uid.isNotEmpty) {
        try {
          await SupaFlow.client.from('users').update({
            'pocket_score': newScore,
          }).eq('id', uid);
        } catch (_) {}
      }

      HapticFeedback.heavyImpact();
      return true;
    } catch (e) {
      debugPrint('Error purchasing defense: $e');
      return false;
    }
  }

  /// 🔄 Toggle equipped status of an owned defense
  Future<void> toggleEquipped(String defenseId) async {
    final uid = SupaFlow.client.auth.currentUser?.id ?? '';
    final prefs = await SharedPreferences.getInstance();
    final equipped = prefs.getStringList('equipped_citadel_defenses_$uid') ?? [];

    if (equipped.contains(defenseId)) {
      equipped.remove(defenseId);
    } else {
      equipped.add(defenseId);
    }
    await prefs.setStringList('equipped_citadel_defenses_$uid', equipped);
    HapticFeedback.selectionClick();
  }
}
