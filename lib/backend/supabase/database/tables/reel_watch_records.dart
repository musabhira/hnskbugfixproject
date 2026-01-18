import '../database.dart';

class ReelWatchRecordsTable extends SupabaseTable<ReelWatchRecordsRow> {
  @override
  String get tableName => 'reel_watch_records';

  @override
  ReelWatchRecordsRow createRow(Map<String, dynamic> data) =>
      ReelWatchRecordsRow(data);
}

class ReelWatchRecordsRow extends SupabaseDataRow {
  ReelWatchRecordsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReelWatchRecordsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get sessionId => getField<String>('session_id')!;
  set sessionId(String value) => setField<String>('session_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get reelId => getField<String>('reel_id')!;
  set reelId(String value) => setField<String>('reel_id', value);

  int get watchTimeSeconds => getField<int>('watch_time_seconds')!;
  set watchTimeSeconds(int value) => setField<int>('watch_time_seconds', value);

  int get coinsEarned => getField<int>('coins_earned')!;
  set coinsEarned(int value) => setField<int>('coins_earned', value);

  String? get rewardType => getField<String>('reward_type');
  set rewardType(String? value) => setField<String>('reward_type', value);

  DateTime? get watchedAt => getField<DateTime>('watched_at');
  set watchedAt(DateTime? value) => setField<DateTime>('watched_at', value);
}
