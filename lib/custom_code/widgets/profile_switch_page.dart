import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

class ProfileSwitchPage extends StatefulWidget {
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
  State<ProfileSwitchPage> createState() => _ProfileSwitchPageState();
}

class _ProfileSwitchPageState extends State<ProfileSwitchPage> {
  int _day = 1;
  String _name = 'Defender';
  String _bio = 'Learning English everyday!';
  String _paletteId = 'stone_castle';
  bool _isVip = false;
  int _streak = 1;
  String _rank = 'Citizen';

  @override
  void initState() {
    super.initState();
    _initFromProfile();
    _loadFullUserData();
  }

  void _initFromProfile() {
    final p = widget.preloadedProfile ?? {};
    final rawDay = (p['learning_day'] as num?)?.toInt() ??
        (p['learning_stage'] as num?)?.toInt() ??
        (p['stage'] as num?)?.toInt() ??
        (p['level'] as num?)?.toInt() ??
        (p['day'] as num?)?.toInt() ??
        1;
    _day = rawDay > 0 ? rawDay : 1;
    _name = p['first_name']?.toString() ??
        p['name']?.toString() ??
        p['display_name']?.toString() ??
        (SupaFlow.client.auth.currentUser?.email?.split('@').first ?? 'Defender');
    _bio = p['bio']?.toString() ?? 'Learning English everyday!';
    _streak = (p['streak'] as num?)?.toInt() ?? _day;
    _rank = p['rank']?.toString() ?? 'Citizen';
    _isVip = p['is_vip'] == true || p['is_premium'] == true;

    final palList = HousePalette.presets;
    final autoPal = palList[(_day - 1) % palList.length].id;
    _paletteId = p['palette_id']?.toString() ?? autoPal;
  }

  Future<void> _loadFullUserData() async {
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    final prefs = await SharedPreferences.getInstance();

    int? resolvedDay;
    if (currentUserId.isNotEmpty) {
      resolvedDay = prefs.getInt('learning_day_$currentUserId') ??
          prefs.getInt('day_$currentUserId');
    }
    resolvedDay ??= prefs.getInt('learning_day') ??
        prefs.getInt('current_learning_day') ??
        prefs.getInt('day') ??
        prefs.getInt('kCurrentLearningDay');

    // Fetch latest profile from Supabase
    if (currentUserId.isNotEmpty) {
      try {
        final res = await SupaFlow.client
            .from('profile')
            .select('learning_day, day, stage, level, first_name, name, display_name, bio, streak, rank, palette_id, is_vip, is_premium, pocket_score')
            .or('user_id.eq.$currentUserId,id.eq.$currentUserId')
            .maybeSingle();
        if (res != null) {
          final dbDay = (res['learning_day'] as num?)?.toInt() ??
              (res['day'] as num?)?.toInt() ??
              (res['stage'] as num?)?.toInt() ??
              (res['level'] as num?)?.toInt();
          if (dbDay != null && dbDay > 0) {
            resolvedDay = dbDay;
          }
          final dbName = res['first_name'] ?? res['name'] ?? res['display_name'];
          if (dbName != null && dbName.toString().isNotEmpty) {
            _name = dbName.toString();
          }
          if (res['bio'] != null) _bio = res['bio'].toString();
          if (res['streak'] != null) _streak = (res['streak'] as num).toInt();
          if (res['rank'] != null) _rank = res['rank'].toString();
          if (res['palette_id'] != null) _paletteId = res['palette_id'].toString();
          if (res['is_vip'] == true || res['is_premium'] == true) _isVip = true;
        }
      } catch (_) {}
    }

    if (resolvedDay != null && resolvedDay > 0 && resolvedDay != _day) {
      if (mounted) {
        setState(() {
          _day = resolvedDay!;
          final palList = HousePalette.presets;
          final autoPal = palList[(_day - 1) % palList.length].id;
          if (_paletteId == 'stone_castle' || _paletteId.isEmpty) {
            _paletteId = autoPal;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    final myNeighbor = PocketNeighbor(
      id: currentUserId,
      name: _name,
      day: _day,
      streak: _streak,
      rank: _rank,
      paletteId: _paletteId,
      isMe: true,
      hasActiveShield: true,
      statusMessage: _bio,
      hp: 100,
      maxHp: 100,
      isVip: _isVip,
    );

    return PocketCitadelAttackPage(
      neighbor: myNeighbor,
      attackerDay: _day,
      isDefenseMode: true,
    );
  }
}
