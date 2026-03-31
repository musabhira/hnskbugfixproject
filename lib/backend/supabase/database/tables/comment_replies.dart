import '../database.dart';

class CommentRepliesTable extends SupabaseTable<CommentRepliesRow> {
  @override
  String get tableName => 'comment_replies';

  @override
  CommentRepliesRow createRow(Map<String, dynamic> data) =>
      CommentRepliesRow(data);
}

class CommentRepliesRow extends SupabaseDataRow {
  CommentRepliesRow(super.data);

  @override
  SupabaseTable get table => CommentRepliesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get commentId => getField<String>('comment_id')!;
  set commentId(String value) => setField<String>('comment_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get profileId => getField<String>('profile_id');
  set profileId(String? value) => setField<String>('profile_id', value);
}
