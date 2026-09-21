import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_audio_space_engine.dart';

/// 🎙️ PocketAudioRoomSheet
/// Clubhouse-style Live Voice Stage Bottom Sheet / Modal View.
class PocketAudioRoomSheet extends StatefulWidget {
  final VoidCallback? onMinimize;

  const PocketAudioRoomSheet({
    super.key,
    this.onMinimize,
  });

  /// Helper to show this bottom sheet modal
  static Future<void> show(BuildContext context, {VoidCallback? onMinimize}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketAudioRoomSheet(onMinimize: onMinimize),
    );
  }

  @override
  State<PocketAudioRoomSheet> createState() => _PocketAudioRoomSheetState();
}

class _PocketAudioRoomSheetState extends State<PocketAudioRoomSheet>
    with SingleTickerProviderStateMixin {
  final PocketAudioSpaceEngine _engine = PocketAudioSpaceEngine.instance;

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    super.dispose();
  }

  void _onEngineUpdate() {
    if (mounted) {
      // If room was ended or user left, dismiss sheet
      if (!_engine.isInRoom && !_engine.isConnecting) {
        Navigator.of(context, rootNavigator: true).maybePop();
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = _engine.currentSpace;
    final screenHeight = MediaQuery.of(context).size.height;

    if (space == null && !_engine.isConnecting) {
      return const SizedBox.shrink();
    }

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark slate clubhouse canvas
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Drag handle & Header bar
          _buildHeader(context, space),

          // 2. Main Stage & Audience Content
          Expanded(
            child: _engine.isConnecting
                ? _buildConnectingState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Category & Topic Card
                        _buildTopicBanner(space!),

                        const SizedBox(height: 20),

                        // Stage (Active Speakers)
                        _buildStageSection(),

                        const SizedBox(height: 28),

                        // Audience (Listeners)
                        _buildAudienceSection(),

                        const SizedBox(height: 100), // padding for floating bottom bar
                      ],
                    ),
                  ),
          ),

          // 3. Bottom Clubhouse Action Bar
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AudioSpaceModel? space) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Drag handle pill
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Minimize button (down chevron)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70, size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onMinimize?.call();
                },
                tooltip: 'Minimize stage',
              ),
              const SizedBox(width: 4),

              // Title with LIVE indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3)),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE AUDIO SPACE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      space?.title ?? 'English Stage',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Leave Quietly button
              GestureDetector(
                onTap: () {
                  _engine.leaveSpace();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✌️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'Leave',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBanner(AudioSpaceModel space) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎙️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        space.levelTag,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${space.category}',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  space.topic,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSection() {
    final speakers = _engine.stageSpeakers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'THE STAGE',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFC00),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${speakers.length} / ${_engine.currentSpace?.speakerLimit ?? 6}',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid of stage speakers
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: speakers.length,
          itemBuilder: (context, index) {
            final speaker = speakers[index];
            return _buildSpeakerTile(speaker);
          },
        ),
      ],
    );
  }

  Widget _buildSpeakerTile(AudioParticipant speaker) {
    final isMe = speaker.userId == _engine.myUserId;
    final isSpeaking = speaker.isSpeaking && !speaker.isMuted;

    return GestureDetector(
      onTap: () => _handleParticipantTap(speaker),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing speaking aura ring
              if (isSpeaking)
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 3),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15)),

              // Avatar Circle
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF334155),
                  border: Border.all(
                    color: speaker.isHost
                        ? const Color(0xFFFFFC00)
                        : (isSpeaking ? const Color(0xFF10B981) : const Color(0xFF475569)),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: speaker.avatarUrl != null && speaker.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: speaker.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                          ),
                          errorWidget: (_, __, ___) => _buildDefaultAvatar(speaker.name),
                        )
                      : _buildDefaultAvatar(speaker.name),
                ),
              ),

              // Crown badge if host
              if (speaker.isHost)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFC00),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('👑', style: TextStyle(fontSize: 10)),
                  ),
                ),

              // Muted badge
              if (speaker.isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0F172A), width: 2),
                    ),
                    child: const Icon(Icons.mic_off_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            isMe ? 'You' : speaker.name,
            style: GoogleFonts.outfit(
              color: isMe ? const Color(0xFFFFFC00) : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Role tag
          Text(
            speaker.isHost ? 'Host' : 'Speaker',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceSection() {
    final listeners = _engine.audienceListeners;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'IN THE AUDIENCE',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${listeners.length}',
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (listeners.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Everyone is currently on stage!',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8,
            ),
            itemCount: listeners.length,
            itemBuilder: (context, index) {
              final listener = listeners[index];
              return _buildListenerTile(listener);
            },
          ),
      ],
    );
  }

  Widget _buildListenerTile(AudioParticipant listener) {
    final isMe = listener.userId == _engine.myUserId;

    return GestureDetector(
      onTap: () => _handleParticipantTap(listener),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(
                    color: listener.isRaisingHand
                        ? const Color(0xFFFFFC00)
                        : const Color(0xFF334155),
                    width: listener.isRaisingHand ? 2 : 1,
                  ),
                ),
                child: ClipOval(
                  child: listener.avatarUrl != null && listener.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: listener.avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildDefaultAvatar(listener.name, size: 14),
                        )
                      : _buildDefaultAvatar(listener.name, size: 14),
                ),
              ),

              // Raised Hand Emoji badge
              if (listener.isRaisingHand)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('✋', style: TextStyle(fontSize: 14)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shake(duration: 800.ms),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isMe ? 'You' : listener.name,
            style: GoogleFonts.outfit(
              color: isMe ? const Color(0xFFFFFC00) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, {double size = 18}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return Container(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFFFC00)),
          const SizedBox(height: 16),
          Text(
            'Joining English Voice Room...',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final isSpeaker = _engine.isSpeaker;
    final isMuted = _engine.isMicMuted;
    final handRaised = _engine.handRaised;
    final isSpeakerOn = _engine.isSpeakerphoneOn;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1120),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Speakerphone toggle
          IconButton(
            onPressed: () => _engine.toggleSpeakerphone(),
            icon: Icon(
              isSpeakerOn ? Icons.volume_up_rounded : Icons.phone_in_talk_rounded,
              color: isSpeakerOn ? const Color(0xFFFFFC00) : Colors.white60,
              size: 26,
            ),
            tooltip: isSpeakerOn ? 'Speakerphone ON' : 'Earpiece Mode',
          ),

          // Center Action:
          // If Speaker: Mute / Unmute
          // If Listener: Raise Hand / Lower Hand
          if (isSpeaker)
            GestureDetector(
              onTap: () => _engine.toggleMic(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isMuted
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMuted ? 'Muted' : 'Speaking',
                      style: GoogleFonts.outfit(
                        color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _engine.toggleHandRaise(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: handRaised
                      ? const Color(0xFFFFFC00).withValues(alpha: 0.2)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: handRaised ? const Color(0xFFFFFC00) : const Color(0xFF475569),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✋', style: TextStyle(fontSize: handRaised ? 18 : 16)),
                    const SizedBox(width: 8),
                    Text(
                      handRaised ? 'Hand Raised' : 'Raise Hand',
                      style: GoogleFonts.outfit(
                        color: handRaised ? const Color(0xFFFFFC00) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right: If speaker, option to step down to audience
          if (isSpeaker && !_engine.isHost)
            TextButton.icon(
              onPressed: () => _engine.demoteSpeakerToListener(_engine.myUserId!),
              icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white54, size: 16),
              label: Text(
                'Quiet',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
            )
          else
            const SizedBox(width: 48), // Spacer to balance layout
        ],
      ),
    );
  }

  void _handleParticipantTap(AudioParticipant participant) {
    final isMe = participant.userId == _engine.myUserId;
    if (isMe) return;

    // Only host has moderation options
    if (!_engine.isHost) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moderation: ${participant.name}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (participant.isListener) ...[
                ListTile(
                  leading: const Icon(Icons.mic_rounded, color: Color(0xFF10B981)),
                  title: Text('Invite to Speak on Stage',
                      style: GoogleFonts.outfit(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _engine.promoteToSpeaker(participant.userId);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.mic_off_rounded, color: Color(0xFFF59E0B)),
                  title: Text('Mute Speaker', style: GoogleFonts.outfit(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _engine.muteSpeaker(participant.userId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove_rounded, color: Color(0xFFEF4444)),
                  title: Text('Move to Audience', style: GoogleFonts.outfit(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _engine.demoteSpeakerToListener(participant.userId);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
