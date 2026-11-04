import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📌 Model for a Pinned Message inside a PocketGang Group Chat
class PinnedGroupMessage {
  final String messageId;
  final String groupId;
  final String messageText;
  final String senderId;
  final String senderName;
  final String pinnedBy;
  final String pinnedByName;
  final DateTime pinnedAt;
  final String? messageType;
  final String? fileUrl;

  PinnedGroupMessage({
    required this.messageId,
    required this.groupId,
    required this.messageText,
    required this.senderId,
    required this.senderName,
    required this.pinnedBy,
    required this.pinnedByName,
    required this.pinnedAt,
    this.messageType,
    this.fileUrl,
  });

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'group_id': groupId,
        'message_text': messageText,
        'sender_id': senderId,
        'sender_name': senderName,
        'pinned_by': pinnedBy,
        'pinned_by_name': pinnedByName,
        'pinned_at': pinnedAt.toIso8601String(),
        'message_type': messageType,
        'file_url': fileUrl,
      };

  factory PinnedGroupMessage.fromJson(Map<String, dynamic> json) =>
      PinnedGroupMessage(
        messageId: json['message_id']?.toString() ?? '',
        groupId: json['group_id']?.toString() ?? '',
        messageText: json['message_text']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? '',
        senderName: json['sender_name']?.toString() ?? 'Member',
        pinnedBy: json['pinned_by']?.toString() ?? '',
        pinnedByName: json['pinned_by_name']?.toString() ?? 'Admin',
        pinnedAt: json['pinned_at'] != null
            ? DateTime.tryParse(json['pinned_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        messageType: json['message_type']?.toString(),
        fileUrl: json['file_url']?.toString(),
      );
}

/// 📌 Service for synchronizing Group-Level Pinned Messages across all members
class PocketPinnedGroupMessagesService {
  PocketPinnedGroupMessagesService._();
  static final PocketPinnedGroupMessagesService instance =
      PocketPinnedGroupMessagesService._();

  static const String _activitiesTableName = 'group_activities';

  /// Get pinned messages for a specific group
  Future<List<PinnedGroupMessage>> getPinnedMessages(String groupId) async {
    if (groupId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_pinned_msgs_$groupId';

    // 1. Try fetching from Supabase cloud
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from(_activitiesTableName)
          .select('data')
          .eq('group_id', groupId)
          .eq('activity_type', 'gang_pinned_messages')
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['pinned_messages'] is List) {
          list = data['pinned_messages'];
        } else if (data is List) {
          list = data;
        }

        final pins = list
            .map((item) =>
                PinnedGroupMessage.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        await prefs.setString(
            cacheKey, jsonEncode(pins.map((p) => p.toJson()).toList()));
        return pins;
      }
    } catch (e) {
      debugPrint('PocketPinnedGroupMessagesService fetch error: $e');
    }

    // 2. Fallback to local cache
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final List list = jsonDecode(cached);
        return list
            .map((e) =>
                PinnedGroupMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    return [];
  }

  /// Pin a message in the group
  Future<bool> pinMessage({
    required String groupId,
    required String userId,
    required String userName,
    required String messageId,
    required String messageText,
    required String senderId,
    required String senderName,
    String? messageType,
    String? fileUrl,
  }) async {
    if (groupId.isEmpty || messageId.isEmpty) return false;

    final currentPins = await getPinnedMessages(groupId);
    // Avoid duplicate pin records
    if (currentPins.any((p) => p.messageId == messageId)) {
      return true;
    }

    final newPin = PinnedGroupMessage(
      messageId: messageId,
      groupId: groupId,
      messageText: messageText,
      senderId: senderId,
      senderName: senderName,
      pinnedBy: userId,
      pinnedByName: userName,
      pinnedAt: DateTime.now(),
      messageType: messageType,
      fileUrl: fileUrl,
    );

    currentPins.insert(0, newPin);
    return await _savePins(groupId: groupId, userId: userId, pins: currentPins);
  }

  /// Unpin a message in the group
  Future<bool> unpinMessage({
    required String groupId,
    required String userId,
    required String messageId,
  }) async {
    if (groupId.isEmpty || messageId.isEmpty) return false;

    final currentPins = await getPinnedMessages(groupId);
    final initialCount = currentPins.length;
    currentPins.removeWhere((p) => p.messageId == messageId);

    if (currentPins.length == initialCount) {
      return true; // Wasn't pinned
    }

    return await _savePins(groupId: groupId, userId: userId, pins: currentPins);
  }

  Future<bool> _savePins({
    required String groupId,
    required String userId,
    required List<PinnedGroupMessage> pins,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_pinned_msgs_$groupId';
    await prefs.setString(
        cacheKey, jsonEncode(pins.map((p) => p.toJson()).toList()));

    try {
      final supabase = Supabase.instance.client;
      await supabase.from(_activitiesTableName).upsert({
        'group_id': groupId,
        'activity_type': 'gang_pinned_messages',
        'title': 'Gang Pinned Messages',
        'data': {
          'pinned_messages': pins.map((p) => p.toJson()).toList(),
          'updated_by': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'created_by': userId,
        'is_active': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error saving gang pinned messages: $e');
      return false;
    }
  }

  /// Subscribe to group pinned messages in real-time
  RealtimeChannel? subscribeToPinnedMessages({
    required String groupId,
    required VoidCallback onPinsChanged,
  }) {
    if (groupId.isEmpty) return null;
    try {
      final supabase = Supabase.instance.client;
      final channel = supabase.channel('gang_pins_$groupId');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _activitiesTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'group_id',
              value: groupId,
            ),
            callback: (payload) {
              if (payload.newRecord['activity_type'] == 'gang_pinned_messages') {
                onPinsChanged();
              }
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Error subscribing to gang pins channel: $e');
      return null;
    }
  }
}

