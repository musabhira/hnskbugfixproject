import '../database.dart';

class UserCourseAccessTable extends SupabaseTable<UserCourseAccessRow> {
  @override
  String get tableName => 'user_course_access';

  @override
  UserCourseAccessRow createRow(Map<String, dynamic> data) =>
      UserCourseAccessRow(data);
}

class UserCourseAccessRow extends SupabaseDataRow {
  UserCourseAccessRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserCourseAccessTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get courseId => getField<String>('course_id')!;
  set courseId(String value) => setField<String>('course_id', value);

  bool? get hasPaid => getField<bool>('has_paid');
  set hasPaid(bool? value) => setField<bool>('has_paid', value);

  String? get appliedCoupon => getField<String>('applied_coupon');
  set appliedCoupon(String? value) => setField<String>('applied_coupon', value);
}
