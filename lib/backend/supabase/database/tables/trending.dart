import '../database.dart';

class TrendingTable extends SupabaseTable<TrendingRow> {
  @override
  String get tableName => 'trending';

  @override
  TrendingRow createRow(Map<String, dynamic> data) => TrendingRow(data);
}

class TrendingRow extends SupabaseDataRow {
  TrendingRow(super.data);

  @override
  SupabaseTable get table => TrendingTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  int? get searchCount => getField<int>('search_count');
  set searchCount(int? value) => setField<int>('search_count', value);

  DateTime? get lastSearchedAt => getField<DateTime>('last_searched_at');
  set lastSearchedAt(DateTime? value) =>
      setField<DateTime>('last_searched_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
