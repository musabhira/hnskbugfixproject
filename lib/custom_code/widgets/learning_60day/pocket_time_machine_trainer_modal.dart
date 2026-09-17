import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

/// ⏳ Model for Past, Present & Future Verb Trio
class TimeMachineVerbItem {
  final String baseVerb;
  final String meaningMl;
  final String pastForm;
  final String presentForm;
  final String futureForm;
  final String pastSentence;
  final String presentSentence;
  final String futureSentence;
  final String didQuestion;
  final String commonTrapMl;

  const TimeMachineVerbItem({
    required this.baseVerb,
    required this.meaningMl,
    required this.pastForm,
    required this.presentForm,
    required this.futureForm,
    required this.pastSentence,
    required this.presentSentence,
    required this.futureSentence,
    required this.didQuestion,
    required this.commonTrapMl,
  });
}

/// 📚 The 20 Essential Daily Action Verbs for Spoken Fluency
const List<TimeMachineVerbItem> kTimeMachineVerbs = [
  TimeMachineVerbItem(
    baseVerb: 'Go',
    meaningMl: 'പോകുക',
    pastForm: 'Went',
    presentForm: 'Go / Goes',
    futureForm: 'Will go',
    pastSentence: 'Yesterday, I went to the city center for an interview.',
    presentSentence: 'Every morning, I go for a refreshing morning walk.',
    futureSentence: 'Tomorrow, I will go to the office early.',
    didQuestion: 'Did you go there yesterday?',
    commonTrapMl: '❌ "Did you went?" എന്ന് പറയരുത്! Did വന്നാൽ "go" എന്ന് മാത്രമേ പറയാവൂ.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'See',
    meaningMl: 'കാണുക',
    pastForm: 'Saw',
    presentForm: 'See / Sees',
    futureForm: 'Will see',
    pastSentence: 'I saw an insightful documentary on technology last night.',
    presentSentence: 'I see positive changes in my English confidence daily.',
    futureSentence: 'I will see you at the presentation tomorrow.',
    didQuestion: 'Did you see that important notification?',
    commonTrapMl: '❌ "Did you saw?" തെറ്റാണ്. ✅ "Did you see?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Do',
    meaningMl: 'ചെയ്യുക',
    pastForm: 'Did',
    presentForm: 'Do / Does',
    futureForm: 'Will do',
    pastSentence: 'I did all my learning assignments before sleeping.',
    presentSentence: 'I do thirty minutes of speaking practice every day.',
    futureSentence: 'I will do my best during the job interview.',
    didQuestion: 'Did you do the daily English mission?',
    commonTrapMl: '❌ "Did you did it?" തെറ്റാണ്. ✅ "Did you do it?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Eat',
    meaningMl: 'ഭക്ഷണം കഴിക്കുക',
    pastForm: 'Ate',
    presentForm: 'Eat / Eats',
    futureForm: 'Will eat',
    pastSentence: 'I ate a light, healthy breakfast this morning.',
    presentSentence: 'I usually eat lunch with my colleagues at one PM.',
    futureSentence: 'I will eat dinner after completing my study session.',
    didQuestion: 'Did you eat lunch already?',
    commonTrapMl: '❌ "Did you ate?" പറയരുത്. ✅ "Did you eat?" എന്ന് പറയുക.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Buy',
    meaningMl: 'വാങ്ങുക',
    pastForm: 'Bought',
    presentForm: 'Buy / Buys',
    futureForm: 'Will buy',
    pastSentence: 'I bought a great self-development book last weekend.',
    presentSentence: 'I buy fresh groceries from the local market.',
    futureSentence: 'I will buy a new laptop once I graduate.',
    didQuestion: 'Did you buy the ticket online?',
    commonTrapMl: '❌ "Did you bought?" തെറ്റാണ്. ✅ "Did you buy?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Tell',
    meaningMl: 'പറയുക / അറിയിക്കുക',
    pastForm: 'Told',
    presentForm: 'Tell / Tells',
    futureForm: 'Will tell',
    pastSentence: 'My mentor told me to focus on active speaking.',
    presentSentence: 'I always tell the truth in my professional dealings.',
    futureSentence: 'I will tell you the good news as soon as I hear it.',
    didQuestion: 'Did he tell you about the scheduled meeting?',
    commonTrapMl: '❌ "Did he told you?" തെറ്റാണ്. ✅ "Did he tell you?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Take',
    meaningMl: 'എടുക്കുക / സമയം എടുക്കുക',
    pastForm: 'Took',
    presentForm: 'Take / Takes',
    futureForm: 'Will take',
    pastSentence: 'It took me two hours to solve the coding problem.',
    presentSentence: 'I take notes whenever I learn a new English phrase.',
    futureSentence: 'I will take immediate action to improve my skills.',
    didQuestion: 'Did you take your medicine on time?',
    commonTrapMl: '❌ "Did you took?" തെറ്റാണ്. ✅ "Did you take?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Speak',
    meaningMl: 'സംസാരിക്കുക',
    pastForm: 'Spoke',
    presentForm: 'Speak / Speaks',
    futureForm: 'Will speak',
    pastSentence: 'I spoke with a fluent partner in the English Arena yesterday.',
    presentSentence: 'I speak clearly and concisely during team meetings.',
    futureSentence: 'I will speak with natural authority and poise.',
    didQuestion: 'Did you speak to the manager directly?',
    commonTrapMl: '❌ "Did you spoke?" തെറ്റാണ്. ✅ "Did you speak?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Meet',
    meaningMl: 'കണ്ടുമുട്ടുക',
    pastForm: 'Met',
    presentForm: 'Meet / Meets',
    futureForm: 'Will meet',
    pastSentence: 'I met an inspiring software architect at the conference.',
    presentSentence: 'We meet every evening to practice conversation.',
    futureSentence: 'I will meet our new international client on Monday.',
    didQuestion: 'Did you meet the new team members?',
    commonTrapMl: '❌ "Did you met?" തെറ്റാണ്. ✅ "Did you meet?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Make',
    meaningMl: 'ഉണ്ടാക്കുക / നിർമ്മിക്കുക',
    pastForm: 'Made',
    presentForm: 'Make / Makes',
    futureForm: 'Will make',
    pastSentence: 'I made steady progress in pronunciation this week.',
    presentSentence: 'I make a comprehensive to-do list every morning.',
    futureSentence: 'I will make a lasting impression in my interview.',
    didQuestion: 'Did you make that presentation by yourself?',
    commonTrapMl: '❌ "Did you made?" തെറ്റാണ്. ✅ "Did you make?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Come',
    meaningMl: 'വരുക',
    pastForm: 'Came',
    presentForm: 'Come / Comes',
    futureForm: 'Will come',
    pastSentence: 'My friend came over to study English grammar with me.',
    presentSentence: 'Great ideas come when we maintain daily discipline.',
    futureSentence: 'Success will come through unbroken daily effort.',
    didQuestion: 'Did the package come in the mail?',
    commonTrapMl: '❌ "Did it came?" തെറ്റാണ്. ✅ "Did it come?" ശരി.',
  ),
  TimeMachineVerbItem(
    baseVerb: 'Write',
    meaningMl: 'എഴുതുക',
    pastForm: 'Wrote',
    presentForm: 'Write / Writes',
    futureForm: 'Will write',
    pastSentence: 'I wrote a formal follow-up email to the interviewer.',
    presentSentence: 'I write my personal reflections in English daily.',
    futureSentence: 'I will write a complete project proposal by Friday.',
    didQuestion: 'Did you write down the key bullet points?',
    commonTrapMl: '❌ "Did you wrote?" തെറ്റാണ്. ✅ "Did you write?" ശരി.',
  ),
];

/// ⏳ POCKET TIME MACHINE: Interactive Past vs Present vs Future Trainer
/// User Audio Request: "പാസ്റ്റ്, പ്രസന്റ് അതൊക്കെ ആഡ് ചെയ്താൽ... പാസ്റ്റ് എന്താ പ്രസന്റ് എന്താ, അതിലുള്ള വേർഡ്സുകൾ, പ്രസന്റിങ്..."
class PocketTimeMachineTrainerModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onTrainingCompleted;

  const PocketTimeMachineTrainerModal({
    super.key,
    this.currentDay = 1,
    this.onTrainingCompleted,
  });

  static Future<void> show(BuildContext context, {int currentDay = 1, VoidCallback? onTrainingCompleted}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketTimeMachineTrainerModal(
        currentDay: currentDay,
        onTrainingCompleted: onTrainingCompleted,
      ),
    );
  }

  @override
  State<PocketTimeMachineTrainerModal> createState() => _PocketTimeMachineTrainerModalState();
}

class _PocketTimeMachineTrainerModalState extends State<PocketTimeMachineTrainerModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeVerbIndex = 0;
  int _selectedTenseIndex = 1; // 0 = Past (Yesterday), 1 = Present (Today), 2 = Future (Tomorrow)
  
  // Audio & Speech
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeakingTts = false;
  bool _isListening = false;
  String _spokenText = '';
  double _speechAccuracy = 0.0;
  bool _hasSpeechAttempted = false;

  // 60-Second Self-Presentation State
  final TextEditingController _nameController = TextEditingController(text: 'Rahul');
  final TextEditingController _professionController = TextEditingController(text: 'Software Developer');
  final TextEditingController _pastProjectController = TextEditingController(text: 'completed my degree and built three mobile applications');
  final TextEditingController _futureGoalController = TextEditingController(text: 'work with top global innovators and lead creative engineering teams');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeakingTts = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _tabController.dispose();
    _nameController.dispose();
    _professionController.dispose();
    _pastProjectController.dispose();
    _futureGoalController.dispose();
    super.dispose();
  }

  Future<void> _speakSentence(String text) async {
    HapticFeedback.lightImpact();
    setState(() => _isSpeakingTts = true);
    await _tts.stop();
    await _tts.speak(text);
  }

  void _listenAndVerify(String targetSentence) async {
    HapticFeedback.mediumImpact();
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _spokenText = '';
        _hasSpeechAttempted = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
            _speechAccuracy = _calculateSimilarity(targetSentence, _spokenText);
          });
          if (result.finalResult) {
            _handleSpeechComplete();
          }
        },
      );
    }
  }

  void _handleSpeechComplete() {
    if (_speechAccuracy >= 0.65) {
      HapticFeedback.vibrate();
      PocketFortressDefenseService.recordTrainingPoints(25);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🌟 Excellent Pronunciation! (${(_speechAccuracy * 100).toInt()}% Match) • +25 XP Earned!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: const Color(0xFF00E676),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double _calculateSimilarity(String target, String recognized) {
    final tWords = target.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').split(' ');
    final rWords = recognized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').split(' ');
    if (tWords.isEmpty || rWords.isEmpty) return 0.0;
    int matches = 0;
    for (final w in rWords) {
      if (tWords.contains(w)) matches++;
    }
    return (matches / tWords.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E17),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: const Text('⏳', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'TIME MACHINE TRAINER',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DAY ${widget.currentDay}',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Past vs Present vs Future • Never mix tenses again!',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF141926),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11.5),
              tabs: const [
                Tab(text: '⚡ 20 ACTION VERBS'),
                Tab(text: '🎤 60s PRESENTING'),
                Tab(text: '🎯 DID TRAP BUSTER'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVerbTrainerTab(),
                _buildSelfPresentationTab(),
                _buildDidTrapBusterTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: 20 ACTION VERB COMPARISON ---
  Widget _buildVerbTrainerTab() {
    final verb = kTimeMachineVerbs[_activeVerbIndex];

    String activeForm;
    String activeSentence;
    String activeTimeLabel;
    Color tenseColor;
    IconData tenseIcon;

    if (_selectedTenseIndex == 0) {
      activeForm = verb.pastForm;
      activeSentence = verb.pastSentence;
      activeTimeLabel = '⏪ YESTERDAY (PAST)';
      tenseColor = const Color(0xFFF59E0B);
      tenseIcon = Icons.history_rounded;
    } else if (_selectedTenseIndex == 1) {
      activeForm = verb.presentForm;
      activeSentence = verb.presentSentence;
      activeTimeLabel = '⏳ TODAY (PRESENT ROUTINE)';
      tenseColor = const Color(0xFF00E5FF);
      tenseIcon = Icons.today_rounded;
    } else {
      activeForm = verb.futureForm;
      activeSentence = verb.futureSentence;
      activeTimeLabel = '⏩ TOMORROW (FUTURE PLAN)';
      tenseColor = const Color(0xFF10B981);
      tenseIcon = Icons.upcoming_rounded;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Verb Selector Carousel
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kTimeMachineVerbs.length,
              itemBuilder: (ctx, i) {
                final isCur = i == _activeVerbIndex;
                final v = kTimeMachineVerbs[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${v.baseVerb} (${v.meaningMl})'),
                    selected: isCur,
                    onSelected: (_) => setState(() {
                      _activeVerbIndex = i;
                      _spokenText = '';
                      _hasSpeechAttempted = false;
                    }),
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF161C2C),
                    labelStyle: GoogleFonts.outfit(
                      color: isCur ? Colors.black : Colors.white70,
                      fontWeight: isCur ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Tense Switcher Bar (Past | Present | Future)
          Row(
            children: [
              _buildTenseButton(0, '⏪ Yesterday (Past)', const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildTenseButton(1, '⏳ Today (Present)', const Color(0xFF00E5FF)),
              const SizedBox(width: 8),
              _buildTenseButton(2, '⏩ Tomorrow (Future)', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 14),

          // Hero Interactive Verb Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121726),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tenseColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: tenseColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tenseIcon, color: tenseColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      activeTimeLabel,
                      style: GoogleFonts.outfit(
                        color: tenseColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: tenseColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeForm.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sentence display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeSentence,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Base: "${verb.baseVerb}" ➔ Form: "$activeForm"',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action controls: TTS Listen & Speech Mic
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _speakSentence(activeSentence),
                        icon: Icon(
                          _isSpeakingTts ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                          size: 18,
                          color: Colors.black,
                        ),
                        label: Text(
                          _isSpeakingTts ? 'LISTENING...' : 'LISTEN NATIVE 🔊',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _listenAndVerify(activeSentence),
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isListening ? 'RECORDING...' : 'SPEAK NOW 🎙️',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening ? Colors.redAccent : const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                // Live speech feedback
                if (_hasSpeechAttempted) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _speechAccuracy >= 0.65
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _speechAccuracy >= 0.65 ? const Color(0xFF10B981) : Colors.amber,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(_speechAccuracy >= 0.65 ? '🎯' : '🎙️', style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You said: "${_spokenText.isEmpty ? 'Listening...' : _spokenText}"',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _speechAccuracy >= 0.65 ? 'Confidence Match: ${(_speechAccuracy * 100).toInt()}% • Great job!' : 'Try speaking louder and clearer! (${(_speechAccuracy * 100).toInt()}% match)',
                                style: GoogleFonts.inter(
                                  color: _speechAccuracy >= 0.65 ? const Color(0xFF6EE7B7) : Colors.amber,
                                  fontSize: 10.5,
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
          const SizedBox(height: 14),

          // "Did" Trap Buster Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1528),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🧲', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'THE "DID" QUESTION PATTERN',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFA855F7),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  verb.didQuestion,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  verb.commonTrapMl,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFD700),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTenseButton(int index, String label, Color color) {
    final isSelected = _selectedTenseIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedTenseIndex = index;
          _spokenText = '';
          _hasSpeechAttempted = false;
        }),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF141824),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? color : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 2: 60-SECOND SELF-PRESENTATION BUILDER ---
  Widget _buildSelfPresentationTab() {
    final fullSpeech = 'Hello everyone. My name is ${_nameController.text.trim()}, '
        'and I am a ${_professionController.text.trim()}. '
        'In the past, I ${_pastProjectController.text.trim()}. '
        'Looking ahead, I will ${_futureGoalController.text.trim()}. '
        'I am dedicated to practicing English daily and mastering sovereign global communication. Thank you!';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎙️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The 60-Second Elevator Pitch: Seamlessly combines Who I am (Present), What I did (Past), and What I will do (Future).',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _buildInputField('1. Who I am (Present):', _nameController, 'Your Name (e.g. Rahul)'),
          const SizedBox(height: 10),
          _buildInputField('2. My Current Role (Present):', _professionController, 'Profession / Student (e.g. Graphic Designer)'),
          const SizedBox(height: 10),
          _buildInputField('3. What I Did / Studied (Past):', _pastProjectController, 'completed degree and built 3 projects'),
          const SizedBox(height: 10),
          _buildInputField('4. What I Will Do / Dream (Future):', _futureGoalController, 'lead creative engineering teams globally'),
          const SizedBox(height: 14),

          // Generated Speech Script Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141926),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📜', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'YOUR ASSEMBLED 60-SECOND PITCH',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  fullSpeech,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _speakSentence(fullSpeech),
                        icon: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.black),
                        label: Text(
                          'HEAR SPEECH 🔊',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _listenAndVerify(fullSpeech),
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded, size: 16, color: Colors.white),
                        label: Text(
                          _isListening ? 'RECORDING...' : 'PRACTICE SPEAKING 🎙️',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening ? Colors.redAccent : const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF121622),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E5FF)),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: "DID" TRAP BUSTER CHEAT CODE DRILL ---
  Widget _buildDidTrapBusterTab() {
    final List<Map<String, dynamic>> quizQuestions = [
      {
        'prompt': 'Choose the grammatically correct question:',
        'optionA': 'Did you saw him yesterday?',
        'optionB': 'Did you see him yesterday?',
        'correct': 'B',
        'explanation': 'DID acts as a past-tense magnet. Never use "saw" after Did! Always say "Did you see".',
      },
      {
        'prompt': 'Choose the correct sentence:',
        'optionA': 'I didn\'t went to the party.',
        'optionB': 'I didn\'t go to the party.',
        'correct': 'B',
        'explanation': 'In negative sentences, "didn\'t" takes the base verb: "didn\'t go".',
      },
      {
        'prompt': 'Did your friend _______ you about the test?',
        'optionA': 'told',
        'optionB': 'tell',
        'correct': 'B',
        'explanation': 'Did + Base Verb (tell), not told!',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizQuestions.length,
      itemBuilder: (ctx, i) {
        final q = quizQuestions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131724),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUICK DRILL #${i + 1}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                q['prompt']!,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _showQuizResultDialog(context, isCorrect: q['correct'] == 'A', explanation: q['explanation']!);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        q['optionA']!,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _showQuizResultDialog(context, isCorrect: q['correct'] == 'B', explanation: q['explanation']!);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        q['optionB']!,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuizResultDialog(BuildContext context, {required bool isCorrect, required String explanation}) {
    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketFortressDefenseService.recordTrainingPoints(15);
    } else {
      HapticFeedback.vibrate();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131722),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: isCorrect ? const Color(0xFF10B981) : Colors.redAccent, width: 1.5),
        ),
        title: Row(
          children: [
            Text(isCorrect ? '🎉' : '⚠️', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              isCorrect ? 'CORRECT! (+15 XP)' : 'COMMON TRAP!',
              style: GoogleFonts.outfit(
                color: isCorrect ? const Color(0xFF10B981) : Colors.redAccent,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
        content: Text(
          explanation,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('CONTINUE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
