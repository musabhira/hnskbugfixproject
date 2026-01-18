import '../database.dart';

class ProfileFollowCountsTable extends SupabaseTable<ProfileFollowCountsRow> {
  @override
  String get tableName => 'profile_follow_counts';

  @override
  ProfileFollowCountsRow createRow(Map<String, dynamic> data) =>
      ProfileFollowCountsRow(data);
}

class ProfileFollowCountsRow extends SupabaseDataRow {
  ProfileFollowCountsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfileFollowCountsTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get followersCount => getField<int>('followers_count');
  set followersCount(int? value) => setField<int>('followers_count', value);

  int? get followingCount => getField<int>('following_count');
  set followingCount(int? value) => setField<int>('following_count', value);

  int? get galleryCount => getField<int>('gallery_count');
  set galleryCount(int? value) => setField<int>('gallery_count', value);

  int? get serviceCount => getField<int>('service_count');
  set serviceCount(int? value) => setField<int>('service_count', value);
}
