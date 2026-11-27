import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';

/// 🔄 Reusable Privacy-Aware Avatar / Profile Photo 3D Flip Widget
///
/// Rules:
/// - Public profile (`isPrivate == false`): Outside lists/cards show real photo if available (else avatar).
/// - Private profile (`isPrivate == true`): Outside lists/non-mates show Avatar only.
/// - Mates / Chat peek (`enableTapPeekFlip == true`): Tapping flips to reveal the photo for ~10s, then flips back to Avatar.
/// - Main Profile Visit (`enableAutoShowcaseFlip == true`): Starts on Avatar, flips to Photo after ~3s for ~30s, then flips back to Avatar.
class PocketPrivacyAvatarFlipWidget extends StatefulWidget {
  final String? profileImageUrl;
  final VectorAvatarConfig avatarConfig;
  final double size;
  final bool isPrivate;
  final bool isMate;
  final bool isSelf;
  final bool showAura;
  final bool enableAutoShowcaseFlip;
  final bool enableTapPeekFlip;
  final VoidCallback? onTapOverride;
  final Duration? customFlipInterval;
  final bool startWithPhoto;

  const PocketPrivacyAvatarFlipWidget({
    super.key,
    required this.profileImageUrl,
    required this.avatarConfig,
    this.size = 48,
    this.isPrivate = false,
    this.isMate = false,
    this.isSelf = false,
    this.showAura = false,
    this.enableAutoShowcaseFlip = false,
    this.enableTapPeekFlip = false,
    this.onTapOverride,
    this.customFlipInterval,
    this.startWithPhoto = false,
  });

  /// Checks both top-level `is_private` and `avatar_config.is_private`
  static bool isProfilePrivate(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    if (profile['is_private'] == true) return true;
    final cfg = profile['avatar_config'];
    if (cfg is Map && cfg['is_private'] == true) return true;
    return false;
  }

  @override
  State<PocketPrivacyAvatarFlipWidget> createState() =>
      _PocketPrivacyAvatarFlipWidgetState();
}

class _PocketPrivacyAvatarFlipWidgetState
    extends State<PocketPrivacyAvatarFlipWidget>
    with SingleTickerProviderStateMixin {
  static final ValueNotifier<bool> _globalShowPhotoNotifier =
      ValueNotifier<bool>(false);
  static Timer? _globalCycleTimer;
  static int _activeListenerCount = 0;

  static void _ensureGlobalCycleStarted() {
    if (_globalCycleTimer != null) return;
    void scheduleNext(bool currentlyShowingPhoto) {
      _globalCycleTimer = Timer(
        const Duration(seconds: 10),
        () {
          if (_activeListenerCount <= 0) {
            _globalCycleTimer = null;
            return;
          }
          final next = !currentlyShowingPhoto;
          _globalShowPhotoNotifier.value = next;
          scheduleNext(next);
        },
      );
    }

    scheduleNext(_globalShowPhotoNotifier.value);
  }

  late AnimationController _flipController;
  Timer? _initialShowcaseTimer;
  Timer? _revertTimer;
  Timer? _customFlipTimer;
  bool _showingPhoto = false;
  bool _listeningGlobal = false;

  bool get _hasPhoto =>
      widget.profileImageUrl != null &&
      widget.profileImageUrl!.trim().isNotEmpty;

  bool get _canRevealPhoto => _hasPhoto;

  void _onGlobalToggle() {
    if (!mounted || !_hasPhoto || widget.enableAutoShowcaseFlip) return;
    if (_globalShowPhotoNotifier.value) {
      if (!_showingPhoto) {
        setState(() => _showingPhoto = true);
        _flipController.forward();
      }
    } else {
      if (_showingPhoto) {
        setState(() => _showingPhoto = false);
        _flipController.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    if (widget.customFlipInterval != null && _hasPhoto) {
      _showingPhoto = widget.startWithPhoto;
      _flipController.value = _showingPhoto ? 1.0 : 0.0;
      _customFlipTimer = Timer.periodic(widget.customFlipInterval!, (_) {
        if (!mounted || !_hasPhoto) return;
        if (_showingPhoto) {
          _flipToAvatar();
        } else {
          _flipToPhoto();
        }
      });
    } else if (widget.enableAutoShowcaseFlip) {
      // Main Profile Visit: show Avatar first for 5s, then flip to real Photo for 10s, then cycle!
      _showingPhoto = false;
      if (_canRevealPhoto) {
        _initialShowcaseTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          _flipToPhoto(revertAfter: const Duration(seconds: 10));
        });
      }
    } else if (_hasPhoto) {
      _listeningGlobal = true;
      _activeListenerCount++;
      _globalShowPhotoNotifier.addListener(_onGlobalToggle);
      _ensureGlobalCycleStarted();
      _showingPhoto = _globalShowPhotoNotifier.value;
      _flipController.value = _showingPhoto ? 1.0 : 0.0;
    } else {
      _showingPhoto = false;
      _flipController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant PocketPrivacyAvatarFlipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customFlipInterval != null) {
      if (oldWidget.profileImageUrl != widget.profileImageUrl) {
        _customFlipTimer?.cancel();
        if (_hasPhoto) {
          _showingPhoto = widget.startWithPhoto;
          _flipController.value = _showingPhoto ? 1.0 : 0.0;
          _customFlipTimer = Timer.periodic(widget.customFlipInterval!, (_) {
            if (!mounted || !_hasPhoto) return;
            if (_showingPhoto) {
              _flipToAvatar();
            } else {
              _flipToPhoto();
            }
          });
        } else {
          setState(() => _showingPhoto = false);
          _flipController.value = 0.0;
        }
      }
      return;
    }
    if (!widget.enableAutoShowcaseFlip &&
        oldWidget.profileImageUrl != widget.profileImageUrl) {
      if (_hasPhoto && !_listeningGlobal) {
        _listeningGlobal = true;
        _activeListenerCount++;
        _globalShowPhotoNotifier.addListener(_onGlobalToggle);
        _ensureGlobalCycleStarted();
        _showingPhoto = _globalShowPhotoNotifier.value;
        _flipController.value = _showingPhoto ? 1.0 : 0.0;
      } else if (!_hasPhoto && _listeningGlobal) {
        _listeningGlobal = false;
        _activeListenerCount = math.max(0, _activeListenerCount - 1);
        _globalShowPhotoNotifier.removeListener(_onGlobalToggle);
        setState(() => _showingPhoto = false);
        _flipController.value = 0.0;
      }
    }
  }

  void _flipToPhoto({Duration? revertAfter}) {
    if (!_canRevealPhoto) return;
    _revertTimer?.cancel();
    setState(() => _showingPhoto = true);
    _flipController.forward();
    if (revertAfter != null) {
      _revertTimer = Timer(revertAfter, () {
        if (!mounted) return;
        _flipToAvatar(
          resumeAfter: widget.enableAutoShowcaseFlip
              ? const Duration(seconds: 10)
              : null,
        );
      });
    }
  }

  void _flipToAvatar({Duration? resumeAfter}) {
    _revertTimer?.cancel();
    setState(() => _showingPhoto = false);
    _flipController.reverse();
    if (resumeAfter != null) {
      _revertTimer = Timer(resumeAfter, () {
        if (!mounted) return;
        _flipToPhoto(revertAfter: const Duration(seconds: 10));
      });
    }
  }

  void _handleTap() {
    if (widget.onTapOverride != null) {
      widget.onTapOverride!();
      return;
    }
    if (!widget.enableTapPeekFlip && !widget.enableAutoShowcaseFlip) return;
    HapticFeedback.selectionClick();
    if (!_canRevealPhoto) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Private account • Become Mates to view photo!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_showingPhoto) {
      _flipToAvatar();
    } else {
      _flipToPhoto(
        revertAfter: widget.enableAutoShowcaseFlip
            ? const Duration(seconds: 30)
            : const Duration(seconds: 10),
      );
    }
  }

  @override
  void dispose() {
    if (_listeningGlobal) {
      _activeListenerCount = math.max(0, _activeListenerCount - 1);
      _globalShowPhotoNotifier.removeListener(_onGlobalToggle);
      if (_activeListenerCount <= 0) {
        _globalCycleTimer?.cancel();
        _globalCycleTimer = null;
      }
    }
    _initialShowcaseTimer?.cancel();
    _revertTimer?.cancel();
    _customFlipTimer?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  Widget _buildAvatarFace() {
    return VectorAvatarWidget(
      config: widget.avatarConfig,
      size: widget.size,
      showAura: widget.showAura,
    );
  }

  Widget _buildPhotoFace() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.profileImageUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildAvatarFace(),
        errorWidget: (_, __, ___) => _buildAvatarFace(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, _) {
          final angle = _flipController.value * math.pi;
          final isBack = angle > (math.pi / 2);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: isBack && _canRevealPhoto
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildPhotoFace(),
                  )
                : _buildAvatarFace(),
          );
        },
      ),
    );

    if (!widget.enableTapPeekFlip &&
        !widget.enableAutoShowcaseFlip &&
        widget.onTapOverride == null) {
      return child;
    }

    return GestureDetector(
      onTap: _handleTap,
      child: child,
    );
  }
}

