import '../database.dart';

class TotalSharesTable extends SupabaseTable<TotalSharesRow> {
  @override
  String get tableName => 'total_shares';

  @override
  TotalSharesRow createRow(Map<String, dynamic> data) => TotalSharesRow(data);
}

class TotalSharesRow extends SupabaseDataRow {
  TotalSharesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TotalSharesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  double get generalAmount => getField<double>('general_amount')!;
  set generalAmount(double value) => setField<double>('general_amount', value);

  double get perShare => getField<double>('per_share')!;
  set perShare(double value) => setField<double>('per_share', value);

  double get currentTotalProfit => getField<double>('current_total_profit')!;
  set currentTotalProfit(double value) =>
      setField<double>('current_total_profit', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);
}
