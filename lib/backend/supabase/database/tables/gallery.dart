import '../database.dart';

class GalleryTable extends SupabaseTable<GalleryRow> {
  @override
  String get tableName => 'gallery';

  @override
  GalleryRow createRow(Map<String, dynamic> data) => GalleryRow(data);
}

class GalleryRow extends SupabaseDataRow {
  GalleryRow(super.data);

  @override
  SupabaseTable get table => GalleryTable();

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

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get secondTitle => getField<String>('second_title');
  set secondTitle(String? value) => setField<String>('second_title', value);
}
