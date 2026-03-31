import '../database.dart';

class FriendNotesTable extends SupabaseTable<FriendNotesRow> {
  @override
  String get tableName => 'friend_notes';

  @override
  FriendNotesRow createRow(Map<String, dynamic> data) => FriendNotesRow(data);
}

class FriendNotesRow extends SupabaseDataRow {
  FriendNotesRow(super.data);

  @override
  SupabaseTable get table => FriendNotesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get note => getField<String>('note')!;
  set note(String value) => setField<String>('note', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
