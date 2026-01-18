import '../database.dart';

class StatusesTable extends SupabaseTable<StatusesRow> {
  @override
  String get tableName => 'statuses';

  @override
  StatusesRow createRow(Map<String, dynamic> data) => StatusesRow(data);
}

class StatusesRow extends SupabaseDataRow {
  StatusesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get mediaType => getField<String>('media_type')!;
  set mediaType(String value) => setField<String>('media_type', value);

  String get mediaUrl => getField<String>('media_url')!;
  set mediaUrl(String value) => setField<String>('media_url', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) => setField<String>('thumbnail_url', value);

  String? get caption => getField<String>('caption');
  set caption(String? value) => setField<String>('caption', value);

  int? get duration => getField<int>('duration');
  set duration(int? value) => setField<int>('duration', value);

  int? get viewsCount => getField<int>('views_count');
  set viewsCount(int? value) => setField<int>('views_count', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);
}
