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
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/create_gallery_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// ⚡ PocketSnapService: High-speed Snapchat-style Snap creator and direct Snap transmission engine
class PocketSnapService {
  static final PocketSnapService _instance = PocketSnapService._internal();
  factory PocketSnapService() => _instance;
  PocketSnapService._internal();

  static final _supabase = SupaFlow.client;

  /// 📸 Launch camera directly for instant Snap creation
  static Future<void> launchSnapWorkflow(
    BuildContext context, {
    required String userId,
    required String profileId,
    String? preselectedRecipientId,
    VoidCallback? onUploaded,
  }) async {
    try {
      XFile? photo;
      if (!kIsWeb && io.Platform.isWindows) {
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
      debugPrint('Direct camera error: $e, falling back to gallery');
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
class SnapLauncherSheet extends StatelessWidget {
  final String userId;
  final String profileId;
  final String? preselectedRecipientId;
  final VoidCallback? onUploaded;

  const SnapLauncherSheet({
    super.key,
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

  void _openAddThoughts(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateThreadPage(),
      ),
    );
  }

  void _openAddGallery(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGalleryWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Minimal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Snap, thoughts, products & services',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white60,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Options List
            _SnapOptionTile(
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFFFFFC00),
              title: 'Take Snap (Camera)',
              subtitle: 'Shoot instant photo with lens',
              onTap: () => _pickFromCamera(context),
            ),
            const SizedBox(height: 8),
            _SnapOptionTile(
              icon: Icons.photo_library_outlined,
              iconColor: const Color(0xFF38BDF8),
              title: 'Choose from Gallery',
              subtitle: 'Select an existing photo from device',
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: 8),
            _SnapOptionTile(
              icon: Icons.draw_outlined,
              iconColor: const Color(0xFFF472B6),
              title: 'Snap Canvas & Doodles',
              subtitle: 'Create story canvas with stickers & text',
              onTap: () => _openCanvas(context),
            ),
            const SizedBox(height: 8),
            _SnapOptionTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFFA78BFA),
              title: 'Add Thoughts',
              subtitle: 'Share opinions, ideas & discussions',
              onTap: () => _openAddThoughts(context),
            ),
            const SizedBox(height: 8),
            _SnapOptionTile(
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFF34D399),
              title: 'Add Gallery / Market',
              subtitle: 'Showcase Product or Service for sale',
              onTap: () => _openAddGallery(context),
            ),
            const SizedBox(height: 6),
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF161A26),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
