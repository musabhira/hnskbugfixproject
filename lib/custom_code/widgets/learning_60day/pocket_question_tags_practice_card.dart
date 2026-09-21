import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Question Tags speaking exercise
class QuestionTagExerciseItem {
  final String category; // 'BASIC', 'TENSE', 'SPECIAL', 'MISTAKES'
  final String tagType;  // friendly label shown in the badge
  final String rule;
  final String promptSentence;
  final String targetWord;       // the full tag e.g. "don't you"
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const QuestionTagExerciseItem({
    required this.category,
    required this.tagType,
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
const List<QuestionTagExerciseItem> _kQuestionTagExercises = [

  // ── BASIC: polarity flip with auxiliary verbs ──────────────────
  QuestionTagExerciseItem(
    category: 'BASIC',
    tagType: 'Basic Rule',
    rule: 'Positive statement + negative tag (auxiliary flipped)',
    promptSentence: 'You like coffee, ___ you?',
    targetWord: "don't",
    acceptableWords: ["don't you", "do not"],
    fullSentence: "You like coffee, don't you?",
    localizedHints: {
      'Malayalam': "Positive statement -> negative tag. 'You like' ennathu positive, so tag 'don't you?' aanu.",
      'Tamil':     "Positive vaakiyam -> negative tag. 'don't you?' enpathai use cheyyungal.",
      'Hindi':     "Positive vaakya me negative tag. 'You like' positive hai to tag 'don't you?' hoga.",
      'Telugu':    "Positive statement ki negative tag vastundi. 'don't you?' anedhi correct tag.",
      'Kannada':   "Positive statement ge negative tag. 'don't you?' enna baLasi.",
      'English':   "Positive statement -> negative tag. No auxiliary in main verb -> use do/does/did.",
    },
    localizedTranslations: {
      'Malayalam': 'നിങ്ങൾക്ക് കോഫി ഇഷ്ടമാണ്, അല്ലേ?',
      'Tamil':     'உங்களுக்கு காபி பிடிக்கும், இல்லையா?',
      'Hindi':     'आपको कॉफ़ी पसंद है, है ना?',
      'Telugu':    'మీకు కాఫీ ఇష్టం, కదా?',
      'Kannada':   'ನಿಮಗೆ ಕಾಫಿ ಇಷ್ಟ, ಅಲ್ಲವೇ?',
      'English':   "You like coffee, don't you?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'BASIC',
    tagType: 'Basic Rule',
    rule: 'Negative statement + positive tag',
    promptSentence: "She isn't coming, ___ she?",
    targetWord: 'is',
    acceptableWords: ['is she'],
    fullSentence: "She isn't coming, is she?",
    localizedHints: {
      'Malayalam': "Negative statement -> positive tag. 'isn't' negative aanu, so tag 'is she?' positive aayirikkanam.",
      'Tamil':     "Negative vaakiyam -> positive tag. 'isn't coming' -> tag 'is she?'",
      'Hindi':     "Negative vaakya me positive tag. 'isn't' negative hai to tag 'is she?' positive hoga.",
      'Telugu':    "Negative statement ki positive tag. 'isn't' -> 'is she?'",
      'Kannada':   "Negative statement ge positive tag. 'isn't' -> 'is she?'",
      'English':   "Negative statement -> positive tag. Flip 'isn't' to 'is'.",
    },
    localizedTranslations: {
      'Malayalam': 'ആ വരുന്നില്ല, അല്ലേ?',
      'Tamil':     'அவள் வரவில்லை, இல்லையா?',
      'Hindi':     'वह नहीं आ रही, है ना?',
      'Telugu':    'ఆమె రావడం లేదు, కదా?',
      'Kannada':   'ಅವಳು ಬರುತ್ತಿಲ್ಲ, ಅಲ್ಲವೇ?',
      'English':   "She isn't coming, is she?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'BASIC',
    tagType: 'Basic Rule',
    rule: 'Positive + negative tag (modal: can)',
    promptSentence: "He can swim, ___ he?",
    targetWord: "can't",
    acceptableWords: ["can't he", 'cannot'],
    fullSentence: "He can swim, can't he?",
    localizedHints: {
      'Malayalam': "Modal 'can' positive aanu, so tag 'can't he?' negative aayirikkanam.",
      'Tamil':     "'can' positive -> tag 'can't he?' negative aaka irukkum.",
      'Hindi':     "'can' positive hai to tag 'can't he?' negative hoga.",
      'Telugu':    "'can' positive -> tag 'can't he?' negative avutundi.",
      'Kannada':   "'can' positive ge tag 'can't he?' negative.",
      'English':   "Modal 'can' (positive) -> tag 'can't he?' (negative).",
    },
    localizedTranslations: {
      'Malayalam': 'അവൻ നീന്തൽ അറിയാം, അല്ലേ?',
      'Tamil':     'அவன் நீந்த தெரியும், இல்லையா?',
      'Hindi':     'वह तैर सकता है, है ना?',
      'Telugu':    'అతను ఈదగలడు, కదా?',
      'Kannada':   'ಅವನು ಈಜಬಲ್ಲ, ಅಲ್ಲವೇ?',
      'English':   "He can swim, can't he?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'BASIC',
    tagType: 'Basic Rule',
    rule: 'Positive + negative tag (have — present perfect)',
    promptSentence: "They have finished, ___ they?",
    targetWord: "haven't",
    acceptableWords: ["haven't they", 'have not'],
    fullSentence: "They have finished, haven't they?",
    localizedHints: {
      'Malayalam': "Present perfect 'have finished' positive -> tag 'haven't they?' negative.",
      'Tamil':     "'have finished' positive -> tag 'haven't they?'",
      'Hindi':     "'have finished' positive hai to tag 'haven't they?' hoga.",
      'Telugu':    "'have finished' positive -> tag 'haven't they?'",
      'Kannada':   "'have finished' positive ge 'haven't they?' tag.",
      'English':   "Present perfect positive -> negative tag with 'haven't'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവർ തീർത്തു, അല്ലേ?',
      'Tamil':     'அவர்கள் முடித்தார்கள், இல்லையா?',
      'Hindi':     'उन्होंने खत्म कर लिया है, है ना?',
      'Telugu':    'వారు పూర్తి చేశారు, కదా?',
      'Kannada':   'ಅವರು ಮುಗಿಸಿದ್ದಾರೆ, ಅಲ್ಲವೇ?',
      'English':   "They have finished, haven't they?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'BASIC',
    tagType: 'Basic Rule',
    rule: 'Positive + negative tag (modal: will)',
    promptSentence: "She will help us, ___ she?",
    targetWord: "won't",
    acceptableWords: ["won't she", 'will not'],
    fullSentence: "She will help us, won't she?",
    localizedHints: {
      'Malayalam': "Modal 'will' positive -> tag 'won't she?' negative.",
      'Tamil':     "'will' positive -> tag 'won't she?'",
      'Hindi':     "'will' positive hai to tag 'won't she?' negative.",
      'Telugu':    "'will' positive -> tag 'won't she?'",
      'Kannada':   "'will' positive ge 'won't she?' tag.",
      'English':   "Modal 'will' (positive) -> 'won't she?' (negative tag).",
    },
    localizedTranslations: {
      'Malayalam': 'ആ നമ്മളെ സഹായിക്കും, അല്ലേ?',
      'Tamil':     'அவள் நம்மை உதவுவாள், இல்லையா?',
      'Hindi':     'वह हमारी मदद करेगी, है ना?',
      'Telugu':    'ఆమె మనకు సహాయం చేస్తుంది, కదా?',
      'Kannada':   'ಅವಳು ನಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತಾಳೆ, ಅಲ್ಲವೇ?',
      'English':   "She will help us, won't she?",
    },
  ),

  // ── TENSE: tag matches the tense of the main verb ─────────────
  QuestionTagExerciseItem(
    category: 'TENSE',
    tagType: 'Tense Matching',
    rule: 'Present simple (no auxiliary) -> use do/does',
    promptSentence: "You live here, ___ you?",
    targetWord: "don't",
    acceptableWords: ["don't you", 'do not'],
    fullSentence: "You live here, don't you?",
    localizedHints: {
      'Malayalam': "Present simple — auxiliary illa, so 'do' upayogikkam. Positive -> 'don't you?'",
      'Tamil':     "Present simple — no auxiliary -> 'do/does'. Positive -> 'don't you?'",
      'Hindi':     "Present simple me auxiliary nahi -> 'do/does' use karo.",
      'Telugu':    "Present simple — auxiliary ledu -> 'do' vadataamu. Positive -> 'don't you?'",
      'Kannada':   "Present simple — auxiliary illa -> 'do' baLasi. Positive -> 'don't you?'",
      'English':   "No auxiliary in present simple -> use do/does. Positive -> negative tag.",
    },
    localizedTranslations: {
      'Malayalam': 'നിങ്ങൾ ഇവിടെ താമസിക്കുന്നു, അല്ലേ?',
      'Tamil':     'நீங்கள் இங்கே வாழ்கிறீர்கள், இல்லையா?',
      'Hindi':     'आप यहाँ रहते हैं, है ना?',
      'Telugu':    'మీరు ఇక్కడ నివసిస్తున్నారు, కదా?',
      'Kannada':   'ನೀವು ಇಲ್ಲಿ ವಾಸಿಸುತ್ತೀರಿ, ಅಲ್ಲವೇ?',
      'English':   "You live here, don't you?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'TENSE',
    tagType: 'Tense Matching',
    rule: 'Past simple (no auxiliary) -> use did',
    promptSentence: "She lived there, ___ she?",
    targetWord: "didn't",
    acceptableWords: ["didn't she", 'did not'],
    fullSentence: "She lived there, didn't she?",
    localizedHints: {
      'Malayalam': "Past simple — auxiliary illa. Positive -> 'didn't she?' tag.",
      'Tamil':     "Past simple — no auxiliary -> 'did'. Positive -> 'didn't she?'",
      'Hindi':     "Past simple me auxiliary nahi -> 'did' use karo. 'didn't she?'",
      'Telugu':    "Past simple — auxiliary ledu -> 'did'. Positive -> 'didn't she?'",
      'Kannada':   "Past simple — auxiliary illa -> 'did' baLasi. 'didn't she?'",
      'English':   "Past simple no auxiliary -> use 'did'. Positive -> 'didn't she?'",
    },
    localizedTranslations: {
      'Malayalam': 'ആ അവിടെ താമസിച്ചിരുന്നു, അല്ലേ?',
      'Tamil':     'அவள் அங்கே வாழ்ந்தாள், இல்லையா?',
      'Hindi':     'वह वहाँ रहती थी, है ना?',
      'Telugu':    'ఆమె అక్కడ నివసించింది, కదా?',
      'Kannada':   'ಅವಳು ಅಲ್ಲಿ ವಾಸಿಸುತ್ತಿದ್ದಳು, ಅಲ್ಲವೇ?',
      'English':   "She lived there, didn't she?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'TENSE',
    tagType: 'Tense Matching',
    rule: 'Present continuous -> tag with is/are/am',
    promptSentence: "He is coming, ___ he?",
    targetWord: "isn't",
    acceptableWords: ["isn't he", 'is not'],
    fullSentence: "He is coming, isn't he?",
    localizedHints: {
      'Malayalam': "Present continuous 'is coming' positive -> tag 'isn't he?' negative.",
      'Tamil':     "'is coming' positive -> 'isn't he?' negative tag.",
      'Hindi':     "'is coming' positive hai to tag 'isn't he?' negative.",
      'Telugu':    "'is coming' positive -> 'isn't he?' tag.",
      'Kannada':   "'is coming' positive ge 'isn't he?' tag.",
      'English':   "Present continuous 'is' (positive) -> 'isn't he?' (negative tag).",
    },
    localizedTranslations: {
      'Malayalam': 'അവൻ വരുന്നുണ്ട്, അല്ലേ?',
      'Tamil':     'அவன் வருகிறான், இல்லையா?',
      'Hindi':     'वह आ रहा है, है ना?',
      'Telugu':    'అతను వస్తున్నాడు, కదా?',
      'Kannada':   'ಅವನು ಬರುತ್ತಿದ್ದಾನೆ, ಅಲ್ಲವೇ?',
      'English':   "He is coming, isn't he?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'TENSE',
    tagType: 'Tense Matching',
    rule: 'Present perfect -> tag with have/has',
    promptSentence: "They have arrived, ___ they?",
    targetWord: "haven't",
    acceptableWords: ["haven't they", 'have not'],
    fullSentence: "They have arrived, haven't they?",
    localizedHints: {
      'Malayalam': "Present perfect 'have arrived' positive -> tag 'haven't they?' negative.",
      'Tamil':     "'have arrived' positive -> 'haven't they?' tag.",
      'Hindi':     "'have arrived' positive -> tag 'haven't they?'",
      'Telugu':    "'have arrived' positive -> 'haven't they?' tag.",
      'Kannada':   "'have arrived' positive ge 'haven't they?' tag.",
      'English':   "Present perfect 'have' (positive) -> 'haven't they?' (negative).",
    },
    localizedTranslations: {
      'Malayalam': 'അവർ എത്തി, അല്ലേ?',
      'Tamil':     'அவர்கள் வந்துவிட்டார்கள், இல்லையா?',
      'Hindi':     'वे पहुँच गए हैं, है ना?',
      'Telugu':    'వారు చేరుకున్నారు, కదా?',
      'Kannada':   'ಅವರು ತಲುಪಿದ್ದಾರೆ, ಅಲ್ಲವೇ?',
      'English':   "They have arrived, haven't they?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'TENSE',
    tagType: 'Tense Matching',
    rule: 'Past continuous -> tag with was/were',
    promptSentence: "She was sleeping, ___ she?",
    targetWord: "wasn't",
    acceptableWords: ["wasn't she", 'was not'],
    fullSentence: "She was sleeping, wasn't she?",
    localizedHints: {
      'Malayalam': "Past continuous 'was sleeping' positive -> tag 'wasn't she?' negative.",
      'Tamil':     "'was sleeping' positive -> 'wasn't she?' tag.",
      'Hindi':     "'was sleeping' positive -> tag 'wasn't she?'",
      'Telugu':    "'was sleeping' positive -> 'wasn't she?' tag.",
      'Kannada':   "'was sleeping' positive ge 'wasn't she?' tag.",
      'English':   "Past continuous 'was' (positive) -> 'wasn't she?' (negative tag).",
    },
    localizedTranslations: {
      'Malayalam': 'ആ ഉറങ്ങുകയായിരുന്നു, അല്ലേ?',
      'Tamil':     'அவள் தூங்கிக்கொண்டிருந்தாள், இல்லையா?',
      'Hindi':     'वह सो रही थी, है ना?',
      'Telugu':    'ఆమె నిద్రపోతోంది, కదా?',
      'Kannada':   'ಅವಳು ನಿದ್ರಿಸುತ್ತಿದ್ದಳು, ಅಲ್ಲವೇ?',
      'English':   "She was sleeping, wasn't she?",
    },
  ),

  // ── SPECIAL: irregular tag patterns ─────────────────────────────
  QuestionTagExerciseItem(
    category: 'SPECIAL',
    tagType: 'Special Cases',
    rule: "I am + statement -> tag is 'aren't I?' (not 'amn't I')",
    promptSentence: "I am on time, ___ I?",
    targetWord: "aren't",
    acceptableWords: ["aren't I"],
    fullSentence: "I am on time, aren't I?",
    localizedHints: {
      'Malayalam': "Special case: 'I am' positive -> tag 'aren't I?' — 'amn't' parayilla.",
      'Tamil':     "Special: 'I am' positive -> tag 'aren't I?' — 'amn't' payanpaduthamattom.",
      'Hindi':     "Special: 'I am' ke baad tag 'aren't I?' hoga — 'amn't' use nahi karte.",
      'Telugu':    "Special: 'I am' positive -> tag 'aren't I?' — 'amn't' vadamaanu.",
      'Kannada':   "Special: 'I am' positive ge 'aren't I?' tag — 'amn't' baLasuvudilla.",
      'English':   "Special case: 'I am' -> tag is 'aren't I?' (never 'amn't I?').",
    },
    localizedTranslations: {
      'Malayalam': 'ഞാൻ സമയത്തിനുണ്ട്, അല്ലേ?',
      'Tamil':     'நான் சரியான நேரத்தில் இருக்கிறேன், இல்லையா?',
      'Hindi':     'मैं समय पर हूँ, है ना?',
      'Telugu':    'నేను సమయానికి ఉన్నాను, కదా?',
      'Kannada':   'ನಾನು ಸಮಯಕ್ಕೆ ಇದ್ದೇನೆ, ಅಲ್ಲವೇ?',
      'English':   "I am on time, aren't I?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'SPECIAL',
    tagType: 'Special Cases',
    rule: "Let's + verb -> tag is 'shall we?'",
    promptSentence: "Let's go for a walk, ___ we?",
    targetWord: 'shall',
    acceptableWords: ['shall we'],
    fullSentence: "Let's go for a walk, shall we?",
    localizedHints: {
      'Malayalam': "Special case: 'Let's' statement -> tag 'shall we?' — will/won't upayogikkaruthu.",
      'Tamil':     "Special: 'Let's' -> tag 'shall we?' — 'will we?' payanpaduthamattom.",
      'Hindi':     "Special: 'Let's' ke baad tag 'shall we?' hoga.",
      'Telugu':    "Special: 'Let's' -> tag 'shall we?' — 'will we?' vadamaanu.",
      'Kannada':   "Special: 'Let's' ge 'shall we?' tag.",
      'English':   "Special: 'Let's' always takes 'shall we?' as the tag.",
    },
    localizedTranslations: {
      'Malayalam': 'നമുക്ക് ഒരു നടത്തം പോകാം, ശരിയല്ലേ?',
      'Tamil':     'நடைப்பயணம் போகலாம், இல்லையா?',
      'Hindi':     'चलो टहलने चलते हैं, ठीक है ना?',
      'Telugu':    'మనం నడకకు వెళదాం, కదా?',
      'Kannada':   'ನಡೆದಾಡಲು ಹೋಗೋಣ, ಸರಿಯೇ?',
      'English':   "Let's go for a walk, shall we?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'SPECIAL',
    tagType: 'Special Cases',
    rule: "Affirmative imperative -> tag is 'will you?' or 'won't you?'",
    promptSentence: "Open the door, ___ you?",
    targetWord: 'will',
    acceptableWords: ['will you', "won't you", "won't"],
    fullSentence: "Open the door, will you?",
    localizedHints: {
      'Malayalam': "Affirmative imperative -> tag 'will you?' — oru request polue.",
      'Tamil':     "Affirmative imperative -> tag 'will you?' — kori kekum pothillamal.",
      'Hindi':     "Affirmative imperative ke baad tag 'will you?' hoga.",
      'Telugu':    "Affirmative imperative -> tag 'will you?'",
      'Kannada':   "Affirmative imperative ge 'will you?' tag.",
      'English':   "Affirmative imperative -> 'will you?' (polite request).",
    },
    localizedTranslations: {
      'Malayalam': 'വാതിൽ തുറക്കൂ, ദയവായി?',
      'Tamil':     'கதவை திறவுங்கள், செய்வீர்களா?',
      'Hindi':     'दरवाज़ा खोलिए, करेंगे ना?',
      'Telugu':    'తలుపు తెరవండి, సరేనా?',
      'Kannada':   'ಬಾಗಿಲು ತೆರೆಯಿರಿ, ತೆರೆಯುತ್ತೀರಾ?',
      'English':   "Open the door, will you?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'SPECIAL',
    tagType: 'Special Cases',
    rule: "Negative imperative -> tag is 'will you?'",
    promptSentence: "Don't be late, ___ you?",
    targetWord: 'will',
    acceptableWords: ['will you'],
    fullSentence: "Don't be late, will you?",
    localizedHints: {
      'Malayalam': "Negative imperative 'Don't...' -> tag 'will you?' aanu — 'won't' alla.",
      'Tamil':     "Negative imperative 'Don't' -> tag 'will you?' payanpaduttungal.",
      'Hindi':     "Negative imperative 'Don't' ke baad tag 'will you?' hoga.",
      'Telugu':    "Negative imperative 'Don't' -> tag 'will you?'",
      'Kannada':   "Negative imperative 'Don't' ge 'will you?' tag.",
      'English':   "Negative imperative 'Don't...' -> always 'will you?' (not 'won't you?').",
    },
    localizedTranslations: {
      'Malayalam': 'വൈകരുത്, ദയവായി?',
      'Tamil':     'தாமதமாக வராதீர்கள், சரியா?',
      'Hindi':     'देर मत करना, ठीक है ना?',
      'Telugu':    'ఆలస్యం కాకండి, సరేనా?',
      'Kannada':   'ತಡ ಮಾಡಬೇಡಿ, ಆಗುತ್ತದೆಯೇ?',
      'English':   "Don't be late, will you?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'SPECIAL',
    tagType: 'Special Cases',
    rule: "Nothing/Nobody subject -> tag uses 'is it?' or 'do they?'",
    promptSentence: "Nothing went wrong, ___ it?",
    targetWord: 'did',
    acceptableWords: ['did it'],
    fullSentence: "Nothing went wrong, did it?",
    localizedHints: {
      'Malayalam': "Nothing/nobody -> tag subject 'it/they'. 'Nothing went' past simple -> 'did it?'",
      'Tamil':     "Nothing/nobody -> tag 'it/they'. Past simple -> 'did it?'",
      'Hindi':     "Nothing/nobody -> tag 'it/they'. Past -> 'did it?'",
      'Telugu':    "Nothing/nobody -> tag 'it/they'. Past simple -> 'did it?'",
      'Kannada':   "Nothing/nobody -> tag 'it/they'. Past -> 'did it?'",
      'English':   "'Nothing' is negative -> positive tag 'did it?' (past simple).",
    },
    localizedTranslations: {
      'Malayalam': 'ഒന്നും തെറ്റിയില്ല, അല്ലേ?',
      'Tamil':     'எதுவும் தவறாகவில்லை, இல்லையா?',
      'Hindi':     'कुछ भी गलत नहीं हुआ, है ना?',
      'Telugu':    'ఏమీ తప్పు జరగలేదు, కదా?',
      'Kannada':   'ಏನೂ ತಪ್ಪಾಗಲಿಲ್ಲ, ಅಲ್ಲವೇ?',
      'English':   "Nothing went wrong, did it?",
    },
  ),

  // ── MISTAKES: common errors learners make ─────────────────────
  QuestionTagExerciseItem(
    category: 'MISTAKES',
    tagType: 'Common Mistakes',
    rule: "He likes -> tag must be 'doesn't he?' (not 'don't he?')",
    promptSentence: "He likes football, ___ he?",
    targetWord: "doesn't",
    acceptableWords: ["doesn't he", 'does not'],
    fullSentence: "He likes football, doesn't he?",
    localizedHints: {
      'Malayalam': "3rd person singular present: 'He likes' -> 'does' upayogikkam, 'do' alla. 'doesn't he?'",
      'Tamil':     "'He likes' -> 'does' use cheyyungal, 'do' alla. 'doesn't he?'",
      'Hindi':     "'He likes' me 3rd person -> 'does'. Tag 'doesn't he?' correct hai.",
      'Telugu':    "'He likes' -> 'does' vadataamu, 'do' kadu. 'doesn't he?'",
      'Kannada':   "'He likes' -> 3rd person 'does' baLasi. 'doesn't he?'",
      'English':   "3rd person singular: 'likes' -> use 'does/doesn't', never 'do/don't'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവന് ഫുട്ബോൾ ഇഷ്ടമാണ്, അല്ലേ?',
      'Tamil':     'அவனுக்கு கால்பந்து பிடிக்கும், இல்லையா?',
      'Hindi':     'उसे फ़ुटबॉल पसंद है, है ना?',
      'Telugu':    'అతనికి ఫుట్‌బాల్ ఇష్టం, కదా?',
      'Kannada':   'ಅವನಿಗೆ ಫುಟ್ಬಾಲ್ ಇಷ್ಟ, ಅಲ್ಲವೇ?',
      'English':   "He likes football, doesn't he?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'MISTAKES',
    tagType: 'Common Mistakes',
    rule: "Positive 'I am' -> tag is 'aren't I?' (very common error)",
    promptSentence: "I am late, ___ I?",
    targetWord: "aren't",
    acceptableWords: ["aren't I"],
    fullSentence: "I am late, aren't I?",
    localizedHints: {
      'Malayalam': "Common mistake: 'I am' -> 'amn't I?' parayilla. Correct: 'aren't I?'",
      'Tamil':     "Tappai: 'I am' -> 'amn't I?' payanpaduthamal. 'aren't I?' correct.",
      'Hindi':     "Galti: 'I am' ke baad 'amn't I?' nahi — 'aren't I?' sahi hai.",
      'Telugu':    "Tappu: 'I am' -> 'amn't I?' kaadu. 'aren't I?' correct.",
      'Kannada':   "Tappu: 'I am' -> 'amn't I?' alla. 'aren't I?' correct.",
      'English':   "Common error: 'amn't I?' is incorrect. Always use 'aren't I?'",
    },
    localizedTranslations: {
      'Malayalam': 'ഞാൻ വൈകി, അല്ലേ?',
      'Tamil':     'நான் தாமதமாகிவிட்டேன், இல்லையா?',
      'Hindi':     'मैं देर से हूँ, है ना?',
      'Telugu':    'నేను ఆలస్యంగా ఉన్నాను, కదా?',
      'Kannada':   'ನಾನು ತಡವಾಗಿದ್ದೇನೆ, ಅಲ್ಲವೇ?',
      'English':   "I am late, aren't I?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'MISTAKES',
    tagType: 'Common Mistakes',
    rule: "Negative 'She can't dance' -> tag is positive 'can she?'",
    promptSentence: "She can't dance, ___ she?",
    targetWord: 'can',
    acceptableWords: ['can she'],
    fullSentence: "She can't dance, can she?",
    localizedHints: {
      'Malayalam': "Common mistake: negative statement -> positive tag. 'can't' negative, so tag 'can she?' positive.",
      'Tamil':     "Tappai: negative statement -> positive tag. 'can't' -> 'can she?'",
      'Hindi':     "Galti: negative me positive tag. 'can't' -> 'can she?'",
      'Telugu':    "Tappu: negative -> positive tag. 'can't' -> 'can she?'",
      'Kannada':   "Tappu: negative ge positive tag. 'can't' -> 'can she?'",
      'English':   "Negative statement -> POSITIVE tag. 'can't' -> 'can she?'",
    },
    localizedTranslations: {
      'Malayalam': 'ആ നൃത്തം ചെയ്യുന്നില്ല, അല്ലേ?',
      'Tamil':     'அவளுக்கு நடனம் தெரியாது, இல்லையா?',
      'Hindi':     'वह नाच नहीं सकती, है ना?',
      'Telugu':    'ఆమె నాట్యం చేయలేదు, కదా?',
      'Kannada':   'ಅವಳು ನೃತ್ಯ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ, ಅಲ್ಲವೇ?',
      'English':   "She can't dance, can she?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'MISTAKES',
    tagType: 'Common Mistakes',
    rule: "Past tense: 'They went' -> tag 'didn't they?' (not 'don't they?')",
    promptSentence: "They went to the park, ___ they?",
    targetWord: "didn't",
    acceptableWords: ["didn't they", 'did not'],
    fullSentence: "They went to the park, didn't they?",
    localizedHints: {
      'Malayalam': "Common mistake: past tense -> 'did' upayogikkam, 'do' alla. 'didn't they?'",
      'Tamil':     "Tappai: past tense -> 'did' use cheyyungal, 'do' alla. 'didn't they?'",
      'Hindi':     "Galti: past tense me 'did' use karo — 'do' nahi. 'didn't they?'",
      'Telugu':    "Tappu: past tense -> 'did' vadataamu, 'do' kadu. 'didn't they?'",
      'Kannada':   "Tappu: past tense ge 'did' baLasi. 'didn't they?'",
      'English':   "Past tense: always use 'did/didn't', not 'do/don't'.",
    },
    localizedTranslations: {
      'Malayalam': 'അവർ പാർക്കിൽ പോയി, അല്ലേ?',
      'Tamil':     'அவர்கள் பூங்காவிற்கு சென்றார்கள், இல்லையா?',
      'Hindi':     'वे पार्क में गए, है ना?',
      'Telugu':    'వారు పార్క్‌కు వెళ్ళారు, కదా?',
      'Kannada':   'ಅವರು ಪಾರ್ಕ್‌ಗೆ ಹೋದರು, ಅಲ್ಲವೇ?',
      'English':   "They went to the park, didn't they?",
    },
  ),

  QuestionTagExerciseItem(
    category: 'MISTAKES',
    tagType: 'Common Mistakes',
    rule: "'Let's' -> tag must be 'shall we?' (not 'will we?')",
    promptSentence: "Let's start, ___ we?",
    targetWord: 'shall',
    acceptableWords: ['shall we'],
    fullSentence: "Let's start, shall we?",
    localizedHints: {
      'Malayalam': "Common mistake: 'Let's' -> 'will we?' parayilla. Correct: 'shall we?'",
      'Tamil':     "Tappai: 'Let's' -> 'will we?' payanpaduthamal. 'shall we?' correct.",
      'Hindi':     "Galti: 'Let's' ke baad 'will we?' nahi — 'shall we?' sahi hai.",
      'Telugu':    "Tappu: 'Let's' -> 'will we?' kaadu. 'shall we?' correct.",
      'Kannada':   "Tappu: 'Let's' -> 'will we?' alla. 'shall we?' correct.",
      'English':   "Common error: 'Let's' only takes 'shall we?' — never 'will we?'",
    },
    localizedTranslations: {
      'Malayalam': 'നമുക്ക് തുടങ്ങാം, ഓക്കെ?',
      'Tamil':     'தொடங்குவோம், சரியா?',
      'Hindi':     'चलो शुरू करते हैं, ठीक है?',
      'Telugu':    'మనం మొదలుపెడదాం, సరేనా?',
      'Kannada':   "ಪ್ರಾರಂಭಿಸೋಣ, ಆಗುತ್ತದೆಯೇ?",
      'English':   "Let's start, shall we?",
    },
  ),
];

/// ❓ Question Tags Practice Card
/// BASIC / TENSE / SPECIAL / MISTAKES — STT, TTS, 6-language support,
/// collapsible rules matrix, completion tracking.
class PocketQuestionTagsPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketQuestionTagsPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '14',
  });

  @override
  State<PocketQuestionTagsPracticeCard> createState() =>
      _PocketQuestionTagsPracticeCardState();
}

class _PocketQuestionTagsPracticeCardState
    extends State<PocketQuestionTagsPracticeCard>
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

  List<QuestionTagExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'BASIC':    return _kQuestionTagExercises.where((e) => e.category == 'BASIC').toList();
      case 'TENSE':    return _kQuestionTagExercises.where((e) => e.category == 'TENSE').toList();
      case 'SPECIAL':  return _kQuestionTagExercises.where((e) => e.category == 'SPECIAL').toList();
      case 'MISTAKES': return _kQuestionTagExercises.where((e) => e.category == 'MISTAKES').toList();
      default:         return _kQuestionTagExercises;
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
      case 'tamil':    return 'கேள்வி குறி வாக்கியங்கள் (Question Tags)';
      case 'telugu':   return 'ప్రశ్న ట్యాగ్‌లు (Question Tags)';
      case 'hindi':    return 'प्रश्न टैग वाक्य (Question Tags)';
      case 'kannada':  return 'ಪ್ರಶ್ನೆ ಟ್ಯಾಗ್‌ಗಳು (Question Tags)';
      case 'malayalam':
      default:         return 'ചോദ്യ ടാഗ് (Question Tags)';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'BASIC':    return const Color(0xFF818CF8); // indigo
      case 'TENSE':    return const Color(0xFF34D399); // emerald
      case 'SPECIAL':  return const Color(0xFFFBBF24); // amber
      case 'MISTAKES': return const Color(0xFFF87171); // red
      default:         return const Color(0xFFC084FC);
    }
  }

  Color _filterChipColor(String filter) {
    switch (filter) {
      case 'BASIC':    return const Color(0xFF818CF8);
      case 'TENSE':    return const Color(0xFF34D399);
      case 'SPECIAL':  return const Color(0xFFFBBF24);
      case 'MISTAKES': return const Color(0xFFF87171);
      default:         return const Color(0xFFC084FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();
    final safeIndex = _currentExerciseIndex.clamp(0, exercises.length - 1);
    final ex = exercises[safeIndex];
    final catColor = _categoryColor(ex.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF818CF8).withValues(alpha: 0.5),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF818CF8))
                .withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
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
                  _buildFilterChip('BASIC', 'BASIC (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('TENSE', 'TENSE (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('SPECIAL', 'SPECIAL (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('MISTAKES', 'MISTAKES (5)'),
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
                        "Question Tags Rules  (Basic → Tense → Special → Mistakes)",
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

          // ── CATEGORY BADGE ──
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
                    ex.tagType.toUpperCase(),
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
                  'STEP ${widget.stepNumber} • ❓ Question Tags',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 0.2),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedSubtitle(widget.selectedLanguage),
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: const Color(0xFF818CF8)),
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

  Widget _buildExerciseCard(QuestionTagExerciseItem ex, int index, int total, Color catColor) {
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
    final chipColor = _filterChipColor(value);
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
      ['Pattern', 'Tag Rule', 'Example'],
      ['Positive + neg tag', "Use flipped auxiliary: don't, isn't, won't", "You like it, don't you?"],
      ['Negative + pos tag', "Flip to positive: is, can, will", "She isn't late, is she?"],
      ['No auxiliary', "Use do/does (present) or did (past)", "You live here, don't you?"],
      ["I am", "Tag is 'aren't I?' (never 'amn't I?')", "I am ready, aren't I?"],
      ["Let's", "Tag is always 'shall we?'", "Let's go, shall we?"],
      ['Imperative', "Affirmative/negative -> 'will you?'", "Close the door, will you?"],
      ['Nothing/Nobody', "Negative meaning -> positive 'did it?'", "Nothing broke, did it?"],
    ];

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
                    ? const Color(0xFF818CF8).withValues(alpha: 0.12)
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
                    flex: colIdx == 1 ? 3 : colIdx == 2 ? 3 : 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text(
                        row[colIdx],
                        style: GoogleFonts.inter(
                          color: isHeader
                              ? const Color(0xFF818CF8)
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
