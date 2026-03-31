import '../database.dart';

class DemoTable extends SupabaseTable<DemoRow> {
  @override
  String get tableName => 'demo';

  @override
  DemoRow createRow(Map<String, dynamic> data) => DemoRow(data);
}

class DemoRow extends SupabaseDataRow {
  DemoRow(super.data);

  @override
  SupabaseTable get table => DemoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);
}
