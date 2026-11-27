import 'package:pocket_mates_app/custom_code/widgets/learning_60day/daily_vocab_item.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/sentence_builder_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_chat_reply_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mini_speech_practice_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_negative_sentence_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/spoken/pocket_90day_spoken_simulator_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_useful_phrases_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'pocket_german_90day_master_data.dart';

/// 🇩🇪 Master German A1 Curriculum Data Repository (Phase 1 MVP: Days 1–5)
/// Mirrors the exact structure of the English Master Track so the entire UI,
/// Open-World Mountain, Games, and Avatar Voice Engine (de-DE) work seamlessly.
class PocketGermanDays1To5Data {
  PocketGermanDays1To5Data._();

  /// 🔤 German Alphabet (A–Z + Ä, Ö, Ü, ß = 30 Letters)
  static const List<Map<String, dynamic>> germanAlphabetLetters = [
    {
      'letter': 'A',
      'sound': '/aː/ (ആ)',
      'word': 'Apfel',
      'emoji': '🍎',
      'voice': 'A wie Apfel',
      'meaning': {'ml': 'ആപ്പിൾ', 'hi': 'सेब', 'ta': 'ஆப்பிள்'},
      'exampleEn': 'Der Apfel ist rot.',
      'exampleMl': 'ആപ്പിൾ ചുവപ്പാണ്.',
    },
    {
      'letter': 'B',
      'sound': '/beː/ (ബേ)',
      'word': 'Ball',
      'emoji': '⚽',
      'voice': 'B wie Ball',
      'meaning': {'ml': 'പന്ത്', 'hi': 'गेंद', 'ta': 'பந்து'},
      'exampleEn': 'Der Ball ist groß.',
      'exampleMl': 'പന്ത് വലുതാണ്.',
    },
    {
      'letter': 'C',
      'sound': '/tseː/ (ത്സേ)',
      'word': 'Café',
      'emoji': '☕',
      'voice': 'C wie Café',
      'meaning': {'ml': 'കഫേ / കോഫി ഷോപ്പ്', 'hi': 'कैफे', 'ta': 'கபே'},
      'exampleEn': 'Wir gehen ins Café.',
      'exampleMl': 'നമ്മൾ കഫേയിലേക്ക് പോകുന്നു.',
    },
    {
      'letter': 'D',
      'sound': '/deː/ (ഡേ)',
      'word': 'Danke',
      'emoji': '🙏',
      'voice': 'D wie Danke',
      'meaning': {'ml': 'നന്ദി', 'hi': 'धन्यवाद', 'ta': 'நன்றி'},
      'exampleEn': 'Danke schön!',
      'exampleMl': 'വളരെ നന്ദി!',
    },
    {
      'letter': 'E',
      'sound': '/eː/ (ഏ)',
      'word': 'Elefant',
      'emoji': '🐘',
      'voice': 'E wie Elefant',
      'meaning': {'ml': 'ആന', 'hi': 'हाथी', 'ta': 'யானை'},
      'exampleEn': 'Der Elefant ist stark.',
      'exampleMl': 'ആന ശക്തനാണ്.',
    },
    {
      'letter': 'F',
      'sound': '/ɛf/ (എഫ്)',
      'word': 'Fisch',
      'emoji': '🐟',
      'voice': 'F wie Fisch',
      'meaning': {'ml': 'മീൻ', 'hi': 'मछली', 'ta': 'மீன்'},
      'exampleEn': 'Der Fisch schwimmt.',
      'exampleMl': 'മീൻ നീന്തുന്നു.',
    },
    {
      'letter': 'G',
      'sound': '/ɡeː/ (ഗേ)',
      'word': 'Guten Tag',
      'emoji': '👋',
      'voice': 'G wie Guten Tag',
      'meaning': {'ml': 'ശുഭദിനം', 'hi': 'शुभ दिन', 'ta': 'நல்ல நாள்'},
      'exampleEn': 'Guten Tag, mein Freund!',
      'exampleMl': 'ശുഭദിനം, എന്റെ സുഹൃത്തേ!',
    },
    {
      'letter': 'H',
      'sound': '/haː/ (ഹാ)',
      'word': 'Haus',
      'emoji': '🏠',
      'voice': 'H wie Haus',
      'meaning': {'ml': 'വീട്', 'hi': 'घर', 'ta': 'வீடு'},
      'exampleEn': 'Das Haus ist schön.',
      'exampleMl': 'വീട് മനോഹരമാണ്.',
    },
    {
      'letter': 'I',
      'sound': '/iː/ (ഈ)',
      'word': 'Ich',
      'emoji': '🙋',
      'voice': 'I wie Ich',
      'meaning': {'ml': 'ഞാൻ', 'hi': 'मैं', 'ta': 'நான்'},
      'exampleEn': 'Ich lerne Deutsch.',
      'exampleMl': 'ഞാൻ ജർമൻ പഠിക്കുന്നു.',
    },
    {
      'letter': 'J',
      'sound': '/jɔt/ (യോട്ട്)',
      'word': 'Ja',
      'emoji': '✅',
      'voice': 'J wie Ja',
      'meaning': {'ml': 'അതെ', 'hi': 'हाँ', 'ta': 'ஆம்'},
      'exampleEn': 'Ja, das stimmt!',
      'exampleMl': 'അതെ, അത് ശരിയാണ്!',
    },
    {
      'letter': 'K',
      'sound': '/kaː/ (കാ)',
      'word': 'Kaffee',
      'emoji': '☕',
      'voice': 'K wie Kaffee',
      'meaning': {'ml': 'കാപ്പി', 'hi': 'कॉफ़ी', 'ta': 'காபி'},
      'exampleEn': 'Ich trinke Kaffee.',
      'exampleMl': 'ഞാൻ കാപ്പി കുടിക്കുന്നു.',
    },
    {
      'letter': 'L',
      'sound': '/ɛl/ (എൽ)',
      'word': 'Lernen',
      'emoji': '📖',
      'voice': 'L wie Lernen',
      'meaning': {'ml': 'പഠിക്കുക', 'hi': 'सीखना', 'ta': 'கற்க'},
      'exampleEn': 'Wir lernen zusammen.',
      'exampleMl': 'നമ്മൾ ഒരുമിച്ച് പഠിക്കുന്നു.',
    },
    {
      'letter': 'M',
      'sound': '/ɛm/ (എം)',
      'word': 'Morgen',
      'emoji': '🌅',
      'voice': 'M wie Morgen',
      'meaning': {'ml': 'രാവിലെ / നാളെ', 'hi': 'सुबह / कल', 'ta': 'காலை'},
      'exampleEn': 'Guten Morgen!',
      'exampleMl': 'സുപ്രഭാതം!',
    },
    {
      'letter': 'N',
      'sound': '/ɛn/ (എൻ)',
      'word': 'Name',
      'emoji': '🪪',
      'voice': 'N wie Name',
      'meaning': {'ml': 'പേര്', 'hi': 'नाम', 'ta': 'பெயர்'},
      'exampleEn': 'Mein Name ist Arun.',
      'exampleMl': 'എന്റെ പേര് അരുൺ എന്നാണ്.',
    },
    {
      'letter': 'O',
      'sound': '/oː/ (ഓ)',
      'word': 'Obst',
      'emoji': '🍇',
      'voice': 'O wie Obst',
      'meaning': {'ml': 'പഴവർഗ്ഗങ്ങൾ', 'hi': 'फल', 'ta': 'பழம்'},
      'exampleEn': 'Ich esse gern Obst.',
      'exampleMl': 'എനിക്ക് പഴങ്ങൾ കഴിക്കാൻ ഇഷ്ടമാണ്.',
    },
    {
      'letter': 'P',
      'sound': '/peː/ (പേ)',
      'word': 'Papa',
      'emoji': '👨',
      'voice': 'P wie Papa',
      'meaning': {'ml': 'അച്ഛൻ', 'hi': 'पापा', 'ta': 'அப்பா'},
      'exampleEn': 'Mein Papa arbeitet in Berlin.',
      'exampleMl': 'എന്റെ അച്ഛൻ ബെർലിനിൽ ജോലി ചെയ്യുന്നു.',
    },
    {
      'letter': 'Q',
      'sound': '/kuː/ (കൂ)',
      'word': 'Quelle',
      'emoji': '💧',
      'voice': 'Q wie Quelle',
      'meaning': {'ml': 'ഉറവിടം', 'hi': 'स्रोत', 'ta': 'மூலம்'},
      'exampleEn': 'Das Wasser kommt aus der Quelle.',
      'exampleMl': 'വെള്ളം ഉറവിടത്തിൽ നിന്ന് വരുന്നു.',
    },
    {
      'letter': 'R',
      'sound': '/ɛʁ/ (എർ)',
      'word': 'Reise',
      'emoji': '✈️',
      'voice': 'R wie Reise',
      'meaning': {'ml': 'യാത്ര', 'hi': 'यात्रा', 'ta': 'பயணம்'},
      'exampleEn': 'Gute Reise!',
      'exampleMl': 'സുരക്ഷിതമായ യാത്ര നേരുന്നു!',
    },
    {
      'letter': 'S',
      'sound': '/ɛs/ (എസ്)',
      'word': 'Sonne',
      'emoji': '☀️',
      'voice': 'S wie Sonne',
      'meaning': {'ml': 'സൂര്യൻ', 'hi': 'सूरज', 'ta': 'சூரியன்'},
      'exampleEn': 'Die Sonne scheint heute.',
      'exampleMl': 'ഇന്ന് സൂര്യൻ പ്രകാശിക്കുന്നു.',
    },
    {
      'letter': 'T',
      'sound': '/teː/ (തേ)',
      'word': 'Tisch',
      'emoji': '🪵',
      'voice': 'T wie Tisch',
      'meaning': {'ml': 'മേശ', 'hi': 'मेज़', 'ta': 'மேசை'},
      'exampleEn': 'Das Buch liegt auf dem Tisch.',
      'exampleMl': 'പുസ്തകം മേശപ്പുറത്താണ്.',
    },
    {
      'letter': 'U',
      'sound': '/uː/ (ഊ)',
      'word': 'Uhr',
      'emoji': '⏰',
      'voice': 'U wie Uhr',
      'meaning': {'ml': 'മണി / ക്ലോക്ക്', 'hi': 'घड़ी', 'ta': 'கடிகாரம்'},
      'exampleEn': 'Wie spät ist es? Drei Uhr.',
      'exampleMl': 'സമയം എത്രയായി? മൂന്ന് മണി.',
    },
    {
      'letter': 'V',
      'sound': '/faʊ/ (ഫൗ)',
      'word': 'Vater',
      'emoji': '👨‍👧',
      'voice': 'V wie Vater',
      'meaning': {'ml': 'പിതാവ്', 'hi': 'पिता', 'ta': 'தந்தை'},
      'exampleEn': 'Mein Vater ist nett.',
      'exampleMl': 'എന്റെ അച്ഛൻ നല്ലയാളാണ്.',
    },
    {
      'letter': 'W',
      'sound': '/veː/ (വേ)',
      'word': 'Wasser',
      'emoji': '💧',
      'voice': 'W wie Wasser',
      'meaning': {'ml': 'വെള്ളം', 'hi': 'पानी', 'ta': 'தண்ணீர்'},
      'exampleEn': 'Ich trinke ein Glas Wasser.',
      'exampleMl': 'ഞാൻ ഒരു ഗ്ലാസ് വെള്ളം കുടിക്കുന്നു.',
    },
    {
      'letter': 'X',
      'sound': '/ɪks/ (ഇക്സ്)',
      'word': 'Xylophon',
      'emoji': '🎶',
      'voice': 'X wie Xylophon',
      'meaning': {'ml': 'സൈലോഫോൺ', 'hi': 'जाइलोफोन', 'ta': 'சைலோபோன்'},
      'exampleEn': 'Er spielt Xylophon.',
      'exampleMl': 'അവൻ സൈലോഫോൺ വായിക്കുന്നു.',
    },
    {
      'letter': 'Y',
      'sound': '/ˈʏpsilɔn/ (ഇപ്സിലോൺ)',
      'word': 'Yoga',
      'emoji': '🧘',
      'voice': 'Y wie Yoga',
      'meaning': {'ml': 'യോഗ', 'hi': 'योग', 'ta': 'யோகா'},
      'exampleEn': 'Ich mache jeden Morgen Yoga.',
      'exampleMl': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ യോഗ ചെയ്യുന്നു.',
    },
    {
      'letter': 'Z',
      'sound': '/tsɛt/ (ത്സെറ്റ്)',
      'word': 'Zug',
      'emoji': '🚆',
      'voice': 'Z wie Zug',
      'meaning': {'ml': 'ട്രെയിൻ', 'hi': 'ट्रेन', 'ta': 'ரயில்'},
      'exampleEn': 'Der Zug kommt um acht Uhr.',
      'exampleMl': 'ട്രെയിൻ എട്ട് മണിക്ക് വരും.',
    },
    {
      'letter': 'Ä',
      'sound': '/ɛː/ (ഏഹ്)',
      'word': 'Bär',
      'emoji': '🐻',
      'voice': 'Ä wie Bär',
      'meaning': {'ml': 'കരടി', 'hi': 'भालू', 'ta': 'கரடி'},
      'exampleEn': 'Der Bär lebt im Wald.',
      'exampleMl': 'കരടി കാട്ടിൽ ജീവിക്കുന്നു.',
    },
    {
      'letter': 'Ö',
      'sound': '/øː/ (ഓ-ഉംലൗട്ട്)',
      'word': 'Öl',
      'emoji': '🫒',
      'voice': 'Ö wie Öl',
      'meaning': {'ml': 'എണ്ണ / ഓയിൽ', 'hi': 'तेल', 'ta': 'எண்ணெய்'},
      'exampleEn': 'Wir kochen mit Olivenöl.',
      'exampleMl': 'നമ്മൾ ഒലിവ് ഓയിൽ ഉപയോഗിച്ച് പാചകം ചെയ്യുന്നു.',
    },
    {
      'letter': 'Ü',
      'sound': '/yː/ (ഊ-ഉംലൗട്ട്)',
      'word': 'Über',
      'emoji': '🌉',
      'voice': 'Ü wie Über',
      'meaning': {'ml': 'മുകളിൽ / കുറിച്ച്', 'hi': 'ऊपर / के बारे में', 'ta': 'மேலே'},
      'exampleEn': 'Wir gehen über die Brücke.',
      'exampleMl': 'നമ്മൾ പാലത്തിന് മുകളിലൂടെ നടക്കുന്നു.',
    },
    {
      'letter': 'ß',
      'sound': '/ɛsˈtsɛt/ (എസ്-ത്സെറ്റ്)',
      'word': 'Straße',
      'emoji': '🛣️',
      'voice': 'Eszett wie Straße',
      'meaning': {'ml': 'റോഡ് / തെരുവ്', 'hi': 'सड़क', 'ta': 'தெரு'},
      'exampleEn': 'Die Straße ist breit.',
      'exampleMl': 'റോഡ് വീതിയുള്ളതാണ്.',
    },
  ];

  /// 📚 20 Essential Everyday German Words for Day 1 Step 2 Avatar Chat
  static const List<Map<String, dynamic>> germanDay1Vocab20 = [
    {
      'word': 'Buch',
      'meaningEn': 'Das Buch (The book)',
      'meaningMl': 'പുസ്തകം (Das Buch)',
      'emoji': '📖',
      'sentence': 'Das ist ein Buch.',
      'sentenceMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
      'exampleEn': 'Das ist ein Buch.',
      'exampleMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
    },
    {
      'word': 'Auto',
      'meaningEn': 'Das Auto (The car)',
      'meaningMl': 'കാർ (Das Auto)',
      'emoji': '🚗',
      'sentence': 'Das ist ein Auto.',
      'sentenceMl': 'ഇത് ഒരു കാറാണ്.',
      'exampleEn': 'Das ist ein Auto.',
      'exampleMl': 'ഇത് ഒരു കാറാണ്.',
    },
    {
      'word': 'Wasser',
      'meaningEn': 'Das Wasser (The water)',
      'meaningMl': 'വെള്ളം (Das Wasser)',
      'emoji': '💧',
      'sentence': 'Ich trinke Wasser.',
      'sentenceMl': 'ഞാൻ വെള്ളം കുടിക്കുന്നു.',
      'exampleEn': 'Ich trinke Wasser.',
      'exampleMl': 'ഞാൻ വെള്ളം കുടിക്കുന്നു.',
    },
    {
      'word': 'Essen',
      'meaningEn': 'Das Essen (The food)',
      'meaningMl': 'ഭക്ഷണം (Das Essen)',
      'emoji': '🍲',
      'sentence': 'Ich esse gern.',
      'sentenceMl': 'എനിക്ക് കഴിക്കാൻ ഇഷ്ടമാണ്.',
      'exampleEn': 'Das Essen ist gut.',
      'exampleMl': 'ഭക്ഷണം നല്ലതാണ്.',
    },
    {
      'word': 'Haus',
      'meaningEn': 'Das Haus (The home)',
      'meaningMl': 'വീട് (Das Haus)',
      'emoji': '🏠',
      'sentence': 'Das ist mein Haus.',
      'sentenceMl': 'ഇത് എന്റെ വീടാണ്.',
      'exampleEn': 'Das ist mein Haus.',
      'exampleMl': 'ഇത് എന്റെ വീടാണ്.',
    },
    {
      'word': 'Freund',
      'meaningEn': 'Der Freund (The friend)',
      'meaningMl': 'സുഹൃത്ത് (Der Freund)',
      'emoji': '🤝',
      'sentence': 'Du bist mein Freund.',
      'sentenceMl': 'നീ എന്റെ സുഹൃത്താണ്.',
      'exampleEn': 'Du bist mein Freund.',
      'exampleMl': 'നീ എന്റെ സുഹൃത്താണ്.',
    },
    {
      'word': 'Fenster',
      'meaningEn': 'Das Fenster (The window)',
      'meaningMl': 'ജനൽ (Das Fenster)',
      'emoji': '🪟',
      'sentence': 'Öffne das Fenster.',
      'sentenceMl': 'ജനൽ തുറക്കൂ.',
      'exampleEn': 'Öffne das Fenster.',
      'exampleMl': 'ജനൽ തുറക്കൂ.',
    },
    {
      'word': 'Schule',
      'meaningEn': 'Die Schule (The school)',
      'meaningMl': 'സ്കൂൾ (Die Schule)',
      'emoji': '🏫',
      'sentence': 'Ich gehe in die Schule.',
      'sentenceMl': 'ഞാൻ സ്കൂളിൽ പോകുന്നു.',
      'exampleEn': 'Ich gehe in die Schule.',
      'exampleMl': 'ഞാൻ സ്കൂളിൽ പോകുന്നു.',
    },
    {
      'word': 'Baum',
      'meaningEn': 'Der Baum (The tree)',
      'meaningMl': 'മരം (Der Baum)',
      'emoji': '🌳',
      'sentence': 'Schau den Baum an.',
      'sentenceMl': 'മരത്തിലേക്ക് നോക്കൂ.',
      'exampleEn': 'Schau den Baum an.',
      'exampleMl': 'മരത്തിലേക്ക് നോക്കൂ.',
    },
    {
      'word': 'Stuhl',
      'meaningEn': 'Der Stuhl (The chair)',
      'meaningMl': 'കസേര (Der Stuhl)',
      'emoji': '🪑',
      'sentence': 'Nimm den Stuhl.',
      'sentenceMl': 'കസേര എടുക്കൂ.',
      'exampleEn': 'Nimm den Stuhl.',
      'exampleMl': 'കസേര എടുക്കൂ.',
    },
    {
      'word': 'Tisch',
      'meaningEn': 'Der Tisch (The table)',
      'meaningMl': 'മേശ (Der Tisch)',
      'emoji': '🪵',
      'sentence': 'Das liegt auf dem Tisch.',
      'sentenceMl': 'അത് മേശപ്പുറത്താണ്.',
      'exampleEn': 'Das liegt auf dem Tisch.',
      'exampleMl': 'അത് മേശപ്പുറത്താണ്.',
    },
    {
      'word': 'Tür',
      'meaningEn': 'Die Tür (The door)',
      'meaningMl': 'വാതിൽ (Die Tür)',
      'emoji': '🚪',
      'sentence': 'Öffne die Tür.',
      'sentenceMl': 'വാതിൽ തുറക്കൂ.',
      'exampleEn': 'Öffne die Tür.',
      'exampleMl': 'വാതിൽ തുറക്കൂ.',
    },
    {
      'word': 'Milch',
      'meaningEn': 'Die Milch (The milk)',
      'meaningMl': 'പാൽ (Die Milch)',
      'emoji': '🥛',
      'sentence': 'Ich trinke Milch.',
      'sentenceMl': 'ഞാൻ പാൽ കുടിക്കുന്നു.',
      'exampleEn': 'Ich trinke Milch.',
      'exampleMl': 'ഞാൻ പാൽ കുടിക്കുന്നു.',
    },
    {
      'word': 'Handy',
      'meaningEn': 'Das Handy (Mobile phone)',
      'meaningMl': 'മൊബൈൽ ഫോൺ (Das Handy)',
      'emoji': '📱',
      'sentence': 'Wo ist mein Handy?',
      'sentenceMl': 'എന്റെ ഫോൺ എവിടെയാണ്?',
      'exampleEn': 'Wo ist mein Handy?',
      'exampleMl': 'എന്റെ ഫോൺ എവിടെയാണ്?',
    },
    {
      'word': 'Vogel',
      'meaningEn': 'Der Vogel (The bird)',
      'meaningMl': 'പക്ഷി (Der Vogel)',
      'emoji': '🐦',
      'sentence': 'Der Vogel fliegt.',
      'sentenceMl': 'പക്ഷി പറക്കുന്നു.',
      'exampleEn': 'Der Vogel fliegt.',
      'exampleMl': 'പക്ഷി പറക്കുന്നു.',
    },
    {
      'word': 'Straße',
      'meaningEn': 'Die Straße (The road/street)',
      'meaningMl': 'റോഡ് (Die Straße)',
      'emoji': '🛣️',
      'sentence': 'Die Straße ist lang.',
      'sentenceMl': 'റോഡ് നീളമുള്ളതാണ്.',
      'exampleEn': 'Die Straße ist lang.',
      'exampleMl': 'റോഡ് നീളമുള്ളതാണ്.',
    },
    {
      'word': 'Geld',
      'meaningEn': 'Das Geld (The money)',
      'meaningMl': 'പണം (Das Geld)',
      'emoji': '💵',
      'sentence': 'Ich habe Geld.',
      'sentenceMl': 'എന്റെ പക്കൽ പണമുണ്ട്.',
      'exampleEn': 'Ich habe Geld.',
      'exampleMl': 'എന്റെ പക്കൽ പണമുണ്ട്.',
    },
    {
      'word': 'Uhr',
      'meaningEn': 'Die Uhr (Clock / Watch)',
      'meaningMl': 'ക്ലോക്ക് (Die Uhr)',
      'emoji': '⏰',
      'sentence': 'Schau auf die Uhr.',
      'sentenceMl': 'ക്ലോക്കിലേക്ക് നോക്കൂ.',
      'exampleEn': 'Schau auf die Uhr.',
      'exampleMl': 'ക്ലോക്കിലേക്ക് നോക്കൂ.',
    },
    {
      'word': 'Kaffee',
      'meaningEn': 'Der Kaffee (Coffee)',
      'meaningMl': 'കാപ്പി (Der Kaffee)',
      'emoji': '☕',
      'sentence': 'Ein Kaffee, bitte.',
      'sentenceMl': 'ദയവായി ഒരു കാപ്പി തരൂ.',
      'exampleEn': 'Ein Kaffee, bitte.',
      'exampleMl': 'ദയവായി ഒരു കാപ്പി തരൂ.',
    },
    {
      'word': 'Danke',
      'meaningEn': 'Thank you',
      'meaningMl': 'നന്ദി (Danke)',
      'emoji': '🙏',
      'sentence': 'Vielen Dank!',
      'sentenceMl': 'വളരെ നന്ദി!',
      'exampleEn': 'Vielen Dank!',
      'exampleMl': 'വളരെ നന്ദി!',
    },
  ];

  /// 🗺️ German Day 1–90 Lesson Metadata (Delegated to full 90-day repository)
  static Map<String, dynamic> getLessonSpecMap(int day) =>
      PocketGerman90DayMasterData.getLessonSpecMap(day);

  /// 📚 10 Core German Words per Day (Days 1–90 = 900 Unique Words)
  static List<DailyVocabItem> getVocabForDay(int day) =>
      PocketGerman90DayMasterData.getVocabForDay(day);

  /// 🧩 Sentence Builder Rounds for German Days 1–90
  static List<SentenceChallengeRound> getSentencesForDay(int day) =>
      PocketGerman90DayMasterData.getSentencesForDay(day);

  /// 💬 Useful German Phrases (Step 6) for Days 1–90
  static DayUsefulPhrases getDayPhrases(int day) =>
      PocketGerman90DayMasterData.getDayPhrases(day);

  /// ⏳ Verb Timeline (Step 15) for Days 1–90
  static List<VerbTimelineItem> getVerbsForDay(int day) =>
      PocketGerman90DayMasterData.getVerbsForDay(day);

  /// 🔄 Negative Builder (Step 17) for Days 1–90
  static List<NegativeSentenceRound> getNegativeRoundsForDay(int day) =>
      PocketGerman90DayMasterData.getNegativeRoundsForDay(day);

  /// 💬 Chat Reply Scenarios (Step 16) for Days 1–90
  static List<ChatReplyScenario> getChatScenariosForDay(int day) =>
      PocketGerman90DayMasterData.getChatScenariosForDay(day);

  /// 📢 Mini Speech Topics (Step 18) for Days 1–90
  static List<MiniSpeechTopic> getSpeechTopicsForDay(int day) =>
      PocketGerman90DayMasterData.getSpeechTopicsForDay(day);

  /// 🎙️ 20-Turn Spoken Simulator (Step 13) for Days 1–90
  static DaySpokenSimulatorPlan getSpokenSimulatorPlanForDay(int day) =>
      PocketGerman90DayMasterData.getSpokenSimulatorPlanForDay(day);

  /// 🗣️ Day 2 Step 1 German Drills
  static const List<Map<String, String>> day2Drills = [
    {
      'en': 'Ich komme aus Indien.',
      'ml': 'ഞാൻ ഇന്ത്യയിൽ നിന്നാണ് വരുന്നത്.',
      'rule': 'Subject: Ich -> komme aus (+ Country)',
    },
    {
      'en': 'Ich wohne in einer schönen Stadt.',
      'ml': 'ഞാൻ മനോഹരമായ ഒരു നഗരത്തിലാണ് താമസിക്കുന്നത്.',
      'rule': 'Action: wohne in (+ City / Place)',
    },
    {
      'en': 'Er ist jetzt zu Hause.',
      'ml': 'അവൻ ഇപ്പോൾ വീട്ടിലുണ്ട്.',
      'rule': 'Subject: Er -> ist (zu Hause = at home)',
    },
    {
      'en': 'Wir lernen zusammen Deutsch.',
      'ml': 'നമ്മൾ ഒരുമിച്ച് ജർമൻ പഠിക്കുന്നു.',
      'rule': 'Plural: Wir -> lernen',
    },
  ];

  /// 🐱 Concept Room & Avatar Chat Specs (Days 1–90)
  static Map<String, dynamic> getAvatarChatSpecMap(int day) =>
      PocketGerman90DayMasterData.getAvatarChatSpecMap(day);

  /// 🎙️ Spoken Gate Exam Questions for Days 1–90
  static List<Map<String, dynamic>> getExamForDay(int day) =>
      PocketGerman90DayMasterData.getExamForDay(day);
}
