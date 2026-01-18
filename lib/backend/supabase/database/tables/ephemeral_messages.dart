import '../database.dart';

class EphemeralMessagesTable extends SupabaseTable<EphemeralMessagesRow> {
  @override
  String get tableName => 'ephemeral_messages';

  @override
  EphemeralMessagesRow createRow(Map<String, dynamic> data) =>
      EphemeralMessagesRow(data);
}

class EphemeralMessagesRow extends SupabaseDataRow {
  EphemeralMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EphemeralMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get senderId => getField<String>('sender_id')!;
  set senderId(String value) => setField<String>('sender_id', value);

  String get receiverId => getField<String>('receiver_id')!;
  set receiverId(String value) => setField<String>('receiver_id', value);

  String get messageType => getField<String>('message_type')!;
  set messageType(String value) => setField<String>('message_type', value);

  String get mediaUrl => getField<String>('media_url')!;
  set mediaUrl(String value) => setField<String>('media_url', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) => setField<String>('thumbnail_url', value);

  int? get duration => getField<int>('duration');
  set duration(int? value) => setField<int>('duration', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  bool? get isViewed => getField<bool>('is_viewed');
  set isViewed(bool? value) => setField<bool>('is_viewed', value);

  DateTime? get viewedAt => getField<DateTime>('viewed_at');
  set viewedAt(DateTime? value) => setField<DateTime>('viewed_at', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  DateTime? get deletedAt => getField<DateTime>('deleted_at');
  set deletedAt(DateTime? value) => setField<DateTime>('deleted_at', value);
}
