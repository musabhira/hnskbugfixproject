import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';

/// 🛡️ Citadel Store Defense Item Model (Clash of Clans Military Armory)
class CitadelDefenseItem {
  final String id;
  final String name;
  final String nameMl;
  final String icon;
  final int pricePS;
  final int extraGates;
  final String challengeType;
  final String description;
  final String benefitEn;
  final String benefitMl;
  final Color themeColor;

  const CitadelDefenseItem({
    required this.id,
    required this.name,
    required this.nameMl,
    required this.icon,
    required this.pricePS,
    required this.extraGates,
    required this.challengeType,
    required this.description,
    required this.benefitEn,
    required this.benefitMl,
    required this.themeColor,
  });
}

/// ⚔️ Central Service managing Citadel Store Purchases & Equipped Defenses
class PocketCitadelStoreService {
  static final PocketCitadelStoreService instance =
      PocketCitadelStoreService._internal();
  factory PocketCitadelStoreService() => instance;
  PocketCitadelStoreService._internal();

  /// 🏛️ Official Catalog of Citadel Defenses available for purchase with Pocket Score
  static const List<CitadelDefenseItem> catalog = [
    CitadelDefenseItem(
      id: 'iron_dome',
      name: 'Iron Dome Missile Shield',
      nameMl: 'അയേൺ ഡോം മിസൈൽ ഷീൽഡ്',
      icon: '🚀',
      pricePS: 500,
      extraGates: 3,
      challengeType: 'Radar Intercept',
      description:
          'Air-defense radar system that fires interceptor missiles. Equips an active Iron Dome Shield and adds 3 radar interception defense traps to your citadel!',
      benefitEn: 'Activates Iron Dome Shield + Adds 3 Radar Defense Gates',
      benefitMl: 'അയേൺ ഡോം ഷീൽഡ് നൽകുന്നു + 3 അധിക റഡാർ ഡിഫൻസ് ഗേറ്റുകൾ കൂട്ടിച്ചേർക്കുന്നു',
      themeColor: Color(0xFF38BDF8),
    ),
    CitadelDefenseItem(
      id: 'gatling_turret',
      name: 'Dual Gatling Plasma Turret',
      nameMl: 'ഡ്യുവൽ ഗാറ്റ്‌ലിങ് പ്ലാസ്മ ടററ്റ്',
      icon: '🔫',
      pricePS: 350,
      extraGates: 2,
      challengeType: 'Rapid-Fire Vocab',
      description:
          'Automated twin-barrel plasma turret firing laser rounds. Forces invading attackers through 2 rapid-fire vocabulary challenge gates.',
      benefitEn: '+2 Rapid-Fire Vocabulary Traps to burn enemy raid time',
      benefitMl: '+2 റാപ്പിഡ്-ഫയർ വൊക്കാബുലറി ട്രാപ്പുകൾ (റൈഡറുടെ സമയം കുറയ്ക്കുന്നു)',
      themeColor: Color(0xFFEF4444),
    ),
    CitadelDefenseItem(
      id: 'tesla_barrier',
      name: 'Tesla High-Voltage Fence',
      nameMl: 'ടെസ്‌ല ഹൈ-വോൾട്ടേജ് ഫെൻസ്',
      icon: '⚡',
      pricePS: 250,
      extraGates: 2,
      challengeType: 'EMP Shockwave',
      description:
          'Electric shock perimeter fence. Hits invading attackers with 2 high-voltage EMP grammar puzzle traps.',
      benefitEn: '+2 High-Voltage EMP Grammar Gates to shock invaders',
      benefitMl: '+2 ഹൈ-വോൾട്ടേജ് ഇ.എം.പി ഗ്രാമർ ഗേറ്റുകൾ കോട്ടയ്ക്ക് സംരക്ഷണം നൽകുന്നു',
      themeColor: Color(0xFFFBBF24),
    ),
    CitadelDefenseItem(
      id: 'cyber_droid',
      name: 'Cyber Sentinel Air Droid',
      nameMl: 'സൈബർ സെന്റിനൽ എയർ ഡ്രോയിഡ്',
      icon: '🤖',
      pricePS: 400,
      extraGates: 2,
      challengeType: 'Drone Audio Scan',
      description:
          'Autonomous aerial guardian patrolling the citadel skies. Challenges invaders with 2 voice audio verification gates.',
      benefitEn: '+2 Audio Verification Gates & Citadel Air Surveillance',
      benefitMl: '+2 ലിസണിങ് / സ്പീക്കിങ് വെരിഫിക്കേഷൻ ഗേറ്റുകൾ കോട്ടയ്ക്ക് നൽകുന്നു',
      themeColor: Color(0xFFA855F7),
    ),
    CitadelDefenseItem(
      id: 'fortress_moat',
      name: 'Deep Bastion Moat & Spikes',
      nameMl: 'ഡീപ്പ് ബാസ്റ്റ്യൻ മോട്ട് & സ്പൈക്ക്സ്',
      icon: '🏰',
      pricePS: 200,
      extraGates: 2,
      challengeType: 'Drawbridge Riddle',
      description:
          'Heavy spiked trench defending the entrance. Requires answering 2 gatekeeper sentence traps to cross.',
      benefitEn: '+2 Drawbridge Sentence Traps & Heavy Wall Armor',
      benefitMl: '+2 ഡ്രോബ്രിഡ്ജ് സെന്റൻസ് ട്രാപ്പുകൾ (കോട്ടമതിലിന്റെ കരുത്ത് വർദ്ധിപ്പിക്കുന്നു)',
      themeColor: Color(0xFF10B981),
    ),
    CitadelDefenseItem(
      id: 'fortress_repair',
      name: 'Nano Fortress Repair Kit',
      nameMl: 'നാനോ ഫോർട്രസ്സ് റിപ്പയർ കിറ്റ്',
      icon: '🛠️',
      pricePS: 150,
      extraGates: 0,
      challengeType: 'Citadel Health 100%',
      description:
          'Instantly restores damaged walls, brings Citadel HP to 100% and clears all attack cracks!',
      benefitEn: 'Restores 100% Citadel HP & clears battle raid damage',
      benefitMl: 'കോട്ടയുടെ HP 100% ആക്കുകയും തകർച്ച പൂർണ്ണമായി നന്നാക്കുകയും ചെയ്യുന്നു',
      themeColor: Color(0xFF0284C7),
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

      // Default: If they own items, equip military items
      final owned = await getOwnedDefenses(userId: uid);
      return owned.where((id) => id != 'fortress_repair').toList();
    } catch (_) {
      return [];
    }
  }

  /// 🧮 Total extra defense gates granted by equipped items
  Future<int> getTotalEquippedGates({String? userId}) async {
    final equipped = await getEquippedDefenses(userId: userId);
    int total = 0;
    for (final id in equipped) {
      final match = catalog.where((item) => item.id == id).toList();
      if (match.isNotEmpty) {
        total += match.first.extraGates;
      }
    }
    return total;
  }

  /// 🛡️ Check if Iron Dome is equipped
  Future<bool> hasIronDomeEquipped({String? userId}) async {
    final equipped = await getEquippedDefenses(userId: userId);
    return equipped.contains('iron_dome');
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

      // Handle Instant Repair Kit specially
      if (item.id == 'fortress_repair') {
        await prefs.setBool('pocket_home_damaged_$uid', false);
        if (uid.isNotEmpty) {
          try {
            await SupaFlow.client.from('pocket_homes').update({
              'hp': 100,
              'stage': 'repaired',
              'is_damaged': false,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('user_id', uid);
          } catch (_) {}
        }
      } else {
        // Add to owned
        final owned = prefs.getStringList('owned_citadel_defenses_$uid') ?? [];
        if (!owned.contains(item.id)) {
          owned.add(item.id);
          await prefs.setStringList('owned_citadel_defenses_$uid', owned);
        }

        // Automatically equip newly purchased defense
        final equipped =
            prefs.getStringList('equipped_citadel_defenses_$uid') ?? [];
        if (!equipped.contains(item.id)) {
          equipped.add(item.id);
          await prefs.setStringList('equipped_citadel_defenses_$uid', equipped);
        }

        // If Iron Dome, activate real active shield
        if (item.id == 'iron_dome') {
          await prefs.setBool('pocket_shield_active_$uid', true);
          if (uid.isNotEmpty) {
            try {
              await SupaFlow.client.from('pocket_homes').update({
                'has_shield': true,
                'shield_until': DateTime.now()
                    .add(const Duration(days: 7))
                    .toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('user_id', uid);
            } catch (_) {}
          }
        }
      }

      // Sync updated Pocket Score to Supabase in background
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
    if (defenseId == 'fortress_repair') return;
    final uid = SupaFlow.client.auth.currentUser?.id ?? '';
    final prefs = await SharedPreferences.getInstance();
    final equipped =
        prefs.getStringList('equipped_citadel_defenses_$uid') ?? [];

    if (equipped.contains(defenseId)) {
      equipped.remove(defenseId);
      if (defenseId == 'iron_dome') {
        await prefs.setBool('pocket_shield_active_$uid', false);
      }
    } else {
      equipped.add(defenseId);
      if (defenseId == 'iron_dome') {
        await prefs.setBool('pocket_shield_active_$uid', true);
      }
    }
    await prefs.setStringList('equipped_citadel_defenses_$uid', equipped);
    HapticFeedback.selectionClick();
  }
}
