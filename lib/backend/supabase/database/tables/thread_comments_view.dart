import '../database.dart';

class ThreadCommentsViewTable extends SupabaseTable<ThreadCommentsViewRow> {
  @override
  String get tableName => 'thread_comments_view';

  @override
  ThreadCommentsViewRow createRow(Map<String, dynamic> data) =>
      ThreadCommentsViewRow(data);
}

class ThreadCommentsViewRow extends SupabaseDataRow {
  ThreadCommentsViewRow(super.data);

  @override
  SupabaseTable get table => ThreadCommentsViewTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get threadId => getField<String>('thread_id');
  set threadId(String? value) => setField<String>('thread_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get profileImageUrl => getField<String>('profile_image_url');
  set profileImageUrl(String? value) =>
      setField<String>('profile_image_url', value);
}
