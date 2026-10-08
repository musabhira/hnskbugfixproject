import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⚡ Model representing a learner candidate card in the Pocket Talk deck
class PocketTalkCandidate {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final VectorAvatarConfig avatarConfig;
  final int dayLevel;
  final int pocketScore;
  final String speciesTitle;
  final String goals;
  final String bio;
  bool isRequestSent;
  bool isMateRequestSent;

  PocketTalkCandidate({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.avatarConfig,
    required this.dayLevel,
    this.pocketScore = 120,
    required this.speciesTitle,
    required this.goals,
    required this.bio,
    this.isRequestSent = false,
    this.isMateRequestSent = false,
  });
}

/// 🃏 3D Holographic Cyber Cat Stacked Swipeable Card Deck for Pocket Talk Match
class PocketTalkCardSwiperDialog extends StatefulWidget {
  const PocketTalkCardSwiperDialog({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PocketTalkSwiper',
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) => const PocketTalkCardSwiperDialog(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  State<PocketTalkCardSwiperDialog> createState() => _PocketTalkCardSwiperDialogState();
}

class _PocketTalkCardSwiperDialogState extends State<PocketTalkCardSwiperDialog>
    with SingleTickerProviderStateMixin {
  final _supabase = SupaFlow.client;

  List<PocketTalkCandidate> _candidates = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _activePactCount = 0;

  // Swipe gesture tracking
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _loadCandidates();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _recordSwiped(String candidateId) async {
    try {
      final myId = _supabase.auth.currentUser?.id ?? '';
      if (myId.isEmpty || candidateId.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final key = 'pocket_talk_swiped_ids_$myId';
      final current = prefs.getStringList(key) ?? [];
      if (!current.contains(candidateId)) {
        current.add(candidateId);
        if (current.length > 120) {
          current.removeRange(0, current.length - 120);
        }
        await prefs.setStringList(key, current);
      }
    } catch (_) {}
  }

  Future<void> _loadCandidates() async {
    final myId = _supabase.auth.currentUser?.id ?? '';
    int activeCount = 0;
    if (myId.isNotEmpty) {
      final activeIds = await PocketTrophyService.getAllActiveAcceptedPactUserIds(myId);
      activeCount = activeIds.length;
    }

    final prefs = await SharedPreferences.getInstance();
    final swipedKey = 'pocket_talk_swiped_ids_$myId';
    List<String> swipedList = prefs.getStringList(swipedKey) ?? [];
    Set<String> swipedIds = swipedList.toSet();

    final List<PocketTalkCandidate> list = [];
    final Set<String> seenUserIds = {};
    final Set<String> seenNames = {};
    final Set<String> seenFirstNames = {};

    try {
      // 1. Fetch real community profiles
      final profiles = await _supabase
          .from('profile')
          .select('user_id, name, profile_image_url, avatar_config, bio, pocket_score, learning_day')
          .limit(50);

      final existingList = profiles as List<dynamic>? ?? [];

      for (var p in existingList) {
        final uid = p['user_id']?.toString().trim() ?? '';
        if (uid.isEmpty || uid == myId) continue;
        if (PocketRobotService.isRobotId(uid)) continue;
        if (seenUserIds.contains(uid)) continue;
        if (swipedIds.contains(uid)) continue;

        final rawName = (p['name']?.toString() ?? '').trim();
        if (rawName.isEmpty) continue;

        // Clean name of zero-width characters, numbers, and symbols
        final cleanName = rawName
            .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
            .replaceAll(RegExp(r'[^a-zA-Z\s]'), '')
            .trim();
        if (cleanName.length < 2) continue;

        final fullNameLower = cleanName.toLowerCase();
        final firstNameLower = fullNameLower.split(RegExp(r'\s+')).first;

        // Block generic dummy names from repeating
        const blockedNames = {
          'community', 'learner', 'user', 'test', 'tester', 'admin',
          'unknown', 'anonymous', 'guest', 'student', 'demo', 'null', 'sample'
        };
        if (blockedNames.contains(firstNameLower) || blockedNames.contains(fullNameLower)) {
          continue;
        }

        // Strict first-name and full-name de-duplication: NO TWO USERS SHARE SAME FIRST NAME
        if (seenNames.contains(fullNameLower) || seenFirstNames.contains(firstNameLower)) {
          continue;
        }

        // Check if existing pact
        if (myId.isNotEmpty) {
          final pact = await PocketTrophyService.getPact(myId, uid);
          if (pact != null && pact.isAccepted) continue;
        }

        seenUserIds.add(uid);
        seenNames.add(fullNameLower);
        seenFirstNames.add(firstNameLower);

        // Candidate's level & avatar strictly match their real level
        final rawScore = (p['pocket_score'] as num?)?.toInt() ?? 0;
        final rawDay = (p['learning_day'] as num?)?.toInt();
        final calculatedLevel = PocketScoreLevelEngine.getLevelFromScore(rawScore);
        final candidateDay = (rawDay != null && rawDay > 0)
            ? rawDay.clamp(1, 90)
            : calculatedLevel.clamp(1, 90);

        VectorAvatarConfig config;
        if (p['avatar_config'] != null) {
          try {
            config = VectorAvatarConfig.fromMap(Map<String, dynamic>.from(p['avatar_config']));
          } catch (_) {
            config = VectorAvatarConfig.getEvolutionAvatarForStage(candidateDay);
          }
        } else {
          config = VectorAvatarConfig.getEvolutionAvatarForStage(candidateDay);
        }

        list.add(
          PocketTalkCandidate(
            id: uid,
            userId: uid,
            name: cleanName,
            avatarUrl: p['profile_image_url']?.toString(),
            avatarConfig: config,
            dayLevel: candidateDay,
            pocketScore: rawScore > 0 ? rawScore : candidateDay * 120,
            speciesTitle: _getSpeciesTitle(config.species, candidateDay),
            goals: _getLearnerGoal(candidateDay),
            bio: (p['bio'] != null && p['bio'].toString().isNotEmpty)
                ? p['bio'].toString()
                : 'Passionate about English fluency & 4-day spoken challenges.',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching candidate profiles: $e');
    }

    // 2. Supplement with distinct unique Cyber Cat & Mythic Evolution Deck candidates
    // Expanded unique name pool with zero repetition across first names
    final samplePool = [
      'Aarav Sharma', 'Meera Nair', 'Rohan Varma', 'Ananya Menon',
      'Devika Pillai', 'Kiran Kumar', 'Siddharth Roy', 'Sneha Patel',
      'Aditi Rao', 'Farhan Ali', 'Tara Joshi', 'Vivek Iyer',
      'Nandita Bose', 'Arjun Das', 'Rhea Sen', 'Gautam Nambiar',
      'Pooja Hegde', 'Nikhil Chandran', 'Aparna Balan', 'Kavya Madhavan',
      'Pranav Mohan', 'Lakshmi Prasad', 'Vikram Seth', 'Sanjana Reddy',
      'Harish Kurup', 'Deepa Warrier', 'Suraj Varma', 'Gayathri Suresh',
      'Ashwin Menon', 'Reshma R Nair', 'Naveen George', 'Anjali Thomas',
    ];

    final stageDistribution = [
      14, 28, 42, 15, 35, 21, 50, 12, 65, 18, 77, 31, 25, 82, 44,
      19, 58, 22, 39, 48, 16, 88, 27, 33, 61, 53, 29, 70, 24, 38, 45, 14
    ];

    for (int i = 0; i < samplePool.length; i++) {
      if (list.length >= 28) break;
      final name = samplePool[i].trim();
      final fullNameLower = name.toLowerCase();
      final firstNameLower = fullNameLower.split(RegExp(r'\s+')).first;

      if (seenNames.contains(fullNameLower) || seenFirstNames.contains(firstNameLower)) {
        continue;
      }

      final stage = stageDistribution[i % stageDistribution.length];
      final dummyUid = 'candidate_deck_${stage}_${name.replaceAll(' ', '_')}';
      if (seenUserIds.contains(dummyUid)) continue;
      if (swipedIds.contains(dummyUid)) continue;

      seenNames.add(fullNameLower);
      seenFirstNames.add(firstNameLower);
      seenUserIds.add(dummyUid);

      final config = VectorAvatarConfig.getEvolutionAvatarForStage(stage);
      list.add(
        PocketTalkCandidate(
          id: dummyUid,
          userId: dummyUid,
          name: name,
          avatarConfig: config,
          dayLevel: stage,
          pocketScore: stage * 135 + 40,
          speciesTitle: _getSpeciesTitle(config.species, stage),
          goals: _getLearnerGoal(stage),
          bio: 'Practicing spoken conversation daily. Excited to complete 4-day pacts and mint Gold Trophies! 🏆',
        ),
      );
    }

    // If all candidates were previously swiped and deck is dry, cycle swiped cache
    if (list.isEmpty && swipedIds.isNotEmpty) {
      await prefs.remove(swipedKey);
      return _loadCandidates();
    }

    // 🌟 Thoroughly shuffle so community profiles and diverse archetypes are mixed with zero repetition
    list.shuffle(math.Random(DateTime.now().millisecondsSinceEpoch));

    // 🌟 Sanity check: Guarantee no two adjacent cards share the same first name or same dayLevel
    for (int i = 0; i < list.length - 1; i++) {
      final curFirst = list[i].name.split(RegExp(r'\s+')).first.toLowerCase();
      final nextFirst = list[i + 1].name.split(RegExp(r'\s+')).first.toLowerCase();
      if (curFirst == nextFirst || list[i].dayLevel == list[i + 1].dayLevel) {
        for (int j = i + 2; j < list.length; j++) {
          final candFirst = list[j].name.split(RegExp(r'\s+')).first.toLowerCase();
          if (candFirst != curFirst && list[j].dayLevel != list[i].dayLevel) {
            final temp = list[i + 1];
            list[i + 1] = list[j];
            list[j] = temp;
            break;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _candidates = list;
        _activePactCount = activeCount;
        _isLoading = false;
      });
    }
  }

  String _getSpeciesTitle(String species, int day) {
    if (species == 'cyber_cat' || day == 14 || day == 15) return 'Cyber Cat #$day';
    if (day == 90) return 'Astral Cosmic Dragon';
    if (day >= 60) return 'Sovereign Lazy Lion';
    if (day >= 30) return 'Rainbow King Ape';
    if (day >= 21) return 'Habit Polka Doge';
    final formatted = species
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
    return '$formatted #$day';
  }

  String _getLearnerGoal(int day) {
    if (day > 60) return 'Mastering advanced debate & spontaneous speaking';
    if (day > 30) return 'Building fluent work presentation & storytelling skills';
    if (day > 14) return '15 mins daily English habit • Zero hesitation target';
    return 'Starting 4-Day Spoken Pact • Daily 15-min speaking practice';
  }

  Color _getRarityColor(VectorAvatarConfig config) {
    if (config.species == 'cyber_cat' ||
        config.rarityTier.toLowerCase().contains('cyber cat')) {
      return const Color(0xFFEC4899); // Tokyo Cyberpunk Pink
    }
    final tier = config.rarityTier.toLowerCase();
    if (tier.contains('mythic')) return const Color(0xFF00E5FF);
    if (tier.contains('legendary')) return const Color(0xFFFFD700);
    if (tier.contains('epic')) return const Color(0xFFD946EF);
    if (tier.contains('rare')) return const Color(0xFF38BDF8);
    return const Color(0xFFFFFC00); // Cyber Yellow
  }

  Future<void> _sendPocketTalkRequest(PocketTalkCandidate candidate) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || myId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to challenge Pocket Talk partners.')),
      );
      return;
    }

    final canStart = await PocketTrophyService.canInitiateNewPact(myId);
    if (!canStart) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFFFC00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚡ You already have 4 active Poketalk pacts! Complete Day 4 before initiating another.',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    HapticFeedback.heavyImpact();

    setState(() {
      candidate.isRequestSent = true;
    });
    _recordSwiped(candidate.userId);

    String myName = 'Pocket Mate';
    try {
      final p = await _supabase.from('profile').select('name').eq('user_id', myId).maybeSingle();
      if (p != null && p['name'] != null) myName = p['name'];
    } catch (_) {}

    await PocketTrophyService.requestPact(
      myId: myId,
      otherUserId: candidate.userId,
    );

    await PocketMateService.sendMateRequest(
      senderId: myId,
      receiverId: candidate.userId,
      senderName: myName,
      receiverName: candidate.name,
      receiverAvatarUrl: candidate.avatarUrl,
      message: 'Challenged you to a 4-Day Spoken English Pact ⚡ (15 mins/day). Check your Poketalk tab!',
      contextType: 'pocket_talk',
    );

    // Save to SharedPreferences sent cache so it appears instantly under Sent tab
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentKey = 'poket_talk_sent_candidates_$myId';
      final currentSentJson = prefs.getStringList(sentKey) ?? [];
      final candidateMap = {
        'id': candidate.userId,
        'user_id': candidate.userId,
        'receiver_id': candidate.userId,
        'receiver_name': candidate.name,
        'receiver_avatar': candidate.avatarUrl,
        'context_type': 'pocket_talk',
        'message': '⚡ 4-Day Spoken English Pact Request (Pending)',
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      };
      currentSentJson.removeWhere((item) => item.contains(candidate.userId));
      currentSentJson.insert(0, jsonEncode(candidateMap));
      await prefs.setStringList(sentKey, currentSentJson);
    } catch (_) {}

    // Ensure conversation exists so it appears instantly under Sent tab
    try {
      final nowIso = DateTime.now().toIso8601String();
      const pactAnnouncement =
          '⚡ PocketTalk Request Sent 🤝 Waiting for acceptance (4-Day Spoken Pact • 15 mins/day)';
      final existing = await _supabase
          .from('conversations')
          .select('id')
          .or('and(user1_id.eq.$myId,user2_id.eq.${candidate.userId}),and(user1_id.eq.${candidate.userId},user2_id.eq.$myId)')
          .maybeSingle();
      dynamic convId = existing != null ? existing['id'] : null;
      if (existing == null) {
        final inserted = await _supabase.from('conversations').insert({
          'user1_id': myId,
          'user2_id': candidate.userId,
          'last_message': pactAnnouncement,
          'last_message_time': nowIso,
          'last_sender_id': myId,
          'unread_count': 0,
          'updated_at': nowIso,
          'is_group': false,
        }).select('id').maybeSingle();
        if (inserted != null) convId = inserted['id'];
      } else {
        await _supabase.from('conversations').update({
          'last_message': pactAnnouncement,
          'last_message_time': nowIso,
          'last_sender_id': myId,
          'updated_at': nowIso,
        }).eq('id', existing['id']);
      }

      // Insert announcement row into messages table
      try {
        await _supabase.from('messages').insert({
          if (convId != null) 'conversation_id': convId,
          'sender_id': myId,
          'receiver_id': candidate.userId,
          'content': pactAnnouncement,
          'message_text': pactAnnouncement,
          'message_type': 'text',
        });
      } catch (_) {}
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '4-Day Spoken Pact Request sent to ${candidate.name}! They will see it in their Poketalk ⚡ tab.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2438),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Auto-advance to next card after a brief moment
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _swipeCard(isLike: true);
    });
  }

  /// 🤝 Send Mate connection request (User Audio Directive: Mate option on card)
  Future<void> _sendMateRequest(PocketTalkCandidate candidate) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || myId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to connect with mates.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      candidate.isMateRequestSent = true;
    });
    _recordSwiped(candidate.userId);

    String myName = 'Pocket Mate';
    try {
      final p = await _supabase.from('profile').select('name').eq('user_id', myId).maybeSingle();
      if (p != null && p['name'] != null) myName = p['name'];
    } catch (_) {}

    await PocketMateService.sendMateRequest(
      senderId: myId,
      receiverId: candidate.userId,
      senderName: myName,
      receiverName: candidate.name,
      receiverAvatarUrl: candidate.avatarUrl,
      message: 'Sent you a Mate connection request from Pocket Talk Cards! 🤝',
      contextType: 'mate_request',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mate request sent to ${candidate.name}! They will see it in Requests tab.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2438),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _swipeCard({required bool isLike}) {
    HapticFeedback.selectionClick();
    if (_currentIndex < _candidates.length) {
      _recordSwiped(_candidates[_currentIndex].userId);
    }
    setState(() {
      _dragOffset = Offset.zero;
      _dragAngle = 0.0;
      if (_currentIndex < _candidates.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = _candidates.length; // Reached end of deck
      }
    });
  }

  void _openProfile(PocketTalkCandidate candidate) {
    if (candidate.userId.startsWith('candidate_deck_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Private Profile • Complete a 4-day pact with ${candidate.name} to view full showcase!'),
          backgroundColor: const Color(0xFF1E2438),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainProfileWidget(userId: candidate.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 36).clamp(300.0, 390.0);
    // User Directive: Fixed height for the card, avoiding Expanded and bottom whitespace
    const cardHeight = 430.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: cardWidth + 16,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header Bar
                  _buildHeaderBar(),
                  const SizedBox(height: 10),

                  // Card Stack Area (Fixed height, no Expanded, eliminates bottom gap)
                  SizedBox(
                    height: cardHeight,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                          )
                        : (_currentIndex >= _candidates.length)
                            ? _buildDeckCompletedView()
                            : _buildCardStack(cardWidth, cardHeight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('⚡', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Poketalk Cards',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Explore 4-Day Spoken partners',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Cap Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.4)),
            ),
            child: Text(
              '$_activePactCount/4 Pairs',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFC00),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(double width, double height) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 3rd Card in background
        if (_currentIndex + 2 < _candidates.length)
          KeyedSubtree(
            key: ValueKey('bg2_${_candidates[_currentIndex + 2].userId}_${_candidates[_currentIndex + 2].dayLevel}'),
            child: Transform.translate(
              offset: const Offset(0, 22),
              child: Transform.scale(
                scale: 0.90,
                child: Opacity(
                  opacity: 0.45,
                  child: _buildCandidateCard(
                    _candidates[_currentIndex + 2],
                    width: width,
                    height: height,
                    isTop: false,
                  ),
                ),
              ),
            ),
          ),

        // 2nd Card in background
        if (_currentIndex + 1 < _candidates.length)
          KeyedSubtree(
            key: ValueKey('bg1_${_candidates[_currentIndex + 1].userId}_${_candidates[_currentIndex + 1].dayLevel}'),
            child: Transform.translate(
              offset: const Offset(0, 11),
              child: Transform.scale(
                scale: 0.95,
                child: Opacity(
                  opacity: 0.75,
                  child: _buildCandidateCard(
                    _candidates[_currentIndex + 1],
                    width: width,
                    height: height,
                    isTop: false,
                  ),
                ),
              ),
            ),
          ),

        // Top Interactive Swipable Card
        KeyedSubtree(
          key: ValueKey('top_${_candidates[_currentIndex].userId}_${_candidates[_currentIndex].dayLevel}'),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dragOffset += details.delta;
                _dragAngle = (_dragOffset.dx / 300) * 0.18;
              });
            },
            onPanEnd: (details) {
              final dx = _dragOffset.dx;
              final vx = details.velocity.pixelsPerSecond.dx;
              if (dx > 75 || vx > 400) {
                // 🌟 User Audio Directive: Swiping right advances card cleanly!
                _swipeCard(isLike: true);
              } else if (dx < -75 || vx < -400) {
                // Swiped left -> Pass
                _swipeCard(isLike: false);
              } else {
                // Reset card position
                setState(() {
                  _dragOffset = Offset.zero;
                  _dragAngle = 0.0;
                });
              }
            },
          child: Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _dragAngle,
              child: Stack(
                children: [
                  _buildCandidateCard(
                    _candidates[_currentIndex],
                    width: width,
                    height: height,
                    isTop: true,
                  ),

                  // Swipe Stamp Overlay (NEXT on right, PASS on left)
                  if (_dragOffset.dx > 40)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFC00),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            'NEXT ➔',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_dragOffset.dx < -40)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'PASS',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
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
      ],
    );
  }

  Widget _buildCandidateCard(
    PocketTalkCandidate candidate, {
    required double width,
    required double height,
    required bool isTop,
  }) {
    final rarityColor = _getRarityColor(candidate.avatarConfig);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          key: ValueKey('card_view_${candidate.userId}'),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                rarityColor,
                const Color(0xFFFFD700),
                rarityColor.withValues(alpha: 0.35),
                const Color(0xFF0F172A),
              ],
              stops: [
                0.0,
                (_shimmerController.value * 0.7).clamp(0.0, 1.0),
                0.85,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: isTop ? 0.55 : 0.25),
                blurRadius: isTop ? 32 : 14,
                spreadRadius: isTop ? 2 : 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3.5), // 3D Holographic border
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F19),
              borderRadius: BorderRadius.circular(21),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Card Header Bar: Rarity Tier & Mint/Candidate ID & View Profile
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: rarityColor.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            candidate.avatarConfig.rarityTier.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: rarityColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '0xNFT-${candidate.dayLevel < 10 ? '0' : ''}${candidate.dayLevel}-${candidate.avatarConfig.species.toUpperCase()}',
                            style: GoogleFonts.firaCode(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openProfile(candidate),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.remove_red_eye_rounded, color: Colors.white70, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Profile',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Main NFT Artwork Frame (Widescreen collectible presentation - exactly like Target Page)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 152,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: candidate.dayLevel == 90
                            ? [
                                const Color(0xFF020B24),
                                const Color(0xFF0D3268),
                                const Color(0xFF020B24)
                              ]
                            : (candidate.avatarConfig.species == 'cyber_cat'
                                ? [
                                    const Color(0xFF1E1B4B),
                                    const Color(0xFF0F172A),
                                    const Color(0xFF0B0F19),
                                  ]
                                : [
                                    rarityColor.withValues(alpha: 0.25),
                                    const Color(0xFF161F33),
                                  ]),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(
                        color: rarityColor.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: VectorAvatarWidget(
                          config: candidate.avatarConfig,
                          size: 142,
                          showAura: true,
                        ),
                      ),
                    ),
                  ),

                  // 3. Card Identity & Details Deck
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Day Milestone Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${candidate.name} • ${candidate.speciesTitle}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: const Color(0xFFFFFC00).withValues(alpha: 0.45)),
                              ),
                              child: Text(
                                'DAY ${candidate.dayLevel}',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Trait Matrix (SPECIES, LEVEL, POCKET SCORE, OUTFIT)
                        Row(
                          children: [
                            _buildTraitPill(
                              label: 'SPECIES',
                              value: candidate.avatarConfig.species
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              color: rarityColor,
                            ),
                            const SizedBox(width: 6),
                            _buildTraitPill(
                              label: 'LEVEL',
                              value: 'LVL ${candidate.dayLevel}',
                              color: const Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 6),
                            _buildTraitPill(
                              label: 'POCKET SCORE',
                              value: '⚡ ${candidate.pocketScore} PS',
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            _buildTraitPill(
                              label: 'OUTFIT',
                              value: candidate.avatarConfig.outfitStyle
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              color: const Color(0xFF38BDF8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // In-Game Fortress Spoken Pact Perk Container
                        Builder(
                          builder: (context) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    rarityColor.withValues(alpha: 0.16),
                                    const Color(0xFF111827),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.55),
                                  width: 1.1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text('⚡', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '4-Day Spoken Pact',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '15 MIN/DAY',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFFFFFC00),
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          candidate.goals,
                                          style: GoogleFonts.inter(
                                            color: Colors.white70,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        // Inline Action Deck: [ 🤝 MATE ] and [ ⚡ POCKET TALK ]
                        Row(
                          children: [
                            // 1. Mate Request Button (User Audio: "Mate-um kodukka")
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton.icon(
                                  onPressed: candidate.isMateRequestSent
                                      ? null
                                      : () => _sendMateRequest(candidate),
                                  icon: Icon(
                                    candidate.isMateRequestSent
                                        ? Icons.check_circle_rounded
                                        : Icons.person_add_rounded,
                                    color: candidate.isMateRequestSent
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF38BDF8),
                                    size: 16,
                                  ),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      candidate.isMateRequestSent ? 'MATE SENT ✓' : 'MATE 🤝',
                                      style: GoogleFonts.outfit(
                                        color: candidate.isMateRequestSent
                                            ? const Color(0xFF10B981)
                                            : Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: candidate.isMateRequestSent
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                      width: 1.3,
                                    ),
                                    backgroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. Pocket Talk Pact Challenge Button (User Audio: "ipparathu Pocket Talk-um kodukka")
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: candidate.isRequestSent
                                      ? null
                                      : () => _sendPocketTalkRequest(candidate),
                                  icon: candidate.isRequestSent
                                      ? const Icon(Icons.check_circle_rounded, color: Colors.black, size: 16)
                                      : const Text('⚡', style: TextStyle(fontSize: 15)),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      candidate.isRequestSent ? 'SENT ✓' : 'POKET TALK',
                                      style: GoogleFonts.outfit(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: candidate.isRequestSent
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFFFFC00),
                                    foregroundColor: Colors.black,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTraitPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF131A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 8.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCompletedView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1424),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              'Deck Completed!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You have reviewed available partner cards.\nCheck your Pocket Talk ⚡ tab to manage pending invites and continue active 4-day pacts!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final myId = _supabase.auth.currentUser?.id ?? '';
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('pocket_talk_swiped_ids_$myId');
                if (mounted) {
                  setState(() {
                    _currentIndex = 0;
                    _isLoading = true;
                  });
                  _loadCandidates();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
              ),
              child: Text(
                'Review Deck Again ↺',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
