import '../database.dart';

class MaterialsTable extends SupabaseTable<MaterialsRow> {
  @override
  String get tableName => 'materials';

  @override
  MaterialsRow createRow(Map<String, dynamic> data) => MaterialsRow(data);
}

class MaterialsRow extends SupabaseDataRow {
  MaterialsRow(super.data);

  @override
  SupabaseTable get table => MaterialsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get pdfUrl => getField<String>('pdf_url')!;
  set pdfUrl(String value) => setField<String>('pdf_url', value);

  int? get fileSize => getField<int>('file_size');
  set fileSize(int? value) => setField<int>('file_size', value);

  int? get orderIndex => getField<int>('order_index');
  set orderIndex(int? value) => setField<int>('order_index', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
