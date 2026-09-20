import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Sentence Structure speaking exercise
class SentenceStructureExerciseItem {
  final String category; // 'SIMPLE', 'COMPOUND', 'COMPLEX', 'RELATIVE'
  final String structureType;
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const SentenceStructureExerciseItem({
    required this.category,
    required this.structureType,
    required this.rule,
    required this.promptSentence,
    required this.targetWord,
    required this.acceptableWords,
    required this.fullSentence,
    required this.localizedHints,
    required this.localizedTranslations,
  });

  String getHint(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedHints.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) return entry.value;
    }
    return localizedHints['Malayalam'] ?? localizedHints['Tamil'] ?? localizedHints['English'] ?? '';
  }

  String getTranslation(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedTranslations.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) return entry.value;
    }
    return localizedTranslations['Malayalam'] ?? localizedTranslations['Tamil'] ?? localizedTranslations['English'] ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────
//  EXERCISE DATA  (20 exercises: 5 per category)
// ─────────────────────────────────────────────────────────────────
const List<SentenceStructureExerciseItem> _kSentenceStructureExercises = [

  // ── SIMPLE: one independent clause ────────────────────────────
  SentenceStructureExerciseItem(
    category: 'SIMPLE',
    structureType: 'Simple Sentence',
    rule: 'One independent clause — subject + verb (+ object)',
    promptSentence: 'She ___ every morning. (run)',
    targetWord: 'runs',
    acceptableWords: ['she runs', 'run'],
    fullSentence: 'She runs every morning.',
    localizedHints: {
      'Malayalam': "Simple sentence: oru independent clause mathram. 'She' 3rd person singular — 'runs' aanu correct.",
      'Tamil':     "Simple sentence: oru clause mathram. 'She' 3rd person singular — 'runs' correct.",
      'Hindi':     "Simple sentence: ek clause. 'She' 3rd person singular — 'runs' sahi hai.",
      'Telugu':    "Simple sentence: oka clause. 'She' 3rd person singular — 'runs' correct.",
      'Kannada':   "Simple sentence: ond clause. 'She' 3rd person singular — 'runs' correct.",
      'English':   "Simple: one independent clause. 3rd person singular needs 's' on verb.",
    },
    localizedTranslations: {
      'Malayalam': 'ആ എല്ലാ ദിവസവും ഓടുന്നു.',
      'Tamil':     'அவள் தினமும் ஓடுகிறாள்.',
      'Hindi':     'वह हर सुबह दौड़ती है।',
      'Telugu':    'ఆమె ప్రతి రోజూ పరుగెడుతుంది.',
      'Kannada':   'ಅವಳು ಪ್ರತಿ ಬೆಳಿಗ್ಗೆ ಓಡುತ್ತಾಳೆ.',
      'English':   'She runs every morning.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'SIMPLE',
    structureType: 'Simple Sentence',
    rule: 'One independent clause — subject + verb + complement',
    promptSentence: 'The coffee ___ very hot. (be)',
    targetWord: 'is',
    acceptableWords: ['coffee is', 'was'],
    fullSentence: 'The coffee is very hot.',
    localizedHints: {
      'Malayalam': "Simple sentence: 'The coffee' singular, present tense — 'is' aanu correct.",
      'Tamil':     "Simple sentence: 'The coffee' singular, present — 'is' correct.",
      'Hindi':     "Simple sentence: singular — 'is' sahi hai.",
      'Telugu':    "Simple sentence: singular — 'is' correct.",
      'Kannada':   "Simple sentence: singular — 'is' correct.",
      'English':   "Simple: 'coffee' is singular, present tense — use 'is'.",
    },
    localizedTranslations: {
      'Malayalam': 'കാപ്പി വളരെ ചൂടാണ്.',
      'Tamil':     'காபி மிகவும் சூடாக இருக்கிறது.',
      'Hindi':     'कॉफ़ी बहुत गर्म है।',
      'Telugu':    'కాఫీ చాలా వేడిగా ఉంది.',
      'Kannada':   'ಕಾಫಿ ತುಂಬಾ ಬಿಸಿಯಾಗಿದೆ.',
      'English':   'The coffee is very hot.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'SIMPLE',
    structureType: 'Simple Sentence',
    rule: 'One independent clause with direct object',
    promptSentence: 'He ___ the book on the table. (put)',
    targetWord: 'put',
    acceptableWords: ['he put', 'puts'],
    fullSentence: 'He put the book on the table.',
    localizedHints: {
      'Malayalam': "Simple sentence: past tense. 'put' irregular — past form also 'put'.",
      'Tamil':     "Simple sentence: past tense. 'put' irregular — past form 'put'.",
      'Hindi':     "Simple sentence: past tense. 'put' ka past bhi 'put' hota hai.",
      'Telugu':    "Simple sentence: past tense. 'put' irregular — past 'put'.",
      'Kannada':   "Simple sentence: past tense. 'put' irregular — past 'put'.",
      'English':   "Simple: past tense. 'put' is irregular — past form is also 'put'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവൻ പുസ്തകം മേശപ്പുറത്ത് വെച്ചു.',
      'Tamil':     'அவன் புத்தகத்தை மேசையில் வைத்தான்.',
      'Hindi':     'उसने किताब मेज़ पर रखी।',
      'Telugu':    'అతను పుస్తకాన్ని బల్ల పై పెట్టాడు.',
      'Kannada':   'ಅವನು ಪುಸ್ತಕವನ್ನು ಮೇಜಿನ ಮೇಲೆ ಇಟ್ಟನು.',
      'English':   'He put the book on the table.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'SIMPLE',
    structureType: 'Simple Sentence',
    rule: 'One independent clause — subject + auxiliary + verb',
    promptSentence: 'They ___ playing football now.',
    targetWord: 'are',
    acceptableWords: ['they are', 'were'],
    fullSentence: 'They are playing football now.',
    localizedHints: {
      'Malayalam': "Simple sentence: plural subject 'They', present continuous — 'are' aanu correct.",
      'Tamil':     "Simple sentence: plural 'They', present continuous — 'are' correct.",
      'Hindi':     "Simple sentence: plural 'They', present continuous — 'are' sahi.",
      'Telugu':    "Simple sentence: plural 'They', present continuous — 'are' correct.",
      'Kannada':   "Simple sentence: plural 'They' — 'are' correct.",
      'English':   "Simple: plural subject 'They' + present continuous -> 'are playing'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവർ ഇപ്പോൾ ഫുട്ബോൾ കളിക്കുന്നു.',
      'Tamil':     'அவர்கள் இப்போது கால்பந்து விளையாடுகிறார்கள்.',
      'Hindi':     'वे अभी फ़ुटबॉल खेल रहे हैं।',
      'Telugu':    'వారు ఇప్పుడు ఫుట్‌బాల్ ఆడుతున్నారు.',
      'Kannada':   'ಅವರು ಈಗ ಫುಟ್ಬಾಲ್ ಆಡುತ್ತಿದ್ದಾರೆ.',
      'English':   'They are playing football now.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'SIMPLE',
    structureType: 'Simple Sentence',
    rule: 'One independent clause — negative simple sentence',
    promptSentence: 'I ___ like spicy food. (not like)',
    targetWord: "don't",
    acceptableWords: ["don't like", 'do not'],
    fullSentence: "I don't like spicy food.",
    localizedHints: {
      'Malayalam': "Simple negative: 'I' present tense — 'don't like' aanu correct. 'doesn't' alla.",
      'Tamil':     "Simple negative: 'I' present — 'don't like' correct.",
      'Hindi':     "Simple negative: 'I' ke saath 'don't' use karo.",
      'Telugu':    "Simple negative: 'I' present — 'don't like' correct.",
      'Kannada':   "Simple negative: 'I' ge 'don't' baLasi.",
      'English':   "Simple negative: 'I' + present simple -> 'don't like'.",
    },
    localizedTranslations: {
      'Malayalam': 'എനിക്ക് എരിവുള്ള ഭക്ഷണം ഇഷ്ടമല്ല.',
      'Tamil':     'எனக்கு காரமான உணவு பிடிக்காது.',
      'Hindi':     'मुझे मसालेदार खाना पसंद नहीं है।',
      'Telugu':    'నాకు వేడి ఆహారం ఇష్టం లేదు.',
      'Kannada':   'ನನಗೆ ಖಾರದ ಆಹಾರ ಇಷ್ಟವಿಲ್ಲ.',
      'English':   "I don't like spicy food.",
    },
  ),

  // ── COMPOUND: two independent clauses joined by FANBOYS ───────
  SentenceStructureExerciseItem(
    category: 'COMPOUND',
    structureType: 'Compound Sentence',
    rule: "Two independent clauses joined by 'but' (coordinating conjunction)",
    promptSentence: 'I like coffee, ___ my sister prefers tea.',
    targetWord: 'but',
    acceptableWords: ['but my sister', 'yet'],
    fullSentence: 'I like coffee, but my sister prefers tea.',
    localizedHints: {
      'Malayalam': "Compound sentence: randu independent clauses 'but' kond join cheyyunnu. Contrast express cheyyunnu.",
      'Tamil':     "Compound sentence: rendu clauses 'but' kond join. Contrast kaattugirathu.",
      'Hindi':     "Compound sentence: do clauses 'but' se join. Contrast dikhata hai.",
      'Telugu':    "Compound sentence: rendu clauses 'but' tho join. Contrast chupistundi.",
      'Kannada':   "Compound sentence: eradu clauses 'but' ninda join. Contrast.",
      'English':   "Compound: two independent clauses joined by 'but' (contrast).",
    },
    localizedTranslations: {
      'Malayalam': 'എനിക്ക് കോഫി ഇഷ്ടമാണ്, പക്ഷേ എന്റെ സഹോദരിക്ക് ചായ ഇഷ്ടമാണ്.',
      'Tamil':     'எனக்கு காபி பிடிக்கும், ஆனால் என் அக்காவுக்கு தேநீர் பிடிக்கும்.',
      'Hindi':     'मुझे कॉफ़ी पसंद है, लेकिन मेरी बहन चाय पसंद करती है।',
      'Telugu':    'నాకు కాఫీ ఇష్టం, కానీ నా చెల్లి టీ ఇష్టపడుతుంది.',
      'Kannada':   'ನನಗೆ ಕಾಫಿ ಇಷ್ಟ, ಆದರೆ ನನ್ನ ತಂಗಿಗೆ ಚಹಾ ಇಷ್ಟ.',
      'English':   'I like coffee, but my sister prefers tea.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPOUND',
    structureType: 'Compound Sentence',
    rule: "Two independent clauses joined by 'and' (addition)",
    promptSentence: 'She studied hard, ___ she passed the exam.',
    targetWord: 'and',
    acceptableWords: ['and she', 'so'],
    fullSentence: 'She studied hard, and she passed the exam.',
    localizedHints: {
      'Malayalam': "Compound: 'and' upayogicchu randu independent clauses join cheyyunnu. Addition/result.",
      'Tamil':     "Compound: 'and' use cheytu rendu clauses join. Addition.",
      'Hindi':     "Compound: 'and' se do clauses join. Addition/result.",
      'Telugu':    "Compound: 'and' tho rendu clauses join. Addition.",
      'Kannada':   "Compound: 'and' ninda eradu clauses join. Addition.",
      'English':   "Compound: 'and' joins two independent clauses (addition/result).",
    },
    localizedTranslations: {
      'Malayalam': 'ആ കഠിനമായി പഠിച്ചു, ആ പരീക്ഷ പാസ്സായി.',
      'Tamil':     'அவள் கஷ்டமாக படித்தாள், அவள் தேர்வில் தேர்ச்சி பெற்றாள்.',
      'Hindi':     'उसने कड़ी मेहनत से पढ़ाई की, और वह परीक्षा में पास हो गई।',
      'Telugu':    'ఆమె కష్టపడి చదివింది, ఆమె పరీక్షలో పాస్ అయింది.',
      'Kannada':   'ಅವಳು ಕಷ್ಟಪಟ್ಟು ಓದಿದಳು, ಅವಳು ಪರೀಕ್ಷೆಯಲ್ಲಿ ಉತ್ತೀರ್ಣಳಾದಳು.',
      'English':   'She studied hard, and she passed the exam.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPOUND',
    structureType: 'Compound Sentence',
    rule: "Two independent clauses joined by 'so' (result/consequence)",
    promptSentence: 'It was raining heavily, ___ we stayed inside.',
    targetWord: 'so',
    acceptableWords: ['so we', 'therefore'],
    fullSentence: 'It was raining heavily, so we stayed inside.',
    localizedHints: {
      'Malayalam': "Compound: 'so' result/consequence kaattunnu. Rain -> inside stay cheythu.",
      'Tamil':     "Compound: 'so' result kaattugirathu. Mazhai -> ullae irundhu.",
      'Hindi':     "Compound: 'so' result dikhata hai. Baarish -> andar rahe.",
      'Telugu':    "Compound: 'so' result chupistundi. Varsham -> lopala untimmu.",
      'Kannada':   "Compound: 'so' parinaaama torsuttade. Male -> ollage iddevi.",
      'English':   "Compound: 'so' shows result/consequence between two independent clauses.",
    },
    localizedTranslations: {
      'Malayalam': 'കനത്ത മഴ പെയ്തു, അതിനാൽ ഞങ്ങൾ അകത്ത് നിന്നു.',
      'Tamil':     'மழை கனமாக பெய்தது, அதனால் நாங்கள் உள்ளே இருந்தோம்.',
      'Hindi':     'बहुत तेज़ बारिश हो रही थी, इसलिए हम अंदर रहे।',
      'Telugu':    'భారీ వర్షం పడింది, అందువల్ల మేము లోపల ఉండిపోయాము.',
      'Kannada':   'ತುಂಬಾ ಮಳೆ ಬಂತು, ಹಾಗಾಗಿ ನಾವು ಒಳಗೇ ಇದ್ದೆವು.',
      'English':   'It was raining heavily, so we stayed inside.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPOUND',
    structureType: 'Compound Sentence',
    rule: "Two independent clauses joined by 'or' (alternative)",
    promptSentence: 'You can take the bus, ___ you can walk.',
    targetWord: 'or',
    acceptableWords: ['or you'],
    fullSentence: 'You can take the bus, or you can walk.',
    localizedHints: {
      'Malayalam': "Compound: 'or' alternative/choice kaattunnu. Bus edukam athava nadakam.",
      'Tamil':     "Compound: 'or' alternative kaattugirathu. Bus edukalam athavaa nadakalam.",
      'Hindi':     "Compound: 'or' alternative dikhata hai. Bus lo ya chalo.",
      'Telugu':    "Compound: 'or' alternative chupistundi. Bus teesukonu leda nadavavachu.",
      'Kannada':   "Compound: 'or' alternative torsuttade. Bus tago ata nadio.",
      'English':   "Compound: 'or' gives an alternative between two independent clauses.",
    },
    localizedTranslations: {
      'Malayalam': 'നിങ്ങൾക്ക് ബസ്സ് എടുക്കാം, അല്ലെങ്കിൽ നടക്കാം.',
      'Tamil':     'நீங்கள் பஸ் எடுக்கலாம், அல்லது நடக்கலாம்.',
      'Hindi':     'आप बस ले सकते हैं, या पैदल चल सकते हैं।',
      'Telugu':    'మీరు బస్సు తీసుకోవచ్చు, లేదా నడవవచ్చు.',
      'Kannada':   'ನೀವು ಬಸ್ ತೆಗೆದುಕೊಳ್ಳಬಹುದು, ಅಥವಾ ನಡೆಯಬಹುದು.',
      'English':   'You can take the bus, or you can walk.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPOUND',
    structureType: 'Compound Sentence',
    rule: "Two independent clauses joined by 'yet' (unexpected contrast)",
    promptSentence: 'He worked all day, ___ he felt full of energy.',
    targetWord: 'yet',
    acceptableWords: ['yet he', 'but'],
    fullSentence: 'He worked all day, yet he felt full of energy.',
    localizedHints: {
      'Malayalam': "Compound: 'yet' = unexpected contrast. Ehh divasavum panichchu, ennitum energy undayirunnu.",
      'Tamil':     "Compound: 'yet' = unexpected contrast. Nal poorithu velai seytha, ennalum energetic aaka irundhan.",
      'Hindi':     "Compound: 'yet' = unexpected contrast. 'but' jaisa, lekin zyada strong contrast.",
      'Telugu':    "Compound: 'yet' = unexpected contrast. 'but' laanti, kaani adhika contrast.",
      'Kannada':   "Compound: 'yet' = unexpected contrast. 'but' taraha, aadare strong contrast.",
      'English':   "Compound: 'yet' = unexpected contrast, stronger than 'but'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവൻ ഏഴ് ദിവസം ജോലി ചെയ്തു, എന്നിട്ടും ഊർജ്ജം നിറഞ്ഞ് തോന്നി.',
      'Tamil':     'அவன் நாள் முழுவதும் வேலை செய்தான், ஆயினும் ஆற்றல் நிறைந்திருந்தான்.',
      'Hindi':     'उसने पूरे दिन काम किया, फिर भी वह ऊर्जा से भरपूर महसूस करता था।',
      'Telugu':    'అతను రోజంతా పని చేశాడు, అయినప్పటికీ శక్తితో నిండిపోయినట్లు అనిపించింది.',
      'Kannada':   'ಅವನು ದಿನವಿಡೀ ಕೆಲಸ ಮಾಡಿದನು, ಆದರೂ ಶಕ್ತಿಯಿಂದ ತುಂಬಿದಂತೆ ಅನಿಸಿತು.',
      'English':   'He worked all day, yet he felt full of energy.',
    },
  ),

  // ── COMPLEX: independent + dependent clause ───────────────────
  SentenceStructureExerciseItem(
    category: 'COMPLEX',
    structureType: 'Complex Sentence',
    rule: "Dependent clause with 'because' (cause/reason)",
    promptSentence: 'I like coffee ___ it wakes me up.',
    targetWord: 'because',
    acceptableWords: ['because it', 'since', 'as'],
    fullSentence: 'I like coffee because it wakes me up.',
    localizedHints: {
      'Malayalam': "Complex: 'because' kaaranam/reason kaattunnu. Independent + dependent clause.",
      'Tamil':     "Complex: 'because' kaaranam kaattugirathu. Independent + dependent clause.",
      'Hindi':     "Complex: 'because' karan batata hai. Independent + dependent clause.",
      'Telugu':    "Complex: 'because' kaaranam chupistundi. Independent + dependent clause.",
      'Kannada':   "Complex: 'because' kaarana torsuttade. Independent + dependent clause.",
      'English':   "Complex: 'because' introduces a dependent clause of reason/cause.",
    },
    localizedTranslations: {
      'Malayalam': 'കോഫി ഉണർവ് നൽകുന്നതിനാൽ ഞാൻ അത് ഇഷ്ടപ്പെടുന്നു.',
      'Tamil':     'காபி என்னை விழிப்பூட்டுவதால் அது பிடிக்கும்.',
      'Hindi':     'मुझे कॉफ़ी पसंद है क्योंकि यह मुझे जगाती है।',
      'Telugu':    'కాఫీ నన్ను మేల్కొలుపుతుంది కనుక నాకు ఇష్టం.',
      'Kannada':   'ಕಾಫಿ ನನ್ನನ್ನು ಎಚ್ಚರಿಸುವುದರಿಂದ ನನಗೆ ಇಷ್ಟ.',
      'English':   'I like coffee because it wakes me up.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPLEX',
    structureType: 'Complex Sentence',
    rule: "Dependent clause leading with 'although' (contrast) + comma",
    promptSentence: '___ it was expensive, she bought the dress.',
    targetWord: 'Although',
    acceptableWords: ['although', 'Even though', 'Though'],
    fullSentence: 'Although it was expensive, she bought the dress.',
    localizedHints: {
      'Malayalam': "Complex: 'Although' dependent clause first varum — comma idam. Contrast express cheyyunnu.",
      'Tamil':     "Complex: 'Although' dependent clause first varum — comma vayyungal. Contrast.",
      'Hindi':     "Complex: 'Although' dependent clause pehle — comma lagaao. Contrast.",
      'Telugu':    "Complex: 'Although' dependent clause mundu vastaundi — comma pettaali. Contrast.",
      'Kannada':   "Complex: 'Although' dependent clause munna bartade — comma haaku. Contrast.",
      'English':   "Complex: dependent clause first -> comma after. 'Although' = contrast/concession.",
    },
    localizedTranslations: {
      'Malayalam': 'ഉടുപ്പ് ചെലവേറിയതാണെങ്കിലും ആ അത് വാങ്ങി.',
      'Tamil':     'அது விலை அதிகமாக இருந்தாலும், அவள் ஆடையை வாங்கினாள்.',
      'Hindi':     'हालाँकि वह महँगी थी, उसने वह ड्रेस खरीदी।',
      'Telugu':    'అది ఖరీదైనదైనా, ఆమె ఆ దుస్తులు కొనింది.',
      'Kannada':   'ಅದು ದುಬಾರಿಯಾಗಿದ್ದರೂ, ಅವಳು ಆ ಉಡುಗೆ ಕೊಂಡಳು.',
      'English':   'Although it was expensive, she bought the dress.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPLEX',
    structureType: 'Complex Sentence',
    rule: "Dependent clause with 'when' (time)",
    promptSentence: 'I went to bed ___ I was tired.',
    targetWord: 'when',
    acceptableWords: ['when i', 'because', 'after'],
    fullSentence: 'I went to bed when I was tired.',
    localizedHints: {
      'Malayalam': "Complex: 'when' samayam/time express cheyyunnu. Independent + time-dependent clause.",
      'Tamil':     "Complex: 'when' neram kaattugirathu. Independent + time clause.",
      'Hindi':     "Complex: 'when' time batata hai. Independent + time clause.",
      'Telugu':    "Complex: 'when' samayam chupistundi. Independent + time clause.",
      'Kannada':   "Complex: 'when' samaya torsuttade. Independent + time clause.",
      'English':   "Complex: 'when' introduces a dependent clause of time.",
    },
    localizedTranslations: {
      'Malayalam': 'ക്ഷീണം തോന്നിയപ്പോൾ ഞാൻ ഉറങ്ങാൻ പോയി.',
      'Tamil':     'நான் சோர்வாக இருந்தபோது தூங்கச் சென்றேன்.',
      'Hindi':     'जब मैं थका हुआ था, तब मैं सोने चला गया।',
      'Telugu':    'నాకు అలసటగా అనిపించినప్పుడు నిద్రకు వెళ్ళాను.',
      'Kannada':   'ನಾನು ದಣಿದಿದ್ದಾಗ ಮಲಗಲು ಹೋದೆ.',
      'English':   'I went to bed when I was tired.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPLEX',
    structureType: 'Complex Sentence',
    rule: "Dependent clause with 'if' (condition)",
    promptSentence: '___ you study hard, you will succeed.',
    targetWord: 'If',
    acceptableWords: ['if you', 'Unless'],
    fullSentence: 'If you study hard, you will succeed.',
    localizedHints: {
      'Malayalam': "Complex: 'If' condition express cheyyunnu. First conditional: if + present, will + verb.",
      'Tamil':     "Complex: 'If' niibanam kaattugirathu. First conditional.",
      'Hindi':     "Complex: 'If' shart batata hai. First conditional.",
      'Telugu':    "Complex: 'If' sarthu chupistundi. First conditional.",
      'Kannada':   "Complex: 'If' shartu torsuttade. First conditional.",
      'English':   "Complex: 'If' condition + comma when dependent clause comes first.",
    },
    localizedTranslations: {
      'Malayalam': 'നിങ്ങൾ കഠിനമായി പഠിച്ചാൽ, നിങ്ങൾ വിജയിക്കും.',
      'Tamil':     'நீங்கள் கஷ்டமாக படித்தால், வெற்றி பெறுவீர்கள்.',
      'Hindi':     'अगर आप कठिन परिश्रम करेंगे, तो आप सफल होंगे।',
      'Telugu':    'మీరు కష్టపడి చదివితే, మీరు విజయం సాధిస్తారు.',
      'Kannada':   'ನೀವು ಕಷ್ಟಪಟ್ಟು ಓದಿದರೆ, ನೀವು ಯಶಸ್ಸು ಪಡೆಯುತ್ತೀರಿ.',
      'English':   'If you study hard, you will succeed.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'COMPLEX',
    structureType: 'Complex Sentence',
    rule: "Dependent clause with 'while' (simultaneous actions)",
    promptSentence: 'She listened to music ___ she cooked dinner.',
    targetWord: 'while',
    acceptableWords: ['while she', 'as', 'when'],
    fullSentence: 'She listened to music while she cooked dinner.',
    localizedHints: {
      'Malayalam': "Complex: 'while' simultaneous actions kaattunnu. Rendhu actions same time-il.",
      'Tamil':     "Complex: 'while' same time-il rendu actions. Simultaneous.",
      'Hindi':     "Complex: 'while' do actions ek hi samay me. Simultaneous.",
      'Telugu':    "Complex: 'while' rendu actions oka saariki. Simultaneous.",
      'Kannada':   "Complex: 'while' eradu actions ek kaalada-li. Simultaneous.",
      'English':   "Complex: 'while' links two simultaneous actions in a complex sentence.",
    },
    localizedTranslations: {
      'Malayalam': 'ആ ഭക്ഷണം പാകം ചെയ്യുന്നതിനിടയിൽ സംഗീതം കേട്ടു.',
      'Tamil':     'அவள் சமையல் செய்யும்போது இசை கேட்டாள்.',
      'Hindi':     'जब वह खाना पका रही थी, तब वह संगीत सुन रही थी।',
      'Telugu':    'ఆమె వంట చేస్తూ సంగీతం వింది.',
      'Kannada':   'ಅವಳು ಅಡುಗೆ ಮಾಡುತ್ತಿದ್ದಾಗ ಸಂಗೀತ ಕೇಳಿದಳು.',
      'English':   'She listened to music while she cooked dinner.',
    },
  ),

  // ── RELATIVE: who/which/that/where/when clauses ───────────────
  SentenceStructureExerciseItem(
    category: 'RELATIVE',
    structureType: 'Relative Clause',
    rule: "Defining relative clause with 'who' (for people)",
    promptSentence: 'The woman ___ lives next door is a doctor.',
    targetWord: 'who',
    acceptableWords: ['who lives', 'that'],
    fullSentence: 'The woman who lives next door is a doctor.',
    localizedHints: {
      'Malayalam': "Relative clause: 'who' people-ne describe cheyyaan. 'The woman' -> 'who lives next door'.",
      'Tamil':     "Relative clause: 'who' manithargalai describe cheyyum. 'The woman' -> 'who lives next door'.",
      'Hindi':     "Relative clause: 'who' logon ke baare me batata hai. 'The woman who...'",
      'Telugu':    "Relative clause: 'who' manushulanu describe chestaadi. 'The woman who...'",
      'Kannada':   "Relative clause: 'who' janara bagge heluttade. 'The woman who...'",
      'English':   "Defining relative clause: 'who' for people, essential to the meaning.",
    },
    localizedTranslations: {
      'Malayalam': 'അടുത്ത വീട്ടിൽ താമസിക്കുന്ന സ്ത്രീ ഒരു ഡോക്ടറാണ്.',
      'Tamil':     'அருகில் வாழும் பெண்மணி ஒரு மருத்துவர்.',
      'Hindi':     'जो महिला बगल में रहती है वह डॉक्टर है।',
      'Telugu':    'పక్కింట్లో నివసించే మహిళ ఒక డాక్టర్.',
      'Kannada':   'ಪಕ್ಕದ ಮನೆಯಲ್ಲಿ ವಾಸಿಸುವ ಮಹಿಳೆ ಒಬ್ಬ ವೈದ್ಯರು.',
      'English':   'The woman who lives next door is a doctor.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'RELATIVE',
    structureType: 'Relative Clause',
    rule: "Defining relative clause with 'that' (for things)",
    promptSentence: 'The book ___ I read was amazing.',
    targetWord: 'that',
    acceptableWords: ['that i', 'which'],
    fullSentence: 'The book that I read was amazing.',
    localizedHints: {
      'Malayalam': "Relative clause: 'that' things describe cheyyaan. 'The book' -> 'that I read'.",
      'Tamil':     "Relative clause: 'that' porul vishayangalukkaga. 'The book that I read'.",
      'Hindi':     "Relative clause: 'that' cheez ke baare me. 'The book that I read'.",
      'Telugu':    "Relative clause: 'that' vastuvulanu describe chestaadi. 'The book that I read'.",
      'Kannada':   "Relative clause: 'that' vastugaLa bagge. 'The book that I read'.",
      'English':   "Defining relative clause: 'that' (or 'which') for things.",
    },
    localizedTranslations: {
      'Malayalam': 'ഞാൻ വായിച്ച പുസ്തകം ഗംഭീരമായിരുന്നു.',
      'Tamil':     'நான் படித்த புத்தகம் அற்புதமாக இருந்தது.',
      'Hindi':     'जो किताब मैंने पढ़ी वह अद्भुत थी।',
      'Telugu':    'నేను చదివిన పుస్తకం అద్భుతంగా ఉంది.',
      'Kannada':   'ನಾನು ಓದಿದ ಪುಸ್ತಕ ಅದ್ಭುತವಾಗಿತ್ತು.',
      'English':   'The book that I read was amazing.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'RELATIVE',
    structureType: 'Relative Clause',
    rule: "Non-defining relative clause with 'who' + commas (extra info)",
    promptSentence: 'My sister, ___ lives in London, is a teacher.',
    targetWord: 'who',
    acceptableWords: ['who lives', 'who'],
    fullSentence: 'My sister, who lives in London, is a teacher.',
    localizedHints: {
      'Malayalam': "Non-defining: commas idum. Extra info mathram — 'who lives in London' ilavachcha-lum vaakya meaning maraykilla.",
      'Tamil':     "Non-defining: commas pottu. Extra info — 'who lives in London' illa-vittalum ardam maraayaadu.",
      'Hindi':     "Non-defining: commas lagate hain. Extra info — 'who lives in London' hata dene par bhi meaning same hai.",
      'Telugu':    "Non-defining: commas pettaali. Extra info — 'who lives in London' theesivessina kuda meaning maripovaadu.",
      'Kannada':   "Non-defining: commas haaku. Extra info — 'who lives in London' tededroo artha maruvudilla.",
      'English':   "Non-defining: commas separate the extra info clause — removing it doesn't change core meaning.",
    },
    localizedTranslations: {
      'Malayalam': 'ലണ്ടനിൽ താമസിക്കുന്ന എന്റെ സഹോദരി ഒരു ടീച്ചറാണ്.',
      'Tamil':     'லண்டனில் வாழும் என் அக்கா ஆசிரியர்.',
      'Hindi':     'मेरी बहन, जो लंदन में रहती है, एक शिक्षिका है।',
      'Telugu':    'లండన్‌లో నివసించే నా చెల్లి ఒక ఉపాధ్యాయిని.',
      'Kannada':   'ಲಂಡನ್‌ನಲ್ಲಿ ವಾಸಿಸುವ ನನ್ನ ತಂಗಿ ಒಬ್ಬ ಶಿಕ್ಷಕಿ.',
      'English':   'My sister, who lives in London, is a teacher.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'RELATIVE',
    structureType: 'Relative Clause',
    rule: "Relative clause with 'where' (for places)",
    promptSentence: 'This is the house ___ I grew up.',
    targetWord: 'where',
    acceptableWords: ['where i', 'in which'],
    fullSentence: 'This is the house where I grew up.',
    localizedHints: {
      'Malayalam': "Relative clause: 'where' places-nee describe cheyyaan. 'The house' -> 'where I grew up'.",
      'Tamil':     "Relative clause: 'where' idam/place kaattugirathu. 'The house where I grew up'.",
      'Hindi':     "Relative clause: 'where' jagah ke baare me. 'The house where I grew up'.",
      'Telugu':    "Relative clause: 'where' sthalanlu describe chestaadi. 'The house where I grew up'.",
      'Kannada':   "Relative clause: 'where' sthalada bagge. 'The house where I grew up'.",
      'English':   "Relative clause: 'where' for places — 'the house where I grew up'.",
    },
    localizedTranslations: {
      'Malayalam': 'ഞാൻ വളർന്ന വീടാണ് ഇത്.',
      'Tamil':     'இது நான் வளர்ந்த வீடு.',
      'Hindi':     'यह वह घर है जहाँ मैं पला-बढ़ा।',
      'Telugu':    'ఇది నేను పెరిగిన ఇల్లు.',
      'Kannada':   'ಇದು ನಾನು ಬೆಳೆದ ಮನೆ.',
      'English':   'This is the house where I grew up.',
    },
  ),

  SentenceStructureExerciseItem(
    category: 'RELATIVE',
    structureType: 'Relative Clause',
    rule: "Relative clause with 'which' for things (non-defining, with comma)",
    promptSentence: 'The report, ___ took three weeks, was well received.',
    targetWord: 'which',
    acceptableWords: ['which took', 'that'],
    fullSentence: 'The report, which took three weeks, was well received.',
    localizedHints: {
      'Malayalam': "Non-defining: 'which' things-nee describe cheyyaan — commas idum. 'which took three weeks' extra info.",
      'Tamil':     "Non-defining: 'which' porutkku upayogikkum — commas pottu. Extra info.",
      'Hindi':     "Non-defining: 'which' cheez ke baare me — commas ke saath. Extra info.",
      'Telugu':    "Non-defining: 'which' vastuvulaku — commas tho. Extra info.",
      'Kannada':   "Non-defining: 'which' vastugaLigu — commas ninda. Extra info.",
      'English':   "Non-defining: 'which' (not 'that') with commas for extra info about a thing.",
    },
    localizedTranslations: {
      'Malayalam': 'മൂന്ന് ആഴ്ച എടുത്ത റിപ്പോർട്ട് നന്നായി സ്വീകരിക്കപ്പെട്ടു.',
      'Tamil':     'மூன்று வாரங்கள் எடுத்த அறிக்கை நன்றாக ஏற்றுக்கொள்ளப்பட்டது.',
      'Hindi':     'रिपोर्ट, जिसमें तीन हफ़्ते लगे, अच्छी तरह से स्वीकार की गई।',
      'Telugu':    'మూడు వారాలు పట్టిన నివేదిక బాగా అందుకోబడింది.',
      'Kannada':   'ಮೂರು ವಾರ ತೆಗೆದುಕೊಂಡ ವರದಿ ಚೆನ್ನಾಗಿ ಸ್ವೀಕರಿಸಲ್ಪಟ್ಟಿತು.',
      'English':   'The report, which took three weeks, was well received.',
    },
  ),
];

/// 🏗️ Sentence Structure (Complex) Practice Card
/// SIMPLE / COMPOUND / COMPLEX / RELATIVE — STT, TTS, 6-language support,
/// collapsible rules guide, completion tracking.
class PocketSentenceStructurePracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketSentenceStructurePracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '15',
  });

  @override
  State<PocketSentenceStructurePracticeCard> createState() =>
      _PocketSentenceStructurePracticeCardState();
}

class _PocketSentenceStructurePracticeCardState
    extends State<PocketSentenceStructurePracticeCard>
    with SingleTickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  String _activeFilter = 'ALL';
  bool _showRuleTable = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _isExerciseAnswered = false;
  bool _isCorrect = false;
  Timer? _listeningTimeoutTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakText(String text) async {
    if (widget.onSpeak != null) {
      widget.onSpeak!(text);
      return;
    }
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (err) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) _stopListening();
          }
        },
      );
    } catch (_) {
      _isSpeechInitialized = false;
    }
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    HapticFeedback.mediumImpact();
    if (!_isSpeechInitialized) await _initSpeechRecognizer();
    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _isExerciseAnswered = false;
      _isCorrect = false;
    });
    _listeningTimeoutTimer?.cancel();
    _listeningTimeoutTimer = Timer(const Duration(seconds: 14), () {
      if (mounted && _isListening) _stopListening();
    });
    try {
      if (_isSpeechInitialized) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() => _recognizedWords = result.recognizedWords);
              if (result.finalResult) {
                _evaluateSpokenAnswer(result.recognizedWords);
                _stopListening();
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 12),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            localeId: 'en_US',
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      }
    } catch (_) {
      if (mounted) _stopListening();
    }
  }

  Future<void> _stopListening() async {
    _listeningTimeoutTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isListening = false);
      if (_recognizedWords.isNotEmpty && !_isExerciseAnswered) {
        _evaluateSpokenAnswer(_recognizedWords);
      }
    }
  }

  bool _matchesPhrase(String text, String phrase) {
    final t = text.trim();
    final p = phrase.trim();
    if (t.isEmpty || p.isEmpty) return false;
    if (t == p) return true;
    final escaped = RegExp.escape(p);
    return RegExp('\\b$escaped\\b', caseSensitive: false).hasMatch(t);
  }

  void _evaluateSpokenAnswer(String spokenText) {
    if (spokenText.trim().isEmpty) return;
    final ex = _filteredExercises[_currentExerciseIndex];
    String clean(String s) =>
        s.toLowerCase().replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '').trim();

    final spoken = clean(spokenText);
    final target = clean(ex.targetWord);
    final full = clean(ex.fullSentence);

    bool matched = _matchesPhrase(spoken, target);
    if (!matched) {
      for (final alt in ex.acceptableWords) {
        if (_matchesPhrase(spoken, clean(alt))) {
          matched = true;
          break;
        }
      }
    }
    if (!matched && (_matchesPhrase(spoken, full) || spoken == full)) matched = true;
    if (!matched) {
      final tokens = target.split(' ').where((w) => w.isNotEmpty).toList();
      if (tokens.length > 1 && tokens.every((t) => _matchesPhrase(spoken, t))) matched = true;
    }

    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = matched;
    });
    if (matched) {
      HapticFeedback.heavyImpact();
      _speakText(ex.fullSentence);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  List<SentenceStructureExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'SIMPLE':   return _kSentenceStructureExercises.where((e) => e.category == 'SIMPLE').toList();
      case 'COMPOUND': return _kSentenceStructureExercises.where((e) => e.category == 'COMPOUND').toList();
      case 'COMPLEX':  return _kSentenceStructureExercises.where((e) => e.category == 'COMPLEX').toList();
      case 'RELATIVE': return _kSentenceStructureExercises.where((e) => e.category == 'RELATIVE').toList();
      default:         return _kSentenceStructureExercises;
    }
  }

  void _setFilter(String filter) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeFilter = filter;
      _currentExerciseIndex = 0;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToNext() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex = (_currentExerciseIndex + 1) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToPrevious() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex = (_currentExerciseIndex - 1 + list.length) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _forcePassForTesting() {
    final ex = _filteredExercises[_currentExerciseIndex];
    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = true;
      _recognizedWords = ex.targetWord;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  String _getLocalizedSubtitle(String lang) {
    switch (lang.toLowerCase()) {
      case 'tamil':    return 'வாக்கிய அமைப்பு (Sentence Structure)';
      case 'telugu':   return 'వాక్య నిర్మాణం (Sentence Structure)';
      case 'hindi':    return 'वाक्य संरचना (Sentence Structure)';
      case 'kannada':  return 'ವಾಕ್ಯ ರಚನೆ (Sentence Structure)';
      case 'malayalam':
      default:         return 'വാക്യ ഘടന (Sentence Structure)';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'SIMPLE':   return const Color(0xFF60A5FA); // blue
      case 'COMPOUND': return const Color(0xFF34D399); // emerald
      case 'COMPLEX':  return const Color(0xFFFBBF24); // amber
      case 'RELATIVE': return const Color(0xFFF472B6); // pink
      default:         return const Color(0xFFC084FC);
    }
  }

  Color _filterChipColor(String filter) => _categoryColor(filter);

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();
    final safeIndex = _currentExerciseIndex.clamp(0, exercises.length - 1);
    final ex = exercises[safeIndex];
    final catColor = _categoryColor(ex.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFF60A5FA).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : const Color(0xFF60A5FA).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),

          // ── FILTER TABS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'ALL (20)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('SIMPLE', 'SIMPLE (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMPOUND', 'COMPOUND (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMPLEX', 'COMPLEX (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('RELATIVE', 'RELATIVE (5)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── COLLAPSIBLE RULES GUIDE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showRuleTable = !_showRuleTable);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sentence Types: Simple → Compound → Complex → Relative',
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      _showRuleTable
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showRuleTable) ...[
            const SizedBox(height: 8),
            _buildRuleTable(),
          ],

          const SizedBox(height: 10),

          // ── STRUCTURE TYPE BADGE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    ex.structureType.toUpperCase(),
                    style: GoogleFonts.firaCode(
                        color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ex.rule,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _buildExerciseCard(ex, safeIndex, exercises.length, catColor),

          const SizedBox(height: 12),

          _buildControls(catColor),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextButton(
              onPressed: _forcePassForTesting,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              child: Text(
                '🧪 TEST: Auto-answer & play TTS',
                style: GoogleFonts.firaCode(
                    color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STEP ${widget.stepNumber} • 🏗️ Sentence Structure',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 0.2),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedSubtitle(widget.selectedLanguage),
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: const Color(0xFF60A5FA)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onCompleted(!widget.isCompleted);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isCompleted ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isCompleted ? const Color(0xFF10B981) : Colors.white24,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: widget.isCompleted ? Colors.black : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isCompleted ? 'DONE ✓' : 'MARK STEP',
                    style: GoogleFonts.outfit(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      color: widget.isCompleted ? Colors.black : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(SentenceStructureExerciseItem ex, int index, int total, Color catColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: catColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${index + 1} of $total',
                  style: GoogleFonts.firaCode(
                      color: catColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _speakText(ex.fullSentence),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.volume_up_rounded, color: catColor, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ex.promptSentence,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w700, height: 1.4),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 ${ex.rule}',
                style: GoogleFonts.inter(
                    color: catColor.withValues(alpha: 0.85), fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),

            if (_recognizedWords.isNotEmpty || _isExerciseAnswered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isExerciseAnswered
                      ? (_isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFEF4444).withValues(alpha: 0.15))
                      : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isExerciseAnswered
                        ? (_isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        : Colors.white24,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recognizedWords.isNotEmpty)
                      Text('"$_recognizedWords"',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    if (_isExerciseAnswered) ...[
                      const SizedBox(height: 4),
                      Text(
                        _isCorrect
                            ? '✅ Correct! "${ex.targetWord}"'
                            : '❌ Answer: "${ex.targetWord}"',
                        style: GoogleFonts.outfit(
                          color: _isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.fullSentence,
                        style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ex.getTranslation(widget.selectedLanguage),
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ex.getHint(widget.selectedLanguage),
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color catColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          InkWell(
            onTap: _goToPrevious,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text('◀', style: TextStyle(color: Colors.white60, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _startListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [catColor, catColor.withValues(alpha: 0.75)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isListening ? Icons.stop_rounded : Icons.mic,
                          color: Colors.black, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _isListening ? 'LISTENING...' : '🎤 SAY IT',
                        style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _goToNext,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text('▶', style: TextStyle(color: Colors.white60, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isActive = _activeFilter == value;
    final chipColor = value == 'ALL' ? const Color(0xFFC084FC) : _filterChipColor(value);
    return GestureDetector(
      onTap: () => _setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? chipColor.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? chipColor : Colors.white12,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isActive ? chipColor : Colors.white38,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleTable() {
    final rows = [
      ['Type', 'Structure', 'Connector', 'Example'],
      ['Simple',   '1 independent clause',      '—',                     'She runs every day.'],
      ['Compound', '2 independent clauses',      'and/but/or/so/yet',     'I work, but she rests.'],
      ['Complex',  '1 indep + 1 dep clause',     'because/when/although/if', 'I left because it was late.'],
      ['Relative', 'Noun + relative clause',     'who/which/that/where',  'The man who smiled left.'],
      ['Defining', 'Essential info, no commas',  'who/that',              'The girl that won is here.'],
      ['Non-def.', 'Extra info, use commas',     'who/which',             'My mum, who is 60, runs.'],
    ];

    const Color headerColor = Color(0xFF60A5FA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: List.generate(rows.length, (rowIdx) {
            final row = rows[rowIdx];
            final isHeader = rowIdx == 0;
            return Container(
              decoration: BoxDecoration(
                color: isHeader
                    ? headerColor.withValues(alpha: 0.12)
                    : rowIdx.isOdd
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.transparent,
                borderRadius: rowIdx == 0
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : rowIdx == rows.length - 1
                        ? const BorderRadius.vertical(bottom: Radius.circular(12))
                        : BorderRadius.zero,
              ),
              child: Row(
                children: List.generate(row.length, (colIdx) {
                  return Expanded(
                    flex: colIdx == 3 ? 4 : colIdx == 1 ? 3 : 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                      child: Text(
                        row[colIdx],
                        style: GoogleFonts.inter(
                          color: isHeader
                              ? headerColor
                              : colIdx == 0
                                  ? Colors.white70
                                  : Colors.white54,
                          fontSize: 10,
                          fontWeight: isHeader
                              ? FontWeight.w700
                              : colIdx == 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
