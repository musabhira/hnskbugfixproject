import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curriculum_data/pocket_90day_rhythm_chants_data.dart';
import 'games/karaoke_rhythm_chant_game.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// 🎤 Minimal Interactive Karaoke Sing-Along Chant Card
class PocketKaraokeChantCard extends StatefulWidget {
  final int day;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketKaraokeChantCard({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '9',
  });

  @override
  State<PocketKaraokeChantCard> createState() => _PocketKaraokeChantCardState();
}

class _PocketKaraokeChantCardState extends State<PocketKaraokeChantCard> {
  late final DayRhythmChantItem _chant;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _chant = Pocket90DayRhythmChantsData.getChantForDay(widget.day);
  }

  void _sing() {
    PocketGameSfx.instance.playClick();
    widget.onSpeak(_chant.fullSongText);
    setState(() => _isPlaying = true);
    widget.onCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF200B36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF4081).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4081).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'STEP ${widget.stepNumber}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF4081),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sing-Along: ${_chant.title}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${_chant.beatBpm} BPM',
                style: GoogleFonts.outfit(color: const Color(0xFFFF4081), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _chant.contextMl,
            style: GoogleFonts.notoSansMalayalam(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Lyric Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _chant.lyrics.map((line) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Text('🎵', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          line,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4081),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.music_note, size: 20),
            label: Text(
              _isPlaying ? 'Singing Along...' : 'Sing Rhythm Chant 🎵',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            onPressed: _sing,
          ),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF4081)),
              foregroundColor: const Color(0xFFFF4081),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.mic, size: 18),
            label: Text(
              'Open Full Karaoke Studio 🎤',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              final done = await PocketKaraokeRhythmChantPage.show(
                context,
                day: widget.day,
              );
              if (done == true) {
                widget.onCompleted(true);
              }
            },
          ),
        ],
      ),
    );
  }
}
