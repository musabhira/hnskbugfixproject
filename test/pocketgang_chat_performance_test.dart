import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simulate optimistic messaging and deduplication', () async {
    final Map<String, dynamic> localStore = {};
    final List<String> messageOrder = [];

    // 1. Send optimistic message
    final tempId = 'temp_123456';
    final payloadText = 'Team meeting at 4 PM';
    localStore[tempId] = {
      'id': tempId,
      'text': payloadText,
      'isOptimistic': true,
      'timestamp': DateTime.now(),
    };
    messageOrder.insert(0, tempId);

    expect(localStore.containsKey(tempId), isTrue);
    expect(localStore[tempId]['isOptimistic'], isTrue);

    // 2. Server ACK arrives with real UUID
    final realId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    // Deduplication / replacement logic
    final optKey = localStore.keys.firstWhere(
      (k) => localStore[k]['text'] == payloadText && localStore[k]['isOptimistic'] == true,
      orElse: () => '',
    );
    if (optKey.isNotEmpty) {
      localStore.remove(optKey);
      messageOrder.remove(optKey);
    }
    localStore[realId] = {
      'id': realId,
      'text': payloadText,
      'isOptimistic': false,
      'timestamp': DateTime.now(),
    };
    messageOrder.insert(0, realId);

    expect(localStore.containsKey(tempId), isFalse);
    expect(localStore.containsKey(realId), isTrue);
    expect(messageOrder.length, equals(1));
    expect(messageOrder.first, equals(realId));

    // 3. Duplicate Realtime Broadcast arrives for the same UUID
    if (!localStore.containsKey(realId)) {
      messageOrder.insert(0, realId);
    }
    expect(messageOrder.length, equals(1), reason: 'Duplicate event must be ignored');
  });

  test('Simulate Chat List Pinning vs Group Message Pinning independence', () {
    // User A & User B
    final userAPins = <String>{};
    final userBPins = <String>{};

    final groupId = 'gang_team_alpha';
    userAPins.add(groupId);

    // User A has pinned conversation
    expect(userAPins.contains(groupId), isTrue);
    // User B does NOT have pinned conversation
    expect(userBPins.contains(groupId), isFalse);

    // Group Message Pinning (Shared)
    final groupPinnedMessages = <String, Map<String, dynamic>>{};
    final msgId = 'msg_announcement_101';
    groupPinnedMessages[msgId] = {
      'id': msgId,
      'text': 'Deadline is Friday!',
      'pinned_by': 'user_a',
    };

    // Both see the pinned message
    expect(groupPinnedMessages.containsKey(msgId), isTrue);
    expect(groupPinnedMessages[msgId]?['pinned_by'], equals('user_a'));
  });
}

