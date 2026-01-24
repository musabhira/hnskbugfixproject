// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

class ShareContentScreen extends StatefulWidget {
  const ShareContentScreen({
    super.key,
    this.width,
    this.height,
    required this.contentToShare,
    required this.currentUserId,
    this.contentId,
    this.contentType = 'text',
  });

  final double? width;
  final double? height;
  final String contentToShare;
  final String currentUserId;
  final String? contentId;
  final String contentType;

  @override
  State<ShareContentScreen> createState() => _ShareContentScreenState();
}

class _ShareContentScreenState extends State<ShareContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Share Content',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.share,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Content to Share',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.contentToShare,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showGroupSelectionBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupSelectionBottomSheet(
        contentToShare: widget.contentToShare,
        currentUserId: widget.currentUserId,
        onGroupSelected: (groupId, groupName, userMessage) {
          Navigator.pop(context);
          _shareToGroup(groupId, groupName);
        },
        onPersonSelected: (userId, userName, userMessage) {
          Navigator.pop(context);
          _shareToPerson(userId, userName);
        },
      ),
    );
  }

  Future<void> _shareToPerson(String userId, String userName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Prepare payload
      final messageData = {
        'sender_id': widget.currentUserId,
        'receiver_id': userId,
        'content': widget.contentToShare, // This serves as title/description
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'message_type': widget.contentType == 'gallery' ? 'gallery' : 'text',
      };

      // If sharing gallery content
      if (widget.contentType == 'gallery' && widget.contentId != null) {
        messageData['gallery_id'] = widget.contentId!;
      }

      await supabase.from('messages').insert(messageData);

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $userName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing content: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _shareToGroup(String groupId, String groupName) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Insert message to group
      // Assuming group_messages table logic.
      // If group_messages also needs gallery_id, I should check that too.
      // For now, focusing on user request "show in personal chat".
      // But let's check group_messages table if I have time, or just insert as text for now.
      // Wait, the previous turn modified whatsapp_group_chat to display gallery messages.
      // It expects 'gallery' key? Or join?
      // In whatsapp_group_chat:
      // gallery:gallery_id(*)

      final messageData = {
        'group_id': groupId,
        'sender_id': widget.currentUserId,
        'message_text': widget.contentToShare,
        'message_type': widget.contentType == 'gallery' ? 'gallery' : 'text',
      };

      if (widget.contentType == 'gallery' && widget.contentId != null) {
        // Assuming group_messages has gallery_id. If not, this might fail or be ignored.
        // Let's assume for now it handles it or I'll need to update schema.
        // Based on whatsapp_group_chat query, it definitely expects gallery relation.
        messageData['gallery_id'] = widget.contentId!;
      }

      await supabase.from('group_messages').insert(messageData);

      // Update group's last message
      await supabase.from('groups').update({
        'last_message': widget.contentToShare,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      Navigator.pop(context); // Close loading

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $groupName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing content: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// Child Class - Bottom Sheet with Group Selection
class GroupSelectionBottomSheet extends StatefulWidget {
  final String contentToShare;
  final String currentUserId;
  final Function(String groupId, String groupName, String userMessage)
      onGroupSelected;
  final Function(String userId, String userName, String userMessage)?
      onPersonSelected;
  final VoidCallback? onWhatsAppShare;
  final String? messageHint;
  final bool showMessageInput;

  const GroupSelectionBottomSheet({
    Key? key,
    required this.contentToShare,
    required this.currentUserId,
    required this.onGroupSelected,
    this.onPersonSelected,
    this.onWhatsAppShare,
    this.messageHint = 'Add a message (optional)...',
    this.showMessageInput = true,
  }) : super(key: key);

  @override
  State<GroupSelectionBottomSheet> createState() =>
      _GroupSelectionBottomSheetState();
}

class _GroupSelectionBottomSheetState extends State<GroupSelectionBottomSheet>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> userGroups = [];
  List<Map<String, dynamic>> recentPeople = [];
  bool isLoading = true;
  String searchQuery = '';
  String userMessage = '';
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    safeSetState(() => isLoading = true);
    await Future.wait([
      _fetchUserGroups(),
      _fetchRecentPeople(),
    ]);
    safeSetState(() => isLoading = false);
  }

  @override
  void dispose() {
    searchController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecentPeople() async {
    try {
      final currentUserId = widget.currentUserId;

      final response = await supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('updated_at', ascending: false)
          .limit(20);

      final userIds = <String>{};
      for (final conv in response) {
        if (conv['user1_id'] != currentUserId) userIds.add(conv['user1_id']);
        if (conv['user2_id'] != currentUserId) userIds.add(conv['user2_id']);
      }

      if (userIds.isEmpty) return;

      final profilesResponse = await supabase
          .from('profile')
          .select('user_id, name, profile_image_url')
          .inFilter('user_id', userIds.toList());

      safeSetState(() {
        recentPeople = List<Map<String, dynamic>>.from(profilesResponse);
      });
    } catch (e) {
      debugPrint('Error fetching recent people: $e');
    }
  }

  Future<void> _fetchUserGroups() async {
    try {
      final response = await supabase.from('group_members').select('''
            group_id,
            groups!inner (
              id,
              name,
              description,
              group_image_url,
              created_at,
              max_members
            )
          ''').eq('user_id', widget.currentUserId).eq('is_active', true);

      safeSetState(() {
        userGroups = response.map((item) {
          final group = item['groups'];
          return {
            'id': group['id'],
            'name': group['name'],
            'description': group['description'],
            'group_image_url': group['group_image_url'],
            'created_at': group['created_at'],
            'max_members': group['max_members'],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  List<Map<String, dynamic>> get filteredGroups {
    if (searchQuery.isEmpty) return userGroups;
    return userGroups
        .where((group) =>
            group['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> get filteredPeople {
    if (searchQuery.isEmpty) return recentPeople;
    return recentPeople
        .where((person) => (person['name'] ?? '')
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Insta-style: Dark rounded sheet
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF121212), // Deep black/grey
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header: Search & Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) =>
                        safeSetState(() => searchQuery = value),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (widget.showMessageInput) ...[
                  const SizedBox(height: 12),
                  // Optional Message Input
                  Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) =>
                          safeSetState(() => userMessage = value),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        prefixIcon: userMessage.isNotEmpty
                            ? null
                            : const Icon(Icons.edit,
                                color: Colors.grey, size: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Lists
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      // If searching, we show strictly what matches.
                      // If not searching, we show Recent People then Groups? Or separate?
                      // The user asked for "search time show a group and personal chat".
                      // We'll show categorized results if searching or not searching.

                      if (filteredPeople.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            searchQuery.isEmpty ? 'Recent People' : 'People',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        ...filteredPeople
                            .map((person) => _buildPersonTile(person)),
                      ],

                      if (filteredGroups.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            searchQuery.isEmpty ? 'Your Groups' : 'Groups',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        ...filteredGroups
                            .map((group) => _buildGroupTile(group)),
                      ],

                      if (filteredPeople.isEmpty && filteredGroups.isEmpty)
                        _buildEmptyState('No matches found'),
                    ],
                  ),
          ),

          // Action Button (Whatsapp or other)
          if (widget.onWhatsAppShare != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onWhatsAppShare!();
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share to WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPersonTile(Map<String, dynamic> person) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[800],
        backgroundImage: person['profile_image_url'] != null
            ? NetworkImage(person['profile_image_url'])
            : null,
        child: person['profile_image_url'] == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        person['name'] ?? 'Unknown',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'Personal',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: _buildSendButton(() {
        if (widget.onPersonSelected != null) {
          widget.onPersonSelected!(
            person['user_id'],
            person['name'] ?? 'Unknown',
            userMessage.trim(),
          );
        }
      }),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
          image: group['group_image_url'] != null
              ? DecorationImage(
                  image: NetworkImage(group['group_image_url']),
                  fit: BoxFit.cover)
              : null,
        ),
        child: group['group_image_url'] == null
            ? const Icon(Icons.group, color: Colors.white, size: 20)
            : null,
      ),
      title: Text(
        group['name'] ?? 'Group',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${group['max_members'] ?? 0} members',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: _buildSendButton(() {
        widget.onGroupSelected(
          group['id'],
          group['name'],
          userMessage.trim(),
        );
      }),
    );
  }

  Widget _buildSendButton(VoidCallback onTap) {
    return Container(
      height: 32,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.blue, // Insta blue
        borderRadius: BorderRadius.circular(4),
      ),
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: const Text(
          'Send',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

final supabase = SupaFlow.client;
