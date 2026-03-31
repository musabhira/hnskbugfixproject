import '../database.dart';

class DailyEarningsTable extends SupabaseTable<DailyEarningsRow> {
  @override
  String get tableName => 'daily_earnings';

  @override
  DailyEarningsRow createRow(Map<String, dynamic> data) =>
      DailyEarningsRow(data);
}

class DailyEarningsRow extends SupabaseDataRow {
  DailyEarningsRow(super.data);

  @override
  SupabaseTable get table => DailyEarningsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get date => getField<DateTime>('date');
  set date(DateTime? value) => setField<DateTime>('date', value);

  int? get totalCoinsEarned => getField<int>('total_coins_earned');
  set totalCoinsEarned(int? value) =>
      setField<int>('total_coins_earned', value);

  int? get sessionCount => getField<int>('session_count');
  set sessionCount(int? value) => setField<int>('session_count', value);

  int? get totalWatchTimeMinutes => getField<int>('total_watch_time_minutes');
  set totalWatchTimeMinutes(int? value) =>
      setField<int>('total_watch_time_minutes', value);
}
