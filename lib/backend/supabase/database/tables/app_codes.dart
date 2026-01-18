import '../database.dart';

class AppCodesTable extends SupabaseTable<AppCodesRow> {
  @override
  String get tableName => 'app_codes';

  @override
  AppCodesRow createRow(Map<String, dynamic> data) => AppCodesRow(data);
}

class AppCodesRow extends SupabaseDataRow {
  AppCodesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppCodesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get className => getField<String>('class_name')!;
  set className(String value) => setField<String>('class_name', value);

  String get classCode => getField<String>('class_code')!;
  set classCode(String value) => setField<String>('class_code', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get version => getField<String>('version');
  set version(String? value) => setField<String>('version', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
