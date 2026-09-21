import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Role of a participant inside an Audio Space.
enum AudioRole { host, speaker, listener }

/// Participant information inside an Audio Space.
class AudioParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;
  final AudioRole role;
  final bool isMuted;
  final bool isRaisingHand;
  final bool isSpeaking;
  final DateTime joinedAt;

  const AudioParticipant({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.isMuted = false,
    this.isRaisingHand = false,
    this.isSpeaking = false,
    required this.joinedAt,
  });

  bool get isHost => role == AudioRole.host;
  bool get isSpeaker => role == AudioRole.speaker || role == AudioRole.host;
  bool get isListener => role == AudioRole.listener;

  AudioParticipant copyWith({
    String? name,
    String? avatarUrl,
    AudioRole? role,
    bool? isMuted,
    bool? isRaisingHand,
    bool? isSpeaking,
  }) {
    return AudioParticipant(
      userId: userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isMuted: isMuted ?? this.isMuted,
      isRaisingHand: isRaisingHand ?? this.isRaisingHand,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      joinedAt: joinedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_muted': isMuted,
      'is_raising_hand': isRaisingHand,
      'is_speaking': isSpeaking,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory AudioParticipant.fromMap(Map<String, dynamic> map) {
    AudioRole role = AudioRole.listener;
    if (map['role'] == 'host') {
      role = AudioRole.host;
    } else if (map['role'] == 'speaker') {
      role = AudioRole.speaker;
    }

    return AudioParticipant(
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'English Mate',
      avatarUrl: map['avatar_url']?.toString(),
      role: role,
      isMuted: map['is_muted'] == true,
      isRaisingHand: map['is_raising_hand'] == true,
      isSpeaking: map['is_speaking'] == true,
      joinedAt: DateTime.tryParse(map['joined_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Representation of a Live Audio Space Room.
class AudioSpaceModel {
  final String id;
  final String title;
  final String topic;
  final String category;
  final String hostUserId;
  final String hostName;
  final String? hostAvatar;
  final String levelTag;
  final bool isActive;
  final int participantCount;
  final int speakerLimit;
  final DateTime createdAt;

  const AudioSpaceModel({
    required this.id,
    required this.title,
    required this.topic,
    this.category = 'General',
    required this.hostUserId,
    required this.hostName,
    this.hostAvatar,
    this.levelTag = 'All Levels',
    this.isActive = true,
    this.participantCount = 1,
    this.speakerLimit = 6,
    required this.createdAt,
  });

  factory AudioSpaceModel.fromMap(Map<String, dynamic> map) {
    return AudioSpaceModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'English Practice Room',
      topic: map['topic']?.toString() ?? 'English Fluency Practice',
      category: map['category']?.toString() ?? 'General',
      hostUserId: map['host_user_id']?.toString() ?? '',
      hostName: map['host_name']?.toString() ?? 'Host',
      hostAvatar: map['host_avatar']?.toString(),
      levelTag: map['level_tag']?.toString() ?? 'All Levels',
      isActive: map['is_active'] != false,
      participantCount: (map['participant_count'] as num?)?.toInt() ?? 1,
      speakerLimit: (map['speaker_limit'] as num?)?.toInt() ?? 6,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'category': category,
      'host_user_id': hostUserId,
      'host_name': hostName,
      'host_avatar': hostAvatar,
      'level_tag': levelTag,
      'is_active': isActive,
      'participant_count': participantCount,
      'speaker_limit': speakerLimit,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 🎙️ PocketAudioSpaceEngine
/// Zero-Cost Multi-Peer Mesh Audio Engine using WebRTC + Supabase Realtime Broadcast & Presence.
class PocketAudioSpaceEngine extends ChangeNotifier {
  static final PocketAudioSpaceEngine instance = PocketAudioSpaceEngine._internal();
  PocketAudioSpaceEngine._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Active Space state
  AudioSpaceModel? _currentSpace;
  AudioSpaceModel? get currentSpace => _currentSpace;

  bool _isInRoom = false;
  bool get isInRoom => _isInRoom;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isMicMuted = false;
  bool get isMicMuted => _isMicMuted;

  bool _isSpeakerphoneOn = true;
  bool get isSpeakerphoneOn => _isSpeakerphoneOn;

  bool _handRaised = false;
  bool get handRaised => _handRaised;

  AudioRole _myRole = AudioRole.listener;
  AudioRole get myRole => _myRole;

  bool get isHost => _myRole == AudioRole.host;
  bool get isSpeaker => _myRole == AudioRole.speaker || _myRole == AudioRole.host;
  bool get isListener => _myRole == AudioRole.listener;

  // Participants in active room
  final Map<String, AudioParticipant> _participants = {};
  List<AudioParticipant> get participants => _participants.values.toList();

  List<AudioParticipant> get stageSpeakers =>
      _participants.values.where((p) => p.isSpeaker).toList();

  List<AudioParticipant> get audienceListeners =>
      _participants.values.where((p) => p.isListener).toList();

  // WebRTC multi-peer resources
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  RealtimeChannel? _roomChannel;
  Timer? _volumeCheckTimer;

  // User details
  String? _myUserId;
  String? get myUserId => _myUserId;
  String _myUserName = 'English Mate';
  String? _myAvatarUrl;

  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun.services.mozilla.com'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  /// Initialize engine with current user details
  Future<void> initUser() async {
    final user = _supabase.auth.currentUser;
    _myUserId = user?.id;
    if (_myUserId != null) {
      try {
        final profile = await _supabase
            .from('profile')
            .select('name, profile_image_url')
            .eq('user_id', _myUserId!)
            .maybeSingle();
        if (profile != null) {
          _myUserName = profile['name']?.toString() ?? 'English Mate';
          _myAvatarUrl = profile['profile_image_url']?.toString();
        }
      } catch (e) {
        debugPrint('PocketAudioSpaceEngine: Profile fetch warning: $e');
      }
    }
  }

  /// Create and host a new Audio Space
  Future<AudioSpaceModel?> createSpace({
    required String title,
    required String topic,
    String category = 'General',
    String levelTag = 'All Levels',
    int speakerLimit = 6,
  }) async {
    await initUser();
    if (_myUserId == null) return null;

    _isConnecting = true;
    notifyListeners();

    try {
      final insertData = {
        'title': title.trim().isEmpty ? 'English Chit-Chat Stage' : title.trim(),
        'topic': topic.trim().isEmpty ? 'Fluency Practice' : topic.trim(),
        'category': category,
        'host_user_id': _myUserId!,
        'host_name': _myUserName,
        'host_avatar': _myAvatarUrl,
        'level_tag': levelTag,
        'is_active': true,
        'participant_count': 1,
        'speaker_limit': speakerLimit,
      };

      final response = await _supabase
          .from('live_audio_spaces')
          .insert(insertData)
          .select()
          .single();

      final space = AudioSpaceModel.fromMap(response);
      await joinSpace(space, initialRole: AudioRole.host);
      return space;
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Create space error: $e');
      _isConnecting = false;
      notifyListeners();
      return null;
    }
  }

  /// Join an existing Audio Space
  Future<void> joinSpace(AudioSpaceModel space,
      {AudioRole initialRole = AudioRole.listener}) async {
    await initUser();
    if (_myUserId == null) return;

    if (_isInRoom && _currentSpace?.id == space.id) {
      return; // Already in this room
    }

    // Leave existing room if any
    if (_isInRoom) {
      await leaveSpace();
    }

    _isConnecting = true;
    _currentSpace = space;
    _myRole = initialRole;
    _isMicMuted = initialRole == AudioRole.listener; // Auto-mute if listener
    _handRaised = false;
    _participants.clear();
    notifyListeners();

    try {
      // 1. If starting as host or speaker, acquire microphone
      if (_myRole == AudioRole.host || _myRole == AudioRole.speaker) {
        await _acquireMicrophone();
      }

      // 2. Set up Supabase Realtime channel
      final channelName = 'audio_space_${space.id}';
      _roomChannel = _supabase.channel(channelName);

      _roomChannel!
          // Signaling: WebRTC Offer/Answer/Candidate
          .onBroadcast(event: 'webrtc_signal', callback: _handleWebRTCSignal)
          // Moderation: promote to speaker
          .onBroadcast(event: 'promoted', callback: (payload) async {
            if (payload['target_user_id'] == _myUserId) {
              await _upgradeToSpeaker();
            }
          })
          // Moderation: demoted to listener
          .onBroadcast(event: 'demoted', callback: (payload) {
            if (payload['target_user_id'] == _myUserId) {
              _demoteToListener();
            }
          })
          // Moderation: host muted me
          .onBroadcast(event: 'force_mute', callback: (payload) {
            if (payload['target_user_id'] == _myUserId) {
              muteMic(true);
            }
          })
          // Host ended room
          .onBroadcast(event: 'space_ended', callback: (payload) {
            leaveSpace(wasEndedByHost: true);
          })
          // Presence sync
          .onPresenceSync((_) {
            _syncPresence();
          })
          .subscribe((status, [error]) async {
            if (status == RealtimeSubscribeStatus.subscribed) {
              _isInRoom = true;
              _isConnecting = false;
              _applySpeakerphone();
              _startVolumeDetection();

              // Track self presence in room
              final myPresence = AudioParticipant(
                userId: _myUserId!,
                name: _myUserName,
                avatarUrl: _myAvatarUrl,
                role: _myRole,
                isMuted: _isMicMuted,
                isRaisingHand: _handRaised,
                isSpeaking: false,
                joinedAt: DateTime.now(),
              );

              _participants[_myUserId!] = myPresence;
              await _roomChannel?.track(myPresence.toMap());

              // Update participant count in database
              _incrementParticipantCount(space.id, 1);
              notifyListeners();
            }
          });
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Join room error: $e');
      _isConnecting = false;
      _isInRoom = false;
      notifyListeners();
    }
  }

  /// Request mic permission and get local audio stream
  Future<void> _acquireMicrophone() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('PocketAudioSpaceEngine: Microphone permission denied');
        return;
      }
    }

    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'highpassFilter': true,
      },
      'video': false,
    };

    try {
      _localStream?.dispose();
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Apply current mute state
      if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
        _localStream!.getAudioTracks().first.enabled = !_isMicMuted;
      }
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Error acquiring local stream: $e');
    }
  }

  /// Toggle Mute/Unmute microphone
  void toggleMic() {
    if (_myRole == AudioRole.listener) return;
    _isMicMuted = !_isMicMuted;

    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      _localStream!.getAudioTracks().first.enabled = !_isMicMuted;
    }

    _updateSelfPresence();
    notifyListeners();
  }

  void muteMic(bool muted) {
    if (_myRole == AudioRole.listener) return;
    _isMicMuted = muted;

    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      _localStream!.getAudioTracks().first.enabled = !_isMicMuted;
    }

    _updateSelfPresence();
    notifyListeners();
  }

  /// Toggle between Speakerphone and Earpiece
  void toggleSpeakerphone() {
    _isSpeakerphoneOn = !_isSpeakerphoneOn;
    _applySpeakerphone();
    notifyListeners();
  }

  void _applySpeakerphone() {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        Helper.setSpeakerphoneOn(_isSpeakerphoneOn);
      }
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Error setting speakerphone: $e');
    }
  }

  /// Raise or lower hand to request stage access
  void toggleHandRaise() {
    if (_myRole != AudioRole.listener) return;
    _handRaised = !_handRaised;
    _updateSelfPresence();
    notifyListeners();
  }

  /// Host Moderation: Promote listener to stage speaker
  Future<void> promoteToSpeaker(String targetUserId) async {
    if (!isHost) return;
    if (stageSpeakers.length >= (_currentSpace?.speakerLimit ?? 6)) {
      debugPrint('Stage full! Max speakers reached.');
      return;
    }

    _roomChannel?.sendBroadcastMessage(
      event: 'promoted',
      payload: {'target_user_id': targetUserId},
    );
  }

  /// Host Moderation: Demote speaker back to listener
  Future<void> demoteSpeakerToListener(String targetUserId) async {
    if (!isHost) return;
    _roomChannel?.sendBroadcastMessage(
      event: 'demoted',
      payload: {'target_user_id': targetUserId},
    );
  }

  /// Host Moderation: Mute a speaker
  Future<void> muteSpeaker(String targetUserId) async {
    if (!isHost) return;
    _roomChannel?.sendBroadcastMessage(
      event: 'force_mute',
      payload: {'target_user_id': targetUserId},
    );
  }

  /// Upgrade self to speaker when promoted
  Future<void> _upgradeToSpeaker() async {
    _myRole = AudioRole.speaker;
    _handRaised = false;
    _isMicMuted = false;
    notifyListeners();

    await _acquireMicrophone();
    _updateSelfPresence();

    // Attach local track to all existing peer connections
    for (final entry in _peerConnections.entries) {
      final peerId = entry.key;
      final pc = entry.value;
      if (_localStream != null) {
        for (final track in _localStream!.getAudioTracks()) {
          pc.addTrack(track, _localStream!);
        }
        // Renegotiate offer with peer
        _createOfferToPeer(peerId);
      }
    }
  }

  /// Demote self to listener
  void _demoteToListener() {
    _myRole = AudioRole.listener;
    _isMicMuted = true;
    _handRaised = false;

    // Disable and stop local mic
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      _localStream!.getAudioTracks().first.enabled = false;
    }

    _updateSelfPresence();
    notifyListeners();
  }

  /// Sync presence state across participants
  void _syncPresence() {
    if (_roomChannel == null) return;
    final presenceState = _roomChannel!.presenceState();

    final Map<String, AudioParticipant> updated = {};
    for (final entry in presenceState) {
      for (final p in entry.presences) {
        final payload = p.payload;
        final userId = payload['user_id']?.toString();
        if (userId != null && userId.isNotEmpty) {
          updated[userId] = AudioParticipant.fromMap(payload);
        }
      }
    }

    // Always preserve self in local map
    if (_myUserId != null && _participants.containsKey(_myUserId)) {
      updated[_myUserId!] = _participants[_myUserId!]!;
    }

    _participants.clear();
    _participants.addAll(updated);

    // If I am a speaker or host, initiate connections with newly discovered participants
    if (isSpeaker) {
      for (final peerId in _participants.keys) {
        if (peerId != _myUserId && !_peerConnections.containsKey(peerId)) {
          _setupPeerConnectionForUser(peerId);
        }
      }
    }

    notifyListeners();
  }

  /// Update self presence in channel
  void _updateSelfPresence() {
    if (_myUserId == null || _roomChannel == null) return;
    final me = AudioParticipant(
      userId: _myUserId!,
      name: _myUserName,
      avatarUrl: _myAvatarUrl,
      role: _myRole,
      isMuted: _isMicMuted,
      isRaisingHand: _handRaised,
      isSpeaking: false,
      joinedAt: _participants[_myUserId]?.joinedAt ?? DateTime.now(),
    );
    _participants[_myUserId!] = me;
    _roomChannel?.track(me.toMap());
  }

  /// Set up a WebRTC RTCPeerConnection with a specific peer
  Future<void> _setupPeerConnectionForUser(String peerId) async {
    if (_peerConnections.containsKey(peerId)) return;

    try {
      final pc = await createPeerConnection(_iceConfig);
      _peerConnections[peerId] = pc;

      pc.onIceCandidate = (RTCIceCandidate candidate) {
        _roomChannel?.sendBroadcastMessage(
          event: 'webrtc_signal',
          payload: {
            'senderId': _myUserId,
            'targetId': peerId,
            'type': 'candidate',
            'candidate': candidate.toMap(),
          },
        );
      };

      pc.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStreams[peerId] = event.streams[0];
          notifyListeners();
        }
      };

      // Add local audio stream if I am on stage
      if (isSpeaker && _localStream != null) {
        for (final track in _localStream!.getAudioTracks()) {
          pc.addTrack(track, _localStream!);
        }
      }

      // Deterministic negotiation: higher userId sends offer
      if (_myUserId != null && _myUserId!.compareTo(peerId) > 0) {
        await _createOfferToPeer(peerId);
      }
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Peer connection setup error ($peerId): $e');
    }
  }

  /// Create and send WebRTC Offer to target peer
  Future<void> _createOfferToPeer(String targetPeerId) async {
    final pc = _peerConnections[targetPeerId];
    if (pc == null) return;

    try {
      final offer = await pc.createOffer({'offerToReceiveAudio': 1});
      await pc.setLocalDescription(offer);

      _roomChannel?.sendBroadcastMessage(
        event: 'webrtc_signal',
        payload: {
          'senderId': _myUserId,
          'targetId': targetPeerId,
          'type': 'offer',
          'sdp': offer.sdp,
        },
      );
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Create offer error ($targetPeerId): $e');
    }
  }

  /// Handle incoming WebRTC signaling message
  Future<void> _handleWebRTCSignal(Map<String, dynamic> payload) async {
    final targetId = payload['targetId']?.toString();
    final senderId = payload['senderId']?.toString();
    final type = payload['type']?.toString();

    if (targetId != _myUserId || senderId == null) return;

    // Lazily create peer connection if not existing yet
    if (!_peerConnections.containsKey(senderId)) {
      await _setupPeerConnectionForUser(senderId);
    }

    final pc = _peerConnections[senderId];
    if (pc == null) return;

    try {
      if (type == 'offer') {
        final sdp = payload['sdp']?.toString() ?? '';
        final description = RTCSessionDescription(sdp, 'offer');
        await pc.setRemoteDescription(description);

        final answer = await pc.createAnswer({'offerToReceiveAudio': 1});
        await pc.setLocalDescription(answer);

        _roomChannel?.sendBroadcastMessage(
          event: 'webrtc_signal',
          payload: {
            'senderId': _myUserId,
            'targetId': senderId,
            'type': 'answer',
            'sdp': answer.sdp,
          },
        );
      } else if (type == 'answer') {
        final sdp = payload['sdp']?.toString() ?? '';
        final description = RTCSessionDescription(sdp, 'answer');
        await pc.setRemoteDescription(description);
      } else if (type == 'candidate') {
        final candMap = payload['candidate'];
        if (candMap is Map<String, dynamic>) {
          final candidate = RTCIceCandidate(
            candMap['candidate'],
            candMap['sdpMid'],
            candMap['sdpMLineIndex'],
          );
          await pc.addCandidate(candidate);
        }
      }
    } catch (e) {
      debugPrint('PocketAudioSpaceEngine: Signaling message handle error: $e');
    }
  }

  /// Active voice volume detection for green speaking indicator
  void _startVolumeDetection() {
    _volumeCheckTimer?.cancel();
    _volumeCheckTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!_isInRoom) return;

      // Check if self is speaking (if not muted and on stage)
      if (isSpeaker && !_isMicMuted && _localStream != null) {
        final self = _participants[_myUserId];
        if (self != null && !self.isSpeaking) {
          _participants[_myUserId!] = self.copyWith(isSpeaking: true);
          notifyListeners();
        }
      } else if (_myUserId != null && _participants.containsKey(_myUserId)) {
        final self = _participants[_myUserId]!;
        if (self.isSpeaking) {
          _participants[_myUserId!] = self.copyWith(isSpeaking: false);
          notifyListeners();
        }
      }
    });
  }

  /// Leave the active Audio Space
  Future<void> leaveSpace({bool wasEndedByHost = false}) async {
    final spaceId = _currentSpace?.id;
    final amHost = isHost;

    _isInRoom = false;
    _isConnecting = false;
    _volumeCheckTimer?.cancel();

    // If host leaves, broadcast space ended & mark inactive in database
    if (amHost && spaceId != null && !wasEndedByHost) {
      try {
        _roomChannel?.sendBroadcastMessage(
          event: 'space_ended',
          payload: {'space_id': spaceId},
        );
        await _supabase
            .from('live_audio_spaces')
            .update({'is_active': false})
            .eq('id', spaceId);
      } catch (e) {
        debugPrint('PocketAudioSpaceEngine: Error ending space: $e');
      }
    } else if (spaceId != null) {
      _incrementParticipantCount(spaceId, -1);
    }

    // Teardown WebRTC peer connections
    for (final pc in _peerConnections.values) {
      try {
        await pc.close();
      } catch (_) {}
    }
    _peerConnections.clear();
    _remoteStreams.clear();

    // Stop local mic stream
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream?.dispose();
    _localStream = null;

    // Unsubscribe from channel
    _roomChannel?.untrack();
    _roomChannel?.unsubscribe();
    _roomChannel = null;

    _currentSpace = null;
    _participants.clear();
    _myRole = AudioRole.listener;
    _isMicMuted = false;
    _handRaised = false;

    notifyListeners();
  }

  void _incrementParticipantCount(String spaceId, int delta) {
    try {
      _supabase.rpc('increment_space_count',
          params: {'space_id': spaceId, 'delta': delta}).catchError((_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    leaveSpace();
    super.dispose();
  }
}
