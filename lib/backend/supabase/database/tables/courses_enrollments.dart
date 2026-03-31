import '../database.dart';

class CoursesEnrollmentsTable extends SupabaseTable<CoursesEnrollmentsRow> {
  @override
  String get tableName => 'courses_enrollments';

  @override
  CoursesEnrollmentsRow createRow(Map<String, dynamic> data) =>
      CoursesEnrollmentsRow(data);
}

class CoursesEnrollmentsRow extends SupabaseDataRow {
  CoursesEnrollmentsRow(super.data);

  @override
  SupabaseTable get table => CoursesEnrollmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get courseId => getField<String>('course_id');
  set courseId(String? value) => setField<String>('course_id', value);
}
