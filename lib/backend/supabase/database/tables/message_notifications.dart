import '../database.dart';

class MessageNotificationsTable extends SupabaseTable<MessageNotificationsRow> {
  @override
  String get tableName => 'message_notifications';

  @override
  MessageNotificationsRow createRow(Map<String, dynamic> data) =>
      MessageNotificationsRow(data);
}

class MessageNotificationsRow extends SupabaseDataRow {
  MessageNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageNotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get senderId => getField<String>('sender_id')!;
  set senderId(String value) => setField<String>('sender_id', value);

  String get senderName => getField<String>('sender_name')!;
  set senderName(String value) => setField<String>('sender_name', value);

  String? get senderProfileImage => getField<String>('sender_profile_image');
  set senderProfileImage(String? value) =>
      setField<String>('sender_profile_image', value);

  String get messagePreview => getField<String>('message_preview')!;
  set messagePreview(String value) =>
      setField<String>('message_preview', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  bool? get isRead => getField<bool>('is_read');
  set isRead(bool? value) => setField<bool>('is_read', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
