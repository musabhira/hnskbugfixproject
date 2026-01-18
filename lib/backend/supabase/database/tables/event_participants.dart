import '../database.dart';

class EventParticipantsTable extends SupabaseTable<EventParticipantsRow> {
  @override
  String get tableName => 'event_participants';

  @override
  EventParticipantsRow createRow(Map<String, dynamic> data) =>
      EventParticipantsRow(data);
}

class EventParticipantsRow extends SupabaseDataRow {
  EventParticipantsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventParticipantsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get eventId => getField<String>('event_id')!;
  set eventId(String value) => setField<String>('event_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);
}
