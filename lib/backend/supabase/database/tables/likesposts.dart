import '../database.dart';

class LikespostsTable extends SupabaseTable<LikespostsRow> {
  @override
  String get tableName => 'likesposts';

  @override
  LikespostsRow createRow(Map<String, dynamic> data) => LikespostsRow(data);
}

class LikespostsRow extends SupabaseDataRow {
  LikespostsRow(super.data);

  @override
  SupabaseTable get table => LikespostsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get postId => getField<String>('post_id');
  set postId(String? value) => setField<String>('post_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
