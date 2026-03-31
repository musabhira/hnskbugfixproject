import '../database.dart';

class LessonsTechTable extends SupabaseTable<LessonsTechRow> {
  @override
  String get tableName => 'lessons_tech';

  @override
  LessonsTechRow createRow(Map<String, dynamic> data) => LessonsTechRow(data);
}

class LessonsTechRow extends SupabaseDataRow {
  LessonsTechRow(super.data);

  @override
  SupabaseTable get table => LessonsTechTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get courseId => getField<String>('course_id');
  set courseId(String? value) => setField<String>('course_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  String? get videoUrl => getField<String>('video_url');
  set videoUrl(String? value) => setField<String>('video_url', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) => setField<String>('thumbnail_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
