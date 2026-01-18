import '../database.dart';

class ThreadsTable extends SupabaseTable<ThreadsRow> {
  @override
  String get tableName => 'threads';

  @override
  ThreadsRow createRow(Map<String, dynamic> data) => ThreadsRow(data);
}

class ThreadsRow extends SupabaseDataRow {
  ThreadsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ThreadsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  int? get fakeLikes => getField<int>('fake_likes');
  set fakeLikes(int? value) => setField<int>('fake_likes', value);
}
