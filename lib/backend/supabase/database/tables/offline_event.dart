import '../database.dart';

class OfflineEventTable extends SupabaseTable<OfflineEventRow> {
  @override
  String get tableName => 'offline_event';

  @override
  OfflineEventRow createRow(Map<String, dynamic> data) => OfflineEventRow(data);
}

class OfflineEventRow extends SupabaseDataRow {
  OfflineEventRow(super.data);

  @override
  SupabaseTable get table => OfflineEventTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);
}
