import '../database.dart';

class PremiumbannergalleryTable extends SupabaseTable<PremiumbannergalleryRow> {
  @override
  String get tableName => 'premiumbannergallery';

  @override
  PremiumbannergalleryRow createRow(Map<String, dynamic> data) =>
      PremiumbannergalleryRow(data);
}

class PremiumbannergalleryRow extends SupabaseDataRow {
  PremiumbannergalleryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PremiumbannergalleryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  double? get price => getField<double>('price');
  set price(double? value) => setField<double>('price', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
