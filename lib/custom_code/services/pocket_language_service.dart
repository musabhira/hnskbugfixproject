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
  static Future<String> init() async {
    if (_initialized) return activeLanguageNotifier.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = SupaFlow.client.auth.currentUser?.id;

      String? savedLang = prefs.getString(kPrefNativeLang);
      if (savedLang == null && currentUserId != null) {
        savedLang = prefs.getString('pm_native_language_$currentUserId');
      }
      savedLang ??= prefs.getString(kPrefMissionLang);

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
}
