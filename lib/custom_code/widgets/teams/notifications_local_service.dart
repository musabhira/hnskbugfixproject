import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsLocalService {
  static const String _key = 'local_notifications_list';

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotifications(
      List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(notifications);
    await prefs.setString(_key, jsonString);
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    final list = await getNotifications();
    // Add to top (newest)
    list.insert(0, notification);
    await saveNotifications(list);
  }

  Future<void> updateNotificationStatus(String id, String status) async {
    final list = await getNotifications();
    final index = list.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      list[index]['status'] = status;
      await saveNotifications(list);
    }
  }

  Future<void> syncNotifications(
      List<Map<String, dynamic>> remoteNotifications) async {
    // Replace local or merge? User said "any notification come time list to latest show".
    // Usually full sync is safer if remote is source of truth.
    await saveNotifications(remoteNotifications);
  }
}
