import '../database.dart';

class ServiceTable extends SupabaseTable<ServiceRow> {
  @override
  String get tableName => 'service';

  @override
  ServiceRow createRow(Map<String, dynamic> data) => ServiceRow(data);
}

class ServiceRow extends SupabaseDataRow {
  ServiceRow(super.data);

  @override
  SupabaseTable get table => ServiceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double? get price => getField<double>('price');
  set price(double? value) => setField<double>('price', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);
}
