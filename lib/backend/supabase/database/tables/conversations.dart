import '../database.dart';

class ConversationsTable extends SupabaseTable<ConversationsRow> {
  @override
  String get tableName => 'conversations';

  @override
  ConversationsRow createRow(Map<String, dynamic> data) =>
      ConversationsRow(data);
}

class ConversationsRow extends SupabaseDataRow {
  ConversationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ConversationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get user1Id => getField<String>('user1_id')!;
  set user1Id(String value) => setField<String>('user1_id', value);

  String get user2Id => getField<String>('user2_id')!;
  set user2Id(String value) => setField<String>('user2_id', value);

  String? get lastMessage => getField<String>('last_message');
  set lastMessage(String? value) => setField<String>('last_message', value);

  DateTime? get lastMessageTime => getField<DateTime>('last_message_time');
  set lastMessageTime(DateTime? value) =>
      setField<DateTime>('last_message_time', value);

  String? get lastSenderId => getField<String>('last_sender_id');
  set lastSenderId(String? value) => setField<String>('last_sender_id', value);

  int? get unreadCount => getField<int>('unread_count');
  set unreadCount(int? value) => setField<int>('unread_count', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  bool? get isGroup => getField<bool>('is_group');
  set isGroup(bool? value) => setField<bool>('is_group', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);
}
