import '../database.dart';

class PromptsTable extends SupabaseTable<PromptsRow> {
  @override
  String get tableName => 'prompts';

  @override
  PromptsRow createRow(Map<String, dynamic> data) => PromptsRow(data);
}

class PromptsRow extends SupabaseDataRow {
  PromptsRow(super.data);

  @override
  SupabaseTable get table => PromptsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get promptText => getField<String>('prompt_text')!;
  set promptText(String value) => setField<String>('prompt_text', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
