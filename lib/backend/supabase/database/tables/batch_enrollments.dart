import '../database.dart';

class BatchEnrollmentsTable extends SupabaseTable<BatchEnrollmentsRow> {
  @override
  String get tableName => 'batch_enrollments';

  @override
  BatchEnrollmentsRow createRow(Map<String, dynamic> data) =>
      BatchEnrollmentsRow(data);
}

class BatchEnrollmentsRow extends SupabaseDataRow {
  BatchEnrollmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BatchEnrollmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get enrolledAt => getField<DateTime>('enrolled_at');
  set enrolledAt(DateTime? value) => setField<DateTime>('enrolled_at', value);

  String? get codeUsed => getField<String>('code_used');
  set codeUsed(String? value) => setField<String>('code_used', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
