import '../database.dart';

class PremiumFeaturesTable extends SupabaseTable<PremiumFeaturesRow> {
  @override
  String get tableName => 'premium_features';

  @override
  PremiumFeaturesRow createRow(Map<String, dynamic> data) =>
      PremiumFeaturesRow(data);
}

class PremiumFeaturesRow extends SupabaseDataRow {
  PremiumFeaturesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PremiumFeaturesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get emailSupport => getField<String>('email_support');
  set emailSupport(String? value) => setField<String>('email_support', value);

  int? get selectedHomeDesign => getField<int>('selected_home_design');
  set selectedHomeDesign(int? value) =>
      setField<int>('selected_home_design', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  int? get bannerCount => getField<int>('banner_count');
  set bannerCount(int? value) => setField<int>('banner_count', value);

  List<String> get bannerImages => getListField<String>('banner_images');
  set bannerImages(List<String>? value) =>
      setListField<String>('banner_images', value);

  List<String> get bannerTitles => getListField<String>('banner_titles');
  set bannerTitles(List<String>? value) =>
      setListField<String>('banner_titles', value);

  List<String> get bannerDescriptions =>
      getListField<String>('banner_descriptions');
  set bannerDescriptions(List<String>? value) =>
      setListField<String>('banner_descriptions', value);

  List<String> get bannerLinks => getListField<String>('banner_links');
  set bannerLinks(List<String>? value) =>
      setListField<String>('banner_links', value);

  bool? get bannerEnabled => getField<bool>('banner_enabled');
  set bannerEnabled(bool? value) => setField<bool>('banner_enabled', value);
}
