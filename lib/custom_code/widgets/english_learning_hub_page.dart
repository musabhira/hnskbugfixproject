import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class EnglishLearningHubPage extends StatefulWidget {
  const EnglishLearningHubPage({super.key});

  @override
  State<EnglishLearningHubPage> createState() => _EnglishLearningHubPageState();
}

class _EnglishLearningHubPageState extends State<EnglishLearningHubPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late TabController _tabController;

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _currentView = 'dashboard'; // dashboard, practice
  String _selectedSubMode = '';
  String _selectedModeTitle = '';

  int _currentItemIndex = 0;
  String _recognizedText = '';
  double _accuracyScore = 0.0;
  bool _hasAnalyzed = false;

  // WPM and timer state for Speed Read Challenge
  Stopwatch _speedStopwatch = Stopwatch();
  int _wordsPerMinute = 0;
  int _speedCountdown = 15;
  Timer? _speedTimer;

  // Dictation state
  final TextEditingController _dictationController = TextEditingController();
  bool _dictationChecked = false;
  List<Map<String, dynamic>> _dictationDiffs = [];

  // Role Play State
  int _rolePlayTurnIndex = 0;
  bool _rolePlayWaitingForUser = false;
  List<Map<String, String>> _rolePlayHistory = [];

  // Free speaking AI feedback
  bool _aiFeedbackLoading = false;
  String _aiFeedbackText = '';

  // Points System
  int _hubPoints = 0;

  // Data Collections
  final List<String> _pronunciationWords = [
    'Mischievous',
    'Conscious',
    'Lieutenant',
    'Queue',
    'Colloquial',
    'Phenomenon',
    'Entrepreneur',
    'Hierarchy',
    'Anemone',
    'Squirrel',
    'Worcestershire',
    'Epitome',
    'Isthmus',
    'Otorhinolaryngologist'
  ];

  final List<Map<String, String>> _minimalPairs = [
    {'label': 'Ship vs Sheep', 'target': 'He boarded the ship but saw a sheep.'},
    {'label': 'Right vs Light', 'target': 'Turn to the right under the bright light.'},
    {'label': 'Sip vs Zip', 'target': 'Take a sip and zip up your jacket.'},
    {'label': 'Wet vs Vet', 'target': 'The wet dog needs to visit the vet.'},
    {'label': 'Cheap vs Jeep', 'target': 'This cheap book was read inside a jeep.'},
    {'label': 'Think vs Sink', 'target': 'I think the dishes are in the sink.'},
    {'label': 'Pass vs Path', 'target': 'Pass the map before taking the path.'}
  ];

  final List<Map<String, String>> _soundDrills = [
    {'sound': '/r/ Sound', 'text': 'Red roses grow rapidly around the red river.'},
    {'sound': '/l/ Sound', 'text': 'Little Lily loves lemon lollipops locally.'},
    {'sound': '/ʃ/ (sh) Sound', 'text': 'She washes shiny shells on the shallow shore.'},
    {'sound': '/θ/ (th) Sound', 'text': 'Thirty-three thousand thoughts through the thin thread.'}
  ];

  final List<Map<String, String>> _thSounds = [
    {'sound': 'Voiced TH', 'text': 'This father, that brother, and other mothers wear smooth leather.'},
    {'sound': 'Unvoiced TH', 'text': 'Nothing healthy on the birthday cloth, think through math.'}
  ];

  final List<Map<String, String>> _consonantClusters = [
    {'cluster': 'str-, -mpl, -ngth', 'text': 'A strong spring string and a glimpse of strengths.'},
    {'cluster': 'twelfth, sphere', 'text': 'The twelfth sphere glows in the night.'}
  ];

  final List<Map<String, String>> _wordStress = [
    {'words': 'REcord vs reCORD', 'text': 'We will record a new record in the studio.'},
    {'words': 'PREsent vs preSENT', 'text': 'I will present a birthday present to you.'},
    {'words': 'OBject vs obJECT', 'text': 'The object of the game is to object to errors.'}
  ];

  final List<String> _readAloudSentences = [
    'Success is not final, failure is not fatal: it is the courage to continue that counts.',
    'The only limit to our realization of tomorrow will be our doubts of today.',
    'Do not go where the path may lead, go instead where there is no path and leave a trail.',
    'In the middle of every difficulty lies opportunity.',
    'Confidence is preparation. Everything else is beyond your control.'
  ];

  final List<String> _shadowingSentences = [
    'I would like to improve my speaking skills.',
    'English is a global language spoken by millions.',
    'Consistent daily practice is the key to mastering any language.',
    'Don\'t be afraid of making grammar mistakes when speaking.'
  ];

  final List<Map<String, String>> _connectedSpeech = [
    {'phrase': 'want to -> wanna', 'text': 'I want to go to the park.'},
    {'phrase': 'got to -> gotta', 'text': 'I have got to leave immediately.'},
    {'phrase': 'what do you -> whaddya', 'text': 'What do you think about the movie?'},
    {'phrase': 'could you -> couldja', 'text': 'Could you help me carry this bag?'}
  ];

  final List<String> _speedChallengeSentences = [
    'Peter Piper picked a peck of pickled peppers.',
    'She sells seashells by the seashore.',
    'Betty Botter bought some butter but the butter was bitter.',
    'How can a clam cram in a clean cream can?'
  ];

  final List<Map<String, String>> _intonationDrills = [
    {'type': 'Rising (Yes/No Question)', 'text': 'Are you coming today?'},
    {'type': 'Falling (Wh- Question)', 'text': 'What is your favorite color?'},
    {'type': 'Falling (Statement)', 'text': 'I love practicing English speaking.'}
  ];

  final List<Map<String, String>> _storytellingPassages = [
    {
      'title': 'The Boy Who Cried Wolf',
      'text': 'A shepherd boy repeatedly fooled villagers by crying wolf. When a real wolf appeared, no one believed his cries and the flock was lost.'
    },
    {
      'title': 'The Tortoise and the Hare',
      'text': 'A confident hare mockingly challenged a slow tortoise. The hare took a nap mid-race, allowing the tortoise to win by crawling steadily.'
    }
  ];

  final List<Map<String, dynamic>> _pictureScenes = [
    {
      'title': 'A Busy City Park in Autumn',
      'vectorDesc': '🌳 Oak trees dropping yellow leaves. 🪑 A person reading a book on a bench. 🏃 A runner jogging with a dog. 🍦 A street vendor selling ice cream.',
      'questions': [
        'What is the person on the bench doing?',
        'Describe the trees and the weather.',
        'What is the runner doing?'
      ]
    },
    {
      'title': 'A Cozy Coffee Shop on a Rainy Day',
      'vectorDesc': '☕ Steaming mugs on tables. 📚 Bookshelves filled with colorful books. 🌧️ Raindrops sliding down the window pane. 🥐 Pastries displayed on a counter.',
      'questions': [
        'Describe what you see on the counter.',
        'What is the weather outside the window?',
        'What can people drink inside the shop?'
      ]
    }
  ];

  final List<String> _conversationPrompts = [
    'Describe your favorite childhood memory in detail.',
    'If you could travel anywhere in the world, where would you go?',
    'What are your primary goals for learning English?',
    'Tell me about a book or a movie that changed your perspective.'
  ];

  final List<Map<String, dynamic>> _rolePlays = [
    {
      'scenario': 'At a Coffee Shop',
      'partnerName': 'Barista',
      'turns': [
        {'speaker': 'partner', 'text': 'Welcome to Pocketmates Coffee! What can I get started for you today?'},
        {'speaker': 'user', 'text': 'Hi, I would like a medium iced latte with oat milk, please.'},
        {'speaker': 'partner', 'text': 'Sure thing! Do you want any pastry or syrup with that?'},
        {'speaker': 'user', 'text': 'No thank you, just the latte. That is all.'},
        {'speaker': 'partner', 'text': 'Alright, that will be four fifty. Cash or card?'},
        {'speaker': 'user', 'text': 'Card, please. Here you go.'}
      ]
    },
    {
      'scenario': 'Job Interview',
      'partnerName': 'Interviewer',
      'turns': [
        {'speaker': 'partner', 'text': 'Thank you for coming in today. Can you tell me a bit about yourself?'},
        {'speaker': 'user', 'text': 'I have three years of experience in app development, and I love building creative solutions.'},
        {'speaker': 'partner', 'text': 'Excellent. What do you consider to be your greatest professional strength?'},
        {'speaker': 'user', 'text': 'I am highly adaptable, a fast learner, and work extremely well under tight deadlines.'},
        {'speaker': 'partner', 'text': 'Great. Why do you want to work for our company?'},
        {'speaker': 'user', 'text': 'Your team is known for top-tier design and quality, and I want to grow alongside experts.'}
      ]
    }
  ];

  final List<String> _listeningSentences = [
    'Consistent daily practice leads to permanent mastery.',
    'Would you mind lending me your notebook for a second?',
    'The weather forecast predicts heavy showers throughout the weekend.',
    'Technological advances are reshaping modern communication interfaces.'
  ];

  final List<String> _dictationSentences = [
    'Experience is the teacher of all things.',
    'A journey of a thousand miles begins with a single step.',
    'Actions speak louder than words.',
    'Practice makes perfect when learning new speaking tenses.'
  ];

  final List<Map<String, dynamic>> _grammarLessons = [
    {
      'topic': 'Present Simple vs. Continuous',
      'explanation': 'Use Present Simple for routines ("I write code daily"). Use Present Continuous for actions happening right now ("I am writing code now").',
      'drills': [
        'I usually drink tea, but today I am drinking coffee.',
        'Water boils at one hundred degrees Celsius.',
        'Look! It is starting to rain outside.'
      ]
    },
    {
      'topic': 'First Conditional',
      'explanation': 'Describes likely future scenarios: "If it rains (present), we will stay (future) home."',
      'drills': [
        'If I study hard tonight, I will pass the exam tomorrow.',
        'If she arrives late, we will miss the train.',
        'They will go to the beach if the weather is warm.'
      ]
    },
    {
      'topic': 'Passive Voice',
      'explanation': 'Focuses on the action rather than the actor. Formed with: to be + past participle.',
      'drills': [
        'The Mona Lisa was painted by Leonardo da Vinci.',
        'A complete report is submitted every Friday.'
      ]
    }
  ];

  final List<Map<String, dynamic>> _interviewPrep = [
    {
      'topic': 'Tell me about yourself',
      'explanation': 'Keep it professional. Start with your current role, briefly mention past experiences, and conclude with why you are here.',
      'drills': [
        'I am currently working as a mobile developer and I have three years of experience.',
        'In my previous role, I led a small team to build an e-commerce application.',
        'I am looking for a position where I can utilize my flutter skills.'
      ]
    },
    {
      'topic': 'Strengths & Weaknesses',
      'explanation': 'Highlight strengths relevant to the job. For weaknesses, state a real one but focus on how you are improving it.',
      'drills': [
        'My greatest strength is my ability to learn new technologies quickly.',
        'I sometimes struggle with delegating tasks, but I am working on trusting my team more.',
        'I am highly organized and always ensure my projects are delivered on time.'
      ]
    }
  ];

  final List<Map<String, dynamic>> _workEnvironmentComm = [
    {
      'topic': 'Asking for Help or Clarification',
      'explanation': 'Be polite and specific about what you do not understand.',
      'drills': [
        'Could you please clarify what you mean by that?',
        'I am having trouble with this task, could you spare a minute to help?',
        'Just to confirm, you want me to finish the report by Friday?'
      ]
    },
    {
      'topic': 'Giving Updates in Standup',
      'explanation': 'State what you did yesterday, what you will do today, and any blockers you have.',
      'drills': [
        'Yesterday, I finished the UI implementation for the dashboard.',
        'Today, I will start working on the backend API integration.',
        'I am currently blocked on the design assets for the new screen.'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initSpeech();
    _initTts();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hubPoints = prefs.getInt('english_hub_points') ?? 0;
    });
  }

  Future<void> _addPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hubPoints += amount;
    });
    await prefs.setInt('english_hub_points', _hubPoints);
  }

  Future<void> _initSpeech() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
            _calculateAccuracy();
          }
        },
        onError: (err) {
          debugPrint('STT Error: $err');
          setState(() => _isListening = false);
        },
      );
    } catch (e) {
      debugPrint('STT Init Failed: $e');
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    final cleanText = text.replaceAll(RegExp(r'\[|\]'), '');
    await _flutterTts.speak(cleanText);
  }

  void _startListening() async {
    if (!_isSpeechInitialized) {
      await _initSpeech();
    }
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _accuracyScore = 0.0;
      _hasAnalyzed = false;
    });

    if (_selectedSubMode == 'speed_read') {
      _speedStopwatch.reset();
      _speedStopwatch.start();
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 4),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    _calculateAccuracy();
  }

  void _calculateAccuracy() {
    if (_recognizedText.isEmpty || _hasAnalyzed) return;

    String target = '';
    if (_selectedSubMode == 'pronunciation') {
      target = _pronunciationWords[_currentItemIndex];
    } else if (_selectedSubMode == 'minimal_pairs') {
      target = _minimalPairs[_currentItemIndex]['target']!;
    } else if (_selectedSubMode == 'sound_drills') {
      target = _soundDrills[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'th_sounds') {
      target = _thSounds[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'consonant_clusters') {
      target = _consonantClusters[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'word_stress') {
      target = _wordStress[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'read_aloud') {
      target = _readAloudSentences[_currentItemIndex];
    } else if (_selectedSubMode == 'shadowing') {
      target = _shadowingSentences[_currentItemIndex];
    } else if (_selectedSubMode == 'connected_speech') {
      target = _connectedSpeech[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'speed_read') {
      target = _speedChallengeSentences[_currentItemIndex];
      _speedStopwatch.stop();
      final ms = _speedStopwatch.elapsedMilliseconds;
      if (ms > 0) {
        final wordsCount = _recognizedText.split(' ').length;
        _wordsPerMinute = ((wordsCount / (ms / 1000)) * 60).toInt();
      }
    } else if (_selectedSubMode == 'intonation') {
      target = _intonationDrills[_currentItemIndex]['text']!;
    } else if (_selectedSubMode == 'listening') {
      target = _listeningSentences[_currentItemIndex];
    } else if (_selectedSubMode == 'grammar_lesson') {
      final drills = _grammarLessons[_currentItemIndex]['drills'] as List<String>;
      target = drills[0]; // Take current drill
    } else if (_selectedSubMode == 'interview_prep') {
      final drills = _interviewPrep[_currentItemIndex]['drills'] as List<String>;
      target = drills[0];
    } else if (_selectedSubMode == 'work_env') {
      final drills = _workEnvironmentComm[_currentItemIndex]['drills'] as List<String>;
      target = drills[0];
    } else if (_selectedSubMode == 'role_play') {
      final turns = _rolePlays[_currentItemIndex]['turns'] as List<Map<String, String>>;
      target = turns[_rolePlayTurnIndex]['text']!;
    }

    if (target.isEmpty) return;

    final cleanTarget = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final cleanRecognized = _recognizedText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    final targetWords = cleanTarget.split(' ');
    final recognizedWords = cleanRecognized.split(' ');

    int matches = 0;
    for (var word in targetWords) {
      if (recognizedWords.contains(word)) {
        matches++;
      }
    }

    setState(() {
      _accuracyScore = (matches / targetWords.length) * 100;
      _hasAnalyzed = true;
      if (_accuracyScore > 60) {
        _addPoints(10); // Reward 10 points for good accuracy
      }

      // For role play, automatically progress to next partner turn if accuracy is good
      if (_selectedSubMode == 'role_play' && _accuracyScore > 60) {
        _rolePlayHistory.add({'speaker': 'user', 'text': _recognizedText});
        _rolePlayWaitingForUser = false;
        _rolePlayTurnIndex++;
        if (_rolePlayTurnIndex < turnsCount()) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _runRolePlayTurn();
          });
        }
      }
    });
  }

  int turnsCount() {
    final turns = _rolePlays[_currentItemIndex]['turns'] as List;
    return turns.length;
  }

  void _runRolePlayTurn() {
    final turns = _rolePlays[_currentItemIndex]['turns'] as List<Map<String, String>>;
    if (_rolePlayTurnIndex >= turns.length) return;

    final turn = turns[_rolePlayTurnIndex];
    if (turn['speaker'] == 'partner') {
      setState(() {
        _rolePlayWaitingForUser = false;
        _recognizedText = '';
        _hasAnalyzed = false;
      });
      _rolePlayHistory.add({'speaker': 'partner', 'text': turn['text']!});
      _speak(turn['text']!).then((_) {
        setState(() {
          _rolePlayTurnIndex++;
          _runRolePlayTurn();
        });
      });
    } else {
      setState(() {
        _rolePlayWaitingForUser = true;
        _recognizedText = '';
        _hasAnalyzed = false;
      });
    }
  }

  void _startRolePlay() {
    setState(() {
      _rolePlayTurnIndex = 0;
      _rolePlayWaitingForUser = false;
      _rolePlayHistory.clear();
      _recognizedText = '';
      _hasAnalyzed = false;
    });
    _runRolePlayTurn();
  }

  void _checkDictation() {
    final cleanTarget = _dictationSentences[_currentItemIndex].toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final cleanInput = _dictationController.text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    final targetWords = cleanTarget.split(' ');
    final inputWords = cleanInput.split(' ');

    List<Map<String, dynamic>> diffs = [];
    for (var word in _dictationController.text.split(' ')) {
      final cleanW = word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      final isCorrect = targetWords.contains(cleanW);
      diffs.add({'word': word, 'isCorrect': isCorrect});
    }

    int matches = 0;
    for (var word in targetWords) {
      if (inputWords.contains(word)) {
        matches++;
      }
    }

    setState(() {
      _dictationChecked = true;
      _dictationDiffs = diffs;
      _accuracyScore = (matches / targetWords.length) * 100;
    });
  }

  void _analyzeFreeSpeech(String promptQuestion) async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _aiFeedbackLoading = true;
      _aiFeedbackText = '';
    });

    final prompt = 'A learner described a scene or answered a prompt. '
        'Question/Context: "$promptQuestion". '
        'Learner\'s spoken answer transcript: "$_recognizedText". '
        'Provide a short feedback (maximum 100 words). '
        'Highlight any grammatical errors in red/parenthesis, suggest 2 better/natural ways to phrase it, and rate their coherence (1-10).';

    final response = await AIService().generateText(prompt: prompt);

    setState(() {
      _aiFeedbackLoading = false;
      _aiFeedbackText = response.isSuccess ? response.data! : 'Failed to analyze transcript.';
    });
  }

  void _showAIExplanation(String target) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.psychology_alt_rounded, color: Color(0xFFFFD600)),
              const SizedBox(width: 10),
              Text(
                'AI Tutor Explanation',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: FutureBuilder<AIResponse>(
            future: AIService().generateText(
              prompt: 'Explain: "$target" for an English learner. '
                  'Provide its meaning, pronunciation tips, and one real-life example sentence. '
                  'Keep it clear, concise, and friendly.',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD600)),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.isSuccess) {
                return const Text('Failed to get AI explanation. Please check your internet connection.',
                    style: TextStyle(color: Colors.redAccent));
              }
              return SingleChildScrollView(
                child: Text(
                  snapshot.data!.data ?? '',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.outfit(color: const Color(0xFFFFD600), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _speedTimer?.cancel();
    _dictationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentView == 'practice') {
              setState(() {
                _currentView = 'dashboard';
                _selectedSubMode = '';
                _recognizedText = '';
                _accuracyScore = 0.0;
                _hasAnalyzed = false;
                _dictationController.clear();
                _dictationChecked = false;
                _aiFeedbackText = '';
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _currentView == 'practice' ? _selectedModeTitle : 'Pocketmates English Hub',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD600), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_hubPoints pts',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD600),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _currentView == 'dashboard' ? _buildDashboard() : _buildPracticeView(),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        Container(
          color: const Color(0xFF121B22),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFFD600),
            labelColor: const Color(0xFFFFD600),
            unselectedLabelColor: Colors.white60,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Clarity'),
              Tab(text: 'Fluency'),
              Tab(text: 'Speaking'),
              Tab(text: 'Grammar'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList([
                _modeTile('pronunciation', '🗣️', 'Pronunciation', 'Practice tricky single words with visual playback.'),
                _modeTile('minimal_pairs', '🎯', 'Minimal Pairs', 'Contrast confusing sets like ship/sheep.'),
                _modeTile('sound_drills', '🔊', 'Sound Drills', 'Isolate and focus on difficult /r/, /l/, or /sh/ sounds.'),
                _modeTile('th_sounds', '👅', 'Th Sounds', 'Master voiced vs. unvoiced /th/ pronunciation.'),
                _modeTile('consonant_clusters', '🔤', 'Consonant Clusters', 'Tackle complex groupings like str- and -ngth.'),
                _modeTile('word_stress', '📝', 'Word Stress', 'Master syllable stress changes: REcord vs reCORD.'),
              ]),
              _buildCategoryList([
                _modeTile('read_aloud', '📖', 'Read Aloud / Improve', 'Speak sentences aloud with accuracy matching.'),
                _modeTile('shadowing', '🔄', 'Shadowing', 'Listen to model sentence rhythm and echo it back.'),
                _modeTile('connected_speech', '🔗', 'Connected Speech', 'Blur words together naturally: want to -> wanna.'),
                _modeTile('speed_read', '⏱️', 'Speed Challenge', 'Read sentences against the clock to track your WPM speed.'),
                _modeTile('intonation', '🎵', 'Intonation Pitch', 'Practice rising and falling tones in sentence contexts.'),
                _modeTile('storytelling', '📜', 'Storytelling Passages', 'Read aloud short narrative summaries to build endurance.'),
              ]),
              _buildCategoryList([
                _modeTile('conversation', '💬', 'Conversation Starters', 'Speak spontaneously on open-ended topics.'),
                _modeTile('picture_description', '🖼️', 'Picture Descriptions', 'Describe scenes; get custom grammar upgrades from AI tutor.'),
                _modeTile('role_play', '🎭', 'Dialogues & Role Plays', 'Join interactive conversational roleplays with TTS partner.'),
              ]),
              _buildCategoryList([
                _modeTile('listening', '👂', 'Listening Practice', 'Listen to sentences, then repeat what you heard.'),
                _modeTile('dictation', '✍️', 'Dictation Test', 'Listen to statements and type them out with visual typo matching.'),
                _modeTile('grammar_lesson', '⚙️', 'Grammar Lessons', 'Interactive core grammar topics with speaking drills.'),
                _modeTile('interview_prep', '👔', 'Interview Prep', 'Common interview questions and how to answer them.'),
                _modeTile('work_env', '🏢', 'Work Environment', 'Communicate professionally with colleagues and in standups.'),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<Widget> tiles) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF121B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            '💡 Practice English, clarity, and fluency. Select any practice mode below to begin speaking.',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        ...tiles,
      ],
    );
  }

  Widget _modeTile(String mode, String emoji, String title, String subtitle) {
    return Card(
      color: const Color(0xFF121B22),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedSubMode = mode;
            _selectedModeTitle = title;
            _currentItemIndex = 0;
            _recognizedText = '';
            _accuracyScore = 0.0;
            _hasAnalyzed = false;
            _currentView = 'practice';
          });
          if (mode == 'role_play') {
            _startRolePlay();
          }
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF070B0D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      ),
    );
  }

  Widget _buildPracticeView() {
    if (_selectedSubMode == 'role_play') return _buildRolePlayView();
    if (_selectedSubMode == 'picture_description') return _buildPictureView();
    if (_selectedSubMode == 'dictation') return _buildDictationView();
    if (_selectedSubMode == 'grammar_lesson') return _buildLessonView(_grammarLessons);
    if (_selectedSubMode == 'interview_prep') return _buildLessonView(_interviewPrep);
    if (_selectedSubMode == 'work_env') return _buildLessonView(_workEnvironmentComm);

    String targetText = '';
    String label = 'Read this aloud:';

    if (_selectedSubMode == 'pronunciation') {
      targetText = _pronunciationWords[_currentItemIndex];
      label = 'Pronounce the word:';
    } else if (_selectedSubMode == 'minimal_pairs') {
      targetText = _minimalPairs[_currentItemIndex]['target']!;
      label = 'Minimal Pair Contrast: ${_minimalPairs[_currentItemIndex]['label']}';
    } else if (_selectedSubMode == 'sound_drills') {
      targetText = _soundDrills[_currentItemIndex]['text']!;
      label = 'Target Drill: ${_soundDrills[_currentItemIndex]['sound']}';
    } else if (_selectedSubMode == 'th_sounds') {
      targetText = _thSounds[_currentItemIndex]['text']!;
      label = 'Drill Tone: ${_thSounds[_currentItemIndex]['sound']}';
    } else if (_selectedSubMode == 'consonant_clusters') {
      targetText = _consonantClusters[_currentItemIndex]['text']!;
      label = 'Cluster Set: ${_consonantClusters[_currentItemIndex]['cluster']}';
    } else if (_selectedSubMode == 'word_stress') {
      targetText = _wordStress[_currentItemIndex]['text']!;
      label = 'Stress Contrast: ${_wordStress[_currentItemIndex]['words']}';
    } else if (_selectedSubMode == 'read_aloud') {
      targetText = _readAloudSentences[_currentItemIndex];
    } else if (_selectedSubMode == 'shadowing') {
      targetText = _shadowingSentences[_currentItemIndex];
      label = 'Shadow the sentence:';
    } else if (_selectedSubMode == 'connected_speech') {
      targetText = _connectedSpeech[_currentItemIndex]['text']!;
      label = 'Link: ${_connectedSpeech[_currentItemIndex]['phrase']}';
    } else if (_selectedSubMode == 'speed_read') {
      targetText = _speedChallengeSentences[_currentItemIndex];
      label = 'Speed Read Challenge (Read quickly):';
    } else if (_selectedSubMode == 'intonation') {
      targetText = _intonationDrills[_currentItemIndex]['text']!;
      label = 'Tone Type: ${_intonationDrills[_currentItemIndex]['type']}';
    } else if (_selectedSubMode == 'listening') {
      targetText = _listeningSentences[_currentItemIndex];
      label = 'Listen, then speak the sentence:';
    } else if (_selectedSubMode == 'conversation') {
      targetText = _conversationPrompts[_currentItemIndex];
      label = 'Conversation Starter:';
    }

    final totalItems = _getTotalItems();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item ${_currentItemIndex + 1} of $totalItems',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
              if (_selectedSubMode != 'conversation')
                IconButton(
                  icon: const Icon(Icons.psychology, color: Color(0xFFFFD600)),
                  onPressed: () => _showAIExplanation(targetText),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12)),
                  const SizedBox(height: 16),
                  if (_selectedSubMode == 'listening' && !_hasAnalyzed && !_isListening)
                    const Icon(Icons.music_note, size: 50, color: Color(0xFFFFD600))
                  else
                    SelectableText(
                      targetText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _speak(targetText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(Icons.volume_up, color: Color(0xFFFFD600), size: 18),
                        label: Text('Listen', style: GoogleFonts.outfit(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_recognizedText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('You Said:', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                      if (_selectedSubMode == 'conversation')
                        IconButton(
                          icon: const Icon(Icons.analytics, color: Color(0xFFFFD600), size: 18),
                          tooltip: 'AI Grammar Check',
                          onPressed: () => _analyzeFreeSpeech(targetText),
                        )
                      else if (_hasAnalyzed)
                        Text(
                          'Score: ${_accuracyScore.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(
                            color: _accuracyScore > 75 ? Colors.green : Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedSubMode == 'speed_read' && _hasAnalyzed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text('Speed: $_wordsPerMinute Words/Minute',
                          style: GoogleFonts.outfit(color: const Color(0xFFFFD600), fontSize: 13)),
                    ),
                  if (_selectedSubMode == 'conversation')
                    Text(_recognizedText, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14))
                  else
                    _buildComparisonWidget(targetText, _recognizedText),
                  if (_aiFeedbackLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(color: Color(0xFFFFD600)),
                    )
                  else if (_aiFeedbackText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF121B22), borderRadius: BorderRadius.circular(8)),
                      child: Text(_aiFeedbackText, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildNavigationControls(totalItems),
        ],
      ),
    );
  }

  Widget _buildComparisonWidget(String target, String recognized) {
    final targetWords = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ');
    final List<Widget> spans = [];
    for (var word in recognized.split(' ')) {
      final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      final isMatched = targetWords.contains(cleanWord);
      spans.add(
        Text(
          '$word ',
          style: GoogleFonts.outfit(
            color: isMatched ? Colors.green : Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    return Wrap(children: spans);
  }

  Widget _buildNavigationControls(int totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
          onPressed: _currentItemIndex > 0
              ? () {
                  setState(() {
                    _currentItemIndex--;
                    _recognizedText = '';
                    _accuracyScore = 0.0;
                    _hasAnalyzed = false;
                    _aiFeedbackText = '';
                  });
                }
              : null,
        ),
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFFFD600),
            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.black, size: 24),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
          onPressed: _currentItemIndex < totalItems - 1
              ? () {
                  setState(() {
                    _currentItemIndex++;
                    _recognizedText = '';
                    _accuracyScore = 0.0;
                    _hasAnalyzed = false;
                    _aiFeedbackText = '';
                  });
                }
              : null,
        ),
      ],
    );
  }

  int _getTotalItems() {
    switch (_selectedSubMode) {
      case 'pronunciation':
        return _pronunciationWords.length;
      case 'minimal_pairs':
        return _minimalPairs.length;
      case 'sound_drills':
        return _soundDrills.length;
      case 'th_sounds':
        return _thSounds.length;
      case 'consonant_clusters':
        return _consonantClusters.length;
      case 'word_stress':
        return _wordStress.length;
      case 'read_aloud':
        return _readAloudSentences.length;
      case 'shadowing':
        return _shadowingSentences.length;
      case 'connected_speech':
        return _connectedSpeech.length;
      case 'speed_read':
        return _speedChallengeSentences.length;
      case 'intonation':
        return _intonationDrills.length;
      case 'listening':
        return _listeningSentences.length;
      case 'conversation':
        return _conversationPrompts.length;
      case 'grammar_lesson':
        return _grammarLessons.length;
      case 'interview_prep':
        return _interviewPrep.length;
      case 'work_env':
        return _workEnvironmentComm.length;
      default:
        return 0;
    }
  }

  Widget _buildDictationView() {
    final sentence = _dictationSentences[_currentItemIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item ${_currentItemIndex + 1} of ${_dictationSentences.length}',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF121B22), borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.headphones, size: 48, color: Color(0xFFFFD600)),
                  const SizedBox(height: 16),
                  Text('Listen carefully and type what you hear:',
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _speak(sentence),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.volume_up, color: Color(0xFFFFD600)),
                    label: const Text('Play Voice'),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _dictationController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type statement here...',
                      hintStyle: GoogleFonts.outfit(color: Colors.white30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_dictationChecked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Check Result:', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                      Text('Score: ${_accuracyScore.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(color: _accuracyScore > 75 ? Colors.green : Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: _dictationDiffs.map((diff) {
                      final word = diff['word'] as String;
                      final isCorrect = diff['isCorrect'] as bool;
                      return Text(
                        '$word ',
                        style: GoogleFonts.outfit(color: isCorrect ? Colors.green : Colors.redAccent, fontSize: 14),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
                onPressed: _currentItemIndex > 0
                    ? () {
                        setState(() {
                          _currentItemIndex--;
                          _dictationController.clear();
                          _dictationChecked = false;
                        });
                      }
                    : null,
              ),
              ElevatedButton(
                onPressed: _checkDictation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Verify Spelling', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
                onPressed: _currentItemIndex < _dictationSentences.length - 1
                    ? () {
                        setState(() {
                          _currentItemIndex++;
                          _dictationController.clear();
                          _dictationChecked = false;
                        });
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLessonView(List<Map<String, dynamic>> lessonList) {
    final lesson = lessonList[_currentItemIndex];
    final drills = lesson['drills'] as List<String>;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Topic ${_currentItemIndex + 1} of ${lessonList.length}',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF121B22), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lesson['topic']!,
                          style: GoogleFonts.outfit(color: const Color(0xFFFFD600), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(lesson['explanation']!,
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Practice Drills (Read aloud):',
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 10),
                ...drills.map((drill) {
                  return Card(
                    color: const Color(0xFF121B22),
                    child: ListTile(
                      title: Text(drill, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                      trailing: const Icon(Icons.mic, color: Color(0xFFFFD600), size: 18),
                      onTap: () {
                        _speak(drill);
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
                onPressed: _currentItemIndex > 0
                    ? () {
                        setState(() {
                          _currentItemIndex--;
                          _recognizedText = '';
                          _accuracyScore = 0.0;
                          _hasAnalyzed = false;
                        });
                      }
                    : null,
              ),
              Text('Swipe/Tap to speak drills', style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11)),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
                onPressed: _currentItemIndex < lessonList.length - 1
                    ? () {
                        setState(() {
                          _currentItemIndex++;
                          _recognizedText = '';
                          _accuracyScore = 0.0;
                          _hasAnalyzed = false;
                        });
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPictureView() {
    final scene = _pictureScenes[_currentItemIndex];
    final totalItems = _pictureScenes.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Scene ${_currentItemIndex + 1} of $totalItems',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, color: Colors.white38, size: 36),
                        const SizedBox(height: 8),
                        Text(scene['title']!,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF121B22), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vector Description:',
                          style: GoogleFonts.outfit(color: const Color(0xFFFFD600), fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(scene['vectorDesc']!,
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Guide Questions:',
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 6),
                ...(scene['questions'] as List<String>).map((q) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFFFFD600))),
                        Expanded(child: Text(q, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_recognizedText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Description:', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                      IconButton(
                        icon: const Icon(Icons.analytics, color: Color(0xFFFFD600), size: 18),
                        onPressed: () => _analyzeFreeSpeech(scene['title']!),
                      )
                    ],
                  ),
                  Text(_recognizedText, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                  if (_aiFeedbackLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(color: Color(0xFFFFD600)),
                    )
                  else if (_aiFeedbackText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF121B22), borderRadius: BorderRadius.circular(8)),
                      child: Text(_aiFeedbackText, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
                onPressed: _currentItemIndex > 0
                    ? () {
                        setState(() {
                          _currentItemIndex--;
                          _recognizedText = '';
                          _hasAnalyzed = false;
                          _aiFeedbackText = '';
                        });
                      }
                    : null,
              ),
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFFFD600),
                  child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.black, size: 24),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
                onPressed: _currentItemIndex < totalItems - 1
                    ? () {
                        setState(() {
                          _currentItemIndex++;
                          _recognizedText = '';
                          _hasAnalyzed = false;
                          _aiFeedbackText = '';
                        });
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRolePlayView() {
    final scenario = _rolePlays[_currentItemIndex];
    final totalItems = _rolePlays.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Role Play Scenario ${_currentItemIndex + 1} of $totalItems',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
              ElevatedButton.icon(
                onPressed: _startRolePlay,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF121B22), foregroundColor: Colors.white),
                icon: const Icon(Icons.refresh, color: Color(0xFFFFD600), size: 14),
                label: const Text('Restart'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _rolePlayHistory.length,
              itemBuilder: (context, index) {
                final chat = _rolePlayHistory[index];
                final isUser = chat['speaker'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0F5340) : const Color(0xFF121B22),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                      ),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(chat['text']!, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
          if (_rolePlayWaitingForUser) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text('Your Turn to Speak:', style: GoogleFonts.outfit(color: const Color(0xFFFFD600), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    (_rolePlays[_currentItemIndex]['turns'] as List)[_rolePlayTurnIndex]['text']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
                onPressed: _currentItemIndex > 0
                    ? () {
                        setState(() {
                          _currentItemIndex--;
                        });
                        _startRolePlay();
                      }
                    : null,
              ),
              if (_rolePlayWaitingForUser)
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFFFD600),
                    child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.black, size: 24),
                  ),
                )
              else
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFFD600))),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
                onPressed: _currentItemIndex < totalItems - 1
                    ? () {
                        setState(() {
                          _currentItemIndex++;
                        });
                        _startRolePlay();
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }
}
