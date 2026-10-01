import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/flutter_flow/nav/nav.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

/// 🔔 In-App Floating Heads-Up Notification Banner Service
/// Displays a sleek, stacked floating notification at the top of the screen
/// (like iOS Dynamic Island / modern glassmorphic card) when a new message arrives.
class InAppNotificationService {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Tracks the chat currently open on screen so we don't show redundant notifications
  /// for the conversation the user is actively viewing!
  static String? currentActiveChatId;

  /// Anti-Spam Rate Limiter for Robots:
  /// Prevents robots from flooding the user with rapid-fire notification banners.
  static DateTime? _lastRobotNotificationTime;
  static const Duration _kRobotCooldown = Duration(seconds: 90);

  /// In-memory profile cache for fast (0ms) sender avatar/name lookup
  static final Map<String, Map<String, String>> _profileCache = {};

  static StreamSubscription? _liveMessageSubscription;
  static bool _isListening = false;

  /// Start listening to live incoming messages across the entire app
  static void startListening() {
    if (_isListening) return;
    _isListening = true;

    _liveMessageSubscription?.cancel();
    _liveMessageSubscription =
        LocalSyncServer().liveMessageStream.listen((event) {
      _processIncomingMessageEvent(event);
    });

    debugPrint('InAppNotificationService: Started listening to live incoming messages');
  }

  /// Stop listening (e.g. on user logout)
  static void stopListening() {
    _liveMessageSubscription?.cancel();
    _liveMessageSubscription = null;
    _isListening = false;
    _dismissCurrent();
  }

  /// Process live messages from LocalSyncServer and trigger in-app banner
  static Future<void> _processIncomingMessageEvent(Map<String, dynamic> event) async {
    try {
      final currentUserId = SupaFlow.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final message = event['message'];
      if (message == null || message is! Map) return;

      final senderId = message['sender_id']?.toString();

      // Ignore messages sent by the logged-in user themselves
      if (senderId == null || senderId == currentUserId) return;

      // Determine chat ID
      String rawChatId = event['chatId']?.toString() ?? '';
      if (rawChatId.isEmpty) {
        rawChatId = senderId;
      }

      // Check if user is currently looking at this active chat
      if (currentActiveChatId != null) {
        final active = currentActiveChatId!;
        if (active == rawChatId ||
            active == 'p:$rawChatId' ||
            active == 'p:$senderId' ||
            active == senderId) {
          // User is currently inside this chat! Suppress notification
          return;
        }
      }

      // Determine if message is from a group
      final bool isGroup = event['is_group'] == true ||
          message['group_id'] != null ||
          event['table'] == 'group_messages';

      // Determine if sender is a Pocket Robot
      final bool isRobot = PocketRobotService.isRobotId(senderId) ||
          message['is_robot'] == true ||
          message['metadata']?['is_robot'] == true;

      // Anti-Spam protection for robot messages
      if (isRobot) {
        final now = DateTime.now();
        if (_lastRobotNotificationTime != null &&
            now.difference(_lastRobotNotificationTime!) < _kRobotCooldown) {
          // Within robot cooldown: silently skip to avoid spamming the user
          debugPrint('InAppNotificationService: Suppressed robot banner (cooldown active)');
          return;
        }
        _lastRobotNotificationTime = now;
      }

      // Resolve Sender Name & Avatar
      String senderName = 'Pocket Mate';
      String? senderAvatar;

      if (isRobot) {
        final robot = PocketRobotService.getRobotById(senderId);
        senderName = robot?.name ?? message['sender_name']?.toString() ?? 'Pocket Robot';
        senderAvatar = robot?.avatarUrl ?? message['sender_avatar']?.toString();
      } else {
        // Human mate: check cache first
        if (_profileCache.containsKey(senderId)) {
          senderName = _profileCache[senderId]!['name'] ?? 'Mate';
          senderAvatar = _profileCache[senderId]!['avatar'];
        } else {
          // Fetch from Supabase profile table
          try {
            final res = await SupaFlow.client
                .from('profile')
                .select('name, profile_image_url')
                .eq('user_id', senderId)
                .maybeSingle();

            if (res != null) {
              senderName = res['name']?.toString() ?? 'Mate';
              senderAvatar = res['profile_image_url']?.toString();
              _profileCache[senderId] = {
                'name': senderName,
                'avatar': senderAvatar ?? '',
              };
            }
          } catch (_) {
            senderName = message['sender_name']?.toString() ?? 'Mate';
            senderAvatar = message['sender_avatar']?.toString();
          }
        }
      }

      // Format Message Preview & determine Badge
      String previewText = message['message_text']?.toString() ??
          message['content']?.toString() ??
          '';

      final messageType = message['message_type']?.toString();
      final metadata = message['metadata'];

      String badgeText = 'CHAT';
      Color badgeColor = const Color(0xFF25D366);

      if (isRobot) {
        badgeText = 'ROBOT';
        badgeColor = const Color(0xFF00E5FF);
      }

      if (messageType == 'snap' || metadata?['is_snap'] == true) {
        previewText = '🔥 Sent you a Snap';
        badgeText = 'SNAP';
        badgeColor = const Color(0xFFFF9500);
      } else if (messageType == 'image') {
        previewText = '📷 Sent a photo';
        badgeText = 'PHOTO';
        badgeColor = const Color(0xFF5856D6);
      } else if (messageType == 'audio' || messageType == 'voice') {
        previewText = '🎤 Sent a voice message';
        badgeText = 'VOICE';
        badgeColor = const Color(0xFFFF2D55);
      } else if (messageType == 'thought') {
        previewText = '💭 Shared a thought';
        badgeText = 'THOUGHT';
        badgeColor = const Color(0xFFAF52DE);
      } else if (previewText.isEmpty) {
        previewText = 'Sent a new message';
      }

      // Precise target chat identifier for navigation
      // Personal chats must always be 'p:<senderId>', while groups use raw groupId
      final String targetGroupId;
      if (isGroup) {
        final gId = message['group_id']?.toString() ?? rawChatId;
        targetGroupId = gId.startsWith('p:') ? gId.substring(2) : gId;
      } else {
        targetGroupId = 'p:$senderId';
      }

      final String displayName = isGroup && message['group_name'] != null
          ? message['group_name'].toString()
          : senderName;

      // Display the floating notification banner
      show(
        title: displayName,
        message: previewText,
        avatarUrl: senderAvatar,
        isRobot: isRobot,
        badgeText: badgeText,
        badgeColor: badgeColor,
        onTap: () {
          _navigateToChat(
            groupId: targetGroupId,
            groupName: displayName,
            groupImage: senderAvatar,
          );
        },
      );
    } catch (e) {
      debugPrint('InAppNotificationService error: $e');
    }
  }

  /// Show a floating notification banner from anywhere in the app
  static void show({
    required String title,
    required String message,
    String? avatarUrl,
    bool isRobot = false,
    String badgeText = 'NOW',
    Color? badgeColor,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlayState = appNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // Dismiss existing notification if one is currently visible
    _dismissCurrent();

    // Subtle tactile & sound feedback
    try {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}

    _currentEntry = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        message: message,
        avatarUrl: avatarUrl,
        isRobot: isRobot,
        badgeText: badgeText,
        badgeColor: badgeColor ?? const Color(0xFF25D366),
        onTap: () {
          _dismissCurrent();
          onTap?.call();
        },
        onDismiss: _dismissCurrent,
      ),
    );

    overlayState.insert(_currentEntry!);

    _dismissTimer = Timer(duration, () {
      _dismissCurrent();
    });
  }

  /// Navigate directly to the chat conversation
  static void _navigateToChat({
    required String groupId,
    required String groupName,
    String? groupImage,
  }) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WhatsAppGroupChat(
          groupId: groupId,
          groupName: groupName,
          groupImage: groupImage,
          showBackButton: true,
        ),
      ),
    );
  }

  /// Dismiss the currently visible notification banner
  static void _dismissCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? avatarUrl;
  final bool isRobot;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    this.avatarUrl,
    required this.isRobot,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismissWithAnimation() {
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  widget.onTap();
                },
                onTapCancel: () => setState(() => _isPressed = false),
                onVerticalDragUpdate: (details) {
                  // Swipe up to dismiss instantly
                  if (details.primaryDelta != null && details.primaryDelta! < -4) {
                    _dismissWithAnimation();
                  }
                },
                child: AnimatedScale(
                  scale: _isPressed ? 0.98 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1B232E).withValues(alpha: 0.92),
                              const Color(0xFF10161D).withValues(alpha: 0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.13),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: widget.badgeColor.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar / Icon Stack
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.badgeColor.withValues(alpha: 0.65),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.badgeColor.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: widget.avatarUrl != null &&
                                            widget.avatarUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: widget.avatarUrl!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                _buildFallbackAvatar(),
                                          )
                                        : _buildFallbackAvatar(),
                                  ),
                                ),
                                if (widget.isRobot)
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0B1926),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.smart_toy_rounded,
                                        color: Color(0xFF00E5FF),
                                        size: 12,
                                      ),
                                    ),
                                  )
                                else
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF25D366),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF10161D),
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // Title & Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: widget.badgeColor.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: widget.badgeColor.withValues(alpha: 0.35),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          widget.badgeText,
                                          style: TextStyle(
                                            color: widget.badgeColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Close gesture button
                            GestureDetector(
                              onTap: _dismissWithAnimation,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: widget.isRobot
            ? const Color(0xFF0B2535)
            : const Color(0xFF1E332D),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.isRobot ? Icons.smart_toy_rounded : Icons.person_rounded,
        color: widget.isRobot
            ? const Color(0xFF00E5FF)
            : const Color(0xFF25D366),
        size: 22,
      ),
    );
  }
}
