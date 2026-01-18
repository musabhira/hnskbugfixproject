import '../database.dart';

class GroupMessagesTable extends SupabaseTable<GroupMessagesRow> {
  @override
  String get tableName => 'group_messages';

  @override
  GroupMessagesRow createRow(Map<String, dynamic> data) =>
      GroupMessagesRow(data);
}

class GroupMessagesRow extends SupabaseDataRow {
  GroupMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get senderId => getField<String>('sender_id');
  set senderId(String? value) => setField<String>('sender_id', value);

  String? get messageText => getField<String>('message_text');
  set messageText(String? value) => setField<String>('message_text', value);

  String? get messageType => getField<String>('message_type');
  set messageType(String? value) => setField<String>('message_type', value);

  String? get fileUrl => getField<String>('file_url');
  set fileUrl(String? value) => setField<String>('file_url', value);

  int? get voiceDuration => getField<int>('voice_duration');
  set voiceDuration(int? value) => setField<int>('voice_duration', value);

  bool? get isRead => getField<bool>('is_read');
  set isRead(bool? value) => setField<bool>('is_read', value);

  String? get replyToMessageId => getField<String>('reply_to_message_id');
  set replyToMessageId(String? value) =>
      setField<String>('reply_to_message_id', value);

  String? get galleryId => getField<String>('gallery_id');
  set galleryId(String? value) => setField<String>('gallery_id', value);
}
