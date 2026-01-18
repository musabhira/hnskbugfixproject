import '../database.dart';

class BannersTable extends SupabaseTable<BannersRow> {
  @override
  String get tableName => 'banners';

  @override
  BannersRow createRow(Map<String, dynamic> data) => BannersRow(data);
}

class BannersRow extends SupabaseDataRow {
  BannersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BannersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get bannerImageUrl => getField<String>('banner_image_url')!;
  set bannerImageUrl(String value) =>
      setField<String>('banner_image_url', value);

  String? get bannerTitle => getField<String>('banner_title');
  set bannerTitle(String? value) => setField<String>('banner_title', value);

  String? get bannerDescription => getField<String>('banner_description');
  set bannerDescription(String? value) =>
      setField<String>('banner_description', value);

  String? get bannerLink => getField<String>('banner_link');
  set bannerLink(String? value) => setField<String>('banner_link', value);

  int? get bannerOrder => getField<int>('banner_order');
  set bannerOrder(int? value) => setField<int>('banner_order', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
