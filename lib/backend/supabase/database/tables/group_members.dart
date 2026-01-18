import '../database.dart';

class GroupMembersTable extends SupabaseTable<GroupMembersRow> {
  @override
  String get tableName => 'group_members';

  @override
  GroupMembersRow createRow(Map<String, dynamic> data) => GroupMembersRow(data);
}

class GroupMembersRow extends SupabaseDataRow {
  GroupMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupMembersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get profileId => getField<String>('profile_id');
  set profileId(String? value) => setField<String>('profile_id', value);
}
