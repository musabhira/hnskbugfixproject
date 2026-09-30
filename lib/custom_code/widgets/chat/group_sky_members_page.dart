import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';

class GroupSkyMembersPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupImage;

  const GroupSkyMembersPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImage,
  });

  @override
  State<GroupSkyMembersPage> createState() => _GroupSkyMembersPageState();
}

class _GroupSkyMembersPageState extends State<GroupSkyMembersPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String _currentUserId = '';
  bool _canInitiatePocketTalk = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _fetchGroupMembers();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroupMembers() async {
    setState(() => _isLoading = true);
    if (_currentUserId.isNotEmpty) {
      _canInitiatePocketTalk =
          await PocketTrophyService.canInitiateNewPact(_currentUserId);
    }
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('group_members')
          .select('''
            id,
            user_id,
            profile_id,
            role,
            profile:profile!profile_id(
              id,
              user_id,
              name,
              profile_image_url,
              pocket_score,
              learning_points,
              xp,
              learning_day,
              learning_stage,
              stage,
              level,
              avatar_config
            )
          ''')
          .eq('group_id', widget.groupId)
          .eq('is_active', true);

      final List raw = response as List;
      final List<Map<String, dynamic>> memberList = [];
      final List<String> missingProfileUserIds = [];

      for (final m in raw) {
        final profile = m['profile'];
        final uid = m['user_id']?.toString() ??
            (profile != null ? profile['user_id']?.toString() : null) ??
            m['profile_id']?.toString() ??
            '';

        if (profile == null && uid.isNotEmpty) {
          missingProfileUserIds.add(uid);
        }

        memberList.add({
          'member_id': m['id'],
          'user_id': uid,
          'role': m['role'] ?? 'member',
          'profile': profile is Map ? Map<String, dynamic>.from(profile) : null,
        });
      }

      // Fetch any missing profiles in bulk
      if (missingProfileUserIds.isNotEmpty) {
        try {
          final missingProfiles = await supabase
              .from('profile')
              .select('id, user_id, name, profile_image_url, stage, level, xp, avatar_config')
              .inFilter('user_id', missingProfileUserIds);

          final profileMap = <String, Map<String, dynamic>>{};
          for (final p in missingProfiles as List) {
            final pUid = p['user_id']?.toString() ?? '';
            if (pUid.isNotEmpty) {
              profileMap[pUid] = Map<String, dynamic>.from(p);
            }
          }

          for (final m in memberList) {
            if (m['profile'] == null && profileMap.containsKey(m['user_id'])) {
              m['profile'] = profileMap[m['user_id']];
            }
          }
        } catch (e) {
          debugPrint('Error fetching missing profiles: $e');
        }
      }

      if (mounted) {
        setState(() {
          _members.clear();
          _members.addAll(memberList);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading group sky members: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onAttackMember(String targetUserId, String targetName) {
    if (targetUserId.isEmpty) return;
    if (targetUserId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚔️ You cannot attack your own citadel!"),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    PocketCitadelAttackPage.openForUser(
      context,
      userId: targetUserId,
      targetName: targetName,
    );
  }

  Future<void> _onPocketTalkMember(
    String targetUserId,
    String targetName,
    String? targetImage,
  ) async {
    if (targetUserId.isEmpty) return;
    if (targetUserId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚡ You cannot challenge yourself to Pocket Talk!"),
          backgroundColor: Color(0xFFFFB300),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final canStart =
        await PocketTrophyService.canInitiateNewPact(_currentUserId);
    if (!canStart) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "⚡ You already have 3 active Pocket Talks running! Complete an agreement first."),
          backgroundColor: Color(0xFFFFB300),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    try {
      await PocketTrophyService.requestPact(
        myId: _currentUserId,
        otherUserId: targetUserId,
        autoAccept: false,
      );

      if (!mounted) return;

      // Navigate straight to the personal chat with this user
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatsAppGroupChat(
            groupId: 'p:$targetUserId',
            groupName: targetName,
            groupImage: targetImage,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚡ Pocket Talk invite sent to $targetName!"),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error sending Pocket Talk invite: $e');
    }
  }

  VectorAvatarConfig _resolveAvatarConfig(Map<String, dynamic>? profile, String userId) {
    if (PocketPresidentService.isPresidentId(userId)) {
      return VectorAvatarConfig.getEvolutionAvatarForStage(90);
    }
    if (PocketRobotService.isRobotId(userId)) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      final dynLvl = PocketRobotService.getDynamicLevel(robot);
      return VectorAvatarConfig.getEvolutionAvatarForStage(dynLvl);
    }
    if (profile != null) {
      if (profile['avatar_config'] != null && profile['avatar_config'] is Map) {
        try {
          return VectorAvatarConfig.fromMap(
              Map<String, dynamic>.from(profile['avatar_config']));
        } catch (_) {}
      }
      final stage = (profile['stage'] ?? profile['level'] ?? 1);
      final stageInt = int.tryParse(stage.toString()) ?? 1;
      return VectorAvatarConfig.getEvolutionAvatarForStage(stageInt);
    }
    return const VectorAvatarConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: Stack(
        children: [
          // 🌤️ Sky & Cloud Animated Background
          _buildSkyBackground(),

          // Foreground Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFB300),
                          ),
                        )
                      : _members.isEmpty
                          ? _buildEmptyState()
                          : _buildMembersGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkyBackground() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final val = _animController.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B192C), // Deep night sky
                Color(0xFF1E3E62), // Atmospheric twilight
                Color(0xFF070D18), // Ground horizon
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating Cloud 1 (Top Left)
              Positioned(
                top: 60 + (val * 15),
                left: -40 + (val * 20),
                child: Opacity(
                  opacity: 0.18,
                  child: _buildCloudShape(width: 240, height: 110),
                ),
              ),
              // Floating Cloud 2 (Top Right)
              Positioned(
                top: 140 - (val * 20),
                right: -60 + (val * 15),
                child: Opacity(
                  opacity: 0.14,
                  child: _buildCloudShape(width: 280, height: 130),
                ),
              ),
              // Floating Cloud 3 (Mid Floating)
              Positioned(
                bottom: 120 + (val * 25),
                left: 30 - (val * 10),
                child: Opacity(
                  opacity: 0.10,
                  child: _buildCloudShape(width: 320, height: 140),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloudShape({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              padding: const EdgeInsets.all(10),
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
                        widget.groupName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('☁️', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text(
                  'Sky Alliance Members (${_members.length})',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Raid/Pact',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: Colors.white30),
          const SizedBox(height: 12),
          Text(
            'No Alliance Members Found',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Invite mates to this group to raid and make pacts!',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final uid = member['user_id']?.toString() ?? '';
        final profile = member['profile'] as Map<String, dynamic>?;
        final name = profile?['name']?.toString() ??
            (uid == _currentUserId ? 'You' : 'Pocket Mate');
        final imageUrl = profile?['profile_image_url']?.toString();
        final avatarConfig = _resolveAvatarConfig(profile, uid);
        final stage = profile?['stage'] ?? profile?['level'] ?? 1;
        final xp = profile?['xp'] ?? 0;
        final isMe = uid == _currentUserId;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131D31).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isMe
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.12),
              width: isMe ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, err) =>
                                  VectorAvatarWidget(
                                config: avatarConfig,
                                size: 62,
                              ),
                            )
                          : VectorAvatarWidget(
                              config: avatarConfig,
                              size: 62,
                            ),
                    ),
                  ),
                  if (member['role'] == 'admin')
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                isMe ? '$name (You)' : name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // Level / Stage
              Text(
                'Stage $stage • $xp XP',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFB300),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Action Buttons
              if (isMe)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Your Profile',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else ...[
                // Attack Button
                GestureDetector(
                  onTap: () => _onAttackMember(uid, name),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3D00).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚔️', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          'Attack',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!PocketRobotService.isRobotId(uid) &&
                    !PocketPresidentService.isPresidentId(uid) &&
                    _canInitiatePocketTalk) ...[
                  const SizedBox(height: 6),
                  // Pocket Talk Button
                  GestureDetector(
                    onTap: () => _onPocketTalkMember(uid, name, imageUrl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            'Pocket Talk',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFB300),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
