import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curriculum_data/pocket_90day_prepositions_visual_data.dart';
import 'games/prepositions_visual_flame_game.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// 🥛 Minimal Interactive Prepositions Spatial Glass Card
class PocketPrepositionsGlassCard extends StatefulWidget {
  final int day;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketPrepositionsGlassCard({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '10',
  });

  @override
  State<PocketPrepositionsGlassCard> createState() =>
      _PocketPrepositionsGlassCardState();
}

class _PocketPrepositionsGlassCardState
    extends State<PocketPrepositionsGlassCard> {
  late final PrepositionDayData _data;
  int _challengeIdx = 0;
  String? _selectedPosition;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _data = Pocket90DayPrepositionsVisualData.getDataForDay(widget.day);
    _initChallenge();
  }

  void _initChallenge() {
    setState(() {
      _selectedPosition = null;
      _isSuccess = false;
    });
  }

  void _onSelect(String posKey) {
    if (_isSuccess) return;
    final challenge = _data.challenges[_challengeIdx];

    setState(() => _selectedPosition = posKey);

    if (posKey == challenge.correctPosition) {
      PocketGameSfx.instance.playSnapCorrect();
      widget.onSpeak(challenge.sentence);
      setState(() => _isSuccess = true);

      if (_challengeIdx + 1 >= _data.challenges.length) {
        widget.onCompleted(true);
      }
    } else {
      PocketGameSfx.instance.playErrorBuzz();
    }
  }

  void _next() {
    if (_challengeIdx + 1 < _data.challenges.length) {
      setState(() => _challengeIdx++);
      _initChallenge();
    } else {
      widget.onCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data.challenges.isEmpty) return const SizedBox.shrink();
    final challenge = _data.challenges[_challengeIdx];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1F38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
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
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'STEP ${widget.stepNumber}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spatial Lab: ${challenge.targetPrep} (${challenge.prepLabelMl})',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${_challengeIdx + 1}/${_data.challenges.length}',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            challenge.prompt,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Mini 2D Visual Demonstration
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🥛', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 12),
                  Text(
                    _selectedPosition != null
                        ? '⚽ ${_selectedPosition!.toUpperCase()}'
                        : 'Tap position below 👇',
                    style: GoogleFonts.outfit(
                      color: _isSuccess ? const Color(0xFF00E676) : const Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Choices
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBtn('inside', 'IN', '📥'),
              _buildBtn('top', 'ON', '🔝'),
              _buildBtn('under', 'UNDER', '👇'),
              _buildBtn('between', 'BETWEEN', '↔️'),
              _buildBtn('behind', 'BEHIND', '🙈'),
              _buildBtn('beside', 'BESIDE', '👉'),
            ],
          ),

          if (_isSuccess) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
              ),
              onPressed: _next,
              child: Text(
                _challengeIdx + 1 < _data.challenges.length ? 'Next Preposition ➔' : 'Completed! 🏆',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],

          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00E5FF)),
              foregroundColor: const Color(0xFF00E5FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.videogame_asset, size: 18),
            label: Text(
              'Open 2D Visual Spatial Lab 🎮',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              final done = await PocketPrepositionsVisualGamePage.show(
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

  Widget _buildBtn(String key, String label, String icon) {
    final isSelected = _selectedPosition == key;
    return InkWell(
      onTap: () => _onSelect(key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF162A45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
