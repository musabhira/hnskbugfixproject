import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_citadel_challenge_generator.dart';

/// 🛡️ Curated Educational Defense Shield Configuration Modal
/// Audio Directive:
/// "മാനുവലി ഇനി ഡിഫൻസ് ആഡ് ചെയ്യലൊന്നും ഇല്ല. ക്വസ്റ്റ്യൻസ് അവരെന്നെ ടൈപ്പ് ചെയ്ത് ആഡ് ചെയ്യേണ്ട...
/// അപ്പൊ അവർക്ക് ഒരുപാട് ഓപ്ഷൻസ് ഉണ്ടാകും. Sentence Builder, Spelling, Spoken, Verb, MCQ...
/// ഒരു 10-15 എണ്ണം ഗെയിമുകൾ ഉണ്ടാകും. ഇതിൽ അവർക്ക് ഏതാണോ വേണ്ടത് എന്ന് പറഞ്ഞാൽ സെലക്ട് ചെയ്യാം.
/// സെലക്ട് ചെയ്തിട്ട് ആഡ് ഡിഫൻസ് എന്ന ബട്ടൺ ടാപ്പ് ചെയ്തു കഴിഞ്ഞാൽ അവരുടെ ആഡ് ആകും...
/// പിന്നെ ചോദിക്കണം, ഹാർഡ് വേണോ സിമ്പിൾ വേണോ എന്നുള്ള ഒരു ഇത് കൊടുക്കണം കേട്ടോ.
/// ബ്രൈറ്റ്‌നസ്സ് ഒക്കെ അഡ്ജസ്റ്റ് ചെയ്യുന്നത് പോലെ ഒരു സാധനം കൊടുത്താൽ മതി."
class PocketDefenseTrapModal extends StatefulWidget {
  final int userDay;
  final HouseShieldQuestion? editingQuestion;
  final bool isLevelComplete;
  final int? initialDaySlot;

  const PocketDefenseTrapModal({
    super.key,
    required this.userDay,
    this.editingQuestion,
    this.isLevelComplete = false,
    this.initialDaySlot,
  });

  static Future<void> show(
    BuildContext context,
    int userDay, {
    HouseShieldQuestion? editingQuestion,
    bool isLevelComplete = false,
    int? targetDay,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PocketDefenseTrapModal(
        userDay: userDay,
        editingQuestion: editingQuestion,
        isLevelComplete: isLevelComplete,
        initialDaySlot: targetDay,
      ),
    );
  }

  static Future<void> showShieldUnlockPrompt(
    BuildContext context, {
    required int day,
    int? coins,
  }) =>
      show(context, day, isLevelComplete: true);

  @override
  State<PocketDefenseTrapModal> createState() => _PocketDefenseTrapModalState();
}

class _PocketDefenseTrapModalState extends State<PocketDefenseTrapModal> {
  List<HouseShieldQuestion> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  late int _selectedDay;
  String _selectedGameFormat = 'sentence_builder';
  double _difficultyValue = 1.0; // 0.0=Easy, 1.0=Normal, 2.0=Hard
  HouseShieldQuestion? _previewQuestion;

  String get _difficultyString {
    if (_difficultyValue <= 0.4) return 'easy';
    if (_difficultyValue >= 1.6) return 'hard';
    return 'normal';
  }

  String get _difficultyLabel {
    switch (_difficultyString) {
      case 'easy':
        return '🟢 Simple / Easy • ലളിതം';
      case 'hard':
        return '🔴 Hard / Master • കഠിനം';
      case 'normal':
      default:
        return '🟡 Normal / Medium • ഇടത്തരം';
    }
  }

  Color get _difficultyColor {
    switch (_difficultyString) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'hard':
        return const Color(0xFFF43F5E);
      case 'normal':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDaySlot ?? widget.userDay.clamp(1, 90);
    _loadExistingQuestions();
  }

  Future<void> _loadExistingQuestions() async {
    setState(() => _isLoading = true);
    final loaded = await PocketFortressDefenseService.loadShieldQuestions(widget.userDay);
    if (!mounted) return;

    setState(() {
      _questions = List.from(loaded);
      _isLoading = false;

      // If editing a specific question, pre-fill settings from it
      if (widget.editingQuestion != null) {
        final idx = _questions.indexWhere((q) => q.id == widget.editingQuestion!.id);
        if (idx >= 0) {
          _selectedDay = idx + 1;
        }
        _selectedGameFormat = widget.editingQuestion!.gameFormat;
        if (widget.editingQuestion!.difficulty == 'easy') {
          _difficultyValue = 0.0;
        } else if (widget.editingQuestion!.difficulty == 'hard') {
          _difficultyValue = 2.0;
        } else {
          _difficultyValue = 1.0;
        }
      } else if (_selectedDay - 1 < _questions.length) {
        final existing = _questions[_selectedDay - 1];
        _selectedGameFormat = existing.gameFormat;
        if (existing.difficulty == 'easy') {
          _difficultyValue = 0.0;
        } else if (existing.difficulty == 'hard') {
          _difficultyValue = 2.0;
        } else {
          _difficultyValue = 1.0;
        }
      }

      _refreshPreview();
    });
  }

  void _refreshPreview() {
    setState(() {
      _previewQuestion = PocketCitadelChallengeGenerator.buildChallengeForFormat(
        format: _selectedGameFormat,
        day: _selectedDay,
        difficulty: _difficultyString,
      );
    });
  }

  Future<void> _onSaveDefense() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.heavyImpact();

    final newDefense = _previewQuestion ??
        PocketCitadelChallengeGenerator.buildChallengeForFormat(
          format: _selectedGameFormat,
          day: _selectedDay,
          difficulty: _difficultyString,
        );

    final targetIdx = _selectedDay - 1;
    while (_questions.length <= targetIdx) {
      final padDay = _questions.length + 1;
      _questions.add(
        PocketCitadelChallengeGenerator.buildChallengeForFormat(
          format: 'sentence_builder',
          day: padDay,
        ),
      );
    }
    _questions[targetIdx] = newDefense;

    await PocketFortressDefenseService.saveShieldQuestions(_questions);

    if (!mounted) return;
    setState(() => _isSaving = false);

    final gameInfo = PocketCitadelChallengeGenerator.getGameInfo(_selectedGameFormat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(gameInfo.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Day $_selectedDay Defense Armed with ${gameInfo.title} (${_difficultyString.toUpperCase()})!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // If reached from a single slot edit, pop; otherwise stay to allow arming other slots
    if (widget.editingQuestion != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDay = math.max(1, widget.userDay.clamp(1, 90));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                      ),
                      child: const Text('🛡️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fortress Defense Station',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'ഡിഫൻസ് ഗെയിമും കാഠിന്യവും തിരഞ്ഞെടുക്കുക (Zero Errors)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Day Slot Selector
                        Row(
                          children: [
                            Text(
                              '📍 DEFENSE DAY SLOT (1–$maxDay)',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Day $_selectedDay Selected',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: maxDay,
                            itemBuilder: (context, idx) {
                              final dayNum = idx + 1;
                              final isSel = dayNum == _selectedDay;
                              final isArmed = idx < _questions.length;
                              final armedFormat = isArmed ? _questions[idx].gameFormat : null;
                              final armedIcon = armedFormat != null
                                  ? PocketCitadelChallengeGenerator.getGameInfo(armedFormat).icon
                                  : null;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedDay = dayNum;
                                    if (idx < _questions.length) {
                                      _selectedGameFormat = _questions[idx].gameFormat;
                                      if (_questions[idx].difficulty == 'easy') {
                                        _difficultyValue = 0.0;
                                      } else if (_questions[idx].difficulty == 'hard') {
                                        _difficultyValue = 2.0;
                                      } else {
                                        _difficultyValue = 1.0;
                                      }
                                    }
                                    _refreshPreview();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? const Color(0xFF0284C7)
                                        : (isArmed ? const Color(0xFF1E293B) : const Color(0xFF0F172A)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? const Color(0xFF38BDF8)
                                          : (isArmed ? Colors.white24 : Colors.white10),
                                      width: isSel ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (armedIcon != null) ...[
                                        Text(armedIcon, style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        'Day $dayNum',
                                        style: GoogleFonts.outfit(
                                          color: isSel ? Colors.white : (isArmed ? Colors.white70 : Colors.white38),
                                          fontSize: 12,
                                          fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. Curated Game Types Grid (12 Educational Arcade Games)
                        Text(
                          '🎮 CHOOSE DEFENSE GAME (12 OPTIONS)',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: PocketCitadelChallengeGenerator.availableGameTypes.length,
                          itemBuilder: (context, idx) {
                            final g = PocketCitadelChallengeGenerator.availableGameTypes[idx];
                            final isSel = g.id == _selectedGameFormat;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedGameFormat = g.id;
                                  _refreshPreview();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFFFFD700) : Colors.white12,
                                    width: isSel ? 2.0 : 1.0,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(g.icon, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 4),
                                    Text(
                                      g.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        color: isSel ? const Color(0xFFFFD700) : Colors.white,
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      g.titleMl,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white54,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // 3. Brightness-Style Difficulty Slider
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _difficultyColor.withValues(alpha: 0.5), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.tune_rounded, color: Colors.white70, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'DIFFICULTY SLIDER',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _difficultyColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _difficultyColor, width: 1),
                                    ),
                                    child: Text(
                                      _difficultyLabel,
                                      style: GoogleFonts.outfit(
                                        color: _difficultyColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: _difficultyColor,
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: _difficultyColor,
                                  overlayColor: _difficultyColor.withValues(alpha: 0.2),
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                ),
                                child: Slider(
                                  value: _difficultyValue,
                                  min: 0.0,
                                  max: 2.0,
                                  divisions: 2,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _difficultyValue = val;
                                      _refreshPreview();
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Simple (ലളിതം)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                                  Text('Normal (ഇടത്തരം)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                                  Text('Hard (കഠിനം)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Live Interactive Preview Card
                        if (_previewQuestion != null) ...[
                          Text(
                            '👁️ LIVE DEFENSE PREVIEW (DAY $_selectedDay)',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF131D2D), Color(0xFF0F172A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                                      ),
                                      child: Text(
                                        PocketCitadelChallengeGenerator.getGameInfo(_selectedGameFormat).title,
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF38BDF8),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text('✅ Curated 100% Accurate', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _previewQuestion!.question,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('🔑 ', style: TextStyle(fontSize: 12)),
                                      Expanded(
                                        child: Text(
                                          'Correct Target: "${_previewQuestion!.explanation}"',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFD700),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Bottom "ADD DEFENSE" Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSaving ? null : _onSaveDefense,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🛡️', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'ADD DEFENSE • ഡേ $_selectedDay ഡിഫൻസ് ആക്കുക',
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
