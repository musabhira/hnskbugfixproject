import '../database.dart';

class CommentRepliesWithProfilesTable
    extends SupabaseTable<CommentRepliesWithProfilesRow> {
  @override
  String get tableName => 'comment_replies_with_profiles';

  @override
  CommentRepliesWithProfilesRow createRow(Map<String, dynamic> data) =>
      CommentRepliesWithProfilesRow(data);
}

class CommentRepliesWithProfilesRow extends SupabaseDataRow {
  CommentRepliesWithProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CommentRepliesWithProfilesTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get commentId => getField<String>('comment_id');
  set commentId(String? value) => setField<String>('comment_id', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get profileImageUrl => getField<String>('profile_image_url');
  set profileImageUrl(String? value) =>
      setField<String>('profile_image_url', value);
}
