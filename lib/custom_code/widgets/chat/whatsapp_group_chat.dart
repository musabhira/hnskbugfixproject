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
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../webrtc_call_screen.dart';
import '../image_viewer.dart';

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
  List<Map<String, dynamic>> _groupMembers = [];
  String? _userRole; // 'admin' or 'member'
  bool _isSending = false;
  bool _showEmojiPicker = false;
  bool _showAttachMenu = false;
  Map<String, dynamic>? _replyMessage;
  bool _showScrollToBottom = false;

  late AnimationController _attachMenuAnimationController;
  late Animation<double> _attachMenuAnimation;

  // UI related methods
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  void _handleCall(String mode) {
    // Find the first member who isn't the current user
    String? targetId;
    try {
      final otherMember = _groupMembers.firstWhere(
        (m) => m['user_id'] != _currentUserId,
      );
      targetId = otherMember['user_id'];
    } catch (_) {
      // If no other members yet, we can't call
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          mode: mode,
          targetUserId: targetId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
    _fetchMembers();

    _attachMenuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _attachMenuAnimation = CurvedAnimation(
      parent: _attachMenuAnimationController,
      curve: Curves.easeOut,
    );

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _attachMenuAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
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

  Future<void> sendMessage({
    String? text,
    String messageType = 'text',
    String? fileUrl,
    int? voiceDuration,
  }) async {
    if (_isSending) return;

    // Filter out empty messages
    if (messageType == 'text' && (text == null || text.trim().isEmpty)) return;

    // Speed: Clear UI immediately for "Fast" feel
    _messageController.clear();
    safeSetState(() {
      _replyMessage = null;
    });
    // Scroll immediately
    _scrollToBottom();

    try {
      await ref.read(chatMessagesProvider(widget.groupId).notifier).sendMessage(
            text: text ?? '',
            messageType: messageType,
            fileUrl: fileUrl,
            voiceDuration: voiceDuration,
            replyToId: _replyMessage?['id'],
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
      // Invalidate the provider to force a fresh fetch from Supabase
      ref.invalidate(chatMessagesProvider(widget.groupId));
      // Wait for the next value to ensure loading state is handled
      await ref.read(chatMessagesProvider(widget.groupId).future);
      await _fetchMembers();
    } catch (e) {
      debugPrint('Refresh error: $e');
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
    const backgroundColor = Colors.black;
    const appBarColor = Color(0xFF1F2C34);
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
              Hero(
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
                _groupMembers.isEmpty
                    ? 'Tap for info'
                    : '${_groupMembers.length} members',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () => _handleCall('Video'),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () => _handleCall('Voice'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: appBarColor,
            onSelected: (value) {
              if (value == 'refresh') _handleRefresh();
              if (value == 'info') _showGroupInfo();
              if (value == 'leave') _showLeaveGroupDialog();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child:
                    Text('Group Info', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Text('Leave Group', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image/Pattern could go here
          Column(
            children: [
              Expanded(
                child: chatMessagesAsync.when(
                  data: (messages) {
                    // Filter out truly empty/null messages
                    final filteredMessages = messages.where((m) {
                      final hasText =
                          m.messageText != null && m.messageText!.isNotEmpty;
                      final hasFile =
                          m.fileUrl != null && m.fileUrl!.isNotEmpty;
                      return hasText || hasFile;
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

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: accentColor,
                      backgroundColor: appBarColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(bottom: 12, top: 12),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = filteredMessages[index];
                          final isMe = message.senderId == _currentUserId;

                          // Date separator logic
                          bool showDate = true;
                          if (index < filteredMessages.length - 1) {
                            final nextMessage = filteredMessages[index + 1];
                            showDate = !_isSameDay(
                                message.createdAt, nextMessage.createdAt);
                          }

                          return Column(
                            children: [
                              if (showDate)
                                _buildDateSeparator(message.createdAt),
                              _buildMessageTile(message, isMe),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  loading: () => _buildShimmerLoading(),
                  error: (e, st) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $e',
                            style: const TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () => ref.refresh(
                              chatMessagesProvider(widget.groupId).future),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_replyMessage != null) _buildReplyPreview(_replyMessage!),
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
          if (_showAttachMenu) _buildAttachMenu(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: VoiceMessageRecorder(
          groupId: widget.groupId,
          currentUserId: _currentUserId,
          onSendMessage: (type, url, duration) => sendMessage(
            messageType: type,
            fileUrl: url,
            voiceDuration: duration,
          ),
        ),
      ),
    );
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
          color: const Color(0xFF1F2C34).withOpacity(0.6),
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
            color: const Color(0xFF1F2C34).withOpacity(0.8),
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 64 : 16,
          right: isMe ? 16 : 64,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender Name (if group and not me)
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.senderName ?? 'User',
                      style: const TextStyle(
                        color: Colors.yellow, // Matched to app theme
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
                          border: Border.all(color: Colors.yellow, width: 0.5),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(color: Colors.yellow, fontSize: 8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                // Gradient for Me (Golden/Yellow), Solid Dark for Others
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : const Color(0xFF1F2C34),
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 4, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.messageType == 'image' &&
                            message.fileUrl != null)
                          _buildImageMessage(message.fileUrl!),
                        if (message.messageType == 'voice' &&
                            message.fileUrl != null)
                          _buildVoiceMessage(message),
                        if (message.messageText != null &&
                            message.messageText!.isNotEmpty)
                          Text(
                            message.messageText!,
                            style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                                fontSize: 16),
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
                            message.isOptimistic
                                ? Icons.access_time
                                : Icons.done_all,
                            size: 14,
                            color: message.isOptimistic
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
          ],
        ),
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

  Widget _buildVoiceMessage(ChatMessage message) {
    return VoiceMessagePlayer(
      fileUrl: message.fileUrl!,
      duration: message.voiceDuration ?? 0,
      isFromCurrentUser: message.senderId == _currentUserId,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(24),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      minLines: 1,
                      maxLines: 6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.white70),
                    onPressed: () =>
                        safeSetState(() => _showAttachMenu = !_showAttachMenu),
                  ),
                  if (_messageController.text.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white70),
                      onPressed: _pickAndSendImage,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => sendMessage(text: _messageController.text),
            child: const CircleAvatar(
              backgroundColor: Colors.yellow,
              radius: 24,
              child: Icon(Icons.send, color: Colors.black),
            ),
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

  Widget _buildAttachMenu() {
    return Positioned(
      bottom: 95,
      left: 10,
      right: 10,
      child: Card(
        color: const Color(0xFF242F35),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachOption(Icons.insert_drive_file, Colors.indigo,
                      'Document', () {}),
                  _buildAttachOption(Icons.camera_alt, Colors.pink, 'Camera',
                      _pickAndSendImageFromCamera),
                  _buildAttachOption(
                      Icons.image, Colors.purple, 'Gallery', _pickAndSendImage),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachOption(
                      Icons.headset, Colors.orange, 'Audio', () {}),
                  _buildAttachOption(
                      Icons.location_on, Colors.green, 'Location', () {}),
                  _buildAttachOption(
                      Icons.person, Colors.blue, 'Contact', () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add camera support
  Future<void> _pickAndSendImageFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Logic from _pickAndSendImage but with this file
      // I'll extract it to a helper if needed later
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
        color: const Color(0xFF1F2C34),
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
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2C34),
          title: const Text('Add Member (Email)',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter email address',
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              onPressed: () async {
                final email = controller.text.trim();
                if (email.isNotEmpty) {
                  await _addMemberByEmail(email);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting group: $e')),
        );
      }
    }
  }

  Future<void> _addMemberByEmail(String email) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      // Find user by email
      final userResponse = await supabase
          .from('profile')
          .select('user_id, id')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('User not found')));
        }
        return;
      }

      final userId = userResponse['user_id'];
      final profileId = userResponse['id'];

      // Add to group
      await supabase.from('group_members').upsert({
        'group_id': widget.groupId,
        'user_id': userId,
        'profile_id': profileId,
        'role': 'member',
        'is_active': true,
      });

      // Send system message
      final addedName = userResponse['name'] ?? 'New member';
      await sendMessage(
        text: 'Added $addedName to the group',
        messageType: 'system',
      );

      _fetchMembers();
    } catch (e) {
      debugPrint('Error adding member: $e');
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
      await sendMessage(
        text: 'Left the group',
        messageType: 'system',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error leaving group: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$_currentUserId/$fileName';

    await _supabase.storage.from('group-images').uploadBinary(path, bytes);
    final url = _supabase.storage.from('group-images').getPublicUrl(path);

    await sendMessage(messageType: 'image', fileUrl: url);
    safeSetState(() => _showAttachMenu = false);
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
