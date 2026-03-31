import '../database.dart';

class BatchCodesTable extends SupabaseTable<BatchCodesRow> {
  @override
  String get tableName => 'batch_codes';

  @override
  BatchCodesRow createRow(Map<String, dynamic> data) => BatchCodesRow(data);
}

class BatchCodesRow extends SupabaseDataRow {
  BatchCodesRow(super.data);

  @override
  SupabaseTable get table => BatchCodesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  int? get maxUses => getField<int>('max_uses');
  set maxUses(int? value) => setField<int>('max_uses', value);

  int? get currentUses => getField<int>('current_uses');
  set currentUses(int? value) => setField<int>('current_uses', value);
}
