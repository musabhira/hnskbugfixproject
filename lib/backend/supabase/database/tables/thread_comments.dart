import '../database.dart';

class ThreadCommentsTable extends SupabaseTable<ThreadCommentsRow> {
  @override
  String get tableName => 'thread_comments';

  @override
  ThreadCommentsRow createRow(Map<String, dynamic> data) =>
      ThreadCommentsRow(data);
}

class ThreadCommentsRow extends SupabaseDataRow {
  ThreadCommentsRow(super.data);

  @override
  SupabaseTable get table => ThreadCommentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get threadId => getField<String>('thread_id')!;
  set threadId(String value) => setField<String>('thread_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);
}
