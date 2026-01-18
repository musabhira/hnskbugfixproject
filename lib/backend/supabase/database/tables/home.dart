import '../database.dart';

class HomeTable extends SupabaseTable<HomeRow> {
  @override
  String get tableName => 'home';

  @override
  HomeRow createRow(Map<String, dynamic> data) => HomeRow(data);
}

class HomeRow extends SupabaseDataRow {
  HomeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HomeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get textRow1 => getField<String>('text_row_1');
  set textRow1(String? value) => setField<String>('text_row_1', value);

  String? get textRow2 => getField<String>('text_row_2');
  set textRow2(String? value) => setField<String>('text_row_2', value);

  String? get textRow3 => getField<String>('text_row_3');
  set textRow3(String? value) => setField<String>('text_row_3', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
