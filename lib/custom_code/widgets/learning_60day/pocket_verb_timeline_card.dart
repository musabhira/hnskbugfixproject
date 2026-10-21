import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'games/verb_timeline_flame_game.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// ⏳ Minimal & Rich Interactive Verb Timeline Practice Card
/// Can be rendered inside PocketMissionTopicDetailPage and Master Hub.
class PocketVerbTimelineCard extends StatefulWidget {
  final int day;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketVerbTimelineCard({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '8',
  });

  @override
  State<PocketVerbTimelineCard> createState() => _PocketVerbTimelineCardState();
}

class _PocketVerbTimelineCardState extends State<PocketVerbTimelineCard> {
  late final List<VerbTimelineItem> _verbs;
  int _activeVerbIdx = 0;

  String? _placedPast;
  String? _placedPresent;
  String? _placedFuture;
  final List<String> _remaining = [];

  bool _isAllFilled = false;

  @override
  void initState() {
    super.initState();
    _verbs = Pocket90DayVerbTimelineData.getVerbsForDay(widget.day);
    _initCurrent();
  }

  void _initCurrent() {
    if (_activeVerbIdx >= _verbs.length) return;
    final item = _verbs[_activeVerbIdx];
    final words = [item.past, item.present, item.future];
    words.shuffle();
    setState(() {
      _placedPast = null;
      _placedPresent = null;
      _placedFuture = null;
      _remaining.clear();
      _remaining.addAll(words);
      _isAllFilled = false;
    });
  }

  void _onTapWord(String word) {
    if (_isAllFilled) return;
    final item = _verbs[_activeVerbIdx];

    if (word == item.past && _placedPast == null) {
      PocketGameSfx.instance.playSnapCorrect();
      widget.onSpeak(item.pastSentence);
      setState(() {
        _placedPast = word;
        _remaining.remove(word);
      });
    } else if (word == item.present && _placedPresent == null) {
      PocketGameSfx.instance.playSnapCorrect();
      widget.onSpeak(item.presentSentence);
      setState(() {
        _placedPresent = word;
        _remaining.remove(word);
      });
    } else if (word == item.future && _placedFuture == null) {
      PocketGameSfx.instance.playSnapCorrect();
      widget.onSpeak(item.futureSentence);
      setState(() {
        _placedFuture = word;
        _remaining.remove(word);
      });
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      return;
    }

    if (_placedPast != null && _placedPresent != null && _placedFuture != null) {
      setState(() => _isAllFilled = true);
      PocketGameSfx.instance.playVictory();
      widget.onSpeak(item.rhythmChant);
      if (_activeVerbIdx + 1 >= _verbs.length) {
        widget.onCompleted(true);
      }
    }
  }

  void _nextVerb() {
    if (_activeVerbIdx + 1 < _verbs.length) {
      setState(() => _activeVerbIdx++);
      _initCurrent();
    } else {
      widget.onCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verbs.isEmpty) {
      return const SizedBox.shrink();
    }
    final item = _verbs[_activeVerbIdx];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF130924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'STEP ${widget.stepNumber}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF9100),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Verb Timeline: ${item.baseVerb.toUpperCase()}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${_activeVerbIdx + 1}/${_verbs.length}',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.meaningMl,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF00E5FF),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Columns Runway
          Row(
            children: [
              Expanded(
                child: _buildColumnBox(
                  'YESTERDAY',
                  _placedPast,
                  const Color(0xFFFF9100),
                  item.pastSentence,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildColumnBox(
                  'TODAY',
                  _placedPresent,
                  const Color(0xFF00E676),
                  item.presentSentence,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildColumnBox(
                  'TOMORROW',
                  _placedFuture,
                  const Color(0xFF00E5FF),
                  item.futureSentence,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Word Bank
          if (!_isAllFilled) ...[
            Text(
              'Tap verb form to place in timeline:',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _remaining.map((word) {
                return InkWell(
                  onTap: () => _onTapWord(word),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B124C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E676)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎵', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'Rhythm Chant:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.rhythmChant,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
              ),
              onPressed: _nextVerb,
              child: Text(
                _activeVerbIdx + 1 < _verbs.length ? 'Next Verb ➔' : 'Step Completed! 🏆',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Full Screen Flame Game Launcher button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF9100)),
              foregroundColor: const Color(0xFFFF9100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.videogame_asset, size: 18),
            label: Text(
              'Open Full-Screen Flame Arcade 🎮',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              final done = await PocketVerbTimelineGamePage.show(
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

  Widget _buildColumnBox(String label, String? word, Color color, String sentence) {
    final filled = word != null;
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: filled ? color : Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          if (filled) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                word,
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sentence,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Icon(Icons.add_circle_outline, color: Colors.white24, size: 20),
          ],
        ],
      ),
    );
  }
}
