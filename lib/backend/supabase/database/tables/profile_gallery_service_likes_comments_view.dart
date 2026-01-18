import '../database.dart';

class ProfileGalleryServiceLikesCommentsViewTable
    extends SupabaseTable<ProfileGalleryServiceLikesCommentsViewRow> {
  @override
  String get tableName => 'profile_gallery_service_likes_comments_view';

  @override
  ProfileGalleryServiceLikesCommentsViewRow createRow(
          Map<String, dynamic> data) =>
      ProfileGalleryServiceLikesCommentsViewRow(data);
}

class ProfileGalleryServiceLikesCommentsViewRow extends SupabaseDataRow {
  ProfileGalleryServiceLikesCommentsViewRow(Map<String, dynamic> data)
      : super(data);

  @override
  SupabaseTable get table => ProfileGalleryServiceLikesCommentsViewTable();

  String? get profileId => getField<String>('profile_id');
  set profileId(String? value) => setField<String>('profile_id', value);

  DateTime? get profileCreatedAt => getField<DateTime>('profile_created_at');
  set profileCreatedAt(DateTime? value) =>
      setField<DateTime>('profile_created_at', value);

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

  String? get instaId => getField<String>('insta_id');
  set instaId(String? value) => setField<String>('insta_id', value);

  String? get instaLink => getField<String>('insta_link');
  set instaLink(String? value) => setField<String>('insta_link', value);

  String? get galleryId => getField<String>('gallery_id');
  set galleryId(String? value) => setField<String>('gallery_id', value);

  DateTime? get galleryCreatedAt => getField<DateTime>('gallery_created_at');
  set galleryCreatedAt(DateTime? value) =>
      setField<DateTime>('gallery_created_at', value);

  String? get galleryTitle => getField<String>('gallery_title');
  set galleryTitle(String? value) => setField<String>('gallery_title', value);

  String? get galleryDescription => getField<String>('gallery_description');
  set galleryDescription(String? value) =>
      setField<String>('gallery_description', value);

  double? get galleryPrice => getField<double>('gallery_price');
  set galleryPrice(double? value) => setField<double>('gallery_price', value);

  String? get galleryImageUrl => getField<String>('gallery_image_url');
  set galleryImageUrl(String? value) =>
      setField<String>('gallery_image_url', value);

  String? get galleryCategory => getField<String>('gallery_category');
  set galleryCategory(String? value) =>
      setField<String>('gallery_category', value);

  String? get serviceId => getField<String>('service_id');
  set serviceId(String? value) => setField<String>('service_id', value);

  DateTime? get serviceCreatedAt => getField<DateTime>('service_created_at');
  set serviceCreatedAt(DateTime? value) =>
      setField<DateTime>('service_created_at', value);

  String? get serviceTitle => getField<String>('service_title');
  set serviceTitle(String? value) => setField<String>('service_title', value);

  String? get serviceDescription => getField<String>('service_description');
  set serviceDescription(String? value) =>
      setField<String>('service_description', value);

  double? get servicePrice => getField<double>('service_price');
  set servicePrice(double? value) => setField<double>('service_price', value);

  String? get serviceCategory => getField<String>('service_category');
  set serviceCategory(String? value) =>
      setField<String>('service_category', value);

  String? get likeId => getField<String>('like_id');
  set likeId(String? value) => setField<String>('like_id', value);

  DateTime? get likeCreatedAt => getField<DateTime>('like_created_at');
  set likeCreatedAt(DateTime? value) =>
      setField<DateTime>('like_created_at', value);

  String? get commentId => getField<String>('comment_id');
  set commentId(String? value) => setField<String>('comment_id', value);

  String? get commentContent => getField<String>('comment_content');
  set commentContent(String? value) =>
      setField<String>('comment_content', value);

  DateTime? get commentCreatedAt => getField<DateTime>('comment_created_at');
  set commentCreatedAt(DateTime? value) =>
      setField<DateTime>('comment_created_at', value);

  DateTime? get commentUpdatedAt => getField<DateTime>('comment_updated_at');
  set commentUpdatedAt(DateTime? value) =>
      setField<DateTime>('comment_updated_at', value);

  String? get commentUserId => getField<String>('comment_user_id');
  set commentUserId(String? value) =>
      setField<String>('comment_user_id', value);
}
