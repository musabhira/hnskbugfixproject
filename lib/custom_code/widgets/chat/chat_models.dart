class ChatMessage {
  final String id;
  final String groupId;
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
  String? get senderName => senderProfile?['name'];

  ChatMessage({
    required this.id,
    required this.groupId,
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
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      groupId: json['group_id'],
      senderId: json['sender_id'],
      messageText: json['message_text'],
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      voiceDuration: json['voice_duration'],
      replyToMessageId: json['reply_to_message_id'],
      createdAt: DateTime.parse(json['created_at']),
      senderProfile: json['sender_profile'],
      replyToMessage: json['reply_to'],
      isEdited: json['is_edited'] ?? false,
      gallery: json['gallery'],
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
    };
  }
}
