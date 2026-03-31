import '../database.dart';

class GroupActivitiesTable extends SupabaseTable<GroupActivitiesRow> {
  @override
  String get tableName => 'group_activities';

  @override
  GroupActivitiesRow createRow(Map<String, dynamic> data) =>
      GroupActivitiesRow(data);
}

class GroupActivitiesRow extends SupabaseDataRow {
  GroupActivitiesRow(super.data);

  @override
  SupabaseTable get table => GroupActivitiesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get activityType => getField<String>('activity_type');
  set activityType(String? value) => setField<String>('activity_type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  dynamic get dataField => getField<dynamic>('data')!;
  set dataField(dynamic value) => setField<dynamic>('data', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);
}
