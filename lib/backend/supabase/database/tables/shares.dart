import '../database.dart';

class SharesTable extends SupabaseTable<SharesRow> {
  @override
  String get tableName => 'shares';

  @override
  SharesRow createRow(Map<String, dynamic> data) => SharesRow(data);
}

class SharesRow extends SupabaseDataRow {
  SharesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SharesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  int get shareNumbers => getField<int>('share_numbers')!;
  set shareNumbers(int value) => setField<int>('share_numbers', value);
}
