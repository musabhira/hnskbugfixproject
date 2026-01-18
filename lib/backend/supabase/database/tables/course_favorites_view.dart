import '../database.dart';

class CourseFavoritesViewTable extends SupabaseTable<CourseFavoritesViewRow> {
  @override
  String get tableName => 'course_favorites_view';

  @override
  CourseFavoritesViewRow createRow(Map<String, dynamic> data) =>
      CourseFavoritesViewRow(data);
}

class CourseFavoritesViewRow extends SupabaseDataRow {
  CourseFavoritesViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CourseFavoritesViewTable();

  String? get favoriteId => getField<String>('favorite_id');
  set favoriteId(String? value) => setField<String>('favorite_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get courseId => getField<String>('course_id');
  set courseId(String? value) => setField<String>('course_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get thumbnail => getField<String>('thumbnail');
  set thumbnail(String? value) => setField<String>('thumbnail', value);

  String? get price => getField<String>('price');
  set price(String? value) => setField<String>('price', value);
}
