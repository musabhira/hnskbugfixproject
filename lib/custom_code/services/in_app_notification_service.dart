import 'dart:async';
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
/// (like iOS Dynamic Island / Instagram in-app push) when a new message arrives.
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

      // Format Message Preview
      String previewText = message['message_text']?.toString() ??
          message['content']?.toString() ??
          '';

      final messageType = message['message_type']?.toString();
      final metadata = message['metadata'];

      if (messageType == 'snap' || metadata?['is_snap'] == true) {
        previewText = '🔥 Sent you a Snap';
      } else if (messageType == 'image') {
        previewText = '📷 Sent a photo';
      } else if (messageType == 'audio' || messageType == 'voice') {
        previewText = '🎤 Sent a voice message';
      } else if (messageType == 'thought') {
        previewText = '💭 Shared a thought';
      } else if (previewText.isEmpty) {
        previewText = 'Sent a new message';
      }

      // Target chat identifier for navigation
      final targetGroupId = rawChatId.startsWith('p:')
          ? rawChatId
          : (rawChatId.contains('-') && rawChatId.length > 30 ? 'p:$rawChatId' : rawChatId);

      // Display the floating notification banner
      show(
        title: senderName,
        message: previewText,
        avatarUrl: senderAvatar,
        isRobot: isRobot,
        onTap: () {
          _navigateToChat(
            groupId: targetGroupId,
            groupName: senderName,
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
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    this.avatarUrl,
    required this.isRobot,
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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
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
      top: topPadding + 6,
      left: 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                // Swipe up to dismiss instantly
                if (details.primaryDelta != null && details.primaryDelta! < -5) {
                  _dismissWithAnimation();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1B242D),
                      Color(0xFF141A20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isRobot
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.45)
                        : const Color(0xFF25D366).withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isRobot
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF25D366))
                          .withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar / Icon Stack
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isRobot
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                                  : const Color(0xFF25D366).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
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
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0B1926),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: Color(0xFF00E5FF),
                                size: 11,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF141A20),
                                  width: 1.8,
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
                                    fontSize: 14,
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
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: (widget.isRobot
                                          ? const Color(0xFF00E5FF)
                                          : const Color(0xFF25D366))
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  widget.isRobot ? 'ROBOT MATE' : 'NOW',
                                  style: TextStyle(
                                    color: widget.isRobot
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF25D366),
                                    fontSize: 8.5,
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
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
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
