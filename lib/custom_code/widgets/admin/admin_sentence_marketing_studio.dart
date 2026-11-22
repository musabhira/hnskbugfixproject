import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';

/// 📝 Model for custom sentences created by Admin for marketing & Instagram Reels recording.
class AdminMarketingSentence {
  final String id;
  final String language; // 'ml' (Malayalam), 'ta' (Tamil), 'hi' (Hindi), 'kn' (Kannada)
  final String prompt; // Native Meaning
  final String englishSentence; // Target English Sentence
  final String extraDistractors; // Optional comma-separated distractor words

  AdminMarketingSentence({
    required this.id,
    this.language = 'ml',
    required this.prompt,
    required this.englishSentence,
    this.extraDistractors = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'prompt': prompt,
        'english_sentence': englishSentence,
        'extra_distractors': extraDistractors,
      };

  factory AdminMarketingSentence.fromJson(Map<String, dynamic> json) =>
      AdminMarketingSentence(
        id: json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        language: json['language']?.toString() ?? 'ml',
        prompt: json['prompt']?.toString() ?? '',
        englishSentence: json['english_sentence']?.toString() ?? '',
        extraDistractors: json['extra_distractors']?.toString() ?? '',
      );

  AdminMarketingSentence copyWith({
    String? language,
    String? prompt,
    String? englishSentence,
    String? extraDistractors,
  }) {
    return AdminMarketingSentence(
      id: id,
      language: language ?? this.language,
      prompt: prompt ?? this.prompt,
      englishSentence: englishSentence ?? this.englishSentence,
      extraDistractors: extraDistractors ?? this.extraDistractors,
    );
  }
}

/// 💾 Repository handling Local Storage for Marketing Studio sentences
class AdminMarketingSentenceRepository {
  static const String _kStorageKey =
      'admin_marketing_sentence_builder_content_v3';

  static final List<AdminMarketingSentence> defaultSentences = [
    // =========================================================================
    // 🌴 MALAYALAM (30 Viral Sentences: Places, Celebrities, Brands & Real Spoken Grammar)
    // =========================================================================
    AdminMarketingSentence(
      id: 'ml_1',
      language: 'ml',
      prompt: 'ഞാൻ ഇന്നലെ ദുബായിൽ നിന്ന് പുതിയ ഐഫോൺ വാങ്ങി',
      englishSentence: 'Did you buy the new iPhone from Dubai yesterday?',
      extraDistractors: 'bought, in, bought, tomorrow',
    ),
    AdminMarketingSentence(
      id: 'ml_2',
      language: 'ml',
      prompt: 'ക്രിസ്റ്റ്യാനോ റൊണാൾഡോയുടെ കിടിലൻ ഗോൾ മലപ്പുറത്തെ ആരാധകർ ആഘോഷിച്ചു',
      englishSentence: 'Malappuram football fans celebrated Cristiano Ronaldo\'s goal with fireworks',
      extraDistractors: 'at, of, plays, cheer',
    ),
    AdminMarketingSentence(
      id: 'ml_3',
      language: 'ml',
      prompt: 'കോഴിക്കോട് ബീച്ചിലെ ചൂടുള്ള സുലൈമാനിയും പലഹാരങ്ങളും വളരെ പ്രശസ്തമാണ്',
      englishSentence: 'Kozhikode beach is famous for delicious hot sulaimani and snacks',
      extraDistractors: 'in, are, the, with',
    ),
    AdminMarketingSentence(
      id: 'ml_4',
      language: 'ml',
      prompt: 'മെസ്സി ലോകകപ്പ് ഫൈനലിൽ അവിസ്മരണീയമായ പ്രകടനം കാഴ്ചവെച്ചു',
      englishSentence: 'Messi delivered an unforgettable performance in the World Cup final',
      extraDistractors: 'did, on, game, score',
    ),
    AdminMarketingSentence(
      id: 'ml_5',
      language: 'ml',
      prompt: 'നമുക്ക് വൈകുന്നേരം കൊച്ചി മെട്രോയിൽ കയറി ലുലു മാളിലേക്ക് പോകാം',
      englishSentence: 'We can travel by Kochi Metro to visit Lulu Mall this evening',
      extraDistractors: 'go, on, in, ride',
    ),
    AdminMarketingSentence(
      id: 'ml_6',
      language: 'ml',
      prompt: 'പാലക്കാട് കഴിഞ്ഞ വേനൽക്കാലത്ത് കേരളത്തിലെ ഏറ്റവും ഉയർന്ന ചൂട് രേഖപ്പെടുത്തി',
      englishSentence: 'Palakkad recorded the highest summer temperature in Kerala last year',
      extraDistractors: 'was, hot, in, had',
    ),
    AdminMarketingSentence(
      id: 'ml_7',
      language: 'ml',
      prompt: 'നിങ്ങൾ തലശ്ശേരി ദം ബിരിയാണി ഇതുവരെ കഴിച്ചിട്ടുണ്ടോ?',
      englishSentence: 'Have you ever tasted the famous Thalassery dum biryani?',
      extraDistractors: 'had, eat, did, took',
    ),
    AdminMarketingSentence(
      id: 'ml_8',
      language: 'ml',
      prompt: 'വയനാട്ടിലെ ചുരം റോഡിലൂടെയുള്ള ബൈക്ക് യാത്ര അതിമനോഹരമാണ്',
      englishSentence: 'Riding a motorcycle through the Wayanad mountain pass is thrilling',
      extraDistractors: 'ride, on, road, goes',
    ),
    AdminMarketingSentence(
      id: 'ml_9',
      language: 'ml',
      prompt: 'മമ്മൂക്കയുടെയും ലാലേട്ടന്റെയും പുതിയ സിനിമകൾ ബോക്സ് ഓഫീസിൽ തരംഗമായി',
      englishSentence: 'The new movies of Mammootty and Mohanlal broke box office records',
      extraDistractors: 'win, on, make, break',
    ),
    AdminMarketingSentence(
      id: 'ml_10',
      language: 'ml',
      prompt: 'ഖത്തർ ലോകകപ്പിൽ അർജന്റീന കിരീടം ഉയർത്തിയ നിമിഷം അത്ഭുതമായിരുന്നു',
      englishSentence: 'Argentina lifted the historic World Cup trophy in Qatar',
      extraDistractors: 'got, win, at, won',
    ),
    AdminMarketingSentence(
      id: 'ml_11',
      language: 'ml',
      prompt: 'എന്റെ സുഹൃത്ത് റോയൽ എൻഫീൽഡ് ബൈക്കിൽ ലഡാക്കിലേക്ക് യാത്ര തിരിച്ചു',
      englishSentence: 'My best friend started a motorcycle trip to Ladakh',
      extraDistractors: 'went, go, with, ride',
    ),
    AdminMarketingSentence(
      id: 'ml_12',
      language: 'ml',
      prompt: 'മൂന്നാറിലെ മഞ്ഞും തേയിലത്തോട്ടങ്ങളും കാണാൻ സഞ്ചാരികൾ എത്താറുണ്ട്',
      englishSentence: 'Tourists arrive in Munnar to admire mist and tea gardens',
      extraDistractors: 'come, on, with, see',
    ),
    AdminMarketingSentence(
      id: 'ml_13',
      language: 'ml',
      prompt: 'നീ എന്തുകൊണ്ടാണ് ഇന്നത്തെ സ്പോക്കൺ ഇംഗ്ലീഷ് ക്ലാസിൽ പങ്കെടുക്കാതിരുന്നത്?',
      englishSentence: 'Why did you not attend the spoken English class today?',
      extraDistractors: 'where, was, come, are',
    ),
    AdminMarketingSentence(
      id: 'ml_14',
      language: 'ml',
      prompt: 'മലപ്പുറം കോട്ടപ്പടി സ്റ്റേഡിയത്തിൽ സെവൻസ് ഫുട്ബോൾ ആവേശം കൊടുമുടിയിലാണ്',
      englishSentence: 'Sevens football creates incredible excitement in Malappuram Kottappadi stadium',
      extraDistractors: 'at, play, is, are',
    ),
    AdminMarketingSentence(
      id: 'ml_15',
      language: 'ml',
      prompt: 'ആലപ്പുഴയിലെ ഹൗസ്ബോട്ട് യാത്ര നിങ്ങളുടെ മനസ്സിന് ശാന്തത നൽകും',
      englishSentence: 'A houseboat ride in Alappuzha gives deep peace of mind',
      extraDistractors: 'is, to, with, give',
    ),
    AdminMarketingSentence(
      id: 'ml_16',
      language: 'ml',
      prompt: 'അവൻ പുതിയ ഫെരാരി കാർ സ്വന്തമാക്കാൻ കഠിനാധ്വാനം ചെയ്യുന്നു',
      englishSentence: 'He is working very hard to purchase a luxury sports car',
      extraDistractors: 'buy, for, does, will',
    ),
    AdminMarketingSentence(
      id: 'ml_17',
      language: 'ml',
      prompt: 'നിങ്ങൾക്ക് നാളെ രാവിലെ തിരുവനന്തപുരത്തേക്ക് ട്രെയിൻ കയറാൻ കഴിയുമോ?',
      englishSentence: 'Can you catch the morning train to Thiruvananthapuram tomorrow?',
      extraDistractors: 'go, will, at, take',
    ),
    AdminMarketingSentence(
      id: 'ml_18',
      language: 'ml',
      prompt: 'പോക്കറ്റ് മേറ്റ്സ് ആപ്പ് വഴി ദിവസവും ഇംഗ്ലീഷ് സംസാരിച്ചു പരിശീലിക്കാം',
      englishSentence: 'You can practice spoken English daily using the Pocket Mates app',
      extraDistractors: 'speak, study, on, talk',
    ),
    AdminMarketingSentence(
      id: 'ml_19',
      language: 'ml',
      prompt: 'നെയ്മറുടെ മാന്ത്രിക ഡ്രിബ്ലിംഗ് ഫുട്ബോൾ പ്രേമികളെ ആവേശം കൊള്ളിക്കുന്നു',
      englishSentence: 'Neymar dazzles football fans worldwide with his brilliant dribbling skills',
      extraDistractors: 'play, on, the, run',
    ),
    AdminMarketingSentence(
      id: 'ml_20',
      language: 'ml',
      prompt: 'ഇന്നത്തെ പത്രത്തിൽ നമ്മുടെ കോളേജിനെക്കുറിച്ചുള്ള വാർത്ത വന്നിട്ടുണ്ട്',
      englishSentence: 'Our college has been featured on the front page of today\'s newspaper',
      extraDistractors: 'in, news, is, was',
    ),
    AdminMarketingSentence(
      id: 'ml_21',
      language: 'ml',
      prompt: 'തൃശ്ശൂർ പൂരത്തിലെ കുടമാറ്റം നേരിൽ കാണാൻ വൻ ജനക്കൂട്ടമാണ് എത്തിയത്',
      englishSentence: 'A massive crowd gathered to witness the famous Thrissur Pooram festival',
      extraDistractors: 'came, on, to, saw',
    ),
    AdminMarketingSentence(
      id: 'ml_22',
      language: 'ml',
      prompt: 'നീ എപ്പോഴാണ് നിന്റെ സ്വപ്ന ഭവനത്തിന്റെ പണി പൂർത്തിയാക്കുക?',
      englishSentence: 'When will you complete the construction of your dream home?',
      extraDistractors: 'did, finish, make, do',
    ),
    AdminMarketingSentence(
      id: 'ml_23',
      language: 'ml',
      prompt: 'കാപ്പിയേക്കാൾ എനിക്ക് ഇഷ്ടം ചൂട് കട്ടൻ ചായ കുടിക്കാനാണ്',
      englishSentence: 'I prefer drinking hot black tea rather than instant coffee',
      extraDistractors: 'like, to, drink, take',
    ),
    AdminMarketingSentence(
      id: 'ml_24',
      language: 'ml',
      prompt: 'സ്പോക്കൺ ഇംഗ്ലീഷിൽ സംസാരിക്കാൻ തുടങ്ങിയാൽ നിങ്ങളുടെ ആത്മവിശ്വാസം ഇരട്ടിയാകും',
      englishSentence: 'Speaking in English regularly will double your personal self-confidence',
      extraDistractors: 'can, make, grow, be',
    ),
    AdminMarketingSentence(
      id: 'ml_25',
      language: 'ml',
      prompt: 'കണ്ണൂർ വിമാനത്താവളത്തിൽ നിന്ന് ഞാൻ അടുത്ത ആഴ്ച ലണ്ടനിലേക്ക് പറക്കും',
      englishSentence: 'I am flying to London from Kannur International Airport next week',
      extraDistractors: 'go, on, fly, will',
    ),
    AdminMarketingSentence(
      id: 'ml_26',
      language: 'ml',
      prompt: 'അവൻ എല്ലാ വാരാന്ത്യത്തിലും ജിമ്മിൽ പോയി കഠിനമായി വ്യായാമം ചെയ്യാറുണ്ട്',
      englishSentence: 'He exercises rigorously at the fitness gym every weekend',
      extraDistractors: 'goes, do, with, did',
    ),
    AdminMarketingSentence(
      id: 'ml_27',
      language: 'ml',
      prompt: 'ഞങ്ങൾ വൈകുന്നേരം ഫോർട്ട് കൊച്ചി കടപ്പുറത്ത് സൂര്യാസ്തമയം ആസ്വദിച്ചു',
      englishSentence: 'We enjoyed the stunning sunset at Fort Kochi beach this evening',
      extraDistractors: 'see, in, saw, like',
    ),
    AdminMarketingSentence(
      id: 'ml_28',
      language: 'ml',
      prompt: 'നിന്റെ മൊബൈൽ ഫോൺ ബാറ്ററി പെട്ടെന്ന് തീർന്നുപോകാറുണ്ടോ?',
      englishSentence: 'Does your smartphone battery drain quickly during heavy usage?',
      extraDistractors: 'is, run, do, are',
    ),
    AdminMarketingSentence(
      id: 'ml_29',
      language: 'ml',
      prompt: 'പഠനം വിജയകരമായി പൂർത്തിയാക്കിയ ശേഷം അവൻ സ്വന്തമായി ബിസിനസ് തുടങ്ങി',
      englishSentence: 'He launched his own startup after completing university graduation',
      extraDistractors: 'start, did, on, made',
    ),
    AdminMarketingSentence(
      id: 'ml_30',
      language: 'ml',
      prompt: 'ദിവസവും കുറഞ്ഞത് പത്ത് മിനിറ്റെങ്കിലും ഇംഗ്ലീഷ് സംസാരിക്കാൻ നമ്മൾ ശ്രമിക്കണം',
      englishSentence: 'We should speak English for at least ten minutes every single day',
      extraDistractors: 'can, practice, do, try',
    ),

    // =========================================================================
    // 🛕 TAMIL (20 Viral Sentences: Chennai, Vijay, Dhoni, Madurai, Brands)
    // =========================================================================
    AdminMarketingSentence(
      id: 'ta_1',
      language: 'ta',
      prompt: 'தல அஜித் மற்றும் தளபதி விஜய் திரைப்படங்கள் எப்போதும் பிளாக்பஸ்டர் ஆகும்',
      englishSentence: 'Movies of Thalapathy Vijay and Ajith always become massive blockbusters',
      extraDistractors: 'are, win, make, is',
    ),
    AdminMarketingSentence(
      id: 'ta_2',
      language: 'ta',
      prompt: 'சென்னை மெரினா கடற்கரையில் மாலை நேரத்தில் சுண்டல் சாப்பிடுவது அலாதி இன்பம்',
      englishSentence: 'Eating hot sundal at Marina Beach in Chennai is delightful',
      extraDistractors: 'in, on, food, with',
    ),
    AdminMarketingSentence(
      id: 'ta_3',
      language: 'ta',
      prompt: 'சேப்பாக்கம் மைதானத்தில் தோனி அடித்த சிக்ஸர் ரசிகர்களை அதிர வைத்தது',
      englishSentence: 'MS Dhoni hit a sensational six at Chepauk stadium in Chennai',
      extraDistractors: 'did, on, stadium, play',
    ),
    AdminMarketingSentence(
      id: 'ta_4',
      language: 'ta',
      prompt: 'மதுரை மீனாட்சி அம்மன் கோவிலின் அழகும் ஜிகர்தண்டாவும் மிகவும் பிரபலம்',
      englishSentence: 'Madurai is world famous for Meenakshi temple and tasty jigarthanda',
      extraDistractors: 'in, with, sweet, are',
    ),
    AdminMarketingSentence(
      id: 'ta_5',
      language: 'ta',
      prompt: 'நீங்கள் புதிய ஐபோனை சென்னையில் எப்போது வாங்கினீர்கள்?',
      englishSentence: 'When did you purchase this new iPhone in Chennai?',
      extraDistractors: 'buy, from, are, take',
    ),
    AdminMarketingSentence(
      id: 'ta_6',
      language: 'ta',
      prompt: 'கோயம்புத்தூர் மக்கள் மிகவும் அன்பானவர்கள் மற்றும் உபசரிப்பு குணம் கொண்டவர்கள்',
      englishSentence: 'People of Coimbatore are extremely polite, hospitable, and friendly',
      extraDistractors: 'is, in, city, were',
    ),
    AdminMarketingSentence(
      id: 'ta_7',
      language: 'ta',
      prompt: 'ஊட்டி மலை ரயிலில் பயணம் செய்வது மறக்க முடியாத அனுபவமாகும்',
      englishSentence: 'Traveling on the Ooty heritage toy train is an unforgettable adventure',
      extraDistractors: 'go, trip, with, on',
    ),
    AdminMarketingSentence(
      id: 'ta_8',
      language: 'ta',
      prompt: 'சூப்பர் ஸ்டார் ரஜினிகாந்தின் ஸ்டைல் உலகெங்கும் உள்ள ரசிகர்களை கவர்ந்தது',
      englishSentence: 'Superstar Rajinikanth captivates audiences worldwide with his unique style',
      extraDistractors: 'is, on, movie, has',
    ),
    AdminMarketingSentence(
      id: 'ta_9',
      language: 'ta',
      prompt: 'திருநெல்வேலி இருட்டுக்கடை அல்வா வாங்க மக்கள் நீண்ட வரிசையில் நின்றனர்',
      englishSentence: 'People stood in a long queue to buy famous Tirunelveli halwa',
      extraDistractors: 'went, for, sweet, standing',
    ),
    AdminMarketingSentence(
      id: 'ta_10',
      language: 'ta',
      prompt: 'நாளை காலை நாங்கள் சென்னை சென்ட்ரல் ரயில் நிலையத்திற்கு செல்ல வேண்டும்',
      englishSentence: 'We must reach Chennai Central railway station early tomorrow morning',
      extraDistractors: 'go, will, to, arrived',
    ),
    AdminMarketingSentence(
      id: 'ta_11',
      language: 'ta',
      prompt: 'தினமும் ஆங்கிலத்தில் பேசினால் உங்கள் வேலை வாய்ப்பு நிச்சயம் உயரும்',
      englishSentence: 'Speaking English daily will guarantee excellent career advancement',
      extraDistractors: 'make, can, talk, rise',
    ),
    AdminMarketingSentence(
      id: 'ta_12',
      language: 'ta',
      prompt: 'பொங்கல் பண்டிகையை குடும்பத்துடன் கொண்டாடுவது மிகுந்த மகிழ்ச்சியை தருகிறது',
      englishSentence: 'Celebrating the Pongal festival with family brings tremendous joy',
      extraDistractors: 'is, in, happy, gave',
    ),
    AdminMarketingSentence(
      id: 'ta_13',
      language: 'ta',
      prompt: 'ராயல் என்ஃபீல்டு புல்லட் ஓட்டுவது பல இளைஞர்களின் மிகப்பெரிய கனவு',
      englishSentence: 'Riding a Royal Enfield motorcycle is a huge dream for youth',
      extraDistractors: 'ride, on, car, drive',
    ),
    AdminMarketingSentence(
      id: 'ta_14',
      language: 'ta',
      prompt: 'தமிழ்நாடு முழுவதும் உள்ள சுவையான பிரியாணி கடைகளை நீங்கள் பார்த்திருக்கிறீர்களா?',
      englishSentence: 'Have you explored the most delicious biryani restaurants across Tamil Nadu?',
      extraDistractors: 'did, eat, in, went',
    ),
    AdminMarketingSentence(
      id: 'ta_15',
      language: 'ta',
      prompt: 'கமல்ஹாசனின் நடிப்பு திறமை இந்திய சினிமா வரலாற்றில் மிக உயர்ந்தது',
      englishSentence: 'Kamal Haasan showcases peerless acting talent in Indian cinema history',
      extraDistractors: 'is, on, show, act',
    ),
    AdminMarketingSentence(
      id: 'ta_16',
      language: 'ta',
      prompt: 'பாக்கெட் மேட்ஸ் செயலி மூலம் உங்கள் ஆங்கில பேச்சாற்றலை வளர்த்துக் கொள்ளுங்கள்',
      englishSentence: 'Master spoken English effortlessly through the interactive Pocket Mates app',
      extraDistractors: 'learn, with, can, speaks',
    ),
    AdminMarketingSentence(
      id: 'ta_17',
      language: 'ta',
      prompt: 'மாலை நேரத்தில் சூடான பில்டர் காபி குடிப்பது மனதிற்கு புத்துணர்ச்சி தரும்',
      englishSentence: 'Drinking hot authentic South Indian filter coffee refreshes the mind',
      extraDistractors: 'drink, on, tea, takes',
    ),
    AdminMarketingSentence(
      id: 'ta_18',
      language: 'ta',
      prompt: 'பெங்களூரு நெடுஞ்சாலையில் செல்லும் போது கார் டயர் பஞ்சர் ஆகிவிட்டது',
      englishSentence: 'The car tire got punctured while driving along the highway',
      extraDistractors: 'was, on, broke, burst',
    ),
    AdminMarketingSentence(
      id: 'ta_19',
      language: 'ta',
      prompt: 'நீங்கள் உங்கள் கல்லூரி படிப்பை எப்போது வெற்றிகரமாக முடிப்பீர்கள்?',
      englishSentence: 'When will you complete your university engineering degree?',
      extraDistractors: 'did, finish, are, was',
    ),
    AdminMarketingSentence(
      id: 'ta_20',
      language: 'ta',
      prompt: 'பயத்தை விட்டு தைரியமாக ஆங்கிலத்தில் பேச இன்றே தொடங்குங்கள்',
      englishSentence: 'Overcome hesitation and begin speaking fluent English with complete confidence',
      extraDistractors: 'start, talk, now, can',
    ),

    // =========================================================================
    // 🇮🇳 HINDI (20 Viral Sentences: Mumbai, Delhi, Kohli, SRK, Manali)
    // =========================================================================
    AdminMarketingSentence(
      id: 'hi_1',
      language: 'hi',
      prompt: 'विराट कोहली ने पाकिस्तान के खिलाफ शानदार शतक बनाया',
      englishSentence: 'Virat Kohli scored a magnificent century against Pakistan',
      extraDistractors: 'hit, in, play, made',
    ),
    AdminMarketingSentence(
      id: 'hi_2',
      language: 'hi',
      prompt: 'मुंबई के मरीन ड्राइव पर शाम की ताज़ी हवा का मज़ा ही कुछ और है',
      englishSentence: 'The refreshing evening breeze at Marine Drive in Mumbai feels magical',
      extraDistractors: 'is, on, fresh, with',
    ),
    AdminMarketingSentence(
      id: 'hi_3',
      language: 'hi',
      prompt: 'शाहरुख खान का घर मन्नत देखने के लिए बांद्रा में भारी भीड़ जमा होती है',
      englishSentence: 'A huge crowd gathers in Bandra to see Shah Rukh Khan\'s mansion',
      extraDistractors: 'went, on, home, came',
    ),
    AdminMarketingSentence(
      id: 'hi_4',
      language: 'hi',
      prompt: 'क्या आपने दिल्ली के चांदनी चौक की मशहूर चाट और परांठे खाए हैं?',
      englishSentence: 'Have you tasted the delicious street food at Chandni Chowk in Delhi?',
      extraDistractors: 'did, eat, was, had',
    ),
    AdminMarketingSentence(
      id: 'hi_5',
      language: 'hi',
      prompt: 'बेंगलुरु के भारी ट्रैफिक की वजह से मेरी फ्लाइट छूटते-छूटते बची',
      englishSentence: 'I almost missed my flight due to terrible Bengaluru road traffic',
      extraDistractors: 'was, on, car, reach',
    ),
    AdminMarketingSentence(
      id: 'hi_6',
      language: 'hi',
      prompt: 'ताजमहल की ख़ूबसूरती देखने दुनिया भर से लाखों पर्यटक आगरा आते हैं',
      englishSentence: 'Millions of tourists visit Agra to admire the stunning Taj Mahal',
      extraDistractors: 'come, in, see, saw',
    ),
    AdminMarketingSentence(
      id: 'hi_7',
      language: 'hi',
      prompt: 'आजकल हर कोई नया आईफोन खरीदने के लिए उत्सुक रहता है',
      englishSentence: 'Nowadays everyone is extremely excited to purchase the latest iPhone',
      extraDistractors: 'buy, for, does, will',
    ),
    AdminMarketingSentence(
      id: 'hi_8',
      language: 'hi',
      prompt: 'रोहित शर्मा की कप्तानी में भारत ने टी-20 वर्ल्ड कप जीता',
      englishSentence: 'India won the historic T20 World Cup under Rohit Sharma\'s captaincy',
      extraDistractors: 'got, win, on, had',
    ),
    AdminMarketingSentence(
      id: 'hi_9',
      language: 'hi',
      prompt: 'गोवा के समुद्री तटों पर छुट्टियां बिताना सभी को बहुत पसंद आता है',
      englishSentence: 'Vacationing on the sunny beaches of Goa is loved by everyone',
      extraDistractors: 'enjoy, in, travel, likes',
    ),
    AdminMarketingSentence(
      id: 'hi_10',
      language: 'hi',
      prompt: 'अगर आप रोज़ अंग्रेजी बोलेंगे तो आपका आत्मविश्वास बहुत बढ़ जाएगा',
      englishSentence: 'Practicing spoken English every day will boost your overall confidence',
      extraDistractors: 'speak, can, make, grow',
    ),
    AdminMarketingSentence(
      id: 'hi_11',
      language: 'hi',
      prompt: 'जयपुर के ऐतिहासिक हवा महल और महलों का दृश्य बेहद मनमोहक है',
      englishSentence: 'The historic monuments and palaces of Jaipur look absolutely breathtaking',
      extraDistractors: 'are, in, show, looked',
    ),
    AdminMarketingSentence(
      id: 'hi_12',
      language: 'hi',
      prompt: 'सर्दियों की सुबह कुल्हड़ वाली गर्म चाय पीने का अपना ही आनंद है',
      englishSentence: 'Drinking hot spiced tea in clay cups on winter mornings is delightful',
      extraDistractors: 'have, on, cup, took',
    ),
    AdminMarketingSentence(
      id: 'hi_13',
      language: 'hi',
      prompt: 'क्या आप अगले महीने हमारे साथ मनाली की यात्रा पर चलेंगे?',
      englishSentence: 'Will you accompany us on an exciting road trip to Manali next month?',
      extraDistractors: 'come, go, did, can',
    ),
    AdminMarketingSentence(
      id: 'hi_14',
      language: 'hi',
      prompt: 'पॉकेट मेट्स ऐप के जरिए आप बिना किसी झिझक के फर्राटेदार अंग्रेजी सीख सकते हैं',
      englishSentence: 'You can learn fluent spoken English without hesitation using Pocket Mates',
      extraDistractors: 'speak, study, with, talking',
    ),
    AdminMarketingSentence(
      id: 'hi_15',
      language: 'hi',
      prompt: 'महेंद्र सिंह धोनी का हेलीकॉप्टर शॉट क्रिकेट इतिहास में हमेशा अमर रहेगा',
      englishSentence: 'MS Dhoni\'s iconic helicopter shot will remain legendary in cricket history',
      extraDistractors: 'is, on, play, hit',
    ),
    AdminMarketingSentence(
      id: 'hi_16',
      language: 'hi',
      prompt: 'लुलु मॉल में सप्ताहांत पर खरीदारी करने के लिए हज़ारों लोग आते हैं',
      englishSentence: 'Thousands of excited shoppers visit Lulu Mall during the weekend',
      extraDistractors: 'go, on, come, shop',
    ),
    AdminMarketingSentence(
      id: 'hi_17',
      language: 'hi',
      prompt: 'क्या आपने आज के अख़बार में छपी ताज़ा खबर पढ़ी है?',
      englishSentence: 'Did you read the shocking breaking news published in today\'s newspaper?',
      extraDistractors: 'see, is, on, read',
    ),
    AdminMarketingSentence(
      id: 'hi_18',
      language: 'hi',
      prompt: 'उसने अपनी पहली तनख्वाह से अपने माता-पिता के लिए उपहार खरीदे',
      englishSentence: 'He bought wonderful surprise gifts for his parents using his first salary',
      extraDistractors: 'buy, with, did, get',
    ),
    AdminMarketingSentence(
      id: 'hi_19',
      language: 'hi',
      prompt: 'कड़ी मेहनत और निरंतर अभ्यास के बिना सफलता हासिल करना असंभव है',
      englishSentence: 'Achieving massive success is impossible without consistent hard work',
      extraDistractors: 'win, on, make, does',
    ),
    AdminMarketingSentence(
      id: 'hi_20',
      language: 'hi',
      prompt: 'आज शाम को हम सब मिलकर एक नई एक्शन फिल्म देखने जा रहे हैं',
      englishSentence: 'We are all going to watch an exciting new blockbuster movie tonight',
      extraDistractors: 'see, will, go, saw',
    ),

    // =========================================================================
    // 🌸 KANNADA (15 Viral Sentences: Bengaluru, Yash, RCB, Mysuru)
    // =========================================================================
    AdminMarketingSentence(
      id: 'kn_1',
      language: 'kn',
      prompt: 'ಬೆಂಗಳೂರಿನ ಕಬ್ಬನ್ ಪಾರ್ಕ್ ನಲ್ಲಿ ಬೆಳಗಿನ ವಾಕಿಂಗ್ ಮಾಡುವುದು ಮನಸ್ಸಿಗೆ ಉಲ್ಲಾಸ ನೀಡುತ್ತದೆ',
      englishSentence: 'A morning walk in Bengaluru Cubbon Park refreshes the soul',
      extraDistractors: 'is, on, walk, goes',
    ),
    AdminMarketingSentence(
      id: 'kn_2',
      language: 'kn',
      prompt: 'ರಾಕಿಂಗ್ ಸ್ಟಾರ್ ಯಶ್ ಅವರ ಕೆಜಿಎಫ್ ಸಿನಿಮಾ ಭಾರತೀಯ ಚಿತ್ರರಂಗದ ದಾಖಲೆ ಮುರಿದಿದೆ',
      englishSentence: 'Rocking Star Yash shattered Indian cinema records with the blockbuster KGF',
      extraDistractors: 'broke, on, movie, made',
    ),
    AdminMarketingSentence(
      id: 'kn_3',
      language: 'kn',
      prompt: 'ರಾಯಲ್ ಚಾಲೆಂಜರ್ಸ್ ಬೆಂಗಳೂರು ತಂಡಕ್ಕೆ ಕರ್ನಾಟಕದಲ್ಲಿ ಅಪಾರ ಅಭಿಮಾನಿಗಳಿದ್ದಾರೆ',
      englishSentence: 'Royal Challengers Bangalore commands an incredibly passionate fan following',
      extraDistractors: 'has, on, team, are',
    ),
    AdminMarketingSentence(
      id: 'kn_4',
      language: 'kn',
      prompt: 'ಮೈಸೂರು ದಸರಾ ಹಬ್ಬದ ಸಮಯದಲ್ಲಿ ಮೈಸೂರು ಅರಮನೆ ದೀಪಾಲಂಕಾರದಿಂದ ಕಂಗೊಳಿಸುತ್ತದೆ',
      englishSentence: 'Mysore Palace illuminates brilliantly with dazzling lights during Dasara festival',
      extraDistractors: 'looks, in, light, shine',
    ),
    AdminMarketingSentence(
      id: 'kn_5',
      language: 'kn',
      prompt: 'ನೀವು ಬೆಂಗಳೂರಿನ ಪ್ರಸಿದ್ಧ ಮಸಾಲೆ ದೋಸೆ ಮತ್ತು ಫಿಲ್ಟರ್ ಕಾಫಿ ಸವಿದಿದ್ದೀರಾ?',
      englishSentence: 'Have you tasted the legendary crispy masala dosa in Bengaluru?',
      extraDistractors: 'did, eat, with, had',
    ),
    AdminMarketingSentence(
      id: 'kn_6',
      language: 'kn',
      prompt: 'ಹಂಪಿಯ ಐತಿಹಾಸಿಕ ಶಿಲ್ಪಕಲೆಗಳು ಮತ್ತು ಕಲ್ಲಿನ ರಥ ವಿಶ್ವಪ್ರಸಿದ್ಧವಾಗಿದೆ',
      englishSentence: 'The magnificent stone chariot in Hampi is a world heritage monument',
      extraDistractors: 'is, on, place, was',
    ),
    AdminMarketingSentence(
      id: 'kn_7',
      language: 'kn',
      prompt: 'ನೀವು ಯಾವಾಗ ಹೊಸ ಐಫೋನ್ ಖರೀದಿಸಲು ದುಬೈಗೆ ಹೋಗುತ್ತಿದ್ದೀರಿ?',
      englishSentence: 'When are you planning to travel to Dubai to buy an iPhone?',
      extraDistractors: 'did, go, buy, will',
    ),
    AdminMarketingSentence(
      id: 'kn_8',
      language: 'kn',
      prompt: 'ಮಂಗಳೂರಿನ ಸಮುದ್ರ ತೀರ ಮತ್ತು ರುಚಿಕರವಾದ ಮೀನಿನ ಊಟ ಬಹಳ ಪ್ರಸಿದ್ಧ',
      englishSentence: 'Mangalore coastal beaches and seafood delicacies are famous throughout Karnataka',
      extraDistractors: 'is, in, food, was',
    ),
    AdminMarketingSentence(
      id: 'kn_9',
      language: 'kn',
      prompt: 'ದಿನವೂ ಇಂಗ್ಲಿಷ್ ನಲ್ಲಿ ಮಾತನಾಡಿದರೆ ನಿಮ್ಮ ಸಂವಹನ ಕೌಶಲ್ಯ ಸುಧಾರಿಸುತ್ತದೆ',
      englishSentence: 'Speaking English daily will greatly accelerate your global communication skills',
      extraDistractors: 'can, learn, make, boost',
    ),
    AdminMarketingSentence(
      id: 'kn_10',
      language: 'kn',
      prompt: 'ಪೊಕೆಟ್ ಮೇಟ್ಸ್ ಆ್ಯಪ್ ಬಳಸಿ ಆತ್ಮವಿಶ್ವಾಸದಿಂದ ಇಂಗ್ಲಿಷ್ ಮಾತನಾಡಲು ಕಲಿಯಿರಿ',
      englishSentence: 'Learn spoken English fluently with unwavering confidence using Pocket Mates',
      extraDistractors: 'speak, with, can, talked',
    ),
    AdminMarketingSentence(
      id: 'kn_11',
      language: 'kn',
      prompt: 'ನಾಳೆ ಸಂಜೆ ನಾವು ಮೆಟ್ರೋ ರೈಲಿನಲ್ಲಿ ನಮ್ಮ ಸ್ನೇಹಿತರೊಂದಿಗೆ ಪ್ರಯಾಣಿಸುತ್ತೇವೆ',
      englishSentence: 'We will commute comfortably across the city on Namma Metro tomorrow',
      extraDistractors: 'go, on, travel, ride',
    ),
    AdminMarketingSentence(
      id: 'kn_12',
      language: 'kn',
      prompt: 'ಕ್ರಿಸ್ಟಿಯಾನೋ ರೊನಾಲ್ಡೊ ವಿಶ್ವದ ಅತ್ಯಂತ ಯಶಸ್ವಿ ಫುಟ್‌ಬಾಲ್ ಆಟಗಾರರಲ್ಲಿ ಒಬ್ಬರು',
      englishSentence: 'Cristiano Ronaldo stands among the most celebrated athletic legends globally',
      extraDistractors: 'is, on, player, was',
    ),
    AdminMarketingSentence(
      id: 'kn_13',
      language: 'kn',
      prompt: 'ನಿಮ್ಮ ಕನಸಿನ ಗುರಿಯನ್ನು ತಲುಪಲು ಪ್ರತಿದಿನ ನಿರಂತರ ಪರಿಶ್ರಮ ಅತ್ಯಗತ್ಯ',
      englishSentence: 'Relentless daily perseverance is essential to achieve your lifelong aspirations',
      extraDistractors: 'need, to, win, make',
    ),
    AdminMarketingSentence(
      id: 'kn_14',
      language: 'kn',
      prompt: 'ವಿರಾಟ್ ಕೊಹ್ಲಿ ಚಿನ್ನಸ್ವಾಮಿ ಕ್ರೀಡಾಂಗಣದಲ್ಲಿ ಬ್ಯಾಟಿಂಗ್ ಮಾಡುವಾಗ ಕ್ರೀಡಾಂಗಣವೇ ಸಂಭ್ರಮಿಸುತ್ತದೆ',
      englishSentence: 'The entire stadium erupts in cheers when Virat Kohli bats at Chinnaswamy',
      extraDistractors: 'is, on, play, hit',
    ),
    AdminMarketingSentence(
      id: 'kn_15',
      language: 'kn',
      prompt: 'ಇಂದಿನಿಂದಲೇ ಧೈರ್ಯವಾಗಿ ಇಂಗ್ಲಿಷ್ ಮಾತನಾಡಲು ಪ್ರಾರಂಭಿಸಿ ಮತ್ತು ಮುನ್ನಡೆಯಿರಿ',
      englishSentence: 'Begin speaking English boldly from today and unlock extraordinary opportunities',
      extraDistractors: 'start, talk, now, will',
    ),
  ];

  static Future<List<AdminMarketingSentence>> getSentences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        final list = decoded
            .map((e) =>
                AdminMarketingSentence.fromJson(Map<String, dynamic>.from(e)))
            .where((s) =>
                s.prompt.trim().isNotEmpty &&
                s.englishSentence.trim().isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[MarketingRepo] Error loading sentences: $e');
    }
    // Fallback to default viral sentences and save
    await saveSentences(defaultSentences);
    return List.from(defaultSentences);
  }

  static Future<void> saveSentences(
      List<AdminMarketingSentence> sentences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(sentences.map((e) => e.toJson()).toList());
      await prefs.setString(_kStorageKey, data);
    } catch (e) {
      debugPrint('[MarketingRepo] Error saving sentences: $e');
    }
  }

  static Future<void> addSentence(AdminMarketingSentence sentence) async {
    final list = await getSentences();
    list.add(sentence);
    await saveSentences(list);
  }

  static Future<void> updateSentence(AdminMarketingSentence sentence) async {
    final list = await getSentences();
    final idx = list.indexWhere((e) => e.id == sentence.id);
    if (idx >= 0) {
      list[idx] = sentence;
      await saveSentences(list);
    }
  }

  static Future<void> deleteSentence(String id) async {
    final list = await getSentences();
    list.removeWhere((e) => e.id == id);
    await saveSentences(list);
  }

  static Future<void> resetToDefaults() async {
    await saveSentences(defaultSentences);
  }
}

/// 🎬 Admin Tab View: Sentence Builder Marketing Studio
class AdminSentenceMarketingStudioTab extends StatefulWidget {
  const AdminSentenceMarketingStudioTab({super.key});

  @override
  State<AdminSentenceMarketingStudioTab> createState() =>
      _AdminSentenceMarketingStudioTabState();
}

class _AdminSentenceMarketingStudioTabState
    extends State<AdminSentenceMarketingStudioTab> {
  List<AdminMarketingSentence> _sentences = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLanguage = 'ml'; // 'ml', 'ta', 'hi', 'kn', 'all'
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> _languageTabs = [
    {'code': 'ml', 'label': 'Malayalam 🌴'},
    {'code': 'ta', 'label': 'Tamil 🛕'},
    {'code': 'hi', 'label': 'Hindi 🇮🇳'},
    {'code': 'kn', 'label': 'Kannada 🌸'},
    {'code': 'all', 'label': 'All 🌐'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await AdminMarketingSentenceRepository.getSentences();
    if (mounted) {
      setState(() {
        _sentences = data;
        _isLoading = false;
      });
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ml':
        return 'Malayalam';
      case 'ta':
        return 'Tamil';
      case 'hi':
        return 'Hindi';
      case 'kn':
        return 'Kannada';
      default:
        return 'All';
    }
  }

  void _showAddEditDialog({AdminMarketingSentence? existing}) {
    final isEdit = existing != null;
    String dialogLanguage =
        existing?.language ?? (_selectedLanguage != 'all' ? _selectedLanguage : 'ml');
    final promptCtrl = TextEditingController(text: existing?.prompt ?? '');
    final englishCtrl =
        TextEditingController(text: existing?.englishSentence ?? '');
    final distractorsCtrl =
        TextEditingController(text: existing?.extraDistractors ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.movie_creation_rounded,
                  color: Color(0xFFFFD700), size: 22),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Edit Marketing Sentence' : 'Add Marketing Sentence',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARGET LANGUAGE',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    {'code': 'ml', 'label': 'Malayalam 🌴'},
                    {'code': 'ta', 'label': 'Tamil 🛕'},
                    {'code': 'hi', 'label': 'Hindi 🇮🇳'},
                    {'code': 'kn', 'label': 'Kannada 🌸'},
                  ].map((lang) {
                    final isSel = dialogLanguage == lang['code'];
                    return ChoiceChip(
                      selected: isSel,
                      label: Text(
                        lang['label']!,
                        style: GoogleFonts.outfit(
                          color: isSel ? Colors.black : Colors.white70,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selectedColor: const Color(0xFFFFD700),
                      backgroundColor: const Color(0xFF0F172A),
                      onSelected: (val) {
                        if (val) {
                          setDialogState(() {
                            dialogLanguage = lang['code']!;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'NATIVE PROMPT / MEANING (Top Bar)',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: promptCtrl,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. ഞാൻ ഇന്നലെ പുതിയ ഐഫോൺ വാങ്ങി',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CORRECT ENGLISH SENTENCE (Target)',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: englishCtrl,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Did you buy the new iPhone from Dubai yesterday?',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'EXTRA DISTRACTOR WORDS (Optional, comma-separated)',
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: distractorsCtrl,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. bought, in, tomorrow',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final prompt = promptCtrl.text.trim();
                final english = englishCtrl.text.trim();
                if (prompt.isEmpty || english.isEmpty) return;

                Navigator.pop(ctx);
                if (isEdit) {
                  await AdminMarketingSentenceRepository.updateSentence(
                    existing.copyWith(
                      language: dialogLanguage,
                      prompt: prompt,
                      englishSentence: english,
                      extraDistractors: distractorsCtrl.text.trim(),
                    ),
                  );
                } else {
                  await AdminMarketingSentenceRepository.addSentence(
                    AdminMarketingSentence(
                      id: '${dialogLanguage}_${DateTime.now().millisecondsSinceEpoch}',
                      language: dialogLanguage,
                      prompt: prompt,
                      englishSentence: english,
                      extraDistractors: distractorsCtrl.text.trim(),
                    ),
                  );
                }
                _loadData();
              },
              child: Text(
                isEdit ? 'Update' : 'Add',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(AdminMarketingSentence s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Sentence?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${s.prompt}"?',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminMarketingSentenceRepository.deleteSentence(s.id);
      _loadData();
    }
  }

  void _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset to Default Sentences?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will restore all 85 viral marketing sentences across Malayalam (30), Tamil (20), Hindi (20), and Kannada (15).',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminMarketingSentenceRepository.resetToDefaults();
      _loadData();
    }
  }

  void _copyToClipboard(AdminMarketingSentence item) {
    Clipboard.setData(
        ClipboardData(text: '${item.prompt}\n${item.englishSentence}'));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF00E5FF), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Copied: "${item.englishSentence}"',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startSimulator(
      {List<AdminMarketingSentence>? sentencesToUse, int initialIndex = 0}) {
    final list = (sentencesToUse != null && sentencesToUse.isNotEmpty)
        ? sentencesToUse
        : _sentences;

    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one sentence for this language first!',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSentenceBuilderSimulatorPage(
          sentences: list,
          initialIndex: initialIndex.clamp(0, list.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    final q = _searchQuery.toLowerCase();
    final filtered = _sentences.where((s) {
      if (_selectedLanguage != 'all' && s.language != _selectedLanguage) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.prompt.toLowerCase().contains(q) ||
          s.englishSentence.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Column(
        children: [
          // Top Control Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.movie_creation_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sentence Builder Studio',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Viral Reels & YouTube Shorts recording engine (Multi-Language)',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_sentences.length} Total',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Add Sentence',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () => _showAddEditDialog(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: Text(
                        'Reset (${AdminMarketingSentenceRepository.defaultSentences.length})',
                        style: GoogleFonts.outfit(fontSize: 12.5),
                      ),
                      onPressed: _handleReset,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🌐 LANGUAGE TABS (Right Above Search Bar)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _languageTabs.map((tab) {
                  final code = tab['code']!;
                  final label = tab['label']!;
                  final isSelected = _selectedLanguage == code;
                  final count = code == 'all'
                      ? _sentences.length
                      : _sentences.where((s) => s.language == code).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedLanguage = code;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : Colors.white12,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.outfit(
                                  color:
                                      isSelected ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText:
                    'Search ${_getLanguageName(_selectedLanguage)} sentences...',
                hintStyle:
                    GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFFFFD700)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Sentence List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No sentences matching "$_searchQuery"'
                          : 'No ${_getLanguageName(_selectedLanguage)} sentences added yet',
                      style: GoogleFonts.outfit(
                          color: Colors.white54, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final words = item.englishSentence.split(' ');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2129),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E5FF)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.language.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF00E5FF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.prompt,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.englishSentence,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.extraDistractors.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Distractors: ${item.extraDistractors}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${words.length} words',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                // Play in Simulator
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Color(0xFF22C55E),
                                    size: 26,
                                  ),
                                  tooltip: 'Simulate this sentence',
                                  onPressed: () => _startSimulator(
                                    sentencesToUse: filtered,
                                    initialIndex: filtered.indexOf(item),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 📋 Copy Text Button (as requested)
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded,
                                          size: 16, color: Color(0xFF38BDF8)),
                                      tooltip: 'Copy text to clipboard',
                                      onPressed: () => _copyToClipboard(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded,
                                          size: 16, color: Colors.white60),
                                      onPressed: () =>
                                          _showAddEditDialog(existing: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16, color: Colors.redAccent),
                                      onPressed: () => _handleDelete(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.rocket_launch_rounded, size: 20),
            label: Text(
              _selectedLanguage == 'all'
                  ? '🚀 Launch All Sentences (${filtered.length})'
                  : '🚀 Launch ${_getLanguageName(_selectedLanguage)} Simulator (${filtered.length})',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            onPressed: () => _startSimulator(
              sentencesToUse: filtered,
              initialIndex: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎮 Exact Clone Replica of the Sentence Builder Game for Screen Recording & Reels
class AdminSentenceBuilderSimulatorPage extends StatefulWidget {
  final List<AdminMarketingSentence> sentences;
  final int initialIndex;

  const AdminSentenceBuilderSimulatorPage({
    super.key,
    required this.sentences,
    this.initialIndex = 0,
  });

  @override
  State<AdminSentenceBuilderSimulatorPage> createState() =>
      _AdminSentenceBuilderSimulatorPageState();
}

class _AdminSentenceBuilderSimulatorPageState
    extends State<AdminSentenceBuilderSimulatorPage>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late int _currentIndex;
  bool _isRoundCompleted = false;
  bool _isSpeaking = false;

  final List<_SimTile> _placedTiles = [];
  final List<_SimTile> _remainingTiles = [];

  String? _shakingTileId;
  late AnimationController _shakeAnimController;

  static const List<Color> _tileColors = [
    Color(0xFFE91E63), // Vibrant Pink / Magenta
    Color(0xFF00E676), // Vibrant Green
    Color(0xFF00E5FF), // Vibrant Sky Cyan
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initTts();
    _loadRound(_currentIndex);
  }

  @override
  void dispose() {
    _shakeAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.05);
      await PocketVoiceService.instance
          .configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  void _loadRound(int index) {
    if (index < 0 || index >= widget.sentences.length) return;

    final currentSentence = widget.sentences[index];
    final targetWords = currentSentence.englishSentence
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final List<_SimTile> allTiles = [];

    // Add target words with assigned vibrant colors
    for (int i = 0; i < targetWords.length; i++) {
      allTiles.add(
        _SimTile(
          id: 'target_${index}_${i}_${targetWords[i]}',
          word: targetWords[i],
          color: _tileColors[i % _tileColors.length],
        ),
      );
    }

    // Add distractors if provided
    List<String> distractors = [];
    if (currentSentence.extraDistractors.isNotEmpty) {
      distractors = currentSentence.extraDistractors
          .split(',')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();
    }

    for (int d = 0; d < distractors.length; d++) {
      allTiles.add(
        _SimTile(
          id: 'distractor_${index}_${d}_${distractors[d]}',
          word: distractors[d],
          color: _tileColors[(targetWords.length + d) % _tileColors.length],
        ),
      );
    }

    // Shuffle tiles into bottom word bank
    allTiles.shuffle(math.Random());

    setState(() {
      _currentIndex = index;
      _placedTiles.clear();
      _remainingTiles.clear();
      _remainingTiles.addAll(allTiles);
      _isRoundCompleted = false;
      _shakingTileId = null;
    });
  }

  Future<void> _speakText(String text) async {
    try {
      if (mounted) setState(() => _isSpeaking = true);
      await _flutterTts.stop();
      await _flutterTts.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _onTileTapped(_SimTile tile) {
    if (_isRoundCompleted) return;

    final targetWords = widget.sentences[_currentIndex].englishSentence
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final nextExpectedIndex = _placedTiles.length;
    if (nextExpectedIndex >= targetWords.length) return;

    final expectedWord = targetWords[nextExpectedIndex];

    // Case-insensitive clean comparison
    final cleanTileWord =
        tile.word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    final cleanExpectedWord =
        expectedWord.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

    if (cleanTileWord == cleanExpectedWord) {
      // ✅ CORRECT TILE!
      PocketGameSfx.instance.playSnapCorrect();
      HapticFeedback.lightImpact();

      setState(() {
        _remainingTiles.removeWhere((t) => t.id == tile.id);
        _placedTiles.add(tile);
      });

      _speakText(tile.word);

      // Check if entire sentence is completed
      if (_placedTiles.length == targetWords.length) {
        _onRoundCompleted();
      }
    } else {
      // ❌ WRONG TILE!
      PocketGameSfx.instance.playErrorBuzz();
      HapticFeedback.heavyImpact(); // Strong error vibration

      setState(() {
        _shakingTileId = tile.id;
      });

      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _shakingTileId = null;
          });
        }
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Try another word to begin or continue the sentence!',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _onPlacedTileTapped(_SimTile tile) {
    if (_isRoundCompleted) return;
    PocketGameSfx.instance.playTilePop();
    HapticFeedback.selectionClick();
    setState(() {
      _placedTiles.removeWhere((t) => t.id == tile.id);
      _remainingTiles.add(tile);
    });
  }

  void _onRoundCompleted() {
    setState(() {
      _isRoundCompleted = true;
    });

    PocketGameSfx.instance.playVictory();
    HapticFeedback.mediumImpact();

    final fullSentence = widget.sentences[_currentIndex].englishSentence;
    _speakText(fullSentence);
  }

  void _nextSentence() {
    if (_currentIndex < widget.sentences.length - 1) {
      _loadRound(_currentIndex + 1);
    } else {
      _loadRound(0); // Loop back
    }
  }

  void _prevSentence() {
    if (_currentIndex > 0) {
      _loadRound(_currentIndex - 1);
    }
  }

  void _restartCurrentSentence() {
    _loadRound(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentSentence = widget.sentences[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF250529),
      body: Stack(
        children: [
          // 1. Authentic deep magenta/plum gradient identical to Sentence Builder Game
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A0E4E), // Top rich plum / magenta
                    Color(0xFF3A083C),
                    Color(0xFF250529), // Deep shadow plum
                    Color(0xFF16031B), // Bottom dark
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Main Gameplay Layout
          SafeArea(
            child: Column(
              children: [
                // Top Header with Close, Progress Dots, Navigation & Restart
                _buildTopHeader(),

                const SizedBox(height: 6),

                // TOP AREA: Sentence Assembly Board with Native Prompt
                Expanded(
                  flex: 5,
                  child: _buildTopAssemblyBoard(currentSentence),
                ),

                // Center Divider Line identical to PocketSentenceBuilderGamePage
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                // BOTTOM AREA: Word Bank with Scrambled Tiles
                Expanded(
                  flex: 6,
                  child: _buildBottomWordBank(),
                ),

                // Bottom Completed Sentence Bar / Next Button
                if (_isRoundCompleted) _buildCompletionFooter(currentSentence),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top Status Bar matching game design with admin controls for recording
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button ✕
          IconButton(
            onPressed: () {
              PocketGameSfx.instance.playClick();
              Navigator.pop(context);
            },
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 36),
          ),

          // Title + Progress Indicator Dots
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SENTENCE BUILDER 🧩',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  math.min(widget.sentences.length, 12),
                  (idx) {
                    final isDone = idx < _currentIndex;
                    final isCurrent = idx == _currentIndex;
                    return Row(
                      children: [
                        Container(
                          width: isCurrent ? 14 : 10,
                          height: isCurrent ? 14 : 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone || isCurrent
                                ? const Color(0xFF00E5FF)
                                : Colors.white24,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        if (idx < math.min(widget.sentences.length, 12) - 1)
                          Container(
                            width: 6,
                            height: 2,
                            color: isDone
                                ? const Color(0xFF00E5FF)
                                : Colors.white24,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Action controls: Restart + Navigation
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Restart Sentence',
                onPressed: _restartCurrentSentence,
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Color(0xFFFFD700), size: 20),
                ),
              ),
              IconButton(
                tooltip: 'Next Sentence',
                onPressed: _nextSentence,
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.skip_next_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Top assembly drop board where correct words sit in neat sentence order
  Widget _buildTopAssemblyBoard(AdminMarketingSentence sentence) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 Prominent Native Prompt Challenge Banner
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38083E), Color(0xFF580C62)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎯 ', style: TextStyle(fontSize: 16)),
                    Flexible(
                      child: Text(
                        sentence.prompt,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Dropped Sentence Word Tiles
              Wrap(
                spacing: 12,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _placedTiles.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white24,
                                style: BorderStyle.solid),
                          ),
                          child: Text(
                            'Tap the word tiles below in order',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ]
                    : _placedTiles.map((tile) {
                        return GestureDetector(
                          onTap: () => _onPlacedTileTapped(tile),
                          child: _buildTileWidget(
                            tile: tile,
                            isPlaced: true,
                            isShaking: false,
                          ),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom word bank where scrambled tiles are displayed
  Widget _buildBottomWordBank() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 14,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _remainingTiles.map((tile) {
              final isShaking = _shakingTileId == tile.id;

              return GestureDetector(
                onTap: () => _onTileTapped(tile),
                child: _buildTileWidget(
                  tile: tile,
                  isPlaced: false,
                  isShaking: isShaking,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Reusable Tile Widget styled precisely like screenshots and Flame game
  Widget _buildTileWidget({
    required _SimTile tile,
    required bool isPlaced,
    required bool isShaking,
  }) {
    Widget tileBox = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(
        horizontal: tile.word.length == 1 ? 16 : 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: tile.color,
        borderRadius: BorderRadius.circular(10),
        border: isShaking
            ? Border.all(color: Colors.redAccent, width: 2.5)
            : null,
        boxShadow: [
          // Pronounced drop shadow matching screenshots
          BoxShadow(
            color: Colors.black.withValues(alpha: isPlaced ? 0.45 : 0.6),
            blurRadius: isPlaced ? 10 : 14,
            offset: Offset(isPlaced ? 2 : 4, isPlaced ? 4 : 8),
          ),
        ],
      ),
      child: Text(
        tile.word,
        style: GoogleFonts.outfit(
          color: tile.textColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );

    // Apply shake animation if wrong tile was tapped
    if (isShaking) {
      return AnimatedBuilder(
        animation: _shakeAnimController,
        builder: (context, child) {
          final offset =
              math.sin(_shakeAnimController.value * math.pi * 5) * 8.0;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: tileBox,
      );
    }

    return tileBox;
  }

  /// Completion footer with translation and Next button
  Widget _buildCompletionFooter(AdminMarketingSentence sentence) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16031B),
        border: const Border(
          top: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Audio speaker button
          IconButton(
            onPressed: () => _speakText(sentence.englishSentence),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSpeaking
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFF38083E),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color: _isSpeaking ? Colors.black : const Color(0xFF00E5FF),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Meaning and english text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sentence.englishSentence,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sentence.prompt,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Next Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: _nextSentence,
            child: Text(
              'NEXT SENTENCE ➔',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimTile {
  final String id;
  final String word;
  final Color color;

  _SimTile({
    required this.id,
    required this.word,
    required this.color,
  });

  Color get textColor => Colors.white;
}
