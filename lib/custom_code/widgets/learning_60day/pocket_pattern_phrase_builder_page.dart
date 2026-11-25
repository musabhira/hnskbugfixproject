import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_vocab_curriculum.dart';

class _PatternPhraseItem {
  final String en;
  final String ml;
  final String ta;
  final String hi;
  final String kn;
  final String te;

  const _PatternPhraseItem({
    required this.en,
    required this.ml,
    required this.ta,
    required this.hi,
    required this.kn,
    required this.te,
  });

  String forLang(String lang) {
    switch (lang.toLowerCase()) {
      case 'tamil':
      case 'ta':
        return ta;
      case 'hindi':
      case 'hi':
        return hi;
      case 'kannada':
      case 'kn':
        return kn;
      case 'telugu':
      case 'te':
        return te;
      default:
        return ml;
    }
  }
}

class _PatternFamily {
  final String rootWord;
  final String title;
  final List<_PatternPhraseItem> items;

  const _PatternFamily({
    required this.rootWord,
    required this.title,
    required this.items,
  });
}

/// 🧩 Step 20: Minimal 2-Column Pattern Phrase Builder + Exam (90 Days)
class PocketPatternPhraseBuilderPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final void Function(int finishedStep)? onStepFinished;

  const PocketPatternPhraseBuilderPage({
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
        builder: (_) => PocketPatternPhraseBuilderPage(
          day: day,
          stepIndex: stepIndex,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketPatternPhraseBuilderPage> createState() =>
      _PocketPatternPhraseBuilderPageState();
}

class _PocketPatternPhraseBuilderPageState
    extends State<PocketPatternPhraseBuilderPage> {
  final FlutterTts _tts = FlutterTts();
  late final _PatternFamily _family;
  bool _isExamMode = false;
  int _examIndex = 0;
  final List<_PatternPhraseItem> _solvedItems = [];
  late List<_PatternPhraseItem> _examQueue;
  late List<String> _currentOptions;
  String? _wrongOption;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _family = _getFamilyForDay(widget.day);
    _examQueue = List<_PatternPhraseItem>.from(_family.items)..shuffle();
    _prepareOptions();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
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
        .where((e) => e.en != target.en)
        .map((e) => e.en)
        .toList()
      ..shuffle();
    _currentOptions = [target.en, ...others.take(3)]..shuffle();
    _wrongOption = null;
  }

  void _onSelectExamOption(String chosen) {
    if (_isCompleted || _examIndex >= _examQueue.length) return;
    final target = _examQueue[_examIndex];
    if (chosen == target.en) {
      HapticFeedback.mediumImpact();
      PocketGameAudioService.instance.playCorrectSound();
      _speak(target.en);
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

  static _PatternFamily _getFamilyForDay(int day) {
    if (day >= 1 && day <= _families.length) {
      return _families[day - 1];
    }
    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final seen = <String>{};
    final items = <_PatternPhraseItem>[];
    for (final v in vocab) {
      final w = v.word.trim();
      if (w.isEmpty || !seen.add(w.toLowerCase())) continue;
      items.add(
        _PatternPhraseItem(
          en: w,
          ml: v.malayalamMeaning.isNotEmpty ? v.malayalamMeaning : v.definition,
          ta: v.tamilMeaning.isNotEmpty ? v.tamilMeaning : v.definition,
          hi: v.hindiMeaning.isNotEmpty ? v.hindiMeaning : v.definition,
          kn: v.kannadaMeaning.isNotEmpty ? v.kannadaMeaning : v.definition,
          te: v.teluguMeaning.isNotEmpty ? v.teluguMeaning : v.definition,
        ),
      );
      if (items.length >= 8) break;
    }
    if (items.isNotEmpty) {
      return _PatternFamily(
        rootWord: 'Day $day',
        title: 'Day $day • Core Expressions',
        items: items,
      );
    }
    return _families[(day - 1) % _families.length];
  }

  static const List<_PatternFamily> _families = [
    _PatternFamily(
      rootWord: 'How',
      title: 'How — Question Patterns',
      items: [
        _PatternPhraseItem(en: 'How far', ml: 'എത്ര ദൂരം', ta: 'எவ்வளவு தூரம்', hi: 'कितनी दूर', kn: 'ಎಷ್ಟು ದೂರ', te: 'ఎంత దూరం'),
        _PatternPhraseItem(en: 'How much', ml: 'എത്ര വില / എത്രത്തോളം', ta: 'எவ்வளவு', hi: 'कितना', kn: 'ಎಷ್ಟು', te: 'ఎంత'),
        _PatternPhraseItem(en: 'How many', ml: 'എത്ര എണ്ണം', ta: 'எத்தனை', hi: 'कितने', kn: 'ಎಷ್ಟು ಸಂಖ್ಯೆ', te: 'ఎన్ని'),
        _PatternPhraseItem(en: 'How long', ml: 'എത്ര സമയം', ta: 'எவ்வளவு நேரம்', hi: 'कितनी देर', kn: 'ಎಷ್ಟು ಸಮಯ', te: 'ఎంత సమయం'),
        _PatternPhraseItem(en: 'How often', ml: 'എത്ര തവണ', ta: 'எவ்வளவு அடிக்கடி', hi: 'कितनी बार', kn: 'ಎಷ್ಟು ಬಾರಿ', te: 'ఎన్నిసార్లు'),
        _PatternPhraseItem(en: 'How old', ml: 'എത്ര വയസ്സ്', ta: 'என்ன வயது', hi: 'कितनी उम्र', kn: 'ಎಷ್ಟು ವಯಸ್ಸು', te: 'ఎంత వయస్సు'),
        _PatternPhraseItem(en: 'How soon', ml: 'എത്ര പെട്ടെന്ന്', ta: 'எவ்வளவு விரைவில்', hi: 'कितनी जल्दी', kn: 'ಎಷ್ಟು ಬೇಗ', te: 'ఎంత త్వరగా'),
        _PatternPhraseItem(en: 'How about you', ml: 'നിങ്ങളുടെ കാര്യമോ', ta: 'நீங்கள் எப்படி', hi: 'आपका क्या हाल है', kn: 'ನಿಮ್ಮ ಬಗ್ಗೆ ಏನು', te: 'మీ సంగతి ఏంటి'),
      ],
    ),
    _PatternFamily(
      rootWord: 'Who',
      title: 'Who — People Patterns',
      items: [
        _PatternPhraseItem(en: 'Who is this', ml: 'ഇത് ആരാണ്', ta: 'இவர் யார்', hi: 'यह कौन है', kn: 'ಇವರು ಯಾರು', te: 'ఇది ఎవరు'),
        _PatternPhraseItem(en: 'Who is that', ml: 'അത് ആരാണ്', ta: 'அவர் யார்', hi: 'वह कौन है', kn: 'ಅವರು ಯಾರು', te: 'అది ఎవరు'),
        _PatternPhraseItem(en: 'Who are you', ml: 'നിങ്ങൾ ആരാണ്', ta: 'நீங்கள் யார்', hi: 'आप कौन हैं', kn: 'ನೀವು ಯಾರು', te: 'మీరు ఎవరు'),
        _PatternPhraseItem(en: 'Who said that', ml: 'ആരാണ് അത് പറഞ്ഞത്', ta: 'அதை யார் சொன்னது', hi: 'किसने कहा वह', kn: 'ಅದನ್ನು ಯಾರು ಹೇಳಿದರು', te: 'అది ఎవరు చెప్పారు'),
        _PatternPhraseItem(en: 'Who knows', ml: 'ആർക്കറിയാം', ta: 'யாருக்குத் தெரியும்', hi: 'किसको पता', kn: 'ಯಾರಿಗೆ ಗೊತ್ತು', te: 'ఎవరికి తెలుసు'),
        _PatternPhraseItem(en: 'Who is coming', ml: 'ആരാണ് വരുന്നത്', ta: 'யார் வருகிறார்கள்', hi: 'कौन आ रहा है', kn: 'ಯಾರು ಬರುತ್ತಿದ್ದಾರೆ', te: 'ఎవరు వస్తున్నారు'),
        _PatternPhraseItem(en: 'Who called', ml: 'ആരാണ് വിളിച്ചത്', ta: 'யார் அழைத்தது', hi: 'किसने बुलाया', kn: 'ಯಾರು ಕರೆ ಮಾಡಿದರು', te: 'ఎవరు పిలిచారు'),
        _PatternPhraseItem(en: 'Who is next', ml: 'അടുത്തത് ആരാണ്', ta: 'அடுத்தது யார்', hi: 'अगला कौन है', kn: 'ಮುಂದೆ ಯಾರು', te: 'తర్వాత ఎవరు'),
      ],
    ),
    _PatternFamily(
      rootWord: 'This is',
      title: 'This is — Everyday Statements',
      items: [
        _PatternPhraseItem(en: 'This is for you', ml: 'ഇത് നിങ്ങൾക്കുള്ളതാണ്', ta: 'இது உங்களுக்கானது', hi: 'यह आपके लिए है', kn: 'ಇದು ನಿಮಗಾಗಿ', te: 'ఇది మీ కోసం'),
        _PatternPhraseItem(en: 'This is true', ml: 'ഇത് സത്യമാണ്', ta: 'இது உண்மை', hi: 'यह सच है', kn: 'ಇದು ನಿಜ', te: 'ఇది నిజం'),
        _PatternPhraseItem(en: 'This is impossible', ml: 'ഇത് അസാധ്യമാണ്', ta: 'இது சாத்தியமில்லை', hi: 'यह असंभव है', kn: 'ಇದು ಅಸಾಧ್ಯ', te: 'ఇది అసాధ్యం'),
        _PatternPhraseItem(en: 'This is enough', ml: 'ഇത് മതി', ta: 'இது போதும்', hi: 'यह काफी है', kn: 'ಇದು ಸಾಕು', te: 'ఇది చాలు'),
        _PatternPhraseItem(en: 'This is urgent', ml: 'ഇത് അത്യാവശ്യമാണ്', ta: 'இது அவசரம்', hi: 'यह जरूरी है', kn: 'ಇದು ತುರ್ತು', te: 'ఇది అత్యవసరం'),
        _PatternPhraseItem(en: 'This is great', ml: 'ഇത് ഗംഭീരമാണ്', ta: 'இது அருமை', hi: 'यह बहुत बढ़िया है', kn: 'ಇದು ಅದ್ಭುತ', te: 'ఇది చాలా బాగుంది'),
        _PatternPhraseItem(en: 'This is mine', ml: 'ഇത് എന്റേതാണ്', ta: 'இது என்னுடையது', hi: 'यह मेरा है', kn: 'ಇದು ನನ್ನದು', te: 'ఇది నాది'),
        _PatternPhraseItem(en: 'This is new', ml: 'ഇത് പുതിയതാണ്', ta: 'இது புதியது', hi: 'यह नया है', kn: 'ಇದು ಹೊಸದು', te: 'ఇది కొత్తది'),
      ],
    ),
    _PatternFamily(
      rootWord: 'What',
      title: 'What — Clarity Patterns',
      items: [
        _PatternPhraseItem(en: 'What is this', ml: 'ഇത് എന്താണ്', ta: 'இது என்ன', hi: 'यह क्या है', kn: 'ಇದು ಏನು', te: 'ఇది ఏమిటి'),
        _PatternPhraseItem(en: 'What happened', ml: 'എന്ത് സംഭവിച്ചു', ta: 'என்ன நடந்தது', hi: 'क्या हुआ', kn: 'ಏನಾಯಿತು', te: 'ఏమి జరిగింది'),
        _PatternPhraseItem(en: 'What time is it', ml: 'സമയം എത്രയായി', ta: 'மணி என்ன', hi: 'समय क्या हुआ है', kn: 'ಸಮಯ ಎಷ್ಟಾಯಿತು', te: 'సమయం ఎంత అయింది'),
        _PatternPhraseItem(en: 'What is next', ml: 'അടുത്തത് എന്താണ്', ta: 'அடுத்து என்ன', hi: 'आगे क्या है', kn: 'ಮುಂದೆ ಏನು', te: 'తర్వాత ఏమిటి'),
        _PatternPhraseItem(en: 'What do you need', ml: 'നിങ്ങൾക്ക് എന്താണ് വേണ്ടത്', ta: 'உங்களுக்கு என்ன வேண்டும்', hi: 'आपको क्या चाहिए', kn: 'ನಿಮಗೆ ಏನು ಬೇಕು', te: 'మీకు ఏమి కావాలి'),
        _PatternPhraseItem(en: 'What is the price', ml: 'ഇതിന് എത്ര വിലയാണ്', ta: 'விலை என்ன', hi: 'कीमत क्या है', kn: 'ಬೆಲೆ ಎಷ್ಟು', te: 'ధర ఎంత'),
      ],
    ),
    _PatternFamily(
      rootWord: 'Where',
      title: 'Where — Location Patterns',
      items: [
        _PatternPhraseItem(en: 'Where are you', ml: 'നിങ്ങൾ എവിടെയാണ്', ta: 'நீங்கள் எங்கே', hi: 'आप कहाँ हैं', kn: 'ನೀವು ಎಲ್ಲಿದ್ದೀರಿ', te: 'మీరు ఎక్కడ ఉన్నారు'),
        _PatternPhraseItem(en: 'Where is it', ml: 'അത് എവിടെയാണ്', ta: 'அது எங்கே', hi: 'वह कहाँ है', kn: 'ಅದು ಎಲ್ಲಿದೆ', te: 'అది ఎక్కడ ఉంది'),
        _PatternPhraseItem(en: 'Where do you live', ml: 'നിങ്ങൾ എവിടെയാണ് താമസിക്കുന്നത്', ta: 'நீங்கள் எங்கே வசிக்கிறீர்கள்', hi: 'आप कहाँ रहते हैं', kn: 'ನೀವು ಎಲ್ಲಿ ವಾಸಿಸುತ್ತೀರಿ', te: 'మీరు ఎక్కడ నివసిస్తున్నారు'),
        _PatternPhraseItem(en: 'Where are we going', ml: 'നമ്മൾ എങ്ങോട്ടാണ് പോകുന്നത്', ta: 'நாம் எங்கே போகிறோம்', hi: 'हम कहाँ जा रहे हैं', kn: 'ನಾವು ಎಲ್ಲಿಗೆ ಹೋಗುತ್ತಿದ್ದೇವೆ', te: 'మనం ఎక్కడికి వెళ్తున్నాము'),
        _PatternPhraseItem(en: 'Where can I sit', ml: 'എനിക്ക് എവിടെ ഇരിക്കാം', ta: 'நான் எங்கே உட்காரலாம்', hi: 'मैं कहाँ बैठ सकता हूँ', kn: 'ನಾನು ಎಲ್ಲಿ ಕುಳಿತುಕೊಳ್ಳಬಹುದು', te: 'నేను ఎక్కడ కూర్చోవచ్చు'),
        _PatternPhraseItem(en: 'Where is the exit', ml: 'പുറത്തേക്കുള്ള വഴി എവിടെയാണ്', ta: 'வெளியேறும் வழி எங்கே', hi: 'निकास कहाँ है', kn: 'ಹೊರಹೋಗುವ ದಾರಿ ಎಲ್ಲಿದೆ', te: 'బయటకు వెళ్ళే దారి ఎక్కడ ఉంది'),
      ],
    ),
    _PatternFamily(
      rootWord: 'I can',
      title: 'I can — Confidence Patterns',
      items: [
        _PatternPhraseItem(en: 'I can do it', ml: 'എനിക്കിത് ചെയ്യാൻ കഴിയും', ta: 'என்னால் செய்ய முடியும்', hi: 'मैं यह कर सकता हूँ', kn: 'ನಾನು ಇದನ್ನು ಮಾಡಬಲ್ಲೆ', te: 'నేను ఇది చేయగలను'),
        _PatternPhraseItem(en: 'I can help you', ml: 'എനിക്ക് നിങ്ങളെ സഹായിക്കാം', ta: 'நான் உங்களுக்கு உதவ முடியும்', hi: 'मैं आपकी मदद कर सकता हूँ', kn: 'ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡಬಲ್ಲೆ', te: 'నేను మీకు సహాయం చేయగలను'),
        _PatternPhraseItem(en: 'I can speak English', ml: 'എനിക്ക് ഇംഗ്ലീഷ് സംസാരിക്കാം', ta: 'என்னால் ஆங்கிலம் பேச முடியும்', hi: 'मैं अंग्रेजी बोल सकता हूँ', kn: 'ನಾನು ಇಂಗ್ಲಿಷ್ ಮಾತನಾಡಬಲ್ಲೆ', te: 'నేను ఇంగ్లీష్ మాట్లాడగలను'),
        _PatternPhraseItem(en: 'I can understand', ml: 'എനിക്ക് മനസ്സിലാകുന്നുണ്ട്', ta: 'எனக்கு புரிகிறது', hi: 'मैं समझ सकता हूँ', kn: 'ನನಗೆ ಅರ್ಥವಾಗುತ್ತದೆ', te: 'నాకు అర్థమవుతోంది'),
        _PatternPhraseItem(en: 'I can wait', ml: 'എനിക്ക് കാത്തിരിക്കാം', ta: 'நான் காத்திருக்க முடியும்', hi: 'मैं इंतज़ार कर सकता हूँ', kn: 'ನಾನು ಕಾಯಬಲ್ಲೆ', te: 'నేను వేచి ఉండగలను'),
        _PatternPhraseItem(en: 'I can try again', ml: 'എനിക്ക് വീണ്ടും ശ്രമിക്കാം', ta: 'நான் மீண்டும் முயற்சிக்க முடியும்', hi: 'मैं फिर से कोशिश कर सकता हूँ', kn: 'ನಾನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಬಲ್ಲೆ', te: 'నేను మళ్ళీ ప్రయత్నించగలను'),
      ],
    ),
    _PatternFamily(
      rootWord: 'Please',
      title: 'Please — Polite Requests',
      items: [
        _PatternPhraseItem(en: 'Please wait', ml: 'ദയവായി കാത്തിരിക്കൂ', ta: 'தயவுசெய்து காத்திருங்கள்', hi: 'कृपया प्रतीक्षा करें', kn: 'ದಯವಿಟ್ಟು ಕಾಯಿರಿ', te: 'దయచేసి వేచి ఉండండి'),
        _PatternPhraseItem(en: 'Please come in', ml: 'ദയവായി അകത്തേക്ക് വരൂ', ta: 'தயவுசெய்து உள்ளே வாருங்கள்', hi: 'कृपया अंदर आइए', kn: 'ದಯವಿಟ್ಟು ಒಳಗೆ ಬನ್ನಿ', te: 'దయచేసి లోపలికి రండి'),
        _PatternPhraseItem(en: 'Please sit down', ml: 'ദയവായി ഇരിക്കൂ', ta: 'தயவுசெய்து உட்காருங்கள்', hi: 'कृपया बैठ जाइए', kn: 'ದಯವಿಟ್ಟು ಕುಳಿತುಕೊಳ್ಳಿ', te: 'దయచేసి కూర్చోండి'),
        _PatternPhraseItem(en: 'Please help me', ml: 'ദയവായി എന്നെ സഹായിക്കൂ', ta: 'தயவுசெய்து எனக்கு உதவுங்கள்', hi: 'कृपया मेरी मदद करें', kn: 'ದಯವಿಟ್ಟು ನನಗೆ ಸಹಾಯ ಮಾಡಿ', te: 'దయచేసి నాకు సహాయం చేయండి'),
        _PatternPhraseItem(en: 'Please listen', ml: 'ദയവായി കേൾക്കൂ', ta: 'தயவுசெய்து கேளுங்கள்', hi: 'कृपया सुनिए', kn: 'ದಯವಿಟ್ಟು ಕೇಳಿ', te: 'దయచేసి వినండి'),
        _PatternPhraseItem(en: 'Please speak slowly', ml: 'ദയവായി പതുക്കെ സംസാരിക്കൂ', ta: 'தயவுசெய்து மெதுவாக பேசுங்கள்', hi: 'कृपया धीरे बोलिए', kn: 'ದಯವಿಟ್ಟು ನಿಧಾನವಾಗಿ ಮಾತನಾಡಿ', te: 'దయచేసి నెమ్మదిగా మాట్లాడండి'),
      ],
    ),
    _PatternFamily(
      rootWord: "Don't",
      title: "Don't — Action Patterns",
      items: [
        _PatternPhraseItem(en: "Don't worry", ml: 'വിഷമിക്കേണ്ട', ta: 'கவலைப்படாதீர்கள்', hi: 'चिंता मत करो', kn: 'ಚಿಂತಿಸಬೇಡಿ', te: 'చింతించకండి'),
        _PatternPhraseItem(en: "Don't forget", ml: 'മറക്കരുത്', ta: 'மறக்காதீர்கள்', hi: 'भूलना मत', kn: 'ಮರೆಯಬೇಡಿ', te: 'మర్చిపోకండి'),
        _PatternPhraseItem(en: "Don't stop", ml: 'നിർത്തരുത്', ta: 'நிறுத்தாதீர்கள்', hi: 'रुकना मत', kn: 'ನಿಲ್ಲಿಸಬೇಡಿ', te: 'ఆపకండి'),
        _PatternPhraseItem(en: "Don't be late", ml: 'വൈകരുത്', ta: 'தாமதிக்காதீர்கள்', hi: 'देर मत करना', kn: 'ತಡ ಮಾಡಬೇಡಿ', te: 'ఆలస్యం చేయకండి'),
        _PatternPhraseItem(en: "Don't give up", ml: 'തോറ്റുകൊടുക്കരുത്', ta: 'விட்டுக்கொடுக்காதீர்கள்', hi: 'हार मत मानो', kn: 'ಬಿಟ್ಟುಕೊಡಬೇಡಿ', te: 'వదిలిపెట్టకండి'),
        _PatternPhraseItem(en: "Don't rush", ml: 'തിടുക്കം കൂട്ടരുത്', ta: 'அவசரப்படாதீர்கள்', hi: 'जल्दबाज़ी मत करो', kn: 'ಅವಸರ ಮಾಡಬೇಡಿ', te: 'తొందరపడకండి'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeLang = PocketLanguageService.activeLanguageNotifier.value;

    return Scaffold(
      backgroundColor: const Color(0xFF141210),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141210),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, _isCompleted),
        ),
        title: Text(
          'Day ${widget.day} • ${_family.title}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PocketBannerAdWidget(
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: _isExamMode
              ? _buildExamView(activeLang)
              : _buildStudyView(activeLang),
        ),
      ),
    );
  }

  Widget _buildStudyView(String activeLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD95D39),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _family.rootWord.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap any row to hear pronunciation',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8EE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.55), width: 1.4),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _family.items.length; i++) ...[
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _speak(_family.items[i].en);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              const Icon(Icons.volume_up_rounded,
                                  color: Color(0xFFD95D39), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _family.items[i].en,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF1C1917),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 22,
                          color: const Color(0xFFD4A373).withValues(alpha: 0.4),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            _family.items[i].forLang(activeLang),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57534E),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < _family.items.length - 1)
                  Divider(
                    height: 1,
                    color: const Color(0xFFD4A373).withValues(alpha: 0.25),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD95D39),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _isExamMode = true);
            },
            icon: const Icon(Icons.quiz_rounded, size: 19),
            label: Text(
              'Start Pattern Exam',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const PocketBannerAdWidget(
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }

  Widget _buildExamView(String activeLang) {
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 10),
            Text(
              'Pattern Mastered!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You matched all ${_family.items.length} "${_family.rootWord}" phrases.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Continue',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final current = _examQueue[_examIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Solved Word Bank
        if (_solvedItems.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _solvedItems
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        item.en,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF6EE7B7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Question Prompt Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8EE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.55), width: 1.4),
          ),
          child: Column(
            children: [
              Text(
                'Question ${_examIndex + 1} of ${_examQueue.length}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF7A5C3D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                current.forLang(activeLang),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1C1917),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Select the matching English phrase below',
                style: GoogleFonts.inter(color: const Color(0xFF78716C), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Options
        for (final opt in _currentOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _onSelectExamOption(opt),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _wrongOption == opt
                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                      : const Color(0xFF1E1B18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _wrongOption == opt
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFD4A373).withValues(alpha: 0.4),
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white38, size: 14),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        const PocketTrueNativeAdWidget(
          placement: PocketAdPlacement.target,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}
