import '../database.dart';

class AnnouncementsTable extends SupabaseTable<AnnouncementsRow> {
  @override
  String get tableName => 'announcements';

  @override
  AnnouncementsRow createRow(Map<String, dynamic> data) =>
      AnnouncementsRow(data);
}

class AnnouncementsRow extends SupabaseDataRow {
  AnnouncementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AnnouncementsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
