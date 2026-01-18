import '../database.dart';

class UserCouponsTable extends SupabaseTable<UserCouponsRow> {
  @override
  String get tableName => 'user_coupons';

  @override
  UserCouponsRow createRow(Map<String, dynamic> data) => UserCouponsRow(data);
}

class UserCouponsRow extends SupabaseDataRow {
  UserCouponsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserCouponsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get couponCode => getField<String>('coupon_code')!;
  set couponCode(String value) => setField<String>('coupon_code', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);
}
