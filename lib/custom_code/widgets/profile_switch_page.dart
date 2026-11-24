import 'package:flutter/material.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

class ProfileSwitchPage extends StatelessWidget {
  final double width;
  final double height;
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const ProfileSwitchPage({
    super.key,
    required this.width,
    required this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    final p = preloadedProfile ?? {};
    final rawDay = (p['learning_day'] as num?)?.toInt() ??
        (p['learning_stage'] as num?)?.toInt() ??
        (p['stage'] as num?)?.toInt() ??
        (p['level'] as num?)?.toInt() ??
        1;
    final day = rawDay > 0 ? rawDay : 1;
    final name = p['first_name'] ??
        p['name'] ??
        p['display_name'] ??
        (SupaFlow.client.auth.currentUser?.email?.split('@').first ?? 'My Fortress');
    final bio = p['bio']?.toString() ?? 'Learning English everyday!';
    final palList = HousePalette.presets;
    final autoPal = palList[(day - 1) % palList.length].id;
    final chosenPal = p['palette_id']?.toString() ?? autoPal;

    final myNeighbor = PocketNeighbor(
      id: currentUserId,
      name: name,
      day: day,
      streak: (p['streak'] as num?)?.toInt() ?? day,
      rank: p['rank']?.toString() ?? 'Citizen',
      paletteId: chosenPal,
      isMe: true,
      hasActiveShield: true,
      statusMessage: bio,
      hp: 100,
      maxHp: 100,
      isVip: p['is_vip'] == true || p['is_premium'] == true,
    );

    return PocketCitadelAttackPage(
      neighbor: myNeighbor,
      attackerDay: day,
      isDefenseMode: true,
    );
  }
}
