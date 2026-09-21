import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_audio_space_engine.dart';
import 'pocket_audio_room_sheet.dart';

/// 🎙️ PocketFloatingAudioBar
/// Sleek floating audio bar that stays above bottom navigation when user
/// minimizes the live Clubhouse voice room to browse the app.
class PocketFloatingAudioBar extends StatefulWidget {
  const PocketFloatingAudioBar({super.key});

  @override
  State<PocketFloatingAudioBar> createState() => _PocketFloatingAudioBarState();
}

class _PocketFloatingAudioBarState extends State<PocketFloatingAudioBar> {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_engine.isInRoom || _engine.currentSpace == null) {
      return const SizedBox.shrink();
    }

    final space = _engine.currentSpace!;
    final isSpeaker = _engine.isSpeaker;
    final isMuted = _engine.isMicMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => PocketAudioRoomSheet.show(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Live Soundwave / Microphone Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: const Text('🎙️', style: TextStyle(fontSize: 18))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.15, 1.15),
                          duration: 800.ms,
                        ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Participant Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE • ${space.levelTag}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        space.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Mic Quick Toggle (if speaker)
                if (isSpeaker) ...[
                  IconButton(
                    onPressed: () => _engine.toggleMic(),
                    icon: Icon(
                      isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      size: 22,
                    ),
                    tooltip: isMuted ? 'Unmute' : 'Mute',
                  ),
                ] else ...[
                  // Listener hand raise quick indicator
                  IconButton(
                    onPressed: () => _engine.toggleHandRaise(),
                    icon: Text(
                      _engine.handRaised ? '✋' : '👋',
                      style: const TextStyle(fontSize: 18),
                    ),
                    tooltip: 'Raise Hand',
                  ),
                ],

                // Leave Button
                IconButton(
                  onPressed: () => _engine.leaveSpace(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  tooltip: 'Leave Room',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
