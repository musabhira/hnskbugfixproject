import '../database.dart';

class StatusLikesTable extends SupabaseTable<StatusLikesRow> {
  @override
  String get tableName => 'status_likes';

  @override
  StatusLikesRow createRow(Map<String, dynamic> data) => StatusLikesRow(data);
}

class StatusLikesRow extends SupabaseDataRow {
  StatusLikesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusLikesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get statusId => getField<String>('status_id')!;
  set statusId(String value) => setField<String>('status_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);
}
