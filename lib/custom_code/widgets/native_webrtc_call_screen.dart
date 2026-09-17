import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';

/// 🎙️ Pure Audio WebRTC Calling Screen for Spoken English Fluency Practice.
/// Optimized for ultra-low latency, zero video crashes, and rock-solid cross-platform audio.
class NativeWebRTCCallScreen extends StatefulWidget {
  final String mode; // 'Voice' or 'Text'
  final String? targetUserId;

  const NativeWebRTCCallScreen({
    super.key,
    required this.mode,
    this.targetUserId,
  });

  @override
  State<NativeWebRTCCallScreen> createState() => _NativeWebRTCCallScreenState();
}

class _NativeWebRTCCallScreenState extends State<NativeWebRTCCallScreen> {
  final supabase = Supabase.instance.client;
  String? myUserId;
  String? remoteUserId;
  bool isConnected = false;
  bool isSearching = true;
  String? currentRoomId;
  RealtimeChannel? _roomSubscription;
  String _statusText = 'Initializing audio...';
  Timer? _matchingLoopTimer;
  Timer? _connectionTimeoutTimer;
  Timer? _callDurationTimer;
  int _callSeconds = 0;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _isMicMuted = false;
  bool _isSpeakerOn = true;
  bool _isCaller = false;
  bool _showChatDrawer = false;

  // Remote User Profile Info
  String? _remoteUserName;
  String? _remoteUserImage;
  bool _isRemoteVerified = false;

  // Text Chat State
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _fdcAwardedForCall = false;

  static const List<Map<String, String>> _icebreakerTopics = [
    {
      'title': '✈️ Dream Travel & Culture',
      'q1': 'If you could fly anywhere tomorrow, where would you go and why?',
      'q2': 'What is the most unique food or tradition in your hometown?'
    },
    {
      'title': '💼 Work, Career & Goals',
      'q1': 'What are you working on right now that excites you most?',
      'q2': 'Where do you see yourself in 3 years with your English fluency?'
    },
    {
      'title': '🎬 Movies, Music & Hobbies',
      'q1': 'What is the best movie or series you watched recently?',
      'q2': 'What kind of music helps you focus or relax after a long day?'
    },
    {
      'title': '🤖 AI & The Future',
      'q1':
          'Do you believe AI like ChatGPT will replace human jobs, or help us?',
      'q2': 'If you could invent one gadget to help humanity, what would it be?'
    },
    {
      'title': '🔥 Quick Dilemmas',
      'q1': 'Would you rather have infinite time or infinite money?',
      'q2':
          'Early bird or night owl? How do you organize your most productive hours?'
    },
  ];

  int _selectedTopicIndex = 0;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {'urls': 'stun:stun.services.mozilla.com'},
      {'urls': 'stun:stun.ekiga.net'},
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
  final List<RTCIceCandidate> _remoteIceCandidatesQueue = [];

  bool get isTextMode => widget.mode == 'Text';

  @override
  void initState() {
    super.initState();
    _initUser();
    findRoom();
  }

  void _initUser() {
    final user = supabase.auth.currentUser;
    myUserId = user?.id ?? 'user_${Random().nextInt(999999)}';
  }

  Future<void> _requestAudioPermission() async {
    if (kIsWeb) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Permission.microphone.request();
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  Future<void> _openAudioMedia() async {
    if (isTextMode) return;

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
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _applySpeakerphone();
    } catch (e) {
      debugPrint("Error opening audio media: $e");
    }
  }

  void _applySpeakerphone() {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        Helper.setSpeakerphoneOn(_isSpeakerOn);
      }
    } catch (e) {
      debugPrint('Speakerphone setting error: $e');
    }
  }

  // Lobby/Broadcast logic for audio matchmaking
  Future<void> findRoom({String? specificRoomId}) async {
    if (!mounted) return;
    _matchingLoopTimer?.cancel();
    _callDurationTimer?.cancel();
    _roomSubscription?.unsubscribe();

    if (!isTextMode && _localStream == null) {
      await _requestAudioPermission();
      await _openAudioMedia();
    }

    setState(() {
      isSearching = true;
      isConnected = false;
      remoteUserId = null;
      currentRoomId = specificRoomId;
      _callSeconds = 0;
      _chatMessages.clear();
      _statusText = specificRoomId != null
          ? 'Joining room: $specificRoomId...'
          : 'Connecting to English speaker...';
    });

    try {
      // Direct room or unified voice lobby
      final channelName =
          specificRoomId != null ? 'room_$specificRoomId' : 'lobby_Voice';

      _roomSubscription = supabase.channel(channelName);

      _roomSubscription!
          .onBroadcast(
              event: 'ping',
              callback: (payload) {
                if (payload['senderId'] != myUserId &&
                    isSearching &&
                    !isConnected) {
                  _handleLobbyPing(payload);
                }
              })
          .onBroadcast(
              event: 'pong',
              callback: (payload) {
                if (payload['targetId'] == myUserId &&
                    isSearching &&
                    !isConnected) {
                  _handleLobbyPong(payload);
                }
              })
          .onBroadcast(event: 'webrtc', callback: _handleSignalingMessage)
          .onBroadcast(event: 'chat', callback: _handleChatMessage)
          .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _roomSubscription?.sendBroadcastMessage(
            event: 'ping',
            payload: {'senderId': myUserId, 'mode': 'Voice'},
          );
        }
      });

      if (!isTextMode) {
        await _setupWebRTCConnection();
      }

      // Periodically ping the lobby
      _matchingLoopTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (isSearching && !isConnected) {
          _roomSubscription?.sendBroadcastMessage(
            event: 'ping',
            payload: {'senderId': myUserId, 'mode': 'Voice'},
          );
        }
      });
    } catch (e) {
      debugPrint("Error connecting to lobby: $e");
      _statusText = 'Searching for partners...';
      _matchingLoopTimer = Timer(const Duration(seconds: 3), () => findRoom());
    }
  }

  void _handleLobbyPing(Map<String, dynamic> payload) {
    _roomSubscription?.sendBroadcastMessage(
      event: 'pong',
      payload: {
        'senderId': myUserId,
        'targetId': payload['senderId'],
      },
    );
    _initiateConnection(payload['senderId']);
  }

  void _handleLobbyPong(Map<String, dynamic> payload) {
    _initiateConnection(payload['senderId']);
  }

  void _initiateConnection(String foundUserId) {
    if (isConnected || !isSearching) return;

    setState(() {
      remoteUserId = foundUserId;
      _isCaller = myUserId!.compareTo(foundUserId) > 0;
      _statusText = 'Partner found! Connecting audio...';
    });

    _fetchRemoteUserInfo(foundUserId);

    if (_isCaller && !isTextMode) {
      Future.delayed(const Duration(milliseconds: 400), () => _createOffer());
    } else if (isTextMode) {
      _onConnected();
    }
  }

  void _onConnected() {
    if (isConnected) return;
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && isConnected) {
        setState(() {
          _callSeconds++;
        });
      }
    });

    setState(() {
      isConnected = true;
      isSearching = false;
      _statusText = 'Connected';
    });

    _connectionTimeoutTimer?.cancel();
    _awardCallFdcPoints();
    _applySpeakerphone();
  }

  Future<void> _fetchRemoteUserInfo(String userId) async {
    try {
      final data = await supabase
          .from('profile')
          .select('name, profile_image_url')
          .eq('id', userId)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() {
          _remoteUserName = data['name'] ?? 'English Mate';
          _remoteUserImage = data['profile_image_url'];
          _isRemoteVerified = true;
        });
      } else if (mounted) {
        setState(() {
          _remoteUserName = 'English Mate';
          _remoteUserImage = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching remote user info: $e');
      if (mounted) {
        setState(() {
          _remoteUserName = 'English Mate';
        });
      }
    }
  }

  Future<void> _setupWebRTCConnection() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _roomSubscription?.sendBroadcastMessage(
        event: 'webrtc',
        payload: {
          'type': 'candidate',
          'candidate': candidate.toMap(),
          'senderId': myUserId,
        },
      );
    };

    // Track handling for audio
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        if (mounted) {
          _onConnected();
        }
      }
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      if (mounted) {
        _onConnected();
      }
    };

    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        if (mounted) _onConnected();
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        nextStranger();
      }
    };

    if (_localStream != null) {
      for (final track in _localStream!.getAudioTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }
    }
  }

  Future<void> _createOffer() async {
    try {
      if (_peerConnection == null) await _setupWebRTCConnection();

      final RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });
      await _peerConnection!.setLocalDescription(offer);

      _roomSubscription?.sendBroadcastMessage(
        event: 'webrtc',
        payload: {
          'type': 'offer',
          'description': offer.toMap(),
          'senderId': myUserId,
        },
      );
    } catch (e) {
      debugPrint("Error creating offer: $e");
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> payload) async {
    if (payload['senderId'] == myUserId) return;

    final type = payload['type'];
    if (type == null) return;

    try {
      if (type == 'offer') {
        if (_peerConnection == null) await _setupWebRTCConnection();
        final description = payload['description'];
        await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']));

        // Drain queued ICE candidates
        for (final cand in _remoteIceCandidatesQueue) {
          await _peerConnection?.addCandidate(cand);
        }
        _remoteIceCandidatesQueue.clear();

        final RTCSessionDescription answer =
            await _peerConnection!.createAnswer({
          'offerToReceiveAudio': 1,
          'offerToReceiveVideo': 0,
        });
        await _peerConnection!.setLocalDescription(answer);

        _roomSubscription?.sendBroadcastMessage(
          event: 'webrtc',
          payload: {
            'type': 'answer',
            'description': answer.toMap(),
            'senderId': myUserId,
          },
        );
      } else if (type == 'answer') {
        final description = payload['description'];
        await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']));

        for (final cand in _remoteIceCandidatesQueue) {
          await _peerConnection?.addCandidate(cand);
        }
        _remoteIceCandidatesQueue.clear();
      } else if (type == 'candidate') {
        final candidateData = payload['candidate'];
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        final remoteDesc = await _peerConnection?.getRemoteDescription();
        if (remoteDesc != null) {
          await _peerConnection?.addCandidate(candidate);
        } else {
          _remoteIceCandidatesQueue.add(candidate);
        }
      }
    } catch (e) {
      debugPrint("Signaling error: $type -> $e");
    }
  }

  // --- TEXT CHAT LOGIC ---
  void _handleChatMessage(Map<String, dynamic> payload) {
    if (payload['senderId'] == myUserId) return;

    setState(() {
      _chatMessages.add({
        'senderId': payload['senderId'],
        'text': payload['text'],
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _sendTextMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty || !isConnected) return;

    _roomSubscription?.sendBroadcastMessage(
      event: 'chat',
      payload: {
        'senderId': myUserId,
        'text': text,
      },
    );

    setState(() {
      _chatMessages.add({
        'senderId': myUserId,
        'text': text,
        'time': DateTime.now(),
      });
      _chatController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void nextStranger() {
    _cleanupRoom();
    findRoom();
  }

  void disconnectCall() {
    final bool wasConnected = isConnected;
    final int duration = _callSeconds;
    _cleanupRoom();

    if (wasConnected && duration >= 15) {
      _showCallFinishedCelebration(duration);
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showCallFinishedCelebration(int durationSeconds) {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    final formattedTime =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF131722),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded,
                      color: Color(0xFFFFFC00), size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Great Speaking Practice!',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Every spoken conversation boosts your real-world English fluency and confidence.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Duration',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(formattedTime,
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: Colors.white12),
                      Column(
                        children: [
                          Text('Reward',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('+20 FDC',
                              style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await PocketAdService().showVideoAd(
                        context: context,
                        placementTitle: 'English Practice Complete',
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Done & Continue',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _awardCallFdcPoints() async {
    if (_fdcAwardedForCall) return;
    _fdcAwardedForCall = true;
    try {
      final total =
          await PocketFortressDefenseService.recordActivityPoints('voice_talk');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFFFFFC00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '+20 Fortress Defense Credits (FDC) earned! Total: $total FDC',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error awarding FDC points: $e');
    }
  }

  Future<void> _cleanupRoom() async {
    _fdcAwardedForCall = false;
    _connectionTimeoutTimer?.cancel();
    _matchingLoopTimer?.cancel();
    _callDurationTimer?.cancel();

    _roomSubscription?.unsubscribe();
    _roomSubscription = null;
    currentRoomId = null;

    _remoteIceCandidatesQueue.clear();
    _peerConnection?.close();
    _peerConnection = null;
    _remoteStream = null;

    if (mounted) {
      setState(() {
        isConnected = false;
        remoteUserId = null;
        _remoteUserName = null;
        _remoteUserImage = null;
        _isRemoteVerified = false;
      });
    }
  }

  void _toggleMic() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = audioTracks[0].enabled;
        audioTracks[0].enabled = !enabled;
        setState(() {
          _isMicMuted = !enabled;
        });
      }
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _applySpeakerphone();
  }

  @override
  void dispose() {
    _cleanupRoom();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _chatController.dispose();
    _roomController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String get _formattedCallDuration {
    final mins = _callSeconds ~/ 60;
    final secs = _callSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D13),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0D13), Color(0xFF131722), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Audio Screen Content
          if (isConnected) ...[
            _buildVoiceCenter(),
            if (_showChatDrawer) _buildInCallChatDrawer(),
          ],

          // Searching Radar State
          if (isSearching) _buildSearchingOverlay(),

          // Top Header Bar
          _buildHeader(),

          // Bottom Call Controls
          if (isConnected) _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 14,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            onTap: disconnectCall,
            icon: Icons.close_rounded,
            color: Colors.white70,
          ),
          if (isConnected) ...[
            // Status & Timer Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formattedCallDuration,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Next Partner Match Button
            _buildNextButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceCenter() {
    final topic = _icebreakerTopics[_selectedTopicIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Remote Avatar with Concentric Audio Waves
            Stack(
              alignment: Alignment.center,
              children: [
                // Radiating Glow Waves
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      duration: 1800.ms,
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.15, 1.15),
                      curve: Curves.easeInOut,
                    ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                // Avatar Center
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFC00),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _remoteUserImage != null
                        ? Image.network(
                            _remoteUserImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Peer Name & Verified Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _remoteUserName ?? 'English Mate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_isRemoteVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      color: Color(0xFFFFFC00), size: 18),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Speaking • Spoken English Practice',
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Active Icebreaker Topic Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: const Color(0xFF161B26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topic['title']!,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTopicIndex = (_selectedTopicIndex + 1) %
                                _icebreakerTopics.length;
                          });
                        },
                        child: Text(
                          'Next Question ↻',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${topic['q1']!}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding for bottom controls dock
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFF1E2638),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Color(0xFFFFFC00), size: 50),
      ),
    );
  }

  Widget _buildSearchingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRadarIcon(),
              const SizedBox(height: 36),
              Text(
                _statusText,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Searching global community for live practice partners...',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 28),
              _buildGlassButton(
                onTap: disconnectCall,
                icon: Icons.close_rounded,
                color: Colors.redAccent,
                label: 'Cancel',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(Icons.record_voice_over_rounded,
            color: Color(0xFFFFFC00), size: 52),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          duration: 1.4.seconds,
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.08, 1.08),
          curve: Curves.easeInOut,
        )
        .shimmer(duration: 2.seconds, color: const Color(0xFFFFFC00));
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF131722).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mute Mic
              _buildRoundControlButton(
                icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: _isMicMuted ? Colors.redAccent : Colors.white,
                onTap: _toggleMic,
              ),
              const SizedBox(width: 14),
              // Loudspeaker
              _buildRoundControlButton(
                icon: _isSpeakerOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_down_rounded,
                color: _isSpeakerOn ? const Color(0xFFFFFC00) : Colors.white70,
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 14),
              // Topics Sheet
              _buildRoundControlButton(
                icon: Icons.lightbulb_outline_rounded,
                color: const Color(0xFFFFFC00),
                onTap: _showTopicsBottomSheet,
              ),
              const SizedBox(width: 14),
              // In-call Text Drawer
              _buildRoundControlButton(
                icon: _showChatDrawer
                    ? Icons.chat_bubble_rounded
                    : Icons.chat_bubble_outline_rounded,
                color:
                    _showChatDrawer ? const Color(0xFFFFFC00) : Colors.white70,
                onTap: () {
                  setState(() => _showChatDrawer = !_showChatDrawer);
                },
              ),
              const SizedBox(width: 18),
              // End Call
              GestureDetector(
                onTap: disconnectCall,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66EF4444),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.call_end_rounded,
                        color: Colors.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        nextStranger();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFC00),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Next',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInCallChatDrawer() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 96,
      left: 16,
      right: 16,
      height: 220,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F131C).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            // Chat header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Notes & Spellings',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showChatDrawer = false),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 18),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            // Chat messages list
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isMe = msg['senderId'] == myUserId;
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFFFFFC00).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: GoogleFonts.inter(
                          color: isMe ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Text Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.black38,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Type spelling or note...',
                        hintStyle: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Color(0xFFFFFC00), size: 20),
                    onPressed: _sendTextMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  const Icon(Icons.lightbulb_rounded,
                      color: Color(0xFFFFFC00), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Spoken English Icebreakers',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a topic to spark fluent English conversations with your mate:',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _icebreakerTopics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _icebreakerTopics[index];
                    final isSelected = _selectedTopicIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTopicIndex = index;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFFC00).withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFFC00)
                                : Colors.white10,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: GoogleFonts.outfit(
                                color: isSelected
                                    ? const Color(0xFFFFFC00)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• ${item['q1']!}',
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    String? label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
