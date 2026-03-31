import '../database.dart';

class FavoriteCoursesTable extends SupabaseTable<FavoriteCoursesRow> {
  @override
  String get tableName => 'favorite_courses';

  @override
  FavoriteCoursesRow createRow(Map<String, dynamic> data) =>
      FavoriteCoursesRow(data);
}

class FavoriteCoursesRow extends SupabaseDataRow {
  FavoriteCoursesRow(super.data);

  @override
  SupabaseTable get table => FavoriteCoursesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get courseId => getField<String>('course_id');
  set courseId(String? value) => setField<String>('course_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);
}
