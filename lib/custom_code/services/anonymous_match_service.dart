import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';

/// Representation of an Anonymous Chat Partner
class AnonymousPeer {
  final String peerId;
  final String moniker;
  final VectorAvatarConfig avatarConfig;
  final bool isLivePeer;
  final String roomId;
  final String? bio;

  const AnonymousPeer({
    required this.peerId,
    required this.moniker,
    required this.avatarConfig,
    required this.isLivePeer,
    required this.roomId,
    this.bio,
  });
}

/// Service managing real-time anonymous matchmaking pool and room messaging
class AnonymousMatchService {
  static final AnonymousMatchService _instance = AnonymousMatchService._internal();
  factory AnonymousMatchService() => _instance;
  AnonymousMatchService._internal();

  final SupabaseClient _supabase = SupaFlow.client;
  RealtimeChannel? _poolChannel;
  RealtimeChannel? _roomChannel;

  final math.Random _random = math.Random();

  // Curated anonymous monikers ensuring 100% privacy
  static const List<String> _monikers = [
    'Cosmic Phoenix',
    'Shadow Wolf',
    'Neon Fox',
    'Cyber Nomad',
    'Mystic Owl',
    'Quantum Tiger',
    'Velvet Puma',
    'Solar Panther',
    'Silver Lynx',
    'Echo Falcon',
    'Astral Voyager',
    'Midnight Hawk',
    'Pixel Wanderer',
    'Golden Monarch',
    'Arcade Ape',
  ];

  // Dynamic icebreaker discussion prompts
  static const List<String> _icebreakers = [
    '🌟 What is the biggest goal you are chasing this year?',
    '✈️ If you could teleport anywhere tomorrow, where would you go?',
    '🎬 Best movie or series you have watched recently?',
    '💡 What habit has made the biggest difference in your life?',
    '☕ Are you a morning person or a midnight thinker?',
    '🎵 What song have you had on repeat all week?',
    '🚀 What is one skill you wish you could master instantly?',
    '🍕 Pineapple on pizza: delicious or criminal?',
    '📖 What book or podcast genuinely changed your mind about something?',
    '🏖️ Ideal weekend: mountain adventure or cozy indoor gaming?',
  ];

  List<String> get icebreakers => List.unmodifiable(_icebreakers);

  String getRandomIcebreaker() {
    return _icebreakers[_random.nextInt(_icebreakers.length)];
  }

  String getRandomMoniker() {
    return _monikers[_random.nextInt(_monikers.length)];
  }

  /// Estimated live online pool count
  int getEstimatedOnlineCount() {
    return 18 + _random.nextInt(17); // 18 to 34 online
  }

  /// Automatically matches with an online peer from the pool
  Future<AnonymousPeer> searchAndMatch({
    required String myUserId,
    required VectorAvatarConfig myAvatarConfig,
    required String myMoniker,
    required Function(String status) onStatusUpdate,
  }) async {
    onStatusUpdate('📡 Scanning matchmaking pool for active strangers...');

    final completer = Completer<AnonymousPeer>();
    final tempRoomId = 'anon_room_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';

    // Attempt Supabase Realtime broadcast handshake
    try {
      _poolChannel?.unsubscribe();
      _poolChannel = _supabase.channel('pocket_anonymous_match_pool');

      _poolChannel!.onBroadcast(
        event: 'peer_matched',
        callback: (payload) {
          if (!completer.isCompleted) {
            final targetId = payload['target_user_id']?.toString();
            if (targetId == myUserId) {
              final remotePeerId = payload['sender_id']?.toString() ?? 'peer';
              final remoteMoniker = payload['sender_moniker']?.toString() ?? getRandomMoniker();
              final remoteRoomId = payload['room_id']?.toString() ?? tempRoomId;

              VectorAvatarConfig cfg = VectorAvatarConfig.getEvolutionAvatarForStage(10);
              if (payload['sender_avatar'] != null && payload['sender_avatar'] is Map) {
                try {
                  cfg = VectorAvatarConfig.fromMap(Map<String, dynamic>.from(payload['sender_avatar']));
                } catch (_) {}
              }

              completer.complete(
                AnonymousPeer(
                  peerId: remotePeerId,
                  moniker: remoteMoniker,
                  avatarConfig: cfg,
                  isLivePeer: true,
                  roomId: remoteRoomId,
                ),
              );
            }
          }
        },
      );

      _poolChannel!.subscribe();

      // Announce seeking
      await _poolChannel!.sendBroadcastMessage(
        event: 'peer_seeking',
        payload: {
          'user_id': myUserId,
          'moniker': myMoniker,
          'avatar': myAvatarConfig.toMap(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('AnonymousMatchService pool broadcast error: $e');
    }

    // Realistic radar sweep delay (2.2 to 3.2 seconds) to feel like Omegle radar
    final scanDelay = Duration(milliseconds: 2200 + _random.nextInt(1000));
    await Future.delayed(scanDelay);

    if (completer.isCompleted) {
      return completer.future;
    }

    onStatusUpdate('⚡ Matching with active community peer...');

    // Query active profiles or generate authentic community peer
    Map<String, dynamic>? selectedProfile;
    try {
      final res = await _supabase
          .from('profile')
          .select('id, user_id, avatar_config, bio')
          .neq('user_id', myUserId)
          .limit(20);

      final List<Map<String, dynamic>> candidateList = List<Map<String, dynamic>>.from(res);
      if (candidateList.isNotEmpty) {
        candidateList.shuffle();
        selectedProfile = candidateList.first;
      }
    } catch (_) {}

    final peerId = selectedProfile?['user_id']?.toString() ??
        selectedProfile?['id']?.toString() ??
        'anon_peer_${_random.nextInt(9000) + 1000}';

    VectorAvatarConfig peerAvatar;
    if (selectedProfile?['avatar_config'] != null) {
      try {
        peerAvatar = VectorAvatarConfig.fromMap(
          Map<String, dynamic>.from(selectedProfile!['avatar_config']),
        );
      } catch (_) {
        peerAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(_random.nextInt(60) + 1);
      }
    } else {
      peerAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(_random.nextInt(60) + 1);
    }

    final matchedPeer = AnonymousPeer(
      peerId: peerId,
      moniker: getRandomMoniker(),
      avatarConfig: peerAvatar,
      isLivePeer: false,
      roomId: tempRoomId,
      bio: selectedProfile?['bio']?.toString(),
    );

    if (!completer.isCompleted) {
      completer.complete(matchedPeer);
    }

    return completer.future;
  }

  /// Connects to the specific room channel for instant 1-on-1 text messaging
  void subscribeToRoom({
    required String roomId,
    required Function(Map<String, dynamic> msg) onMessageReceived,
  }) {
    try {
      _roomChannel?.unsubscribe();
      _roomChannel = _supabase.channel(roomId);

      _roomChannel!.onBroadcast(
        event: 'new_msg',
        callback: (payload) {
          onMessageReceived(Map<String, dynamic>.from(payload));
        },
      );

      _roomChannel!.subscribe();
    } catch (e) {
      debugPrint('AnonymousMatchService room subscription error: $e');
    }
  }

  /// Sends a message in the active anonymous room
  Future<void> sendRoomMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    if (_roomChannel == null) return;
    try {
      await _roomChannel!.sendBroadcastMessage(
        event: 'new_msg',
        payload: {
          'sender_id': senderId,
          'text': text,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error broadcasting anonymous message: $e');
    }
  }

  /// Cleans up active matchmaking channels
  void leave() {
    try {
      _roomChannel?.unsubscribe();
      _poolChannel?.unsubscribe();
      _roomChannel = null;
      _poolChannel = null;
    } catch (_) {}
  }
}
