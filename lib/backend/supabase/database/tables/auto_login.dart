import '../database.dart';

class AutoLoginTable extends SupabaseTable<AutoLoginRow> {
  @override
  String get tableName => 'auto_login';

  @override
  AutoLoginRow createRow(Map<String, dynamic> data) => AutoLoginRow(data);
}

class AutoLoginRow extends SupabaseDataRow {
  AutoLoginRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AutoLoginTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get parentUserId => getField<String>('parent_user_id');
  set parentUserId(String? value) => setField<String>('parent_user_id', value);
}
