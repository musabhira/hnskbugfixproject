import '../database.dart';

class StatusViewsTable extends SupabaseTable<StatusViewsRow> {
  @override
  String get tableName => 'status_views';

  @override
  StatusViewsRow createRow(Map<String, dynamic> data) => StatusViewsRow(data);
}

class StatusViewsRow extends SupabaseDataRow {
  StatusViewsRow(super.data);

  @override
  SupabaseTable get table => StatusViewsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get statusId => getField<String>('status_id')!;
  set statusId(String value) => setField<String>('status_id', value);

  String get viewerUserId => getField<String>('viewer_user_id')!;
  set viewerUserId(String value) => setField<String>('viewer_user_id', value);

  String get viewerProfileId => getField<String>('viewer_profile_id')!;
  set viewerProfileId(String value) =>
      setField<String>('viewer_profile_id', value);
}
