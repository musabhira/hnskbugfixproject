import '../database.dart';

class ThreadsViewTable extends SupabaseTable<ThreadsViewRow> {
  @override
  String get tableName => 'threads_view';

  @override
  ThreadsViewRow createRow(Map<String, dynamic> data) => ThreadsViewRow(data);
}

class ThreadsViewRow extends SupabaseDataRow {
  ThreadsViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ThreadsViewTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  int? get fakeLikes => getField<int>('fake_likes');
  set fakeLikes(int? value) => setField<int>('fake_likes', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get profileImageUrl => getField<String>('profile_image_url');
  set profileImageUrl(String? value) =>
      setField<String>('profile_image_url', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  int? get likeCount => getField<int>('like_count');
  set likeCount(int? value) => setField<int>('like_count', value);

  int? get commentCount => getField<int>('comment_count');
  set commentCount(int? value) => setField<int>('comment_count', value);
}
