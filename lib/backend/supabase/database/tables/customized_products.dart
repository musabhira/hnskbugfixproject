import '../database.dart';

class CustomizedProductsTable extends SupabaseTable<CustomizedProductsRow> {
  @override
  String get tableName => 'customized_products';

  @override
  CustomizedProductsRow createRow(Map<String, dynamic> data) =>
      CustomizedProductsRow(data);
}

class CustomizedProductsRow extends SupabaseDataRow {
  CustomizedProductsRow(super.data);

  @override
  SupabaseTable get table => CustomizedProductsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get productId => getField<String>('product_id')!;
  set productId(String value) => setField<String>('product_id', value);

  String? get designImageUrl => getField<String>('design_image_url');
  set designImageUrl(String? value) =>
      setField<String>('design_image_url', value);

  String get color => getField<String>('color')!;
  set color(String value) => setField<String>('color', value);

  double get price => getField<double>('price')!;
  set price(double value) => setField<double>('price', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
