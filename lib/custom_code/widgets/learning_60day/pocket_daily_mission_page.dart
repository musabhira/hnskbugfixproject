import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/stage_peer_matchmaker.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_battle_arena_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_library_page.dart';

/// 📚 Model for Daily 10 Vocabulary Words to Memorize (Multilingual Support)
class DailyVocabItem {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String malayalamMeaning;
  final String tamilMeaning;
  final String hindiMeaning;
  final String teluguMeaning;
  final String kannadaMeaning;
  final String exampleSentence;
  final String phonetic;

  const DailyVocabItem({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.malayalamMeaning,
    this.tamilMeaning = '',
    this.hindiMeaning = '',
    this.teluguMeaning = '',
    this.kannadaMeaning = '',
    required this.exampleSentence,
    required this.phonetic,
  });

  String getMeaning(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return tamilMeaning.isNotEmpty ? tamilMeaning : malayalamMeaning;
      case 'hindi':
        return hindiMeaning.isNotEmpty ? hindiMeaning : malayalamMeaning;
      case 'telugu':
        return teluguMeaning.isNotEmpty ? teluguMeaning : malayalamMeaning;
      case 'kannada':
        return kannadaMeaning.isNotEmpty ? kannadaMeaning : malayalamMeaning;
      case 'malayalam':
      default:
        return malayalamMeaning;
    }
  }
}

/// 🎯 Comprehensive Interactive Daily English Mission Experience
class PocketDailyMissionPage extends StatefulWidget {
  final int day;
  final VoidCallback? onMissionCompleted;

  const PocketDailyMissionPage({
    super.key,
    required this.day,
    this.onMissionCompleted,
  });

  @override
  State<PocketDailyMissionPage> createState() => _PocketDailyMissionPageState();
}

class _PocketDailyMissionPageState extends State<PocketDailyMissionPage> {
  final FlutterTts _tts = FlutterTts();

  // ⏱️ Shared 60-Minute Daily Practice Timer Service
  final PocketMissionTimerService _timerService = PocketMissionTimerService.instance;

  // Checklist Subtasks Progress
  bool _hubChatVerified = false;
  bool _peerCallVerified = false;
  bool _vocabMemorized = false;
  bool _readingNotesCompleted = false;
  bool _revisionQuizPassed = false;
  bool _defenseTrapArmed = false;
  bool _trialRaidLaunched = false;

  // Quiz state
  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  // 🌐 Multilingual Category Preferences (Audio Requirement)
  static const List<String> kSupportedLanguages = [
    'Malayalam',
    'Tamil',
    'Hindi',
    'Telugu',
    'Kannada',
  ];

  String _selectedLanguage = 'Malayalam';
  bool _isStorySpeaking = false;

  static const String _kDay1StoryText =
      'A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others. A wise mentor approached him and smiled. Look at this bamboo, the mentor said. For four years, its roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky! Your daily English practice is just like that seed. Every day you speak, read, and listen for sixty minutes, you are building unseen roots. Soon, your fluency will soar higher than you ever imagined. The student took a deep breath, spoke his first sentence with courage, and stepped fearlessly onto his ninety day path.';

  static const String _kDay1StoryFormatted =
      '🌱 Part 1: The Hesitant Learner\n'
      'A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others.\n\n'
      '🎋 Part 2: The Wisdom of the Bamboo\n'
      'A wise mentor approached him and smiled. "Look at this bamboo," the mentor said. "For four years, its roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky!"\n\n'
      '✨ Part 3: The 90-Day Secret\n'
      '"Your daily English practice is just like that seed. Every day you speak, read, and listen for sixty minutes, you are building unseen roots. Soon, your fluency will soar higher than you ever imagined."\n\n'
      '🚀 Part 4: The First Step\n'
      'The student took a deep breath, spoke his first sentence with courage, and stepped fearlessly onto his 90-day path.';

  static const String _kDay2StoryText =
      'Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow. One day, his grandfather handed him an empty notebook with golden edges. Marcus, the old man said gently, we do not decide our future. We decide our daily habits, and our habits decide our future. Dedicate the very first sixty minutes of your sunrise to what you wish to master. Marcus accepted the wisdom. He placed the notebook on his desk and woke up thirty minutes earlier each dawn. In the quiet morning, he read aloud, spoke to the mirror, and practiced his vocabulary sentences. Within weeks, what once felt impossible became effortless. Marcus realized that mastery does not require giant leaps, only unbroken daily rituals.';

  static const String _kDay2StoryFormatted =
      '🌅 Part 1: The Evening Struggle\n'
      'Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow.\n\n'
      '📖 Part 2: The Golden Notebook\n'
      'One day, his grandfather handed him an empty notebook with golden edges. "Marcus," the old man said gently, "we do not decide our future. We decide our daily habits, and our habits decide our future."\n\n'
      '☀️ Part 3: The Sunrise Rule\n'
      '"Dedicate the very first sixty minutes of your sunrise to what you wish to master." Marcus accepted the wisdom. He woke up thirty minutes earlier each dawn to read aloud and speak vocabulary sentences.\n\n'
      '🏆 Part 4: Unbroken Rituals\n'
      'Within weeks, what once felt impossible became effortless. Marcus realized that mastery does not require giant leaps, only unbroken daily rituals.';

  late final List<DailyVocabItem> _vocabList;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadVocabForDay();
    _timerService.initForDay(widget.day);
    _timerService.addListener(_onTimerStateChanged);
    _loadSavedMissionState();
  }

  void _onTimerStateChanged() {
    if (mounted) setState(() {});
  }

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
  }

  void _speakWord(String text) async {
    HapticFeedback.lightImpact();
    await _tts.speak(text);
  }

  void _speakStory(String text) async {
    HapticFeedback.lightImpact();
    if (_isStorySpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isStorySpeaking = false);
    } else {
      setState(() => _isStorySpeaking = true);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isStorySpeaking = false);
      });
      await _tts.speak(text);
    }
  }

  void _onLanguageSelected(String lang) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedLanguage = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pocket_mission_pref_lang', lang);
  }

  String _getGrammarRuleExplanation(String lang) {
    if (widget.day == 2) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return 'செயல் எவ்வளவு முறை நடக்கிறது என்பதைக் குறிக்க Adverbs of Frequency பயன்படுகின்றன. இவை பொதுவாக முதன்மை வினைச்சொல்லுக்கு (main verb) முன்னால் வரும்.\n• சரியான வாக்கியம்: "I always practice English in the morning."\n• தமிழில்: "நான் எப்போதும் காலையில் பயிற்சி செய்கிறேன்." main verb-க்கு முன் "always, usually" வைக்க நினைவில் கொள்ளுங்கள்!';
        case 'hindi':
          return 'Adverbs of Frequency बताते हैं कि कोई काम कितनी बार होता है। ये मुख्य क्रिया (main verb) से ठीक पहले आते हैं।\n• सही वाक्य: "I always practice English in the morning."\n• हिंदी में: "मैं हमेशा सुबह अभ्यास करता हूँ।" Main verb से पहले always, usually का प्रयोग करें!';
        case 'telugu':
          return 'ఒక పని ఎంత తరచుగా జరుగుతుందో తెలిపేందుకు Adverbs of Frequency వాడతారు. ఇవి సాధారణంగా ప్రధాన క్రియకు (main verb) ముందే వస్తాయి.\n• సరైనది: "I always practice English in the morning."\n• తెలుగులో: "నేను ఎల్లప్పుడూ ఉదయం సాధన చేస్తాను." Main verb కు ముందుగా వీటిని ఉంచండి!';
        case 'kannada':
          return 'ಒಂದು ಕೆಲಸ ಎಷ್ಟು ಬಾರಿ ನಡೆಯುತ್ತದೆ ಎಂಬುದನ್ನು ತಿಳಿಸಲು Adverbs of Frequency ಬಳಸಲಾಗುತ್ತದೆ. ಇವು ಸಾಮಾನ್ಯವಾಗಿ ಮುಖ್ಯ ಕ್ರಿಯಾಪದದ ಮುಂಚೆ ಬರುತ್ತವೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "I always practice English in the morning."\n• ಕನ್ನಡದಲ್ಲಿ: "ನಾನು ಯಾವಾಗಲೂ ಬೆಳಗ್ಗೆ ಅಭ್ಯಾಸ ಮಾಡುತ್ತೇನೆ." Main verb ಗಿಂತ ಮೊದಲು ಇರಿಸಿ!';
        case 'malayalam':
        default:
          return 'Adverbs of Frequency show how often an action happens. They usually go BEFORE the main verb, but AFTER the verb "to be".\n• Correct: "I always practice English in the morning."\n• Correct with "be": "He is usually punctual."\n• In Malayalam: "ഞാൻ എപ്പോഴും രാവിലെ ഇംഗ്ലീഷ് പരിശീലിക്കുന്നു." പ്രധാന ക്രിയയ്ക്ക് (verb) തൊട്ടുമുമ്പായി "always, often, usually" ചേർക്കുക!';
      }
    }

    switch (lang.toLowerCase()) {
      case 'tamil':
        return 'ஆங்கிலத்தில் வாக்கிய அமைப்பு: எழுவாய் (Subject) + வினைச்சொல் (Verb) + செயப்படுபொருள் (Object).\n• சரியான வாக்கியம்: "She reads books."\n• தமிழில்: "அவள் புத்தகம் படிக்கிறாள்" (Subject + Object + Verb). ஆங்கிலத்தில் பேசுவதற்கு முன் வினையை (Verb) பொருளுக்கு முன்னால் வைக்க நினைவில் கொள்ளுங்கள்!';
      case 'hindi':
        return 'अंग्रेजी में वाक्य विन्यास: कर्ता (Subject) + क्रिया (Verb) + कर्म (Object) के क्रम में आता है।\n• सही: "She reads books."\n• हिंदी में: "वह किताब पढ़ती है" (Subject + Object + Verb)। अंग्रेजी में हमेशा क्रिया (Verb) को कर्म से पहले रखें!';
      case 'telugu':
        return 'ఇంగ్లీషులో వాక్య నిర్మాణం: కర్త (Subject) + క్రియ (Verb) + కర్మ (Object) క్రమంలో ఉంటుంది.\n• సరైనది: "She reads books."\n• తెలుగులో: "ఆమె పుస్తకం చదువుతుంది" (Subject + Object + Verb). ఇంగ్లీష్ మాట్లాడేటప్పుడు క్రియను కర్మకు ముందే ఉంచాలని గుర్తుంచుకోండి!';
      case 'kannada':
        return 'ಇಂಗ್ಲಿಷ್ ವಾಕ್ಯ ರಚನೆ: ಕರ್ತೃ (Subject) + ಕ್ರಿಯಾಪದ (Verb) + ಕರ್ಮ (Object) ಕ್ರಮದಲ್ಲಿ ಬರುತ್ತದೆ.\n• ಸರಿಯಾದ ವಾಕ್ಯ: "She reads books."\n• ಕನ್ನಡದಲ್ಲಿ: "ಅವಳು ಪುಸ್ತಕ ಓದುತ್ತಾಳೆ" (Subject + Object + Verb). ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಕ್ರಿಯಾಪದವನ್ನು (Verb) ಕರ್ಮಕ್ಕಿಂತ ಮೊದಲು ಇರಿಸಿ!';
      case 'malayalam':
      default:
        return 'English sentences follow the order: Subject (who) + Verb (action) + Object (what).\n• Correct: "She reads books."\n• In Malayalam: "അവൾ പുസ്തകം വായിക്കുന്നു" (Subject + Object + Verb). Remember to place the action verb BEFORE the object in English!';
    }
  }

  String _getStorySummary(String lang) {
    if (widget.day == 2) {
      switch (lang.toLowerCase()) {
        case 'tamil':
          return '💡 நீதி: "நமது பழக்கவழக்கங்களே நமது எதிர்காலத்தை உருவாக்குகின்றன." தினமும் விடாமல் செய்யும் சிறிய பயிற்சியே மாபெரும் வெற்றியைத் தரும்.';
        case 'hindi':
          return '💡 सीख: "हमारी आदतें ही हमारा भविष्य तय करती हैं।" प्रतिदिन का छोटा लेकिन अटूट अभ्यास ही महान सफलता की कुंजी है।';
        case 'telugu':
          return '💡 నీతి: "మన అలవాట్లే మన భవిష్యత్తును నిర్ణయిస్తాయి." ప్రతిరోజూ చేసే క్రమశిక్షణతో కూడిన సాధనే గొప్ప ఫలితాన్ని ఇస్తుంది.';
        case 'kannada':
          return '💡 ನೀತಿ: "ನಮ್ಮ ಅಭ್ಯಾಸಗಳೇ ನಮ್ಮ ಭವಿಷ್ಯವನ್ನು ನಿರ್ಧರಿಸುತ್ತವೆ." ಪ್ರತಿದಿನ ಮಾಡುವ ಸಣ್ಣ ಸತತ ಪ್ರಯತ್ನವೇ ದೊಡ್ಡ ಯಶಸ್ಸಿಗೆ ಕಾರಣವಾಗುತ್ತದೆ.';
        case 'malayalam':
        default:
          return '💡 സന്ദേശം: "നമ്മുടെ ശീലങ്ങളാണ് നമ്മുടെ ഭാവിയെ നിർണയിക്കുന്നത്." ദിവസേനയുള്ള ചെറിയ ചിട്ടയായ പരിശീലനം വലിയ മാറ്റങ്ങൾ സൃഷ്ടിക്കും.';
      }
    }

    switch (lang.toLowerCase()) {
      case 'tamil':
        return '💡 நீதி: நமது ஆங்கிலப் பயிற்சி மூங்கில் விதை போன்றது. ஆரம்பத்தில் வெளியே தெரியாவிட்டாலும் உள்ளுக்குள் ஆழமான வேர்கள் உருவாகின்றன. 90 நாட்கள் தொடர் பயிற்சியால் உங்கள் சரளத்தன்மை வானளவிற்கு உயரும்.';
      case 'hindi':
        return '💡 सीख: हमारा अंग्रेजी अभ्यास बांस के बीज जैसा है। शुरुआत में भले ही बाहर कुछ न दिखे, लेकिन जड़ें गहराई तक फैलती हैं। 90 दिनों के नियमित अभ्यास से आपका आत्मविश्वास नई ऊंचाइयां छुएगा।';
      case 'telugu':
        return '💡 నీతి: మన ఇంగ్లీష్ సాధన వెదురు విత్తనం లాంటిది. మొదట్లో బయటకు కనిపించకపోయినా, లోపల వేర్లు బలంగా నాటుకుంటాయి. 90 రోజుల నిరంతర సాధనతో మీ ఆత్మవిశ్వాసం ఆకాశమంత ఎత్తుకు ఎదుగుతుంది.';
      case 'kannada':
        return '💡 ನೀತಿ: ನಮ್ಮ ಇಂಗ್ಲಿಷ್ ಅಭ್ಯಾಸವು ಬಿದಿರಿನ ಬೀಜದಂತಿದೆ. ಆರಂಭದಲ್ಲಿ ಮೇಲ್ನೋಟಕ್ಕೆ ಕಾಣಿಸದಿದ್ದರೂ, ಬೇರುಗಳು ಆಳವಾಗಿ ಬೆಳೆಯುತ್ತವೆ. 90 ದಿನಗಳ ನಿರಂತರ ಅಭ್ಯಾಸದಿಂದ ನಿಮ್ಮ ಆತ್ಮವಿಶ್ವಾಸವು ಎತ್ತರಕ್ಕೆ ಬೆಳೆಯುತ್ತದೆ.';
      case 'malayalam':
      default:
        return '💡 സന്ദേശം: നമ്മുടെ ഇംഗ്ലീഷ് പരിശീലനം മുളയുടെ വിത്ത് പോലെയാണ്. തുടക്കത്തിൽ പുറമെ വളർച്ച കാണുന്നില്ലെങ്കിലും വേരുകൾ ആഴത്തിൽ ഉറക്കുകയാണ്. 90 ദിവസത്തെ നിരന്തര പരിശീലനത്തിലൂടെ ആത്മവിശ്വാസം ഉയരങ്ങളിലേക്ക് വളരും.';
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _timerService.removeListener(_onTimerStateChanged);
    super.dispose();
  }

  void _loadVocabForDay() {
    if (widget.day == 2) {
      // 10 high-impact vocabulary words for Day 2 (Habits & Daily Routines) with Multilingual translations
      _vocabList = const [
        DailyVocabItem(
          word: 'Routine',
          partOfSpeech: 'noun',
          definition: 'A sequence of actions regularly followed.',
          malayalamMeaning: 'നിത്യകർമ്മം / ചിട്ടയായ ശീലം',
          tamilMeaning: 'வழக்கமான நடைமுறை',
          hindiMeaning: 'दिनचर्या / नियम',
          teluguMeaning: 'దినచర్య / నిత్యకృత్యం',
          kannadaMeaning: 'ದಿನಚರಿ / ವಾಡಿಕೆ',
          exampleSentence: 'A morning routine gives you focus for the entire day.',
          phonetic: '/ruːˈtiːn/',
        ),
        DailyVocabItem(
          word: 'Habit',
          partOfSpeech: 'noun',
          definition: 'A settled or regular tendency or practice.',
          malayalamMeaning: 'ശീലം / പതിവ്',
          tamilMeaning: 'பழக்கம் / வழக்கம்',
          hindiMeaning: 'आदत / स्वभाव',
          teluguMeaning: 'అలవాటు',
          kannadaMeaning: 'ಅಭ್ಯಾಸ / ರೂಢಿ',
          exampleSentence: 'Speaking English daily will soon become a natural habit.',
          phonetic: '/ˈhæb.ɪt/',
        ),
        DailyVocabItem(
          word: 'Chronological',
          partOfSpeech: 'adjective',
          definition: 'Arranged in the order of time of occurrence.',
          malayalamMeaning: 'കാലക്രമത്തിലുള്ള',
          tamilMeaning: 'காலவரிசைப்படி',
          hindiMeaning: 'कालक्रमानुसार',
          teluguMeaning: 'కాలక్రమానుసారమైన',
          kannadaMeaning: 'ಕಾಲಾನುಕ್ರಮದ',
          exampleSentence: 'Describe your daily activities in chronological order.',
          phonetic: '/ˌkrɒn.əˈlɒdʒ.ɪ.kəl/',
        ),
        DailyVocabItem(
          word: 'Frequently',
          partOfSpeech: 'adverb',
          definition: 'Regularly or with little time in between; often.',
          malayalamMeaning: 'അടിക്കടി / പലപ്പോഴും',
          tamilMeaning: 'அடிக்கடி',
          hindiMeaning: 'बार-बार / अक्सर',
          teluguMeaning: 'తరచుగా',
          kannadaMeaning: 'ಆಗಾಗ್ಗೆ / ಪದೇ ಪದೇ',
          exampleSentence: 'He frequently speaks with language mates to gain fluency.',
          phonetic: '/ˈfriː.kwənt.li/',
        ),
        DailyVocabItem(
          word: 'Seldom',
          partOfSpeech: 'adverb',
          definition: 'Not often; rarely.',
          malayalamMeaning: 'വല്ലപ്പോഴും മാത്രം / അപൂർവ്വമായി',
          tamilMeaning: 'எப்போதாவது / அரிதாக',
          hindiMeaning: 'कभी-कभार / शायद ही कभी',
          teluguMeaning: 'అరుదుగా',
          kannadaMeaning: 'ಅಪರೂಪವಾಗಿ',
          exampleSentence: 'Confident speakers seldom worry about little mistakes.',
          phonetic: '/ˈsel.dəm/',
        ),
        DailyVocabItem(
          word: 'Accomplish',
          partOfSpeech: 'verb',
          definition: 'To achieve or complete successfully.',
          malayalamMeaning: 'നിർവഹിക്കുക / പൂർത്തിയാക്കുക',
          tamilMeaning: 'சாதித்தல் / நிறைவேற்றுதல்',
          hindiMeaning: 'पूरा करना / हासिल करना',
          teluguMeaning: 'సాధించు / పూర్తిచేయు',
          kannadaMeaning: 'ಸಾಧಿಸು / ಪೂರೈಸು',
          exampleSentence: 'You will accomplish great fluency in 90 days.',
          phonetic: '/əˈkʌm.plɪʃ/',
        ),
        DailyVocabItem(
          word: 'Schedule',
          partOfSpeech: 'noun',
          definition: 'A plan of events or actions with specified times.',
          malayalamMeaning: 'സമയപ്പട്ടിക / നിശ്ചയിച്ച സമയം',
          tamilMeaning: 'கால அட்டவணை',
          hindiMeaning: 'समय सारणी / योजना',
          teluguMeaning: 'సమయ పట్టిక',
          kannadaMeaning: 'ವೇಳಾಪಟ್ಟಿ',
          exampleSentence: 'Set a daily schedule for reading and speaking practice.',
          phonetic: '/ˈʃedʒ.uːl/',
        ),
        DailyVocabItem(
          word: 'Prioritize',
          partOfSpeech: 'verb',
          definition: 'To designate or treat as more important than other things.',
          malayalamMeaning: 'മുൻഗണന നൽകുക',
          tamilMeaning: 'முன்னுரிமை அளித்தல்',
          hindiMeaning: 'प्राथमिकता देना',
          teluguMeaning: 'ప్రాధాన్యత ఇచ్చు',
          kannadaMeaning: 'ಆದ್ಯತೆ ನೀಡು',
          exampleSentence: 'Prioritize speaking over silent grammar memorization.',
          phonetic: '/praɪˈɒr.ɪ.taɪz/',
        ),
        DailyVocabItem(
          word: 'Productive',
          partOfSpeech: 'adjective',
          definition: 'Achieving or producing a significant or useful result.',
          malayalamMeaning: 'ഫലപ്രദമായ / കാര്യക്ഷമമായ',
          tamilMeaning: 'பയനുള്ള / ஆக்கபூர்வமான',
          hindiMeaning: 'उत्पादक / फलदायी',
          teluguMeaning: 'ఉత్పాదకమైన / ఉపయోగకరమైన',
          kannadaMeaning: 'ಉತ್ಪಾದಕ / ಪ್ರಯೋಜನಕಾರಿ',
          exampleSentence: 'Joining the audio call made my evening truly productive.',
          phonetic: '/prəˈdʌk.tɪv/',
        ),
        DailyVocabItem(
          word: 'Reflect',
          partOfSpeech: 'verb',
          definition: 'To think deeply or carefully about something.',
          malayalamMeaning: 'ചിന്തിച്ചുനോക്കുക / വിലയിരുത്തുക',
          tamilMeaning: 'ஆழமாக யோசித்தல் / பரிசீலித்தல்',
          hindiMeaning: 'विचार करना / मंथन करना',
          teluguMeaning: 'ఆలోచించు / సమీక్షించు',
          kannadaMeaning: 'ಆಲೋಚಿಸು / ಪರಿಶೀಲಿಸು',
          exampleSentence: 'Reflect on what you learned at the end of each mission.',
          phonetic: '/rɪˈflekt/',
        ),
      ];
      return;
    }

    // 10 high-impact vocabulary words for Day 1 with Multilingual translations
    _vocabList = const [
      DailyVocabItem(
        word: 'Ambition',
        partOfSpeech: 'noun',
        definition: 'A strong desire to achieve success or greatness.',
        malayalamMeaning: 'ഉയർന്ന ലക്ഷ്യം / ആഗ്രഹം',
        tamilMeaning: 'உயர்ந்த லட்சியம் / விருப்பம்',
        hindiMeaning: 'महत्वाकांक्षा / बड़ा लक्ष्य',
        teluguMeaning: 'గొప్ప ఆశయం / ఆకాంక్ష',
        kannadaMeaning: 'ಉನ್ನತ ಆಕಾಂಕ್ಷೆ / ಗುರಿ',
        exampleSentence: 'Her ambition is to speak fluent English with confidence.',
        phonetic: '/æmˈbɪʃ.ən/',
      ),
      DailyVocabItem(
        word: 'Courage',
        partOfSpeech: 'noun',
        definition: 'The ability to do something that frightens you; bravery.',
        malayalamMeaning: 'ധൈര്യം',
        tamilMeaning: 'தைரியம் / துணிவு',
        hindiMeaning: 'साहस / हिम्मत',
        teluguMeaning: 'ధైర్యం',
        kannadaMeaning: 'ಧೈರ್ಯ / ಸಾಹಸ',
        exampleSentence: 'Have the courage to speak without fear of making mistakes.',
        phonetic: '/ˈkʌr.ɪdʒ/',
      ),
      DailyVocabItem(
        word: 'Diligent',
        partOfSpeech: 'adjective',
        definition: 'Showing careful and persistent work and effort.',
        malayalamMeaning: 'കഠിനാധ്വാനം ചെയ്യുന്ന / ശ്രദ്ധാലുവായ',
        tamilMeaning: 'விடாமுயற்சியுள்ள / கடின உழைப்பாளி',
        hindiMeaning: 'परिश्रमी / मेहनती',
        teluguMeaning: 'శ్రద్ధగల / కష్టపడి పనిచేసే',
        kannadaMeaning: 'ಪರಿಶ್ರಮಿ / ಜಾಗರೂಕ',
        exampleSentence: 'A diligent student practices English every single day.',
        phonetic: '/ˈdɪl.ə.dʒənt/',
      ),
      DailyVocabItem(
        word: 'Express',
        partOfSpeech: 'verb',
        definition: 'To convey feelings, thoughts, or ideas in words.',
        malayalamMeaning: 'വ്യക്തമാക്കുക / പ്രകടിപ്പിക്കുക',
        tamilMeaning: 'வெளிப்படுத்து / விளக்கு',
        hindiMeaning: 'व्यक्त करना / कहना',
        teluguMeaning: 'వ్యక్తీకరించు / తెలుపు',
        kannadaMeaning: 'ವ್ಯಕ್ತಪಡಿಸು / ಪ್ರಕಟಿಸು',
        exampleSentence: 'Reading books will help you express your thoughts easily.',
        phonetic: '/ɪkˈspres/',
      ),
      DailyVocabItem(
        word: 'Fluency',
        partOfSpeech: 'noun',
        definition: 'The ability to speak or write a language easily and accurately.',
        malayalamMeaning: 'സരളത / അനായാസമായ സംസാരം',
        tamilMeaning: 'சரளம் / தடையற்ற பேச்சு',
        hindiMeaning: 'धाराप्रवाह / सहज बोलना',
        teluguMeaning: 'ధారాళత / నిరాటంక సంభాషణ',
        kannadaMeaning: 'ನಿರರ್ಗಳತೆ / ಸರಾಗ ಮಾತು',
        exampleSentence: 'Consistency across 90 days creates unstoppable fluency.',
        phonetic: '/ˈfluː.ən.si/',
      ),
      DailyVocabItem(
        word: 'Grateful',
        partOfSpeech: 'adjective',
        definition: 'Feeling or showing appreciation for kindness received.',
        malayalamMeaning: 'നന്ദിയുള്ള',
        tamilMeaning: 'நன்றியுடைய / கடமைப்பட்ட',
        hindiMeaning: 'आभारी / कृतज्ञ',
        teluguMeaning: 'కృతజ్ఞత గల',
        kannadaMeaning: 'ಕೃತಜ್ಞ / ಧನ್ಯವಾದ',
        exampleSentence: 'I am grateful for every mate who helps me practice speaking.',
        phonetic: '/ˈɡreɪt.fəl/',
      ),
      DailyVocabItem(
        word: 'Hesitate',
        partOfSpeech: 'verb',
        definition: 'To pause before saying or doing something through uncertainty.',
        malayalamMeaning: 'മടിക്കുക / സംശയിച്ചു നിൽക്കുക',
        tamilMeaning: 'தயங்குதல் / தயக்கம்',
        hindiMeaning: 'हिचकिचाना / झिझकना',
        teluguMeaning: 'సంకోచించు / తటపటాయించు',
        kannadaMeaning: 'ಹಿಂಜರಿಯು / ಅನುಮಾನಿಸು',
        exampleSentence: 'Do not hesitate when speaking; just let the words flow.',
        phonetic: '/ˈhez.ə.teɪt/',
      ),
      DailyVocabItem(
        word: 'Inspire',
        partOfSpeech: 'verb',
        definition: 'To fill someone with the urge or ability to do something.',
        malayalamMeaning: 'പ്രചോദിപ്പിക്കുക',
        tamilMeaning: 'ஊக்கப்படுத்து / ஊக்கம் அளி',
        hindiMeaning: 'प्रेरित करना',
        teluguMeaning: 'ప్రేరేపించు / ఉత్సాహపరచు',
        kannadaMeaning: 'ಪ್ರೇರೇಪಿಸು / ಸ್ಪೂರ್ತಿ ನೀಡು',
        exampleSentence: 'Great communicators inspire people around the world.',
        phonetic: '/ɪnˈspaɪər/',
      ),
      DailyVocabItem(
        word: 'Journey',
        partOfSpeech: 'noun',
        definition: 'An act of traveling from one place or milestone to another.',
        malayalamMeaning: 'യാത്ര / ഘട്ടം',
        tamilMeaning: 'பயணம் / வளர்ச்சிப் பாதை',
        hindiMeaning: 'यात्रा / सफर',
        teluguMeaning: 'ప్రయాణం / ప్రస్థానం',
        kannadaMeaning: 'ಪ್ರಯಾಣ / ಹಂತ',
        exampleSentence: 'Your transformative 90-day English journey begins today.',
        phonetic: '/ˈdʒɜː.ni/',
      ),
      DailyVocabItem(
        word: 'Knowledge',
        partOfSpeech: 'noun',
        definition: 'Facts, information, and skills acquired through experience.',
        malayalamMeaning: 'അറിവ്',
        tamilMeaning: 'அறிவு / ஞானம்',
        hindiMeaning: 'ज्ञान / विद्या',
        teluguMeaning: 'జ్ఞానము',
        kannadaMeaning: 'ಜ್ಞಾನ / ತಿಳುವಳಿಕೆ',
        exampleSentence: 'Knowledge is gained by learning, and fluency by speaking.',
        phonetic: '/ˈnɒl.ɪdʒ/',
      ),
    ];
  }

  Future<void> _loadSavedMissionState() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    setState(() {
      _selectedLanguage = prefs.getString('pocket_mission_pref_lang') ?? 'Malayalam';
      _hubChatVerified = prefs.getBool('${dayKey}_hub_chat') ?? false;
      _peerCallVerified = prefs.getBool('${dayKey}_peer_call') ?? false;
      _vocabMemorized = prefs.getBool('${dayKey}_vocab_mem') ?? false;
      _readingNotesCompleted = prefs.getBool('${dayKey}_reading') ?? false;
      _revisionQuizPassed = prefs.getBool('${dayKey}_quiz') ?? false;
      _defenseTrapArmed = prefs.getBool('${dayKey}_defense') ?? false;
      _trialRaidLaunched = prefs.getBool('${dayKey}_raid') ?? false;
    });
  }

  Future<void> _saveSubtask(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    await prefs.setBool('${dayKey}_$key', value);
  }

  int get _completedSubtasksCount {
    int count = 0;
    if (_hubChatVerified) count++;
    if (_peerCallVerified) count++;
    if (_vocabMemorized) count++;
    if (_readingNotesCompleted) count++;
    if (_revisionQuizPassed) count++;
    if (_defenseTrapArmed) count++;
    if (_trialRaidLaunched) count++;
    return count;
  }

  bool get _isAllCompleted => _completedSubtasksCount >= 7;
  bool get _isTimerCompleted => _timerService.hasReachedTarget;
  bool get _canClaimAndAdvance => _isTimerCompleted && _isAllCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // Subtle dark vignette background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF070B14)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Deck
                _buildHeader(context),

                // Mission Body Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      // ⏱️ 60-Min Daily Practice Study Timer Card
                      _buildDailyStudyTimerCard(),

                      const SizedBox(height: 18),

                      // 📋 Mission Subtasks Tracker Header
                      _buildMissionProgressCard(),

                      const SizedBox(height: 18),

                      // Subtask 1: 💬 English Hub Group Practice
                      _buildSubtaskCard(
                        stepNumber: '1',
                        icon: '💬',
                        title: 'English Hub Group Practice',
                        description: 'Enter the active English Hub and send at least 10–15 English messages to fellow learners to build active muscle memory.',
                        isVerified: _hubChatVerified,
                        actionLabel: 'OPEN ENGLISH HUB CHAT',
                        actionColor: const Color(0xFFFFFC00),
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WhatsAppGroupChat(
                                groupId: 'english_hub',
                                groupName: 'English Hub',
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _hubChatVerified = true);
                              _saveSubtask('hub_chat', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _hubChatVerified = true);
                          _saveSubtask('hub_chat', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 2: 🎙️ Anonymous Peer Talk / Call
                      _buildSubtaskCard(
                        stepNumber: '2',
                        icon: '🎙️',
                        title: 'Peer Call / 1-on-1 English Talk',
                        description: 'Connect with 2 mates for live conversation practice to conquer speaking hesitation.',
                        isVerified: _peerCallVerified,
                        actionLabel: 'FIND 1-ON-1 PEERS',
                        actionColor: const Color(0xFF00E5FF),
                        onAction: () {
                          // Auto-start 60-min practice timer as instructed in audio
                          if (!_timerService.isRunning && !_timerService.hasReachedTarget) {
                            _timerService.toggleTimer();
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StagePeerMatchmakerPage(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _peerCallVerified = true);
                              _saveSubtask('peer_call', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _peerCallVerified = true);
                          _saveSubtask('peer_call', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 3: 🧠 10 Vocabulary Words to Memorize
                      _buildVocabDeckCard(),

                      const SizedBox(height: 14),

                      // Subtask 4: 📖 Core Notes & Reading Passage
                      _buildReadingNotesCard(),

                      const SizedBox(height: 14),

                      // Subtask 5: ✍️ Quick Revision Mini-Quiz
                      _buildRevisionQuizCard(),

                      const SizedBox(height: 14),

                      // Subtask 6: 🛡️ Craft Citadel Defense Trap
                      _buildSubtaskCard(
                        stepNumber: '6',
                        icon: '🛡️',
                        title: 'Add Day ${widget.day} Citadel Defense Shield',
                        description: 'Arm your front gate with 1 authentic English challenge to defend your house from raiders. (Shield Slot ${widget.day} of ${widget.day})',
                        isVerified: _defenseTrapArmed,
                        actionLabel: _defenseTrapArmed ? 'EDIT DEFENSE SHIELD 🛡️' : 'ADD DEFENSE SHIELD 🛡️',
                        actionColor: const Color(0xFF8B5CF6),
                        onAction: () {
                          PocketDefenseTrapModal.show(context, widget.day);
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                        onVerify: () {
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 7: ⚔️ Launch First Trial Raid
                      _buildSubtaskCard(
                        stepNumber: '7',
                        icon: '⚔️',
                        title: 'First Trial Siege Attack (Level 5 House)',
                        description: 'Launch your first raid against a Level 5 Neighbor Citadel in the Battle Arena to test your combat English!',
                        isVerified: _trialRaidLaunched,
                        actionLabel: 'LAUNCH BATTLE ARENA RAID',
                        actionColor: const Color(0xFFEF4444),
                        onAction: () {
                          final rival = PocketNeighbor(
                            id: 'trial_citadel_lvl5',
                            name: 'Shadow Sentinel Lvl 5',
                            day: 5,
                            streak: 8,
                            rank: 'Rival Fortress',
                            paletteId: 'regal_amethyst',
                            statusMessage: 'Can you breach my English gates?',
                            hasActiveShield: true,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PocketBattleArenaPage(
                                neighbor: rival,
                                userDay: widget.day,
                                userStreak: 1,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _trialRaidLaunched = true);
                              _saveSubtask('raid', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _trialRaidLaunched = true);
                          _saveSubtask('raid', true);
                        },
                      ),

                      const SizedBox(height: 20),

                      // 🛡️ House Defense Shield Banner (Audio Directive: Show right inside Day 1!)
                      _buildShieldUnlockBanner(),

                      const SizedBox(height: 10),

                      // 🏆 Final Mission Completion Button
                      _buildFinalClaimButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TOP APP BAR HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DAY ${widget.day}',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ENGLISH LEARNING MISSION',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stage ${widget.day}/90 • Foundation & First Steps',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$_completedSubtasksCount/7 Done',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFC00),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ⏱️ 60-MINUTE PRACTICE TIMER CARD ---
  Widget _buildDailyStudyTimerCard() {
    final isRunning = _timerService.isRunning;
    final isTargetMet = _timerService.hasReachedTarget;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRunning
              ? const Color(0xFFFFD700)
              : (isTargetMet ? const Color(0xFF10B981) : Colors.white12),
          width: (isRunning || isTargetMet) ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isRunning)
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          if (isTargetMet)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'DAILY 60-MIN PRACTICE TIMER',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isRunning
                      ? Colors.green.withValues(alpha: 0.2)
                      : (isTargetMet
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.white10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isRunning
                      ? 'ACTIVE'
                      : (isTargetMet
                          ? 'TARGET MET'
                          : _timerService.pauseReason.toUpperCase()),
                  style: TextStyle(
                    color: isRunning
                        ? Colors.greenAccent
                        : (isTargetMet ? const Color(0xFF10B981) : Colors.white54),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rule: Spend 60+ mins practicing English daily (chat, voice calls, drills). Pauses when leaving app.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _timerService.formatTime(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/ ${_timerService.formatTime(_timerService.targetSeconds)} Target',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _timerService.progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isTargetMet
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFFC00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (isTargetMet) {
                    _timerService.addAnotherHourPractice();
                  } else {
                    _timerService.toggleTimer();
                  }
                },
                icon: Icon(
                  isRunning
                      ? Icons.pause_rounded
                      : (isTargetMet ? Icons.add_alarm_rounded : Icons.play_arrow_rounded),
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  isRunning
                      ? 'PAUSE'
                      : (isTargetMet ? '+60m' : 'START'),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning
                      ? Colors.amberAccent
                      : (isTargetMet ? const Color(0xFF10B981) : const Color(0xFFFFFC00)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          // ⚠️ Extra Hour Prompt Banner when 60 minutes are met but subtasks remain
          if (isTargetMet && !_isAllCompleted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '60-Min Target Reached! (${7 - _completedSubtasksCount} subtasks pending)',
                          style: GoogleFonts.outfit(
                            color: Colors.amberAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice timer automatically stopped at 60:00. You must complete all 7 subtasks to advance to Day ${widget.day + 1}. Complete the tasks below, or add an extra 1-hour practice session.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.addAnotherHourPractice();
                          },
                          icon: const Icon(Icons.add_alarm_rounded, size: 16, color: Color(0xFFFFFC00)),
                          label: Text(
                            '+ ADD 1-HR PRACTICE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFFC00),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFFC00)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.restartPracticeSession();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                          label: Text(
                            'RESTART 1-HR RUN',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 📋 OVERALL MISSION PROGRESS CARD ---
  Widget _buildMissionProgressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎯', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${widget.day} Subtask Checklist',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete all 7 actions below to claim Day ${widget.day} rewards & badge.',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${((_completedSubtasksCount / 7) * 100).toInt()}%',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFFC00),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --- GENERIC SUBTASK CARD ---
  Widget _buildSubtaskCard({
    required String stepNumber,
    required String icon,
    required String title,
    required String description,
    required bool isVerified,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
    required VoidCallback onVerify,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFF10B981) : Colors.white12,
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP $stepNumber',
                  style: TextStyle(
                    color: isVerified ? Colors.black : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: actionColor,
                    side: BorderSide(color: actionColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onVerify,
                icon: Icon(isVerified ? Icons.check_rounded : Icons.done_all_rounded, color: Colors.black, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isVerified ? const Color(0xFF10B981) : Colors.white24,
                ),
                tooltip: 'Mark Complete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🌐 Language Category Selector Bar (Audio Directive)
  Widget _buildLanguageSelectorBar() {
    final languageFlags = {
      'Malayalam': 'മലയാളം',
      'Tamil': 'தமிழ்',
      'Hindi': 'हिन्दी',
      'Telugu': 'తెలుగు',
      'Kannada': 'ಕನ್ನಡ',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Translation Language:',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _selectedLanguage,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kSupportedLanguages.map((lang) {
                final isSelected = _selectedLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _onLanguageSelected(lang),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        languageFlags[lang] ?? lang,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 3: 🧠 10 VOCABULARY WORDS TO MEMORIZE CARD ---
  Widget _buildVocabDeckCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906).withValues(alpha: 0.5),
          width: _vocabMemorized ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('STEP 3', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '10 Core Vocabulary Words to Memorize',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_vocabMemorized)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Memorize all 10 words below (definitions, native meanings & audio pronunciation):',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // 🌐 Multilingual Category Switcher Bar (Audio Directive)
          _buildLanguageSelectorBar(),

          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vocabList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final v = _vocabList[idx];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${idx + 1}', style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.word,
                                style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.phonetic,
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${v.partOfSpeech})',
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📖 ${v.definition}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🗣️ Meaning ($_selectedLanguage): ${v.getMeaning(_selectedLanguage)}',
                            style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '💡 "${v.exampleSentence}"',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 20),
                      onPressed: () => _speakWord('${v.word}. ${v.exampleSentence}'),
                      tooltip: 'Pronounce',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _vocabMemorized = true);
                _saveSubtask('vocab_mem', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 10 Vocabulary Words memorized and recorded!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(_vocabMemorized ? Icons.check_circle_rounded : Icons.star_rounded, color: Colors.black),
              label: Text(
                _vocabMemorized ? '10 WORDS MEMORIZED ✓' : 'I MEMORIZED ALL 10 WORDS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 4: 📖 CORE NOTES & AUTHENTIC STORY READING CARD ---
  Widget _buildReadingNotesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
          width: _readingNotesCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 4', style: TextStyle(color: _readingNotesCompleted ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('📖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Grammar Notes & Authentic Story Reading',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_readingNotesCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),

          // Grammar Concept Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.day == 2
                          ? 'Rule 2: Adverbs of Frequency (Always, Usually, Often...)'
                          : 'Rule 1: Sentence Structure (S + V + O)',
                      style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getGrammarRuleExplanation(_selectedLanguage),
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 📖 Authentic Story Card (Audio Directive: Authentic story with TTS speaker reader!)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.day == 2 ? '⏰' : '🎋', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.day == 2
                                ? 'DAY 2 STORY: THE MORNING RITUAL OF CHAMPIONS'
                                : 'DAY 1 STORY: THE SEED OF CONFIDENCE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            widget.day == 2
                                ? 'The Power of Habits & Morning Routine Practice'
                                : 'Aloud Reading & Pronunciation Practice',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isStorySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        color: _isStorySpeaking ? Colors.redAccent : const Color(0xFFFFFC00),
                        size: 22,
                      ),
                      tooltip: _isStorySpeaking ? 'Stop Reading' : 'Read Aloud (TTS)',
                      onPressed: () => _speakStory(widget.day == 2 ? _kDay2StoryText : _kDay1StoryText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.day == 2
                      ? '"Marcus was an ambitious learner who struggled to find time for English. Every evening he felt exhausted and postponed his speaking practice to tomorrow. One day, his grandfather handed him an empty notebook with golden edges: \'We do not decide our future. We decide our daily habits, and our habits decide our future...\'"'
                      : '"A young student once stood by a tall bamboo tree, hesitant to practice speaking English. He was afraid of making mistakes in front of others. A wise mentor approached him: \'For four years, the bamboo roots grow deep underground in silence. Then, in the fifth year, it shoots up eighty feet into the sky! Your daily English practice is just like that seed...\'"',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStorySummary(_selectedLanguage),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Full Story Reader, Read Books, Read Aloud Done
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showStoryDetailModal,
                  icon: const Icon(Icons.menu_book_rounded, color: Colors.black, size: 15),
                  label: Text(
                    'STORY READER',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PocketLibraryPage()),
                    ).then((_) {
                      if (mounted) {
                        setState(() => _readingNotesCompleted = true);
                        _saveSubtask('reading', true);
                      }
                    });
                  },
                  icon: const Icon(Icons.auto_stories_rounded, color: Colors.black, size: 15),
                  label: Text(
                    'READ BOOKS 📚',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _readingNotesCompleted = true);
                    _saveSubtask('reading', true);
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(
                    _readingNotesCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
                    color: const Color(0xFFFFFC00),
                    size: 15,
                  ),
                  label: Text(
                    _readingNotesCompleted ? 'DONE ✓' : 'FINISHED',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFFC00)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📖 Full Interactive Story Reader Modal (Audio Directive: Story details view with TTS)
  void _showStoryDetailModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, modalSetState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.day == 2
                                ? 'DAY 2 STORY: THE MORNING RITUAL OF CHAMPIONS'
                                : 'DAY 1 STORY: THE SEED OF CONFIDENCE',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            widget.day == 2
                                ? 'The Power of Habits & Morning Routine Guide'
                                : 'Authentic Short Story Reading & Pronunciation Guide',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () {
                        _tts.stop();
                        if (mounted) setState(() => _isStorySpeaking = false);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Audio Narrator Controller Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_isStorySpeaking) {
                            _tts.stop();
                            modalSetState(() => _isStorySpeaking = false);
                            setState(() => _isStorySpeaking = false);
                          } else {
                            modalSetState(() => _isStorySpeaking = true);
                            setState(() => _isStorySpeaking = true);
                            _tts.setCompletionHandler(() {
                              if (mounted) {
                                modalSetState(() => _isStorySpeaking = false);
                                setState(() => _isStorySpeaking = false);
                              }
                            });
                            _tts.speak(widget.day == 2 ? _kDay2StoryText : _kDay1StoryText);
                          }
                        },
                        icon: Icon(
                          _isStorySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          _isStorySpeaking ? 'STOP NARRATOR' : 'LISTEN TO NARRATOR (TTS)',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _selectedLanguage,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            widget.day == 2 ? _kDay2StoryFormatted : _kDay1StoryFormatted,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _getStorySummary(_selectedLanguage),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6EE7B7),
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tts.stop();
                      setState(() {
                        _readingNotesCompleted = true;
                        _isStorySpeaking = false;
                      });
                      _saveSubtask('reading', true);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Day 1 Story Reading completed!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
                    label: Text(
                      'I FINISHED READING THIS STORY ✓',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SUBTASK 5: ✍️ QUICK REVISION MINI-QUIZ CARD ---
  Widget _buildRevisionQuizCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
          width: _revisionQuizPassed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 5', style: TextStyle(color: _revisionQuizPassed ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('✍️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quick Revision Mini-Quiz',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_revisionQuizPassed)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.day == 2
                ? 'Q: Which sentence uses the adverb of frequency correctly?'
                : 'Q: Which sentence follows the correct English "Subject + Verb + Object" order?',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (i) {
            final options = widget.day == 2
                ? [
                    'I always practice speaking in the morning.',
                    'I practice always speaking in the morning.',
                    'Always I practice in the morning speaking.',
                  ]
                : [
                    'She reads books diligently.',
                    'She books reads diligently.',
                    'Reads she books diligently.',
                  ];
            final isCorrect = i == 0;
            final isSelected = _selectedQuizAnswer == i;

            Color optionBg = const Color(0xFF1E293B);
            if (_quizSubmitted) {
              if (isCorrect) optionBg = const Color(0xFF10B981).withValues(alpha: 0.3);
              if (isSelected && !isCorrect) optionBg = Colors.red.withValues(alpha: 0.3);
            } else if (isSelected) {
              optionBg = const Color(0xFFFFFC00).withValues(alpha: 0.2);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: optionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                ),
              ),
              child: ListTile(
                title: Text(
                  options[i],
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                onTap: _quizSubmitted
                    ? null
                    : () {
                        setState(() => _selectedQuizAnswer = i);
                        HapticFeedback.lightImpact();
                      },
                trailing: isSelected ? const Icon(Icons.radio_button_checked, color: Color(0xFFFFFC00), size: 18) : null,
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedQuizAnswer == -1
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = true;
                        if (_selectedQuizAnswer == 0) {
                          _revisionQuizPassed = true;
                          _saveSubtask('quiz', true);
                        }
                      });
                      HapticFeedback.mediumImpact();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _revisionQuizPassed ? 'QUIZ PASSED ✓' : 'SUBMIT ANSWER',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🛡️ HOUSE DEFENSE SHIELD UNLOCK BANNER ---
  Widget _buildShieldUnlockBanner() {
    final allSubtasksDone = _completedSubtasksCount >= 7;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _defenseTrapArmed
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : (allSubtasksDone
                  ? [const Color(0xFF3B0764), const Color(0xFF1E1B4B)]
                  : [const Color(0xFF1E293B), const Color(0xFF0F172A)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _defenseTrapArmed
              ? const Color(0xFF10B981)
              : (allSubtasksDone ? const Color(0xFFFFD700) : Colors.white12),
          width: 1.5,
        ),
        boxShadow: [
          if (allSubtasksDone && !_defenseTrapArmed)
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.3),
              blurRadius: 14,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _defenseTrapArmed
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFFFFFC00).withValues(alpha: 0.15),
              border: Border.all(
                color: _defenseTrapArmed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFFC00),
                width: 1.2,
              ),
            ),
            child: Text(
              _defenseTrapArmed ? '🛡️' : '⚔️',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DAY ${widget.day} DEFENSE SHIELD',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: _defenseTrapArmed
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _defenseTrapArmed ? 'ACTIVE ✓' : 'SLOT READY',
                        style: TextStyle(
                          color: _defenseTrapArmed
                              ? const Color(0xFF10B981)
                              : Colors.amberAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _defenseTrapArmed
                      ? 'House protection active! Question ${widget.day} is guarding your gate against raiders.'
                      : 'Craft 1 tricky English question to arm your house shield against raiders in Pocket World!',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              PocketDefenseTrapModal.show(context, widget.day);
              setState(() => _defenseTrapArmed = true);
              _saveSubtask('defense', true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _defenseTrapArmed
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFFFC00),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _defenseTrapArmed ? 'EDIT 🛡️' : 'ADD SHIELD',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🏆 FINAL CLAIM & ADVANCE BUTTON ---
  Widget _buildFinalClaimButton() {
    final isTimerMet = _isTimerCompleted;
    final isSubtasksMet = _isAllCompleted;
    final canClaim = _canClaimAndAdvance;

    String headerTitle;
    String description;
    String buttonText;

    if (canClaim) {
      headerTitle = '🎉 MISSION COMPLETED!';
      description =
          '60-Minute practice target met & all 7 subtasks verified! Claim +100 XP, +40 Fortress Defense Coins and unlock Day ${widget.day + 1}!';
      buttonText = 'CLAIM DAY ${widget.day} REWARDS & ADVANCE 🚀';
    } else if (isTimerMet && !isSubtasksMet) {
      headerTitle = '⚠️ ${7 - _completedSubtasksCount} SUBTASKS REMAINING';
      description =
          'Practice time target (60m) completed! You must complete all 7 subtasks below before unlocking Day ${widget.day + 1}.';
      buttonText = 'FINISH ${7 - _completedSubtasksCount} MORE SUBTASKS TO ADVANCE';
    } else if (!isTimerMet && isSubtasksMet) {
      headerTitle = '⏱️ PRACTICE TIME TARGET PENDING';
      description =
          'All 7 subtasks are verified! Practice for ${_timerService.formatTime(_timerService.remainingSeconds)} more minutes in app chats, drills, or calls to complete the 60-min target.';
      buttonText = 'PRACTICE ${_timerService.formatTime(_timerService.remainingSeconds)} MORE TO ADVANCE';
    } else {
      headerTitle = 'PRACTICE TARGET & SUBTASKS PENDING';
      description =
          'Progress: ${_timerService.formatTime()}/${_timerService.formatTime(_timerService.targetSeconds)} practice time • $_completedSubtasksCount/7 subtasks verified.';
      buttonText = '${7 - _completedSubtasksCount} SUBTASKS & ${_timerService.formatTime(_timerService.remainingSeconds)} REMAINING';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim
              ? const [Color(0xFF10B981), Color(0xFF047857)]
              : const [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (canClaim)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            headerTitle,
            style: GoogleFonts.outfit(
              color: canClaim ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim
                  ? () async {
                      HapticFeedback.heavyImpact();
                      if (!_defenseTrapArmed) {
                        PocketDefenseTrapModal.show(context, widget.day);
                        setState(() => _defenseTrapArmed = true);
                        _saveSubtask('defense', true);
                      }
                      final uid = SupaFlow.client.auth.currentUser?.id;
                      if (uid != null) {
                        await Learning60DayService().completeTask(
                          userId: uid,
                          taskId: 'day_${widget.day}_mission',
                        );
                        await PocketFortressDefenseService.recordActivityPoints(
                          'daily_mission',
                        );
                      }
                      widget.onMissionCompleted?.call();
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 Day ${widget.day} English Mission Complete! +100 XP • Day ${widget.day + 1} Unlocked!',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.outfit(
                  color: canClaim ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
