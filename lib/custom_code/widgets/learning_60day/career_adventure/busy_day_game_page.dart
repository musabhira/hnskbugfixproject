import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'busy_day_models.dart';

/// 2D Flame Game Page for Level 7: The Busy Day
class BusyDayGamePage extends StatefulWidget {
  final BusyDayLevelData levelData;

  const BusyDayGamePage({
    super.key,
    required this.levelData,
  });

  @override
  State<BusyDayGamePage> createState() => _BusyDayGamePageState();
}

class _BusyDayGamePageState extends State<BusyDayGamePage> {
  late final BusyDayFlameGame _flameGame;
  late final FlutterTts _flutterTts;

  int _currentSceneIndex = 0;
  int _scoreXp = 0;
  int _hintsUsed = 0;
  int _wrongChoices = 0;
  bool _audioMuted = false;
  bool _showTaskBoard = false;
  String? _selectedFolderId;
  String? _lastFeedback;
  bool _isOptionSelected = false;

  // Communication Quality Metrics
  double _totalNaturalness = 0.0;
  double _totalPoliteness = 0.0;
  double _totalAccuracy = 0.0;
  int _evaluatedChoicesCount = 0;

  // Active Quests
  late List<QuestItem> _quests;

  @override
  void initState() {
    super.initState();
    _quests = List.from(widget.levelData.initialQuests);
    _initTts();
    _initFlameGame();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.48);
    _flutterTts.setPitch(1.0);
  }

  void _initFlameGame() {
    _flameGame = BusyDayFlameGame(
      levelData: widget.levelData,
      onZoneReached: (zoneId) {
        // Player walked into zone
      },
    );

    // Speak initial scene prompt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentScene();
    });
  }

  void _speakCurrentScene() {
    if (_audioMuted) return;
    final scene = widget.levelData.scenes[_currentSceneIndex];
    _speak(scene.spokenText);
  }

  Future<void> _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _showHintDialog() {
    HapticFeedback.lightImpact();
    setState(() {
      _hintsUsed++;
      if (_scoreXp > 5) _scoreXp -= 5;
    });

    final scene = widget.levelData.scenes[_currentSceneIndex];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.4),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded,
                color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              'Communication Clue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          scene.hint,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'GOT IT',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChoiceSelected(DialogueOption option) {
    if (_isOptionSelected) return;

    HapticFeedback.selectionClick();
    setState(() {
      _isOptionSelected = true;
      _lastFeedback = option.feedback;
      _totalNaturalness += option.naturalnessScore;
      _totalPoliteness += option.politenessScore;
      _totalAccuracy += option.accuracyScore;
      _evaluatedChoicesCount++;
    });

    if (option.isSuccessful) {
      HapticFeedback.mediumImpact();
      setState(() {
        _scoreXp += option.xpReward;
      });

      final scene = widget.levelData.scenes[_currentSceneIndex];

      // Mark related quest completed if any
      if (scene.relatedQuestId != null) {
        final qIndex = _quests.indexWhere((q) => q.id == scene.relatedQuestId);
        if (qIndex != -1) {
          _quests[qIndex].status = QuestStatus.completed;
        }
      }

      // Smooth delay to read feedback and proceed
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _advanceToNextScene();
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _wrongChoices++;
      });
      // Reset option lock so player can try a better response
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _isOptionSelected = false;
          _lastFeedback = null;
        });
      });
    }
  }

  void _advanceToNextScene() {
    if (_currentSceneIndex < widget.levelData.scenes.length - 1) {
      setState(() {
        _currentSceneIndex++;
        _isOptionSelected = false;
        _lastFeedback = null;
        _selectedFolderId = null;
      });

      // Move player character forward in Flame world
      _flameGame.movePlayerToScene(_currentSceneIndex);
      _speakCurrentScene();
    } else {
      // Completed all 10 scenes!
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    final naturalnessPct = _evaluatedChoicesCount > 0
        ? ((_totalNaturalness / _evaluatedChoicesCount) * 100).round()
        : 88;
    final politenessPct = _evaluatedChoicesCount > 0
        ? ((_totalPoliteness / _evaluatedChoicesCount) * 100).round()
        : 92;
    final accuracyPct = _evaluatedChoicesCount > 0
        ? ((_totalAccuracy / _evaluatedChoicesCount) * 100).round()
        : 90;
    final problemSolvingPct = math.max(75, 100 - (_wrongChoices * 5));

    final overallRating = ((naturalnessPct + politenessPct + accuracyPct + problemSolvingPct) / 4).round();
    final stars = overallRating >= 90 ? 3 : (overallRating >= 75 ? 2 : 1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF10B981),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(
              'BUSY DAY COMPLETE!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'All everyday communications & decisions verified.',
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isStar = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isStar ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isStar ? const Color(0xFFFFD700) : Colors.white24,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Score Metrics Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricStat('Naturalness', '$naturalnessPct%'),
                      _metricStat('Politeness', '$politenessPct%'),
                      _metricStat('Problem Solving', '$problemSolvingPct%'),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricStat('Quests',
                          '${_quests.where((q) => q.status == QuestStatus.completed).length}/${_quests.length}'),
                      _metricStat('Total XP', '+$_scoreXp XP'),
                      _metricStat('Hints', '$_hintsUsed'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'CONTINUE TO DAY 8 🚀',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFD700),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.levelData.scenes[_currentSceneIndex];
    final progress = (_currentSceneIndex + 1) / widget.levelData.scenes.length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 18),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF0EA5E9), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'The Busy Day',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Audio Speech Toggle
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF0EA5E9),
              size: 20,
            ),
            tooltip: 'Toggle Speech Audio',
            onPressed: () {
              setState(() {
                _audioMuted = !_audioMuted;
              });
            },
          ),
          // Task Board Toggle
          IconButton(
            icon: Badge(
              label: Text(
                '${_quests.where((q) => q.status == QuestStatus.completed).length}/${_quests.length}',
                style: const TextStyle(fontSize: 9),
              ),
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(Icons.checklist_rounded,
                  color: Color(0xFF38BDF8), size: 20),
            ),
            tooltip: 'Today\'s Task Board',
            onPressed: () {
              setState(() {
                _showTaskBoard = !_showTaskBoard;
              });
            },
          ),
          // Hint Lightbulb
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFFFFD700), size: 22),
            tooltip: 'Communication Hint',
            onPressed: _showHintDialog,
          ),
          // XP Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 3),
                Text(
                  '$_scoreXp XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // 🎮 1. Continuous 2D Flame Game Canvas
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width;
                _flameGame.movePlayerByPixels(details.delta.dx, width);
              },
              child: GameWidget(game: _flameGame),
            ),
          ),

          // 🎯 2. Top HUD: Clock, Location & Objective
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTopClockAndObjectiveCard(scene),
              ],
            ),
          ),

          // 📋 3. Task Board Drawer Modal (when toggled)
          if (_showTaskBoard)
            Positioned(
              top: 84,
              left: 14,
              right: 14,
              child: _buildTaskBoardOverlay(),
            ),

          // 📂 4. Scene 9 Specific: Visual Folder Selection Modal
          if (scene.type == BusyDaySceneType.folderDetail && scene.folderChoices != null)
            Positioned(
              bottom: 170,
              left: 16,
              right: 16,
              child: _buildFolderSelectionPanel(scene.folderChoices!),
            ),

          // 🕹️ 5. Bottom Interactive Decision & Dialogue Panel
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: _buildBottomDialoguePanel(scene),
          ),
        ],
      ),
    );
  }

  Widget _buildTopClockAndObjectiveCard(BusyDayScene scene) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Clock Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    color: Colors.black, size: 13),
                const SizedBox(width: 4),
                Text(
                  scene.clockTime,
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Location & Objective
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${scene.locationTitle} · SCENE ${scene.id}/10',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  scene.objective,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
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

  Widget _buildTaskBoardOverlay() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.today_rounded,
                      color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'TODAY\'S SCHEDULE',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white60, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _showTaskBoard = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._quests.map((quest) {
            final isDone = quest.status == QuestStatus.completed;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isDone ? const Color(0xFF10B981) : Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: GoogleFonts.inter(
                        color: isDone ? Colors.white54 : Colors.white,
                        fontSize: 11,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Text(
                    quest.timeLabel,
                    style: GoogleFonts.inter(
                      color: isDone ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFolderSelectionPanel(List<FolderItem> folders) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open_rounded,
                  color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 6),
              Text(
                'Select Requested Item:',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: folders.map((folder) {
              final isSelected = _selectedFolderId == folder.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedFolderId = folder.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: folder.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFD700) : folder.color,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        folder.isSmall ? Icons.folder_rounded : Icons.folder_shared_rounded,
                        color: folder.color,
                        size: folder.isSmall ? 24 : 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        folder.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDialoguePanel(BusyDayScene scene) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NPC Speech Prompt
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0EA5E9)),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Color(0xFF0EA5E9), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.npcName,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0EA5E9),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '“${scene.npcSpeech}”',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF38BDF8), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _speak(scene.spokenText),
              ),
            ],
          ),

          if (_lastFeedback != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _lastFeedback!.contains('Great') ||
                          _lastFeedback!.contains('Perfect') ||
                          _lastFeedback!.contains('Proactive') ||
                          _lastFeedback!.contains('Polite') ||
                          _lastFeedback!.contains('Excellent') ||
                          _lastFeedback!.contains('Professional') ||
                          _lastFeedback!.contains('Natural') ||
                          _lastFeedback!.contains('Exact') ||
                          _lastFeedback!.contains('Outstanding')
                      ? const Color(0xFF10B981)
                      : Colors.orangeAccent,
                ),
              ),
              child: Text(
                _lastFeedback!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Dialogue Choices
          ...scene.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOptionSelected
                      ? null
                      : () => _handleChoiceSelected(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.id.split('_').last.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.text,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 6),

          // Bottom Walk Accessibility Step Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerLeft(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK LEFT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerRight(),
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK RIGHT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 2D Flame Game World for Level 7: The Busy Day
class BusyDayFlameGame extends FlameGame with TapCallbacks {
  final BusyDayLevelData levelData;
  final void Function(String zoneId) onZoneReached;

  double playerX = 120.0;
  double targetPlayerX = 120.0;
  bool isMoving = false;
  bool facingRight = true;
  double walkCycle = 0.0;

  static const double worldWidth = 1900.0;
  static const double groundY = 270.0;

  BusyDayFlameGame({
    required this.levelData,
    required this.onZoneReached,
  });

  void movePlayerByPixels(double dx, double screenWidth) {
    targetPlayerX = (playerX + dx * (worldWidth / screenWidth)).clamp(40.0, worldWidth - 40.0);
    facingRight = dx >= 0;
    isMoving = true;
  }

  void movePlayerLeft() {
    targetPlayerX = (playerX - 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = false;
    isMoving = true;
  }

  void movePlayerRight() {
    targetPlayerX = (playerX + 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = true;
    isMoving = true;
  }

  void movePlayerToScene(int sceneIndex) {
    final step = (worldWidth - 200.0) / (levelData.scenes.length - 1);
    targetPlayerX = (100.0 + (sceneIndex * step)).clamp(40.0, worldWidth - 40.0);
    facingRight = targetPlayerX >= playerX;
    isMoving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((targetPlayerX - playerX).abs() > 2.0) {
      final direction = (targetPlayerX - playerX).sign;
      playerX += direction * 220.0 * dt;
      walkCycle += dt * 8.0;
      isMoving = true;
    } else {
      playerX = targetPlayerX;
      isMoving = false;
    }

    // Check active zone
    for (final zone in levelData.zones) {
      if (playerX >= zone.startX && playerX <= zone.endX) {
        onZoneReached(zone.id);
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final viewWidth = size.x;
    final cameraX = (playerX - (viewWidth / 2))
        .clamp(0.0, math.max<double>(0.0, worldWidth - viewWidth));

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Sky & Background Gradients
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A0F1D), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), bgPaint);

    // 2. Continuous City Ground / Sidewalk
    final sidewalkPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), sidewalkPaint);

    final curbPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, 6), curbPaint);

    // 3. Render Distinct Zones
    _renderApartmentZone(canvas);
    _renderBusStopZone(canvas);
    _renderCafeZone(canvas);
    _renderWorkplaceZone(canvas);
    _renderExecutiveSuiteZone(canvas);

    // 4. Render Player Character
    _renderPlayer(canvas, playerX, groundY);

    canvas.restore();
  }

  void _renderApartmentZone(Canvas canvas) {
    // Apartment Room (x: 0 .. 380)
    final wallPaint = Paint()..color = const Color(0xFF1E1B4B);
    canvas.drawRect(const Rect.fromLTWH(20, 70, 320, 200), wallPaint);

    // Bed
    final bedPaint = Paint()..color = const Color(0xFF4338CA);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(40, 220, 100, 50), const Radius.circular(8)), bedPaint);

    // Window with morning glow
    final windowPaint = Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.6);
    canvas.drawRect(const Rect.fromLTWH(70, 100, 60, 80), windowPaint);

    // Wall Clock showing 8:00
    final clockPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(220, 120), 16, clockPaint);
    final handPaint = Paint()..color = Colors.black..strokeWidth = 2;
    canvas.drawLine(const Offset(220, 120), const Offset(220, 108), handPaint);
    canvas.drawLine(const Offset(220, 120), const Offset(220, 128), handPaint);
  }

  void _renderBusStopZone(Canvas canvas) {
    // Bus Shelter (x: 380 .. 740)
    final shelterGlass = Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.35);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(440, 120, 180, 150), const Radius.circular(10)), shelterGlass);

    final postPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 4;
    canvas.drawLine(const Offset(450, 120), const Offset(450, 270), postPaint);
    canvas.drawLine(const Offset(610, 120), const Offset(610, 270), postPaint);

    // Bus Stop Sign
    final signPaint = Paint()..color = const Color(0xFF0EA5E9);
    canvas.drawCircle(const Offset(420, 150), 18, signPaint);

    // Metro Entrance Canopy
    final metroPaint = Paint()..color = const Color(0xFF0369A1);
    canvas.drawRect(const Rect.fromLTWH(660, 170, 60, 100), metroPaint);
  }

  void _renderCafeZone(Canvas canvas) {
    // Corner Brew Café (x: 740 .. 1120)
    final cafeBg = Paint()..color = const Color(0xFF451A03);
    canvas.drawRect(const Rect.fromLTWH(770, 90, 310, 180), cafeBg);

    // Café Counter
    final counterPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(820, 200, 160, 70), const Radius.circular(8)), counterPaint);

    // Coffee Machine & Cups
    final machinePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRect(const Rect.fromLTWH(840, 165, 40, 35), machinePaint);

    // Awning stripes
    final awningPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawRect(const Rect.fromLTWH(760, 75, 330, 25), awningPaint);
  }

  void _renderWorkplaceZone(Canvas canvas) {
    // Workplace Lobby & Open Desk (x: 1120 .. 1520)
    final officeWall = Paint()..color = const Color(0xFF064E3B);
    canvas.drawRect(const Rect.fromLTWH(1150, 80, 330, 190), officeWall);

    // Workstation Desk & Computer
    final deskPaint = Paint()..color = const Color(0xFF047857);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1210, 210, 130, 60), const Radius.circular(6)), deskPaint);

    final monitorPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRect(const Rect.fromLTWH(1250, 175, 50, 35), monitorPaint);

    // Potted Plant
    final plantPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(1410, 230), 20, plantPaint);
  }

  void _renderExecutiveSuiteZone(Canvas canvas) {
    // Floor 2 Executive Suite (x: 1520 .. 1900)
    final execWall = Paint()..color = const Color(0xFF2E1065);
    canvas.drawRect(const Rect.fromLTWH(1550, 70, 320, 200), execWall);

    // Conference Table
    final tablePaint = Paint()..color = const Color(0xFF6B21A8);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1600, 215, 180, 55), const Radius.circular(10)), tablePaint);

    // Presentation Screen
    final screenPaint = Paint()..color = const Color(0xFFA855F7).withValues(alpha: 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1640, 95, 110, 70), const Radius.circular(6)), screenPaint);
  }

  void _renderPlayer(Canvas canvas, double x, double groundY) {
    canvas.save();
    canvas.translate(x, groundY);
    if (!facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    final swing = isMoving ? math.sin(walkCycle) * 10 : 0.0;

    // Legs
    final legPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 5..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-4, -18), Offset(-4 + swing, 0), legPaint);
    canvas.drawLine(const Offset(4, -18), Offset(4 - swing, 0), legPaint);

    // Body (Jacket)
    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -42, 18, 26), const Radius.circular(6)), bodyPaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(0, -50), 10, headPaint);

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawArc(const Rect.fromLTWH(-10, -60, 20, 16), math.pi, math.pi, true, hairPaint);

    // Briefcase / Bag
    final bagPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, -32, 10, 14), const Radius.circular(2)), bagPaint);

    canvas.restore();
  }
}
