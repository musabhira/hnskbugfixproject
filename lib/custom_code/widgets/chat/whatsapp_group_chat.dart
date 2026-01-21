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

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;

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

    _loadGroupMembers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _attachMenuAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupMembers() async {
    try {
      final response = await _supabase
          .from('group_members')
          .select('*, profile:profile!profile_id(*)')
          .eq('group_id', widget.groupId)
          .eq('is_active', true);

      safeSetState(() {
        _groupMembers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading group members: $e');
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
    // Refresh the provider
    ref.invalidate(chatMessagesProvider(widget.groupId));
    await _loadGroupMembers();
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
            onPressed: () {
              // Video call TODO
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Audio call TODO
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: appBarColor,
            onSelected: (value) {
              if (value == 'refresh') _handleRefresh();
              if (value == 'info') _showGroupInfo();
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
                child: Text(
                  message.senderName ?? 'User',
                  style: const TextStyle(
                    color: Colors.yellow, // Matched to app theme
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
                          const Icon(Icons.done_all,
                              size: 14, color: Colors.blue),
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
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildImageMessage(String url) {
    return Padding(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.transparent, // Background handled by parent scaffold/stack
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
                        color: Colors.grey),
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
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      minLines: 1,
                      maxLines: 6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () =>
                        safeSetState(() => _showAttachMenu = !_showAttachMenu),
                  ),
                  if (_messageController.text.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: _pickAndSendImage,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => sendMessage(text: _messageController.text),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00A884),
              radius: 24,
              child: const Icon(Icons.send, color: Colors.white),
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
            indicatorColor: Color(0xFF00A884),
            iconColor: Colors.grey,
            iconColorSelected: Color(0xFF00A884),
            backspaceColor: Color(0xFF00A884),
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
      bottom: 80,
      left: 10,
      right: 10,
      child: Card(
        color: const Color(0xFF1F2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachOption(
                  Icons.image, Colors.purple, 'Gallery', _pickAndSendImage),
              _buildAttachOption(Icons.camera_alt, Colors.red, 'Camera', () {
                // Future implementation
              }),
              _buildAttachOption(Icons.headset, Colors.orange, 'Audio', () {}),
              _buildAttachOption(
                  Icons.location_on, Colors.green, 'Location', () {}),
            ],
          ),
        ),
      ),
    );
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
        border:
            const Border(left: BorderSide(color: Color(0xFF00A884), width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Color(0xFF00A884)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Replying to message',
                    style: TextStyle(
                        color: Color(0xFF00A884),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Group Info',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _groupMembers.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white.withOpacity(0.1)),
                itemBuilder: (context, index) {
                  final member = _groupMembers[index];
                  final profile = member['profile'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profile?['profile_image_url'] != null
                          ? NetworkImage(profile['profile_image_url'])
                          : null,
                      child: profile?['profile_image_url'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(profile?['name'] ?? 'Unknown',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(member['role'] ?? 'member',
                        style: const TextStyle(color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
