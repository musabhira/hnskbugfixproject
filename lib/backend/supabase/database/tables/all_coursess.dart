import '../database.dart';

class AllCoursessTable extends SupabaseTable<AllCoursessRow> {
  @override
  String get tableName => 'AllCoursess';

  @override
  AllCoursessRow createRow(Map<String, dynamic> data) => AllCoursessRow(data);
}

class AllCoursessRow extends SupabaseDataRow {
  AllCoursessRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AllCoursessTable();

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

  String? get lessonId => getField<String>('lesson_id');
  set lessonId(String? value) => setField<String>('lesson_id', value);

  String? get lessonTitle => getField<String>('lesson_title');
  set lessonTitle(String? value) => setField<String>('lesson_title', value);

  String? get lessonContent => getField<String>('lesson_content');
  set lessonContent(String? value) => setField<String>('lesson_content', value);

  String? get lessonVideoUrl => getField<String>('lesson_video_url');
  set lessonVideoUrl(String? value) =>
      setField<String>('lesson_video_url', value);

  String? get lessonThamnail => getField<String>('lesson_thamnail');
  set lessonThamnail(String? value) =>
      setField<String>('lesson_thamnail', value);

  DateTime? get lessonCreatedAt => getField<DateTime>('lesson_created_at');
  set lessonCreatedAt(DateTime? value) =>
      setField<DateTime>('lesson_created_at', value);
}
