import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ShareContentScreen extends StatefulWidget {
  const ShareContentScreen({
    super.key,
    this.width,
    this.height,
    required this.contentToShare,
    required this.currentUserId,
    this.contentId,
    this.contentType = 'text',
    this.metadata,
  });

  final double? width;
  final double? height;
  final String contentToShare;
  final String currentUserId;
  final String? contentId;
  final String contentType;
  final Map<String, dynamic>? metadata;

  @override
  State<ShareContentScreen> createState() => _ShareContentScreenState();
}

class _ShareContentScreenState extends State<ShareContentScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Share',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Preview Section
            if (widget.contentType == 'thought' && widget.metadata != null)
              _buildThoughtPreview()
            else
              _buildDefaultPreview(),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ShareActionButton(
                    icon: Icons.group_rounded,
                    label: 'Send to Chat',
                    color: Colors.blue,
                    onTap: () => _showGroupSelectionBottomSheet(context),
                  ),
                  const SizedBox(height: 16),
                  _ShareActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Share to Vibes',
                    color: Colors.pink,
                    onTap: () => _shareToStatus(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThoughtPreview() {
    final name = widget.metadata!['name'] ?? 'User';
    final avatar = widget.metadata!['profile_image_url'];
    final time = widget.metadata!['created_at'];
    final createdAt = time != null
        ? DateTime.tryParse(time.toString()) ?? DateTime.now()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.yellow.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with User Info
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.yellow.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage: avatar != null
                          ? CachedNetworkImageProvider(avatar)
                          : null,
                      child: avatar == null
                          ? Text(name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          timeago.format(createdAt, locale: 'en'),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.format_quote_rounded,
                        color: Colors.yellow, size: 20),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                widget.contentToShare,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // Interaction Dummy Bar (for look)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.white.withOpacity(0.03),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      size: 18, color: Colors.pink.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('${widget.metadata!['like_count'] ?? 0}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(width: 20),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: Colors.blue.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('${widget.metadata!['comment_count'] ?? 0}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            widget.contentType == 'gallery'
                ? Icons.image
                : (widget.contentType == 'thought'
                    ? Icons.lightbulb
                    : Icons.text_fields),
            size: 48,
            color: Colors.yellow,
          ),
          const SizedBox(height: 16),
          Text(
            widget.contentToShare,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
          _shareToGroup(groupId, groupName, userMessage);
        },
        onPersonSelected: (userId, userName, userMessage) {
          Navigator.pop(context);
          _shareToPerson(userId, userName, userMessage);
        },
        onStatusSelected: (userMessage) {
          Navigator.pop(context);
          _shareToStatus(userMessage);
        },
      ),
    );
  }

  Future<void> _shareToPerson(
      String userId, String userName, String? userMessage) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Prepare payload
      final Map<String, dynamic> messageData = {
        'sender_id': widget.currentUserId,
        'receiver_id': userId,
        'content': widget.contentToShare,
        'message_text': widget.contentToShare,
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'message_type': widget.contentType == 'gallery'
            ? 'gallery'
            : (widget.contentType == 'thought' ? 'thought' : 'text'),
      };

      if (widget.contentType == 'gallery' && widget.contentId != null) {
        final parsed = int.tryParse(widget.contentId.toString());
        if (parsed != null) messageData['gallery_id'] = parsed;
      }

      if (widget.contentType == 'thought' && widget.contentId != null) {
        final parsed = int.tryParse(widget.contentId.toString());
        if (parsed != null) messageData['thought_id'] = parsed;
      }

      await supabase.from('messages').insert(messageData);

      // Update conversation record
      final existingConv = await supabase
          .from('conversations')
          .select('id, unread_count')
          .or('and(user1_id.eq.${widget.currentUserId},user2_id.eq.$userId),and(user1_id.eq.$userId,user2_id.eq.${widget.currentUserId})')
          .maybeSingle();

      if (existingConv != null) {
        await supabase.from('conversations').update({
          'last_message': widget.contentToShare,
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': widget.currentUserId,
          'unread_count': (existingConv['unread_count'] ?? 0) + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingConv['id']);
      } else {
        await supabase.from('conversations').insert({
          'user1_id': widget.currentUserId,
          'user2_id': userId,
          'last_message': widget.contentToShare,
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': widget.currentUserId,
          'unread_count': 1,
        });
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, true); // Return success to caller
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $userName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareToGroup(
      String groupId, String groupName, String? userMessage) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final Map<String, dynamic> messageData = {
        'group_id': groupId,
        'sender_id': widget.currentUserId,
        'message_text': widget.contentToShare,
        'message_type': widget.contentType == 'gallery'
            ? 'gallery'
            : (widget.contentType == 'thought' ? 'thought' : 'text'),
      };

      if (widget.contentType == 'gallery' && widget.contentId != null) {
        final parsed = int.tryParse(widget.contentId.toString());
        if (parsed != null) messageData['gallery_id'] = parsed;
      }

      if (widget.contentType == 'thought' && widget.contentId != null) {
        final parsed = int.tryParse(widget.contentId.toString());
        if (parsed != null) messageData['thought_id'] = parsed;
      }

      await supabase.from('group_messages').insert(messageData);

      await supabase.from('groups').update({
        'last_message': widget.contentToShare,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, true); // Return success to caller
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $groupName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareToStatus([String? userMessage]) async {
    try {
      final profileResponse = await supabase
          .from('profile')
          .select('id')
          .eq('user_id', widget.currentUserId)
          .single();
      final profileId = profileResponse['id'] as String;

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatusUploadWidget(
            userId: widget.currentUserId,
            profileId: profileId,
            sharedContent: widget.contentToShare,
            sharedContentType: widget.contentType,
            sharedContentId: widget.contentId,
            sharedMetadata: widget.metadata,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error preparing status share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

class GroupSelectionBottomSheet extends StatefulWidget {
  final String contentToShare;
  final String currentUserId;
  final Function(String groupId, String groupName, String? userMessage)
      onGroupSelected;
  final Function(String userId, String userName, String? userMessage)?
      onPersonSelected;
  final Function(String? userMessage)? onStatusSelected;
  final VoidCallback? onWhatsAppShare;

  const GroupSelectionBottomSheet({
    super.key,
    required this.contentToShare,
    required this.currentUserId,
    required this.onGroupSelected,
    this.onPersonSelected,
    this.onStatusSelected,
    this.onWhatsAppShare,
  });

  @override
  State<GroupSelectionBottomSheet> createState() =>
      _GroupSelectionBottomSheetState();
}

class _GroupSelectionBottomSheetState extends State<GroupSelectionBottomSheet> {
  List<Map<String, dynamic>> userGroups = [];
  List<Map<String, dynamic>> recentPeople = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchUserGroups(),
      _fetchRecentPeople(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchRecentPeople() async {
    try {
      final response = await supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.${widget.currentUserId},user2_id.eq.${widget.currentUserId}')
          .order('updated_at', ascending: false)
          .limit(20);

      final userIds = <String>{};
      for (final conv in response) {
        if (conv['user1_id'] != widget.currentUserId)
          userIds.add(conv['user1_id']);
        if (conv['user2_id'] != widget.currentUserId)
          userIds.add(conv['user2_id']);
      }

      if (userIds.isNotEmpty) {
        final profilesResponse = await supabase
            .from('profile')
            .select('user_id, name, profile_image_url')
            .inFilter('user_id', userIds.toList());
        if (mounted) {
          setState(() {
            recentPeople = List<Map<String, dynamic>>.from(profilesResponse);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching people: $e');
    }
  }

  Future<void> _fetchUserGroups() async {
    try {
      final response = await supabase.from('group_members').select('''
            group_id,
            groups!inner (
              id,
              name,
              group_image_url
            )
          ''').eq('user_id', widget.currentUserId).eq('is_active', true);

      if (mounted) {
        setState(() {
          userGroups = response.map((item) {
            final group = item['groups'];
            return {
              'id': group['id'],
              'name': group['name'],
              'group_image_url': group['group_image_url'],
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search people or groups...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      if (widget.onWhatsAppShare != null ||
                          true) // Always show for now
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF25D366),
                            child: Icon(Icons.share,
                                color: Colors.white, size: 20),
                          ),
                          title: const Text('Share to WhatsApp',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            if (widget.onWhatsAppShare != null) {
                              widget.onWhatsAppShare!();
                            } else {
                              final text =
                                  "Check out this thought: ${widget.contentToShare}";
                              Share.share(text);
                            }
                          },
                        ),
                      if (widget.onStatusSelected != null)
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.pink,
                            child: Icon(Icons.auto_awesome,
                                color: Colors.white, size: 20),
                          ),
                          title: const Text('My Vibes',
                              style: TextStyle(color: Colors.white)),
                          onTap: () => widget.onStatusSelected!(null),
                        ),
                      if (recentPeople.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('People',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold)),
                        ),
                        ...recentPeople
                            .where((p) =>
                                p['name']
                                    ?.toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ??
                                true)
                            .map((p) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        p['profile_image_url'] != null
                                            ? CachedNetworkImageProvider(
                                                p['profile_image_url'])
                                            : null,
                                    child: p['profile_image_url'] == null
                                        ? Text(p['name']?[0] ?? '?')
                                        : null,
                                  ),
                                  title: Text(p['name'] ?? 'User',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  onTap: () => widget.onPersonSelected!(
                                      p['user_id'], p['name'], null),
                                )),
                      ],
                      if (userGroups.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Groups',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold)),
                        ),
                        ...userGroups
                            .where((g) =>
                                g['name']
                                    ?.toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ??
                                true)
                            .map((g) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        g['group_image_url'] != null
                                            ? CachedNetworkImageProvider(
                                                g['group_image_url'])
                                            : null,
                                    child: g['group_image_url'] == null
                                        ? const Icon(Icons.group)
                                        : null,
                                  ),
                                  title: Text(g['name'] ?? 'Group',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  onTap: () => widget.onGroupSelected(
                                      g['id'], g['name'], null),
                                )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
