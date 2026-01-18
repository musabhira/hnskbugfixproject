import '../database.dart';

class WatchSessionsTable extends SupabaseTable<WatchSessionsRow> {
  @override
  String get tableName => 'watch_sessions';

  @override
  WatchSessionsRow createRow(Map<String, dynamic> data) =>
      WatchSessionsRow(data);
}

class WatchSessionsRow extends SupabaseDataRow {
  WatchSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WatchSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  int? get totalCoinsEarned => getField<int>('total_coins_earned');
  set totalCoinsEarned(int? value) =>
      setField<int>('total_coins_earned', value);

  int? get adsWatchedCount => getField<int>('ads_watched_count');
  set adsWatchedCount(int? value) => setField<int>('ads_watched_count', value);

  int? get totalWatchTimeSeconds => getField<int>('total_watch_time_seconds');
  set totalWatchTimeSeconds(int? value) =>
      setField<int>('total_watch_time_seconds', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  DateTime? get endedAt => getField<DateTime>('ended_at');
  set endedAt(DateTime? value) => setField<DateTime>('ended_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
