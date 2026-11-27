import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'german_localization_helper.dart';

class _ArticleChallengeItem {
  final String article; // der, die, das
  final String noun;
  final Map<String, String> meaning;
  final String sentenceDe;
  final Map<String, String> ruleHint;

  const _ArticleChallengeItem({
    required this.article,
    required this.noun,
    required this.meaning,
    required this.sentenceDe,
    required this.ruleHint,
  });
}

/// 🇩🇪 German Gender & Article Lab (der / die / das + Nominative/Akkusativ)
/// Replaces English-only essay/tense templates in the German 90-Day Track.
class GermanArticleGenderGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int stepIndex)? onStepFinished;

  const GermanArticleGenderGamePage({
    super.key,
    required this.day,
    this.stepIndex = 7,
    this.userId,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int day,
    int stepIndex = 7,
    String? userId,
    void Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GermanArticleGenderGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<GermanArticleGenderGamePage> createState() =>
      _GermanArticleGenderGamePageState();
}

class _GermanArticleGenderGamePageState
    extends State<GermanArticleGenderGamePage> {
  final FlutterTts _tts = FlutterTts();
  late final List<_ArticleChallengeItem> _items;
  int _index = 0;
  String? _selectedArticle;
  bool? _isCorrect;
  int _score = 0;
  bool _completed = false;

  static const List<_ArticleChallengeItem> _bank = [
    _ArticleChallengeItem(
      article: 'der',
      noun: 'Apfel',
      meaning: {
        'ml': 'ആപ്പിൾ',
        'ta': 'ஆப்பிள்',
        'hi': 'सेब',
        'kn': 'ಸೇಬು',
        'te': 'ఆపిల్',
        'en': 'Apple',
      },
      sentenceDe: 'Der Apfel ist frisch und süß.',
      ruleHint: {
        'ml': 'ആപ്പിൾ (Apfel) പുല്ലിംഗമാണ് → der',
        'ta': 'Apfel ஆண்பால் (masculine) → der',
        'hi': 'Apfel पुल्लिंग संज्ञा है → der',
        'kn': 'Apfel ಪುಲ್ಲಿಂಗ ನಾಮಪದ → der',
        'te': 'Apfel పుంలింగం → der',
        'en': 'Apfel takes masculine article "der"',
      },
    ),
    _ArticleChallengeItem(
      article: 'die',
      noun: 'Sonne',
      meaning: {
        'ml': 'സൂര്യൻ',
        'ta': 'சூரியன்',
        'hi': 'सूरज',
        'kn': 'ಸೂರ್ಯ',
        'te': 'సూర్యుడు',
        'en': 'Sun',
      },
      sentenceDe: 'Die Sonne scheint heute warm.',
      ruleHint: {
        'ml': '-e-യിൽ അവസാനിക്കുന്ന മിക്ക വാക്കുകളും സ്ത്രീലിംഗം → die',
        'ta': '-e இல் முடியும் பெரும்பாலான சொற்கள் → die',
        'hi': '-e पर समाप्त अधिकतर शब्द स्त्रीलिंग → die',
        'kn': '-e ನಿಂದ ಕೊನೆಗೊಳ್ಳುವ ಬಹುತೇಕ ಪದಗಳು → die',
        'te': '-e తో ముగిసే చాలా పదాలు → die',
        'en': 'Most nouns ending in -e take feminine "die"',
      },
    ),
    _ArticleChallengeItem(
      article: 'das',
      noun: 'Buch',
      meaning: {
        'ml': 'പുസ്തകം',
        'ta': 'புத்தகம்',
        'hi': 'किताब',
        'kn': 'ಪುಸ್ತಕ',
        'te': 'పుస్తకం',
        'en': 'Book',
      },
      sentenceDe: 'Das Buch liegt auf dem Tisch.',
      ruleHint: {
        'ml': 'Buch നപുംസകലിംഗമാണ് → das',
        'ta': 'Buch அஃறிணை → das',
        'hi': 'Buch नपुंसकलिंग संज्ञा है → das',
        'kn': 'Buch ನಪುಂಸಕಲಿಂಗ → das',
        'te': 'Buch నపుంసకలింగం → das',
        'en': 'Buch takes neuter article "das"',
      },
    ),
    _ArticleChallengeItem(
      article: 'das',
      noun: 'Wasser',
      meaning: {
        'ml': 'വെള്ളം',
        'ta': 'தண்ணீர்',
        'hi': 'पानी',
        'kn': 'ನೀರು',
        'te': 'నీరు',
        'en': 'Water',
      },
      sentenceDe: 'Das Wasser ist kalt und klar.',
      ruleHint: {
        'ml': 'ദ്രാവകങ്ങൾ പൊതുവെ നപുംസകലിംഗം → das Wasser',
        'ta': 'திரவப் பெயர்கள் பெரும்பாலும் → das',
        'hi': 'तरल पदार्थ अक्सर नपुंसकलिंग → das Wasser',
        'kn': 'ದ್ರವ ಪದಗಳು ಸಾಮಾನ್ಯವಾಗಿ → das Wasser',
        'te': 'ద్రవ పదార్థాలు సాధారణంగా → das Wasser',
        'en': 'Water takes neuter article "das"',
      },
    ),
    _ArticleChallengeItem(
      article: 'der',
      noun: 'Tisch',
      meaning: {
        'ml': 'മേശ',
        'ta': 'மேசை',
        'hi': 'मेज़',
        'kn': 'ಮೇಜು',
        'te': 'బల్ల',
        'en': 'Table',
      },
      sentenceDe: 'Der Tisch steht im Wohnzimmer.',
      ruleHint: {
        'ml': 'Tisch പുല്ലിംഗമാണ് → der Tisch',
        'ta': 'Tisch ஆண்பால் → der Tisch',
        'hi': 'Tisch पुल्लिंग है → der Tisch',
        'kn': 'Tisch ಪುಲ್ಲಿಂಗ → der Tisch',
        'te': 'Tisch పుంలింగం → der Tisch',
        'en': 'Tisch takes masculine "der"',
      },
    ),
    _ArticleChallengeItem(
      article: 'die',
      noun: 'Straße',
      meaning: {
        'ml': 'റോഡ് / തെരുവ്',
        'ta': 'சாலை',
        'hi': 'सड़क',
        'kn': 'ರಸ್ತೆ',
        'te': 'వీధి / రోడ్డు',
        'en': 'Street',
      },
      sentenceDe: 'Die Straße führt zum Bahnhof.',
      ruleHint: {
        'ml': 'Straße (-e അവസാനം) → die Straße',
        'ta': 'Straße (-e முடிவு) → die Straße',
        'hi': 'Straße (-e अंत) → die Straße',
        'kn': 'Straße (-e ಕೊನೆ) → die Straße',
        'te': 'Straße (-e చివర) → die Straße',
        'en': 'Straße ends in -e → feminine "die"',
      },
    ),
    _ArticleChallengeItem(
      article: 'der',
      noun: 'Zug',
      meaning: {
        'ml': 'ട്രെയിൻ / തീവണ്ടി',
        'ta': 'ரயில்',
        'hi': 'ट्रेन',
        'kn': 'ರೈಲು',
        'te': 'రైలు',
        'en': 'Train',
      },
      sentenceDe: 'Der Zug fährt nach München.',
      ruleHint: {
        'ml': 'വാഹനങ്ങൾ/ട്രെയിൻ (Zug) → der Zug',
        'ta': 'Zug ஆண்பால் → der Zug',
        'hi': 'Zug पुल्लिंग है → der Zug',
        'kn': 'Zug ಪುಲ್ಲಿಂಗ → der Zug',
        'te': 'Zug పుంలింగం → der Zug',
        'en': 'Zug takes masculine "der"',
      },
    ),
    _ArticleChallengeItem(
      article: 'das',
      noun: 'Haus',
      meaning: {
        'ml': 'വീട്',
        'ta': 'வீடு',
        'hi': 'घर',
        'kn': 'ಮನೆ',
        'te': 'ఇల్లు',
        'en': 'House',
      },
      sentenceDe: 'Das Haus hat einen Garten.',
      ruleHint: {
        'ml': 'Haus നപുംസകലിംഗമാണ് → das Haus',
        'ta': 'Haus அஃறிணை → das Haus',
        'hi': 'Haus नपुंसकलिंग है → das Haus',
        'kn': 'Haus ನಪುಂಸಕಲಿಂಗ → das Haus',
        'te': 'Haus నపుంసకలింగం → das Haus',
        'en': 'Haus takes neuter "das"',
      },
    ),
    _ArticleChallengeItem(
      article: 'die',
      noun: 'Familie',
      meaning: {
        'ml': 'കുടുംബം',
        'ta': 'குடும்பம்',
        'hi': 'परिवार',
        'kn': 'ಕುಟುಂಬ',
        'te': 'కుటుంబం',
        'en': 'Family',
      },
      sentenceDe: 'Die Familie isst zusammen.',
      ruleHint: {
        'ml': 'Familie → die Familie',
        'ta': 'Familie → die Familie',
        'hi': 'Familie → die Familie',
        'kn': 'Familie → die Familie',
        'te': 'Familie → die Familie',
        'en': 'Familie ends in -ie → feminine "die"',
      },
    ),
    _ArticleChallengeItem(
      article: 'der',
      noun: 'Kaffee',
      meaning: {
        'ml': 'കാപ്പി',
        'ta': 'காபி',
        'hi': 'कॉफी',
        'kn': 'ಕಾಫಿ',
        'te': 'కాఫీ',
        'en': 'Coffee',
      },
      sentenceDe: 'Der Kaffee ist noch heiß.',
      ruleHint: {
        'ml': 'ചൂടുള്ള പാനീയങ്ങൾ (Kaffee, Tee) മിക്കവാറും der → der Kaffee',
        'ta': 'Kaffee, Tee போன்றவை ஆண்பால் → der Kaffee',
        'hi': 'Kaffee और Tee पुल्लिंग होते हैं → der Kaffee',
        'kn': 'Kaffee, Tee ಸಾಮಾನ್ಯವಾಗಿ ಪುಲ್ಲಿಂಗ → der Kaffee',
        'te': 'Kaffee, Tee సాధారణంగా పుంలింగం → der Kaffee',
        'en': 'Hot drinks like Kaffee & Tee take masculine "der"',
      },
    ),
    _ArticleChallengeItem(
      article: 'die',
      noun: 'Übung',
      meaning: {
        'ml': 'പരിശീലനം',
        'ta': 'பயிற்சி',
        'hi': 'अभ्यास',
        'kn': 'ಅಭ್ಯಾಸ',
        'te': 'అభ్యాసం',
        'en': 'Practice',
      },
      sentenceDe: 'Die Übung hilft jeden Tag.',
      ruleHint: {
        'ml': '-ung-ൽ അവസാനിക്കുന്ന എല്ലാ വാക്കുകളും സ്ത്രീലിംഗം → die!',
        'ta': '-ung இல் முடியும் எல்லா சொற்களும் → die!',
        'hi': '-ung पर समाप्त सभी शब्द हमेशा → die!',
        'kn': '-ung ನಿಂದ ಕೊನೆಗೊಳ್ಳುವ ಎಲ್ಲಾ ಪದಗಳು → die!',
        'te': '-ung తో ముగిసే అన్నీ పదాలు → die!',
        'en': 'Golden rule: ALL nouns ending in -ung take "die"!',
      },
    ),
    _ArticleChallengeItem(
      article: 'das',
      noun: 'Mädchen',
      meaning: {
        'ml': 'പെൺകുട്ടി',
        'ta': 'சிறுமி',
        'hi': 'लड़की',
        'kn': 'ಹುಡುಗಿ',
        'te': 'బాలిక',
        'en': 'Girl',
      },
      sentenceDe: 'Das Mädchen liest ein Buch.',
      ruleHint: {
        'ml': '-chen-ൽ അവസാനിക്കുന്ന എല്ലാ വാക്കുകളും എപ്പോഴും das ആണ്!',
        'ta': '-chen இல் முடியும் எல்லா சொற்களும் எப்போதும் das!',
        'hi': '-chen पर खत्म होने वाले शब्द हमेशा das होते हैं!',
        'kn': '-chen ನಿಂದ ಕೊನೆಗೊಳ್ಳುವ ಪದಗಳು ಯಾವಾಗಲೂ das!',
        'te': '-chen తో ముగిసే పదాలు ఎప్పుడూ das!',
        'en': 'Golden rule: ALL nouns ending in -chen take "das"!',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    final rot = (widget.day - 1) % _bank.length;
    final ordered = [..._bank.sublist(rot), ..._bank.sublist(0, rot)];
    _items = ordered.take(6).toList();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.45);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _pickArticle(String choice) {
    if (_selectedArticle != null && _isCorrect == true) return;
    final current = _items[_index];
    final correct = choice == current.article;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedArticle = choice;
      _isCorrect = correct;
      if (correct) _score += 10;
    });
    if (correct) {
      PocketGameAudioService.instance.playCorrectSound();
      _speak('${current.article} ${current.noun}. ${current.sentenceDe}');
    } else {
      PocketGameAudioService.instance.playIncorrectSound();
    }
  }

  void _nextQuestion() {
    if (_index + 1 < _items.length) {
      setState(() {
        _index++;
        _selectedArticle = null;
        _isCorrect = null;
      });
    } else {
      setState(() => _completed = true);
      widget.onStepFinished?.call(widget.stepIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerTitle = GermanLocalizationHelper.pick(
      en: 'der / die / das Article Lab',
      ml: 'der / die / das ആർട്ടിക്കിൾ ലാബ്',
      ta: 'der / die / das பாலினப் பயிற்சி',
      hi: 'der / die / das लिंग और आर्टिकल लैब',
      kn: 'der / die / das ಲಿಂಗ ಮತ್ತು ಆರ್ಟಿಕಲ್',
      te: 'der / die / das ఆర్టికల్ ల్యాబ్',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A101D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context, _completed),
        ),
        title: Text(
          headerTitle,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '🪙 $_score',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8), fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _completed ? _buildDoneView() : _buildQuestionView(),
      ),
    );
  }

  Widget _buildDoneView() {
    final doneTitle = GermanLocalizationHelper.pick(
      en: 'Article Lab Mastered!',
      ml: 'der / die / das വിജയകരമായി പൂർത്തിയാക്കി!',
      ta: 'der / die / das பயிற்சி முடிந்தது!',
      hi: 'der / die / das अभ्यास पूरा हुआ!',
      kn: 'der / die / das ಅಭ್ಯಾಸ ಪೂರ್ಣಗೊಂಡಿದೆ!',
      te: 'der / die / das అభ్యాసం పూర్తయింది!',
    );
    final contLabel = GermanLocalizationHelper.pick(
      en: 'Continue',
      ml: 'തുടരുക',
      ta: 'தொடர்க',
      hi: 'आगे बढ़ें',
      kn: 'ಮುಂದುವರಿಸಿ',
      te: 'కొనసాగించు',
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇩🇪🏆', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            Text(
              doneTitle,
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
                child: Text(contLabel,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final current = _items[_index];
    final promptText = GermanLocalizationHelper.pick(
      en: 'Choose the correct German article:',
      ml: 'ശരിയായ ജർമൻ ആർട്ടിക്കിൾ തിരഞ്ഞെടുക്കുക:',
      ta: 'சரியான ஜெர்மன் சொல்லைத் தேர்ந்தெடுக்கவும்:',
      hi: 'सही जर्मन आर्टिकल चुनें:',
      kn: 'ಸರಿಯಾದ ಜರ್ಮನ್ ಆರ್ಟಿಕಲ್ ಆರಿಸಿ:',
      te: 'సరైన జర్మన్ ఆర్టికల్ ఎంచుకోండి:',
    );
    final nextLabel = GermanLocalizationHelper.pick(
      en: 'Next Word ➔',
      ml: 'അടുത്ത വാക്ക് ➔',
      ta: 'அடுத்த சொல் ➔',
      hi: 'अगला शब्द ➔',
      kn: 'ಮುಂದಿನ ಪದ ➔',
      te: 'తదుపరి పదం ➔',
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / _items.length,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF131C2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Text(
                promptText,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_isCorrect == true ? current.article : '___'} ${current.noun}',
                    style: GoogleFonts.outfit(
                      color: _isCorrect == true
                          ? const Color(0xFF34D399)
                          : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFF38BDF8)),
                    onPressed: () => _speak(current.noun),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                GermanLocalizationHelper.pickMap(current.meaning),
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFACC15),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _articleChoiceChip('der', const Color(0xFF38BDF8)),
            const SizedBox(width: 10),
            _articleChoiceChip('die', const Color(0xFFF472B6)),
            const SizedBox(width: 10),
            _articleChoiceChip('das', const Color(0xFF34D399)),
          ],
        ),
        if (_selectedArticle != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (_isCorrect == true
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444))
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isCorrect == true
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GermanLocalizationHelper.pickMap(current.ruleHint),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isCorrect == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    current.sentenceDe,
                    style: GoogleFonts.inter(
                        color: const Color(0xFFA7F3D0), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          if (_isCorrect == true) ...[
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
                onPressed: _nextQuestion,
                child: Text(nextLabel,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        const PocketBannerAdWidget(margin: EdgeInsets.only(bottom: 8)),
      ],
    );
  }

  Widget _articleChoiceChip(String art, Color color) {
    final picked = _selectedArticle == art;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pickArticle(art),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: picked ? color : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: picked ? color : color.withValues(alpha: 0.45),
                width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            art,
            style: GoogleFonts.outfit(
              color: picked ? Colors.black : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
