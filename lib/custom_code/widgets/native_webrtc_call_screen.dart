import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_mates_app/custom_code/widgets/message_screen.dart';

class NativeWebRTCCallScreen extends StatefulWidget {
  final String mode; // 'Video', 'Voice', or 'Text'
  final String? targetUserId;

  const NativeWebRTCCallScreen({super.key, required this.mode, this.targetUserId});

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
  String _statusText = 'Initializing...';
  Timer? _matchingLoopTimer;
  Timer? _connectionTimeoutTimer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isMicMuted = false;
  bool _isVideoMuted = false;
  bool _isCaller = false;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _initUser();
    if (widget.mode != 'Text') {
      _initRenderers().then((_) => findRoom());
    } else {
      findRoom();
    }
  }

  void _initUser() {
    final user = supabase.auth.currentUser;
    myUserId = user?.id ?? 'user_${Random().nextInt(999999)}';
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _openUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': widget.mode == 'Video' ? {'facingMode': 'user'} : false,
    };
    
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      if (widget.mode == 'Video') {
        _localRenderer.srcObject = _localStream;
      }
    } catch (e) {
      debugPrint("Error opening user media: $e");
    }
  }

  Future<void> findRoom() async {
    if (!mounted) return;
    _matchingLoopTimer?.cancel();
    _roomSubscription?.unsubscribe();

    if (widget.mode != 'Text' && _localStream == null) {
      await _requestPermissions();
      await _openUserMedia();
    }

    setState(() {
      isSearching = true;
      isConnected = false;
      _statusText = 'Searching for a match...';
    });

    try {
      // 1. Try to join an existing waiting room
      final matchRes = await supabase
          .from('rooms')
          .select('id, user1_id')
          .eq('status', 'waiting')
          .eq('mode', widget.mode)
          .neq('user1_id', myUserId!)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (matchRes != null) {
        final roomId = matchRes['id'].toString();
        final foundUserId = matchRes['user1_id'].toString();

        await supabase.from('rooms').update({'user2_id': myUserId, 'status': 'active'}).eq('id', roomId);

        setState(() {
          currentRoomId = roomId;
          remoteUserId = foundUserId;
          _isCaller = false; // The one who joined is the answerer
          _statusText = 'Stranger found! Connecting...';
        });

        if (widget.mode == 'Text') {
          _navigateToSupabaseChat(foundUserId);
          return;
        }

        await _setupWebRTCAndSubscribe(roomId);
        _startConnectionTimeout();
        return;
      }

      // 2. Create a room and wait
      final newRoomId = 'room_${Random().nextInt(9999999)}';
      await supabase.from('rooms').insert({'id': newRoomId, 'user1_id': myUserId, 'status': 'waiting', 'mode': widget.mode});

      setState(() {
        currentRoomId = newRoomId;
        _isCaller = true; // The one who created the room is the caller
        _statusText = 'Waiting for a stranger...';
      });

      _roomSubscription = supabase.channel('room_$newRoomId');
      
      _roomSubscription!.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: newRoomId),
          callback: (payload) async {
            final status = payload.newRecord['status'];
            final u2 = payload.newRecord['user2_id'];
            if (status == 'active' && u2 != null) {
              setState(() {
                remoteUserId = u2.toString();
                _statusText = 'Stranger joined! Handshaking...';
              });
              
              if (widget.mode == 'Text') {
                _navigateToSupabaseChat(u2.toString());
                return;
              }
              
              // As the caller, initiate the offer immediately once someone joins
              await _createOffer();
            }
          }).onBroadcast(event: 'webrtc', callback: _handleSignalingMessage).subscribe();
          
      if (widget.mode != 'Text') {
        await _setupWebRTCConnection();
      }
    } catch (e) {
      debugPrint('Matching Error: $e');
      setState(() => _statusText = 'Connection error. Retrying...');
      _matchingLoopTimer = Timer(const Duration(seconds: 5), () => findRoom());
    }
  }

  Future<void> _setupWebRTCAndSubscribe(String roomId) async {
    _roomSubscription = supabase.channel('room_$roomId');
    _roomSubscription!.onBroadcast(event: 'webrtc', callback: _handleSignalingMessage).subscribe();
    await _setupWebRTCConnection();
  }

  Future<void> _setupWebRTCConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_roomSubscription != null) {
        _roomSubscription!.sendBroadcastMessage(
          event: 'webrtc',
          payload: {
            'type': 'candidate',
            'candidate': candidate.toMap(),
            'senderId': myUserId,
          },
        );
      }
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      setState(() {
        _remoteStream = stream;
        if (widget.mode == 'Video') {
          _remoteRenderer.srcObject = _remoteStream;
        }
        isConnected = true;
        isSearching = false;
        _statusText = 'Connected';
      });
      _connectionTimeoutTimer?.cancel();
    };

    if (_localStream != null) {
      _peerConnection!.addStream(_localStream!);
    }
  }

  Future<void> _createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
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

  Future<void> _handleSignalingMessage(Map<String, dynamic> payload) async {
    if (payload['senderId'] == myUserId) return; // Ignore own messages

    final type = payload['type'];
    if (_peerConnection == null) return;

    try {
      if (type == 'offer') {
        final description = payload['description'];
        await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']));
        
        RTCSessionDescription answer = await _peerConnection!.createAnswer();
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
      } else if (type == 'candidate') {
        final candidateData = payload['candidate'];
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
      }
    } catch (e) {
      debugPrint("Signaling error: $e");
    }
  }

  void _navigateToSupabaseChat(String receiverId) {
    if (!mounted) return;
    _connectionTimeoutTimer?.cancel();
    _roomSubscription?.unsubscribe();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          receiverId: receiverId,
          receiverName: 'Stranger', // Anonymous chat
          receiverProfileImage: null, // Hide real image
        ),
      ),
    );
  }

  void _startConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !isConnected && isSearching) {
        debugPrint('Connect timeout. Skipping user.');
        nextStranger();
      }
    });
  }

  void nextStranger() {
    _cleanupRoom();
    findRoom();
  }

  void disconnectCall() {
    _cleanupRoom();
    Navigator.pop(context);
  }

  Future<void> _cleanupRoom() async {
    _connectionTimeoutTimer?.cancel();
    _roomSubscription?.unsubscribe();
    _matchingLoopTimer?.cancel();
    
    if (currentRoomId != null) {
      try {
        await supabase.from('rooms').delete().eq('id', currentRoomId!);
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }
      currentRoomId = null;
    }

    _peerConnection?.close();
    _peerConnection = null;
    _remoteRenderer.srcObject = null;
    isConnected = false;
  }

  void _toggleMic() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = audioTracks[0].enabled;
        audioTracks[0].enabled = !enabled;
        setState(() {
          _isMicMuted = enabled; // Toggled state
        });
      }
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final enabled = videoTracks[0].enabled;
        videoTracks[0].enabled = !enabled;
        setState(() {
          _isVideoMuted = enabled; // Toggled state
        });
      }
    }
  }

  @override
  void dispose() {
    _cleanupRoom();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = isConnected
        ? const LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),

          if (widget.mode == 'Video' && isConnected)
            RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),

          // Small local pip video
          if (widget.mode == 'Video' && _localStream != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 20,
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                ),
              ),
            ),

          if (isSearching && !isConnected)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                backgroundBlendMode: BlendMode.darken,
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: Colors.yellow.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.radar, color: Colors.yellow, size: 80),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .scale(duration: 1.5.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
                            .shimmer(duration: 2.seconds, color: Colors.yellowAccent),
                        const SizedBox(height: 40),
                        Text(
                          _statusText,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 10),
                        Text(
                          'Ensure your camera and mic are on',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Header Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(onTap: disconnectCall, icon: Icons.close, color: Colors.white),
                if (isConnected)
                  GestureDetector(
                    onTap: nextStranger,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          const Text('Next', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),

          // Voice Only Indication
          if (widget.mode == 'Voice' && isConnected)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over, size: 80, color: Colors.blueAccent),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.lightBlueAccent).scale(duration: 1.5.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
                  const SizedBox(height: 30),
                  Text('Voice Connected', style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Floating Call Controls (Bottom)
          if (isConnected)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGlassButton(
                      onTap: _toggleMic,
                      icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                      color: _isMicMuted ? Colors.red : Colors.white,
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: disconnectCall,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                      ),
                    ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                    const SizedBox(width: 24),
                    if (widget.mode == 'Video')
                      _buildGlassButton(
                        onTap: _toggleVideo,
                        icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                        color: _isVideoMuted ? Colors.red : Colors.white,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required VoidCallback onTap, required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
