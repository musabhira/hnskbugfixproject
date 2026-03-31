import '../database.dart';

class ProfileTable extends SupabaseTable<ProfileRow> {
  @override
  String get tableName => 'profile';

  @override
  ProfileRow createRow(Map<String, dynamic> data) => ProfileRow(data);
}

class ProfileRow extends SupabaseDataRow {
  ProfileRow(super.data);

  @override
  SupabaseTable get table => ProfileTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get phoneNo => getField<String>('phone_no');
  set phoneNo(String? value) => setField<String>('phone_no', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  String? get shopName => getField<String>('shop_name');
  set shopName(String? value) => setField<String>('shop_name', value);

  String? get profileImageUrl => getField<String>('profile_image_url');
  set profileImageUrl(String? value) =>
      setField<String>('profile_image_url', value);

  String? get bannerImageUrl => getField<String>('banner_image_url');
  set bannerImageUrl(String? value) =>
      setField<String>('banner_image_url', value);

  String? get buttonColorCode => getField<String>('button_color_code');
  set buttonColorCode(String? value) =>
      setField<String>('button_color_code', value);

  String? get bgColorCode => getField<String>('bg_color_code');
  set bgColorCode(String? value) => setField<String>('bg_color_code', value);

  String? get bgTextColor => getField<String>('bg_text_color');
  set bgTextColor(String? value) => setField<String>('bg_text_color', value);

  String? get state => getField<String>('state');
  set state(String? value) => setField<String>('state', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  String? get buttonTextColor => getField<String>('button_text_color');
  set buttonTextColor(String? value) =>
      setField<String>('button_text_color', value);

  bool? get verified => getField<bool>('verified');
  set verified(bool? value) => setField<bool>('verified', value);

  int? get day => getField<int>('day');
  set day(int? value) => setField<int>('day', value);

  int? get month => getField<int>('month');
  set month(int? value) => setField<int>('month', value);

  int? get year => getField<int>('year');
  set year(int? value) => setField<int>('year', value);

  String? get instaId => getField<String>('insta_id');
  set instaId(String? value) => setField<String>('insta_id', value);

  String? get instaLink => getField<String>('insta_link');
  set instaLink(String? value) => setField<String>('insta_link', value);

  bool? get isPremium => getField<bool>('is_premium');
  set isPremium(bool? value) => setField<bool>('is_premium', value);
}
