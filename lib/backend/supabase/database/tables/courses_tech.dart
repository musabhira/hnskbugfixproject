import '../database.dart';

class CoursesTechTable extends SupabaseTable<CoursesTechRow> {
  @override
  String get tableName => 'courses_tech';

  @override
  CoursesTechRow createRow(Map<String, dynamic> data) => CoursesTechRow(data);
}

class CoursesTechRow extends SupabaseDataRow {
  CoursesTechRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CoursesTechTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get thumbnail => getField<String>('thumbnail');
  set thumbnail(String? value) => setField<String>('thumbnail', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  double? get price => getField<double>('price');
  set price(double? value) => setField<double>('price', value);

  double? get retailPrice => getField<double>('retail_price');
  set retailPrice(double? value) => setField<double>('retail_price', value);

  String? get language => getField<String>('language');
  set language(String? value) => setField<String>('language', value);
}
