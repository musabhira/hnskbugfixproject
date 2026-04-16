import 'dart:convert';

class ChatMessage {
  final String id;
  final String? groupId;
  final String? receiverId;
  final String senderId;
  final String? messageText;
  final String messageType;
  final String? fileUrl;
  final int? voiceDuration;
  final String? replyToMessageId;
  final DateTime createdAt;
  final Map<String, dynamic>? senderProfile;
  final Map<String, dynamic>? replyToMessage;
  final bool isOptimistic; // For optimistic UI updates
  final bool isPending; // For offline queued messages
  final bool isEdited;
  final bool isRead;
  final Map<String, dynamic>? gallery;
  final Map<String, dynamic>? thought;
  final Map<String, dynamic>? tool;
  final Map<String, dynamic>? metadata;
  String? get senderName => senderProfile?['name'];

  ChatMessage({
    required this.id,
    this.groupId,
    this.receiverId,
    required this.senderId,
    this.messageText,
    required this.messageType,
    this.fileUrl,
    this.voiceDuration,
    this.replyToMessageId,
    required this.createdAt,
    this.senderProfile,
    this.replyToMessage,
    this.isOptimistic = false,
    this.isPending = false,
    this.isEdited = false,
    this.isRead = false,
    this.gallery,
    this.thought,
    this.tool,
    this.metadata,
  });

  static Map<String, dynamic>? _safeMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedMetadata = _safeMap(json['metadata']);
    String? contentStr = json['content']?.toString();
    if (parsedMetadata == null &&
        contentStr != null &&
        contentStr.startsWith('{')) {
      try {
        final decoded = jsonDecode(contentStr);
        parsedMetadata = _safeMap(decoded);
      } catch (_) {}
    }

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString(),
      receiverId: json['receiver_id']?.toString(),
      senderId: json['sender_id']?.toString() ?? '',
      messageText: json['message_text'] ?? json['content'],
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      voiceDuration: json['voice_duration'],
      replyToMessageId: json['reply_to_message_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      senderProfile: _safeMap(json['sender_profile']),
      replyToMessage: _safeMap(json['reply_to']),
      isOptimistic: json['isOptimistic'] ?? false,
      isPending: json['isPending'] ?? false,
      isEdited: json['is_edited'] ?? false,
      isRead: json['is_read'] ?? false,
      gallery: _safeMap(json['gallery']),
      thought: _safeMap(json['thought']),
      tool: _safeMap(json['tool']),
      metadata: parsedMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'receiver_id': receiverId,
      'sender_id': senderId,
      'message_text': messageText,
      'message_type': messageType,
      'file_url': fileUrl,
      'voice_duration': voiceDuration,
      'reply_to_message_id': replyToMessageId,
      'created_at': createdAt.toIso8601String(),
      'sender_profile': senderProfile,
      'reply_to': replyToMessage,
      'isOptimistic': isOptimistic,
      'isPending': isPending,
      'is_edited': isEdited,
      'is_read': isRead,
      'gallery': gallery,
      'thought': thought,
      'tool': tool,
      'metadata': metadata,
    };
  }
}
