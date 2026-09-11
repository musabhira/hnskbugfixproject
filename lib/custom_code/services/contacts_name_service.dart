import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📱 Service that maps user IDs and phone numbers to the user's saved local phonebook contacts
class ContactsNameService {
  static final ContactsNameService _instance = ContactsNameService._internal();
  factory ContactsNameService() => _instance;
  ContactsNameService._internal();

  final Map<String, String> _userIdToContactName = {};
  final Map<String, String> _phoneToContactName = {};
  bool _isInitialized = false;

  /// Initialize local contact mappings
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

      // Check permission and load contacts
      final hasPerm = await FlutterContacts.permissions.request(PermissionType.read);
      if (hasPerm == PermissionStatus.granted) {
        final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});
        for (final c in contacts) {
          final String? name = c.displayName;
          if (name == null || name.isEmpty) continue;
          for (final p in c.phones) {
            final String numStr = p.number;
            if (numStr.isEmpty) continue;
            final clean = numStr.replaceAll(RegExp(r'[^\d]'), '');
            if (clean.length >= 7) {
              final last10 = clean.length > 10 ? clean.substring(clean.length - 10) : clean;
              _phoneToContactName[last10] = name;
            }
          }
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('ContactsNameService initialization error: $e');
    }
  }

  /// Normalize phone number to match phonebook format (last 10 digits)
  String normalizePhoneNumber(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^\d]'), '');
    return clean.length > 10 ? clean.substring(clean.length - 10) : clean;
  }

  /// Register matched user ID with contact name
  Future<void> registerUserId(String userId, String contactName) async {
    if (userId.isEmpty || contactName.isEmpty) return;
    _userIdToContactName[userId] = contactName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_contacts_name_map', jsonEncode(_userIdToContactName));
    } catch (_) {}
  }

  /// Match and cache Supabase profile phone numbers
  Future<void> matchProfiles(List<Map<String, dynamic>> profiles) async {
    for (final p in profiles) {
      final uid = p['user_id']?.toString() ?? p['id']?.toString();
      final phone = p['phone_no']?.toString() ?? p['phone']?.toString();
      if (uid != null && phone != null) {
        final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
        final last10 = clean.length > 10 ? clean.substring(clean.length - 10) : clean;
        if (_phoneToContactName.containsKey(last10)) {
          final savedName = _phoneToContactName[last10]!;
          _userIdToContactName[uid] = savedName;
        }
      }
    }
  }

  /// Get display name: returns saved phonebook contact name if matched, else fallback
  String getDisplayName({required String userId, required String fallbackName}) {
    if (_userIdToContactName.containsKey(userId)) {
      final name = _userIdToContactName[userId];
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return fallbackName;
  }
}
