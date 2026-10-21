import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_language_service.dart';

/// 🌐 Unified Multi-Language Localization Engine for Verb Timeline & Tenses Arcade
/// Supports: Malayalam ('ml'), Hindi ('hi'), Tamil ('ta'), Telugu ('te'), and English ('en')
/// Ensures NO hardcoded Malayalam text appears when the user selects Hindi, Tamil, or other languages!
class PocketVerbLocalizationService {
  /// Resolves the optimal native typography for the selected language
  static TextStyle getNativeTextStyle({
    required Color color,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.0,
  }) {
    final lang = PocketLanguageService.currentLanguage.toLowerCase();
    if (lang.startsWith('hi') || lang.contains('hind')) {
      return GoogleFonts.notoSansDevanagari(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } else if (lang.startsWith('ta') || lang.contains('tamil')) {
      return GoogleFonts.notoSansTamil(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } else if (lang.startsWith('te') || lang.contains('telug')) {
      return GoogleFonts.notoSansTelugu(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } else if (lang.startsWith('kn') || lang.contains('kannad')) {
      return GoogleFonts.notoSansKannada(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } else if (lang.startsWith('ml') || lang.contains('malay')) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    }
    return GoogleFonts.outfit(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  /// Get localized interactive directive prompt
  static String getDirective({
    required String anchorTitle,
    required String anchorWord,
    String? lang,
  }) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();

    if (language.startsWith('hi') || language.contains('hind')) {
      return '$anchorTitle: "$anchorWord" दिया गया है। बाकी 2 सही रूप चुनें!';
    } else if (language.startsWith('ta') || language.contains('tamil')) {
      return '$anchorTitle: "$anchorWord" கொடுக்கப்பட்டுள்ளது. மீதமுள்ள 2 வடிவங்களைக் கண்டறியவும்!';
    } else if (language.startsWith('te') || language.contains('telug')) {
      return '$anchorTitle: "$anchorWord" ఇవ్వబడింది. మిగిలిన 2 రూపాలను కనుగొనండి!';
    } else if (language.startsWith('kn') || language.contains('kannad')) {
      return '$anchorTitle: "$anchorWord" ನೀಡಲಾಗಿದೆ. ಉಳಿದ 2 ರೂಪಗಳನ್ನು ಹುಡುಕಿ!';
    } else if (language.startsWith('ml') || language.contains('malay')) {
      return '$anchorTitle: "$anchorWord" നൽകിയിട്ടുണ്ട്. ബാക്കി 2 രൂപങ്ങൾ കണ്ടെത്തുക!';
    }
    return '$anchorTitle form "$anchorWord" is given. Tap the remaining 2 forms!';
  }

  /// Get localized Past tier subtitle based on tense category
  static String getPastSubtitle(String tenseCategory, {String? lang}) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();
    final cat = tenseCategory.toLowerCase();

    if (cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Past Continuous • चल रहा था (भूतकाल)';
      if (language.startsWith('ta')) return 'Past Continuous • கடந்த காலத்தில் நடந்தது';
      if (language.startsWith('te')) return 'Past Continuous • గతంలో జరుగుతూ ఉండినది';
      if (language.startsWith('ml')) return 'Past Continuous • കഴിഞ്ഞപ്പോൾ നടക്കുകയായിരുന്നു';
      return 'Past Continuous • Was/Were doing (Past)';
    }

    if (cat.contains('perfect') && !cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Past Perfect • पहले ही पूरा हो चुका था';
      if (language.startsWith('ta')) return 'Past Perfect • முன்பே முடிந்த செயல்';
      if (language.startsWith('te')) return 'Past Perfect • ముందే పూర్తయిన పని';
      if (language.startsWith('ml')) return 'Past Perfect • മറ്റൊരു കാര്യത്തിന് മുമ്പ് കഴിഞ്ഞത്';
      return 'Past Perfect • Had done before another event';
    }

    if (cat.contains('perfect') && cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Past Perfect Cont. • लगातार चल रहा था';
      if (language.startsWith('ta')) return 'Past Perfect Cont. • தொடர்ந்து நடந்தது';
      if (language.startsWith('te')) return 'Past Perfect Cont. • కొనసాగుతూ ఉండినది';
      if (language.startsWith('ml')) return 'Past Perfect Cont. • തുടർച്ചയായി നടക്കുകയായിരുന്നു';
      return 'Past Perfect Cont. • Had been doing';
    }

    if (cat.contains('modal') || cat.contains('habit')) {
      if (language.startsWith('hi')) return 'Past Habit / Ability • पुरानी आदत / कर सकता था';
      if (language.startsWith('ta')) return 'Past Habit / Ability • முந்தைய வழக்கம்';
      if (language.startsWith('te')) return 'Past Habit / Ability • పూర్వపు అలవాటు';
      if (language.startsWith('ml')) return 'Past Habit / Ability • പണ്ട് ശീലിച്ച / കഴിഞ്ഞ കാര്യം';
      return 'Past Habit / Ability • Used to / Could';
    }

    // Default: Simple Past
    if (language.startsWith('hi')) return 'Yesterday • बीती हुई बात (कल)';
    if (language.startsWith('ta')) return 'Yesterday • முடிந்த செயல் (நேற்று)';
    if (language.startsWith('te')) return 'Yesterday • గతించిన పని (నిన్న)';
    if (language.startsWith('ml')) return 'Yesterday • കഴിഞ്ഞ കാര്യം (ഇന്നലെ)';
    return 'Yesterday • Past Action';
  }

  /// Get localized Present tier subtitle based on tense category
  static String getPresentSubtitle(String tenseCategory, {String? lang}) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();
    final cat = tenseCategory.toLowerCase();

    if (cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Present Continuous • अभी चल रहा है';
      if (language.startsWith('ta')) return 'Present Continuous • இப்போது நடக்கிறது';
      if (language.startsWith('te')) return 'Present Continuous • ప్రస్తుతం జరుగుతున్న పని';
      if (language.startsWith('ml')) return 'Present Continuous • ഇപ്പോൾ നടന്നുകൊണ്ടിരിക്കുന്നത്';
      return 'Present Continuous • Is/Am/Are doing (Right now)';
    }

    if (cat.contains('perfect') && !cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Present Perfect • अभी-अभी पूरा हुआ';
      if (language.startsWith('ta')) return 'Present Perfect • சற்றுமுன் முடிந்த செயல்';
      if (language.startsWith('te')) return 'Present Perfect • ఇప్పుడే పూర్తయిన పని';
      if (language.startsWith('ml')) return 'Present Perfect • തൊട്ടുമുമ്പ് കഴിഞ്ഞത് / അനുഭവം';
      return 'Present Perfect • Have/Has done (Recent / Experience)';
    }

    if (cat.contains('perfect') && cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Present Perfect Cont. • काफी समय से जारी है';
      if (language.startsWith('ta')) return 'Present Perfect Cont. • தொடர்ந்து நடைபெறுகிறது';
      if (language.startsWith('te')) return 'Present Perfect Cont. • కొనసాగుతున్న పని';
      if (language.startsWith('ml')) return 'Present Perfect Cont. • കുറച്ചുകാലമായി തുടരുന്നത്';
      return 'Present Perfect Cont. • Have been doing';
    }

    if (cat.contains('modal') || cat.contains('habit')) {
      if (language.startsWith('hi')) return 'Present Habit / Ability • वर्तमान आदत / कर सकता हूँ';
      if (language.startsWith('ta')) return 'Present Habit / Ability • தற்போதைய வழக்கம்';
      if (language.startsWith('te')) return 'Present Habit / Ability • ప్రస్తుత అలవాటు';
      if (language.startsWith('ml')) return 'Present Habit / Ability • ഇപ്പോൾ ചെയ്യുന്ന ശീലം / പ്രാവീണ്യം';
      return 'Present Habit / Ability • Usually / Can / Must';
    }

    // Default: Simple Present
    if (language.startsWith('hi')) return 'Today • नियमित आदत (आज)';
    if (language.startsWith('ta')) return 'Today • வழக்கமான செயல் (இன்று)';
    if (language.startsWith('te')) return 'Today • అలవాటు (ఈరోజు)';
    if (language.startsWith('ml')) return 'Today • ഇപ്പോൾ / ശീലം (ഇന്ന്)';
    return 'Today • Routine / Habitual Action';
  }

  /// Get localized Future tier subtitle based on tense category
  static String getFutureSubtitle(String tenseCategory, {String? lang}) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();
    final cat = tenseCategory.toLowerCase();

    if (cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Future Continuous • उस समय चल रहा होगा';
      if (language.startsWith('ta')) return 'Future Continuous • எதிர்காலத்தில் நடக்கும்';
      if (language.startsWith('te')) return 'Future Continuous • భవిష్యత్తులో జరుగుతుంటుంది';
      if (language.startsWith('ml')) return 'Future Continuous • നാളെ നടന്നുകൊണ്ടിരിക്കുന്നത്';
      return 'Future Continuous • Will be doing (At that time)';
    }

    if (cat.contains('perfect') && !cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Future Perfect • उस समय तक पूरा हो चुका होगा';
      if (language.startsWith('ta')) return 'Future Perfect • அந்த நேரத்திற்குள் முடியும்';
      if (language.startsWith('te')) return 'Future Perfect • ఆ సమయానికి పూర్తవుతుంది';
      if (language.startsWith('ml')) return 'Future Perfect • ആ സമയത്തിന് മുമ്പ് പൂർത്തിയാകും';
      return 'Future Perfect • Will have done by then';
    }

    if (cat.contains('perfect') && cat.contains('continuous')) {
      if (language.startsWith('hi')) return 'Future Perfect Cont. • तब तक जारी रहेगा';
      if (language.startsWith('ta')) return 'Future Perfect Cont. • தொடர்ந்து நீடிக்கும்';
      if (language.startsWith('te')) return 'Future Perfect Cont. • అప్పటివరకు కొనసాగుతుంది';
      if (language.startsWith('ml')) return 'Future Perfect Cont. • അത്രയും കാലം തുടർന്നിട്ടുണ്ടാകും';
      return 'Future Perfect Cont. • Will have been doing';
    }

    if (cat.contains('modal') || cat.contains('habit')) {
      if (language.startsWith('hi')) return 'Future Ability / Plan • कर सकूँगा / करना होगा';
      if (language.startsWith('ta')) return 'Future Ability / Plan • செய்ய முடியும்';
      if (language.startsWith('te')) return 'Future Ability / Plan • చేయగలుగుతాను';
      if (language.startsWith('ml')) return 'Future Ability / Plan • ചെയ്യാൻ സാധിക്കുന്നത്';
      return 'Future Ability / Plan • Will be able to / Will have to';
    }

    // Default: Simple Future
    if (language.startsWith('hi')) return 'Tomorrow • आने वाला कल (भविष्य)';
    if (language.startsWith('ta')) return 'Tomorrow • நடக்கவிருப்பது (நாளை)';
    if (language.startsWith('te')) return 'Tomorrow • జరగబోయేది (రేపు)';
    if (language.startsWith('ml')) return 'Tomorrow • വരാനിരിക്കുന്നത് (നാളെ)';
    return 'Tomorrow • Future Action';
  }

  /// Get localized grammar trap
  static String getGrammarTrap({
    required String baseVerb,
    required String past,
    String? lang,
    String fallback = '',
  }) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();

    if (language.startsWith('hi')) {
      return '❌ "Did you $past?" मत कहें! ✅ "Did you $baseVerb?" कहें। (Did के साथ हमेशा V1 आता है)';
    } else if (language.startsWith('ta')) {
      return '❌ "Did you $past?" என சொல்லாதீர்கள்! ✅ "Did you $baseVerb?" என சொல்லுங்கள்। (Did உடன் V1 மட்டுமே வரும்)';
    } else if (language.startsWith('te')) {
      return '❌ "Did you $past?" అని అనకండి! ✅ "Did you $baseVerb?" అని చెప్పండి। (Did తో V1 మాత్రమే వాడాలి)';
    } else if (language.startsWith('ml')) {
      if (fallback.isNotEmpty) return fallback;
      return '❌ "Did you $past?" പറയരുത്! ✅ "Did you $baseVerb?" എന്ന് പറയുക. (Did-നൊപ്പം V1 മാത്രം)';
    }
    return '❌ Never say "Did you $past?"! ✅ Always use base form: "Did you $baseVerb?" (Did + V1 rule)';
  }

  /// Comprehensive multi-language dictionary for English action verbs
  static const Map<String, Map<String, String>> _verbDictionary = {
    'sleep': {'en': 'To sleep', 'ml': 'ഉറങ്ങുക', 'hi': 'सोना', 'ta': 'தூங்குதல்', 'te': 'నిద్రించడం'},
    'eat': {'en': 'To eat', 'ml': 'കഴിക്കുക', 'hi': 'खाना', 'ta': 'சாப்பிடுதல்', 'te': 'తినడం'},
    'go': {'en': 'To go', 'ml': 'പോകുക', 'hi': 'जाना', 'ta': 'போதல்', 'te': 'వెళ్లడం'},
    'see': {'en': 'To see', 'ml': 'കാണുക', 'hi': 'देखना', 'ta': 'பார்த்தல்', 'te': 'చూడడం'},
    'come': {'en': 'To come', 'ml': 'വരുക', 'hi': 'आना', 'ta': 'வருதல்', 'te': 'రావడం'},
    'drink': {'en': 'To drink', 'ml': 'കുടിക്കുക', 'hi': 'पीना', 'ta': 'குடித்தல்', 'te': 'తాగడం'},
    'read': {'en': 'To read', 'ml': 'വായിക്കുക', 'hi': 'पढ़ना', 'ta': 'படித்தல்', 'te': 'చదవడం'},
    'write': {'en': 'To write', 'ml': 'എഴുതുക', 'hi': 'लिखना', 'ta': 'எழுதுதல்', 'te': 'రాయడం'},
    'speak': {'en': 'To speak', 'ml': 'സംസാരിക്കുക', 'hi': 'बोलना', 'ta': 'பேசுதல்', 'te': 'మాట్లాడటం'},
    'play': {'en': 'To play', 'ml': 'കളിക്കുക', 'hi': 'खेलना', 'ta': 'விளையாடுதல்', 'te': 'ఆడటం'},
    'run': {'en': 'To run', 'ml': 'ഓടുക', 'hi': 'दौड़ना', 'ta': 'ஓடுதல்', 'te': 'పరుగెత్తడం'},
    'walk': {'en': 'To walk', 'ml': 'നടക്കുക', 'hi': 'चलना', 'ta': 'நடத்தல்', 'te': 'నడవడం'},
    'buy': {'en': 'To buy', 'ml': 'വാങ്ങുക', 'hi': 'खरीदना', 'ta': 'வாங்குதல்', 'te': 'కొనడం'},
    'sell': {'en': 'To sell', 'ml': 'വിൽക്കുക', 'hi': 'बेचना', 'ta': 'விற்பனை செய்தல்', 'te': 'అమ్మడం'},
    'pay': {'en': 'To pay', 'ml': 'പണം നൽകുക', 'hi': 'भुगतान करना', 'ta': 'பணம் செலுத்துதல்', 'te': 'చెల్లించడం'},
    'give': {'en': 'To give', 'ml': 'നൽകുക', 'hi': 'देना', 'ta': 'கொடுத்தல்', 'te': 'ఇవ్వడం'},
    'take': {'en': 'To take', 'ml': 'എടുക്കുക', 'hi': 'लेना', 'ta': 'எடுத்தல்', 'te': 'తీసుకోవడం'},
    'send': {'en': 'To send', 'ml': 'അയക്കുക', 'hi': 'भेजना', 'ta': 'அனுப்புதல்', 'te': 'పంపడం'},
    'think': {'en': 'To think', 'ml': 'ചിന്തിക്കുക', 'hi': 'सोचना', 'ta': 'யோசித்தல்', 'te': 'ఆలోచించడం'},
    'know': {'en': 'To know', 'ml': 'അറിയുക', 'hi': 'जानना', 'ta': 'அறிதல்', 'te': 'తెలుసుకోవడం'},
    'understand': {'en': 'To understand', 'ml': 'മനസ്സിലാക്കുക', 'hi': 'समझना', 'ta': 'புரிந்துகொள்ளுதல்', 'te': 'అర్థం చేసుకోవడం'},
    'learn': {'en': 'To learn', 'ml': 'പഠിക്കുക', 'hi': 'सीखना', 'ta': 'கற்றல்', 'te': 'నేర్చుకోవడం'},
    'teach': {'en': 'To teach', 'ml': 'പഠിപ്പിക്കുക', 'hi': 'सिखाना', 'ta': 'கற்பித்தல்', 'te': 'బోధించడం'},
    'make': {'en': 'To make', 'ml': 'ഉണ്ടാക്കുക', 'hi': 'बनाना', 'ta': 'உருவாக்குதல்', 'te': 'తయారు చేయడం'},
    'build': {'en': 'To build', 'ml': 'നിർമ്മിക്കുക', 'hi': 'निर्माण करना', 'ta': 'கட்டுதல்', 'te': 'నిర్మించడం'},
    'find': {'en': 'To find', 'ml': 'കണ്ടെത്തുക', 'hi': 'ढूंढना', 'ta': 'கண்டுபிடித்தல்', 'te': 'కనుగొనడం'},
    'lose': {'en': 'To lose', 'ml': 'നഷ്ടപ്പെടുക', 'hi': 'खोना', 'ta': 'இழத்தல்', 'te': 'కోల్పోవడం'},
    'leave': {'en': 'To leave', 'ml': 'പുറപ്പെടുക / വിട്ടുപോവുക', 'hi': 'छोड़ना / निकलना', 'ta': 'புறப்படுதல்', 'te': 'బయలుదేరడం'},
    'arrive': {'en': 'To arrive', 'ml': 'എത്തിച്ചേരുക', 'hi': 'पहुंचना', 'ta': 'வந்து சேருதல்', 'te': 'చేరుకోవడం'},
    'help': {'en': 'To help', 'ml': 'സഹായിക്കുക', 'hi': 'मदद करना', 'ta': 'உதவுதல்', 'te': 'సహాయం చేయడం'},
    'call': {'en': 'To call', 'ml': 'വിളിക്കുക', 'hi': 'बुलाना / फोन करना', 'ta': 'அழைத்தல்', 'te': 'పిలవడం'},
    'ask': {'en': 'To ask', 'ml': 'ചോദിക്കുക', 'hi': 'पूछना', 'ta': 'கேட்டல்', 'te': 'అడగడం'},
    'answer': {'en': 'To answer', 'ml': 'ഉത്തരം നൽകുക', 'hi': 'उत्तर देना', 'ta': 'பதிலளித்தல்', 'te': 'సమాధానం ఇవ్వడం'},
    'clean': {'en': 'To clean', 'ml': 'വൃത്തിയാക്കുക', 'hi': 'साफ करना', 'ta': 'சுத்தம் செய்தல்', 'te': 'శుభ్రం చేయడం'},
    'cook': {'en': 'To cook', 'ml': 'പാചകം ചെയ്യുക', 'hi': 'पकाना', 'ta': 'சமைத்தல்', 'te': 'వండటం'},
    'drive': {'en': 'To drive', 'ml': 'വാഹനം ഓടിക്കുക', 'hi': 'गाड़ी चलाना', 'ta': 'வண்டி ஓட்டுதல்', 'te': 'నడపడం'},
    'watch': {'en': 'To watch', 'ml': 'കാണുക / ശ്രദ്ധിക്കുക', 'hi': 'देखना', 'ta': 'பார்த்தல்', 'te': 'చూడటం'},
    'listen': {'en': 'To listen', 'ml': 'ശ്രദ്ധിച്ചു കേൾക്കുക', 'hi': 'सुनना', 'ta': 'கவனித்துக் கேட்டல்', 'te': 'వినడం'},
    'open': {'en': 'To open', 'ml': 'തുറക്കുക', 'hi': 'खोलना', 'ta': 'திறத்தல்', 'te': 'తెరవడం'},
    'close': {'en': 'To close', 'ml': 'അടയ്ക്കുക', 'hi': 'बंद करना', 'ta': 'மூடுதல்', 'te': 'మూయడం'},
    'start': {'en': 'To start', 'ml': 'ആരംഭിക്കുക', 'hi': 'शुरू करना', 'ta': 'தொடங்குதல்', 'te': 'ప్రారంభించడం'},
    'finish': {'en': 'To finish', 'ml': 'പൂർത്തിയാക്കുക', 'hi': 'समाप्त करना', 'ta': 'முடித்தல்', 'te': 'పూర్తి చేయడం'},
    'wait': {'en': 'To wait', 'ml': 'കാത്തിരിക്കുക', 'hi': 'प्रतीक्षा करना', 'ta': 'காத்திருத்தல்', 'te': 'వేచి ఉండటం'},
    'meet': {'en': 'To meet', 'ml': 'കണ്ടുമുട്ടുക', 'hi': 'मिलना', 'ta': 'சந்தித்தல்', 'te': 'కలవడం'},
    'bring': {'en': 'To bring', 'ml': 'കൊണ്ടുവരിക', 'hi': 'लाना', 'ta': 'கொண்டு வருதல்', 'te': 'తీసుకురావడం'},
    'hear': {'en': 'To hear', 'ml': 'കേൾക്കുക', 'hi': 'सुनना', 'ta': 'கேட்டல்', 'te': 'వినడం'},
    'feel': {'en': 'To feel', 'ml': 'തോന്നുക / അനുഭവപ്പെടുക', 'hi': 'महसूस करना', 'ta': 'உணருதல்', 'te': 'అనుభూతి చెందడం'},
    'win': {'en': 'To win', 'ml': 'വിജയിക്കുക', 'hi': 'जीतना', 'ta': 'வெற்றி பெறுதல்', 'te': 'గెలవడం'},
    'choose': {'en': 'To choose', 'ml': 'തിരഞ്ഞെടുക്കുക', 'hi': 'चुनना', 'ta': 'தேர்ந்தெடுத்தல்', 'te': 'ఎంచుకోవడం'},
    'travel': {'en': 'To travel', 'ml': 'യാത്ര ചെയ്യുക', 'hi': 'यात्रा करना', 'ta': 'பயணம் செய்தல்', 'te': 'ప్రయాణించడం'},
    'wake up': {'en': 'To wake up', 'ml': 'ഉണരുക', 'hi': 'जागना', 'ta': 'விழித்தல்', 'te': 'మేల్కొనడం'},
    'figure out': {'en': 'To solve/understand', 'ml': 'കണ്ടെത്തുക / പരിഹരിക്കുക', 'hi': 'हल निकालना', 'ta': 'புரிந்துகொள்ளுதல்', 'te': 'పరిష్కరించడం'},
    'give up': {'en': 'To stop trying', 'ml': 'ഉപേക്ഷിക്കുക / വിട്ടുകൊടുക്കുക', 'hi': 'हार मानना', 'ta': 'கைவிடுதல்', 'te': 'వదులుకోవడం'},
  };

  /// Resolves meaning of baseVerb in the requested native language
  static String getMeaning(String baseVerb, {String? lang, String fallback = ''}) {
    final language = (lang ?? PocketLanguageService.currentLanguage).toLowerCase();
    final key = baseVerb.toLowerCase().trim();

    if (_verbDictionary.containsKey(key)) {
      final entry = _verbDictionary[key]!;
      if (language.startsWith('hi')) return entry['hi'] ?? fallback;
      if (language.startsWith('ta')) return entry['ta'] ?? fallback;
      if (language.startsWith('te')) return entry['te'] ?? fallback;
      if (language.startsWith('ml')) return entry['ml'] ?? fallback;
      if (language.startsWith('en')) return entry['en'] ?? fallback;
    }

    if (fallback.isNotEmpty) return fallback;
    return baseVerb;
  }
}
