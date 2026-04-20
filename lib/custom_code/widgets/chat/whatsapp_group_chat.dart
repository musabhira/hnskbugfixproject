// Automatic FlutterFlow imports

import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_provider.dart';
import 'chat_models.dart';
import 'voice_player.dart';
import 'voice_recorder.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart' hide supabaseClientProvider;

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:pocket_mates_app/custom_code/widgets/courses_widget.dart';

import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import 'package:pocket_mates_app/auth/auth_helper.dart';

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
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _showMentionSuggestions = false;
  String? _mentionQuery;

  // Editing state
  bool _isEditing = false;
  String? _editingMessageId;

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

        // Pagination Trigger: Call loadMoreMessages when reaching the top of scrollable area
        // In reverse: true, maxScrollExtent is the "top" (older messages)
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
          ref.read(chatMessagesProvider(widget.groupId).notifier).loadMoreMessages();
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
    final text = _messageController.text;
    if (text.contains('@')) {
      final lastAt = text.lastIndexOf('@');
      final query = text.substring(lastAt + 1);
      if (!query.contains(' ')) {
        safeSetState(() {
          _showMentionSuggestions = true;
          _mentionQuery = query;
          _filteredMembers = _groupMembers.where((m) {
            final profile = _safeGet(m['profile']);
            final name = (profile?['name'] ?? '').toString().toLowerCase();
            return name.contains(_mentionQuery!.toLowerCase());
          }).toList();
        });
      } else {
        safeSetState(() => _showMentionSuggestions = false);
      }
    } else {
      safeSetState(() => _showMentionSuggestions = false);
    }
    
    // Note: Rebuild swap was moved to ValueListenableBuilder in _buildInputArea
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

  Future<String?> _sendMessage({
    String? text,
    String messageType = 'text',
    String? fileUrl,
    int? voiceDuration,
    String? galleryId,
    String? thoughtId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isSending) return null;

    // Filter out truly empty messages
    bool isEmpty = (text == null || text.trim().isEmpty) &&
        fileUrl == null &&
        galleryId == null &&
        thoughtId == null &&
        metadata == null;

    if (isEmpty && messageType == 'text') return null;

    final replyId = _replyMessage?['id'];
    _isSending = true;
    _messageController.clear();
    safeSetState(() {
      _replyMessage = null;
      _stagedGalleryId = null;
      _stagedThoughtId = null;
      _stagedTool = null;
      _stagedVideoPath = null;
      _stagedDocumentPath = null;
      _stagedAudioPath = null;
    });
    _scrollToBottom();

    try {
      final message = await ref.read(chatMessagesProvider(widget.groupId).notifier).sendMessage(
            text: text ?? '',
            messageType: messageType,
            fileUrl: fileUrl,
            voiceDuration: voiceDuration,
            replyToId: replyId,
            galleryId: galleryId,
            thoughtId: thoughtId,
            metadata: metadata,
          );
      return message?.id;
    } catch (e) {
      debugPrint('SendMessage Error: $e');
      _showErrorSnackBar('Failed to send: $e');
      return null;
    } finally {
      _isSending = false;
    }
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Message', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text('Are you sure you want to delete this message?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(chatMessagesProvider(widget.groupId).notifier)
                  .deleteMessage(messageId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleEditAction(ChatMessage message) {
    safeSetState(() {
      _isEditing = true;
      _editingMessageId = message.id;
      _messageController.text = message.messageText ?? '';
      _focusNode.requestFocus();
    });
  }

  void _cancelEditing() {
    safeSetState(() {
      _isEditing = false;
      _editingMessageId = null;
      _messageController.clear();
      _focusNode.unfocus();
    });
  }

  void _showBlockUserDialog(String otherUserId, String otherUserName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Block $otherUserName?', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to block $otherUserName? They will no longer be able to message you, and you will not see their content.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _blockUser(otherUserId);
            },
            child: const Text('Block', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showUserOptionsDialog(String userId, String name) {
    if (userId == _currentUserId) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: const Text('View Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              final member = _groupMembers.firstWhere(
                  (m) => m['user_id'] == userId,
                  orElse: () => {});
              final url = member['profile']?['profile_image_url'];
              if (url != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageViewer(imageUrl: url, title: name)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.orange),
            title: const Text('Report User', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              ReportHelper.showReportDialog(
                context: context,
                contentType: 'user',
                contentId: userId,
                contentTitle: name,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Block User', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showBlockUserDialog(userId, name);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _blockUser(String blockedId) async {
    try {
      await _supabase.from('blocks').insert({
        'blocker_id': _currentUserId,
        'blocked_id': blockedId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.groupName} has been blocked.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error blocking user: $e')),
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
      ref.invalidate(chatMessagesProvider(widget.groupId));
      ref.invalidate(conversationsProvider);
      await ref.read(chatMessagesProvider(widget.groupId).future);
      await _fetchMembers();
    } catch (e) {
      debugPrint('Refresh error: $e');
      _showSnackBar('Refresh failed: $e');
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: FlutterFlowTheme.of(context).secondaryBackground,
      highlightColor: FlutterFlowTheme.of(context).primaryBackground,
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
                color: FlutterFlowTheme.of(context).primaryBackground,
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
    const backgroundColor = Color(0xFF070B0D);
    const appBarColor = Color(0xFF121B22);
    const accentColor = Colors.yellow;

    final chatMessagesAsync = ref.watch(chatMessagesProvider(widget.groupId));

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        canvasColor: backgroundColor,
        primaryColor: accentColor,
      ),
      child: Scaffold(
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
                      ? 'Tap to view profile'
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
                if (value == 'report') {
                  ReportHelper.showReportDialog(
                    context: context,
                    contentType: 'user',
                    contentId: widget.groupId.startsWith('p:') ? widget.groupId.substring(2) : widget.groupId,
                    contentTitle: widget.groupName,
                  );
                }
                if (value == 'block') {
                  final otherUserId = widget.groupId.startsWith('p:') ? widget.groupId.substring(2) : '';
                  if (otherUserId.isNotEmpty) {
                    _showBlockUserDialog(otherUserId, widget.groupName);
                  }
                }
                if (value == 'clear') {
                  _clearChat();
                }
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
                  if (isPersonalChat) ...[
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear Chat', style: TextStyle(color: Colors.red)),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report User', style: TextStyle(color: Colors.orange)),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Block User', style: TextStyle(color: Colors.red)),
                    ),
                  ],
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

                        final filteredMessages = messages.where((m) {
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

                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: accentColor,
                          backgroundColor: appBarColor,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            reverse: true,
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            itemCount: filteredMessages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == filteredMessages.length) {
                                  return chatMessagesAsync.isLoading ? 
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Center(child: CircularProgressIndicator(color: Colors.yellow, strokeWidth: 2)),
                                    ) : const SizedBox(height: 20);
                              }

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
                  if (_isEditing) _buildEditPreview(),
                  if (_stagedGalleryId != null ||
                      _stagedThoughtId != null ||
                      _stagedTool != null ||
                      _stagedVideoPath != null ||
                      _stagedDocumentPath != null ||
                      _stagedAudioPath != null)
                    _buildStagedPreview(),
                  if (_showMentionSuggestions) _buildMentionSuggestions(),
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

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 8) {
          if (_replyMessage?['id'] != message.id) {
            safeSetState(() {
              _replyMessage = {
                'id': message.id,
                'message_text': message.messageText,
                'sender_id': message.senderId,
                'sender_name': message.senderName,
                'metadata': message.metadata,
                'message_type': message.messageType,
                'file_url': message.fileUrl,
              };
            });
            HapticFeedback.lightImpact();
          }
        }
      },
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        if (!isMe)
          GestureDetector(
            onTap: () => _showUserOptionsDialog(message.senderId, message.senderName ?? 'User'),
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
                if (!isMe && !widget.groupId.startsWith('p:'))
                  GestureDetector(
                    onTap: () => _showUserOptionsDialog(message.senderId, message.senderName ?? 'User'),
                    child: Padding(
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
                                color: Colors.yellow.withValues(alpha: 0.2),
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
                  ),

                GestureDetector(
                  onLongPress: () => _showMessageContextMenu(message, isMe),
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
                          : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
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
                              if (message.replyToMessage != null || 
                                  message.metadata?['reply_type'] == 'status_reply')
                                _buildReplyInBubble(message, isMe),
                              if (message.messageType == 'image')
                                _buildImageMessage(message),
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
                              if (message.messageType == 'video')
                                _buildVideoMessage(message),
                              if (message.messageType == 'tool' &&
                                  message.metadata != null)
                                _buildToolMessage(message.metadata!, isMe),
                              if (message.messageType == 'document')
                                _buildDocumentMessage(message, isMe),
                              if (message.messageType == 'course' &&
                                  message.metadata != null)
                                _buildCourseMessage(message.metadata!, isMe),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        message.messageText!,
                                        onTap: () => _showMessageContextMenu(message, isMe),
                                        style: TextStyle(
                                            color: isMe
                                                ? Colors.black87
                                                : Colors.white.withValues(alpha: 0.93),
                                            fontSize: 15,
                                            height: 1.3),
                                      ),
                                      if (message.isEdited)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'edited',
                                            style: TextStyle(
                                              color: (isMe ? Colors.black54 : Colors.white54),
                                              fontSize: 9,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                _formatTime(message.createdAt),
                                style: TextStyle(
                                  color: (isMe ? Colors.black : Colors.white)
                                      .withValues(alpha: 0.6),
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
                                  color: (message.isOptimistic || message.isPending)
                                      ? (isMe ? Colors.black54 : Colors.white54)
                                      : (message.isRead ? Colors.blue : (isMe ? Colors.black54 : Colors.white54)),
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
    ),
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
    final subTextTheme = isMe ? Colors.black54 : Colors.white.withValues(alpha: 0.7);
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
          color: FlutterFlowTheme.of(context).secondaryBackground,
          border:
              Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
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
                          final profileList = galleryData['user']?['profile'];
                          if (profileList is List && profileList.isNotEmpty) {
                            final url = profileList[0]['profile_image_url'];
                            if (url is String && url.isNotEmpty) {
                              return NetworkImage(url);
                            }
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
                              final profileList =
                                  galleryData['user']?['profile'];
                              if (profileList is List &&
                                  profileList.isNotEmpty) {
                                final name = profileList[0]['name'];
                                if (name is String) {
                                  return name;
                                }
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

  Widget _buildImageMessage(ChatMessage message) {
    final url = message.fileUrl;
    final localPath = message.metadata?['local_path'];

    return GestureDetector(
      onTap: () {
        if (url != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(
                imageUrl: url,
                title: widget.groupName,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Stack(
              children: [
                if (localPath != null && File(localPath).existsSync())
                  Image.file(File(localPath), fit: BoxFit.cover, width: double.infinity, height: 200)
                else if (url != null)
                  CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        height: 200,
                        width: 200,
                        color: Colors.black12,
                        child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  Container(height: 200, width: 200, color: Colors.black12, child: const Icon(Icons.image, color: Colors.white24)),
                
                if (message.isOptimistic)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentMessage(ChatMessage message, bool isMe) {
    final url = message.fileUrl;
    final localPath = message.metadata?['local_path'];
    final mainColor = isMe ? Colors.black87 : Colors.yellow;
    final subColor = isMe ? Colors.black54 : Colors.grey;
    final borderColor = isMe ? Colors.black.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.2);
    final iconBgColor = isMe ? Colors.white.withValues(alpha: 0.4) : Colors.yellow.withValues(alpha: 0.2);
    
    return GestureDetector(
      onTap: () {
        if (url != null) {
          try {
            final uri = Uri.parse(url);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            _showErrorSnackBar('Could not open document: $e');
          }
        } else if (localPath != null) {
          _showSnackBar('Document is still sending...');
        }
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
                  Text(message.isOptimistic ? 'Sending...' : 'Tap to view file',
                      style: TextStyle(color: subColor, fontSize: 11)),
                ],
              ),
            ),
            if (message.isOptimistic)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.yellow))
            else
              Icon(Icons.open_in_new, color: mainColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(ChatMessage message) {
    final url = message.fileUrl;
    final localPath = message.metadata?['local_path'];

    return GestureDetector(
      onTap: () {
        if (url != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(
                videoUrl: url,
                title: widget.groupName,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300, minHeight: 150),
                child: localPath != null && File(localPath).existsSync()
                  ? FutureBuilder<String?>(
                      future: VideoCompress.getFileThumbnail(localPath).then((f) => f.path),
                      builder: (context, snapshot) {
                        return snapshot.hasData ? Image.file(File(snapshot.data!), fit: BoxFit.cover) : Container(color: Colors.black26);
                      })
                  : (url != null ? FutureBuilder<String?>(
                      future: VideoCompress.getFileThumbnail(url).then((f) => f.path),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                        }
                        return Container(height: 200, width: 200, color: Colors.black12, child: const Icon(Icons.videocam, color: Colors.white24, size: 40));
                      },
                    ) : Container(color: Colors.black26)),
              ),
              if (message.isOptimistic)
                const CircularProgressIndicator(color: Colors.yellow)
              else
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
        final String toolName = title;
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

  Widget _buildCourseMessage(Map<String, dynamic> metadata, bool isMe) {
    final String title = metadata['course_title'] ?? 'Course';
    final String? description = metadata['course_description'];
    final String? thumbnail = metadata['course_thumbnail'];

    final titleColor = isMe ? Colors.black87 : Colors.white;
    final subColor =
        isMe ? Colors.black54 : Colors.white.withValues(alpha: 0.6);
    final bgColor = isMe
        ? Colors.black.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.4);
    final borderColor = isMe
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.indigo.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(
              courseData: Map<String, dynamic>.from(metadata),
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.indigo, size: 48),
              ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: subColor,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isMe ? Colors.black87 : Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'View Course',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTool(String title) {
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1F2C34),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) => _showSnackBar(message, isError: true);

  void _showMessageContextMenu(ChatMessage message, bool isMe) {
    if (message.isOptimistic || message.isPending) return;
    
    final canDelete = isMe || _userRole == 'admin';
    final canEdit = isMe && message.messageType == 'text';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.reply, color: Colors.blue),
            title: const Text('Reply', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              safeSetState(() {
                _replyMessage = {
                  'id': message.id,
                  'message_text': message.messageText,
                  'sender_id': message.senderId,
                  'sender_name': message.senderName,
                  'metadata': message.metadata,
                  'message_type': message.messageType,
                  'file_url': message.fileUrl,
                };
              });
            },
          ),
          if (message.messageText != null)
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.green),
              title: const Text('Copy Text', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: message.messageText!));
                _showSnackBar('Copied to clipboard');
              },
            ),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Edit Message', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _handleEditAction(message);
              },
            ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.orangeAccent),
            title: const Text('Report', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              ReportHelper.showReportDialog(
                context: context,
                contentType: 'message',
                contentId: message.id,
                contentTitle: message.messageText ?? 'Media Message',
              );
            },
          ),
          if (canDelete)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(message.id);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEditPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1F2C34),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.yellow, size: 18),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Editing message',
              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
            onPressed: _cancelEditing,
          ),
        ],
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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, child) {
                      if (!_isRecording && value.text.isEmpty) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file, color: Colors.white70),
                              onPressed: () => _showAttachmentBottomSheet(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white70),
                              onPressed: () => _handleCameraAction(),
                            ),
                          ],
                        );
                      } else if (!_isRecording) {
                         return IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.white70),
                            onPressed: () => _showAttachmentBottomSheet(),
                          );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final showSend = value.text.isNotEmpty ||
                  _stagedGalleryId != null ||
                  _stagedThoughtId != null ||
                  _stagedTool != null ||
                  _stagedVideoPath != null ||
                  _stagedDocumentPath != null ||
                  _stagedAudioPath != null;

              if (showSend) {
                return GestureDetector(
                  onTap: _isEditing ? _submitEdit : _handleSendAction,
                  child: CircleAvatar(
                    backgroundColor: Colors.yellow,
                    radius: 24,
                    child: Icon(_isEditing ? Icons.check : Icons.send, color: Colors.black),
                  ),
                );
              } else {
                return VoiceMessageRecorder(
                  onSendMessage: (path, duration) =>
                      _handleVoiceMessage(path, duration),
                  onRecordingStateChanged: (recording) {
                    safeSetState(() => _isRecording = recording);
                  },
                );
              }
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
        config: const Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32,
            backgroundColor: Color(0xFF1F2C34),
            recentsLimit: 28,
          ),
          categoryViewConfig: CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: Color(0xFF1F2C34),
            indicatorColor: Colors.yellow,
            iconColor: Colors.grey,
            iconColorSelected: Colors.yellow,
            backspaceColor: Colors.yellow,
            dividerColor: Color(0xFF1F2C34),
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            enabled: false,
            backgroundColor: Color(0xFF1F2C34),
            buttonColor: Color(0xFF1F2C34),
            buttonIconColor: Colors.grey,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: Color(0xFF1F2C34),
            buttonIconColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showAttachmentBottomSheet() {
    if (!AuthHelper.checkLoggedIn(context)) return;
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    Navigator.pop(ctx);
                    _pickAndStageDocument();
                  }),
                  _buildAttachOption(Icons.camera_alt, Colors.pink, 'Camera',
                      () {
                    Navigator.pop(ctx);
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
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.1),
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
    if (!AuthHelper.checkLoggedIn(context)) return;
    final text = _messageController.text;
    final mentions = _extractMentions(text);
    final metadata = mentions.isNotEmpty ? {'mentions': mentions} : null;

    if (_stagedGalleryId != null) {
      final galleryMetadata = {
        'title': _stagedGalleryTitle,
        'image_url': _stagedGalleryImage,
        if (mentions.isNotEmpty) 'mentions': mentions,
      };
      await _sendMessage(
          text: text,
          messageType: 'gallery',
          galleryId: _stagedGalleryId,
          metadata: galleryMetadata);
    } else if (_stagedThoughtId != null) {
      await _sendMessage(
          text: text, 
          messageType: 'thought', 
          thoughtId: _stagedThoughtId,
          metadata: metadata);
    } else if (_stagedTool != null) {
      final toolMetadata = Map<String, dynamic>.from(_stagedTool!);
      if (mentions.isNotEmpty) toolMetadata['mentions'] = mentions;
      await _sendMessage(
          text: text, messageType: 'tool', metadata: toolMetadata);
    } else if (_stagedVideoPath != null) {
      await _uploadStagedVideo(text); // This also needs to handle metadata if we want
    } else if (_stagedDocumentPath != null) {
      await _uploadStagedFile(text, _stagedDocumentPath!, 'document');
    } else if (_stagedAudioPath != null) {
      await _uploadStagedFile(text, _stagedAudioPath!, 'voice');
    } else {
      await _sendMessage(text: text, metadata: metadata);
    }
  }

  List<String> _extractMentions(String text) {
    if (widget.groupId.startsWith('p:')) return [];
    final mentions = <String>[];
    for (final member in _groupMembers) {
      final name = member['profile']?['name'];
      if (name != null && text.contains('@$name')) {
        mentions.add(member['user_id']);
      }
    }
    return mentions;
  }

  Future<void> _submitEdit() async {
    if (_editingMessageId == null) return;
    final newText = _messageController.text.trim();
    if (newText.isEmpty) {
      _cancelEditing();
      return;
    }

    try {
      final msgId = _editingMessageId!;
      _cancelEditing();
      await ref.read(chatMessagesProvider(widget.groupId).notifier).editMessage(msgId, newText);
      _showSnackBar('Message updated');
    } catch (e) {
      _showErrorSnackBar('Failed to update: $e');
    }
  }

  Future<void> _handleCameraAction() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _pickAndUploadImage(ImageSource.camera);
    } else if (status.isPermanentlyDenied) {
      _showErrorSnackBar('Camera access is permanently denied. Please enable it in settings.');
      openAppSettings();
    } else {
      _showErrorSnackBar('Camera access denied. Please allow it to take photos.');
    }
  }

  Future<void> _uploadStagedFile(String? caption, String path, String type) async {
    // 1. Immediate optimistic send
    final messageId = await _sendMessage(
      text: caption ?? (type == 'document' ? 'Document 📁' : 'Audio 🎵'),
      messageType: type,
      metadata: {'local_path': path}, // Store local path for preview
    );

    // 2. Perform upload in background
    _performBackgroundUpload(messageId, path, type, caption);
    
    safeSetState(() {
      _stagedDocumentPath = null;
      _stagedAudioPath = null;
    });
  }


  Future<File?> _compressVideo(String path) async {
    try {
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info?.file;
    } catch (e) {
      debugPrint('Video compression error: $e');
      return null;
    }
  }

  Future<Uint8List?> _compressImage(String path) async {
    try {
      // Decode image
      final bytes = await File(path).readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      var finalImage = decodedImage;
      // Resize if too large
      if (decodedImage.width > 1200 || decodedImage.height > 1200) {
        finalImage = img.copyResize(decodedImage, width: 1200);
      }

      // Encode with compression
      return Uint8List.fromList(img.encodeJpg(finalImage, quality: 75));
    } catch (e) {
      debugPrint('Image compression error: $e');
      return null;
    }
  }

  Future<void> _performBackgroundUpload(
      String? messageId, String path, String type, String? caption) async {
    if (messageId == null) return;
    try {
      File file = File(path);
      final String bucket = type == 'voice' ? 'voice-messages' : 'ephemeral_media';
      final extension = path.split('.').last;
      final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = '${widget.groupId}/$fileName';

      if (type == 'image') {
        final compressedBytes = await _compressImage(path);
        if (compressedBytes != null) {
          await _supabase.storage.from(bucket).uploadBinary(storagePath, compressedBytes);
        } else {
          await _supabase.storage.from(bucket).upload(storagePath, file);
        }
      } else {
        await _supabase.storage.from(bucket).upload(storagePath, file);
      }
      
      final url = _supabase.storage.from(bucket).getPublicUrl(storagePath);

      // Update the EXISTING record instead of sending a new one
      await ref.read(chatMessagesProvider(widget.groupId).notifier).updateMessageFileUrl(
            messageId,
            url,
          );
    } catch (e) {
      debugPrint('Background upload error: $e');
      _showErrorSnackBar('Failed to deliver $type: $e');
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
      final status = await Permission.videos.request();
      if (!status.isGranted && !status.isLimited) {
        final status2 = await Permission.storage.request();
        if (!status2.isGranted) {
           if (!mounted) return;
           showDialog(
             context: context,
             builder: (context) => AlertDialog(
               backgroundColor: const Color(0xFF1F2C34),
               title: const Text('Access Required', style: TextStyle(color: Colors.white)),
               content: const Text('We need video access to share videos. Please enable it in settings.',
                   style: TextStyle(color: Colors.white70)),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                 TextButton(onPressed: () {
                   Navigator.pop(context);
                   openAppSettings();
                 }, child: const Text('Settings')),
               ],
             ),
           );
           return;
        }
      }

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
    final path = _stagedVideoPath!;
    
    // 1. Immediate optimistic send
    final messageId = await _sendMessage(
      text: caption ?? 'Video 📹',
      messageType: 'video',
      metadata: {'local_path': path},
    );

    // 2. Clear staged path to allow new picking
    safeSetState(() => _stagedVideoPath = null);

    // 3. Perform processing and upload in background
    _performBackgroundVideoUpload(messageId, path, caption);
  }

  Future<void> _performBackgroundVideoUpload(String? messageId, String path, String? caption) async {
    if (messageId == null) return;
    try {
      File fileToUpload = File(path);
      
      // Video Compression
      final compressed = await _compressVideo(path);
      if (compressed != null) {
        fileToUpload = compressed;
        debugPrint('Video compressed: ${fileToUpload.lengthSync()} bytes');
      }

      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storagePath = '${widget.groupId}/$fileName';

      await _supabase.storage.from('ephemeral_media').upload(storagePath, fileToUpload);
      final url = _supabase.storage.from('ephemeral_media').getPublicUrl(storagePath);

      // Update the EXISTING record instead of sending a new one
      await ref.read(chatMessagesProvider(widget.groupId).notifier).updateMessageFileUrl(
            messageId,
            url,
          );

      if (compressed != null) {
        VideoCompress.deleteAllCache();
      }
    } catch (e) {
      debugPrint('Background video upload error: $e');
      _showErrorSnackBar('Failed to deliver video: $e');
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
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image == null) return;

      final path = image.path;
      const type = 'image';

      // 1. Immediate optimistic send
      final messageId = await _sendMessage(
        text: '', 
        messageType: type,
        metadata: {'local_path': path},
      );

      // 2. Perform upload in background
      _performBackgroundUpload(messageId, path, type, '');

      safeSetState(() {
        _showEmojiPicker = false;
      });
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      _showErrorSnackBar('Error: $e');
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

  Widget _buildReplyInBubble(ChatMessage message, bool isMe) {
    // Check if it's a message reply or a status reply
    final reply = message.replyToMessage;
    final metadata = message.metadata;
    final isStatusReply = metadata?['reply_type'] == 'status_reply';

    if (isStatusReply) {
      final statusMediaUrl = metadata?['status_media_url'];
      final statusMediaType = metadata?['status_media_type'];

      return Container(
        margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.black54 : Colors.yellow,
              width: 3,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Replied to Vibe',
                      style: TextStyle(
                        color: isMe ? Colors.black87 : Colors.yellow,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Vibe Reaction',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusMediaUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: statusMediaType == 'text'
                        ? Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.text_fields, color: Colors.white, size: 14),
                          )
                        : CachedNetworkImage(
                            imageUrl: statusMediaUrl,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (reply == null) return const SizedBox.shrink();

    final replyText = reply['message_text']?.toString() ?? 'Media';
    final replyMetadata = reply['metadata'] as Map<String, dynamic>?;
    final isReplyToStatus = replyMetadata?['reply_type'] == 'status_reply';
    final replyStatusMediaUrl = replyMetadata?['status_media_url'];
    final replyStatusMediaType = replyMetadata?['status_media_type'];

    final senderData = reply['sender'];
    final senderProfile = senderData?['profile'];
    final profile = senderProfile is List
        ? (senderProfile.isNotEmpty ? senderProfile.first : null)
        : senderProfile;
    final senderName = profile?['name']?.toString() ?? 'User';

    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.black54 : Colors.yellow,
            width: 3,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isReplyToStatus ? 'Replied to Vibe' : senderName,
                    style: TextStyle(
                      color: isMe ? Colors.black87 : Colors.yellow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    replyText,
                    style: TextStyle(
                      color: isMe ? Colors.black54 : Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isReplyToStatus && replyStatusMediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: replyStatusMediaType == 'text'
                      ? Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.text_fields, color: Colors.white, size: 14),
                        )
                      : CachedNetworkImage(
                          imageUrl: replyStatusMediaUrl,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            if (reply['message_type'] == 'image' && reply['file_url'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: reply['file_url'],
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(Map<String, dynamic> message) {
    final metadata = message['metadata'] as Map<String, dynamic>?;
    final isStatusReply = metadata?['reply_type'] == 'status_reply';
    final statusMediaUrl = metadata?['status_media_url'];
    final statusMediaType = metadata?['status_media_type'];

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isStatusReply ? 'Replying to Vibe' : (message['sender_name'] ?? 'Message'),
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message['message_text'] ?? (isStatusReply ? 'Vibe Reaction' : 'Media'),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isStatusReply && statusMediaUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: statusMediaType == 'text'
                        ? Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.text_fields,
                                color: Colors.white, size: 16),
                          )
                        : CachedNetworkImage(
                            imageUrl: statusMediaUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              const SizedBox(width: 32), // Space for close icon
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white54),
              onPressed: () => safeSetState(() => _replyMessage = null),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing helper methods like _showGroupInfo, _pickAndSendImage)
  void _showGroupInfo() {
    if (widget.groupId.startsWith('p:')) {
      final parts = widget.groupId.substring(2).split('_');
      final targetId = parts.firstWhere((id) => id != _currentUserId, orElse: () => '');
      
      if (targetId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerfiedSwitchPage(userId: targetId),
          ),
        );
      }
      return;
    }
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

                    if (!widget.groupId.startsWith('p:')) ...[
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
                      if ((_userRole?.toLowerCase() ?? '') == 'admin') ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete_sweep_outlined,
                              color: Colors.yellow),
                          title: const Text('Clear all messages',
                              style: TextStyle(color: Colors.yellow)),
                          onTap: () {
                            Navigator.pop(context);
                            _clearChat();
                          },
                        ),
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
                      ],
                    ],
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

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all messages in this group? This action cannot be undone and will affect everyone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = ref.read(supabaseClientProvider);
        await supabase
            .from('group_messages')
            .delete()
            .eq('group_id', widget.groupId);
        // Refresh the messages list
        ref.invalidate(chatMessagesProvider(widget.groupId));
        if (mounted) _showSnackBar('Chat cleared successfully');
      } catch (e) {
        debugPrint('Error clearing chat: $e');
        if (mounted) _showSnackBar('Failed to clear chat', isError: true);
      }
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
    if (!AuthHelper.checkLoggedIn(context)) return;
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

  Widget _buildMentionSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredMembers.length,
        itemBuilder: (context, index) {
          final member = _filteredMembers[index];
          final profile = member['profile'];
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundImage: profile?['profile_image_url'] != null
                  ? NetworkImage(profile['profile_image_url'])
                  : null,
              child: profile?['profile_image_url'] == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            title: Text(profile?['name'] ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            onTap: () {
              final text = _messageController.text;
              final selection = _messageController.selection;
              final lastAtPos = text.lastIndexOf('@', selection.baseOffset - 1);
              
              if (lastAtPos != -1) {
                final newText = text.replaceRange(
                  lastAtPos, 
                  selection.baseOffset, 
                  '@${profile?['name']} '
                );
                _messageController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: lastAtPos + (profile?['name'] as String).length + 2),
                );
              }
              safeSetState(() => _showMentionSuggestions = false);
            },
          );
        },
      ),
    );
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
                          color: Colors.white.withValues(alpha: 0.5),
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
