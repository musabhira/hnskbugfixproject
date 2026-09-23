import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_fluency_gym_data.dart';
import 'pocket_fluency_gym_detail_page.dart';

/// 🏛️ Pocket Fluency Gym Card (All-in-One Multi-Skill Vocal Training Arena)
/// Incorporates the 8 core vocal pillars requested:
/// 1. 👅 Tongue Twisters & Speed Challenge
/// 2. 🎵 Word Stress & Rhythm Metronome
/// 3. 🌊 Connected Speech & Sound Drilling
/// 4. 🎭 Conversation Starter & Roleplay
/// 5. 🎙️ Shadowing, Read Along & Speed Read
/// 6. 🚫 Filler Word Elimination
/// 7. 🖼️ Situation / Picture Description
/// 8. 🎧 Dictation & Fill The Gap
class PocketFluencyGymCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketFluencyGymCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '4',
  });

  @override
  State<PocketFluencyGymCard> createState() => _PocketFluencyGymCardState();
}

class _PocketFluencyGymCardState extends State<PocketFluencyGymCard>
    with SingleTickerProviderStateMixin {
  late PocketFluencyGymDayData _data;
  final FlutterTts _tts = FlutterTts();

  // Active section tab index (0: Twister, 1: Stress & Rhythm, 2: Connected Speech, 3: Roleplay, 4: Shadowing, 5: Fillers, 6: Picture/Situation, 7: Dictation)
  int _activeTabIndex = 0;

  // Speed Challenge Timer
  Timer? _challengeTimer;
  int _challengeRemainingSeconds = 0;
  bool _isChallengeRunning = false;
  bool _isChallengeSucceeded = false;

  // Dictation state
  final TextEditingController _dictationController = TextEditingController();
  bool? _isDictationCorrect;

  @override
  void initState() {
    super.initState();
    _data = PocketFluencyGymRegistry.getDataForDay(widget.day);
    _initTts();
  }

  @override
  void didUpdateWidget(covariant PocketFluencyGymCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      _data = PocketFluencyGymRegistry.getDataForDay(widget.day);
      _dictationController.clear();
      _isDictationCorrect = null;
      _stopChallenge();
    }
  }

  @override
  void dispose() {
    _challengeTimer?.cancel();
    _dictationController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakText(String text, {double rate = 0.48}) async {
    HapticFeedback.lightImpact();
    if (widget.onSpeak != null) {
      widget.onSpeak!(text);
      return;
    }
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startSpeedChallenge() {
    HapticFeedback.mediumImpact();
    setState(() {
      _challengeRemainingSeconds = _data.tongueTwisterTargetSeconds;
      _isChallengeRunning = true;
      _isChallengeSucceeded = false;
    });

    _challengeTimer?.cancel();
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_challengeRemainingSeconds > 1) {
        setState(() {
          _challengeRemainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _challengeRemainingSeconds = 0;
          _isChallengeRunning = false;
          _isChallengeSucceeded = true;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _stopChallenge() {
    _challengeTimer?.cancel();
    _challengeTimer = null;
    if (mounted) {
      setState(() {
        _isChallengeRunning = false;
        _challengeRemainingSeconds = 0;
      });
    }
  }

  void _verifyDictation() {
    final input = _dictationController.text.trim().toLowerCase();
    final expected = _data.dictationAnswer.trim().toLowerCase();
    final correct = input == expected;
    HapticFeedback.mediumImpact();
    setState(() {
      _isDictationCorrect = correct;
    });
    if (correct && !widget.isCompleted) {
      widget.onCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏆 Card Header
          _buildHeader(),

          // 🎛️ Navigation Pills (Multi-Skill Tabs)
          _buildTabPills(),

          const Divider(color: Colors.white10, height: 1),

          // 🎯 Interactive Body based on active tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildActiveTabContent(),
          ),

          // ⚡ Footer Action / Mark Completed Button
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text('🎙️', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP ${widget.stepNumber} • FLUENCY GYM',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF38BDF8),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'VERIFIED',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        PocketFluencyGymDetailPage.open(
                          context,
                          day: widget.day,
                          selectedLanguage: widget.selectedLanguage,
                          isInitiallyCompleted: widget.isCompleted,
                          onCompleted: widget.onCompleted,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'OPEN ARENA',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.open_in_new_rounded,
                                size: 12, color: Color(0xFF10B981)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _data.dayTheme,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPills() {
    final tabs = [
      {'icon': '👅', 'label': 'Twister'},
      {'icon': '🎵', 'label': 'Stress'},
      {'icon': '🌊', 'label': 'Linking'},
      {'icon': '🎭', 'label': 'Roleplay'},
      {'icon': '🎙️', 'label': 'Shadow'},
      {'icon': '🚫', 'label': 'Fillers'},
      {'icon': '🖼️', 'label': 'Picture'},
      {'icon': '🎧', 'label': 'Dictation'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _activeTabIndex == index;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _activeTabIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Text(tabs[index]['icon']!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    tabs[index]['label']!,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildTongueTwisterSection();
      case 1:
        return _buildWordStressSection();
      case 2:
        return _buildConnectedSpeechSection();
      case 3:
        return _buildRoleplaySection();
      case 4:
        return _buildShadowingSection();
      case 5:
        return _buildFillerWordsSection();
      case 6:
        return _buildPictureDescriptionSection();
      case 7:
        return _buildDictationSection();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. 👅 TONGUE TWISTER & SPEED CHALLENGE
  Widget _buildTongueTwisterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'TARGET: ${_data.tongueTwisterTargetSound}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF472B6),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
              tooltip: 'Listen Normal',
              onPressed: () => _speakText(_data.tongueTwister, rate: 0.45),
            ),
            IconButton(
              icon: const Icon(Icons.speed_rounded, color: Color(0xFFEC4899)),
              tooltip: 'Listen Native Fast',
              onPressed: () => _speakText(_data.tongueTwister, rate: 0.65),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
          ),
          child: Text(
            '"${_data.tongueTwister}"',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _data.tongueTwisterTipMl,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Speed Challenge Button
        Center(
          child: ElevatedButton.icon(
            onPressed: _isChallengeRunning ? _stopChallenge : _startSpeedChallenge,
            icon: Icon(
              _isChallengeRunning ? Icons.stop_rounded : Icons.timer_outlined,
              color: Colors.white,
            ),
            label: Text(
              _isChallengeRunning
                  ? 'STOPPING (${_challengeRemainingSeconds}s REMAINING)'
                  : (_isChallengeSucceeded
                      ? '⚡ CHALLENGE WON! TAP TO RETRY'
                      : '⚡ START ${_data.tongueTwisterTargetSeconds}s SPEED CHALLENGE'),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isChallengeRunning
                  ? Colors.redAccent
                  : (_isChallengeSucceeded ? const Color(0xFF10B981) : const Color(0xFFEC4899)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // 2. 🎵 WORD STRESS & RHYTHM METRONOME
  Widget _buildWordStressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _data.wordStressFocus,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _data.rhythmRule,
          style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 12),
        ..._data.wordStressPairs.map((pair) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair.primaryWord,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pair.phoneticStress,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pair.explanation,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Color(0xFFFBBF24)),
                  onPressed: () => _speakText(pair.primaryWord, rate: 0.4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 3. 🌊 CONNECTED SPEECH & MINIMAL PAIRS
  Widget _buildConnectedSpeechSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _data.connectedSpeechTitle,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2DD4BF),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WRITTEN ENGLISH',
                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_data.writtenForm, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF2DD4BF), size: 20),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF134E4A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SPOKEN LINKED',
                        style: GoogleFonts.outfit(fontSize: 10, color: Color(0xFF5EEAD4), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_data.spokenForm,
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _data.soundClinicTipMl,
          style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 12),
        Text('MINIMAL PAIR DRILLS',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2DD4BF))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _data.minimalPairs.map((pair) {
            return InkWell(
              onTap: () => _speakText(pair),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up, size: 14, color: Color(0xFF2DD4BF)),
                    const SizedBox(width: 6),
                    Text(pair, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 4. 🎭 CONVERSATION STARTER & ROLEPLAY
  Widget _buildRoleplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFA855F7).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'SCENARIO: ${_data.roleplayScenario}',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC084FC),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Partner Line
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('👤', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PARTNER SPEAKS:',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                    const SizedBox(height: 2),
                    Text(
                      '"${_data.partnerLine}"',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFFA855F7)),
                onPressed: () => _speakText(_data.partnerLine),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Your Turn Prompt
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B0764).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR MISSION:',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC))),
              const SizedBox(height: 4),
              Text(_data.yourPrompt, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 8),
              Text('SUGGESTED RESPONSE:',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF4ADE80))),
              const SizedBox(height: 2),
              Text(
                '"${_data.suggestedResponse}"',
                style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF4ADE80), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. 🎙️ SHADOWING & SPEED READ
  Widget _buildShadowingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('NATIVE SHADOWING PASSAGE',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
            const Spacer(),
            Text('0.8x', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
            IconButton(
              icon: const Icon(Icons.slow_motion_video_rounded, color: Color(0xFF38BDF8), size: 20),
              onPressed: () => _speakText(_data.shadowingPassage, rate: 0.38),
            ),
            Text('1.0x', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
            IconButton(
              icon: const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF10B981), size: 22),
              onPressed: () => _speakText(_data.shadowingPassage, rate: 0.48),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            _data.shadowingPassage,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, height: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '💡 Pacing Tip: ${_data.shadowingPacingTip}',
          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // 6. 🚫 FILLER WORDS ELIMINATION
  Widget _buildFillerWordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STRATEGIC PAUSING & FILLER ELIMINATION',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFF97316)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF431407).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('❌', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMMON HESITATION TRAP:',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 2),
                    Text(_data.fillerWordTrap, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONFIDENT REPLACEMENT:',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                    const SizedBox(height: 2),
                    Text(_data.confidentReplacement, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. 🖼️ PICTURE / SITUATION DESCRIPTION
  Widget _buildPictureDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _data.situationTitle,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF38BDF8)),
              onPressed: () => _speakText(_data.situationDescription),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _data.situationDescription,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, height: 1.4),
          ),
        ),
        const SizedBox(height: 10),
        Text('POWER KEYWORDS TO USE:',
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _data.powerKeywords.map((kw) {
            return Chip(
              backgroundColor: const Color(0xFF0F172A),
              label: Text(kw, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFFBBF24))),
              side: const BorderSide(color: Color(0xFFFBBF24), width: 0.5),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 8. 🎧 DICTATION & FILL THE GAP
  Widget _buildDictationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('LISTEN & FILL IN THE MISSING WORD',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _speakText(_data.dictationAudioSentence, rate: 0.42),
              icon: const Icon(Icons.volume_up_rounded, size: 16),
              label: const Text('LISTEN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _data.dictationPromptWithBlank,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dictationController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type missing word...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _verifyDictation(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _verifyDictation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('CHECK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        if (_isDictationCorrect != null) ...[
          const SizedBox(height: 8),
          Text(
            _isDictationCorrect! ? '🎉 Correct! Well done.' : '❌ Try again! Listen carefully.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _isDictationCorrect! ? const Color(0xFF10B981) : Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Text(
            'Practice 2+ drills to verify',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              PocketFluencyGymDetailPage.open(
                context,
                day: widget.day,
                selectedLanguage: widget.selectedLanguage,
                isInitiallyCompleted: widget.isCompleted,
                onCompleted: widget.onCompleted,
              );
            },
            icon: const Icon(Icons.fullscreen_rounded, size: 16),
            label: Text(
              'FULL ARENA 🎙️',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              widget.onCompleted(!widget.isCompleted);
            },
            icon: Icon(
              widget.isCompleted ? Icons.check_circle : Icons.sports_score_rounded,
              size: 16,
            ),
            label: Text(
              widget.isCompleted ? 'VERIFIED ✓' : 'MARK DRILL COMPLETED',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isCompleted ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
              foregroundColor: widget.isCompleted ? Colors.white : const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
