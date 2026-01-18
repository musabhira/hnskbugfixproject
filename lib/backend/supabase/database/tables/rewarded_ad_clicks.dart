import '../database.dart';

class RewardedAdClicksTable extends SupabaseTable<RewardedAdClicksRow> {
  @override
  String get tableName => 'rewarded_ad_clicks';

  @override
  RewardedAdClicksRow createRow(Map<String, dynamic> data) =>
      RewardedAdClicksRow(data);
}

class RewardedAdClicksRow extends SupabaseDataRow {
  RewardedAdClicksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RewardedAdClicksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get sessionId => getField<String>('session_id')!;
  set sessionId(String value) => setField<String>('session_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get adUnitId => getField<String>('ad_unit_id')!;
  set adUnitId(String value) => setField<String>('ad_unit_id', value);

  int get rewardAmount => getField<int>('reward_amount')!;
  set rewardAmount(int value) => setField<int>('reward_amount', value);

  DateTime? get clickedAt => getField<DateTime>('clicked_at');
  set clickedAt(DateTime? value) => setField<DateTime>('clicked_at', value);
}
