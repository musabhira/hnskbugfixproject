import '../database.dart';

class StocksTable extends SupabaseTable<StocksRow> {
  @override
  String get tableName => 'stocks';

  @override
  StocksRow createRow(Map<String, dynamic> data) => StocksRow(data);
}

class StocksRow extends SupabaseDataRow {
  StocksRow(super.data);

  @override
  SupabaseTable get table => StocksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get stockName => getField<String>('stock_name')!;
  set stockName(String value) => setField<String>('stock_name', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
