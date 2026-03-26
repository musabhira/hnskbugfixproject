import '../database.dart';

class AppUpdatesTable extends SupabaseTable<AppUpdatesRow> {
  @override
  String get tableName => 'app_updates';

  @override
  AppUpdatesRow createRow(Map<String, dynamic> data) => AppUpdatesRow(data);
}

class AppUpdatesRow extends SupabaseDataRow {
  AppUpdatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppUpdatesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get androidVersion => getField<String>('android_version');
  set androidVersion(String? value) => setField<String>('android_version', value);

  String? get iosVersion => getField<String>('ios_version');
  set iosVersion(String? value) => setField<String>('ios_version', value);

  bool? get androidActive => getField<bool>('android_active');
  set androidActive(bool? value) => setField<bool>('android_active', value);

  bool? get iosActive => getField<bool>('ios_active');
  set iosActive(bool? value) => setField<bool>('ios_active', value);

  bool? get isMandatory => getField<bool>('is_mandatory');
  set isMandatory(bool? value) => setField<bool>('is_mandatory', value);

  String get version => getField<String>('version')!;
  set version(String value) => setField<String>('version', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  List<String> get features => getListField<String>('features');
  set features(List<String>? value) => setListField<String>('features', value);

  String? get iosLink => getField<String>('ios_link');
  set iosLink(String? value) => setField<String>('ios_link', value);

  String? get androidLink => getField<String>('android_link');
  set androidLink(String? value) => setField<String>('android_link', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);
}
