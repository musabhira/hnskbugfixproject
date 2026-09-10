import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/chat_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/story/snapchat_story_creator_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// ⚡ PocketSnapService: High-speed Snapchat-style Snap creator and direct Snap transmission engine
class PocketSnapService {
  static final PocketSnapService _instance = PocketSnapService._internal();
  factory PocketSnapService() => _instance;
  PocketSnapService._internal();

  static final _supabase = SupaFlow.client;

  /// 📸 Launch the Snapchat-style Snap flow with graceful Windows/Desktop camera fallback
  static Future<void> launchSnapWorkflow(
    BuildContext context, {
    required String userId,
    required String profileId,
    String? preselectedRecipientId,
    VoidCallback? onUploaded,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SnapLauncherSheet(
        userId: userId,
        profileId: profileId,
        preselectedRecipientId: preselectedRecipientId,
        onUploaded: onUploaded,
      ),
    );
  }

  /// 🚀 Send a direct Snap to one or more Pocket Mates + optionally post to Story
  static Future<String> sendSnapDirectly({
    required String senderId,
    required String senderProfileId,
    required List<String> recipientIds,
    required Uint8List imageBytes,
    String? caption,
    bool postToStoryToo = false,
  }) async {
    // 1. Optimize / compress image
    Uint8List bytesToUpload = imageBytes;
    if (imageBytes.lengthInBytes > 1200 * 1024) {
      try {
        final originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          final resized = img.copyResize(originalImage, width: 1080);
          bytesToUpload = Uint8List.fromList(img.encodeJpg(resized, quality: 80));
        }
      } catch (e) {
        debugPrint('PocketSnapService compression fallback: $e');
      }
    }

    // 2. Upload to Supabase storage
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'snap_${senderId}_$timestamp.jpg';
    await _supabase.storage.from('statuses').uploadBinary(
          fileName,
          bytesToUpload,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final mediaUrl = _supabase.storage.from('statuses').getPublicUrl(fileName);

    // 3. Dispatch to selected recipients as high-speed direct Snaps
    for (final recipientId in recipientIds) {
      final snapMessage = {
        'sender_id': senderId,
        'receiver_id': recipientId,
        'content': mediaUrl,
        'message_text': caption?.isNotEmpty == true ? caption! : '🔥 Pocket Snap',
        'message_type': 'snap',
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await _supabase.from('messages').insert(snapMessage);
      } catch (e) {
        debugPrint('Error inserting snap message for $recipientId: $e');
      }

      // 4. Update local Dart sync server for 0ms perceptible latency
      try {
        final localMsg = ChatMessage(
          id: 'snap_$timestamp',
          senderId: senderId,
          receiverId: recipientId,
          fileUrl: mediaUrl,
          messageText: caption ?? '🔥 Pocket Snap',
          messageType: 'snap',
          createdAt: DateTime.now(),
          metadata: {'is_snap': true, 'caption': caption},
        );
        LocalSyncServer().dispatchInstantMessage(
          userId: senderId,
          chatOrGroupId: recipientId,
          message: localMsg.toJson(),
        );
      } catch (_) {}

      // If recipient is a Pocket Robot, trigger realistic view & snap reaction
      if (PocketRobotService.isRobotId(recipientId)) {
        PocketRobotService.handleUserSnapToRobot(
          userId: senderId,
          robotId: recipientId,
          userSnapUrl: mediaUrl,
          userCaption: caption,
        );
      }
    }

    // 5. Optionally post to Story / Vibe
    if (postToStoryToo) {
      try {
        await _supabase.from('status').insert({
          'user_id': senderId,
          'profile_id': senderProfileId,
          'media_type': 'image',
          'media_url': mediaUrl,
          'caption': caption,
          'duration': 5,
          'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
          'is_active': true,
        });
      } catch (e) {
        debugPrint('Error cross-posting snap to story: $e');
      }
    }

    // 6. Reward Pocket Score & Streaks (+15 PTS per Snap)
    try {
      await PocketFortressDefenseService.recordActivityPoints('snap_send');
    } catch (_) {}

    return mediaUrl;
  }

  /// 👥 Retrieve list of Pocket Mates / Friends for instant Snap sharing
  static Future<List<ChatConversation>> getPocketMates(String userId) async {
    try {
      final cached = LocalSyncServer().getCachedConversations(userId);
      if (cached.isNotEmpty) {
        return cached.where((c) => !c.isGroup && !c.isTool && !c.isNotification).toList();
      }

      // Fetch from Supabase profile / conversations if cache empty
      final profiles = await _supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url, avatar_config')
          .neq('user_id', userId)
          .limit(30);

      return (profiles as List).map((p) {
        return ChatConversation(
          id: p['user_id']?.toString() ?? '',
          name: p['name']?.toString() ?? 'Mate',
          imageUrl: p['profile_image_url']?.toString(),
          isGroup: false,
          avatarConfig: p['avatar_config'] is Map ? Map<String, dynamic>.from(p['avatar_config']) : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting pocket mates: $e');
      return [];
    }
  }
}

/// 📱 Bottom Action Sheet for Snapchat-Style Snap launcher
class _SnapLauncherSheet extends StatelessWidget {
  final String userId;
  final String profileId;
  final String? preselectedRecipientId;
  final VoidCallback? onUploaded;

  const _SnapLauncherSheet({
    required this.userId,
    required this.profileId,
    this.preselectedRecipientId,
    this.onUploaded,
  });

  Future<void> _pickFromCamera(BuildContext context) async {
    Navigator.pop(context);
    try {
      XFile? photo;
      // On Windows/Desktop, camera plugin throws UnimplementedError
      if (!kIsWeb && io.Platform.isWindows) {
        // Desktop fallback: prompt gallery file picker cleanly
        photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
      } else {
        photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
      }

      if (photo != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SnapchatStoryCreatorPage(
              userId: userId,
              profileId: profileId,
              initialFile: photo,
              initialMediaType: 'image',
              onStatusUploaded: onUploaded,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
      // Graceful fallback to gallery if camera fails
      try {
        final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
        if (photo != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SnapchatStoryCreatorPage(
                userId: userId,
                profileId: profileId,
                initialFile: photo,
                initialMediaType: 'image',
                onStatusUploaded: onUploaded,
              ),
            ),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    Navigator.pop(context);
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (photo != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SnapchatStoryCreatorPage(
              userId: userId,
              profileId: profileId,
              initialFile: photo,
              initialMediaType: 'image',
              onStatusUploaded: onUploaded,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  void _openCanvas(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SnapchatStoryCreatorPage(
          userId: userId,
          profileId: profileId,
          onStatusUploaded: onUploaded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141721),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFC00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pocket Snap & Vibe',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Capture, style with stickers & send to Mates',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SnapOptionTile(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFFFFFC00),
              title: 'Take Snap (Camera)',
              subtitle: 'Shoot instant photo with lens & audio',
              onTap: () => _pickFromCamera(context),
            ),
            const SizedBox(height: 10),
            _SnapOptionTile(
              icon: Icons.photo_library_rounded,
              iconColor: Colors.cyanAccent,
              title: 'Choose from Gallery',
              subtitle: 'Select an existing photo from device',
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: 10),
            _SnapOptionTile(
              icon: Icons.brush_rounded,
              iconColor: Colors.pinkAccent,
              title: 'Snap Canvas & Doodles',
              subtitle: 'Create thought story with avatar stickers',
              onTap: () => _openCanvas(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SnapOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SnapOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
