import '../database.dart';

class UserProgressTable extends SupabaseTable<UserProgressRow> {
  @override
  String get tableName => 'user_progress';

  @override
  UserProgressRow createRow(Map<String, dynamic> data) => UserProgressRow(data);
}

class UserProgressRow extends SupabaseDataRow {
  UserProgressRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserProgressTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String? get contentType => getField<String>('content_type');
  set contentType(String? value) => setField<String>('content_type', value);

  String get contentId => getField<String>('content_id')!;
  set contentId(String value) => setField<String>('content_id', value);

  double? get progress => getField<double>('progress');
  set progress(double? value) => setField<double>('progress', value);

  DateTime? get lastAccessed => getField<DateTime>('last_accessed');
  set lastAccessed(DateTime? value) =>
      setField<DateTime>('last_accessed', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
