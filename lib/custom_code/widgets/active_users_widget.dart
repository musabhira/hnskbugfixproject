import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'active_users_provider.dart';
import 'message_screen.dart'; // Import MessageScreen

class ActiveUsersWidget extends ConsumerWidget {
  const ActiveUsersWidget({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.currentProfileId,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String currentProfileId;

  // Actions
  void _startVideoCall(BuildContext context, String targetUserId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Direct video calling coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startAudioCall(BuildContext context, String targetUserId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Direct audio calling coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startChat(BuildContext context, Map<String, dynamic> userProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          receiverId: userProfile['user_id'],
          receiverName: userProfile['name'],
          receiverProfileImage: userProfile['profile_image_url'],
          phonenumber: userProfile['phone_no'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUsersAsync = ref.watch(activeUsersProvider(currentProfileId));

    return activeUsersAsync.when(
      loading: () => Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(height: 0),
      data: (data) {
        final _activeFriends = data.activeFriends;
        final _allUserNotes = data.userNotes;

        return Container(
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Online Now (${_activeFriends.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_activeFriends.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No active users nearby.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 150, // Slightly increased height for better spacing
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _activeFriends.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final friend = _activeFriends[index];
                      final profileId = friend['profile_id'].toString();
                      final notes = _allUserNotes[profileId];
                      final hasNote = notes != null && notes.isNotEmpty;
                      final latestNote =
                          hasNote ? notes.first['note_content'] : null;

                      return Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profile Image with Note Badge
                            Stack(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: hasNote
                                          ? const Color(0xFF4B39EF)
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          friend['profile_image_url'] ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[100],
                                        child: const Icon(Icons.person,
                                            color: Colors.grey),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[100],
                                        child: const Icon(Icons.person,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                if (hasNote)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4B39EF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                      ),
                                      child: const Text('💬',
                                          style: TextStyle(fontSize: 10)),
                                    ).animate().scale(
                                        duration: 400.ms,
                                        curve: Curves.elasticOut),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Name
                            Text(
                              friend['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            // Note text
                            if (latestNote != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  latestNote,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.indigo[400],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionButton(
                                  icon: Icons.videocam_rounded,
                                  color: Colors.purple,
                                  onTap: () => _startVideoCall(
                                      context, friend['user_id']),
                                ),
                                _ActionButton(
                                  icon: Icons.call_rounded,
                                  color: Colors.green,
                                  onTap: () => _startAudioCall(
                                      context, friend['user_id']),
                                ),
                                _ActionButton(
                                  icon: Icons.chat_bubble_rounded,
                                  color: Colors.blue,
                                  onTap: () => _startChat(context, friend),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
