import '../database.dart';

class FriendlistTable extends SupabaseTable<FriendlistRow> {
  @override
  String get tableName => 'friendlist';

  @override
  FriendlistRow createRow(Map<String, dynamic> data) => FriendlistRow(data);
}

class FriendlistRow extends SupabaseDataRow {
  FriendlistRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FriendlistTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get profileId => getField<String>('profile_id');
  set profileId(String? value) => setField<String>('profile_id', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);
}
