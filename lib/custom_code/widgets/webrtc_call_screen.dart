import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String mode; // 'Video', 'Voice', or 'Text'

  const WebRTCCallScreen({super.key, required this.mode});

  @override
  _WebRTCCallScreenState createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  // Supabase client
  final supabase = Supabase.instance.client;

  // WebRTC objects
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  // Renderers
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // State variables
  String? myUserId;
  String? roomId;
  String? remoteUserId;
  bool isConnected = false;
  bool isMuted = false;
  bool isVideoEnabled = true;
  bool isSearching = true;
  bool isInitiator = false;

  // Realtime subscription
  RealtimeChannel? signalingChannel;
  RealtimeChannel? roomChannel;

  // Text chat
  List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();
  ScrollController? _activeScrollController;

  // Connection Timeout Timer
  Timer? _connectionTimeoutTimer;
  String _statusText = 'Initializing...';

  // ICE Candidate buffering
  List<RTCIceCandidate> candidatesBuffer = [];
  bool remoteDescriptionSet = false;

  @override
  void initState() {
    super.initState();
    initializeWebRTC();
  }

  Future<void> initializeWebRTC() async {
    // Request permissions
    await requestPermissions();

    // Initialize renderers
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    // Use actual user ID if logged in, otherwise random
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      myUserId = currentUser.id;
    } else {
      myUserId = 'user_${Random().nextInt(999999)}';
    }

    // Get user media
    await getUserMedia();

    // Find or create room
    await findRoom();
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || widget.mode == 'Text') {
      return;
    }
    if (widget.mode == 'Video') {
      await Permission.camera.request();
    }
    await Permission.microphone.request();
  }

  Future<void> getUserMedia() async {
    if (widget.mode == 'Text') {
      setState(() {
        isVideoEnabled = false;
        _statusText = 'Finding a match...';
      });
      return;
    }

    try {
      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': widget.mode == 'Video'
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'minHeight': '480',
                  'minFrameRate': '30',
                },
                'facingMode': 'user',
              }
            : false,
      };

      localStream = await navigator.mediaDevices.getUserMedia(constraints);
      localRenderer.srcObject = localStream;

      setState(() {
        isVideoEnabled = widget.mode == 'Video';
        _statusText = 'Finding a match...';
      });
    } catch (e) {
      debugPrint('Error getting user media: $e');
      _showErrorSnackBar('Failed to access Camera/Microphone: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            nextStranger();
          },
        ),
      ),
    );
  }

  Future<void> findRoom() async {
    try {
      // Check for waiting rooms with the same mode
      final response = await supabase
          .from('rooms')
          .select('id, status, mode, user1_id')
          .eq('status', 'waiting')
          .eq('mode', widget.mode)
          .neq('user1_id', myUserId!)
          .limit(1);

      if (response.isEmpty) {
        // Create new room
        await createRoom();
      } else {
        // Join existing room
        await joinRoom(response[0]['id']);
      }
    } catch (e, stackTrace) {
      debugPrint('Error finding room: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        _showErrorSnackBar(
            'Error connecting to matchmaker. Please check your internet or try again later.');
      }

      // Don't auto-retry indefinitely to avoid potential loops
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && isSearching) {
        // Option to retry or go back
        setState(() {
          _statusText = 'Connection issue. Retrying...';
        });
        // You might want to limit retries here
      }
    }
  }

  void _startConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && !isConnected) {
        _showErrorSnackBar(
            'Connection timed out. No one responded or network issue.');
        disconnectCall();
      }
    });
  }

  Future<void> createRoom() async {
    roomId = 'room_${Random().nextInt(999999)}';
    isInitiator = true;

    try {
      await supabase.from('rooms').insert({
        'id': roomId,
        'user1_id': myUserId,
        'status': 'waiting',
        'mode': widget.mode,
      });

      // Subscribe to room updates
      await subscribeToRoom();

      setState(() {
        isSearching = true;
        _statusText = 'Waiting for someone to join...';
      });
    } catch (e, stackTrace) {
      debugPrint('Error creating room: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackBar('Failed to join queue: $e');
        setState(() {
          isSearching = false;
          _statusText = 'Ready to start';
        });
      }
    }
  }

  Future<void> joinRoom(String existingRoomId) async {
    debugPrint('Joining room: $existingRoomId');
    roomId = existingRoomId;
    isInitiator = false;

    try {
      await supabase.from('rooms').update({
        'user2_id': myUserId,
        'status': 'active',
      }).eq('id', roomId!);

      setState(() {
        isSearching = false;
        _statusText = 'Creating connection...';
      });

      await subscribeToRoom();
      _startConnectionTimeout();

      // CRITICAL: Create peer connection first
      await _setupPeerConnection();

      // Small delay to ensure everything is set up
      await Future.delayed(const Duration(milliseconds: 500));

      // Then create and send offer
      await createOffer();

      if (widget.mode == 'Text') {
        setState(() {
          isConnected = true;
          _statusText = 'Connected';
          _connectionTimeoutTimer?.cancel();
        });
      }
    } catch (e) {
      debugPrint('Error joining room: $e');
      _showErrorSnackBar('Failed to join room: $e');
    }
  }

  Future<void> subscribeToRoom() async {
    // Subscribe to room channel
    roomChannel = supabase.channel('room_$roomId');

    roomChannel!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rooms',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: roomId,
      ),
      callback: (payload) {
        if (payload.newRecord['status'] == 'active' && isInitiator) {
          remoteUserId = payload.newRecord['user2_id'];
          setState(() {
            isSearching = false;
            _statusText = 'Connecting to stranger...';
          });
          _startConnectionTimeout();
          _setupPeerConnection();
          if (widget.mode == 'Text') {
            setState(() {
              isConnected = true;
              _statusText = 'Connected';
              _connectionTimeoutTimer?.cancel();
            });
          }
        }
      },
    );

    roomChannel!.subscribe();

    // Subscribe to signaling channel
    await subscribeToSignaling();
  }

  Future<void> subscribeToSignaling() async {
    signalingChannel = supabase.channel('signaling_$roomId');

    // First, clean up old signaling messages for this room
    try {
      await supabase.from('signaling').delete().eq('room_id', roomId!);
      debugPrint('Cleaned up old signaling data');
    } catch (e) {
      debugPrint('Error cleaning signaling data: $e');
    }

    signalingChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'signaling',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        debugPrint('Signaling message received: ${payload.newRecord['type']}');
        handleSignalingData(payload.newRecord);
      },
    );

    signalingChannel!.subscribe();
    debugPrint('Subscribed to signaling channel: signaling_$roomId');
  }

  // MAIN PEER CONNECTION SETUP - This is the ONLY function that creates RTCPeerConnection
  Future<void> _setupPeerConnection() async {
    debugPrint('Setting up peer connection...');

    // Configuration with proper constraints
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };

    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': widget.mode != 'Text',
        'OfferToReceiveVideo': widget.mode == 'Video',
      },
      'optional': [],
    };

    // Call the GLOBAL createPeerConnection from flutter_webrtc package
    peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
    debugPrint('Peer connection created');

    // Add local stream tracks individually
    if (localStream != null) {
      localStream!.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
        debugPrint('Added local track: ${track.kind}');
      });
    }

    // Handle remote stream - Use onTrack for modern approach
    peerConnection?.onTrack = (RTCTrackEvent event) {
      debugPrint('onTrack called: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        setState(() {
          remoteStream = event.streams[0];
          remoteRenderer.srcObject = remoteStream;
          isConnected = true;
          isSearching = false;
          _statusText = 'Connected';
          _connectionTimeoutTimer?.cancel();
        });
      }
    };

    // Also handle onAddStream for compatibility
    peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint('onAddStream called');
      setState(() {
        remoteStream = stream;
        remoteRenderer.srcObject = remoteStream;
        isConnected = true;
        isSearching = false;
        _statusText = 'Connected';
        _connectionTimeoutTimer?.cancel();
      });
    };

    // Handle ICE candidates
    peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        debugPrint('Sending ICE candidate: ${candidate.candidate}');
        sendSignalingData('candidate', {
          'candidate': candidate.toMap(),
        });
      }
    };

    // Handle ICE gathering state
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state: $state');
    };

    // Handle ICE connection state
    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE connection state: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        debugPrint('ICE Connection established!');
        setState(() {
          isConnected = true;
          _statusText = 'Connected';
          _connectionTimeoutTimer?.cancel();
        });
      }
    };

    // Handle connection state
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Peer Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() {
          isConnected = true;
          _statusText = 'Connected';
          _connectionTimeoutTimer?.cancel();
        });
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _showErrorSnackBar('Connection Lost/Failed.');
        disconnectCall();
      }
    };
  }

  Future<void> createOffer() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'mandatory': {
          'OfferToReceiveAudio': widget.mode != 'Text',
          'OfferToReceiveVideo': widget.mode == 'Video',
        },
      };

      RTCSessionDescription offer =
          await peerConnection!.createOffer(mediaConstraints);
      await peerConnection!.setLocalDescription(offer);

      debugPrint('Offer created and set as local description');
      sendSignalingData('offer', {
        'sdp': offer.sdp,
        'type': offer.type,
      });
    } catch (e) {
      debugPrint('Failed to create offer: $e');
      _showErrorSnackBar('Failed to create offer: $e');
    }
  }

  Future<void> createAnswer() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'mandatory': {
          'OfferToReceiveAudio': widget.mode != 'Text',
          'OfferToReceiveVideo': widget.mode == 'Video',
        },
      };

      RTCSessionDescription answer =
          await peerConnection!.createAnswer(mediaConstraints);
      await peerConnection!.setLocalDescription(answer);

      debugPrint('Answer created and set as local description');
      sendSignalingData('answer', {
        'sdp': answer.sdp,
        'type': answer.type,
      });
    } catch (e) {
      debugPrint('Failed to create answer: $e');
      _showErrorSnackBar('Failed to create answer: $e');
    }
  }

  Future<void> sendSignalingData(String type, Map<String, dynamic> data) async {
    await supabase.from('signaling').insert({
      'room_id': roomId,
      'user_id': myUserId,
      'type': type,
      'data': data,
    });
  }

  Future<void> handleSignalingData(Map<String, dynamic> data) async {
    if (!mounted) return;
    if (data['user_id'] == myUserId) return;

    String type = data['type'];
    Map<String, dynamic> payload = data['data'];

    debugPrint('Received signaling data: $type');

    try {
      switch (type) {
        case 'offer':
          debugPrint('Processing offer...');
          if (peerConnection == null) {
            debugPrint('PeerConnection is null, creating it now');
            await _setupPeerConnection();
          }

          await peerConnection?.setRemoteDescription(
            RTCSessionDescription(payload['sdp'], payload['type']),
          );
          debugPrint('Remote description set from offer');
          remoteDescriptionSet = true;
          _processBufferedCandidates();
          await createAnswer();
          break;

        case 'answer':
          debugPrint('Processing answer...');
          await peerConnection?.setRemoteDescription(
            RTCSessionDescription(payload['sdp'], payload['type']),
          );
          debugPrint('Remote description set from answer');
          remoteDescriptionSet = true;
          _processBufferedCandidates();
          break;

        case 'candidate':
          if (payload['candidate'] == null) {
            debugPrint('Received null candidate, skipping');
            break;
          }

          RTCIceCandidate candidate = RTCIceCandidate(
            payload['candidate']['candidate'],
            payload['candidate']['sdpMid'],
            payload['candidate']['sdpMLineIndex'],
          );

          if (remoteDescriptionSet && peerConnection != null) {
            debugPrint('Adding ICE candidate immediately');
            await peerConnection?.addCandidate(candidate);
          } else {
            debugPrint('Buffering ICE candidate');
            candidatesBuffer.add(candidate);
          }
          break;

        case 'chat':
          setState(() {
            messages.add({
              'sender': 'Stranger',
              'message': payload['message'],
              'timestamp': DateTime.now(),
            });
          });
          scrollToBottom();
          break;
      }
    } catch (e) {
      debugPrint('Error handling signaling data: $e');
      _showErrorSnackBar('Signaling error: $e');
    }
  }

  void _processBufferedCandidates() async {
    debugPrint('Processing ${candidatesBuffer.length} buffered candidates');
    for (var candidate in candidatesBuffer) {
      try {
        await peerConnection?.addCandidate(candidate);
        debugPrint('Added buffered candidate');
      } catch (e) {
        debugPrint('Error adding buffered candidate: $e');
      }
    }
    candidatesBuffer.clear();
  }

  void toggleMute() {
    if (localStream != null) {
      bool enabled = localStream!.getAudioTracks()[0].enabled;
      localStream!.getAudioTracks()[0].enabled = !enabled;
      setState(() {
        isMuted = !isMuted;
      });
    }
  }

  void toggleVideo() {
    if (localStream != null && widget.mode == 'Video') {
      bool enabled = localStream!.getVideoTracks()[0].enabled;
      localStream!.getVideoTracks()[0].enabled = !enabled;
      setState(() {
        isVideoEnabled = !isVideoEnabled;
      });
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    String message = messageController.text.trim();

    setState(() {
      messages.add({
        'sender': 'You',
        'message': message,
        'timestamp': DateTime.now(),
      });
    });

    sendSignalingData('chat', {'message': message});
    messageController.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final controller = _activeScrollController ?? scrollController;
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> disconnectCall() async {
    // Close peer connection
    await peerConnection?.close();
    peerConnection = null;

    // Stop local stream
    localStream?.getTracks().forEach((track) => track.stop());

    // Dispose renderers
    await localRenderer.dispose();
    await remoteRenderer.dispose();

    // Unsubscribe from channels
    await signalingChannel?.unsubscribe();
    await roomChannel?.unsubscribe();

    // Update room status
    if (roomId != null) {
      try {
        await supabase.from('rooms').delete().eq('id', roomId!);
      } catch (e) {
        // Ignore delete errors
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> nextStranger() async {
    // Cancel any existing timeout
    _connectionTimeoutTimer?.cancel();

    // Close peer connection
    await peerConnection?.close();
    peerConnection = null;

    // Unsubscribe from channels
    await signalingChannel?.unsubscribe();
    await roomChannel?.unsubscribe();

    // Delete current room if I was the one who created it or was in it
    if (roomId != null) {
      try {
        // Only try to delete, if it fails it's likely already gone
        await supabase.from('rooms').delete().eq('id', roomId!);
      } catch (e) {
        print('Error deleting room on skip: $e');
      }
    }

    // Reset state for new search
    setState(() {
      isConnected = false;
      isSearching = true;
      roomId = null;
      remoteUserId = null;
      remoteStream = null;
      remoteRenderer.srcObject = null;
      messages.clear();
      candidatesBuffer.clear();
      remoteDescriptionSet = false;
      _statusText = 'Finding someone new...';
    });

    // Small delay before looking for a new room
    await Future.delayed(const Duration(milliseconds: 500));

    // Re-initialize for a new search
    findRoom();
  }

  @override
  void dispose() {
    _connectionTimeoutTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();

    // Unsubscribe from channels
    signalingChannel?.unsubscribe();
    roomChannel?.unsubscribe();

    // Ensure resources are cleaned up
    localStream?.getTracks().forEach((track) => track.stop());
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await disconnectCall();
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor:
          widget.mode == 'Text' ? theme.primaryBackground : Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.mode} Mode',
          style: theme.titleLarge.override(
            fontFamily: 'Inter Tight',
            color: widget.mode == 'Text' ? theme.primaryText : Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: widget.mode == 'Text'
            ? theme.secondaryBackground
            : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.mode == 'Text' ? theme.primaryText : Colors.white,
          ),
          onPressed: () => disconnectCall(),
        ),
        actions: [
          if (isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: nextStranger,
                icon: const Icon(Icons.skip_next, color: Colors.yellow),
                label:
                    const Text('Next', style: TextStyle(color: Colors.yellow)),
              ),
            ),
          IconButton(
            icon: Icon(
              const IconData(0xe3b3, fontFamily: 'MaterialIcons'),
              color: widget.mode == 'Text' ? theme.primaryText : Colors.white,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Area
            if (widget.mode == 'Video')
              _buildVideoCallUI(theme)
            else if (widget.mode == 'Voice')
              _buildVoiceCallUI(theme)
            else if (widget.mode == 'Text')
              _buildTextChatUI(theme),

            // Chat overlay for Video/Voice calls
            if (widget.mode != 'Text')
              DraggableScrollableSheet(
                initialChildSize: 0.1,
                minChildSize: 0.1,
                maxChildSize: 0.7,
                builder: (context, sheetScrollController) {
                  _activeScrollController = sheetScrollController;
                  return _buildChatOverlay(theme, sheetScrollController);
                },
              ),

            // Call Controls for Video/Voice
            if (widget.mode != 'Text' && isConnected)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildCallControls(theme),
              ),

            // Notification or Overlay for Searching
            if (isSearching) _buildSearchingOverlay(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallUI(FlutterFlowTheme theme) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: isConnected
                ? RTCVideoView(remoteRenderer, mirror: false)
                : Center(child: _buildSearchingPlaceholder(theme, true)),
          ),
        ),
        if (localStream != null)
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(localRenderer, mirror: true),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceCallUI(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.person,
              size: 120,
              color: Colors.yellow,
            )
                .animate()
                .scale(duration: 1000.ms, curve: Curves.easeInOut)
                .fadeIn(),
          ),
          const SizedBox(height: 40),
          Text(
            isConnected ? 'Stranger matched!' : _statusText,
            style: theme.headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
            ),
          ),
          if (!isConnected)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
        ],
      ),
    );
  }

  Widget _buildTextChatUI(FlutterFlowTheme theme) {
    if (!isConnected && isSearching) {
      return Container(
        padding: const EdgeInsets.all(24),
        color: Colors.black,
        child: Center(child: _buildSearchingPlaceholder(theme, true)),
      );
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg['sender'] == 'You';
                return _buildPremiumMessageBubble(msg, isMe, theme);
              },
            ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildPremiumMessageBubble(
      Map<String, dynamic> msg, bool isMe, FlutterFlowTheme theme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.yellow : Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg['message']!,
              style: theme.bodyMedium.override(
                fontFamily: 'Inter',
                color: isMe ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TimeOfDay.fromDateTime(msg['timestamp'] as DateTime)
                  .format(context),
              style: theme.bodySmall.override(
                fontFamily: 'Inter',
                color: isMe ? Colors.black54 : Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      )
          .animate()
          .slideX(
              begin: isMe ? 0.2 : -0.2,
              duration: 300.ms,
              curve: Curves.easeOutQuad)
          .fadeIn(),
    );
  }

  Widget _buildMessageInput(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: messageController,
                focusNode: messageFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Say something nice...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingPlaceholder(FlutterFlowTheme theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow.withOpacity(0.1),
          ),
          child: Icon(
            widget.mode == 'Video'
                ? FontAwesomeIcons.video
                : (widget.mode == 'Voice'
                    ? FontAwesomeIcons.microphone
                    : FontAwesomeIcons.solidCommentDots),
            size: 50,
            color: Colors.yellow,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut)
            .then()
            .scale(
                end: const Offset(1, 1),
                duration: 1000.ms,
                curve: Curves.easeInOut),
        const SizedBox(height: 32),
        Text(
          _statusText,
          textAlign: TextAlign.center,
          style: theme.titleMedium.override(
            fontFamily: 'Inter Tight',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Connecting you with a stranger...',
          textAlign: TextAlign.center,
          style: theme.bodySmall.override(
            fontFamily: 'Inter',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingOverlay(FlutterFlowTheme theme) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(child: _buildSearchingPlaceholder(theme, true)),
    );
  }

  Widget _buildChatOverlay(
      FlutterFlowTheme theme, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'In-call Chat',
            style: theme.titleSmall.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == 'You';
                return _buildPremiumMessageBubble(msg, isMe, theme);
              },
            ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildCallControls(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            onPressed: toggleMute,
            icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            color: isMuted ? Colors.red : Colors.yellow.withOpacity(0.2),
            iconColor: isMuted ? Colors.white : Colors.yellow,
          ),
          if (widget.mode == 'Video')
            _buildControlButton(
              onPressed: toggleVideo,
              icon: isVideoEnabled
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              color:
                  !isVideoEnabled ? Colors.red : Colors.yellow.withOpacity(0.2),
              iconColor: !isVideoEnabled ? Colors.white : Colors.yellow,
            ),
          _buildControlButton(
            onPressed: disconnectCall,
            icon: Icons.call_end_rounded,
            color: Colors.red,
            iconColor: Colors.white,
            isLarge: true,
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.5, duration: 500.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: isLarge ? 32 : 24),
      ),
    );
  }
}
