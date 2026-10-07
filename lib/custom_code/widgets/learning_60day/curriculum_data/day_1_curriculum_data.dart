import 'dart:convert';

import 'pocket_day_curriculum_service.dart';

/// 📜 Central Day 1 JSON Curriculum Loader & Accessor
/// User Audio Directive:
/// - Keep all questions, texts, vocabularies, reading, dialogues, defenses, and exam in standard JSON.
/// - Simple to inspect, test, and use as template for Day 2.
class Day1CurriculumJsonData {
  static Map<String, dynamic>? _cachedJson;

  /// Loads the Day 1 Curriculum JSON from assets or returns cached
  static Future<Map<String, dynamic>> load() async {
    if (_cachedJson != null) return _cachedJson!;
    try {
      _cachedJson = await PocketDayCurriculumService.loadRequiredDayCurriculum(1);
      return _cachedJson!;
    } catch (_) {
      // Fallback to static raw json
      _cachedJson = json.decode(rawJson) as Map<String, dynamic>;
      return _cachedJson!;
    }
  }

  /// Synchronous getter from fallback rawJson
  static Map<String, dynamic> get rawMap {
    _cachedJson ??= json.decode(rawJson) as Map<String, dynamic>;
    return _cachedJson!;
  }

  /// Helper to get localized string from an object: {"en": "...", "ml": "...", ...}
  static String getLocalizedString(dynamic field, {String lang = 'en', String fallback = ''}) {
    if (field == null) return fallback;
    if (field is String) return field;
    if (field is Map) {
      final l = lang.toLowerCase();
      if (l.startsWith('ml') || l.contains('malay')) return field['ml']?.toString() ?? field['en']?.toString() ?? fallback;
      if (l.startsWith('hi') || l.contains('hind')) return field['hi']?.toString() ?? field['en']?.toString() ?? fallback;
      if (l.startsWith('ta') || l.contains('tamil')) return field['ta']?.toString() ?? field['en']?.toString() ?? fallback;
      return field['en']?.toString() ?? field.values.firstOrNull?.toString() ?? fallback;
    }
    return field.toString();
  }

  /// Raw Embedded JSON string matching assets/curriculum/day_1_curriculum.json
  static const String rawJson = r'''{
  "day": 1,
  "title": {
    "en": "Day 1: ME + BASIC ENGLISH",
    "ml": "ദിവസം 1: ഞാനും അടിസ്ഥാന ഇംഗ്ലീഷും",
    "hi": "दिन 1: मैं और बुनियादी अंग्रेजी",
    "ta": "நாள் 1: நானும் அடிப்படை ஆங்கிலமும்"
  },
  "diagnosticPreCheck": {
    "title": {
      "en": "Quick English Diagnostic Check",
      "ml": "ദ്രുത നിലവാര പരിശോധന",
      "hi": "त्वरित अंग्रेजी नैदानिक ​​जांच",
      "ta": "விரைவான ஆங்கில நிலை சரிபார்ப்பு"
    },
    "description": {
      "en": "You can skip the basics if you already know them!",
      "ml": "നിങ്ങൾക്ക് അറിയാവുന്ന കാര്യങ്ങൾ സ്കിപ്പ് ചെയ്യാം!",
      "hi": "यदि आप पहले से जानते हैं तो बुनियादी बातें छोड़ सकते हैं!",
      "ta": "உங்களுக்கு ஏற்கனவே தெரிந்திருந்தால் அடிப்படைகளைத் தவிர்க்கலாம்!"
    },
    "questions": [
      {
        "id": "knows_alphabet",
        "question": {
          "en": "Do you know the English Alphabet (A–Z) and Phonics sounds?",
          "ml": "നിങ്ങൾക്ക് ഇംഗ്ലീഷ് അക്ഷരങ്ങളും (A–Z) അവയുടെ ശബ്ദങ്ങളും അറിയാമോ?",
          "hi": "क्या आप अंग्रेजी वर्णमाला (A–Z) और ध्वनियां जानते हैं?",
          "ta": "உங்களுக்கு ஆங்கில எழுத்துக்களும் (A–Z) அவற்றின் ஒலிகளும் தெரியுமா?"
        },
        "options": [
          {
            "id": "need_alphabet",
            "label": {
              "en": "No, start with ABCD (Step 1)",
              "ml": "ഇല്ല, എനിക്ക് ABCD മുതൽ തുടങ്ങണം",
              "hi": "नहीं, ABCD से शुरू करें",
              "ta": "இல்லை, ABCD முதல் தொடங்கவும்"
            },
            "skipStep1": false
          },
          {
            "id": "knows_alphabet",
            "label": {
              "en": "Yes, I know ABCD! (Skip Step 1)",
              "ml": "അതെ, എനിക്ക് അക്ഷരങ്ങൾ അറിയാം! (സ്റ്റെപ്പ് 1 സ്കിപ്പ് ചെയ്യാം)",
              "hi": "हाँ, मैं ABCD जानता हूँ! (स्टेप 1 छोड़ें)",
              "ta": "ஆம், எனக்கு ABCD தெரியும்! (படி 1 ஐத் தவிர்க்கவும்)"
            },
            "skipStep1": true
          }
        ]
      },
      {
        "id": "knows_vocab",
        "question": {
          "en": "Do you know 50+ basic words (Apple, Book, Water, Grapes, Bed, Crow...)?",
          "ml": "നിങ്ങൾക്ക് അടിസ്ഥാന വാക്കുകൾ (Apple, Book, മുന്തിരി, Bed, Crow, Water...) അറിയാമോ?",
          "hi": "क्या आप 50+ बुनियादी शब्द (Apple, Book, अंगूर, Bed, Crow...) जानते हैं?",
          "ta": "உங்களுக்கு 50+ அடிப்படை வார்த்தைகள் (Apple, Book, திராட்சை, Bed, Crow...) தெரியுமா?"
        },
        "options": [
          {
            "id": "need_vocab",
            "label": {
              "en": "No, I need vocabulary practice (Step 2)",
              "ml": "ഇല്ല, പദസമ്പത്ത് പഠിക്കണം",
              "hi": "नहीं, शब्दावली अभ्यास चाहिए",
              "ta": "இல்லை, எனக்கு சொல் பயிற்சி தேவை"
            },
            "skipStep2": false
          },
          {
            "id": "knows_vocab",
            "label": {
              "en": "Yes, I know these 50+ basic words! (Skip Step 2)",
              "ml": "അതെ, ഈ 50+ വാക്കുകൾ എനിക്കറിയാം! (സ്റ്റെപ്പ് 2 സ്കിപ്പ് ചെയ്യാം)",
              "hi": "हाँ, मैं ये 50+ शब्द जानता हूँ! (स्टेप 2 छोड़ें)",
              "ta": "ஆம், எனக்கு இந்த 50+ வார்த்தைகள் தெரியும்! (படி 2 ஐத் தவிர்க்கவும்)"
            },
            "skipStep2": true
          }
        ]
      }
    ]
  },
  "steps": [
    {
      "stepNumber": 1,
      "id": "step_1_alphabet",
      "title": {
        "en": "Meet the Letters & Phonics",
        "ml": "അക്ഷരങ്ങളും ശബ്ദങ്ങളും",
        "hi": "अक्षर और ध्वनियां",
        "ta": "எழுத்துக்களும் ஒலிகளும்"
      },
      "icon": "🔤",
      "gameType": "tutor_alphabet",
      "canBeSkipped": true,
      "description": {
        "en": "Tutor guides you through fundamental letters, sounds, and native pronunciations.",
        "ml": "ട്യൂട്ടർ അക്ഷരങ്ങളും അവയുടെ ഉച്ചാരണവും പഠിപ്പിക്കുന്നു.",
        "hi": "ट्यूटर आपको अक्षरों और उच्चारण के बारे में बताता है।",
        "ta": "ஆசிரியர் உங்களுக்கு எழுத்துக்களையும் உச்சரிப்பையும் கற்பிக்கிறார்."
      },
      "items": [
        {
          "letter": "A",
          "sound": "/æ/",
          "word": "Apple",
          "emoji": "🍎",
          "voice": "This is A. A for Apple.",
          "meaning": {"ml": "ആപ്പിൾ", "hi": "सेब", "ta": "ஆப்பிள்"},
          "example": {"en": "An apple is sweet.", "ml": "ആപ്പിൾ മധുരമുള്ളതാണ്."}
        },
        {
          "letter": "B",
          "sound": "/b/",
          "word": "Ball",
          "emoji": "⚽",
          "voice": "This is B. B for Ball.",
          "meaning": {"ml": "പന്ത്", "hi": "गेंद", "ta": "பந்து"},
          "example": {"en": "A red ball.", "ml": "ഒരു ചുവന്ന പന്ത്."}
        },
        {
          "letter": "C",
          "sound": "/k/",
          "word": "Cat",
          "emoji": "🐱",
          "voice": "This is C. C for Cat.",
          "meaning": {"ml": "പൂച്ച", "hi": "बिल्ली", "ta": "பூனை"},
          "example": {"en": "A cute cat.", "ml": "ഒരു ചെറിയ പൂച്ച."}
        },
        {
          "letter": "D",
          "sound": "/d/",
          "word": "Dog",
          "emoji": "🐶",
          "voice": "This is D. D for Dog.",
          "meaning": {"ml": "നായ", "hi": "कुत्ता", "ta": "நாய்"},
          "example": {"en": "A loyal dog.", "ml": "ഒരു നല്ല നായ."}
        },
        {
          "letter": "E",
          "sound": "/e/",
          "word": "Egg",
          "emoji": "🥚",
          "voice": "This is E. E for Egg.",
          "meaning": {"ml": "മുട്ട", "hi": "अंडा", "ta": "முட்டை"},
          "example": {"en": "A white egg.", "ml": "ഒരു വെള്ള മുട്ട."}
        },
        {
          "letter": "F",
          "sound": "/f/",
          "word": "Fish",
          "emoji": "🐟",
          "voice": "This is F. F for Fish.",
          "meaning": {"ml": "മത്സ്യം", "hi": "मछली", "ta": "மீன்"},
          "example": {"en": "Fish swims in water.", "ml": "മത്സ്യം വെള്ളത്തിൽ നീന്തുന്നു."}
        }
      ]
    },
    {
      "stepNumber": 2,
      "id": "step_2_vocab_50",
      "title": {
        "en": "50+ Essential Beginner Words",
        "ml": "50+ നിത്യോപയോഗ അടിസ്ഥാന വാക്കുകൾ",
        "hi": "50+ आवश्यक शुरुआती शब्द",
        "ta": "50+ அத்தியாவசிய அடிப்படை வார்த்தைகள்"
      },
      "icon": "📚",
      "gameType": "vocab_bank",
      "canBeSkipped": true,
      "description": {
        "en": "See, hear, and touch 50+ basic words including Apple, Book, Grapes, Bed, Crow, Water, and more.",
        "ml": "Apple, Book, മുന്തിരി, Bed, Crow, Water തുടങ്ങി 50-ൽ പരം നിത്യോപയോഗ വാക്കുകൾ കാണുക, കേൾക്കുക, പഠിക്കുക.",
        "hi": "Apple, Book, अंगूर, Bed, Crow, Water सहित 50+ शब्द सीखें।",
        "ta": "Apple, Book, திராட்சை, Bed, Crow, Water உள்ளிட்ட 50+ வார்த்தைகளைக் கற்றுக்கொள்ளுங்கள்."
      },
      "words": [
        {"word": "Apple", "emoji": "🍎", "phonetic": "/ˈæp.əl/", "meaning": {"ml": "ആപ്പിൾ", "hi": "सेब", "ta": "ஆப்பிள்"}, "example": "I eat an apple."},
        {"word": "Book", "emoji": "📖", "phonetic": "/bʊk/", "meaning": {"ml": "പുസ്തകം", "hi": "किताब", "ta": "புத்தகம்"}, "example": "This is my book."},
        {"word": "Grapes", "emoji": "🍇", "phonetic": "/ɡreɪps/", "meaning": {"ml": "മുന്തിരി", "hi": "अंगूर", "ta": "திராட்சை"}, "example": "Sweet green grapes."},
        {"word": "Bed", "emoji": "🛏️", "phonetic": "/bed/", "meaning": {"ml": "കിടക്ക / കട്ടിൽ", "hi": "बिस्तर", "ta": "படுக்கை"}, "example": "I sleep on the bed."},
        {"word": "Crow", "emoji": "🐦‍⬛", "phonetic": "/krəʊ/", "meaning": {"ml": "കാക്ക", "hi": "कौआ", "ta": "காகம்"}, "example": "A black crow is singing."},
        {"word": "Water", "emoji": "💧", "phonetic": "/ˈwɔː.tər/", "meaning": {"ml": "വെള്ളം", "hi": "पानी", "ta": "தண்ணீர்"}, "example": "Please give me water."},
        {"word": "Cat", "emoji": "🐱", "phonetic": "/kæt/", "meaning": {"ml": "പൂച്ച", "hi": "बिल्ली", "ta": "பூனை"}, "example": "The cat is sleeping."},
        {"word": "Dog", "emoji": "🐶", "phonetic": "/dɒɡ/", "meaning": {"ml": "നായ", "hi": "कुत्ता", "ta": "நாய்"}, "example": "My dog is friendly."},
        {"word": "House", "emoji": "🏡", "phonetic": "/haʊs/", "meaning": {"ml": "വീട്", "hi": "घर", "ta": "வீடு"}, "example": "Welcome to my house."},
        {"word": "Sun", "emoji": "☀️", "phonetic": "/sʌn/", "meaning": {"ml": "സൂര്യൻ", "hi": "सूरज", "ta": "சூரியன்"}, "example": "The sun is shining bright."},
        {"word": "Tree", "emoji": "🌳", "phonetic": "/triː/", "meaning": {"ml": "മരം", "hi": "पेड़", "ta": "மரம்"}, "example": "A tall green tree."},
        {"word": "Milk", "emoji": "🥛", "phonetic": "/mɪlk/", "meaning": {"ml": "പാൽ", "hi": "दूध", "ta": "பால்"}, "example": "I drink warm milk."},
        {"word": "Car", "emoji": "🚗", "phonetic": "/kɑːr/", "meaning": {"ml": "കാർ / വണ്ടി", "hi": "गाड़ी", "ta": "கார்"}, "example": "The red car is fast."},
        {"word": "Pen", "emoji": "🖊️", "phonetic": "/pen/", "meaning": {"ml": "പേന", "hi": "कलम", "ta": "பேனா"}, "example": "I write with a pen."},
        {"word": "School", "emoji": "🏫", "phonetic": "/skuːl/", "meaning": {"ml": "സ്കൂൾ", "hi": "स्कूल", "ta": "பள்ளி"}, "example": "Children go to school."},
        {"word": "Fish", "emoji": "🐟", "phonetic": "/fɪʃ/", "meaning": {"ml": "മത്സ്യം", "hi": "मछली", "ta": "மீன்"}, "example": "Fish in the clean water."},
        {"word": "Bird", "emoji": "🐦", "phonetic": "/bɜːd/", "meaning": {"ml": "പക്ഷി", "hi": "पक्षी", "ta": "பறவை"}, "example": "A bird flies in the sky."},
        {"word": "Cup", "emoji": "☕", "phonetic": "/kʌp/", "meaning": {"ml": "കപ്പ്", "hi": "कप", "ta": "கோப்பை"}, "example": "A hot cup of tea."},
        {"word": "Bag", "emoji": "🎒", "phonetic": "/bæɡ/", "meaning": {"ml": "ബാഗ്", "hi": "बस्ता", "ta": "பை"}, "example": "My heavy school bag."},
        {"word": "Door", "emoji": "🚪", "phonetic": "/dɔːr/", "meaning": {"ml": "വാതിൽ", "hi": "दरवाजा", "ta": "கதவு"}, "example": "Open the front door."},
        {"word": "Chair", "emoji": "🪑", "phonetic": "/tʃeər/", "meaning": {"ml": "കസേര", "hi": "कुर्सी", "ta": "நாற்காலி"}, "example": "Sit on the chair."},
        {"word": "Table", "emoji": "🪵", "phonetic": "/ˈteɪ.bəl/", "meaning": {"ml": "മേശ", "hi": "मेज़", "ta": "மேசை"}, "example": "Food is on the table."},
        {"word": "Road", "emoji": "🛣️", "phonetic": "/rəʊd/", "meaning": {"ml": "വഴി / റോഡ്", "hi": "सड़क", "ta": "சாலை"}, "example": "Cross the quiet road."},
        {"word": "Star", "emoji": "⭐", "phonetic": "/stɑːr/", "meaning": {"ml": "നക്ഷത്രം", "hi": "तारा", "ta": "நட்சத்திரம்"}, "example": "Twinkling star at night."},
        {"word": "Moon", "emoji": "🌙", "phonetic": "/muːn/", "meaning": {"ml": "ചന്ദ്രൻ", "hi": "चाँद", "ta": "நிலா"}, "example": "Bright white moon."},
        {"word": "Rain", "emoji": "🌧️", "phonetic": "/reɪn/", "meaning": {"ml": "മഴ", "hi": "बारिश", "ta": "மழை"}, "example": "I love the cool rain."},
        {"word": "Hand", "emoji": "✋", "phonetic": "/hænd/", "meaning": {"ml": "കൈ", "hi": "हाथ", "ta": "கை"}, "example": "Wash your clean hand."},
        {"word": "Eye", "emoji": "👁️", "phonetic": "/aɪ/", "meaning": {"ml": "കണ്ണ്", "hi": "आँख", "ta": "கண்"}, "example": "Open your happy eyes."},
        {"word": "Food", "emoji": "🍲", "phonetic": "/fuːd/", "meaning": {"ml": "ഭക്ഷണം", "hi": "खाना", "ta": "உணவு"}, "example": "Healthy and tasty food."},
        {"word": "Friend", "emoji": "🤝", "phonetic": "/frend/", "meaning": {"ml": "സുഹൃത്ത്", "hi": "दोस्त", "ta": "நண்பன்"}, "example": "Rahul is my good friend."},
        {"word": "Time", "emoji": "⏳", "phonetic": "/taɪm/", "meaning": {"ml": "സമയം", "hi": "समय", "ta": "நேரம்"}, "example": "What is the time?"},
        {"word": "Clock", "emoji": "⏰", "phonetic": "/klɒk/", "meaning": {"ml": "ക്ലോക്ക്", "hi": "घड़ी", "ta": "கடிகாரம்"}, "example": "The clock says 7 AM."},
        {"word": "Night", "emoji": "🌃", "phonetic": "/naɪt/", "meaning": {"ml": "രാത്രി", "hi": "रात", "ta": "இரவு"}, "example": "Good night, sleep well."},
        {"word": "Day", "emoji": "🌅", "phonetic": "/deɪ/", "meaning": {"ml": "പകൽ / ദിവസം", "hi": "दिन", "ta": "நாள்"}, "example": "Have a wonderful day."},
        {"word": "Boy", "emoji": "👦", "phonetic": "/bɔɪ/", "meaning": {"ml": "ആൺകുട്ടി", "hi": "लड़का", "ta": "சிறுவன்"}, "example": "The cheerful young boy."},
        {"word": "Girl", "emoji": "👧", "phonetic": "/ɡɜːl/", "meaning": {"ml": "പെൺകുട്ടി", "hi": "लड़की", "ta": "சிறுமி"}, "example": "The polite young girl."},
        {"word": "Mother", "emoji": "👩", "phonetic": "/ˈmʌð.ər/", "meaning": {"ml": "അമ്മ", "hi": "माँ", "ta": "அம்மா"}, "example": "My loving mother."},
        {"word": "Father", "emoji": "👨", "phonetic": "/ˈfɑː.ðər/", "meaning": {"ml": "അച്ഛൻ", "hi": "पिता", "ta": "அப்பா"}, "example": "My hardworking father."},
        {"word": "Child", "emoji": "🧒", "phonetic": "/tʃaɪld/", "meaning": {"ml": "കുട്ടി", "hi": "बच्चा", "ta": "குழந்தை"}, "example": "The smiling little child."},
        {"word": "Walk", "emoji": "🚶", "phonetic": "/wɔːk/", "meaning": {"ml": "നടക്കുക", "hi": "चलना", "ta": "நடப்பது"}, "example": "I walk in the morning park."},
        {"word": "Run", "emoji": "🏃", "phonetic": "/rʌn/", "meaning": {"ml": "ഓടുക", "hi": "दौड़ना", "ta": "ஓடுவது"}, "example": "Run fast to the finish."},
        {"word": "Eat", "emoji": "🍽️", "phonetic": "/iːt/", "meaning": {"ml": "കഴിക്കുക", "hi": "खाना", "ta": "சாப்பிடுவது"}, "example": "I eat breakfast early."},
        {"word": "Drink", "emoji": "🥤", "phonetic": "/drɪŋk/", "meaning": {"ml": "കുടിക്കുക", "hi": "पीना", "ta": "குடிப்பது"}, "example": "Drink pure water."},
        {"word": "Sleep", "emoji": "😴", "phonetic": "/sliːp/", "meaning": {"ml": "ഉറങ്ങുക", "hi": "सोना", "ta": "தூங்குவது"}, "example": "Sleep early tonight."},
        {"word": "Read", "emoji": "📖", "phonetic": "/riːd/", "meaning": {"ml": "വായിക്കുക", "hi": "पढ़ना", "ta": "படிப்பது"}, "example": "Read this interesting book."},
        {"word": "Write", "emoji": "✍️", "phonetic": "/raɪt/", "meaning": {"ml": "എഴുതുക", "hi": "लिखना", "ta": "எழுதுவது"}, "example": "Write your name here."},
        {"word": "Speak", "emoji": "🗣️", "phonetic": "/spiːk/", "meaning": {"ml": "സംസാരിക്കുക", "hi": "बोलना", "ta": "பேசுவது"}, "example": "Speak English confidently."},
        {"word": "Listen", "emoji": "👂", "phonetic": "/ˈlɪs.ən/", "meaning": {"ml": "കേൾക്കുക", "hi": "सुनना", "ta": "கேட்பது"}, "example": "Listen to the teacher."},
        {"word": "See", "emoji": "👀", "phonetic": "/siː/", "meaning": {"ml": "കാണുക", "hi": "देखना", "ta": "பார்ப்பது"}, "example": "I see a blue bird."},
        {"word": "Smile", "emoji": "😊", "phonetic": "/smaɪl/", "meaning": {"ml": "പുഞ്ചിരിക്കുക", "hi": "मुस्कुराना", "ta": "புன்னகை"}, "example": "Always smile with joy."},
        {"word": "Happy", "emoji": "😃", "phonetic": "/ˈhæp.i/", "meaning": {"ml": "സന്തോഷം", "hi": "खुश", "ta": "மகிழ்ச்சி"}, "example": "I am very happy today."},
        {"word": "Big", "emoji": "🐘", "phonetic": "/bɪɡ/", "meaning": {"ml": "വലിയ", "hi": "बड़ा", "ta": "பெரிய"}, "example": "A big green elephant."},
        {"word": "Small", "emoji": "🐜", "phonetic": "/smɔːl/", "meaning": {"ml": "ചെറിയ", "hi": "छोटा", "ta": "சிறிய"}, "example": "A small busy ant."},
        {"word": "Red", "emoji": "🔴", "phonetic": "/red/", "meaning": {"ml": "ചുവപ്പ്", "hi": "लाल", "ta": "சிவப்பு"}, "example": "A bright red apple."},
        {"word": "Blue", "emoji": "🔵", "phonetic": "/bluː/", "meaning": {"ml": "നീല", "hi": "नीला", "ta": "நீலம்"}, "example": "The clear blue sky."}
      ]
    },
    {
      "stepNumber": 3,
      "id": "step_3_game_hunt",
      "title": {
        "en": "GAME 1: Letter & Word Hunt",
        "ml": "ഗെയിം 1: അക്ഷര & പദ വേട്ട",
        "hi": "गेम 1: अक्षर और शब्द खोज",
        "ta": "விளையாட்டு 1: சொல் வேட்டை"
      },
      "icon": "🔍",
      "gameType": "game_hunt",
      "description": {
        "en": "Hunt and collect 6 target items on the interactive game map.",
        "ml": "മാപ്പിൽ ചിതറിയ 6 വാക്കുകളും അക്ഷരങ്ങളും ടാപ്പ് ചെയ്തു കണ്ടെത്തുക.",
        "hi": "मानचित्र पर 6 लक्षित शब्द खोजें।",
        "ta": "வரைபடத்தில் 6 இலக்கு வார்த்தைகளைக் கண்டறியவும்."
      },
      "rounds": [
        {"round": 1, "target": "A", "prompt": {"en": "Find Letter A 🍎", "ml": "A കണ്ടെത്തുക"}, "options": ["B", "A", "C", "D"], "correct": "A"},
        {"round": 2, "target": "Bed", "prompt": {"en": "Find the word: Bed 🛏️", "ml": "Bed കണ്ടെത്തുക"}, "options": ["Crow", "Grapes", "Bed", "Apple"], "correct": "Bed"},
        {"round": 3, "target": "Crow", "prompt": {"en": "Find the word: Crow 🐦‍⬛", "ml": "Crow കണ്ടെത്തുക"}, "options": ["Water", "Crow", "Dog", "Cat"], "correct": "Crow"},
        {"round": 4, "target": "Grapes", "prompt": {"en": "Find the word: Grapes 🍇", "ml": "Grapes (മുന്തിരി) കണ്ടെത്തുക"}, "options": ["Grapes", "Book", "House", "Sun"], "correct": "Grapes"},
        {"round": 5, "target": "Water", "prompt": {"en": "Find the word: Water 💧", "ml": "Water കണ്ടെത്തുക"}, "options": ["Milk", "Bed", "Water", "Fish"], "correct": "Water"},
        {"round": 6, "target": "Friend", "prompt": {"en": "Find the word: Friend 🤝", "ml": "Friend കണ്ടെത്തുക"}, "options": ["Enemy", "Friend", "Stranger", "Door"], "correct": "Friend"}
      ]
    },
    {
      "stepNumber": 4,
      "id": "step_4_game_match_build",
      "title": {
        "en": "GAME 2: Match & Sentence Builder",
        "ml": "ഗെയിം 2: യോജിപ്പിക്കലും വാക്യം നിർമ്മാണവും",
        "hi": "गेम 2: मिलान और वाक्य निर्माण",
        "ta": "விளையாட்டு 2: வாக்கியம் உருவாக்குதல்"
      },
      "icon": "🧩",
      "gameType": "game_match_build",
      "description": {
        "en": "6 Interactive puzzle challenges: Match objects to names and unscramble words to build real sentences.",
        "ml": "6 പസിൽ വെല്ലുവിളികൾ: വാക്കുകൾ യോജിപ്പിക്കുക, അർത്ഥവത്തായ വാക്യങ്ങൾ നിർമ്മിക്കുക.",
        "hi": "6 पहेलियां: शब्दों का मिलान करें और वाक्य बनाएं।",
        "ta": "6 புதிர்கள்: வார்த்தைகளை பொருத்தி வாக்கியங்களை உருவாக்கவும்."
      },
      "rounds": [
        {
          "round": 1,
          "type": "match",
          "prompt": {"en": "Match 'Bed' to its emoji", "ml": "'Bed' അനുയോജ്യമായ ചിത്രവുമായി യോജിപ്പിക്കുക"},
          "left": "Bed",
          "options": ["🛏️ Bed", "🍇 Grapes", "🐦‍⬛ Crow"],
          "correct": "🛏️ Bed"
        },
        {
          "round": 2,
          "type": "match",
          "prompt": {"en": "Match 'Crow' to its emoji", "ml": "'Crow' ചിത്രവുമായി യോജിപ്പിക്കുക"},
          "left": "Crow",
          "options": ["🐦‍⬛ Crow", "🍎 Apple", "💧 Water"],
          "correct": "🐦‍⬛ Crow"
        },
        {
          "round": 3,
          "type": "build",
          "prompt": {"en": "Build sentence: 'This is my bed'", "ml": "'ഇത് എന്റെ കട്ടിൽ/കിടക്കയാണ്' എന്ന് നിർമ്മിക്കുക"},
          "scrambled": ["bed", "is", "This", "my"],
          "expected": "This is my bed"
        },
        {
          "round": 4,
          "type": "build",
          "prompt": {"en": "Build sentence: 'I see a black crow'", "ml": "'ഞാൻ ഒരു കറുത്ത കാക്കയെ കാണുന്നു' എന്ന് നിർമ്മിക്കുക"},
          "scrambled": ["crow", "see", "black", "I", "a"],
          "expected": "I see a black crow"
        },
        {
          "round": 5,
          "type": "build",
          "prompt": {"en": "Build sentence: 'Sweet grapes on the table'", "ml": "'മേശപ്പുറത്ത് മധുരമുള്ള മുന്തിരി' എന്ന് നിർമ്മിക്കുക"},
          "scrambled": ["grapes", "table", "Sweet", "on", "the"],
          "expected": "Sweet grapes on the table"
        },
        {
          "round": 6,
          "type": "build",
          "prompt": {"en": "Build sentence: 'Water is very fresh'", "ml": "'വെള്ളം വളരെ ഫ്രഷ് ആണ്' എന്ന് നിർമ്മിക്കുക"},
          "scrambled": ["fresh", "Water", "very", "is"],
          "expected": "Water is very fresh"
        }
      ]
    },
    {
      "stepNumber": 5,
      "id": "step_5_reading_book",
      "title": {
        "en": "Reading Room: The Crow and the Grapes",
        "ml": "റീഡിംഗ് റൂം: കാക്കയും മുന്തിരിയും (പുസ്തക വായന)",
        "hi": "रीडिंग रूम: कौआ और अंगूर",
        "ta": "வாசிப்பு அறை: காகமும் திராட்சையும்"
      },
      "icon": "📖",
      "gameType": "reading_room",
      "description": {
        "en": "Read 6 sentences with native voice audio, practice speaking aloud into your mic, and answer comprehension questions.",
        "ml": "ഓഡിയോ കേട്ട് 6 വാക്യങ്ങൾ ഉറക്കെ വായിക്കുക, തുടർന്ന് ചോദ്യങ്ങൾക്ക് ഉത്തരം നൽകുക.",
        "hi": "6 वाक्य ऑडियो के साथ पढ़ें और प्रश्नों के उत्तर दें।",
        "ta": "6 வாக்கியங்களை வாசித்து கேள்விகளுக்கு பதிலளிக்கவும்."
      },
      "passage": {
        "bookTitle": {
          "en": "The Crow and the Sweet Grapes",
          "ml": "കാക്കയും മധുര മുന്തിരിയും",
          "hi": "कौआ और मीठे अंगूर",
          "ta": "காகமும் இனிப்பு திராட்சையும்"
        },
        "sentences": [
          {
            "id": 1,
            "en": "A clever crow flies near a wooden house.",
            "ml": "ഒരു ബുദ്ധിയുള്ള കാക്ക ഒരു മര വീടിന് അടുത്ത് പറക്കുന്നു.",
            "hi": "एक चतुर कौआ लकड़ी के घर के पास उड़ता है।",
            "ta": "ஒரு புத்திசாலி காகம் மர வீட்டின் அருகில் பறக்கிறது."
          },
          {
            "id": 2,
            "en": "The crow sees a bowl of sweet green grapes on the table.",
            "ml": "മേശപ്പുറത്ത് ഒരു പാത്രം നിറയെ മധുരമുള്ള പച്ച മുന്തിരി കാക്ക കാണുന്നു.",
            "hi": "कौआ मेज पर मीठे हरे अंगूर का कटोरा देखता है।",
            "ta": "மேசையில் இனிப்பு திராட்சை கிண்ணத்தை காகம் பார்க்கிறது."
          },
          {
            "id": 3,
            "en": "A friendly cat is sleeping peacefully on the soft bed.",
            "ml": "ഒരു നല്ല പൂച്ച മൃദുവായ കിടക്കയിൽ സമാധാനമായി ഉറങ്ങുകയാണ്.",
            "hi": "एक बिल्ली बिस्तर पर आराम से सो रही है।",
            "ta": "ஒரு பூனை படுக்கையில் நிம்மதியாக தூங்குகிறது."
          },
          {
            "id": 4,
            "en": "The crow gently takes one grape and drinks cool water.",
            "ml": "കാക്ക പതിയെ ഒരു മുന്തിരി എടുക്കുകയും തണുത്ത വെള്ളം കുടിക്കുകയും ചെയ്യുന്നു.",
            "hi": "कौआ धीरे से एक अंगूर लेता है और ठंडा पानी पीता है।",
            "ta": "காகம் ஒரு திராட்சையை எடுத்து குளிர்ந்த நீரைக் குடிக்கிறது."
          },
          {
            "id": 5,
            "en": "The crow smiles and flies happily into the blue sky.",
            "ml": "കാക്ക പുഞ്ചിരിച്ച് നീലാകാശത്തേക്ക് സന്തോഷത്തോടെ പറന്നുപോകുന്നു.",
            "hi": "कौआ मुस्कुराता है और नीले आसमान में खुशी से उड़ जाता है।",
            "ta": "காகம் மகிழ்ச்சியுடன் நீல வானத்தில் பறக்கிறது."
          },
          {
            "id": 6,
            "en": "Sharing good food makes everyone joyful.",
            "ml": "നല്ല ഭക്ഷണം പങ്കുവെക്കുന്നത് എല്ലാവരിലും സന്തോഷം നിറയ്ക്കുന്നു.",
            "hi": "अच्छा खाना बांटने से सब खुश होते हैं।",
            "ta": "நல்ல உணவை பகிர்வது அனைவருக்கும் மகிழ்ச்சியைத் தரும்."
          }
        ],
        "comprehensionQuestions": [
          {
            "id": 1,
            "question": {
              "en": "What did the crow see on the table?",
              "ml": "മേശപ്പുറത്ത് കാക്ക എന്താണ് കണ്ടത്?",
              "hi": "कौए ने मेज पर क्या देखा?",
              "ta": "மேசையில் காகம் எதைப் பார்த்தது?"
            },
            "options": ["A bowl of sweet grapes 🍇", "A red ball ⚽", "A book 📖", "An egg 🥚"],
            "correctIndex": 0,
            "explanation": {
              "en": "The crow saw a bowl of sweet green grapes.",
              "ml": "കാക്ക മേശപ്പുറത്ത് മുന്തിരിയാണ് കണ്ടത്."
            }
          },
          {
            "id": 2,
            "question": {
              "en": "Where was the friendly cat sleeping?",
              "ml": "പൂച്ച എവിടെയാണ് ഉറങ്ങിക്കിടന്നത്?",
              "hi": "बिल्ली कहाँ सो रही थी?",
              "ta": "பூனை எங்கே தூங்கிக்கொண்டிருந்தது?"
            },
            "options": ["On the road", "On the soft bed 🛏️", "Under the tree", "In the car"],
            "correctIndex": 1,
            "explanation": {
              "en": "The cat was sleeping on the soft bed.",
              "ml": "കിടക്കയിലാണ് (bed) പൂച്ച ഉറങ്ങിയത്."
            }
          },
          {
            "id": 3,
            "question": {
              "en": "What did the crow drink?",
              "ml": "കാക്ക എന്താണ് കുടിച്ചത്?",
              "hi": "कौए ने क्या पिया?",
              "ta": "காகம் என்ன குடித்தது?"
            },
            "options": ["Warm milk", "Cool water 💧", "Hot tea", "Juice"],
            "correctIndex": 1,
            "explanation": {
              "en": "The crow drank cool water.",
              "ml": "തണുത്ത വെള്ളമാണ് (cool water) കാക്ക കുടിച്ചത്."
            }
          }
        ]
      }
    },
    {
      "stepNumber": 6,
      "id": "step_6_spoken_lab",
      "title": {
        "en": "Spoken Speech Lab (Voice Reflex)",
        "ml": "സംസാര പരിശീലനം (മൈക്ക് പ്രാക്ടീസ്)",
        "hi": "बोलने की प्रयोगशाला",
        "ta": "பேச்சுப் பயிற்சி கூடம்"
      },
      "icon": "🎙️",
      "gameType": "spoken_lab",
      "description": {
        "en": "Speak 6 key everyday sentences into your microphone with native audio comparison.",
        "ml": "മൈക്കിലൂടെ 6 പ്രധാന വാക്യങ്ങൾ ഉറക്കെ പറഞ്ഞു ശീലിക്കുക.",
        "hi": "माइक में 6 महत्वपूर्ण वाक्य बोलें।",
        "ta": "மைக்கில் 6 முக்கிய வாக்கியங்களைப் பேசுங்கள்."
      },
      "challenges": [
        {
          "id": 1,
          "phrase": "Hello! Good morning.",
          "phonetic": "/həˈləʊ ɡʊd ˈmɔː.nɪŋ/",
          "meaning": {"ml": "ഹലോ! സുപ്രഭാതം.", "hi": "नमस्ते! शुभ प्रभात।", "ta": "வணக்கம்! காலை வணக்கம்."}
        },
        {
          "id": 2,
          "phrase": "My name is Alex.",
          "phonetic": "/maɪ neɪm ɪz ˈæl.ɪks/",
          "meaning": {"ml": "എന്റെ പേര് അലക്സ് എന്നാണ്.", "hi": "मेरा नाम एलेक्स है।", "ta": "என் பெயர் அலெக்ஸ்."}
        },
        {
          "id": 3,
          "phrase": "I want a glass of water.",
          "phonetic": "/aɪ wɒnt ə ɡlɑːs əv ˈwɔː.tər/",
          "meaning": {"ml": "എനിക്ക് ഒരു ഗ്ലാസ്സ് വെള്ളം വേണം.", "hi": "मुझे एक गिलास पानी चाहिए।", "ta": "எனக்கு ஒரு டம்ளர் தண்ணீர் வேண்டும்."}
        },
        {
          "id": 4,
          "phrase": "I love sweet grapes.",
          "phonetic": "/aɪ lʌv swiːt ɡreɪps/",
          "meaning": {"ml": "എനിക്ക് മധുരമുള്ള മുന്തിരി ഇഷ്ടമാണ്.", "hi": "मुझे मीठे अंगूर पसंद हैं।", "ta": "எனக்கு இனிப்பு திராட்சை பிடிக்கும்."}
        },
        {
          "id": 5,
          "phrase": "Nice to meet you, friend.",
          "phonetic": "/naɪs tuː miːt juː frend/",
          "meaning": {"ml": "സുഹൃത്തേ, കണ്ടുമുട്ടിയതിൽ സന്തോഷം.", "hi": "आपसे मिलकर अच्छा लगा दोस्त।", "ta": "உங்களை சந்தித்ததில் மகிழ்ச்சி நண்பா."}
        },
        {
          "id": 6,
          "phrase": "Have a wonderful day ahead!",
          "phonetic": "/hæv ə ˈwʌn.də.fəl deɪ əˈhed/",
          "meaning": {"ml": "ഒരു നല്ല ദിവസം ആശംസിക്കുന്നു!", "hi": "आपका दिन शुभ हो!", "ta": "இனிய நாளாக அமையட்டும்!"}
        }
      ]
    },
    {
      "stepNumber": 7,
      "id": "step_7_random_chat_partner",
      "title": {
        "en": "Random Partner English Call",
        "ml": "റാൻഡം ഇംഗ്ലീഷ് കോൾ & ചാറ്റ് 📞",
        "hi": "रैंडम साथी के साथ बात करें",
        "ta": "சீரற்ற நண்பருடன் பேசுங்கள்"
      },
      "icon": "📞",
      "gameType": "random_call_action",
      "description": {
        "en": "Connect anonymously with a real English learning partner from Kerala/India to practice speaking today's words!",
        "ml": "ഹോം പേജിലെ റാൻഡം കോളിലൂടെ ഒരു ലൈവ് കൂട്ടുകാരനുമായി ഇംഗ്ലീഷിൽ സംസാരിക്കുക!",
        "hi": "लाइव साथी के साथ अंग्रेजी बोलने का अभ्यास करें।",
        "ta": "நேரலை நண்பருடன் ஆங்கிலம் பேச பயிற்சி செய்யுங்கள்."
      },
      "action": {
        "targetRoute": "anonymous_english_chat",
        "promptText": {
          "en": "Tap below to connect with a random English learning partner!",
          "ml": "താഴെ ടാപ്പ് ചെയ്ത് റാൻഡം ഇംഗ്ലീഷ് പാർട്ണറുമായി സംസാരിക്കുക!",
          "hi": "रैंडम पार्टनर से जुड़ने के लिए नीचे टैप करें!",
          "ta": "சீரற்ற பார்ட்னருடன் இணைக்க கீழே தட்டவும்!"
        },
        "starterTopics": [
          "Ask their name: 'Hi, what is your name?'",
          "Ask their favorite fruit: 'Do you like grapes or apples?'",
          "Say goodbye: 'Nice meeting you, have a good day!'"
        ]
      }
    },
    {
      "stepNumber": 8,
      "id": "step_8_pocket_talk",
      "title": {
        "en": "PocketTalk & Community Chat",
        "ml": "പോക്കറ്റ് ടോക്ക് & കമ്മ്യൂണിറ്റി ചാറ്റ് ⚡💬",
        "hi": "पॉकेटटॉक और कम्युनिटी चैट",
        "ta": "பாக்கெட்டாக் & சமூக அரட்டை"
      },
      "icon": "⚡",
      "gameType": "pocket_talk_action",
      "description": {
        "en": "Find your spoken practice mate via PocketTalk and chat in the community English Hub room!",
        "ml": "പോക്കറ്റ് ടോക്ക് വഴി ഒരു സ്പോക്കൺ പാർട്ണറെ കണ്ടെത്തുക, ഗ്രൂപ്പിൽ ഹലോ പറയുക!",
        "hi": "पॉकेटटॉक स्वाइप करें और कम्युनिटी चैट में शामिल हों!",
        "ta": "பாக்கெட்டாக் நண்பரைத் தேடுங்கள் அல்லது சமூக அரட்டையில் இணையுங்கள்!"
      },
      "action": {
        "targetRoute": "pocket_talk_card_swiper",
        "communityRoute": "community_chat_page",
        "promptText": {
          "en": "Swipe cards to find your mate or post in the English Hub!",
          "ml": "മേറ്റിനെ കണ്ടെത്തുക അല്ലെങ്കിൽ ഗ്രൂപ്പ് ചാറ്റിൽ സംസാരിക്കുക!",
          "hi": "साथी खोजें या कम्युनिटी चैट में शामिल हों!",
          "ta": "நண்பரைத் தேடுங்கள் அல்லது அரட்டையில் இணையுங்கள்!"
        }
      }
    },
    {
      "stepNumber": 9,
      "id": "step_9_house_defense",
      "title": {
        "en": "House Defense Shield & Citadel Combat",
        "ml": "ഹൗസ് ഡിഫൻസ് ഷീൽഡ് & അറ്റാക്ക് കോംബാറ്റ് 🛡️",
        "hi": "हाउस डिफेंस शील्ड और कॉम्बैट",
        "ta": "ஹவுஸ் டிஃபென்ஸ் ஷீல்டு"
      },
      "icon": "🛡️",
      "gameType": "house_defense",
      "description": {
        "en": "Equip 5 learned English defense traps to protect your house. Test your attack against a Level 10 opponent. Once armed, your vehicle drives to House 2!",
        "ml": "നിങ്ങളുടെ വീടിന് 5 ഡിഫൻസ് ട്രാപ്പുകൾ സെറ്റ് ചെയ്യുക. ലെവൽ 10 എതിരാളിയെ അറ്റാക്ക് ചെയ്യുക. പൂർത്തിയാകുമ്പോൾ വണ്ടി ഹൗസ് 2-ലേക്ക് ഡ്രൈവ് ചെയ്യും!",
        "hi": "अपने घर की रक्षा के लिए 5 डिफेंस ट्रैप लगाएं और लेवल 10 बॉट पर हमला करें!",
        "ta": "உங்கள் வீட்டைப் பாதுகாக்க 5 டிஃபென்ஸ் பொறிகளை அமைத்து எதிரியைத் தாக்கங்கள்!"
      },
      "combatTest": {
        "targetOpponent": "Iron Citadel Bot (Level 10)",
        "opponentHp": 100,
        "challenge": {
          "en": "Which object do you sleep on? 🛏️",
          "ml": "നിങ്ങൾ ഉറങ്ങുന്നത് എന്തിലാണ്? 🛏️",
          "hi": "आप किस पर सोते हैं? 🛏️",
          "ta": "நீங்கள் எதில் தூங்குகிறீர்கள்? 🛏️"
        },
        "options": ["Crow 🐦‍⬛", "Bed 🛏️", "Grapes 🍇", "Water 💧"],
        "correct": "Bed 🛏️"
      },
      "defenseTraps": [
        {
          "gate": 1,
          "question": {
            "en": "What is the English word for 'കിടക്ക / കട്ടിൽ' 🛏️?",
            "ml": "'കിടക്ക / കട്ടിൽ' എന്നതിന്റെ ഇംഗ്ലീഷ് വാക്ക് ഏതാണ്?",
            "hi": "'बिस्तर' के लिए अंग्रेजी शब्द क्या है?",
            "ta": "'படுக்கை' என்பதன் ஆங்கில சொல் எது?"
          },
          "options": ["Bed", "Crow", "Grapes", "Water"],
          "correctIndex": 0,
          "explanation": {"ml": "Bed എന്നാൽ കിടക്ക."}
        },
        {
          "gate": 2,
          "question": {
            "en": "What fruit is sweet and purple or green 🍇?",
            "ml": "'മുന്തിരി' എന്നതിന് ഇംഗ്ലീഷിൽ എന്ത് പറയും?",
            "hi": "'अंगूर' को अंग्रेजी में क्या कहते हैं?",
            "ta": "'திராட்சை' என்பதை ஆங்கிலத்தில் என்ன சொல்வார்கள்?"
          },
          "options": ["Apple", "Grapes", "Egg", "Fish"],
          "correctIndex": 1,
          "explanation": {"ml": "Grapes എന്നാൽ മുന്തിരി."}
        },
        {
          "gate": 3,
          "question": {
            "en": "What is the black bird that says 'caw-caw' 🐦‍⬛?",
            "ml": "'കാക്ക' എന്നതിന്റെ ഇംഗ്ലീഷ് വാക്ക് ഏതാണ്?",
            "hi": "'कौआ' को अंग्रेजी में क्या कहते हैं?",
            "ta": "'காகம்' என்பதன் ஆங்கில சொல் எது?"
          },
          "options": ["Cat", "Dog", "Crow", "Fish"],
          "correctIndex": 2,
          "explanation": {"ml": "Crow എന്നാൽ കാക്ക."}
        },
        {
          "gate": 4,
          "question": {
            "en": "Complete: 'I drink pure ______.' 💧",
            "ml": "വാചകം പൂർത്തിയാക്കുക: 'I drink pure ______.'",
            "hi": "वाक्य पूरा करें: 'I drink pure ______.'",
            "ta": "நிரப்புக: 'I drink pure ______.'"
          },
          "options": ["water", "crow", "bed", "book"],
          "correctIndex": 0,
          "explanation": {"ml": "Water എന്നാൽ വെള്ളം."}
        },
        {
          "gate": 5,
          "question": {
            "en": "How do you politely greet in the morning?",
            "ml": "രാവിലെ എങ്ങനെയാണ് അഭിവാദ്യം ചെയ്യുന്നത്?",
            "hi": "सुबह कैसे बधाई देते हैं?",
            "ta": "காலையில் எப்படி வாழ்த்து சொல்வீர்கள்?"
          },
          "options": ["Good night", "Good morning", "Goodbye", "Go away"],
          "correctIndex": 1,
          "explanation": {"ml": "Good morning."}
        }
      ]
    }
    },
    {
      "stepNumber": 10,
      "id": "step_10_gate_exam",
      "title": {
        "en": "House 1 Final Gate Exam & Unlock House 2",
        "ml": "ഹൗസ് 1 ഫൈനൽ എക്സാം & ഹൗസ് 2 അൺലോക്ക് 🎓🏆",
        "hi": "हाउस 1 फाइनल गेट परीक्षा और हाउस 2 अनलॉक",
        "ta": "ஹவுஸ் 1 இறுதித் தேர்வு & ஹவுஸ் 2 திறத்தல்"
      },
      "icon": "🎓",
      "gameType": "gate_exam",
      "description": {
        "en": "Pass the 8-question exam to master House 1, unlock House 2, and start your journey on Day 2!",
        "ml": "ഹൗസ് 1 പൂർത്തിയാക്കി ഹൗസ് 2 അൺലോക്ക് ചെയ്യുന്നതിനായി 8 ചോദ്യങ്ങൾക്ക് ഉത്തരം നൽകുക!",
        "hi": "हाउस 1 पूरा करें और हाउस 2 अनलॉक करने के लिए परीक्षा पास करें!",
        "ta": "ஹவுஸ் 1 முடித்து ஹவுஸ் 2 ஐ திறக்க 8 கேள்விகளுக்கு பதிலளிக்கவும்!"
      },
      "passPercentage": 60,
      "totalQuestions": 8
    }
  ],
  "houseGateExam": {
    "title": {
      "en": "House 1 Final Gate Exam",
      "ml": "ഹൗസ് 1 ഫൈനൽ എക്സാം (ഹൗസ് 2 അൺലോക്ക് ചെയ്യാൻ)",
      "hi": "हाउस 1 फाइनल गेट परीक्षा",
      "ta": "ஹவுஸ் 1 இறுதித் தேர்வு"
    },
    "description": {
      "en": "Pass this 8-question exam to master House 1 and officially unlock House 2 (Day 2).",
      "ml": "ഹൗസ് 2-ലേക്ക് കടക്കുന്നതിനായി ഈ 8 ചോദ്യങ്ങൾക്ക് കൃത്യമായി ഉത്തരം നൽകുക.",
      "hi": "हाउस 2 अनलॉक करने के लिए इन 8 प्रश्नों के उत्तर दें।",
      "ta": "ஹவுஸ் 2 ஐ திறக்க இந்த 8 கேள்விகளுக்கு பதிலளிக்கவும்."
    },
    "passPercentage": 60,
    "questions": [
      {
        "id": 1,
        "question": {
          "en": "Which letter starts the word 'Apple' 🍎?",
          "ml": "'Apple' എന്ന വാക്ക് തുടങ്ങുന്ന അക്ഷരം ഏതാണ്?",
          "hi": "'Apple' किस अक्षर से शुरू होता है?",
          "ta": "'Apple' எந்த எழுத்தில் தொடங்குகிறது?"
        },
        "options": ["A", "B", "C", "D"],
        "correctIndex": 0,
        "explanation": {"ml": "A for Apple."}
      },
      {
        "id": 2,
        "question": {
          "en": "What is the English word for 'മുന്തിരി' 🍇?",
          "ml": "'മുന്തിരി' എന്നതിന്റെ ഇംഗ്ലീഷ് വാക്ക് ഏതാണ്?",
          "hi": "'अंगूर' का अंग्रेजी शब्द क्या है?",
          "ta": "'திராட்சை' என்பதன் ஆங்கில சொல் எது?"
        },
        "options": ["Grapes", "Book", "Bed", "Water"],
        "correctIndex": 0,
        "explanation": {"ml": "Grapes എന്നാൽ മുന്തിരി."}
      },
      {
        "id": 3,
        "question": {
          "en": "What is the English word for 'കാക്ക' 🐦‍⬛?",
          "ml": "'കാക്ക' എന്നതിന്റെ ഇംഗ്ലീഷ് വാക്ക് ഏതാണ്?",
          "hi": "'कौआ' का अंग्रेजी शब्द क्या है?",
          "ta": "'காகம்' என்பதன் ஆங்கில சொல் எது?"
        },
        "options": ["Crow", "Cat", "Fish", "Dog"],
        "correctIndex": 0,
        "explanation": {"ml": "Crow എന്നാൽ കാക്ക."}
      },
      {
        "id": 4,
        "question": {
          "en": "Where do you sleep at night? 🛏️",
          "ml": "രാത്രിയിൽ നിങ്ങൾ എവിടെയാണ് ഉറങ്ങുന്നത്?",
          "hi": "आप रात में कहाँ सोते हैं?",
          "ta": "இரவில் எங்கு தூங்குகிறீர்கள்?"
        },
        "options": ["On the table", "On the bed", "In the water", "On the road"],
        "correctIndex": 1,
        "explanation": {"ml": "On the bed (കിടക്കയിൽ)."}
      },
      {
        "id": 5,
        "question": {
          "en": "Rearrange the words to make a correct sentence: [my / is / bed / This]",
          "ml": "വാചകം ശരിയായ ക്രമത്തിൽ എഴുതുക:",
          "hi": "सही वाक्य बनाएं:",
          "ta": "சரியான வாக்கியத்தை அமைக்கவும்:"
        },
        "options": ["This is my bed", "Bed my is this", "Is this bed my", "My bed this is"],
        "correctIndex": 0,
        "explanation": {"ml": "This is my bed (ഇത് എന്റെ കട്ടിലാണ്)."}
      },
      {
        "id": 6,
        "question": {
          "en": "In the story, what did the crow see on the table?",
          "ml": "കഥയിൽ മേശപ്പുറത്ത് കാക്ക എന്താണ് കണ്ടത്?",
          "hi": "कहानी में कौए ने मेज पर क्या देखा?",
          "ta": "கதையில் காகம் மேசையில் எதைப் பார்த்தது?"
        },
        "options": ["A bowl of sweet grapes 🍇", "A hot tea", "A sleeping dog", "A book"],
        "correctIndex": 0,
        "explanation": {"ml": "A bowl of sweet grapes."}
      },
      {
        "id": 7,
        "question": {
          "en": "What do you say when you meet someone for the first time?",
          "ml": "ആദ്യമായി ഒരാളെ കാണുമ്പോൾ എന്ത് പറയുന്നു?",
          "hi": "पहली बार किसी से मिलने पर क्या कहते हैं?",
          "ta": "ஒருவரை முதன்முறையாக சந்திக்கும் போது என்ன சொல்வீர்கள்?"
        },
        "options": ["Nice to meet you", "Go away", "Good night", "I am sleeping"],
        "correctIndex": 0,
        "explanation": {"ml": "'Nice to meet you' എന്ന് പറയുന്നു."}
      },
      {
        "id": 8,
        "question": {
          "en": "What transparent liquid do all humans need to drink? 💧",
          "ml": "മനുഷ്യർ കുടിക്കുന്ന ദ്രാവകം ഏതാണ്?",
          "hi": "पीने के लिए किस तरल पदार्थ की आवश्यकता होती है?",
          "ta": "குடிக்க வேண்டிய திரவம் எது?"
        },
        "options": ["Water", "Oil", "Ink", "Paint"],
        "correctIndex": 0,
        "explanation": {"ml": "Water (വെള്ളം)."}
      }
    ]
  }
}
''';
}
