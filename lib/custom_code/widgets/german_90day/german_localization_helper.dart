import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/daily_vocab_item.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_curriculum_1_18.dart';

/// 🇩🇪 Pure German + Native-Language Localization & 6-Language Alphabet Helper
/// Guarantees ZERO unwanted English leakage when Native Language is
/// Malayalam, Tamil, Hindi, Kannada, or Telugu. Returns English explanations
/// strictly when the user explicitly selects English as their Native Language.
class GermanLocalizationHelper {
  GermanLocalizationHelper._();

  static String get langCode => PocketLanguageService.languageCode;
  static bool get isEnglishNative => PocketLanguageService.isEnglish;

  /// Picks strictly the user's chosen native language string.
  static String pick({
    required String en,
    required String ml,
    required String ta,
    required String hi,
    required String kn,
    required String te,
  }) {
    switch (langCode) {
      case 'ml':
        return ml;
      case 'ta':
        return ta;
      case 'hi':
        return hi;
      case 'kn':
        return kn;
      case 'te':
        return te;
      default:
        return en;
    }
  }

  static String pickMap(Map<String, String> map, {String? fallback}) {
    final v = map[langCode];
    if (v != null && v.isNotEmpty) return v;
    if (isEnglishNative && map['en'] != null && map['en']!.isNotEmpty) {
      return map['en']!;
    }
    return map['ml'] ?? map['en'] ?? fallback ?? '';
  }

  /// Resolves the meaning of a German vocab word in the active native language
  /// without falling back to English text unless English is the selected native language.
  static String vocabMeaning(DailyVocabItem item) {
    final cleanPos = GermanLocalizationHelper.partOfSpeechLabel(item.partOfSpeech);
    switch (langCode) {
      case 'ml':
        return item.malayalamMeaning.isNotEmpty
            ? item.malayalamMeaning
            : cleanPos;
      case 'ta':
        return item.tamilMeaning.isNotEmpty
            ? item.tamilMeaning
            : cleanPos;
      case 'hi':
        return item.hindiMeaning.isNotEmpty
            ? item.hindiMeaning
            : cleanPos;
      case 'kn':
        if (item.kannadaMeaning.isNotEmpty) return item.kannadaMeaning;
        return item.word;
      case 'te':
        if (item.teluguMeaning.isNotEmpty) return item.teluguMeaning;
        return item.word;
      default:
        return item.definition;
    }
  }

  static String partOfSpeechLabel(String pos) {
    final p = pos.toLowerCase();
    if (p.contains('(der)')) {
      return pick(
        en: 'Noun (der • masculine)',
        ml: 'നാമം (der • പുല്ലിംഗം)',
        ta: 'பெயர்ச்சொல் (der • ஆண்பால்)',
        hi: 'संज्ञा (der • पुल्लिंग)',
        kn: 'ನಾಮಪದ (der • ಪುಲ್ಲಿಂಗ)',
        te: 'నామవాచకం (der • పుంలింగం)',
      );
    }
    if (p.contains('(die)')) {
      return pick(
        en: 'Noun (die • feminine)',
        ml: 'നാമം (die • സ്ത്രീലിംഗം)',
        ta: 'பெயர்ச்சொல் (die • பெண்பால்)',
        hi: 'संज्ञा (die • स्त्रीलिंग)',
        kn: 'ನಾಮಪದ (die • ಸ್ತ್ರೀಲಿಂಗ)',
        te: 'నామవాచకం (die • స్త్రీలింగం)',
      );
    }
    if (p.contains('(das)')) {
      return pick(
        en: 'Noun (das • neuter)',
        ml: 'നാമം (das • നപുംസകലിംഗം)',
        ta: 'பெயர்ச்சொல் (das • அஃறிணை)',
        hi: 'संज्ञा (das • नपुंसकलिंग)',
        kn: 'ನಾಮಪದ (das • ನಪುಂಸಕಲಿಂಗ)',
        te: 'నామవాచకం (das • నపుంసకలింగం)',
      );
    }
    if (p.contains('verb')) {
      return pick(
        en: 'Verb (Action)',
        ml: 'ക്രിയ (Verb)',
        ta: 'வினைச்சொல்',
        hi: 'क्रिया',
        kn: 'ಕ್ರಿಯಾಪದ',
        te: 'క్రియ',
      );
    }
    if (p.contains('greeting')) {
      return pick(
        en: 'Greeting',
        ml: 'അഭിവാദ്യം',
        ta: 'வாழ்த்து',
        hi: 'अभिवादन',
        kn: 'ಶುಭಾಶಯ',
        te: 'అభివాదం',
      );
    }
    return pick(
      en: 'Expression',
      ml: 'പ്രയോഗം',
      ta: 'சொற்றொடர்',
      hi: 'अभिव्यक्ति',
      kn: 'ಪದಪ್ರಯೋಗ',
      te: 'పదబంధం',
    );
  }

  /// German 30-Letter Alphabet (A–Z + Ä, Ö, Ü, ß) with 6-language meanings & German examples
  static const List<Map<String, dynamic>> germanAlphabet30 = [
    {
      'letter': 'A a',
      'phonetic': '/aː/',
      'word': 'Apfel',
      'emoji': '🍎',
      'voice': 'A wie Apfel',
      'meaning': {
        'ml': 'ആപ്പിൾ',
        'ta': 'ஆப்பிள்',
        'hi': 'सेब',
        'kn': 'ಸೇಬು',
        'te': 'ఆపిల్',
        'en': 'Apple',
      },
      'guide': {
        'ml': 'വായ തുറന്ന് നീട്ടി "ആ" (Apfel) എന്ന് പറയുക',
        'ta': 'வாயை நன்றாகத் திறந்து நீண்ட "ஆ" (Apfel)',
        'hi': 'मुँह खोलकर लंबा "आ" बोलें (Apfel)',
        'kn': 'ಬಾಯಿ ತೆರೆದು ದೀರ್ಘ "ಆ" ಎಂದು ಹೇಳಿ (Apfel)',
        'te': 'నోరు తెరిచి దీర్ఘంగా "ఆ" అనండి (Apfel)',
        'en': 'Open mouth wide for clear "ah": /aː/ as in Apfel',
      },
      'exampleDe': 'Der Apfel ist rot.',
      'exampleNative': {
        'ml': 'ആപ്പിൾ ചുവപ്പാണ്.',
        'ta': 'ஆப்பிள் சிவப்பு நிறத்தில் உள்ளது.',
        'hi': 'सेब लाल है।',
        'kn': 'ಸೇಬು ಕೆಂಪಾಗಿದೆ.',
        'te': 'ఆపిల్ ఎరుపు రంగులో ఉంది.',
        'en': 'The apple is red.',
      },
    },
    {
      'letter': 'B b',
      'phonetic': '/beː/',
      'word': 'Buch',
      'emoji': '📘',
      'voice': 'B wie Buch',
      'meaning': {
        'ml': 'പുസ്തകം',
        'ta': 'புத்தகம்',
        'hi': 'किताब',
        'kn': 'ಪುಸ್ತಕ',
        'te': 'పుస్తకం',
        'en': 'Book',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ ചേർത്തുവെച്ച് "ബേ" (Buch) എന്ന് ഉച്ചരിക്കുക',
        'ta': 'இரு உதடுகளையும் சேர்த்து "பே" (Buch)',
        'hi': 'दोनों होंठ मिलाकर स्पष्ट "बे" बोलें (Buch)',
        'kn': 'ಎರಡೂ ತುಟಿಗಳನ್ನು ಸೇರಿಸಿ "ಬೇ" ಎಂದು ಹೇಳಿ (Buch)',
        'te': 'రెండు పెదాలు కలిపి "బే" అని పలకండి (Buch)',
        'en': 'Press lips together for crisp "bay": /beː/ as in Buch',
      },
      'exampleDe': 'Das Buch ist neu.',
      'exampleNative': {
        'ml': 'പുസ്തകം പുതിയതാണ്.',
        'ta': 'புத்தகம் புதியது.',
        'hi': 'किताब नई है।',
        'kn': 'ಪುಸ್ತಕ ಹೊಸದಾಗಿದೆ.',
        'te': 'పుస్తకం కొత్తది.',
        'en': 'The book is new.',
      },
    },
    {
      'letter': 'C c',
      'phonetic': '/tseː/',
      'word': 'Café',
      'emoji': '☕',
      'voice': 'C wie Café',
      'meaning': {
        'ml': 'കഫേ / കോഫി ഷോപ്പ്',
        'ta': 'கபே',
        'hi': 'कैफे',
        'kn': 'ಕೆಫೆ',
        'te': 'కేఫ్',
        'en': 'Café',
      },
      'guide': {
        'ml': 'തനിയെ വരുമ്പോൾ "ത്സേ", e/i-ക്ക് മുമ്പിൽ "ത്സ്" ശബ്ദം',
        'ta': 'தனியாக "த்ஸே" என ஒலிக்கும் (Café)',
        'hi': 'अकेले अक्षर में "त्से" (C-A-F-É) बोलें',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ "ತ್ಸೇ" ಎಂದು ಉಚ್ಚರಿಸಿ (Café)',
        'te': 'జర్మన్‌లో "త్సే" అని పలుకుతారు (Café)',
        'en': 'Pronounced /tseː/ like "tsay" in German',
      },
      'exampleDe': 'Wir sitzen im Café.',
      'exampleNative': {
        'ml': 'നമ്മൾ കഫേയിൽ ഇരിക്കുന്നു.',
        'ta': 'நாம் கபேயில் அமர்ந்திருக்கிறோம்.',
        'hi': 'हम कैफे में बैठे हैं।',
        'kn': 'ನಾವು ಕೆಫೆಯಲ್ಲಿ ಕುಳಿತಿದ್ದೇವೆ.',
        'te': 'మేము కేఫ్‌లో కూర్చున్నాము.',
        'en': 'We are sitting in the café.',
      },
    },
    {
      'letter': 'D d',
      'phonetic': '/deː/',
      'word': 'Danke',
      'emoji': '🙏',
      'voice': 'D wie Danke',
      'meaning': {
        'ml': 'നന്ദി',
        'ta': 'நன்றி',
        'hi': 'धन्यवाद',
        'kn': 'ಧನ್ಯವಾದ',
        'te': 'ధన్యవాదాలు',
        'en': 'Thank you',
      },
      'guide': {
        'ml': 'നാവ് പല്ലിന് പിന്നിൽ മുട്ടിച്ച് "ഡേ" (Danke) എന്ന് പറയുക',
        'ta': 'நாக்கை பல்லின் பின்னால் வைத்து "டே" (Danke)',
        'hi': 'जीभ दाँतों के पीछे रखकर "डे" बोलें (Danke)',
        'kn': 'ನಾಲಿಗೆಯನ್ನು ಹಲ್ಲಿನ ಹಿಂದೆ ಇರಿಸಿ "ಡೇ" (Danke)',
        'te': 'నాలుక పళ్ల వెనుక పెట్టి "డే" (Danke)',
        'en': 'Crisp tongue behind teeth: /deː/ as in Danke',
      },
      'exampleDe': 'Danke für deine Hilfe!',
      'exampleNative': {
        'ml': 'നിന്റെ സഹായത്തിന് നന്ദി!',
        'ta': 'உங்கள் உதவிக்கு நன்றி!',
        'hi': 'आपकी मदद के लिए धन्यवाद!',
        'kn': 'ನಿಮ್ಮ ಸಹಾಯಕ್ಕೆ ಧನ್ಯವಾದಗಳು!',
        'te': 'మీ సహాయానికి ధన్యవాదాలు!',
        'en': 'Thank you for your help!',
      },
    },
    {
      'letter': 'E e',
      'phonetic': '/eː/',
      'word': 'Elefant',
      'emoji': '🐘',
      'voice': 'E wie Elefant',
      'meaning': {
        'ml': 'ആന',
        'ta': 'யானை',
        'hi': 'हाथी',
        'kn': 'ಆನೆ',
        'te': 'ఏనుగు',
        'en': 'Elephant',
      },
      'guide': {
        'ml': 'ജർമനിൽ E എന്നത് "ഈ" അല്ല, വ്യക്തമായ "ഏ" ആണ് (Elefant)',
        'ta': 'ஜெர்மனில் E என்பது "ஏ" ஒலி (Elefant)',
        'hi': 'जर्मन में E का उच्चारण "ए" होता है, "ई" नहीं',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ E ಅಕ್ಷರಕ್ಕೆ "ಏ" ಶಬ್ದವಿರುತ್ತದೆ',
        'te': 'జర్మన్‌లో E అంటే "ఏ" శబ్దం (Elefant)',
        'en': 'Always sounds like "ay/eh", never "ee": /eː/',
      },
      'exampleDe': 'Der Elefant ist groß.',
      'exampleNative': {
        'ml': 'ആന വലുതാണ്.',
        'ta': 'யானை பெரியது.',
        'hi': 'हाथी बड़ा है।',
        'kn': 'ಆನೆ ದೊಡ್ಡದಾಗಿದೆ.',
        'te': 'ఏనుగు పెద్దది.',
        'en': 'The elephant is big.',
      },
    },
    {
      'letter': 'F f',
      'phonetic': '/ɛf/',
      'word': 'Fisch',
      'emoji': '🐟',
      'voice': 'F wie Fisch',
      'meaning': {
        'ml': 'മീൻ',
        'ta': 'மீன்',
        'hi': 'मछली',
        'kn': 'ಮೀನು',
        'te': 'చేప',
        'en': 'Fish',
      },
      'guide': {
        'ml': 'മുകളിലെ പല്ല് താഴത്തെ ചുണ്ടിൽ മുട്ടിച്ച് "എഫ്" (Fisch)',
        'ta': 'மேல் பல்லை கீழ் உதட்டில் வைத்து "எஃப்"',
        'hi': 'ऊपरी दाँत नीचे होंठ पर रखकर "एफ़" बोलें',
        'kn': 'ಮೇಲಿನ ಹಲ್ಲನ್ನು ಕೆಳತುಟಿಗೆ ತಾಗಿಸಿ "ಎಫ್"',
        'te': 'పై పంటిని కింది పెదవిపై ఉంచి "ఎఫ్"',
        'en': 'Gentle breath through upper teeth & bottom lip: /ɛf/',
      },
      'exampleDe': 'Der Fisch schwimmt im Meer.',
      'exampleNative': {
        'ml': 'മീൻ കടലിൽ നീന്തുന്നു.',
        'ta': 'மீன் கடலில் நீந்துகிறது.',
        'hi': 'मछली समुद्र में तैरती है।',
        'kn': 'ಮೀನು ಸಮುದ್ರದಲ್ಲಿ ಈಜುತ್ತದೆ.',
        'te': 'చేప సముద్రంలో ఈదుతుంది.',
        'en': 'The fish swims in the sea.',
      },
    },
    {
      'letter': 'G g',
      'phonetic': '/ɡeː/',
      'word': 'Guten Tag',
      'emoji': '👋',
      'voice': 'G wie Guten Tag',
      'meaning': {
        'ml': 'ശുഭദിനം',
        'ta': 'நல்ல நாள்',
        'hi': 'शुभ दिन',
        'kn': 'ಶುಭ ದಿನ',
        'te': 'శుభ దినం',
        'en': 'Good day',
      },
      'guide': {
        'ml': 'എപ്പോഴും കട്ടിയുള്ള "ഗേ" ശബ്ദം മാത്രം (ജേ അല്ല)',
        'ta': 'எப்போதும் கடினமான "கே" (g) ஒலி மட்டுமே',
        'hi': 'जर्मन में G हमेशा "ग" बोला जाता है, "ज" नहीं',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ G ಯಾವಾಗಲೂ "ಗ" ಶಬ್ದವೇ ಆಗಿರುತ್ತದೆ',
        'te': 'జర్మన్‌లో G ఎప్పుడూ కఠినమైన "గ" శబ్దం',
        'en': 'Hard "g" sound (/ɡeː/), as in Guten Tag',
      },
      'exampleDe': 'Guten Tag, mein Freund!',
      'exampleNative': {
        'ml': 'ശുഭദിനം, എന്റെ സുഹൃത്തേ!',
        'ta': 'நல்ல நாள், என் நண்பரே!',
        'hi': 'शुभ दिन, मेरे दोस्त!',
        'kn': 'ಶುಭ ದಿನ, ನನ್ನ ಸ್ನೇಹಿತ!',
        'te': 'శుభ దినం, నా స్నేహితుడా!',
        'en': 'Good day, my friend!',
      },
    },
    {
      'letter': 'H h',
      'phonetic': '/haː/',
      'word': 'Haus',
      'emoji': '🏠',
      'voice': 'H wie Haus',
      'meaning': {
        'ml': 'വീട്',
        'ta': 'வீடு',
        'hi': 'घर',
        'kn': 'ಮನೆ',
        'te': 'ఇల్లు',
        'en': 'House',
      },
      'guide': {
        'ml': 'വാക്കിന്റെ തുടക്കത്തിൽ വ്യക്തമായ "ഹാ" (Haus)',
        'ta': 'சொல்லின் தொடக்கத்தில் தெளிவான "ஹா" (Haus)',
        'hi': 'शब्द के शुरू में स्पष्ट "हा" बोलें (Haus)',
        'kn': 'ಪದದ ಆರಂಭದಲ್ಲಿ ಸ್ಪಷ್ಟವಾದ "ಹಾ" (Haus)',
        'te': 'పదం మొదట్లో స్పష్టమైన "హా" (Haus)',
        'en': 'Breathe out softly at start: /haː/ as in Haus',
      },
      'exampleDe': 'Das Haus ist hell und warm.',
      'exampleNative': {
        'ml': 'വീട് വെളിച്ചമുള്ളതും ചൂടുള്ളതുമാണ്.',
        'ta': 'வீடு வெளிச்சமாகவும் வெதுவெதுப்பாகவும் உள்ளது.',
        'hi': 'घर उजला और गर्म है।',
        'kn': 'ಮನೆ ಬೆಳಕಿನಿಂದ ಮತ್ತು ಬೆಚ್ಚಗಿದೆ.',
        'te': 'ఇల్లు వెలుతురుగా మరియు వెచ్చగా ఉంది.',
        'en': 'The house is bright and warm.',
      },
    },
    {
      'letter': 'I i',
      'phonetic': '/iː/',
      'word': 'Insel',
      'emoji': '🏝️',
      'voice': 'I wie Insel',
      'meaning': {
        'ml': 'ദ്വീപ്',
        'ta': 'தீவு',
        'hi': 'द्वीप',
        'kn': 'ದ್ವೀಪ',
        'te': 'ద్వీపం',
        'en': 'Island',
      },
      'guide': {
        'ml': 'ജർമനിൽ I എന്നത് "ഐ" അല്ല, "ഈ/ഇ" ആണ് (Insel)',
        'ta': 'ஜெர்மனில் I என்பது "ஈ/இ" ஒலி (Insel)',
        'hi': 'जर्मन में I का उच्चारण "इ / ई" होता है, "आइ" नहीं',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ I ಅಕ್ಷರಕ್ಕೆ "ಇ / ಈ" ಶಬ್ದ ಬರುತ್ತದೆ',
        'te': 'జర్మన్‌లో I అంటే "ఇ / ఈ" శబ్దం',
        'en': 'Always "ee" or short "ih", never "eye": /iː/',
      },
      'exampleDe': 'Wir reisen zur Insel.',
      'exampleNative': {
        'ml': 'ഞങ്ങൾ ദ്വീപിലേക്ക് യാത്ര ചെയ്യുന്നു.',
        'ta': 'நாம் தீவுக்குப் பயணம் செய்கிறோம்.',
        'hi': 'हम द्वीप की यात्रा कर रहे हैं।',
        'kn': 'ನಾವು ದ್ವೀಪಕ್ಕೆ ಪ್ರಯಾಣಿಸುತ್ತಿದ್ದೇವೆ.',
        'te': 'మేము ద్వీపానికి ప్రయాణిస్తున్నాము.',
        'en': 'We are traveling to the island.',
      },
    },
    {
      'letter': 'J j',
      'phonetic': '/jɔt/',
      'word': 'Jacke',
      'emoji': '🧥',
      'voice': 'J wie Jacke',
      'meaning': {
        'ml': 'ജാക്കറ്റ്',
        'ta': 'ஜாக்கெட்',
        'hi': 'जैकेट',
        'kn': 'ಜಾಕೆಟ್',
        'te': 'జాకెట్',
        'en': 'Jacket',
      },
      'guide': {
        'ml': 'ശ്രദ്ധിക്കുക! ജർമനിൽ J "യ" (Ja = യാ) എന്നാണ് ഉച്ചരിക്കുന്നത്!',
        'ta': 'கவனம்! ஜெர்மனில் J "ய" (Ja = யா) என ஒலிக்கும்!',
        'hi': 'ध्यान दें! जर्मन में J को "य" (Ja = या) बोला जाता है!',
        'kn': 'ಗಮನಿಸಿ! ಜರ್ಮನ್‌ನಲ್ಲಿ J ಅನ್ನು "ಯ" (Ja = ಯಾ) ಎನ್ನಲಾಗುತ್ತದೆ!',
        'te': 'గమనించండి! జర్మన్‌లో J ని "య" (Ja = యా) అని పలుకుతారు!',
        'en': 'Key German rule: J sounds like "Y" (Ja = Yah, Jacke = Yacke)!',
      },
      'exampleDe': 'Die Jacke ist sehr warm.',
      'exampleNative': {
        'ml': 'ജാക്കറ്റ് വളരെ ചൂടുള്ളതാണ്.',
        'ta': 'ஜாக்கெட் மிகவும் கதகதப்பாக உள்ளது.',
        'hi': 'जैकेट बहुत गर्म है।',
        'kn': 'ಜಾಕೆಟ್ ತುಂಬಾ ಬೆಚ್ಚಗಿದೆ.',
        'te': 'జాకెట్ చాలా వెచ్చగా ఉంది.',
        'en': 'The jacket is very warm.',
      },
    },
    {
      'letter': 'K k',
      'phonetic': '/kaː/',
      'word': 'Kaffee',
      'emoji': '☕',
      'voice': 'K wie Kaffee',
      'meaning': {
        'ml': 'കാപ്പി',
        'ta': 'காபி',
        'hi': 'कॉफी',
        'kn': 'ಕಾಫಿ',
        'te': 'కాఫీ',
        'en': 'Coffee',
      },
      'guide': {
        'ml': 'വ്യക്തവും ശക്തവുമായ "കാ" (Kaffee)',
        'ta': 'தெளிவான "கா" (Kaffee)',
        'hi': 'स्पष्ट "का" बोलें (Kaffee)',
        'kn': 'ಸ್ಪಷ್ಟ "ಕಾ" ಶಬ್ದ (Kaffee)',
        'te': 'స్పష్టమైన "కా" శబ్దం (Kaffee)',
        'en': 'Crisp aspirated "k": /kaː/ as in Kaffee',
      },
      'exampleDe': 'Ich trinke morgens Kaffee.',
      'exampleNative': {
        'ml': 'ഞാൻ രാവിലെ കാപ്പി കുടിക്കുന്നു.',
        'ta': 'நான் காலையில் காபி குடிக்கிறேன்.',
        'hi': 'मैं सुबह कॉफी पीता हूँ।',
        'kn': 'ನಾನು ಬೆಳಿಗ್ಗೆ ಕಾಫಿ ಕುಡಿಯುತ್ತೇನೆ.',
        'te': 'నేను ఉదయం కాఫీ తాగుతాను.',
        'en': 'I drink coffee in the morning.',
      },
    },
    {
      'letter': 'L l',
      'phonetic': '/ɛl/',
      'word': 'Lampe',
      'emoji': '💡',
      'voice': 'L wie Lampe',
      'meaning': {
        'ml': 'വിളക്ക് / ലാമ്പ്',
        'ta': 'விளக்கு',
        'hi': 'बत्ती / लैंप',
        'kn': 'ದೀಪ',
        'te': 'దీపం',
        'en': 'Lamp',
      },
      'guide': {
        'ml': 'നാവ് മുകളിലെ മോണയിൽ വെച്ച് മൃദുവായി "എൽ" (Lampe)',
        'ta': 'நாக்கை மேல் அண்ணத்தில் வைத்து "எல்" (Lampe)',
        'hi': 'जीभ ऊपर लगाकर हल्का "एल" बोलें (Lampe)',
        'kn': 'ನಾಲಿಗೆಯನ್ನು ಮೇಲೆ ತಾಗಿಸಿ ಹಗುರವಾಗಿ "ಎಲ್" (Lampe)',
        'te': 'నాలుకపై భాగాన్ని తాకించి "ఎల్" (Lampe)',
        'en': 'Light, front-of-tongue L: /ɛl/ as in Lampe',
      },
      'exampleDe': 'Die Lampe leuchtet hell.',
      'exampleNative': {
        'ml': 'വിളക്ക് തെളിഞ്ഞു പ്രകാശിക്കുന്നു.',
        'ta': 'விளக்கு பிரகாசமாக எரிகிறது.',
        'hi': 'लैंप तेज़ चमक रहा है।',
        'kn': 'ದೀಪವು ಪ್ರಕಾಶಮಾನವಾಗಿ ಬೆಳಗುತ್ತದೆ.',
        'te': 'దీపం ప్రకాశవంతంగా వెలుగుతోంది.',
        'en': 'The lamp shines brightly.',
      },
    },
    {
      'letter': 'M m',
      'phonetic': '/ɛm/',
      'word': 'Mutter',
      'emoji': '👩',
      'voice': 'M wie Mutter',
      'meaning': {
        'ml': 'അമ്മ',
        'ta': 'அம்மா',
        'hi': 'माँ',
        'kn': 'ಅಮ್ಮ',
        'te': 'అమ్మ',
        'en': 'Mother',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ അടച്ച് "എം" (Mutter) എന്ന് പറയുക',
        'ta': 'உதடுகளை மூடி "எம்" (Mutter)',
        'hi': 'होंठ बंद करके "एम" बोलें (Mutter)',
        'kn': 'ತುಟಿ ಮುಚ್ಚಿ "ಎಮ್" ಎಂದು ಹೇಳಿ (Mutter)',
        'te': 'పెదాలు మూసి "ఎమ్" అని పలకండి (Mutter)',
        'en': 'Humming lips together: /ɛm/ as in Mutter',
      },
      'exampleDe': 'Meine Mutter kocht sehr gut.',
      'exampleNative': {
        'ml': 'എന്റെ അമ്മ നന്നായി പാചകം ചെയ്യുന്നു.',
        'ta': 'என் அம்மா நன்றாக சமைக்கிறார்.',
        'hi': 'मेरी माँ बहुत अच्छा खाना बनाती हैं।',
        'kn': 'ನನ್ನ ತಾಯಿ ತುಂಬಾ ಚೆನ್ನಾಗಿ ಅಡುಗೆ ಮಾಡುತ್ತಾರೆ.',
        'te': 'మా అమ్మ చాలా బాగా వంట చేస్తుంది.',
        'en': 'My mother cooks very well.',
      },
    },
    {
      'letter': 'N n',
      'phonetic': '/ɛn/',
      'word': 'Name',
      'emoji': '🪪',
      'voice': 'N wie Name',
      'meaning': {
        'ml': 'പേര്',
        'ta': 'பெயர்',
        'hi': 'नाम',
        'kn': 'ಹೆಸರು',
        'te': 'పేరు',
        'en': 'Name',
      },
      'guide': {
        'ml': 'നാവ് അണ്ണാക്കിൽ മുട്ടിച്ച് "എൻ" (Name)',
        'ta': 'நாக்கை அண்ணத்தில் வைத்து "என்" (Name)',
        'hi': 'जीभ तालु से लगाकर "एन" बोलें (Name)',
        'kn': 'ನಾಲಿಗೆಯನ್ನು ಮೇಲೆ ಇರಿಸಿ "ಎನ್" (Name)',
        'te': 'నాలుకపై ఉంచి "ఎన్" (Name)',
        'en': 'Clear nasal N: /ɛn/ as in Name',
      },
      'exampleDe': 'Mein Name ist Paul.',
      'exampleNative': {
        'ml': 'എന്റെ പേര് പോൾ എന്നാണ്.',
        'ta': 'என் பெயர் பால்.',
        'hi': 'मेरा नाम पॉल है।',
        'kn': 'ನನ್ನ ಹೆಸರು ಪಾಲ್.',
        'te': 'నా పేరు పాల్.',
        'en': 'My name is Paul.',
      },
    },
    {
      'letter': 'O o',
      'phonetic': '/oː/',
      'word': 'Oma',
      'emoji': '👵',
      'voice': 'O wie Oma',
      'meaning': {
        'ml': 'മുത്തശ്ശി',
        'ta': 'பாட்டி',
        'hi': 'दादी / नानी',
        'kn': 'ಅಜ್ಜಿ',
        'te': 'అమ్మమ్మ / నాన్నమ్మ',
        'en': 'Grandma',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ വൃത്താകൃതിയിലാക്കി "ഓ" (Oma)',
        'ta': 'உதடுகளை வட்டமாக்கி "ஓ" (Oma)',
        'hi': 'होंठ गोल करके स्पष्ट "ओ" बोलें (Oma)',
        'kn': 'ತುಟಿಗಳನ್ನು ವೃತ್ತಾಕಾರ ಮಾಡಿ "ಓ" (Oma)',
        'te': 'పెదాలను గుండ్రంగా చేసి "ఓ" (Oma)',
        'en': 'Pure rounded "oh": /oː/ as in Oma',
      },
      'exampleDe': 'Meine Oma besucht uns heute.',
      'exampleNative': {
        'ml': 'എന്റെ മുത്തശ്ശി ഇന്ന് ഞങ്ങളെ കാണാൻ വരുന്നു.',
        'ta': 'என் பாட்டி இன்று எங்களைப் பார்க்க வருகிறார்.',
        'hi': 'मेरी दादी आज हमसे मिलने आ रही हैं।',
        'kn': 'ನನ್ನ ಅಜ್ಜಿ ಇಂದು ನಮ್ಮನ್ನು ನೋಡಲು ಬರುತ್ತಿದ್ದಾರೆ.',
        'te': 'మా అమ్మమ్మ ఈరోజు మమ్మల్ని చూడటానికి వస్తోంది.',
        'en': 'My grandma is visiting us today.',
      },
    },
    {
      'letter': 'P p',
      'phonetic': '/peː/',
      'word': 'Paket',
      'emoji': '📦',
      'voice': 'P wie Paket',
      'meaning': {
        'ml': 'പാക്കറ്റ് / പാർസൽ',
        'ta': 'பார்சல்',
        'hi': 'पैकेट',
        'kn': 'ಪಾರ್ಸೆಲ್',
        'te': 'ప్యాకెట్',
        'en': 'Package',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ ചേർത്ത് ശക്തമായി "പേ" (Paket)',
        'ta': 'உதடுகளை அழுத்தி "பே" (Paket)',
        'hi': 'होंठ दबाकर स्पष्ट "पे" बोलें (Paket)',
        'kn': 'ತುಟಿ ಒತ್ತಿ "ಪೇ" ಎಂದು ಹೇಳಿ (Paket)',
        'te': 'పెదాలు నొక్కి "పే" అని పలకండి (Paket)',
        'en': 'Burst of breath: /peː/ as in Paket',
      },
      'exampleDe': 'Das Paket kommt morgen an.',
      'exampleNative': {
        'ml': 'പാർസൽ നാളെ എത്തും.',
        'ta': 'பார்சல் நாளை வரும்.',
        'hi': 'पैकेट कल आएगा।',
        'kn': 'ಪಾರ್ಸೆಲ್ ನಾಳೆ ಬರುತ್ತದೆ.',
        'te': 'ప్యాకెట్ రేపు వస్తుంది.',
        'en': 'The package arrives tomorrow.',
      },
    },
    {
      'letter': 'Q q',
      'phonetic': '/kuː/',
      'word': 'Quelle',
      'emoji': '💧',
      'voice': 'Q wie Quelle',
      'meaning': {
        'ml': 'ഉറവിടം / നീരുറവ',
        'ta': 'நீரூற்று / மூலம்',
        'hi': 'स्रोत / झरना',
        'kn': 'ಮೂಲ / ಬುಗ್ಗೆ',
        'te': 'మూలం / ఊట',
        'en': 'Source / Spring',
      },
      'guide': {
        'ml': 'ജർമനിൽ Qu എന്നതിന് "ക്വ്" (ക്വല്ലെ) എന്ന് ശബ്ദിക്കും!',
        'ta': 'ஜெர்மனில் Qu என்பது "க்வ்" என ஒலிக்கும்',
        'hi': 'जर्मन में Qu का उच्चारण "क्व" होता है (Quelle)',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ Qu ಗೆ "ಕ್ವ" ಶಬ್ದವಿರುತ್ತದೆ',
        'te': 'జర్మన్‌లో Qu ను "క్వ" అని పలుకుతారు',
        'en': 'German Qu sounds like "kv": /kuː/ in alphabet',
      },
      'exampleDe': 'Das Wasser aus der Quelle ist klar.',
      'exampleNative': {
        'ml': 'നീരുറവയിലെ വെള്ളം തെളിഞ്ഞതാണ്.',
        'ta': 'ஊற்றில் இருந்து வரும் நீர் தெளிவாக உள்ளது.',
        'hi': 'झरने का पानी साफ है।',
        'kn': 'ಬುಗ್ಗೆಯ ನೀರು ಸ್ಪಷ್ಟವಾಗಿದೆ.',
        'te': 'ఊట నుండి వచ్చే నీరు స్వచ్ఛంగా ఉంది.',
        'en': 'The water from the spring is clear.',
      },
    },
    {
      'letter': 'R r',
      'phonetic': '/ɛʁ/',
      'word': 'Regen',
      'emoji': '🌧️',
      'voice': 'R wie Regen',
      'meaning': {
        'ml': 'മഴ',
        'ta': 'மழை',
        'hi': 'बारिश',
        'kn': 'ಮಳೆ',
        'te': 'వర్షం',
        'en': 'Rain',
      },
      'guide': {
        'ml': 'തൊണ്ടയുടെ ഉൾഭാഗത്ത് നിന്ന് ചെറിയ വിറയലോടെ "എർ"',
        'ta': 'தொண்டையின் பின்புறத்தில் இருந்து "எர்"',
        'hi': 'गले के पीछे से हल्की कंपन के साथ "एर" (Regen)',
        'kn': 'ಗಂಟಲಿನ ಹಿಂಭಾಗದಿಂದ ಮೃದುವಾದ "ಎರ್"',
        'te': 'గొంతు వెనుక నుండి మెత్తగా "ఎర్"',
        'en': 'Soft uvular throat R: /ɛʁ/ as in Regen',
      },
      'exampleDe': 'Im Sommer gibt es warmen Regen.',
      'exampleNative': {
        'ml': 'വേനൽക്കാലത്ത് ഇളം ചൂടുള്ള മഴ പെയ്യുന്നു.',
        'ta': 'கோடையில் இதமான மழை பெய்கிறது.',
        'hi': 'गर्मियों में हल्की बारिश होती है।',
        'kn': 'ಬೇಸಿಗೆಯಲ್ಲಿ ಬೆಚ್ಚಗಿನ ಮಳೆ ಬರುತ್ತದೆ.',
        'te': 'వేసవిలో వెచ్చని వర్షం కురుస్తుంది.',
        'en': 'In summer there is warm rain.',
      },
    },
    {
      'letter': 'S s',
      'phonetic': '/ɛs/',
      'word': 'Sonne',
      'emoji': '☀️',
      'voice': 'S wie Sonne',
      'meaning': {
        'ml': 'സൂര്യൻ',
        'ta': 'சூரியன்',
        'hi': 'सूरज',
        'kn': 'ಸೂರ್ಯ',
        'te': 'సూర్యుడు',
        'en': 'Sun',
      },
      'guide': {
        'ml': 'സ്വരാക്ഷരത്തിന് മുമ്പിൽ S മൃദുവായ "സൊ/സ" (Sonne = സൊന്നെ)',
        'ta': 'உயிரெழுத்துக்கு முன் S மென்மையான "ஸ" (Sonne)',
        'hi': 'स्वर से पहले S हल्के "ज़" जैसा बोलें (Zonne)',
        'kn': 'ಸ್ವರದ ಮುಂದೆ S ಮೃದು "ಝ/ಸ" ಶಬ್ದ ಕೊಡುತ್ತದೆ',
        'te': 'అచ్చు ముందు S మెత్తని "జ/స" శబ్దం వస్తుంది',
        'en': 'Before vowels, S sounds like Z ("Zonne"): /ɛs/',
      },
      'exampleDe': 'Die Sonne scheint hell.',
      'exampleNative': {
        'ml': 'സൂര്യൻ തെളിഞ്ഞു പ്രകാശിക്കുന്നു.',
        'ta': 'சூரியன் பிரகாசமாக ஒளிர்கிறது.',
        'hi': 'सूरज तेज़ चमक रहा है।',
        'kn': 'ಸೂರ್ಯನು ಪ್ರಕಾಶಮಾನವಾಗಿ ಹೊಳೆಯುತ್ತಾನೆ.',
        'te': 'సూర్యుడు ప్రకాశవంతంగా ప్రకాశిస్తున్నాడు.',
        'en': 'The sun shines brightly.',
      },
    },
    {
      'letter': 'T t',
      'phonetic': '/teː/',
      'word': 'Tisch',
      'emoji': '🪑',
      'voice': 'T wie Tisch',
      'meaning': {
        'ml': 'മേശ',
        'ta': 'மேசை',
        'hi': 'मेज़',
        'kn': 'ಮೇಜು',
        'te': 'బల్ల',
        'en': 'Table',
      },
      'guide': {
        'ml': 'നാവ് അണ്ണാക്കിൽ തട്ടി ശക്തമായി "തേ/ടേ" (Tisch)',
        'ta': 'நாக்கை அண்ணத்தில் தட்டி "டே" (Tisch)',
        'hi': 'जीभ तालु से टकराकर "टे" बोलें (Tisch)',
        'kn': 'ನಾಲಿಗೆ ಮೇಲೆ ತಾಗಿಸಿ "ಟೇ" (Tisch)',
        'te': 'నాలుకపై ఉంచి "టే" (Tisch)',
        'en': 'Crisp released T: /teː/ as in Tisch',
      },
      'exampleDe': 'Das Buch liegt auf dem Tisch.',
      'exampleNative': {
        'ml': 'പുസ്തകം മേശയുടെ മുകളിലാണ്.',
        'ta': 'புத்தகம் மேசையின் மேல் உள்ளது.',
        'hi': 'किताब मेज़ पर रखी है।',
        'kn': 'ಪುಸ್ತಕ ಮೇಜಿನ ಮೇಲಿದೆ.',
        'te': 'పుస్తకం బల్లపై ఉంది.',
        'en': 'The book lies on the table.',
      },
    },
    {
      'letter': 'U u',
      'phonetic': '/uː/',
      'word': 'Uhr',
      'emoji': '🕰️',
      'voice': 'U wie Uhr',
      'meaning': {
        'ml': 'ഘടികാരം / സമയം',
        'ta': 'கடிகாரம் / மணி',
        'hi': 'घड़ी / बजे',
        'kn': 'ಗಡಿಯಾರ',
        'te': 'గడియారం',
        'en': 'Clock / O\'clock',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ കൂട്ടിപ്പിടിച്ച് എപ്പോഴും "ഊ" (Uhr = ഊർ)',
        'ta': 'உதடுகளைக் குவித்து நீண்ட "ஊ" (Uhr)',
        'hi': 'होंठ गोल करके "ऊ" बोलें (Uhr), कभी "अ" नहीं',
        'kn': 'ತುಟಿಗಳನ್ನು ಸುತ್ತಿ ದೀರ್ಘ "ಊ" (Uhr)',
        'te': 'పెదాలను దగ్గరగా ఉంచి దీర్ఘమైన "ఊ" (Uhr)',
        'en': 'Pure rounded "oo" (/uː/), never "uh/yu"',
      },
      'exampleDe': 'Wie viel Uhr ist es jetzt?',
      'exampleNative': {
        'ml': 'ഇപ്പോൾ സമയം എത്രയായി?',
        'ta': 'இப்போது மணி என்ன?',
        'hi': 'अभी कितने बजे हैं?',
        'kn': 'ಈಗ ಸಮಯ ಎಷ್ಟು ಗಂಟೆ?',
        'te': 'ఇప్పుడు సమయం ఎంత అయింది?',
        'en': 'What time is it now?',
      },
    },
    {
      'letter': 'V v',
      'phonetic': '/faʊ̯/',
      'word': 'Vogel',
      'emoji': '🐦',
      'voice': 'V wie Vogel',
      'meaning': {
        'ml': 'പക്ഷി',
        'ta': 'பறவை',
        'hi': 'पक्षी',
        'kn': 'ಪಕ್ಷಿ',
        'te': 'పక్షి',
        'en': 'Bird',
      },
      'guide': {
        'ml': 'ജർമൻ വാക്കുകളിൽ V-ന് "ഫ്" (Vogel = ഫോഗൽ) ശബ്ദമാണ്!',
        'ta': 'கவனம்! ஜெர்மனில் V பெரும்பாலும் "ஃப்" (F) போல ஒலிக்கும்',
        'hi': 'जर्मन शब्दों में V ज़्यादातर "फ़" (F) की तरह बोला जाता है',
        'kn': 'ಜರ್ಮನ್ ಪದಗಳಲ್ಲಿ V ಸಾಮಾನ್ಯವಾಗಿ "ಫ" (F) ಶಬ್ದವಾಗುತ್ತದೆ',
        'te': 'జర్మన్ పదాలలో V ఎక్కువగా "ఫ" (F) లాగా పలుకుతారు',
        'en': 'Key rule: native German V sounds like "F" (Vogel = Fogel)!',
      },
      'exampleDe': 'Der kleine Vogel singt schön.',
      'exampleNative': {
        'ml': 'ചെറിയ പക്ഷി മനോഹരമായി പാടുന്നു.',
        'ta': 'சிறிய பறவை அழகாகப் பாடுகிறது.',
        'hi': 'छोटा पक्षी सुंदर गा रहा है।',
        'kn': 'ಸಣ್ಣ ಪಕ್ಷಿ ಸುಂದರವಾಗಿ ಹಾಡುತ್ತಿದೆ.',
        'te': 'చిన్న పక్షి అందంగా పాడుతోంది.',
        'en': 'The little bird sings beautifully.',
      },
    },
    {
      'letter': 'W w',
      'phonetic': '/veː/',
      'word': 'Wasser',
      'emoji': '💧',
      'voice': 'W wie Wasser',
      'meaning': {
        'ml': 'വെള്ളം',
        'ta': 'தண்ணீர்',
        'hi': 'पानी',
        'kn': 'ನೀರು',
        'te': 'నీరు',
        'en': 'Water',
      },
      'guide': {
        'ml': 'ജർമനിൽ W എന്നാൽ "വ്" (Wasser = വസ്സർ) എന്നാണ്!',
        'ta': 'ஜெர்மனில் W என்பது "வ்" (Wasser = வஸ்ஸர்)',
        'hi': 'जर्मन में W को "व" (V) बोला जाता है (Wasser)',
        'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ W ಎಂದರೆ "ವ" (Wasser = ವಸ್ಸರ್)',
        'te': 'జర్మన్‌లో W అంటే "వ" (Wasser = వస్సర్)',
        'en': 'German W ALWAYS sounds like English V ("Vasser")!',
      },
      'exampleDe': 'Ich trinke frisches Wasser.',
      'exampleNative': {
        'ml': 'ഞാൻ ശുദ്ധമായ വെള്ളം കുടിക്കുന്നു.',
        'ta': 'நான் சுத்தமான தண்ணீர் குடிக்கிறேன்.',
        'hi': 'मैं ताज़ा पानी पीता हूँ।',
        'kn': 'ನಾನು ತಾಜಾ ನೀರು ಕುಡಿಯುತ್ತೇನೆ.',
        'te': 'నేను తాజా నీరు తాగుతున్నాను.',
        'en': 'I drink fresh water.',
      },
    },
    {
      'letter': 'X x',
      'phonetic': '/ɪks/',
      'word': 'Xylophon',
      'emoji': '🎶',
      'voice': 'X wie Xylophon',
      'meaning': {
        'ml': 'സൈലോഫോൺ വാദ്യം',
        'ta': 'சைலோபோன் இசைக்கருவி',
        'hi': 'ज़ाइलोफ़ोन वाद्य',
        'kn': 'ಕ್ಸೈಲೋಫೋನ್',
        'te': 'క్సైలోఫోన్',
        'en': 'Xylophone',
      },
      'guide': {
        'ml': '"ഇക്സ്" (ക്സ്) ശബ്ദത്തോടെ ഉച്ചരിക്കുക',
        'ta': '"இக்ஸ்" ஒலியுடன் கூறவும்',
        'hi': '"इक्स" (क्स) की ध्वनि से बोलें',
        'kn': '"ಇಕ್ಸ್" ಶಬ್ದದೊಂದಿಗೆ ಹೇಳಿ',
        'te': '"ఇక్స్" శబ్దంతో పలకండి',
        'en': 'Pronounced /ɪks/: ks sound',
      },
      'exampleDe': 'Das Kind spielt Xylophon.',
      'exampleNative': {
        'ml': 'കുട്ടി സൈലോഫോൺ വായിക്കുന്നു.',
        'ta': 'குழந்தை சைலோபோன் வாசிக்கிறது.',
        'hi': 'बच्चा ज़ाइलोफ़ोन बजा रहा है।',
        'kn': 'ಮಗು ಕ್ಸೈಲೋಫೋನ್ ನುಡಿಸುತ್ತಿದೆ.',
        'te': 'పిల్లవాడు క్సైలోఫోన్ వాయిస్తున్నాడు.',
        'en': 'The child plays xylophone.',
      },
    },
    {
      'letter': 'Y y',
      'phonetic': '/ˈʏpsilɔn/',
      'word': 'Yoga',
      'emoji': '🧘',
      'voice': 'Y wie Yoga',
      'meaning': {
        'ml': 'യോഗ',
        'ta': 'யோகா',
        'hi': 'योग',
        'kn': 'ಯೋಗ',
        'te': 'యోగా',
        'en': 'Yoga',
      },
      'guide': {
        'ml': 'അക്ഷരത്തിന്റെ പേര് "ഇപ്സിലോൺ" — വാക്കിൽ "യ/യു"',
        'ta': 'எழுத்தின் பெயர் "இப்சிலோன்"',
        'hi': 'इस अक्षर का नाम "इप्सिलोन" है',
        'kn': 'ಈ ಅಕ್ಷರದ ಹೆಸರು "ಇಪ್ಸಿಲೋನ್"',
        'te': 'ఈ అక్షరం పేరు "ఇప్సిలోన్"',
        'en': 'Called "Ypsilon" (/ˈʏpsilɔn/); y sound in Yoga',
      },
      'exampleDe': 'Morgens mache ich gern Yoga.',
      'exampleNative': {
        'ml': 'രാവിലെ ഞാൻ യോഗ ചെയ്യാറുണ്ട്.',
        'ta': 'காலையில் நான் யோகா செய்கிறேன்.',
        'hi': 'सुबह मुझे योग करना पसंद है।',
        'kn': 'ಬೆಳಿಗ್ಗೆ ನಾನು ಯೋಗ ಮಾಡಲು ಇಷ್ಟಪಡುತ್ತೇನೆ.',
        'te': 'ఉదయం నేను యోగా చేయడం ఇష్టపడతాను.',
        'en': 'In the morning I like doing yoga.',
      },
    },
    {
      'letter': 'Z z',
      'phonetic': '/tsɛt/',
      'word': 'Zug',
      'emoji': '🚆',
      'voice': 'Z wie Zug',
      'meaning': {
        'ml': 'ട്രെയിൻ / തീവണ്ടി',
        'ta': 'ரயில்',
        'hi': 'ट्रेन',
        'kn': 'ರೈಲು',
        'te': 'రైలు',
        'en': 'Train',
      },
      'guide': {
        'ml': 'വളരെ പ്രധാനം! ജർമൻ Z എന്നാൽ "ത്സ്" (Zug = ത്സൂഗ്) ആണ്!',
        'ta': 'முக்கியம்! ஜெர்மனில் Z "த்ஸ்" (Zug = த்ஸுக்) என ஒலிக்கும்!',
        'hi': 'बहुत ज़रूरी! जर्मन में Z हमेशा "त्स" (Zug = त्सूग) होता है!',
        'kn': 'ಮುಖ್ಯ ನಿಯಮ! ಜರ್ಮನ್‌ನಲ್ಲಿ Z ಎಂದರೆ "ತ್ಸ್" (Zug = ತ್ಸೂಗ್)!',
        'te': 'ముఖ్య నియమం! జర్మన్‌లో Z ఎప్పుడూ "త్స్" (Zug = త్సూగ్)!',
        'en': 'Important: German Z always sounds like "ts" (Zug = Tsoog)!',
      },
      'exampleDe': 'Der Zug fährt nach Berlin.',
      'exampleNative': {
        'ml': 'ട്രെയിൻ ബെർലിനിലേക്ക് പോകുന്നു.',
        'ta': 'ரயில் பெர்லினுக்குச் செல்கிறது.',
        'hi': 'ट्रेन बर्लिन जा रही है।',
        'kn': 'ರೈಲು ಬರ್ಲಿನ್‌ಗೆ ಹೋಗುತ್ತಿದೆ.',
        'te': 'రైలు బెర్లిన్‌కు వెళుతోంది.',
        'en': 'The train goes to Berlin.',
      },
    },
    {
      'letter': 'Ä ä',
      'phonetic': '/ɛː/',
      'word': 'Ärztin',
      'emoji': '🩺',
      'voice': 'Ä wie Ärztin',
      'meaning': {
        'ml': 'വനിതാ ഡോക്ടർ',
        'ta': 'பெண் மருத்துவர்',
        'hi': 'महिला डॉक्टर',
        'kn': 'ಮಹಿಳಾ ವೈದ್ಯೆ',
        'te': 'మహిళా డాక్టర్',
        'en': 'Female doctor',
      },
      'guide': {
        'ml': 'ഉംലൗട്ട് (Ä): "ഏ/ആ" ചേർന്ന ശബ്ദം (എയർത്സ്റ്റിൻ)',
        'ta': 'உம்லவுட் (Ä): "ஏ/ஆ" கலந்த தெளிவான ஒலி',
        'hi': 'उमलाउट (Ä): खुले मुँह से लंबा "ए" (Ärztin)',
        'kn': 'ಉಮ್ಲೌಟ್ (Ä): ತೆರೆದ ಬಾಯಿಯಿಂದ "ಏ" ಶಬ್ದ (Ärztin)',
        'te': 'ఉమ్లౌట్ (Ä): "ఏ" లాంటి శబ్దం (Ärztin)',
        'en': 'A-Umlaut: sounds like "eh/air" — Ärztin',
      },
      'exampleDe': 'Die Ärztin hilft dem Kind.',
      'exampleNative': {
        'ml': 'വനിതാ ഡോക്ടർ കുട്ടിയെ സഹായിക്കുന്നു.',
        'ta': 'பெண் மருத்துவர் குழந்தைக்கு உதவுகிறார்.',
        'hi': 'डॉक्टर बच्चे की मदद करती हैं।',
        'kn': 'ವೈದ್ಯೆ ಮಗುವಿಗೆ ಸಹಾಯ ಮಾಡುತ್ತಿದ್ದಾರೆ.',
        'te': 'డాక్టర్ చిన్నారికి సహాయం చేస్తోంది.',
        'en': 'The female doctor helps the child.',
      },
    },
    {
      'letter': 'Ö ö',
      'phonetic': '/øː/',
      'word': 'Öl',
      'emoji': '🫒',
      'voice': 'Ö wie Öl',
      'meaning': {
        'ml': 'എണ്ണ / ഓയിൽ',
        'ta': 'எண்ணெய்',
        'hi': 'तेल',
        'kn': 'ಎಣ್ಣೆ',
        'te': 'నూనె',
        'en': 'Oil',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ വട്ടത്തിൽ "ഒ" പോലെ വെച്ച് "ഏ" ഉച്ചരിക്കൂ: Ö (Öl)',
        'ta': 'உதடுகளை "ஓ" போல் குவித்து "ஏ" சொல்லுங்கள்: Ö (Öl)',
        'hi': '"ओ" जैसे गोल होंठ बनाकर "ए" की आवाज़ निकालें: Ö (Öl)',
        'kn': '"ಓ" ಆಕಾರದ ತುಟಿಯಲ್ಲಿ "ಏ" ಶಬ್ದ ಹೇಳಿ: Ö (Öl)',
        'te': '"ఓ" ఆకారంలో పెదాలు ఉంచి "ఏ" అని అనండి: Ö (Öl)',
        'en': 'O-Umlaut: round lips like "O" while saying "E"!',
      },
      'exampleDe': 'Wir kochen mit Olivenöl.',
      'exampleNative': {
        'ml': 'ഞങ്ങൾ ഒലിവ് എണ്ണ ഉപയോഗിച്ച് പാചകം ചെയ്യുന്നു.',
        'ta': 'நாங்கள் ஆலிவ் எண்ணெயில் சமைக்கிறோம்.',
        'hi': 'हम जैतून के तेल से खाना बनाते हैं।',
        'kn': 'ನಾವು ಆಲಿವ್ ಎಣ್ಣೆಯಿಂದ ಅಡುಗೆ ಮಾಡುತ್ತೇವೆ.',
        'te': 'మేము ఆలివ్ నూనెతో వంట చేస్తాము.',
        'en': 'We cook with olive oil.',
      },
    },
    {
      'letter': 'Ü ü',
      'phonetic': '/yː/',
      'word': 'Übung',
      'emoji': '🎯',
      'voice': 'Ü wie Übung',
      'meaning': {
        'ml': 'പരിശീലനം',
        'ta': 'பயிற்சி',
        'hi': 'अभ्यास',
        'kn': 'ಅಭ್ಯಾಸ',
        'te': 'అభ్యాసం',
        'en': 'Practice / Exercise',
      },
      'guide': {
        'ml': 'ചുണ്ടുകൾ "ഊ" പോലെ കൂട്ടിപ്പിടിച്ച് "ഈ" എന്ന് പറയൂ: Ü (Übung)',
        'ta': 'உதடுகளை "ஊ" போல் குவித்து "ஈ" சொல்லுங்கள்: Ü (Übung)',
        'hi': 'सीटी बजाने जैसे गोल होंठ से "ई" बोलें: Ü (Übung)',
        'kn': '"ಊ" ಆಕಾರದ ತುಟಿಯಲ್ಲಿ "ಈ" ಎಂದು ಹೇಳಿ: Ü (Übung)',
        'te': '"ఊ" ఆకారంలో పెదాలు ఉంచి "ఈ" అని అనండి: Ü (Übung)',
        'en': 'U-Umlaut: purse lips tight like "OO" while saying "EE"!',
      },
      'exampleDe': 'Übung macht den Meister.',
      'exampleNative': {
        'ml': 'പരിശീലനം നമ്മളെ മികവുറ്റതാക്കുന്നു.',
        'ta': 'பயிற்சி முழுமையாக்கும்.',
        'hi': 'अभ्यास व्यक्ति को निपुण बनाता है।',
        'kn': 'ಅಭ್ಯಾಸವು ಪರಿಪೂರ್ಣತೆಯನ್ನು ತರುತ್ತದೆ.',
        'te': 'అభ్యాసం మనిషిని నిపుణుడిని చేస్తుంది.',
        'en': 'Practice makes perfect.',
      },
    },
    {
      'letter': 'ß',
      'phonetic': '/ɛsˈtsɛt/',
      'word': 'Straße',
      'emoji': '🛣️',
      'voice': 'Eszett wie in Straße',
      'meaning': {
        'ml': 'റോഡ് / തെരുവ്',
        'ta': 'சாலை / தெரு',
        'hi': 'सड़क',
        'kn': 'ರಸ್ತೆ / ಬೀದಿ',
        'te': 'వీధి / రోడ్డు',
        'en': 'Street',
      },
      'guide': {
        'ml': 'ഇത് B അല്ല! എസ്സെറ്റ് (ß) എന്നാൽ ഇരട്ട "സ്സ്" (Straße = ഷ്ട്രാസ്സെ)',
        'ta': 'இது B அல்ல! எஸ்செட் (ß) என்பது நீண்ட "ஸ்" (Straße)',
        'hi': 'यह B नहीं है! Eszett (ß) हमेशा दोहरे "स" (ss) जैसा बोला जाता है',
        'kn': 'ಇದು B ಅಲ್ಲ! Eszett (ß) ಎಂದರೆ ದೀರ್ಘ "ಸ್ಸ್" (Straße)',
        'te': 'ఇది B కాదు! Eszett (ß) అంటే గట్టి "స్స్" (Straße)',
        'en': 'Eszett (ß) is NOT "B" — it always sounds like sharp "ss" (Straße)!',
      },
      'exampleDe': 'Die Straße ist sehr ruhig.',
      'exampleNative': {
        'ml': 'ഈ തെരുവ് വളരെ ശാന്തമാണ്.',
        'ta': 'இந்தச் சாலை மிகவும் அமைதியாக உள்ளது.',
        'hi': 'यह सड़क बहुत शांत है।',
        'kn': 'ಈ ರಸ್ತೆ ತುಂಬಾ ಶಾಂತವಾಗಿದೆ.',
        'te': 'ఈ వీధి చాలా ప్రశాంతంగా ఉంది.',
        'en': 'The street is very quiet.',
      },
    },
  ];

  /// Converts the 30-letter German Alphabet into AlphabetPhonicItem list
  /// using strictly the active Native Language for guides.
  static List<AlphabetPhonicItem> getGermanPhonicsItems() {
    return germanAlphabet30.map((item) {
      final meaningMap = Map<String, String>.from(item['meaning'] as Map);
      final guideMap = Map<String, String>.from(item['guide'] as Map);
      final nativeMeaning = pickMap(meaningMap);
      return AlphabetPhonicItem(
        letter: item['letter'] as String,
        phoneme: item['phonetic'] as String,
        exampleWord: isEnglishNative
            ? '${item['word']} (${meaningMap['en'] ?? ''})'
            : '${item['word']} • $nativeMeaning',
        pronunciationGuide: pickMap(guideMap),
        audioPrompt: item['voice'] as String,
      );
    }).toList();
  }
}
