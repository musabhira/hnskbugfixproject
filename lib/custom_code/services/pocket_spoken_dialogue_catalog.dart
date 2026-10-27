import 'dart:math' as math;

/// 💬 Model for Curated Spoken English Dialogue Pairs & Prepositional Rules
/// Audio Directive (Malayalam):
/// "ഈ പ്രിപ്പോസിഷൻ റൂൾസ് ആൻഡ് കൊളൊക്കേഷൻസ്... ഇതെല്ലാം എന്ത് ചെയ്യണം എന്നറിയോ?
/// മാക്സിമം ഈ വൈബ്സ് ഇടുക വൈബ്സ്. റോബോട്ടുകൾ ഇങ്ങനെ വൈബ്സ് ഇട്ടുകൊണ്ടേയിരിക്കും...
/// How are you? I am fine. / What are you doing? I am studying. / Where are you from? I am from India.
/// What is your name? My name is Roshan. / Nice to meet you. Nice to meet you too.
/// Thank you. You are welcome. / Sorry. It's okay. / Excuse me, may I come in? Yes, please come in...
/// പല പല കളർ ബാക്ക്ഗ്രൗണ്ടുകളൊക്കെ വരുന്നുണ്ട്... അതിൽ ഇങ്ങനെ ചാറ്റിന്റെ ബബിൾ ആക്കി കൊടുക്കുക!
/// ഇവിടെ ഇങ്ങനെ ചോദിക്കുന്നു, ഇതിന് ഉത്തരം കൊടുക്കുന്നു...
/// ഒരാൾ ഒന്നാമത്തെ ലെവൽ ആണെങ്കിൽ ബേസിക്... 90-ാമത്തെ ലെവൽ ആണെങ്കിൽ ആ ലെവലിലുള്ളത്...
/// സ്നാപ്പിന്റെ അടിയിൽ തന്നെ എഴുത്തും ടെക്സ്റ്റും കൊളാഷ് ആയി പോവരുത്... മിനിമൽ ആയിട്ട് അയക്കുക."
class PocketSpokenDialogueItem {
  final String id;
  final String type; // 'spoken_dialogue' | 'preposition_rule'
  final String tag;
  final int minLevel;
  final int maxLevel;
  final List<int> gradientColors;
  // For Spoken Dialogue:
  final String question;
  final String answer;
  final List<String> alternativeReplies;
  // For Preposition Rules:
  final String? ruleTitle;
  final String? preposition;
  final List<String> collocations;
  // Explanatory note in Malayalam:
  final String malayalamNote;

  const PocketSpokenDialogueItem({
    required this.id,
    required this.type,
    required this.tag,
    required this.minLevel,
    required this.maxLevel,
    required this.gradientColors,
    required this.question,
    required this.answer,
    this.alternativeReplies = const [],
    this.ruleTitle,
    this.preposition,
    this.collocations = const [],
    required this.malayalamNote,
  });

  bool get isPrepositionRule => type == 'preposition_rule';
}

/// 📚 Comprehensive Master Catalog of Progressive Spoken English Dialogues & Preposition Rules
class PocketSpokenDialogueCatalog {
  static final math.Random _random = math.Random();

  static const List<PocketSpokenDialogueItem> allItems = [
    // ==========================================
    // 🟢 TIER 1: LEVEL 1 TO 15 (FOUNDATIONAL BASICS & COURTESY)
    // ==========================================
    PocketSpokenDialogueItem(
      id: 'dialogue_whats_up',
      type: 'spoken_dialogue',
      tag: '💬 Casual Chat • Day 1',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF06B6D4, 0xFF3B82F6],
      question: 'What\'s up?',
      answer: 'Not much, just chilling.',
      alternativeReplies: ['All good here!', 'Just relaxing.'],
      malayalamNote: 'സുഹൃത്തുക്കളോട് വിശേഷം ചോദിക്കാൻ \'What\'s up?\' എന്ന് ലളിതമായി ചോദിക്കാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_drink_water',
      type: 'spoken_dialogue',
      tag: '💬 Daily Care • Day 1',
      minLevel: 1,
      maxLevel: 25,
      gradientColors: [0xFF0284C7, 0xFF0EA5E9],
      question: 'Did you drink water?',
      answer: 'Yes, I just did!',
      alternativeReplies: ['Having some right now.', 'Thanks for reminding me!'],
      malayalamNote: 'വെള്ളം കുടിച്ചോ എന്ന് ചോദിക്കുമ്പോൾ \'Did you drink water?\' എന്ന് ചോദിക്കാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_had_breakfast',
      type: 'spoken_dialogue',
      tag: '💬 Daily Routine • Day 2',
      minLevel: 1,
      maxLevel: 25,
      gradientColors: [0xFF10B981, 0xFF059669],
      question: 'Had your breakfast?',
      answer: 'Yes, I had it!',
      alternativeReplies: ['Going to have now.', 'Not yet, will eat soon.'],
      malayalamNote: 'പ്രഭാതഭക്ഷണം കഴിച്ചോ എന്ന് ചോദിക്കുമ്പോൾ \'Had your breakfast?\' എന്ന് പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_are_you_free',
      type: 'spoken_dialogue',
      tag: '💬 Quick Connect • Day 2',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF8B5CF6, 0xFF6366F1],
      question: 'Are you free now?',
      answer: 'Yes, let\'s talk!',
      alternativeReplies: ['Give me five minutes.', 'Yes, free now.'],
      malayalamNote: 'ഇപ്പോൾ ഒഴിവുണ്ടോ എന്ന് ചോദിക്കുമ്പോൾ \'Are you free now?\' എന്ന് ഉപയോഗിക്കാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_student_homework',
      type: 'spoken_dialogue',
      tag: '📚 Student Life • Day 3',
      minLevel: 1,
      maxLevel: 35,
      gradientColors: [0xFFF59E0B, 0xFFD97706],
      question: 'Did you finish your homework?',
      answer: 'Yes, all done for today!',
      alternativeReplies: ['Almost finished.', 'Working on it now.'],
      malayalamNote: 'ഹോംവർക്ക് കഴിഞ്ഞോ എന്ന് ചോദിക്കാൻ \'Did you finish your homework?\' എന്ന് ചോദിക്കാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_kids_play',
      type: 'spoken_dialogue',
      tag: '🎈 Fun & Play • Day 3',
      minLevel: 1,
      maxLevel: 20,
      gradientColors: [0xFFEC4899, 0xFFF43F5E],
      question: 'Can we go play now?',
      answer: 'Yes, let\'s go play!',
      alternativeReplies: ['Sure, let\'s go outside!'],
      malayalamNote: 'കളിക്കാൻ പോകാമോ എന്ന് ചോദിക്കുമ്പോൾ \'Can we go play now?\' എന്ന് പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_how_are_you',
      type: 'spoken_dialogue',
      tag: '💬 Daily Greeting • Day 1',
      minLevel: 1,
      maxLevel: 20,
      gradientColors: [0xFF6366F1, 0xFF8B5CF6], // Royal Indigo & Violet
      question: 'How are you doing today?',
      answer: 'I am fine, thank you!',
      alternativeReplies: [
        'I am doing great!',
        'Doing wonderful, thanks for asking!',
        'Couldn\'t be better!',
      ],
      malayalamNote: 'സുഖമാണോ എന്ന് ചോദിക്കുമ്പോൾ \'I am fine\' അല്ലെങ്കിൽ \'I am doing great\' എന്ന് ആത്മവിശ്വാസത്തോടെ മറുപടി നൽകാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_what_are_you_doing',
      type: 'spoken_dialogue',
      tag: '💬 Daily Activity • Day 2',
      minLevel: 1,
      maxLevel: 25,
      gradientColors: [0xFF0284C7, 0xFF0EA5E9], // Ocean Blue & Sky
      question: 'What are you doing right now?',
      answer: 'I am studying English.',
      alternativeReplies: [
        'I am reading a book.',
        'Just relaxing for a bit.',
        'Getting ready for work.',
      ],
      malayalamNote: 'ഇപ്പോൾ ചെയ്തുകൊണ്ടിരിക്കുന്ന പ്രവൃത്തിയെക്കുറിച്ച് ചോദിക്കുമ്പോൾ \'I am + ing verb\' (e.g. studying, reading) ഉപയോഗിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_where_are_you_from',
      type: 'spoken_dialogue',
      tag: '💬 Origin & Identity • Day 3',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF059669, 0xFF10B981], // Emerald & Mint
      question: 'Where are you from?',
      answer: 'I am from India.',
      alternativeReplies: [
        'I live in Kerala, India.',
        'I was born and raised in India.',
        'I\'m from Kochi, India.',
      ],
      malayalamNote: 'സ്വദേശം പറയുമ്പോൾ \'I am from India\' അല്ലെങ്കിൽ \'I live in Kerala\' എന്ന് വ്യക്തമായി പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_what_is_your_name',
      type: 'spoken_dialogue',
      tag: '💬 Self Introduction • Day 1',
      minLevel: 1,
      maxLevel: 15,
      gradientColors: [0xFF9333EA, 0xFFC026D3], // Purple & Fuchsia
      question: 'What is your name?',
      answer: 'My name is Roshan.',
      alternativeReplies: [
        'I\'m Roshan, nice to meet you!',
        'You can call me Roshan.',
      ],
      malayalamNote: 'പേര് പറയുമ്പോൾ \'My name is...\' അല്ലെങ്കിൽ \'I\'m...\' എന്ന് ലളിതമായി പറയുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_nice_to_meet_you',
      type: 'spoken_dialogue',
      tag: '💬 Politeness • Day 2',
      minLevel: 1,
      maxLevel: 25,
      gradientColors: [0xFF0D9488, 0xFF14B8A6], // Deep Teal
      question: 'Nice to meet you!',
      answer: 'Nice to meet you too!',
      alternativeReplies: [
        'Pleased to meet you!',
        'The pleasure is entirely mine.',
        'Great meeting you as well!',
      ],
      malayalamNote: 'ആദ്യമായി ഒരാളെ കാണുമ്പോൾ \'Nice to meet you\' എന്നും, മറുപടിയായി \'Nice to meet you too\' എന്നും പറയണം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_thank_you',
      type: 'spoken_dialogue',
      tag: '💬 Gratitude • Day 1',
      minLevel: 1,
      maxLevel: 25,
      gradientColors: [0xFFEA580C, 0xFFF97316], // Sunset Orange
      question: 'Thank you so much for your help!',
      answer: 'You are most welcome!',
      alternativeReplies: [
        'Anytime!',
        'Glad to help!',
        'Don\'t mention it.',
      ],
      malayalamNote: 'നന്ദി പറയുമ്പോൾ വെറും \'Welcome\' എന്നതിനേക്കാൾ \'You are most welcome\' അല്ലെങ്കിൽ \'Glad to help\' എന്ന് പറയുന്നത് കൂടുതൽ പ്രൊഫഷണലാണ്.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_sorry_delay',
      type: 'spoken_dialogue',
      tag: '💬 Apologies & Grace • Day 3',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFFB91C1C, 0xFFE11D48], // Crimson & Rose
      question: 'I am so sorry for the delay.',
      answer: 'It\'s totally okay, no problem at all!',
      alternativeReplies: [
        'That\'s completely alright.',
        'Don\'t worry about it!',
        'Not a problem.',
      ],
      malayalamNote: 'ആരെങ്കിലും ക്ഷമ ചോദിക്കുമ്പോൾ \'It\'s okay\' അല്ലെങ്കിൽ \'No problem at all\' എന്ന് പറഞ്ഞ് സൗഹൃദം നിലനിർത്താം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_may_i_come_in',
      type: 'spoken_dialogue',
      tag: '💬 Courteous Permission • Day 4',
      minLevel: 1,
      maxLevel: 35,
      gradientColors: [0xFF1E3A8A, 0xFF3B82F6], // Cobalt Blue
      question: 'Excuse me, may I come in?',
      answer: 'Yes, please come in! Take a seat.',
      alternativeReplies: [
        'Sure, please have a seat.',
        'Of course, welcome in!',
      ],
      malayalamNote: 'അനുവാദം ചോദിക്കാൻ \'May I come in?\' ഉപയോഗിക്കുക. മറുപടിയായി \'Yes, please come in\' എന്ന് പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_sit_down_comfort',
      type: 'spoken_dialogue',
      tag: '💬 Hospitality • Day 5',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF4F46E5, 0xFF7C3AED], // Indigo & Violet
      question: 'Please sit down and make yourself comfortable.',
      answer: 'Thank you very much, that\'s very kind of you.',
      alternativeReplies: [
        'Thanks a lot!',
        'Much appreciated.',
      ],
      malayalamNote: '\'Sit down, please\' അല്ലെങ്കിൽ \'Make yourself comfortable\' എന്ന് സന്ദർശകരോട് ആതിഥ്യത്തോടെ പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_please_listen',
      type: 'spoken_dialogue',
      tag: '💬 Active Listening • Day 4',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF059669, 0xFF0D9488], // Emerald & Teal
      question: 'Please listen carefully to this instruction.',
      answer: 'I\'m listening! Go ahead.',
      alternativeReplies: [
        'I\'m all ears!',
        'Yes, I am paying full attention.',
      ],
      malayalamNote: 'ശ്രദ്ധിച്ചു കേൾക്കാൻ പറയുമ്പോൾ \'I\'m listening\' അല്ലെങ്കിൽ \'I\'m all ears\' എന്ന് മറുപടി നൽകാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_repeat_slowly',
      type: 'spoken_dialogue',
      tag: '💬 Clarification • Day 5',
      minLevel: 1,
      maxLevel: 40,
      gradientColors: [0xFFD97706, 0xFFF59E0B], // Amber & Gold
      question: 'I don\'t understand, can you repeat please?',
      answer: 'Sure, let me explain it slowly for you.',
      alternativeReplies: [
        'Could you speak a bit slower, please?',
        'No worries, I will rephrase it.',
      ],
      malayalamNote: 'മനസ്സിലായില്ലെങ്കിൽ മടിക്കാതെ \'Could you repeat that please?\' അല്ലെങ്കിൽ \'Please speak slowly\' എന്ന് ചോദിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_sounds_good',
      type: 'spoken_dialogue',
      tag: '💬 Agreement • Day 6',
      minLevel: 1,
      maxLevel: 35,
      gradientColors: [0xFF7C3AED, 0xFFDB2777], // Purple & Pink
      question: 'Shall we practice speaking English for 15 minutes?',
      answer: 'That sounds good! Let\'s get started.',
      alternativeReplies: [
        'Sounds like a solid plan!',
        'I\'d love to do that.',
        'Count me in!',
      ],
      malayalamNote: 'നല്ലൊരു ആശയം കേൾക്കുമ്പോൾ \'That sounds good\' അല്ലെങ്കിൽ \'Sounds great\' എന്ന് സ്വാഭാവികമായി പ്രതികരിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_agree_disagree',
      type: 'spoken_dialogue',
      tag: '💬 Sharing Opinions • Day 8',
      minLevel: 5,
      maxLevel: 45,
      gradientColors: [0xFF2563EB, 0xFF7C3AED], // Electric Blue & Violet
      question: 'I think daily speaking is more important than grammar.',
      answer: 'I completely agree with you on that!',
      alternativeReplies: [
        'I respectfully disagree; balance is key.',
        'I feel the exact same way.',
      ],
      malayalamNote: 'യോജിക്കുമ്പോൾ \'I agree with you\', മാന്യമായി വിയോജിക്കുമ്പോൾ \'I respectfully disagree\' എന്ന് ഉപയോഗിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_dont_know_try',
      type: 'spoken_dialogue',
      tag: '💬 Encouragement • Day 6',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFF0891B2, 0xFF06B6D4], // Cyan
      question: 'I don\'t know the correct answer yet.',
      answer: 'That\'s completely alright! Try again, you can do it.',
      alternativeReplies: [
        'No problem, let\'s figure it out together.',
        'Mistakes help us learn. Give it another shot!',
      ],
      malayalamNote: 'ഉത്തരം അറിയില്ലെങ്കിലും വിഷമിക്കേണ്ട; \'That\'s alright, try again\' എന്ന് ധൈര്യത്തോടെ മുന്നോട്ട് പോവുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_congratulations',
      type: 'spoken_dialogue',
      tag: '💬 Celebrating Wins • Day 7',
      minLevel: 1,
      maxLevel: 35,
      gradientColors: [0xFF16A34A, 0xFF65A30D], // Lime Green
      question: 'Congratulations on reaching a 10-day streak!',
      answer: 'Thank you so much! Good luck with your journey too.',
      alternativeReplies: [
        'Thanks a million! Feeling proud.',
        'Appreciate the kind words!',
      ],
      malayalamNote: 'വിജയങ്ങളിൽ \'Congratulations\' പറയുമ്പോൾ \'Thank you, good luck to you too\' എന്ന് മറുപടി നൽകാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_take_care',
      type: 'spoken_dialogue',
      tag: '💬 Warm Farewells • Day 5',
      minLevel: 1,
      maxLevel: 30,
      gradientColors: [0xFFC2410C, 0xFFEA580C], // Warm Sunset
      question: 'It was great talking to you. Take care and be careful!',
      answer: 'Thank you! You take care too. See you soon.',
      alternativeReplies: [
        'Catch you later!',
        'Stay safe and have a great day!',
      ],
      malayalamNote: 'യാത്രപറയുമ്പോൾ \'Take care\' അല്ലെങ്കിൽ \'Be careful\' എന്ന് ആശംസിക്കുന്നത് വളരെ ഊഷ്മളമായ ഇംഗ്ലീഷ് ശൈലിയാണ്.',
    ),

    // ==========================================
    // ⚡ PREPOSITION RULES & COLLOCATIONS (FOUNDATIONAL & INTERMEDIATE)
    // ==========================================
    PocketSpokenDialogueItem(
      id: 'prep_rule_at',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "AT"',
      minLevel: 1,
      maxLevel: 40,
      gradientColors: [0xFF4F46E5, 0xFF818CF8], // Indigo Aura
      ruleTitle: 'Words that ALWAYS pair with "AT":',
      preposition: 'AT',
      collocations: [
        'Good at English 🎯',
        'Bad at driving 🚗',
        'Clever at math 🧠',
        'Angry at someone 😡',
        'Surprised at the news 😲',
        'Slow at typing ⌨️',
      ],
      question: 'Are you good at speaking English in public?',
      answer: 'Yes! I am getting better at it every single day.',
      malayalamNote: '\'Good in English\' എന്ന് ഒരിക്കലും പറയരുത്! വ്യക്തിഗത കഴിവുകളെ സൂചിപ്പിക്കാൻ എപ്പോഴും \'good at\', \'bad at\' എന്ന് ഉപയോഗിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_for',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "FOR"',
      minLevel: 5,
      maxLevel: 45,
      gradientColors: [0xFF059669, 0xFF34D399], // Emerald
      ruleTitle: 'Words that ALWAYS pair with "FOR":',
      preposition: 'FOR',
      collocations: [
        'Eager for success 🌟',
        'Famous for hospitality 🌴',
        'Wait for someone ⏳',
        'Apologize for delay 🤝',
        'Looking for keys 🔍',
        'Responsible for tasks 📋',
      ],
      question: 'What are you looking for right now?',
      answer: 'I am waiting for my friend outside.',
      malayalamNote: '\'Wait to me\' തെറ്റാണ്; \'Wait for me\' എന്നാണ് ശരി. കാരണം ആർക്കുവേണ്ടിയാണോ കാത്തിരിക്കുന്നത് അതിന് \'for\' ചേർക്കുന്നു.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_with',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "WITH"',
      minLevel: 10,
      maxLevel: 50,
      gradientColors: [0xFF7C3AED, 0xFFA78BFA], // Purple
      ruleTitle: 'Words that ALWAYS pair with "WITH":',
      preposition: 'WITH',
      collocations: [
        'Bored with routine 🥱',
        'Agree with someone 🤝',
        'Satisfied with results ✅',
        'Crowded with people 👥',
        'Familiar with words 📖',
        'Angry with a person 😤',
      ],
      question: 'Are you bored with reading grammar rules?',
      answer: 'Not at all! I enjoy real conversational dialogues with my Pocket Mate.',
      malayalamNote: '\'I agree to you\' എന്നല്ല, ഒരു വ്യക്തിയോട് യോജിക്കുമ്പോൾ \'I agree with you\' എന്ന് പറയുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_of',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "OF"',
      minLevel: 10,
      maxLevel: 55,
      gradientColors: [0xFFDC2626, 0xFFF87171], // Vibrant Red
      ruleTitle: 'Words that ALWAYS pair with "OF":',
      preposition: 'OF',
      collocations: [
        'Afraid of mistakes 😨',
        'Proud of your win 🏆',
        'Fond of music 🎵',
        'Tired of waiting ⏰',
        'Jealous of others 😒',
        'Aware of the rules 📜',
      ],
      question: 'Are you afraid of speaking in front of others?',
      answer: 'No, I am proud of trying my best every single day!',
      malayalamNote: '\'Afraid to dogs\' എന്നല്ല; ഭയം, അഭിമാനം, ക്ഷീണം എന്നിവ സൂചിപ്പിക്കുമ്പോൾ \'afraid of\', \'proud of\', \'tired of\' എന്നിവ ഉപയോഗിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_to',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "TO"',
      minLevel: 12,
      maxLevel: 60,
      gradientColors: [0xFF2563EB, 0xFF60A5FA], // Blue
      ruleTitle: 'Words that ALWAYS pair with "TO":',
      preposition: 'TO',
      collocations: [
        'Married to someone 💍',
        'Listen to audio 🎧',
        'Belong to me 📦',
        'Looking forward to meeting 🤝',
        'Object to a proposal ✋',
        'Accustomed to habits 🔄',
      ],
      question: 'Who does this notebook belong to?',
      answer: 'It belongs to me! Thank you for finding it.',
      malayalamNote: '\'Married with\' എന്നത് ഏറ്റവും സാധാരണയായ ഒരു തെറ്റാണ്. \'Married to\' എന്നാണ് ശരിയായ ഇംഗ്ലീഷ് ശൈലി.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_about',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "ABOUT"',
      minLevel: 15,
      maxLevel: 65,
      gradientColors: [0xFFEA580C, 0xFFFB923C], // Orange Flame
      ruleTitle: 'Words that ALWAYS pair with "ABOUT":',
      preposition: 'ABOUT',
      collocations: [
        'Excited about progress 🚀',
        'Worried about interview 💼',
        'Angry about a situation 💢',
        'Complain about delay 🗣️',
        'Care about health 💖',
        'Enthusiastic about learning 🌟',
      ],
      question: 'What are you so excited about today?',
      answer: 'I am excited about reaching my next English speaking milestone!',
      malayalamNote: 'ഒരു സംഭവത്തെയോ സാഹചര്യത്തെയോ കുറിച്ച് വികാരം പ്രകടിപ്പിക്കുമ്പോൾ \'about\' (e.g. excited about, worried about) ഉപയോഗിക്കുന്നു.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_in',
      type: 'preposition_rule',
      tag: '⚡ Preposition Rule • "IN"',
      minLevel: 18,
      maxLevel: 70,
      gradientColors: [0xFF0D9488, 0xFF2DD4BF], // Teal
      ruleTitle: 'Words that ALWAYS pair with "IN":',
      preposition: 'IN',
      collocations: [
        'Interested in English 🗣️',
        'Believe in yourself 🌟',
        'Succeed in career 📈',
        'Participate in events 🎙️',
        'Specialize in software 💻',
        'Confident in speaking 💪',
      ],
      question: 'Are you interested in master-level English conversations?',
      answer: 'Yes, I strongly believe in daily speaking practice!',
      malayalamNote: 'താല്പര്യം, ആഴത്തിലുള്ള വിശ്വാസം എന്നിവയ്ക്ക് \'interested in\', \'believe in\' എന്നീ പ്രിപ്പോസിഷനുകൾ വരുന്നു.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_by',
      type: 'preposition_rule',
      tag: '⚡ Fixed Phrases with "BY"',
      minLevel: 20,
      maxLevel: 75,
      gradientColors: [0xFF4338CA, 0xFF6366F1], // Royal Indigo
      ruleTitle: 'Fixed Prepositional Idioms with "BY":',
      preposition: 'BY',
      collocations: [
        'By mistake 🤦‍♂️',
        'By accident 🚗',
        'By chance 🍀',
        'By heart 🧠',
        'By all means 👍',
        'By the way 💬',
      ],
      question: 'Did you delete the chat on purpose?',
      answer: 'No, I deleted it completely by mistake!',
      malayalamNote: '\'With mistake\' അല്ലെങ്കിൽ \'in mistake\' എന്ന് പറയരുത്. അബദ്ധത്തിൽ സംഭവിച്ച കാര്യങ്ങൾക്ക് \'by mistake\' അല്ലെങ്കിൽ \'by accident\' എന്ന് പറയുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'prep_rule_on',
      type: 'preposition_rule',
      tag: '⚡ Fixed Phrases with "ON"',
      minLevel: 22,
      maxLevel: 80,
      gradientColors: [0xFF0F766E, 0xFF14B8A6], // Deep Sea Teal
      ruleTitle: 'Fixed Prepositional Idioms with "ON":',
      preposition: 'ON',
      collocations: [
        'On purpose 🎯',
        'On time ⌚',
        'On vacation 🏖️',
        'Depend on practice 💪',
        'Insist on clarity 🔍',
        'Congratulate on success 🏆',
      ],
      question: 'Did you reach the meeting room late?',
      answer: 'Not at all! I arrived right on time.',
      malayalamNote: '\'In time\' എന്നാൽ അവസാന നിമിഷത്തിന് മുമ്പ്, \'On time\' എന്നാൽ കൃത്യസമയത്ത്. മനപ്പൂർവ്വം ചെയ്തതിന് \'on purpose\' എന്ന് പറയുന്നു.',
    ),

    // ==========================================
    // 🔵 TIER 2: LEVEL 25 TO 50 (WORKPLACE & SOCIAL FLUENCY)
    // ==========================================
    PocketSpokenDialogueItem(
      id: 'dialogue_help_hand',
      type: 'spoken_dialogue',
      tag: '💬 Workplace Courtesy • Day 25',
      minLevel: 20,
      maxLevel: 60,
      gradientColors: [0xFF1E293B, 0xFF475569], // Slate Professional
      question: 'Could you please give me a hand with this report?',
      answer: 'I\'d be more than happy to help! Let me take a look.',
      alternativeReplies: [
        'Sure, what do you need help with?',
        'Give me two minutes and I\'m all yours.',
      ],
      malayalamNote: 'സഹായം ചോദിക്കാൻ \'Give me a hand\' എന്ന ശൈലിയും, സന്തോഷത്തോടെ സഹായിക്കാൻ \'I\'d be happy to help\' എന്നും ഉപയോഗിക്കുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_how_has_day_been',
      type: 'spoken_dialogue',
      tag: '💬 Social Small Talk • Day 28',
      minLevel: 20,
      maxLevel: 65,
      gradientColors: [0xFF0369A1, 0xFF0284C7], // Ocean
      question: 'How has your day been so far?',
      answer: 'It\'s been quite productive, thanks for asking! How about yours?',
      alternativeReplies: [
        'Pretty busy, but going well!',
        'Can\'t complain, everything is on track.',
      ],
      malayalamNote: 'പകൽസമയത്ത് ഒരാളോട് വിവരങ്ങൾ ചോദിക്കുമ്പോൾ \'How has your day been so far?\' എന്ന് ചോദിക്കുന്നത് സ്വാഭാവികമാണ്.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_mind_joining',
      type: 'spoken_dialogue',
      tag: '💬 Polite Inquiries • Day 32',
      minLevel: 25,
      maxLevel: 70,
      gradientColors: [0xFF6D28D9, 0xFF7C3AED], // Deep Violet
      question: 'Would you mind if I joined you at this table?',
      answer: 'Not at all! Please make yourself comfortable.',
      alternativeReplies: [
        'You\'re very welcome to join us!',
        'Sure, take a seat.',
      ],
      malayalamNote: '\'Would you mind...\' എന്ന് ചോദിക്കുമ്പോൾ വിരോധമില്ലെങ്കിൽ \'Not at all\' (വിരോധമില്ല) എന്നാണ് ഉത്തരം പറയേണ്ടത്.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_next_steps',
      type: 'spoken_dialogue',
      tag: '💬 Brainstorming • Day 38',
      minLevel: 30,
      maxLevel: 75,
      gradientColors: [0xFF047857, 0xFF059669], // Forest Emerald
      question: 'What do you think we should focus on next?',
      answer: 'In my opinion, we should focus on spontaneous voice practice.',
      alternativeReplies: [
        'I suggest we review yesterday\'s collocations first.',
        'Let\'s do a 5-minute audio shadowing session.',
      ],
      malayalamNote: 'സ്വന്തം അഭിപ്രായം പങ്കുവെക്കാൻ \'In my opinion...\' അല്ലെങ്കിൽ \'I suggest we...\' എന്ന് ഉപയോഗിക്കുക.',
    ),

    // ==========================================
    // 🟣 TIER 3: LEVEL 50 TO 90 (ADVANCED PROFESSIONAL & DIPLOMATIC)
    // ==========================================
    PocketSpokenDialogueItem(
      id: 'dialogue_reschedule_meeting',
      type: 'spoken_dialogue',
      tag: '💬 Executive Scheduling • Day 55',
      minLevel: 45,
      maxLevel: 90,
      gradientColors: [0xFF0F172A, 0xFF1E3A8A], // Midnight Navy
      question: 'Could we possibly reschedule our discussion to tomorrow afternoon?',
      answer: 'Tomorrow afternoon works smoothly for me. What time suits you best?',
      alternativeReplies: [
        'Sure, let\'s connect around 3 PM.',
        'That fits my schedule perfectly.',
      ],
      malayalamNote: 'മീറ്റിംഗ് മാറ്റിവെക്കാൻ \'Could we possibly reschedule...\' എന്നും, സമയം ചോദിക്കാൻ \'What time suits you best?\' എന്നും ഉപയോഗിക്കാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_diplomatic_handling',
      type: 'spoken_dialogue',
      tag: '💬 Conflict Resolution • Day 65',
      minLevel: 50,
      maxLevel: 90,
      gradientColors: [0xFF312E81, 0xFF4338CA], // Diplomatic Indigo
      question: 'How do you handle a sensitive disagreement with a team member?',
      answer: 'I prioritize active listening and find common ground respectfully.',
      alternativeReplies: [
        'I remain calm, clarify viewpoints, and seek a collaborative solution.',
        'I focus strictly on facts and maintain professional courtesy.',
      ],
      malayalamNote: 'ഇന്റർവ്യൂവിലും ജോലിസ്ഥലത്തും തർക്കങ്ങൾ പരിഹരിക്കുന്നതിനെക്കുറിച്ച് ചോദിക്കുമ്പോൾ \'active listening\' ഉം \'common ground\' ഉം എടുത്തുപറയുക.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_collaborate_future',
      type: 'spoken_dialogue',
      tag: '💬 Partnership • Day 75',
      minLevel: 55,
      maxLevel: 90,
      gradientColors: [0xFF1E1B4B, 0xFF581C87], // Sovereign Velvet
      question: 'Looking forward to working together.',
      answer: 'Likewise! Great to team up.',
      alternativeReplies: [
        'The feeling is mutual!',
        'Glad to collaborate.',
      ],
      malayalamNote: '\'Looking forward to\' എന്നതിന് ശേഷം verb+ing വരണം. മറുപടിയായി \'Likewise!\' എന്ന് പറയാം.',
    ),

    PocketSpokenDialogueItem(
      id: 'dialogue_mastery_fluency',
      type: 'spoken_dialogue',
      tag: '🏆 Fluency Mastery • Day 90',
      minLevel: 70,
      maxLevel: 90,
      gradientColors: [0xFFB45309, 0xFFF59E0B], // Imperial Gold
      question: 'How do you think directly in English?',
      answer: 'Practice daily speaking without translating in mind!',
      alternativeReplies: [
        'Speak small phrases out loud every day.',
      ],
      malayalamNote: 'ഇംഗ്ലീഷിൽ നേരിട്ട് ചിന്തിക്കാൻ സ്ഥിരമായി സംസാരിക്കുകയും മനസ്സിനുള്ളിലെ തർജ്ജമ ഒഴിവാക്കുകയും ചെയ്യുക.',
    ),
  ];

  /// 🎯 Get items filtered by learner's current day/level
  static List<PocketSpokenDialogueItem> getItemsForLevel(int userLevel) {
    final effectiveLevel = userLevel.clamp(1, 90);

    // Filter matching level window
    final matched = allItems.where((item) {
      // Allow slight forward/backward range around user's current progress
      if (effectiveLevel <= 15) {
        return item.minLevel <= 20;
      } else if (effectiveLevel <= 45) {
        return item.minLevel <= 45 && item.maxLevel >= 10;
      } else {
        return item.minLevel >= 20 || item.maxLevel >= 55;
      }
    }).toList();

    return matched.isNotEmpty ? matched : allItems;
  }

  /// 🎲 Pick a random spoken dialogue or preposition rule for a given level
  static PocketSpokenDialogueItem getRandomItemForLevel(int userLevel, {math.Random? random}) {
    final rng = random ?? _random;
    final pool = getItemsForLevel(userLevel);
    return pool[rng.nextInt(pool.length)];
  }

  /// 📜 Retrieve all preposition rule cards
  static List<PocketSpokenDialogueItem> getPrepositionRules() {
    return allItems.where((item) => item.isPrepositionRule).toList();
  }

  /// 💬 Retrieve all spoken dialogue cards
  static List<PocketSpokenDialogueItem> getDialogues() {
    return allItems.where((item) => !item.isPrepositionRule).toList();
  }
}
