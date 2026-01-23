import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:pocket_mates_app/custom_code/widgets/chat/chat_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/chat_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/voice_player.dart';
import 'package:pocket_mates_app/custom_code/widgets/webrtc_call_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/image_viewer.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D1418), // WhatsApp Dark Background
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundImage: widget.groupImage != null
                ? CachedNetworkImageProvider(widget.groupImage!)
                : null,
            child: widget.groupImage == null ? const Icon(Icons.group) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(widget.groupName, overflow: TextOverflow.ellipsis)),
        ]),
        backgroundColor: const Color(0xFF1F2C34),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Get first member who isn't me
              // For simplicity, navigating to call screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebRTCCallScreen(
                    mode: 'Video',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebRTCCallScreen(
                    mode: 'Voice',
                  ),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
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
                  // Performance: Use itemExtent for fixed-height items if possible
                  // itemExtent: 80, // Uncomment if all messages have similar height
                  cacheExtent: 500, // Cache more items for smoother scrolling
                  itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index == messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser;

                    // Use keys for better performance
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text("Error loading messages",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(chatMessagesProvider(widget.groupId)),
                    child: const Text('Retry'),
                  ),
                ],
              )),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          if (_replyingTo != null) _buildReplyPreview(),
          _buildInputArea(),
          if (_showEmojiPicker && !_isRecording) _buildEmojiPicker(),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF1F2C34),
      child: Row(
        children: [
          const Icon(Icons.reply, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Replying to ${_replyingTo?.senderProfile?['name'] ?? 'User'}",
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                Text(
                    _replyingTo?.messageText ??
                        _replyingTo?.messageType ??
                        'Message',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
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
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: Colors.grey),
                    onPressed: () {
                      setState(() => _showEmojiPicker = !_showEmojiPicker);
                      if (_showEmojiPicker) FocusScope.of(context).unfocus();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
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
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _pickImage,
                  ),
                  if (_textController.text.isEmpty && !_isRecording)
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey),
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
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00A884),
              radius: 24,
              child: Icon(
                _textController.text.isNotEmpty
                    ? Icons.send
                    : (_isRecording ? Icons.mic_off : Icons.mic),
                color: Colors.white,
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
          child: const Icon(Icons.reply, color: Colors.white70)),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                            color: Colors.teal[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              if (message.replyToMessageId != null)
                _ReplyBubble(replyId: message.replyToMessageId!),
              if (message.messageType == 'image' && message.fileUrl != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
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
                          color: Colors.black12,
                          child:
                              const Center(child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
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
                  child: Text(
                    message.messageText!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeago.format(message.createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
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
        color: Colors.black26,
        borderRadius: BorderRadius.circular(4),
        border: const Border(left: BorderSide(color: Colors.teal, width: 4)),
      ),
      child: const Text("Replying to message...",
          style: TextStyle(
              color: Colors.white70,
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
