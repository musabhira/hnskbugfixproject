import '../database.dart';

class AllcoursesTable extends SupabaseTable<AllcoursesRow> {
  @override
  String get tableName => 'allcourses';

  @override
  AllcoursesRow createRow(Map<String, dynamic> data) => AllcoursesRow(data);
}

class AllcoursesRow extends SupabaseDataRow {
  AllcoursesRow(super.data);

  @override
  SupabaseTable get table => AllcoursesTable();

  String? get courseId => getField<String>('course_id');
  set courseId(String? value) => setField<String>('course_id', value);

  String? get courseTitle => getField<String>('course_title');
  set courseTitle(String? value) => setField<String>('course_title', value);

  String? get courseDescription => getField<String>('course_description');
  set courseDescription(String? value) =>
      setField<String>('course_description', value);

  String? get courseThumbnail => getField<String>('course_thumbnail');
  set courseThumbnail(String? value) =>
      setField<String>('course_thumbnail', value);

  DateTime? get courseCreatedAt => getField<DateTime>('course_created_at');
  set courseCreatedAt(DateTime? value) =>
      setField<DateTime>('course_created_at', value);

  String? get coursePrice => getField<String>('course_price');
  set coursePrice(String? value) => setField<String>('course_price', value);

  String? get courseLanguage => getField<String>('course_language');
  set courseLanguage(String? value) =>
      setField<String>('course_language', value);

  String? get courseRetailPrice => getField<String>('course_retail_price');
  set courseRetailPrice(String? value) =>
      setField<String>('course_retail_price', value);

  String? get lessonId => getField<String>('lesson_id');
  set lessonId(String? value) => setField<String>('lesson_id', value);

  String? get lessonTitle => getField<String>('lesson_title');
  set lessonTitle(String? value) => setField<String>('lesson_title', value);

  String? get lessonContent => getField<String>('lesson_content');
  set lessonContent(String? value) => setField<String>('lesson_content', value);

  String? get lessonVideoUrl => getField<String>('lesson_video_url');
  set lessonVideoUrl(String? value) =>
      setField<String>('lesson_video_url', value);

  String? get lessonThumbnail => getField<String>('lesson_thumbnail');
  set lessonThumbnail(String? value) =>
      setField<String>('lesson_thumbnail', value);

  DateTime? get lessonCreatedAt => getField<DateTime>('lesson_created_at');
  set lessonCreatedAt(DateTime? value) =>
      setField<DateTime>('lesson_created_at', value);
}
