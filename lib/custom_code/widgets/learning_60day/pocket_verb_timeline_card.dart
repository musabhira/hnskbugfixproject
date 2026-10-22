import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'games/verb_timeline_flame_game.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_verb_localization_service.dart';

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
  bool _showClassGuide = false;
  bool _isAutoDemoRunning = false;

  @override
  void initState() {
    super.initState();
    _verbs = Pocket90DayVerbTimelineData.getVerbsForDay(widget.day);
    // User Audio Directive: Day 1-ൽ മാത്രം ആദ്യ തവണ എന്താണ് Past, Present, Future എന്ന് കാണിച്ചു കൊടുക്കുക
    _showClassGuide = (widget.day == 1);
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

  Future<void> _runQuickDemo() async {
    if (_verbs.isEmpty || _isAutoDemoRunning) return;
    setState(() {
      _isAutoDemoRunning = true;
      _initCurrent();
    });

    final item = _verbs[_activeVerbIdx];
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _onTapWord(item.past);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _onTapWord(item.present);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _onTapWord(item.future);
    if (mounted) {
      setState(() => _isAutoDemoRunning = false);
    }
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
              // 💡 Class / Demo Toggle Button
              GestureDetector(
                onTap: () => setState(() => _showClassGuide = !_showClassGuide),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.6), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        'Class / Demo',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB74D),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_activeVerbIdx + 1}/${_verbs.length}',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.getLocalizedMeaning(),
            style: PocketVerbLocalizationService.getNativeTextStyle(
              color: const Color(0xFF00E5FF),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          // 🎓 Master Class Banner: Past, Present, Future Explanation & Quick Demo
          if (_showClassGuide) _buildClassGuideBanner(),

          // 3 Columns Runway
          Row(
            children: [
              Expanded(
                child: _buildColumnBox(
                  'YESTERDAY',
                  'PAST • കഴിഞ്ഞത്',
                  _placedPast,
                  const Color(0xFFFF9100),
                  item.pastSentence,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildColumnBox(
                  'TODAY',
                  'PRESENT • ഇപ്പോൾ',
                  _placedPresent,
                  const Color(0xFF00E676),
                  item.presentSentence,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildColumnBox(
                  'TOMORROW',
                  'FUTURE • ഇനി',
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

  Widget _buildClassGuideBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎓', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'MASTER CLASS: Past, Present, Future',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showClassGuide = false),
                child: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTimelineExplanationRow(
            '⏪ YESTERDAY (PAST / കഴിഞ്ഞത്):',
            'കഴിഞ്ഞുപോയ കാര്യങ്ങൾക്ക് Verb-ന്റെ Past രൂപം (V2) ഉപയോഗിക്കുക (ഉദാ: Went, Ate, Played).',
            const Color(0xFFFF9100),
          ),
          const SizedBox(height: 5),
          _buildTimelineExplanationRow(
            '⏸️ TODAY (PRESENT / ഇപ്പോൾ):',
            'ഇപ്പോൾ ചെയ്യുന്നതോ ദിവസവും ശീലമായതോ ആയ കാര്യങ്ങൾക്ക് (ഉദാ: Go, Eat, Play).',
            const Color(0xFF00E676),
          ),
          const SizedBox(height: 5),
          _buildTimelineExplanationRow(
            '⏩ TOMORROW (FUTURE / ഇനി നടക്കാൻ പോകുന്നത്):',
            'ഭാവിയിൽ ചെയ്യാൻ പോകുന്ന കാര്യങ്ങൾക്ക് "Will" ചേർക്കുക (ഉദാ: Will go, Will eat, Will play).',
            const Color(0xFF00E5FF),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9100),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: Text(
                  _isAutoDemoRunning ? 'ഡെമോ കാണിക്കുന്നു...' : '▶️ കളി കാണിച്ചു തരാം (Demo)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                onPressed: _isAutoDemoRunning ? null : _runQuickDemo,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _showClassGuide = false),
                child: Text('മനസ്സിലായി 👍', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineExplanationRow(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        Text(desc, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _buildColumnBox(String label, String sublabel, String? word, Color color, String sentence) {
    final filled = word != null;
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(7),
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
          Text(
            sublabel,
            style: GoogleFonts.inter(
              color: color.withValues(alpha: 0.75),
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
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
            const SizedBox(height: 14),
            const Icon(Icons.add_circle_outline, color: Colors.white24, size: 20),
          ],
        ],
      ),
    );
  }
}
