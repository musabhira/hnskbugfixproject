import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'package:timeago/timeago.dart' as timeago;

import '../index.dart';
import 'chat_models.dart';
import 'chat_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/voice_player.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupImage;

  const ChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImage,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  ChatMessage? _replyingTo;

  // Audio Recording State
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Simple scroll
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent, // Reverse list
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- Input Handlers ---

  Future<void> _sendMessage(
      {String messageType = 'text',
      String? fileUrl,
      int? voiceDuration}) async {
    final text = _textController.text.trim();
    if (text.isEmpty && fileUrl == null) return;

    _textController.clear();
    final replyId = _replyingTo?.id;

    // Clear reply interaction
    setState(() {
      _replyingTo = null;
      _showEmojiPicker = false;
    });

    try {
      await ref.read(chatMessagesProvider(widget.groupId).notifier).sendMessage(
            text: text,
            messageType: messageType,
            fileUrl: fileUrl,
            voiceDuration: voiceDuration,
            replyToId: replyId,
          );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text('Error'),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      // Upload Logic
      // For speed in this artifact, I'll extract upload logic here or in provider.
      // Ideally provider handles everything, but for UI feedback (loading), let's see.

      // Note: To match "High Performance", uploads should happen in background or with progress.
      // For simplicity, we block or show generic loading.

      await _uploadAndSendImage(image);
    }
  }

  Future<void> _uploadAndSendImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final userId = ref.read(currentUserIdProvider);
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      final supabase = ref.read(supabaseClientProvider);
      await supabase.storage.from('group-images').uploadBinary(path, bytes);
      final url = supabase.storage.from('group-images').getPublicUrl(path);

      await _sendMessage(messageType: 'image', fileUrl: url);
    } catch (e) {
// print("Upload error: $e");
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  Future<void> _stopAndSendRecording() async {
    final path = _recordingPath;
    if (!_isRecording || path == null) return;

    await _audioRecorder.stop();
    _recordingTimer?.cancel();
    setState(() => _isRecording = false);

    // Upload
    try {
      final file = File(path);
      if (!file.existsSync()) return;

      final userId = ref.read(currentUserIdProvider);
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = '$userId/$fileName';

      final supabase = ref.read(supabaseClientProvider);
      await supabase.storage.from('voice-messages').upload(storagePath, file);
      final url =
          supabase.storage.from('voice-messages').getPublicUrl(storagePath);

      await _sendMessage(
          messageType: 'voice',
          fileUrl: url,
          voiceDuration: _recordingDuration.inSeconds);
    } catch (e) {
// print("Voice upload error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more when scrolled to 80% from bottom (top in reverse list)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  bool _isLoadingMore = false;

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      await ref
          .read(chatMessagesProvider(widget.groupId).notifier)
          .loadMoreMessages();
    } catch (e) {
      // Silently fail or show subtle error
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.groupId));
    final currentUser = ref.watch(currentUserIdProvider);

    return ScaffoldPage(
      header: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: const Color(0xFF1F2C34),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: widget.groupImage != null
                    ? CachedNetworkImage(
                        imageUrl: widget.groupImage!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(FluentIcons.group, size: 24),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.groupName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.video),
              onPressed: () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const NativeWebRTCCallScreen(
                      mode: 'Video',
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.phone),
              onPressed: () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const NativeWebRTCCallScreen(
                      mode: 'Voice',
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.more),
              onPressed: () {},
            ),
          ],
        ),
      ),
      content: ColoredBox(
        color: const Color(0xFF0D1418),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    cacheExtent: 500,
                    itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: ProgressRing(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser;

                      return _MessageBubble(
                        key: ValueKey(msg.id),
                        message: msg,
                        isMe: isMe,
                        onSwipe: () {
                          setState(() {
                            _replyingTo = msg;
                          });
                        },
                      );
                    },
                  );
                },
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text("Error loading messages",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Button(
                        onPressed: () => ref
                            .invalidate(chatMessagesProvider(widget.groupId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: ProgressRing()),
              ),
            ),
            if (_replyingTo != null) _buildReplyPreview(),
            _buildInputArea(),
            if (_showEmojiPicker && !_isRecording) _buildEmojiPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF1F2C34),
      child: Row(
        children: [
          const Icon(FluentIcons.reply, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Replying to ${_replyingTo?.senderProfile?['name'] ?? 'User'}",
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                Text(
                    _replyingTo?.messageText ??
                        _replyingTo?.messageType ??
                        'Message',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(FluentIcons.clear, color: Colors.white),
              onPressed: () => setState(() => _replyingTo = null))
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFF1F2C34),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _showEmojiPicker
                            ? FluentIcons.keyboard_classic
                            : FluentIcons.emoji,
                        color: Colors.grey),
                    onPressed: () {
                      setState(() => _showEmojiPicker = !_showEmojiPicker);
                      if (_showEmojiPicker) FocusScope.of(context).unfocus();
                    },
                  ),
                  Expanded(
                    child: TextBox(
                      controller: _textController,
                      placeholder: "Message",
                      placeholderStyle: const TextStyle(color: Colors.grey),
                      style: const TextStyle(color: Colors.white),
                      decoration: WidgetStateProperty.all(const BoxDecoration(
                        color: Colors.transparent,
                        border: Border.fromBorderSide(BorderSide.none),
                      )),
                      minLines: 1,
                      maxLines: 6,
                      onTap: () {
                        if (_showEmojiPicker) {
                          setState(() => _showEmojiPicker = false);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.attach, color: Colors.grey),
                    onPressed: _pickImage,
                  ),
                  if (_textController.text.isEmpty && !_isRecording)
                    IconButton(
                      icon: const Icon(FluentIcons.camera, color: Colors.grey),
                      onPressed: _pickImage,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopAndSendRecording,
            onTap: () {
              if (_textController.text.isNotEmpty) {
                _sendMessage();
              }
            },
            child: ClipOval(
              child: Container(
                width: 48,
                height: 48,
                color: const Color(0xFF00A884),
                child: Center(
                  child: Icon(
                    _textController.text.isNotEmpty
                        ? FluentIcons.send
                        : (_isRecording
                            ? FluentIcons.mic_off
                            : FluentIcons.microphone),
                    color: Colors.white,
                  ),
                ),
              ),
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
        textEditingController: _textController,
        config: const Config(),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onSwipe;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        // We don't format dismiss, we interpret it as swipe to reply
        // But dismissible actually removes it from tree if not handled carefully.
        // Better use a swipe widget or custom gesture.
        // For now, simpler: Long press or just use the callback if triggered differently.
        // Reverting to GestureDetector wrapper for swipe logic would be better but elaborate.
        // Let's just use Double Tap to Reply for simplicity.
      },
      confirmDismiss: (direction) async {
        onSwipe();
        return false;
      },
      background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(FluentIcons.reply, color: Color(0xB2FFFFFF))),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () async {
            if (message.messageText != null &&
                message.messageText!.isNotEmpty) {
              await Clipboard.setData(
                  ClipboardData(text: message.messageText!));
              if (context.mounted) {
                displayInfoBar(context, builder: (context, close) {
                  return const InfoBar(
                    title: Text('Copied'),
                    content: Text('Message copied to clipboard'),
                    severity: InfoBarSeverity.success,
                  );
                });
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C34),
              borderRadius: BorderRadius.circular(12).copyWith(
                bottomRight: isMe ? Radius.zero : null,
                bottomLeft: isMe ? null : Radius.zero,
              ),
            ),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe && (message.senderProfile != null))
                  Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(message.senderProfile!['name'] ?? 'User',
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                if (message.replyToMessageId != null)
                  _ReplyBubble(replyId: message.replyToMessageId!),
                if (message.messageType == 'image' && message.fileUrl != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) => ImageViewer(
                            imageUrl: message.fileUrl!,
                            title: message.senderProfile?['name'] ?? 'Image',
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: message.fileUrl!,
                        placeholder: (_, __) => Container(
                            height: 150,
                            width: 150,
                            color: const Color(0x1F000000),
                            child: const Center(child: ProgressRing())),
                        errorWidget: (_, __, ___) =>
                            const Icon(FluentIcons.error),
                      ),
                    ),
                  ),
                if (message.messageType == 'gallery' && message.gallery != null)
                  GestureDetector(
                    // Enable tap to navigate if needed
                    child: _buildGalleryMessage(context, message.gallery!),
                  ),
                if (message.messageType == 'voice' && message.fileUrl != null)
                  VoiceMessagePlayer(
                      fileUrl: message.fileUrl!,
                      duration: message.voiceDuration ?? 0,
                      isFromCurrentUser: isMe),
                if (message.messageText != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: SelectableText(
                      message.messageText!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.messageText != null &&
                          message.messageText!.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: message.messageText!));
                            if (context.mounted) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return const InfoBar(
                                  title: Text('Copied'),
                                  severity: InfoBarSeverity.success,
                                );
                              });
                            }
                          },
                          child: Icon(
                            FluentIcons.copy,
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        timeago.format(message.createdAt),
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.54),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryMessage(
      BuildContext context, Map<String, dynamic> galleryData) {
    // Prepare gallery item map as clearly as possible
    final galleryItem = {
      'gallery_id': galleryData['id'],
      'gallery_title': galleryData['title'],
      'gallery_description': galleryData['description'],
      'gallery_image_url': galleryData['image_url'],
      'user_id': galleryData['user_id'],
      'price': galleryData['price'],
      'category': galleryData['category'],
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
          FluentPageRoute(
            builder: (context) => GalleryDetailsPage(
              item: galleryItem,
              allItems: [galleryItem],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF262626),
                Color(0xFF1E1E1E),
              ]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: () {
                if (galleryData['user_id'] != null) {
                  Navigator.push(
                    context,
                    FluentPageRoute(
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
                        border: Border.all(color: Colors.yellow, width: 1),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: () {
                            try {
                              final profileList =
                                  galleryData['user']?['profile'];
                              if (profileList is List &&
                                  profileList.isNotEmpty) {
                                final url = profileList[0]['profile_image_url'];
                                if (url is String && url.isNotEmpty) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                  );
                                }
                              }
                            } catch (_) {}
                            return const Icon(FluentIcons.contact,
                                size: 12, color: Colors.white);
                          }(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        () {
                          try {
                            final profileList = galleryData['user']?['profile'];
                            if (profileList is List && profileList.isNotEmpty) {
                              return profileList[0]['name']?.toString() ??
                                  'User';
                            }
                          } catch (_) {}
                          return 'User';
                        }(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(FluentIcons.chevron_right,
                        size: 10, color: Colors.white),
                  ],
                ),
              ),
            ),

            // Image
            Stack(
              children: [
                if (galleryData['image_url'] != null)
                  CachedNetworkImage(
                    imageUrl: galleryData['image_url'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        height: 160,
                        color: const Color(0xFF262626),
                        child:
                            const Center(child: ProgressRing(strokeWidth: 2))),
                    errorWidget: (_, __, ___) => Container(
                        height: 160,
                        color: const Color(0xFF262626),
                        child:
                            const Icon(FluentIcons.error, color: Colors.white)),
                  ),

                // Price Tag
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
                        border: Border.all(color: Colors.yellow, width: 0.5),
                      ),
                      child: Text(
                        '\$${galleryData['price']}',
                        style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),

            // Footer
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
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    galleryData['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final String replyId;
  const _ReplyBubble({required this.replyId});

  @override
  Widget build(BuildContext context) {
    // In a real app we'd fetch the reply message content via provider.
    // For now simplified visual placeholder.
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: Colors.teal, width: 4)),
      ),
      child: Text("Replying to message...",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              fontSize: 12)),
    );
  }
}

extension GestureDetectorApplier on Widget {
  Widget apply({VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: this);
  }
}