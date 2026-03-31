import '../database.dart';

class GamesTable extends SupabaseTable<GamesRow> {
  @override
  String get tableName => 'games';

  @override
  GamesRow createRow(Map<String, dynamic> data) => GamesRow(data);
}

class GamesRow extends SupabaseDataRow {
  GamesRow(super.data);

  @override
  SupabaseTable get table => GamesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get gameTitle => getField<String>('game_title')!;
  set gameTitle(String value) => setField<String>('game_title', value);

  String get gameUrl => getField<String>('game_url')!;
  set gameUrl(String value) => setField<String>('game_url', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get gameEmoji => getField<String>('game_emoji');
  set gameEmoji(String? value) => setField<String>('game_emoji', value);

  String get appVersion => getField<String>('app_version')!;
  set appVersion(String value) => setField<String>('app_version', value);

  String? get platform => getField<String>('platform');
  set platform(String? value) => setField<String>('platform', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
