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
  final bool isEdited;
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
    this.isEdited = false,
    this.gallery,
    this.thought,
    this.tool,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
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
      senderProfile: json['sender_profile'],
      replyToMessage: json['reply_to'],
      isEdited: json['is_edited'] ?? false,
      gallery: json['gallery'],
      thought: json['thought'],
      tool: json['tool'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'message_text': messageText,
      'message_type': messageType,
      'file_url': fileUrl,
      'voice_duration': voiceDuration,
      'reply_to_message_id': replyToMessageId,
      'created_at': createdAt.toIso8601String(),
      'sender_profile': senderProfile,
      'reply_to': replyToMessage,
      'is_edited': isEdited,
      'gallery': gallery,
      'thought': thought,
      'tool': tool,
      'metadata': metadata,
    };
  }
}
