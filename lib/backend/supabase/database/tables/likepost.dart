import '../database.dart';

class LikepostTable extends SupabaseTable<LikepostRow> {
  @override
  String get tableName => 'likepost';

  @override
  LikepostRow createRow(Map<String, dynamic> data) => LikepostRow(data);
}

class LikepostRow extends SupabaseDataRow {
  LikepostRow(super.data);

  @override
  SupabaseTable get table => LikepostTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get postId => getField<int>('post_id')!;
  set postId(int value) => setField<int>('post_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
