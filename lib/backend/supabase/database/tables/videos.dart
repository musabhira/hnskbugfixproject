import '../database.dart';

class VideosTable extends SupabaseTable<VideosRow> {
  @override
  String get tableName => 'videos';

  @override
  VideosRow createRow(Map<String, dynamic> data) => VideosRow(data);
}

class VideosRow extends SupabaseDataRow {
  VideosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VideosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get videoUrl => getField<String>('video_url');
  set videoUrl(String? value) => setField<String>('video_url', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) => setField<String>('thumbnail_url', value);

  int? get duration => getField<int>('duration');
  set duration(int? value) => setField<int>('duration', value);

  int? get orderIndex => getField<int>('order_index');
  set orderIndex(int? value) => setField<int>('order_index', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
