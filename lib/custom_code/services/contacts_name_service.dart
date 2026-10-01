import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/services/push_notification_service.dart';

/// 📱 Service that maps user IDs and phone numbers to the user's saved local phonebook contacts.
/// Powers WhatsApp-style contact name display and Snapchat/Telegram-style contact joined discovery.
class ContactsNameService {
  static final ContactsNameService _instance = ContactsNameService._internal();
  factory ContactsNameService() => _instance;
  ContactsNameService._internal();

  final Map<String, String> _userIdToContactName = {};
  final Map<String, String> _phoneToContactName = {};
  final List<Map<String, dynamic>> _matchedProfiles = [];
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Notifier to trigger UI rebuilds when contact names are synchronized
  final ValueNotifier<int> syncNotifier = ValueNotifier<int>(0);

  List<Map<String, dynamic>> get matchedProfiles => List.unmodifiable(_matchedProfiles);
  List<String> get allSyncedContactUserIds => _userIdToContactName.keys.toList();

  /// Initialize local contact mappings and trigger background Supabase sync
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_contacts_name_map');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        try {
          final decoded = Map<String, dynamic>.from(jsonDecode(cachedStr));
          decoded.forEach((k, v) => _userIdToContactName[k] = v.toString());
        } catch (_) {}
      }

      _isInitialized = true;

      // Automatically sync contacts with Supabase in background
      syncContactsWithSupabase();
    } catch (e) {
      debugPrint('ContactsNameService initialization error: $e');
    }
  }

  /// 🔄 Synchronize local phone contacts with registered Supabase profiles.
  /// Matches phone numbers (last 10 digits) and triggers Snapchat/Telegram-style
  /// "Contact Joined Pocket Mates" notifications for newly discovered friends.
  Future<void> syncContactsWithSupabase({bool notifyNewContacts = true}) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Read contacts permission
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final hasPerm =
            await FlutterContacts.permissions.request(PermissionType.read);
        if (hasPerm != PermissionStatus.granted &&
            hasPerm != PermissionStatus.limited) {
          _isSyncing = false;
          return;
        }

        final contacts =
            await FlutterContacts.getAll(properties: {ContactProperty.phone});
        _phoneToContactName.clear();

        for (final c in contacts) {
          final String? name = c.displayName;
          if (name == null || name.isEmpty) continue;
          for (final p in c.phones) {
            final String numStr = p.number;
            if (numStr.isEmpty) continue;
            final clean = numStr.replaceAll(RegExp(r'[^\d]'), '');
            if (clean.length >= 7) {
              final last10 = clean.length > 10
                  ? clean.substring(clean.length - 10)
                  : clean;
              _phoneToContactName[last10] = name;
            }
          }
        }
      }

      if (_phoneToContactName.isEmpty) {
        _isSyncing = false;
        return;
      }

      // 2. Fetch registered profiles from Supabase that have a phone number
      final response = await SupaFlow.client
          .from('profile')
          .select('user_id, name, profile_image_url, phone_no')
          .neq('phone_no', '')
          .not('phone_no', 'is', null);

      final List<Map<String, dynamic>> profiles =
          List<Map<String, dynamic>>.from(response);

      final prefs = await SharedPreferences.getInstance();
      final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
      final notifiedSet =
          (prefs.getStringList('notified_contacts_on_pocket_mates') ?? []).toSet();
      final List<String> newlyNotified = [];

      _matchedProfiles.clear();

      for (final p in profiles) {
        final uid = p['user_id']?.toString();
        final rawPhone = p['phone_no']?.toString();
        if (uid == null || rawPhone == null || uid.isEmpty) continue;

        final clean = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
        final last10 =
            clean.length > 10 ? clean.substring(clean.length - 10) : clean;

        if (_phoneToContactName.containsKey(last10)) {
          final savedContactName = _phoneToContactName[last10]!;
          _userIdToContactName[uid] = savedContactName;

          final matchedEntry = Map<String, dynamic>.from(p);
          matchedEntry['contact_name'] = savedContactName;
          _matchedProfiles.add(matchedEntry);

          // 📣 Snapchat/Telegram-style "Contact Joined / On Pocket Mates" Viral Notification
          if (notifyNewContacts &&
              uid != currentUserId &&
              !notifiedSet.contains(uid)) {
            newlyNotified.add(uid);
            notifiedSet.add(uid);

            PushNotificationService.showInstantNotification(
              id: uid.hashCode.abs() % 100000,
              title: '👋 $savedContactName is on Poket Mates!',
              body:
                  '$savedContactName from your contacts is on Poket Mates. Tap to say hello and start chatting!',
              payload: 'chat_p:$uid',
            );
          }
        }
      }

      // 3. Persist mappings & notified contacts
      await prefs.setString(
          'cached_contacts_name_map', jsonEncode(_userIdToContactName));
      if (newlyNotified.isNotEmpty) {
        await prefs.setStringList(
            'notified_contacts_on_pocket_mates', notifiedSet.toList());
      }

      // Notify UI listeners to update contact names
      syncNotifier.value++;
    } catch (e) {
      debugPrint('ContactsNameService sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Normalize phone number to match phonebook format (last 10 digits)
  String normalizePhoneNumber(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^\d]'), '');
    return clean.length > 10 ? clean.substring(clean.length - 10) : clean;
  }

  /// Register matched user ID with contact name manually
  Future<void> registerUserId(String userId, String contactName) async {
    if (userId.isEmpty || contactName.isEmpty) return;
    _userIdToContactName[userId] = contactName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_contacts_name_map', jsonEncode(_userIdToContactName));
      syncNotifier.value++;
    } catch (_) {}
  }

  /// Match and cache Supabase profile phone numbers
  Future<void> matchProfiles(List<Map<String, dynamic>> profiles) async {
    for (final p in profiles) {
      final uid = p['user_id']?.toString() ?? p['id']?.toString();
      final phone = p['phone_no']?.toString() ?? p['phone']?.toString();
      if (uid != null && phone != null) {
        final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
        final last10 =
            clean.length > 10 ? clean.substring(clean.length - 10) : clean;
        if (_phoneToContactName.containsKey(last10)) {
          final savedName = _phoneToContactName[last10]!;
          _userIdToContactName[uid] = savedName;
        }
      }
    }
    syncNotifier.value++;
  }

  /// Get display name: returns saved phonebook contact name if matched, else fallback name
  String getDisplayName(
      {required String userId, required String fallbackName}) {
    if (_userIdToContactName.containsKey(userId)) {
      final name = _userIdToContactName[userId];
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return fallbackName;
  }

  /// Whether a specific user is saved in the local phonebook contacts
  bool isContact(String userId) => _userIdToContactName.containsKey(userId);

  /// Get saved contact name if exists
  String? getContactName(String userId) => _userIdToContactName[userId];
}
