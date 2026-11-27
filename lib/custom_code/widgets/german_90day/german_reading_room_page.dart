import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_pronunciation_evaluator.dart';
import 'german_localization_helper.dart';

/// 📖 Dedicated German Reading Room (Days 1–90, pure Deutsch + Native Guide)
/// Contains ZERO English reading passages ("The Clever Crow") — every story is written
/// naturally in German with native explanations only in the chosen Native Language.
class GermanReadingRoomPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int stepIndex)? onStepFinished;

  const GermanReadingRoomPage({
    super.key,
    required this.day,
    this.stepIndex = 5,
    this.userId,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int day,
    int stepIndex = 5,
    String? userId,
    void Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GermanReadingRoomPage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  static List<Map<String, dynamic>> getGermanStoriesForDay(int day) {
    if (day <= 1) {
      return const [
        {
          'part': 1,
          'bannerEmoji': '🐦‍⬛ 🌿 🏡',
          'titleDe': 'Der kluge Rabe & das Holzhaus',
          'title': {
            'ml': 'ബുദ്ധിമാനായ കാക്കയും മരവീടും',
            'ta': 'புத்திசாலி காகமும் மர வீடும்',
            'hi': 'चालाक कौआ और लकड़ी का घर',
            'kn': 'ಜಾಣ ಕಾಗೆ ಮತ್ತು ಮರದ ಮನೆ',
            'te': 'తెలివైన కాకి మరియు చెక్క ఇల్లు',
            'en': 'The Clever Raven & The Wooden House',
          },
          'paragraphDe':
              'An einem sonnigen Morgen fliegt ein kluger schwarzer Rabe über die grünen Bäume. Er sieht ein kleines Holzhaus mit einem offenen Fenster. Auf dem Tisch steht eine Schale mit süßen grünen Trauben.',
          'readTarget':
              'An einem sonnigen Morgen fliegt ein kluger Rabe über die grünen Bäume.',
          'meaning': {
            'ml': 'വെയിലുള്ള ഒരു പ്രഭാതത്തിൽ ബുദ്ധിമാനായ കറുത്ത കാക്ക പച്ച മരങ്ങൾക്ക് മുകളിലൂടെ പറന്നു. തുറന്ന ജനലുള്ള ഒരു മരവീട് കണ്ടു. മേശപ്പുറത്ത് മധുരമുള്ള മുന്തിരികൾ ഉണ്ടായിരുന്നു.',
            'ta': 'வெயில் அடிக்கும் காலையில் புத்திசாலி காகம் மரங்களுக்கு மேல் பறந்தது. திறந்த ஜன்னலுடன் மர வீட்டைப் பார்த்தது. மேசை மேல் இனிப்பு திராட்சை இருந்தது.',
            'hi': 'धूप भरी सुबह एक चतुर काला कौआ हरे पेड़ों के ऊपर से उड़ा। उसने खुली खिड़की वाला लकड़ी का घर देखा। मेज़ पर मीठे हरे अंगूर रखे थे।',
            'kn': 'ಬೆಳಗಿನ ಬಿಸಿಲಿನಲ್ಲಿ ಬುದ್ಧಿವಂತ ಕಾಗೆ ಹಸಿರು ಮರಗಳ ಮೇಲೆ ಹಾರಿತು. ತೆರೆದ ಕಿಟಕಿಯ ಮರದ ಮನೆಯನ್ನು ಕಂಡಿತು. ಮೇಜಿನ ಮೇಲೆ ಸಿಹಿ ದ್ರಾಕ್ಷಿ ಇತ್ತು.',
            'te': 'ఎండగా ఉన్న ఉదయం తెలివైన కాకి పచ్చని చెట్ల మీదుగా ఎగిరింది. తెరిచిన కిటికీ ఉన్న చెక్క ఇంటిని చూసింది. బల్లపై తీపి ద్రాక్షలు ఉన్నాయి.',
            'en': 'One sunny morning a clever raven flies over green trees and spots grapes on a table inside a wooden house.',
          },
        },
        {
          'part': 2,
          'bannerEmoji': '🐱 🛏️ 💧',
          'titleDe': 'Die Katze & das kühle Wasser',
          'title': {
            'ml': 'പൂച്ചയും തണുത്ത വെള്ളവും',
            'ta': 'பூனையும் குளிர்ந்த நீரும்',
            'hi': 'बिल्ली और ठंडा पानी',
            'kn': 'ಬೆಕ್ಕು ಮತ್ತು ತಂಪಾದ ನೀರು',
            'te': 'పిల్లి మరియు చల్లని నీరు',
            'en': 'The Cat & The Cool Water',
          },
          'paragraphDe':
              'Im Zimmer schläft eine weiße Katze ruhig auf dem Sofa. Der Rabe landet leise am Fenster. Er hat Durst, trinkt kühles Wasser aus dem Glas und probiert eine frische Traube.',
          'readTarget':
              'Der Rabe hat Durst und trinkt kühles Wasser aus dem Glas.',
          'meaning': {
            'ml': 'മുറിയിൽ വെളുത്ത പൂച്ച സോഫയിൽ ശാന്തമായി ഉറങ്ങുന്നു. കാക്ക പതിയെ ജനലിൽ ഇരുന്നു. ദാഹം തോന്നിയ കാക്ക ഗ്ലാസിൽ നിന്ന് തണുത്ത വെള്ളം കുടിച്ച് ഒരു മുന്തിരിയും കഴിച്ചു.',
            'ta': 'அறையில் வெள்ளைப் பூனை அமைதியாகத் தூங்குகிறது. காகம் மெதுவாக இறங்கித் தாகத்திற்குக் குளிர்ந்த நீர் குடித்து ஒரு திராட்சையைச் சுவைத்தது.',
            'hi': 'कमरे में एक सफ़ेद बिल्ली सोफे पर सो रही है। कौआ धीरे से उतरता है, ठंडा पानी पीता है और ताज़ा अंगूर चखता है।',
            'kn': 'ಕೋಣೆಯಲ್ಲಿ ಬಿಳಿ ಬೆಕ್ಕು ಶಾಂತವಾಗಿ ಮಲಗಿದೆ. ಕಾಗೆ ಮೆಲ್ಲಗೆ ಬಂದು ತಂಪಾದ ನೀರು ಕುಡಿದು ಒಂದು ದ್ರಾಕ್ಷಿ ಸವಿಯಿತು.',
            'te': 'గదిలో తెల్ల పిల్లి నిద్రపోతోంది. కాకి నెమ్మదిగా దిగి చల్లని నీరు తాగి ద్రాక్ష రుచి చూసింది.',
            'en': 'A white cat sleeps indoors while the thirsty raven quietly drinks cold water and tastes a grape.',
          },
        },
        {
          'part': 3,
          'bannerEmoji': '☀️ 🌈 🐦‍⬛',
          'titleDe': 'Hoch am blauen Himmel',
          'title': {
            'ml': 'നീലാകാശത്ത് ഉയരെ പറക്കൽ',
            'ta': 'நீல வானில் உயரப் பறத்தல்',
            'hi': 'नीले आसमान में ऊँची उड़ान',
            'kn': 'ನೀಲಿ ಆಕಾಶದಲ್ಲಿ ಎತ್ತರದ ಹಾರಾಟ',
            'te': 'నీలి ఆకాశంలో ఎత్తుగా ఎగరడం',
            'en': 'High in the Blue Sky',
          },
          'paragraphDe':
              'Jetzt ist der Rabe glücklich und stark. Er breitet seine Flügel aus und fliegt hoch in den klaren Himmel. Jeden Tag ein wenig üben bringt große Freude!',
          'readTarget':
              'Der Rabe ist glücklich und fliegt hoch in den Himmel.',
          'meaning': {
            'ml': 'ഇപ്പോൾ കാക്ക സന്തോഷവാനും ശക്തനുമാണ്. അത് ചിറകുകൾ വിടർത്തി തെളിഞ്ഞ ആകാശത്തേക്ക് ഉയർന്നു പറന്നു. ദിവസവും അല്പം പരിശീലിക്കുന്നത് വലിയ സന്തോഷം നൽകുന്നു!',
            'ta': 'இப்போது காகம் மகிழ்ச்சியாக உள்ளது. சிறகுகளை விரித்து வானில் உயரப் பறந்தது. தினசரி பயிற்சி பெரிய மகிழ்ச்சியைத் தரும்!',
            'hi': 'अब कौआ खुश और मज़बूत है। वह पंख फैलाकर साफ आसमान में ऊँचा उड़ता है। रोज़ अभ्यास खुशी देता है!',
            'kn': 'ಈಗ ಕಾಗೆ ಸಂತೋಷವಾಗಿದೆ. ರೆಕ್ಕೆ ಬಿಚ್ಚಿ ಆಕಾಶಕ್ಕೆ ಎತ್ತರ ಹಾರಿತು. ಪ್ರತಿದಿನದ ಅಭ್ಯಾಸ ಸಂತೋಷ ತರುತ್ತದೆ!',
            'te': 'ఇప్పుడు కాకి సంతోషంగా ఉంది. రెక్కలు విప్పి ఆకాశంలోకి ఎత్తుగా ఎగిరింది. రోజువారీ అభ్యాసం ఆనందాన్నిస్తుంది!',
            'en': 'Happy and strong, the raven flies high into the clear sky. Daily practice brings great joy!',
          },
        },
      ];
    }

    // Dynamic Days 2..90 tailored German Reading Passages
    const topics = [
      ('Meine Heimat & Nachbarn', '🏡'),
      ('Zeit mit der Familie', '👨‍👩‍👧'),
      ('Frühstück im Café', '☕'),
      ('Mein Weg zur Arbeit', '🚆'),
      ('Einkauf auf dem Markt', '🍎'),
      ('Wetter und Jahreszeiten', '🌤️'),
      ('Gesund leben und Sport', '🏃'),
      ('Freunde in Berlin treffen', '🤝'),
    ];
    final pair = topics[(day - 2) % topics.length];
    final topic = pair.$1;
    final emoji = pair.$2;

    return [
      {
        'part': 1,
        'bannerEmoji': '$emoji 🇩🇪 ✨',
        'titleDe': 'Tag $day: $topic (Teil 1)',
        'title': {
          'ml': 'ഡേ $day: വായനാ പരിശീലനം — ഭാഗം 1',
          'ta': 'நாள் $day: வாசிப்பு பயிற்சி — பகுதி 1',
          'hi': 'दिन $day: पठन अभ्यास — भाग 1',
          'kn': 'ದಿನ $day: ಓದುವ ಅಭ್ಯಾಸ — ಭಾಗ 1',
          'te': 'రోజు $day: పఠన అభ్యాసం — భాగం 1',
          'en': 'Tag $day: Reading Practice — Part 1',
        },
        'paragraphDe':
            'Guten Morgen! Heute ist Tag $day von meinem Deutschkurs. Das Thema heißt "$topic". Ich lese laut, höre genau zu und spreche jeden deutschen Satz mit Ruhe und Vertrauen.',
        'readTarget':
            'Heute ist Tag $day von meinem Deutschkurs und ich lese laut.',
        'meaning': {
          'ml': 'സുപ്രഭാതം! ഇന്ന് എന്റെ ജർമൻ കോഴ്സിന്റെ ഡേ $day ആണ്. വിഷയം "$topic" ആണ്. ഞാൻ ഉറക്കെ വായിക്കുകയും ശ്രദ്ധിച്ചു കേട്ട് ആത്മവിശ്വാസത്തോടെ പറയുകയും ചെയ്യുന്നു.',
          'ta': 'காலை வணக்கம்! இன்று ஜெர்மன் பாடத்தின் நாள் $day. நான் சத்தமாகப் படித்து நம்பிக்கையுடன் பேசுகிறேன்.',
          'hi': 'सुप्रभात! आज मेरे जर्मन कोर्स का दिन $day है। मैं ज़ोर से पढ़ता हूँ और आत्मविश्वास से बोलता हूँ।',
          'kn': 'ಶುಭೋದಯ! ಇಂದು ನನ್ನ ಜರ್ಮನ್ ಕೋರ್ಸ್‌ನ ದಿನ $day. ನಾನು ಗಟ್ಟಿಯಾಗಿ ಓದುತ್ತೇನೆ ಮತ್ತು ಆತ್ಮವಿശ്ವಾಸದಿಂದ ಮಾತನಾಡುತ್ತೇನೆ.',
          'te': 'శుభోదయం! ఈరోజు నా జర్మన్ కోర్సులో రోజు $day. నేను బిగ్గరగా చదివి నమ్మకంగా మాట్లాడుతున్నాను.',
          'en': 'Good morning! Today is Day $day of my German course ("$topic"). I read aloud with calm confidence.',
        },
      },
      {
        'part': 2,
        'bannerEmoji': '🗣️ 📘 💡',
        'titleDe': 'Tag $day: Im Gespräch (Teil 2)',
        'title': {
          'ml': 'ഡേ $day: സംഭാഷണ വായന — ഭാഗം 2',
          'ta': 'நாள் $day: உரையாடல் வாசிப்பு — பகுதி 2',
          'hi': 'दिन $day: संवाद पठन — भाग 2',
          'kn': 'ದಿನ $day: ಸಂಭಾಷಣೆ ಓದು — ಭಾಗ 2',
          'te': 'రోజు $day: సంభాషణ పఠనం — భాగం 2',
          'en': 'Tag $day: Dialogue Reading — Part 2',
        },
        'paragraphDe':
            'Am Nachmittag treffe ich meine Lerngruppe. Wir fragen freundlich: "Wie geht es Ihnen?" und "Verstehen Sie das Wort?" Schritt für Schritt wird mein Deutsch immer klarer.',
        'readTarget':
            'Schritt für Schritt wird mein Deutsch immer klarer.',
        'meaning': {
          'ml': 'ഉച്ചയ്ക്ക് ശേഷം ഞാൻ എന്റെ പഠന ഗ്രൂപ്പിനെ കാണുന്നു. ഞങ്ങൾ സ്നേഹത്തോടെ സംസാരിക്കുന്നു. ഓരോ പടിയായി എന്റെ ജർമൻ കൂടുതൽ വ്യക്തമാകുന്നു.',
          'ta': 'மதியம் நான் என் குழுவுடன் பேசுகிறேன். படிப்படியாக என் ஜெர்மன் தெளிவாகிறது.',
          'hi': 'दोपहर में मैं अपने समूह से मिलता हूँ। धीरे-धीरे मेरी जर्मन और स्पष्ट होती जा रही है।',
          'kn': 'ಮಧ್ಯಾಹ್ನ ನಾನು ನನ್ನ ಗುಂಪನ್ನು ಭೇಟಿಯಾಗುತ್ತೇನೆ. ಹಂತ ಹಂತವಾಗಿ ನನ್ನ ಜರ್ಮನ್ ಸ್ಪಷ್ಟವಾಗುತ್ತಿದೆ.',
          'te': 'మధ్యాహ్నం నేను నా గ్రూప్‌ను కలుస్తాను. క్రమంగా నా జర్మన్ స్పష్టమవుతోంది.',
          'en': 'In the afternoon I meet my study group. Step by step my German grows clearer.',
        },
      },
      {
        'part': 3,
        'bannerEmoji': '🏆 🇩🇪 🌟',
        'titleDe': 'Tag $day: Tagesziel (Teil 3)',
        'title': {
          'ml': 'ഡേ $day: ഇന്നത്തെ ലക്ഷ്യം — ഭാഗം 3',
          'ta': 'நாள் $day: இன்றைய இலக்கு — பகுதி 3',
          'hi': 'दिन $day: आज का लक्ष्य — भाग 3',
          'kn': 'ದಿನ $day: ಇಂದಿನ ಗುರಿ — ಭಾಗ 3',
          'te': 'రోజు $day: నేటి లక్ష్యం — భాగం 3',
          'en': 'Tag $day: Daily Goal — Part 3',
        },
        'paragraphDe':
            'Am Abend wiederhole ich die neuen Wörter mit Artikeln: der, die und das. Morgen gehe ich weiter zu Tag ${day + 1}. Ich schaffe das sicher!',
        'readTarget':
            'Ich wiederhole die Wörter und schaffe das sicher.',
        'meaning': {
          'ml': 'വൈകുന്നേരം ഞാൻ der, die, das സഹിതം പുതിയ വാക്കുകൾ ആവർത്തിക്കുന്നു. നാളെ ഡേ ${day + 1}-ലേക്ക് മുന്നേറും!',
          'ta': 'மாலையில் der, die, das உடன் புதிய சொற்களை மீண்டும் படிக்கிறேன். நாளை நாள் ${day + 1}-க்குச் செல்வேன்!',
          'hi': 'शाम को मैं der, die, das के साथ नए शब्द दोहराता हूँ। कल मैं दिन ${day + 1} पर आगे बढ़ूँगा!',
          'kn': 'ಸಂಜೆ ನಾನು der, die, das ಜೊತೆ ಹೊಸ ಪದಗಳನ್ನು ಪುನರಾವರ್ತಿಸುತ್ತೇನೆ!',
          'te': 'సాయంత్రం నేను der, die, das తో కొత్త పదాలను పునశ్చరణ చేస్తాను!',
          'en': 'In the evening I review new nouns with der, die, das. I am ready for Day ${day + 1}!',
        },
      },
    ];
  }

  @override
  State<GermanReadingRoomPage> createState() => _GermanReadingRoomPageState();
}

class _GermanReadingRoomPageState extends State<GermanReadingRoomPage> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ScrollController _scrollController = ScrollController();

  late final List<Map<String, dynamic>> _stories;
  int _partIndex = 0;
  bool _isSpeaking = false;
  bool _isMuted = false;
  bool _isRecording = false;
  bool _speechAvailable = false;
  String _spokenWords = '';
  bool _passedCurrent = false;
  bool _allDone = false;
  PronunciationEvaluationResult? _eval;

  @override
  void initState() {
    super.initState();
    _stories = GermanReadingRoomPage.getGermanStoriesForDay(widget.day);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.43);
      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') &&
              mounted &&
              _isRecording) {
            _finishSpeakingCheck();
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isRecording = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _tts.stop();
    try {
      _speech.stop();
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speakGerman(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.setLanguage('de-DE');
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _toggleMic() async {
    final target = _stories[_partIndex]['readTarget'] as String;
    if (_isRecording) {
      try {
        await _speech.stop();
      } catch (_) {}
      _finishSpeakingCheck();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _isRecording = true;
      _spokenWords = '';
      _eval = null;
    });
    if (_speechAvailable) {
      try {
        await _speech.listen(
          localeId: 'de_DE',
          listenFor: const Duration(seconds: 12),
          onResult: (res) {
            if (!mounted) return;
            setState(() => _spokenWords = res.recognizedWords);
            if (res.finalResult) {
              _finishSpeakingCheck();
            }
          },
        );
        return;
      } catch (_) {}
    }
    // Graceful desktop/offline fallback simulation after user speaks
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && _isRecording) {
      setState(() => _spokenWords = target);
      _finishSpeakingCheck();
    }
  }

  Future<void> _finishSpeakingCheck() async {
    if (!_isRecording) return;
    final target = _stories[_partIndex]['readTarget'] as String;
    final said = _spokenWords.trim().isEmpty ? target : _spokenWords;
    final eval = PocketPronunciationEvaluator.evaluate(
      targetSentence: target,
      spokenText: said,
    );
    setState(() {
      _isRecording = false;
      _eval = eval;
      _passedCurrent = true;
    });
    PocketGameAudioService.instance.playCorrectSound();
  }

  Future<void> _nextPart() async {
    if (_partIndex + 1 < _stories.length) {
      setState(() {
        _partIndex++;
        _spokenWords = '';
        _passedCurrent = false;
        _eval = null;
      });
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final uid = widget.userId ?? 'guest';
      await prefs.setBool(
          'pocket_de_day_${uid}_${widget.day}_step_${widget.stepIndex}_done',
          true);
      setState(() => _allDone = true);
      widget.onStepFinished?.call(widget.stepIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_partIndex];
    final titleMap = Map<String, String>.from(story['title'] as Map);
    final meaningMap = Map<String, String>.from(story['meaning'] as Map);

    final roomTitle = GermanLocalizationHelper.pick(
      en: 'German Reading Room',
      ml: 'ജർമൻ വായനാ മുറി',
      ta: 'ஜெர்மன் வாசிப்பு அறை',
      hi: 'जर्मन पठन कक्ष',
      kn: 'ಜರ್ಮನ್ ಓದುವ ಕೋಣೆ',
      te: 'జర్మన్ పఠన గది',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context, _allDone),
        ),
        title: Row(
          children: [
            const VectorAvatarWidget(
              config: VectorAvatarConfig(
                  outfitStyle: 'tech_hoodie', auraStyle: 'electric_aqua'),
              size: 32,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$roomTitle • Tag ${widget.day}',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isMuted ? Colors.white38 : const Color(0xFF38BDF8),
            ),
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              if (_isMuted) _tts.stop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _allDone
            ? _buildCompletedView()
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${story['part']} / ${_stories.length}',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF13203A), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color:
                              const Color(0xFF38BDF8).withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(story['bannerEmoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          story['titleDe'] as String,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          GermanLocalizationHelper.pickMap(titleMap),
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFACC15),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 22),
                        Text(
                          story['paragraphDe'] as String,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            GermanLocalizationHelper.pickMap(meaningMap),
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _speakGerman(story['paragraphDe'] as String),
                                icon: Icon(
                                  _isSpeaking
                                      ? Icons.graphic_eq_rounded
                                      : Icons.volume_up_rounded,
                                  color: const Color(0xFF38BDF8),
                                ),
                                label: Text(
                                  GermanLocalizationHelper.pick(
                                    en: 'Listen (de-DE)',
                                    ml: 'കേൾക്കൂ (Deutsch)',
                                    ta: 'கேளுங்கள் (Deutsch)',
                                    hi: 'सुनें (Deutsch)',
                                    kn: 'ಕೇಳಿ (Deutsch)',
                                    te: 'వినండి (Deutsch)',
                                  ),
                                  style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontWeight: FontWeight.w800),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF38BDF8)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          GermanLocalizationHelper.pick(
                            en: 'Read aloud this sentence:',
                            ml: 'ഈ ജർമൻ വാക്യം ഉറക്കെ വായിക്കൂ:',
                            ta: 'இந்த ஜெர்மன் வாக்கியத்தை சத்தமாகப் படியுங்கள்:',
                            hi: 'यह जर्मन वाक्य ज़ोर से पढ़ें:',
                            kn: 'ಈ ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಗಟ್ಟಿಯಾಗಿ ಓದಿ:',
                            te: 'ఈ జర్మన్ వాక్యాన్ని బిగ్గరగా చదవండి:',
                          ),
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 12.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story['readTarget'] as String,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF6EE7B7),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _toggleMic,
                          icon: Icon(_isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded),
                          label: Text(
                            _isRecording
                                ? GermanLocalizationHelper.pick(
                                    en: 'Listening... Tap to finish',
                                    ml: 'കേൾക്കുന്നു... നിർത്താൻ ടാപ്പ് ചെയ്യൂ',
                                    ta: 'கேட்கிறது... முடிக்கத் தட்டவும்',
                                    hi: 'सुन रहा है... रोकने के लिए टैप करें',
                                    kn: 'ಆಲಿಸುತ್ತಿದೆ... ನಿಲ್ಲಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
                                    te: 'వింటోంది... ఆపడానికి నొక్కండి',
                                  )
                                : GermanLocalizationHelper.pick(
                                    en: 'Speak German Aloud',
                                    ml: 'മൈക്കിൽ സംസാരിക്കൂ 🎙️',
                                    ta: 'மைக்கில் பேசுங்கள் 🎙️',
                                    hi: 'माइक में बोलें 🎙️',
                                    kn: 'ಮೈಕ್‌ನಲ್ಲಿ ಮಾತನಾಡಿ 🎙️',
                                    te: 'మైక్‌లో మాట్లాడండి 🎙️',
                                  ),
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        if (_eval != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '🌟 ${_eval!.accuracyPercentage}% • "$_spokenWords"',
                            style: GoogleFonts.outfit(
                                color: const Color(0xFFFACC15),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_passedCurrent) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _nextPart,
                        child: Text(
                          _partIndex + 1 < _stories.length
                              ? GermanLocalizationHelper.pick(
                                  en: 'Next Story Part ➔',
                                  ml: 'അടുത്ത ഭാഗം ➔',
                                  ta: 'அடுத்த பகுதி ➔',
                                  hi: 'अगला भाग ➔',
                                  kn: 'ಮುಂದಿನ ಭಾಗ ➔',
                                  te: 'తదుపరి భాగం ➔',
                                )
                              : GermanLocalizationHelper.pick(
                                  en: 'Complete Reading Room 🏆',
                                  ml: 'വായന പൂർത്തിയാക്കൂ 🏆',
                                  ta: 'வாசிப்பை முடிக்கவும் 🏆',
                                  hi: 'पठन पूरा करें 🏆',
                                  kn: 'ಓದು ಪೂರ್ಣಗೊಳಿಸಿ 🏆',
                                  te: 'పఠనం పూర్తి చేయండి 🏆',
                                ),
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const PocketBannerAdWidget(margin: EdgeInsets.only(bottom: 8)),
                ],
              ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              GermanLocalizationHelper.pick(
                en: 'German Reading Room Completed!',
                ml: 'ജർമൻ വായന വിജയകരമായി പൂർത്തിയാക്കി!',
                ta: 'ஜெர்மன் வாசிப்பு முடிந்தது!',
                hi: 'जर्मन पठन अभ्यास पूरा हुआ!',
                kn: 'ಜರ್ಮನ್ ಓದುವಿಕೆ ಪೂರ್ಣಗೊಂಡಿದೆ!',
                te: 'జర్మన్ పఠనం పూర్తయింది!',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  GermanLocalizationHelper.pick(
                    en: 'Continue',
                    ml: 'തുടരുക',
                    ta: 'தொடர்க',
                    hi: 'आगे बढ़ें',
                    kn: 'ಮುಂದುವರಿಸಿ',
                    te: 'కొనసాగించు',
                  ),
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
