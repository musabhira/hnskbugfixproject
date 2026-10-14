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

    // -------------------------------------------------------------------------
    // DAY 24: Quantifiers (Countable vs Uncountable Nouns)
    // -------------------------------------------------------------------------
    24: const DayCurriculumSpec(
      day: 24,
      topicEmoji: '🏂',
      titleEn: 'Day 24: Quantifiers (Countable vs Uncountable Nouns)',
      titleMl: 'ഡേ 24: അളവുകളും എണ്ണവും കൃത്യമായി പറയാൻ Quantifiers',
      greetingEn: 'Welcome to Day 24! 🌟 Today we master quantifiers: using "many" and "few" for countable things, and "much" and "little" for uncountable quantities!',
      greetingMl: 'ഡേ 24 ലേക്ക് സ്വാഗതം! 🌟 എണ്ണാൻ കഴിയുന്നവയ്ക്കും കഴിയാത്തവയ്ക്കും കൃത്യമായ അളവുകൾ (many, much, few, little) നൽകി സംസാരിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 24! Today we master countable and uncountable quantifiers like many, much, some, and any.',
      blueprintTitle: 'COUNTABLE VS UNCOUNTABLE FORMULA',
      blueprintExplanationEn: 'Use "many" and "few" for things you can count individually (books, tasks, bugs). Use "much" and "little" for uncountable volume or abstract mass (time, water, information). Use "some" in positive statements and "any" in questions or negatives!',
      blueprintExplanationMl: 'എണ്ണാൻ കഴിയുന്നവയ്ക്ക് many, few ഉപയോഗിക്കുക (many tasks). എണ്ണാൻ കഴിയാത്തവയ്ക്ക് much, little ഉപയോഗിക്കുക (much time). ചോദ്യങ്ങളിലും നെഗറ്റീവുകളിലും "any" ഉപയോഗിക്കുക (Do you have any questions?).',
      blueprintRules: [
        {'subject': 'Countable Nouns', 'en': 'There are many new features in this release.', 'ml': 'ഈ റിലീസിൽ നിരവധി പുതിയ ഫീച്ചറുകൾ ഉണ്ട്.'},
        {'subject': 'Uncountable Nouns', 'en': 'We don\'t have much time before the deadline.', 'ml': 'ഡെഡ്‌ലൈന് മുൻപ് ഞങ്ങൾക്ക് അധികം സമയമില്ല.'},
        {'subject': 'Questions & Negatives', 'en': 'Do you have any questions about the plan?', 'ml': 'പദ്ധതിയെക്കുറിച്ച് നിങ്ങൾക്ക് എന്തെങ്കിലും സംശയങ്ങളുണ്ടോ?'},
      ],
      drills: [
        {'en': 'We encountered many unexpected challenges yesterday.', 'ml': 'ഇന്നലെ ഞങ്ങൾ പല അപ്രതീക്ഷിത വെല്ലുവിളികളും നേരിട്ടു.', 'rule': 'Countable Quantifier: many + challenges'},
        {'en': 'I do not have much time before the meeting.', 'ml': 'മീറ്റിംഗിന് മുൻപ് എനിക്ക് അധികം സമയമില്ല.', 'rule': 'Uncountable Quantifier: much + time'},
        {'en': 'Do you have any suggestions for our project?', 'ml': 'ഞങ്ങളുടെ പ്രോജക്റ്റിലേക്ക് എന്തെങ്കിലും നിർദ്ദേശങ്ങൾ നിങ്ങൾക്കുണ്ടോ?', 'rule': 'Question Quantifier: any + suggestions'},
        {'en': 'She gave me some valuable advice about learning.', 'ml': 'പഠനത്തെക്കുറിച്ച് അവൾ എനിക്ക് ചില വിലപ്പെട്ട ഉപദേശങ്ങൾ തന്നു.', 'rule': 'Uncountable: some advice (not an advice)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating you don\'t have enough time today, say:',
          'qMl': 'ചോദ്യം 1: എനിക്ക് ഇന്ന് അധികം സമയമില്ല എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it I do not have much time, or I do not have many time?',
          'correct': 'I do not have much time.',
          'wrong': 'I do not have many time.',
          'tip': 'Time is uncountable! Use "much time", never "many time".',
        },
        {
          'qEn': 'Question 2: Complete: "There are ___ bugs to fix in this version."',
          'qMl': 'ചോദ്യം 2: ഈ വേർഷനിൽ പരിഹരിക്കാൻ ധാരാളം ബഗ്ഗുകൾ ഉണ്ട്:',
          'audio': 'Question 2: Does bugs take many, or much?',
          'correct': 'many',
          'wrong': 'much',
          'tip': 'Bugs are countable nouns! Say: "many bugs".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 25: Master the Articles (A, An, The)
    // -------------------------------------------------------------------------
    25: const DayCurriculumSpec(
      day: 25,
      topicEmoji: '🏝️',
      titleEn: 'Day 25: Master the Articles (A, An, The)',
      titleMl: 'ഡേ 25: നാമങ്ങൾക്ക് വ്യക്തത നൽകാൻ Articles (A, An, The)',
      greetingEn: 'Welcome to Day 25! 🌟 Today we master English articles: knowing exactly when to use "a", "an", and when to switch into the specific spotlight with "the"!',
      greetingMl: 'ഡേ 25 ലേക്ക് സ്വാഗതം! 🌟 ഇംഗ്ലീഷ് സംസാരത്തിന് കൂടുതൽ അഴക് നൽകുന്ന Articles (A, An, The) കൃത്യമായി ഉപയോഗിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 25! Today we master the spotlight rule of articles: a, an, and the.',
      blueprintTitle: 'THE ARTICLE SPOTLIGHT FORMULA',
      blueprintExplanationEn: 'Use "a" before consonant sounds and "an" before vowel sounds (an hour, a university). Use "a/an" when introducing an item for the first time, and switch to "the" once it becomes specific and known to both speaker and listener!',
      blueprintExplanationMl: 'ഒരു വസ്തുവിനെ ആദ്യമായി പരാമർശിക്കുമ്പോൾ "a" അല്ലെങ്കിൽ "an" ഉപയോഗിക്കുക. അതേ വസ്തുവിനെ തുടർന്ന് പറയുമ്പോഴോ എല്ലാവർക്കും അറിയാവുന്ന പ്രത്യേക കാര്യമാണെങ്കിലോ "the" ഉപയോഗിക്കുക ("I bought a phone. The phone is fast").',
      blueprintRules: [
        {'subject': 'First Mention', 'en': 'I bought a new laptop yesterday.', 'ml': 'ഞാൻ ഇന്നലെ ഒരു പുതിയ ലാപ്ടോപ്പ് വാങ്ങി.'},
        {'subject': 'Specific Mention', 'en': 'The laptop is remarkably fast and light.', 'ml': 'ആ ലാപ്ടോപ്പ് വളരെ വേഗതയേറിയതും ഭാരം കുറഞ്ഞതുമാണ്.'},
        {'subject': 'Vowel Sound Rule', 'en': 'She has an honest and transparent approach.', 'ml': 'അവൾക്ക് സത്യസന്ധവും സുതാര്യവുമായ ഒരു സമീപനമുണ്ട് (honest takes an).'},
      ],
      drills: [
        {'en': 'I am a software engineer building a mobile app.', 'ml': 'ഞാൻ ഒരു മൊബൈൽ ആപ്പ് നിർമ്മിക്കുന്ന സോഫ്റ്റ്‌വെയർ എഞ്ചിനീയറാണ്.', 'rule': 'Indefinite Article: a + engineer / a + app'},
        {'en': 'She gave an inspiring presentation to the team.', 'ml': 'അവൾ ടീമിന് പ്രചോദനാത്മകമായ ഒരു പ്രസന്റേഷൻ നൽകി.', 'rule': 'Vowel Sound: an + inspiring'},
        {'en': 'The project we started last week is progressing well.', 'ml': 'കഴിഞ്ഞ ആഴ്ച നമ്മൾ തുടങ്ങിയ ആ പ്രോജക്ട് നന്നായി മുന്നേറുന്നു.', 'rule': 'Definite Specific Article: The project'},
        {'en': 'He is an honest person with great dedication.', 'ml': 'അവൻ മികച്ച അർപ്പണബോധമുള്ള ഒരു സത്യസന്ധനായ വ്യക്തിയാണ്.', 'rule': 'Silent H: an honest person'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating your profession as an engineer:',
          'qMl': 'ചോദ്യം 1: ഞാൻ ഒരു എഞ്ചിനീയറാണ് എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it I am an engineer, or I am a engineer?',
          'correct': 'I am an engineer.',
          'wrong': 'I am a engineer.',
          'tip': '"Engineer" begins with a vowel sound! Always say: "an engineer".',
        },
        {
          'qEn': 'Question 2: Complete: "She attends ___ university in Kochi."',
          'qMl': 'ചോദ്യം 2: അവൾ കൊച്ചിയിലെ ഒരു യൂണിവേഴ്സിറ്റിയിലാണ് പഠിക്കുന്നത്:',
          'audio': 'Question 2: Does university take a, or an?',
          'correct': 'a',
          'wrong': 'an',
          'tip': '"University" starts with a "yu" consonant sound, so it takes "a university"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 26: Ownership & Possessives (My/Mine, Your/Yours)
    // -------------------------------------------------------------------------
    26: const DayCurriculumSpec(
      day: 26,
      topicEmoji: '🏭',
      titleEn: 'Day 26: Ownership & Possessives (My/Mine, Your/Yours)',
      titleMl: 'ഡേ 26: ഉടമസ്ഥതയും ഉത്തരവാദിത്തവും വ്യക്തമാക്കാൻ Possessives',
      greetingEn: 'Welcome to Day 26! 🌟 Today we master expressing ownership, responsibility, and task boundaries using possessive adjectives and pronouns!',
      greetingMl: 'ഡേ 26 ലേക്ക് സ്വാഗതം! 🌟 വസ്തുക്കളുടെയും ഉത്തരവാദിത്തങ്ങളുടെയും ഉടമസ്ഥത (my, mine, our, ours) വ്യക്തമായി പറയാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 26! Today we master possessive adjectives and pronouns to state ownership with clarity.',
      blueprintTitle: 'POSSESSIVE PRONOUN BLUEPRINT',
      blueprintExplanationEn: 'Possessive adjectives (my, your, our, their) always attach directly to nouns ("my code"). Possessive pronouns (mine, yours, ours, theirs) stand alone ("that code is mine"). Also remember: "its" shows ownership; "it\'s" means "it is"!',
      blueprintExplanationMl: 'നാമത്തോടൊപ്പം വരുമ്പോൾ my, our, your ("my project"). ഒറ്റയ്ക്ക് നിൽക്കുമ്പോൾ mine, ours, yours ("The project is mine"). Its (ഉടമസ്ഥത) ഇൽ അപ്പോസ്ട്രഫി ഇടരുത്.',
      blueprintRules: [
        {'subject': 'Attached to Noun', 'en': 'This is our strategic roadmap.', 'ml': 'ഇതാണ് ഞങ്ങളുടെ തന്ത്രപരമായ റോഡ്മാപ്പ്.'},
        {'subject': 'Standing Alone', 'en': 'The final decision is entirely yours.', 'ml': 'അന്തിമ തീരുമാനം പൂർണ്ണമായും നിങ്ങളുടേതാണ്.'},
        {'subject': 'Non-Human Possessive', 'en': 'The mobile app updated its user interface.', 'ml': 'മൊബൈൽ ആപ്പ് അതിന്റെ യൂസർ ഇന്റർഫേസ് അപ്ഡേറ്റ് ചെയ്തു (its, no apostrophe).'},
      ],
      drills: [
        {'en': 'This laptop is mine and that workstation is yours.', 'ml': 'ഈ ലാപ്ടോപ്പ് എന്റേതാണ്, ആ വർക്ക്സ്റ്റേഷൻ നിങ്ങളുടേതാണ്.', 'rule': 'Standalone Possessives: mine & yours'},
        {'en': 'Our team completed the milestone ahead of schedule.', 'ml': 'ഞങ്ങളുടെ ടീം നിശ്ചിത സമയത്തിന് മുൻപേ ലക്ഷ്യം പൂർത്തിയാക്കി.', 'rule': 'Possessive Adjective: Our + team'},
        {'en': 'The company launched its new product line today.', 'ml': 'കമ്പനി ഇന്ന് തങ്ങളുടെ പുതിയ ഉൽപ്പന്നങ്ങൾ പുറത്തിറക്കി.', 'rule': 'Possessive Its: its + product (no apostrophe)'},
        {'en': 'The responsibility for this success is entirely ours.', 'ml': 'ഈ വിജയത്തിന്റെ ഉത്തരവാദിത്തം പൂർണ്ണമായും നമ്മുടേതാണ്.', 'rule': 'Standalone Pronoun: entirely ours'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating that a phone belongs to you:',
          'qMl': 'ചോദ്യം 1: ഈ ഫോൺ എന്റേതാണ് എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it This phone is mine, or This phone is my?',
          'correct': 'This phone is mine.',
          'wrong': 'This phone is my.',
          'tip': 'When standing alone at the end of a clause, use "mine", not "my"!',
        },
        {
          'qEn': 'Question 2: Complete: "The application updated ___ database securely."',
          'qMl': 'ചോദ്യം 2: ആപ്ലിക്കേഷൻ അതിന്റെ ഡാറ്റാബേസ് സുരക്ഷിതമായി അപ്ഡേറ്റ് ചെയ്തു:',
          'audio': 'Question 2: Is it its, or it\'s?',
          'correct': 'its',
          'wrong': 'it\'s',
          'tip': 'Possessive form is "its" without an apostrophe! "It\'s" means "it is".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 27: Smart Comparisons (Comparatives: -er / more than)
    // -------------------------------------------------------------------------
    27: const DayCurriculumSpec(
      day: 27,
      topicEmoji: '🐝',
      titleEn: 'Day 27: Smart Comparisons (Comparatives: -er / more than)',
      titleMl: 'ഡേ 27: രണ്ട് കാര്യങ്ങൾ തമ്മിൽ താരതമ്യം ചെയ്യാൻ Comparatives',
      greetingEn: 'Welcome to Day 27! 🌟 Today we master evaluating choices and comparing alternatives using comparatives (-er than, more than)!',
      greetingMl: 'ഡേ 27 ലേക്ക് സ്വാഗതം! 🌟 രണ്ട് കാര്യങ്ങളെ തമ്മിൽ ശരിയായി താരതമ്യം ചെയ്യാനും തീരുമാനങ്ങൾ വ്യക്തമാക്കാനും Comparatives ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 27! Today we master making smart comparisons using -er than and more than.',
      blueprintTitle: 'COMPARATIVE EVALUATION FORMULA',
      blueprintExplanationEn: 'Use "-er than" for short one-syllable adjectives (fast ➔ faster than, clean ➔ cleaner than). Use "more ... than" for longer multi-syllable adjectives (efficient ➔ more efficient than). Never combine both (never say "more faster")!',
      blueprintExplanationMl: 'ചെറിയ വാക്കുകൾക്ക് -er than (quicker than, simpler than). വലിയ വാക്കുകൾക്ക് more ... than (more powerful than). ഒരിക്കലും "more faster" എന്ന് രണ്ടും ഒരുമിച്ച് പറയരുത്!',
      blueprintRules: [
        {'subject': 'Short Adjectives (-er)', 'en': 'This framework is faster than the old one.', 'ml': 'ഈ ഫ്രെയിംവർക്ക് പഴയതിനേക്കാൾ വേഗതയേറിയതാണ്.'},
        {'subject': 'Long Adjectives (more)', 'en': 'This design is more user-friendly than before.', 'ml': 'ഈ ഡിസൈൻ മുൻപത്തേക്കാൾ കൂടുതൽ ഉപയോക്തൃ സൗഹൃദമാണ്.'},
        {'subject': 'Irregular Comparatives', 'en': 'Her spoken English is much better now.', 'ml': 'അവളുടെ ഇംഗ്ലീഷ് സംസാരം ഇപ്പോൾ വളരെ മികച്ചതാണ് (good ➔ better).'},
      ],
      drills: [
        {'en': 'This new approach is faster and cleaner than the old method.', 'ml': 'ഈ പുതിയ രീതി പഴയതിനേക്കാൾ വേഗതയേറിയതും വൃത്തിയുള്ളതുമാണ്.', 'rule': 'Short Comparatives: faster and cleaner'},
        {'en': 'Flutter is more flexible and productive for mobile apps.', 'ml': 'മൊബൈൽ ആപ്പുകൾക്ക് ഫ്ലട്ടർ കൂടുതൽ വഴക്കമുള്ളതും ഫലപ്രദവുമാണ്.', 'rule': 'Long Comparative: more flexible'},
        {'en': 'My pronunciation is significantly better than last month.', 'ml': 'കഴിഞ്ഞ മാസത്തെ അപേക്ഷിച്ച് എന്റെ ഉച്ചാരണം വളരെ മികച്ചതാണ്.', 'rule': 'Irregular: better (good ➔ better)'},
        {'en': 'This solution is simpler and more reliable for our users.', 'ml': 'ഈ പരിഹാരം ഞങ്ങളുടെ ഉപയോക്താക്കൾക്ക് കൂടുതൽ ലളിതവും ആശ്രയിക്കാവുന്നതുമാണ്.', 'rule': 'Combined: simpler and more reliable'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Comparing the speed of two tools, which is correct?',
          'qMl': 'ചോദ്യം 1: രണ്ട് ടൂളുകളുടെ വേഗത താരതമ്യം ചെയ്യാൻ ഏതാണ് ശരി?',
          'audio': 'Question 1: Is it Flutter is faster than React, or Flutter is more faster than React?',
          'correct': 'Flutter is faster than React.',
          'wrong': 'Flutter is more faster than React.',
          'tip': 'Never say "more faster"! Short adjectives take -er only: "faster than"!',
        },
        {
          'qEn': 'Question 2: Complete: "His English communication is getting ___ every single day."',
          'qMl': 'ചോദ്യം 2: അവന്റെ ഇംഗ്ലീഷ് സംസാരം ദിവസേന കൂടുതൽ മികച്ചതായി മാറുന്നു:',
          'audio': 'Question 2: Is it better, or gooder?',
          'correct': 'better',
          'wrong': 'gooder',
          'tip': '"Good" is irregular! Its comparative form is "better", never "gooder".',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 28: Superlatives (The Best, The Greatest, The Most)
    // -------------------------------------------------------------------------
    28: const DayCurriculumSpec(
      day: 28,
      topicEmoji: '🚇',
      titleEn: 'Day 28: Superlatives (The Best, The Greatest, The Most)',
      titleMl: 'ഡേ 28: ഏറ്റവും മികച്ചതിനെ ഉയർത്തിക്കാട്ടാൻ Superlatives',
      greetingEn: 'Welcome to Day 28! 🌟 Today we master superlatives (the greatest, the most innovative) to celebrate peak achievements and define excellence!',
      greetingMl: 'ഡേ 28 ലേക്ക് സ്വാഗതം! 🌟 ഒരു കൂട്ടത്തിൽ ഏറ്റവും മികച്ചത് (the best, the most important) എടുത്തുപറയാൻ Superlatives ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 28! Today we master superlatives to highlight the number one in any category.',
      blueprintTitle: 'SUPERLATIVE PINNACLE BLUEPRINT',
      blueprintExplanationEn: 'Superlatives identify the top spot in a group. Always use "the" before superlatives! Short adjectives add -est (the fastest, the simplest), while long adjectives take "the most" (the most impactful).',
      blueprintExplanationMl: 'ഏറ്റവും മികച്ചത് എന്ന് പറയാൻ എപ്പോഴും "the" ഉപയോഗിക്കണം (the best, the most valuable). ചെറിയ വാക്കുകൾക്ക് -est (the easiest), വലിയ വാക്കുകൾക്ക് the most (the most dependable).',
      blueprintRules: [
        {'subject': 'Short Adjectives (-est)', 'en': 'This is the simplest way to learn speaking.', 'ml': 'സംസാരം പഠിക്കാനുള്ള ഏറ്റവും ലളിതമായ മാർഗ്ഗമാണിത്.'},
        {'subject': 'Long Adjectives (the most)', 'en': 'Security is the most critical feature of our app.', 'ml': 'സുരക്ഷയാണ് ഞങ്ങളുടെ ആപ്പിന്റെ ഏറ്റവും നിർണ്ണായകമായ ഫീച്ചർ.'},
        {'subject': 'Irregular Superlatives', 'en': 'Consistency is the best habit you can cultivate.', 'ml': 'തുടർച്ചയായ പരിശീലനമാണ് നിങ്ങൾക്ക് വളർത്തിയെടുക്കാവുന്ന ഏറ്റവും മികച്ച ശീലം (best).'},
      ],
      drills: [
        {'en': 'This is the most effective English course I have taken.', 'ml': 'ഞാൻ പങ്കെടുത്തതിൽ വെച്ച് ഏറ്റവും ഫലപ്രദമായ ഇംഗ്ലീഷ് കോഴ്സാണിത്.', 'rule': 'Superlative: the most effective'},
        {'en': 'Speaking daily is the fastest way to gain fluency.', 'ml': 'ദിവസവും സംസാരിക്കുന്നതാണ് വേഗത്തിൽ സ്വാഭാവികത നേടാനുള്ള ഏറ്റവും മികച്ച വഴി.', 'rule': 'Superlative: the fastest way'},
        {'en': 'He is the most experienced developer on our team.', 'ml': 'ഞങ്ങളുടെ ടീമിലെ ഏറ്റവും പരിചയസമ്പന്നനായ ഡെവലപ്പറാണ് അവൻ.', 'rule': 'Superlative: the most experienced'},
        {'en': 'That was the best presentation delivered at the summit.', 'ml': 'സമ്മിറ്റിൽ അവതരിപ്പിക്കപ്പെട്ടതിൽ വെച്ച് ഏറ്റവും മികച്ച പ്രസന്റേഷനായിരുന്നു അത്.', 'rule': 'Irregular Superlative: the best (good ➔ best)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Praising a colleague as the top developer on the team:',
          'qMl': 'ചോദ്യം 1: ടീമിലെ ഏറ്റവും മികച്ച ഡെവലപ്പർ എന്ന് എങ്ങനെ പറയും?',
          'audio': 'Question 1: Is it He is the best developer, or He is best developer?',
          'correct': 'He is the best developer.',
          'wrong': 'He is best developer.',
          'tip': 'Always include "the" with superlatives: "the best"!',
        },
        {
          'qEn': 'Question 2: Complete: "This is ___ convenient feature in the entire app."',
          'qMl': 'ചോദ്യം 2: മുഴുവൻ ആപ്പിലും വെച്ച് ഏറ്റവും സൗകര്യപ്രദമായ ഫീച്ചർ:',
          'audio': 'Question 2: Does convenient take the most, or the more?',
          'correct': 'the most',
          'wrong': 'the more',
          'tip': 'Superlative pinnacle requires "the most convenient"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 29: Connecting Thoughts (And, But, Because, So)
    // -------------------------------------------------------------------------
    29: const DayCurriculumSpec(
      day: 29,
      topicEmoji: '🧗',
      titleEn: 'Day 29: Connecting Thoughts (And, But, Because, So)',
      titleMl: 'ഡേ 29: ആശയങ്ങൾ കൂട്ടിയിണക്കി സംസാരിക്കാൻ Conjunctions',
      greetingEn: 'Welcome to Day 29! 🌟 Today we master the connectors of human speech (and, but, because, so, although) that transform short fragments into fluent, natural sentences!',
      greetingMl: 'ഡേ 29 ലേക്ക് സ്വാഗതം! 🌟 കൊച്ചുകൊച്ചു വാചകങ്ങൾക്ക് പകരം ആശയങ്ങളെ ഒഴുക്കോടെ കൂട്ടിയിണക്കി സംസാരിക്കാൻ Conjunctions ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 29! Today we master connecting thoughts smoothly with and, but, because, and so.',
      blueprintTitle: 'ORGANIC CONJUNCTION BLUEPRINT',
      blueprintExplanationEn: 'Connectors are the glue of human speech. Use "and" for addition, "but" for contrast, "because" for causes/reasons, and "so" for results. Never pair "although" with "but" in the same sentence!',
      blueprintExplanationMl: 'വാക്യങ്ങളെ കൂട്ടിച്ചേർക്കാൻ and (കൂടാതെ), but (പക്ഷേ), because (കാരണം), so (അതുകൊണ്ട്) ഉപയോഗിക്കുക. ഒരു വാക്യത്തിൽ Although ഉം But ഉം ഒരുമിച്ച് ഉപയോഗിക്കരുത്.',
      blueprintRules: [
        {'subject': 'Addition & Contrast', 'en': 'I was tired after work, but I completed my drill.', 'ml': 'ജോലി കഴിഞ്ഞ് എനിക്ക് ക്ഷീണമായിരുന്നു, പക്ഷേ ഞാൻ ഡ്രിൽ പൂർത്തിയാക്കി.'},
        {'subject': 'Reason & Consequence', 'en': 'I practice speaking daily because fluency requires action.', 'ml': 'ഫ്ലുവൻസിക്ക് പ്രവർത്തനം ആവശ്യമായതുകൊണ്ട് ഞാൻ ദിവസവും സംസാരിക്കുന്നു.'},
        {'subject': 'Subordination (Although)', 'en': 'Although the problem was complex, we solved it.', 'ml': 'പ്രശ്നം സങ്കീർണ്ണമായിരുന്നെങ്കിലും ഞങ്ങൾ അത് പരിഹരിച്ചു.'},
      ],
      drills: [
        {'en': 'I enjoy coding, but I also love learning spoken English.', 'ml': 'എനിക്ക് കോഡിംഗ് ഇഷ്ടമാണ്, പക്ഷേ അതോടൊപ്പം ഇംഗ്ലീഷ് സംസാരിക്കാൻ പഠിക്കുന്നതും ഞാൻ ഇഷ്ടപ്പെടുന്നു.', 'rule': 'Contrast Connector: but'},
        {'en': 'I practice speaking every morning because consistency brings results.', 'ml': 'തുടർച്ചയായ പരിശീലനം ഫലം തരുമെന്നതിനാൽ ഞാൻ എല്ലാ ദിവസവും രാവിലെ സംസാരിക്കുന്നു.', 'rule': 'Causal Connector: because'},
        {'en': 'We completed all test cases, so we deployed the release build.', 'ml': 'ഞങ്ങൾ എല്ലാ ടെസ്റ്റുകളും പൂർത്തിയാക്കി, അതിനാൽ റിലീസ് ബിൽഡ് വിന്യസിച്ചു.', 'rule': 'Consequence Connector: so'},
        {'en': 'Although it rained heavily, our team arrived right on time.', 'ml': 'കനത്ത മഴ പെയ്തിട്ടും ഞങ്ങളുടെ ടീം കൃത്യസമയത്ത് തന്നെ എത്തിച്ചേർന്നു.', 'rule': 'Subordination: Although (no but)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing that you attended the meeting despite being tired:',
          'qMl': 'ചോദ്യം 1: ക്ഷീണിതനായിരുന്നിട്ടും മീറ്റിംഗിൽ പങ്കെടുത്തു എന്ന് പറയാൻ ഏതാണ് ശരി?',
          'audio': 'Question 1: Is it Although I was tired, I attended the meeting, or Although I was tired, but I attended the meeting?',
          'correct': 'Although I was tired, I attended the meeting.',
          'wrong': 'Although I was tired, but I attended the meeting.',
          'tip': 'Never combine "Although" with "but"! "Although" handles the contrast by itself.',
        },
        {
          'qEn': 'Question 2: Complete: "The server crashed, ___ we quickly restored the backup."',
          'qMl': 'ചോദ്യം 2: സെർവർ തകരാറിലായി, അതിനാൽ ഞങ്ങൾ വേഗത്തിൽ ബാക്കപ്പ് റീസ്റ്റോർ ചെയ്തു:',
          'audio': 'Question 2: Does it take so, or because?',
          'correct': 'so',
          'wrong': 'because',
          'tip': '"So" indicates consequence and result!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 30: Foundation Capstone & Speech Autonomy
    // -------------------------------------------------------------------------
    30: const DayCurriculumSpec(
      day: 30,
      topicEmoji: '🏆',
      titleEn: '🥈 Day 30: Foundation Capstone & Speech Autonomy',
      titleMl: 'ഡേ 30: ഫൗണ്ടേഷൻ സമാപനവും 3-മിനിറ്റ് സംഭാഷണ വിജയവും',
      greetingEn: 'Welcome to Day 30! 🌟 Congratulations on reaching the Phase 1 Foundation milestone! Today we weave together present, past, future, modals, and connectors into autonomous spoken fluency!',
      greetingMl: 'ഡേ 30 ലേക്ക് സ്വാഗതം! 🌟 അഭിനന്ദനങ്ങൾ! ആദ്യ 30 ദിവസങ്ങൾ വിജയകരമായി പൂർത്തിയാക്കി നമ്മൾ ഇംഗ്ലീഷിന്റെ അടിത്തറ കീഴടക്കി. പഠിച്ച എല്ലാ വ്യാകരണങ്ങളും ഒഴുക്കോടെ സംസാരിക്കാൻ ഇന്ന് പരിശീലിച്ച് സിൽവർ ഷീൽഡ് നേടാം!',
      greetingAudio: 'Welcome to Day 30! Congratulations on completing Phase 1. Today we synthesize all 30 days into complete spoken fluency.',
      blueprintTitle: 'PHASE 1 CAPSTONE SYNTHESIS',
      blueprintExplanationEn: 'Over 30 days you mastered S-V-O rhythm, Present Simple habits, Past Simple narratives, Future intentions, Modals of capacity, and Connectors. Now speak continuously without pausing to translate from Malayalam!',
      blueprintExplanationMl: 'കഴിഞ്ഞ 30 ദിവസത്തെ കഠിനാധ്വാനം കൊണ്ട് നിങ്ങൾ ഇംഗ്ലീഷിന്റെ എല്ലാ അടിസ്ഥാനങ്ങളും പഠിച്ചുകഴിഞ്ഞു. ഇപ്പോൾ മലയാളത്തിൽ ആലോചിച്ച് വിവർത്തനം ചെയ്യാതെ സ്വാഭാവികമായി ചിന്തിച്ച് സംസാരിക്കുക!',
      blueprintRules: [
        {'subject': 'Self Introduction', 'en': 'I am an ambitious professional dedicated to continuous growth.', 'ml': 'നിരന്തരമായ വളർച്ചയ്ക്കായി പ്രയത്നിക്കുന്ന ഒരു വ്യക്തിയാണ് ഞാൻ.'},
        {'subject': 'Past Experience', 'en': 'Over the last thirty days, I practiced English consistently.', 'ml': 'കഴിഞ്ഞ 30 ദിവസങ്ങളിൽ ഞാൻ മുടങ്ങാതെ ഇംഗ്ലീഷ് സംസാരിച്ചു പരിശീലിച്ചു.'},
        {'subject': 'Future Vision', 'en': 'I will communicate fearlessly in any professional setting.', 'ml': 'ഏതൊരു അന്താരാഷ്ട്ര വേദിയിലും ഞാൻ ഭയമില്ലാതെ ഇംഗ്ലീഷിൽ സംസാരിക്കും.'},
      ],
      drills: [
        {'en': 'I have completed thirty consecutive days of spoken English training.', 'ml': 'തുടർച്ചയായ 30 ദിവസത്തെ ഇംഗ്ലീഷ് സംഭാഷണ പരിശീലനം ഞാൻ വിജയകരമായി പൂർത്തിയാക്കി.', 'rule': 'Milestone Monologue: completed 30 days'},
        {'en': 'I can express my daily thoughts clearly and without hesitation now.', 'ml': 'എന്റെ ദൈനംദിന ചിന്തകൾ യാതൊരു മടിയുമില്ലാതെ വ്യക്തമായി പ്രകടിപ്പിക്കാൻ എനിക്കിപ്പോൾ സാധിക്കുന്നുണ്ട്.', 'rule': 'Capacity & Autonomy: can express'},
        {'en': 'Although it was challenging initially, I built a lasting habit.', 'ml': 'തുടക്കത്തിൽ വെല്ലുവിളിയായിരുന്നെങ്കിലും ഞാൻ ശാശ്വതമായ ഒരു ശീലം ഉണ്ടാക്കിയെടുത്തു.', 'rule': 'Connector Synthesis: Although + built'},
        {'en': 'I will continue practicing until full native-like fluency is achieved.', 'ml': 'പൂർണ്ണമായ ഒഴുക്ക് നേടുന്നതുവരെ ഞാൻ ഈ സംഭാഷണ പരിശീലനം തുടരും.', 'rule': 'Future Commitment: will continue'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Reflecting on your 30-day journey, which sentence is grammatically flawless?',
          'qMl': 'ചോദ്യം 1: നിങ്ങളുടെ 30 ദിവസത്തെ യാത്രയെക്കുറിച്ച് പറയാൻ ഏതാണ് ശരി?',
          'audio': 'Question 1: Is it I have practiced English every day for thirty days, or I practiced English every day since thirty days?',
          'correct': 'I have practiced English every day for thirty days.',
          'wrong': 'I practiced English every day since thirty days.',
          'tip': 'Use "for" with durations of time: "for thirty days"!',
        },
        {
          'qEn': 'Question 2: Complete: "I can now speak English ___ and with genuine confidence."',
          'qMl': 'ചോദ്യം 2: എനിക്ക് ഇപ്പോൾ വ്യക്തമായും ആത്മവിശ്വാസത്തോടെയും സംസാരിക്കാൻ സാധിക്കുന്നു:',
          'audio': 'Question 2: Does speak take clearly, or clear?',
          'correct': 'clearly',
          'wrong': 'clear',
          'tip': 'Verbs require adverbs: "speak clearly"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 31: Life Experience (The Present Perfect: have/has + V3)
    // -------------------------------------------------------------------------
    31: const DayCurriculumSpec(
      day: 31,
      topicEmoji: '🏜️',
      titleEn: 'Day 31: Life Experience (The Present Perfect)',
      titleMl: 'ഡേ 31: ജീവിതാനുഭവങ്ങൾ പറയാൻ Present Perfect Tense',
      greetingEn: 'Welcome to Day 31! 🌟 Welcome to Phase 2: Functional English! Today we unlock the Present Perfect tense (have/has + V3) to talk about life achievements, milestones, and experiences!',
      greetingMl: 'ഡേ 31 ലേക്ക് സ്വാഗതം! 🌟 ഫേസ് 2 (Functional English) ലേക്ക് സ്വാഗതം! നിങ്ങളുടെ ജീവിതാനുഭവങ്ങളും പ്രധാന നേട്ടങ്ങളും ഇംഗ്ലീഷിൽ പറയാൻ Present Perfect (have/has + V3) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 31 and Phase 2! Today we master the Present Perfect tense to talk about life experiences.',
      blueprintTitle: 'PRESENT PERFECT EXPERIENCE BLUEPRINT',
      blueprintExplanationEn: 'Use "have / has + V3 (Past Participle)" for life experiences when the exact time is unstated or unimportant. For example: "I have visited many cities", "She has built several apps". Pair with words like ever, never, already, yet!',
      blueprintExplanationMl: 'ജീവിതത്തിൽ ഇതുവരെ ചെയ്ത കാര്യങ്ങൾ, കൈവരിച്ച അനുഭവങ്ങൾ പറയാൻ have/has + V3 ഉപയോഗിക്കുക ("I have worked on Flutter apps"). സമയം പ്രസക്തമല്ലാത്തപ്പോഴാണ് ഇത് ഉപയോഗിക്കുന്നത് (have visited, have completed).',
      blueprintRules: [
        {'subject': 'Life Experience (I/We)', 'en': 'I have built multiple mobile applications.', 'ml': 'ഞാൻ നിരവധി മൊബൈൽ ആപ്പുകൾ നിർമ്മിച്ചിട്ടുണ്ട് (have + V3).'},
        {'subject': 'Third Person (He/She)', 'en': 'She has achieved remarkable success in her career.', 'ml': 'അവൾ തന്റെ കരിയറിൽ മികച്ച വിജയം നേടിയിട്ടുണ്ട് (has + V3).'},
        {'subject': 'Questions of Experience', 'en': 'Have you ever presented to international clients?', 'ml': 'നിങ്ങൾ എപ്പോഴെങ്കിലും വിദേശ ക്ലയന്റുകൾക്ക് മുന്നിൽ പ്രസന്റേഷൻ ചെയ്തിട്ടുണ്ടോ?'},
      ],
      drills: [
        {'en': 'I have developed modern applications for international users.', 'ml': 'ഞാൻ അന്താരാഷ്ട്ര ഉപയോക്താക്കൾക്കായി ആധുനിക ആപ്ലിക്കേഷനുകൾ നിർമ്മിച്ചിട്ടുണ്ട്.', 'rule': 'Present Perfect: have + developed (V3)'},
        {'en': 'She has achieved significant milestones in software development.', 'ml': 'സോഫ്റ്റ്‌വെയർ രംഗത്ത് അവൾ നിർണ്ണായക നേട്ടങ്ങൾ കൈവരിച്ചിട്ടുണ്ട്.', 'rule': 'Third Person: has + achieved (V3)'},
        {'en': 'Have you ever traveled to another country for work?', 'ml': 'ജോലിക്കായി നിങ്ങൾ എപ്പോഴെങ്കിലും മറ്റൊരു രാജ്യത്തേക്ക് യാത്ര ചെയ്തിട്ടുണ്ടോ?', 'rule': 'Experience Question: Have you ever traveled'},
        {'en': 'We have already tested all core functions of this system.', 'ml': 'ഞങ്ങൾ ഈ സിസ്റ്റത്തിന്റെ എല്ലാ പ്രധാന ഫംഗ്ഷനുകളും ഇതിനകം പരിശോധിച്ചു കഴിഞ്ഞു.', 'rule': 'Adverb: have already tested'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating your experience in visiting Bengaluru:',
          'qMl': 'ചോദ്യം 1: ഞാൻ ബംഗളൂരു സന്ദർശിച്ചിട്ടുണ്ട് എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I have visited Bengaluru, or I have visit Bengaluru?',
          'correct': 'I have visited Bengaluru.',
          'wrong': 'I have visit Bengaluru.',
          'tip': 'Present Perfect requires the V3 past participle: "have visited"!',
        },
        {
          'qEn': 'Question 2: Asking a friend if they have ever eaten Italian pasta:',
          'qMl': 'ചോദ്യം 2: ഇറ്റാലിയൻ പാസ്ത കഴിച്ചിട്ടുണ്ടോ എന്ന് ചോദിക്കാൻ:',
          'audio': 'Question 2: Is it Have you ever eaten Italian pasta, or Did you ever eaten Italian pasta?',
          'correct': 'Have you ever eaten Italian pasta?',
          'wrong': 'Did you ever eaten Italian pasta?',
          'tip': 'Life experience questions use "Have you ever + V3": "Have you ever eaten"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 32: Present Perfect vs Simple Past (The Time Anchor Test)
    // -------------------------------------------------------------------------
    32: const DayCurriculumSpec(
      day: 32,
      topicEmoji: '🏎️',
      titleEn: 'Day 32: Present Perfect vs Simple Past',
      titleMl: 'ഡേ 32: Present Perfect വേഴ്സസ് Simple Past കൃത്യമായി ഉപയോഗിക്കാം',
      greetingEn: 'Welcome to Day 32! 🌟 Today we master the critical difference between unspecified life experiences ("have done") and specific finished past moments ("did yesterday")!',
      greetingMl: 'ഡേ 32 ലേക്ക് സ്വാഗതം! 🌟 കൃത്യമായ സമയം പറയുമ്പോൾ Simple Past ("I did yesterday") എന്നും, സമയം പറയാതെ അനുഭവം പറയുമ്പോൾ Present Perfect ("I have done") എന്നും എപ്പോൾ ഉപയോഗിക്കണമെന്ന് ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 32! Today we master the difference between Present Perfect and Simple Past. Ready to start?',
      blueprintTitle: 'THE TIME ANCHOR FORMULA',
      blueprintExplanationEn: 'If you state a specific finished time anchor (yesterday, last year, in 2021, two hours ago), ALWAYS use Simple Past ("I submitted the report yesterday"). If the time is unstated, ongoing, or represents life experience, use Present Perfect ("I have submitted the report")!',
      blueprintExplanationMl: 'കഴിഞ്ഞുപോയ കൃത്യമായ സമയം (yesterday, last month, at 9 AM) പറയുമ്പോൾ Simple Past ഉപയോഗിക്കുക ("I completed it yesterday"). സമയം പറയാതെ കാര്യം പൂർത്തിയായി എന്ന് മാത്രം സൂചിപ്പിക്കുമ്പോൾ Present Perfect ("I have completed it").',
      blueprintRules: [
        {'subject': 'Finished Time Anchor (Past Simple)', 'en': 'I graduated from university in 2022.', 'ml': 'ഞാൻ 2022-ൽ ബിരുദം നേടി (കൃത്യമായ വർഷം = Simple Past).'},
        {'subject': 'Unspecified Experience (Present Perfect)', 'en': 'I have completed several advanced certifications.', 'ml': 'ഞാൻ നിരവധി അഡ്വാൻസ്ഡ് സർട്ടിഫിക്കേഷനുകൾ പൂർത്തിയാക്കിയിട്ടുണ്ട് (സമയം പറയാത്ത അനുഭവം).'},
        {'subject': 'Current Status with Just / Already', 'en': 'Our engineering team has just deployed the update.', 'ml': 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ടീം ഇപ്പോൾ അപ്ഡേറ്റ് റിലീസ് ചെയ്തു കഴിഞ്ഞു.'},
      ],
      drills: [
        {'en': 'I resolved three critical issues yesterday afternoon.', 'ml': 'ഇന്നലെ ഉച്ചതിരിഞ്ഞ് ഞാൻ മൂന്ന് നിർണായക പ്രശ്നങ്ങൾ പരിഹരിച്ചു.', 'rule': 'Simple Past: resolved + yesterday afternoon'},
        {'en': 'Have you ever led a cross-functional project team?', 'ml': 'നിങ്ങൾ എപ്പോഴെങ്കിലും വ്യത്യസ്ത ടീമുകളെ ഒരുമിച്ച് നയിച്ചിട്ടുണ്ടോ?', 'rule': 'Present Perfect: Have you ever led'},
        {'en': 'She has already reviewed the entire code pull request.', 'ml': 'അവൾ ഇതിനകം കോഡ് പുൾ റിക്വസ്റ്റ് പൂർണ്ണമായി റിവ്യൂ ചെയ്തിട്ടുണ്ട്.', 'rule': 'Present Perfect: has already reviewed'},
        {'en': 'We launched our product in Europe last quarter.', 'ml': 'കഴിഞ്ഞ പാദത്തിലാണ് ഞങ്ങൾ യൂറോപ്പിൽ ഞങ്ങളുടെ ഉൽപ്പന്നം പുറത്തിറക്കിയത്.', 'rule': 'Simple Past: launched + last quarter'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: You sent the invoice two hours ago. How do you say it?',
          'qMl': 'ചോദ്യം 1: രണ്ട് മണിക്കൂർ മുമ്പ് ഇൻവോയ്സ് അയച്ചു എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it I sent the invoice two hours ago, or I have sent the invoice two hours ago?',
          'correct': 'I sent the invoice two hours ago.',
          'wrong': 'I have sent the invoice two hours ago.',
          'tip': 'Two hours ago is a finished past time anchor, so use Simple Past: "I sent"!',
        },
        {
          'qEn': 'Question 2: Asking if someone has ever visited Germany in their life:',
          'qMl': 'ചോദ്യം 2: എപ്പോഴെങ്കിലും ജർമ്മനി സന്ദർശിച്ചിട്ടുണ്ടോ എന്ന് ചോദിക്കാൻ:',
          'audio': 'Question 2: Is it Have you ever visited Germany, or Did you ever visited Germany?',
          'correct': 'Have you ever visited Germany?',
          'wrong': 'Did you ever visited Germany?',
          'tip': 'General life experiences without a time anchor use "Have you ever + V3"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 33: Sequence of Events (The Past Perfect: had + V3)
    // -------------------------------------------------------------------------
    33: const DayCurriculumSpec(
      day: 33,
      topicEmoji: '🚁',
      titleEn: 'Day 33: Sequence of Events (The Past Perfect)',
      titleMl: 'ഡേ 33: കഴിഞ്ഞകാലത്തെ രണ്ട് കാര്യങ്ങളുടെ ക്രമം പറയാൻ Past Perfect (had + V3)',
      greetingEn: 'Welcome to Day 33! 🌟 Today we master the Past Perfect tense (had + V3) to clearly describe which past event happened first before another event took place!',
      greetingMl: 'ഡേ 33 ലേക്ക് സ്വാഗതം! 🌟 കഴിഞ്ഞകാലത്ത് നടന്ന രണ്ട് കാര്യങ്ങളിൽ ആദ്യം സംഭവിച്ചതിനെ വ്യക്തമാക്കാൻ Past Perfect (had + V3) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 33! Today we master the Past Perfect tense to describe the exact sequence of past events.',
      blueprintTitle: 'THE PAST BEFORE THE PAST',
      blueprintExplanationEn: 'When two actions happened in the past, use "had + V3" for the EARLIER action, and Simple Past (V2) for the later action. For example: "By the time the manager arrived, the team had already finalized the budget."',
      blueprintExplanationMl: 'കഴിഞ്ഞകാലത്ത് രണ്ട് കാര്യങ്ങൾ നടന്നപ്പോൾ ആദ്യം സംഭവിച്ചതിന് "had + V3" ഉപയോഗിക്കുക. രണ്ടാമത് സംഭവിച്ചതിന് Simple Past ("When I reached the station, the train had already left").',
      blueprintRules: [
        {'subject': 'First Action (Past Perfect)', 'en': 'The client had approved the proposal before we started development.', 'ml': 'ഞങ്ങൾ പണി തുടങ്ങുന്നതിന് മുമ്പ് തന്നെ ക്ലയന്റ് പ്രൊപ്പോസൽ അംഗീകരിച്ചിരുന്നു.'},
        {'subject': 'Later Action (Simple Past)', 'en': 'When our supervisor called, we had already backed up the data.', 'ml': 'സൂപ്പർവൈസർ വിളിച്ചപ്പോഴേക്കും ഞങ്ങൾ ഡാറ്റ ബാക്കപ്പ് ചെയ്തു കഴിഞ്ഞിരുന്നു.'},
        {'subject': 'Negative Past Perfect', 'en': 'He had not received the onboarding credentials until yesterday.', 'ml': 'ഇന്നലെ വരെ അയാൾക്ക് ലോഗിൻ വിവരങ്ങൾ ലഭിച്ചിരുന്നില്ല.'},
      ],
      drills: [
        {'en': 'When the power went out, I had already saved all my project files.', 'ml': 'വൈദ്യുതി പോയപ്പോഴേക്കും ഞാൻ എന്റെ എല്ലാ പ്രോജക്റ്റ് ഫയലുകളും സേവ് ചെയ്തിരുന്നു.', 'rule': 'Past Perfect: had already saved before power went out'},
        {'en': 'By the time the conference began, all attendees had registered online.', 'ml': 'സമ്മേളനം ആരംഭിച്ചപ്പോഴേക്കും പങ്കെടുത്തവരെല്ലാം ഓൺലൈനായി രജിസ്റ്റർ ചെയ്തിരുന്നു.', 'rule': 'Sequence: had registered before conference began'},
        {'en': 'She realized that she had left her access badge on the office desk.', 'ml': 'ഓഫീസ് മേശപ്പുറത്താണ് തിരിച്ചറിയൽ കാർഡ് വെച്ചുപോന്നതെന്ന് അവൾക്ക് മനസ്സിലായി.', 'rule': 'Earlier Past: had left'},
        {'en': 'Before joining our tech team, Rahul had managed infrastructure in Dubai.', 'ml': 'ഞങ്ങളുടെ ടീമിൽ ചേരുന്നതിന് മുമ്പ് രാഹുൽ ദുബായിൽ ഇൻഫ്രാസ്ട്രക്ചർ കൈകാര്യം ചെയ്തിരുന്നു.', 'rule': 'Prior History: had managed'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: The flight departed before you arrived at the terminal:',
          'qMl': 'ചോദ്യം 1: നിങ്ങൾ എയർപോർട്ടിൽ എത്തുന്നതിന് മുമ്പ് വിമാനം പോയിക്കഴിഞ്ഞിരുന്നു എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it The flight had departed before I arrived, or The flight departed before I had arrived?',
          'correct': 'The flight had departed before I arrived.',
          'wrong': 'The flight departed before I had arrived.',
          'tip': 'The earlier action (flight departure) gets Past Perfect: "had departed"!',
        },
        {
          'qEn': 'Question 2: Correctly expressing that you had finished dinner before your friend arrived:',
          'qMl': 'ചോദ്യം 2: സുഹൃത്ത് വരുന്നതിന് മുമ്പ് ഞാൻ ഭക്ഷണം കഴിച്ചിരുന്നു എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it I had already eaten dinner when he arrived, or I have already eaten dinner when he arrived?',
          'correct': 'I had already eaten dinner when he arrived.',
          'wrong': 'I have already eaten dinner when he arrived.',
          'tip': 'In a past timeline, use "had already eaten", not "have"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 34: Future Forms Mastery (Plans, Predictions & Schedules)
    // -------------------------------------------------------------------------
    34: const DayCurriculumSpec(
      day: 34,
      topicEmoji: '🏥',
      titleEn: 'Day 34: Future Forms Mastery (Plans, Schedules & Predictions)',
      titleMl: 'ഡേ 34: ഭാവി കാര്യങ്ങൾ കൃത്യമായി പറയാൻ Will, Going to, Present Continuous',
      greetingEn: 'Welcome to Day 34! 🌟 Today we master the three ways to express the future: spontaneous promises ("will"), calculated plans ("going to"), and fixed calendar schedules (Present Continuous)!',
      greetingMl: 'ഡേ 34 ലേക്ക് സ്വാഗതം! 🌟 ഭാവിയെക്കുറിച്ച് സംസാരിക്കാൻ 3 വഴികൾ: പെട്ടെന്നുള്ള തീരുമാനങ്ങൾക്ക് "will", നേരത്തെ തീരുമാനിച്ച പ്ലാനുകൾക്ക് "going to", ഉറപ്പിച്ച ഷെഡ്യൂളുകൾക്ക് Present Continuous!',
      greetingAudio: 'Welcome to Day 34! Today we master the future forms: will, going to, and scheduled continuous tenses.',
      blueprintTitle: 'THE FUTURE SPECTRUM BLUEPRINT',
      blueprintExplanationEn: 'Use "will" for spontaneous offers and promises ("I will assist you right now"). Use "going to" for premeditated intentions and observable trends ("We are going to upgrade our servers"). Use Present Continuous for fixed calendar appointments ("I am flying to London this Friday")!',
      blueprintExplanationMl: 'പെട്ടെന്നുള്ള തീരുമാനങ്ങൾക്കും വാഗ്ദാനങ്ങൾക്കും "will" ഉപയോഗിക്കുക ("I will help you"). മുൻകൂട്ടി തീരുമാനിച്ച പ്ലാനുകൾക്ക് "going to" ("I am going to learn Python"). ഉറപ്പിച്ച ടൈംടേബിൾ അല്ലെങ്കിൽ കലണ്ടർ മീറ്റിംഗുകൾക്ക് Present Continuous ("I am meeting the manager at 3 PM").',
      blueprintRules: [
        {'subject': 'Fixed Calendar Appointment', 'en': 'We are hosting the quarterly shareholder meeting tomorrow at 10 AM.', 'ml': 'ഞങ്ങൾ നാളെ രാവിലെ 10 മണിക്ക് ഷെയർഹോൾഡർ മീറ്റിംഗ് നടത്തുന്നു.'},
        {'subject': 'Premeditated Intention', 'en': 'I am going to redesign the customer onboarding flow this weekend.', 'ml': 'ഈ വാരാന്ത്യത്തിൽ കസ്റ്റമർ ഓൺബോർഡിംഗ് രീതി അടിമുടി മാറ്റാൻ ഞാൻ ഉദ്ദേശിക്കുന്നു.'},
        {'subject': 'Spontaneous Offer / Promise', 'en': 'Don\'t worry about the presentation slides; I will compile them for you.', 'ml': 'പ്രസന്റേഷനെക്കുറിച്ച് വിഷമിക്കേണ്ട; ഞാൻ നിങ്ങൾക്കായി അത് തയ്യാറാക്കിത്തരാം.'},
      ],
      drills: [
        {'en': 'I am meeting our regional director tomorrow at two in the afternoon.', 'ml': 'നാളെ ഉച്ചയ്ക്ക് രണ്ടു മണിക്ക് ഞാൻ ഞങ്ങളുടെ റീജിയണൽ ഡയറക്ടറെ കാണുന്നുണ്ട്.', 'rule': 'Fixed Appointment: am meeting + specific time'},
        {'en': 'Our engineering department is going to adopt automated testing workflows.', 'ml': 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ഡിപ്പാർട്ട്മെന്റ് ഓട്ടോമേറ്റഡ് ടെസ്റ്റിംഗ് രീതികൾ നടപ്പിലാക്കാൻ പോകുന്നു.', 'rule': 'Planned Intention: is going to adopt'},
        {'en': 'That suitcase looks heavy; let me help, I will carry it upstairs for you.', 'ml': 'ആ സ്യൂട്ട്കേസിന് നല്ല ഭാരമുണ്ട്; ഞാൻ സഹായിക്കാം, ഞാൻ മുകളിലേക്ക് എടുത്തു തരാം.', 'rule': 'Instant Offer: I will carry'},
        {'en': 'Look at those dark clouds gathering; it is definitely going to rain soon.', 'ml': 'ആ കറുത്ത കാർമേഘങ്ങൾ നോക്കൂ; ഉടൻ തന്നെ മഴ പെയ്യാൻ പോകുന്നു.', 'rule': 'Evidence-Based Prediction: is going to rain'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: You have a scheduled flight to Mumbai on Friday. How do you describe it?',
          'qMl': 'ചോദ്യം 1: വെള്ളിയാഴ്ച മുംബൈയിലേക്ക് ടിക്കറ്റെടുത്ത യാത്രയെക്കുറിച്ച് പറയാൻ:',
          'audio': 'Question 1: Is it I am flying to Mumbai on Friday, or I will to fly to Mumbai on Friday?',
          'correct': 'I am flying to Mumbai on Friday.',
          'wrong': 'I will to fly to Mumbai on Friday.',
          'tip': 'Confirmed calendar bookings use Present Continuous: "I am flying"!',
        },
        {
          'qEn': 'Question 2: Spontaneously offering immediate assistance with a ringing office phone:',
          'qMl': 'ചോദ്യം 2: ബെല്ലടിക്കുന്ന ഓഫീസ് ഫോൺ പെട്ടെന്ന് എടുക്കാമെന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it I will answer the phone, or I am answering the phone right now for sure?',
          'correct': 'I will answer the phone.',
          'wrong': 'I am answering the phone right now for sure.',
          'tip': 'Instant spontaneous decisions made at the moment of speaking take "will"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 35: Real Possibilities (The First Conditional)
    // -------------------------------------------------------------------------
    35: const DayCurriculumSpec(
      day: 35,
      topicEmoji: '🧙',
      titleEn: 'Day 35: Real Possibilities (The First Conditional)',
      titleMl: 'ഡേ 35: യഥാർത്ഥ സാധ്യതകളും ഫലങ്ങളും പറയാൻ First Conditional',
      greetingEn: 'Welcome to Day 35! 🌟 Today we master the First Conditional ("If + Present Simple, will + V1") to discuss realistic consequences, negotiations, and plans!',
      greetingMl: 'ഡേ 35 ലേക്ക് സ്വാഗതം! 🌟 ഭാവിയിൽ നടക്കാൻ ഏറെ സാധ്യതയുള്ള കാര്യങ്ങളും അവയുടെ ഫലങ്ങളും വ്യക്തമാക്കാൻ First Conditional ("If + Present Simple, will + V1") ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 35! Today we master the First Conditional for real possibilities and future outcomes.',
      blueprintTitle: 'CAUSE & FUTURE EFFECT BLUEPRINT',
      blueprintExplanationEn: 'In First Conditional, the "If" clause always takes Present Simple (NEVER "will"). The main result clause takes "will + V1". Structure: "If you practice consistently, your fluency will improve dramatically."',
      blueprintExplanationMl: 'First Conditional-ൽ If വരുന്ന ഭാഗത്ത് Present Simple മാത്രമേ വരാവൂ, will വരാൻ പാടില്ല ("If you study", NOT "If you will study"). അതിന്റെ ഫലം വരുന്ന ഭാഗത്താണ് will ഉപയോഗിക്കേണ്ടത് ("you will succeed").',
      blueprintRules: [
        {'subject': 'If + Present Simple (Condition)', 'en': 'If we optimize our database queries, the application will respond instantly.', 'ml': 'ഡാറ്റാബേസ് ക്വറികൾ ഒപ്റ്റിമൈസ് ചെയ്താൽ, ആപ്പ് പെട്ടെന്ന് പ്രവർത്തിക്കും.'},
        {'subject': 'Negative Condition (Unless / If not)', 'en': 'Unless we reserve tickets today, we will miss the international keynote.', 'ml': 'ഇന്ന് ടിക്കറ്റ് ബുക്ക് ചെയ്തില്ലെങ്കിൽ നമുക്ക് ആ കോൺഫറൻസ് നഷ്ടപ്പെടും.'},
        {'subject': 'Inverted Clauses', 'en': 'The client will sign the contract if we deliver the prototype on time.', 'ml': 'സമയത്തിന് പ്രോട്ടോടൈപ്പ് നൽകിയാൽ ക്ലയന്റ് കരാറിൽ ഒപ്പുവെക്കും.'},
      ],
      drills: [
        {'en': 'If you speak English every single day, you will gain natural confidence.', 'ml': 'ദിവസവും ഇംഗ്ലീഷ് സംസാരിച്ചാൽ നിങ്ങൾക്ക് സ്വാഭാവികമായ ആത്മവിശ്വാസം ലഭിക്കും.', 'rule': 'First Conditional: If you speak (V1), you will gain'},
        {'en': 'If our team finishes the sprint early, we will launch the feature on Monday.', 'ml': 'ഞങ്ങളുടെ ടീം പണി നേരത്തെ തീർത്താൽ തിങ്കളാഴ്ച ഈ ഫീച്ചർ പുറത്തിറക്കും.', 'rule': 'Future Probability: finishes -> will launch'},
        {'en': 'Unless the manager approves the budget, we will postpone the marketing campaign.', 'ml': 'മാനേജർ ബഡ്ജറ്റ് അംഗീകരിച്ചില്ലെങ്കിൽ ഞങ്ങൾ പരസ്യ ക്യാമ്പയിൻ നീട്ടിവെക്കും.', 'rule': 'Unless = If not: Unless the manager approves'},
        {'en': 'If the server load exceeds capacity, our backup cluster will activate automatically.', 'ml': 'സെർവർ ലോഡ് പരിധി കവിഞ്ഞാൽ ബാക്കപ്പ് ക്ലസ്റ്റർ തനിയെ പ്രവർത്തിക്കും.', 'rule': 'Conditional Logic: exceeds -> will activate'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: If it rains tomorrow, we will conduct the meeting indoors:',
          'qMl': 'ചോദ്യം 1: നാളെ മഴ പെയ്താൽ മീറ്റിംഗ് അകത്ത് വെച്ച് നടത്തും എന്ന് പറയാൻ:',
          'audio': 'Question 1: Is it If it rains tomorrow we will meet indoors, or If it will rain tomorrow we will meet indoors?',
          'correct': 'If it rains tomorrow, we will meet indoors.',
          'wrong': 'If it will rain tomorrow, we will meet indoors.',
          'tip': 'Never use "will" in the "If" condition clause; use Present Simple: "If it rains"!',
        },
        {
          'qEn': 'Question 2: Predicting success if your colleague prepares thoroughly:',
          'qMl': 'ചോദ്യം 2: നന്നായി തയ്യാറെടുത്താൽ ഇന്റർവ്യൂവിൽ വിജയിക്കും എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it If you prepare well you will clear the interview, or If you prepare well you would clear the interview?',
          'correct': 'If you prepare well, you will clear the interview.',
          'wrong': 'If you prepare well, you would clear the interview.',
          'tip': 'First Conditional pairs Present Simple with "will", not "would"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 36: Imaginary Situations (The Second Conditional)
    // -------------------------------------------------------------------------
    36: const DayCurriculumSpec(
      day: 36,
      topicEmoji: '🏴‍☠️',
      titleEn: 'Day 36: Imaginary Situations (The Second Conditional)',
      titleMl: 'ഡേ 36: സങ്കൽപ്പങ്ങളും സാധ്യതയില്ലാത്ത കാര്യങ്ങളും പറയാൻ Second Conditional',
      greetingEn: 'Welcome to Day 36! 🌟 Today we enter the world of imagination and hypotheticals with the Second Conditional ("If + Past Simple, would + V1")!',
      greetingMl: 'ഡേ 36 ലേക്ക് സ്വാഗതം! 🌟 ഇപ്പോൾ യാഥാർത്ഥ്യമല്ലാത്ത, സങ്കൽപ്പപരമായ കാര്യങ്ങളും ആഗ്രഹങ്ങളും പറയാൻ Second Conditional ("If + Past Simple, would + V1") ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 36! Today we master the Second Conditional for imaginary scenarios and hypothetical dreams.',
      blueprintTitle: 'THE HYPOTHETICAL DREAM BLUEPRINT',
      blueprintExplanationEn: 'Use Second Conditional for dreams, unreal present situations, and advice. Rule: "If + Past Simple (V2), would + Base Verb (V1)". Note: In formal English, use "were" for all subjects ("If I were you", "If she were here")!',
      blueprintExplanationMl: 'യഥാർത്ഥമല്ലാത്ത സങ്കൽപ്പങ്ങൾ പറയുമ്പോൾ If വരുന്ന ഭാഗത്ത് Past Simple-ഉം, ഫലം വരുന്ന ഭാഗത്ത് would + V1-ഉം ഉപയോഗിക്കുക. "ഞാൻ നിങ്ങളുടെ സ്ഥാനത്തായിരുന്നെങ്കിൽ" എന്ന് പറയാൻ "If I were you" എന്ന് പ്രയോഗിക്കുക.',
      blueprintRules: [
        {'subject': 'Unreal Present Condition', 'en': 'If I had more leisure time, I would learn Spanish and photography.', 'ml': 'എനിക്ക് കൂടുതൽ ഒഴിവുസമയം ഉണ്ടായിരുന്നെങ്കിൽ ഞാൻ സ്പാനിഷും ഫോട്ടോഗ്രാഫിയും പഠിക്കുമായിരുന്നു.'},
        {'subject': 'Giving Advice (If I were you)', 'en': 'If I were you, I would negotiate for remote work flexibility.', 'ml': 'ഞാൻ നിങ്ങളുടെ സ്ഥാനത്തായിരുന്നെങ്കിൽ റിമോട്ട് വർക്ക് സൗകര്യം ആവശ്യപ്പെടുമായിരുന്നു.'},
        {'subject': 'Hypothetical Career', 'en': 'If she led the design agency, she would champion accessible user interfaces.', 'ml': 'അവളാണ് ഡിസൈൻ ഏജൻസിയെ നയിച്ചിരുന്നതെങ്കിൽ എല്ലാവർക്കും എളുപ്പമുള്ള ഇന്റർഫേസുകൾക്ക് മുൻഗണന നൽകിയേനെ.'},
      ],
      drills: [
        {'en': 'If I won the global innovation award, I would fund research in clean energy.', 'ml': 'എനിക്ക് ഗ്ലോബൽ ഇന്നൊവേഷൻ അവാർഡ് ലഭിച്ചാൽ ഞാൻ ക്ലീൻ എനർജി ഗവേഷണങ്ങൾക്ക് ധനസഹായം നൽകും.', 'rule': 'Second Conditional: If I won (V2), I would fund (V1)'},
        {'en': 'If I were the founder of this startup, I would foster a four-day work week.', 'ml': 'ഞാനാണ് ഈ സ്റ്റാർട്ടപ്പിന്റെ സ്ഥാപകനെങ്കിൽ ആഴ്ചയിൽ നാല് ദിവസത്തെ ജോലിരീതി കൊണ്ടുവരുമായിരുന്നു.', 'rule': 'Subjunctive: If I were + would foster'},
        {'en': 'If we had unlimited cloud storage, we would retain raw logs indefinitely.', 'ml': 'പരിധിയില്ലാത്ത ക്ലൗഡ് സ്റ്റോറേജ് ഉണ്ടായിരുന്നെങ്കിൽ ഞങ്ങൾ എല്ലാ ലോഗുകളും എപ്പോഴും സൂക്ഷിക്കുമായിരുന്നു.', 'rule': 'Hypothetical Resource: If we had + would retain'},
        {'en': 'If you lived in London, which neighborhood would you choose to stay in?', 'ml': 'നിങ്ങൾ ലണ്ടനിലാണ് ജീവിച്ചിരുന്നതെങ്കിൽ ഏത് പ്രദേശത്ത് താമസിക്കാൻ തിരഞ്ഞെടുക്കുമായിരുന്നു?', 'rule': 'Hypothetical Question: would you choose'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Giving polite career advice: "If I was/were you, I would take that offer":',
          'qMl': 'ചോദ്യം 1: ഞാൻ നിങ്ങളുടെ സ്ഥാനത്തായിരുന്നെങ്കിൽ എന്ന് ഉപദേശം നൽകാൻ:',
          'audio': 'Question 1: Is it If I were you I would accept the job, or If I will be you I would accept the job?',
          'correct': 'If I were you, I would accept the job.',
          'wrong': 'If I will be you, I would accept the job.',
          'tip': 'Formal hypothetical advice uses the subjunctive: "If I were you, I would..."!',
        },
        {
          'qEn': 'Question 2: Talking about an imaginary scenario if you had a private airplane:',
          'qMl': 'ചോദ്യം 2: സ്വന്തമായി വിമാനം ഉണ്ടായിരുന്നെങ്കിൽ എന്ന് സങ്കൽപ്പിക്കാൻ:',
          'audio': 'Question 2: Is it If I had a private jet I would travel the globe, or If I have a private jet I would travel the globe?',
          'correct': 'If I had a private jet, I would travel the globe.',
          'wrong': 'If I have a private jet, I would travel the globe.',
          'tip': 'Second conditional requires the past simple tense in the "if" clause: "If I had"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 37: Nuanced Possibility (Might / May / Could / Would)
    // -------------------------------------------------------------------------
    37: const DayCurriculumSpec(
      day: 37,
      topicEmoji: '🚦',
      titleEn: 'Day 37: Nuanced Possibility (Might, May, Could & Would)',
      titleMl: 'ഡേ 37: കാര്യങ്ങളുടെ സാധ്യതയും മര്യാദയും വ്യക്തമാക്കാൻ Modals',
      greetingEn: 'Welcome to Day 37! 🌟 Today we master the modals of probability and tact: might, may, could, and would to express nuanced uncertainty without sounding aggressive or rigid!',
      greetingMl: 'ഡേ 37 ലേക്ക് സ്വാഗതം! 🌟 ഒരു കാര്യം നടക്കാൻ സാധ്യതയുണ്ടെന്ന് പക്വതയോടെയും വിനയത്തോടെയും പറയാൻ Might, May, Could, Would എന്നിവ ഉപയോഗിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 37! Today we master might, may, could, and would for professional possibility.',
      blueprintTitle: 'THE DEGREES OF PROBABILITY FORMULA',
      blueprintExplanationEn: 'Avoid rigid absolutes like "This will definitely happen". Senior communicators use "might" (30-40% chance), "could" (practical possibility), and "would" (hypothetical outcome) to reflect realistic situations and intellectual humility.',
      blueprintExplanationMl: '100% ഉറപ്പില്ലാത്ത കാര്യങ്ങളിൽ "will" എന്ന് തീർത്തു പറയാതെ, "might" (സാധ്യതയുണ്ട്), "could" (ചെയ്യാൻ സാധിച്ചേക്കാം) എന്ന് സംസാരിക്കുന്നത് പ്രൊഫഷണൽ മീറ്റിംഗുകളിൽ നിങ്ങളുടെ വിശ്വാസ്യത വർദ്ധിപ്പിക്കും.',
      blueprintRules: [
        {'subject': 'Tentative Possibility (Might)', 'en': 'Our overseas shipment might face customs delays due to port congestion.', 'ml': 'തുറമുഖത്തെ തിരക്ക് കാരണം നമ്മുടെ വിദേശ ഷിപ്പ്മെന്റ് വൈകാൻ സാധ്യതയുണ്ട് (might).'},
        {'subject': 'Capable Alternative (Could)', 'en': 'We could migrate these services to micro-containers to reduce monthly overhead.', 'ml': 'ചെലവ് കുറയ്ക്കാൻ നമുക്ക് ഈ സർവീസുകളെ കണ്ടെയ്നറുകളിലേക്ക് മാറ്റാൻ സാധിച്ചേക്കും (could).'},
        {'subject': 'Soft Proposal (Would)', 'en': 'Implementing two-factor authentication would protect user accounts significantly.', 'ml': 'ടു-ഫാക്ടർ ഓതന്റിക്കേഷൻ നടപ്പിലാക്കുന്നത് ഉപയോക്താക്കളുടെ അക്കൗണ്ടുകൾ കൂടുതൽ സുരക്ഷിതമാക്കും (would).'},
      ],
      drills: [
        {'en': 'The client might request additional architectural changes before final sign-off.', 'ml': 'അന്തിമ അംഗീകാരത്തിന് മുമ്പ് ക്ലയന്റ് കൂടുതൽ മാറ്റങ്ങൾ ആവശ്യപ്പെട്ടേക്കാം.', 'rule': 'Uncertainty: might request'},
        {'en': 'Adopting this automated build system could save our team several hours each week.', 'ml': 'ഈ ഓട്ടോമേറ്റഡ് ബിൽഡ് സിസ്റ്റം ഉപയോഗിച്ചാൽ നമ്മുടെ ടീമിന് ഓരോ ആഴ്ചയും മണിക്കൂറുകൾ ലാഭിക്കാൻ കഴിഞ്ഞേക്കും.', 'rule': 'Potential Benefit: could save'},
        {'en': 'A scheduled maintenance window on Sunday night would minimize user disruption.', 'ml': 'ഞായറാഴ്ച രാത്രി മെയിന്റനൻസ് നടത്തുന്നത് ഉപയോക്താക്കൾക്കുണ്ടാകുന്ന തടസ്സം കുറയ്ക്കും.', 'rule': 'Hypothetical Preference: would minimize'},
        {'en': 'Severe weather conditions may disrupt regional transportation links tomorrow.', 'ml': 'മോശം കാലാവസ്ഥ നാളെ പ്രാദേശിക ഗതാഗതത്തെ തടസ്സപ്പെടുത്തിയേക്കാം.', 'rule': 'Formal Possibility: may disrupt'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing that a project might take longer than estimated:',
          'qMl': 'ചോദ്യം 1: പ്രോജക്റ്റ് വിചാരിച്ചതിലും വൈകിയേക്കാം എന്ന് വിനയത്തോടെ പറയാൻ:',
          'audio': 'Question 1: Is it The project might take longer than anticipated, or The project will to take longer maybe?',
          'correct': 'The project might take longer than anticipated.',
          'wrong': 'The project will to take longer maybe.',
          'tip': 'Use modal "might + base verb" directly without clumsy filler words like "will to"!',
        },
        {
          'qEn': 'Question 2: Suggesting an alternative feature that could assist clients:',
          'qMl': 'ചോദ്യം 2: ഈ ഫീച്ചർ ക്ലയന്റുകളെ സഹായിച്ചേക്കാം എന്ന് നിർദ്ദേശിക്കാൻ:',
          'audio': 'Question 2: Is it This feature could improve user retention, or This feature can to improve user retention?',
          'correct': 'This feature could improve user retention.',
          'wrong': 'This feature can to improve user retention.',
          'tip': 'Modals are followed directly by the bare infinitive: "could improve"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 38: Mastering Polite Requests (Could you...? Would you mind...?)
    // -------------------------------------------------------------------------
    38: const DayCurriculumSpec(
      day: 38,
      topicEmoji: '🤖',
      titleEn: 'Day 38: Mastering Polite Requests (Could you...? Would you mind...?)',
      titleMl: 'ഡേ 38: മാന്യമായി ആവശ്യപ്പെടാൻ Could you, Would you mind',
      greetingEn: 'Welcome to Day 38! 🌟 Today we master the art of polite, executive requests ("Could you please...", "Would you mind + ing") to eliminate blunt commands!',
      greetingMl: 'ഡേ 38 ലേക്ക് സ്വാഗതം! 🌟 മറ്റുള്ളവരോട് ആജ്ഞാപിക്കുന്നതിന് പകരം ബഹുമാനത്തോടെ കാര്യങ്ങൾ ആവശ്യപ്പെടാൻ "Could you please...", "Would you mind..." എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 38! Today we transform blunt commands into respectful executive requests.',
      blueprintTitle: 'THE EXECUTIVE DIPLOMACY FORMULA',
      blueprintExplanationEn: 'Never say "Give me that report" or "Do this immediately". Soften requests using: 1) "Could you please + V1..." 2) "Would you mind + V-ing..." (Remember: mind always takes -ing!) and 3) "I would appreciate it if you could...".',
      blueprintExplanationMl: 'നേരിട്ട് ആജ്ഞാപിക്കുന്നത് ("Send me this") പരുഷമായി തോന്നും. പകരം "Could you please share the file?", "Would you mind reviewing the draft?" എന്ന് ചോദിക്കുക. "Would you mind" ന് ശേഷം എപ്പോഴും verb-ing വരണം!',
      blueprintRules: [
        {'subject': 'Standard Polite Request', 'en': 'Could you please forward the meeting summary when you are free?', 'ml': 'സമയമുള്ളപ്പോൾ മീറ്റിംഗിന്റെ വിവരങ്ങൾ ഒന്ന് ഫോർവേഡ് ചെയ്യാമോ?'},
        {'subject': 'High Etiquette (Would you mind + ing)', 'en': 'Would you mind muting your microphone while the speaker presents?', 'ml': 'സ്പീക്കർ സംസാരിക്കുമ്പോൾ മൈക്രോഫോൺ ഒന്ന് മ്യൂട്ട് ചെയ്യാൻ ബുദ്ധിമുട്ടുണ്ടോ?'},
        {'subject': 'Soft Formal Inquiry', 'en': 'I was wondering if you could grant me access to the staging server.', 'ml': 'ടെസ്റ്റിംഗ് സെർവറിലേക്ക് പ്രവേശനം അനുവദിച്ചു തരുമോ എന്ന് ചോദിക്കാൻ വേണ്ടിയാണ്.'},
      ],
      drills: [
        {'en': 'Could you please share your screen so that everyone can follow the walk-through?', 'ml': 'എല്ലാവർക്കും കാണാൻ സാധിക്കുന്ന രീതിയിൽ സ്ക്രീൻ ഒന്ന് ഷെയർ ചെയ്യാമോ?', 'rule': 'Polite Imperative: Could you please share'},
        {'en': 'Would you mind reviewing this design specification before our morning standup?', 'ml': 'രാവിലത്തെ സ്റ്റാൻഡ്-അപ്പിന് മുമ്പ് ഈ ഡിസൈൻ ഒന്നു നോക്കാൻ ബുദ്ധിമുട്ടുണ്ടോ?', 'rule': 'High Etiquette: Would you mind reviewing (-ing)'},
        {'en': 'I was wondering if you could extend the project deadline by forty-eight hours.', 'ml': 'ഡെഡ്‌ലൈൻ 48 മണിക്കൂർ കൂടി നീട്ടിത്തരാൻ സാധിക്കുമോ എന്ന് ചോദിക്കുകയായിരുന്നു.', 'rule': 'Diplomatic Softener: I was wondering if you could extend'},
        {'en': 'Would you be kind enough to introduce me to the head of talent acquisition?', 'ml': 'എന്നെ റിക്രൂട്ട്മെന്റ് തലവന് ഒന്നു പരിചയപ്പെടുത്തിത്തരാൻ ദയവുണ്ടാകുമോ?', 'rule': 'Executive Etiquette: Would you be kind enough'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Asking someone politely to close the office door:',
          'qMl': 'ചോദ്യം 1: വാതിൽ അടയ്ക്കാമോ എന്ന് "Would you mind" ഉപയോഗിച്ച് ചോദിക്കാൻ:',
          'audio': 'Question 1: Is it Would you mind closing the door, or Would you mind to close the door?',
          'correct': 'Would you mind closing the door?',
          'wrong': 'Would you mind to close the door?',
          'tip': '"Would you mind" is strictly followed by the gerund (-ing): "Would you mind closing"!',
        },
        {
          'qEn': 'Question 2: Requesting an expedited code review from a busy colleague:',
          'qMl': 'ചോദ്യം 2: സഹപ്രവർത്തകനോട് ഒരു കോഡ് റിവ്യൂ ചെയ്തുതരുമോ എന്ന് വിനയത്തോടെ ചോദിക്കാൻ:',
          'audio': 'Question 2: Is it Could you please review my pull request today, or Give me review on my pull request today?',
          'correct': 'Could you please review my pull request today?',
          'wrong': 'Give me review on my pull request today?',
          'tip': 'Never use direct commands; always soften with "Could you please review"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 39: Making Compelling Suggestions (Why don\'t we...? How about...?)
    // -------------------------------------------------------------------------
    39: const DayCurriculumSpec(
      day: 39,
      topicEmoji: '🚪',
      titleEn: 'Day 39: Making Compelling Suggestions (Why don\'t we...? How about...?)',
      titleMl: 'ഡേ 39: പുതിയ ആശയങ്ങളും നിർദ്ദേശങ്ങളും അവതരിപ്പിക്കാൻ Suggestions',
      greetingEn: 'Welcome to Day 39! 🌟 Today we master collaborative suggestion frames ("Why don\'t we...", "How about + ing", "We could consider...") to inspire teamwork!',
      greetingMl: 'ഡേ 39 ലേക്ക് സ്വാഗതം! 🌟 ടീം മീറ്റിംഗുകളിൽ നിങ്ങളുടെ ആശയങ്ങൾ എല്ലാവർക്കും ഇഷ്ടപ്പെടുന്ന രീതിയിൽ നിർദ്ദേശിക്കാൻ "Why don\'t we...", "How about..." എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 39! Today we learn how to pitch compelling suggestions and invite collaboration.',
      blueprintTitle: 'THE COLLABORATIVE PROPOSAL FORMULA',
      blueprintExplanationEn: 'Influential leaders do not dictate; they pitch inclusive ideas using: 1) "Why don\'t we + V1..." 2) "How about + V-ing..." 3) "Shall we + V1..." and 4) "We could consider + V-ing...". This builds team ownership!',
      blueprintExplanationMl: 'ആശയങ്ങൾ അടിച്ചേൽപ്പിക്കുന്നതിന് പകരം, "നമുക്ക് ഇങ്ങനെ ചെയ്താലോ?" എന്ന് ചോദിക്കാൻ "Why don\'t we test this?", "How about rescheduling the meeting?" എന്ന് ഉപയോഗിക്കുക. "How about" ന് ശേഷം verb-ing വരണം.',
      blueprintRules: [
        {'subject': 'Inviting Inquiry (Why don\'t we)', 'en': 'Why don\'t we schedule a thirty-minute brainstorming session tomorrow?', 'ml': 'നാളെ അരമണിക്കൂർ സമയം ഒരു ചർച്ച നടത്തിയാലോ (Why don\'t we)?'},
        {'subject': 'Creative Proposal (How about + ing)', 'en': 'How about automating this manual data entry process using Python scripts?', 'ml': 'ഈ ഡാറ്റ എൻട്രി പൈത്തൺ സ്ക്രിപ്റ്റുകൾ വഴി ഓട്ടോമേറ്റ് ചെയ്താലോ (How about automating)?'},
        {'subject': 'Strategic Consideration', 'en': 'We could consider piloting the new feature with our beta users first.', 'ml': 'പുതിയ ഫീച്ചർ ആദ്യം ബീറ്റാ ഉപയോക്താക്കൾക്കിടയിൽ പരീക്ഷിക്കാൻ നമുക്ക് ആലോചിക്കാം.'},
      ],
      drills: [
        {'en': 'Why don\'t we take a five-minute coffee break before tackling the architecture review?', 'ml': 'ആർക്കിടെക്ചർ റിവ്യൂ തുടങ്ങുന്നതിന് മുമ്പ് നമുക്ക് 5 മിനിറ്റ് കോഫി ബ്രേക്ക് എടുത്താലോ?', 'rule': 'Suggestion: Why don\'t we take (V1)'},
        {'en': 'How about conducting a short usability poll among our daily active mobile users?', 'ml': 'നമ്മുടെ ആപ്പ് ഉപയോക്താക്കൾക്കിടയിൽ ഒരു ചെറിയ സർവേ നടത്തിയാലോ?', 'rule': 'Gerund Suggestion: How about conducting (-ing)'},
        {'en': 'Shall we draft the project timeline and assign deliverables during tomorrow\'s sync?', 'ml': 'നാളത്തെ മീറ്റിംഗിൽ നമുക്ക് പ്രോജക്റ്റ് ടൈംലൈൻ തയ്യാറാക്കി ജോലികൾ വീതിച്ചു നൽകിയാലോ?', 'rule': 'Inclusive Offer: Shall we draft'},
        {'en': 'We might want to explore caching frequently accessed database records in memory.', 'ml': 'എപ്പോഴും ആവശ്യമുള്ള ഡാറ്റ മെമ്മറിയിൽ കാഷെ ചെയ്യുന്നത് നമുക്ക് പരിഗണിക്കാവുന്നതാണ്.', 'rule': 'Tactful Innovation: We might want to explore'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Proposing to eat lunch together after a long meeting:',
          'qMl': 'ചോദ്യം 1: നമുക്ക് ഒരുമിച്ച് ലഞ്ച് കഴിച്ചാലോ എന്ന് "How about" ഉപയോഗിച്ച് ചോദിക്കാൻ:',
          'audio': 'Question 1: Is it How about having lunch together, or How about to have lunch together?',
          'correct': 'How about having lunch together?',
          'wrong': 'How about to have lunch together?',
          'tip': '"How about" takes the -ing gerund form: "How about having"!',
        },
        {
          'qEn': 'Question 2: Suggesting that the team test the backend API first:',
          'qMl': 'ചോദ്യം 2: നമുക്ക് ആദ്യം API ടെസ്റ്റ് ചെയ്താലോ എന്ന് ചോദിക്കാൻ:',
          'audio': 'Question 2: Is it Why don\'t we test the API first, or Why don\'t we to test the API first?',
          'correct': 'Why don\'t we test the API first?',
          'wrong': 'Why don\'t we to test the API first?',
          'tip': '"Why don\'t we" is followed by the bare base verb without "to": "Why don\'t we test"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 40: Articulating Personal Opinions (In my view...)
    // -------------------------------------------------------------------------
    40: const DayCurriculumSpec(
      day: 40,
      topicEmoji: '🌎',
      titleEn: 'Day 40: Articulating Personal Opinions (In my view... From my perspective)',
      titleMl: 'ഡേ 40: സ്വന്തം അഭിപ്രായങ്ങൾ പക്വതയോടെ തുറന്നു പറയാൻ Opinion Frames',
      greetingEn: 'Welcome to Day 40! 🌟 Today we replace basic "I think" statements with sophisticated executive opinion frames like "In my view...", "From my perspective...", and "I am convinced that..."!',
      greetingMl: 'ഡേ 40 ലേക്ക് സ്വാഗതം! 🌟 വെറുതെ "I think" എന്ന് മാത്രം പറയാതെ, സ്വന്തം അഭിപ്രായങ്ങൾ ശക്തമായും വ്യക്തമായും പറയാൻ "In my view...", "From my perspective..." എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 40! Today we elevate your personal opinion expressions with authority and clarity.',
      blueprintTitle: 'THE EXECUTIVE OPINION SPECTRUM',
      blueprintExplanationEn: 'Avoid repetitive "I think" or the non-standard "According to me". Use standard professional markers: 1) "In my opinion / In my view..." 2) "From my perspective / standpoint..." 3) "I firmly believe that..." and 4) "As far as I can tell...".',
      blueprintExplanationMl: 'സ്വന്തം അഭിപ്രായം പറയുമ്പോൾ "According to me" എന്ന് ഉപയോഗിക്കരുത് (അത് തെറ്റാണ്). പകരം "In my opinion...", "From my perspective..." (എന്റെ കാഴ്ചപ്പാടിൽ), "I firmly believe that..." (ഞാൻ ഉറച്ചു വിശ്വസിക്കുന്നു) എന്ന് പ്രയോഗിക്കുക.',
      blueprintRules: [
        {'subject': 'Professional Viewpoint', 'en': 'In my view, prioritizing user onboarding retention is more vital than raw user acquisition.', 'ml': 'എന്റെ വീക്ഷണത്തിൽ, പുതിയ ഉപയോക്താക്കളെ കണ്ടെത്തുന്നതിനേക്കാൾ പ്രധാനം നിലവിലുള്ളവരെ നിലനിർത്തുന്നതാണ്.'},
        {'subject': 'Authoritative Stance', 'en': 'From my perspective, microservices add unnecessary complexity for our small team size.', 'ml': 'എന്റെ കാഴ്ചപ്പാടിൽ, നമ്മുടെ ചെറിയ ടീമിന് മൈക്രോസർവീസുകൾ അനാവശ്യ സങ്കീർണ്ണത ഉണ്ടാക്കും.'},
        {'subject': 'Strong Conviction', 'en': 'I am convinced that comprehensive automated tests save months of production debugging.', 'ml': 'ഓട്ടോമേറ്റഡ് ടെസ്റ്റുകൾ മാസങ്ങളുടെ ഡീബഗ്ഗിംഗ് സമയം ലാഭിക്കുമെന്ന് ഞാൻ ഉറച്ചു വിശ്വസിക്കുന്നു.'},
      ],
      drills: [
        {'en': 'From my perspective, simplicity in software design always wins over clever complexity.', 'ml': 'എന്റെ വീക്ഷണത്തിൽ, സങ്കീർണ്ണതയേക്കാൾ എപ്പോഴും വിജയിക്കുന്നത് ലാളിത്യമുള്ള സോഫ്റ്റ്‌വെയർ ഡിസൈനാണ്.', 'rule': 'Opinion Framing: From my perspective'},
        {'en': 'In my view, consistent team documentation eliminates critical operational bottlenecks.', 'ml': 'എന്റെ അഭിപ്രായത്തിൽ, ചിട്ടയായ ഡോക്യുമെന്റേഷൻ ജോലിയിലെ കാലതാമസങ്ങൾ പൂർണ്ണമായി ഇല്ലാതാക്കും.', 'rule': 'Strategic Perspective: In my view'},
        {'en': 'I strongly believe that investing in employee mentorship accelerates company growth.', 'ml': 'ജീവനക്കാർക്ക് മാർഗ്ഗനിർദ്ദേശം നൽകുന്നത് കമ്പനിയുടെ വളർച്ച വേഗത്തിലാക്കുമെന്ന് ഞാൻ വിശ്വസിക്കുന്നു.', 'rule': 'Conviction Marker: I strongly believe that'},
        {'en': 'As far as I am concerned, delivering exceptional quality must never be compromised for speed.', 'ml': 'എന്നെ സംബന്ധിച്ചിടത്തോളം, വേഗതയ്ക്ക് വേണ്ടി ഗുണനിലവാരത്തിൽ വിട്ടുവീഴ്ച ചെയ്യാൻ പാടില്ല.', 'rule': 'Personal Principle: As far as I am concerned'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing your personal professional perspective in a meeting:',
          'qMl': 'ചോദ്യം 1: മീറ്റിംഗിൽ എന്റെ അഭിപ്രായത്തിൽ എന്ന് ശരിയായി പറയാൻ:',
          'audio': 'Question 1: Is it In my opinion this architecture is ideal, or According to me this architecture is ideal?',
          'correct': 'In my opinion, this architecture is ideal.',
          'wrong': 'According to me, this architecture is ideal.',
          'tip': 'Native English speakers do not use "According to me" for their own opinion; use "In my opinion" or "In my view"!',
        },
        {
          'qEn': 'Question 2: Stating your strong conviction regarding remote collaboration:',
          'qMl': 'ചോദ്യം 2: റിമോട്ട് ജോലിയെക്കുറിച്ച് നിങ്ങളുടെ ശക്തമായ ഉറപ്പ് പ്രകടിപ്പിക്കാൻ:',
          'audio': 'Question 2: Is it I am convinced that remote work fosters deep focus, or I am thinking that remote work fosters deep focus?',
          'correct': 'I am convinced that remote work fosters deep focus.',
          'wrong': 'I am thinking that remote work fosters deep focus.',
          'tip': 'Use "I am convinced that..." to articulate grounded, mature conviction!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 41: Agreeing with Conviction (I couldn\'t agree more / Exactly)
    // -------------------------------------------------------------------------
    41: const DayCurriculumSpec(
      day: 41,
      topicEmoji: '🏹',
      titleEn: 'Day 41: Agreeing with Conviction (I couldn\'t agree more / Exactly)',
      titleMl: 'ഡേ 41: പൂർണ്ണമായി യോജിപ്പ് പ്രകടിപ്പിക്കാൻ Agreement Expressions',
      greetingEn: 'Welcome to Day 41! 🌟 Today we master active agreement phrases ("I couldn\'t agree more", "You hit the nail on the head", "That is a valid point") to build instant rapport!',
      greetingMl: 'ഡേ 41 ലേക്ക് സ്വാഗതം! 🌟 മറ്റൊരാളുടെ ആശയത്തോട് വെറുതെ "yes" എന്ന് മാത്രം പറയാതെ, പൂർണ്ണമായും യോജിക്കാൻ "I couldn\'t agree more", "Exactly" എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 41! Today we learn how to agree with conviction and build immediate consensus.',
      blueprintTitle: 'THE ACTIVE CONSENSUS FORMULA',
      blueprintExplanationEn: 'Never say "I am agree with you" (Agree is a verb!). Use powerful native agreement phrases: 1) "I couldn\'t agree more" 2) "You hit the nail on the head" 3) "That is spot on" and 4) "I completely concur with that assessment".',
      blueprintExplanationMl: '"I am agree" എന്ന് ഒരിക്കലും പറയരുത് (Agree എന്നത് ക്രിയയാണ്, അതിനാൽ "I agree" എന്ന് പറയുക). സംഭാഷണം കൂടുതൽ മനോഹരമാക്കാൻ "I couldn\'t agree more" (എനിക്ക് ഇതിൽ കൂടുതൽ യോജിക്കാൻ കഴിയില്ല = 100% യോജിക്കുന്നു), "That\'s spot on" എന്ന് പറയുക.',
      blueprintRules: [
        {'subject': 'Strong Agreement', 'en': 'I couldn\'t agree more; prioritizing client security must be our top objective.', 'ml': 'ഞാൻ പൂർണ്ണമായും യോജിക്കുന്നു; ഉപഭോക്താക്കളുടെ സുരക്ഷയ്ക്കാണ് പ്രഥമ പരിഗണന നൽകേണ്ടത്.'},
        {'subject': 'Precision Validation', 'en': 'You hit the nail on the head; database latency is indeed our primary bottleneck.', 'ml': 'നിങ്ങൾ പറഞ്ഞത് കൃത്യമാണ്; ഡാറ്റാബേസ് വേഗതക്കുറവ് തന്നെയാണ് നമ്മുടെ പ്രധാന പ്രശ്നം.'},
        {'subject': 'Correct Grammar (No "am")', 'en': 'I completely agree with your proposal to restructure the sprint cycles.', 'ml': 'സ്പ്രിന്റ് രീതി മാറ്റാനുള്ള നിങ്ങളുടെ നിർദ്ദേശത്തോട് ഞാൻ പൂർണ്ണമായി യോജിക്കുന്നു.'},
      ],
      drills: [
        {'en': 'I couldn\'t agree more with your strategy to simplify the user checkout experience.', 'ml': 'ചെക്കൗട്ട് രീതി ലളിതമാക്കാനുള്ള നിങ്ങളുടെ തന്ത്രത്തോട് ഞാൻ പൂർണ്ണമായി യോജിക്കുന്നു.', 'rule': 'Deep Agreement: I couldn\'t agree more with'},
        {'en': 'That is spot on; clear communication always prevents expensive production misunderstandings.', 'ml': 'അത് വളരെ കൃത്യമാണ്; വ്യക്തമായ ആശയവിനിമയം തെറ്റിദ്ധാരണകളെ ഒഴിവാക്കും.', 'rule': 'Validation: That is spot on'},
        {'en': 'I share your sentiment regarding the importance of regular code refactoring.', 'ml': 'കോഡ് കൃത്യമായി വൃത്തിയാക്കി സൂക്ഷിക്കേണ്ടതിന്റെ പ്രാധാന്യത്തെക്കുറിച്ചുള്ള നിങ്ങളുടെ നിലപാട് തന്നെയാണ് എനിക്കും ഉള്ളത്.', 'rule': 'Rapport Building: I share your sentiment'},
        {'en': 'You make a very compelling argument, and our experimental test metrics support it.', 'ml': 'നിങ്ങൾ വളരെ ശക്തമായ കാര്യമാണ് പറഞ്ഞത്, നമ്മുടെ ടെസ്റ്റ് ഫലങ്ങളും അത് ശരിവെക്കുന്നു.', 'rule': 'Evidentiary Agreement: compelling argument'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Correctly stating that you agree with your colleague\'s assessment:',
          'qMl': 'ചോദ്യം 1: സഹപ്രവർത്തകന്റെ വിലയിരുത്തലോട് യോജിക്കുന്നു എന്ന് വ്യാകരണ തെറ്റില്ലാതെ പറയാൻ:',
          'audio': 'Question 1: Is it I agree with your assessment, or I am agree with your assessment?',
          'correct': 'I agree with your assessment.',
          'wrong': 'I am agree with your assessment.',
          'tip': 'Agree is already an active verb; never say "I am agree"!',
        },
        {
          'qEn': 'Question 2: Enthusiastically affirming that someone\'s observation is 100% accurate:',
          'qMl': 'ചോദ്യം 2: ഒരാൾ പറഞ്ഞത് അക്ഷരംപ്രതി ശരിയാണെന്ന് സമ്മതിക്കാൻ:',
          'audio': 'Question 2: Is it You hit the nail on the head, or You hit the nail in the head?',
          'correct': 'You hit the nail on the head!',
          'wrong': 'You hit the nail in the head!',
          'tip': 'The exact idiomatic expression is "hit the nail on the head"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 42: Disagreeing Politely & Professionally
    // -------------------------------------------------------------------------
    42: const DayCurriculumSpec(
      day: 42,
      topicEmoji: '🚗',
      titleEn: 'Day 42: Disagreeing Politely & Professionally (I see your point; however...)',
      titleMl: 'ഡേ 42: മാന്യമായും സൗമ്യമായും വിയോജിപ്പ് പ്രകടിപ്പിക്കാൻ Polite Disagreement',
      greetingEn: 'Welcome to Day 42! 🌟 Today we master the high-stakes art of diplomatic disagreement ("I see your point; however...", "With all due respect...") without creating conflict!',
      greetingMl: 'ഡേ 42 ലേക്ക് സ്വാഗതം! 🌟 മറ്റൊരാളോട് തർക്കിക്കാതെ, ആരെയും വേദനിപ്പിക്കാതെ പക്വമായി വിയോജിപ്പ് രേഖപ്പെടുത്താൻ "I see your point, but...", "With respect..." എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 42! Today we learn how to disagree politely and professionally.',
      blueprintTitle: 'THE DIPLOMATIC DISSENT FORMULA',
      blueprintExplanationEn: 'Never blurt out "You are wrong!" or "No!". Acknowledge their perspective first ("I see what you mean / That is an interesting idea"), then introduce your counterpoint with a transition ("however, from a cost and scalability perspective...").',
      blueprintExplanationMl: '"You are wrong" എന്ന് ആരോടും ഒരിക്കലും പറയരുത്. ആദ്യം അവർ പറഞ്ഞതിനെ ബഹുമാനിക്കുക ("I see your point"), തുടർന്ന് "however" അല്ലെങ്കിൽ "on the other hand" എന്ന് പറഞ്ഞ് നിങ്ങളുടെ കാഴ്ച്ചപ്പാട് അവതരിപ്പിക്കുക.',
      blueprintRules: [
        {'subject': 'Perspective Acknowledgment + Pivot', 'en': 'I see your point; however, rushing this release could compromise platform stability.', 'ml': 'നിങ്ങൾ പറഞ്ഞത് മനസ്സിലായി; എങ്കിലും, ധൃതിപിടിച്ച് റിലീസ് ചെയ്യുന്നത് സിസ്റ്റത്തിന്റെ സ്ഥിരതയെ ബാധിച്ചേക്കാം.'},
        {'subject': 'Polite Softening', 'en': 'I am not entirely sure that migrating everything to a new framework is wise right now.', 'ml': 'എല്ലാം പുതിയ ഫ്രെയിംവർക്കിലേക്ക് മാറ്റുന്നത് ഇപ്പോൾ ഉചിതമാണോ എന്ന് എനിക്ക് പൂർണ്ണ ഉറപ്പില്ല.'},
        {'subject': 'Respectful Counter-Stance', 'en': 'With all due respect, our historical metrics tell a significantly different story.', 'ml': 'എല്ലാ ബഹുമാനത്തോടും കൂടി പറയട്ടെ, നമ്മുടെ പഴയ കണക്കുകൾ കാണിക്കുന്നത് മറ്റൊന്നാണ്.'},
      ],
      drills: [
        {'en': 'I understand your rationale; however, we might run into severe scalability roadblocks later.', 'ml': 'നിങ്ങളുടെ കാരണം എനിക്ക് മനസ്സിലായി; എങ്കിലും പിന്നീട് നമുക്ക് വലിയ വെല്ലുവിളികൾ ഉണ്ടായേക്കാം.', 'rule': 'Diplomatic Contrast: I understand... however'},
        {'en': 'That is a fair observation; nonetheless, our budget does not accommodate custom bespoke hardware.', 'ml': 'അതൊരു നല്ല നിരീക്ഷണമാണ്; എന്നിരുന്നാലും നമ്മുടെ ബഡ്ജറ്റിൽ പുതിയ ഹാർഡ്‌വെയർ ഉൾക്കൊള്ളാൻ കഴിയില്ല.', 'rule': 'Measured Rebuttal: nonetheless'},
        {'en': 'With respect, I look at the problem from an operational maintainability angle.', 'ml': 'ബഹുമാനത്തോടെ പറയട്ടെ, ഞാൻ ഈ പ്രശ്നത്തെ പരിപാലന സൗകര്യത്തിന്റെ വീക്ഷണത്തിലാണ് കാണുന്നത്.', 'rule': 'Executive Disagreement: With respect, I look at...'},
        {'en': 'I see what you are trying to achieve, but there might be a less risky approach available.', 'ml': 'നിങ്ങൾ ഉദ്ദേശിച്ച ലക്ഷ്യം മനസ്സിലായി, പക്ഷെ കുറച്ചുകൂടി അപകടസാധ്യത കുറഞ്ഞ വഴി ഉണ്ടായേക്കാം.', 'rule': 'Collaborative Dissent: less risky approach'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Diplomatically objecting to a proposed deadline during a team review:',
          'qMl': 'ചോദ്യം 1: പ്രൊപ്പോസ് ചെയ്ത ഡെഡ്‌ലൈൻ വളരെ ഇടുങ്ങിയതാണെന്ന് മാന്യമായി പറയാൻ:',
          'audio': 'Question 1: Is it I see your point; however, this deadline may be overly tight, or You are totally wrong about the deadline?',
          'correct': 'I see your point; however, this deadline may be overly tight.',
          'wrong': 'You are totally wrong about the deadline!',
          'tip': 'Acknowledge first ("I see your point"), then introduce the caveat with "however"!',
        },
        {
          'qEn': 'Question 2: Expressing disagreement with an approach without sounding confrontational:',
          'qMl': 'ചോദ്യം 2: ഒരു രീതിയോട് ശാന്തമായി വിയോജിപ്പ് അറിയിക്കാൻ:',
          'audio': 'Question 2: Is it With respect, I view this issue differently, or I am not agree with anything you said?',
          'correct': 'With respect, I view this issue differently.',
          'wrong': 'I am not agree with anything you said!',
          'tip': 'Use "With respect, I view this differently" instead of aggressive non-standard phrasing!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 43: Articulating Reasons & Justifications (Because, Since, As, Due to)
    // -------------------------------------------------------------------------
    43: const DayCurriculumSpec(
      day: 43,
      topicEmoji: '🏰',
      titleEn: 'Day 43: Articulating Reasons & Justifications (Because, Since, As, Due to)',
      titleMl: 'ഡേ 43: കാരണങ്ങളും ന്യായീകരണങ്ങളും വ്യക്തമായി ബോധ്യപ്പെടുത്താൻ Connectors',
      greetingEn: 'Welcome to Day 43! 🌟 Today we master causal connectors (Because, Since, As, Due to, Owing to) to explain the strategic rationale behind your decisions!',
      greetingMl: 'ഡേ 43 ലേക്ക് സ്വാഗതം! 🌟 നിങ്ങൾ എടുത്ത തീരുമാനങ്ങൾക്ക് പിന്നിലെ കാരണങ്ങൾ കൃത്യമായി സമർത്ഥിക്കാൻ Because, Since, As, Due to എന്നിവ ഉപയോഗിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 43! Today we master because, since, as, and due to for logical justifications.',
      blueprintTitle: 'THE CAUSAL LOGIC FORMULA',
      blueprintExplanationEn: 'Distinguish between clauses and noun phrases: Use "Because / Since / As + Subject + Verb" ("Since our team was small..."). Use "Because of / Due to + Noun Phrase" ("Due to unexpected weather delays..."). Never say "Due to he was absent"!',
      blueprintExplanationMl: '"Because / Since / As" എന്നിവയ്ക്ക് ശേഷം പൂർണ്ണമായ വാക്യം വരണം ("Because the server was slow"). എന്നാൽ "Due to / Because of" എന്നിവയ്ക്ക് ശേഷം നാമം (Noun) മാത്രമേ വരാവൂ ("Due to server latency").',
      blueprintRules: [
        {'subject': 'Clause Justification (Since/As)', 'en': 'Since our existing database reached capacity, we decided to horizontally partition the tables.', 'ml': 'നിലവിലെ ഡാറ്റാബേസ് കവിഞ്ഞതിനാൽ, ഞങ്ങൾ ടേബിളുകൾ വിഭജിക്കാൻ തീരുമാനിച്ചു.'},
        {'subject': 'Noun Phrase Cause (Due to)', 'en': 'Due to unprecedented market volatility, the company postponed its public stock listing.', 'ml': 'വിപണിയിലെ അപ്രതീക്ഷിത ചാഞ്ചാട്ടം കാരണം കമ്പനി ഐപിഒ നീട്ടിവെച്ചു.'},
        {'subject': 'Direct Explanation (The reason is that...)', 'en': 'The reason we chose Flutter is that it delivers native cross-platform performance.', 'ml': 'ഞങ്ങൾ ഫ്ലട്ടർ തിരഞ്ഞെടുത്തതിന് കാരണം അത് മികച്ച പെർഫോമൻസ് നൽകുന്നു എന്നതാണ്.'},
      ],
      drills: [
        {'en': 'Since we had strict deadline constraints, we focused entirely on core minimum features.', 'ml': 'സമയപരിമിതി ഉണ്ടായിരുന്നതിനാൽ ഞങ്ങൾ പ്രധാനപ്പെട്ട ഫീച്ചറുകളിൽ മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിച്ചു.', 'rule': 'Reason Clause: Since we had constraints'},
        {'en': 'Due to unforeseen network infrastructure outages, our automated deployments were held back.', 'ml': 'അപ്രതീക്ഷിത നെറ്റ്‌വർക്ക് തകരാറുകൾ കാരണം ഓട്ടോമേറ്റഡ് റിലീസുകൾ തടസ്സപ്പെട്ടു.', 'rule': 'Noun Phrase Cause: Due to unforeseen outages'},
        {'en': 'As several senior developers were mentoring interns, our sprint progress slowed down slightly.', 'ml': 'സീനിയർ എഞ്ചിനീയർമാർ ഇന്റേണുകളെ പഠിപ്പിക്കുകയായിരുന്നതിനാൽ സ്പ്രിന്റ് വേഗത അല്പം കുറഞ്ഞു.', 'rule': 'Known Context: As several developers were mentoring'},
        {'en': 'Owing to sustained user feedback, we redesigned the mobile navigation hierarchy from scratch.', 'ml': 'ഉപയോക്താക്കളുടെ തുടർച്ചയായ നിർദ്ദേശങ്ങൾ മാനിച്ച് ഞങ്ങൾ ആപ്പിന്റെ നാവിഗേഷൻ അടിമുടി പുതുക്കി.', 'rule': 'Formal Attribution: Owing to sustained user feedback'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Explaining that the flight was cancelled because of severe weather:',
          'qMl': 'ചോദ്യം 1: മോശം കാലാവസ്ഥ കാരണം ഫ്ലൈറ്റ് റദ്ദാക്കി എന്ന് "Due to" ഉപയോഗിച്ച് പറയാൻ:',
          'audio': 'Question 1: Is it Due to severe weather the flight was cancelled, or Due to it was bad weather the flight was cancelled?',
          'correct': 'Due to severe weather, the flight was cancelled.',
          'wrong': 'Due to it was bad weather, the flight was cancelled.',
          'tip': '"Due to" must be followed by a noun phrase ("severe weather"), not a full clause with "it was"!',
        },
        {
          'qEn': 'Question 2: The reason why your team selected cloud storage:',
          'qMl': 'ചോദ്യം 2: ക്ലൗഡ് സ്റ്റോറേജ് തിരഞ്ഞെടുക്കാനുള്ള കാരണം വിശദീകരിക്കാൻ:',
          'audio': 'Question 2: Is it The reason is that it provides automated backups, or The reason why is because it provides automated backups?',
          'correct': 'The reason is that it provides automated backups.',
          'wrong': 'The reason why is because it provides automated backups.',
          'tip': 'Avoid the clumsy repetition "The reason why is because"; use "The reason is that..."!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 44: Explaining How Things Work (The core reason is... In order to...)
    // -------------------------------------------------------------------------
    44: const DayCurriculumSpec(
      day: 44,
      topicEmoji: '🛸',
      titleEn: 'Day 44: Explaining How Things Work (The core reason is... In order to...)',
      titleMl: 'ഡേ 44: കാര്യങ്ങളുടെ പ്രവർത്തനരീതി ലളിതമായി വിശദീകരിക്കാൻ Step-by-Step Exposition',
      greetingEn: 'Welcome to Day 44! 🌟 Today we master the art of crystal-clear technical exposition ("What this means is...", "In order to...", "Namely") to explain complex systems simply!',
      greetingMl: 'ഡേ 44 ലേക്ക് സ്വാഗതം! 🌟 സങ്കീർണ്ണമായ സാങ്കേതിക കാര്യങ്ങളും സിസ്റ്റങ്ങളും ആർക്കും എളുപ്പത്തിൽ മനസ്സിലാകുന്ന രീതിയിൽ വിശദീകരിക്കാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 44! Today we learn how to explain how things work clearly and concisely.',
      blueprintTitle: 'THE STEP-BY-STEP EXPOSITION BLUEPRINT',
      blueprintExplanationEn: 'Senior communicators don\'t hide behind dense jargon. They clarify using: 1) "In order to achieve this, we..." 2) "What this essentially means is that..." 3) "Think of it as..." and 4) "The mechanism works by...".',
      blueprintExplanationMl: 'കഠിനമായ വാക്കുകൾ ഒഴിവാക്കി മറ്റൊരാൾക്ക് കാര്യം മനസ്സിലാക്കി കൊടുക്കാൻ ഈ ലിങ്കറുകൾ ഉപയോഗിക്കുക: "In order to..." (ഇത് സാധ്യമാക്കുന്നതിനായി), "What this essentially means is..." (ലളിതമായി പറഞ്ഞാൽ ഇതിനർത്ഥം...).',
      blueprintRules: [
        {'subject': 'Purpose Specification (In order to)', 'en': 'In order to ensure zero downtime, our system replicates data across three cloud zones.', 'ml': 'തടസ്സമില്ലാത്ത പ്രവർത്തനം ഉറപ്പാക്കാൻ ഞങ്ങളുടെ സിസ്റ്റം മൂന്ന് ക്ലൗഡ് സോണുകളിലായി ഡാറ്റ സൂക്ഷിക്കുന്നു.'},
        {'subject': 'Demystifying Principle', 'en': 'What this essentially means is that users can continue working even while offline.', 'ml': 'ലളിതമായി പറഞ്ഞാൽ, ഇന്റർനെറ്റ് ഇല്ലെങ്കിലും ഉപയോക്താക്കൾക്ക് തുടർന്നും ജോലി ചെയ്യാം എന്നാണ് ഇതിനർത്ഥം.'},
        {'subject': 'Step Sequence', 'en': 'First the client submits the form, whereupon the background worker validates every parameter.', 'ml': 'ആദ്യം ഉപയോക്താവ് ഫോം സബ്മിറ്റ് ചെയ്യുന്നു, ഉടൻ തന്നെ ബാക്ക്ഗ്രൗണ്ട് വർക്കർ വിവരങ്ങൾ പരിശോധിക്കുന്നു.'},
      ],
      drills: [
        {'en': 'In order to prevent data corruption, every transaction is locked until verification completes.', 'ml': 'ഡാറ്റ നഷ്ടപ്പെടാതിരിക്കാൻ, പരിശോധന പൂർത്തിയാകുന്നതുവരെ ഓരോ ട്രാൻസാക്ഷനും ലോക്ക് ചെയ്യപ്പെടുന്നു.', 'rule': 'Purpose Formulation: In order to prevent'},
        {'en': 'What this architectural approach essentially achieves is a complete separation of concerns.', 'ml': 'ഈ ഡിസൈൻ രീതി വഴി ഓരോ ഘടകങ്ങളും സ്വതന്ത്രമായി പ്രവർത്തിക്കാൻ സാധിക്കുന്നു.', 'rule': 'Exposition Framing: What this essentially achieves is'},
        {'en': 'The mechanism functions by continuously monitoring incoming traffic for unusual request spikes.', 'ml': 'അസാധാരണമായ ട്രാഫിക് വർദ്ധനവുണ്ടോ എന്ന് തുടർച്ചയായി നിരീക്ഷിച്ചുകൊണ്ടാണ് ഈ സിസ്റ്റം പ്രവർത്തിക്കുന്നത്.', 'rule': 'Function Mechanism: functions by continuously monitoring'},
        {'en': 'To put it another way, the cache serves as an immediate buffer for repetitive database queries.', 'ml': 'മറ്റൊരു രീതിയിൽ പറഞ്ഞാൽ, ആവർത്തിച്ചുള്ള അന്വേഷണങ്ങൾക്ക് ഒരു താൽക്കാലിക തടയായി കാഷെ പ്രവർത്തിക്കുന്നു.', 'rule': 'Analogy & Simplification: To put it another way'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Stating the objective of compressing files before upload:',
          'qMl': 'ചോദ്യം 1: അപ്‌ലോഡ് ചെയ്യുന്നതിന് മുമ്പ് ഫയൽ കംപ്രസ്സ് ചെയ്യുന്നതിന്റെ ലക്ഷ്യം വ്യക്തമാക്കാൻ:',
          'audio': 'Question 1: Is it In order to reduce upload bandwidth, or For in order reduce upload bandwidth?',
          'correct': 'In order to reduce upload bandwidth.',
          'wrong': 'For in order reduce upload bandwidth.',
          'tip': 'Use "In order to + base verb" directly without adding redundant prepositions like "For"!',
        },
        {
          'qEn': 'Question 2: Simplifying a complex technical concept for a client:',
          'qMl': 'ചോദ്യം 2: സങ്കീർണ്ണമായ ഒരു കാര്യം ലളിതമായി ക്ലയന്റിന് പറഞ്ഞു കൊടുക്കാൻ:',
          'audio': 'Question 2: Is it What this essentially means is that your data remains safe, or What this means is because your data is safe?',
          'correct': 'What this essentially means is that your data remains safe.',
          'wrong': 'What this means is because your data is safe.',
          'tip': 'The standard bridging formula is "What this essentially means is that..."!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 45: Describing People (Personality & Character Compound Adjectives)
    // -------------------------------------------------------------------------
    45: const DayCurriculumSpec(
      day: 45,
      topicEmoji: '🏪',
      titleEn: 'Day 45: Describing People (Personality & Character Compound Adjectives)',
      titleMl: 'ഡേ 45: വ്യക്തികളുടെ സ്വഭാവഗുണങ്ങളും മിടുക്കും വർണ്ണിക്കാൻ Compound Adjectives',
      greetingEn: 'Welcome to Day 45! 🌟 Today we master compound character adjectives (detail-oriented, level-headed, open-minded, trustworthy) to describe colleagues and leaders with precision!',
      greetingMl: 'ഡേ 45 ലേക്ക് സ്വാഗതം! 🌟 വ്യക്തികളുടെ പ്രൊഫഷണൽ സ്വഭാവഗുണങ്ങളും മിടുക്കും വ്യക്തമായി വർണ്ണിക്കാൻ compound adjectives (hardworking, level-headed, detail-oriented) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 45! Today we master compound adjectives to describe personality and character.',
      blueprintTitle: 'THE CHARACTER & PERSONALITY BLUEPRINT',
      blueprintExplanationEn: 'Move beyond basic words like "good" or "nice". Use compound hyphenated adjectives: 1) "detail-oriented" (noticing every small thing) 2) "level-headed" (calm under pressure) 3) "results-driven" (focused on outcomes) and 4) "open-minded" (welcoming new ideas). Note: "hard" is the adverb ("He works hard", NOT "hardly")!',
      blueprintExplanationMl: 'വ്യക്തികളെക്കുറിച്ച് പറയുമ്പോൾ വെറുതെ "He is good" എന്ന് പറയാതെ, അവരുടെ കൃത്യതയെയും ശാന്തതയെയും സൂചിപ്പിക്കുന്ന വാക്കുകൾ ഉപയോഗിക്കുക: detail-oriented (സൂക്ഷ്മതയുള്ളവൻ), level-headed (സമ്മർദ്ദത്തിലും ശാന്തനായവൻ). "He works hard" എന്ന് പറയുക ("hardly" എന്ന് പറയരുത്).',
      blueprintRules: [
        {'subject': 'Professional Character', 'en': 'She is an exceptionally detail-oriented software architect who never overlooks edge cases.', 'ml': 'അവൾ ചെറിയ കാര്യങ്ങൾ പോലും വിട്ടുകളയാത്ത അതീവ സൂക്ഷ്മതയുള്ള ഒരു സോഫ്റ്റ്‌വെയർ ആർക്കിടെക്റ്റാണ്.'},
        {'subject': 'Composure Under Pressure', 'en': 'Our engineering lead remains remarkably level-headed even during critical system outages.', 'ml': 'സിസ്റ്റം പൂർണ്ണമായി നിലച്ചാൽ പോലും ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ലീഡ് തികച്ചും ശാന്തനായി കാര്യങ്ങൾ കൈകാര്യം ചെയ്യുന്നു.'},
        {'subject': 'Collaborative Trait', 'en': 'He is an approachable, open-minded mentor who genuinely encourages questions from junior staff.', 'ml': 'ജൂനിയർ ജീവനക്കാരെ ചോദ്യങ്ങൾ ചോദിക്കാൻ പ്രോത്സാഹിപ്പിക്കുന്ന സൗഹാർദ്ദപരമായ മനസ്സുള്ള ആളാണ് അദ്ദേഹം.'},
      ],
      drills: [
        {'en': 'Priya is a results-driven project manager who consistently brings complex initiatives to completion.', 'ml': 'പ്രിയ ലക്ഷ്യബോധമുള്ള ഒരു പ്രോജക്റ്റ് മാനേജരാണ്, ഏത് സങ്കീർണ്ണമായ ജോലിയും സമയത്ത് പൂർത്തിയാക്കാൻ അവൾക്ക് കഴിയും.', 'rule': 'Compound Trait: results-driven'},
        {'en': 'Rahul works exceptionally hard and maintains an inspiring work ethic throughout the sprint.', 'ml': 'രാഹുൽ അത്യധികം കഠിനാധ്വാനം ചെയ്യുകയും സ്പ്രിന്റിലുടനീളം മാതൃകാപരമായ അച്ചടക്കം പുലർത്തുകയും ചെയ്യുന്നു.', 'rule': 'Adverb Usage: works hard (not hardly)'},
        {'en': 'She is known for being remarkably calm and quick-witted when presenting to demanding corporate clients.', 'ml': 'വലിയ കോർപ്പറേറ്റ് ക്ലയന്റുകൾക്ക് മുന്നിൽ സംസാരിക്കുമ്പോൾ സമചിത്തതയും ബുദ്ധിസാമർത്ഥ്യവും പ്രകടിപ്പിക്കുന്നതിൽ അവൾ പ്രശസ്തയാണ്.', 'rule': 'Character Duo: calm and quick-witted'},
        {'en': 'Our entire team values his trustworthy demeanor and transparent problem-solving methodology.', 'ml': 'അദ്ദേഹത്തിന്റെ വിശ്വസ്തമായ സ്വഭാവത്തെയും സുതാര്യമായ രീതികളെയും ടീം മുഴുവൻ ബഹുമാനിക്കുന്നു.', 'rule': 'Integrity Marker: trustworthy demeanor'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing a colleague who works with extreme diligence:',
          'qMl': 'ചോദ്യം 1: സഹപ്രവർത്തകൻ വളരെ കഠിനാധ്വാനം ചെയ്യുന്നു എന്ന് ശരിയായി പറയാൻ:',
          'audio': 'Question 1: Is it He works very hard every day, or He works very hardly every day?',
          'correct': 'He works very hard every day.',
          'wrong': 'He works very hardly every day.',
          'tip': '"Hardly" means almost not! Use "works hard" for diligence!',
        },
        {
          'qEn': 'Question 2: Praising an engineer who pays immense attention to every tiny detail:',
          'qMl': 'ചോദ്യം 2: ചെറിയ കാര്യങ്ങൾ പോലും അതീവ സൂക്ഷ്മതയോടെ ചെയ്യുന്ന ആളാണെന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it She is a detail-oriented professional, or She is a detail-mindful professional?',
          'correct': 'She is a detail-oriented professional.',
          'wrong': 'She is a detail-mindful professional.',
          'tip': 'The standard recognized corporate compound adjective is "detail-oriented"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 46: Describing Environments & Places Vividly
    // -------------------------------------------------------------------------
    46: const DayCurriculumSpec(
      day: 46,
      topicEmoji: '🚂',
      titleEn: 'Day 46: Describing Environments & Places Vividly (Atmosphere & Sensory Adjectives)',
      titleMl: 'ഡേ 46: സ്ഥലങ്ങളെയും അന്തരീക്ഷത്തെയും ഭംഗിയായി വർണ്ണിക്കാൻ Sensory Adjectives',
      greetingEn: 'Welcome to Day 46! 🌟 Today we master sensory, atmospheric adjectives (bustling, serene, state-of-the-art, picturesque) to bring places and workplaces to life!',
      greetingMl: 'ഡേ 46 ലേക്ക് സ്വാഗതം! 🌟 ഓഫീസുകളെയും നാട്ടിൻപുറങ്ങളെയും അവയുടെ തനതായ അന്തരീക്ഷം അനുഭവപ്പെടുന്ന രീതിയിൽ വർണ്ണിക്കാൻ sensory adjectives ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 46! Today we learn how to describe environments vividly using sensory adjectives.',
      blueprintTitle: 'THE VIVID ENVIRONMENT BLUEPRINT',
      blueprintExplanationEn: 'Transport your listener using sensory atmosphere words: 1) "bustling" (energetic, crowded) 2) "serene" (peaceful, tranquil) 3) "state-of-the-art" (cutting-edge, ultra-modern) 4) "picturesque" (visually scenic). Never say "My city is very crowd place"; say "My city is a bustling metropolis"!',
      blueprintExplanationMl: '"It is a crowd place" എന്ന് പറയരുത്. പകരം "It is a bustling city" (തിരക്കേറിയ നഗരം), "It is a serene countryside" (ശാന്തസുന്ദരമായ ഗ്രാമം), "a state-of-the-art facility" (അത്യാധുനിക സൗകര്യങ്ങളുള്ള സ്ഥലം) എന്ന് വിശേഷിപ്പിക്കുക.',
      blueprintRules: [
        {'subject': 'Dynamic Urban Energy', 'en': 'Bengaluru is a bustling technological hub where historic avenues blend with modern tech parks.', 'ml': 'പഴയ തെരുവുകളും പുതിയ ടെക് പാർക്കുകളും ഇടകലർന്ന തിരക്കുപിടിച്ച സാങ്കേതിക കേന്ദ്രമാണ് ബംഗളൂരു.'},
        {'subject': 'Tranquil Natural Setting', 'en': 'Munnar boasts serene, mist-covered hills and expansive emerald tea plantations.', 'ml': 'മൂന്നാർ ശാന്തവും കോടമഞ്ഞ് മൂടിയതുമായ മലനിരകളും പച്ചപ്പാർന്ന തേയിലത്തോട്ടങ്ങളും കൊണ്ട് അനുഗൃഹീതമാണ്.'},
        {'subject': 'Modern Workplace Environment', 'en': 'Our design studio is a sunlit, state-of-the-art workspace that encourages spontaneous collaboration.', 'ml': 'ഞങ്ങളുടെ ഡിസൈൻ സ്റ്റുഡിയോ വെളിച്ചം നിറഞ്ഞതും കൂട്ടായ ചർച്ചകളെ പ്രോത്സാഹിപ്പിക്കുന്നതുമായ അത്യാധുനിക ഇടമാണ്.'},
      ],
      drills: [
        {'en': 'The central train station was a bustling hive of commuters rushing in every direction.', 'ml': 'റെയിൽവേ സ്റ്റേഷൻ എല്ലാ ഭാഗത്തേക്കും പായുന്ന യാത്രക്കാരുടെ തിരക്കുകൊണ്ട് സജീവമായിരുന്നു.', 'rule': 'Sensory Energy: bustling hive of commuters'},
        {'en': 'Our engineers work in a serene, noise-insulated library room ideal for deep coding sessions.', 'ml': 'ഞങ്ങളുടെ എഞ്ചിനീയർമാർ ഏകാഗ്രതയോടെ കോഡ് ചെയ്യാൻ അനുയോജ്യമായ ശബ്ദരഹിതമായ ശാന്തമായ മുറിയിൽ ജോലി ചെയ്യുന്നു.', 'rule': 'Tranquility: serene, noise-insulated'},
        {'en': 'The international headquarters features state-of-the-art laboratories and ergonomic meeting pods.', 'ml': 'അന്താരാഷ്ട്ര ആസ്ഥാനത്ത് അത്യാധുനിക ലബോറട്ടറികളും സുഖകരമായ മീറ്റിംഗ് മുറികളും ഉണ്ട്.', 'rule': 'Modernity: state-of-the-art laboratories'},
        {'en': 'We hiked along a picturesque coastal trail overlooking turquoise ocean waves crashing below.', 'ml': 'താഴെ ആഞ്ഞടിക്കുന്ന നീലക്കടൽത്തിരമാലകൾ കണ്ടുകൊണ്ട് ഞങ്ങൾ മനോഹരമായ തീരദേശ പാതയിലൂടെ നടന്നു.', 'rule': 'Scenic Imagery: picturesque coastal trail'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Describing an energetic, crowded city center correctly:',
          'qMl': 'ചോദ്യം 1: നല്ല തിരക്കും ജീവസ്സുമുള്ള നഗര കേന്ദ്രത്തെക്കുറിച്ച് പറയാൻ:',
          'audio': 'Question 1: Is it The downtown market is a bustling commercial center, or The downtown market is a very crowd commercial center?',
          'correct': 'The downtown market is a bustling commercial center.',
          'wrong': 'The downtown market is a very crowd commercial center.',
          'tip': 'Use the vivid sensory adjective "bustling" instead of "very crowd"!',
        },
        {
          'qEn': 'Question 2: Describing an ultra-modern corporate research facility:',
          'qMl': 'ചോദ്യം 2: അത്യാധുനിക സൗകര്യങ്ങളുള്ള ഓഫീസ് ലാബിനെക്കുറിച്ച് പറയാൻ:',
          'audio': 'Question 2: Is it They built a state-of-the-art research facility, or They built a very highest art research facility?',
          'correct': 'They built a state-of-the-art research facility.',
          'wrong': 'They built a very highest art research facility.',
          'tip': 'The established professional phrase for cutting-edge environments is "state-of-the-art"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 47: Narrating Unforgettable Experiences (Narrative Hooks & Suspense)
    // -------------------------------------------------------------------------
    47: const DayCurriculumSpec(
      day: 47,
      topicEmoji: '🕵️',
      titleEn: 'Day 47: Narrating Unforgettable Experiences (Narrative Hooks & Suspense)',
      titleMl: 'ഡേ 47: അവിസ്മരണീയമായ അനുഭവങ്ങൾ ആകാംഷയോടെ വിവരിക്കാൻ Narrative Hooks',
      greetingEn: 'Welcome to Day 47! 🌟 Today we master story openers and dramatic narrative hooks ("It all started when...", "Little did I know...", "To my surprise...") to captivate any audience!',
      greetingMl: 'ഡേ 47 ലേക്ക് സ്വാഗതം! 🌟 ജീവിതത്തിലെ മറക്കാനാവാത്ത സംഭവങ്ങളും അനുഭവങ്ങളും കേൾവിക്കാരിൽ കൗതുകമുണർത്തുന്ന രീതിയിൽ പറയാൻ Narrative Hooks ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 47! Today we master dramatic narrative hooks to tell unforgettable stories.',
      blueprintTitle: 'THE DRAMATIC NARRATIVE HOOK FORMULA',
      blueprintExplanationEn: 'Never ruin a good story by blurting out the punchline immediately. Hook your listener with curiosity: 1) "It was supposed to be a normal Tuesday morning, but..." 2) "Little did I know that..." 3) "To my utter astonishment..." and 4) "All of a sudden...".',
      blueprintExplanationMl: 'കഥയുടെ അവസാനം തുടക്കത്തിലേ വിളിച്ചു പറയാതെ, ആകാംഷ നിലനിർത്തി സംസാരിക്കുക: "Little did I know..." (ഞാൻ അറിഞ്ഞതേയില്ല...), "To my surprise..." (എന്നെ അത്ഭുതപ്പെടുത്തിക്കൊണ്ട്...), "It all began when..." (ഇതെല്ലാം തുടങ്ങിയത്...).',
      blueprintRules: [
        {'subject': 'Curiosity Opener', 'en': 'It all started when our flight made an unscheduled emergency landing in Oman.', 'ml': 'ഞങ്ങളുടെ വിമാനം ഒമാനിൽ അപ്രതീക്ഷിതമായി ഇറക്കേണ്ടി വന്നതോടെയാണ് ഇതെല്ലാം തുടങ്ങിയത്.'},
        {'subject': 'Suspense Hook (Little did I know)', 'en': 'Little did I know that this spontaneous hackathon would launch my entire tech career.', 'ml': 'ഈ ചെറിയ ഹാക്കത്തോൺ എന്റെ കരിയറിനെത്തന്നെ മാറ്റിമറിക്കുമെന്ന് അന്ന് ഞാൻ അറിഞ്ഞിരുന്നില്ല.'},
        {'subject': 'Plot Twist Marker', 'en': 'To our complete surprise, the keynote speaker invited our small team onto the main stage.', 'ml': 'ഞങ്ങളെ പൂർണ്ണമായി അത്ഭുതപ്പെടുത്തിക്കൊണ്ട് മുഖ്യ പ്രഭാഷകൻ ഞങ്ങളുടെ ടീമിനെ വേദിയിലേക്ക് ക്ഷണിച്ചു.'},
      ],
      drills: [
        {'en': 'It was supposed to be a routine software update, but everything changed at midnight.', 'ml': 'ഒരു സാധാരണ അപ്ഡേറ്റ് ആയിരിക്കേണ്ടതായിരുന്നു അത്, എന്നാൽ അർദ്ധരാത്രിയോടെ എല്ലാം മാറിമറിഞ്ഞു.', 'rule': 'Narrative Hook: It was supposed to be... but'},
        {'en': 'Little did I know that moving to a new city would teach me true resilience.', 'ml': 'ഒരു പുതിയ നഗരത്തിലേക്ക് താമസം മാറുന്നത് എന്നെ ജീവിതത്തിലെ പക്വത പഠിപ്പിക്കുമെന്ന് ഞാൻ കരുതിയിരുന്നില്ല.', 'rule': 'Suspense Inversion: Little did I know that'},
        {'en': 'To my astonishment, our open-source project surpassed ten thousand stars within forty-eight hours.', 'ml': 'എന്നെ അത്ഭുതപ്പെടുത്തിക്കൊണ്ട്, ഞങ്ങളുടെ പ്രോജക്റ്റിന് 48 മണിക്കൂറിനുള്ളിൽ പതിനായിരത്തിലധികം സ്റ്റാറുകൾ ലഭിച്ചു.', 'rule': 'Astonishment Marker: To my astonishment'},
        {'en': 'Just when we thought all hope was lost, our backup server miraculously restored the lost database.', 'ml': 'എല്ലാം നഷ്ടപ്പെട്ടു എന്ന് കരുതിയ നിമിഷത്തിലാണ് ഞങ്ങളുടെ ബാക്കപ്പ് സെർവർ അത്ഭുതകരമായി ഡാറ്റ തിരികെ നൽകിയത്.', 'rule': 'Climax Turning Point: Just when we thought'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Hooking an audience with the classic suspense expression:',
          'qMl': 'ചോദ്യം 1: ഭാവിയിൽ നടക്കാനിരിക്കുന്ന വലിയ കാര്യം താൻ അറിഞ്ഞിരുന്നില്ല എന്ന് ആകാംഷയോടെ പറയാൻ:',
          'audio': 'Question 1: Is it Little did I know what was about to happen, or Little did I knew what was about to happen?',
          'correct': 'Little did I know what was about to happen.',
          'wrong': 'Little did I knew what was about to happen.',
          'tip': 'After the auxiliary "did", always use the base verb "know", not "knew"!',
        },
        {
          'qEn': 'Question 2: Introducing an unexpected and delightful plot twist in your story:',
          'qMl': 'ചോദ്യം 2: അപ്രതീക്ഷിതമായി സംഭവിച്ച ഒരു അത്ഭുതത്തെക്കുറിച്ച് പറയാൻ:',
          'audio': 'Question 2: Is it To my surprise, the client approved the entire budget, or For my surprise, the client approved the entire budget?',
          'correct': 'To my surprise, the client approved the entire budget.',
          'wrong': 'For my surprise, the client approved the entire budget.',
          'tip': 'The idiomatic English preposition is "To my surprise", never "For my surprise"!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 48: The 3-Act Storytelling Framework (Setup -> Conflict -> Resolution)
    // -------------------------------------------------------------------------
    48: const DayCurriculumSpec(
      day: 48,
      topicEmoji: '🐍',
      titleEn: 'Day 48: The 3-Act Storytelling Framework (Setup -> Conflict -> Resolution)',
      titleMl: 'ഡേ 48: അനുഭവങ്ങളും പ്രോജക്റ്റുകളും മൂന്ന് ഘട്ടങ്ങളായി പറയാൻ 3-Act Framework',
      greetingEn: 'Welcome to Day 48! 🌟 Today we master the Hollywood 3-Act Framework (Setup, Conflict, Resolution) using executive narrative linkers (Initially, Suddenly, Ultimately)!',
      greetingMl: 'ഡേ 48 ലേക്ക് സ്വാഗതം! 🌟 ഏത് അനുഭവവും അല്ലെങ്കിൽ ഇന്റർവ്യൂ ഉത്തരങ്ങളും 3 ഘട്ടങ്ങളായി (തുടക്കം, നേരിട്ട വെല്ലുവിളി, പരിഹാരം) പറയാൻ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 48! Today we structure stories into three acts: setup, conflict, and resolution.',
      blueprintTitle: 'THE 3-ACT NARRATIVE FORMULA',
      blueprintExplanationEn: 'Every great story follows three acts: Act 1: The Setup ("Initially, our project was running smoothly..."). Act 2: The Conflict ("Suddenly, our payment gateway collapsed..."). Act 3: The Triumph & Lesson ("Ultimately, by refactoring the pipeline, we restored operations").',
      blueprintExplanationMl: 'കഥ പറയുമ്പോൾ 3 ഘട്ടങ്ങൾ പാലിക്കുക: 1. തുടക്കം ("Initially...", തുടക്കത്തിൽ), 2. വെല്ലുവിളി ("Suddenly / However...", പെട്ടെന്ന് പ്രശ്നമുണ്ടായി), 3. പരിഹാരവും വിജയവും ("Ultimately / In the end...", ഒടുവിൽ ഞങ്ങൾ അത് പരിഹരിച്ചു).',
      blueprintRules: [
        {'subject': 'Act 1: Context & Setup', 'en': 'Initially, our startup operated out of a cramped living room with just two laptops.', 'ml': 'തുടക്കത്തിൽ ഞങ്ങളുടെ സ്റ്റാർട്ടപ്പ് രണ്ട് ലാപ്ടോപ്പുകളുമായി ഒരു ചെറിയ മുറിയിലാണ് പ്രവർത്തിച്ചിരുന്നത്.'},
        {'subject': 'Act 2: The Obstacle & Conflict', 'en': 'Suddenly, two days before launch, our primary database experienced severe indexing corruptions.', 'ml': 'ലോഞ്ചിന് രണ്ട് ദിവസം മുമ്പ് പെട്ടെന്ന് നമ്മുടെ പ്രധാന ഡാറ്റാബേസിൽ വലിയ തകരാറുണ്ടായി.'},
        {'subject': 'Act 3: The Triumph & Takeaway', 'en': 'Ultimately, by working through the night and rebuilding the tables, we launched without a hitch.', 'ml': 'ഒടുവിൽ രാത്രി മുഴുവൻ പണിയെടുത്ത് ടേബിളുകൾ പുനർനിർമ്മിച്ച് ഞങ്ങൾ തടസ്സങ്ങളില്ലാതെ അത് പുറത്തിറക്കി.'},
      ],
      drills: [
        {'en': 'Initially, our entire department felt skeptical about transitioning to the new agile methodology.', 'ml': 'തുടക്കത്തിൽ പുതിയ രീതിയിലേക്ക് മാറുന്നതിൽ ഡിപ്പാർട്ട്മെന്റിന് മുഴുവൻ സംശയങ്ങളുണ്ടായിരുന്നു.', 'rule': 'Act 1 Setup: Initially, our department felt'},
        {'en': 'However, at the midpoint of the quarter, our productivity metrics plummeted unexpectedly.', 'ml': 'എങ്കിലും പാദത്തിന്റെ മധ്യത്തിൽ നമ്മുടെ ഉൽപ്പാദനക്ഷമത അപ്രതീക്ഷിതമായി കുത്തനെ ഇടിഞ്ഞു.', 'rule': 'Act 2 Conflict: plummeted unexpectedly'},
        {'en': 'Ultimately, through daily collaborative standups and clear ownership, we exceeded our annual sales targets.', 'ml': 'ഒടുവിൽ കൂട്ടായ പ്രവർത്തനത്തിലൂടെയും കൃത്യമായ ഉത്തരവാദിത്തത്തിലൂടെയും ഞങ്ങൾ ലക്ഷ്യത്തെ മറികടന്നു.', 'rule': 'Act 3 Resolution: Ultimately, through collaboration'},
        {'en': 'What this whole experience taught me was that clear communication beats raw technical speed.', 'ml': 'സാങ്കേതിക വേഗതയേക്കാൾ പ്രധാനം വ്യക്തമായ ആശയവിനിമയമാണെന്ന് ഈ അനുഭവം എന്നെ പഠിപ്പിച്ചു.', 'rule': 'Core Takeaway: What this experience taught me was'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Opening the first act of your story describing the starting condition:',
          'qMl': 'ചോദ്യം 1: കാര്യങ്ങളുടെ തുടക്കത്തെക്കുറിച്ച് പറയാൻ ഏറ്റവും അനുയോജ്യമായ വാക്ക്:',
          'audio': 'Question 1: Is it Initially we lacked sufficient resources, or In the start we lacked sufficient resources?',
          'correct': 'Initially, we lacked sufficient resources.',
          'wrong': 'In the start, we lacked sufficient resources.',
          'tip': 'The executive transition adverb for the beginning of a story is "Initially"!',
        },
        {
          'qEn': 'Question 2: Concluding your story with the final triumph and resolution:',
          'qMl': 'ചോദ്യം 2: ഒടുവിൽ എല്ലാ പ്രശ്നങ്ങളും പരിഹരിച്ച് വിജയം നേടിയെന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it Ultimately our solution proved successful, or Last of all our solution proved successful?',
          'correct': 'Ultimately, our solution proved successful.',
          'wrong': 'Last of all our solution proved successful.',
          'tip': 'Use "Ultimately" to represent the triumphant resolution of a multi-stage narrative!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 49: Executive Connecting Words (However, Therefore, Furthermore, In spite of)
    // -------------------------------------------------------------------------
    49: const DayCurriculumSpec(
      day: 49,
      topicEmoji: '🌊',
      titleEn: 'Day 49: Executive Connecting Words (However, Therefore, Furthermore, In spite of)',
      titleMl: 'ഡേ 49: സംസാരത്തിന്റെ നിലവാരം ഉയർത്താൻ Executive Linkers',
      greetingEn: 'Welcome to Day 49! 🌟 Today we replace basic words like "but", "so", and "also" with high-level executive linkers: However, Therefore, Furthermore, and In spite of!',
      greetingMl: 'ഡേ 49 ലേക്ക് സ്വാഗതം! 🌟 വെറുതെ "but", "so" എന്ന് മാത്രം പറയാതെ, സംസാരം കൂടുതൽ പ്രൊഫഷണലാക്കാൻ However, Therefore, Furthermore, In spite of എന്നിവ ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 49! Today we elevate your speech using executive connecting words.',
      blueprintTitle: 'THE EXECUTIVE DISCOURSE CONNECTORS',
      blueprintExplanationEn: 'Upgrade your vocabulary: Replace "but" with "however". Replace "so" with "therefore". Replace "also" with "furthermore / in addition". Use "In spite of + noun / -ing" (NEVER "In spite of it was raining")!',
      blueprintExplanationMl: 'സംസാരത്തിന്റെ ലെവൽ മാറ്റാൻ: But ന് പകരം However (എന്നിരുന്നാലും), So ക്ക് പകരം Therefore (അതുകൊണ്ട്), Also ക്ക് പകരം Furthermore (കൂടാതെ) എന്ന് പ്രയോഗിക്കുക. "In spite of" ന് ശേഷം noun അല്ലെങ്കിൽ -ing വരണം.',
      blueprintRules: [
        {'subject': 'Contrast Connector (However)', 'en': 'The deadline was remarkably demanding; however, our developers delivered flawless code.', 'ml': 'സമയം വളരെ കുറവായിരുന്നു; എന്നിരുന്നാലും ഞങ്ങളുടെ ഡെവലപ്പർമാർ തെറ്റുകളില്ലാതെ കോഡ് തയ്യാറാക്കി.'},
        {'subject': 'Consequence Connector (Therefore)', 'en': 'Our overseas server latency increased; therefore, we routed traffic to a regional data hub.', 'ml': 'സെർവറിലെ കാലതാമസം വർദ്ധിച്ചു; അതുകൊണ്ട് ഞങ്ങൾ അടുത്തുള്ള ഡാറ്റാ സെന്ററിലേക്ക് ട്രാഫിക് തിരിച്ചുവിട്ടു.'},
        {'subject': 'Concession (In spite of + noun)', 'en': 'In spite of heavy market turbulence, our firm achieved thirty percent profit expansion.', 'ml': 'വിപണിയിലെ വലിയ മാന്ദ്യമുണ്ടായിരുന്നിട്ടും ഞങ്ങളുടെ കമ്പനി മുപ്പത് ശതമാനം ലാഭ വളർച്ച കൈവരിച്ചു.'},
      ],
      drills: [
        {'en': 'The initial project costs were high; however, the long-term energy savings far outweighed the expense.', 'ml': 'തുടക്കത്തിലെ ചെലവ് കൂടുതലായിരുന്നു; എന്നിരുന്നാലും ദീർഘകാലാടിസ്ഥാനത്തിൽ ഇത് വലിയ ലാഭം നൽകി.', 'rule': 'Contrast: however'},
        {'en': 'Our mobile users demanded dark mode; therefore, we redesigned the entire visual styling system.', 'ml': 'ഉപയോക്താക്കൾ ഡാർക്ക് മോഡ് ആവശ്യപ്പെട്ടു; അതുകൊണ്ട് ഞങ്ങൾ ഡിസൈൻ മുഴുവൻ മാറ്റിമറിച്ചു.', 'rule': 'Consequence: therefore'},
        {'en': 'Furthermore, automated unit tests provide junior engineers with the confidence to deploy quickly.', 'ml': 'കൂടാതെ, ഓട്ടോമേറ്റഡ് ടെസ്റ്റുകൾ ജൂനിയർ എഞ്ചിനീയർമാർക്ക് വേഗത്തിൽ കാര്യങ്ങൾ ചെയ്യാൻ ധൈര്യം നൽകുന്നു.', 'rule': 'Additive Linker: Furthermore'},
        {'en': 'In spite of facing severe technical roadblocks, the team met every milestone ahead of schedule.', 'ml': 'വലിയ സാങ്കേതിക വെല്ലുവിളികൾ നേരിട്ടിട്ടും ടീം എല്ലാ ലക്ഷ്യങ്ങളും സമയത്തിന് മുമ്പേ കൈവരിച്ചു.', 'rule': 'Concession: In spite of facing (-ing)'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing that despite having a busy schedule, you attended the training:',
          'qMl': 'ചോദ്യം 1: തിരക്കുണ്ടായിരുന്നിട്ടും ഞാൻ പങ്കെടുത്തു എന്ന് "In spite of" ഉപയോഗിച്ച് പറയാൻ:',
          'audio': 'Question 1: Is it In spite of my tight schedule I attended the session, or In spite of I had a tight schedule I attended the session?',
          'correct': 'In spite of my tight schedule, I attended the session.',
          'wrong': 'In spite of I had a tight schedule, I attended the session.',
          'tip': '"In spite of" takes a noun phrase ("my tight schedule"), not a subject-verb clause ("I had")!',
        },
        {
          'qEn': 'Question 2: Explaining a decision as a logical consequence of your findings:',
          'qMl': 'ചോദ്യം 2: കണ്ടെത്തലുകളുടെ വെളിച്ചത്തിൽ അതിനാൽ ഞങ്ങൾ ഇങ്ങനെയൊരു തീരുമാനമെടുത്തു എന്ന് പറയാൻ:',
          'audio': 'Question 2: Is it Therefore, we chose to upgrade the hardware, or Therefore because we chose to upgrade the hardware?',
          'correct': 'Therefore, we chose to upgrade the hardware.',
          'wrong': 'Therefore because we chose to upgrade the hardware.',
          'tip': 'Never combine "Therefore" with "because"; use "Therefore" alone as the consequence linker!',
        },
      ],
    ),

    // -------------------------------------------------------------------------
    // DAY 50: Essential Workplace & Career Vocabulary (Deliverables, Bandwidth, Synergies)
    // -------------------------------------------------------------------------
    50: const DayCurriculumSpec(
      day: 50,
      topicEmoji: '👑',
      titleEn: 'Day 50: Essential Workplace & Career Vocabulary (Deliverables, Bandwidth, Synergies)',
      titleMl: 'ഡേ 50: കരിയറിലും ഓഫീസിലും തിളങ്ങാൻ Workplace Collocations',
      greetingEn: 'Welcome to Day 50! 🌟 Congratulations on reaching the 50-Day Half-Way Milestone! Today we master essential corporate collocations: meeting deadlines, delegating tasks, and streamlining workflows!',
      greetingMl: 'ഡേ 50 ലേക്ക് സ്വാഗതം! 🌟 50-ാം ദിവസത്തെ ചരിത്ര നേട്ടത്തിന് അഭിനന്ദനങ്ങൾ! കോർപ്പറേറ്റ് ലോകത്തെ പ്രധാന പദങ്ങളും ശൈലികളും (meet deadlines, streamline workflows, delegate tasks) ഇന്ന് പഠിക്കാം!',
      greetingAudio: 'Welcome to Day 50 and congratulations on reaching the 50-day milestone! Today we master essential workplace vocabulary.',
      blueprintTitle: 'THE EXECUTIVE COLLOCATION BLUEPRINT',
      blueprintExplanationEn: 'Professional English relies on natural collocations (words that belong together): 1) "meet a deadline" (NOT "reach a deadline") 2) "streamline workflows" (making processes efficient) 3) "delegate responsibilities" (assigning work) and 4) "have sufficient bandwidth" (having capacity/time).',
      blueprintExplanationMl: 'ഓഫീസ് സംസാരത്തിൽ വാക്കുകൾ കൂട്ടമായി പ്രയോഗിക്കുക: "meet a deadline" (സമയത്ത് ജോലി തീർക്കുക), "streamline workflows" (ജോലി കൂടുതൽ ലളിതവും കാര്യക്ഷമവുമാക്കുക), "delegate tasks" (മറ്റുള്ളവർക്ക് ചുമതലകൾ വീതിച്ചു നൽകുക).',
      blueprintRules: [
        {'subject': 'Meeting Deadlines', 'en': 'By working cohesively, our team managed to meet the stringent project deadline.', 'ml': 'ഒറ്റക്കെട്ടായി പ്രവർത്തിച്ചുകൊണ്ട് ഞങ്ങളുടെ ടീമിന് ആ കടുത്ത സമയപരിധിക്കുള്ളിൽ ജോലി തീർക്കാൻ സാധിച്ചു.'},
        {'subject': 'Operational Efficiency', 'en': 'We streamlined our release workflow by implementing automated cloud CI/CD pipelines.', 'ml': 'ഓട്ടോമേറ്റഡ് ക്ലൗഡ് പൈപ്പ്‌ലൈനുകൾ വഴി ഞങ്ങൾ റിലീസ് ജോലികൾ കൂടുതൽ കാര്യക്ഷമമാക്കി.'},
        {'subject': 'Professional Capacity (Bandwidth)', 'en': 'I would love to assist on that project, but my current bandwidth is fully committed.', 'ml': 'ആ പ്രോജക്റ്റിൽ സഹായിക്കാൻ എനിക്ക് ആഗ്രഹമുണ്ട്, എന്നാൽ നിലവിൽ എനിക്ക് സമയമില്ല (bandwidth is committed).'},
      ],
      drills: [
        {'en': 'Our project manager delegates operational tasks effectively so that we avoid team burnout.', 'ml': 'ടീം ക്ഷീണിക്കാതിരിക്കാൻ ഞങ്ങളുടെ പ്രോജക്റ്റ് മാനേജർ ജോലികൾ കൃത്യമായി വീതിച്ചു നൽകുന്നു.', 'rule': 'Workplace Collocation: delegates operational tasks'},
        {'en': 'We must streamline our customer onboarding process to minimize user drop-off rates.', 'ml': 'ഉപയോക്താക്കൾ കൊഴിഞ്ഞുപോകാതിരിക്കാൻ ഞങ്ങൾ ജോലികൾ കൂടുതൽ സുഗമമാക്കണം.', 'rule': 'Efficiency Collocation: streamline our process'},
        {'en': 'She has the technical bandwidth and leadership acumen to spearhead this corporate initiative.', 'ml': 'ഈ പുതിയ പ്രോജക്റ്റിന് നേതൃത്വം നൽകാനുള്ള കഴിവും സമയവും അവൾക്കുണ്ട്.', 'rule': 'Corporate Idiom: bandwidth and leadership acumen'},
        {'en': 'Holding daily standup syncs ensures that our cross-functional priorities remain perfectly aligned.', 'ml': 'ദിവസേനയുള്ള മീറ്റിംഗുകൾ നമ്മുടെ ടീമുകളുടെ മുൻഗണനകൾ ഒരേ ദിശയിലാക്കാൻ സഹായിക്കുന്നു.', 'rule': 'Alignment: priorities remain aligned'},
      ],
      quizQuestions: [
        {
          'qEn': 'Question 1: Expressing that you completed your project work before the required time limit:',
          'qMl': 'ചോദ്യം 1: സമയപരിധിക്കുള്ളിൽ ജോലി പൂർത്തിയാക്കി എന്ന് ശരിയായ ബിസിനസ്സ് ഇംഗ്ലീഷിൽ പറയാൻ:',
          'audio': 'Question 1: Is it We met the deadline comfortably, or We reached the deadline comfortably?',
          'correct': 'We met the deadline comfortably.',
          'wrong': 'We reached the deadline comfortably.',
          'tip': 'The natural English business collocation is "meet the deadline", never "reach the deadline"!',
        },
        {
          'qEn': 'Question 2: Telling your manager politely that you do not have spare time for extra tasks:',
          'qMl': 'ചോദ്യം 2: പുതിയ ജോലി ഏറ്റെടുക്കാൻ തനിക്ക് നിലവിൽ സമയമില്ലെന്ന് പ്രൊഫഷണലായി പറയാൻ:',
          'audio': 'Question 2: Is it I do not have the bandwidth for additional tasks right now, or I do not have the battery for additional tasks right now?',
          'correct': 'I do not have the bandwidth for additional tasks right now.',
          'wrong': 'I do not have the battery for additional tasks right now.',
          'tip': 'In modern corporate English, "bandwidth" is the standard term for personal capacity and time!',
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

    // Forgiving evaluation check (avoid blocking user due to mobile mic/STT inaccuracies)
    if (!evalResult.isAcceptable &&
        evalResult.accuracyPercentage < 50 &&
        voiceText.toLowerCase() != target.toLowerCase() &&
        !voiceText.toLowerCase().contains('yes') &&
        !voiceText.toLowerCase().contains('start') &&
        !voiceText.toLowerCase().contains('test')) {
      // Evaluation failed: Give constructive retry feedback with option to continue anyway
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
                'Target: "$target"\n\n'
                '${evalResult.feedbackTip}',
            textNative: 'ശ്രമിക്കൂ! വീണ്ടും പറയാം അല്ലെങ്കിൽ മുന്നോട്ട് പോകാം.',
            cardContent: PocketPronunciationResultCard(
              result: evalResult,
              onRetry: () => _toggleLiveListening(),
            ),
            speakThisPrompt: 'Tap mic to try again, or continue:',
            inBubbleOptions: [
              DayInBubbleOption(
                labelEn: '🎙️ RETRY: "$target"',
                labelNative: 'വീണ്ടും പറയാം',
                icon: '🔄',
                isHighlightedAnswer: false,
                backgroundColor: const Color(0xFFEF4444),
                borderColor: const Color(0xFFFCA5A5),
                textColor: Colors.white,
                onTap: () => _handleVoiceSubmission(
                  voiceText: target,
                  action: action,
                ),
              ),
              DayInBubbleOption(
                labelEn: '✨ CONTINUE ANYWAY ➔',
                labelNative: 'മുന്നോട്ട് പോകാം',
                icon: '🚀',
                isHighlightedAnswer: true,
                backgroundColor: const Color(0xFF10B981),
                borderColor: const Color(0xFF6EE7B7),
                textColor: Colors.white,
                onTap: () {
                  setState(() => _isAnalyzing = false);
                  action();
                },
              ),
            ],
          ),
        );
        _isAnalyzing = false;
      });

      _speak('Good try! Say: $target');
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
            final raw = result.recognizedWords.trim();
            final normalized = PocketSpeechNormalizer.normalize(raw);
            _handleVoiceSubmission(
              voiceText: normalized.isEmpty ? raw : normalized,
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

class PocketDay24Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay24Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 24, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 24, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay25Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay25Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 25, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 25, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay26Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay26Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 26, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 26, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay27Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay27Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 27, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 27, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay28Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay28Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 28, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 28, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay29Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay29Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 29, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 29, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay30Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay30Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 30, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 30, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay31Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay31Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 31, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 31, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay32Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay32Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 32, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 32, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay33Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay33Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 33, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 33, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay34Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay34Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 34, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 34, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay35Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay35Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 35, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 35, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay36Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay36Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 36, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 36, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay37Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay37Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 37, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 37, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay38Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay38Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 38, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 38, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay39Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay39Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 39, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 39, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay40Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay40Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 40, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 40, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay41Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay41Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 41, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 41, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay42Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay42Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 42, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 42, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay43Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay43Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 43, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 43, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay44Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay44Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 44, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 44, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay45Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay45Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 45, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 45, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay46Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay46Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 46, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 46, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay47Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay47Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 47, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 47, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay48Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay48Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 48, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 48, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay49Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay49Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 49, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 49, userId: userId, onStepFinished: onStepFinished);
}

class PocketDay50Step1AvatarChatPage extends StatelessWidget {
  final String? userId;
  final Function(int)? onStepFinished;
  const PocketDay50Step1AvatarChatPage({super.key, this.userId, this.onStepFinished});
  static Future<void> show(BuildContext context, {String? userId, Function(int)? onStepFinished}) =>
      PocketDayAvatarChatPage.show(context, day: 50, userId: userId, onStepFinished: onStepFinished);
  @override
  Widget build(BuildContext context) => PocketDayAvatarChatPage(day: 50, userId: userId, onStepFinished: onStepFinished);
}



