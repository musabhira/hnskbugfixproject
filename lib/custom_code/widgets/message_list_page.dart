import 'package:flutter/material.dart';
import 'dart:async';
import 'package:timeago/timeago.dart' as timeago;
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final _supabase = SupaFlow.client;
  late String _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;
    _loadConversations();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    try {
      // First get conversations
      final conversationsResponse = await _supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.$_currentUserId,user2_id.eq.$_currentUserId')
          .order('updated_at', ascending: false);

      // Get user IDs from conversations
      final userIds = <String>{};
      for (final conv in conversationsResponse) {
        userIds.add(conv['user1_id']);
        userIds.add(conv['user2_id']);
      }

      // Get profiles for all users
      final profilesResponse = await _supabase
          .from('profile')
          .select('user_id, name, shop_name, profile_image_url')
          .inFilter('user_id', userIds.toList());

      // Create a map for quick lookup
      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profileMap[profile['user_id']] = profile;
      }

      // Combine conversations with profile data
      final conversations = conversationsResponse.map((conv) {
        return {
          ...conv,
          'user1_profile': profileMap[conv['user1_id']],
          'user2_profile': profileMap[conv['user2_id']],
        };
      }).toList();
      print(_conversations);
      if (mounted) {
        safeSetState(() {
          _conversations = conversations;
          print(_conversations);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getOtherUser(Map<String, dynamic> conversation) {
    final isUser1 = conversation['user1_id'] == _currentUserId;
    if (isUser1) {
      return {
        'id': conversation['user2_id'],
        'name': conversation['user2_profile']?['name'] ??
            conversation['user2_profile']?['shop_name'] ??
            'Unknown',
        'avatar': conversation['user2_profile']?['profile_image_url'],
        'phonenumber': conversation['user2_profile']?['phone_no'],
      };
    } else {
      return {
        'id': conversation['user1_id'],
        'name': conversation['user1_profile']?['name'] ??
            conversation['user1_profile']?['shop_name'] ??
            'Unknown',
        'avatar': conversation['user1_profile']?['profile_image_url'],
        'phonenumber': conversation['user1_profile']?['phone_no'],
      };
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      // Delete conversation and related notifications
      await _supabase.from('conversations').delete().eq('id', conversationId);
      await _supabase
          .from('message_notifications')
          .delete()
          .eq('conversation_id', conversationId);

      // Refresh the list
      _loadConversations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting conversation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToMessageScreen(Map<String, dynamic> otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: 'p:${otherUser['id']}',
          groupName: otherUser['name'],
          groupImage: otherUser['avatar'],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 80,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start messaging with someone!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    final otherUser = _getOtherUser(conversation);
                    final isUnread = (conversation['unread_count'] ?? 0) > 0;
                    final lastMessageTime = conversation['last_message_time'] !=
                            null
                        ? timeago.format(
                            DateTime.parse(conversation['last_message_time']))
                        : '';

                    return Dismissible(
                      key: Key(conversation['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text(
                              'Delete Conversation',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this conversation?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.yellow),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _deleteConversation(conversation['id']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: otherUser['avatar'] != null
                                ? NetworkImage(otherUser['avatar'])
                                : null,
                            backgroundColor: Colors.yellow.shade700,
                            child: otherUser['avatar'] == null
                                ? Text(
                                    otherUser['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            otherUser['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            conversation['last_message'] ?? 'No messages yet',
                            style: TextStyle(
                              color: isUnread
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lastMessageTime,
                                style: TextStyle(
                                  color: isUnread
                                      ? Colors.yellow
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${conversation['unread_count']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _navigateToMessageScreen(otherUser),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
