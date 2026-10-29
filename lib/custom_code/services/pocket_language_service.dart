import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

/// 🌐 Unified Global Language & Localization Service for Pocket Mates
/// Ensures chosen native language (Hindi, Tamil, Malayalam, Telugu, Kannada, English)
/// is synchronized across local storage, Supabase user profile, and all curriculum engines.
/// Guarantees that users selecting Hindi or Tamil NEVER see hardcoded Malayalam text!
class PocketLanguageService {
  static final ValueNotifier<String> activeLanguageNotifier =
      ValueNotifier<String>('Malayalam');

  static const String kPrefNativeLang = 'pm_native_language';
  static const String kPrefMissionLang = 'pocket_mission_pref_lang';
  static const String kPrefHasSelected = 'pocket_user_has_selected_lang';

  static bool _initialized = false;

  /// Initialize and load saved language globally
  static Future<String> init({bool force = false, String? userId}) async {
    if (_initialized && !force) return activeLanguageNotifier.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = userId ?? SupaFlow.client.auth.currentUser?.id;

      String? savedLang;
      // 1. Prioritize active user's specific saved language key
      if (currentUserId != null && currentUserId.isNotEmpty) {
        savedLang = prefs.getString('pm_native_language_$currentUserId');
      }
      // 2. Global saved keys
      savedLang ??= prefs.getString(kPrefNativeLang);
      savedLang ??= prefs.getString(kPrefMissionLang);
      savedLang ??= prefs.getString('preferred_language');
      savedLang ??= prefs.getString('selected_native_language');

      if (savedLang != null && savedLang.isNotEmpty) {
        activeLanguageNotifier.value = _normalizeLanguage(savedLang);
      } else {
        // Default language: Malayalam
        activeLanguageNotifier.value = 'Malayalam';
      }
      _initialized = true;
    } catch (e) {
      debugPrint('PocketLanguageService init error: $e');
    }
    return activeLanguageNotifier.value;
  }

  /// Sync language directly from fetched Supabase user profile
  static Future<void> syncWithUserProfile(Map<String, dynamic>? profile, {String? userId}) async {
    if (profile == null) return;
    final lang = profile['native_language']?.toString();
    if (lang != null && lang.trim().isNotEmpty) {
      await setNativeLanguage(lang, userId: userId);
    }
  }

  /// Universal Multi-Language Text Resolver
  /// Returns the text in the active user's chosen language.
  /// Guarantees that Hindi, Tamil, Telugu, Kannada, and English users NEVER see Malayalam fallback!
  static String localize({
    required String en,
    String? ml,
    String? hi,
    String? ta,
    String? te,
    String? kn,
  }) {
    if (isEnglish) return en;
    if (isHindi) return (hi != null && hi.isNotEmpty) ? hi : en;
    if (isTamil) return (ta != null && ta.isNotEmpty) ? ta : en;
    if (isTelugu) return (te != null && te.isNotEmpty) ? te : en;
    if (isKannada) return (kn != null && kn.isNotEmpty) ? kn : en;
    if (isMalayalam) return (ml != null && ml.isNotEmpty) ? ml : en;
    return en;
  }

  /// Get current active native language name (e.g. "Hindi", "Tamil", "Malayalam")
  static String get currentLanguage => activeLanguageNotifier.value;

  /// Convenience language check getters
  static bool get isHindi => activeLanguageNotifier.value.toLowerCase() == 'hindi';
  static bool get isTamil => activeLanguageNotifier.value.toLowerCase() == 'tamil';
  static bool get isMalayalam => activeLanguageNotifier.value.toLowerCase() == 'malayalam';
  static bool get isTelugu => activeLanguageNotifier.value.toLowerCase() == 'telugu';
  static bool get isKannada => activeLanguageNotifier.value.toLowerCase() == 'kannada';
  static bool get isEnglish => activeLanguageNotifier.value.toLowerCase() == 'english';

  /// Standard 2-letter language code
  static String get languageCode {
    switch (activeLanguageNotifier.value.toLowerCase()) {
      case 'hindi':
      case 'hi':
        return 'hi';
      case 'tamil':
      case 'ta':
        return 'ta';
      case 'malayalam':
      case 'ml':
        return 'ml';
      case 'telugu':
      case 'te':
        return 'te';
      case 'kannada':
      case 'kn':
        return 'kn';
      default:
        return 'en';
    }
  }

  /// Update native language across all storage keys and Supabase profile
  static Future<void> setNativeLanguage(String language, {String? userId}) async {
    final normalized = _normalizeLanguage(language);
    activeLanguageNotifier.value = normalized;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrefNativeLang, normalized);
      await prefs.setString(kPrefMissionLang, normalized);
      await prefs.setString('preferred_language', normalized);
      await prefs.setString('selected_native_language', normalized);
      await prefs.setBool(kPrefHasSelected, true);

      final uid = userId ?? SupaFlow.client.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) {
        await prefs.setString('pm_native_language_$uid', normalized);
        try {
          await SupaFlow.client.from('profile').upsert({
            'user_id': uid,
            'native_language': normalized,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');
        } catch (dbErr) {
          debugPrint('Error syncing language to profile: $dbErr');
        }
      }
    } catch (e) {
      debugPrint('Error saving language in PocketLanguageService: $e');
    }
  }

  static String _normalizeLanguage(String lang) {
    final l = lang.trim().toLowerCase();
    if (l.contains('hind') || l == 'hi') return 'Hindi';
    if (l.contains('tamil') || l == 'ta') return 'Tamil';
    if (l.contains('malay') || l == 'ml') return 'Malayalam';
    if (l.contains('telug') || l == 'te') return 'Telugu';
    if (l.contains('kannad') || l == 'kn') return 'Kannada';
    if (l.contains('arab')) return 'Arabic';
    if (l.contains('bengal')) return 'Bengali';
    return 'English';
  }

  /// Placement Quiz questions dynamically localized so Hindi/Tamil users never see Malayalam
  static List<Map<String, dynamic>> getPlacementQuestions(String langName) {
    final l = _normalizeLanguage(langName).toLowerCase();

    switch (l) {
      case 'hindi':
        return [
          {
            'question': 'What is the English word for "पानी" (Water)?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'मुझे नहीं पता',
            ],
            'correct': 1,
          },
          {
            'question': 'How do you say "मुझे चाय चाहिए" (I want tea)?',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'मुझे नहीं पता',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'मुझे नहीं पता',
            ],
            'correct': 1,
          },
        ];

      case 'tamil':
        return [
          {
            'question': 'What is the English word for "தண்ணீர்" (Water)?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'எனக்கு தெரியாது',
            ],
            'correct': 1,
          },
          {
            'question': 'How do you say "எனக்கு தேநீர் வேண்டும்" (I want tea)?',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'எனக்கு தெரியாது',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'எனக்கு தெரியாது',
            ],
            'correct': 1,
          },
        ];

      case 'telugu':
        return [
          {
            'question': 'What is the English word for "నీరు" (Water)?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'నాకు తెలియదు',
            ],
            'correct': 1,
          },
          {
            'question': 'How do you say "నాకు టీ కావాలి" (I want tea)?',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'నాకు తెలియదు',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'నాకు తెలియదు',
            ],
            'correct': 1,
          },
        ];

      case 'kannada':
        return [
          {
            'question': 'What is the English word for "ನೀರು" (Water)?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'ನನಗೆ ಗೊತ್ತಿಲ್ಲ',
            ],
            'correct': 1,
          },
          {
            'question': 'How do you say "ನನಗೆ ಚಹಾ ಬೇಕು" (I want tea)?',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'ನನಗೆ ಗೊತ್ತಿಲ್ಲ',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'ನನಗೆ ಗೊತ್ತಿಲ್ಲ',
            ],
            'correct': 1,
          },
        ];

      case 'malayalam':
        return [
          {
            'question': 'What is the English word for "വെള്ളം" (Water)?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'അറിയില്ല / I do not know',
            ],
            'correct': 1,
          },
          {
            'question': 'How do you say "എനിക്ക് ചായ വേണം" (I want tea)?',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'അറിയില്ല / I do not know',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'അറിയില്ല / I do not know',
            ],
            'correct': 1,
          },
        ];

      default:
        return [
          {
            'question': 'What is the English word for "Water"?',
            'options': [
              'Paper',
              'Water',
              'Sleep',
              'I do not know',
            ],
            'correct': 1,
          },
          {
            'question': 'Choose the sentence meaning "I want tea":',
            'options': [
              'Me tea give',
              'I want tea',
              'Tea want I',
              'I do not know',
            ],
            'correct': 1,
          },
          {
            'question': 'Which sentence is grammatically correct?',
            'options': [
              'She go to the office every day.',
              'She goes to the office every day.',
              'She going to the office every day.',
              'I do not know',
            ],
            'correct': 1,
          },
        ];
    }
  }

  /// English Levels with native descriptions (3 Clean Master Tracks: Zero, Middle, Higher)
  static List<Map<String, String>> getEnglishLevels(String langName) {
    final l = _normalizeLanguage(langName).toLowerCase();

    switch (l) {
      case 'hindi':
        return [
          {
            'title': 'Level 0: Zero Foundation (ABC नहीं जानते)',
            'subtitle': 'बिल्कुल शुरुआत - बुनियादी अक्षर और आवाज़ से सीखें',
            'emoji': '🌱',
          },
          {
            'title': 'Level 1: Core Middle (साधारण बातचीत / मिडिल)',
            'subtitle': 'बुनियादी शब्द जानते हैं, आत्मविश्वास से वाक्य बनाना और बोलना सीखें',
            'emoji': '🗣️',
          },
          {
            'title': 'Level 2: Higher Fluency (प्रवाह और करियर / उच्च)',
            'subtitle': 'इंटरव्यू, ऑफिस और प्राकृतिक प्रवाह के साथ धाराप्रवाह अंग्रेज़ी',
            'emoji': '🚀',
          },
        ];

      case 'tamil':
        return [
          {
            'title': 'Level 0: Zero Foundation (ABC தெரியாது)',
            'subtitle': 'முற்றிலும் புதிது - அடிப்படை எழுத்துக்கள் மற்றும் ஒலிகள்',
            'emoji': '🌱',
          },
          {
            'title': 'Level 1: Core Middle (எளிய உரையாடல்கள் / மிடில்)',
            'subtitle': 'வார்த்தைகள் தெரியும், வாக்கியங்கள் அமைத்து சரளமாகப் பேசப் பழகுங்கள்',
            'emoji': '🗣️',
          },
          {
            'title': 'Level 2: Higher Fluency (முழு சரளம் & தொழில்முறை)',
            'subtitle': 'வேலை நேர்காணல் மற்றும் நம்பிக்கையான சரளமான ஆங்கிலம்',
            'emoji': '🚀',
          },
        ];

      case 'malayalam':
        return [
          {
            'title': 'Level 0: Zero Foundation (ABC അറിയില്ല / തുടക്കം)',
            'subtitle': 'പൂർണ്ണമായും തുടക്കം - അക്ഷരങ്ങളും ശബ്ദങ്ങളും ഉച്ചാരണവും കേട്ട് പഠിക്കാം',
            'emoji': '🌱',
          },
          {
            'title': 'Level 1: Core Middle (സാധാരണ ഇംഗ്ലീഷ് & സംഭാഷണം / മിഡിൽ)',
            'subtitle': 'വാക്കുകൾ അറിയാം, വാക്യങ്ങൾ നിർമ്മിക്കാനും സംസാരിക്കാനും പഠിക്കാം',
            'emoji': '🗣️',
          },
          {
            'title': 'Level 2: Higher Fluency (കോൺഫിഡൻസും ഫ്ലുവെൻസിയും / ഡിഗ്രി & കരിയർ)',
            'subtitle': 'ഇന്റർവ്യൂ, ഓഫീസ്, പൊതു ഇടങ്ങളിൽ ഒഴുക്കോടെ സംസാരിക്കാനുള്ള ഇംഗ്ലീഷ്',
            'emoji': '🚀',
          },
        ];

      default:
        return [
          {
            'title': 'Level 0: Zero Foundation (Starting from scratch)',
            'subtitle': 'Absolute zero - learn from letters, sounds & voice',
            'emoji': '🌱',
          },
          {
            'title': 'Level 1: Core Middle (Everyday Sentences & Conversation)',
            'subtitle': 'Know some words, learn to build sentences and speak freely',
            'emoji': '🗣️',
          },
          {
            'title': 'Level 2: Higher Fluency (Confidence, Interviews & Career)',
            'subtitle': 'Natural fluency, professional expressions & confidence',
            'emoji': '🚀',
          },
        ];
    }
  }

  /// Multilingual Vocabulary translations dictionary
  static final Map<String, Map<String, String>> _wordTranslations = {
    'hello': {
      'hindi': 'नमस्ते / हैलो',
      'tamil': 'வணக்கம் / ஹலோ',
      'malayalam': 'നമസ്കാരം / ഹലോ',
      'telugu': 'నమస్కారం / హలో',
      'kannada': 'ನಮಸ್ಕಾರ / ಹಲೋ',
    },
    'apple': {
      'hindi': 'सेब',
      'tamil': 'ஆப்பிள் பழம்',
      'malayalam': 'ആപ്പിൾ പഴം',
      'telugu': 'యాపిల్ పండు',
      'kannada': 'ಸೇಬು ಹಣ್ಣು',
    },
    'book': {
      'hindi': 'किताब / पुस्तक',
      'tamil': 'புத்தகம்',
      'malayalam': 'പുസ്തകം',
      'telugu': 'పుస్తకం',
      'kannada': 'ಪುಸ್ತಕ',
    },
    'water': {
      'hindi': 'पानी',
      'tamil': 'தண்ணீர்',
      'malayalam': 'വെള്ളം',
      'telugu': 'నీరు',
      'kannada': 'ನೀರು',
    },
    'cat': {
      'hindi': 'बिल्ली',
      'tamil': 'பூனை',
      'malayalam': 'പൂച്ച',
      'telugu': 'పిల్లి',
      'kannada': 'ಬೆಕ್ಕು',
    },
    'door': {
      'hindi': 'दरवाज़ा',
      'tamil': 'கதவு',
      'malayalam': 'വാതിൽ',
      'telugu': 'తలుపు',
      'kannada': 'ಬಾಗಿಲು',
    },
    'tea': {
      'hindi': 'चाय',
      'tamil': 'தேநீர் / டீ',
      'malayalam': 'ചായ',
      'telugu': 'టీ',
      'kannada': 'ಚಹಾ',
    },
    'food': {
      'hindi': 'खाना / भोजन',
      'tamil': 'உணவு',
      'malayalam': 'ഭക്ഷണം / ചോറ്',
      'telugu': 'ఆహారం',
      'kannada': 'ಆಹಾರ',
    },
    'money': {
      'hindi': 'पैसा / धन',
      'tamil': 'பணம்',
      'malayalam': 'പണം / കാശ്',
      'telugu': 'డబ్బు',
      'kannada': 'ಹಣ',
    },
    'market': {
      'hindi': 'बाज़ार',
      'tamil': 'சந்தை',
      'malayalam': 'ചന്ത / അങ്ങാടി',
      'telugu': 'మార్కెట్',
      'kannada': 'ಮಾರುಕಟ್ಟೆ',
    },
    'good': {
      'hindi': 'अच्छा / बढ़िया',
      'tamil': 'நல்லது',
      'malayalam': 'നല്ലത്',
      'telugu': 'మంచిది',
      'kannada': 'ಒಳ್ಳೆಯದು',
    },
    'morning': {
      'hindi': 'सुबह / सवेरा',
      'tamil': 'காலை',
      'malayalam': 'പ്രഭാതം',
      'telugu': 'ఉదయం',
      'kannada': 'ಮುಂಜಾನೆ',
    },
    'house': {
      'hindi': 'घर / मकान',
      'tamil': 'வீடு',
      'malayalam': 'വീട്',
      'telugu': 'ఇల్లు',
      'kannada': 'ಮನೆ',
    },
    'friend': {
      'hindi': 'दोस्त / मित्र',
      'tamil': 'நண்பன் / தோழன்',
      'malayalam': 'സുഹൃത്ത് / ചങ്ങാതി',
      'telugu': 'స్నేహితుడు',
      'kannada': 'ಸ್ನೇಹಿತ',
    },
    'time': {
      'hindi': 'समय / वक़्त',
      'tamil': 'நேரம்',
      'malayalam': 'സമയം',
      'telugu': 'సమయం',
      'kannada': 'ಸಮಯ',
    },
    'work': {
      'hindi': 'काम / कार्य',
      'tamil': 'வேலை',
      'malayalam': 'ജോലി / പ്രവർത്തി',
      'telugu': 'పని',
      'kannada': 'ಕೆಲಸ',
    },
    'speak': {
      'hindi': 'बोलना',
      'tamil': 'பேசுதல்',
      'malayalam': 'സംസാരിക്കുക',
      'telugu': 'మాట్లాడటం',
      'kannada': 'ಮಾತನಾಡು',
    },
    'learn': {
      'hindi': 'सीखना',
      'tamil': 'கற்றல்',
      'malayalam': 'പഠിക്കുക',
      'telugu': 'నేర్చుకోవడం',
      'kannada': 'ಕಲಿಯಿರಿ',
    },
    'help': {
      'hindi': 'मदद / सहायता',
      'tamil': 'உதவி',
      'malayalam': 'സഹായം',
      'telugu': 'సహాయం',
      'kannada': 'ಸಹಾಯ',
    },
  };

  /// Get accurate native word translation for a given language
  static String getWordTranslation(String word, String langName) {
    final key = word.trim().toLowerCase();
    final lang = _normalizeLanguage(langName).toLowerCase();
    if (_wordTranslations.containsKey(key)) {
      final entry = _wordTranslations[key]!;
      if (entry.containsKey(lang) && entry[lang]!.isNotEmpty) {
        return entry[lang]!;
      }
    }
    return '';
  }

  /// 🎓 Dynamic Learner Type Choice translations (Adult vs Kids)
  static Map<String, String> getLearnerTypeTranslations(String langName) {
    final l = _normalizeLanguage(langName).toLowerCase();
    switch (l) {
      case 'hindi':
        return {
          'title': 'Who is learning English?\nयह खाता किसके लिए है?',
          'subtitle': 'अपनी उम्र और सीखने की ज़रूरत के अनुसार ट्रैक चुनें:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18+ वयस्कों के लिए 90 दिनों का स्पोकन इंग्लिश, करियर और वास्तविक बातचीत!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 से 18 वर्ष के छात्रों के लिए स्कूल टास्क, व्याकरण और सिटाडेल फाइट्स!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 वर्ष तक के बच्चों के लिए 2D गेम्स, फोनिक्स और मज़ेदार कार्टून एडवेंचर!',
        };
      case 'tamil':
        return {
          'title': 'Who is learning English?\nஇந்த கணக்கு யாருக்காக?',
          'subtitle': 'உங்கள் வயது மற்றும் தேவைக்கு ஏற்ப வழியைத் தேர்ந்தெடுக்கவும்:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18+ பெரியவர்களுக்கான 90 நாட்கள் ஸ்போக்கன் இங்கிலீஷ், வேலைவாய்ப்பு & பயிற்சி!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 முதல் 18 வயது மாணவர்களுக்கான பள்ளி பணிகள், இலக்கணம் & பயிற்சிகள்!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 வயது வரையிலான குழந்தைகளுக்கான 2D விளையாட்டுகள் & கார்ட்டூன் போனிக்ஸ்!',
        };
      case 'telugu':
        return {
          'title': 'Who is learning English?\nఈ ఖాతా ఎవరి కోసం?',
          'subtitle': 'మీ వయస్సు మరియు అభ్యాస అవసరాల ఆధారంగా ఎంచుకోండి:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18+ పెద్దల కోసం 90 రోజుల స్పోకెన్ ఇంగ్లీష్, కెరీర్ మరియు మాట్లాడే సాధన!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 నుండి 18 సంవత్సరాల విద్యార్థుల కోసం పాఠశాల ఆంగ్లం మరియు సాధన!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 సంవత్సరాల లోపు పిల్లల కోసం 2D గేమ్‌లు మరియు కార్టూన్ ఫోనిక్స్!',
        };
      case 'kannada':
        return {
          'title': 'Who is learning English?\nಈ ಖಾತೆ ಯಾರಿಗಾಗಿ?',
          'subtitle': 'ನಿಮ್ಮ ವಯಸ್ಸು ಮತ್ತು ಕಲಿಕೆಯ ಅಗತ್ಯಕ್ಕೆ ತಕ್ಕಂತೆ ಆಯ್ಕೆಮಾಡಿ:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18+ ವಯಸ್ಕರಿಗೆ 90 ದಿನಗಳ ಸ್ಪೋಕನ್ ಇಂಗ್ಲಿಷ್ ಮತ್ತು ವೃತ್ತಿಪರ ಅಭ್ಯಾಸ!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 ರಿಂದ 18 ವರ್ಷದ ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಶಾಲಾ ಇಂಗ್ಲಿಷ್ ಮತ್ತು ಅಭ್ಯಾಸ!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 ವರ್ಷದೊಳಗಿನ ಮಕ್ಕಳಿಗೆ 2D ಆಟಗಳು ಮತ್ತು ಕಾರ್ಟೂನ್ ಫೋನಿಕ್ಸ್!',
        };
      case 'arabic':
        return {
          'title': 'Who is learning English?\nلمن هذا الحساب؟',
          'subtitle': 'اختر المسار المناسب لعمرك وأهدافك:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': 'للبالغين 18+: 90 يومًا لتعلم التحدث بالإنجليزية والمهام المهنية!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': 'للطلاب من 9 إلى 18 سنة: مهام مدرسية، قواعد ومحادثات ممتعة!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': 'للأطفال حتى 8 سنوات: ألعاب كرتونية ثنائية الأبعاد وأصوات الحروف!',
        };
      case 'bengali':
        return {
          'title': 'Who is learning English?\nএই অ্যাকাউন্টটি কার জন্য?',
          'subtitle': 'আপনার বয়স এবং লক্ষ্য অনুসারে ট্র্যাক চয়ন করুন:',
          'adultTitle': 'English Mastery (Adults)',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18+ প্রাপ্তবয়স্কদের জন্য 90 দিনের স্পোকেন ইংলিশ এবং বাস্তব অনুশীলন!',
          'studentTitle': 'Student English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 থেকে 18 বছর বয়সী শিক্ষার্থীদের জন্য স্কুল ইংরেজি এবং ব্যাকরণ!',
          'kidsTitle': 'Junior Explorer (Kids)',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 বছর পর্যন্ত শিশুদের জন্য 2D গেম এবং কার্টুন ধ্বনিবিদ্যা!',
        };
      case 'malayalam':
        return {
          'title': 'Who is learning English?\nആർക്കുവേണ്ടിയാണ് ഈ അക്കൗണ്ട്?',
          'subtitle': 'നിങ്ങളുടെ പ്രായത്തിനും ആവശ്യത്തിനും അനുയോജ്യമായ ട്രാക്ക് തിരഞ്ഞെടുക്കുക:',
          'adultTitle': 'Adult (18+) - Spoken English Mastery',
          'adultBadge': '18+ ADULT',
          'adultDesc': '18 വയസ്സ് മുതൽ മുതിർന്നവർക്കായി 90 ദിവസത്തെ സ്പോക്കൺ ഇംഗ്ലീഷ് & കരിയർ ടാസ്‌ക്കുകൾ!',
          'studentTitle': 'Student (9–18) - School English & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': '9 മുതൽ 18 വയസ്സുവരെയുള്ള വിദ്യാർത്ഥികൾക്കായി സ്കൂൾ മിഷനുകൾ & സ്പോക്കൺ ഇംഗ്ലീഷ്!',
          'kidsTitle': 'Kids (Up to 8) - Junior Explorer',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': '8 വയസ്സുവരെയുള്ള കുട്ടികൾക്കായി 2D ഗെയിമുകൾ, കാർട്ടൂൺ ഫോണിക്സ് & കളികൾ!',
        };
      default:
        return {
          'title': 'Who is learning English?',
          'subtitle': 'Choose the personalized track suited for your learning journey:',
          'adultTitle': 'Adult (18+) - English Mastery',
          'adultBadge': '18+ ADULT',
          'adultDesc': 'For adults 18+: 90 days spoken English, career, tasks & real speaking!',
          'studentTitle': 'Student (9–18) - School & Fluency',
          'studentBadge': '9–18 STUDENT',
          'studentDesc': 'For students aged 9–18: School missions, grammar puzzles & citadel practice!',
          'kidsTitle': 'Kids (Up to 8) - Junior Explorer',
          'kidsBadge': 'UP TO 8 KIDS',
          'kidsDesc': 'For kids up to 8: 2D cartoon games, phonics & animal adventures!',
        };
    }
  }

  /// 🔒 Parent Zone localized title
  static String getParentZoneTitle(String langName) {
    final l = _normalizeLanguage(langName).toLowerCase();
    switch (l) {
      case 'hindi':
        return 'Parent Zone / अभिभावक क्षेत्र';
      case 'tamil':
        return 'Parent Zone / பெற்றோர் மண்டலம்';
      case 'telugu':
        return 'Parent Zone / తల్లిదండ్రుల జోన్';
      case 'kannada':
        return 'Parent Zone / ಪೋಷಕರ ವಲಯ';
      case 'arabic':
        return 'Parent Zone / منطقة الوالدين';
      case 'bengali':
        return 'Parent Zone / অভিভাবক জোন';
      case 'malayalam':
        return 'Parent Zone / രക്ഷാകർത്താവ്';
      default:
        return 'Parent Zone / Parent Gate';
    }
  }

  /// 🧸 Kids Onboarding & Profile setup localized strings
  static Map<String, String> getKidsProfileTranslations(String langName) {
    final l = _normalizeLanguage(langName).toLowerCase();
    switch (l) {
      case 'hindi':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'एक प्यारा नाम चुनें जिसे साथी और रोबोट पुकारेंगे!',
          'nameHint': 'बच्चे का नाम लिखें (उदा: आरव, रिया)',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'हम उनकी कक्षा के अनुसार उपयुक्त खेल तैयार करेंगे!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '100-दिन के पहाड़ पर आपके साथ चढ़ने वाला साथी!',
        };
      case 'tamil':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'தோழர்கள் மற்றும் ரோபோக்கள் கூப்பிட ஒரு பெயர்!',
          'nameHint': 'குழந்தையின் பெயரை உள்ளிடவும்',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'அவர்களின் வகுப்புக்கு ஏற்ற விளையாட்டுகளை அமைப்போம்!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '100-நாள் மலையில் உங்களுடன் ஏறும் தோழன்!',
        };
      case 'telugu':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'స్నేహితులు మరియు రోబోట్లు పిలవడానికి ఒక ముద్దుపేరు!',
          'nameHint': 'పిల్లల పేరు నమోదు చేయండి',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'వారి తరగతికి తగిన సరదా ఆటలను సిద్ధం చేస్తాము!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '100-రోజుల కొండపై మీతో ప్రయాణించే సహచరుడు!',
        };
      case 'kannada':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'ಸ್ನೇಹಿತರು ಕರೆಯಲು ಒಂದು ಮುದ್ದಾದ ಹೆಸರು!',
          'nameHint': 'ಮಗುವಿನ ಹೆಸರನ್ನು ನಮೂದಿಸಿ',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'ಅವರ ತರಗತಿಗೆ ಸೂಕ್ತವಾದ ಆಟಗಳನ್ನು ಸಿದ್ಧಪಡಿಸುತ್ತೇವೆ!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '100-ದಿನಗಳ ಬೆಟ್ಟದಲ್ಲಿ ನಿಮ್ಮೊಂದಿಗೆ ಸಾಗುವ ಒಡನಾಡಿ!',
        };
      case 'arabic':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'اختر اسمًا لطيفًا سيناديه به الأصدقاء والروبوتات!',
          'nameHint': 'أدخل اسم الطفل',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'سنخصص ألعابًا تناسب مرحلته العمرية!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': 'صديقك المفضل لتسلق جبل الـ 100 يوم!',
        };
      case 'bengali':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'বন্ধুরা ডাকার জন্য একটি সুন্দর ডাকনাম!',
          'nameHint': 'বাচ্চার নাম লিখুন',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'আমরা তাদের ক্লাসের উপযোগী গেম তৈরি করব!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '১০০ দিনের পাহাড়ি পথে আপনার সঙ্গী!',
        };
      case 'malayalam':
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'കൂട്ടുകാരും റോബോട്ടുകളും വിളിക്കാൻ ഒരു പേര് തിരഞ്ഞെടുക്കൂ!',
          'nameHint': 'കുട്ടിയുടെ പേര് നൽകുക (ഉദാ: ലിയോ, രാഹുൽ)',
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'അവരുടെ ക്ലാസിന് അനുയോജ്യമായ ഗെയിമുകൾ ഞങ്ങൾ ഒരുക്കും!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': '100 ദിവസത്തെ മലകയറ്റത്തിൽ ഒപ്പം നിൽക്കുന്ന ചങ്ങാതി!',
        };
      default:
        return {
          'nameTitle': "What is your Kid's Name / Nickname? 🌟",
          'nameSub': 'Choose a friendly name your mates & robots will call you!',
          'nameHint': "Enter kid's nickname (e.g. Leo)",
          'ageTitle': 'Pick Age Group & Standard 📚',
          'ageSub': 'We will tailor curriculum games for their grade!',
          'avatarTitle': 'Pick Your Mascot Buddy! 🦁',
          'avatarSub': 'Your animated climbing partner for the 100-Day Summit!',
        };
    }
  }

  /// 📖 Vocabulary Meaning Resolver
  /// Translates common English words to Tamil, Hindi, or Malayalam dynamically.
  /// Guarantees that Tamil users NEVER see fallback Malayalam words like "വെള്ളം"!
  static String getVocabMeaning(dynamic itemOrWord, {String? defaultFallback}) {
    final lang = currentLanguage.toLowerCase();
    String wordKey = '';
    if (itemOrWord is Map) {
      wordKey = (itemOrWord['word'] ?? '').toString().trim().toLowerCase();
    } else if (itemOrWord != null) {
      wordKey = itemOrWord.toString().trim().toLowerCase();
    }
    wordKey = wordKey.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    if (_vocabDict.containsKey(wordKey)) {
      final entry = _vocabDict[wordKey]!;
      if (lang == 'tamil' && entry.containsKey('ta')) return entry['ta']!;
      if (lang == 'hindi' && entry.containsKey('hi')) return entry['hi']!;
      if (lang == 'malayalam' && entry.containsKey('ml')) return entry['ml']!;
      if (lang == 'english') return wordKey;
    }

    if (lang == 'malayalam') {
      if (itemOrWord is Map && itemOrWord['meaning'] != null) {
        return itemOrWord['meaning'].toString();
      }
      return defaultFallback ?? (wordKey.isNotEmpty ? wordKey : 'വാക്ക്');
    }

    if (lang == 'tamil') {
      if (wordKey.isNotEmpty) return wordKey;
      return defaultFallback != null && !RegExp(r'[\u0D00-\u0D7F]').hasMatch(defaultFallback)
          ? defaultFallback
          : 'சொல்';
    }

    return wordKey.isNotEmpty ? wordKey : (defaultFallback ?? '');
  }

  static const Map<String, Map<String, String>> _vocabDict = {
    'water': {'ta': 'தண்ணீர்', 'hi': 'पानी', 'ml': 'വെള്ളം'},
    'food': {'ta': 'உணவு', 'hi': 'खाना', 'ml': 'ഭക്ഷണം'},
    'book': {'ta': 'புத்தகம்', 'hi': 'किताब', 'ml': 'പുസ്തകം'},
    'pen': {'ta': 'பேனா', 'hi': 'कलम', 'ml': 'പേന'},
    'paper': {'ta': 'காகிதம்', 'hi': 'कागज़', 'ml': 'കടലാസ്'},
    'bag': {'ta': 'பை', 'hi': 'बस्ता', 'ml': 'ബാഗ് / സഞ്ചി'},
    'chair': {'ta': 'நாற்காலி', 'hi': 'कुर्सी', 'ml': 'കസേര'},
    'table': {'ta': 'மேசை', 'hi': 'मेज़', 'ml': 'മേശ'},
    'bed': {'ta': 'படுக்கை', 'hi': 'बिस्तर', 'ml': 'കിടക്ക'},
    'door': {'ta': 'கதவு', 'hi': 'दरवाज़ा', 'ml': 'വാതിൽ'},
    'window': {'ta': 'ஜன்னல்', 'hi': 'खिड़की', 'ml': 'ജനൽ'},
    'phone': {'ta': 'தொலைபேசி', 'hi': 'फ़ोन', 'ml': 'ഫോൺ'},
    'key': {'ta': 'சாவி', 'hi': 'चाबी', 'ml': 'താക്കോൽ'},
    'clock': {'ta': 'கடிகாரம்', 'hi': 'घड़ी', 'ml': 'ഘടികാരം'},
    'cup': {'ta': 'கோப்பை', 'hi': 'प्याला', 'ml': 'കപ്പ്'},
    'plate': {'ta': 'தட்டு', 'hi': 'थाली', 'ml': 'തളിക / പ്ലേറ്റ്'},
    'spoon': {'ta': 'கரண்டி', 'hi': 'चम्मच', 'ml': 'സ്പൂൺ'},
    'glass': {'ta': 'டம்ளர்', 'hi': 'गिलास', 'ml': 'ഗ്ലാസ്'},
    'bottle': {'ta': 'பாட்டில்', 'hi': 'बोतल', 'ml': 'കുപ്പി'},
    'box': {'ta': 'பெட்டி', 'hi': 'डिब्बा', 'ml': 'പെട്ടി'},
    'light': {'ta': 'வெளிச்சம்', 'hi': 'रोशनी', 'ml': 'വെളിച്ചം'},
    'fan': {'ta': 'மின்விசிறி', 'hi': 'पंखा', 'ml': 'ഫാൻ'},
    'mirror': {'ta': 'கண்ணாடி', 'hi': 'आईना', 'ml': 'കണ്ണാടി'},
    'shoes': {'ta': 'காலணி', 'hi': 'जूते', 'ml': 'ഷൂസ്'},
    'shirt': {'ta': 'சட்டை', 'hi': 'कमीज़', 'ml': 'കുപ്പായം'},
    'pants': {'ta': 'கால்சட்டை', 'hi': 'पतलून', 'ml': 'പാന്റ്സ്'},
    'hat': {'ta': 'தொப்பி', 'hi': 'टोपी', 'ml': 'തൊപ്പി'},
    'watch': {'ta': 'கைக்கடிகாரம்', 'hi': 'घड़ी', 'ml': 'വാച്ച്'},
    'ring': {'ta': 'மோதிரம்', 'hi': 'अंगूठी', 'ml': 'മോതിരം'},
    'car': {'ta': 'மகிழுந்து', 'hi': 'गाड़ी', 'ml': 'കാർ'},
    'bus': {'ta': 'பேருந்து', 'hi': 'बस', 'ml': 'ബസ്'},
    'train': {'ta': 'ரயில்', 'hi': 'रेलगाड़ी', 'ml': 'തീവണ്ടി'},
    'road': {'ta': 'சாலை', 'hi': 'सड़क', 'ml': 'വഴി / റോഡ്'},
    'bridge': {'ta': 'பாலம்', 'hi': 'पुल', 'ml': 'പാലം'},
    'school': {'ta': 'பள்ளி', 'hi': 'स्कूल', 'ml': 'സ്കൂൾ'},
    'college': {'ta': 'கல்லூரி', 'hi': 'कॉलेज', 'ml': 'കോളേജ്'},
    'office': {'ta': 'அலுவலகம்', 'hi': 'कार्यालय', 'ml': 'ഓഫീസ്'},
    'market': {'ta': 'சந்தை', 'hi': 'बाज़ार', 'ml': 'മാർക്കറ്റ്'},
    'hospital': {'ta': 'மருத்துவமனை', 'hi': 'अस्पताल', 'ml': 'ആശുപത്രി'},
    'bank': {'ta': 'வங்கி', 'hi': 'बैंक', 'ml': 'ബാങ്ക്'},
    'park': {'ta': 'பூங்கா', 'hi': 'बगीचा', 'ml': 'പാർക്ക്'},
    'tree': {'ta': 'மரம்', 'hi': 'पेड़', 'ml': 'മരം'},
    'flower': {'ta': 'பூ', 'hi': 'फूल', 'ml': 'പൂവ്'},
    'sun': {'ta': 'சூரியன்', 'hi': 'सूरज', 'ml': 'സൂര്യൻ'},
    'moon': {'ta': 'நிலவு', 'hi': 'चाँद', 'ml': 'ചന്ദ്രൻ'},
    'star': {'ta': 'நட்சத்திரம்', 'hi': 'तारा', 'ml': 'നക്ഷത്രം'},
    'sky': {'ta': 'வானம்', 'hi': 'आसमान', 'ml': 'ആകാശം'},
    'rain': {'ta': 'மழை', 'hi': 'बारिश', 'ml': 'മഴ'},
    'wind': {'ta': 'காற்று', 'hi': 'हवा', 'ml': 'കാറ്റ്'},
    'dog': {'ta': 'நாய்', 'hi': 'कुत्ता', 'ml': 'നായ'},
    'cat': {'ta': 'பூனை', 'hi': 'बिल्ली', 'ml': 'പൂച്ച'},
    'bird': {'ta': 'பறவை', 'hi': 'चिड़िया', 'ml': 'പക്ഷി'},
    'fish': {'ta': 'மீன்', 'hi': 'मछली', 'ml': 'മീൻ'},
    'cow': {'ta': 'பசு', 'hi': 'गाय', 'ml': 'പശു'},
    'milk': {'ta': 'பால்', 'hi': 'दूध', 'ml': 'പാൽ'},
    'tea': {'ta': 'தேநீர்', 'hi': 'चाय', 'ml': 'ചായ'},
    'coffee': {'ta': 'காபி', 'hi': 'कॉफ़ी', 'ml': 'കാപ്പി'},
    'bread': {'ta': 'ரொட்டி', 'hi': 'रोटी', 'ml': 'ബ്രെഡ്'},
    'rice': {'ta': 'சாதம்', 'hi': 'चावल', 'ml': 'അരി / ചോറ്'},
    'apple': {'ta': 'ஆப்பிள்', 'hi': 'सेब', 'ml': 'ആപ്പിൾ'},
    'mango': {'ta': 'மாம்பழம்', 'hi': 'आम', 'ml': 'മാമ്പഴം'},
    'banana': {'ta': 'வாழைப்பழம்', 'hi': 'केला', 'ml': 'വാഴപ്പഴം'},
    'orange': {'ta': 'ஆரஞ்சு', 'hi': 'संतरा', 'ml': 'ഓറഞ്ച്'},
    'egg': {'ta': 'முட்டை', 'hi': 'अंडा', 'ml': 'മുട്ട'},
    'salt': {'ta': 'உப்பு', 'hi': 'नमक', 'ml': 'ഉപ്പ്'},
    'sugar': {'ta': 'சர்க்கரை', 'hi': 'चीनी', 'ml': 'പഞ്ചസാര'},
    'oil': {'ta': 'எண்ணெய்', 'hi': 'तेल', 'ml': 'എണ്ണ'},
    'soap': {'ta': 'சோப்பு', 'hi': 'साबुन', 'ml': 'സോപ്പ്'},
    'towel': {'ta': 'துண்டு', 'hi': 'तौलिया', 'ml': 'തോർത്ത്'},
    'clean': {'ta': 'சுத்தம்', 'hi': 'साफ़', 'ml': 'വൃത്തിയുള്ള'},
    'wash': {'ta': 'கழுவுதல்', 'hi': 'धोना', 'ml': 'കഴുകുക'},
    'sleep': {'ta': 'தூங்குதல்', 'hi': 'सोना', 'ml': 'ഉറങ്ങുക'},
    'wake': {'ta': 'எழுந்திருத்தல்', 'hi': 'जागना', 'ml': 'ഉണരുക'},
    'eat': {'ta': 'சாப்பிடுதல்', 'hi': 'खाना', 'ml': 'കഴിക്കുക'},
    'drink': {'ta': 'குடித்தல்', 'hi': 'पीना', 'ml': 'കുടിക്കുക'},
    'read': {'ta': 'படித்தல்', 'hi': 'पढ़ना', 'ml': 'വായിക്കുക'},
    'write': {'ta': 'எழுதுதல்', 'hi': 'लिखना', 'ml': 'എഴുതുക'},
    'speak': {'ta': 'பேசுதல்', 'hi': 'बोलना', 'ml': 'സംസാരിക്കുക'},
    'listen': {'ta': 'கேட்டல்', 'hi': 'सुनना', 'ml': 'കേൾക്കുക'},
    'walk': {'ta': 'நடத்தல்', 'hi': 'चलना', 'ml': 'നടക്കുക'},
    'run': {'ta': 'ஓடுதல்', 'hi': 'दौड़ना', 'ml': 'ഓടുക'},
    'sit': {'ta': 'உட்காருதல்', 'hi': 'बैठना', 'ml': 'ഇരിക്കുക'},
    'stand': {'ta': 'நிற்றல்', 'hi': 'खड़े होना', 'ml': 'നിൽക്കുക'},
    'play': {'ta': 'விளையாடுதல்', 'hi': 'खेलना', 'ml': 'കളിക്കുക'},
    'learn': {'ta': 'கற்றுக்கொள்ளுதல்', 'hi': 'सीखना', 'ml': 'പഠിക്കുക'},
    'work': {'ta': 'வேலை செய்தல்', 'hi': 'काम करना', 'ml': 'ജോലി ചെയ്യുക'},
    'help': {'ta': 'உதவுதல்', 'hi': 'मदद करना', 'ml': 'സഹായിക്കുക'},
    'happy': {'ta': 'மகிழ்ச்சி', 'hi': 'खुश', 'ml': 'സന്തോഷം'},
    'sad': {'ta': 'சோகம்', 'hi': 'उदास', 'ml': 'വിഷമം'},
    'fast': {'ta': 'வேகமாக', 'hi': 'तेज़', 'ml': 'വേഗതയുള്ള'},
    'slow': {'ta': 'மெதுவாக', 'hi': 'धीमा', 'ml': 'പതുക്കെ'},
    'first': {'ta': 'முதலில்', 'hi': 'पहला', 'ml': 'ആദ്യം'},
    'last': {'ta': 'கடைசி', 'hi': 'आखिरी', 'ml': 'അവസാനം'},
    'today': {'ta': 'இன்று', 'hi': 'आज', 'ml': 'ഇന്ന്'},
    'tomorrow': {'ta': 'நாளை', 'hi': 'कल', 'ml': 'നാളെ'},
    'yesterday': {'ta': 'நேற்று', 'hi': 'कल (बीता)', 'ml': 'ഇന്നലെ'},
    'morning': {'ta': 'காலை', 'hi': 'सुबह', 'ml': 'രാവിലെ'},
    'night': {'ta': 'இரவு', 'hi': 'रात', 'ml': 'രാത്രി'},
    'friend': {'ta': 'நண்பர்', 'hi': 'दोस्त', 'ml': 'സുഹൃത്ത്'},
    'family': {'ta': 'குடும்பம்', 'hi': 'परिवार', 'ml': 'കുടുംബം'},
    'mother': {'ta': 'அம்மா', 'hi': 'माँ', 'ml': 'അമ്മ'},
    'father': {'ta': 'அப்பா', 'hi': 'पिता', 'ml': 'അച്ഛൻ'},
    'brother': {'ta': 'சகோதரன்', 'hi': 'भाई', 'ml': 'സഹോദരൻ'},
    'sister': {'ta': 'சகோதரி', 'hi': 'बहन', 'ml': 'സഹോദരി'},
    'doctor': {'ta': 'மருத்துவர்', 'hi': 'डॉक्टर', 'ml': 'ഡോക്ടർ'},
    'teacher': {'ta': 'ஆசிரியர்', 'hi': 'शिक्षक', 'ml': 'അധ്യാപകൻ'},
    'money': {'ta': 'பணம்', 'hi': 'पैसे', 'ml': 'പണം'},
    'house': {'ta': 'வீடு', 'hi': 'घर', 'ml': 'വീട്'},
    'time': {'ta': 'நேரம்', 'hi': 'समय', 'ml': 'സമയം'},
    'day': {'ta': 'நாள்', 'hi': 'दिन', 'ml': 'ദിവസം'},
  };
}

