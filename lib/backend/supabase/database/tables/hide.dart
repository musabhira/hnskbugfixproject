import '../database.dart';

class HideTable extends SupabaseTable<HideRow> {
  @override
  String get tableName => 'hide';

  @override
  HideRow createRow(Map<String, dynamic> data) => HideRow(data);
}

class HideRow extends SupabaseDataRow {
  HideRow(super.data);

  @override
  SupabaseTable get table => HideTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  bool? get isHidden => getField<bool>('is_hidden');
  set isHidden(bool? value) => setField<bool>('is_hidden', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
