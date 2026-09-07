import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceAccentCoachPage extends StatefulWidget {
  const VoiceAccentCoachPage({super.key});

  @override
  State<VoiceAccentCoachPage> createState() => _VoiceAccentCoachPageState();
}

class _VoiceAccentCoachPageState extends State<VoiceAccentCoachPage> {
  final FlutterTts _tts = FlutterTts();
  int _selectedCategoryIndex = 0;
  int _currentSentenceIndex = 0;
  bool _isPlaying = false;
  bool _isListening = false;
  bool _showFeedback = false;
  int _lastScore = 94;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Daily Habits & Routines',
      'icon': Icons.alarm_rounded,
      'color': const Color(0xFF00E5FF),
      'drills': [
        {
          'text': 'I always wake up early and prioritize my morning routine.',
          'phonetic': '/aɪ ˈɔːl.weɪz weɪk ʌp ˈɜː.li ænd praɪˈɒr.ɪ.taɪz maɪ ˈmɔː.nɪŋ ruːˈtiːn/',
          'focus': 'Stress "always" and connect "wake up" into /weɪ-kʌp/.',
        },
        {
          'text': 'She seldom skips breakfast because she needs steady energy.',
          'phonetic': '/ʃiː ˈsel.dəm skɪps ˈbrek.fəst bɪˈkɒz ʃiː niːdz ˈsted.i ˈen.ə.dʒi/',
          'focus': 'Clear /s/ sound at the start of "seldom" and "skips".',
        },
        {
          'text': 'We frequently discuss our daily goals during the morning standup.',
          'phonetic': '/wiː ˈfriː.kwənt.li dɪˈskʌs ˈaʊər ˈdeɪ.li ɡəʊlz ˈdjʊə.rɪŋ ðə ˈmɔː.nɪŋ ˈstænd.ʌp/',
          'focus': 'Soft /ð/ sound on "the" and sharp /p/ on "standup".',
        },
      ],
    },
    {
      'name': 'Everyday Small Talk',
      'icon': Icons.forum_rounded,
      'color': const Color(0xFF10B981),
      'drills': [
        {
          'text': 'It is fantastic catching up with you after such a long time.',
          'phonetic': '/ɪt ɪz fænˈtæs.tɪk ˈkætʃ.ɪŋ ʌp wɪð juː ˈɑːf.tər sʌtʃ ə lɒŋ taɪm/',
          'focus': 'Natural rising intonation on "catching up".',
        },
        {
          'text': 'Could you please let me know when the next session starts?',
          'phonetic': '/kʊd juː pliːz let miː nəʊ wen ðə nekst ˈseʃ.ən stɑːts/',
          'focus': 'Polite downward melody on "starts".',
        },
        {
          'text': 'I completely agree with your perspective on that matter.',
          'phonetic': '/aɪ kəmˈpliːt.li əˈɡriː wɪð jɔː pəˈspek.tɪv ɒn ðæt ˈmæt.ər/',
          'focus': 'Liaison: connect "that matter" smoothly.',
        },
      ],
    },
    {
      'name': 'Work & Interviews',
      'icon': Icons.business_center_rounded,
      'color': const Color(0xFFFFD700),
      'drills': [
        {
          'text': 'My primary strength is solving complex challenges under tight deadlines.',
          'phonetic': '/maɪ ˈpraɪ.mə.ri streŋθ ɪz ˈsɒl.vɪŋ ˈkɒm.pleks ˈtʃæl.ɪn.dʒɪz ˈʌn.dər taɪt ˈded.laɪnz/',
          'focus': 'Emphasize "primary strength" with measured pace.',
        },
        {
          'text': 'I have led cross-functional teams to deliver scalable software solutions.',
          'phonetic': '/aɪ hæv led krɒs ˈfʌŋk.ʃən.əl tiːmz tuː dɪˈlɪv.ər ˈskeɪ.lə.bəl ˈsɒft.weər səˈluː.ʃənz/',
          'focus': 'Strong crisp articulation on "scalable solutions".',
        },
      ],
    },
    {
      'name': 'Tongue Twisters',
      'icon': Icons.speed_rounded,
      'color': const Color(0xFFFF5722),
      'drills': [
        {
          'text': 'She sells sea shells by the sea shore.',
          'phonetic': '/ʃiː selz siː ʃelz baɪ ðə siː ʃɔːr/',
          'focus': 'Switch smoothly between /s/ and /ʃ/ sounds without pausing.',
        },
        {
          'text': 'How can a clam cram in a clean cream can?',
          'phonetic': '/haʊ kæn ə klæm kræm ɪn ə kliːn kriːm kæn/',
          'focus': 'Crisp /cl/ versus /cr/ consonant cluster agility.',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.48);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Map<String, dynamic> get _currentDrill {
    final drills = _categories[_selectedCategoryIndex]['drills'] as List;
    if (_currentSentenceIndex >= drills.length) {
      _currentSentenceIndex = 0;
    }
    return drills[_currentSentenceIndex] as Map<String, dynamic>;
  }

  void _speak({bool slow = false}) async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);
    await _tts.setSpeechRate(slow ? 0.32 : 0.48);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    await _tts.speak(_currentDrill['text'] as String);
  }

  void _simulateSpeakingPractice() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _showFeedback = false;
    });

    // Simulated speech recognition / accent scoring interval
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    setState(() {
      _isListening = false;
      _showFeedback = true;
      _lastScore = 92 + (_currentSentenceIndex % 7);
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final cat = _categories[_selectedCategoryIndex];
    final drill = _currentDrill;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1015),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Voice & Accent Coach',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Pronunciation & Spoken Rhythm Trainer',
              style: GoogleFonts.inter(color: const Color(0xFF00E5FF), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final c = _categories[i];
                  final isSel = i == _selectedCategoryIndex;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategoryIndex = i;
                        _currentSentenceIndex = 0;
                        _showFeedback = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? (c['color'] as Color).withValues(alpha: 0.15) : const Color(0xFF13172A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? (c['color'] as Color) : Colors.white10,
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(c['icon'] as IconData, color: isSel ? (c['color'] as Color) : Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            c['name'] as String,
                            style: GoogleFonts.outfit(
                              color: isSel ? Colors.white : Colors.white60,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Drill Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF13172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (cat['color'] as Color).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DRILL ${_currentSentenceIndex + 1} OF ${(cat['drills'] as List).length}',
                          style: GoogleFonts.outfit(
                            color: cat['color'] as Color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white70),
                        tooltip: 'Next Sentence',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            final drills = cat['drills'] as List;
                            _currentSentenceIndex = (_currentSentenceIndex + 1) % drills.length;
                            _showFeedback = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Target Sentence
                  Text(
                    drill['text'] as String,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Phonetic Transcription
                  Text(
                    drill['phonetic'] as String,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00E5FF),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Articulation Focus Tip
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            drill['focus'] as String,
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Playback Audio Controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _speak(slow: true),
                          icon: const Icon(Icons.slow_motion_video_rounded, size: 16, color: Color(0xFF00E5FF)),
                          label: Text(
                            'SLOW (0.35x)',
                            style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00E5FF)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _speak(slow: false),
                          icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 16, color: Colors.black),
                          label: Text(
                            _isPlaying ? 'STOP' : 'LISTEN',
                            style: GoogleFonts.outfit(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Speaking Drill Practice & Instant Feedback
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF13172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Practice Speaking Aloud',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap microphone and speak sentence clearly into the mic',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5),
                  ),
                  const SizedBox(height: 16),

                  // Mic Button with Animated Ripple
                  GestureDetector(
                    onTap: _isListening ? null : _simulateSpeakingPractice,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [Colors.redAccent, const Color(0xFFFF8906)]
                              : [const Color(0xFF00E5FF), const Color(0xFF3B82F6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.redAccent : const Color(0xFF00E5FF)).withValues(alpha: 0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isListening ? 'Analyzing pronunciation & pitch...' : 'TAP TO RECORD & EVALUATE',
                    style: GoogleFonts.outfit(
                      color: _isListening ? const Color(0xFFFF8906) : Colors.white60,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Real-Time Evaluation Result
                  if (_showFeedback) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fluency Match: $_lastScore%',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Excellent pace and tone! Word linkage and vowel stress are on point.',
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
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
          ],
        ),
      ),
    );
  }
}
