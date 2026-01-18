import '../database.dart';

class ThreadLikesTable extends SupabaseTable<ThreadLikesRow> {
  @override
  String get tableName => 'thread_likes';

  @override
  ThreadLikesRow createRow(Map<String, dynamic> data) => ThreadLikesRow(data);
}

class ThreadLikesRow extends SupabaseDataRow {
  ThreadLikesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ThreadLikesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get threadId => getField<String>('thread_id')!;
  set threadId(String value) => setField<String>('thread_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get fakeThreadsLikes => getField<String>('fake_threads_likes');
  set fakeThreadsLikes(String? value) =>
      setField<String>('fake_threads_likes', value);
}
