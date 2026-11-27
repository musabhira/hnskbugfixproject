import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_vocab_curriculum.dart';
import 'curriculum_data/pocket_german_90day_master_data.dart';
import 'german_localization_helper.dart';

class _DePatternItem {
  final String de;
  final Map<String, String> native;
  const _DePatternItem({required this.de, required this.native});
}

class _DePatternFamily {
  final String rootGerman;
  final Map<String, String> title;
  final List<_DePatternItem> items;
  const _DePatternFamily({
    required this.rootGerman,
    required this.title,
    required this.items,
  });
}

/// 🧩 Dedicated German Pattern Phrase Builder & Exam (Days 1–90)
/// Uses authentic German structural roots (Ich möchte..., Wie viel..., Wo ist...,
/// Kann ich..., Es gibt...) with strict 6-language native prompts — zero English UI leaks!
class GermanPatternPhraseBuilderPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final void Function(int finishedStep)? onStepFinished;

  const GermanPatternPhraseBuilderPage({
    super.key,
    this.day = 1,
    this.stepIndex = 20,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 20,
    void Function(int finishedStep)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GermanPatternPhraseBuilderPage(
          day: day,
          stepIndex: stepIndex,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<GermanPatternPhraseBuilderPage> createState() =>
      _GermanPatternPhraseBuilderPageState();
}

class _GermanPatternPhraseBuilderPageState
    extends State<GermanPatternPhraseBuilderPage> {
  final FlutterTts _tts = FlutterTts();
  late final _DePatternFamily _family;
  bool _isExamMode = false;
  int _examIndex = 0;
  final List<_DePatternItem> _solvedItems = [];
  late List<_DePatternItem> _examQueue;
  late List<String> _currentOptions;
  String? _wrongOption;
  bool _isCompleted = false;

  static const List<_DePatternFamily> _coreFamilies = [
    _DePatternFamily(
      rootGerman: 'Wie ...',
      title: {
        'ml': 'Wie — ചോദ്യ വാക്യങ്ങൾ',
        'ta': 'Wie — கேள்வி வாக்கியங்கள்',
        'hi': 'Wie — प्रश्नवाचक वाक्य',
        'kn': 'Wie — ಪ್ರಶ್ನೆ ವಾಕ್ಯಗಳು',
        'te': 'Wie — ప్రశ్న పదాలు',
        'en': 'Wie — Question Patterns',
      },
      items: [
        _DePatternItem(
          de: 'Wie heißt du?',
          native: {
            'ml': 'നിന്റെ പേര് എന്താണ്?',
            'ta': 'உன் பெயர் என்ன?',
            'hi': 'तुम्हारा नाम क्या है?',
            'kn': 'ನಿನ್ನ ಹೆಸರು ಏನು?',
            'te': 'నీ పేరు ఏమిటి?',
            'en': 'What is your name?',
          },
        ),
        _DePatternItem(
          de: 'Wie geht es dir?',
          native: {
            'ml': 'സുഖമാണോ?',
            'ta': 'எப்படி இருக்கிறாய்?',
            'hi': 'तुम कैसे हो?',
            'kn': 'ಹೇಗಿದ್ದೀಯಾ?',
            'te': 'ఎలా ఉన్నావు?',
            'en': 'How are you?',
          },
        ),
        _DePatternItem(
          de: 'Wie viel kostet das?',
          native: {
            'ml': 'ഇതിനു എത്ര വിലയാണ്?',
            'ta': 'இதன் விலை என்ன?',
            'hi': 'इसकी कीमत कितनी है?',
            'kn': 'ಇದರ ಬೆಲೆ ಎಷ್ಟು?',
            'te': 'దీని ధర ఎంత?',
            'en': 'How much does this cost?',
          },
        ),
        _DePatternItem(
          de: 'Wie spät ist es?',
          native: {
            'ml': 'ഇപ്പോൾ സമയം എത്രയായി?',
            'ta': 'இப்போது மணி என்ன?',
            'hi': 'अभी कितने बजे हैं?',
            'kn': 'ಈಗ ಸಮಯ ಎಷ್ಟು?',
            'te': 'ఇప్పుడు సమయం ఎంత?',
            'en': 'What time is it?',
          },
        ),
        _DePatternItem(
          de: 'Wie lange dauert es?',
          native: {
            'ml': 'എത്ര സമയം എടുക്കും?',
            'ta': 'எவ்வளவு நேரம் ஆகும்?',
            'hi': 'कितना समय लगेगा?',
            'kn': 'ಎಷ್ಟು ಸಮಯ ತೆಗೆದುಕೊಳ್ಳುತ್ತದೆ?',
            'te': 'ఎంత సమయం పడుతుంది?',
            'en': 'How long does it take?',
          },
        ),
        _DePatternItem(
          de: 'Wie weit ist der Bahnhof?',
          native: {
            'ml': 'റെയിൽവേ സ്റ്റേഷൻ എത്ര ദൂരെയാണ്?',
            'ta': 'ரயில் நிலையம் எவ்வளவு தூரம்?',
            'hi': 'रेलवे स्टेशन कितनी दूर है?',
            'kn': 'ರೈಲು ನಿಲ್ದಾಣ ಎಷ್ಟು ದೂರದಲ್ಲಿದೆ?',
            'te': 'రైల్వే స్టేషన్ ఎంత దూరంలో ఉంది?',
            'en': 'How far is the station?',
          },
        ),
      ],
    ),
    _DePatternFamily(
      rootGerman: 'Ich möchte ...',
      title: {
        'ml': 'Ich möchte — എനിക്ക് വേണം / ആഗ്രഹിക്കുന്നു',
        'ta': 'Ich möchte — எனக்கு வேண்டும்',
        'hi': 'Ich möchte — मुझे चाहिए / मैं चाहता हूँ',
        'kn': 'Ich möchte — ನನಗೆ ಬೇಕು / ಬಯಸುತ್ತೇನೆ',
        'te': 'Ich möchte — నాకు కావాలి',
        'en': 'Ich möchte — Polite Requests',
      },
      items: [
        _DePatternItem(
          de: 'Ich möchte Wasser, bitte.',
          native: {
            'ml': 'എനിക്ക് വെള്ളം തരാമോ, ദയവായി.',
            'ta': 'எனக்குத் தண்ணீர் வேண்டும், தயவுசெய்து.',
            'hi': 'कृपया मुझे पानी चाहिए।',
            'kn': 'ದಯವಿಟ್ಟು ನನಗೆ ನೀರು ಬೇಕು.',
            'te': 'దయచేసి నాకు నీరు కావాలి.',
            'en': 'I would like water, please.',
          },
        ),
        _DePatternItem(
          de: 'Ich möchte Deutsch lernen.',
          native: {
            'ml': 'എനിക്ക് ജർമൻ പഠിക്കണം.',
            'ta': 'நான் ஜெர்மன் கற்க விரும்புகிறேன்.',
            'hi': 'मैं जर्मन सीखना चाहता हूँ।',
            'kn': 'ನಾನು ಜರ್ಮನ್ ಕಲಿಯಲು ಬಯಸುತ್ತೇನೆ.',
            'te': 'నేను జర్మన్ నేర్చుకోవాలనుకుంటున్నాను.',
            'en': 'I would like to learn German.',
          },
        ),
        _DePatternItem(
          de: 'Ich möchte bezahlen, bitte.',
          native: {
            'ml': 'എനിക്ക് ബിൽ അടയ്ക്കണം.',
            'ta': 'நான் பணம் செலுத்த வேண்டும்.',
            'hi': 'मैं बिल देना चाहता हूँ।',
            'kn': 'ನಾನು ಹಣ ಪಾವತಿಸಬೇಕು.',
            'te': 'నేను బిల్లు చెల్లించాలనుకుంటున్నాను.',
            'en': 'I would like to pay, please.',
          },
        ),
        _DePatternItem(
          de: 'Ich möchte nach Hause gehen.',
          native: {
            'ml': 'എനിക്ക് വീട്ടിലേക്ക് പോകണം.',
            'ta': 'நான் வீட்டிற்குச் செல்ல வேண்டும்.',
            'hi': 'मैं घर जाना चाहता हूँ।',
            'kn': 'ನಾನು ಮನೆಗೆ ಹೋಗಲು ಬಯಸುತ್ತೇನೆ.',
            'te': 'నేను ఇంటికి వెళ్లాలనుకుంటున్నాను.',
            'en': 'I would like to go home.',
          },
        ),
        _DePatternItem(
          de: 'Ich möchte einen Kaffee.',
          native: {
            'ml': 'എനിക്ക് ഒരു കാപ്പി വേണം.',
            'ta': 'எனக்கு ஒரு காபி வேண்டும்.',
            'hi': 'मुझे एक कॉफी चाहिए।',
            'kn': 'ನನಗೆ ಒಂದು ಕಾಫಿ ಬೇಕು.',
            'te': 'నాకు ఒక కాఫీ కావాలి.',
            'en': 'I would like a coffee.',
          },
        ),
      ],
    ),
    _DePatternFamily(
      rootGerman: 'Wo ... / Kann ich ...',
      title: {
        'ml': 'Wo & Kann ich — സ്ഥലവും അനുവാദവും',
        'ta': 'Wo & Kann ich — இடம் & அனுமதி',
        'hi': 'Wo और Kann ich — स्थान व अनुमति',
        'kn': 'Wo & Kann ich — ಸ್ಥಳ ಮತ್ತು ಅನುಮತಿ',
        'te': 'Wo & Kann ich — స్థలం & అనుమతి',
        'en': 'Wo & Kann ich — Places & Permission',
      },
      items: [
        _DePatternItem(
          de: 'Wo ist die Straße?',
          native: {
            'ml': 'ആ തെരുവ് എവിടെയാണ്?',
            'ta': 'அந்தச் சாலை எங்கே உள்ளது?',
            'hi': 'वह सड़क कहाँ है?',
            'kn': 'ಆ ರಸ್ತೆ ಎಲ್ಲಿದೆ?',
            'te': 'ఆ వీధి ఎక్కడ ఉంది?',
            'en': 'Where is the street?',
          },
        ),
        _DePatternItem(
          de: 'Woher kommst du?',
          native: {
            'ml': 'നീ എവിടെ നിന്നാണ് വരുന്നത്?',
            'ta': 'நீ எங்கிருந்து வருகிறாய்?',
            'hi': 'तुम कहाँ से हो?',
            'kn': 'ನೀನು ಎಲ್ಲಿಂದ ಬರುತ್ತಿದ್ದೀಯಾ?',
            'te': 'నీవు ఎక్కడి నుండి వస్తున్నావు?',
            'en': 'Where do you come from?',
          },
        ),
        _DePatternItem(
          de: 'Kann ich Ihnen helfen?',
          native: {
            'ml': 'ഞാൻ നിങ്ങളെ സഹായിക്കട്ടെ?',
            'ta': 'நான் உங்களுக்கு உதவலாமா?',
            'hi': 'क्या मैं आपकी मदद कर सकता हूँ?',
            'kn': 'ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡಬಹುದೇ?',
            'te': 'నేను మీకు సహాయం చేయగలనా?',
            'en': 'Can I help you?',
          },
        ),
        _DePatternItem(
          de: 'Kann ich das bitte sehen?',
          native: {
            'ml': 'ദയവായി ഞാൻ അതൊന്ന് കാണട്ടെ?',
            'ta': 'தயவுசெய்து அதைப் பார்க்கலாமா?',
            'hi': 'क्या मैं इसे देख सकता हूँ?',
            'kn': 'ದಯವಿಟ್ಟು ನಾನು ಅದನ್ನು ನೋಡಬಹುದೇ?',
            'te': 'దయచేసి నేను దానిని చూడవచ్చా?',
            'en': 'Can I please see that?',
          },
        ),
        _DePatternItem(
          de: 'Wo gibt es einen Zug?',
          native: {
            'ml': 'എവിടെയാണ് ട്രെയിൻ കിട്ടുക?',
            'ta': 'ரயில் எங்கே கிடைக்கும்?',
            'hi': 'ट्रेन कहाँ मिलेगी?',
            'kn': 'ರೈಲು ಎಲ್ಲಿ ಸಿಗುತ್ತದೆ?',
            'te': 'రైలు ఎక్కడ ఉంటుంది?',
            'en': 'Where is there a train?',
          },
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _family = _buildFamilyForDay(widget.day);
    _examQueue = List<_DePatternItem>.from(_family.items)..shuffle();
    _prepareOptions();
    _initTts();
  }

  _DePatternFamily _buildFamilyForDay(int day) {
    if (day <= _coreFamilies.length) {
      return _coreFamilies[day - 1];
    }
    final sents = PocketGerman90DayMasterData.getSentencesForDay(day);
    if (sents.length >= 4) {
      final items = sents.take(6).map((s) {
        return _DePatternItem(
          de: s.sentence,
          native: {
            'ml': s.translationMl,
            'ta': s.translationMl,
            'hi': s.translationMl,
            'kn': s.translationMl,
            'te': s.translationMl,
            'en': s.hint,
          },
        );
      }).toList();
      return _DePatternFamily(
        rootGerman: 'Tag $day',
        title: {
          'ml': 'ഡേ $day — പ്രധാന ജർമൻ വാക്യങ്ങൾ',
          'ta': 'நாள் $day — முக்கிய ஜெர்மன் வாக்கியங்கள்',
          'hi': 'दिन $day — मुख्य जर्मन वाक्य',
          'kn': 'ದಿನ $day — ಪ್ರಮುಖ ಜರ್ಮನ್ ವಾಕ್ಯಗಳು',
          'te': 'రోజు $day — ముఖ్యమైన జర్మన్ వాక్యాలు',
          'en': 'Tag $day — Core German Patterns',
        },
        items: items,
      );
    }
    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    if (vocab.length >= 4) {
      final items = vocab
          .take(6)
          .map((v) => _DePatternItem(
                de: v.exampleSentence.isNotEmpty ? v.exampleSentence : v.word,
                native: {
                  'ml': v.malayalamMeaning,
                  'ta': v.tamilMeaning,
                  'hi': v.hindiMeaning,
                  'kn': v.kannadaMeaning.isNotEmpty
                      ? v.kannadaMeaning
                      : v.word,
                  'te': v.teluguMeaning.isNotEmpty ? v.teluguMeaning : v.word,
                  'en': v.definition,
                },
              ))
          .toList();
      return _DePatternFamily(
        rootGerman: 'Tag $day',
        title: {
          'ml': 'ഡേ $day — ജർമൻ പ്രയോഗങ്ങൾ',
          'ta': 'நாள் $day — ஜெர்மன் சொற்றொடர்கள்',
          'hi': 'दिन $day — जर्मन वाक्य',
          'kn': 'ದಿನ $day — ಜರ್ಮನ್ ವಾಕ್ಯಗಳು',
          'te': 'రోజు $day — జర్మన్ పదాలు',
          'en': 'Tag $day — Core Expressions',
        },
        items: items,
      );
    }
    return _coreFamilies[(day - 1) % _coreFamilies.length];
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.46);
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

  void _prepareOptions() {
    if (_examIndex >= _examQueue.length) return;
    final target = _examQueue[_examIndex];
    final others = _family.items
        .where((e) => e.de != target.de)
        .map((e) => e.de)
        .toList()
      ..shuffle();
    _currentOptions = [target.de, ...others.take(3)]..shuffle();
    _wrongOption = null;
  }

  void _onSelectOption(String chosen) {
    if (_isCompleted || _examIndex >= _examQueue.length) return;
    final target = _examQueue[_examIndex];
    if (chosen == target.de) {
      HapticFeedback.mediumImpact();
      PocketGameAudioService.instance.playCorrectSound();
      _speak(target.de);
      setState(() {
        _solvedItems.add(target);
        _wrongOption = null;
        if (_examIndex + 1 < _examQueue.length) {
          _examIndex++;
          _prepareOptions();
        } else {
          _isCompleted = true;
        }
      });
      if (_isCompleted) {
        widget.onStepFinished?.call(widget.stepIndex);
      }
    } else {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playIncorrectSound();
      setState(() => _wrongOption = chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = GermanLocalizationHelper.pick(
      en: 'German Pattern Builder',
      ml: 'ജർമൻ വാക്യ നിർമ്മാണം',
      ta: 'ஜெர்மன் வாக்கிய அமைப்பு',
      hi: 'जर्मन वाक्य निर्माण',
      kn: 'ಜರ್ಮನ್ ವಾಕ್ಯ ರಚನೆ',
      te: 'జర్మన్ వాక్య నిర్మాణం',
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0E131F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141B2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context, _isCompleted),
        ),
        title: Text(
          '$appBarTitle • ${_family.rootGerman}',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _isExamMode ? _buildExamWidgets() : _buildStudyWidgets(),
        ),
      ),
    );
  }

  List<Widget> _buildStudyWidgets() {
    final tapHint = GermanLocalizationHelper.pick(
      en: 'Tap any German phrase to hear native de-DE audio',
      ml: 'ഉച്ചാരണം കേൾക്കാൻ ഓരോ ജർമൻ വാക്യത്തിലും ടാപ്പ് ചെയ്യൂ',
      ta: 'உச்சரிப்பைக் கேட்க ஜெர்மன் வாக்கியத்தைத் தட்டவும்',
      hi: 'उच्चारण सुनने के लिए जर्मन वाक्य पर टैप करें',
      kn: 'ಉಚ್ಚಾರಣೆ ಕೇಳಲು ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ',
      te: 'ఉచ్చారణ వినడానికి జర్మన్ వాక్యంపై నొక్కండి',
    );
    final examBtn = GermanLocalizationHelper.pick(
      en: 'Start German Pattern Quiz ➔',
      ml: 'ജർമൻ പാറ്റേൺ പരീക്ഷ തുടങ്ങാം ➔',
      ta: 'ஜெர்மன் பயிற்சித் தேர்வு ➔',
      hi: 'जर्मन पैटर्न परीक्षा शुरू करें ➔',
      kn: 'ಜರ್ಮನ್ ಪರೀಕ್ಷೆ ಪ್ರಾರಂಭಿಸಿ ➔',
      te: 'జర్మన్ ప్యాటర్న్ పరీక్ష ప్రారంభించండి ➔',
    );

    return [
      Text(
        GermanLocalizationHelper.pickMap(_family.title),
        style: GoogleFonts.outfit(
          color: const Color(0xFF38BDF8),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 4),
      Text(tapHint,
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12.5)),
      const SizedBox(height: 14),
      ..._family.items.map(
        (item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF172033),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
          ),
          child: ListTile(
            onTap: () => _speak(item.de),
            title: Text(
              item.de,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
            subtitle: Text(
              GermanLocalizationHelper.pickMap(item.native),
              style: GoogleFonts.inter(
                color: const Color(0xFFFACC15),
                fontSize: 13,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.volume_up_rounded,
                  color: Color(0xFF38BDF8)),
              onPressed: () => _speak(item.de),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => setState(() => _isExamMode = true),
          child: Text(examBtn,
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w900)),
        ),
      ),
      const SizedBox(height: 14),
      const PocketBannerAdWidget(margin: EdgeInsets.only(bottom: 10)),
    ];
  }

  List<Widget> _buildExamWidgets() {
    if (_isCompleted) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF172033),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Column(
            children: [
              const Text('🎉🇩🇪', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              Text(
                GermanLocalizationHelper.pick(
                  en: 'German Patterns Mastered!',
                  ml: 'ജർമൻ വാക്യ പാറ്റേൺ പൂർത്തിയാക്കി!',
                  ta: 'ஜெர்மன் வாக்கிய முறை முடிந்தது!',
                  hi: 'जर्मन पैटर्न पूरा हुआ!',
                  kn: 'ಜರ್ಮನ್ ವಾಕ್ಯ ರಚನೆ ಪೂರ್ಣಗೊಂಡಿದೆ!',
                  te: 'జర్మన్ ప్యాటర్న్స్ పూర్తయ్యాయి!',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
      ];
    }

    final current = _examQueue[_examIndex];
    final qPrompt = GermanLocalizationHelper.pick(
      en: 'Select the matching German phrase below:',
      ml: 'ശരിയായ ജർമൻ വാക്യം താഴെ നിന്ന് തിരഞ്ഞെടുക്കുക:',
      ta: 'பொருத்தமான ஜெர்மன் வாக்கியத்தைத் தேர்ந்தெடுக்கவும்:',
      hi: 'नीचे से सही जर्मन वाक्य चुनें:',
      kn: 'ಕೆಳಗಿನಿಂದ ಸರಿಯಾದ ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಆರಿಸಿ:',
      te: 'క్రింది వాటిలో సరైన జర్మన్ వాక్యాన్ని ఎంచుకోండి:',
    );

    return [
      if (_solvedItems.isNotEmpty) ...[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _solvedItems
              .map(
                (it) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  ),
                  child: Text(it.de,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF6EE7B7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
      ],
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF172033),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            Text(
              '${_examIndex + 1} / ${_examQueue.length}',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              GermanLocalizationHelper.pickMap(current.native),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(qPrompt,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
      const SizedBox(height: 14),
      for (final opt in _currentOptions)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _onSelectOption(opt),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _wrongOption == opt
                    ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _wrongOption == opt
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(opt,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}
