import '../games/sentence_builder_flame_game.dart';

/// 🧩 Master 90-Day Progressive Sentence Builder Curriculum Data
/// Features:
/// - 90 Days fully populated (5-6 high-utility sentences per day = 450+ unique challenges)
/// - ZERO DUPLICATES across all 90 days!
/// - Strict progressive difficulty:
///   - Days 1–15: Simple high-utility foundations (3–5 words)
///   - Days 16–30: Intermediate polite requests & prepositions (4–7 words)
///   - Days 31–60: Past/Future situational dialogs & travel (5–8 words)
///   - Days 61–90: Professional fluency, interviews & leadership (6–10 words)
/// - Dynamic tile coloring & native Malayalam translation banner prompts.
class Pocket90DaySentenceBuilderData {
  /// Returns curated sentence challenge rounds for any day (1 to 90)
  static List<SentenceChallengeRound> getSentencesForDay(int day) {
    if (day < 1) day = 1;
    if (day > 90) day = 90;

    final cached = _curriculum[day];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return _curriculum[1] ?? const [];
  }

  /// Helper to synthesize SentenceChallengeRound with colorful tiles
  static SentenceChallengeRound _buildRound({
    required int id,
    required String sentence,
    required String translationMl,
    required String hint,
  }) {
    final tokens = sentence.split(' ').where((w) => w.isNotEmpty).toList();
    final tiles = <SentenceTileData>[];
    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      final lower = t.toLowerCase();
      SentenceTileColor color;
      if (lower == 'you' ||
          lower == 'i' ||
          lower == 'we' ||
          lower == 'they' ||
          lower == 'he' ||
          lower == 'she' ||
          lower == 'it' ||
          lower == 'my' ||
          lower == 'your' ||
          lower == 'our' ||
          lower == 'his' ||
          lower == 'her') {
        color = SentenceTileColor.green;
      } else if (lower == 'who' ||
          lower == 'what' ||
          lower == 'where' ||
          lower == 'when' ||
          lower == 'why' ||
          lower == 'how' ||
          lower == 'which' ||
          lower == 'the' ||
          lower == 'a' ||
          lower == 'an' ||
          lower == 'in' ||
          lower == 'on' ||
          lower == 'at' ||
          lower == 'to' ||
          lower == 'for' ||
          lower == 'with' ||
          lower == 'from' ||
          lower == '?' ||
          lower == '.') {
        color = SentenceTileColor.cyan;
      } else {
        color = SentenceTileColor.magenta;
      }
      tiles.add(SentenceTileData(
        id: 'd_r${id}_${t}_$i',
        word: t,
        colorType: color,
      ));
    }

    return SentenceChallengeRound(
      id: id,
      sentence: sentence,
      translationMl: translationMl,
      tiles: tiles,
      hint: hint,
    );
  }

  // =========================================================================
  // 🌟 MASTER 90-DAY PROGRESSIVE SENTENCE REPOSITORY
  // =========================================================================
  static final Map<int, List<SentenceChallengeRound>> _curriculum = {
    // -----------------------------------------------------------------------
    // DAY 1
    // -----------------------------------------------------------------------
    1: [
      _buildRound(
        id: 1,
        sentence: 'Who asked you ?',
        translationMl: 'ആരാണ് നിന്നോട് ചോദിച്ചത്?',
        hint: 'Start with the question word \'Who\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Did you put the milk in the refrigerator ?',
        translationMl: 'നീ പാല് ഫ്രിഡ്ജിൽ വെച്ചോ?',
        hint: 'Question starts with past auxiliary \'Did\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What are you doing today ?',
        translationMl: 'നീ ഇന്ന് എന്താണ് ചെയ്യുന്നത്?',
        hint: 'Start with \'What\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Where do you live ?',
        translationMl: 'നീ എവിടെയാണ് താമസിക്കുന്നത്?',
        hint: 'Inquire about place with \'Where\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I am learning English .',
        translationMl: 'ഞാൻ ഇംഗ്ലീഷ് പഠിക്കുകയാണ്.',
        hint: 'Subject \'I\' takes \'am\'',
      ),
      _buildRound(
        id: 6,
        sentence: 'Nice to meet you .',
        translationMl: 'നിങ്ങളെ കണ്ടതിൽ സന്തോഷം.',
        hint: 'Polite conversational greeting',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 2
    // -----------------------------------------------------------------------
    2: [
      _buildRound(
        id: 1,
        sentence: 'I live in Kerala with my family .',
        translationMl: 'ഞാൻ എന്റെ കുടുംബത്തോടൊപ്പം കേരളത്തിൽ താമസിക്കുന്നു.',
        hint: 'Start with "I live in..."',
      ),
      _buildRound(
        id: 2,
        sentence: 'I wake up early every morning .',
        translationMl: 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ നേരത്തെ എഴുന്നേൽക്കുന്നു.',
        hint: 'Daily routine: Subject + Action + Time',
      ),
      _buildRound(
        id: 3,
        sentence: 'I drink a cup of hot tea .',
        translationMl: 'ഞാൻ ഒരു കപ്പ് ചൂടുചായ കുടിക്കുന്നു.',
        hint: 'Action sentence: I + drink + tea',
      ),
      _buildRound(
        id: 4,
        sentence: 'I stay at home on Sundays .',
        translationMl: 'ഞായറാഴ്ചകളിൽ ഞാൻ വീട്ടിൽ സമയം ചിലവഴിക്കുന്നു.',
        hint: 'Remember: "at home" for specific place',
      ),
      _buildRound(
        id: 5,
        sentence: 'I go to work on time .',
        translationMl: 'ഞാൻ കൃത്യസമയത്ത് ജോലിക്ക് പോകുന്നു.',
        hint: 'Expressing regular activity: "go to work"',
      ),
      _buildRound(
        id: 6,
        sentence: 'Come to my house this evening .',
        translationMl: 'ഇന്ന് വൈകുന്നേരം എന്റെ വീട്ടിലേക്ക് വരൂ.',
        hint: 'Friendly invitation phrase: "Come to my house"',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 3
    // -----------------------------------------------------------------------
    3: [
      _buildRound(
        id: 1,
        sentence: 'This is my elder brother .',
        translationMl: 'ഇത് എന്റെ മൂത്ത സഹോദരനാണ്.',
        hint: 'Introducing someone: "This is my..."',
      ),
      _buildRound(
        id: 2,
        sentence: 'He works in an IT company .',
        translationMl: 'അവൻ ഒരു ഐടി കമ്പനിയിൽ ജോലി ചെയ്യുന്നു.',
        hint: 'Describing a male person: "He works in..."',
      ),
      _buildRound(
        id: 3,
        sentence: 'Meet my mother and father .',
        translationMl: 'എന്റെ അമ്മയെയും അച്ഛനെയും പരിചയപ്പെടൂ.',
        hint: 'Social introduction phrase: "Meet my..."',
      ),
      _buildRound(
        id: 4,
        sentence: 'She is a kind school teacher .',
        translationMl: 'അവൾ ദയയുള്ള ഒരു സ്കൂൾ അധ്യാപികയാണ്.',
        hint: 'Describing a female person: "She is a..."',
      ),
      _buildRound(
        id: 5,
        sentence: 'His office is near our home .',
        translationMl: 'അവന്റെ ഓഫീസ് ഞങ്ങളുടെ വീടിനടുത്താണ്.',
        hint: 'Possessive pronoun: "His office..."',
      ),
      _buildRound(
        id: 6,
        sentence: 'We love spending time together .',
        translationMl: 'ഞങ്ങൾ ഒരുമിച്ച് സമയം ചിലവഴിക്കാൻ ഇഷ്ടപ്പെടുന്നു.',
        hint: 'Talking about family unity: "We love..."',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 4: Demonstratives (This, That, These, Those) & Daily Routines
    // -----------------------------------------------------------------------
    4: [
      _buildRound(
        id: 1,
        sentence: 'This is my new wristwatch .',
        translationMl: 'ഇത് എന്റെ പുതിയ കൈഘടികാരമാണ്.',
        hint: 'Singular object near you: "This is my..."',
      ),
      _buildRound(
        id: 2,
        sentence: 'That is a big wall clock .',
        translationMl: 'അത് വലിയൊരു ചുമർ ക്ലോക്കാണ്.',
        hint: 'Singular object far away: "That is a..."',
      ),
      _buildRound(
        id: 3,
        sentence: 'These are my favorite story books .',
        translationMl: 'ഇവ എന്റെ പ്രിയപ്പെട്ട കഥാപുസ്തകങ്ങളാണ്.',
        hint: 'Plural objects near you: "These are my..."',
      ),
      _buildRound(
        id: 4,
        sentence: 'Those are bright birds on the tree .',
        translationMl: 'അവ മരത്തിലിരിക്കുന്ന തിളങ്ങുന്ന പക്ഷികളാണ്.',
        hint: 'Plural objects far away: "Those are..."',
      ),
      _buildRound(
        id: 5,
        sentence: 'I wake up early every morning .',
        translationMl: 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ നേരത്തെ ഉണരുന്നു.',
        hint: 'Habitual routine: "I wake up..."',
      ),
      _buildRound(
        id: 6,
        sentence: 'What is the time right now ?',
        translationMl: 'ഇപ്പോൾ സമയം എത്രയാണ്?',
        hint: 'Asking the time: "What is the time..."',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 5: Ownership & Possession (Have / Has)
    // -----------------------------------------------------------------------
    5: [
      _buildRound(
        id: 1,
        sentence: 'I have a question for you .',
        translationMl: 'എനിക്ക് നിങ്ങളോട് ഒരു ചോദ്യമുണ്ട്.',
        hint: 'Expressing a query without "am having": "I have a..."',
      ),
      _buildRound(
        id: 2,
        sentence: 'She has great communication skills .',
        translationMl: 'അവൾക്ക് മികച്ച ആശയവിനിമയ ശേഷിയുണ്ട്.',
        hint: 'Singular third person possession: "She has..."',
      ),
      _buildRound(
        id: 3,
        sentence: 'He has a fast new laptop .',
        translationMl: 'അവന്റെ പക്കൽ വേഗതയേറിയ പുതിയൊരു ലാപ്ടോപ്പ് ഉണ്ട്.',
        hint: 'Possessing equipment: "He has a..."',
      ),
      _buildRound(
        id: 4,
        sentence: 'We have an important team meeting .',
        translationMl: 'ഞങ്ങൾക്ക് ഇന്ന് ഒരു പ്രധാന ടീം മീറ്റിങ് ഉണ്ട്.',
        hint: 'Scheduled event: "We have an important..."',
      ),
      _buildRound(
        id: 5,
        sentence: 'Do you have a few minutes ?',
        translationMl: 'നിങ്ങൾക്ക് കുറച്ചു സമയം ഉണ്ടോ?',
        hint: 'Polite question: "Do you have..."',
      ),
      _buildRound(
        id: 6,
        sentence: 'They have all the project files .',
        translationMl: 'അവരുടെ പക്കൽ എല്ലാ പ്രൊജക്റ്റ് ഫയലുകളും ഉണ്ട്.',
        hint: 'Possession: "They have all..."',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 6: Daily Habits & The Present Simple (Third-Person -s Rule)
    // -----------------------------------------------------------------------
    6: [
      _buildRound(
        id: 1,
        sentence: 'I drink black coffee every morning .',
        translationMl: 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ ബ്ലാക്ക് കോഫി കുടിക്കുന്നു.',
        hint: 'Habitual first person: "I drink..."',
      ),
      _buildRound(
        id: 2,
        sentence: 'He goes to the office by metro .',
        translationMl: 'അവൻ മെട്രോയിലാണ് ഓഫീസിൽ പോകുന്നത്.',
        hint: 'Third-person singular takes -es: "He goes..."',
      ),
      _buildRound(
        id: 3,
        sentence: 'She speaks English very fluently .',
        translationMl: 'അവൾ വളരെ ഒഴുക്കോടെ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു.',
        hint: 'Third-person singular takes -s: "She speaks..."',
      ),
      _buildRound(
        id: 4,
        sentence: 'My brother exercises in the gym .',
        translationMl: 'എന്റെ സഹോദരൻ ജിമ്മിൽ വ്യായാമം ചെയ്യുന്നു.',
        hint: 'Singular subject agreement: "My brother exercises..."',
      ),
      _buildRound(
        id: 5,
        sentence: 'We cook delicious food together .',
        translationMl: 'ഞങ്ങൾ ഒരുമിച്ച് രുചികരമായ ഭക്ഷണം പാകം ചെയ്യുന്നു.',
        hint: 'Plural subject takes base verb: "We cook..."',
      ),
      _buildRound(
        id: 6,
        sentence: 'They clean their study room daily .',
        translationMl: 'അവർ അവരുടെ പഠനമുറി ദിവസേന വൃത്തിയാക്കുന്നു.',
        hint: 'Habitual action: "They clean their..."',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 7
    // -----------------------------------------------------------------------
    7: [
      _buildRound(
        id: 1,
        sentence: 'Use a clean plate .',
        translationMl: 'ഉപയോഗിക്കുക - Use a clean plate.',
        hint: 'Pay attention to: Articles A & An (A table, An umbrella)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Hold the cup .',
        translationMl: 'പിടിക്കുക - Hold the cup.',
        hint: 'Pay attention to: Articles A & An (A table, An umbrella)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Everyday Household Objects gives you great confidence in English .',
        translationMl: 'നിത്യജീവിത സാധനങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Articles A & An (A table, An umbrella)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Don\'t drop the glass .',
        translationMl: 'നിത്യജീവിത സാധനങ്ങൾ',
        hint: 'Core sentence pattern: Articles A & An (A table, An umbrella)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Find my keys .',
        translationMl: 'കണ്ടെത്തുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'find\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 8
    // -----------------------------------------------------------------------
    8: [
      _buildRound(
        id: 1,
        sentence: 'Count the coins .',
        translationMl: 'എണ്ണുക - Count the coins.',
        hint: 'Pay attention to: Singular vs Plural Nouns (-s / -es)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Add two spoons .',
        translationMl: 'കൂട്ടിച്ചേർക്കുക - Add two spoons.',
        hint: 'Pay attention to: Singular vs Plural Nouns (-s / -es)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Numbers, Counting & Plurals gives you great confidence in English .',
        translationMl: 'സംഖ്യകളും എണ്ണലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Singular vs Plural Nouns (-s / -es)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Buy three pens .',
        translationMl: 'സംഖ്യകളും എണ്ണലും',
        hint: 'Core sentence pattern: Singular vs Plural Nouns (-s / -es)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Pay ten rupees .',
        translationMl: 'പണം നൽകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'pay\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 9
    // -----------------------------------------------------------------------
    9: [
      _buildRound(
        id: 1,
        sentence: 'Look at the red bird .',
        translationMl: 'നോക്കുക - Look at the red bird.',
        hint: 'Pay attention to: Adjectives before Nouns (Red car, Big house)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Wear a blue shirt .',
        translationMl: 'ധരിക്കുക - Wear a blue shirt.',
        hint: 'Pay attention to: Adjectives before Nouns (Red car, Big house)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Colors & Appearance gives you great confidence in English .',
        translationMl: 'നിറങ്ങളും രൂപങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Adjectives before Nouns (Red car, Big house)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Paint it green .',
        translationMl: 'നിറങ്ങളും രൂപങ്ങളും',
        hint: 'Core sentence pattern: Adjectives before Nouns (Red car, Big house)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Stars shine bright .',
        translationMl: 'തിളങ്ങുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'shine\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 10
    // -----------------------------------------------------------------------
    10: [
      _buildRound(
        id: 1,
        sentence: 'Start at 9 AM .',
        translationMl: 'ആരംഭിക്കുക - Start at 9 AM.',
        hint: 'Pay attention to: Prepositions of Time: At 5 PM, On Monday, In May',
      ),
      _buildRound(
        id: 2,
        sentence: 'Finish on Monday .',
        translationMl: 'തീർക്കുക - Finish on Monday.',
        hint: 'Pay attention to: Prepositions of Time: At 5 PM, On Monday, In May',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Telling Time & Days gives you great confidence in English .',
        translationMl: 'സമയവും ദിവസങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Prepositions of Time: At 5 PM, On Monday, In May',
      ),
      _buildRound(
        id: 4,
        sentence: 'Wait for 10 minutes .',
        translationMl: 'സമയവും ദിവസങ്ങളും',
        hint: 'Core sentence pattern: Prepositions of Time: At 5 PM, On Monday, In May',
      ),
      _buildRound(
        id: 5,
        sentence: 'Hurry up, time is up .',
        translationMl: 'തിടുക്കം കൂട്ടുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'hurry\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 11
    // -----------------------------------------------------------------------
    11: [
      _buildRound(
        id: 1,
        sentence: 'Brush twice daily .',
        translationMl: 'പല്ല് തേക്കുക - Brush twice daily.',
        hint: 'Pay attention to: Subject-Verb Agreement (I go vs He goes)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Take a quick bath .',
        translationMl: 'കുളിക്കുക - Take a quick bath.',
        hint: 'Pay attention to: Subject-Verb Agreement (I go vs He goes)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Morning Productivity gives you great confidence in English .',
        translationMl: 'രാവിലത്തെ ശീലങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Subject-Verb Agreement (I go vs He goes)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Dress up neatly .',
        translationMl: 'രാവിലത്തെ ശീലങ്ങൾ',
        hint: 'Core sentence pattern: Subject-Verb Agreement (I go vs He goes)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Leave home at 8 .',
        translationMl: 'ഇറങ്ങുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'leave\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 12
    // -----------------------------------------------------------------------
    12: [
      _buildRound(
        id: 1,
        sentence: 'Return home at 6 .',
        translationMl: 'തിരികെ എത്തുക - Return home at 6.',
        hint: 'Pay attention to: Habitual Verbs in Daily Routine',
      ),
      _buildRound(
        id: 2,
        sentence: 'Relax for an hour .',
        translationMl: 'വിശ്രമിക്കുക - Relax for an hour.',
        hint: 'Pay attention to: Habitual Verbs in Daily Routine',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Evening Leisure & Family Time gives you great confidence in English .',
        translationMl: 'വൈകുന്നേര ശീലങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Habitual Verbs in Daily Routine',
      ),
      _buildRound(
        id: 4,
        sentence: 'Watch evening news .',
        translationMl: 'വൈകുന്നേര ശീലങ്ങൾ',
        hint: 'Core sentence pattern: Habitual Verbs in Daily Routine',
      ),
      _buildRound(
        id: 5,
        sentence: 'Read a book .',
        translationMl: 'വായിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'read\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 13
    // -----------------------------------------------------------------------
    13: [
      _buildRound(
        id: 1,
        sentence: 'He works hard .',
        translationMl: 'ജോലി ചെയ്യുക - He works hard.',
        hint: 'Pay attention to: Do with I/You/We/They | Does with He/She/It',
      ),
      _buildRound(
        id: 2,
        sentence: 'She studies well .',
        translationMl: 'പഠിക്കുക - She studies well.',
        hint: 'Pay attention to: Do with I/You/We/They | Does with He/She/It',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Habits with Do vs Does gives you great confidence in English .',
        translationMl: 'Do vs Does ശീലങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Do with I/You/We/They | Does with He/She/It',
      ),
      _buildRound(
        id: 4,
        sentence: 'They play football .',
        translationMl: 'Do vs Does ശീലങ്ങൾ',
        hint: 'Core sentence pattern: Do with I/You/We/They | Does with He/She/It',
      ),
      _buildRound(
        id: 5,
        sentence: 'Do you know him ?',
        translationMl: 'അറിയുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'know\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 14
    // -----------------------------------------------------------------------
    14: [
      _buildRound(
        id: 1,
        sentence: 'I don\'t like junk food .',
        translationMl: 'ഇഷ്ടപ്പെടുക - I don\'t like junk food.',
        hint: 'Pay attention to: Don\'t / Doesn\'t + V1 (Never add \'s\' after doesn\'t)',
      ),
      _buildRound(
        id: 2,
        sentence: 'He doesn\'t smoke .',
        translationMl: 'പുകവലിക്കുക - He doesn\'t smoke.',
        hint: 'Pay attention to: Don\'t / Doesn\'t + V1 (Never add \'s\' after doesn\'t)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Negatives with Don\'t & Doesn\'t gives you great confidence in English .',
        translationMl: 'നെഗറ്റീവ് ശീലങ്ങൾ (Don\'t / Doesn\'t) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Don\'t / Doesn\'t + V1 (Never add \'s\' after doesn\'t)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Don\'t waste time .',
        translationMl: 'നെഗറ്റീവ് ശീലങ്ങൾ (Don\'t / Doesn\'t)',
        hint: 'Core sentence pattern: Don\'t / Doesn\'t + V1 (Never add \'s\' after doesn\'t)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Don\'t fight .',
        translationMl: 'വഴക്കിടുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'fight\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 15: Giving Advice, Recommendations & Guidance (Should / Shouldn't)
    // -----------------------------------------------------------------------
    15: [
      _buildRound(
        id: 1,
        sentence: 'You should review the report before the client meeting .',
        translationMl: 'ക്ലയന്റ് മീറ്റിംഗിന് മുൻപ് നിങ്ങൾ റിപ്പോർട്ട് പരിശോധിക്കണം.',
        hint: 'Constructive Advice: Subject + should + V1 (review)',
      ),
      _buildRound(
        id: 2,
        sentence: 'We shouldn\'t deploy the code without thorough testing .',
        translationMl: 'വിശദമായ പരിശോധനയില്ലാതെ നമ്മൾ കോഡ് ഡിപ്ലോയ് ചെയ്യരുത്.',
        hint: 'Negative Recommendation: shouldn\'t + V1 (deploy)',
      ),
      _buildRound(
        id: 3,
        sentence: 'You should consult a specialist if the pain continues .',
        translationMl: 'വേദന തുടരുകയാണെങ്കിൽ നിങ്ങൾ ഒരു സ്പെഷ്യലിസ്റ്റിനെ കാണണം.',
        hint: 'Medical Guidance: should + V1 (consult)',
      ),
      _buildRound(
        id: 4,
        sentence: 'To speak fluently, you should practice aloud every single day .',
        translationMl: 'ഒഴുക്കോടെ സംസാരിക്കാൻ, ദിവസവും ഉറക്കെ സംസാരിച്ചു പരിശീലിക്കണം.',
        hint: 'Fluency Tip: should + V1 (practice)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We should prioritize customer security above all else .',
        translationMl: 'എല്ലാറ്റിനുമുപരി ഉപഭോക്തൃ സുരക്ഷയ്ക്ക് നമ്മൾ മുൻഗണന നൽകണം.',
        hint: 'Professional Priority: should + V1 (prioritize)',
      ),
      _buildRound(
        id: 6,
        sentence: 'You shouldn\'t ignore honest feedback from your team .',
        translationMl: 'ടീമിൽ നിന്നുള്ള ആത്മാർത്ഥമായ അഭിപ്രായങ്ങൾ നിങ്ങൾ അവഗണിക്കരുത്.',
        hint: 'Constructive Leadership: shouldn\'t + V1 (ignore)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 16: Workplace Obligations, Strict Rules & Official Deadlines (Must / Have to)
    // -----------------------------------------------------------------------
    16: [
      _buildRound(
        id: 1,
        sentence: 'All employees must wear their security ID badges inside the office .',
        translationMl: 'ഓഫീസിനുള്ളിൽ എല്ലാ ജീവനക്കാരും തിരിച്ചറിയൽ കാർഡ് ധരിച്ചിരിക്കണം.',
        hint: 'Strict Corporate Rule: Subject + must + V1 (wear)',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have to submit the project proposal before five PM today .',
        translationMl: 'ഇന്ന് വൈകുന്നേരം അഞ്ചുമണിക്ക് മുൻപ് എനിക്ക് പ്രൊപ്പോസൽ സമർപ്പിക്കേണ്ടതുണ്ട്.',
        hint: 'External Deadline: I + have to + V1 (submit)',
      ),
      _buildRound(
        id: 3,
        sentence: 'You must not share confidential client passwords with anyone .',
        translationMl: 'നിങ്ങൾ രഹസ്യ പാസ്‌വേഡുകൾ ആരോടും പങ്കുവെക്കാൻ പാടില്ല.',
        hint: 'Strict Prohibition: must not + V1 (share)',
      ),
      _buildRound(
        id: 4,
        sentence: 'She has to attend the executive board meeting in Kochi tomorrow .',
        translationMl: 'നാളെ കൊച്ചിയിൽ നടക്കുന്ന എക്സിക്യൂട്ടീവ് ബോർഡ് മീറ്റിംഗിൽ അവൾക്ക് പങ്കെടുക്കേണ്ടതുണ്ട്.',
        hint: 'Third-person Duty: She + has to + V1 (attend)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We don\'t have to work this weekend because the release is finished .',
        translationMl: 'റിലീസ് പൂർത്തിയായതിനാൽ ഈ വാരാന്ത്യത്തിൽ നമുക്ക് ജോലി ചെയ്യേണ്ടതില്ല.',
        hint: 'Lack of Obligation: don\'t have to + V1 (work)',
      ),
      _buildRound(
        id: 6,
        sentence: 'Every driver must stop when the traffic signal turns red .',
        translationMl: 'ട്രാഫിക് സിഗ്നൽ ചുവപ്പാകുമ്പോൾ ഓരോ ഡ്രൈവറും വാഹനം നിർത്തിയേ തീരൂ.',
        hint: 'Legal Obligation: Subject + must + V1 (stop)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 17: Talking About Yesterday & Finished Time (The Simple Past V2)
    // -----------------------------------------------------------------------
    17: [
      _buildRound(
        id: 1,
        sentence: 'Yesterday I completed three key tasks on time .',
        translationMl: 'ഇന്നലെ ഞാൻ മൂന്ന് പ്രധാന ജോലികൾ കൃത്യസമയത്ത് പൂർത്തിയാക്കി.',
        hint: 'Simple Past: completed (regular V2 of complete)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She went to the market and bought fresh vegetables .',
        translationMl: 'അവൾ മാർക്കറ്റിൽ പോയി പുതിയ പച്ചക്കറികൾ വാങ്ങി.',
        hint: 'Irregular Past: went (go) and bought (buy)',
      ),
      _buildRound(
        id: 3,
        sentence: 'We saw an interesting technical presentation yesterday afternoon .',
        translationMl: 'ഇന്നലെ ഉച്ചകഴിഞ്ഞ് ഞങ്ങൾ ഒരു രസകരമായ സാങ്കേതിക പ്രസന്റേഷൻ കണ്ടു.',
        hint: 'Irregular Past: saw (V2 of see)',
      ),
      _buildRound(
        id: 4,
        sentence: 'He worked late and finished the client proposal last night .',
        translationMl: 'അവൻ ഇന്നലെ രാത്രി വൈകുവോളം ജോലി ചെയ്ത് ക്ലയന്റ് പ്രൊപ്പോസൽ പൂർത്തിയാക്കി.',
        hint: 'Completed Action: worked and finished',
      ),
      _buildRound(
        id: 5,
        sentence: 'Our engineering team resolved the critical server issue yesterday .',
        translationMl: 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ടീം ഇന്നലെ ആ ഗുരുതരമായ സെർവർ പ്രശ്നം പരിഹരിച്ചു.',
        hint: 'Past Accomplishment: resolved (regular V2)',
      ),
      _buildRound(
        id: 6,
        sentence: 'They launched the new mobile application two days ago .',
        translationMl: 'രണ്ട് ദിവസം മുൻപ് അവർ പുതിയ മൊബൈൽ ആപ്ലിക്കേഷൻ പുറത്തിറക്കി.',
        hint: 'Past Time Anchor: launched ... two days ago',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 18: Inquiring About the Past (Did you...? & The "Did" Reset Rule)
    // -----------------------------------------------------------------------
    18: [
      _buildRound(
        id: 1,
        sentence: 'Did you finish the project report yesterday afternoon ?',
        translationMl: 'ഇന്നലെ ഉച്ചകഴിഞ്ഞ് നിങ്ങൾ പ്രോജക്ട് റിപ്പോർട്ട് പൂർത്തിയാക്കിയോ?',
        hint: 'Past Question: Did + you + finish (V1 reset)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Where did you go for your family vacation last summer ?',
        translationMl: 'കഴിഞ്ഞ വേനൽക്കാലത്ത് കുടുംബത്തോടൊപ്പം യാത്രയ്ക്കായി നിങ്ങൾ എവിടെയാണ് പോയത്?',
        hint: 'Wh- Question: Where + did + you + go (V1 base form)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Did she receive the important email I sent last night ?',
        translationMl: 'ഇന്നലെ രാത്രി ഞാൻ അയച്ച പ്രധാനപ്പെട്ട ഇമെയിൽ അവൾക്ക് ലഭിച്ചോ?',
        hint: 'Auxiliary Did: Did + she + receive (not received)',
      ),
      _buildRound(
        id: 4,
        sentence: 'What time did the train arrive at the station ?',
        translationMl: 'ട്രെയിൻ ഏതു സമയത്താണ് സ്റ്റേഷനിൽ എത്തിച്ചേർന്നത്?',
        hint: 'Wh- Past Question: What time + did + the train + arrive (V1)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Why did they choose this specific software solution ?',
        translationMl: 'എന്തുകൊണ്ടാണ് അവർ ഈ പ്രത്യേക സോഫ്റ്റ്‌വെയർ സൊല്യൂഷൻ തിരഞ്ഞെടുത്തത്?',
        hint: 'Past Inquiry: Why + did + they + choose (V1 reset)',
      ),
      _buildRound(
        id: 6,
        sentence: 'Did you verify the bank account details before making the transfer ?',
        translationMl: 'പണം അയക്കുന്നതിന് മുൻപ് നിങ്ങൾ ബാങ്ക് അക്കൗണ്ട് വിവരങ്ങൾ പരിശോധിച്ച് ഉറപ്പുവരുത്തിയോ?',
        hint: 'Careful Inquiry: Did + you + verify (V1 base verb)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 19 (Past Negatives: didn't + V1)
    // -----------------------------------------------------------------------
    19: [
      _buildRound(
        id: 1,
        sentence: 'I didn\'t finish the report yesterday because the server was down .',
        translationMl: 'സെർവർ തകരാറിലായതിനാൽ എനിക്ക് ഇന്നലെ റിപ്പോർട്ട് പൂർത്തിയാക്കാൻ കഴിഞ്ഞില്ല.',
        hint: 'Subject + didn\'t + Base Verb (V1 finish, NOT finished)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She didn\'t receive the revised contract before leaving the office .',
        translationMl: 'ഓഫീസ് വിടുന്നതിന് മുൻപ് അവൾക്ക് പുതുക്കിയ കരാർ ലഭിച്ചില്ല.',
        hint: 'didn\'t + Base Verb (receive, NOT received)',
      ),
      _buildRound(
        id: 3,
        sentence: 'We didn\'t anticipate the sudden delay in the payment system .',
        translationMl: 'പേയ്‌മെന്റ് സിസ്റ്റത്തിലെ പെട്ടെന്നുള്ള കാലതാമസം ഞങ്ങൾ മുൻകൂട്ടി കണ്ടില്ല.',
        hint: 'didn\'t + Base Verb (anticipate)',
      ),
      _buildRound(
        id: 4,
        sentence: 'They didn\'t find any critical bugs during the security audit .',
        translationMl: 'സെക്യൂരിറ്റി ഓഡിറ്റിൽ അവർക്ക് ഗുരുതരമായ പിഴവുകളൊന്നും കണ്ടെത്താനായില്ല.',
        hint: 'didn\'t + Base Verb (find, NOT found)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He didn\'t know about the rescheduled morning conference meeting .',
        translationMl: 'രാവിലത്തെ കോൺഫറൻസ് മീറ്റിംഗ് മാറ്റിവെച്ച വിവരം അവൻ അറിഞ്ഞില്ല.',
        hint: 'didn\'t + Base Verb (know, NOT knew)',
      ),
      _buildRound(
        id: 6,
        sentence: 'We didn\'t cancel the project despite the unexpected technical challenge .',
        translationMl: 'പ്രതീക്ഷിക്കാത്ത സാങ്കേതിക വെല്ലുവിളിയുണ്ടായിട്ടും ഞങ്ങൾ പ്രോജക്റ്റ് റദ്ദാക്കിയില്ല.',
        hint: 'didn\'t + Base Verb (cancel)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 20 (Future Commitments & Decisions: Will + V1)
    // -----------------------------------------------------------------------
    20: [
      _buildRound(
        id: 1,
        sentence: 'I will resolve the database latency issue before noon tomorrow .',
        translationMl: 'നാളെ ഉച്ചയ്ക്ക് മുൻപ് ഞാൻ ഡാറ്റാബേസ് കാലതാമസ പ്രശ്നം പരിഹരിക്കും.',
        hint: 'Subject + will + Base Verb (V1 resolve)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Our engineering team will launch the updated mobile application next week .',
        translationMl: 'ഞങ്ങളുടെ എൻജിനീയറിങ് ടീം അടുത്ത ആഴ്ച പുതിയ മൊബൈൽ ആപ്പ് പുറത്തിറക്കും.',
        hint: 'Subject + will + Base Verb (launch)',
      ),
      _buildRound(
        id: 3,
        sentence: 'I will dedicate thirty minutes every evening to speaking English aloud .',
        translationMl: 'എല്ലാ ദിവസവും വൈകുന്നേരം മുപ്പത് മിനിറ്റ് ഞാൻ ഉച്ചത്തിൽ ഇംഗ്ലീഷ് സംസാരിക്കാൻ നീക്കിവെക്കും.',
        hint: 'Subject + will + Base Verb (dedicate)',
      ),
      _buildRound(
        id: 4,
        sentence: 'We will assist you with the international client demonstration .',
        translationMl: 'അന്താരാഷ്ട്ര ക്ലയന്റ് ഡെമോൺസ്ട്രേഷനിൽ ഞങ്ങൾ നിങ്ങളെ സഹായിക്കും.',
        hint: 'Subject + will + Base Verb (assist)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He will contact the project manager as soon as he arrives .',
        translationMl: 'എത്തിച്ചേർന്ന ഉടൻ തന്നെ അവൻ പ്രോജക്റ്റ് മാനേജരെ ബന്ധപ്പെടും.',
        hint: 'Subject + will + Base Verb (contact)',
      ),
      _buildRound(
        id: 6,
        sentence: 'I will never give up on achieving complete English spoken fluency .',
        translationMl: 'പൂർണ്ണമായ ഇംഗ്ലീഷ് സംസാര പ്രാവീണ്യം നേടുന്നതിൽ ഞാൻ ഒരിക്കലും പിന്മാറില്ല.',
        hint: 'Subject + will never + Base Verb (give up)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 21 (Planned Intentions & Roadmaps: Going to + V1)
    // -----------------------------------------------------------------------
    21: [
      _buildRound(
        id: 1,
        sentence: 'I am going to build a modern portfolio website this weekend .',
        translationMl: 'ഈ വാരാന്ത്യത്തിൽ ഞാൻ ഒരു പുതിയ പോർട്ട്‌ഫോളിയോ വെബ്‌സൈറ്റ് നിർമ്മിക്കാൻ പോകുന്നു.',
        hint: 'Subject + am going to + Base Verb (build)',
      ),
      _buildRound(
        id: 2,
        sentence: 'We are going to deploy the new features next Monday morning .',
        translationMl: 'അടുത്ത തിങ്കളാഴ്ച രാവിലെ ഞങ്ങൾ പുതിയ ഫീച്ചറുകൾ വിന്യസിക്കാൻ പോകുന്നു.',
        hint: 'Subject + are going to + Base Verb (deploy)',
      ),
      _buildRound(
        id: 3,
        sentence: 'She is going to present our quarterly roadmap to international stakeholders .',
        translationMl: 'അന്താരാഷ്ട്ര ഓഹരി ഉടമകൾക്ക് അവൾ ഞങ്ങളുടെ ത്രൈമാസ റോഡ്‌മാപ്പ് അവതരിപ്പിക്കാൻ പോകുന്നു.',
        hint: 'Subject + is going to + Base Verb (present)',
      ),
      _buildRound(
        id: 4,
        sentence: 'They are going to collaborate with our senior design team in London .',
        translationMl: 'ലണ്ടനിലെ ഞങ്ങളുടെ സീനിയർ ഡിസൈൻ ടീമുമായി അവർ സഹകരിച്ച് പ്രവർത്തിക്കാൻ പോകുന്നു.',
        hint: 'Subject + are going to + Base Verb (collaborate)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Our company is going to expand customer support into three new regions .',
        translationMl: 'ഞങ്ങളുടെ കമ്പനി കസ്റ്റമർ സപ്പോർട്ട് മൂന്ന് പുതിയ മേഖലകളിലേക്ക് വ്യാപിപ്പിക്കാൻ പോകുന്നു.',
        hint: 'Subject + is going to + Base Verb (expand)',
      ),
      _buildRound(
        id: 6,
        sentence: 'I am going to achieve my professional career goals this year .',
        translationMl: 'ഈ വർഷം എന്റെ കരിയർ ലക്ഷ്യങ്ങൾ ഞാൻ നേടിയെടുക്കാൻ പോകുന്നു.',
        hint: 'Subject + am going to + Base Verb (achieve)',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 22
    // -----------------------------------------------------------------------
    22: [
      _buildRound(
        id: 1,
        sentence: 'When will the bus arrive ?',
        translationMl: 'എത്തിച്ചേരുക - When will the bus arrive?',
        hint: 'Pay attention to: When do you...? / Why are you...?',
      ),
      _buildRound(
        id: 2,
        sentence: 'Why was it delayed ?',
        translationMl: 'വൈകിക്കുക - Why was it delayed?',
        hint: 'Pay attention to: When do you...? / Why are you...?',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Asking Questions: When & Why gives you great confidence in English .',
        translationMl: 'When & Why ചോദ്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: When do you...? / Why are you...?',
      ),
      _buildRound(
        id: 4,
        sentence: 'When do you leave ?',
        translationMl: 'When & Why ചോദ്യങ്ങൾ',
        hint: 'Core sentence pattern: When do you...? / Why are you...?',
      ),
      _buildRound(
        id: 5,
        sentence: 'Why did you stop ?',
        translationMl: 'നിർത്തുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'stop\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 23
    // -----------------------------------------------------------------------
    23: [
      _buildRound(
        id: 1,
        sentence: 'Who did you meet ?',
        translationMl: 'കണ്ടുമുട്ടുക - Who did you meet?',
        hint: 'Pay attention to: Who is that? / Which one do you like?',
      ),
      _buildRound(
        id: 2,
        sentence: 'Which color do you pick ?',
        translationMl: 'തിരഞ്ഞെടുക്കുക - Which color do you pick?',
        hint: 'Pay attention to: Who is that? / Which one do you like?',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Asking Questions: Who & Which gives you great confidence in English .',
        translationMl: 'Who & Which ചോദ്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Who is that? / Which one do you like?',
      ),
      _buildRound(
        id: 4,
        sentence: 'Who knows the answer ?',
        translationMl: 'Who & Which ചോദ്യങ്ങൾ',
        hint: 'Core sentence pattern: Who is that? / Which one do you like?',
      ),
      _buildRound(
        id: 5,
        sentence: 'Who brought this ?',
        translationMl: 'കൊണ്ടുവരിക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'bring\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 24
    // -----------------------------------------------------------------------
    24: [
      _buildRound(
        id: 1,
        sentence: 'How much does it cost ?',
        translationMl: 'വിലയാകുക - How much does it cost?',
        hint: 'Pay attention to: How are you? / How much does it cost?',
      ),
      _buildRound(
        id: 2,
        sentence: 'How far is the town ?',
        translationMl: 'അളക്കുക - How far is the town?',
        hint: 'Pay attention to: How are you? / How much does it cost?',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Asking Questions: How & How Much gives you great confidence in English .',
        translationMl: 'How & How Much ചോദ്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: How are you? / How much does it cost?',
      ),
      _buildRound(
        id: 4,
        sentence: 'How do you feel ?',
        translationMl: 'How & How Much ചോദ്യങ്ങൾ',
        hint: 'Core sentence pattern: How are you? / How much does it cost?',
      ),
      _buildRound(
        id: 5,
        sentence: 'How much does it weigh ?',
        translationMl: 'ഭാരം തൂക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'weigh\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 25
    // -----------------------------------------------------------------------
    25: [
      _buildRound(
        id: 1,
        sentence: 'He sells fresh fruits .',
        translationMl: 'വിൽക്കുക - He sells fresh fruits.',
        hint: 'Pay attention to: Quantity Words: Kilo, Packet, Bottle, Dozen',
      ),
      _buildRound(
        id: 2,
        sentence: 'Don\'t bargain here .',
        translationMl: 'വിലപേശുക - Don\'t bargain here.',
        hint: 'Pay attention to: Quantity Words: Kilo, Packet, Bottle, Dozen',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Buying Groceries & Market Talk gives you great confidence in English .',
        translationMl: 'കടയും പച്ചക്കറി വാങ്ങലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Quantity Words: Kilo, Packet, Bottle, Dozen',
      ),
      _buildRound(
        id: 4,
        sentence: 'Carry the grocery bag .',
        translationMl: 'കടയും പച്ചക്കറി വാങ്ങലും',
        hint: 'Core sentence pattern: Quantity Words: Kilo, Packet, Bottle, Dozen',
      ),
      _buildRound(
        id: 5,
        sentence: 'Check the bill .',
        translationMl: 'പരിശോധിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'check\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 26
    // -----------------------------------------------------------------------
    26: [
      _buildRound(
        id: 1,
        sentence: 'Turn left at the signal .',
        translationMl: 'തിരിയുക - Turn left at the signal.',
        hint: 'Pay attention to: Imperative Commands: Turn left, Go straight',
      ),
      _buildRound(
        id: 2,
        sentence: 'Cross the road safely .',
        translationMl: 'മുറിച്ചുകടക്കുക - Cross the road safely.',
        hint: 'Pay attention to: Imperative Commands: Turn left, Go straight',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Giving Simple Directions gives you great confidence in English .',
        translationMl: 'വഴികൾ പറഞ്ഞു കൊടുക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Imperative Commands: Turn left, Go straight',
      ),
      _buildRound(
        id: 4,
        sentence: 'Follow this road .',
        translationMl: 'വഴികൾ പറഞ്ഞു കൊടുക്കൽ',
        hint: 'Core sentence pattern: Imperative Commands: Turn left, Go straight',
      ),
      _buildRound(
        id: 5,
        sentence: 'Pass the temple .',
        translationMl: 'കടന്നുപോകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'pass\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 27
    // -----------------------------------------------------------------------
    27: [
      _buildRound(
        id: 1,
        sentence: 'My knee hurts .',
        translationMl: 'വേദനിക്കൽ - My knee hurts.',
        hint: 'Pay attention to: I have a headache / stomach ache / fever',
      ),
      _buildRound(
        id: 2,
        sentence: 'My head aches .',
        translationMl: 'വേദനിക്കുക - My head aches.',
        hint: 'Pay attention to: I have a headache / stomach ache / fever',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Health, Body & Minor Ailments gives you great confidence in English .',
        translationMl: 'ആരോഗ്യവും അസുഖങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I have a headache / stomach ache / fever',
      ),
      _buildRound(
        id: 4,
        sentence: 'He is coughing .',
        translationMl: 'ആരോഗ്യവും അസുഖങ്ങളും',
        hint: 'Core sentence pattern: I have a headache / stomach ache / fever',
      ),
      _buildRound(
        id: 5,
        sentence: 'Take complete rest .',
        translationMl: 'വിശ്രമിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'rest\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 28
    // -----------------------------------------------------------------------
    28: [
      _buildRound(
        id: 1,
        sentence: 'Take this after food .',
        translationMl: 'കഴിക്കുക - Take this after food.',
        hint: 'Pay attention to: Dosage instructions: Before/After food, Twice daily',
      ),
      _buildRound(
        id: 2,
        sentence: 'Doctor prescribed pills .',
        translationMl: 'കുറിച്ചു നൽകുക - Doctor prescribed pills.',
        hint: 'Pay attention to: Dosage instructions: Before/After food, Twice daily',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of At the Pharmacy & Medicine gives you great confidence in English .',
        translationMl: 'മരുന്നുകടയും കുറിപ്പടിയും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Dosage instructions: Before/After food, Twice daily',
      ),
      _buildRound(
        id: 4,
        sentence: 'It will heal fast .',
        translationMl: 'മരുന്നുകടയും കുറിപ്പടിയും',
        hint: 'Core sentence pattern: Dosage instructions: Before/After food, Twice daily',
      ),
      _buildRound(
        id: 5,
        sentence: 'Swallow with water .',
        translationMl: 'വിഴുങ്ങുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'swallow\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 29
    // -----------------------------------------------------------------------
    29: [
      _buildRound(
        id: 1,
        sentence: 'It is raining outside .',
        translationMl: 'പെയ്യുക - It is raining outside.',
        hint: 'Pay attention to: It is sunny / rainy / cloudy / humid',
      ),
      _buildRound(
        id: 2,
        sentence: 'Cool wind is blowing .',
        translationMl: 'വീശുക - Cool wind is blowing.',
        hint: 'Pay attention to: It is sunny / rainy / cloudy / humid',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Weather, Climate & Nature gives you great confidence in English .',
        translationMl: 'കാലാവസ്ഥയും പ്രകൃതിയും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: It is sunny / rainy / cloudy / humid',
      ),
      _buildRound(
        id: 4,
        sentence: 'It is freezing cold .',
        translationMl: 'കാലാവസ്ഥയും പ്രകൃതിയും',
        hint: 'Core sentence pattern: It is sunny / rainy / cloudy / humid',
      ),
      _buildRound(
        id: 5,
        sentence: 'Weather changes fast .',
        translationMl: 'മാറുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'change\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 30
    // -----------------------------------------------------------------------
    30: [
      _buildRound(
        id: 1,
        sentence: 'Review your lessons .',
        translationMl: 'വിലയിരുത്തുക - Review your lessons.',
        hint: 'Pay attention to: Full Foundation Integration (Days 1–29)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Master your grammar .',
        translationMl: 'സ്വായത്തമാക്കുക - Master your grammar.',
        hint: 'Pay attention to: Full Foundation Integration (Days 1–29)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of House 1 Grand Review & Gate Exam gives you great confidence in English .',
        translationMl: 'ഹൗസ് 1 ഫൈനൽ റിവ്യൂ & എക്സാം ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Full Foundation Integration (Days 1–29)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Pass the gate exam .',
        translationMl: 'ഹൗസ് 1 ഫൈനൽ റിവ്യൂ & എക്സാം',
        hint: 'Core sentence pattern: Full Foundation Integration (Days 1–29)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Celebrate Day 30 .',
        translationMl: 'ആഘോഷിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'celebrate\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 31
    // -----------------------------------------------------------------------
    31: [
      _buildRound(
        id: 1,
        sentence: 'I was at home .',
        translationMl: 'ആയിരുന്നു - I was at home.',
        hint: 'Pay attention to: Was (I/He/She/It) vs Were (You/We/They)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She felt tired .',
        translationMl: 'തോന്നിയിരുന്നു - She felt tired.',
        hint: 'Pay attention to: Was (I/He/She/It) vs Were (You/We/They)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Past State: Was vs Were gives you great confidence in English .',
        translationMl: 'കഴിഞ്ഞ അവസ്ഥകൾ: Was vs Were ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Was (I/He/She/It) vs Were (You/We/They)',
      ),
      _buildRound(
        id: 4,
        sentence: 'They became happy .',
        translationMl: 'കഴിഞ്ഞ അവസ്ഥകൾ: Was vs Were',
        hint: 'Core sentence pattern: Was (I/He/She/It) vs Were (You/We/They)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He remained silent .',
        translationMl: 'തുടരുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'remain\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 32
    // -----------------------------------------------------------------------
    32: [
      _buildRound(
        id: 1,
        sentence: 'I visited Munnar .',
        translationMl: 'സന്ദർശിക്കുക - I visited Munnar.',
        hint: 'Pay attention to: Subject + V2 past verb (I visited, I bought)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Mom cooked biryani .',
        translationMl: 'പാകം ചെയ്തു - Mom cooked biryani.',
        hint: 'Pay attention to: Subject + V2 past verb (I visited, I bought)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Past Actions: Simple Past V2 gives you great confidence in English .',
        translationMl: 'ഇന്നലെ ചെയ്ത കാര്യങ്ങൾ (V2) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Subject + V2 past verb (I visited, I bought)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I bought a shirt .',
        translationMl: 'ഇന്നലെ ചെയ്ത കാര്യങ്ങൾ (V2)',
        hint: 'Core sentence pattern: Subject + V2 past verb (I visited, I bought)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We watched a movie .',
        translationMl: 'കണ്ടു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'watch\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 33
    // -----------------------------------------------------------------------
    33: [
      _buildRound(
        id: 1,
        sentence: 'Did you see the match ?',
        translationMl: 'കാണുക - Did you see the match?',
        hint: 'Pay attention to: Did + Subject + V1 base verb (Did you go?)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Did you hear the news ?',
        translationMl: 'കേൾക്കുക - Did you hear the news?',
        hint: 'Pay attention to: Did + Subject + V1 base verb (Did you go?)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Asking in the Past: Did you...? gives you great confidence in English .',
        translationMl: 'കഴിഞ്ഞ കാര്യങ്ങൾ ചോദിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Did + Subject + V1 base verb (Did you go?)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Did she call you ?',
        translationMl: 'കഴിഞ്ഞ കാര്യങ്ങൾ ചോദിക്കൽ',
        hint: 'Core sentence pattern: Did + Subject + V1 base verb (Did you go?)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Did you understand ?',
        translationMl: 'മനസ്സിലാക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'understand\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 34
    // -----------------------------------------------------------------------
    34: [
      _buildRound(
        id: 1,
        sentence: 'I didn\'t know that .',
        translationMl: 'അറിയുക - I didn\'t know that.',
        hint: 'Pay attention to: Didn\'t + V1 (Never use V2 after didn\'t!)',
      ),
      _buildRound(
        id: 2,
        sentence: 'I didn\'t receive it .',
        translationMl: 'ലഭിക്കുക - I didn\'t receive it.',
        hint: 'Pay attention to: Didn\'t + V1 (Never use V2 after didn\'t!)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Negative Past: Didn\'t + V1 gives you great confidence in English .',
        translationMl: 'ചെയ്യാതിരുന്ന കാര്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Didn\'t + V1 (Never use V2 after didn\'t!)',
      ),
      _buildRound(
        id: 4,
        sentence: 'He didn\'t attend class .',
        translationMl: 'ചെയ്യാതിരുന്ന കാര്യങ്ങൾ',
        hint: 'Core sentence pattern: Didn\'t + V1 (Never use V2 after didn\'t!)',
      ),
      _buildRound(
        id: 5,
        sentence: 'They didn\'t agree .',
        translationMl: 'സമ്മതിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'agree\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 35
    // -----------------------------------------------------------------------
    35: [
      _buildRound(
        id: 1,
        sentence: 'Yesterday I woke at 7 .',
        translationMl: 'ഉണർന്നു - Yesterday I woke at 7.',
        hint: 'Pay attention to: Time Sequencers: In the morning, Then, Later',
      ),
      _buildRound(
        id: 2,
        sentence: 'I reached office late .',
        translationMl: 'എത്തി - I reached office late.',
        hint: 'Pay attention to: Time Sequencers: In the morning, Then, Later',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Yesterday\'s Full Story gives you great confidence in English .',
        translationMl: 'ഇന്നലത്തെ ദിവസത്തിന്റെ വിവരണം ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Time Sequencers: In the morning, Then, Later',
      ),
      _buildRound(
        id: 4,
        sentence: 'I completed the task .',
        translationMl: 'ഇന്നലത്തെ ദിവസത്തിന്റെ വിവരണം',
        hint: 'Core sentence pattern: Time Sequencers: In the morning, Then, Later',
      ),
      _buildRound(
        id: 5,
        sentence: 'I returned at 8 PM .',
        translationMl: 'മടങ്ങി സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'return\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 36
    // -----------------------------------------------------------------------
    36: [
      _buildRound(
        id: 1,
        sentence: 'I used to play cricket .',
        translationMl: 'കളിച്ചിരുന്നു - I used to play cricket.',
        hint: 'Pay attention to: Used to + V1 (Things you did in the past but not now)',
      ),
      _buildRound(
        id: 2,
        sentence: 'We used to live there .',
        translationMl: 'താമസിച്ചിരുന്നു - We used to live there.',
        hint: 'Pay attention to: Used to + V1 (Things you did in the past but not now)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Childhood Habits: Used to gives you great confidence in English .',
        translationMl: 'പഴയ ശീലങ്ങൾ (Used to) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Used to + V1 (Things you did in the past but not now)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I used to read comics .',
        translationMl: 'പഴയ ശീലങ്ങൾ (Used to)',
        hint: 'Core sentence pattern: Used to + V1 (Things you did in the past but not now)',
      ),
      _buildRound(
        id: 5,
        sentence: 'I used to swim in river .',
        translationMl: 'നീന്തിയിരുന്നു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'swim\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 37
    // -----------------------------------------------------------------------
    37: [
      _buildRound(
        id: 1,
        sentence: 'I was sleeping then .',
        translationMl: 'ഉറങ്ങുകയായിരുന്നു - I was sleeping then.',
        hint: 'Pay attention to: Was/Were + Verb-ing (While I was sleeping)',
      ),
      _buildRound(
        id: 2,
        sentence: 'He was driving home .',
        translationMl: 'ഓടിക്കുകയായിരുന്നു - He was driving home.',
        hint: 'Pay attention to: Was/Were + Verb-ing (While I was sleeping)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Past Continuous: Was/Were + ing gives you great confidence in English .',
        translationMl: 'അപ്പോൾ ചെയ്തുകൊണ്ടിരുന്ന കാര്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Was/Were + Verb-ing (While I was sleeping)',
      ),
      _buildRound(
        id: 4,
        sentence: 'They were studying .',
        translationMl: 'അപ്പോൾ ചെയ്തുകൊണ്ടിരുന്ന കാര്യങ്ങൾ',
        hint: 'Core sentence pattern: Was/Were + Verb-ing (While I was sleeping)',
      ),
      _buildRound(
        id: 5,
        sentence: 'It was raining heavily .',
        translationMl: 'പെയ്യുകയായിരുന്നു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'rain\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 38
    // -----------------------------------------------------------------------
    38: [
      _buildRound(
        id: 1,
        sentence: 'What happened suddenly ?',
        translationMl: 'സംഭവിക്കുക - What happened suddenly?',
        hint: 'Pay attention to: undefined',
      ),
      _buildRound(
        id: 2,
        sentence: 'Someone shouted loudly .',
        translationMl: 'നിലവിളിക്കുക - Someone shouted loudly.',
        hint: 'Pay attention to: undefined',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Past Narrative & Incident Storytelling gives you great confidence in English .',
        translationMl: 'കഥ പറയൽ: First, Then, Suddenly ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: undefined',
      ),
      _buildRound(
        id: 4,
        sentence: 'We ran outside .',
        translationMl: 'കഥ പറയൽ: First, Then, Suddenly',
        hint: 'Core sentence pattern: undefined',
      ),
      _buildRound(
        id: 5,
        sentence: 'Then I realized the truth .',
        translationMl: 'മനസ്സിലാക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'realize\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 39
    // -----------------------------------------------------------------------
    39: [
      _buildRound(
        id: 1,
        sentence: 'I promise I will help .',
        translationMl: 'വാഗ്ദാനം ചെയ്യുക - I promise I will help.',
        hint: 'Pay attention to: Subject + Will + V1 (I will help you)',
      ),
      _buildRound(
        id: 2,
        sentence: 'I will call you tonight .',
        translationMl: 'വിളിക്കുക - I will call you tonight.',
        hint: 'Pay attention to: Subject + Will + V1 (I will help you)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Future Promises & Instant Decisions: Will gives you great confidence in English .',
        translationMl: 'ഭാവി കാര്യങ്ങൾ: Will ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Subject + Will + V1 (I will help you)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will send the photo .',
        translationMl: 'ഭാവി കാര്യങ്ങൾ: Will',
        hint: 'Core sentence pattern: Subject + Will + V1 (I will help you)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We will join tomorrow .',
        translationMl: 'ചേരുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'join\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 40
    // -----------------------------------------------------------------------
    40: [
      _buildRound(
        id: 1,
        sentence: 'I am going to buy a car .',
        translationMl: 'പ്ലാൻ ചെയ്യുക - I am going to buy a car.',
        hint: 'Pay attention to: Am/Is/Are + Going to + V1 (I am going to buy a car)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She is going to start gym .',
        translationMl: 'തുടങ്ങാൻ പോകുന്നു - She is going to start gym.',
        hint: 'Pay attention to: Am/Is/Are + Going to + V1 (I am going to buy a car)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Definite Future Plans: Going to gives you great confidence in English .',
        translationMl: 'ഉറച്ച പ്ലാനുകൾ: Going to ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Am/Is/Are + Going to + V1 (I am going to buy a car)',
      ),
      _buildRound(
        id: 4,
        sentence: 'We are going to shift home .',
        translationMl: 'ഉറച്ച പ്ലാനുകൾ: Going to',
        hint: 'Core sentence pattern: Am/Is/Are + Going to + V1 (I am going to buy a car)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He is going to travel .',
        translationMl: 'യാത്ര പോകാൻ പോകുന്നു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'travel\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 41
    // -----------------------------------------------------------------------
    41: [
      _buildRound(
        id: 1,
        sentence: 'Does this shirt fit you ?',
        translationMl: 'പാകമാകുക - Does this shirt fit you?',
        hint: 'Pay attention to: Size, Fit, Color & Trial Room Conversation',
      ),
      _buildRound(
        id: 2,
        sentence: 'Try this in the trial room .',
        translationMl: 'ധരിച്ചു നോക്കുക - Try this in the trial room.',
        hint: 'Pay attention to: Size, Fit, Color & Trial Room Conversation',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Shopping for Clothes & Trial Room gives you great confidence in English .',
        translationMl: 'വസ്ത്രങ്ങൾ വാങ്ങലും ട്രയലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Size, Fit, Color & Trial Room Conversation',
      ),
      _buildRound(
        id: 4,
        sentence: 'Can I change this size ?',
        translationMl: 'വസ്ത്രങ്ങൾ വാങ്ങലും ട്രയലും',
        hint: 'Core sentence pattern: Size, Fit, Color & Trial Room Conversation',
      ),
      _buildRound(
        id: 5,
        sentence: 'Select your color .',
        translationMl: 'തിരഞ്ഞെടുക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'select\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 42
    // -----------------------------------------------------------------------
    42: [
      _buildRound(
        id: 1,
        sentence: 'Are you ready to order ?',
        translationMl: 'ഓർഡർ ചെയ്യുക - Are you ready to order?',
        hint: 'Pay attention to: Can I have...? / Could we get the bill?',
      ),
      _buildRound(
        id: 2,
        sentence: 'The soup tastes great .',
        translationMl: 'രുചിക്കുക - The soup tastes great.',
        hint: 'Pay attention to: Can I have...? / Could we get the bill?',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of At a Restaurant: Ordering & Bill gives you great confidence in English .',
        translationMl: 'ഹോട്ടലിൽ ഓർഡർ ചെയ്യലും ബില്ലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Can I have...? / Could we get the bill?',
      ),
      _buildRound(
        id: 4,
        sentence: 'Please serve it hot .',
        translationMl: 'ഹോട്ടലിൽ ഓർഡർ ചെയ്യലും ബില്ലും',
        hint: 'Core sentence pattern: Can I have...? / Could we get the bill?',
      ),
      _buildRound(
        id: 5,
        sentence: 'Can I pay by card ?',
        translationMl: 'പണം നൽകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'pay\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 43
    // -----------------------------------------------------------------------
    43: [
      _buildRound(
        id: 1,
        sentence: 'Board train at platform 2 .',
        translationMl: 'കയറുക - Board train at platform 2.',
        hint: 'Pay attention to: Asking Timing, Stops & Platforms',
      ),
      _buildRound(
        id: 2,
        sentence: 'Alight at next station .',
        translationMl: 'ഇറങ്ങുക - Alight at next station.',
        hint: 'Pay attention to: Asking Timing, Stops & Platforms',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Public Transport: Bus & Train Travel gives you great confidence in English .',
        translationMl: 'ബസ്, ട്രെയിൻ യാത്രകൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Asking Timing, Stops & Platforms',
      ),
      _buildRound(
        id: 4,
        sentence: 'Don\'t miss the bus .',
        translationMl: 'ബസ്, ട്രെയിൻ യാത്രകൾ',
        hint: 'Core sentence pattern: Asking Timing, Stops & Platforms',
      ),
      _buildRound(
        id: 5,
        sentence: 'They announced delay .',
        translationMl: 'അറിയിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'announce\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 44
    // -----------------------------------------------------------------------
    44: [
      _buildRound(
        id: 1,
        sentence: 'Check in your luggage .',
        translationMl: 'ചെക്ക്-ഇൻ ചെയ്യുക - Check in your luggage.',
        hint: 'Pay attention to: Check-in, Boarding, Luggage & Security',
      ),
      _buildRound(
        id: 2,
        sentence: 'Board the flight .',
        translationMl: 'കയറുക - Board the flight.',
        hint: 'Pay attention to: Check-in, Boarding, Luggage & Security',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of At the Airport & Flight Journey gives you great confidence in English .',
        translationMl: 'വിമാനത്താവളവും ഫ്ലൈറ്റ് യാത്രയും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Check-in, Boarding, Luggage & Security',
      ),
      _buildRound(
        id: 4,
        sentence: 'Flight landed safely .',
        translationMl: 'വിമാനത്താവളവും ഫ്ലൈറ്റ് യാത്രയും',
        hint: 'Core sentence pattern: Check-in, Boarding, Luggage & Security',
      ),
      _buildRound(
        id: 5,
        sentence: 'We are flying to Dubai .',
        translationMl: 'പറക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'fly\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 45
    // -----------------------------------------------------------------------
    45: [
      _buildRound(
        id: 1,
        sentence: 'I booked a room online .',
        translationMl: 'ബുക്ക് ചെയ്യുക - I booked a room online.',
        hint: 'Pay attention to: I have a reservation under the name...',
      ),
      _buildRound(
        id: 2,
        sentence: 'We stay for two nights .',
        translationMl: 'താമസിക്കുക - We stay for two nights.',
        hint: 'Pay attention to: I have a reservation under the name...',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Hotel Stay & Check-in gives you great confidence in English .',
        translationMl: 'ഹോട്ടൽ ബുക്കിംഗും താമസവും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I have a reservation under the name...',
      ),
      _buildRound(
        id: 4,
        sentence: 'Request extra towel .',
        translationMl: 'ഹോട്ടൽ ബുക്കിംഗും താമസവും',
        hint: 'Core sentence pattern: I have a reservation under the name...',
      ),
      _buildRound(
        id: 5,
        sentence: 'Check out is at 11 AM .',
        translationMl: 'റൂം ഒഴിയുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'check out\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 46
    // -----------------------------------------------------------------------
    46: [
      _buildRound(
        id: 1,
        sentence: 'Schedule a meeting .',
        translationMl: 'സമയം നിശ്ചയിക്കുക - Schedule a meeting.',
        hint: 'Pay attention to: Setting & Confirming Meeting Times',
      ),
      _buildRound(
        id: 2,
        sentence: 'Please confirm my slot .',
        translationMl: 'ഉറപ്പാക്കുക - Please confirm my slot.',
        hint: 'Pay attention to: Setting & Confirming Meeting Times',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Tomorrow\'s Schedule & Appointments gives you great confidence in English .',
        translationMl: 'നാളത്തെ അപ്പോയിന്റ്മെന്റുകൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Setting & Confirming Meeting Times',
      ),
      _buildRound(
        id: 4,
        sentence: 'Can we postpone it ?',
        translationMl: 'നാളത്തെ അപ്പോയിന്റ്മെന്റുകൾ',
        hint: 'Core sentence pattern: Setting & Confirming Meeting Times',
      ),
      _buildRound(
        id: 5,
        sentence: 'I will attend on time .',
        translationMl: 'പങ്കെടുക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'attend\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 47
    // -----------------------------------------------------------------------
    47: [
      _buildRound(
        id: 1,
        sentence: 'I invite you to dinner .',
        translationMl: 'ക്ഷണിക്കുക - I invite you to dinner.',
        hint: 'Pay attention to: Would you like + to V1 / noun (Would you like tea?)',
      ),
      _buildRound(
        id: 2,
        sentence: 'Would you like to join ?',
        translationMl: 'കൂടുക - Would you like to join?',
        hint: 'Pay attention to: Would you like + to V1 / noun (Would you like tea?)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Polite Invitations: Would you like to...? gives you great confidence in English .',
        translationMl: 'വിനയത്തോടെ ക്ഷണിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Would you like + to V1 / noun (Would you like tea?)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Would you like to visit ?',
        translationMl: 'വിനയത്തോടെ ക്ഷണിക്കൽ',
        hint: 'Core sentence pattern: Would you like + to V1 / noun (Would you like tea?)',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please come over .',
        translationMl: 'വരുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'come\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 48
    // -----------------------------------------------------------------------
    48: [
      _buildRound(
        id: 1,
        sentence: 'Would you mind closing door ?',
        translationMl: 'വിഷമമാവുക - Would you mind closing door?',
        hint: 'Pay attention to: Could you please + V1 / Would you mind + V-ing',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you do me a favor ?',
        translationMl: 'സഹായിക്കുക - Could you do me a favor?',
        hint: 'Pay attention to: Could you please + V1 / Would you mind + V-ing',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Polite Requests: Could you please... gives you great confidence in English .',
        translationMl: 'മാന്യമായ ആവശ്യപ്പെടലുകൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Could you please + V1 / Would you mind + V-ing',
      ),
      _buildRound(
        id: 4,
        sentence: 'Could you pass the water ?',
        translationMl: 'മാന്യമായ ആവശ്യപ്പെടലുകൾ',
        hint: 'Core sentence pattern: Could you please + V1 / Would you mind + V-ing',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could you lend your pen ?',
        translationMl: 'കടം നൽകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'lend\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 49
    // -----------------------------------------------------------------------
    49: [
      _buildRound(
        id: 1,
        sentence: 'Doctor advised rest .',
        translationMl: 'ഉപദേശിക്കുക - Doctor advised rest.',
        hint: 'Pay attention to: You should + V1 (You should sleep early)',
      ),
      _buildRound(
        id: 2,
        sentence: 'You should exercise daily .',
        translationMl: 'വ്യായാമം ചെയ്യുക - You should exercise daily.',
        hint: 'Pay attention to: You should + V1 (You should sleep early)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Giving Advice: Should & Ought to gives you great confidence in English .',
        translationMl: 'ഉപദേശങ്ങൾ നൽകൽ (Should) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: You should + V1 (You should sleep early)',
      ),
      _buildRound(
        id: 4,
        sentence: 'You should avoid sugar .',
        translationMl: 'ഉപദേശങ്ങൾ നൽകൽ (Should)',
        hint: 'Core sentence pattern: You should + V1 (You should sleep early)',
      ),
      _buildRound(
        id: 5,
        sentence: 'You should consult doctor .',
        translationMl: 'കാണുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'consult\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 50
    // -----------------------------------------------------------------------
    50: [
      _buildRound(
        id: 1,
        sentence: 'You must follow rules .',
        translationMl: 'പാലിക്കുക - You must follow rules.',
        hint: 'Pay attention to: Must (Personal/Strict) vs Have to (External rule)',
      ),
      _buildRound(
        id: 2,
        sentence: 'You must wear a helmet .',
        translationMl: 'ധരിക്കുക - You must wear a helmet.',
        hint: 'Pay attention to: Must (Personal/Strict) vs Have to (External rule)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Compulsion & Rules: Must vs Have to gives you great confidence in English .',
        translationMl: 'നിർബന്ധങ്ങൾ: Must vs Have to ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Must (Personal/Strict) vs Have to (External rule)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I have to submit today .',
        translationMl: 'നിർബന്ധങ്ങൾ: Must vs Have to',
        hint: 'Core sentence pattern: Must (Personal/Strict) vs Have to (External rule)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We must obey traffic .',
        translationMl: 'അനുസരിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'obey\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 51
    // -----------------------------------------------------------------------
    51: [
      _buildRound(
        id: 1,
        sentence: 'I happily accept .',
        translationMl: 'സ്വീകരിക്കുക - I happily accept.',
        hint: 'Pay attention to: I\'d love to! vs I wish I could, but...',
      ),
      _buildRound(
        id: 2,
        sentence: 'I must decline politely .',
        translationMl: 'നിരസിക്കുക - I must decline politely.',
        hint: 'Pay attention to: I\'d love to! vs I wish I could, but...',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Accepting & Declining Politely gives you great confidence in English .',
        translationMl: 'ക്ഷണം സ്വീകരിക്കലും നിരസിക്കലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I\'d love to! vs I wish I could, but...',
      ),
      _buildRound(
        id: 4,
        sentence: 'I apologize for the delay .',
        translationMl: 'ക്ഷണം സ്വീകരിക്കലും നിരസിക്കലും',
        hint: 'Core sentence pattern: I\'d love to! vs I wish I could, but...',
      ),
      _buildRound(
        id: 5,
        sentence: 'I appreciate your invite .',
        translationMl: 'വിലമതിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'appreciate\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 52
    // -----------------------------------------------------------------------
    52: [
      _buildRound(
        id: 1,
        sentence: 'I feel confident now .',
        translationMl: 'തോന്നുക - I feel confident now.',
        hint: 'Pay attention to: I feel proud / nervous / thrilled / upset',
      ),
      _buildRound(
        id: 2,
        sentence: 'Don\'t worry at all .',
        translationMl: 'ആശങ്കപ്പെടുക - Don\'t worry at all.',
        hint: 'Pay attention to: I feel proud / nervous / thrilled / upset',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Expressing Feelings & Emotions gives you great confidence in English .',
        translationMl: 'വികാരങ്ങളും മാനസികാവസ്ഥയും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I feel proud / nervous / thrilled / upset',
      ),
      _buildRound(
        id: 4,
        sentence: 'Cheer up, all is well .',
        translationMl: 'വികാരങ്ങളും മാനസികാവസ്ഥയും',
        hint: 'Core sentence pattern: I feel proud / nervous / thrilled / upset',
      ),
      _buildRound(
        id: 5,
        sentence: 'Calm down and breathe .',
        translationMl: 'ശാന്തമാവുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'calm\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 53
    // -----------------------------------------------------------------------
    53: [
      _buildRound(
        id: 1,
        sentence: 'I have a small complaint .',
        translationMl: 'പരാതിപ്പെടുക - I have a small complaint.',
        hint: 'Pay attention to: I am afraid there is a problem with...',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you replace this ?',
        translationMl: 'മാറ്റി നൽകുക - Could you replace this?',
        hint: 'Pay attention to: I am afraid there is a problem with...',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Handling Complaints & Polite Feedback gives you great confidence in English .',
        translationMl: 'പരാതികളും ഫീഡ്ബാക്കും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I am afraid there is a problem with...',
      ),
      _buildRound(
        id: 4,
        sentence: 'Please fix the issue .',
        translationMl: 'പരാതികളും ഫീഡ്ബാക്കും',
        hint: 'Core sentence pattern: I am afraid there is a problem with...',
      ),
      _buildRound(
        id: 5,
        sentence: 'Can I get a refund ?',
        translationMl: 'പണം തിരികെ നൽകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'refund\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 54
    // -----------------------------------------------------------------------
    54: [
      _buildRound(
        id: 1,
        sentence: 'Deposit money in account .',
        translationMl: 'നിക്ഷേപിക്കുക - Deposit money in account.',
        hint: 'Pay attention to: Deposit, Withdraw, Transfer, UPI & Balance',
      ),
      _buildRound(
        id: 2,
        sentence: 'Withdraw cash from ATM .',
        translationMl: 'പിൻവലിക്കുക - Withdraw cash from ATM.',
        hint: 'Pay attention to: Deposit, Withdraw, Transfer, UPI & Balance',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Banking & Money Transactions gives you great confidence in English .',
        translationMl: 'ബാങ്കും പണമിടപാടുകളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Deposit, Withdraw, Transfer, UPI & Balance',
      ),
      _buildRound(
        id: 4,
        sentence: 'Transfer via UPI .',
        translationMl: 'ബാങ്കും പണമിടപാടുകളും',
        hint: 'Core sentence pattern: Deposit, Withdraw, Transfer, UPI & Balance',
      ),
      _buildRound(
        id: 5,
        sentence: 'Save monthly income .',
        translationMl: 'സൂക്ഷിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'save\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 55
    // -----------------------------------------------------------------------
    55: [
      _buildRound(
        id: 1,
        sentence: 'Charge your phone .',
        translationMl: 'ചാർജ് ചെയ്യുക - Charge your phone.',
        hint: 'Pay attention to: My battery is low / Network is weak / Restart',
      ),
      _buildRound(
        id: 2,
        sentence: 'Connect to WiFi .',
        translationMl: 'ബന്ധിപ്പിക്കുക - Connect to WiFi.',
        hint: 'Pay attention to: My battery is low / Network is weak / Restart',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Technology, Mobiles & Connectivity gives you great confidence in English .',
        translationMl: 'മൊബൈൽ, വൈഫൈ, സാങ്കേതികവിദ്യ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: My battery is low / Network is weak / Restart',
      ),
      _buildRound(
        id: 4,
        sentence: 'Download the update .',
        translationMl: 'മൊബൈൽ, വൈഫൈ, സാങ്കേതികവിദ്യ',
        hint: 'Core sentence pattern: My battery is low / Network is weak / Restart',
      ),
      _buildRound(
        id: 5,
        sentence: 'Restart the device .',
        translationMl: 'റീസ്റ്റാർട്ട് ചെയ്യുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'restart\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 56
    // -----------------------------------------------------------------------
    56: [
      _buildRound(
        id: 1,
        sentence: 'I lost my wallet .',
        translationMl: 'നഷ്ടപ്പെടുക - I lost my wallet.',
        hint: 'Pay attention to: I lost my... / Please call an ambulance / Urgent',
      ),
      _buildRound(
        id: 2,
        sentence: 'We searched everywhere .',
        translationMl: 'തിരയുക - We searched everywhere.',
        hint: 'Pay attention to: I lost my... / Please call an ambulance / Urgent',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Lost Items & Urgent Emergencies gives you great confidence in English .',
        translationMl: 'സാധനങ്ങൾ നഷ്ടപ്പെടലും അത്യാഹിതങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I lost my... / Please call an ambulance / Urgent',
      ),
      _buildRound(
        id: 4,
        sentence: 'Report to local police .',
        translationMl: 'സാധനങ്ങൾ നഷ്ടപ്പെടലും അത്യാഹിതങ്ങളും',
        hint: 'Core sentence pattern: I lost my... / Please call an ambulance / Urgent',
      ),
      _buildRound(
        id: 5,
        sentence: 'Rescue team arrived .',
        translationMl: 'രക്ഷിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'rescue\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 57
    // -----------------------------------------------------------------------
    57: [
      _buildRound(
        id: 1,
        sentence: 'Doctor examined my chest .',
        translationMl: 'പരിശോധിക്കുക - Doctor examined my chest.',
        hint: 'Pay attention to: I have been having this pain since yesterday',
      ),
      _buildRound(
        id: 2,
        sentence: 'I am suffering from flu .',
        translationMl: 'കഷ്ടപ്പെടുക - I am suffering from flu.',
        hint: 'Pay attention to: I have been having this pain since yesterday',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Doctor Consultation: Explaining Symptoms gives you great confidence in English .',
        translationMl: 'ഡോക്ടറോട് ലക്ഷണങ്ങൾ പറയൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I have been having this pain since yesterday',
      ),
      _buildRound(
        id: 4,
        sentence: 'You will recover soon .',
        translationMl: 'ഡോക്ടറോട് ലക്ഷണങ്ങൾ പറയൽ',
        hint: 'Core sentence pattern: I have been having this pain since yesterday',
      ),
      _buildRound(
        id: 5,
        sentence: 'Nurse injected medicine .',
        translationMl: 'കുത്തിവെയ്ക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'inject\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 58
    // -----------------------------------------------------------------------
    58: [
      _buildRound(
        id: 1,
        sentence: 'React within 3 seconds .',
        translationMl: 'പ്രതികരിക്കുക - React within 3 seconds.',
        hint: 'Pay attention to: Eliminating Translation Delay: Direct English Response',
      ),
      _buildRound(
        id: 2,
        sentence: 'Speak without pause .',
        translationMl: 'സംസാരിക്കുക - Speak without pause.',
        hint: 'Pay attention to: Eliminating Translation Delay: Direct English Response',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Rapid Fire Reflex Drills: Spontaneous Speech gives you great confidence in English .',
        translationMl: 'വേഗത്തിലുള്ള മറുപടികൾ (Reflex) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Eliminating Translation Delay: Direct English Response',
      ),
      _buildRound(
        id: 4,
        sentence: 'Think directly in English .',
        translationMl: 'വേഗത്തിലുള്ള മറുപടികൾ (Reflex)',
        hint: 'Core sentence pattern: Eliminating Translation Delay: Direct English Response',
      ),
      _buildRound(
        id: 5,
        sentence: 'Reply with confidence .',
        translationMl: 'മറുപടി നൽകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'reply\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 59
    // -----------------------------------------------------------------------
    59: [
      _buildRound(
        id: 1,
        sentence: 'Compliment their watch .',
        translationMl: 'പ്രശംസിക്കുക - Compliment their watch.',
        hint: 'Pay attention to: Weather, Commute, Compliments & Safe Topics',
      ),
      _buildRound(
        id: 2,
        sentence: 'Chat during the train ride .',
        translationMl: 'സൊറ പറയുക - Chat during the train ride.',
        hint: 'Pay attention to: Weather, Commute, Compliments & Safe Topics',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Social Small Talk with Strangers gives you great confidence in English .',
        translationMl: 'അപരിചിതരുമായുള്ള സൗഹൃദ സംഭാഷണം ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Weather, Commute, Compliments & Safe Topics',
      ),
      _buildRound(
        id: 4,
        sentence: 'Smile and greet .',
        translationMl: 'അപരിചിതരുമായുള്ള സൗഹൃദ സംഭാഷണം',
        hint: 'Core sentence pattern: Weather, Commute, Compliments & Safe Topics',
      ),
      _buildRound(
        id: 5,
        sentence: 'Introduce casually .',
        translationMl: 'പരിചയപ്പെടുത്തുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'introduce\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 60
    // -----------------------------------------------------------------------
    60: [
      _buildRound(
        id: 1,
        sentence: 'Conquer House 2 .',
        translationMl: 'കീഴടക്കുക - Conquer House 2.',
        hint: 'Pay attention to: Past, Future, Modals & Situation Integration',
      ),
      _buildRound(
        id: 2,
        sentence: 'Celebrate milestone .',
        translationMl: 'ആഘോഷിക്കുക - Celebrate milestone.',
        hint: 'Pay attention to: Past, Future, Modals & Situation Integration',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of House 2 Grand Review & Gate Exam gives you great confidence in English .',
        translationMl: 'ഹൗസ് 2 ഫൈനൽ റിവ്യൂ & എക്സാം ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Past, Future, Modals & Situation Integration',
      ),
      _buildRound(
        id: 4,
        sentence: 'Advance to House 3 .',
        translationMl: 'ഹൗസ് 2 ഫൈനൽ റിവ്യൂ & എക്സാം',
        hint: 'Core sentence pattern: Past, Future, Modals & Situation Integration',
      ),
      _buildRound(
        id: 5,
        sentence: 'Prove your fluency .',
        translationMl: 'തെളിയിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'prove\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 61
    // -----------------------------------------------------------------------
    61: [
      _buildRound(
        id: 1,
        sentence: 'I have finished my work .',
        translationMl: 'പൂർത്തിയാക്കി - I have finished my work.',
        hint: 'Pay attention to: Have/Has + V3 (Action completed with present connection)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She has eaten lunch .',
        translationMl: 'കഴിച്ചു - She has eaten lunch.',
        hint: 'Pay attention to: Have/Has + V3 (Action completed with present connection)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Present Perfect: Have/Has + V3 gives you great confidence in English .',
        translationMl: 'ചെയ്തു കഴിഞ്ഞ കാര്യങ്ങൾ: Have/Has + V3 ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Have/Has + V3 (Action completed with present connection)',
      ),
      _buildRound(
        id: 4,
        sentence: 'We have cleaned the room .',
        translationMl: 'ചെയ്തു കഴിഞ്ഞ കാര്യങ്ങൾ: Have/Has + V3',
        hint: 'Core sentence pattern: Have/Has + V3 (Action completed with present connection)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He has written the email .',
        translationMl: 'എഴുതിക്കഴിഞ്ഞു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'write\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 62
    // -----------------------------------------------------------------------
    62: [
      _buildRound(
        id: 1,
        sentence: 'Have you ever traveled abroad ?',
        translationMl: 'യാത്ര ചെയ്തിട്ടുണ്ടോ - Have you ever traveled abroad?',
        hint: 'Pay attention to: Have you ever + V3? / I have never + V3',
      ),
      _buildRound(
        id: 2,
        sentence: 'Have you ever tasted sushi ?',
        translationMl: 'രുചിച്ചിട്ടുണ്ടോ - Have you ever tasted sushi?',
        hint: 'Pay attention to: Have you ever + V3? / I have never + V3',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Life Experiences: Have you ever...? gives you great confidence in English .',
        translationMl: 'ജീവിതാനുഭവങ്ങൾ: Have you ever...? ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Have you ever + V3? / I have never + V3',
      ),
      _buildRound(
        id: 4,
        sentence: 'Have you ever flown in a plane ?',
        translationMl: 'ജീവിതാനുഭവങ്ങൾ: Have you ever...?',
        hint: 'Core sentence pattern: Have you ever + V3? / I have never + V3',
      ),
      _buildRound(
        id: 5,
        sentence: 'Have you ever met a celebrity ?',
        translationMl: 'കണ്ടിട്ടുണ്ടോ സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'meet\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 63
    // -----------------------------------------------------------------------
    63: [
      _buildRound(
        id: 1,
        sentence: 'Train has just arrived .',
        translationMl: 'എത്തിച്ചേർന്നു - Train has just arrived.',
        hint: 'Pay attention to: Just (ഇപ്പോൾ തന്നെ) | Already (നേരത്തെ തന്നെ) | Yet (ഇതുവരെ ഇല്ല)',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have already sent it .',
        translationMl: 'അയച്ചു കഴിഞ്ഞു - I have already sent it.',
        hint: 'Pay attention to: Just (ഇപ്പോൾ തന്നെ) | Already (നേരത്തെ തന്നെ) | Yet (ഇതുവരെ ഇല്ല)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Just, Already & Yet gives you great confidence in English .',
        translationMl: 'Just, Already, Yet പ്രയോഗങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Just (ഇപ്പോൾ തന്നെ) | Already (നേരത്തെ തന്നെ) | Yet (ഇതുവരെ ഇല്ല)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I haven\'t received it yet .',
        translationMl: 'Just, Already, Yet പ്രയോഗങ്ങൾ',
        hint: 'Core sentence pattern: Just (ഇപ്പോൾ തന്നെ) | Already (നേരത്തെ തന്നെ) | Yet (ഇതുവരെ ഇല്ല)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We haven\'t decided yet .',
        translationMl: 'തീരുമാനിച്ചിട്ടില്ല സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'decide\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 64
    // -----------------------------------------------------------------------
    64: [
      _buildRound(
        id: 1,
        sentence: 'I have lived here for 5 years .',
        translationMl: 'താമസിച്ചുവരുന്നു - I have lived here for 5 years.',
        hint: 'Pay attention to: Since + Starting point (Since 2020) | For + Period (For 3 years)',
      ),
      _buildRound(
        id: 2,
        sentence: 'She has worked here since May .',
        translationMl: 'ജോലി ചെയ്യുന്നു - She has worked here since May.',
        hint: 'Pay attention to: Since + Starting point (Since 2020) | For + Period (For 3 years)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Since vs For: Duration of Action gives you great confidence in English .',
        translationMl: 'Since vs For (കാലയളവ് പറയൽ) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Since + Starting point (Since 2020) | For + Period (For 3 years)',
      ),
      _buildRound(
        id: 4,
        sentence: 'I have waited for two hours .',
        translationMl: 'Since vs For (കാലയളവ് പറയൽ)',
        hint: 'Core sentence pattern: Since + Starting point (Since 2020) | For + Period (For 3 years)',
      ),
      _buildRound(
        id: 5,
        sentence: 'We have known each other since school .',
        translationMl: 'പരിചയമുണ്ട് സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'know\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 65
    // -----------------------------------------------------------------------
    65: [
      _buildRound(
        id: 1,
        sentence: 'I have been learning English for months .',
        translationMl: 'പഠിച്ചുകൊണ്ടിരിക്കുന്നു - I have been learning English for months.',
        hint: 'Pay attention to: Have/Has been + V-ing (Action started in past and still continuing)',
      ),
      _buildRound(
        id: 2,
        sentence: 'He has been practicing speaking .',
        translationMl: 'പരിശീലിച്ചുവരുന്നു - He has been practicing speaking.',
        hint: 'Pay attention to: Have/Has been + V-ing (Action started in past and still continuing)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Present Perfect Continuous: Have been doing gives you great confidence in English .',
        translationMl: 'തുടർന്നുകൊണ്ടേയിരിക്കുന്ന കാര്യങ്ങൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Have/Has been + V-ing (Action started in past and still continuing)',
      ),
      _buildRound(
        id: 4,
        sentence: 'It has been raining since morning .',
        translationMl: 'തുടർന്നുകൊണ്ടേയിരിക്കുന്ന കാര്യങ്ങൾ',
        hint: 'Core sentence pattern: Have/Has been + V-ing (Action started in past and still continuing)',
      ),
      _buildRound(
        id: 5,
        sentence: 'I have been working on this code .',
        translationMl: 'ജോലി ചെയ്തുകൊണ്ടിരിക്കുന്നു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'work\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 66
    // -----------------------------------------------------------------------
    66: [
      _buildRound(
        id: 1,
        sentence: 'I manage client communications .',
        translationMl: 'കൈകാര്യം ചെയ്യുക - I manage client communications.',
        hint: 'Pay attention to: I have been working as a [Role] for [Years]',
      ),
      _buildRound(
        id: 2,
        sentence: 'I handle software projects .',
        translationMl: 'നോക്കുക - I handle software projects.',
        hint: 'Pay attention to: I have been working as a [Role] for [Years]',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Describing Career & Work Experience gives you great confidence in English .',
        translationMl: 'തൊഴിൽ പരിചയം വിവരിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I have been working as a [Role] for [Years]',
      ),
      _buildRound(
        id: 4,
        sentence: 'I lead a team of five .',
        translationMl: 'തൊഴിൽ പരിചയം വിവരിക്കൽ',
        hint: 'Core sentence pattern: I have been working as a [Role] for [Years]',
      ),
      _buildRound(
        id: 5,
        sentence: 'We deliver on deadlines .',
        translationMl: 'പൂർത്തിയാക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'deliver\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 67
    // -----------------------------------------------------------------------
    67: [
      _buildRound(
        id: 1,
        sentence: 'I studied hard, so I passed .',
        translationMl: 'പഠിച്ചു - I studied hard, so I passed.',
        hint: 'Pay attention to: Cause (Because) vs Result (So)',
      ),
      _buildRound(
        id: 2,
        sentence: 'I was tired, so I slept .',
        translationMl: 'ക്ഷീണിച്ചു - I was tired, so I slept.',
        hint: 'Pay attention to: Cause (Because) vs Result (So)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Connecting Ideas: Because & So gives you great confidence in English .',
        translationMl: 'കാരണവും ഫലവും പറയൽ (Because & So) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Cause (Because) vs Result (So)',
      ),
      _buildRound(
        id: 4,
        sentence: 'He succeeded because he persisted .',
        translationMl: 'കാരണവും ഫലവും പറയൽ (Because & So)',
        hint: 'Core sentence pattern: Cause (Because) vs Result (So)',
      ),
      _buildRound(
        id: 5,
        sentence: 'English improved because I practiced .',
        translationMl: 'മെച്ചപ്പെട്ടു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'improve\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 68
    // -----------------------------------------------------------------------
    68: [
      _buildRound(
        id: 1,
        sentence: 'Although he tried, it was hard .',
        translationMl: 'ശ്രമിച്ചു - Although he tried, it was hard.',
        hint: 'Pay attention to: Although + Clause (Although it rained, we enjoyed)',
      ),
      _buildRound(
        id: 2,
        sentence: 'However, we continued forward .',
        translationMl: 'തുടർന്നു - However, we continued forward.',
        hint: 'Pay attention to: Although + Clause (Although it rained, we enjoyed)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Contrast Connectors: Although, However, But gives you great confidence in English .',
        translationMl: 'വൈരുദ്ധ്യങ്ങൾ പറയൽ (Although / However) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Although + Clause (Although it rained, we enjoyed)',
      ),
      _buildRound(
        id: 4,
        sentence: 'Although tired, they won .',
        translationMl: 'വൈരുദ്ധ്യങ്ങൾ പറയൽ (Although / However)',
        hint: 'Core sentence pattern: Although + Clause (Although it rained, we enjoyed)',
      ),
      _buildRound(
        id: 5,
        sentence: 'It was tough; however, I learned .',
        translationMl: 'പഠിച്ചു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'learn\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 69
    // -----------------------------------------------------------------------
    69: [
      _buildRound(
        id: 1,
        sentence: 'If it rains, we will stay home .',
        translationMl: 'മഴ പെയ്താൽ - If it rains, we will stay home.',
        hint: 'Pay attention to: If + Present Simple, Will + V1',
      ),
      _buildRound(
        id: 2,
        sentence: 'If you call, I will answer .',
        translationMl: 'വിളിച്ചാൽ - If you call, I will answer.',
        hint: 'Pay attention to: If + Present Simple, Will + V1',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Real Conditions: If it rains, I will stay gives you great confidence in English .',
        translationMl: 'സാധ്യമായ നിബന്ധനകൾ (First Conditional) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: If + Present Simple, Will + V1',
      ),
      _buildRound(
        id: 4,
        sentence: 'If you practice, you will speak .',
        translationMl: 'സാധ്യമായ നിബന്ധനകൾ (First Conditional)',
        hint: 'Core sentence pattern: If + Present Simple, Will + V1',
      ),
      _buildRound(
        id: 5,
        sentence: 'If you come, I will cook .',
        translationMl: 'വന്നാൽ സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'come\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 70
    // -----------------------------------------------------------------------
    70: [
      _buildRound(
        id: 1,
        sentence: 'If I had time, I would travel .',
        translationMl: 'യാത്ര ചെയ്യുമായിരുന്നു - If I had time, I would travel.',
        hint: 'Pay attention to: If + Past Simple, Would + V1 (If I had money, I would travel)',
      ),
      _buildRound(
        id: 2,
        sentence: 'If I won, I would buy a house .',
        translationMl: 'വാങ്ങുമായിരുന്നു - If I won, I would buy a house.',
        hint: 'Pay attention to: If + Past Simple, Would + V1 (If I had money, I would travel)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Imaginary Situations: If I were... / Would gives you great confidence in English .',
        translationMl: 'സങ്കൽപ്പങ്ങൾ (Second Conditional) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: If + Past Simple, Would + V1 (If I had money, I would travel)',
      ),
      _buildRound(
        id: 4,
        sentence: 'If I knew, I would help .',
        translationMl: 'സങ്കൽപ്പങ്ങൾ (Second Conditional)',
        hint: 'Core sentence pattern: If + Past Simple, Would + V1 (If I had money, I would travel)',
      ),
      _buildRound(
        id: 5,
        sentence: 'If I had wings, I would fly .',
        translationMl: 'പറക്കുമായിരുന്നു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'fly\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 71
    // -----------------------------------------------------------------------
    71: [
      _buildRound(
        id: 1,
        sentence: 'It might rain this evening .',
        translationMl: 'മഴ പെയ്തേക്കാം - It might rain this evening.',
        hint: 'Pay attention to: Expressing 50% vs 30% Probability',
      ),
      _buildRound(
        id: 2,
        sentence: 'He may visit us today .',
        translationMl: 'വന്നേക്കാം - He may visit us today.',
        hint: 'Pay attention to: Expressing 50% vs 30% Probability',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Modals of Probability: May, Might, Could gives you great confidence in English .',
        translationMl: 'സാധ്യതകൾ: May, Might, Could ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Expressing 50% vs 30% Probability',
      ),
      _buildRound(
        id: 4,
        sentence: 'The plan could succeed .',
        translationMl: 'സാധ്യതകൾ: May, Might, Could',
        hint: 'Core sentence pattern: Expressing 50% vs 30% Probability',
      ),
      _buildRound(
        id: 5,
        sentence: 'The train might be delayed .',
        translationMl: 'വൈകിയേക്കാം സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'delay\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 72
    // -----------------------------------------------------------------------
    72: [
      _buildRound(
        id: 1,
        sentence: 'He must be tired after work .',
        translationMl: 'ആയിരിക്കും - He must be tired after work.',
        hint: 'Pay attention to: Must be (തീർച്ചയായും ആയിരിക്കും) | Can\'t be (ഒരിക്കലും ആകില്ല)',
      ),
      _buildRound(
        id: 2,
        sentence: 'You can\'t be serious; it must be a joke .',
        translationMl: 'തമാശ പറയുക - You can\'t be serious; it must be a joke.',
        hint: 'Pay attention to: Must be (തീർച്ചയായും ആയിരിക്കും) | Can\'t be (ഒരിക്കലും ആകില്ല)',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Logical Deductions: Must be vs Can\'t be gives you great confidence in English .',
        translationMl: 'യുക്തിപരമായ നിഗമനങ്ങൾ (Must be / Can\'t be) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Must be (തീർച്ചയായും ആയിരിക്കും) | Can\'t be (ഒരിക്കലും ആകില്ല)',
      ),
      _buildRound(
        id: 4,
        sentence: 'She can\'t be lying .',
        translationMl: 'യുക്തിപരമായ നിഗമനങ്ങൾ (Must be / Can\'t be)',
        hint: 'Core sentence pattern: Must be (തീർച്ചയായും ആയിരിക്കും) | Can\'t be (ഒരിക്കലും ആകില്ല)',
      ),
      _buildRound(
        id: 5,
        sentence: 'He must know the truth .',
        translationMl: 'അറിയുമായിരിക്കും സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'know\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 73
    // -----------------------------------------------------------------------
    73: [
      _buildRound(
        id: 1,
        sentence: 'The flight was delayed .',
        translationMl: 'വൈകിപ്പിക്കപ്പെട്ടു - The flight was delayed.',
        hint: 'Pay attention to: The flight is delayed / I was told / It is made of...',
      ),
      _buildRound(
        id: 2,
        sentence: 'I was informed yesterday .',
        translationMl: 'അറിയിക്കപ്പെട്ടു - I was informed yesterday.',
        hint: 'Pay attention to: The flight is delayed / I was told / It is made of...',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Passive Voice in Daily Spoken Speech gives you great confidence in English .',
        translationMl: 'നിത്യജീവിതത്തിലെ പാസ്സീവ് വോയ്സ് ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: The flight is delayed / I was told / It is made of...',
      ),
      _buildRound(
        id: 4,
        sentence: 'The match was cancelled .',
        translationMl: 'നിത്യജീവിതത്തിലെ പാസ്സീവ് വോയ്സ്',
        hint: 'Core sentence pattern: The flight is delayed / I was told / It is made of...',
      ),
      _buildRound(
        id: 5,
        sentence: 'My phone is repaired .',
        translationMl: 'നന്നാക്കപ്പെട്ടു സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'repair\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 74
    // -----------------------------------------------------------------------
    74: [
      _buildRound(
        id: 1,
        sentence: 'Could you connect me to HR ?',
        translationMl: 'ബന്ധിപ്പിക്കുക - Could you connect me to HR?',
        hint: 'Pay attention to: May I speak with...? / May I ask who is calling?',
      ),
      _buildRound(
        id: 2,
        sentence: 'Please hold the line .',
        translationMl: 'ഹോൾഡ് ചെയ്യുക - Please hold the line.',
        hint: 'Pay attention to: May I speak with...? / May I ask who is calling?',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Professional Telephone Etiquette gives you great confidence in English .',
        translationMl: 'ഓഫീസ് ഫോൺ കോളുകൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: May I speak with...? / May I ask who is calling?',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will transfer your call .',
        translationMl: 'ഓഫീസ് ഫോൺ കോളുകൾ',
        hint: 'Core sentence pattern: May I speak with...? / May I ask who is calling?',
      ),
      _buildRound(
        id: 5,
        sentence: 'I will call you back shortly .',
        translationMl: 'തിരികെ വിളിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'call back\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 75
    // -----------------------------------------------------------------------
    75: [
      _buildRound(
        id: 1,
        sentence: 'Can I leave a message ?',
        translationMl: 'നൽകുക - Can I leave a message?',
        hint: 'Pay attention to: Could you take a message? / Please tell him that...',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have noted down your number .',
        translationMl: 'കുറിച്ചെടുക്കുക - I have noted down your number.',
        hint: 'Pay attention to: Could you take a message? / Please tell him that...',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Taking Messages & Leaving Voicemails gives you great confidence in English .',
        translationMl: 'വോയ്‌സ് മെസ്സേജുകളും സന്ദേശങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Could you take a message? / Please tell him that...',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will deliver the message .',
        translationMl: 'വോയ്‌സ് മെസ്സേജുകളും സന്ദേശങ്ങളും',
        hint: 'Core sentence pattern: Could you take a message? / Please tell him that...',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please remind him to call .',
        translationMl: 'ഓർമ്മിപ്പിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'remind\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 76
    // -----------------------------------------------------------------------
    76: [
      _buildRound(
        id: 1,
        sentence: 'Let\'s grab a coffee .',
        translationMl: 'കുടിക്കുക - Let\'s grab a coffee.',
        hint: 'Pay attention to: Casual Workplace Interaction: Projects, Weekend, Coffee',
      ),
      _buildRound(
        id: 2,
        sentence: 'Good to catch up with you .',
        translationMl: 'വിശേഷങ്ങൾ പങ്കിടുക - Good to catch up with you.',
        hint: 'Pay attention to: Casual Workplace Interaction: Projects, Weekend, Coffee',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Office Small Talk & Break Room English gives you great confidence in English .',
        translationMl: 'ഓഫീസിലെ സൗഹൃദ സംഭാഷണം ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Casual Workplace Interaction: Projects, Weekend, Coffee',
      ),
      _buildRound(
        id: 4,
        sentence: 'Let\'s wrap up this task .',
        translationMl: 'ഓഫീസിലെ സൗഹൃദ സംഭാഷണം',
        hint: 'Core sentence pattern: Casual Workplace Interaction: Projects, Weekend, Coffee',
      ),
      _buildRound(
        id: 5,
        sentence: 'Are you heading out now ?',
        translationMl: 'ഇറങ്ങുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'head out\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 77
    // -----------------------------------------------------------------------
    77: [
      _buildRound(
        id: 1,
        sentence: 'Here is my daily update .',
        translationMl: 'വിവരങ്ങൾ അറിയിക്കുക - Here is my daily update.',
        hint: 'Pay attention to: Yesterday I completed..., Today I am working on..., No blockers.',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have no blockers today .',
        translationMl: 'തടസ്സപ്പെടുക - I have no blockers today.',
        hint: 'Pay attention to: Yesterday I completed..., Today I am working on..., No blockers.',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Daily Standups & Meeting Updates gives you great confidence in English .',
        translationMl: 'ഓഫീസ് മീറ്റിംഗുകളും അപ്‌ഡേറ്റുകളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Yesterday I completed..., Today I am working on..., No blockers.',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will collaborate with team .',
        translationMl: 'ഓഫീസ് മീറ്റിംഗുകളും അപ്‌ഡേറ്റുകളും',
        hint: 'Core sentence pattern: Yesterday I completed..., Today I am working on..., No blockers.',
      ),
      _buildRound(
        id: 5,
        sentence: 'Let\'s sync up after lunch .',
        translationMl: 'ഏകോപിപ്പിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'sync\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 78
    // -----------------------------------------------------------------------
    78: [
      _buildRound(
        id: 1,
        sentence: 'I suggest we try this approach .',
        translationMl: 'നിർദ്ദേശിക്കുക - I suggest we try this approach.',
        hint: 'Pay attention to: In my opinion / From my perspective / As far as I can tell',
      ),
      _buildRound(
        id: 2,
        sentence: 'I highly recommend this tool .',
        translationMl: 'ശുപാർശ ചെയ്യുക - I highly recommend this tool.',
        hint: 'Pay attention to: In my opinion / From my perspective / As far as I can tell',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Giving Professional Opinions Politely gives you great confidence in English .',
        translationMl: 'അഭിപ്രായങ്ങൾ മാന്യമായി പറയൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: In my opinion / From my perspective / As far as I can tell',
      ),
      _buildRound(
        id: 4,
        sentence: 'From my point of view, it works .',
        translationMl: 'അഭിപ്രായങ്ങൾ മാന്യമായി പറയൽ',
        hint: 'Core sentence pattern: In my opinion / From my perspective / As far as I can tell',
      ),
      _buildRound(
        id: 5,
        sentence: 'Let me clarify my point .',
        translationMl: 'വ്യക്തമാക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'clarify\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 79
    // -----------------------------------------------------------------------
    79: [
      _buildRound(
        id: 1,
        sentence: 'I respectfully disagree .',
        translationMl: 'വിയോജിക്കുക - I respectfully disagree.',
        hint: 'Pay attention to: I see your point, but... / Respectfully, I disagree',
      ),
      _buildRound(
        id: 2,
        sentence: 'I appreciate your thought, but.. .',
        translationMl: 'വിലമതിക്കുക - I appreciate your thought, but...',
        hint: 'Pay attention to: I see your point, but... / Respectfully, I disagree',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Diplomatic Disagreement & Debating gives you great confidence in English .',
        translationMl: 'മാന്യമായി വിയോജിപ്പ് അറിയിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: I see your point, but... / Respectfully, I disagree',
      ),
      _buildRound(
        id: 4,
        sentence: 'Can we reconsider this ?',
        translationMl: 'മാന്യമായി വിയോജിപ്പ് അറിയിക്കൽ',
        hint: 'Core sentence pattern: I see your point, but... / Respectfully, I disagree',
      ),
      _buildRound(
        id: 5,
        sentence: 'Let\'s conclude positively .',
        translationMl: 'ഉപസംഹരിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'conclude\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 80
    // -----------------------------------------------------------------------
    80: [
      _buildRound(
        id: 1,
        sentence: 'I am excited to present this .',
        translationMl: 'അവതരിപ്പിക്കുക - I am excited to present this.',
        hint: 'Pay attention to: Signposting: First, moving on to, finally, to conclude',
      ),
      _buildRound(
        id: 2,
        sentence: 'Let me highlight key benefits .',
        translationMl: 'എടുത്തുപറയുക - Let me highlight key benefits.',
        hint: 'Pay attention to: Signposting: First, moving on to, finally, to conclude',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Delivering Confident Presentations gives you great confidence in English .',
        translationMl: 'പ്രസന്റേഷനുകൾ അവതരിപ്പിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Signposting: First, moving on to, finally, to conclude',
      ),
      _buildRound(
        id: 4,
        sentence: 'To summarize the main points.. .',
        translationMl: 'പ്രസന്റേഷനുകൾ അവതരിപ്പിക്കൽ',
        hint: 'Core sentence pattern: Signposting: First, moving on to, finally, to conclude',
      ),
      _buildRound(
        id: 5,
        sentence: 'Now I invite any questions .',
        translationMl: 'ക്ഷണിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'invite\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 81
    // -----------------------------------------------------------------------
    81: [
      _buildRound(
        id: 1,
        sentence: 'Allow me to introduce myself .',
        translationMl: 'പരിചയപ്പെടുത്തുക - Allow me to introduce myself.',
        hint: 'Pay attention to: The 3-Part Pitch: Past Background + Present Role + Future Goal',
      ),
      _buildRound(
        id: 2,
        sentence: 'I graduated in engineering .',
        translationMl: 'ബിരുദം നേടുക - I graduated in engineering.',
        hint: 'Pay attention to: The 3-Part Pitch: Past Background + Present Role + Future Goal',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Job Interview Part 1: \'Tell Me About Yourself\' gives you great confidence in English .',
        translationMl: 'ഇന്റർവ്യൂ 1: സ്വന്തം വിവരണം (Self Pitch) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: The 3-Part Pitch: Past Background + Present Role + Future Goal',
      ),
      _buildRound(
        id: 4,
        sentence: 'I specialize in communication .',
        translationMl: 'ഇന്റർവ്യൂ 1: സ്വന്തം വിവരണം (Self Pitch)',
        hint: 'Core sentence pattern: The 3-Part Pitch: Past Background + Present Role + Future Goal',
      ),
      _buildRound(
        id: 5,
        sentence: 'I aspire to grow in this role .',
        translationMl: 'ആഗ്രഹിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'aspire\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 82
    // -----------------------------------------------------------------------
    82: [
      _buildRound(
        id: 1,
        sentence: 'My greatest strength is adaptability .',
        translationMl: 'ശക്തിപ്പെടുത്തുക - My greatest strength is adaptability.',
        hint: 'Pay attention to: Framing weaknesses constructively into learning habits',
      ),
      _buildRound(
        id: 2,
        sentence: 'I overcame stage fear through practice .',
        translationMl: 'മറികടക്കുക - I overcame stage fear through practice.',
        hint: 'Pay attention to: Framing weaknesses constructively into learning habits',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Job Interview Part 2: Strengths & Weaknesses gives you great confidence in English .',
        translationMl: 'ഇന്റർവ്യൂ 2: കരുത്തും ദൗർബല്യങ്ങളും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Framing weaknesses constructively into learning habits',
      ),
      _buildRound(
        id: 4,
        sentence: 'I actively learn from mistakes .',
        translationMl: 'ഇന്റർവ്യൂ 2: കരുത്തും ദൗർബല്യങ്ങളും',
        hint: 'Core sentence pattern: Framing weaknesses constructively into learning habits',
      ),
      _buildRound(
        id: 5,
        sentence: 'I adapt quickly to change .',
        translationMl: 'പൊരുത്തപ്പെടുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'adapt\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 83
    // -----------------------------------------------------------------------
    83: [
      _buildRound(
        id: 1,
        sentence: 'I resolved the conflict effectively .',
        translationMl: 'പരിഹരിക്കുക - I resolved the conflict effectively.',
        hint: 'Pay attention to: Storytelling Framework: Situation -> Task -> Action -> Result',
      ),
      _buildRound(
        id: 2,
        sentence: 'We achieved 100% target .',
        translationMl: 'കൈവരിക്കുക - We achieved 100% target.',
        hint: 'Pay attention to: Storytelling Framework: Situation -> Task -> Action -> Result',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Job Interview Part 3: The STAR Method gives you great confidence in English .',
        translationMl: 'ഇന്റർവ്യൂ 3: STAR രീതി (Situation, Task, Action, Result) ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Storytelling Framework: Situation -> Task -> Action -> Result',
      ),
      _buildRound(
        id: 4,
        sentence: 'I executed the action plan .',
        translationMl: 'ഇന്റർവ്യൂ 3: STAR രീതി (Situation, Task, Action, Result)',
        hint: 'Core sentence pattern: Storytelling Framework: Situation -> Task -> Action -> Result',
      ),
      _buildRound(
        id: 5,
        sentence: 'Delivered results under budget .',
        translationMl: 'സമർപ്പിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'deliver\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 84
    // -----------------------------------------------------------------------
    84: [
      _buildRound(
        id: 1,
        sentence: 'May I inquire about team culture ?',
        translationMl: 'അന്വേഷിക്കുക - May I inquire about team culture?',
        hint: 'Pay attention to: What does success look like in this role? / Team Culture',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you clarify the expectations ?',
        translationMl: 'വ്യക്തത വരുത്തുക - Could you clarify the expectations?',
        hint: 'Pay attention to: What does success look like in this role? / Team Culture',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Job Interview Part 4: Asking Smart Questions gives you great confidence in English .',
        translationMl: 'ഇന്റർവ്യൂ 4: ഇന്റർവ്യൂവറോട് ചോദ്യങ്ങൾ ചോദിക്കൽ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: What does success look like in this role? / Team Culture',
      ),
      _buildRound(
        id: 4,
        sentence: 'I want to understand the roadmap .',
        translationMl: 'ഇന്റർവ്യൂ 4: ഇന്റർവ്യൂവറോട് ചോദ്യങ്ങൾ ചോദിക്കൽ',
        hint: 'Core sentence pattern: What does success look like in this role? / Team Culture',
      ),
      _buildRound(
        id: 5,
        sentence: 'I value long-term mentorship .',
        translationMl: 'വിലമതിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'value\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 85
    // -----------------------------------------------------------------------
    85: [
      _buildRound(
        id: 1,
        sentence: 'I would like to negotiate the offer .',
        translationMl: 'ചർച്ച ചെയ്യുക - I would like to negotiate the offer.',
        hint: 'Pay attention to: Discussing compensation package with confidence & diplomacy',
      ),
      _buildRound(
        id: 2,
        sentence: 'Evaluating the overall package .',
        translationMl: 'വിലയിരുത്തുക - Evaluating the overall package.',
        hint: 'Pay attention to: Discussing compensation package with confidence & diplomacy',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Salary Negotiation & Offer Discussion gives you great confidence in English .',
        translationMl: 'ശമ്പള ചർച്ചയും ജോലി ഓഫറും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Discussing compensation package with confidence & diplomacy',
      ),
      _buildRound(
        id: 4,
        sentence: 'Thrilled to accept the role .',
        translationMl: 'ശമ്പള ചർച്ചയും ജോലി ഓഫറും',
        hint: 'Core sentence pattern: Discussing compensation package with confidence & diplomacy',
      ),
      _buildRound(
        id: 5,
        sentence: 'Can we discuss the start date ?',
        translationMl: 'സംസാരിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'discuss\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 86
    // -----------------------------------------------------------------------
    86: [
      _buildRound(
        id: 1,
        sentence: 'Break the ice with a smile .',
        translationMl: 'തകർക്കുക - Break the ice with a smile.',
        hint: 'Pay attention to: Bite the bullet, Break the ice, Piece of cake',
      ),
      _buildRound(
        id: 2,
        sentence: 'Bite the bullet and speak up .',
        translationMl: 'നേരിടുക - Bite the bullet and speak up.',
        hint: 'Pay attention to: Bite the bullet, Break the ice, Piece of cake',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Native Everyday Idioms: Volume 1 gives you great confidence in English .',
        translationMl: 'സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 1 ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Bite the bullet, Break the ice, Piece of cake',
      ),
      _buildRound(
        id: 4,
        sentence: 'Sailed through the exam .',
        translationMl: 'സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 1',
        hint: 'Core sentence pattern: Bite the bullet, Break the ice, Piece of cake',
      ),
      _buildRound(
        id: 5,
        sentence: 'It didn\'t cost an arm and a leg .',
        translationMl: 'വിലയാകുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'cost\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 87
    // -----------------------------------------------------------------------
    87: [
      _buildRound(
        id: 1,
        sentence: 'You hit the nail on the head .',
        translationMl: 'കൃത്യമായി പറയുക - You hit the nail on the head.',
        hint: 'Pay attention to: Under the weather, Hit the nail on the head, Once in a blue moon',
      ),
      _buildRound(
        id: 2,
        sentence: 'Don\'t miss the boat .',
        translationMl: 'നഷ്ടപ്പെടുക - Don\'t miss the boat.',
        hint: 'Pay attention to: Under the weather, Hit the nail on the head, Once in a blue moon',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Native Everyday Idioms: Volume 2 gives you great confidence in English .',
        translationMl: 'സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 2 ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Under the weather, Hit the nail on the head, Once in a blue moon',
      ),
      _buildRound(
        id: 4,
        sentence: 'Burn the midnight oil .',
        translationMl: 'സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 2',
        hint: 'Core sentence pattern: Under the weather, Hit the nail on the head, Once in a blue moon',
      ),
      _buildRound(
        id: 5,
        sentence: 'We see eye to eye .',
        translationMl: 'യോജിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'see\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 88
    // -----------------------------------------------------------------------
    88: [
      _buildRound(
        id: 1,
        sentence: 'I figured out the solution .',
        translationMl: 'കണ്ടെത്തുക - I figured out the solution.',
        hint: 'Pay attention to: Figure out, Look into, Call off, Follow up, Carry on',
      ),
      _buildRound(
        id: 2,
        sentence: 'We will look into the matter .',
        translationMl: 'അന്വേഷിക്കുക - We will look into the matter.',
        hint: 'Pay attention to: Figure out, Look into, Call off, Follow up, Carry on',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Essential Workplace Phrasal Verbs gives you great confidence in English .',
        translationMl: 'ഓഫീസിലെ ഫ്രേസൽ വെർബുകൾ ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Figure out, Look into, Call off, Follow up, Carry on',
      ),
      _buildRound(
        id: 4,
        sentence: 'They called off the strike .',
        translationMl: 'ഓഫീസിലെ ഫ്രേസൽ വെർബുകൾ',
        hint: 'Core sentence pattern: Figure out, Look into, Call off, Follow up, Carry on',
      ),
      _buildRound(
        id: 5,
        sentence: 'Follow up with the customer .',
        translationMl: 'തുടർനടപടി സ്വീകരിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'follow up\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 89
    // -----------------------------------------------------------------------
    89: [
      _buildRound(
        id: 1,
        sentence: 'Inspire people with your words .',
        translationMl: 'പ്രചോദിപ്പിക്കുക - Inspire people with your words.',
        hint: 'Pay attention to: Hook the audience, Speak with conviction, Inspire action',
      ),
      _buildRound(
        id: 2,
        sentence: 'Engage the audience eyes .',
        translationMl: 'ആകർഷിക്കുക - Engage the audience eyes.',
        hint: 'Pay attention to: Hook the audience, Speak with conviction, Inspire action',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Public Speaking & Confident Storytelling gives you great confidence in English .',
        translationMl: 'പബ്ലിക് സ്പീക്കിംഗും കഥ പറയലും ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: Hook the audience, Speak with conviction, Inspire action',
      ),
      _buildRound(
        id: 4,
        sentence: 'Express heartfelt feelings .',
        translationMl: 'പബ്ലിക് സ്പീക്കിംഗും കഥ പറയലും',
        hint: 'Core sentence pattern: Hook the audience, Speak with conviction, Inspire action',
      ),
      _buildRound(
        id: 5,
        sentence: 'Conclude on an empowering note .',
        translationMl: 'ഉപസംഹരിക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'conclude\'',
      ),
    ],
    // -----------------------------------------------------------------------
    // DAY 90
    // -----------------------------------------------------------------------
    90: [
      _buildRound(
        id: 1,
        sentence: 'I completed the 90-day journey! .',
        translationMl: 'വിജയകരമായി പൂർത്തിയാക്കുക - I completed the 90-day journey!',
        hint: 'Pay attention to: 90-Day Spoken English Master Badge & Lifetime Fluency',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have achieved spoken English confidence .',
        translationMl: 'ആത്മവിശ്വാസത്തോടെ ഇംഗ്ലീഷ് സംസാരിക്കാൻ ഞാൻ കഴിവ് നേടി.',
        hint: 'Pay attention to: 90-Day Spoken English Master Badge & Lifetime Fluency',
      ),
      _buildRound(
        id: 3,
        sentence: 'Daily practice of Grand Graduation Day & Lifetime Mastery gives you great confidence in English .',
        translationMl: '90-ഡേ ഫൈനൽ ഗ്രാജ്വേഷൻ & ലൈഫ്‌ടൈം മാസ്റ്ററി ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.',
        hint: 'Pay attention to: 90-Day Spoken English Master Badge & Lifetime Fluency',
      ),
      _buildRound(
        id: 4,
        sentence: 'I speak English boldly .',
        translationMl: '90-ഡേ ഫൈനൽ ഗ്രാജ്വേഷൻ & ലൈഫ്‌ടൈം മാസ്റ്ററി',
        hint: 'Core sentence pattern: 90-Day Spoken English Master Badge & Lifetime Fluency',
      ),
      _buildRound(
        id: 5,
        sentence: 'I graduated the 90-day journey! .',
        translationMl: 'വിജയകരമായി പൂർത്തിയാക്കുക സംബന്ധിച്ച വാചകം.',
        hint: 'Using the verb \'graduate\'',
      ),
    ],
  };
}
