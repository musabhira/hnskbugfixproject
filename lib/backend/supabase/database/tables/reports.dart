import '../database.dart';

class ReportsTable extends SupabaseTable<ReportsRow> {
  @override
  String get tableName => 'reports';

  @override
  ReportsRow createRow(Map<String, dynamic> data) => ReportsRow(data);
}

class ReportsRow extends SupabaseDataRow {
  ReportsRow(super.data);

  @override
  SupabaseTable get table => ReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reporterId => getField<String>('reporter_id')!;
  set reporterId(String value) => setField<String>('reporter_id', value);

  String get contentType => getField<String>('content_type')!;
  set contentType(String value) => setField<String>('content_type', value);

  String get contentId => getField<String>('content_id')!;
  set contentId(String value) => setField<String>('content_id', value);

  String get reportType => getField<String>('report_type')!;
  set reportType(String value) => setField<String>('report_type', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get additionalInfo => getField<String>('additional_info');
  set additionalInfo(String? value) =>
      setField<String>('additional_info', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
