import '../database.dart';

class BatchesTable extends SupabaseTable<BatchesRow> {
  @override
  String get tableName => 'batches';

  @override
  BatchesRow createRow(Map<String, dynamic> data) => BatchesRow(data);
}

class BatchesRow extends SupabaseDataRow {
  BatchesRow(super.data);

  @override
  SupabaseTable get table => BatchesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get startDate => getField<DateTime>('start_date')!;
  set startDate(DateTime value) => setField<DateTime>('start_date', value);

  DateTime get endDate => getField<DateTime>('end_date')!;
  set endDate(DateTime value) => setField<DateTime>('end_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
