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
  });

  final double? width;
  final double? height;
  final String contentToShare;
  final String currentUserId;

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
                    'Share to Groups',
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
      ),
    );
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
      await supabase.from('group_messages').insert({
        'group_id': groupId,
        'sender_id': widget.currentUserId,
        'message_text': widget.contentToShare,
        'message_type': 'text',
      });

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
  final String? messageHint;
  final bool showMessageInput;

  const GroupSelectionBottomSheet({
    Key? key,
    required this.contentToShare,
    required this.currentUserId,
    required this.onGroupSelected,
    this.messageHint = 'Add a message (optional)...',
    this.showMessageInput = true,
  }) : super(key: key);

  @override
  State<GroupSelectionBottomSheet> createState() =>
      _GroupSelectionBottomSheetState();
}

class _GroupSelectionBottomSheetState extends State<GroupSelectionBottomSheet> {
  List<Map<String, dynamic>> userGroups = [];
  bool isLoading = true;
  String searchQuery = '';
  String userMessage = '';
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserGroups();
  }

  @override
  void dispose() {
    searchController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserGroups() async {
    try {
      safeSetState(() => isLoading = true);

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
        isLoading = false;
      });
    } catch (e) {
      safeSetState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading groups: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredGroups {
    if (searchQuery.isEmpty) return userGroups;
    return userGroups
        .where((group) =>
            group['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700), // Yellow handle
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              children: [
                // Title Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Share to Groups',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3A3A3A),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      safeSetState(() => searchQuery = value);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search groups...',
                      hintStyle: TextStyle(color: Color(0xFF888888)),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFFFFD700),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                // Message input field
                if (widget.showMessageInput) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        safeSetState(() => userMessage = value);
                      },
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: widget.messageHint,
                        hintStyle: const TextStyle(color: Color(0xFF888888)),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(top: 12, left: 12, right: 8),
                          child: Icon(
                            Icons.message_rounded,
                            color: Color(0xFFFFD700),
                            size: 22,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Groups list/grid
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      strokeWidth: 3,
                    ),
                  )
                : filteredGroups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.group_off_rounded,
                                size: 48,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No groups found'
                                  : 'No groups match your search',
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ListView.separated(
                          itemCount: filteredGroups.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final group = filteredGroups[index];
                            return _buildGroupCard(group);
                          },
                        ),
                      ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return GestureDetector(
      onTap: () => widget.onGroupSelected(
        group['id'],
        group['name'],
        userMessage.trim(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group image/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF3A3A3A),
                ),
                child: group['group_image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          group['group_image_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultGroupIcon(),
                        ),
                      )
                    : _buildDefaultGroupIcon(),
              ),
              const SizedBox(width: 16),
              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'] ?? 'Unnamed Group',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (group['description'] != null)
                      Text(
                        group['description'],
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Arrow icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultGroupIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.8),
            const Color(0xFFFFD700),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.group_rounded,
          size: 28,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

final supabase = SupaFlow.client;
