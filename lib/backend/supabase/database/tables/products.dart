import '../database.dart';

class ProductsTable extends SupabaseTable<ProductsRow> {
  @override
  String get tableName => 'products';

  @override
  ProductsRow createRow(Map<String, dynamic> data) => ProductsRow(data);
}

class ProductsRow extends SupabaseDataRow {
  ProductsRow(super.data);

  @override
  SupabaseTable get table => ProductsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get modelPath => getField<String>('model_path')!;
  set modelPath(String value) => setField<String>('model_path', value);

  String get thumbnailPath => getField<String>('thumbnail_path')!;
  set thumbnailPath(String value) => setField<String>('thumbnail_path', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
