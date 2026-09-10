import 'package:flutter/foundation.dart';

/// 📘 Multilingual Vocabulary Item for Pocket Open World
class OpenWorldVocabItem {
  final String word;
  final String phonetics;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningMl; // Malayalam
  final String meaningTa; // Tamil
  final String meaningHi; // Hindi
  final String meaningTe; // Telugu
  final String exampleEn;
  final String category;

  const OpenWorldVocabItem({
    required this.word,
    required this.phonetics,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningMl,
    required this.meaningTa,
    required this.meaningHi,
    required this.meaningTe,
    required this.exampleEn,
    this.category = 'CORE',
  });

  String getMeaning(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'malayalam':
      case 'ml':
        return meaningMl;
      case 'tamil':
      case 'ta':
        return meaningTa;
      case 'hindi':
      case 'hi':
        return meaningHi;
      case 'telugu':
      case 'te':
        return meaningTe;
      case 'english':
      case 'en':
      default:
        return meaningEn;
    }
  }

  static String getLanguageFlag(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'malayalam':
      case 'ml':
        return '🌴';
      case 'tamil':
      case 'ta':
        return '🦚';
      case 'hindi':
      case 'hi':
        return '🇮🇳';
      case 'telugu':
      case 'te':
        return '🌺';
      case 'english':
      case 'en':
      default:
        return '🌐';
    }
  }

  static String getLanguageLabel(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'malayalam':
      case 'ml':
        return 'മലയാളം';
      case 'tamil':
      case 'ta':
        return 'தமிழ்';
      case 'hindi':
      case 'hi':
        return 'हिन्दी';
      case 'telugu':
      case 'te':
        return 'తెలుగు';
      case 'english':
      case 'en':
      default:
        return 'English';
    }
  }

  static String getLanguageShortCode(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'malayalam':
      case 'ml':
        return 'ML';
      case 'tamil':
      case 'ta':
        return 'TA';
      case 'hindi':
      case 'hi':
        return 'HI';
      case 'telugu':
      case 'te':
        return 'TE';
      case 'english':
      case 'en':
      default:
        return 'EN';
    }
  }
}

/// 📚 35+ Curated High-Yield Words with Multi-Language Translations
const List<OpenWorldVocabItem> kOpenWorldVocabBank = [
  OpenWorldVocabItem(
    word: 'RESILIENT',
    phonetics: '/rɪˈzɪl.i.ənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Able to withstand or recover quickly from difficult conditions.',
    meaningMl: 'പ്രതിസന്ധികളിൽ തളരാതെ വേഗത്തിൽ തിരിച്ചുവരാൻ കഴിവുള്ള.',
    meaningTa: 'துன்பங்களிலிருந்து விரைவாக மீண்டு வரும் திறன் கொண்ட.',
    meaningHi: 'कठिनाइयों से शीघ्र उबरने में सक्षम, लचीला।',
    meaningTe: 'కష్టాల నుండి త్వరగా కోలుకోగల మనోధైర్యం గల.',
    exampleEn: 'Resilient minds turn every stumble into a step forward.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'COURAGE',
    phonetics: '/ˈkʌr.ɪdʒ/',
    partOfSpeech: 'Noun',
    meaningEn: 'The ability to do something that frightens one; bravery.',
    meaningMl: 'ഭയത്തെയും വെല്ലുവിളികളെയും നേരിടാനുള്ള മനക്കരുത്ത്, ധൈര്യം.',
    meaningTa: 'அச்சத்தை துணிவுடன் எதிர்கொள்ளும் மனோபலம்.',
    meaningHi: 'भय और चुनौतियों का सामना करने का अदम्य साहस।',
    meaningTe: 'భయాన్ని ఎదిరించే అసలైన మనోధైర్యం.',
    exampleEn: 'It takes courage to speak in a new language daily.',
    category: 'STRENGTH',
  ),
  OpenWorldVocabItem(
    word: 'ELOQUENT',
    phonetics: '/ˈel.ə.kwənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Fluent or persuasive in speaking or expressing ideas.',
    meaningMl: 'വ്യക്തതയോടും ആകർഷകമായും സംസാരിക്കാനുള്ള വാഗ്‌വിലാസം.',
    meaningTa: 'தெளிவாகவும் கவரும் வகையிலும் பேசும் சொல்வளம்.',
    meaningHi: 'प्रभावशाली एवं ओजस्वी रूप से बोलने की कला।',
    meaningTe: 'ఆకట్టుకునేలా అనర్గళంగా మాట్లాడే ప్రావీణ్యం.',
    exampleEn: 'Her eloquent speech captivated the entire audience.',
    category: 'SPEECH',
  ),
  OpenWorldVocabItem(
    word: 'PERSISTENCE',
    phonetics: '/pəˈsɪs.təns/',
    partOfSpeech: 'Noun',
    meaningEn: 'Continuing firmly in a course of action despite obstacles.',
    meaningMl: 'തടസ്സങ്ങൾ മറികടന്ന് ലക്ഷ്യത്തിലേക്ക് മുന്നേറുന്ന ദൃഢനിശ്ചയം.',
    meaningTa: 'தடைகளை மீறி விடாமுயற்சியுடன் முன்னேறும் குணம்.',
    meaningHi: 'कठिनाइयों के बावजूद लक्ष्य की ओर निरंतर प्रयास।',
    meaningTe: 'ఆటంకాలు వచ్చినా వెనకడుగు వేయని పట్టుదల.',
    exampleEn: 'Persistence is the golden key to true fluency.',
    category: 'HABIT',
  ),
  OpenWorldVocabItem(
    word: 'SERENE',
    phonetics: '/səˈriːn/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Calm, peaceful, and untroubled by stress.',
    meaningMl: 'ശാന്തവും ആശങ്കകളില്ലാത്തതുമായ പ്രശാന്തത.',
    meaningTa: 'அமைதியான, தெளிவான மற்றும் சலனமற்ற நிலை.',
    meaningHi: 'शांत, निर्मल और चिंतामुक्त मानसिक अवस्था।',
    meaningTe: 'ప్రశాంతమైన మరియు కలతలేని నిశ్చల స్థితి.',
    exampleEn: 'The sea bridge offered a serene and inspiring view.',
    category: 'PEACE',
  ),
  OpenWorldVocabItem(
    word: 'EXPEDITION',
    phonetics: '/ˌek.spəˈdɪʃ.ən/',
    partOfSpeech: 'Noun',
    meaningEn: 'A focused journey with a definite purpose or exploration.',
    meaningMl: 'നിർദ്ദിഷ്ട ലക്ഷ്യത്തോടുകൂടിയ സാഹസിക പര്യവേഷണ യാത്ര.',
    meaningTa: 'குறிக்கோளுடன் மேற்கொள்ளப்படும் தேடல் பயணம்.',
    meaningHi: 'एक निश्चित उद्देश्य के लिए की जाने वाली साहसिक यात्रा।',
    meaningTe: 'లక్ష్య సాధన కోసం సాగించే అన్వేషణ యాత్ర.',
    exampleEn: 'This highway journey is an expedition into English mastery.',
    category: 'TRAVEL',
  ),
  OpenWorldVocabItem(
    word: 'INNOVATION',
    phonetics: '/ˌɪn.əˈveɪ.ʃən/',
    partOfSpeech: 'Noun',
    meaningEn: 'Creating and applying new ideas, methods, or devices.',
    meaningMl: 'പുതിയ ആശയങ്ങളും മാർഗ്ഗങ്ങളും കണ്ടെത്തി പ്രാവർത്തികമാക്കൽ.',
    meaningTa: 'புதிய சிந்தனைகள் மற்றும் படைப்பாற்றல் கண்டுபிடிப்புகள்.',
    meaningHi: 'नई सोच और तकनीकों का रचनात्मक आविष्कार।',
    meaningTe: 'సరికొత్త ఆలోచనలు మరియు పద్ధతుల ఆవిష్కరణ.',
    exampleEn: 'Gamified learning is a great innovation for students.',
    category: 'GROWTH',
  ),
  OpenWorldVocabItem(
    word: 'INTEGRITY',
    phonetics: '/ɪnˈteɡ.rə.ti/',
    partOfSpeech: 'Noun',
    meaningEn: 'The quality of being honest and having strong moral standards.',
    meaningMl: 'സത്യസന്ധതയും അചഞ്ചലമായ സദാചാരബോധവും.',
    meaningTa: 'உண்மையும் உறுதியான நற்பண்பும் கொண்ட நேர்மை.',
    meaningHi: 'ईमानदारी, सत्यनिष्ठा और उच्च नैतिक चरित्र।',
    meaningTe: 'నిజాయితీ మరియు ఉన్నతమైన నైతిక విలువలు.',
    exampleEn: 'Practicing with integrity guarantees lifelong confidence.',
    category: 'VALUES',
  ),
  OpenWorldVocabItem(
    word: 'HARMONY',
    phonetics: '/ˈhɑː.mə.ni/',
    partOfSpeech: 'Noun',
    meaningEn: 'Pleasing agreement or concord between people or ideas.',
    meaningMl: 'ഐക്യവും പരസ്പരപൊരുത്തവുമുള്ള സമാധാനാന്തരീക്ഷം.',
    meaningTa: 'ஒற்றுமையும் மன அமைதியும் தரும் நல்லிணக்கம்.',
    meaningHi: 'आपसी तालमेल, सामंजस्य और सुखद संतुलन।',
    meaningTe: 'సామరస్యం మరియు మనోహరమైన కలయిక.',
    exampleEn: 'Teamwork and respect create perfect harmony in learning.',
    category: 'UNITY',
  ),
  OpenWorldVocabItem(
    word: 'BENEVOLENT',
    phonetics: '/bəˈnev.əl.ənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Well-meaning and kindly disposed towards others.',
    meaningMl: 'ദയയും കാരുണ്യവും നിറഞ്ഞ നല്ല മനസ്സ്.',
    meaningTa: 'இரக்கமும் பிறருக்கு நன்மை செய்யும் நற்குணமும்.',
    meaningHi: 'दयालु, परोपकारी और सबका भला चाहने वाला।',
    meaningTe: 'దయాహృదయం గల, ఇతరులకు మేలు చేసే స్వభావం.',
    exampleEn: 'A benevolent mentor guides learners with endless patience.',
    category: 'KINDNESS',
  ),
  OpenWorldVocabItem(
    word: 'DISCIPLINE',
    phonetics: '/ˈdɪs.ə.plɪn/',
    partOfSpeech: 'Noun',
    meaningEn: 'Controlled behavior resulting from training and dedication.',
    meaningMl: 'ചിട്ടയായ പരിശീലനത്തിലൂടെ കൈവരുന്ന ആത്മനിയന്ത്രണം.',
    meaningTa: 'கட்டுப்பாட்டுடன் கூடிய ஒழுக்கமும் அர்ப்பணிப்பும்.',
    meaningHi: 'कठिन परिश्रम और संयम से प्राप्त अनुशासन।',
    meaningTe: 'నిరంతర సాధనతో కూడిన క్రమశిక్షణ.',
    exampleEn: 'Daily discipline turns learning dreams into reality.',
    category: 'HABIT',
  ),
  OpenWorldVocabItem(
    word: 'AMBITION',
    phonetics: '/æmˈbɪʃ.ən/',
    partOfSpeech: 'Noun',
    meaningEn: 'A strong desire to achieve something grand and meaningful.',
    meaningMl: 'ഉന്നതമായ ലക്ഷ്യങ്ങൾ നേടാനുള്ള തീവ്രമായ ആഗ്രഹം.',
    meaningTa: 'உயர் இலக்குகளை அடைய வேண்டும் என்ற தீவிர வேட்கை.',
    meaningHi: 'सफलता प्राप्त करने की तीव्र आकांक्षा या महत्वाकांक्षा।',
    meaningTe: 'గొప్ప విజయాలు సాధించాలనే బలమైన ఆకాంక్ష.',
    exampleEn: 'Her ambition pushed her to reach the highest streak.',
    category: 'GOALS',
  ),
  OpenWorldVocabItem(
    word: 'GENUINE',
    phonetics: '/ˈdʒen.ju.ɪn/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Truly what something is said to be; authentic and sincere.',
    meaningMl: 'യഥാർത്ഥമായതും കളങ്കമില്ലാത്തതുമായ ആത്മാർത്ഥത.',
    meaningTa: 'உண்மையான மற்றும் கலப்படமற்ற உள்ளன்பு.',
    meaningHi: 'वास्तविक, सच्चा और निष्कपट भाव।',
    meaningTe: 'నిజమైన మరియు నిష్కపటమైన స్వచ్ఛత.',
    exampleEn: 'Genuine praise motivates every student to do better.',
    category: 'VALUES',
  ),
  OpenWorldVocabItem(
    word: 'TENACIOUS',
    phonetics: '/təˈneɪ.ʃəs/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Holding fast; persistent, resolute, and determined.',
    meaningMl: 'വിട്ടുകൊടുക്കാതെ മുറുകെപ്പിടിക്കുന്ന നിശ്ചയദാർഢ്യം.',
    meaningTa: 'கைவிடாமல் உறுதியாகப் பிடித்து நிற்கும் விடாப்பிடி.',
    meaningHi: 'दृढ़ निश्चयी और आसानी से हार न मानने वाला।',
    meaningTe: 'ఓటమిని ఒప్పుకోకుండా గట్టిగా నిలబడే గుణం.',
    exampleEn: 'A tenacious learner conquers even the toughest accents.',
    category: 'STRENGTH',
  ),
  OpenWorldVocabItem(
    word: 'WISDOM',
    phonetics: '/ˈwɪz.dəm/',
    partOfSpeech: 'Noun',
    meaningEn: 'The ability to make sensible decisions based on experience.',
    meaningMl: 'ജീവിതാനുഭവങ്ങളിൽ നിന്ന് ആർജ്ജിച്ച വിവേകവും ജ്ഞാനവും.',
    meaningTa: 'அனுபவத்தால் பெறப்பட்ட விவேகமும் மெய்யறிவும்.',
    meaningHi: 'अनुभव और ज्ञान से प्राप्त समझदारी, विवेक।',
    meaningTe: 'అనుభవం ద్వారా అలవడే వివేకం మరియు జ్ఞానం.',
    exampleEn: 'Wisdom is knowing when to speak and when to listen.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'VICTORY',
    phonetics: '/ˈvɪk.tər.i/',
    partOfSpeech: 'Noun',
    meaningEn: 'An act of defeating an enemy or conquering a challenge.',
    meaningMl: 'പ്രതിസന്ധികളെ തോൽപ്പിച്ച് നേടുന്ന മഹത്തായ വിജയം.',
    meaningTa: 'சவால்களை வென்று அடையும் மகத்தான வெற்றி.',
    meaningHi: 'कठिनाइयों पर विजय प्राप्त करना, सफलता।',
    meaningTe: 'సవాళ్లను ఎదుర్కొని సాధించే అద్భుత విజయం.',
    exampleEn: 'Every completed mission is a victory on your path.',
    category: 'ACTION',
  ),
  OpenWorldVocabItem(
    word: 'OPTIMISTIC',
    phonetics: '/ˌɒp.tɪˈmɪs.tɪk/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Hopeful and confident about future success.',
    meaningMl: 'ശുഭപ്രതീക്ഷയും ആത്മവിശ്വാസവുമുള്ള മനോഭാവം.',
    meaningTa: 'எதிர்காலத்தை நம்பிக்கையோடு பார்க்கும் நேர்மறை எண்ணம்.',
    meaningHi: 'सकारात्मक और आशावादी दृष्टिकोण रखने वाला।',
    meaningTe: 'భవిష్యత్తుపై ఆశావహ దృక్పథం కలిగి ఉండటం.',
    exampleEn: 'An optimistic attitude makes every challenge easier.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'EMPATHY',
    phonetics: '/ˈem.pə.θi/',
    partOfSpeech: 'Noun',
    meaningEn: 'The ability to understand and share the feelings of another.',
    meaningMl: 'മറ്റുള്ളവരുടെ വികാരങ്ങളെ തിരിച്ചറിഞ്ഞ് പങ്കുവെക്കാനുള്ള സഹാനുഭൂതി.',
    meaningTa: 'பிறர் உணர்வுகளைப் புரிந்து கொள்ளும் பரிவு.',
    meaningHi: 'दूसरों की भावनाओं को समझने की संवेदनशीलता, सहानुभूति।',
    meaningTe: 'ఇతరుల బాధలను అర్థం చేసుకునే సహానుభూతి.',
    exampleEn: 'Empathy helps us connect deeply with fellow learners.',
    category: 'KINDNESS',
  ),
  OpenWorldVocabItem(
    word: 'PROFOUND',
    phonetics: '/prəˈfaʊnd/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Very great, deep, or having immense insight.',
    meaningMl: 'ആഴമേറിയതും അഗാധവുമായ ജ്ഞാനവും ഉൾക്കാഴ്ചയും.',
    meaningTa: 'ஆழமான சிந்தனையும் மிகுந்த முக்கியத்துவமும் கொண்ட.',
    meaningHi: 'अत्यंत गहरा, गंभीर और ज्ञानवर्धक।',
    meaningTe: 'లోతైన మరియు జ్ఞానోదయమైన భావన.',
    exampleEn: 'The story left a profound impact on my perspective.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'DILIGENCE',
    phonetics: '/ˈdɪl.ɪ.dʒəns/',
    partOfSpeech: 'Noun',
    meaningEn: 'Careful and persistent work or effort.',
    meaningMl: 'ശ്രദ്ധയോടും ആത്മാർത്ഥതയോടുമുള്ള കഠിനാധ്വാനം.',
    meaningTa: 'கவனத்துடனும் ஊக்கத்துடனும் செய்யப்படும் அயராத உழைப்பு.',
    meaningHi: 'लगन, निष्ठा और ध्यानपूर्वक किया गया परिश्रम।',
    meaningTe: 'శ్రద్ధతో కూడిన కఠోర శ్రమ.',
    exampleEn: 'Diligence will always outshine natural talent.',
    category: 'HABIT',
  ),
  OpenWorldVocabItem(
    word: 'CHAMPION',
    phonetics: '/ˈtʃæm.pi.ən/',
    partOfSpeech: 'Noun',
    meaningEn: 'A person who has surpassed all rivals in a contest.',
    meaningMl: 'എല്ലാ വെല്ലുവിളികളെയും അതിജീവിച്ച ഒന്നാം സ്ഥാനക്കാരൻ.',
    meaningTa: 'போட்டிகளில் முதன்மை பெற்று வெற்றி வாகை சூடியவர்.',
    meaningHi: 'सर्वश्रेष्ठ प्रदर्शन करने वाला विजेता या चैम्पियन।',
    meaningTe: 'పోటీలో అందరినీ అధిగమించిన విజేత.',
    exampleEn: 'Train every day like a true language champion.',
    category: 'ACTION',
  ),
  OpenWorldVocabItem(
    word: 'BRILLIANT',
    phonetics: '/ˈbrɪl.jənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Exceptionally clever or radiant in brilliance.',
    meaningMl: 'അസാധാരണമായ ബുദ്ധിസാമർത്ഥ്യവും തിളക്കവുമുള്ള.',
    meaningTa: 'அதிபுத்திசாலித்தனமான மற்றும் பிரகாசமான.',
    meaningHi: 'असाधारण रूप से प्रतिभाशाली और चमकदार।',
    meaningTe: 'అద్భుతమైన ప్రతిభావంతమైన మెరుపు.',
    exampleEn: 'She gave a brilliant answer to the complex question.',
    category: 'GROWTH',
  ),
  OpenWorldVocabItem(
    word: 'RADIANT',
    phonetics: '/ˈreɪ.di.ənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Shining brightly; giving off light or joyful energy.',
    meaningMl: 'തേജസ്സോടും സന്തോഷത്തോടും കൂടി ശോഭിക്കുന്ന.',
    meaningTa: 'மகிழ்ச்சியிலும் ஒளியிலும் சுடர்விட்டுப் பிரகாசிக்கும்.',
    meaningHi: 'दीप्तिमान, प्रफुल्लित और प्रकाशवान।',
    meaningTe: 'సంతోషంతో ప్రకాశించే కాంతివంతమైన.',
    exampleEn: 'His radiant smile welcomed everyone to the session.',
    category: 'PEACE',
  ),
  OpenWorldVocabItem(
    word: 'ELEVATE',
    phonetics: '/ˈel.ɪ.veɪt/',
    partOfSpeech: 'Verb',
    meaningEn: 'Raise to a higher position or standard.',
    meaningMl: 'ഉയർന്ന നിലവാരത്തിലേക്ക് ഉയർത്തുക, അഭിവൃദ്ധിപ്പെടുത്തുക.',
    meaningTa: 'உயர்ந்த நிலைக்கு அல்லது தரத்திற்கு உயர்த்துதல்.',
    meaningHi: 'उच्च स्तर या पद पर उठाना, संवर्धन करना।',
    meaningTe: 'మరింత ఉన్నత స్థాయికి చేర్చడం లేదా పెంచడం.',
    exampleEn: 'Reading diverse books will elevate your vocabulary.',
    category: 'GROWTH',
  ),
  OpenWorldVocabItem(
    word: 'FLOURISH',
    phonetics: '/ˈflʌr.ɪʃ/',
    partOfSpeech: 'Verb',
    meaningEn: 'Grow or develop in a healthy or vigorous way.',
    meaningMl: 'ഏറ്റവും നല്ല രീതിയിൽ തഴച്ചുവളരുക, പുരോഗമിക്കുക.',
    meaningTa: 'செழித்து வளருதல் மற்றும் முன்னேற்றம் அடைதல்.',
    meaningHi: 'समृद्ध होना, फलना-फूलना और तरक्की करना।',
    meaningTe: 'బాగా వృద్ధి చెందడం, వికసించడం.',
    exampleEn: 'With daily practice, conversational confidence will flourish.',
    category: 'GROWTH',
  ),
  OpenWorldVocabItem(
    word: 'TRAILBLAZER',
    phonetics: '/ˈtreɪlˌbleɪ.zər/',
    partOfSpeech: 'Noun',
    meaningEn: 'A pioneer; someone who makes a new path for others.',
    meaningMl: 'മറ്റുള്ളവർക്ക് മാതൃകയായി പുതിയ വഴി വെട്ടിത്തെളിക്കുന്ന മുന്നോടി.',
    meaningTa: 'புதிய வழியைக் காட்டி முன்னின்று செல்லும் வழிகாட்டி.',
    meaningHi: 'नया मार्ग प्रशस्त करने वाला अग्रणी व्यक्ति या पथप्रदर्शक।',
    meaningTe: 'ఇతరులకు మార్గదర్శిగా కొత్త బాట వేసే నాయకుడు.',
    exampleEn: 'Be a trailblazer in your community by mastering English.',
    category: 'LEADERSHIP',
  ),
  OpenWorldVocabItem(
    word: 'ENLIGHTEN',
    phonetics: '/ɪnˈlaɪ.tən/',
    partOfSpeech: 'Verb',
    meaningEn: 'Give someone greater knowledge and understanding.',
    meaningMl: 'അറിവും തിരിച്ചറിവും പകർന്നുനൽകി പ്രകാശിപ്പിക്കുക.',
    meaningTa: 'அறிவையும் புரிதலையும் வழங்கி தெளிவுபடுத்துதல்.',
    meaningHi: 'ज्ञान का प्रकाश देना, प्रबुद्ध करना।',
    meaningTe: 'జ్ఞానోదయం కలిగించడం, సత్యాన్ని తెలియజేయడం.',
    exampleEn: 'A great conversation can enlighten our entire day.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'COURTEOUS',
    phonetics: '/ˈkɜː.ti.əs/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Polite, respectful, and considerate in manner.',
    meaningMl: 'വിനയവും മാന്യവുമായ പെരുമാറ്റമുള്ള, മര്യാദയുള്ള.',
    meaningTa: 'மரியாதையும் அன்பும் கலந்த நற்பண்புமிக்க.',
    meaningHi: 'विनम्र, शिष्ट और दूसरों का सम्मान करने वाला।',
    meaningTe: 'మర్యాదపూర్వకమైన మరియు గౌరవప్రదమైన ప్రవర్తన గల.',
    exampleEn: 'Courteous speech builds lasting friendships across borders.',
    category: 'VALUES',
  ),
  OpenWorldVocabItem(
    word: 'MAGNIFICENT',
    phonetics: '/mæɡˈnɪf.ɪ.sənt/',
    partOfSpeech: 'Adj.',
    meaningEn: 'Extremely beautiful, elaborate, or impressive.',
    meaningMl: 'വിസ്മയകരമായ സൗന്ദര്യവും ഗാംഭീര്യവുമുള്ള മനോഹര കാഴ്‌ച.',
    meaningTa: 'அதிசயத்தக்க அழகும் கம்பீரமும் வாய்ந்த.',
    meaningHi: 'अत्यंत भव्य, मनोहारी और प्रभावशाली।',
    meaningTe: 'అత్యంత వైభవోపేతమైన మరియు గంభీరమైన దృశ్యం.',
    exampleEn: 'The grand suspension bridge is a magnificent creation.',
    category: 'TRAVEL',
  ),
  OpenWorldVocabItem(
    word: 'PASSION',
    phonetics: '/ˈpæʃ.ən/',
    partOfSpeech: 'Noun',
    meaningEn: 'Strong and barely controllable emotion or enthusiasm.',
    meaningMl: 'ഒരു കാര്യത്തോടുള്ള അടങ്ങാത്ത അഭിനിവേശവും താൽപ്പര്യവും.',
    meaningTa: 'குறிக்கோளின் மீதான அளவற்ற ஆர்வமும் பற்றும்.',
    meaningHi: 'किसी लक्ष्य के प्रति गहरा लगाव, जुनून या उत्साह।',
    meaningTe: 'ఒక లక్ష్యం పట్ల ఉండే బలమైన ఇష్టం మరియు తపన.',
    exampleEn: 'Follow your passion for learning with full heart.',
    category: 'MINDSET',
  ),
  OpenWorldVocabItem(
    word: 'GRATITUDE',
    phonetics: '/ˈɡræt.ɪ.tjuːd/',
    partOfSpeech: 'Noun',
    meaningEn: 'The quality of being thankful and showing appreciation.',
    meaningMl: 'നന്ദിയുള്ള മനോഭാവവും മറ്റുള്ളവരുടെ സഹായങ്ങളെ വിലമതിക്കലും.',
    meaningTa: 'நன்றி உணர்வு மற்றும் பாராட்டும் குணம்.',
    meaningHi: 'कृतज्ञता, उपकार मानने का भाव।',
    meaningTe: 'కృతజ్ఞతా భావం, మేలును గుర్తుంచుకోవడం.',
    exampleEn: 'Gratitude keeps the learning mind open and energized.',
    category: 'VALUES',
  ),
  OpenWorldVocabItem(
    word: 'ADVENTURE',
    phonetics: '/ədˈven.tʃər/',
    partOfSpeech: 'Noun',
    meaningEn: 'An unusual and exciting, typically hazardous, experience.',
    meaningMl: 'സാഹസികതയും ആവേശവും നിറഞ്ഞ പുതിയ അനുഭവം.',
    meaningTa: 'புதிய உற்சாகமும் சாகசமும் நிறைந்த அனுபவம்.',
    meaningHi: 'रोमांचक और अनोखा अनुभव, साहसिक कार्य।',
    meaningTe: 'ఉత్సాహం మరియు సాహసంతో కూడిన కొత్త అనుభవం.',
    exampleEn: 'Learning English is an unforgettable life adventure.',
    category: 'TRAVEL',
  ),
];
