import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_animate/flutter_animate.dart';
// import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:pocket_mates_app/custom_code/widgets/message_screen.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String mode; // 'Video', 'Voice', or 'Text'
  final String? targetUserId;

  const WebRTCCallScreen({super.key, required this.mode, this.targetUserId});

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  final supabase = Supabase.instance.client;
  InAppWebViewController? webViewController;
  String? myUserId;
  String? remoteUserId;
  bool isConnected = false;
  bool isSearching = true;
  String? currentRoomId;
  RealtimeChannel? _roomSubscription;
  String _statusText = 'Initializing...';
  final Set<String> _triedUserIds = {};
  Timer? _matchingLoopTimer;
  Timer? _connectionTimeoutTimer;

  // Text chat state
  List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  // Media state
  bool _isMicMuted = false;
  bool _isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() {
    final user = supabase.auth.currentUser;
    // PeerJS IDs should be alphanumeric. UUID contains dashes, which are usually fine.
    myUserId = user?.id ?? 'user_${Random().nextInt(999999)}';
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await [Permission.camera, Permission.microphone].request();
  }

  String get _peerHtml => '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"></script>
    <style>
        body, html { margin: 0; padding: 0; width: 100%; height: 100%; background: black; overflow: hidden; }
        #remoteVideo { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; z-index: 1; }
        #localVideo { position: absolute; top: 20px; right: 20px; width: 30%; aspect-ratio: 3/4; border-radius: 12px; border: 2px solid rgba(255,255,255,0.5); object-fit: cover; z-index: 10; transform: scaleX(-1); }
        .hidden { display: none !important; }
    </style>
</head>
<body>
    <video id="remoteVideo" autoplay playsinline></video>
    <video id="localVideo" autoplay muted playsinline></video>

    <script>
        let peer;
        let localStream;
        let activeCall;

        const localVideo = document.getElementById('localVideo');
        const remoteVideo = document.getElementById('remoteVideo');

        async function init(myId, mode) {
            try {
                if (mode !== 'Text') {
                    const constraints = {
                        audio: true,
                        video: mode === 'Video' ? { facingMode: 'user' } : false
                    };
                    localStream = await navigator.mediaDevices.getUserMedia(constraints);
                    localVideo.srcObject = localStream;
                    if (mode !== 'Video') localVideo.classList.add('hidden');
                } else {
                    localVideo.classList.add('hidden');
                    remoteVideo.classList.add('hidden');
                }

                peer = new Peer(myId, {
                    debug: 2,
                    config: {'iceServers': [
                        { urls: 'stun:stun.l.google.com:19302' },
                        { urls: 'stun:stun1.l.google.com:19302' },
                        { urls: 'stun:stun2.l.google.com:19302' }
                    ]}
                });

                peer.on('open', (id) => {
                    window.flutter_inappwebview.callHandler('onPeerOpen', id);
                });

                peer.on('call', (call) => {
                    if (localStream) {
                        call.answer(localStream);
                    } else {
                        call.answer(); // Text mode empty answer
                    }
                    handleCall(call);
                });

                // Data connection for Text chat
                peer.on('connection', (conn) => {
                    handleConnection(conn);
                });

                peer.on('error', (err) => {
                    window.flutter_inappwebview.callHandler('onError', err.type + ": " + err.message);
                });

            } catch (e) {
                window.flutter_inappwebview.callHandler('onError', "Permission/Media Error: " + e.message);
            }
        }

        let activeConn;
        function handleConnection(conn) {
            activeConn = conn;
            conn.on('open', () => {
                window.flutter_inappwebview.callHandler('onConnected');
            });
            conn.on('data', (data) => {
                window.flutter_inappwebview.callHandler('onMessageReceived', data);
            });
            conn.on('close', () => {
                window.flutter_inappwebview.callHandler('onDisconnected');
            });
        }

        function handleCall(call) {
            activeCall = call;
            call.on('stream', (remoteStream) => {
                remoteVideo.srcObject = remoteStream;
                window.flutter_inappwebview.callHandler('onConnected');
            });
            call.on('close', () => {
                window.flutter_inappwebview.callHandler('onDisconnected');
            });
        }

        function callPeer(peerId, mode) {
            if (!peer) return;
            if (mode === 'Text') {
                const conn = peer.connect(peerId);
                handleConnection(conn);
            } else if (localStream) {
                const call = peer.call(peerId, localStream);
                handleCall(call);
            }
        }

        function sendData(data) {
            if (activeConn && activeConn.open) {
                activeConn.send(data);
            }
        }

        function toggleAudio(mute) {
            if (localStream) {
                localStream.getAudioTracks().forEach(track => {
                    track.enabled = !mute;
                });
            }
        }

        function toggleVideo(mute) {
            if (localStream) {
                localStream.getVideoTracks().forEach(track => {
                    track.enabled = !mute;
                });
            }
        }

        function endCall() {
            if (activeCall) activeCall.close();
            if (activeConn) activeConn.close();
        }
    </script>
</body>
</html>
''';

  Future<void> findRoom() async {
    if (!mounted) return;
    _matchingLoopTimer?.cancel();
    _roomSubscription?.unsubscribe();

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
          _statusText = 'Stranger found! Connecting...';
        });

        if (widget.mode == 'Text') {
          _navigateToSupabaseChat(foundUserId);
          return;
        }

        webViewController?.evaluateJavascript(source: 'callPeer("$foundUserId", "${widget.mode}")');
        _startConnectionTimeout();
        return;
      }

      // 2. Create a room and wait
      final newRoomId = 'room_${Random().nextInt(9999999)}';
      await supabase.from('rooms').insert({'id': newRoomId, 'user1_id': myUserId, 'status': 'waiting', 'mode': widget.mode});

      setState(() {
        currentRoomId = newRoomId;
        _statusText = 'Waiting for a stranger...';
      });

      _roomSubscription = supabase.channel('room_$newRoomId').onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: newRoomId),
          callback: (payload) {
            final status = payload.newRecord['status'];
            final u2 = payload.newRecord['user2_id'];
            if (status == 'active' && u2 != null) {
              _roomSubscription?.unsubscribe();
              setState(() {
                remoteUserId = u2.toString();
                _statusText = 'Stranger joined!';
              });
              if (widget.mode == 'Text') {
                _navigateToSupabaseChat(u2.toString());
              }
            }
          }).subscribe();
    } catch (e) {
      debugPrint('Matching Error: $e');
      setState(() => _statusText = 'Connection error. Retrying...');
      _matchingLoopTimer = Timer(const Duration(seconds: 5), () => findRoom());
    }
  }

  void _navigateToSupabaseChat(String receiverId) {
    if (!mounted) return;
    _connectionTimeoutTimer?.cancel();
    _roomSubscription?.unsubscribe();
    webViewController?.evaluateJavascript(source: 'endCall()');

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
        if (widget.targetUserId != null) {
          debugPrint('Connect timeout. Retrying direct call.');
          _triedUserIds.remove(widget.targetUserId);
          nextStranger();
        } else {
          debugPrint('Connect timeout. Skipping user.');
          nextStranger();
        }
      }
    });
  }

  void nextStranger() {
    _cleanupRoom();
    webViewController?.evaluateJavascript(source: 'endCall()');
    findRoom();
  }

  void disconnectCall() {
    _cleanupRoom();
    webViewController?.evaluateJavascript(source: 'endCall()');
    Navigator.pop(context);
  }

  Future<void> _cleanupRoom() async {
    _connectionTimeoutTimer?.cancel();
    _roomSubscription?.unsubscribe();
    if (currentRoomId != null) {
      try {
        await supabase.from('rooms').delete().eq('id', currentRoomId!);
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }
      currentRoomId = null;
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    final text = messageController.text.trim();

    webViewController?.evaluateJavascript(source: 'sendData("$text")');

    setState(() {
      messages.add({
        'sender': 'You',
        'message': text,
        'timestamp': DateTime.now(),
      });
    });
    messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _cleanupRoom();
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = FlutterFlowTheme.of(context);

    // Dynamic background for different states
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
          // Background Layer
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),

          // The magic WebView that runs PeerJS
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _peerHtml,
              baseUrl: WebUri("https://localhost/"),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              clearCache: true,
              transparentBackground: true,
              hardwareAcceleration: true,
              userAgent:
                  "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1",
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.addJavaScriptHandler(
                  handlerName: 'onPeerOpen',
                  callback: (args) {
                    debugPrint('PeerJS Open: ${args[0]}');
                    findRoom();
                  });
              controller.addJavaScriptHandler(
                  handlerName: 'onConnected',
                  callback: (args) {
                    setState(() {
                      isConnected = true;
                      isSearching = false;
                      _statusText = 'Connected';
                    });
                    _connectionTimeoutTimer?.cancel();
                  });
              controller.addJavaScriptHandler(
                  handlerName: 'onMessageReceived',
                  callback: (args) {
                    setState(() {
                      messages.add({
                        'sender': 'Stranger',
                        'message': args[0].toString(),
                        'timestamp': DateTime.now(),
                      });
                    });
                    _scrollToBottom();
                  });
              controller.addJavaScriptHandler(
                  handlerName: 'onDisconnected',
                  callback: (args) => nextStranger());
              controller.addJavaScriptHandler(
                  handlerName: 'onError',
                  callback: (args) => debugPrint('PeerJS Error: ${args[0]}'));
            },
            onLoadStop: (controller, url) async {
              if (widget.mode != 'Text') {
                await _requestPermissions();
              }
              controller.evaluateJavascript(
                  source: 'init("$myUserId", "${widget.mode}")');
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT);
            },
          ),

          // Searching Overlay with Premium Animation
          if (isSearching && !isConnected)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                backgroundBlendMode: BlendMode.darken,
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                      sigmaX: 10, sigmaY: 10), // Blur effect
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                                color: Colors.yellow.withValues(alpha: 0.3),
                                width: 2),
                          ),
                          child: const Icon(Icons.radar,
                              color: Colors.yellow, size: 80),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .scale(
                                duration: 1.5.seconds,
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                curve: Curves.easeInOut)
                            .shimmer(
                                duration: 2.seconds,
                                color: Colors.yellowAccent),
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

          // Header Controls (Glassmorphism)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  onTap: disconnectCall,
                  icon: Icons.close,
                  color: Colors.white,
                ),
                if (isConnected)
                  GestureDetector(
                    onTap: nextStranger,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('Next',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.black, size: 20),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 300.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),

          // Chat Overlay (Premium Bottom Sheet)
          if (isConnected)
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.8,
              builder: (context, sheetScrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                        top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1))),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                                height: 5,
                                width: 40,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                          Text('Live Conversation',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          const Divider(color: Colors.white10),
                          Expanded(
                            child: ListView.builder(
                              controller:
                                  scrollController, // Use main scroll controller for auto-scroll
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe = msg['sender'] == 'You';
                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFFFFD700)
                                          : Colors.white12,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      msg['message'],
                                      style: TextStyle(
                                          color: isMe
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn()
                                      .slideX(begin: isMe ? 0.2 : -0.2),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              border: Border(
                                  top: BorderSide(color: Colors.white10)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: TextField(
                                        controller: messageController,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                            hintText: 'Type a message...',
                                            hintStyle: TextStyle(
                                                color: Colors.white38),
                                            border: InputBorder.none)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: sendMessage,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFFFD700),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.send_rounded,
                                        color: Colors.black, size: 20),
                                  ),
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
                      onTap: () {
                        setState(() {
                          _isMicMuted = !_isMicMuted;
                        });
                        webViewController?.evaluateJavascript(
                            source: 'toggleAudio($_isMicMuted)');
                      },
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
                          boxShadow: [
                            BoxShadow(
                                color: Colors.red.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 2)
                          ],
                        ),
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 32),
                      ),
                    ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.elasticOut),
                    const SizedBox(width: 24),
                    if (widget.mode == 'Video')
                      _buildGlassButton(
                        onTap: () {
                          setState(() {
                            _isVideoMuted = !_isVideoMuted;
                          });
                          webViewController?.evaluateJavascript(
                              source: 'toggleVideo($_isVideoMuted)');
                        },
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

  Widget _buildGlassButton(
      {required VoidCallback onTap,
      required IconData icon,
      required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
