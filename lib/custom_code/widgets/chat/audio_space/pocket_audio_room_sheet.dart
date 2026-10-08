import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_audio_space_engine.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';

/// ☕ PocketAudioRoomSheet
/// Intimate 4-Seat Round Coffee Table Chit-Chat space.
/// Features:
/// - 4 Round Table seats (Host + 3 Friends)
/// - Tap participant for profile card ("Add Mate", "PocketTalk Request", "View Profile")
/// - In-room ephemeral text chat & voice notes with audio recording and playback
/// - Strict self-destruct ephemeral deletion on read or room close from Supabase Storage
class PocketAudioRoomSheet extends StatefulWidget {
  final VoidCallback? onMinimize;

  const PocketAudioRoomSheet({
    super.key,
    this.onMinimize,
  });

  /// Helper to show this bottom sheet modal
  static Future<void> show(BuildContext context, {VoidCallback? onMinimize}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketAudioRoomSheet(onMinimize: onMinimize),
    );
  }

  @override
  State<PocketAudioRoomSheet> createState() => _PocketAudioRoomSheetState();
}

class _PocketAudioRoomSheetState extends State<PocketAudioRoomSheet> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PocketAudioSpaceEngine _engine = PocketAudioSpaceEngine.instance;

  // Text chat
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // Voice note recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingVoice = false;
  Timer? _recordTimer;
  int _recordDurationSeconds = 0;

  // Voice note playback
  AudioPlayer? _voicePlayer;
  String? _currentlyPlayingMsgId;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
    _initVoicePlayer();
  }

  void _initVoicePlayer() {
    _voicePlayer = AudioPlayer();
    _voicePlayer!.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingVoice = state.playing &&
              state.processingState != ProcessingState.completed;
          if (state.processingState == ProcessingState.completed) {
            _currentlyPlayingMsgId = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _chatController.dispose();
    _chatScrollController.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    _voicePlayer?.dispose();
    super.dispose();
  }

  void _onEngineUpdate() {
    if (mounted) {
      if (!_engine.isInRoom && !_engine.isConnecting) {
        Navigator.of(context, rootNavigator: true).maybePop();
      } else {
        setState(() {});
      }
    }
  }

  // --- Voice Note Recording ---
  Future<void> _startRecordingVoice() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required for voice notes')),
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/table_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
        path: filePath,
      );

      setState(() {
        _isRecordingVoice = true;
        _recordDurationSeconds = 0;
      });

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordDurationSeconds = timer.tick;
          });
          // Auto-stop at 60 seconds
          if (timer.tick >= 60) {
            _stopRecordingVoiceAndSend();
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting voice note: $e');
    }
  }

  Future<void> _stopRecordingVoiceAndSend() async {
    _recordTimer?.cancel();
    if (!_isRecordingVoice) return;

    try {
      final path = await _audioRecorder.stop();
      final duration = _recordDurationSeconds;

      setState(() {
        _isRecordingVoice = false;
        _recordDurationSeconds = 0;
      });

      if (path != null && duration > 0) {
        await _engine.sendVoiceMessage(path, duration);
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error stopping voice note: $e');
      setState(() {
        _isRecordingVoice = false;
        _recordDurationSeconds = 0;
      });
    }
  }

  void _cancelVoiceRecording() async {
    _recordTimer?.cancel();
    await _audioRecorder.stop();
    setState(() {
      _isRecordingVoice = false;
      _recordDurationSeconds = 0;
    });
  }

  // --- Voice Note Playback ---
  Future<void> _playVoiceNote(SpaceChatMessage msg) async {
    if (msg.voiceUrl == null || msg.voiceUrl!.isEmpty) return;

    if (_currentlyPlayingMsgId == msg.id && _isPlayingVoice) {
      await _voicePlayer?.pause();
      setState(() {
        _isPlayingVoice = false;
      });
      return;
    }

    try {
      setState(() {
        _currentlyPlayingMsgId = msg.id;
      });

      await _voicePlayer?.stop();
      await _voicePlayer?.setUrl(msg.voiceUrl!);
      await _voicePlayer?.play();

      // Mark message as read
      _engine.markMessageRead(msg.id);
    } catch (e) {
      debugPrint('Error playing voice note: $e');
      setState(() {
        _currentlyPlayingMsgId = null;
        _isPlayingVoice = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTextMessage() {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      _engine.sendChatMessage(text);
      _chatController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _confirmLeaveTable() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _engine.isHost ? 'End Chit-Chat Table?' : 'Leave Table?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _engine.isHost
              ? 'Ending this table will dismiss all participants and permanently delete all voice notes & chat records.'
              : 'All your temporary voice clips and chat in this room will be purged from storage.',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Stay', style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_engine.isHost ? 'End Table' : 'Leave Table'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _engine.leaveSpace();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = _engine.currentSpace;
    final screenHeight = MediaQuery.of(context).size.height;

    if (space == null && !_engine.isConnecting) {
      return const SizedBox.shrink();
    }

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1D), // Rich dark slate canvas
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Header with Drag Handle & Leave Button
          _buildHeader(context, space),

          // 2. Main Content
          Expanded(
            child: _engine.isConnecting
                ? _buildConnectingState()
                : Column(
                    children: [
                      // Coffee Table with 4 Seats
                      _buildCoffeeTableSection(space!),

                      const Divider(color: Color(0xFF1E293B), height: 1),

                      // In-Table Ephemeral Chat Messages & Voice Notes Feed
                      Expanded(
                        child: _buildChatMessagesFeed(),
                      ),
                    ],
                  ),
          ),

          // 3. Bottom Composer (Voice Record & Text Input)
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AudioSpaceModel? space) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111726),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Minimize
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70, size: 26),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onMinimize?.call();
                },
                tooltip: 'Minimize table',
              ),
              const SizedBox(width: 4),

              // Title and 4-Seat badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '☕ 4-SEAT CHIT-CHAT',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${math.min(_engine.participants.length, 4)}/4 Seated',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      space?.title ?? 'English Coffee Table',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Leave / End Button
              GestureDetector(
                onTap: _confirmLeaveTable,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        _engine.isHost ? 'End' : 'Leave',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ☕ 4-Seat Round Coffee Table Visualization
  Widget _buildCoffeeTableSection(AudioSpaceModel space) {
    // Participants mapped into max 4 table seats
    final allParticipants = _engine.participants;
    // Host is always Seat 1
    AudioParticipant? seat1Host;
    final otherSeats = <AudioParticipant>[];

    for (final p in allParticipants) {
      if (p.isHost && seat1Host == null) {
        seat1Host = p;
      } else if (otherSeats.length < 3) {
        otherSeats.add(p);
      }
    }

    // Fallback if host presence hasn't synced yet
    seat1Host ??= AudioParticipant(
      userId: space.hostUserId,
      name: space.hostName,
      avatarUrl: space.hostAvatar,
      role: AudioRole.host,
      joinedAt: space.createdAt,
    );

    final seat2 = otherSeats.isNotEmpty ? otherSeats[0] : null;
    final seat3 = otherSeats.length > 1 ? otherSeats[1] : null;
    final seat4 = otherSeats.length > 2 ? otherSeats[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1424),
      ),
      child: Column(
        children: [
          // Top Row: Seat 1 (Host)
          Center(
            child: _buildSeatTile(seat1Host, seatNumber: 1, isHostSeat: true),
          ),

          const SizedBox(height: 6),

          // Middle Row: Seat 2 (Left) --- Central Table Topic Hub --- Seat 3 (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Seat 2
              _buildSeatTile(seat2, seatNumber: 2),

              // Central Coffee Table Hub
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF131D33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('☕', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        space.topic,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ephemeral Table • Voice & Text',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Seat 3
              _buildSeatTile(seat3, seatNumber: 3),
            ],
          ),

          const SizedBox(height: 6),

          // Bottom Row: Seat 4
          Center(
            child: _buildSeatTile(seat4, seatNumber: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatTile(
    AudioParticipant? participant, {
    required int seatNumber,
    bool isHostSeat = false,
  }) {
    final isOccupied = participant != null;
    final isMe = isOccupied && participant.userId == _engine.myUserId;

    if (!isOccupied) {
      // Empty Seat Slot (Tap to Join / Sit)
      return GestureDetector(
        onTap: () {
          // If listener, take empty seat
          if (!_engine.isSpeaker) {
            _engine.toggleHandRaise();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seat requested! You can chat and drop voice notes.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF131D33),
                  border: Border.all(
                    color: const Color(0xFF334155),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('🪑', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Seat $seatNumber',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Open',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Occupied Seat
    return GestureDetector(
      onTap: () => _showParticipantProfile(context, participant),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Avatar border
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isHostSeat
                          ? const Color(0xFFFFFC00)
                          : (isMe ? const Color(0xFF38BDF8) : const Color(0xFF10B981)),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isHostSeat
                                ? const Color(0xFFFFFC00)
                                : const Color(0xFF10B981))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (participant.avatarUrl != null &&
                            participant.avatarUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: participant.avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _buildAvatarFallback(participant.name),
                          )
                        : _buildAvatarFallback(participant.name),
                  ),
                ),

                // Host Crown or Me badge
                if (isHostSeat)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 12)),
                    ),
                  )
                else if (isMe)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'YOU',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              participant.name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              isHostSeat ? 'Host' : 'Mate',
              style: GoogleFonts.outfit(
                color: isHostSeat ? const Color(0xFFFFFC00) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 💬 Live In-Room Ephemeral Chat & Voice Notes Feed
  Widget _buildChatMessagesFeed() {
    final messages = _engine.chatMessages;

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('☕', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome to the Chit-Chat Table!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start chatting or send a quick voice note with your mates.\nMessages and voice notes self-destruct once table closes.',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == _engine.myUserId;
        final canDelete = isMe || _engine.isHost;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                GestureDetector(
                  onTap: () {
                    final participant = _engine.participants.firstWhere(
                      (p) => p.userId == msg.senderId,
                      orElse: () => AudioParticipant(
                        userId: msg.senderId,
                        name: msg.senderName,
                        avatarUrl: msg.senderAvatar,
                        role: AudioRole.listener,
                        joinedAt: msg.sentAt,
                      ),
                    );
                    _showParticipantProfile(context, participant);
                  },
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1E293B),
                    backgroundImage: (msg.senderAvatar != null &&
                            msg.senderAvatar!.isNotEmpty)
                        ? CachedNetworkImageProvider(msg.senderAvatar!)
                        : null,
                    child: (msg.senderAvatar == null || msg.senderAvatar!.isEmpty)
                        ? Text(
                            msg.senderName.isNotEmpty
                                ? msg.senderName[0].toUpperCase()
                                : 'M',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFFFFFC00)
                        : const Color(0xFF182236),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe
                          ? const Color(0xFFFFFC00)
                          : const Color(0xFF26354D),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Sender Name & Delete Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMe)
                            Text(
                              msg.senderName,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (!isMe) const SizedBox(width: 6),
                          Text(
                            _formatTime(msg.sentAt),
                            style: GoogleFonts.inter(
                              color: isMe ? Colors.black45 : Colors.white38,
                              fontSize: 9.5,
                            ),
                          ),
                          if (canDelete) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _engine.deleteChatMessage(msg.id),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 13,
                                color: isMe ? Colors.black45 : Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Voice Note Bubble OR Text Bubble
                      if (msg.isVoice)
                        _buildVoiceBubble(msg, isMe: isMe)
                      else
                        Text(
                          msg.text,
                          style: GoogleFonts.inter(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 13.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceBubble(SpaceChatMessage msg, {required bool isMe}) {
    final isPlaying = _currentlyPlayingMsgId == msg.id && _isPlayingVoice;
    final isRead = msg.readBy.contains(_engine.myUserId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play / Pause Icon
          GestureDetector(
            onTap: () => _playVoiceNote(msg),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isMe ? Colors.black : const Color(0xFFFFFC00),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isMe ? const Color(0xFFFFFC00) : Colors.black,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Duration & Wave indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${msg.voiceDuration ?? 0}s Voice Note',
                    style: GoogleFonts.outfit(
                      color: isMe ? Colors.black87 : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isRead && !isMe)
                    const Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF10B981)),
                ],
              ),
              Text(
                'Self-destructs on exit',
                style: GoogleFonts.outfit(
                  color: isMe ? Colors.black54 : Colors.white38,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 🎙️ Bottom Composer (Voice Record & Text Input)
  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF111726),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: _isRecordingVoice
          ? _buildRecordingBar()
          : Row(
              children: [
                // Voice Note Record Button (Tap to record)
                GestureDetector(
                  onTap: _startRecordingVoice,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Color(0xFFFFFC00),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text Input
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Chit-chat in English...',
                      hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13.5),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendTextMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: _sendTextMessage,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFC00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        // Pulsing red recording dot
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1.3, 1.3),
            ),
        const SizedBox(width: 8),

        // Timer
        Text(
          'Recording: ${_recordDurationSeconds}s / 60s',
          style: GoogleFonts.outfit(
            color: const Color(0xFFEF4444),
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        // Cancel button
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
          onPressed: _cancelVoiceRecording,
          tooltip: 'Cancel',
        ),

        // Send Voice Note Button
        ElevatedButton.icon(
          onPressed: _stopRecordingVoiceAndSend,
          icon: const Icon(Icons.send_rounded, size: 14),
          label: Text(
            'Send',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFC00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFFFC00)),
          const SizedBox(height: 16),
          Text(
            'Taking a seat at the table...',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 Participant Profile Card with "Add Mate", "PocketTalk Request", "View Profile"
  void _showParticipantProfile(BuildContext context, AudioParticipant participant) async {
    final isMe = participant.userId == _engine.myUserId;
    final currentUserId = _supabase.auth.currentUser?.id;

    bool isFollowing = false;
    if (!isMe && currentUserId != null) {
      try {
        final res = await _supabase
            .from('follows')
            .select('follower_id')
            .eq('follower_id', currentUserId)
            .eq('followed_id', participant.userId)
            .maybeSingle();
        isFollowing = res != null;
      } catch (_) {}
    }

    if (!mounted || !context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131D33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Avatar with border
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: participant.isHost
                          ? const Color(0xFFFFFC00)
                          : const Color(0xFF10B981),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: (participant.avatarUrl != null &&
                            participant.avatarUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: participant.avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _buildAvatarFallback(participant.name),
                          )
                        : _buildAvatarFallback(participant.name),
                  ),
                ),
                const SizedBox(height: 10),

                // Name & Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      participant.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (participant.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'HOST',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMe ? 'You (Current Speaker)' : 'English Learning Mate',
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12.5),
                ),

                const SizedBox(height: 20),

                // Social Connections for other participants
                if (!isMe) ...[
                  Row(
                    children: [
                      // 1. Add Mate Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (currentUserId == null) return;
                            try {
                              if (isFollowing) {
                                await _supabase
                                    .from('follows')
                                    .delete()
                                    .eq('follower_id', currentUserId)
                                    .eq('followed_id', participant.userId);
                                setModalState(() => isFollowing = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Unfollowed mate')),
                                  );
                                }
                              } else {
                                await _supabase.from('follows').insert({
                                  'follower_id': currentUserId,
                                  'followed_id': participant.userId,
                                });
                                setModalState(() => isFollowing = true);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mate added! 🎉')),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Follow error: $e');
                            }
                          },
                          icon: Icon(
                            isFollowing
                                ? Icons.check_circle_rounded
                                : Icons.person_add_rounded,
                            size: 16,
                            color: isFollowing
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFFFC00),
                          ),
                          label: Text(
                            isFollowing ? 'Mate' : 'Add Mate',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: isFollowing
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFFFC00),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. PocketTalk Request Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WhatsAppGroupChat(
                                  groupId: 'p:${participant.userId}',
                                  groupName: participant.name,
                                  groupImage: participant.avatarUrl,
                                ),
                              ),
                            );
                          },
                          icon: const Text('💬', style: TextStyle(fontSize: 14)),
                          label: Text(
                            'PocketTalk',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3. View Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileDetailPage(userId: participant.userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_circle_outlined,
                          size: 18, color: Colors.white70),
                      label: Text(
                        'View Full Profile',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],

                // Host Moderation Controls
                if (_engine.isHost && !isMe) ...[
                  const Divider(color: Color(0xFF1E293B), height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _engine.muteSpeaker(participant.userId);
                          },
                          icon: const Icon(Icons.mic_off_rounded,
                              size: 16, color: Color(0xFFF59E0B)),
                          label: Text(
                            'Mute',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFF59E0B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _engine.demoteSpeakerToListener(participant.userId);
                          },
                          icon: const Icon(Icons.person_remove_rounded,
                              size: 16, color: Color(0xFFEF4444)),
                          label: Text(
                            'Vacate Seat',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFEF4444),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
