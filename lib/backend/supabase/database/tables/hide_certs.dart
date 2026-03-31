import '../database.dart';

class HideCertsTable extends SupabaseTable<HideCertsRow> {
  @override
  String get tableName => 'hide_certs';

  @override
  HideCertsRow createRow(Map<String, dynamic> data) => HideCertsRow(data);
}

class HideCertsRow extends SupabaseDataRow {
  HideCertsRow(super.data);

  @override
  SupabaseTable get table => HideCertsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  bool get showPrice => getField<bool>('show_price')!;
  set showPrice(bool value) => setField<bool>('show_price', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
