import '../database.dart';

class AdWatchLimitsTable extends SupabaseTable<AdWatchLimitsRow> {
  @override
  String get tableName => 'ad_watch_limits';

  @override
  AdWatchLimitsRow createRow(Map<String, dynamic> data) =>
      AdWatchLimitsRow(data);
}

class AdWatchLimitsRow extends SupabaseDataRow {
  AdWatchLimitsRow(super.data);

  @override
  SupabaseTable get table => AdWatchLimitsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int? get adsWatchedThisHour => getField<int>('ads_watched_this_hour');
  set adsWatchedThisHour(int? value) =>
      setField<int>('ads_watched_this_hour', value);

  int? get adsWatchedToday => getField<int>('ads_watched_today');
  set adsWatchedToday(int? value) => setField<int>('ads_watched_today', value);

  DateTime? get lastHourReset => getField<DateTime>('last_hour_reset');
  set lastHourReset(DateTime? value) =>
      setField<DateTime>('last_hour_reset', value);

  DateTime? get lastDayReset => getField<DateTime>('last_day_reset');
  set lastDayReset(DateTime? value) =>
      setField<DateTime>('last_day_reset', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
