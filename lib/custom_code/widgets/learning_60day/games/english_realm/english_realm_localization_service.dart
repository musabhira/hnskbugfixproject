import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 🌐 Unified Multi-Language Localization Engine for English Realm
/// Fully eliminates hardcoded Malayalam and dynamically adapts to the user's
/// chosen native language (Tamil, Hindi, Malayalam, Telugu, Kannada, English).
class EnglishRealmLocalizationService {
  /// Normalize any language input (name, code, or mixed) to standard 2-letter code
  static String normalizeLang(String? lang) {
    if (lang == null || lang.trim().isEmpty) {
      lang = PocketLanguageService.currentLanguage;
    }
    final l = lang.trim().toLowerCase();
    if (l.contains('tamil') || l == 'ta') return 'ta';
    if (l.contains('hind') || l == 'hi') return 'hi';
    if (l.contains('malay') || l == 'ml') return 'ml';
    if (l.contains('telug') || l == 'te') return 'te';
    if (l.contains('kannad') || l == 'kn') return 'kn';
    if (l.contains('arab') || l == 'ar') return 'ar';
    if (l.contains('bengal') || l == 'bn') return 'bn';
    return 'en';
  }

  /// Get native language display name with emoji
  static String getLanguageBadge(String? lang) {
    final code = normalizeLang(lang);
    switch (code) {
      case 'ta':
        return 'தமிழ்';
      case 'hi':
        return 'हिन्दी';
      case 'ml':
        return 'മലയാളം';
      case 'te':
        return 'తెలుగు';
      case 'kn':
        return 'ಕನ್ನಡ';
      default:
        return 'English';
    }
  }

  // =========================================================================
  // 🏛️ REGION NAMES LOCALIZATION
  // =========================================================================
  static final Map<String, Map<String, String>> _regionNames = {
    'foundations_village': {
      'en': 'English Foundations Village',
      'ml': 'അടിസ്ഥാന ഇംഗ്ലീഷ് ഗ്രാമം',
      'ta': 'அடிப்படை ஆங்கில கிராமம்',
      'hi': 'बुनियादी अंग्रेज़ी गाँव',
      'te': 'ప్రాథమిక ఆంగ్ల గ్రామం',
      'kn': 'ಮೂಲಭೂತ ಇಂಗ್ಲಿಷ್ ಹಳ್ಳಿ',
    },
    'sentence_forest': {
      'en': 'Sentence Structure Forest',
      'ml': 'വാക്യഘടന വനം',
      'ta': 'வாக்கிய அமைப்பு காடு',
      'hi': 'वाक्य संरचना वन',
      'te': 'వాక్య నిర్మాణ అడవి',
      'kn': 'ವಾಕ್ಯ ರಚನೆ ಕಾಡು',
    },
    'tense_kingdom': {
      'en': 'Tense Kingdom',
      'ml': 'കാലങ്ങളുടെ രാജ്യം (Tense Kingdom)',
      'ta': 'காலங்களின் பேரரசு (Tense Kingdom)',
      'hi': 'काल का साम्राज्य (Tense Kingdom)',
      'te': 'కాలాల సామ్రాజ్యం (Tense Kingdom)',
      'kn': 'ಕಾಲಗಳ ಸಾಮ್ರಾಜ್ಯ (Tense Kingdom)',
    },
    'modal_mountains': {
      'en': 'Question & Modal Mountains',
      'ml': 'മോഡൽ & ചോദ്യ പർവ്വതനിരകൾ',
      'ta': 'கேள்வி & மாடல் மலைத்தொடர்',
      'hi': 'प्रश्न और मॉडल पर्वतमाला',
      'te': 'ప్రశ్న & మోడల్ పర్వతాలు',
      'kn': 'ಪ್ರಶ್ನೆ ಮತ್ತು ಮೋಡಲ್ ಪರ್ವತಗಳು',
    },
    'verb_caverns': {
      'en': 'Verb & Grammar Caverns',
      'ml': 'ക്രിയാ ഗുഹകൾ',
      'ta': 'வினைச்சொல் & இலக்கண குகைகள்',
      'hi': 'क्रिया और व्याकरण गुफाएँ',
      'te': 'క్రియ & వ్యాకరణ గుహలు',
      'kn': 'ಕ್ರಿಯಾಪದ ಮತ್ತು ವ್ಯಾಕರಣ ಗುಹೆಗಳು',
    },
    'grammar_citadel': {
      'en': 'Complex Grammar Citadel',
      'ml': 'കോംപ്ലക്സ് ഗ്രാമർ കോട്ട',
      'ta': 'சிக்கலான இலக்கண கோட்டை',
      'hi': 'जटिल व्याकरण दुर्ग',
      'te': 'సంక్లిష్ట వ్యాకరణ కోట',
      'kn': 'ಕ್ಲಿಷ್ಟ ವ್ಯಾಕರಣ ಕೋಟೆ',
    },
    'sentence_islands': {
      'en': 'Advanced Sentence Islands',
      'ml': 'വാക്യ നിർമ്മാണ ദ്വീപുകൾ',
      'ta': 'மேம்பட்ட வாக்கிய தீவுகள்',
      'hi': 'उन्नत वाक्य द्वीप समूह',
      'te': 'ఉన్నత వాక్య ద్వీపాలు',
      'kn': 'ಮುಂದುವರಿದ ವಾಕ್ಯ ದ್ವೀಪಗಳು',
    },
    'vocab_town': {
      'en': 'Vocabulary Trading Town',
      'ml': 'പദസമ്പത്ത് വ്യാപാര നഗരം',
      'ta': 'சொற்களஞ்சிய வர்த்தக நகரம்',
      'hi': 'शब्दावली व्यापार नगर',
      'te': 'పదజాల వ్యాపార నగరం',
      'kn': 'ಶಬ್ದಕೋಶ ವ್ಯಾಪಾರ ನಗರ',
    },
    'pragmatics_observatory': {
      'en': 'Pronunciation & Pragmatics Realm',
      'ml': 'ഉച്ചാരണ & ആശയവിനിമയ മണ്ഡലം',
      'ta': 'உச்சரிப்பு & பயன்பாட்டு உலகம்',
      'hi': 'उच्चारण और व्यावहारिक अंग्रेज़ी क्षेत्र',
      'te': 'ఉచ్చారణ & సంభాషణ రంగం',
      'kn': 'ಉಚ್ಚಾರಣೆ ಮತ್ತು ಸಂವಹನ ಕ್ಷೇತ್ರ',
    },
  };

  static String getRegionName(String regionId, [String? lang]) {
    final code = normalizeLang(lang);
    final map = _regionNames[regionId];
    if (map != null && map.containsKey(code)) {
      return map[code]!;
    }
    return map?['en'] ?? regionId;
  }

  // =========================================================================
  // 💬 COMMON UI LABELS
  // =========================================================================
  static final Map<String, Map<String, String>> _uiStrings = {
    'correct_banner': {
      'en': '🎉 EXCELLENT! CORRECT ANSWER',
      'ml': '🎉 മികച്ചത്! ശരിയായ ഉത്തരം',
      'ta': '🎉 அருமை! சரியான விடை',
      'hi': '🎉 बहुत बढ़िया! सही उत्तर',
      'te': '🎉 అద్భుతం! సరైన సమాధానం',
      'kn': '🎉 ಅದ್ಭುತ! ಸರಿಯಾದ ಉತ್ತರ',
    },
    'incorrect_banner': {
      'en': '💡 NOT QUITE! LEARN WHY:',
      'ml': '💡 സാരമില്ല! കാരണം മനസ്സിലാക്കാം:',
      'ta': '💡 பரவாயில்லை! காரணத்தை அறியுங்கள்:',
      'hi': '💡 कोई बात नहीं! कारण समझें:',
      'te': '💡 ఫరవాలేదు! కారణం తెలుసుకోండి:',
      'kn': '💡 ಪರವಾಗಿಲ್ಲ! ಕಾರಣ ತಿಳಿಯಿರಿ:',
    },
    'next_challenge': {
      'en': 'NEXT CHALLENGE ➔',
      'ml': 'അടുത്ത ചോദ്യം ➔',
      'ta': 'அடுத்த சவால் ➔',
      'hi': 'अगली चुनौती ➔',
      'te': 'తదుపరి సవాలు ➔',
      'kn': 'ಮುಂದಿನ ಸವಾಲು ➔',
    },
    'complete_round': {
      'en': 'COMPLETE VICTORY ➔',
      'ml': 'വിജയം പൂർത്തിയാക്കൂ ➔',
      'ta': 'வெற்றி பெறுக ➔',
      'hi': 'विजय पूर्ण करें ➔',
      'te': 'విజయం పూర్తి చేయండి ➔',
      'kn': 'ವಿಜಯ ಪೂರ್ಣಗೊಳಿಸಿ ➔',
    },
    'replay_challenge': {
      'en': 'REPLAY CHALLENGE ↺',
      'ml': 'വീണ്ടും കളിക്കുക ↺',
      'ta': 'மீண்டும் விளையாடு ↺',
      'hi': 'पुनः खेलें ↺',
      'te': 'మళ్లీ ఆడండి ↺',
      'kn': 'ಮತ್ತೆ ಆಡಿ ↺',
    },
    'play_fullscreen': {
      'en': 'PLAY FULLSCREEN GAME ➔',
      'ml': 'ഫുൾസ്ക്രീൻ ഗെയിം കളിക്കൂ ➔',
      'ta': 'முழுத்திரையில் விளையாடு ➔',
      'hi': 'फुलस्क्रीन गेम खेलें ➔',
      'te': 'ఫుల్ స్క్రీన్ గేమ్ ఆడండి ➔',
      'kn': 'ಪೂರ್ಣಪರದೆಯಲ್ಲಿ ಆಟವಾಡಿ ➔',
    },
    'explore_realm': {
      'en': 'EXPLORE IN 2D OPEN-WORLD REALM',
      'ml': '2D ഓപ്പൺ വേൾഡിൽ പര്യവേക്ഷണം ചെയ്യൂ',
      'ta': '2D திறந்த உலகில் ஆராய்க',
      'hi': '2D ओपन-वर्ल्ड में घूमें',
      'te': '2D ఓపెన్ వరల్డ్‌లో అన్వేషించండి',
      'kn': '2D ಓಪನ್ ವರ್ಲ್ಡ್‌ನಲ್ಲಿ ಅನ್ವೇಷಿಸಿ',
    },
    'tap_to_play': {
      'en': 'TAP TO PLAY GAME',
      'ml': 'കളിക്കാൻ ടാപ്പ് ചെയ്യൂ',
      'ta': 'விளையாட தட்டவும்',
      'hi': 'खेलने के लिए टैप करें',
      'te': 'ఆడటానికి నొక్కండి',
      'kn': 'ಆಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
    },
    'fast_travel': {
      'en': 'FAST TRAVEL MAP',
      'ml': 'വേൾഡ് മാപ്പ് (ഫാസ്റ്റ് ട്രാവൽ)',
      'ta': 'உலக வரைபடம் (வேகப் பயணம்)',
      'hi': 'विश्व मानचित्र (फास्ट ट्रैवल)',
      'te': 'ప్రపంచ పటం (ఫాస్ట్ ట్రావెల్)',
      'kn': 'ವಿಶ್ವ ನಕ್ಷೆ (ವೇಗದ ಪ್ರಯಾಣ)',
    },
    'coins': {
      'en': 'Coins',
      'ml': 'നാണയങ്ങൾ',
      'ta': 'நாணயங்கள்',
      'hi': 'सिक्के',
      'te': 'నాణేలు',
      'kn': 'ನಾಣ್ಯಗಳು',
    },
    'play_to_learn_subtitle': {
      'en': 'Play to Learn (2 Fullscreen Games)',
      'ml': 'കളിച്ചു പഠിക്കാം (2 ഫുൾ-സ്ക്രീൻ ഗെയിമുകൾ)',
      'ta': 'விளையாடி கற்கலாம் (2 முழுத்திரை விளையாட்டுகள்)',
      'hi': 'खेलकर सीखें (2 फुल-स्क्रीन गेम्स)',
      'te': 'ఆడుతూ నేర్చుకోండి (2 ఫుల్-స్క్రీన్ గేమ్‌లు)',
      'kn': 'ಆಟವಾಡುತ್ತಾ ಕಲಿಯಿರಿ (2 ಪೂರ್ಣಪರದೆ ಆಟಗಳು)',
    },
    'town_quest_desc': {
      'en': 'Walk through the town and speak real English with characters!',
      'ml': 'നഗരത്തിലൂടെ നടന്ന് ആളുകളുമായി യഥാർത്ഥ ഇംഗ്ലീഷിൽ സംസാരിക്കുക!',
      'ta': 'நகரத்தில் நடந்து சென்று நபர்களுடன் உண்மையான ஆங்கிலத்தில் பேசுங்கள்!',
      'hi': 'शहर में घूमें और लोगों से असली अंग्रेज़ी में बात करें!',
      'te': 'నగరంలో నడుస్తూ వ్యక్తులతో నిజమైన ఆంగ్లంలో మాట్లాడండి!',
      'kn': 'ನಗರದಲ್ಲಿ ತಿರುಗಾಡಿ ಜನರೊಂದಿಗೆ ನೈಜ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಮಾತನಾಡಿ!',
    },
  };

  static String t(String key, [String? lang]) {
    final code = normalizeLang(lang);
    final entry = _uiStrings[key];
    if (entry != null && entry.containsKey(code)) {
      return entry[code]!;
    }
    return entry?['en'] ?? key;
  }

  // =========================================================================
  // 🧠 PROMPT TRANSLATION ENGINE
  // =========================================================================
  static String translatePrompt(String promptEn, String promptMl, [String? lang]) {
    final code = normalizeLang(lang);
    if (code == 'ml') return promptMl;
    if (code == 'en') return ''; // English learner already sees promptEn directly!

    final pLower = promptEn.toLowerCase();

    switch (code) {
      case 'ta': // Tamil
        if (pLower.contains('fill in the blank') || pLower.contains('complete the')) {
          return 'கோடிட்ட இடத்தை சரியான வார்த்தையால் நிரப்புக:';
        }
        if (pLower.contains('which sentence is') || pLower.contains('identify the correct')) {
          return 'இலக்கணப்படி சரியான வாக்கியத்தைத் தேர்ந்தெடுக்கவும்:';
        }
        if (pLower.contains('spot') || pLower.contains('correct the error') || pLower.contains('fix this')) {
          return 'வாக்கியத்தில் உள்ள பிழையைக் கண்டறிந்து திருத்தவும்:';
        }
        if (pLower.contains('how do you say') || pLower.contains('how would you')) {
          return 'சரியான முறையில் எவ்வாறு கூறுவீர்கள்:';
        }
        if (pLower.contains('choose the correct') || pLower.contains('select the')) {
          return 'சரியான விருப்பத்தைத் தேர்ந்தெடுக்கவும்:';
        }
        if (pLower.contains('transform') || pLower.contains('convert')) {
          return 'வாக்கியத்தை மாற்றி அமைக்கவும்:';
        }
        if (pLower.contains('what does') && pLower.contains('mean')) {
          return 'இதன் சரியான பொருள் என்ன:';
        }
        if (pLower.contains('spelling')) {
          return 'சரியான எழுத்துப்பிழையற்ற வார்த்தை எது:';
        }
        return 'சரியான விடையைத் தேர்ந்தெடுக்கவும்:';

      case 'hi': // Hindi
        if (pLower.contains('fill in the blank') || pLower.contains('complete the')) {
          return 'रिक्त स्थान को सही शब्द से भरें:';
        }
        if (pLower.contains('which sentence is') || pLower.contains('identify the correct')) {
          return 'व्याकरण के अनुसार सही वाक्य पहचानें:';
        }
        if (pLower.contains('spot') || pLower.contains('correct the error') || pLower.contains('fix this')) {
          return 'वाक्य की त्रुटि पहचानें और सही रूप चुनें:';
        }
        if (pLower.contains('how do you say') || pLower.contains('how would you')) {
          return 'इसे प्राकृतिक रूप से कैसे कहेंगे:';
        }
        if (pLower.contains('choose the correct') || pLower.contains('select the')) {
          return 'सही विकल्प का चयन करें:';
        }
        if (pLower.contains('transform') || pLower.contains('convert')) {
          return 'वाक्य को सही संरचना में बदलें:';
        }
        if (pLower.contains('what does') && pLower.contains('mean')) {
          return 'इसका सही अर्थ क्या है:';
        }
        if (pLower.contains('spelling')) {
          return 'सही वर्तनी (Spelling) वाला शब्द चुनें:';
        }
        return 'सही उत्तर चुनें:';

      case 'te': // Telugu
        if (pLower.contains('fill in the blank') || pLower.contains('complete the')) {
          return 'ఖాళీని సరైన పదంతో పూరించండి:';
        }
        if (pLower.contains('which sentence is') || pLower.contains('identify the correct')) {
          return 'వ్యాకరణపరంగా సరైన వాక్యాన్ని గుర్తించండి:';
        }
        if (pLower.contains('spot') || pLower.contains('correct the error') || pLower.contains('fix this')) {
          return 'వాక్యంలోని తప్పును గుర్తించి సరిచేయండి:';
        }
        if (pLower.contains('choose the correct') || pLower.contains('select the')) {
          return 'సరైన ఎంపికను ఎంచుకోండి:';
        }
        return 'సరైన సమాధానాన్ని ఎంచుకోండి:';

      case 'kn': // Kannada
        if (pLower.contains('fill in the blank') || pLower.contains('complete the')) {
          return 'ಖಾಲಿ ಜಾಗವನ್ನು ಸರಿಯಾದ ಪದದಿಂದ ಭರ್ತಿ ಮಾಡಿ:';
        }
        if (pLower.contains('which sentence is') || pLower.contains('identify the correct')) {
          return 'ವ್ಯಾಕರಣದ ದೃಷ್ಟಿಯಿಂದ ಸರಿಯಾದ ವಾಕ್ಯವನ್ನು ಆರಿಸಿ:';
        }
        if (pLower.contains('spot') || pLower.contains('correct the error') || pLower.contains('fix this')) {
          return 'ವಾಕ್ಯದಲ್ಲಿನ ತಪ್ಪನ್ನು ಗುರುತಿಸಿ ಸರಿಪಡಿಸಿ:';
        }
        if (pLower.contains('choose the correct') || pLower.contains('select the')) {
          return 'ಸರಿಯಾದ ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ:';
        }
        return 'ಸರಿಯಾದ ಉತ್ತರವನ್ನು ಆರಿಸಿ:';

      default:
        return promptMl;
    }
  }

  // =========================================================================
  // 💡 EXPLANATION TRANSLATION ENGINE
  // =========================================================================
  static String translateExplanation(String expEn, String expMl, [String? lang]) {
    final code = normalizeLang(lang);
    if (code == 'ml') return expMl;
    if (code == 'en') return expEn;

    final eLower = expEn.toLowerCase();

    switch (code) {
      case 'ta': // Tamil
        if (eLower.contains('subject') && eLower.contains('verb') && eLower.contains('singular')) {
          return 'ஆங்கிலத்தில் ஒருமை எழுவாய்க்கு (Singular subject) ஒருமை வினையே (Singular verb) வர வேண்டும்.';
        }
        if (eLower.contains('past') || eLower.contains('v2') || eLower.contains('yesterday')) {
          return 'கடந்த கால நிகழ்வுகளைக் குறிக்க Past tense (V2) வடிவம் பயன்படுத்தப்படுகிறது.';
        }
        if (eLower.contains('present continuous') || eLower.contains('-ing')) {
          return 'தற்போது தொடர்ந்து நிகழும் செயல்களுக்கு Present Continuous (-ing) வடிவம் வர வேண்டும்.';
        }
        if (eLower.contains('third person singular') || eLower.contains('he, she, it') || eLower.contains('-s') || eLower.contains('-es')) {
          return 'He, She, It ஆகிய ஒருமைப் பெயர்களுக்கு Simple Present-ல் வினைச்சொல்லுடன் -s அல்லது -es சேரும்.';
        }
        if (eLower.contains('preposition')) {
          return 'ஆங்கிலத்தில் குறிப்பிட்ட நேரம், இடம் ஆகியவற்றிற்கு முறையான Preposition அமைப்பைப் பயன்படுத்த வேண்டும்.';
        }
        if (eLower.contains('passive') || eLower.contains('v3') || eLower.contains('past participle')) {
          return 'செயப்பாட்டு வினையில் (Passive Voice) Be-வினை + Past Participle (V3) வடிவம் வரும்.';
        }
        if (eLower.contains('condition') || eLower.contains('if')) {
          return 'நிபந்தனை வாக்கியங்களில் (Conditionals) கால அமைப்பு விதிமுறையின்படி சரியாக இணைய வேண்டும்.';
        }
        if (eLower.contains('polite') || eLower.contains('would you mind') || eLower.contains('could')) {
          return 'பணிவான வேண்டுகோள்களுக்கு Would, Could ஆகிய மோடல் வினைகள் இயல்பாகப் பயன்படுகின்றன.';
        }
        return 'ஆங்கில இலக்கண விதிகளின்படி இந்த விடையே சரியானது ($expEn).';

      case 'hi': // Hindi
        if (eLower.contains('subject') && eLower.contains('verb') && eLower.contains('singular')) {
          return 'अंग्रेज़ी में एकवचन कर्ता (Singular subject) के साथ एकवचन क्रिया (Singular verb) आती है।';
        }
        if (eLower.contains('past') || eLower.contains('v2') || eLower.contains('yesterday')) {
          return 'भूतकाल की घटनाओं को व्यक्त करने के लिए Past tense (V2) का प्रयोग होता है।';
        }
        if (eLower.contains('present continuous') || eLower.contains('-ing')) {
          return 'वर्तमान में जारी कार्य के लिए Present Continuous (-ing) रूप का प्रयोग किया जाता है।';
        }
        if (eLower.contains('third person singular') || eLower.contains('he, she, it') || eLower.contains('-s') || eLower.contains('-es')) {
          return 'He, She, It के साथ Simple Present में क्रिया में -s या -es जोड़ा जाता है।';
        }
        if (eLower.contains('preposition')) {
          return 'समय और स्थान को सही ढंग से दर्शाने के लिए उचित Preposition का प्रयोग आवश्यक है।';
        }
        if (eLower.contains('passive') || eLower.contains('v3') || eLower.contains('past participle')) {
          return 'Passive voice में सहायक क्रिया के साथ Past Participle (V3) का प्रयोग होता है।';
        }
        if (eLower.contains('condition') || eLower.contains('if')) {
          return 'शर्त वाले वाक्यों (Conditionals) में सही Tense संयोजन का पालन किया जाता है।';
        }
        if (eLower.contains('polite') || eLower.contains('would you mind') || eLower.contains('could')) {
          return 'विनम्र बातचीत और अनुरोध के लिए Would और Could का उपयोग सबसे स्वाभाविक है।';
        }
        return 'अंग्रेज़ी व्याकरण के नियमानुसार यही सही विकल्प है ($expEn)।';

      case 'te': // Telugu
        if (eLower.contains('past') || eLower.contains('v2')) {
          return 'గతంలో పూర్తయిన పనులను సూచించడానికి Past Tense (V2) ఉపయోగిస్తారు.';
        }
        if (eLower.contains('singular') && eLower.contains('verb')) {
          return 'ఏకవచన కర్తతో ఏకవచన క్రియ మాత్రమే రావాలి.';
        }
        return 'వ్యాకరణ నియమాల ప్రకారం ఈ సమాధానం సరైనది ($expEn).';

      case 'kn': // Kannada
        if (eLower.contains('past') || eLower.contains('v2')) {
          return 'ಹಿಂದೆ ನಡೆದ ಘಟನೆಗಳನ್ನು ವಿವರಿಸಲು Past Tense (V2) ಬಳಸಲಾಗುತ್ತದೆ.';
        }
        if (eLower.contains('singular') && eLower.contains('verb')) {
          return 'ಏಕವಚನ ಸಬ್ಜೆಕ್ಟ್ ಜೊತೆಗೆ ಏಕವಚನ ಕ್ರಿಯಾಪದ ಬರಬೇಕು.';
        }
        return 'ವ್ಯಾಕರಣ ನಿಯಮಗಳ ಪ್ರಕಾರ ಈ ಉತ್ತರ ಸರಿಯಾಗಿದೆ ($expEn).';

      default:
        return expMl;
    }
  }

  // =========================================================================
  // 🎮 GAME DESCRIPTION TRANSLATOR
  // =========================================================================
  static String translateGameDescription(String descEn, String descMl, [String? lang]) {
    final code = normalizeLang(lang);
    if (code == 'ml') return descMl;
    if (code == 'en') return descEn;

    switch (code) {
      case 'ta':
        return '2D விளையாட்டின் மூலம் இந்த இலக்கண தலைப்பில் பயிற்சி பெற்று தேர்ச்சி பெறுங்கள்.';
      case 'hi':
        return '2D गेम खेलकर इस व्याकरण विषय का अभ्यास करें और महारत हासिल करें।';
      case 'te':
        return '2D గేమ్ ద్వారా ఈ అంశాన్ని సాధన చేసి పట్టు సాధించండి.';
      case 'kn':
        return '2D ಆಟದ ಮೂಲಕ ಈ ವ್ಯಾಕರಣ ವಿಷಯವನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿ.';
      default:
        return descMl;
    }
  }
}
