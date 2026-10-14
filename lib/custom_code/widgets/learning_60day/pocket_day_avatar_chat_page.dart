import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_pronunciation_evaluator.dart';
import 'pocket_fortress_defense_service.dart';
import 'games/pocket_20days_40games_spec.dart';
import 'games/pocket_universal_arcade_engine_page.dart';

/// 💬 Chat Message Model for Days 3 to 16 Unified Avatar Conversational Engine
class DayChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String textNative;
  final String? audioText;
  final Widget? cardContent;
  final List<DayInBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final bool isVoiceMessage;
  final DateTime timestamp;

  DayChatMessage({
    required this.id,
    required this.isAvatar,
    required this.textEn,
    this.textNative = '',
    this.audioText,
    this.cardContent,
    this.inBubbleOptions,
    this.speakThisPrompt,
    this.isVoiceMessage = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 🔘 In-Bubble Option Button (Strictly rendered inside avatar bubble under divider)
class DayInBubbleOption {
  final String labelEn;
  final String labelNative;
  final String? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  const DayInBubbleOption({
    required this.labelEn,
    this.labelNative = '',
    this.icon,
    this.backgroundColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlightedAnswer = false,
    required this.onTap,
  });
}

/// 🌟 Comprehensive Pedagogical Data Specification for Days 3 to 16
class DayCurriculumSpec {
  final int day;
  final String topicEmoji;
  final String titleEn;
  final String titleMl;
  final String greetingEn;
  final String greetingMl;
  final String greetingAudio;
  final String blueprintTitle;
  final String blueprintExplanationEn;
  final String blueprintExplanationMl;
  final List<Map<String, String>> blueprintRules;
  final List<Map<String, String>> drills;
  final List<Map<String, dynamic>> quizQuestions;

  const DayCurriculumSpec({
    required this.day,
    required this.topicEmoji,
    required this.titleEn,
    required this.titleMl,
    required this.greetingEn,
    required this.greetingMl,
    required this.greetingAudio,
    required this.blueprintTitle,
    required this.blueprintExplanationEn,
    required this.blueprintExplanationMl,
    required this.blueprintRules,
    required this.drills,
    required this.quizQuestions,
  });
}

/// 📚 Master Curriculum Registry for Days 3 to 16
class PocketDays3To16Registry {
  static final Map<int, DayCurriculumSpec> specs = {
    // -------------------------------------------------------------------------
    // DAY 3: Basic Nouns & Action Verbs (S-V-O Blueprint)
    // -------------------------------------------------------------------------
    3: const DayCurriculumSpec(
      day: 3,
      topicEmoji: '🐠',
      titleEn: 'Day 3: S-V-O Sentence Blueprint & Action Verbs',
      titleMl: 'ഡേ 3: ഇംഗ്ലീഷ് വാക്യഘടന (Subject + Verb + Object)',
      greetingEn: 'Welcome to Day 3! 🌟 Today we master the immutable English S-V-O Blueprint (Subject + Verb + Object) and everyday action verbs!',
      greetingMl: 'ഡേ 3 ലേക്ക് സ്വാഗതം! 🌟 ഇംഗ്ലീഷിലെ ഏറ്റവും പ്രധാനപ്പെട്ട S-V-O വാക്യഘടനയും ദൈനംദിന പ്രവർത്തികളും ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 3! Today we master the English Subject, Verb, and Object blueprint. Shall we begin?',
      blueprintTitle: 'S-V-O ACTION FORMULA',
      blueprintExplanationEn: 'In English, the verb immediately follows the subject: Subject ➔ Verb ➔ Object. Never say "I football play", always say "I play football"!',
      blueprintExplanationMl: 'മലയാളത്തിൽ ക്രിയ ഒടുവിലാണ് വരുന്നത് ("ഞാൻ ചോറ് തിന്നു"). എന്നാൽ ഇംഗ്ലീഷിൽ ക്രിയ എപ്പോഴും സബ്ജക്റ്റിന് തൊട്ടുപിന്നാലെ വരണം: "I eat rice".',
      blueprintRules: [
        {'subject': 'I / You / We / They', 'en': 'I read English books.', 'ml': 'ഞാൻ ഇംഗ്ലീഷ് പുസ്തകങ്ങൾ വായിക്കുന്നു.'},
        {'subject': 'He / She / It', 'en': 'She reads English books.', 'ml': 'അവൾ ഇംഗ്ലീഷ് പുസ്തകങ്ങൾ വായിക്കുന്നു (verb + s).'},
        {'subject': 'S-V-O Order', 'en': 'They build modern apps.', 'ml': 'അവർ ആപ്പുകൾ നിർമ്മിക്കുന്നു (They + build + apps).'},
      ],
      drills: [
        {'en': 'I eat breakfast every morning.', 'ml': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ പ്രഭാതഭക്ഷണം കഴിക്കുന്നു.', 'rule': 'S-V-O: I (Subject) + eat (Verb) + breakfast (Object)'},
        {'en': 'She reads books in the library.', 'ml': 'അവൾ ലൈബ്രറിയിൽ ഇരുന്ന് പുസ്തകങ്ങൾ വായിക്കുന്നു.', 'rule': 'S-V-O: She + reads + books'},
        {'en': 'They build modern mobile apps.', 'ml': 'അവർ ആധുനിക മൊബൈൽ ആപ്പുകൾ നിർമ്മിക്കുന്നു.', 'rule': 'S-V-O: They + build + apps'},
        {'en': 'We drink fresh water every day.', 'ml': 'ഞങ്ങൾ എല്ലാ ദിവസവും ശുദ്ധജലം കുടിക്കുന്നു.', 'rule': 'S-V-O: We + drink + water'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which sentence follows the correct English S-V-O order?',
          'qMl': 'ചോദ്യം 1: ശരിയായ വാക്യഘടന ഏതാണ്?',
          'audio': 'Question 1: Which sentence follows the correct English S-V-O order?',
          'correct': 'I play football every weekend.',
          'wrong': 'I football play every weekend.',
          'tip': 'Remember: Verb must come right after the subject (I play, not I football play)!',
        },
        {
          'qEn': 'Question 2: Complete the sentence: "She ___ tea every afternoon."',
          'qMl': 'ചോദ്യം 2: വിട്ടുപോയ വാക്ക് പൂരിപ്പിക്കുക: "She ___ tea every afternoon."',
          'audio': 'Question 2: Does She take drinks, or drink?',
          'correct': 'drinks',
          'wrong': 'drink',
          'tip': 'Third-person singular (He, She, It) adds -s to the verb: She drinks!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 4: Demonstratives (This, That, These, Those)
    // -------------------------------------------------------------------------
    4: const DayCurriculumSpec(
      day: 4,
      topicEmoji: '🏃',
      titleEn: 'Day 4: Demonstratives (This, That, These, Those)',
      titleMl: 'ഡേ 4: വസ്തുക്കളെ ചൂണ്ടിക്കാണിക്കാൻ This, That, These, Those',
      greetingEn: 'Hi there! Welcome to Day 4! 🌟 Today we master Demonstratives: how to point to things near and far with confidence!',
      greetingMl: 'ഡേ 4 ലേക്ക് സ്വാഗതം! 🌟 അടുത്തുള്ളതും അകലെയുള്ളതുമായ വസ്തുക്കളെ വ്യക്തമായി സൂചിപ്പിക്കാൻ This, That, These, Those പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 4! Today we master Demonstratives: This, That, These, and Those.',
      blueprintTitle: 'SPATIAL DEMONSTRATIVE GRID',
      blueprintExplanationEn: 'Use THIS for one thing near you, THAT for one thing far away. Use THESE for multiple things near you, and THOSE for multiple things far away.',
      blueprintExplanationMl: 'അടുത്തുള്ള ഒരെണ്ണത്തിന് This (ഇത്), അകലെയുള്ള ഒരെണ്ണത്തിന് That (അത്). അടുത്തുള്ള പലതിന് These (ഇവ), അകലെയുള്ള പലതിന് Those (അവ).',
      blueprintRules: [
        {'subject': 'Near + Singular', 'en': 'This is my laptop.', 'ml': 'ഇത് എന്റെ ലാപ്ടോപ്പാണ് (അടുത്തുള്ള ഒരെണ്ണം).'},
        {'subject': 'Far + Singular', 'en': 'That car is very fast.', 'ml': 'ആ കാർ വളരെ വേഗതയുള്ളതാണ് (അകലെയുള്ള ഒരെണ്ണം).'},
        {'subject': 'Near + Plural', 'en': 'These apples are fresh.', 'ml': 'ഈ ആപ്പിളുകൾ ഫ്രഷ് ആണ് (അടുത്തുള്ള പലത്).'},
        {'subject': 'Far + Plural', 'en': 'Those buildings are tall.', 'ml': 'ആ കാണുന്ന കെട്ടിടങ്ങൾ ഉയരമുള്ളതാണ് (അകലെയുള്ള പലത്).'},
      ],
      drills: [
        {'en': 'This is my favorite notebook.', 'ml': 'ഇത് എന്റെ പ്രിയപ്പെട്ട നോട്ട്ബുക്കാണ്.', 'rule': 'Demonstrative: This + is (Singular near)'},
        {'en': 'That car across the street is fast.', 'ml': 'അക്കരെയുള്ള ആ കാർ വേഗതയുള്ളതാണ്.', 'rule': 'Demonstrative: That + is (Singular far)'},
        {'en': 'These apples are sweet and fresh.', 'ml': 'ഈ ആപ്പിളുകൾ മധുരമുള്ളതും പുതിയതുമാണ്.', 'rule': 'Demonstrative: These + are (Plural near)'},
        {'en': 'Those buildings are very tall.', 'ml': 'ആ കാണുന്ന കെട്ടിടങ്ങൾ വളരെ ഉയരമുള്ളതാണ്.', 'rule': 'Demonstrative: Those + are (Plural far)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Pointing to multiple books on your own desk, which should you say?',
          'qMl': 'ചോദ്യം 1: നിങ്ങളുടെ മേശപ്പുറത്തിരിക്കുന്ന പുസ്തകങ്ങളെ എങ്ങനെ പറയും?',
          'audio': 'Question 1: For multiple books on your desk, is it These are my books, or This is my books?',
          'correct': 'These are my books.',
          'wrong': 'This are my books.',
          'tip': 'Plural items near you take "These are", never "This are"!',
        },
        {
          'qEn': 'Question 2: Pointing to an airplane high in the distant sky, say:',
          'qMl': 'ചോദ്യം 2: ആകാശത്ത് ദൂരെ പറക്കുന്ന വിമാനത്തെ എങ്ങനെ സൂചിപ്പിക്കും?',
          'audio': 'Question 2: Is it That plane, or These plane?',
          'correct': 'That plane is flying high.',
          'wrong': 'These plane is flying high.',
          'tip': 'A single distant object uses "That"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 5: Ownership & Possession (Have / Has)
    // -------------------------------------------------------------------------
    5: const DayCurriculumSpec(
      day: 5,
      topicEmoji: '🔑',
      titleEn: 'Day 5: Ownership & Possession (Have / Has)',
      titleMl: 'ഡേ 5: കൈവശമുള്ളത് പറയാൻ Have / Has',
      greetingEn: 'Welcome to Day 5! 🌟 Today we master expressing ownership with Have and Has—and eliminating the incorrect "am having" habit!',
      greetingMl: 'ഡേ 5 ലേക്ക് സ്വാഗതം! 🌟 ഉടമസ്ഥത പറയാൻ Have / Has എങ്ങനെ കൃത്യമായി ഉപയോഗിക്കാമെന്ന് ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 5! Today we master expressing ownership with Have and Has.',
      blueprintTitle: 'POSSESSION FORMULA',
      blueprintExplanationEn: 'Use HAVE for I, You, We, They. Use HAS for He, She, It. Never say "I am having two laptops" for physical possession—always say "I have"!',
      blueprintExplanationMl: 'I, You, We, They എന്നിവയ്‌ക്കൊപ്പം have. He, She, It എന്നിവയ്‌ക്കൊപ്പം has. കയ്യിലുള്ള വസ്തുവിന് "I am having" എന്ന് പറയരുത്, "I have" എന്ന് മാത്രം പറയുക.',
      blueprintRules: [
        {'subject': 'I / You / We / They', 'en': 'I have a new laptop.', 'ml': 'എനിക്ക് ഒരു പുതിയ ലാപ്ടോപ്പുണ്ട്.'},
        {'subject': 'He / She / It', 'en': 'She has a creative idea.', 'ml': 'അവളുടെ കയ്യിൽ നല്ലൊരു ആശയമുണ്ട്.'},
        {'subject': 'No "am having"!', 'en': 'We have enough time.', 'ml': 'നമ്മുടെ കയ്യിൽ ആവശ്യത്തിന് സമയമുണ്ട്.'},
      ],
      drills: [
        {'en': 'I have two brothers and one sister.', 'ml': 'എനിക്ക് രണ്ട് സഹോദരന്മാരും ഒരു സഹോദരിയും ഉണ്ട്.', 'rule': 'Possession: I + have'},
        {'en': 'She has a creative idea for our project.', 'ml': 'നമ്മുടെ പ്രൊജക്റ്റിനായി അവളുടെ കയ്യിൽ നല്ലൊരു ആശയമുണ്ട്.', 'rule': 'Possession: She + has'},
        {'en': 'He has an important meeting today.', 'ml': 'അവന് ഇന്ന് ഒരു പ്രധാനപ്പെട്ട മീറ്റിംഗ് ഉണ്ട്.', 'rule': 'Possession: He + has'},
        {'en': 'We have enough time to finish this work.', 'ml': 'ഈ ജോലി പൂർത്തിയാക്കാൻ നമ്മുടെ കയ്യിൽ ആവശ്യത്തിന് സമയമുണ്ട്.', 'rule': 'Possession: We + have'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which is the natural, correct way to state you own a car?',
          'qMl': 'ചോദ്യം 1: സ്വന്തമായി കാറുണ്ട് എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it I have a car, or I am having a car?',
          'correct': 'I have a car.',
          'wrong': 'I am having a car.',
          'tip': 'Never use "am having" for physical possession! Say "I have a car".',
        },
        {
          'qEn': 'Question 2: Complete: "Rahul ___ a meeting with his team."',
          'qMl': 'ചോദ്യം 2: രാഹുലിന് മീറ്റിംഗ് ഉണ്ട് എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 2: Does Rahul take has, or have?',
          'correct': 'has',
          'wrong': 'have',
          'tip': 'Singular names (Rahul, She, He) take "has"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 6: Daily Habits & Present Simple
    // -------------------------------------------------------------------------
    6: const DayCurriculumSpec(
      day: 6,
      topicEmoji: '⏰',
      titleEn: 'Day 6: Daily Habits & The Present Simple',
      titleMl: 'ഡേ 6: ദൈനംദിന ശീലങ്ങൾ പറയാൻ Simple Present Tense',
      greetingEn: 'Welcome to Day 6! 🌟 Today we master talking about daily routines, habits, and the golden third-person -s rule!',
      greetingMl: 'ഡേ 6 ലേക്ക് സ്വാഗതം! 🌟 ദിവസേനയുള്ള ശീലങ്ങളും ദിനചര്യകളും കൃത്യമായി പറയാൻ ഇന്ന് പരിശീലിക്കാം!',
      greetingAudio: 'Welcome to Day 6! Today we master daily habits and the Present Simple tense.',
      blueprintTitle: 'HABITUAL ACTION FORMULA',
      blueprintExplanationEn: 'Use the Simple Present for recurring daily habits. Remember: when talking about He, She, or It, always add -s or -es to the verb!',
      blueprintExplanationMl: 'ദിവസേന ആവർത്തിക്കുന്ന ശീലങ്ങൾക്ക് Simple Present ഉപയോഗിക്കുക. അവൻ (He), അവൾ (She) വരുമ്പോൾ ക്രിയയിൽ s അല്ലെങ്കിൽ es ചേർക്കുക (He works, She speaks).',
      blueprintRules: [
        {'subject': 'I / You / We / They', 'en': 'I wake up at six AM.', 'ml': 'ഞാൻ രാവിലെ 6 മണിക്ക് ഉണരുന്നു (base verb).'},
        {'subject': 'He / She / It', 'en': 'He works at a tech company.', 'ml': 'അവൻ ടെക് കമ്പനിയിൽ ജോലി ചെയ്യുന്നു (verb + s).'},
        {'subject': 'Daily Routine', 'en': 'They practice English daily.', 'ml': 'അവർ ദിവസേന ഇംഗ്ലീഷ് പരിശീലിക്കുന്നു.'},
      ],
      drills: [
        {'en': 'I wake up at six every morning.', 'ml': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ ആറു മണിക്ക് ഉണരുന്നു.', 'rule': 'Habit: I + wake up'},
        {'en': 'He works hard on his projects.', 'ml': 'അവൻ അവന്റെ പ്രൊജക്റ്റുകളിൽ കഠിനാധ്വാനം ചെയ്യുന്നു.', 'rule': 'Habit: He + works (third person -s)'},
        {'en': 'She speaks English with confidence.', 'ml': 'അവൾ ആത്മവിശ്വാസത്തോടെ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു.', 'rule': 'Habit: She + speaks'},
        {'en': 'They practice spoken English daily.', 'ml': 'അവർ ദിവസേന സ്പോക്കൺ ഇംഗ്ലീഷ് പരിശീലിക്കുന്നു.', 'rule': 'Habit: They + practice'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which is correct for describing John\'s daily habit?',
          'qMl': 'ചോദ്യം 1: ജോണിന്റെ ശീലം പറയാൻ ഏതാണ് ശരി?',
          'audio': 'Question 1: Is it John works hard, or John work hard?',
          'correct': 'John works hard every day.',
          'wrong': 'John work hard every day.',
          'tip': 'Singular subjects (John, He, She) require the -s ending: works!',
        },
        {
          'qEn': 'Question 2: Complete: "I ___ coffee every morning before work."',
          'qMl': 'ചോദ്യം 2: വിട്ടുപോയ വാക്ക് പൂരിപ്പിക്കുക: "I ___ coffee every morning."',
          'audio': 'Question 2: Does I take drink, or drinks?',
          'correct': 'drink',
          'wrong': 'drinks',
          'tip': 'First-person "I" takes the base verb: "I drink", not "I drinks"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 7: Present Negative (Don't / Doesn't)
    // -------------------------------------------------------------------------
    7: const DayCurriculumSpec(
      day: 7,
      topicEmoji: '🛑',
      titleEn: 'Day 7: Present Negative (Don\'t / Doesn\'t)',
      titleMl: 'ഡേ 7: ചെയ്യുന്നില്ല എന്ന് പറയാൻ Don\'t / Doesn\'t',
      greetingEn: 'Welcome to Day 7! 🌟 Today we master negation: using Don\'t and Doesn\'t correctly without double-marking verbs!',
      greetingMl: 'ഡേ 7 ലേക്ക് സ്വാഗതം! 🌟 ഒരു കാര്യം ചെയ്യുന്നില്ല എന്ന് വ്യക്തമായി പറയാൻ Don\'t / Doesn\'t ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 7! Today we master the Present Negative with Don\'t and Doesn\'t.',
      blueprintTitle: 'NEGATION BLUEPRINT',
      blueprintExplanationEn: 'Use DON\'T with I, You, We, They. Use DOESN\'T with He, She, It. Critical rule: when using doesn\'t, the verb resets to base form (He doesn\'t like, NOT doesn\'t likes)!',
      blueprintExplanationMl: 'I, You, We, They എന്നിവയ്‌ക്കൊപ്പം don\'t. He, She, It എന്നിവയ്‌ക്കൊപ്പം doesn\'t. Doesn\'t വന്നുകഴിഞ്ഞാൽ പ്രധാന ക്രിയയിൽ വീണ്ടും s ചേർക്കരുത് (He doesn\'t know, NOT knows)!',
      blueprintRules: [
        {'subject': 'I / You / We / They', 'en': 'I don\'t drink cold soda.', 'ml': 'ഞാൻ തണുത്ത പാനീയങ്ങൾ കുടിക്കാറില്ല.'},
        {'subject': 'He / She / It', 'en': 'He doesn\'t eat junk food.', 'ml': 'അവൻ ജങ്ക് ഫുഡ് കഴിക്കാറില്ല (doesn\'t + base verb).'},
        {'subject': 'No Double-S!', 'en': 'She doesn\'t work on Sundays.', 'ml': 'അവൾ ഞായറാഴ്ചകളിൽ ജോലി ചെയ്യാറില്ല.'},
      ],
      drills: [
        {'en': 'I don\'t waste time on unproductive things.', 'ml': 'ഞാൻ പ്രയോജനമില്ലാത്ത കാര്യങ്ങളിൽ സമയം കളയാറില്ല.', 'rule': 'Negative: I + don\'t + base verb'},
        {'en': 'He doesn\'t drink cold drinks.', 'ml': 'അവൻ തണുത്ത പാനീയങ്ങൾ കുടിക്കാറില്ല.', 'rule': 'Negative: He + doesn\'t + drink (no -s)'},
        {'en': 'She doesn\'t give up easily.', 'ml': 'അവൾ ഒരിക്കലും എളുപ്പത്തിൽ പിന്മാറാറില്ല.', 'rule': 'Negative: She + doesn\'t + give up'},
        {'en': 'We don\'t fear making mistakes.', 'ml': 'തെറ്റുകൾ വരുത്താൻ ഞങ്ങൾ ഒട്ടും ഭയപ്പെടുന്നില്ല.', 'rule': 'Negative: We + don\'t + fear'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which sentence correctly negates He likes tea?',
          'qMl': 'ചോദ്യം 1: "He likes tea" എന്നതിന്റെ ശരിയായ നെഗറ്റീവ് രൂപം ഏതാണ്?',
          'audio': 'Question 1: Is it He doesn\'t like tea, or He doesn\'t likes tea?',
          'correct': 'He doesn\'t like tea.',
          'wrong': 'He doesn\'t likes tea.',
          'tip': 'After "doesn\'t", the verb resets to base form: "like", not "likes"!',
        },
        {
          'qEn': 'Question 2: Complete: "They ___ know the answer yet."',
          'qMl': 'ചോദ്യം 2: "They ___ know the answer yet."',
          'audio': 'Question 2: Does They take don\'t, or doesn\'t?',
          'correct': 'don\'t',
          'wrong': 'doesn\'t',
          'tip': 'Plural subjects (They, We, You) take "don\'t"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 8: Asking Questions (Do / Does)
    // -------------------------------------------------------------------------
    8: const DayCurriculumSpec(
      day: 8,
      topicEmoji: '❓',
      titleEn: 'Day 8: Asking Questions (Do / Does)',
      titleMl: 'ഡേ 8: സംശയങ്ങളും ചോദ്യങ്ങളും ചോദിക്കാൻ Do / Does',
      greetingEn: 'Welcome to Day 8! 🌟 Today we master forming natural Yes/No questions using Do and Does inversion!',
      greetingMl: 'ഡേ 8 ലേക്ക് സ്വാഗതം! 🌟 Do, Does ഉപയോഗിച്ച് ഇംഗ്ലീഷിൽ സ്വാഭാവികമായി ചോദ്യങ്ങൾ ചോദിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 8! Today we learn how to ask confident questions with Do and Does.',
      blueprintTitle: 'QUESTION INVERSION FORMULA',
      blueprintExplanationEn: 'English questions do not just raise vocal pitch; they require placing Do or Does in front of the subject: Do/Does + Subject + Base Verb?',
      blueprintExplanationMl: 'വെറുതെ ടോൺ ഉയർത്തിയാൽ ഇംഗ്ലീഷിൽ ചോദ്യമാകില്ല ("You know him?"). "Do you know him?" എന്ന് Do അല്ലെങ്കിൽ Does മുന്നിൽ ചേർത്ത് തന്നെ ചോദിക്കണം.',
      blueprintRules: [
        {'subject': 'Do + I/You/We/They', 'en': 'Do you speak English?', 'ml': 'നിങ്ങൾ ഇംഗ്ലീഷ് സംസാരിക്കാറുണ്ടോ?'},
        {'subject': 'Does + He/She/It', 'en': 'Does he live in Kochi?', 'ml': 'അവൻ കൊച്ചിയിലാണോ താമസിക്കുന്നത്?'},
        {'subject': 'Base Verb Rule', 'en': 'Does she work here?', 'ml': 'അവൾ ഇവിടെയാണോ ജോലി ചെയ്യുന്നത് (work, not works)?'},
      ],
      drills: [
        {'en': 'Do you like to learn new languages?', 'ml': 'നിങ്ങൾക്ക് പുതിയ ഭാഷകൾ പഠിക്കാൻ ഇഷ്ടമാണോ?', 'rule': 'Question: Do + you + like'},
        {'en': 'Does he work at your office?', 'ml': 'അവൻ നിങ്ങളുടെ ഓഫീസിലാണോ ജോലി ചെയ്യുന്നത്?', 'rule': 'Question: Does + he + work (base verb)'},
        {'en': 'Do they live near the city?', 'ml': 'അവർ നഗരത്തിന് അടുത്താണോ താമസിക്കുന്നത്?', 'rule': 'Question: Do + they + live'},
        {'en': 'Does she understand our plan?', 'ml': 'നമ്മുടെ പദ്ധതി അവൾക്ക് മനസ്സിലായോ?', 'rule': 'Question: Does + she + understand'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: How do you politely ask a colleague if they drink coffee?',
          'qMl': 'ചോദ്യം 1: നിങ്ങൾ കാപ്പി കുടിക്കാറുണ്ടോ എന്ന് എങ്ങനെ ചോദിക്കും?',
          'audio': 'Question 1: Is it Do you drink coffee, or You drink coffee?',
          'correct': 'Do you drink coffee?',
          'wrong': 'You drink coffee?',
          'tip': 'Always invert with the helper verb "Do": "Do you drink coffee?"',
        },
        {
          'qEn': 'Question 2: Complete the question: "___ Sarah have a car?"',
          'qMl': 'ചോദ്യം 2: സാറയ്ക്ക് കാറുണ്ടോ എന്ന് ചോദിക്കാൻ:',
          'audio': 'Question 2: Does Sarah take Does, or Do?',
          'correct': 'Does',
          'wrong': 'Do',
          'tip': 'Singular third-person names take "Does"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 9: WH Questions (Who, What, Where, When, Why, How)
    // -------------------------------------------------------------------------
    9: const DayCurriculumSpec(
      day: 9,
      topicEmoji: '🔍',
      titleEn: 'Day 9: WH Questions (Who, What, Where, When, Why, How)',
      titleMl: 'ഡേ 9: കൂടുതൽ വിവരങ്ങൾ ചോദിച്ചറിയാൻ WH Questions',
      greetingEn: 'Welcome to Day 9! 🌟 Today we master the 6 master inquiry keys: Who, What, Where, When, Why, and How!',
      greetingMl: 'ഡേ 9 ലേക്ക് സ്വാഗതം! 🌟 സംഭാഷണങ്ങളെ നയിക്കാൻ സഹായിക്കുന്ന 6 പ്രധാന ചോദ്യവാക്കുകൾ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 9! Today we master the six master inquiry keys: Who, What, Where, When, Why, and How.',
      blueprintTitle: 'THE 6 MASTER INQUIRY KEYS',
      blueprintExplanationEn: 'Pattern: WH Word + Helper (do/does/is/are) + Subject + Verb? (e.g., Where + do + you + live?). Never say "Where you are going?", say "Where are you going?"!',
      blueprintExplanationMl: 'WH ചോദ്യങ്ങളുടെ ക്രമം: WH വാക്ക് + സഹായക്രിയ + സബ്ജക്റ്റ് + പ്രധാന ക്രിയ. "Where you go?" എന്ന് തെറ്റായി ചോദിക്കരുത്, "Where do you go?" എന്ന് ചോദിക്കുക.',
      blueprintRules: [
        {'subject': 'Where / When', 'en': 'Where do you work?', 'ml': 'നിങ്ങൾ എവിടെയാണ് ജോലി ചെയ്യുന്നത്?'},
        {'subject': 'Why / What', 'en': 'Why do you study English?', 'ml': 'നിങ്ങൾ എന്തിനാണ് ഇംഗ്ലീഷ് പഠിക്കുന്നത്?'},
        {'subject': 'How / Who', 'en': 'How do you commute to office?', 'ml': 'നിങ്ങൾ എങ്ങനെയാണ് ഓഫീസിലേക്ക് പോകുന്നത്?'},
      ],
      drills: [
        {'en': 'Where do you work every day?', 'ml': 'നിങ്ങൾ എവിടെയാണ് ജോലി ചെയ്യുന്നത്?', 'rule': 'WH Question: Where + do + you + work'},
        {'en': 'What are your primary goals for this year?', 'ml': 'ഈ വർഷത്തെ നിങ്ങളുടെ പ്രധാന ലക്ഷ്യങ്ങൾ എന്തൊക്കെയാണ്?', 'rule': 'WH Question: What + are + your goals'},
        {'en': 'Why do you want to master English?', 'ml': 'നിങ്ങൾക്ക് എന്തിനാണ് ഇംഗ്ലീഷ് നന്നായി സംസാരിക്കാൻ ആഗ്രഹം?', 'rule': 'WH Question: Why + do + you + want'},
        {'en': 'How do you manage your daily schedule?', 'ml': 'നിങ്ങൾ എങ്ങനെയാണ് നിങ്ങളുടെ ദൈനംദിന ഷെഡ്യൂൾ ക്രമീകരിക്കുന്നത്?', 'rule': 'WH Question: How + do + you + manage'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which is the correct way to ask where someone lives?',
          'qMl': 'ചോദ്യം 1: എവിടെയാണ് താമസിക്കുന്നത് എന്ന് ചോദിക്കാൻ ശരിയായ രൂപം ഏതാണ്?',
          'audio': 'Question 1: Is it Where do you live, or Where you live?',
          'correct': 'Where do you live?',
          'wrong': 'Where you live?',
          'tip': 'WH questions require the auxiliary verb: "Where DO you live?"',
        },
        {
          'qEn': 'Question 2: Complete: "Why ___ you come late today?"',
          'qMl': 'ചോദ്യം 2: "Why ___ you come late today?"',
          'audio': 'Question 2: Is it did, or was?',
          'correct': 'did',
          'wrong': 'was',
          'tip': 'Past action inquiry uses helper "did": "Why did you come late?"',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 10: Describing Places (There is / There are)
    // -------------------------------------------------------------------------
    10: const DayCurriculumSpec(
      day: 10,
      topicEmoji: '🏡',
      titleEn: 'Day 10: Describing Places (There is / There are)',
      titleMl: 'ഡേ 10: ഒരു സ്ഥലത്ത് ഉള്ള കാര്യങ്ങൾ പറയാൻ There is / There are',
      greetingEn: 'Welcome to Day 10! 🌟 Today we reach our golden milestone: describing places, offices, and rooms with There is and There are!',
      greetingMl: 'ഡേ 10 ലേക്ക് സ്വാഗതം! 🌟 പത്താം ദിവസത്തെ സുവർണ്ണ നാഴികക്കല്ലിൽ എത്തിയ നിങ്ങൾക്ക് അഭിനന്ദനങ്ങൾ! ഒരു സ്ഥലത്ത് ഉള്ള കാര്യങ്ങൾ പറയാൻ There is / are ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 10! Today we reach a golden milestone: describing places with There is and There are.',
      blueprintTitle: 'EXISTENTIAL PLACE BLUEPRINT',
      blueprintExplanationEn: 'Use "There is" for one item (singular), and "There are" for multiple items (plural). Never say "In my room have a table"—always say "There is a table in my room"!',
      blueprintExplanationMl: 'ഒരു സ്ഥലത്ത് ഒരെണ്ണം ഉണ്ട് എന്ന് പറയാൻ "There is", ഒന്നിൽക്കൂടുതൽ ഉണ്ട് എന്ന് പറയാൻ "There are". "Room have table" എന്ന് പറയരുത്, "There is a table in the room" എന്ന് പറയുക.',
      blueprintRules: [
        {'subject': 'Singular Existence', 'en': 'There is a laptop on the desk.', 'ml': 'മേശപ്പുറത്ത് ഒരു ലാപ്ടോപ്പുണ്ട് (There is).'},
        {'subject': 'Plural Existence', 'en': 'There are many cars on the road.', 'ml': 'റോഡിൽ നിരവധി കാറുകളുണ്ട് (There are).'},
        {'subject': 'Negation', 'en': 'There is no problem at all.', 'ml': 'യാതൊരു പ്രശ്നവുമില്ല (There is no).'},
      ],
      drills: [
        {'en': 'There is a quiet library near my house.', 'ml': 'എന്റെ വീടിനടുത്ത് ശാന്തമായ ഒരു ലൈബ്രറിയുണ്ട്.', 'rule': 'Existence: There is + singular noun'},
        {'en': 'There are many tall trees in this park.', 'ml': 'ഈ പാർക്കിൽ നിരവധി വലിയ മരങ്ങളുണ്ട്.', 'rule': 'Existence: There are + plural noun'},
        {'en': 'There is a great opportunity waiting for us.', 'ml': 'നമുക്കായി വലിയൊരു അവസരം കാത്തിരിക്കുന്നുണ്ട്.', 'rule': 'Existence: There is + singular'},
        {'en': 'There are five members in my project team.', 'ml': 'എന്റെ പ്രൊജക്റ്റ് ടീമിൽ അഞ്ച് അംഗങ്ങളുണ്ട്.', 'rule': 'Existence: There are + plural'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing two chairs in a room, say:',
          'qMl': 'ചോദ്യം 1: മുറിയിൽ രണ്ട് കസേരകൾ ഉണ്ട് എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it There are two chairs, or There is two chairs?',
          'correct': 'There are two chairs in the room.',
          'wrong': 'There is two chairs in the room.',
          'tip': 'Plural count (two chairs) takes "There are", not "There is"!',
        },
        {
          'qEn': 'Question 2: Describing a water bottle on the table, say:',
          'qMl': 'ചോദ്യം 2: മേശപ്പുറത്ത് ഒരു വാട്ടർ ബോട്ടിൽ ഉണ്ട് എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it There is a water bottle, or Table has bottle?',
          'correct': 'There is a water bottle on the table.',
          'wrong': 'Table has a water bottle.',
          'tip': 'Natural English uses "There is a water bottle on the table"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 11: Prepositions of Place & Time (In, On, At)
    // -------------------------------------------------------------------------
    11: const DayCurriculumSpec(
      day: 11,
      topicEmoji: '📍',
      titleEn: 'Day 11: Prepositions of Place & Time (In, On, At)',
      titleMl: 'ഡേ 11: സമയവും സ്ഥലവും കൃത്യമായി സൂചിപ്പിക്കാൻ In, On, At',
      greetingEn: 'Welcome to Day 11! 🌟 Today we conquer the In-On-At preposition triangle for absolute precision in space and time!',
      greetingMl: 'ഡേ 11 ലേക്ക് സ്വാഗതം! 🌟 സ്ഥലവും സമയവും തെറ്റുകൂടാതെ കൃത്യമായി പറയാൻ In, On, At എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 11! Today we conquer the In, On, and At preposition triangle.',
      blueprintTitle: 'THE IN-ON-AT PYRAMID',
      blueprintExplanationEn: 'IN is broadest (months, years, cities, enclosed spaces). ON is more specific (days, dates, flat surfaces). AT is exact (precise hours, exact street addresses, specific points).',
      blueprintExplanationMl: 'കൃത്യമായ സമയത്തിന് At (at 5 PM, at home). ദിവസങ്ങൾക്കും പ്രതലങ്ങൾക്കും On (on Monday, on the table). മാസങ്ങൾക്കും നഗരങ്ങൾക്കും In (in October, in Kochi).',
      blueprintRules: [
        {'subject': 'At (Exact Time/Spot)', 'en': 'The meeting starts at 9 AM.', 'ml': 'മീറ്റിംഗ് കൃത്യം 9 മണിക്ക് ആരംഭിക്കുന്നു.'},
        {'subject': 'On (Days & Surfaces)', 'en': 'We will meet on Sunday.', 'ml': 'ഞങ്ങൾ ഞായറാഴ്ച കാണും (on Sunday).'},
        {'subject': 'In (Months & Cities)', 'en': 'She lives in Kerala.', 'ml': 'അവൾ കേരളത്തിലാണ് താമസിക്കുന്നത് (in Kerala).'},
      ],
      drills: [
        {'en': 'The morning meeting starts at nine sharp.', 'ml': 'പ്രഭാത മീറ്റിംഗ് കൃത്യം ഒൻപത് മണിക്ക് ആരംഭിക്കും.', 'rule': 'Preposition: at + exact hour'},
        {'en': 'I will meet my friends on Sunday.', 'ml': 'ഞാൻ ഞായറാഴ്ച എന്റെ സുഹൃത്തുക്കളെ കാണും.', 'rule': 'Preposition: on + day of week'},
        {'en': 'My laptop is on the study table.', 'ml': 'എന്റെ ലാപ്ടോപ്പ് പഠന മേശപ്പുറത്തുണ്ട്.', 'rule': 'Preposition: on + surface'},
        {'en': 'She lives in Kerala with her parents.', 'ml': 'അവൾ മാതാപിതാക്കളോടൊപ്പം കേരളത്തിലാണ് താമസിക്കുന്നത്.', 'rule': 'Preposition: in + region/state'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Scheduling an appointment on Friday, say:',
          'qMl': 'ചോദ്യം 1: വെള്ളിയാഴ്ച കാണാം എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it on Friday, or in Friday?',
          'correct': 'I will see you on Friday.',
          'wrong': 'I will see you in Friday.',
          'tip': 'Days of the week always take preposition "on" (on Friday)!',
        },
        {
          'qEn': 'Question 2: The train arrives ___ 4:30 PM.',
          'qMl': 'ചോദ്യം 2: "The train arrives ___ 4:30 PM."',
          'audio': 'Question 2: Does exact time take at, or on?',
          'correct': 'at',
          'wrong': 'on',
          'tip': 'Precise times of day always take "at" (at 4:30 PM)!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 12: Vivid Adjectives & Describing People
    // -------------------------------------------------------------------------
    12: const DayCurriculumSpec(
      day: 12,
      topicEmoji: '🎨',
      titleEn: 'Day 12: Vivid Adjectives & Describing People',
      titleMl: 'ഡേ 12: വ്യക്തികളെയും ഗുണങ്ങളെയും വർണ്ണിക്കാൻ Adjectives',
      greetingEn: 'Welcome to Day 12! 🌟 Today we master descriptive English with vivid adjectives, giving rich color to people and ideas!',
      greetingMl: 'ഡേ 12 ലേക്ക് സ്വാഗതം! 🌟 വ്യക്തികളുടെ സ്വഭാവവും ഗുണങ്ങളും മനോഹരമായി വർണ്ണിക്കാൻ Adjectives ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 12! Today we master vivid adjectives to describe people and qualities.',
      blueprintTitle: 'ADJECTIVE PLACEMENT BLUEPRINT',
      blueprintExplanationEn: 'In English, descriptive adjectives go BEFORE the noun ("a brilliant coder", not "a coder brilliant") or after linking verbs ("She is intelligent").',
      blueprintExplanationMl: 'ഇംഗ്ലീഷിൽ വിശേഷണങ്ങൾ നാമത്തിന് തൊട്ടുമുന്നിലാണ് വരുന്നത്: "an intelligent developer" (അല്ലാതെ developer intelligent എന്നല്ല).',
      blueprintRules: [
        {'subject': 'Before Nouns', 'en': 'He is a hardworking engineer.', 'ml': 'അവൻ കഠിനാധ്വാനിയായ ഒരു എഞ്ചിനീയറാണ്.'},
        {'subject': 'After Linking Verbs', 'en': 'She is calm and confident.', 'ml': 'അവൾ ശാന്തയും ആത്മവിശ്വാസമുള്ളവളുമാണ്.'},
        {'subject': 'Sensory Descriptors', 'en': 'They designed a clean interface.', 'ml': 'അവർ വൃത്തിയുള്ള ഒരു ഇന്റർഫേസ് രൂപകൽപ്പന ചെയ്തു.'},
      ],
      drills: [
        {'en': 'He is an honest and hardworking developer.', 'ml': 'അവൻ സത്യസന്ധനും കഠിനാധ്വാനിയുമായ ഒരു ഡെവലപ്പറാണ്.', 'rule': 'Adjectives: honest and hardworking + noun'},
        {'en': 'She has a calm and welcoming personality.', 'ml': 'അവൾക്ക് ശാന്തവും ആകർഷകവുമായ ഒരു പെരുമാറ്റമുണ്ട്.', 'rule': 'Adjectives: calm and welcoming + personality'},
        {'en': 'They created a modern and clean application.', 'ml': 'അവർ ആധുനികവും വൃത്തിയുള്ളതുമായ ഒരു ആപ്ലിക്കേഷൻ ഉണ്ടാക്കി.', 'rule': 'Adjectives: modern and clean + application'},
        {'en': 'We faced a difficult challenge today.', 'ml': 'ഞങ്ങൾ ഇന്ന് കഠിനമായ ഒരു വെല്ലുവിളിയെ നേരിട്ടു.', 'rule': 'Adjective: difficult + challenge'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Which is the correct word order in English?',
          'qMl': 'ചോദ്യം 1: ശരിയായ ക്രമം ഏതാണ്?',
          'audio': 'Question 1: Is it an expensive phone, or a phone expensive?',
          'correct': 'I bought an expensive phone.',
          'wrong': 'I bought a phone expensive.',
          'tip': 'Adjectives always precede the noun: "expensive phone"!',
        },
        {
          'qEn': 'Question 2: Complete: "She gave a very ___ presentation."',
          'qMl': 'ചോദ്യം 2: "She gave a very ___ presentation."',
          'audio': 'Question 2: Is it clear, or clearly?',
          'correct': 'clear',
          'wrong': 'clearly',
          'tip': '"Clear" is the adjective modifying presentation. "Clearly" is an adverb.',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 13: Dynamic Adverbs (Slowly, Quickly, Carefully)
    // -------------------------------------------------------------------------
    13: const DayCurriculumSpec(
      day: 13,
      topicEmoji: '⚡',
      titleEn: 'Day 13: Dynamic Adverbs (Manner & Frequency)',
      titleMl: 'ഡേ 13: ഒരു കാര്യം എങ്ങനെ ചെയ്യുന്നു എന്ന് പറയാൻ Adverbs',
      greetingEn: 'Welcome to Day 13! 🌟 Today we master adverbs of manner (-ly) and frequency, adding rhythm and tempo to your speaking!',
      greetingMl: 'ഡേ 13 ലേക്ക് സ്വാഗതം! 🌟 ഒരു പ്രവർത്തി എങ്ങനെ അല്ലെങ്കിൽ എത്ര തവണ ചെയ്യപ്പെടുന്നു എന്ന് വ്യക്തമാക്കാൻ Adverbs ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 13! Today we master dynamic adverbs of manner and frequency.',
      blueprintTitle: 'MANNER & FREQUENCY ADVERBS',
      blueprintExplanationEn: 'Adjectives describe things; adverbs describe HOW actions occur. Most manner adverbs end in -ly (slowly, carefully). Frequency adverbs (always, usually) sit before main verbs.',
      blueprintExplanationMl: 'ഒരു കാര്യം എങ്ങനെ ചെയ്യുന്നു എന്ന് പറയാനാണ് Adverbs ഉപയോഗിക്കുന്നത് (പതിയെ = slowly, ശ്രദ്ധയോടെ = carefully). "He drives slow" എന്നല്ല, "He drives slowly" എന്ന് പറയണം.',
      blueprintRules: [
        {'subject': 'Manner (-ly)', 'en': 'He drives very carefully.', 'ml': 'അവൻ വളരെ ശ്രദ്ധയോടെ വണ്ടി ഓടിക്കുന്നു.'},
        {'subject': 'Frequency', 'en': 'I always wake up early.', 'ml': 'ഞാൻ എപ്പോഴും നേരത്തെ ഉണരാറുണ്ട്.'},
        {'subject': 'Good vs Well', 'en': 'She speaks English well.', 'ml': 'അവൾ നന്നായി ഇംഗ്ലീഷ് സംസാരിക്കുന്നു (well is adverb).'},
      ],
      drills: [
        {'en': 'I practice speaking English consistently.', 'ml': 'ഞാൻ മുടങ്ങാതെ ദിവസവും ഇംഗ്ലീഷ് സംസാരിച്ചു പരിശീലിക്കുന്നു.', 'rule': 'Adverb of Manner: consistently'},
        {'en': 'He drives carefully on busy roads.', 'ml': 'തിരക്കുള്ള റോഡുകളിൽ അവൻ ശ്രദ്ധയോടെ വണ്ടി ഓടിക്കുന്നു.', 'rule': 'Adverb of Manner: carefully'},
        {'en': 'She solved the problem remarkably quickly.', 'ml': 'വളരെ വേഗത്തിൽ തന്നെ അവൾ ആ പ്രശ്നത്തിന് പരിഹാരം കണ്ടു.', 'rule': 'Adverbs: remarkably quickly'},
        {'en': 'They always arrive on time for meetings.', 'ml': 'മീറ്റിംഗുകൾക്ക് അവർ എപ്പോഴും കൃത്യസമയത്ത് തന്നെ എത്താറുണ്ട്.', 'rule': 'Adverb of Frequency: always'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing someone who drives with care, say:',
          'qMl': 'ചോദ്യം 1: ശ്രദ്ധയോടെ വണ്ടി ഓടിക്കുന്നു എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it He drives carefully, or He drives careful?',
          'correct': 'He drives carefully.',
          'wrong': 'He drives careful.',
          'tip': 'Verbs are modified by adverbs ending in -ly: "drives carefully"!',
        },
        {
          'qEn': 'Question 2: Which is correct for complimenting someone\'s speech?',
          'qMl': 'ചോദ്യം 2: ഇംഗ്ലീഷ് നന്നായി സംസാരിക്കുന്നു എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it You speak English well, or You speak English good?',
          'correct': 'You speak English well.',
          'wrong': 'You speak English good.',
          'tip': '"Well" is the adverb modifying speak. "Good" is an adjective.',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 14: Abilities & Permission (Can / Cannot)
    // -------------------------------------------------------------------------
    14: const DayCurriculumSpec(
      day: 14,
      topicEmoji: '💪',
      titleEn: 'Day 14: Abilities & Permission (Can / Cannot)',
      titleMl: 'ഡേ 14: കഴിവുകളും അനുവാദവും ചോദിക്കാൻ Can / Cannot',
      greetingEn: 'Welcome to Day 14! 🌟 Today we master expressing skills, abilities, and polite permission requests using Can and Can\'t!',
      greetingMl: 'ഡേ 14 ലേക്ക് സ്വാഗതം! 🌟 കഴിവും അനുവാദവും വളരെ ലളിതമായി വ്യക്തമാക്കാൻ Can, Cannot ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 14! Today we master expressing skills and polite requests with Can and Cannot.',
      blueprintTitle: 'MODALS OF CAPABILITY',
      blueprintExplanationEn: '"Can" never changes form (never say "cans" or "canning"). Always follow "can" directly with the base action verb WITHOUT "to" (I can swim, NOT I can to swim)!',
      blueprintExplanationMl: 'കഴിവ് പറയാൻ "Can" ഉം കഴിയില്ലെന്ന് പറയാൻ "Cannot/Can\'t" ഉം ഉപയോഗിക്കുന്നു. Can-ന് ശേഷം "to" ചേർക്കരുത് (I can swim, NOT I can to swim).',
      blueprintRules: [
        {'subject': 'Ability (Can)', 'en': 'I can speak English clearly.', 'ml': 'എനിക്ക് വ്യക്തമായി ഇംഗ്ലീഷ് സംസാരിക്കാൻ കഴിയും.'},
        {'subject': 'Inability (Can\'t)', 'en': 'He cannot come today.', 'ml': 'അവന് ഇന്ന് വരാൻ കഴിയില്ല.'},
        {'subject': 'Polite Request', 'en': 'Can you help me, please?', 'ml': 'എന്നെ ഒന്ന് സഹായിക്കാൻ സാധിക്കുമോ?'},
      ],
      drills: [
        {'en': 'I can speak English clearly now.', 'ml': 'എനിക്ക് ഇപ്പോൾ ഇംഗ്ലീഷ് വ്യക്തമായി സംസാരിക്കാൻ സാധിക്കുന്നുണ്ട്.', 'rule': 'Modal: I + can + base verb (no to)'},
        {'en': 'He can build mobile applications easily.', 'ml': 'അവന് മൊബൈൽ ആപ്പുകൾ എളുപ്പത്തിൽ നിർമ്മിക്കാൻ കഴിയും.', 'rule': 'Modal: He + can + build'},
        {'en': 'Can you help me with this task, please?', 'ml': 'ഈ ജോലിയിൽ എന്നെ ഒന്ന് സഹായിക്കാൻ സാധിക്കുമോ?', 'rule': 'Polite Request: Can + you + help'},
        {'en': 'She can solve complex coding problems.', 'ml': 'സങ്കീർണ്ണമായ കോഡിംഗ് പ്രശ്നങ്ങൾ പരിഹരിക്കാൻ അവൾക്ക് കഴിയും.', 'rule': 'Modal: She + can + solve'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating your ability to speak English, which is correct?',
          'qMl': 'ചോദ്യം 1: ഇംഗ്ലീഷ് സംസാരിക്കാൻ കഴിയും എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it I can speak English, or I can to speak English?',
          'correct': 'I can speak English.',
          'wrong': 'I can to speak English.',
          'tip': 'Never put "to" after the modal verb can! Say: "I can speak".',
        },
        {
          'qEn': 'Question 2: Complete: "She ___ play the piano beautifully."',
          'qMl': 'ചോദ്യം 2: "She ___ play the piano beautifully."',
          'audio': 'Question 2: Does She take can, or cans?',
          'correct': 'can',
          'wrong': 'cans',
          'tip': 'Modals never take -s! It is always "can", never "cans".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 15: Giving Advice & Guidance (Should / Shouldn't)
    // -------------------------------------------------------------------------
    15: const DayCurriculumSpec(
      day: 15,
      topicEmoji: '💡',
      titleEn: 'Day 15: Giving Advice & Guidance (Should / Shouldn\'t)',
      titleMl: 'ഡേ 15: നല്ല ഉപദേശങ്ങളും നിർദ്ദേശങ്ങളും നൽകാൻ Should / Shouldn\'t',
      greetingEn: 'Welcome to Day 15! 🌟 Today we master offering constructive advice, recommendations, and best practices with Should and Shouldn\'t!',
      greetingMl: 'ഡേ 15 ലേക്ക് സ്വാഗതം! 🌟 ആർക്കെങ്കിലും നല്ല ഉപദേശങ്ങൾ നൽകാനും കാര്യങ്ങൾ നിർദ്ദേശിക്കാനും Should / Shouldn\'t ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 15! Today we master giving constructive advice with Should and Shouldn\'t.',
      blueprintTitle: 'CONSTRUCTIVE ADVICE BLUEPRINT',
      blueprintExplanationEn: 'Use "should" to offer friendly, constructive recommendations without sounding bossy. Follow "should" directly with the base verb without "to" (You should sleep early)!',
      blueprintExplanationMl: 'ഒരു നല്ല കാര്യം നിർദ്ദേശിക്കാൻ "Should" (ചെയ്യണം), ഒഴിവാക്കേണ്ടതിന് "Shouldn\'t" (ചെയ്യരുത്). Should-ന് ശേഷം "to" ചേർക്കരുത്.',
      blueprintRules: [
        {'subject': 'Recommendation', 'en': 'You should drink more water.', 'ml': 'നിങ്ങൾ കൂടുതൽ വെള്ളം കുടിക്കണം.'},
        {'subject': 'Negative Advice', 'en': 'We shouldn\'t skip breakfast.', 'ml': 'നാം പ്രഭാതഭക്ഷണം ഒഴിവാക്കരുത്.'},
        {'subject': 'Team Advice', 'en': 'We should test our code thoroughly.', 'ml': 'നമ്മുടെ കോഡ് വിശദമായി ടെസ്റ്റ് ചെയ്യണം.'},
      ],
      drills: [
        {'en': 'You should drink plenty of water every day.', 'ml': 'നിങ്ങൾ ദിവസവും ധാരാളം വെള്ളം കുടിക്കണം.', 'rule': 'Advice: You + should + drink (base verb)'},
        {'en': 'We shouldn\'t skip our morning exercise.', 'ml': 'രാവിലത്തെ വ്യായാമം നാം ഒരിക്കലും ഒഴിവാക്കരുത്.', 'rule': 'Negative Advice: shouldn\'t + skip'},
        {'en': 'You should read English books for fifteen minutes.', 'ml': 'പതിനഞ്ചു മിനിറ്റെങ്കിലും നിങ്ങൾ ഇംഗ്ലീഷ് പുസ്തകങ്ങൾ വായിക്കണം.', 'rule': 'Recommendation: should + read'},
        {'en': 'They should review their work before submitting.', 'ml': 'സബ്മിറ്റ് ചെയ്യുന്നതിന് മുൻപ് അവർ ജോലി വീണ്ടും പരിശോധിക്കണം.', 'rule': 'Advice: should + review'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Advising a friend to get some rest, which is correct?',
          'qMl': 'ചോദ്യം 1: വിശ്രമിക്കാൻ സുഹൃത്തിനെ ഉപദേശിക്കാൻ ഏതാണ് ശരി?',
          'audio': 'Question 1: Is it You should take rest, or You should to take rest?',
          'correct': 'You should take rest.',
          'wrong': 'You should to take rest.',
          'tip': 'Never use "to" after should! Say: "You should take rest".',
        },
        {
          'qEn': 'Question 2: Complete: "You ___ stay up late before an exam."',
          'qMl': 'ചോദ്യം 2: പരീക്ഷയുടെ തലേന്ന് ഉറക്കമിളക്കരുത് എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it shouldn\'t, or don\'t should?',
          'correct': 'shouldn\'t',
          'wrong': 'don\'t should',
          'tip': 'Negative recommendation uses "shouldn\'t"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 16: Obligation & Rules (Must / Have to)
    // -------------------------------------------------------------------------
    16: const DayCurriculumSpec(
      day: 16,
      topicEmoji: '🛡️',
      titleEn: 'Day 16: Obligation & Rules (Must / Have to)',
      titleMl: 'ഡേ 16: നിർബന്ധമായ ചുമതലകളും നിയമങ്ങളും പറയാൻ Must / Have to',
      greetingEn: 'Welcome to Day 16! 🌟 Today we master expressing strict necessity, workplace responsibilities, and non-negotiable rules with Must and Have to!',
      greetingMl: 'ഡേ 16 ലേക്ക് സ്വാഗതം! 🌟 നിർബന്ധമായും പാലിക്കേണ്ട കാര്യങ്ങളും ഉത്തരവാദിത്തങ്ങളും വ്യക്തമായി പറയാൻ Must, Have to ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 16! Today we master expressing obligation and workplace rules with Must and Have to.',
      blueprintTitle: 'OBLIGATION & RESPONSIBILITY BLUEPRINT',
      blueprintExplanationEn: 'Use "have to" for external duties and deadlines ("I have to submit this today"). Use "must" for strong personal necessity or formal safety rules.',
      blueprintExplanationMl: 'ഓഫീസിലോ ജീവിതത്തിലോ നിർബന്ധമായും ചെയ്യേണ്ട കാര്യങ്ങൾക്ക് Must അല്ലെങ്കിൽ Have to ഉപയോഗിക്കുക (I have to finish this by 5 PM).',
      blueprintRules: [
        {'subject': 'External Duty', 'en': 'I have to submit the report today.', 'ml': 'എനിക്ക് ഇന്ന് റിപ്പോർട്ട് സമർപ്പിക്കേണ്ടതുണ്ട് (have to).'},
        {'subject': 'Strict Rule', 'en': 'Drivers must stop at red lights.', 'ml': 'ഡ്രൈവർമാർ റെഡ് ലൈറ്റിൽ വണ്ടി നിർത്തിയേ തീരൂ (must).'},
        {'subject': 'Prohibition', 'en': 'You must not smoke here.', 'ml': 'ഇവിടെ പുകവലിക്കാൻ പാടില്ല (must not).'},
      ],
      drills: [
        {'en': 'I must complete this task before five PM.', 'ml': 'വൈകുന്നേരം അഞ്ചു മണിക്ക് മുൻപ് എനിക്ക് ഈ ജോലി പൂർത്തിയാക്കിയേ തീരൂ.', 'rule': 'Obligation: must + complete'},
        {'en': 'We have to follow safety rules at all times.', 'ml': 'എല്ലാ സമയത്തും നാം സുരക്ഷാ നിയമങ്ങൾ പാലിക്കണം.', 'rule': 'Duty: have to + follow'},
        {'en': 'You must speak English every single day.', 'ml': 'എല്ലാ ദിവസവും നിങ്ങൾ നിർബന്ധമായും ഇംഗ്ലീഷ് സംസാരിക്കണം.', 'rule': 'Necessity: must + speak'},
        {'en': 'He has to travel to Kochi for the conference.', 'ml': 'കോൺഫറൻസിനായി അവന് കൊച്ചിയിലേക്ക് യാത്ര ചെയ്യേണ്ടതുണ്ട്.', 'rule': 'External Duty: has to + travel'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating a mandatory office rule about wearing an ID card:',
          'qMl': 'ചോദ്യം 1: ഐഡി കാർഡ് ധരിക്കൽ നിർബന്ധമാണ് എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it You must wear your ID card, or You must to wear your ID card?',
          'correct': 'You must wear your ID card.',
          'wrong': 'You must to wear your ID card.',
          'tip': 'Never use "to" after the modal must! Say: "You must wear".',
        },
        {
          'qEn': 'Question 2: Complete: "She ___ wake up at 5 AM for her morning flight."',
          'qMl': 'ചോദ്യം 2: ഫ്ലൈറ്റിനായി അവൾക്ക് പുലർച്ചെ 5 മണിക്ക് ഉണരേണ്ടതുണ്ട്:',
          'audio': 'Question 2: Does She take has to, or have to?',
          'correct': 'has to',
          'wrong': 'have to',
          'tip': 'Third-person singular (She, He) takes "has to"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 17: Talking About Yesterday (The Simple Past)
    // -------------------------------------------------------------------------
    17: const DayCurriculumSpec(
      day: 17,
      topicEmoji: '🏎️',
      titleEn: 'Day 17: Talking About Yesterday (The Simple Past)',
      titleMl: 'ഡേ 17: കഴിഞ്ഞുപോയ കാര്യങ്ങൾ പറയാൻ Simple Past Tense',
      greetingEn: 'Welcome to Day 17! 🌟 Today we master the Simple Past tense (V2) to talk about yesterday, completed actions, and past experiences with total confidence!',
      greetingMl: 'ഡേ 17 ലേക്ക് സ്വാഗതം! 🌟 ഇന്നലെ ചെയ്ത കാര്യങ്ങളും കഴിഞ്ഞുപോയ അനുഭവങ്ങളും ഇംഗ്ലീഷിൽ കൃത്യമായി പറയാൻ Simple Past Tense (V2) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 17! Today we master the Simple Past tense with regular and irregular verbs. Ready to begin?',
      blueprintTitle: 'COMPLETED ACTIONS FORMULA (V2)',
      blueprintExplanationEn: 'Use the Simple Past (V2 form of verb) for actions completed in finished past time (yesterday, last week). Regular verbs add -ed (worked, completed), while irregular verbs change form (go ➔ went, see ➔ saw, buy ➔ bought).',
      blueprintExplanationMl: 'കഴിഞ്ഞുപോയ കാര്യങ്ങൾക്ക് ക്രിയയുടെ രണ്ടാം രൂപം (V2) ഉപയോഗിക്കുക: "Yesterday I went to Kochi" (അല്ലാതെ I go എന്നല്ല). കഴിഞ്ഞ കാലത്തെ സൂചിപ്പിക്കുന്ന yesterday, last night എന്നിവയ്ക്കൊപ്പം V2 വരും.',
      blueprintRules: [
        {'subject': 'Regular Verbs (-ed)', 'en': 'I completed the project yesterday.', 'ml': 'ഞാൻ ഇന്നലെ പ്രോജക്ട് പൂർത്തിയാക്കി.'},
        {'subject': 'Irregular Verbs', 'en': 'She went to the office by train.', 'ml': 'അവൾ ട്രെയിനിലാണ് ഓഫീസിലേക്ക് പോയത് (go ➔ went).'},
        {'subject': 'Past of Be (Was/Were)', 'en': 'We were very busy last week.', 'ml': 'കഴിഞ്ഞ ആഴ്ച ഞങ്ങൾ വളരെ തിരക്കിലായിരുന്നു.'},
      ],
      drills: [
        {'en': 'Yesterday I completed three key tasks on time.', 'ml': 'ഇന്നലെ ഞാൻ മൂന്ന് പ്രധാന ജോലികൾ കൃത്യസമയത്ത് പൂർത്തിയാക്കി.', 'rule': 'Simple Past: completed (regular V2)'},
        {'en': 'She went to the market and bought fresh fruits.', 'ml': 'അവൾ മാർക്കറ്റിൽ പോയി പുതിയ പഴങ്ങൾ വാങ്ങി.', 'rule': 'Irregular Past: went and bought (V2)'},
        {'en': 'We saw an interesting tech presentation yesterday.', 'ml': 'ഇന്നലെ ഞങ്ങൾ ഒരു രസകരമായ സാങ്കേതിക പ്രസന്റേഷൻ കണ്ടു.', 'rule': 'Irregular Past: saw (V2 of see)'},
        {'en': 'He worked hard and achieved his quarterly goal.', 'ml': 'അവൻ കഠിനാധ്വാനം ചെയ്ത് തന്റെ ലക്ഷ്യം നേടി.', 'rule': 'Simple Past: worked and achieved'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing a trip to the market yesterday, say:',
          'qMl': 'ചോദ്യം 1: ഇന്നലെ മാർക്കറ്റിൽ പോയി എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it Yesterday I went to the market, or Yesterday I go to the market?',
          'correct': 'Yesterday I went to the market.',
          'wrong': 'Yesterday I go to the market.',
          'tip': 'Past actions in finished time require the V2 verb: "went", not "go"!',
        },
        {
          'qEn': 'Question 2: Which sentence correctly uses the past form of buy?',
          'qMl': 'ചോദ്യം 2: buy എന്ന വാക്കിന്റെ ശരിയായ പാസ്റ്റ് രൂപം ഏതാണ്?',
          'audio': 'Question 2: Is it She bought a new car, or She buyed a new car?',
          'correct': 'She bought a new car.',
          'wrong': 'She buyed a new car.',
          'tip': '"Buy" is irregular! Its past form is "bought", never "buyed".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 18: Inquiring About the Past (Did you...?)
    // -------------------------------------------------------------------------
    18: const DayCurriculumSpec(
      day: 18,
      topicEmoji: '🧟',
      titleEn: 'Day 18: Inquiring About the Past (Did you...?)',
      titleMl: 'ഡേ 18: കഴിഞ്ഞ കാര്യങ്ങൾ ചോദിക്കാൻ "Did you...?"',
      greetingEn: 'Welcome to Day 18! 🌟 Today we master asking about past actions using the auxiliary "Did" and the golden V1 base verb reset rule!',
      greetingMl: 'ഡേ 18 ലേക്ക് സ്വാഗതം! 🌟 കഴിഞ്ഞുപോയ കാര്യങ്ങൾ സംശയമില്ലാതെ ചോദിച്ചറിയാൻ "Did you...?" ഘടന ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 18! Today we master past questions using Did and the base verb reset rule.',
      blueprintTitle: 'THE "DID" RESET BLUEPRINT',
      blueprintExplanationEn: 'Because "Did" already shows the past tense, the main verb MUST be in its base form (V1). Never say "Did you went?", ALWAYS say "Did you go?"!',
      blueprintExplanationMl: 'കഴിഞ്ഞ കാര്യങ്ങൾ ചോദിക്കാൻ Did ഉപയോഗിക്കുമ്പോൾ പ്രധാന ക്രിയ എപ്പോഴും ആദ്യ രൂപത്തിൽ (V1) ആയിരിക്കണം: "Did you see?" (അല്ലാതെ Did you saw? എന്ന് ഒരിക്കലും പറയരുത്).',
      blueprintRules: [
        {'subject': 'Past Questions', 'en': 'Did you finish the report yesterday?', 'ml': 'നീ ഇന്നലെ റിപ്പോർട്ട് പൂർത്തിയാക്കിയോ?'},
        {'subject': 'Question Words', 'en': 'Where did they go for the conference?', 'ml': 'കോൺഫറൻസിനായി അവർ എവിടെയാണ് പോയത്?'},
        {'subject': 'Follow-up Inquiries', 'en': 'What did she say about the design?', 'ml': 'ഡിസൈനിനെക്കുറിച്ച് അവൾ എന്താണ് പറഞ്ഞത്?'},
      ],
      drills: [
        {'en': 'Did you finish your breakfast this morning?', 'ml': 'ഇന്ന് രാവിലെ നീ പ്രഭാതഭക്ഷണം കഴിച്ചോ?', 'rule': 'Past Question: Did + you + finish (V1 reset)'},
        {'en': 'Where did you go for the weekend trip?', 'ml': 'വീക്കെൻഡ് യാത്രയ്ക്കായി നിങ്ങൾ എവിടെയാണ് പോയത്?', 'rule': 'Wh- Question: Where did you go (V1)'},
        {'en': 'Did she receive the email I sent yesterday?', 'ml': 'ഇന്നലെ ഞാൻ അയച്ച ഇമെയിൽ അവൾക്ക് ലഭിച്ചോ?', 'rule': 'Auxiliary Did + base verb receive'},
        {'en': 'Why did you choose this learning course?', 'ml': 'എന്തുകൊണ്ടാണ് നിങ്ങൾ ഈ കോഴ്സ് തിരഞ്ഞെടുത്തത്?', 'rule': 'Wh- Question: Why did you choose'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Asking a friend if they went to the office yesterday:',
          'qMl': 'ചോദ്യം 1: സുഹൃത്ത് ഇന്നലെ ഓഫീസിൽ പോയോ എന്ന് ചോദിക്കാൻ:',
          'audio': 'Question 1: Is it Did you go to the office, or Did you went to the office?',
          'correct': 'Did you go to the office?',
          'wrong': 'Did you went to the office?',
          'tip': '"Did" already carries the past! The main verb resets to V1: "go"!',
        },
        {
          'qEn': 'Question 2: Complete: "What time did the train ___?"',
          'qMl': 'ചോദ്യം 2: "What time did the train ___?"',
          'audio': 'Question 2: Does it take arrive, or arrived?',
          'correct': 'arrive',
          'wrong': 'arrived',
          'tip': 'After "did", always use the base form "arrive"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 19: Past Negatives (I didn't...)
    // -------------------------------------------------------------------------
    19: const DayCurriculumSpec(
      day: 19,
      topicEmoji: '🎮',
      titleEn: 'Day 19: Past Negatives (I didn\'t...)',
      titleMl: 'ഡേ 19: കഴിഞ്ഞ കാര്യങ്ങൾ നിഷേധിക്കാൻ "I didn\'t..."',
      greetingEn: 'Welcome to Day 19! 🌟 Today we master expressing past negatives and clearing up misunderstandings with "didn\'t" + base verb!',
      greetingMl: 'ഡേ 19 ലേക്ക് സ്വാഗതം! 🌟 കഴിഞ്ഞകാലത്ത് ഒരു കാര്യം ചെയ്തില്ല അല്ലെങ്കിൽ സംഭവിച്ചില്ല എന്ന് വ്യക്തമായി പറയാൻ "I didn\'t..." ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 19! Today we master past negatives using didn\'t and base verbs.',
      blueprintTitle: 'PAST NEGATION BLUEPRINT',
      blueprintExplanationEn: 'To negate a past action, use "didn\'t" (did not) + base verb (V1). Never use past tense verbs after didn\'t ("I didn\'t know", NOT "I didn\'t knew").',
      blueprintExplanationMl: 'ഒരു കാര്യം ചെയ്തില്ല എന്ന് പറയാൻ Subject + didn\'t + Base Verb (V1) ഉപയോഗിക്കുക. "I didn\'t went" എന്ന് ഒരിക്കലും പറയരുത്, "I didn\'t go" എന്ന് പറയണം.',
      blueprintRules: [
        {'subject': 'Basic Negation', 'en': 'I didn\'t see the message yesterday.', 'ml': 'ഞാൻ ഇന്നലെ ആ മെസ്സേജ് കണ്ടില്ല.'},
        {'subject': 'Third Person Negation', 'en': 'She didn\'t attend the meeting.', 'ml': 'അവൾ മീറ്റിംഗിൽ പങ്കെടുത്തില്ല.'},
        {'subject': 'Explaining Reasons', 'en': 'We didn\'t know about the delay.', 'ml': 'ആ വൈകലിനെക്കുറിച്ച് ഞങ്ങൾ അറിഞ്ഞിരുന്നില്ല.'},
      ],
      drills: [
        {'en': 'I didn\'t receive the update until this morning.', 'ml': 'ഇന്ന് രാവിലെ വരെ എനിക്ക് ആ അപ്‌ഡേറ്റ് ലഭിച്ചില്ലായിരുന്നു.', 'rule': 'Past Negative: didn\'t + receive (V1)'},
        {'en': 'She didn\'t know about the schedule change.', 'ml': 'സമയമാറ്റത്തെക്കുറിച്ച് അവൾ അറിഞ്ഞിരുന്നില്ല.', 'rule': 'Negative: didn\'t + know (not knew)'},
        {'en': 'We didn\'t find any critical errors in the code.', 'ml': 'കോഡിൽ വലിയ തെറ്റുകളൊന്നും ഞങ്ങൾ കണ്ടെത്തിയില്ല.', 'rule': 'Negative: didn\'t + find (not found)'},
        {'en': 'He didn\'t come to the office yesterday.', 'ml': 'അവൻ ഇന്നലെ ഓഫീസിലേക്ക് വന്നില്ല.', 'rule': 'Negative: didn\'t + come (not came)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Saying you did not know about an announcement:',
          'qMl': 'ചോദ്യം 1: ഞാൻ അറിഞ്ഞിരുന്നില്ല എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it I didn\'t know, or I didn\'t knew?',
          'correct': 'I didn\'t know.',
          'wrong': 'I didn\'t knew.',
          'tip': 'Always use base verb after didn\'t: "didn\'t know"!',
        },
        {
          'qEn': 'Question 2: Complete: "She ___ come yesterday because she was unwell."',
          'qMl': 'ചോദ്യം 2: അവൾ ഇന്നലെ വന്നില്ല എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it didn\'t, or doesn\'t?',
          'correct': 'didn\'t',
          'wrong': 'doesn\'t',
          'tip': 'Past negative uses "didn\'t"! "Doesn\'t" is for present habits.',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 20: Future Plans & Spontaneous Decisions (Will)
    // -------------------------------------------------------------------------
    20: const DayCurriculumSpec(
      day: 20,
      topicEmoji: '🌍',
      titleEn: 'Day 20: Future Plans & Spontaneous Decisions (Will)',
      titleMl: 'ഡേ 20: ഭാവി തീരുമാനങ്ങളും വാഗ്ദാനങ്ങളും പറയാൻ "Will"',
      greetingEn: 'Welcome to Day 20! 🌟 Today we master the modal "will" for rapid on-the-spot decisions, promises, and future commitments!',
      greetingMl: 'ഡേ 20 ലേക്ക് സ്വാഗതം! 🌟 പെട്ടെന്നുള്ള തീരുമാനങ്ങൾ, വാഗ്ദാനങ്ങൾ, ഭാവി കാര്യങ്ങൾ എന്നിവ വ്യക്തമാക്കാൻ "Will" ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 20! Today we master expressing future decisions and promises with Will.',
      blueprintTitle: 'SPONTANEOUS FUTURE FORMULA',
      blueprintExplanationEn: 'Use "will" + base verb (V1) for decisions made at the moment of speaking ("I\'ll call you"), promises ("I will help"), and predictions. Never add -s or -ing after will!',
      blueprintExplanationMl: 'സംസാരിക്കുന്ന നിമിഷത്തിൽ എടുക്കുന്ന തീരുമാനങ്ങൾക്കും ഉറപ്പുകൾക്കും "will" ഉപയോഗിക്കുക: "I will call you back" (will-ന് ശേഷം ക്രിയയുടെ ആദ്യരൂപം മാത്രം).',
      blueprintRules: [
        {'subject': 'Instant Decision', 'en': 'I will send you the document right now.', 'ml': 'ഞാൻ ഇപ്പോൾ തന്നെ ആ രേഖ അയച്ചുതരാം.'},
        {'subject': 'Personal Promise', 'en': 'I will practice English every day.', 'ml': 'ഞാൻ എല്ലാ ദിവസവും ഇംഗ്ലീഷ് പരിശീലിക്കും.'},
        {'subject': 'Future Prediction', 'en': 'The weather will be pleasant tomorrow.', 'ml': 'നാളെ കാലാവസ്ഥ സുഖകരമായിരിക്കും.'},
      ],
      drills: [
        {'en': 'I will call you as soon as I arrive.', 'ml': 'ഞാൻ എത്തിയ ഉടൻ തന്നെ നിങ്ങളെ വിളിക്കാം.', 'rule': 'Spontaneous Decision: will + call'},
        {'en': 'We will improve our spoken English together.', 'ml': 'നമ്മൾ ഒരുമിച്ച് ഇംഗ്ലീഷ് സംസാരിക്കാൻ മെച്ചപ്പെടും.', 'rule': 'Future Commitment: will + improve'},
        {'en': 'She will join our team meeting tomorrow morning.', 'ml': 'നാളെ രാവിലെ അവൾ നമ്മുടെ ടീം മീറ്റിംഗിൽ പങ്കുചേരും.', 'rule': 'Future Plan: will + join'},
        {'en': 'I will help you solve this coding problem.', 'ml': 'ഈ കോഡിംഗ് പ്രശ്നം പരിഹരിക്കാൻ ഞാൻ നിന്നെ സഹായിക്കാം.', 'rule': 'Instant Offer: will + help'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Promising to call a colleague back shortly:',
          'qMl': 'ചോദ്യം 1: ഞാൻ ഉടൻ തിരിച്ചു വിളിക്കാം എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I will call you back, or I will calling you back?',
          'correct': 'I will call you back.',
          'wrong': 'I will calling you back.',
          'tip': 'Modals like "will" take the base verb directly: "will call"!',
        },
        {
          'qEn': 'Question 2: Which is correct for tomorrow\'s weather?',
          'qMl': 'ചോദ്യം 2: നാളെ മഴ പെയ്യും എന്ന് പറയാൻ ഏതാണ് ശരി?',
          'audio': 'Question 2: Is it It will rain tomorrow, or It will rains tomorrow?',
          'correct': 'It will rain tomorrow.',
          'wrong': 'It will rains tomorrow.',
          'tip': 'Never add -s to the verb after will! Say: "will rain".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 21: Planned Intentions (Going to)
    // -------------------------------------------------------------------------
    21: const DayCurriculumSpec(
      day: 21,
      topicEmoji: '🎯',
      titleEn: 'Day 21: Planned Intentions (Going to)',
      titleMl: 'ഡേ 21: നേരത്തെ ആസൂത്രണം ചെയ്ത കാര്യങ്ങൾക്ക് "Going to"',
      greetingEn: 'Welcome to Day 21! 🌟 Today we master expressing premeditated plans, intentions, and upcoming roadmaps with "am/is/are + going to"!',
      greetingMl: 'ഡേ 21 ലേക്ക് സ്വാഗതം! 🌟 മുൻകൂട്ടി തീരുമാനിച്ച പ്ലാനുകളും ഉദ്ദേശ്യങ്ങളും പറയാൻ "going to" ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 21! Today we master planned intentions using going to.',
      blueprintTitle: 'PLANNED FUTURE BLUEPRINT',
      blueprintExplanationEn: 'Use "am / is / are + going to + base verb" when you decided the action BEFORE the moment of speaking (pre-arranged plans). For example: "I am going to start a new project next week."',
      blueprintExplanationMl: 'നേരത്തെ തന്നെ പ്ലാൻ ചെയ്തുറപ്പിച്ച കാര്യങ്ങൾക്ക് am/is/are + going to + Verb ഉപയോഗിക്കുക (I am going to learn Flutter, She is going to travel).',
      blueprintRules: [
        {'subject': 'I (am)', 'en': 'I am going to buy a new laptop this weekend.', 'ml': 'ഈ വാരാന്ത്യത്തിൽ ഞാൻ പുതിയ ലാപ്ടോപ്പ് വാങ്ങാൻ പോകുന്നു.'},
        {'subject': 'He / She (is)', 'en': 'She is going to present the project tomorrow.', 'ml': 'അവൾ നാളെ പ്രോജക്ട് അവതരിപ്പിക്കാൻ പോകുന്നു.'},
        {'subject': 'We / They (are)', 'en': 'We are going to launch the mobile app soon.', 'ml': 'ഞങ്ങൾ ഉടൻ തന്നെ മൊബൈൽ ആപ്പ് ലോഞ്ച് ചെയ്യാൻ പോകുന്നു.'},
      ],
      drills: [
        {'en': 'I am going to practice English for thirty minutes.', 'ml': 'ഞാൻ മുപ്പത് മിനിറ്റ് ഇംഗ്ലീഷ് പരിശീലിക്കാൻ പോകുന്നു.', 'rule': 'Intention: am + going to + practice'},
        {'en': 'She is going to start a new job next month.', 'ml': 'അടുത്ത മാസം അവൾ പുതിയ ജോലി ആരംഭിക്കാൻ പോകുന്നു.', 'rule': 'Planned Future: is + going to + start'},
        {'en': 'We are going to build a useful mobile application.', 'ml': 'ഉപകാരപ്രദമായ ഒരു മൊബൈൽ ആപ്പ് നിർമ്മിക്കാൻ ഞങ്ങൾ പോകുന്നു.', 'rule': 'Team Plan: are + going to + build'},
        {'en': 'He is going to visit his grandparents this Sunday.', 'ml': 'ഈ ഞായറാഴ്ച അവൻ മുത്തശ്ശീമുത്തശ്ശന്മാരെ സന്ദർശിക്കാൻ പോകുന്നു.', 'rule': 'Plan: is + going to + visit'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing your pre-decided plan to travel next week:',
          'qMl': 'ചോദ്യം 1: അടുത്ത ആഴ്ച യാത്ര ചെയ്യാൻ പ്ലാൻ ചെയ്തിരിക്കുന്നു എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I am going to travel next week, or I going to travel next week?',
          'correct': 'I am going to travel next week.',
          'wrong': 'I going to travel next week.',
          'tip': 'Never forget the helper verb! Say "I am going to", not "I going to"!',
        },
        {
          'qEn': 'Question 2: Complete: "She ___ going to launch her startup next month."',
          'qMl': 'ചോദ്യം 2: "She ___ going to launch her startup next month."',
          'audio': 'Question 2: Does She take is, or are?',
          'correct': 'is',
          'wrong': 'are',
          'tip': 'Singular third person (She, He) takes "is"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 22: What is Happening Right Now (Present Continuous)
    // -------------------------------------------------------------------------
    22: const DayCurriculumSpec(
      day: 22,
      topicEmoji: '🏗️',
      titleEn: 'Day 22: What is Happening Right Now (Present Continuous)',
      titleMl: 'ഡേ 22: ഇപ്പോൾ നടക്കുന്ന കാര്യങ്ങൾ പറയാൻ Present Continuous',
      greetingEn: 'Welcome to Day 22! 🌟 Today we master the Present Continuous tense (am/is/are + verb-ing) to narrate live actions happening at this exact moment!',
      greetingMl: 'ഡേ 22 ലേക്ക് സ്വാഗതം! 🌟 ഇപ്പോൾ നിങ്ങളുടെ മുന്നിൽ സംഭവിച്ചുകൊണ്ടിരിക്കുന്ന കാര്യങ്ങൾ ലൈവായി പറയാൻ Present Continuous (am/is/are + ing) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 22! Today we master the Present Continuous tense for ongoing live actions.',
      blueprintTitle: 'LIVE MOMENT FORMULA',
      blueprintExplanationEn: 'Use "am / is / are + verb-ing" for actions in progress right now. Always pair the subject with its matching helper: I am, He/She is, We/They are!',
      blueprintExplanationMl: 'സംസാരിക്കുന്ന ഈ നിമിഷത്തിൽ നടക്കുന്ന കാര്യങ്ങൾക്ക് Present Continuous ഉപയോഗിക്കുക: "I am writing code now" (am/is/are വിട്ടുപോകരുത്).',
      blueprintRules: [
        {'subject': 'I (am)', 'en': 'I am speaking English right now.', 'ml': 'ഞാൻ ഇപ്പോൾ ഇംഗ്ലീഷ് സംസാരിച്ചുകൊണ്ടിരിക്കുകയാണ്.'},
        {'subject': 'Singular (is)', 'en': 'The software is compiling smoothly.', 'ml': 'സോഫ്റ്റ്‌വെയർ സുഗമമായി കംപൈൽ ചെയ്തുകൊണ്ടിരിക്കുന്നു.'},
        {'subject': 'Plural (are)', 'en': 'We are developing an innovative feature.', 'ml': 'ഞങ്ങൾ ഒരു പുതിയ ഫീച്ചർ വികസിപ്പിച്ചുകൊണ്ടിരിക്കുകയാണ്.'},
      ],
      drills: [
        {'en': 'I am learning new English phrases right now.', 'ml': 'ഞാൻ ഇപ്പോൾ പുതിയ ഇംഗ്ലീഷ് ശൈലികൾ പഠിച്ചുകൊണ്ടിരിക്കുകയാണ്.', 'rule': 'Present Continuous: am + learning'},
        {'en': 'She is writing clean code for the new feature.', 'ml': 'പുതിയ ഫീച്ചറിനായി അവൾ വൃത്തിയുള്ള കോഡ് എഴുതിക്കൊണ്ടിരിക്കുകയാണ്.', 'rule': 'Ongoing Action: is + writing'},
        {'en': 'They are testing the application on multiple devices.', 'ml': 'വിവിധ ഫോണുകളിൽ അവർ ആപ്ലിക്കേഷൻ പരിശോധിച്ച് കൊണ്ടിരിക്കുകയാണ്.', 'rule': 'Team Continuous: are + testing'},
        {'en': 'The team is preparing for the product demonstration.', 'ml': 'പ്രൊഡക്റ്റ് ഡെമോൺസ്ട്രേഷനായി ടീം തയ്യാറെടുത്തുകൊണ്ടിരിക്കുകയാണ്.', 'rule': 'Present Continuous: is + preparing'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing what you are currently doing:',
          'qMl': 'ചോദ്യം 1: ഞാൻ ഇപ്പോൾ കോഡ് എഴുതുകയാണ് എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I am writing code now, or I writing code now?',
          'correct': 'I am writing code now.',
          'wrong': 'I writing code now.',
          'tip': 'Always include the auxiliary "am": "I am writing"!',
        },
        {
          'qEn': 'Question 2: Complete: "He ___ working on fixing the bug at this moment."',
          'qMl': 'ചോദ്യം 2: അവൻ ഇപ്പോൾ ബഗ്ഗ് പരിഹരിക്കുകയാണ്:',
          'audio': 'Question 2: Does He take is, or are?',
          'correct': 'is',
          'wrong': 'are',
          'tip': 'He/She takes "is": "He is working"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 23: Past Interrupted Actions (Past Continuous)
    // -------------------------------------------------------------------------
    23: const DayCurriculumSpec(
      day: 23,
      topicEmoji: '🛸',
      titleEn: 'Day 23: Past Interrupted Actions (Past Continuous)',
      titleMl: 'ഡേ 23: മുൻപ് നടന്നുകൊണ്ടിരുന്നപ്പോൾ മറ്റൊന്ന് സംഭവിച്ചാൽ Past Continuous',
      greetingEn: 'Welcome to Day 23! 🌟 Today we master the Past Continuous tense (was/were + verb-ing) to set background scenes and describe interrupted actions!',
      greetingMl: 'ഡേ 23 ലേക്ക് സ്വാഗതം! 🌟 മുൻപ് ഒരു കാര്യം നടന്നുകൊണ്ടിരുന്നപ്പോൾ മറ്റൊന്ന് സംഭവിച്ചു എന്ന് വർണ്ണിക്കാൻ Past Continuous (was/were + ing + when) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 23! Today we master the Past Continuous tense to describe background and interrupted actions.',
      blueprintTitle: 'BACKGROUND & INTERRUPTION BLUEPRINT',
      blueprintExplanationEn: 'Use "was / were + verb-ing" for the ongoing background action, connected by "when" to a sudden Simple Past action ("I was coding when the power went out").',
      blueprintExplanationMl: 'നടന്നുകൊണ്ടിരുന്ന കാര്യത്തിന് was/were + ing ഉം പെട്ടെന്ന് സംഭവിച്ച കാര്യത്തിന് Simple Past ഉം ഉപയോഗിക്കുക ("I was studying when my phone rang").',
      blueprintRules: [
        {'subject': 'Singular (Was)', 'en': 'I was working when you called me.', 'ml': 'നീ എന്നെ വിളിച്ചപ്പോൾ ഞാൻ ജോലി ചെയ്തുകൊണ്ടിരിക്കുകയായിരുന്നു.'},
        {'subject': 'Plural (Were)', 'en': 'They were discussing the plan when the bell rang.', 'ml': 'ബെല്ലടിച്ചപ്പോൾ അവർ പ്ലാൻ ചർച്ച ചെയ്തുകൊണ്ടിരിക്കുകയായിരുന്നു.'},
        {'subject': 'Parallel Actions', 'en': 'While she was designing, he was coding.', 'ml': 'അവൾ ഡിസൈൻ ചെയ്യുമ്പോൾ അവൻ കോഡിംഗ് ചെയ്യുകയായിരുന്നു.'},
      ],
      drills: [
        {'en': 'I was studying English when my friend called me.', 'ml': 'സുഹൃത്ത് എന്നെ വിളിച്ചപ്പോൾ ഞാൻ ഇംഗ്ലീഷ് പഠിച്ചുകൊണ്ടിരിക്കുകയായിരുന്നു.', 'rule': 'Interrupted Past: was studying + when called'},
        {'en': 'They were discussing the project when the power went out.', 'ml': 'വൈദ്യുതി പോയപ്പോൾ അവർ പ്രോജക്റ്റിനെക്കുറിച്ച് സംസാരിക്കുകയായിരുന്നു.', 'rule': 'Past Continuous: were discussing'},
        {'en': 'She was explaining the logic when the meeting ended.', 'ml': 'മീറ്റിംഗ് തീർന്നപ്പോൾ അവൾ അതിന്റെ ലോജിക് വിശദീകരിക്കുകയായിരുന്നു.', 'rule': 'Scene Setting: was explaining'},
        {'en': 'We were developing the app while they prepared the tests.', 'ml': 'അവർ ടെസ്റ്റുകൾ തയ്യാറാക്കുമ്പോൾ ഞങ്ങൾ ആപ്പ് ഡെവലപ്പ് ചെയ്യുകയായിരുന്നു.', 'rule': 'Parallel Actions: were developing'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating you were having dinner when the doorbell rang:',
          'qMl': 'ചോദ്യം 1: കോളിംഗ് ബെല്ലടിച്ചപ്പോൾ ഞാൻ ഭക്ഷണം കഴിക്കുകയായിരുന്നു എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I was having dinner when the bell rang, or I were having dinner when the bell rang?',
          'correct': 'I was having dinner when the bell rang.',
          'wrong': 'I were having dinner when the bell rang.',
          'tip': 'First person singular "I" takes "was": "I was having"!',
        },
        {
          'qEn': 'Question 2: Complete: "They ___ working late last night when the server crashed."',
          'qMl': 'ചോദ്യം 2: സെർവർ തകരാറിലായപ്പോൾ അവർ ജോലി ചെയ്യുകയായിരുന്നു:',
          'audio': 'Question 2: Does They take was, or were?',
          'correct': 'were',
          'wrong': 'was',
          'tip': 'Plural subjects (They, We) take "were": "They were working"!',
        },
      ],
    ),
  };
}

/// 🐱 Unified Conversational Avatar Chat Page for Days 3 through 16
class PocketDayAvatarChatPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDayAvatarChatPage({
    super.key,
    required this.day,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDayAvatarChatPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDayAvatarChatPage> createState() => _PocketDayAvatarChatPageState();
}

class _PocketDayAvatarChatPageState extends State<PocketDayAvatarChatPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;

  final List<DayChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _speechAvailable = false;

  String _userName = 'Hira';
  String _currentExpectedVoicePhrase = 'Yes';
  int _drillIndex = 0;
  int _quizIndex = 0;

  late DayCurriculumSpec _spec;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _micWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _spec = PocketDays3To16Registry.specs[widget.day] ??
        PocketDays3To16Registry.specs[3]!;

    _initUserName();
    _initTts();
    _initSpeechRecognizer();

    PocketGameAudioService.instance.playAmbientAppTheme();
    PocketGameAudioService.instance.setVolume(0.16);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWelcomeFlow();
    });
  }

  void _initUserName() {
    final user = SupaFlow.client.auth.currentUser;
    final metaName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'];
    if (metaName != null && metaName.toString().trim().isNotEmpty) {
      _userName = metaName.toString().trim();
      return;
    }
    final email = user?.email ?? '';
    if (email.isNotEmpty) {
      final namePart = email.split('@').first;
      if (namePart.isNotEmpty) {
        _userName = namePart[0].toUpperCase() + namePart.substring(1);
        return;
      }
    }
    _userName = 'Hira';
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);

      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }

    try {
      _speech = stt.SpeechToText();
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (_) {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _micWaveController.dispose();
    _tts.stop();
    try {
      if (_speechAvailable) _speech.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSoundMuted = !_isSoundMuted;
    });
    if (_isSoundMuted) {
      _tts.stop();
      _isSpeaking = false;
    } else {
      final lastAvatar = _messages.lastWhere(
        (m) => m.isAvatar && m.audioText != null,
        orElse: () => _messages.first,
      );
      if (lastAvatar.audioText != null) {
        _speak(lastAvatar.audioText!);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 280,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 🎙️ CONVERSATION FLOW (Phases 1 to 5)
  // =========================================================================

  /// Phase 1: Greeting & Game vs Chat Mode Selection
  void _startWelcomeFlow() {
    // Look up arcade game spec from registry
    final gameSpecs = Pocket20Days40GamesRegistry.allGames
        .where((g) => g.day == widget.day)
        .toList();
    final gameTitle = gameSpecs.isNotEmpty
        ? '${gameSpecs.first.emoji} ${gameSpecs.first.title}'
        : '🎮 Mini Game';

    final promptEn =
        'Hi $_userName! Welcome to Day ${widget.day}! 🌟 Today we master ${_spec.titleEn}.\n\n'
        'Would you like to play the interactive game first, or jump into speaking chat?';
    final promptMl =
        'ഹായ് $_userName! ഡേ ${widget.day} ലേക്ക് സ്വാഗതം! 🌟 ഇന്ന് ${_spec.titleMl} നമുക്ക് പഠിക്കാം.\n\n'
        'ഗെയിം കളിച്ചു പഠിക്കണോ, അതോ സംസാരിച്ചു തുടങ്ങണോ?';

    _currentExpectedVoicePhrase = 'Speaking Chat';

    setState(() {
      _messages.clear();
      _messages.add(
        DayChatMessage(
          id: 'day_${widget.day}_welcome',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Hi $_userName! ${_spec.greetingAudio}',
          speakThisPrompt: 'Choose your learning mode:',
          inBubbleOptions: [
            DayInBubbleOption(
              labelEn: '🗣️ SPEAKING CHAT & DRILLS',
              labelNative: 'സംസാരിച്ചു പഠിക്കാം! 🎙️',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Speaking Chat',
                action: _showBlueprintCard,
              ),
            ),
            DayInBubbleOption(
              labelEn: '🎮 PLAY $gameTitle',
              labelNative: 'ഗെയിം കളിച്ച് പഠിക്കാം ➔',
              icon: '🎮',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF60A5FA),
              textColor: const Color(0xFF93C5FD),
              onTap: () {
                PocketUniversalArcadeEnginePage.launch(
                  context,
                  day: widget.day,
                  gameIndex: 1,
                  onCompleted: () {
                    _showBlueprintCard();
                  },
                );
              },
            ),
            DayInBubbleOption(
              labelEn: '⚡ I ALREADY KNOW THIS (TEST ME)',
              labelNative: 'നേരിട്ട് പരീക്ഷിക്കാം ➔',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Test me',
                action: _startMiniQuiz,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! ${_spec.greetingAudio}');
    _scrollToBottom();
  }

  /// Phase 2: Teach Grammar Blueprint & Rules
  void _showBlueprintCard() {
    final textEn =
        'Awesome, $_userName! 🚀 Let us master the Day ${widget.day} core blueprint:\n\n'
        '${_spec.blueprintExplanationEn}';
    final textMl = _spec.blueprintExplanationMl;

    _currentExpectedVoicePhrase = _spec.drills.first['en']!;

    setState(() {
      _messages.add(
        DayChatMessage(
          id: 'day_${widget.day}_blueprint',
          isAvatar: true,
          textEn: textEn,
          textNative: textMl,
          audioText:
              'Remember this golden rule for Day ${widget.day}. ${_spec.blueprintRules.first['en']}',
          cardContent: _buildBlueprintVisualCard(),
          speakThisPrompt: 'Ready to speak aloud? Tap below! 👇',
          inBubbleOptions: [
            DayInBubbleOption(
              labelEn: '🎙️ START SPEAKING DRILLS ➔',
              labelNative: 'പരിശീലനം ആരംഭിക്കാം! 🚀',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Start Drills',
                action: _startNextDrill,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Let us master the Day ${widget.day} core blueprint. Are you ready?');
    _scrollToBottom();
  }

  Widget _buildBlueprintVisualCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_spec.topicEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DAY ${widget.day}: ${_spec.blueprintTitle}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._spec.blueprintRules.map((r) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRuleRow(r['subject']!, r['en']!, r['ml']!),
                const Divider(color: Colors.white12, height: 14),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String subject, String en, String ml) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subject,
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF7DD3FC),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                en,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            ml,
            style: GoogleFonts.notoSansMalayalam(
              color: Colors.white60,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Phase 3: Interactive Speaking Drills
  void _startNextDrill() {
    if (_drillIndex >= _spec.drills.length) {
      _startMiniQuiz();
      return;
    }

    final drill = _spec.drills[_drillIndex];
    final target = drill['en']!;
    final ml = drill['ml']!;
    final rule = drill['rule']!;

    _currentExpectedVoicePhrase = target;

    final promptEn =
        'Drill ${_drillIndex + 1} of ${_spec.drills.length}:\n'
        'Speak this sentence aloud into the mic below! 👇\n\n'
        '"$target"';

    final promptMl =
        'പരിശീലനം ${_drillIndex + 1}/${_spec.drills.length}:\n'
        'ഈ വാചകം മൈക്കിലൂടെ ഉറക്കെ പറയൂ! ($ml)';

    setState(() {
      _messages.add(
        DayChatMessage(
          id: 'drill_${widget.day}_$_drillIndex',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Please say: $target',
          cardContent: _buildDrillCard(target, ml, rule),
          speakThisPrompt: 'SPEAK THIS ALOUD 👇',
          inBubbleOptions: [
            DayInBubbleOption(
              labelEn: '🗣️ "$target"',
              labelNative: 'ടാപ്പ് ചെയ്ത് പറയാം',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: target,
                action: _onDrillPassed,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Please say: $target');
    _scrollToBottom();
  }

  Widget _buildDrillCard(String target, String ml, String rule) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🎯 $rule',
              style: GoogleFonts.inter(
                color: const Color(0xFF34D399),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$target"',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            ml,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onDrillPassed() {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCorrectSound();

    _drillIndex++;
    if (_drillIndex < _spec.drills.length) {
      _startNextDrill();
    } else {
      _startMiniQuiz();
    }
  }

  /// Phase 4: Quick In-Bubble Mini Quiz
  void _startMiniQuiz() {
    if (_quizIndex >= _spec.quizQuestions.length) {
      _completeStep1();
      return;
    }

    final q = _spec.quizQuestions[_quizIndex];
    final qEn = q['qEn'] as String;
    final qMl = q['qMl'] as String;
    final audio = q['audio'] as String;
    final correct = q['correct'] as String;
    final wrong = q['wrong'] as String;
    final tip = q['tip'] as String;

    _currentExpectedVoicePhrase = correct;

    setState(() {
      _messages.add(
        DayChatMessage(
          id: 'day_${widget.day}_q$_quizIndex',
          isAvatar: true,
          textEn: qEn,
          textNative: qMl,
          audioText: audio,
          speakThisPrompt: 'Choose the correct answer:',
          inBubbleOptions: [
            DayInBubbleOption(
              labelEn: '✅ "$correct"',
              labelNative: 'ശരിയായ ഉത്തരം ⭐',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: correct,
                action: () {
                  PocketGameAudioService.instance.playCorrectSound();
                  HapticFeedback.heavyImpact();
                  _quizIndex++;
                  if (_quizIndex < _spec.quizQuestions.length) {
                    _startMiniQuiz();
                  } else {
                    _completeStep1();
                  }
                },
              ),
            ),
            DayInBubbleOption(
              labelEn: '❌ "$wrong"',
              labelNative: 'തെറ്റ്',
              icon: '❌',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: Colors.white70,
              onTap: () {
                PocketGameAudioService.instance.playIncorrectSound();
                _speak('Oops! $tip');
              },
            ),
          ],
        ),
      );
    });

    _speak(audio);
    _scrollToBottom();
  }

  /// Phase 5: Step 1 Completion & Road Unlock
  Future<void> _completeStep1() async {
    PocketGameAudioService.instance.playVictorySfx();
    HapticFeedback.heavyImpact();

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_1_completed', true);
      await PocketFortressDefenseService.recordTrainingPoints(25, uid);
    } catch (_) {}

    final replyEn =
        'CONGRATULATIONS, $_userName! 🏆🎉\n\n'
        'You have mastered Day ${widget.day} Step 1: ${_spec.titleEn}!\n'
        '+25 XP & Fortress Defense Shield Points Awarded! 🛡️⚡\n\n'
        'Step 2: Vocabulary Drive is now unlocked on the open road! 🚗💨';

    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName! 🏆\n\n'
        'നിങ്ങൾ ഡേ ${widget.day} ലെ Step 1 വിജയകരമായി പൂർത്തിയാക്കി!\n'
        '+25 XP നൽകി. റോഡിലേക്ക് മടങ്ങി Step 2 വൊക്കാബുലറി ഡ്രൈവ് ആരംഭിക്കാം!';

    setState(() {
      _messages.add(
        DayChatMessage(
          id: 'day_${widget.day}_completed',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Congratulations, $_userName! You have mastered Day ${widget.day} Step 1. Let us proceed to Step 2!',
          speakThisPrompt: 'Tap below to return to the road: 👇',
          inBubbleOptions: [
            DayInBubbleOption(
              labelEn: '🚗 PROCEED TO STEP 2: VOCAB DRIVE ➔',
              labelNative: 'റോഡിലേക്ക് മടങ്ങുക ➔',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onStepFinished?.call(1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You have mastered Day ${widget.day} Step 1. Let us proceed to Step 2!');
    _scrollToBottom();
  }

  // =========================================================================
  // 🎙️ SPEECH RECOGNITION & STRICT PRONUNCIATION EVALUATION
  // =========================================================================

  Future<void> _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    // If submitted via direct button tap with expected phrase, evaluate against expected
    final target = _currentExpectedVoicePhrase;
    final evalResult = PocketPronunciationEvaluator.evaluate(
      targetSentence: target,
      spokenText: voiceText,
    );

    // Show learner message
    setState(() {
      _messages.add(
        DayChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    // Strict evaluation check
    if (evalResult.accuracyPercentage < 65 &&
        voiceText.toLowerCase() != target.toLowerCase() &&
        !voiceText.toLowerCase().contains('yes') &&
        !voiceText.toLowerCase().contains('start') &&
        !voiceText.toLowerCase().contains('test')) {
      // Evaluation failed: Give constructive retry feedback
      PocketGameAudioService.instance.playIncorrectSound();
      HapticFeedback.vibrate();

      setState(() {
        _messages.add(
          DayChatMessage(
            id: 'eval_fail_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            textEn:
                'Pronunciation Check (${evalResult.accuracyPercentage}%):\n'
                'You said: "$voiceText"\n'
                'Expected: "$target"\n\n'
                '${evalResult.feedbackTip}',
            textNative: 'ശ്രമിക്കൂ! ഈ വാക്ക് കുറച്ചുകൂടി വ്യക്തമായി പറയൂ.',
            cardContent: PocketPronunciationResultCard(
              result: evalResult,
              onRetry: () => _toggleLiveListening(),
            ),
            speakThisPrompt: 'Tap mic or button below to try again:',
            inBubbleOptions: [
              DayInBubbleOption(
                labelEn: '🎙️ RETRY: "$target"',
                labelNative: 'വീണ്ടും പറയാം',
                icon: '🔄',
                isHighlightedAnswer: true,
                backgroundColor: const Color(0xFFEF4444),
                borderColor: const Color(0xFFFCA5A5),
                textColor: Colors.white,
                onTap: () => _handleVoiceSubmission(
                  voiceText: target,
                  action: action,
                ),
              ),
            ],
          ),
        );
        _isAnalyzing = false;
      });

      _speak('Let\'s try again: $target');
      _scrollToBottom();
      return;
    }

    // Success!
    setState(() => _isAnalyzing = false);
    action();
  }

  void _toggleLiveListening() async {
    if (!_speechAvailable) {
      // Graceful fallback on non-mobile platforms (e.g. Windows desktop development)
      HapticFeedback.selectionClick();
      await _handleVoiceSubmission(
        voiceText: _currentExpectedVoicePhrase,
        action: () {
          if (_drillIndex < _spec.drills.length) {
            _onDrillPassed();
          } else {
            _quizIndex++;
            if (_quizIndex < _spec.quizQuestions.length) {
              _startMiniQuiz();
            } else {
              _completeStep1();
            }
          }
        },
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      HapticFeedback.mediumImpact();
      _speech.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            setState(() => _isListening = false);
            _handleVoiceSubmission(
              voiceText: result.recognizedWords.trim(),
              action: () {
                if (_drillIndex < _spec.drills.length) {
                  _onDrillPassed();
                } else {
                  _quizIndex++;
                  if (_quizIndex < _spec.quizQuestions.length) {
                    _startMiniQuiz();
                  } else {
                    _completeStep1();
                  }
                }
              },
            );
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
        ),
      );
    }
  }

  // =========================================================================
  // 🎨 UI RENDERING
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) => _buildMessageItem(_messages[idx]),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _tts.stop();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isSpeaking
                    ? const [Color(0xFF00F0FF), Color(0xFF10B981)]
                    : const [Color(0xFF10B981), Color(0xFF047857)],
              ),
              border: Border.all(
                color: _isSpeaking ? const Color(0xFF00F0FF) : const Color(0xFFFFD700),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(_spec.topicEmoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Day ${widget.day} • Step 1',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  _spec.titleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleSpeaker,
            icon: Icon(
              _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSoundMuted ? Colors.white38 : const Color(0xFF10B981),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DayChatMessage msg) {
    if (msg.isAvatar) {
      return _buildAvatarBubble(msg);
    } else {
      return _buildLearnerBubble(msg);
    }
  }

  Widget _buildAvatarBubble(DayChatMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
              ),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Center(
              child: Text('🐱', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.textEn,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  if (msg.textNative.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      msg.textNative,
                      style: GoogleFonts.notoSansMalayalam(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (msg.cardContent != null) ...[
                    const SizedBox(height: 10),
                    msg.cardContent!,
                  ],
                  if (msg.inBubbleOptions != null &&
                      msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 10),
                    if (msg.speakThisPrompt != null) ...[
                      Text(
                        msg.speakThisPrompt!,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ...msg.inBubbleOptions!.map((opt) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: opt.onTap,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: opt.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: opt.borderColor,
                                width: opt.isHighlightedAnswer ? 1.8 : 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Text(opt.icon!,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          color: opt.textColor,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.notoSansMalayalam(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 13, color: Colors.white54),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnerBubble(DayChatMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF047857), Color(0xFF065F46)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg.isVoiceMessage) ...[
                  const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    msg.textEn,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isListening
                          ? 'Listening to you... Speak now! 🎙️'
                          : 'Target: "$_currentExpectedVoicePhrase"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: _isListening
                            ? const Color(0xFF34D399)
                            : Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _toggleLiveListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [const Color(0xFF10B981), const Color(0xFF047857)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981))
                            .withValues(
                                alpha: 0.3 + (_pulseController.value * 0.3)),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 🚀 DEDICATED CONVENIENCE CLASSES FOR DAYS 3 TO 16
// =============================================================================

class PocketDay3Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay3Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 3, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 3, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay4Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay4Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 4, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 4, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay5Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay5Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 5, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 5, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay6Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay6Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 6, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 6, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay7Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay7Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 7, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 7, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay8Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay8Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 8, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 8, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay9Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay9Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 9, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 9, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay10Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay10Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 10, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 10, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay11Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay11Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 11, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 11, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay12Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay12Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 12, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 12, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay13Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay13Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 13, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 13, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay14Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay14Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 14, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 14, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay15Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay15Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 15, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 15, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay16Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay16Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 16, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 16, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay17Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay17Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 17, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 17, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay18Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay18Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 18, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 18, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay19Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay19Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 19, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 19, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay20Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay20Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 20, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 20, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay21Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay21Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 21, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 21, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay22Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay22Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 22, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 22, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay23Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay23Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 23, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 23, userId: userId, onStepFinished: onStepFinished);
}

