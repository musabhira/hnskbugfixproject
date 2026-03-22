// Automatic FlutterFlow imports

import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_provider.dart';
import 'chat_models.dart';
import 'voice_player.dart';
import 'voice_recorder.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
// import '../webrtc_call_screen.dart';
import '../image_viewer.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/drawing_academy_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poster_designer/template_gallery_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/bulk_sender/bulk_sender_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poki_games_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/nearby_users_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chess_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/user_search_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

class WhatsAppGroupChat extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  final String groupId;
  final String groupName;
  final String? groupImage;

  const WhatsAppGroupChat({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImage,
    this.width,
    this.height,
  });

  @override
  ConsumerState<WhatsAppGroupChat> createState() => _WhatsAppGroupChatState();
}

class _WhatsAppGroupChatState extends ConsumerState<WhatsAppGroupChat>
    with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();

  late String _currentUserId;
  bool _isRecording = false;
  List<Map<String, dynamic>> _groupMembers = [];
  String? _userRole; // 'admin' or 'member'
  bool _isSending = false;
  bool _showEmojiPicker = false;
  Map<String, dynamic>? _replyMessage;
  bool _showScrollToBottom = false;

  // UI related methods
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? ''; // Original line
    // Assuming currentUserIdProvider is defined elsewhere if needed, otherwise keep original
    // _currentUserId = ref.read(currentUserIdProvider); // New line from user's snippet, commented out to avoid compile error if not defined
    _messageController.addListener(_onMessageChanged);
    // _setupSystemColor(); // New line from user's snippet, commented out to avoid compile error if not defined
    _fetchMembers();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        // Show FAB when scrolled away from bottom (bottom is offset 0 in reverse)
        final show = _scrollController.offset > 300;
        if (show != _showScrollToBottom) {
          safeSetState(() => _showScrollToBottom = show);
        }
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        safeSetState(() => _showEmojiPicker = false);
      }
    });

    // Cleanup trigger
    Future.microtask(() => ref
        .read(chatMessagesProvider(widget.groupId).notifier)
        .cleanupOldMessages());
  }

  void _onMessageChanged() {
    // Force rebuild to swap send/mic buttons
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Staged content for previews
  String? _stagedGalleryId;
  String? _stagedGalleryTitle;
  String? _stagedGalleryImage;
  String? _stagedThoughtId;
  String? _stagedThoughtText;
  Map<String, dynamic>? _stagedTool;
  String? _stagedVideoPath;
  String? _stagedDocumentPath;
  String? _stagedAudioPath;

  Future<void> _fetchMembers() async {
    if (widget.groupId.startsWith('p:')) return;
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.from('group_members').select('''
            *,
            profile:profile!profile_id(name, profile_image_url)
          ''').eq('group_id', widget.groupId).eq('is_active', true);

      final List rawMembers = response as List;
      final members = rawMembers.map((m) {
        final profileData = _safeGet(m['profile']);
        return {
          ...Map<String, dynamic>.from(m),
          'profile': profileData,
        };
      }).toList();

      final myMember = members.firstWhere((m) => m['user_id'] == _currentUserId,
          orElse: () => {});

      safeSetState(() {
        _groupMembers = members;
        _userRole = myMember['role'] ?? 'member';
      });
    } catch (e) {
      debugPrint('Error fetching members: $e');
    }
  }

  Future<void> _sendMessage({
    String? text,
    String messageType = 'text',
    String? fileUrl,
    int? voiceDuration,
    String? galleryId,
    String? thoughtId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isSending) return;

    // Filter out truly empty messages
    bool isEmpty = (text == null || text.trim().isEmpty) &&
        fileUrl == null &&
        galleryId == null &&
        thoughtId == null &&
        metadata == null;

    if (isEmpty && messageType == 'text') return;

    final replyId = _replyMessage?['id'];
    _isSending = true;
    _messageController.clear();
    safeSetState(() {
      _replyMessage = null;
      _stagedGalleryId = null;
      _stagedThoughtId = null;
      _stagedTool = null;
      _stagedVideoPath = null;
    });
    _scrollToBottom();

    try {
      await ref.read(chatMessagesProvider(widget.groupId).notifier).sendMessage(
            text: text ?? '',
            messageType: messageType,
            fileUrl: fileUrl,
            voiceDuration: voiceDuration,
            replyToId: replyId,
            galleryId: galleryId,
            thoughtId: thoughtId,
            metadata: metadata,
          );
    } catch (e) {
      debugPrint('SendMessage Error: $e');
      _showSnackBar('Failed to send: $e', isError: true);
    } finally {
      _isSending = false;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleRefresh() async {
    try {
      // Invalidate the provider and wait for fresh data
      ref.invalidate(chatMessagesProvider(widget.groupId));
      await ref.read(chatMessagesProvider(widget.groupId).future);
      await _fetchMembers();
    } catch (e) {
      debugPrint('Refresh error: $e');
      _showSnackBar('Refresh failed: $e');
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        reverse: true,
        itemCount: 15,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: isMe ? 64 : 16,
                right: isMe ? 16 : 64,
              ),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // App Theme Colors (Yellow/Black)
    const backgroundColor = Color(0xFF070B0D); // Premium deep black/blue
    const appBarColor = Color(0xFF121B22); // Sleek dark gray
    const accentColor = Colors.yellow;

    final chatMessagesAsync = ref.watch(chatMessagesProvider(widget.groupId));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leadingWidth: 70,
        titleSpacing: 0,
        leading: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, color: Colors.white),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  if (widget.groupImage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(
                          imageUrl: widget.groupImage!,
                          title: widget.groupName,
                        ),
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: 'group_avatar_${widget.groupId}',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: widget.groupImage != null
                        ? NetworkImage(widget.groupImage!)
                        : null,
                    child: widget.groupImage == null
                        ? const Icon(Icons.group, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: InkWell(
          onTap: _showGroupInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.groupName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.groupId.startsWith('p:')
                    ? 'Tap for info'
                    : (_groupMembers.isEmpty
                        ? 'Tap for info'
                        : '${_groupMembers.length} members'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: appBarColor,
            onSelected: (value) {
              if (value == 'refresh') _handleRefresh();
              if (value == 'info') _showGroupInfo();
              if (value == 'leave') _showLeaveGroupDialog();
            },
            itemBuilder: (context) {
              final isPersonalChat = widget.groupId.startsWith('p:');
              return [
                if (!isPersonalChat)
                  const PopupMenuItem(
                    value: 'info',
                    child: Text('Group Info', style: TextStyle(color: Colors.white)),
                  ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Text('Refresh', style: TextStyle(color: Colors.white)),
                ),
                if (!isPersonalChat)
                  const PopupMenuItem(
                    value: 'leave',
                    child: Text('Leave Group', style: TextStyle(color: Colors.red)),
                  ),
                if (isPersonalChat)
                  const PopupMenuItem(
                    value: 'refresh', // Temporary to avoid error if missing clear_chat action
                    child: Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ),
              ];
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Background Image/Pattern could go here
          Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    final messages = chatMessagesAsync.value ?? [];
                    final isLoadingInitial = chatMessagesAsync.isLoading &&
                        !chatMessagesAsync.hasValue;
                    final isErrorInitial = chatMessagesAsync.hasError &&
                        !chatMessagesAsync.hasValue;

                    if (isLoadingInitial) return _buildShimmerLoading();

                    if (isErrorInitial) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text('Error: ${chatMessagesAsync.error}',
                                style: const TextStyle(color: Colors.white)),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(
                                    chatMessagesProvider(widget.groupId));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter out truly empty/null messages
                    final filteredMessages = messages.where((m) {
                      // Allow messages that are optimistic or have content in known fields
                      return m.isOptimistic ||
                          (m.messageText != null &&
                              m.messageText!.isNotEmpty) ||
                          (m.fileUrl != null && m.fileUrl!.isNotEmpty) ||
                          (m.messageType != 'text' &&
                              m.messageType != 'system');
                    }).toList();

                    if (filteredMessages.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                color: Colors.white12, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show list (even if refreshing)
                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: accentColor,
                      backgroundColor: appBarColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = filteredMessages[index];
                          final isMe = message.senderId == _currentUserId;

                          bool showDate = true;
                          if (index < filteredMessages.length - 1) {
                            final nextMessage = filteredMessages[index + 1];
                            showDate = !_isSameDay(
                                message.createdAt, nextMessage.createdAt);
                          }

                          return Container(
                            key: ValueKey(message.id),
                            child: Column(
                              children: [
                                if (showDate)
                                  _buildDateSeparator(message.createdAt),
                                _buildMessageTile(message, isMe),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              if (_replyMessage != null) _buildReplyPreview(_replyMessage!),
              if (_stagedGalleryId != null ||
                  _stagedThoughtId != null ||
                  _stagedTool != null ||
                  _stagedVideoPath != null ||
                  _stagedDocumentPath != null ||
                  _stagedAudioPath != null)
                _buildStagedPreview(),
              _buildInputArea(),
              if (_showEmojiPicker) _buildEmojiPicker(),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: const Color(0xFF1F2C34),
                foregroundColor: accentColor,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
        ],
      ),
    ));
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          _formatDate(date),
          style: const TextStyle(
              color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildMessageTile(ChatMessage message, bool isMe) {
    if (message.messageType == 'system') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2C34).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message.messageText ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
      );
    }

    final radius = BorderRadius.circular(12);
    final borderRadius = isMe
        ? radius.copyWith(topRight: Radius.zero)
        : radius.copyWith(topLeft: Radius.zero);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe)
          GestureDetector(
            onTap: () {
              final member = _groupMembers.firstWhere(
                  (m) => m['user_id'] == message.senderId,
                  orElse: () => {});
              final url = member['profile']?['profile_image_url'];
              if (url != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewer(
                      imageUrl: url,
                      title: message.senderName,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[800],
                backgroundImage: () {
                  final member = _groupMembers.firstWhere(
                      (m) => m['user_id'] == message.senderId,
                      orElse: () => {});
                  final url = member['profile']?['profile_image_url'];
                  return url != null ? NetworkImage(url) : null;
                }(),
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              ),
            ),
          ),
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: isMe ? 48 : 4,
              right: isMe ? 8 : 48,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender Name (if group and not me)
                if (!isMe && !widget.groupId.startsWith('p:'))
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.senderName ?? 'User',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isAdmin(message.senderId)) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: Colors.yellow, width: 0.5),
                            ),
                            child: const Text(
                              'Admin',
                              style:
                                  TextStyle(color: Colors.yellow, fontSize: 8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                GestureDetector(
                  onLongPress: () async {
                    if (message.messageText != null &&
                        message.messageText!.isNotEmpty) {
                      await Clipboard.setData(
                          ClipboardData(text: message.messageText!));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message copied')),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : const Color(0xFF121B22),
                      borderRadius: borderRadius,
                      border: isMe
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 2, right: 2, top: 1, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.messageType == 'image' &&
                                  message.fileUrl != null)
                                _buildImageMessage(message.fileUrl!),
                              if (message.messageType == 'voice' &&
                                  message.fileUrl != null)
                                _buildVoiceMessage(message),
                              if (message.messageType == 'thought' &&
                                  message.thought != null)
                                _buildThoughtMessage(message.thought!, isMe),
                              if (message.messageType == 'gallery' &&
                                  message.gallery != null)
                                _buildGalleryMessage(message.gallery!, isMe),
                              if (message.messageType == 'status_mention')
                                _buildStatusMentionMessage(message, isMe),
                              if (message.messageType == 'video' &&
                                  message.fileUrl != null)
                                _buildVideoMessage(message.fileUrl!),
                              if (message.messageType == 'tool' &&
                                  message.metadata != null)
                                _buildToolMessage(message.metadata!, isMe),
                              if (message.messageType == 'document' &&
                                  message.fileUrl != null)
                                _buildDocumentMessage(message.fileUrl!, isMe),
                              if (message.messageType == 'text' &&
                                  message.messageText != null &&
                                  message.messageText!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  child: SelectableText(
                                    message.messageText!,
                                    style: TextStyle(
                                        color: isMe
                                            ? Colors.black87
                                            : Colors.white.withOpacity(0.93),
                                        fontSize: 15,
                                        height: 1.3),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.messageText != null &&
                                  message.messageText!.isNotEmpty) ...[
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text: message.messageText!));
                                    _showSnackBar('Copied');
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 12,
                                    color: (isMe ? Colors.black : Colors.white)
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                _formatTime(message.createdAt),
                                style: TextStyle(
                                  color: (isMe ? Colors.black : Colors.white)
                                      .withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  (message.isOptimistic || message.isPending)
                                      ? Icons.access_time
                                      : Icons.done_all,
                                  size: 14,
                                  color: (message.isOptimistic ||
                                          message.isPending)
                                      ? (isMe ? Colors.black54 : Colors.white54)
                                      : Colors.blue,
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMentionMessage(ChatMessage message, bool isMe) {
    final metadata = message.metadata ?? {};
    final senderName = metadata['sender_name'] ?? 'Someone';
    final mediaUrl = metadata['status_media_url'];
    final mediaType = metadata['media_type'] ?? 'image';
    final caption = message.messageText ?? '';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withValues(alpha: 0.1)
            : Colors.yellow.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.yellow.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mediaType == 'video' ? Icons.videocam : Icons.image,
                  color: Colors.yellow,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Group Mention',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$senderName mentioned this group in their Vibe:',
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (mediaUrl != null && mediaType != 'text')
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (mediaType == 'text')
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                mediaUrl ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            caption,
            style: TextStyle(
              color: isMe ? Colors.black87 : Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Logic to open status viewer can be added later if needed
                _showSnackBar('Opening Vibe...');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.yellow, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'View Vibe',
                style: TextStyle(color: Colors.yellow, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour =
        local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildThoughtMessage(Map<String, dynamic> thoughtData, bool isMe) {
    final String content = thoughtData['content'] ?? '';
    final profile = thoughtData['user']?['profile'] is List &&
            (thoughtData['user']['profile'] as List).isNotEmpty
        ? thoughtData['user']['profile'][0]
        : thoughtData['profile'] ?? {};

    final String name = profile['name'] ?? 'User';
    final String? avatar = profile['profile_image_url'];

    final mainTextTheme = isMe ? Colors.black87 : Colors.white;
    final subTextTheme = isMe ? Colors.black54 : Colors.white.withValues(alpha: 0.9);
    final linkTheme = isMe ? Colors.black : Colors.yellow.withValues(alpha: 0.8);
    final iconTheme = isMe ? Colors.black87 : Colors.yellow;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadCommentsPage(
              threadId: thoughtData['id'].toString(),
              threadContent: content,
            ),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isMe
              ? Colors.black.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.4),
          border: Border.all(
              color: isMe
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage:
                        avatar != null ? NetworkImage(avatar) : null,
                    backgroundColor: Colors.grey[800],
                    child: avatar == null
                        ? const Icon(Icons.person, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: mainTextTheme,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.forum_outlined, color: iconTheme, size: 16),
                ],
              ),
            ),
            // Content Preview
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.length > 150
                        ? '${content.substring(0, 150)}...'
                        : content,
                    style: TextStyle(
                      color: subTextTheme,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Read more...',
                    style: TextStyle(
                      color: linkTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryMessage(Map<String, dynamic> galleryData, bool isMe) {
    // Prepare item for GalleryDetailsPage
    final galleryItem = {
      'gallery_id': galleryData['id'],
      'gallery_title': galleryData['title'],
      'gallery_description': galleryData['description'],
      'gallery_image_url': galleryData['image_url'],
      'user_id': galleryData['user_id'],
      'name': galleryData['user']?['profile'] is List &&
              (galleryData['user']['profile'] as List).isNotEmpty
          ? galleryData['user']['profile'][0]['name']
          : 'User',
      'profile_image_url': galleryData['user']?['profile'] is List &&
              (galleryData['user']['profile'] as List).isNotEmpty
          ? galleryData['user']['profile'][0]['profile_image_url']
          : null,
      // Add other fields if needed by GalleryDetailsPage, potentially formatted dates etc.
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailsPage(
              item: galleryItem,
              allItems: [galleryItem],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              const Color(0xFF1E1E1E),
            ],
          ),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            GestureDetector(
              onTap: () {
                if (galleryData['user_id'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerfiedSwitchPage(
                        userId: galleryData['user_id'],
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: () {
                          try {
                            final profileList = galleryData['user']?['profile'];
                            if (profileList is List && profileList.isNotEmpty) {
                              final url = profileList[0]['profile_image_url'];
                              if (url is String && url.isNotEmpty) {
                                return NetworkImage(url);
                              }
                            }
                          } catch (e) {
                            // ignore
                          }
                          return null;
                        }(),
                        child: const Icon(Icons.person,
                            size: 14, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            () {
                              try {
                                final profileList =
                                    galleryData['user']?['profile'];
                                if (profileList is List &&
                                    profileList.isNotEmpty) {
                                  final name = profileList[0]['name'];
                                  if (name is String) {
                                    return name;
                                  }
                                }
                              } catch (e) {
                                // ignore
                              }
                              return 'Unknown';
                            }(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Shared a gallery',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: Colors.white30),
                  ],
                ),
              ),
            ),

            // Image Section
            Stack(
              children: [
                if (galleryData['image_url'] != null)
                  CachedNetworkImage(
                    imageUrl: galleryData['image_url'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[850],
                      height: 180,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[850],
                      height: 180,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white24, size: 40),
                    ),
                  ),

                // Price Tag if available
                if (galleryData['price'] != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 0.5),
                      ),
                      child: Text(
                        '\$${galleryData['price']}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (galleryData['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        galleryData['category'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    galleryData['title'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (galleryData['description'] != null &&
                      galleryData['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      galleryData['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewer(
              imageUrl: url,
              title: widget.groupName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                  height: 200,
                  width: 200,
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentMessage(String url, bool isMe) {
    final mainColor = isMe ? Colors.black87 : Colors.yellow;
    final subColor = isMe ? Colors.black54 : Colors.grey;
    final borderColor = isMe ? Colors.black.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.2);
    final iconBgColor = isMe ? Colors.white.withValues(alpha: 0.4) : Colors.yellow.withValues(alpha: 0.2);
    
    return GestureDetector(
      onTap: () {
        // Implement downloading or opening the document using url_launcher or similar
        // For now, simple snackbar to open document URL
        _showSnackBar('Opening document...');
        try {
          // ignore: deprecated_member_use
          // launch(url);
        } catch (_) {}
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.black.withValues(alpha: 0.05)
              : Colors.yellow.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.insert_drive_file, color: mainColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document',
                      style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('Tap to view file',
                      style: TextStyle(color: subColor, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.download, color: mainColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoUrl: url,
              title: widget.groupName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: FutureBuilder<String?>(
                  future:
                      VideoCompress.getFileThumbnail(url).then((f) => f.path),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(File(snapshot.data!),
                          fit: BoxFit.cover);
                    }
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.black12,
                      child: const Icon(Icons.videocam,
                          color: Colors.white24, size: 40),
                    );
                  },
                ),
              ),
              const CircleAvatar(
                backgroundColor: Colors.black45,
                radius: 24,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolMessage(Map<String, dynamic> metadata, bool isMe) {
    final String title = metadata['title'] ?? 'Tool';
    final String? description = metadata['description'];

    final titleColor = isMe ? Colors.black87 : Colors.white;
    final subColor = isMe ? Colors.black54 : Colors.white.withValues(alpha: 0.6);
    final bgColor = isMe ? Colors.black.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.05);
    final borderColor = isMe ? Colors.black.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.3);
    final iconColor = isMe ? Colors.black : Colors.yellow;

    return GestureDetector(
      onTap: () {
        // Logic to open tool
        final String toolName = title;
        // Navigation logic from HomePageWidgetTree
        _navigateToTool(toolName);
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMe ? Colors.black87 : Colors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getToolIcon(title),
                color: isMe ? Colors.white : Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: iconColor),
          ],
        ),
      ),
    );
  }

  IconData _getToolIcon(String title) {
    switch (title) {
      case 'Poster Designer':
        return Icons.palette;
      case 'Bulk Sender':
        return Icons.send_to_mobile;
      case 'Poki Games':
        return Icons.games;
      case 'Drawing Academy':
        return Icons.draw;
      case 'Travel Radar':
        return Icons.location_on;
      default:
        return Icons.apps;
    }
  }

  void _navigateToTool(String title) {
    // Implement navigation matching home_page_widget_tree.dart
    Widget? page;
    switch (title) {
      case 'Poster Designer':
        page = const TemplateGalleryPage();
        break;
      case 'Bulk Sender':
        page = const BulkSenderPage();
        break;
      case 'Poki Games':
        page = const PokiGamesPage();
        break;
      case 'Drawing Academy':
        page = const DrawingAcademyHomePage();
        break;
      case 'Travel Radar':
        page = const NearbyUsersPage();
        break;
      case 'Nearby Profiles':
        page = const NearbyUsersPage();
        break;
      case 'Chess':
        page = const ChessMatchmakingPage();
        break;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  /// Safe snack-bar helper that works with both MaterialApp and FluentApp.
  void _showSnackBar(String message,
      {bool isError = false, bool isLoading = false}) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.maybeOf(context);
    if (sm != null) {
      sm.showSnackBar(SnackBar(
        content: isLoading
            ? Row(children: [
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ])
            : Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: isLoading
            ? const Duration(seconds: 10)
            : const Duration(seconds: 3),
      ));
    } else {
      // Fallback: show an overlay toast-style notification
      debugPrint('[SnackBar] $message');
      final overlay = Overlay.maybeOf(context);
      if (overlay == null) return;
      final entry = OverlayEntry(
          builder: (_) => Positioned(
                bottom: 60,
                left: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isError ? Colors.red[800] : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 8)
                      ],
                    ),
                    child: Text(message,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ),
                ),
              ));
      overlay.insert(entry);
      Future.delayed(const Duration(seconds: 3), entry.remove);
    }
  }

  void _showLoadingSnackBar(String message) =>
      _showSnackBar(message, isLoading: true);

  void _showErrorSnackBar(String message) =>
      _showSnackBar(message, isError: true);

  void _hideSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }

  Widget _buildVoiceMessage(ChatMessage message) {
    return VoiceMessagePlayer(
      fileUrl: message.fileUrl!,
      duration: message.voiceDuration ?? 0,
      isFromCurrentUser: message.senderId == _currentUserId,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B0D),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121B22),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: Colors.white70),
                    onPressed: () {
                      safeSetState(() => _showEmojiPicker = !_showEmojiPicker);
                      if (_showEmojiPicker) FocusScope.of(context).unfocus();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                      minLines: 1,
                      maxLines: 6,
                    ),
                  ),
                  if (!_isRecording) ...[
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.white70),
                      onPressed: () {
                        _showAttachmentBottomSheet();
                      },
                    ),
                    if (_messageController.text.isEmpty)
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white70),
                        onPressed: () => _pickAndUploadImage(ImageSource.camera),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _messageController.text.isNotEmpty ||
                  _stagedGalleryId != null ||
                  _stagedThoughtId != null ||
                  _stagedTool != null ||
                  _stagedVideoPath != null ||
                  _stagedDocumentPath != null ||
                  _stagedAudioPath != null
              ? GestureDetector(
                  onTap: _handleSendAction,
                  child: const CircleAvatar(
                    backgroundColor: Colors.yellow,
                    radius: 24,
                    child: Icon(Icons.send, color: Colors.black),
                  ),
                )
              : VoiceMessageRecorder(
                  onSendMessage: (path, duration) =>
                      _handleVoiceMessage(path, duration),
                  onRecordingStateChanged: (recording) {
                    safeSetState(() => _isRecording = recording);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: const EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32,
            backgroundColor: Color(0xFF1F2C34),
            recentsLimit: 28,
          ),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: Color(0xFF1F2C34),
            indicatorColor: Colors.yellow,
            iconColor: Colors.grey,
            iconColorSelected: Colors.yellow,
            backspaceColor: Colors.yellow,
            dividerColor: Color(0xFF1F2C34),
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            enabled: false,
            backgroundColor: Color(0xFF1F2C34),
            buttonColor: Color(0xFF1F2C34),
            buttonIconColor: Colors.grey,
          ),
          searchViewConfig: const SearchViewConfig(
            backgroundColor: Color(0xFF1F2C34),
            buttonIconColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showAttachmentBottomSheet() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF121B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.yellow.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachOption(Icons.insert_drive_file, Colors.blue,
                      'Document', () {
                    Navigator.pop(context);
                    _pickAndStageDocument();
                  }),
                  _buildAttachOption(Icons.camera_alt, Colors.pink, 'Camera',
                      () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera);
                  }),
                  _buildAttachOption(Icons.image, Colors.purple, 'Gallery', () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachOption(Icons.audiotrack, Colors.orange, 'Audio',
                      () {
                    Navigator.pop(context);
                    _pickAndStageAudio();
                  }),
                  _buildAttachOption(Icons.videocam, Colors.teal, 'Video', () {
                    Navigator.pop(context);
                    _pickAndStageVideo();
                  }),
                  _buildAttachOption(Icons.construction_rounded,
                      Colors.deepOrange, 'Tool', () {
                    Navigator.pop(context);
                    _showToolPicker();
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStagedPreview() {
    String label = '';
    IconData icon = Icons.insert_drive_file;
    if (_stagedGalleryId != null) {
      label = _stagedGalleryTitle ?? 'Gallery Item';
      icon = Icons.grid_view_rounded;
    } else if (_stagedThoughtId != null) {
      label = _stagedThoughtText ?? 'Thought';
      icon = Icons.lightbulb_outline;
    } else if (_stagedTool != null) {
      label = _stagedTool!['title'] ?? 'Tool';
      icon = _getToolIcon(label);
    } else if (_stagedVideoPath != null) {
      label = 'Video Ready';
      icon = Icons.videocam;
    } else if (_stagedAudioPath != null) {
      label = 'Audio Ready';
      icon = Icons.audiotrack;
    } else if (_stagedDocumentPath != null) {
      label = 'Document Ready';
      icon = Icons.insert_drive_file;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF242F35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.yellow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sharing $label',
                    style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                if (_stagedThoughtText != null)
                  Text(_stagedThoughtText!,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () {
              safeSetState(() {
                _stagedGalleryId = null;
                _stagedThoughtId = null;
                _stagedTool = null;
                _stagedVideoPath = null;
                _stagedAudioPath = null;
                _stagedDocumentPath = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendAction() async {
    final text = _messageController.text;

    if (_stagedGalleryId != null) {
      await _sendMessage(
          text: text,
          messageType: 'gallery',
          galleryId: _stagedGalleryId,
          metadata: {
            'title': _stagedGalleryTitle,
            'image_url': _stagedGalleryImage
          });
    } else if (_stagedThoughtId != null) {
      await _sendMessage(
          text: text, messageType: 'thought', thoughtId: _stagedThoughtId);
    } else if (_stagedTool != null) {
      await _sendMessage(
          text: text, messageType: 'tool', metadata: _stagedTool);
    } else if (_stagedVideoPath != null) {
      await _uploadStagedVideo(text);
    } else if (_stagedDocumentPath != null) {
      await _uploadStagedFile(text, _stagedDocumentPath!, 'document');
    } else if (_stagedAudioPath != null) {
      await _uploadStagedFile(text, _stagedAudioPath!, 'voice');
    } else {
      await _sendMessage(text: text);
    }
  }

  Future<void> _uploadStagedFile(String? caption, String path, String type) async {
    try {
      _showLoadingSnackBar('Sending $type...');
      final file = File(path);
      final extension = path.split('.').last;
      final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'group_${widget.groupId}/$fileName';

      await _supabase.storage.from('chat-media').upload(storagePath, file);
      final url = _supabase.storage.from('chat-media').getPublicUrl(storagePath);

      await _sendMessage(
          text: caption ?? (type == 'document' ? 'Document 📁' : 'Audio 🎵'),
          messageType: type,
          fileUrl: url);

      safeSetState(() {
        _stagedDocumentPath = null;
        _stagedAudioPath = null;
      });
      _hideSnackBar();
    } catch (e) {
      _showErrorSnackBar('Error uploading $type: $e');
    }
  }

  Future<void> _pickAndStageDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        safeSetState(() {
          _stagedDocumentPath = result.files.single.path;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking document: $e');
    }
  }

  Future<void> _pickAndStageAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        safeSetState(() {
          _stagedAudioPath = result.files.single.path;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking audio: $e');
    }
  }

  Future<void> _pickAndStageVideo() async {
    try {
      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      safeSetState(() {
        _stagedVideoPath = video.path;
      });
    } catch (e) {
      _showErrorSnackBar('Error picking video: $e');
    }
  }

  Future<void> _uploadStagedVideo(String? caption) async {
    if (_stagedVideoPath == null) return;
    try {
      _showLoadingSnackBar('Sending Video...');
      final file = File(_stagedVideoPath!);
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storagePath = 'group_${widget.groupId}/$fileName';

      await _supabase.storage.from('chat-media').upload(storagePath, file);
      final url =
          _supabase.storage.from('chat-media').getPublicUrl(storagePath);

      await _sendMessage(
          text: caption ?? 'Video 📹', messageType: 'video', fileUrl: url);

      _hideSnackBar();
    } catch (e) {
      _showErrorSnackBar('Error uploading video: $e');
    }
  }





  void _showToolPicker() {
    final tools = [
      {'title': 'Poster Designer', 'description': 'Create amazing posters'},
      {'title': 'Bulk Sender', 'description': 'Send messages in bulk'},
      {'title': 'Poki Games', 'description': 'Play games with mates'},
      {'title': 'Drawing Academy', 'description': 'Learn to draw'},
      {'title': 'Travel Radar', 'description': 'Explore nearby places'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121B22),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tools to Share',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          ...tools.map((t) => ListTile(
                leading: Icon(_getToolIcon(t['title']!), color: Colors.yellow),
                title: Text(t['title']!,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(t['description']!,
                    style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  safeSetState(() {
                    _stagedTool = t;
                  });
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$_currentUserId/$fileName';

      await _supabase.storage.from('group-images').uploadBinary(path, bytes);
      final url = _supabase.storage.from('group-images').getPublicUrl(path);

      await _sendMessage(messageType: 'image', fileUrl: url);
      safeSetState(() {
        _showEmojiPicker = false;
      });
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Widget _buildAttachOption(
      IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 28,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(Map<String, dynamic> message) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF121B22),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Colors.yellow, width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Colors.yellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Replying to message',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(
                  message['message_text'] ?? 'Image/Voice',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: () => safeSetState(() => _replyMessage = null),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing helper methods like _showGroupInfo, _pickAndSendImage)
  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B141B), // Darker background for premium feel
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pull Bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Group Header
                    Center(
                      child: Column(
                        children: [
                          Hero(
                            tag: 'group_avatar_info_${widget.groupId}',
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: widget.groupImage != null
                                  ? NetworkImage(widget.groupImage!)
                                  : null,
                              child: widget.groupImage == null
                                  ? const Icon(Icons.group,
                                      color: Colors.white, size: 50)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.groupName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Group · ${_groupMembers.length} members',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Participants Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_groupMembers.length} members',
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        if (_userRole == 'admin')
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: () {}, // TODO: Member search
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_userRole == 'admin')
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.person_add, color: Colors.black),
                        ),
                        title: const Text('Add members',
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          _showAddMemberDialog();
                        },
                      ),
                    ..._groupMembers.map((member) {
                      final profile = member['profile'];
                      final isMemberAdmin = member['role'] == 'admin';
                      final isMe = member['user_id'] == _currentUserId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: profile?['profile_image_url'] != null
                              ? NetworkImage(profile['profile_image_url'])
                              : null,
                          child: profile?['profile_image_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          isMe ? 'You' : (profile?['name'] ?? 'Unknown'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          profile?['bio'] ?? 'Busy', // Or role if needed
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isMemberAdmin
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.yellow),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Group Admin',
                                    style: TextStyle(
                                        color: Colors.yellow, fontSize: 10)),
                              )
                            : (_userRole == 'admin'
                                ? IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeMember(member['user_id']),
                                  )
                                : null),
                        onTap: () {
                          if (member['user_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerfiedSwitchPage(
                                  userId: member['user_id'].toString(),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 32),

                    // Exit Group Button
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Exit group',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        _showLeaveGroupDialog();
                      },
                    ),
                    if ((_userRole?.toLowerCase() ?? '') == 'admin')
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('Delete group',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteGroup();
                        },
                      ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeMember(String userId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('group_members')
          .update({'is_active': false})
          .eq('group_id', widget.groupId)
          .eq('user_id', userId);

      _fetchMembers();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error removing member: $e');
    }
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        multipleSelection: true,
        onUsersSelected: (selectedUsers) async {
          if (selectedUsers.isNotEmpty) {
            await _addMembers(selectedUsers);
          }
        },
      ),
    );
  }

  Future<void> _addMembers(List<UserResult> users) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      for (var user in users) {
        await supabase.from('group_members').upsert({
          'group_id': widget.groupId,
          'user_id': user.userId,
          'role': 'member',
          'is_active': true,
        });

        await _sendMessage(
          text: 'Added ${user.name} to the group',
          messageType: 'system',
        );
      }
      _fetchMembers();
    } catch (e) {
      debugPrint('Error adding members: $e');
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title:
            const Text('Delete Group', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone and all messages will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final supabase = ref.read(supabaseClientProvider);

      // Delete group image if exists
      if (widget.groupImage != null && widget.groupImage!.isNotEmpty) {
        try {
          // Attempt to extract filename from URL.
          // Standard Supabase URL: .../storage/v1/object/public/[bucket]/[filename]
          // We assume filename is the last segment.
          final uri = Uri.parse(widget.groupImage!);
          final fileName = uri.pathSegments.last;

          await supabase.storage
              .from('group-profileimagesorginal')
              .remove([fileName]);
        } catch (e) {
          debugPrint('Error deleting group image: $e');
        }
      }

      // Delete group (Cascade should handle members and messages)
      await supabase.from('groups').delete().eq('id', widget.groupId);

      if (mounted) {
        Navigator.pop(context); // Close chat screen
      }
    } catch (e) {
      debugPrint('Error deleting group: $e');
      _showSnackBar('Error deleting group: $e', isError: true);
    }
  }

  bool _isAdmin(String userId) {
    return _groupMembers.any((m) =>
        m['user_id'] == userId &&
        (m['role']?.toString().toLowerCase() ?? '') == 'admin');
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to leave this group?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveGroup();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveGroup() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('group_members')
          .update({'is_active': false})
          .eq('group_id', widget.groupId)
          .eq('user_id', _currentUserId);

      // Send system message
      await _sendMessage(
        text: 'Left the group',
        messageType: 'system',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error leaving group: $e');
    }
  }

  Future<void> _handleVoiceMessage(String path, int duration) async {
    try {
      final file = File(path);
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = '${widget.groupId}/$fileName';

      await _supabase.storage.from('voice-messages').upload(storagePath, file);
      final url =
          _supabase.storage.from('voice-messages').getPublicUrl(storagePath);

      await _sendMessage(
        text: 'Voice Message 🎤',
        messageType: 'voice',
        fileUrl: url,
        voiceDuration: duration,
      );
    } catch (e) {
      debugPrint('Error sending voice: $e');
      _showSnackBar('Failed to send voice message: $e', isError: true);
    }
  }

  // Helper for safe data extraction from Supabase joins
  Map<String, dynamic>? _safeGet(dynamic input) {
    if (input == null) return null;
    if (input is Map) return Map<String, dynamic>.from(input);
    if (input is List && input.isNotEmpty) {
      final first = input.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Center(
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white.withOpacity(0.5),
                          size: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.yellow),
      ),
    );
  }
}
