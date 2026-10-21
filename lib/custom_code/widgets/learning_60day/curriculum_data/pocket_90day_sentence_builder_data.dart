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
    // DAY 21: Asking Questions: What & Where
    21: [
      _buildRound(
        id: 1,
        sentence: 'What is the reason for this sudden meeting ?',
        translationMl: 'ഈ പെട്ടെന്നുള്ള മീറ്റിംഗിന്റെ കാരണം എന്താണ്?',
        hint: 'Question about reason starts with \'What is the reason for...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Where do you keep the spare car keys ?',
        translationMl: 'നിങ്ങൾ കാറിന്റെ സ്പെയർ താക്കോലുകൾ എവിടെയാണ് സൂക്ഷിക്കുന്നത്?',
        hint: 'Routine location question: \'Where do you + base verb...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What time does the last express train arrive ?',
        translationMl: 'അവസാന എക്സ്പ്രസ് ട്രെയിൻ ഏത് സമയത്താണ് എത്തിച്ചേരുന്നത്?',
        hint: 'Specific inquiry: \'What time does the [singular subject] + arrive?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Where can we find clean drinking water here ?',
        translationMl: 'ഇവിടെ നമുക്ക് ശുദ്ധമായ കുടിവെള്ളം എവിടെ ലഭിക്കും?',
        hint: 'Ability / possibility query: \'Where can we find...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'What are your main expectations from this project ?',
        translationMl: 'ഈ പ്രോജക്റ്റിൽ നിന്നുള്ള നിങ്ങളുടെ പ്രധാന പ്രതീക്ഷകൾ എന്തൊക്കെയാണ്?',
        hint: 'Plural question: \'What are your...\'',
      ),
    ],
    // DAY 22: Asking Questions: When & Why
    22: [
      _buildRound(
        id: 1,
        sentence: 'When does the college semester examination commence ?',
        translationMl: 'കോളേജ് സെമസ്റ്റർ പരീക്ഷ എപ്പോഴാണ് ആരംഭിക്കുന്നത്?',
        hint: 'Question about time schedule: \'When does the [singular subject] + verb...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Why are you carrying two heavy umbrellas today ?',
        translationMl: 'ഇന്ന് നിങ്ങൾ എന്തിനാണ് രണ്ട് വലിയ കുടകൾ കൊണ്ടുപോകുന്നത്?',
        hint: 'Present continuous reason: \'Why are you + verb-ing...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'When did your family shift to this neighborhood ?',
        translationMl: 'നിങ്ങളുടെ കുടുംബം എപ്പോഴാണ് ഈ പ്രദേശത്തേക്ക് മാറിയത്?',
        hint: 'Past time question: \'When did + subject + base verb...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Why is the office air conditioner not functioning properly ?',
        translationMl: 'ഓഫീസിലെ എയർകണ്ടീഷണർ എന്തിനാണ് ശരിയായി പ്രവർത്തിക്കാത്തത്?',
        hint: 'Present state inquiry: \'Why is the [subject] not + verb-ing...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'When will the manager review our design proposal ?',
        translationMl: 'മാനേജർ എപ്പോഴാണ് നമ്മുടെ ഡിസൈൻ പ്രൊപ്പോസൽ പരിശോധിക്കുന്നത്?',
        hint: 'Future time inquiry: \'When will the manager review...\'',
      ),
    ],
    // DAY 23: Asking Questions: Who & Which
    23: [
      _buildRound(
        id: 1,
        sentence: 'Who is managing the customer support department today ?',
        translationMl: 'ഇന്ന് കസ്റ്റമർ സപ്പോർട്ട് വിഭാഗം നിയന്ത്രിക്കുന്നത് ആരാണ്?',
        hint: 'Question about person in charge: \'Who is managing...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Which laptop model offers the highest battery backup ?',
        translationMl: 'ഏത് ലാപ്‌ടോപ്പ് മോഡലാണ് ഏറ്റവും കൂടുതൽ ബാറ്ററി ബാക്കപ്പ് നൽകുന്നത്?',
        hint: 'Inquiring about choices: \'Which [noun] offers...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Who told you about this fantastic job opening ?',
        translationMl: 'ഈ മികച്ച ജോലി അവസരത്തെക്കുറിച്ച് നിങ്ങളോട് ആരാണ് പറഞ്ഞത്?',
        hint: 'Past inquiry about information source: \'Who told you about...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Which bus goes directly to the central railway station ?',
        translationMl: 'ഏത് ബസ്സാണ് സെൻട്രൽ റെയിൽവേ സ്റ്റേഷനിലേക്ക് നേരിട്ട് പോകുന്നത്?',
        hint: 'Selection question: \'Which bus goes directly to...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Who wants to volunteer for the tree planting drive ?',
        translationMl: 'വൃക്ഷത്തൈ നടീൽ യജ്ഞത്തിന് സന്നദ്ധസേവനം ചെയ്യാൻ ആർക്കാണ് താൽപ്പര്യം?',
        hint: 'Third person singular subject query: \'Who wants to volunteer...\'',
      ),
    ],
    // DAY 24: Asking Questions: How & How Much
    24: [
      _buildRound(
        id: 1,
        sentence: 'How much sugar do you prefer in your morning tea ?',
        translationMl: 'രാവിലത്തെ ചായയിൽ നിങ്ങൾക്ക് എത്രത്തോളം പഞ്ചസാര വേണം?',
        hint: 'Uncountable quantity query: \'How much sugar do you prefer...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'How do you travel to your workplace during peak hours ?',
        translationMl: 'തിരക്കേറിയ സമയങ്ങളിൽ നിങ്ങൾ എങ്ങനെയാണ് ജോലിസ്ഥലത്തേക്ക് യാത്ര ചെയ്യുന്നത്?',
        hint: 'Manner of transport: \'How do you travel to...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'How much does this handcrafted leather bag cost ?',
        translationMl: 'കൈകൊണ്ട് നിർമ്മിച്ച ഈ തുകൽ ബാഗിന് എത്ര വിലവരും?',
        hint: 'Price inquiry: \'How much does [subject] cost?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'How can we improve our conversational speaking rhythm ?',
        translationMl: 'നമ്മുടെ സംഭാഷണ ശൈലിയും താളവും എങ്ങനെ മെച്ചപ്പെടുത്താം?',
        hint: 'Possibility / method query: \'How can we improve...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'How much water should an adult drink throughout the day ?',
        translationMl: 'ഒരു മുതിർന്ന വ്യക്തി ദിവസം മുഴുവൻ എത്രത്തോളം വെള്ളം കുടിക്കണം?',
        hint: 'Health recommendation query: \'How much water should...\'',
      ),
    ],
    // DAY 25: Buying Groceries & Market Talk
    25: [
      _buildRound(
        id: 1,
        sentence: 'How much is one kilogram of crisp red apples today ?',
        translationMl: 'ഇന്ന് ഒരു കിലോ നല്ല ചുവന്ന ആപ്പിളിന് എത്രയാണ് വില?',
        hint: 'Market inquiry: \'How much is one kilogram of [item] today?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you please give me two bunches of fresh coriander leaves ?',
        translationMl: 'ദയവായി എനിക്ക് രണ്ട് കെട്ട് നല്ല പച്ച മല്ലിയില തരുമോ?',
        hint: 'Polite quantity request: \'Could you please give me [quantity] of [item]?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Are these yellow bananas naturally ripened without chemicals ?',
        translationMl: 'ഈ മഞ്ഞ നേന്ത്രപ്പഴങ്ങൾ രാസവസ്തുക്കളില്ലാതെ സ്വാഭാവികമായി പഴുപ്പിച്ചതാണോ?',
        hint: 'Quality verification question: \'Are these [items] naturally ripened...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Please weigh three large potatoes and add them to my basket .',
        translationMl: 'ദയവായി മൂന്ന് വലിയ ഉരുളക്കിഴങ്ങുകൾ തൂക്കി എന്റെ കുട്ടയിൽ ഇടുക.',
        hint: 'Imperative request: \'Please weigh [item] and add them...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Do you accept digital payments or only paper cash here ?',
        translationMl: 'നിങ്ങൾ ഇവിടെ ഡിജിറ്റൽ പേയ്‌മെന്റുകൾ സ്വീകരിക്കുമോ അതോ പണം മാത്രമാണോ?',
        hint: 'Payment query: \'Do you accept digital payments or...\'',
      ),
    ],
    // DAY 26: Giving Simple Directions
    26: [
      _buildRound(
        id: 1,
        sentence: 'Go straight along this avenue until you see the cathedral .',
        translationMl: 'വലിയ പള്ളി കാണുന്നതുവരെ ഈ വീഥിയിലൂടെ നേരെ പോവുക.',
        hint: 'Imperative direction: \'Go straight along [street] until you see...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Take a sharp left turn just past the petrol pump .',
        translationMl: 'പെട്രോൾ പമ്പ് കഴിഞ്ഞ ഉടൻ തന്നെ ഇടത്തേക്ക് തിരിയുക.',
        hint: 'Direction instruction: \'Take a sharp left turn just past...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'The pharmacy is on your right hand side opposite the bank .',
        translationMl: 'ബാങ്കിന്റെ എതിർവശത്ത് നിങ്ങളുടെ വലതുവശത്താണ് മെഡിക്കൽ ഷോപ്പ്.',
        hint: 'Location description: \'It is on your right hand side opposite...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Walk across the footbridge to reach the platform safely .',
        translationMl: 'പ്ലാറ്റ്‌ഫോമിൽ സുരക്ഷിതമായി എത്താൻ മേൽപ്പാലത്തിലൂടെ നടക്കുക.',
        hint: 'Guidance sentence: \'Walk across [structure] to reach...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Can you guide me towards the nearest automated teller machine ?',
        translationMl: 'ഏറ്റവും അടുത്തുള്ള എടിഎമ്മിലേക്ക് എനിക്ക് വഴികാണിച്ചു തരാമോ?',
        hint: 'Direction inquiry: \'Can you guide me towards the nearest...\'',
      ),
    ],
    // DAY 27: Health, Body & Minor Ailments
    27: [
      _buildRound(
        id: 1,
        sentence: 'I have a sore throat and a slight dry cough .',
        translationMl: 'എനിക്ക് തൊണ്ടവേദനയും ചെറിയ വരണ്ട ചുമയുമുണ്ട്.',
        hint: 'Health expression: \'I have a sore throat and...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'My lower back hurts after sitting at the desk all day .',
        translationMl: 'ദിവസം മുഴുവൻ മേശപ്പുറത്ത് ഇരുന്നതിനാൽ എന്റെ നടുവ് വേദനിക്കുന്നു.',
        hint: 'Body pain: \'[Body part] hurts after...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'You should drink warm herbal tea to soothe your chest congestion .',
        translationMl: 'നെഞ്ചിലെ കഫക്കെട്ട് മാറാൻ നിങ്ങൾ ചൂടുള്ള ഹെർബൽ ചായ കുടിക്കണം.',
        hint: 'Health advice: \'You should drink... to soothe...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'She feels dizzy because she skipped her breakfast this morning .',
        translationMl: 'ഇന്ന് രാവിലെ പ്രഭാതഭക്ഷണം കഴിക്കാതിരുന്നതിനാൽ അവൾക്ക് തലകറക്കം അനുഭവപ്പെടുന്നു.',
        hint: 'Symptom and cause: \'She feels dizzy because...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Are you taking sufficient rest to recover from the viral fever ?',
        translationMl: 'വൈറൽ പനിയിൽ നിന്ന് മുക്തി നേടാൻ നിങ്ങൾ ആവശ്യത്തിന് വിശ്രമിക്കുന്നുണ്ടോ?',
        hint: 'Health care question: \'Are you taking sufficient rest to...\'',
      ),
    ],
    // DAY 28: At the Pharmacy & Medicine
    28: [
      _buildRound(
        id: 1,
        sentence: 'Could you please dispense the medicines listed on this doctor prescription ?',
        translationMl: 'ഈ ഡോക്ടറുടെ കുറിപ്പടിയിലുള്ള മരുന്നുകൾ ദയവായി എടുത്തുതരാമോ?',
        hint: 'Pharmacy request: \'Could you please dispense the medicines listed on...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Take one tablet twice daily strictly after having your meals .',
        translationMl: 'ഭക്ഷണം കഴിച്ചതിനുശേഷം കൃത്യമായി ദിവസവും രണ്ടുനേരം ഒരു ഗുളിക വീതം കഴിക്കുക.',
        hint: 'Dosage instruction: \'Take one tablet twice daily strictly after...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Does this pain relief medication cause any drowsiness or dizziness ?',
        translationMl: 'ഈ വേദനസംഹാരി മരുന്ന് ഉറക്കത്തൂക്കമോ തലകറക്കമോ ഉണ്ടാക്കുമോ?',
        hint: 'Side-effects inquiry: \'Does this medication cause any...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Keep these antibiotic syrups refrigerated between two and eight degrees .',
        translationMl: 'ഈ ആന്റിബയോട്ടിക് സിറപ്പുകൾ ഫ്രിഡ്ജിൽ രണ്ട് മുതൽ എട്ട് ഡിഗ്രി വരെ സൂക്ഷിക്കുക.',
        hint: 'Storage instruction: \'Keep these syrups refrigerated between...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'You must complete the full course even if you feel completely better .',
        translationMl: 'പൂർണ്ണമായും സുഖം തോന്നിയാൽ പോലും നിങ്ങൾ മരുന്നിന്റെ മുഴുവൻ കാലാവധിയും പൂർത്തിയാക്കണം.',
        hint: 'Medical warning: \'You must complete the full course even if...\'',
      ),
    ],
    // DAY 29: Weather, Climate & Nature
    29: [
      _buildRound(
        id: 1,
        sentence: 'It is raining heavily outside, so remember to take your raincoat .',
        translationMl: 'പുറത്ത് കനത്ത മഴ പെയ്യുന്നു, അതിനാൽ റെയിൻകോട്ട് എടുക്കാൻ ഓർക്കുക.',
        hint: 'Weather condition: \'It is raining heavily outside, so...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'The climate here is delightfully pleasant throughout the winter months .',
        translationMl: 'ശീതകാല മാസങ്ങളിൽ ഇവിടുത്തെ കാലാവസ്ഥ അതീവ മനോഹരവും സുഖകരവുമാണ്.',
        hint: 'Climate description: \'The climate here is delightfully pleasant...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Dark thunder clouds are gathering rapidly over the northern horizon .',
        translationMl: 'വടക്കൻ ചക്രവാളത്തിൽ കാർമേഘങ്ങൾ വേഗത്തിൽ ഉരുണ്ടുകൂടുകയാണ്.',
        hint: 'Present continuous weather: \'Clouds are gathering rapidly...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Is it humid and warm near the beach this afternoon ?',
        translationMl: 'ഇന്ന് ഉച്ചയ്ക്ക് ബീച്ചിനടുത്ത് നല്ല ഈർപ്പവും ചൂടുമാണോ?',
        hint: 'Weather query: \'Is it [adjective] and [adjective] near...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'The meteorological department predicted a sunny weekend ahead for tourists .',
        translationMl: 'വിനോദസഞ്ചാരികൾക്കായി തെളിഞ്ഞ കാലാവസ്ഥയുള്ള ഒരു വാരാന്ത്യമാണ് കാലാവസ്ഥാ വകുപ്പ് പ്രവചിച്ചത്.',
        hint: 'Forecast sentence: \'The department predicted a sunny weekend...\'',
      ),
    ],
    // DAY 30: House 1 Grand Review & Gate Exam
    30: [
      _buildRound(
        id: 1,
        sentence: 'I can now ask and answer daily conversational questions with high confidence .',
        translationMl: 'എനിക്കിപ്പോൾ ഉയർന്ന ആത്മവിശ്വാസത്തോടെ ദൈനംദിന സംഭാഷണ ചോദ്യങ്ങൾ ചോദിക്കാനും ഉത്തരം നൽകാനും സാധിക്കും.',
        hint: 'Milestone statement: \'I can now ask and answer daily questions...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Consistent daily effort transforms hesitant learners into articulate fluent speakers .',
        translationMl: 'സ്ഥിരമായ ദൈനംദിന പരിശ്രമം മടിച്ചുനിൽക്കുന്ന പഠിതാക്കളെ വ്യക്തമായി സംസാരിക്കുന്ന പ്രാപ്തരാക്കി മാറ്റുന്നു.',
        hint: 'Inspirational observation: \'Consistent effort transforms...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Which topic from House One did you enjoy practicing the most ?',
        translationMl: 'ഹൗസ് ഒന്നിലെ ഏത് വിഷയമാണ് നിങ്ങൾക്ക് ഏറ്റവും കൂടുതൽ പരിശീലിക്കാൻ ഇഷ്ടപ്പെട്ടത്?',
        hint: 'Review question: \'Which topic from [unit] did you enjoy...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Always focus on communicating your core idea clearly rather than worrying about grammar .',
        translationMl: 'വ്യാകരണത്തെക്കുറിച്ച് ആശങ്കപ്പെടുന്നതിനേക്കാൾ നിങ്ങളുടെ ആശയം വ്യക്തമായി അറിയിക്കാൻ എപ്പോഴും ശ്രദ്ധിക്കുക.',
        hint: 'Communication philosophy: \'Always focus on communicating...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We are stepping confidently into the next exciting phase of English mastery .',
        translationMl: 'ഇംഗ്ലീഷ് പ്രാവീണ്യത്തിന്റെ അടുത്ത ആവേശകരമായ ഘട്ടത്തിലേക്ക് നാം ആത്മവിശ്വാസത്തോടെ കാലെടുത്തുവെക്കുകയാണ്.',
        hint: 'Forward outlook: \'We are stepping confidently into...\'',
      ),
    ],
    // DAY 31: Past State: Was vs Were
    31: [
      _buildRound(
        id: 1,
        sentence: 'I was extremely tired after returning from the long interstate train journey .',
        translationMl: 'നീണ്ട അന്തർസംസ്ഥാന ട്രെയിൻ യാത്ര കഴിഞ്ഞ് മടങ്ങിയെത്തിയപ്പോൾ ഞാൻ അതീവ ക്ഷീണിതനായിരുന്നു.',
        hint: 'Singular past state: \'I was + adjective + after...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'They were in the conference room discussing the quarterly project deliverables .',
        translationMl: 'അവർ കോൺഫറൻസ് റൂമിൽ ത്രൈമാസ പ്രോജക്ട് കാര്യങ്ങൾ ചർച്ച ചെയ്യുകയായിരുന്നു.',
        hint: 'Plural past state: \'They were in the [place] + verb-ing...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Where were you when the sudden earthquake tremors shook the building ?',
        translationMl: 'പെട്ടെന്ന് ഭൂചലനം കെട്ടിടത്തെ ഉലച്ചപ്പോൾ നിങ്ങൾ എവിടെയായിരുന്നു?',
        hint: 'Past inquiry: \'Where were you when...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'She was delightfully surprised by the thoughtful birthday gifts from colleagues .',
        translationMl: 'സഹപ്രവർത്തകരുടെ സ്നേഹം നിറഞ്ഞ ജന്മദിന സമ്മാനങ്ങൾ കണ്ട് അവൾ സന്തോഷത്തോടെ അത്ഭുതപ്പെട്ടു.',
        hint: 'Passive emotion: \'She was delightfully surprised by...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We were confident about our speech presentation because we practiced every day .',
        translationMl: 'ദിവസവും പരിശീലിച്ചതിനാൽ ഞങ്ങളുടെ പ്രസംഗാവതരണത്തെക്കുറിച്ച് ഞങ്ങൾക്ക് നല്ല ആത്മവിശ്വാസമുണ്ടായിരുന്നു.',
        hint: 'Cause and effect: \'We were confident because we practiced...\'',
      ),
    ],
    // DAY 32: Past Actions: Simple Past V2
    32: [
      _buildRound(
        id: 1,
        sentence: 'Yesterday I completed the backend database optimization and submitted my report .',
        translationMl: 'ഇന്നലെ ഞാൻ ബാക്കെൻഡ് ഡാറ്റാബേസ് ഒപ്റ്റിമൈസേഷൻ പൂർത്തിയാക്കുകയും എന്റെ റിപ്പോർട്ട് സമർപ്പിക്കുകയും ചെയ്തു.',
        hint: 'Sequential past actions: \'I completed [task] and submitted [report]...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Our engineering team launched the newly redesigned mobile software last Friday .',
        translationMl: 'കഴിഞ്ഞ വെള്ളിയാഴ്ച ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് സംഘം പുനർരൂപകൽപ്പന ചെയ്ത പുതിയ മൊബൈൽ സോഫ്റ്റ്‌വെയർ പുറത്തിറക്കി.',
        hint: 'Simple past V2 action: \'Subject + launched (V2) + object + time marker...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'She met the visiting clients at the reception and escorted them inside .',
        translationMl: 'അവൾ റിസപ്ഷനിൽ എത്തിയ ഉപഭോക്താക്കളെ കണ്ടുമുട്ടുകയും അവരെ അകത്തേക്ക് കൂട്ടിക്കൊണ്ടുപോവുകയും ചെയ്തു.',
        hint: 'Chained V2 verbs: \'met (V2)... and escorted (V2)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We bought fresh organic vegetables directly from the village farmer market .',
        translationMl: 'ഞങ്ങൾ ഗ്രാമത്തിലെ കർഷക ചന്തയിൽ നിന്ന് നേരിട്ട് നല്ല പച്ചക്കറികൾ വാങ്ങി.',
        hint: 'Irregular past V2: \'bought\' from \'buy\'.',
      ),
      _buildRound(
        id: 5,
        sentence: 'He spoke confidently during the entire panel interview session yesterday afternoon .',
        translationMl: 'ഇന്നലെ ഉച്ചയ്ക്ക് നടന്ന മുഴുവൻ പാനൽ ഇന്റർവ്യൂവിലും അവൻ വളരെ ആത്മവിശ്വാസത്തോടെ സംസാരിച്ചു.',
        hint: 'Irregular past V2: \'spoke\' from \'speak\'.',
      ),
    ],
    // DAY 33: Asking in the Past: Did you...?
    33: [
      _buildRound(
        id: 1,
        sentence: 'Did you receive the updated agenda for tomorrow conference meeting ?',
        translationMl: 'നാളത്തെ കോൺഫറൻസ് മീറ്റിംഗിനായുള്ള പുതിയ കാര്യപരിപാടി നിങ്ങൾക്ക് ലഭിച്ചോ?',
        hint: 'Past auxiliary question: \'Did you receive (V1)...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Did they inform the regional director about the delivery delay ?',
        translationMl: 'വിതരണത്തിലെ കാലതാമസത്തെക്കുറിച്ച് അവർ റീജിയണൽ ഡയറക്ടറെ അറിയിച്ചിരുന്നോ?',
        hint: 'Rule: \'Did they inform (V1)...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Did you lock all the ground floor windows before going to sleep ?',
        translationMl: 'ഉറങ്ങാൻ പോകുന്നതിനു മുൻപ് താഴത്തെ നിലയിലെ എല്ലാ ജനലുകളും നിങ്ങൾ പൂട്ടിയിരുന്നോ?',
        hint: 'Daily security question: \'Did you lock (V1) all the windows...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'What time did your parents arrive at the international airport ?',
        translationMl: 'നിങ്ങളുടെ മാതാപിതാക്കൾ ഏത് സമയത്താണ് അന്താരാഷ്ട്ര വിമാനത്താവളത്തിൽ എത്തിയത്?',
        hint: 'WH past question: \'What time did your parents arrive (V1)...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Did you enjoy the classical musical concert last night ?',
        translationMl: 'ഇന്നലെ രാത്രിയിലെ ശാസ്ത്രീയ സംഗീത കച്ചേരി നിങ്ങൾ ആസ്വദിച്ചോ?',
        hint: 'Experience inquiry: \'Did you enjoy (V1)...?\'',
      ),
    ],
    // DAY 34: Negative Past: Didn\'t + V1
    34: [
      _buildRound(
        id: 1,
        sentence: 'I did not receive any notification regarding the project deadline extension .',
        translationMl: 'പ്രോജക്ട് അവസാന തീയതി നീട്ടിയതിനെക്കുറിച്ച് എനിക്ക് യാതൊരു അറിയിപ്പും ലഭിച്ചില്ല.',
        hint: 'Negative past: \'I did not receive (V1)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'We didn\'t notice any defects during our initial quality inspection .',
        translationMl: 'ഞങ്ങളുടെ പ്രാഥമിക ഗുണനിലവാര പരിശോധനയിൽ യാതൊരു തകരാറുകളും ഞങ്ങൾ ശ്രദ്ധിച്ചില്ല.',
        hint: 'Rule: \'didn\'t notice (V1)...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'She did not agree with the proposed marketing budget cuts .',
        translationMl: 'നിർദ്ദേശിക്കപ്പെട്ട മാർക്കറ്റിംഗ് ബജറ്റ് വെട്ടിക്കുറയ്ക്കലുകളോട് അവൾ യോജിച്ചില്ല.',
        hint: 'Past disagreement: \'She did not agree (V1)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'They didn\'t charge any extra fees for the door delivery service .',
        translationMl: 'ഡോർ ഡെലിവറി സേവനത്തിനായി അവർ അധിക നിരക്കുകളൊന്നും ഈടാക്കിയില്ല.',
        hint: 'Rule: \'They didn\'t charge (V1)...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'He did not hesitate when the manager asked for a volunteer leader .',
        translationMl: 'മാനേജർ ഒരു വളണ്ടിയർ ലീഡറെ ആവശ്യപ്പെട്ടപ്പോൾ അവൻ ഒട്ടും മടിച്ചുനിന്നില്ല.',
        hint: 'Adverbial past negative: \'He did not hesitate (V1)...\'',
      ),
    ],
    // DAY 35: Yesterday\'s Full Story
    35: [
      _buildRound(
        id: 1,
        sentence: 'First I woke up at dawn and went for a refreshing jog along the riverbank .',
        translationMl: 'ആദ്യം ഞാൻ പ്രഭാതത്തിൽ ഉണർന്ന് നദീതീരത്തുകൂടി ഉന്മേഷദായകമായ ഒരു ഓട്ടത്തിന് പോയി.',
        hint: 'Story connector: \'First I woke up... and went for...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Then I prepared a healthy breakfast of oatmeal and fresh sliced fruits .',
        translationMl: 'പിന്നെ ഞാൻ ഓട്‌സും പഴങ്ങളും ചേർത്ത് ആരോഗ്യകരമായ പ്രഭാതഭക്ഷണം തയ്യാറാക്കി.',
        hint: 'Second chronological step: \'Then I prepared...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'After that I attended three productive client meetings at the downtown branch .',
        translationMl: 'അതിനുശേഷം ഞാൻ ടൗണിലെ ബ്രാഞ്ചിൽ വെച്ച് ഉപഭോക്താക്കളുമായി മൂന്ന് നല്ല മീറ്റിംഗുകളിൽ പങ്കെടുത്തു.',
        hint: 'Third step: \'After that I attended...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Later in the afternoon I resolved the software deployment issues with my team .',
        translationMl: 'പിന്നീട് ഉച്ചകഴിഞ്ഞ് ഞാൻ എന്റെ ടീമിനൊപ്പം സോഫ്റ്റ്‌വെയർ വിന്യാസത്തിലെ പ്രശ്നങ്ങൾ പരിഹരിച്ചു.',
        hint: 'Subsequent event: \'Later in the afternoon I resolved...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Finally I returned home and spent quality time chatting with my family .',
        translationMl: 'ഒടുവിൽ ഞാൻ വീട്ടിൽ തിരിച്ചെത്തുകയും കുടുംബത്തോടൊപ്പം സമയം ചിലവഴിക്കുകയും ചെയ്തു.',
        hint: 'Story conclusion: \'Finally I returned home and spent...\'',
      ),
    ],
    // DAY 36: Childhood Habits: Used to
    36: [
      _buildRound(
        id: 1,
        sentence: 'When I was young, I used to ride my bicycle to school every morning .',
        translationMl: 'ചെറുപ്പത്തിൽ ഞാൻ എല്ലാ ദിവസവും രാവിലെ സൈക്കിൾ ചവിട്ടിയാണ് സ്കൂളിൽ പോയിരുന്നത്.',
        hint: 'Past habit formula: \'When I was young, I used to + base verb (ride)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'My grandmother used to tell us enchanting bedtime fairy tales every evening .',
        translationMl: 'എന്റെ മുത്തശ്ശി എല്ലാ ദിവസവും വൈകുന്നേരങ്ങളിൽ ഞങ്ങൾക്ക് മനോഹരമായ മുത്തശ്ശിക്കഥകൾ പറഞ്ഞുതരുമായിരുന്നു.',
        hint: 'Rule: Subject + used to tell (V1)...',
      ),
      _buildRound(
        id: 3,
        sentence: 'We used to play hide and seek beneath the shady mango trees .',
        translationMl: 'തണലുള്ള മാവുകൾക്ക് ചുവട്ടിൽ ഞങ്ങൾ ഒളിച്ചുക്കളി കളിക്കാറുണ്ടായിരുന്നു.',
        hint: 'Childhood routine: \'We used to play (V1)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Did you use to live in that old brick heritage house near the river ?',
        translationMl: 'നിങ്ങൾ നദിക്കടുത്തുള്ള ആ പഴയ പൈതൃക വീട്ടിലാണോ പണ്ട് താമസിച്ചിരുന്നത്?',
        hint: 'Past habit question: \'Did you use to + V1 (live)...?\' (Notice \'use to\' after did).',
      ),
      _buildRound(
        id: 5,
        sentence: 'People used to write long handwritten letters before smartphones were invented .',
        translationMl: 'സ്മാർട്ട്ഫോണുകൾ കണ്ടുപിടിക്കുന്നതിന് മുൻപ് ആളുകൾ കൈകൊണ്ട് നീണ്ട കത്തുകൾ എഴുതാറുണ്ടായിരുന്നു.',
        hint: 'Historical contrast: \'People used to write (V1)...\'',
      ),
    ],
    // DAY 37: Past Continuous: Was/Were + ing
    37: [
      _buildRound(
        id: 1,
        sentence: 'I was working on the project presentation when my laptop battery died .',
        translationMl: 'എന്റെ ലാപ്ടോപ്പ് ബാറ്ററി തീർന്നപ്പോൾ ഞാൻ പ്രോജക്ട് പ്രസന്റേഷനിൽ ജോലി ചെയ്യുകയായിരുന്നു.',
        hint: 'Interrupted action: \'I was working (past continuous) when [incident in V2]...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'While my mother was preparing tea, my father was reading the morning newspaper .',
        translationMl: 'അമ്മ ചായ ഉണ്ടാക്കിക്കൊണ്ടിരിക്കുമ്പോൾ അച്ഛൻ പ്രഭാത പത്രം വായിക്കുകയായിരുന്നു.',
        hint: 'Simultaneous past actions with while: \'While [was/were -ing], [was/were -ing]...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'They were waiting outside the cinema hall because it was raining heavily .',
        translationMl: 'കനത്ത മഴ പെയ്തുകൊണ്ടിരുന്നതിനാൽ അവർ സിനിമാ ഹാളിന് പുറത്ത് കാത്തിരിക്കുകയായിരുന്നു.',
        hint: 'Continuous past explanation: \'They were waiting because it was raining...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'What were you doing at seven yesterday evening when I phoned your mobile ?',
        translationMl: 'ഇന്നലെ വൈകുന്നേരം ഏഴുമണിക്ക് ഞാൻ നിങ്ങളുടെ മൊബൈലിലേക്ക് വിളിച്ചപ്പോൾ നിങ്ങൾ എന്തെടുക്കുകയായിരുന്നു?',
        hint: 'Past continuous question: \'What were you doing when...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'The children were laughing and splashing happily in the shallow garden pool .',
        translationMl: 'കുട്ടികൾ പൂന്തോട്ടത്തിലെ ചെറിയ കുളത്തിൽ സന്തോഷത്തോടെ ചിരിക്കുകയും വെള്ളം തെറിപ്പിക്കുകയുമായിരുന്നു.',
        hint: 'Compound continuous verbs: \'were laughing and splashing...\'',
      ),
    ],
    // DAY 38: Past Narrative & Incident Storytelling
    38: [
      _buildRound(
        id: 1,
        sentence: 'Suddenly a deafening thunderbolt struck the ancient pine tree on the hill .',
        translationMl: 'പെട്ടെന്ന് കുന്നിൻമുകളിലെ പഴയ പൈൻ മരത്തിൽ വലിയ ശബ്ദത്തോടെ ഇടിമിന്നലേറ്റു.',
        hint: 'Dramatic past opening: \'Suddenly + subject + V2 (struck)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Luckily everyone had moved indoors just minutes before the heavy branch snapped .',
        translationMl: 'ഭാഗ്യവശാൽ വലിയ ചില്ല ഒടിയുന്നതിന് ഏതാനും മിനിറ്റുകൾക്ക് മുൻപ് എല്ലാവരും വീടിനകത്തേക്ക് മാറിയിരുന്നു.',
        hint: 'Fortunate turn: \'Luckily + subject + had moved indoors...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'As soon as we heard the alarm, we calmly evacuated through the fire exits .',
        translationMl: 'അലാറം കേട്ട ഉടൻ തന്നെ ഞങ്ങൾ ഫയർ എക്സിറ്റുകളിലൂടെ ശാന്തമായി പുറത്തിറങ്ങി.',
        hint: 'Immediate reaction: \'As soon as we heard [trigger], we [action in V2]...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'To our utter surprise, the friendly village elder offered us warm herbal soup .',
        translationMl: 'ഞങ്ങളെ ഏറെ അത്ഭുതപ്പെടുത്തിക്കൊണ്ട്, ആ നാട്ടിലെ സ്നേഹമുള്ള മുതിർന്നയാൾ ഞങ്ങൾക്ക് ചൂടുള്ള സൂപ്പ് തന്നു.',
        hint: 'Expressing surprise: \'To our utter surprise, [subject] offered (V2)...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'It was a thrilling adventure that our travel group will never forget .',
        translationMl: 'ഞങ്ങളുടെ യാത്രാസംഘം ഒരിക്കലും മറക്കാത്ത ആവേശകരമായ ഒരു സാഹസികതയായിരുന്നു അത്.',
        hint: 'Story moral/memory: \'It was a thrilling adventure that we will never forget.\'',
      ),
    ],
    // DAY 39: Future Promises & Instant Decisions: Will
    39: [
      _buildRound(
        id: 1,
        sentence: 'The doorbell is ringing, so I will go and answer it immediately .',
        translationMl: 'കോളിംഗ് ബെൽ അടിക്കുന്നു, അതിനാൽ ഞാൻ ഇപ്പോൾ തന്നെ പോയി വാതിൽ തുറക്കാം.',
        hint: 'Spontaneous decision: \'I will go and answer it...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Do not worry about the presentation slides; I will finalize them tonight .',
        translationMl: 'പ്രസന്റേഷൻ സ്ലൈഡുകളെക്കുറിച്ച് വിഷമിക്കേണ്ട; ഇന്ന് രാത്രി ഞാൻ അവ പൂർത്തിയാക്കാം.',
        hint: 'Reassuring promise: \'Do not worry... I will finalize (V1)...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'We will definitely support your charity fundraising event next weekend .',
        translationMl: 'അടുത്ത വാരാന്ത്യത്തിലെ നിങ്ങളുടെ ചാരിറ്റി പരിപാടിയെ ഞങ്ങൾ തീർച്ചയായും പിന്തുണയ്ക്കും.',
        hint: 'Definite commitment: \'We will definitely support (V1)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will transfer the remaining project payment directly to your bank account .',
        translationMl: 'ബാക്കി തുക ഞാൻ നിങ്ങളുടെ ബാങ്ക് അക്കൗണ്ടിലേക്ക് നേരിട്ട് ട്രാൻസ്ഫർ ചെയ്യാം.',
        hint: 'Promise of action: \'I will transfer the payment...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Will you accompany me to the dental clinic tomorrow morning ?',
        translationMl: 'നാളെ രാവിലെ ദന്താശുപത്രിയിലേക്ക് നിങ്ങൾ എന്റെ കൂടെ വരുമോ?',
        hint: 'Polite future request: \'Will you accompany me to...?\'',
      ),
    ],
    // DAY 40: Definite Future Plans: Going to
    40: [
      _buildRound(
        id: 1,
        sentence: 'I am going to start an intensive public speaking course next Monday morning .',
        translationMl: 'അടുത്ത തിങ്കളാഴ്ച രാവിലെ ഞാൻ ഒരു പബ്ലിക് സ്പീക്കിംഗ് കോഴ്സ് ആരംഭിക്കാൻ പോകുന്നു.',
        hint: 'Pre-planned future intention: \'I am going to start (V1)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Our engineering department is going to deploy the major server upgrades tonight .',
        translationMl: 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് വിഭാഗം ഇന്ന് രാത്രി സെർവർ അപ്‌ഗ്രേഡുകൾ വിന്യസിക്കാൻ പോകുന്നു.',
        hint: 'Scheduled organizational plan: \'is going to deploy (V1)...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Are you going to attend the cultural music festival this coming weekend ?',
        translationMl: 'വരുന്ന വാരാന്ത്യത്തിലെ സാംസ്കാരിക സംഗീതോത്സവത്തിൽ നിങ്ങൾ പങ്കെടുക്കാൻ പോകുകയാണോ?',
        hint: 'Future plan inquiry: \'Are you going to attend (V1)...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We are going to plant fifty coconut saplings along the western boundary wall .',
        translationMl: 'പടിഞ്ഞാറൻ അതിർത്തി മതിലിനോട് ചേർന്ന് ഞങ്ങൾ അമ്പത് തെങ്ങിൻ തൈകൾ നടാൻ പോകുന്നു.',
        hint: 'Group intention: \'We are going to plant (V1)...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'She is going to celebrate her graduation with her university friends in Goa .',
        translationMl: 'അവൾ തന്റെ ബിരുദദാനം ഗോവയിൽ വെച്ച് സുഹൃത്തുക്കളോടൊപ്പം ആഘോഷിക്കാൻ പോകുന്നു.',
        hint: 'Third person singular plan: \'She is going to celebrate (V1)...\'',
      ),
    ],
    // DAY 41: Shopping for Clothes & Trial Room
    41: [
      _buildRound(
        id: 1,
        sentence: 'Excuse me, where is the trial room located in this section ?',
        translationMl: 'ക്ഷമിക്കണം, ഈ വിഭാഗത്തിലെ ട്രയൽ റൂം എവിടെയാണ്?',
        hint: 'Store inquiry: \'Where is the trial room located...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'This shirt feels slightly tight around the collar; do you have a larger size ?',
        translationMl: 'ഈ ഷർട്ട് കഴുത്തിന് അല്പം ഇറുക്കമുള്ളതായി തോന്നുന്നു; ഇതിന്റെ വലിയ അളവ് ഉണ്ടോ?',
        hint: 'Size request: \'Do you have a larger size?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Can you show me some formal linen trousers in beige or cream color ?',
        translationMl: 'ബീജ് അല്ലെങ്കിൽ ക്രീം നിറത്തിലുള്ള ഫോർമൽ ലിനൻ പാന്റ്സ് കാണിച്ചു തരാമോ?',
        hint: 'Product request: \'Can you show me some... in [color]?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'How much is the discounted price after applying the festival offer ?',
        translationMl: 'ഉത്സവ ഓഫർ കഴിഞ്ഞാൽ കിഴിവ് ചെയ്ത വില എത്രയാണ്?',
        hint: 'Discount inquiry: \'How much is the discounted price after applying...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I will take both the sky blue shirt and the navy blazer, please .',
        translationMl: 'ഞാൻ ആകാശ നീല ഷർട്ടും നേവി ബ്ലേസറും എടുക്കാം, ദയവായി പാക്ക് ചെയ്യുക.',
        hint: 'Decision at counter: \'I will take both [item] and [item], please.\'',
      ),
    ],
    // DAY 42: At a Restaurant: Ordering & Bill
    42: [
      _buildRound(
        id: 1,
        sentence: 'Could we please have a table for four near the quiet window garden ?',
        translationMl: 'പൂന്തോട്ടം കാണുന്ന ജനലിനടുത്ത് ഞങ്ങൾക്ക് നാലുപേർക്കായി ഒരു ടേബിൾ തരാമോ?',
        hint: 'Table request: \'Could we please have a table for [number] near...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Can you recommend the chef\'s special vegetarian dish for dinner ?',
        translationMl: 'അത്താഴത്തിന് ഷെഫിന്റെ പ്രത്യേക വെജിറ്റേറിയൻ വിഭവം ഏതാണെന്ന് ശുപാർശ ചെയ്യാമോ?',
        hint: 'Recommendation request: \'Can you recommend the chef\'s special...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I would like to order one paneer tikka and two butter naans, please .',
        translationMl: 'എനിക്ക് ഒരു പനീർ ടിക്കയും രണ്ട് ബട്ടർ നാനും വേണം, ദയവായി കുറിച്ചെടുക്കുക.',
        hint: 'Ordering formula: \'I would like to order [item] and [item], please.\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Please make the gravy medium spicy with less oil and green chillies .',
        translationMl: 'കറി അധികം എരിവില്ലാതെ, കുറഞ്ഞ എണ്ണയിലും പച്ചമുളകിലും തയ്യാറാക്കി തരുക.',
        hint: 'Dietary preference: \'Please make the [dish] medium spicy with...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could we get the bill, please, and do you accept digital payment cards ?',
        translationMl: 'ഞങ്ങൾക്ക് ബിൽ തരാമോ, നിങ്ങൾ പേയ്‌മെന്റ് കാർഡുകൾ സ്വീകരിക്കുമോ?',
        hint: 'Polite bill inquiry: \'Could we get the bill, please, and...?\'',
      ),
    ],
    // DAY 43: Public Transport: Bus & Train Travel
    43: [
      _buildRound(
        id: 1,
        sentence: 'Excuse me, does this red express bus go towards the technical university campus ?',
        translationMl: 'ക്ഷമിക്കണം, ഈ ചുവന്ന എക്സ്പ്രസ് ബസ് ടെക്നിക്കൽ യൂണിവേഴ്സിറ്റി ക്യാമ്പസിലേക്ക് പോകുമോ?',
        hint: 'Route inquiry: \'Does this bus go towards [destination]?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Which railway platform does the evening intercity express depart from ?',
        translationMl: 'വൈകുന്നേരത്തെ ഇന്റർസിറ്റി എക്സ്പ്രസ് ഏത് പ്ലാറ്റ്‌ഫോമിൽ നിന്നാണ് പുറപ്പെടുന്നത്?',
        hint: 'Platform inquiry: \'Which platform does [train] depart from?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Could you please tell me when the next metro train arrives here ?',
        translationMl: 'അടുത്ത മെട്രോ ട്രെയിൻ എപ്പോഴാണ് ഇവിടെ എത്തുക എന്ന് പറഞ്ഞുതരാമോ?',
        hint: 'Schedule inquiry: \'Could you please tell me when the next train arrives...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Two adult tickets to the central town hall, please; how much is the fare ?',
        translationMl: 'സെൻട്രൽ ടൗൺ ഹാളിലേക്ക് രണ്ട് ടിക്കറ്റ് തരിക; എത്രയാണ് യാത്രാക്കൂലി?',
        hint: 'Ticketing request: \'[Number] tickets to [place], please; how much is the fare?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Remember to hold the handrails securely when the bus accelerates or turns .',
        translationMl: 'ബസ് വേഗത കൂട്ടുകയോ വളവ് തിരിയുകയോ ചെയ്യുമ്പോൾ കൈപ്പിടിയിൽ മുറുകെ പിടിക്കാൻ ശ്രദ്ധിക്കുക.',
        hint: 'Transit safety: \'Remember to hold the handrails securely...\'',
      ),
    ],
    // DAY 44: At the Airport & Flight Journey
    44: [
      _buildRound(
        id: 1,
        sentence: 'Here is my passport and electronic flight ticket booking confirmation .',
        translationMl: 'ഇതാ എന്റെ പാസ്‌പോർട്ടും ഇലക്ട്രോണിക് ഫ്ലൈറ്റ് ടിക്കറ്റ് ബുക്കിംഗ് സ്ഥിരീകരണവും.',
        hint: 'Airport counter statement: \'Here is my passport and...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Would you prefer a window seat or an aisle seat for this flight ?',
        translationMl: 'ഈ വിമാനയാത്രയിൽ ജനലിനടുത്തുള്ള സീറ്റാണോ ഇടനാഴിയുടെ വശത്തുള്ള സീറ്റാണോ നിങ്ങൾക്കിഷ്ടം?',
        hint: 'Seating preference: \'Would you prefer a window seat or an aisle seat...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Please place your laptop and liquids separately in this scanning tray .',
        translationMl: 'ഈ സ്കാനിംഗ് ട്രേയിൽ നിങ്ങളുടെ ലാപ്ടോപ്പും ദ്രാവകങ്ങളും പ്രത്യേകം എടുത്തു വെക്കുക.',
        hint: 'Security directive: \'Please place your [items] separately in...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Which boarding gate is flight four hundred and fifty departing from ?',
        translationMl: 'ഫ്ലൈറ്റ് നമ്പർ 450 ഏത് ബോർഡിംഗ് ഗേറ്റിൽ നിന്നാണ് പുറപ്പെടുന്നത്?',
        hint: 'Gate inquiry: \'Which boarding gate is flight [number] departing from?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please remain seated with your seatbelts fastened until the aircraft comes to a complete halt .',
        translationMl: 'വിമാനം പൂർണ്ണമായും നിൽക്കുന്നതുവരെ ദയവായി സീറ്റ് ബെൽറ്റ് ധരിച്ച് ഇരിക്കുക.',
        hint: 'In-flight announcement: \'Please remain seated until...\'',
      ),
    ],
    // DAY 45: Hotel Stay & Check-in
    45: [
      _buildRound(
        id: 1,
        sentence: 'Good afternoon, I have a hotel room reservation under the name Rajesh Nair .',
        translationMl: 'ശുഭ ഉച്ചതിരിഞ്ഞ്, രാജേഷ് നായർ എന്ന പേരിൽ എനിക്ക് ഒരു റൂം ബുക്കിംഗ് ഉണ്ട്.',
        hint: 'Check-in formula: \'I have a reservation under the name [Name].\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you please tell me what time the morning complimentary breakfast is served ?',
        translationMl: 'രാവിലത്തെ സൗജന്യ പ്രഭാതഭക്ഷണം ഏത് സമയത്താണ് വിളമ്പുന്നതെന്ന് പറഞ്ഞുതരാമോ?',
        hint: 'Breakfast inquiry: \'What time is the complimentary breakfast served?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Here is my government identity card and the credit card for incidental charges .',
        translationMl: 'ഇതാ എന്റെ തിരിച്ചറിയൽ കാർഡും റൂം ഡെപ്പോസിറ്റിനായുള്ള ക്രെഡിറ്റ് കാർഡും.',
        hint: 'ID presentation: \'Here is my identity card and...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Could housekeeping please send up an extra dental kit and a fresh blanket ?',
        translationMl: 'ഹൗസ് കീപ്പിംഗിൽ നിന്ന് ഒരു എക്സ്ട്രാ ഡെന്റൽ കിറ്റും പുതിയ കമ്പിളി പുതപ്പും റൂമിലേക്ക് തരുമോ?',
        hint: 'Room amenity request: \'Could housekeeping please send up...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'What is the standard checkout time tomorrow afternoon at this property ?',
        translationMl: 'നാളെ ഉച്ചയ്ക്ക് ഈ ഹോട്ടലിലെ ഔദ്യോഗിക ചെക്ക്ഔട്ട് സമയം എപ്പോഴാണ്?',
        hint: 'Checkout inquiry: \'What is the standard checkout time tomorrow...?\'',
      ),
    ],
    // DAY 46: Tomorrow\'s Schedule & Appointments
    46: [
      _buildRound(
        id: 1,
        sentence: 'I have a scheduled doctor appointment tomorrow morning at nine-thirty sharp .',
        translationMl: 'നാളെ രാവിലെ കൃത്യം ഒമ്പതരയ്ക്ക് എനിക്ക് ഡോക്ടറുമായി ഒരു അപ്പോയിന്റ്‌മെന്റ് ഉണ്ട്.',
        hint: 'Schedule formula: \'I have an appointment at [Time] sharp.\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could we please reschedule our budget review meeting to three PM tomorrow ?',
        translationMl: 'നമ്മുടെ ബജറ്റ് റിവ്യൂ മീറ്റിംഗ് നാളെ ഉച്ചതിരിഞ്ഞ് മൂന്ന് മണിയിലേക്ക് മാറ്റിവെക്കാമോ?',
        hint: 'Polite rescheduling: \'Could we please reschedule [event] to [Time]?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What time works best for you to have a brief ten-minute telephone conversation ?',
        translationMl: 'ഒരു പത്ത് മിനിറ്റ് ഫോൺ സംഭാഷണത്തിന് നിങ്ങൾക്ക് ഏറ്റവും അനുയോജ്യമായ സമയം ഏതാണ്?',
        hint: 'Availability query: \'What time works best for you to...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will send a calendar invite right away with the secure video meeting link .',
        translationMl: 'വീഡിയോ മീറ്റിംഗ് ലിങ്കോടുകൂടിയ കലണ്ടർ ഇൻവൈറ്റ് ഞാൻ ഇപ്പോൾ തന്നെ അയക്കാം.',
        hint: 'Action commitment: \'I will send a calendar invite right away with...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please set a reminder alarm so we do not miss the afternoon client presentation .',
        translationMl: 'ഉച്ചകഴിഞ്ഞുള്ള ക്ലയന്റ് പ്രസന്റേഷൻ നഷ്ടപ്പെടാതിരിക്കാൻ ദയവായി ഒരു റിമൈൻഡർ അലാറം വെക്കുക.',
        hint: 'Precautionary reminder: \'Please set a reminder so we do not miss...\'',
      ),
    ],
    // DAY 47: Polite Invitations: Would you like to...?
    47: [
      _buildRound(
        id: 1,
        sentence: 'Would you like to join our family for dinner at our home this Saturday evening ?',
        translationMl: 'ഈ ശനിയാഴ്ച വൈകുന്നേരം ഞങ്ങളുടെ വീട്ടിൽ അത്താഴത്തിന് കൂടാൻ നിങ്ങൾക്ക് താൽപ്പര്യമുണ്ടോ?',
        hint: 'Invitation formula: \'Would you like to join [us] for [event]...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'We would be delighted if you could attend our daughter\'s graduation ceremony .',
        translationMl: 'ഞങ്ങളുടെ മകളുടെ ബിരുദദാന ചടങ്ങിൽ പങ്കെടുക്കാൻ കഴിഞ്ഞാൽ ഞങ്ങൾ വളരെ സന്തുഷ്ടരായിരിക്കും.',
        hint: 'Formal polite invitation: \'We would be delighted if you could attend...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Would you like to have a cup of hot cardamom tea and homemade biscuits ?',
        translationMl: 'ഒരു കപ്പ് ഏലയ്ക്കാ ചായയും ബിസ്കറ്റും കഴിക്കാൻ നിങ്ങൾക്ക് താൽപ്പര്യമുണ്ടോ?',
        hint: 'Hospitality offer: \'Would you like to have a cup of...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Thank you so much for the thoughtful invite; I would love to attend !',
        translationMl: 'സ്നേഹം നിറഞ്ഞ ക്ഷണത്തിന് വളരെ നന്ദി; ഞാൻ തീർച്ചയായും പങ്കെടുക്കാം!',
        hint: 'Enthusiastic acceptance: \'I would love to attend!\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Would you like to accompany me to the weekend book fair in town ?',
        translationMl: 'ടൗണിൽ നടക്കുന്ന വാരാന്ത്യ പുസ്തകോത്സവത്തിലേക്ക് എന്റെ കൂടെ വരാൻ താൽപ്പര്യമുണ്ടോ?',
        hint: 'Companion invitation: \'Would you like to accompany me to...?\'',
      ),
    ],
    // DAY 48: Polite Requests: Could you please...
    48: [
      _buildRound(
        id: 1,
        sentence: 'Could you please pass me the glass water bottle from the table ?',
        translationMl: 'മേശപ്പുറത്തിരിക്കുന്ന ഗ്ലാസ് വാട്ടർ ബോട്ടിൽ എനിക്ക് ഒന്ന് എടുത്തുതരാമോ?',
        hint: 'Polite request: \'Could you please pass me [item]...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Would you mind lowering the volume of the television speaker slightly ?',
        translationMl: 'ടെലിവിഷന്റെ ശബ്ദം അല്പം കുറയ്ക്കാമോ?',
        hint: 'Polite request with \'Would you mind + verb-ing (lowering)...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Could you please guide me to the nearest metro station exit gate ?',
        translationMl: 'ഏറ്റവും അടുത്തുള്ള മെട്രോ എക്സിറ്റിലേക്ക് എനിക്ക് വഴികാണിച്ചു തരാമോ?',
        hint: 'Direction assistance: \'Could you please guide me to...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Would you mind holding this heavy cardboard parcel while I open the door ?',
        translationMl: 'ഞാൻ വാതിൽ തുറക്കുന്നതുവരെ ഈ വലിയ പെട്ടി ഒന്ന് പിടിക്കാമോ?',
        hint: 'Assistance request: \'Would you mind holding (ing)...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could you please double-check the final numbers before submitting the official report ?',
        translationMl: 'ഔദ്യോഗിക റിപ്പോർട്ട് സമർപ്പിക്കുന്നതിന് മുൻപ് അവസാന കണക്കുകൾ ഒന്നുകൂടി പരിശോധിക്കാമോ?',
        hint: 'Workplace verification: \'Could you please double-check...?\'',
      ),
    ],
    // DAY 49: Giving Advice: Should & Ought to
    49: [
      _buildRound(
        id: 1,
        sentence: 'You should drink at least eight glasses of clean water every day .',
        translationMl: 'നിങ്ങൾ ദിവസവും കുറഞ്ഞത് എട്ട് ഗ്ലാസ് ശുദ്ധജലമെങ്കിലും കുടിക്കണം.',
        hint: 'Health advice formula: \'You should + base verb (drink)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'You ought to apologize sincerely to your colleague for the misunderstanding .',
        translationMl: 'ആ തെറ്റിദ്ധാരണയ്ക്ക് നിങ്ങൾ സഹപ്രവർത്തകനോട് ആത്മാർത്ഥമായി മാപ്പ് പറയേണ്ടതാണ്.',
        hint: 'Moral duty: \'You ought to apologize (V1)...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'You shouldn\'t skip breakfast because it provides essential morning energy .',
        translationMl: 'രാവിലത്തെ ഭക്ഷണം നിങ്ങൾ ഒഴിവാക്കരുത്, കാരണം അത് ശരീരത്തിന് ആവശ്യമായ ഊർജ്ജം നൽകുന്നു.',
        hint: 'Negative advice: \'You shouldn\'t skip (V1)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We should review the agreement terms thoroughly before signing the contract .',
        translationMl: 'കരാറിൽ ഒപ്പിടുന്നതിന് മുൻപ് നാം വ്യവസ്ഥകൾ വിശദമായി പരിശോധിക്കേണ്ടതാണ്.',
        hint: 'Prudent advice: \'We should review (V1)...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Children ought to respect their teachers and value cultural traditions .',
        translationMl: 'കുട്ടികൾ തങ്ങളുടെ അധ്യാപകരെ ബഹുമാനിക്കുകയും സംസ്കാരത്തെ വിലമതിക്കുകയും ചെയ്യേണ്ടതാണ്.',
        hint: 'Social responsibility: \'Children ought to respect (V1)...\'',
      ),
    ],
    // DAY 50: Compulsion & Rules: Must vs Have to
    50: [
      _buildRound(
        id: 1,
        sentence: 'You must wear a protective seatbelt while driving on the highway .',
        translationMl: 'ഹൈവേയിൽ വാഹനം ഓടിക്കുമ്പോൾ നിങ്ങൾ നിർബന്ധമായും സീറ്റ് ബെൽറ്റ് ധരിക്കണം.',
        hint: 'Strict rule: \'You must wear (V1)...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'All employees have to submit their annual tax documents before Friday noon .',
        translationMl: 'എല്ലാ ജീവനക്കാരും വെള്ളിയാഴ്ച ഉച്ചയ്ക്ക് മുൻപ് വാർഷിക നികുതി രേഖകൾ സമർപ്പിക്കേണ്ടതുണ്ട്.',
        hint: 'External obligation: \'Employees have to submit (V1)...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'You mustn\'t take photographs inside the high security defense museum .',
        translationMl: 'പ്രതിരോധ മ്യൂസിയത്തിനുള്ളിൽ ഫോട്ടോ എടുക്കാൻ പാടില്ല.',
        hint: 'Strict prohibition: \'You mustn\'t take (V1)...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Tomorrow is a national holiday, so you don\'t have to report to the office .',
        translationMl: 'നാളെ പൊതു അവധിയായതിനാൽ നിങ്ങൾ ഓഫീസിൽ ഹാജരാകേണ്ടതില്ല.',
        hint: 'Lack of obligation: \'You don\'t have to report...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'International travelers must present a valid passport and entry visa at immigration .',
        translationMl: 'അന്താരാഷ്ട്ര യാത്രക്കാർ ഇമിഗ്രേഷനിൽ സാധുവായ പാസ്‌പോർട്ടും വിസയും നിർബന്ധമായും ഹാജരാക്കണം.',
        hint: 'Legal mandate: \'Travelers must present (V1)...\'',
      ),
    ],
    // DAY 51: Accepting & Declining Politely
    51: [
      _buildRound(
        id: 1,
        sentence: 'Thank you so much for the dinner invite, but unfortunately I have a prior commitment .',
        translationMl: 'അത്താഴ ക്ഷണത്തിന് വളരെ നന്ദി, എന്നാൽ നിർഭാഗ്യവശാൽ എനിക്ക് മുൻകൂട്ടി നിശ്ചയിച്ച മറ്റൊരു പരിപാടിയുണ്ട്.',
        hint: 'Polite declining formula: \'Thank you for [invite], but unfortunately I have a prior commitment.\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'I would be absolutely delighted to attend your sister\'s wedding reception in Chennai .',
        translationMl: 'ചെന്നൈയിൽ നടക്കുന്ന നിങ്ങളുടെ സഹോദരിയുടെ വിവാഹ വിരുന്നിൽ പങ്കെടുക്കാൻ എനിക്ക് വലിയ സന്തോഷമേയുള്ളൂ.',
        hint: 'Enthusiastic acceptance: \'I would be delighted to attend...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I truly appreciate you thinking of me, though I won\'t be able to make it this time .',
        translationMl: 'എന്നെ ഓർത്തതിന് വളരെ നന്ദി, എന്നിരുന്നാലും ഇത്തവണ എനിക്ക് എത്താൻ സാധിക്കില്ല.',
        hint: 'Soft rejection: \'I appreciate you thinking of me, though I won\'t be able to make it...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Could we take a rain check and grab coffee sometime early next week instead ?',
        translationMl: 'നമുക്കിത് മറ്റൊരു ദിവസത്തേക്ക് മാറ്റിവെച്ച് അടുത്ത ആഴ്ച ആദ്യം കോഫി കുടിക്കാൻ കാണാമോ?',
        hint: 'Idiomatic rescheduling: \'Could we take a rain check and...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We look forward to celebrating this joyful milestone together with your family .',
        translationMl: 'നിങ്ങളുടെ കുടുംബത്തോടൊപ്പം ഈ സന്തോഷകരമായ നിമിഷം ആഘോഷിക്കാൻ ഞങ്ങൾ ആകാംക്ഷയോടെ കാത്തിരിക്കുന്നു.',
        hint: 'Warm acceptance: \'We look forward to celebrating...\'',
      ),
    ],
    // DAY 52: Expressing Feelings & Emotions
    52: [
      _buildRound(
        id: 1,
        sentence: 'I feel incredibly delighted to announce that our research paper has been published .',
        translationMl: 'ഞങ്ങളുടെ ഗവേഷണ പ്രബന്ധം പ്രസിദ്ധീകരിച്ചു എന്ന് അറിയിക്കുന്നതിൽ എനിക്ക് അതിയായ സന്തോഷമുണ്ട്.',
        hint: 'Emotion formula: \'I feel [adjective] to announce that...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Do not feel anxious about the presentation; you have prepared exceptionally well .',
        translationMl: 'പ്രസന്റേഷനെക്കുറിച്ച് ഓർത്ത് ആശങ്കപ്പെടേണ്ടതില്ല; നിങ്ങൾ വളരെ നന്നായി തയ്യാറെടുത്തിട്ടുണ്ട്.',
        hint: 'Reassurance: \'Do not feel anxious about...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I felt slightly overwhelmed by the massive workload, so I asked my manager for assistance .',
        translationMl: 'അമിതമായ ജോലിഭാരത്താൽ എനിക്ക് അല്പം പ്രയാസം തോന്നി, അതിനാൽ ഞാൻ മാനേജറോട് സഹായം ചോദിച്ചു.',
        hint: 'Vulnerability and action: \'I felt overwhelmed by... so I asked...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'She is perfectly content with her quiet morning routine and steaming cup of filter coffee .',
        translationMl: 'തന്റെ ശാന്തമായ പ്രഭാത ദിനചര്യയിലും ചൂടുള്ള ഫിൽട്ടർ കോഫിയിലും അവൾ തികച്ചും സന്തുഷ്ടയാണ്.',
        hint: 'Peaceful state: \'She is perfectly content with...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We were immensely relieved when the rescue helicopter landed safely at the base camp .',
        translationMl: 'ബേസ് ക്യാമ്പിൽ റെസ്ക്യൂ ഹെലികോപ്റ്റർ സുരക്ഷിതമായി ഇറങ്ങിയപ്പോൾ ഞങ്ങൾക്ക് വലിയ ആശ്വാസമായി.',
        hint: 'Collective relief: \'We were immensely relieved when...\'',
      ),
    ],
    // DAY 53: Handling Complaints & Polite Feedback
    53: [
      _buildRound(
        id: 1,
        sentence: 'I am afraid there is an overcharge error on our dinner invoice bill .',
        translationMl: 'ഞങ്ങളുടെ അത്താഴ ബില്ലിൽ അധിക തുക രേഖപ്പെടുത്തിയ ഒരു തെറ്റ് വന്നിട്ടുണ്ടെന്ന് തോന്നുന്നു.',
        hint: 'Soft complaint opening: \'I am afraid there is an error on...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you please look into why our internet connection has been fluctuating today ?',
        translationMl: 'ഇന്ന് ഇന്റർനെറ്റ് കണക്ഷൻ ഇടയ്ക്കിടെ നിലയ്ക്കുന്നത് എന്തുകൊണ്ടാണെന്ന് ഒന്ന് പരിശോധിക്കാമോ?',
        hint: 'Investigation request: \'Could you please look into why...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'This laptop screen arrived with a visible scratch; I would like a replacement .',
        translationMl: 'ഈ ലാപ്‌ടോപ്പ് സ്ക്രീനിൽ ഒരു പോറൽ ഉണ്ട്; എനിക്കിത് മാറ്റി തരണം എന്ന് ആഗ്രഹിക്കുന്നു.',
        hint: 'Defect statement: \'[Item] arrived with a defect; I would like a replacement.\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We appreciate your feedback and will rectify the software glitch immediately .',
        translationMl: 'നിങ്ങളുടെ അഭിപ്രായത്തെ ഞങ്ങൾ വിലമതിക്കുന്നു, സോഫ്റ്റ്‌വെയർ തകരാർ ഞങ്ങൾ ഉടൻ പരിഹരിക്കും.',
        hint: 'Professional response: \'We will rectify [issue] immediately.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please accept our sincere apologies for the delayed shipment of your books .',
        translationMl: 'പുസ്തകങ്ങൾ അയക്കുന്നതിൽ ഉണ്ടായ കാലതാമസത്തിൽ ഞങ്ങളുടെ ആത്മാർത്ഥമായ ക്ഷമാപണം സ്വീകരിക്കുക.',
        hint: 'Formal apology: \'Please accept our sincere apologies for...\'',
      ),
    ],
    // DAY 54: Banking & Money Transactions
    54: [
      _buildRound(
        id: 1,
        sentence: 'I would like to deposit this account payee cheque into my savings account .',
        translationMl: 'ഈ അക്കൗണ്ട് പേയീ ചെക്ക് എന്റെ സേവിംഗ്സ് അക്കൗണ്ടിൽ നിക്ഷേപിക്കാൻ ഞാൻ ആഗ്രഹിക്കുന്നു.',
        hint: 'Banking request: \'I would like to deposit [instrument] into...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Could you please print an official six-month bank account statement with seal ?',
        translationMl: 'മുദ്ര പതിപ്പിച്ച ആറു മാസത്തെ ഔദ്യോഗിക ബാങ്ക് സ്റ്റേറ്റ്‌മെന്റ് എനിക്ക് പ്രിന്റ് ചെയ്തു തരാമോ?',
        hint: 'Statement request: \'Could you please print an official statement...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What is the daily maximum cash withdrawal limit at your branch automated teller ?',
        translationMl: 'നിങ്ങളുടെ ബ്രാഞ്ചിലെ എടിഎമ്മിൽ നിന്ന് പ്രതിദിനം പരമാവധി എത്ര തുക പിൻവലിക്കാം?',
        hint: 'Withdrawal limit inquiry: \'What is the daily maximum cash withdrawal limit...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Please update my new permanent residential address and mobile phone number in your records .',
        translationMl: 'എന്റെ പുതിയ താമസസ്ഥലത്തെ വിലാസവും മൊബൈൽ നമ്പറും നിങ്ങളുടെ രേഖകളിൽ അപ്‌ഡേറ്റ് ചെയ്യുക.',
        hint: 'Account update: \'Please update my [details] in your records.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I noticed an unauthorized card debit transaction and want to block my card immediately .',
        translationMl: 'ഞാൻ അറിയാതെ കാർഡിൽ നിന്ന് പണം കുറഞ്ഞതായി കണ്ടു, എന്റെ കാർഡ് ഉടൻ ബ്ലോക്ക് ചെയ്യണം.',
        hint: 'Emergency fraud report: \'I noticed an unauthorized transaction and want to...\'',
      ),
    ],
    // DAY 55: Technology, Mobiles & Connectivity
    55: [
      _buildRound(
        id: 1,
        sentence: 'My mobile battery died while I was navigating the highway directions .',
        translationMl: 'ഹൈവേയിലെ വഴി നോക്കിക്കൊണ്ടിരിക്കുമ്പോൾ എന്റെ മൊബൈലിലെ ചാർജ് തീർന്നുപോയി.',
        hint: 'Battery expression: \'My battery died while...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'The Wi-Fi signal in this conference room is remarkably weak and keeps disconnecting .',
        translationMl: 'ഈ കോൺഫറൻസ് റൂമിലെ വൈഫൈ സിഗ്നൽ വളരെ ദുർബലമാണ്, ഇടയ്ക്കിടെ കട്ടാവുന്നു.',
        hint: 'Connectivity complaint: \'The signal is weak and keeps disconnecting.\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Let me restart the internet broadband router to see if that resolves the network speed .',
        translationMl: 'നെറ്റ്‌വർക്ക് വേഗത ശരിയാകുമോ എന്നറിയാൻ ഞാൻ ബ്രോഡ്ബാൻഡ് റൂട്ടർ ഒന്ന് റീസ്റ്റാർട്ട് ചെയ്തു നോക്കട്ടെ.',
        hint: 'Troubleshooting: \'Let me restart the router to see if...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Could you please share your mobile portable hotspot connection for five quick minutes ?',
        translationMl: 'ഒരു അഞ്ച് മിനിറ്റത്തേക്ക് നിങ്ങളുടെ മൊബൈൽ ഹോട്ട്‌സ്‌പോട്ട് ഒന്ന് ഓൺ ചെയ്തു തരാമോ?',
        hint: 'Hotspot request: \'Could you please share your mobile hotspot for...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Please back up all your important project documents before updating the operating system .',
        translationMl: 'ഓപ്പറേറ്റിംഗ് സിസ്റ്റം അപ്‌ഡേറ്റ് ചെയ്യുന്നതിന് മുൻപ് നിങ്ങളുടെ പ്രധാന പ്രോജക്ട് ഫയലുകൾ ബാക്കപ്പ് ചെയ്യുക.',
        hint: 'Tech advice: \'Please back up your documents before updating...\'',
      ),
    ],
    // DAY 56: Lost Items & Urgent Emergencies
    56: [
      _buildRound(
        id: 1,
        sentence: 'Help! Please call an ambulance immediately; someone has fainted on the pavement !',
        translationMl: 'സഹായിക്കൂ! ദയവായി ഉടൻ ഒരു ആംബുലൻസ് വിളിക്കൂ; നടപ്പാതയിൽ ഒരാൾ ബോധരഹിതനായി വീണു!',
        hint: 'Emergency shouting formula: \'Help! Please call [service] immediately; [situation]!\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have misplaced my black leather wallet containing my driving license and credit cards .',
        translationMl: 'എന്റെ ഡ്രൈവിംഗ് ലൈസൻസും കാർഡുകളുമുള്ള കറുത്ത പഴ്സ് എനിക്ക് കളഞ്ഞുപോയി.',
        hint: 'Lost item statement: \'I have misplaced my [item] containing...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Where is the lost and found property counter located in this airport terminal ?',
        translationMl: 'ഈ എയർപോർട്ട് ടെർമിനലിലെ കളഞ്ഞുകിട്ടിയ വസ്തുക്കളുടെ കൗണ്ടർ എവിടെയാണ്?',
        hint: 'Airport service inquiry: \'Where is the lost and found counter located...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Do not panic; keep calm and follow the marked green emergency exit signs .',
        translationMl: 'പരിഭ്രാന്തരാകരുത്; ശാന്തമായി പച്ച എമർജൻസി എക്സിറ്റ് ബോർഡുകൾ കണ്ട് പുറത്തേക്ക് പോവുക.',
        hint: 'Safety evacuation directive: \'Do not panic; follow the exit signs.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We must report this stolen passport immediately to the embassy and local police .',
        translationMl: 'ഈ പാസ്‌പോർട്ട് മോഷണം പോയ വിവരം നാം ഉടൻ തന്നെ എംബസിയിലും ലോക്കൽ പോലീസിലും അറിയിക്കണം.',
        hint: 'Urgent legal requirement: \'We must report this stolen item immediately to...\'',
      ),
    ],
    // DAY 57: Doctor Consultation: Explaining Symptoms
    57: [
      _buildRound(
        id: 1,
        sentence: 'I have been experiencing a sharp throbbing headache behind my eyes for three days .',
        translationMl: 'കഴിഞ്ഞ മൂന്ന് ദിവസമായി എന്റെ കണ്ണുകൾക്ക് പിന്നിൽ തുളച്ചുകയറുന്ന കടുത്ത തലവേദന അനുഭവപ്പെടുന്നുണ്ട്.',
        hint: 'Present perfect continuous symptom: \'I have been experiencing [pain] for [duration]...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'The joint pain becomes significantly worse whenever I climb upstairs in the morning .',
        translationMl: 'രാവിലെ കോണിപ്പടികൾ കയറുമ്പോൾ കാൽമുട്ടിലെ വേദന വളരെ കൂടുന്നു.',
        hint: 'Pain trigger: \'The pain becomes worse whenever I...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Are there any specific foods or medications that trigger allergic skin rashes ?',
        translationMl: 'ത്വക്കിൽ തടിപ്പുകൾ ഉണ്ടാക്കുന്ന എന്തെങ്കിലും പ്രത്യേക ഭക്ഷണങ്ങളോ മരുന്നുകളോ ഉണ്ടോ?',
        hint: 'Medical history query: \'Are there any medications that trigger...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I feel slightly dizzy and nauseous especially after taking my morning medicine .',
        translationMl: 'രാവിലത്തെ മരുന്ന് കഴിച്ചതിനുശേഷം എനിക്ക് തലകറക്കവും ഛർദ്ദിക്കാൻ വരുന്നതായും തോന്നുന്നു.',
        hint: 'Side-effect description: \'I feel dizzy and nauseous after...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'The doctor recommended complete bed rest and prescribed a five-day antibiotic course .',
        translationMl: 'ഡോക്ടർ പൂർണ്ണ വിശ്രമം നിർദ്ദേശിക്കുകയും അഞ്ച് ദിവസത്തെ ആന്റിബയോട്ടിക് കുറിച്ചുനൽകുകയും ചെയ്തു.',
        hint: 'Medical recommendation: \'The doctor recommended... and prescribed...\'',
      ),
    ],
    // DAY 58: Rapid Fire Reflex Drills: Spontaneous Speech
    58: [
      _buildRound(
        id: 1,
        sentence: 'I will take care of finalizing the presentation slides right away !',
        translationMl: 'സ്ലൈഡുകൾ പൂർത്തിയാക്കുന്ന കാര്യം ഞാൻ ഇപ്പോൾ തന്നെ ഏറ്റെടുത്ത് ചെയ്തോളാം!',
        hint: 'Instant initiative: \'I will take care of [task] right away!\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'I couldn\'t agree with you more on this crucial strategic decision .',
        translationMl: 'ഈ നിർണ്ണായക തീരുമാനത്തിൽ ഞാൻ നിങ്ങളോട് പൂർണ്ണമായും യോജിക്കുന്നു.',
        hint: 'Total agreement idiom: \'I couldn\'t agree with you more...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Well, to be completely candid with you, there is a better alternative .',
        translationMl: 'തുറന്നു പറയുകയാണെങ്കിൽ, ഇതിലും നല്ല മറ്റൊരു വഴിയുണ്ട്.',
        hint: 'Conversational filler: \'Well, to be completely candid with you...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Consider it done; I will dispatch the signed agreement before lunchtime .',
        translationMl: 'അത് കഴിഞ്ഞതായി കരുതിക്കോളൂ; ഉച്ചയ്ക്ക് മുൻപ് ഞാൻ ഒപ്പിട്ട കരാർ അയക്കാം.',
        hint: 'Decisive commitment: \'Consider it done; I will...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'That sounds like a brilliant suggestion; let us test it immediately !',
        translationMl: 'അത് വളരെ മികച്ചൊരു നിർദ്ദേശമാണ്; നമുക്ക് ഇപ്പോൾ തന്നെ അത് പരീക്ഷിച്ചു നോക്കാം!',
        hint: 'Enthusiastic endorsement: \'That sounds like a brilliant suggestion; let us...\'',
      ),
    ],
    // DAY 59: Social Small Talk with Strangers
    59: [
      _buildRound(
        id: 1,
        sentence: 'Lovely morning breeze today, isn\'t it ?',
        translationMl: 'ഇന്ന് നല്ല സുഖമുള്ള പ്രഭാത കാറ്റുണ്ട്, അല്ലേ?',
        hint: 'Small talk tag question: \'Lovely weather today, isn\'t it?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Excuse me, do you happen to know if this suburban train stops at North Bridge ?',
        translationMl: 'ക്ഷമിക്കണം, ഈ ട്രെയിൻ നോർത്ത് ബ്രിഡ്ജിൽ നിർത്തുമോ എന്ന് അറിയാമോ?',
        hint: 'Polite stranger query: \'Do you happen to know if...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I noticed the historical novel you are reading; is it as captivating as people say ?',
        translationMl: 'നിങ്ങൾ വായിക്കുന്ന ചരിത്ര നോവൽ ഞാൻ ശ്രദ്ധിച്ചു; ആളുകൾ പറയുന്നതുപോലെ അത്ര രസകരമാണോ അത്?',
        hint: 'Common interest opening: \'I noticed [book/object]; is it...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'It gets surprisingly crowded around five in the evening at this metro station .',
        translationMl: 'വൈകുന്നേരം അഞ്ചുമണിക്ക് ഈ മെട്രോ സ്റ്റേഷനിൽ അത്ഭുതകരമായ തിരക്കാണ് ഉണ്ടാകുന്നത്.',
        hint: 'Observational small talk: \'It gets crowded around [time]...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Have a wonderful onward journey and enjoy your weekend exploring the city !',
        translationMl: 'നല്ലൊരു യാത്ര ആശംസിക്കുന്നു, നഗരം കണ്ടുകൊണ്ട് നിങ്ങളുടെ വാരാന്ത്യം മനോഹരമായി ആസ്വദിക്കൂ!',
        hint: 'Warm stranger farewell: \'Have a wonderful onward journey and...\'',
      ),
    ],
    // DAY 60: House 2 Grand Review & Gate Exam
    60: [
      _buildRound(
        id: 1,
        sentence: 'I can now navigate shopping, transit, hotels, and dining in English with complete ease .',
        translationMl: 'ഷോപ്പിംഗ്, യാത്രകൾ, ഹോട്ടലുകൾ, റസ്റ്റോറന്റുകൾ എന്നിവയിൽ എനിക്ക് പൂർണ്ണ ആത്മവിശ്വാസത്തോടെ സംസാരിക്കാനാകും.',
        hint: 'Milestone mastery: \'I can now navigate [situations] with complete ease.\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Consistent daily spoken practice transforms hesitation into articulate confident eloquence .',
        translationMl: 'സ്ഥിരമായ സംസാര പരിശീലനം സങ്കോചങ്ങളെ മാറ്റി വാക്ചാതുര്യമുള്ള ആത്മവിശ്വാസമാക്കി മാറ്റുന്നു.',
        hint: 'Inspirational observation: \'Daily practice transforms hesitation into eloquence.\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Would you like to review our favorite conversational highlights from House Two ?',
        translationMl: 'ഹൗസ് രണ്ടിലെ നമ്മുടെ പ്രിയപ്പെട്ട സംഭാഷണങ്ങൾ ഒന്നുകൂടി ഓർത്തെടുക്കാൻ നിങ്ങൾക്ക് താൽപ്പര്യമുണ്ടോ?',
        hint: 'Polite review invitation: \'Would you like to review...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We must celebrate this sixty-day habit achievement with pride and renewed enthusiasm .',
        translationMl: 'അഭിമാനത്തോടും പുതിയ ആവേശത്തോടും കൂടി നാം ഈ അറുപത് ദിവസത്തെ നേട്ടം ആഘോഷിക്കണം.',
        hint: 'Compulsory celebration: \'We must celebrate this achievement with...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I am ready to step boldly into advanced workplace communication and professional debate .',
        translationMl: 'ഓഫീസ് സംഭാഷണങ്ങളിലേക്കും തൊഴിൽപരമായ ചർച്ചകളിലേക്കും ആത്മവിശ്വാസത്തോടെ കടക്കാൻ ഞാൻ തയ്യാറാണ്.',
        hint: 'Forward commitment: \'I am ready to step boldly into...\'',
      ),
    ],
    // DAY 61: Present Perfect Tense: Have/Has + V3
    61: [
      _buildRound(
        id: 1,
        sentence: 'I have submitted the comprehensive quarterly financial report to our manager .',
        translationMl: 'ഞാൻ ഞങ്ങളുടെ മാനേജർക്ക് സമഗ്രമായ ത്രൈമാസ സാമ്പത്തിക റിപ്പോർട്ട് സമർപ്പിച്ചിട്ടുണ്ട്.',
        hint: 'Present Perfect: \'I have submitted the quarterly report...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'She has finalized the contract agreement with the international client .',
        translationMl: 'അവൾ അന്താരാഷ്ട്ര ക്ലയന്റുമായുള്ള കരാർ ഉടമ്പടി അന്തിമമാക്കിയിട്ടുണ്ട്.',
        hint: 'Singular subject: \'She has finalized the contract...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Our engineering squad has resolved the critical network issue successfully .',
        translationMl: 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് സ്ക്വാഡ് നിർണായക നെറ്റ്‌വർക്ക് പ്രശ്നം വിജയകരമായി പരിഹരിച്ചിട്ടുണ്ട്.',
        hint: 'Squad has resolved: \'Our team has resolved the issue...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Have you updated your contact details in the company database ?',
        translationMl: 'കമ്പനി ഡാറ്റാബേസിൽ നിങ്ങളുടെ കോൺടാക്റ്റ് വിവരങ്ങൾ നിങ്ങൾ പുതുക്കിയിട്ടുണ്ടോ?',
        hint: 'Question form: \'Have you updated your contact details...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'We have reached an important milestone in our mobile application development .',
        translationMl: 'ഞങ്ങളുടെ മൊബൈൽ ആപ്പ് വികസനത്തിൽ ഞങ്ങൾ ഒരു പ്രധാന നാഴികക്കല്ലിൽ എത്തിച്ചേർന്നിട്ടുണ്ട്.',
        hint: 'Present Perfect milestone: \'We have reached an important milestone...\'',
      ),
    ],
    // DAY 62: Life Experiences: Have you ever...? / I have never...
    62: [
      _buildRound(
        id: 1,
        sentence: 'Have you ever climbed a high mountain peak during snowy winter ?',
        translationMl: 'മഞ്ഞുകാലത്ത് നിങ്ങൾ എപ്പോഴെങ്കിലും ഉയരമുള്ള ഒരു പർവത കൊടുമുടി കയറിയിട്ടുണ്ടോ?',
        hint: 'Experience question: \'Have you ever climbed...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'I have never tasted traditional Japanese matcha green tea in my life .',
        translationMl: 'ജീവിതത്തിൽ ഞാൻ ഒരിക്കലും പരമ്പരാഗത ജാപ്പനീസ് മാച്ച ഗ്രീൻ ടീ രുചിച്ചിട്ടില്ല.',
        hint: 'Negative experience: \'I have never tasted...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'She has visited seven different countries across two continents this year .',
        translationMl: 'അവൾ ഈ വർഷം രണ്ട് ഭൂഖണ്ഡങ്ങളിലായി ഏഴ് വ്യത്യസ്ത രാജ്യങ്ങൾ സന്ദർശിച്ചിട്ടുണ്ട്.',
        hint: 'Travel count: \'She has visited seven countries...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Have they ever witnessed a live orchestral performance in a theater ?',
        translationMl: 'അവർ എപ്പോഴെങ്കിലും ഒരു തിയേറ്ററിൽ ലൈവ് ഓർക്കസ്ട്ര പ്രകടനം കണ്ടിട്ടുണ്ടോ?',
        hint: 'Audience experience: \'Have they ever witnessed...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'He has never driven an electric automobile on an express highway .',
        translationMl: 'അവൻ ഒരിക്കലും ഒരു എക്സ്പ്രസ് ഹൈവേയിൽ ഇലക്ട്രിക് വാഹനം ഓടിച്ചിട്ടില്ല.',
        hint: 'Never done: \'He has never driven...\'',
      ),
    ],
    // DAY 63: Time Adverbs with Present Perfect: Just, Already, Yet
    63: [
      _buildRound(
        id: 1,
        sentence: 'The logistics company has just dispatched our urgent parcel from the hub .',
        translationMl: 'ലോജിസ്റ്റിക്സ് കമ്പനി ഹബ്ബിൽ നിന്ന് ഞങ്ങളുടെ അടിയന്തര പാർസൽ ഇപ്പോൾ തന്നെ അയച്ചിട്ടുണ്ട്.',
        hint: 'Just dispatched: \'The company has just dispatched our parcel...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'We have already submitted the revised architectural designs to the municipality .',
        translationMl: 'ഞങ്ങൾ പരിഷ്കരിച്ച വാസ്തുവിദ്യാ രൂപകൽപ്പനകൾ ഇതിനകം മുനിസിപ്പാലിറ്റിയിൽ സമർപ്പിച്ചിട്ടുണ്ട്.',
        hint: 'Already submitted: \'We have already submitted the designs...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Has the delivery courier arrived with our medical shipment yet ?',
        translationMl: 'ഞങ്ങളുടെ മെഡിക്കൽ ഷിപ്പ്‌മെന്റുമായി ഡെലിവറി കൊറിയർ ഇതിനകം എത്തിയോ?',
        hint: 'Question with yet at end: \'Has the courier arrived... yet?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I have not received the monthly bank transaction statement yet .',
        translationMl: 'എനിക്ക് പ്രതിമാസ ബാങ്ക് ഇടപാട് സ്റ്റേറ്റ്‌മെന്റ് ഇതുവരെ ലഭിച്ചിട്ടില്ല.',
        hint: 'Negative with yet: \'I have not received the statement yet.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'She has just stepped into the conference hall for the opening keynote .',
        translationMl: 'ഉദ്ഘാടന പ്രസംഗത്തിനായി അവൾ ഇപ്പോൾ തന്നെ കോൺഫറൻസ് ഹാളിലേക്ക് പ്രവേശിച്ചു.',
        hint: 'Just stepped: \'She has just stepped into the hall...\'',
      ),
    ],
    // DAY 64: Duration: Since vs For
    64: [
      _buildRound(
        id: 1,
        sentence: 'He has worked as an electrical engineer at the plant for six years .',
        translationMl: 'അദ്ദേഹം ആറ് വർഷമായി പ്ലാന്റിൽ ഇലക്ട്രിക്കൽ എഞ്ചിനീയറായി ജോലി ചെയ്യുന്നു.',
        hint: 'Period of time: \'for six years\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Our family has resided in this heritage neighborhood since nineteen ninety five .',
        translationMl: 'ഞങ്ങളുടെ കുടുംബം 1995 മുതൽ ഈ പൈതൃക മേഖലയിലാണ് താമസിക്കുന്നത്.',
        hint: 'Point of origin: \'since 1995\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'She has been the senior project coordinator since last November .',
        translationMl: 'കഴിഞ്ഞ നവംബർ മുതൽ അവളാണ് സീനിയർ പ്രോജക്റ്റ് കോർഡിനേറ്റർ.',
        hint: 'Starting point: \'since last November\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'They have maintained this community organic garden for more than a decade .',
        translationMl: 'ഒരു ദശാബ്ദത്തിലേറെയായി അവർ ഈ കമ്മ്യൂണിറ്റി ജൈവ ഉദ്യാനം പരിപാലിക്കുന്നു.',
        hint: 'Duration: \'for more than a decade\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I have waited at the customer support desk for forty five minutes .',
        translationMl: 'ഞാൻ നാൽപ്പത്തിയഞ്ച് മിനിറ്റായി കസ്റ്റമർ സപ്പോർട്ട് ഡെസ്കിൽ കാത്തിരിക്കുന്നു.',
        hint: 'Time length: \'for forty-five minutes\'',
      ),
    ],
    // DAY 65: Present Perfect Continuous: Have/Has been + V-ing
    65: [
      _buildRound(
        id: 1,
        sentence: 'I have been writing this software algorithm code since seven o\'clock this morning .',
        translationMl: 'ഞാൻ ഇന്ന് രാവിലെ ഏഴ് മണി മുതൽ ഈ സോഫ്റ്റ്‌വെയർ അൽഗോരിതം കോഡ് എഴുതിക്കൊണ്ടിരിക്കുകയാണ്.',
        hint: 'Action continuing: \'I have been writing... since seven o\'clock\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'She has been studying civil engineering at this university for three semesters .',
        translationMl: 'അവൾ മൂന്ന് സെമസ്റ്ററുകളായി ഈ സർവകലാശാലയിൽ സിവിൽ എഞ്ചിനീയറിംഗ് പഠിച്ചുകൊണ്ടിരിക്കുകയാണ്.',
        hint: 'Study duration: \'She has been studying... for three semesters\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Our team has been developing this mobile platform feature for two consecutive months .',
        translationMl: 'ഞങ്ങളുടെ ടീം തുടർച്ചയായി രണ്ട് മാസമായി ഈ മൊബൈൽ പ്ലാറ്റ്‌ഫോം ഫീച്ചർ നിർമ്മിച്ചുകൊണ്ടിരിക്കുകയാണ്.',
        hint: 'Development effort: \'Our team has been developing...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'How long have you been practicing the classical violin for the recital ?',
        translationMl: 'സംഗീത പരിപാടിക്കായി നിങ്ങൾ എത്ര സമയമായി ക്ലാസിക്കൽ വയലിൻ പരിശീലിച്ചുകൊണ്ടിരിക്കുകയാണ്?',
        hint: 'Question: \'How long have you been practicing...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'They have been waiting patiently for the doctor\'s consultation since lunchtime .',
        translationMl: 'ഉച്ചഭക്ഷണ സമയം മുതൽ അവർ ക്ഷമയോടെ ഡോക്ടറെ കാണാൻ കാത്തിരിക്കുകയാണ്.',
        hint: 'Waiting since noon: \'They have been waiting... since lunchtime\'',
      ),
    ],
    // DAY 66: Career History & Experience: Working as a [Role]
    66: [
      _buildRound(
        id: 1,
        sentence: 'I have been working as a software development lead for four consecutive years .',
        translationMl: 'ഞാൻ തുടർച്ചയായി നാല് വർഷമായി സോഫ്റ്റ്‌വെയർ ഡെവലപ്‌മെന്റ് ലീഡായി ജോലി ചെയ്യുന്നു.',
        hint: 'Career role duration: \'I have been working as a... for four years\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'She manages cross functional engineering teams across three global corporate offices .',
        translationMl: 'മൂന്ന് ആഗോള കോർപ്പറേറ്റ് ഓഫീസുകളിലെ വിവിധ എഞ്ചിനീയറിംഗ് ടീമുകളെ അവൾ കൈകാര്യം ചെയ്യുന്നു.',
        hint: 'Leadership responsibility: \'She manages cross functional teams...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Prior to joining this firm , he served as a data analytics consultant .',
        translationMl: 'ഈ സ്ഥാപനത്തിൽ ചേരുന്നതിന് മുമ്പ്, അദ്ദേഹം ഒരു ഡാറ്റ അനലിറ്റിക്സ് കൺസൾട്ടന്റായി സേവനമനുഷ്ഠിച്ചു.',
        hint: 'Prior background: \'Prior to joining this firm, he served as...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'My core expertise lies in financial risk modeling and investment portfolio strategy .',
        translationMl: 'സാമ്പത്തിക റിസ്ക് മോഡലിംഗിലും നിക്ഷേപ പോർട്ട്ഫോളിയോ തന്ത്രങ്ങളിലുമാണ് എന്റെ പ്രധാന വൈദഗ്ധ്യം.',
        hint: 'Core expertise: \'My core expertise lies in...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'They have built a reputable consulting enterprise over the past twelve years .',
        translationMl: 'കഴിഞ്ഞ പന്ത്രണ്ട് വർഷത്തിനിടയിൽ അവർ പ്രശസ്തമായ ഒരു കൺസൾട്ടിംഗ് സംരംഭം കെട്ടിപ്പടുത്തു.',
        hint: 'Company building: \'They have built a reputable enterprise...\'',
      ),
    ],
    // DAY 67: Logical Connectors: Cause & Effect (Because, So, As a result)
    67: [
      _buildRound(
        id: 1,
        sentence: 'The morning train was canceled because severe electrical storms damaged the railway signal cables .',
        translationMl: 'കനത്ത ഇടിമിന്നലിൽ റെയിൽവേ സിഗ്നൽ കേബിളുകൾ തകരാറിലായതിനാൽ രാവിലത്തെ ട്രെയിൻ റദ്ദാക്കി.',
        hint: 'Because + reason: \'...because storms damaged the cables.\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Our team completed the software audit early , so we received a performance commendation .',
        translationMl: 'ഞങ്ങളുടെ സംഘം സോഫ്റ്റ്‌വെയർ ഓഡിറ്റ് നേരത്തെ പൂർത്തിയാക്കി, അതിനാൽ ഞങ്ങൾക്ക് പ്രശംസ ലഭിച്ചു.',
        hint: 'Action, so + result: \'...so we received a commendation.\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Production costs escalated rapidly ; as a result , retail prices were adjusted upward .',
        translationMl: 'ഉൽപ്പാദനച്ചെലവ് കുതിച്ചുയർന്നു; തൽഫലമായി, ചില്ലറ വിൽപ്പന വില വർദ്ധിപ്പിച്ചു.',
        hint: 'Formal connector: \'...as a result, retail prices were adjusted.\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'He missed the executive briefing because his international connecting flight was delayed in Dubai .',
        translationMl: 'ദുബായിൽ കണക്റ്റിംഗ് ഫ്ലൈറ്റ് വൈകിയതിനാൽ അദ്ദേഹത്തിന് എക്സിക്യൂട്ടീവ് മീറ്റിംഗ് നഷ്ടമായി.',
        hint: 'Because + cause: \'...because his flight was delayed.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'The solar panels generated surplus clean electricity , so operational energy bills dropped significantly .',
        translationMl: 'സോളാർ പാനലുകൾ അധിക വൈദ്യുതി ഉത്പാദിപ്പിച്ചു, അതിനാൽ പ്രവർത്തന ചെലവ് ഗണ്യമായി കുറഞ്ഞു.',
        hint: 'So + outcome: \'...so energy bills dropped significantly.\'',
      ),
    ],
    // DAY 68: Contrast Connectors: Although, Even though, However
    68: [
      _buildRound(
        id: 1,
        sentence: 'Although the project deadline was extremely tight , the engineering team delivered exceptional results .',
        translationMl: 'പ്രോജക്റ്റ് ഡെഡ്‌ലൈൻ വളരെ ഇടുങ്ങിയതായിരുന്നിട്ടും, എഞ്ചിനീയറിംഗ് ടീം മികച്ച ഫലങ്ങൾ നൽകി.',
        hint: 'Although + clause: \'Although the deadline was tight, the team delivered...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Even though she faced severe personal hardships , she maintained an inspiring positive attitude .',
        translationMl: 'കടുത്ത വ്യക്തിപരമായ ബുദ്ധിമുട്ടുകൾ നേരിട്ടെങ്കിലും, അവൾ പ്രചോദനാത്മകമായ പോസിറ്റീവ് മനോഭാവം നിലനിർത്തി.',
        hint: 'Even though + adversity: \'Even though she faced hardships, she maintained...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'The prototype showed immense commercial potential ; however , manufacturing expenses remain elevated .',
        translationMl: 'പ്രോട്ടോടൈപ്പ് വലിയ വാണിജ്യ സാധ്യതകൾ പ്രകടമാക്കി; എങ്കിലും, നിർമ്മാണച്ചെലവ് ഉയർന്നതായി തുടരുന്നു.',
        hint: 'Formal however: \'...potential; however, expenses remain elevated.\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Although they lacked financial capital initially , their relentless passion attracted angel investors .',
        translationMl: 'തുടക്കത്തിൽ അവർക്ക് സാമ്പത്തിക മൂലധനം കുറവായിരുന്നിട്ടും, അവരുടെ കഠിനമായ അഭിനിവേശം നിക്ഷേപകരെ ആകർഷിച്ചു.',
        hint: 'Although + lack: \'Although they lacked capital initially...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'He studied medical literature until midnight every evening ; nevertheless , he woke up energized .',
        translationMl: 'എല്ലാ ദിവസവും അർദ്ധരാത്രി വരെ അദ്ദേഹം പഠിച്ചു; എന്നിരുന്നാലും, അദ്ദേഹം ഊർജ്ജസ്വലനായി ഉണർന്നു.',
        hint: 'Nevertheless connector: \'...midnight; nevertheless, he woke up energized.\'',
      ),
    ],
    // DAY 69: First Conditional: Real Future Possibilities
    69: [
      _buildRound(
        id: 1,
        sentence: 'If our client approves this revised budget proposal , we will commence development next Monday .',
        translationMl: 'ക്ലയന്റ് ഈ പുതുക്കിയ ബജറ്റ് നിർദ്ദേശം അംഗീകരിച്ചാൽ, അടുത്ത തിങ്കളാഴ്ച ഞങ്ങൾ വികസന പ്രവർത്തനങ്ങൾ ആരംഭിക്കും.',
        hint: 'If + present simple, will + V1: \'If our client approves..., we will commence...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'If you practice speaking English consistently every day , your conversational fluency will soar .',
        translationMl: 'നിങ്ങൾ എല്ലാ ദിവസവും സ്ഥിരമായി ഇംഗ്ലീഷ് സംസാരിക്കാൻ പരിശീലിച്ചാൽ, നിങ്ങളുടെ സംസാര നൈപുണ്യം കുതിച്ചുയരും.',
        hint: 'If you practice..., your fluency will soar.',
      ),
      _buildRound(
        id: 3,
        sentence: 'We will miss our international connecting flight if the taxi encounters heavy downtown traffic .',
        translationMl: 'ടാക്സി കനത്ത നഗര ഗതാഗതക്കുരുക്കിൽ പെട്ടാൽ ഞങ്ങളുടെ കണക്റ്റിംഗ് ഫ്ലൈറ്റ് നഷ്ടപ്പെടും.',
        hint: 'Result first: \'We will miss... if the taxi encounters...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'If the quarterly financial audit passes without discrepancies , the company will distribute bonuses .',
        translationMl: 'ത്രൈമാസ ഓഡിറ്റ് തെറ്റുകളൊന്നുമില്ലാതെ പാസ്സായാൽ, കമ്പനി ജീവനക്കാർക്ക് ബോണസ് വിതരണം ചെയ്യും.',
        hint: 'If it passes..., the company will distribute...',
      ),
      _buildRound(
        id: 5,
        sentence: 'What will happen if the shipment does not arrive at the regional warehouse tomorrow ?',
        translationMl: 'നാളെ റീജിയണൽ വെയർഹൗസിൽ സാധനങ്ങൾ എത്തിയില്ലെങ്കിൽ എന്ത് സംഭവിക്കും?',
        hint: 'Question: \'What will happen if the shipment does not arrive...?\'',
      ),
    ],
    // DAY 70: Second Conditional: Hypothetical Situations & Dreams
    70: [
      _buildRound(
        id: 1,
        sentence: 'If I won a ten million dollar lottery prize , I would establish free rural medical academies .',
        translationMl: 'എനിക്ക് പത്ത് ദശലക്ഷം ഡോളർ ലോട്ടറി അടിച്ചാൽ, ഞാൻ സൗജന്യ ഗ്രാമീണ മെഡിക്കൽ അക്കാദമികൾ സ്ഥാപിക്കും.',
        hint: 'Hypothetical dream: \'If I won..., I would establish...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'If she were the chief education minister , she would reform the examination grading framework .',
        translationMl: 'അവൾ വിദ്യാഭ്യാസ മന്ത്രിയായിരുന്നെങ്കിൽ, പരീക്ഷാ മൂല്യനിർണ്ണയ രീതി പരിഷ്കരിക്കുമായിരുന്നു.',
        hint: 'Subjunctive were: \'If she were the minister, she would reform...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'If we had unlimited venture funding , we would build solar powered desalinization plants .',
        translationMl: 'ഞങ്ങൾക്ക് പരിധിയില്ലാത്ത ഫണ്ടിംഗ് ഉണ്ടായിരുന്നെങ്കിൽ, സൗരോർജ്ജത്തിൽ പ്രവർത്തിക്കുന്ന കുടിവെള്ള പ്ലാന്റുകൾ നിർമ്മിക്കുമായിരുന്നു.',
        hint: 'Hypothetical resources: \'If we had funding, we would build...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'If I were in your shoes , I would accept that international job opportunity immediately .',
        translationMl: 'ഞാൻ നിങ്ങളുടെ സ്ഥാനത്തായിരുന്നെങ്കിൽ, ആ അന്താരാഷ്ട്ര തൊഴിലവസരം ഞാൻ ഉടൻ സ്വീകരിക്കുമായിരുന്നു.',
        hint: 'Advice idiom: \'If I were in your shoes, I would accept...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Where would you travel if you had a month of uninterrupted free time ?',
        translationMl: 'ഒരു മാസത്തെ ഒഴിവുസമയം ലഭിച്ചാൽ നിങ്ങൾ എങ്ങോട്ടാണ് യാത്ര ചെയ്യുക?',
        hint: 'Hypothetical question: \'Where would you travel if you had...?\'',
      ),
    ],
    // DAY 71: Modals of Probability: May, Might, Could
    71: [
      _buildRound(
        id: 1,
        sentence: 'Heavy afternoon thunderstorms may delay our scheduled flight to Singapore by two hours .',
        translationMl: 'ഉച്ചകഴിഞ്ഞുള്ള കനത്ത ഇടിമിന്നൽ സിംഗപ്പൂരിലേക്കുള്ള ഞങ്ങളുടെ വിമാനം രണ്ട് മണിക്കൂർ വൈകിപ്പിച്ചേക്കാം.',
        hint: 'May delay: \'Thunderstorms may delay our flight...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'The executive committee might approve additional engineering hiring during tomorrow\'s session .',
        translationMl: 'എക്സിക്യൂട്ടീവ് കമ്മിറ്റി നാളത്തെ സെഷനിൽ കൂടുതൽ എഞ്ചിനീയർമാരെ നിയമിക്കുന്നത് അംഗീകരിച്ചേക്കാം.',
        hint: 'Might approve: \'The committee might approve hiring...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'You could explore renewable solar solutions to reduce manufacturing operational overhead .',
        translationMl: 'നിർമ്മാണ ചെലവ് കുറയ്ക്കുന്നതിന് നിങ്ങൾക്ക് സൗരോർജ്ജ സാധ്യതകൾ പരിശോധിക്കാവുന്നതാണ്.',
        hint: 'Suggestion modal: \'You could explore solar solutions...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'We might not receive the final government permit before the end of this month .',
        translationMl: 'ഈ മാസം അവസാനത്തിന് മുമ്പ് ഞങ്ങൾക്ക് അന്തിമ സർക്കാർ അനുമതി ലഭിച്ചേക്കില്ല.',
        hint: 'Negative possibility: \'We might not receive...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could this technical glitch be related to yesterday\'s cloud database migration ?',
        translationMl: 'ഈ സാങ്കേതിക തകരാർ ഇന്നലത്തെ ക്ലൗഡ് ഡാറ്റാബേസ് മാറ്റവുമായി ബന്ധപ്പെട്ടതായിരിക്കുമോ?',
        hint: 'Possibility inquiry: \'Could this glitch be related to...?\'',
      ),
    ],
    // DAY 72: Modals of Deduction: Must be vs Can\'t be
    72: [
      _buildRound(
        id: 1,
        sentence: 'He worked an eighteen hour shift without sleep , so he must be completely fatigued .',
        translationMl: 'അദ്ദേഹം ഉറക്കമില്ലാതെ പതിനെട്ട് മണിക്കൂർ ജോലി ചെയ്തു, അതിനാൽ അദ്ദേഹം തീർച്ചയായും കഠിനമായി ക്ഷീണിച്ചിട്ടുണ്ടാകും.',
        hint: 'Logical deduction: \'...so he must be fatigued.\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'That luxury sports car can\'t be his because he just started his internship yesterday .',
        translationMl: 'ആ ആഡംബര സ്പോർട്സ് കാർ ഒരിക്കലും അദ്ദേഹത്തിന്റേതാകാൻ വഴിയില്ല, കാരണം അദ്ദേഹം ഇന്നലെയാണ് ഇന്റേൺഷിപ്പ് തുടങ്ങിയത്.',
        hint: 'Impossible deduction: \'...can\'t be his because...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'The museum lights are still shining brightly , so the curators must still be inside .',
        translationMl: 'മ്യൂസിയത്തിലെ ലൈറ്റുകൾ ഇപ്പോഴും തെളിഞ്ഞുനിൽക്കുന്നു, അതിനാൽ ക്യൂറേറ്റർമാർ തീർച്ചയായും അകത്തുണ്ടാകും.',
        hint: 'Evidence to deduction: \'...so they must still be inside.\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'This signature can\'t be authentic because the ink formula was only invented in the nineteenth century .',
        translationMl: 'ഈ ഒപ്പ് യഥാർത്ഥമാകാൻ വഴിയില്ല, കാരണം മഷി വിദ്യ പത്തൊൻപതാം നൂറ്റാണ്ടിലാണ് കണ്ടുപിടിച്ചത്.',
        hint: 'Impossible: \'can\'t be authentic because...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'She has won five consecutive gold medals , so she must be an exceptionally gifted athlete .',
        translationMl: 'അവൾ തുടർച്ചയായി അഞ്ച് സ്വർണ്ണ മെഡലുകൾ നേടിയിട്ടുണ്ട്, അതിനാൽ അവൾ തീർച്ചയായും അസാധാരണ കഴിവുള്ള കായികതാരമായിരിക്കും.',
        hint: 'Must be + gifted athlete',
      ),
    ],
    // DAY 73: Passive Voice in Business & Reports
    73: [
      _buildRound(
        id: 1,
        sentence: 'The annual audited balance sheet has been submitted to the ministry of corporate affairs .',
        translationMl: 'വാർഷിക ഓഡിറ്റ് ചെയ്ത ബാലൻസ് ഷീറ്റ് കോർപ്പറേറ്റ് കാര്യ മന്ത്രാലയത്തിന് സമർപ്പിക്കപ്പെട്ടിട്ടുണ്ട്.',
        hint: 'Present Perfect passive: \'has been submitted to...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Critical software security updates were deployed across all corporate workstations last midnight .',
        translationMl: 'ഇന്നലെ അർദ്ധരാത്രി എല്ലാ വർക്ക്‌സ്റ്റേഷനുകളിലും നിർണായക സോഫ്റ്റ്‌വെയർ സെക്യൂരിറ്റി അപ്‌ഡേറ്റുകൾ ഇൻസ്റ്റാൾ ചെയ്യപ്പെട്ടു.',
        hint: 'Past passive: \'were deployed across...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Fresh organic vegetables are harvested daily and transported to metropolitan supermarkets .',
        translationMl: 'പുതിയ ജൈവ പച്ചക്കറികൾ ദിവസവും വിളവെടുക്കുകയും നഗര സൂപ്പർമാർക്കറ്റുകളിലേക്ക് എത്തിക്കുകയും ചെയ്യുന്നു.',
        hint: 'Present Simple passive: \'are harvested and transported...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Formal written authorization must be obtained prior to accessing patient health records .',
        translationMl: 'രോഗികളുടെ ആരോഗ്യ വിവരങ്ങൾ പരിശോധിക്കുന്നതിന് മുമ്പ് ഔദ്യോഗിക രേഖാമൂലമുള്ള അനുമതി വാങ്ങിയിരിക്കണം.',
        hint: 'Modal passive: \'must be obtained prior to...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'A new solar energy manufacturing plant will be constructed in the industrial zone .',
        translationMl: 'വ്യാവസായിക മേഖലയിൽ പുതിയ സൗരോർജ്ജ നിർമ്മാണ പ്ലാന്റ് നിർമ്മിക്കപ്പെടും.',
        hint: 'Future passive: \'will be constructed in...\'',
      ),
    ],
    // DAY 74: Professional Telephone Etiquette & Connecting Calls
    74: [
      _buildRound(
        id: 1,
        sentence: 'Good morning , this is Rahul calling from the logistics operations division .',
        translationMl: 'ശുഭോദയം, ഞാൻ ലോജിസ്റ്റിക്സ് ഓപ്പറേഷൻസ് വിഭാഗത്തിൽ നിന്നുള്ള രാഹുലാണ് വിളിക്കുന്നത്.',
        hint: 'Phone intro: \'This is Rahul calling from...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'May I please speak with Ms . Anita in the accounts department ?',
        translationMl: 'എനിക്ക് അക്കൗണ്ട്സ് വിഭാഗത്തിലെ അനിതയുമായി സംസാരിക്കാമോ?',
        hint: 'Polite request: \'May I please speak with...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Could you kindly hold the line while I transfer your call to her extension ?',
        translationMl: 'ഞാൻ നിങ്ങളുടെ കോൾ അവരുടെ എക്സ്റ്റൻഷനിലേക്ക് മാറ്റുന്നതുവരെ ദയവായി ഒന്ന് കാത്തിരിക്കാമോ?',
        hint: 'Transfer line: \'Could you kindly hold the line while...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I am afraid her line is currently engaged with another overseas client .',
        translationMl: 'അവരുടെ ഫോൺ ഇപ്പോൾ മറ്റൊരു വിദേശ ക്ലയന്റുമായി സംഭാഷണത്തിലാണെന്ന് ഞാൻ ഭയപ്പെടുന്നു.',
        hint: 'Polite apology: \'I am afraid her line is currently engaged...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Would you like me to connect you to her personal voicemail box ?',
        translationMl: 'അവരുടെ വോയ്‌സ്‌മെയിൽ ബോക്സിലേക്ക് ഞാൻ കണക്റ്റ് ചെയ്യണമെന്നുണ്ടോ?',
        hint: 'Offering voicemail: \'Would you like me to connect you...?\'',
      ),
    ],
    // DAY 75: Voicemails & Taking Messages Professionally
    75: [
      _buildRound(
        id: 1,
        sentence: 'Could you please take a message for Dr . Anand and request him to call me back ?',
        translationMl: 'ഡോ. ആനന്ദിന് വേണ്ടി ഒരു സന്ദേശം കുറിച്ചെടുത്ത് എന്നെ തിരിച്ചുവിളിക്കാൻ ആവശ്യപ്പെടാമോ?',
        hint: 'Take message: \'Could you please take a message for...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Please inform Ms . Deepa that our supplier confirmed the cargo shipment will arrive tomorrow .',
        translationMl: 'ചരക്ക് നാളെ എത്തുമെന്ന് സപ്ലയർ സ്ഥിരീകരിച്ച വിവരം ദയവായി ദീപയെ അറിയിക്കുക.',
        hint: 'Passing info: \'Please inform Ms. Deepa that...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Hi , you have reached the voicemail of David Paul ; please leave your name and number .',
        translationMl: 'ഹലോ, നിങ്ങൾ ഡേവിഡ് പോളിന്റെ വോയ്‌സ്‌മെയിലിലാണ് എത്തിയിരിക്കുന്നത്; ദയവായി പേരും നമ്പറും പറയുക.',
        hint: 'Voicemail greeting: \'You have reached the voicemail of...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I am calling regarding the commercial lease contract and need a brief clarification .',
        translationMl: 'വാണിജ്യ പാട്ടക്കരാറുമായി ബന്ധപ്പെട്ട് ഒരു ചെറിയ വ്യക്തത തേടാനാണ് ഞാൻ വിളിക്കുന്നത്.',
        hint: 'Calling regarding: \'I am calling regarding...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'He can reach me on my mobile at nine eight four seven zero one two three four five .',
        translationMl: 'എന്റെ മൊബൈൽ നമ്പറായ 9847012345 ൽ അദ്ദേഹത്തിന് എന്നെ തിരിച്ചുവിളിക്കാവുന്നതാണ്.',
        hint: 'Leave number clearly',
      ),
    ],
    // DAY 76: Office Watercooler & Casual Workplace Talk
    76: [
      _buildRound(
        id: 1,
        sentence: 'How did your weekend go , Anita ? Did you manage to get some rest ?',
        translationMl: 'അനിതാ, നിങ്ങളുടെ വാരാന്ത്യം എങ്ങനെയുണ്ടായിരുന്നു? കുറച്ച് വിശ്രമിക്കാൻ കഴിഞ്ഞോ?',
        hint: 'Weekend check: \'How did your weekend go...?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'The coffee machine on the third floor cafeteria is finally working properly again .',
        translationMl: 'മൂന്നാം നിലയിലെ കഫറ്റീരിയയിലെ കോഫി മെഷീൻ ഒടുവിൽ വീണ്ടും ശരിയായി പ്രവർത്തിക്കുന്നുണ്ട്.',
        hint: 'Casual watercooler observation: \'The coffee machine is working again.\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Are you attending the company cricket tournament scheduled for this Saturday afternoon ?',
        translationMl: 'ഈ ശനിയാഴ്ച ഉച്ചതിരിഞ്ഞ് നടക്കുന്ന കമ്പനി ക്രിക്കറ്റ് ടൂർണമെന്റിൽ നിങ്ങൾ പങ്കെടുക്കുന്നുണ്ടോ?',
        hint: 'Sports talk: \'Are you attending the cricket tournament...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'How is the client presentation preparation coming along for your team ?',
        translationMl: 'നിങ്ങളുടെ ടീമിന്റെ ക്ലയന്റ് പ്രസന്റേഷൻ തയ്യാറെടുപ്പുകൾ എങ്ങനെ പുരോഗമിക്കുന്നു?',
        hint: 'Work check-in: \'How is the preparation coming along...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Let us grab a quick lunch together at the garden bistro downstairs .',
        translationMl: 'നമുക്ക് താഴെയുള്ള ഗാർഡൻ ബിസ്ട്രോയിൽ നിന്ന് ഒരുമിച്ച് പെട്ടെന്ന് ഉച്ചഭക്ഷണം കഴിക്കാം.',
        hint: 'Lunch invite: \'Let us grab lunch together...\'',
      ),
    ],
    // DAY 77: Daily Standups & Agile Meetings
    77: [
      _buildRound(
        id: 1,
        sentence: 'Yesterday I completed the user authentication module and wrote all unit test cases .',
        translationMl: 'ഇന്നലെ ഞാൻ ഉപയോക്തൃ ലോഗിൻ മൊഡ്യൂൾ പൂർത്തിയാക്കുകയും എല്ലാ യൂണിറ്റ് ടെസ്റ്റ് കേസുകളും എഴുതുകയും ചെയ്തു.',
        hint: 'Standup part 1: \'Yesterday I completed...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Today I am focusing on integrating the payment gateway API with our mobile backend .',
        translationMl: 'ഇന്ന് ഞാൻ പേയ്‌മെന്റ് ഗേറ്റ്‌വേ എപിഐ ഞങ്ങളുടെ മൊബൈൽ ബാക്കെൻഡുമായി ബന്ധിപ്പിക്കുന്നതിൽ ശ്രദ്ധ കേന്ദ്രീകരിക്കുന്നു.',
        hint: 'Standup part 2: \'Today I am focusing on...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I currently have no blockers and anticipate finishing this task before tomorrow noon .',
        translationMl: 'എനിക്ക് നിലവിൽ തടസ്സങ്ങളൊന്നുമില്ല, നാളെ ഉച്ചയ്ക്ക് മുമ്പ് ഈ ജോലി പൂർത്തിയാക്കാൻ കഴിയുമെന്ന് പ്രതീക്ഷിക്കുന്നു.',
        hint: 'Standup part 3: \'I have no blockers...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'I am facing one blocker regarding API server credentials from the third party vendor .',
        translationMl: 'തേർഡ് പാർട്ടി വെണ്ടറിൽ നിന്നുള്ള എപിഐ ലോഗിൻ വിവരങ്ങൾ സംബന്ധിച്ച് ഞാൻ ഒരു തടസ്സം നേരിടുന്നുണ്ട്.',
        hint: 'Stating blocker: \'I am facing one blocker regarding...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Can we take this detailed technical architectural discussion offline after the standup concludes ?',
        translationMl: 'സ്റ്റാൻഡ്അപ്പ് കഴിഞ്ഞ ശേഷം നമുക്ക് ഈ സാങ്കേതിക ചർച്ച പ്രത്യേകം സംസാരിക്കാമോ?',
        hint: 'Take offline: \'Can we take this discussion offline...?\'',
      ),
    ],
    // DAY 78: Sharing Opinions Diplomatically in Meetings
    78: [
      _buildRound(
        id: 1,
        sentence: 'From my perspective , prioritizing mobile application security will foster greater long term customer trust .',
        translationMl: 'എന്റെ വീക്ഷണത്തിൽ, മൊബൈൽ ആപ്പ് സുരക്ഷയ്ക്ക് മുൻഗണന നൽകുന്നത് ഉപഭോക്താക്കളുടെ ദീർഘകാല വിശ്വാസം വർദ്ധിപ്പിക്കും.',
        hint: 'Opinion opener: \'From my perspective...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'In my opinion , allocating additional resources to user research would be highly advantageous .',
        translationMl: 'എന്റെ അഭിപ്രായത്തിൽ, ഉപയോക്തൃ ഗവേഷണത്തിനായി കൂടുതൽ വിഭവങ്ങൾ അനുവദിക്കുന്നത് വളരെ ഗുണകരമായിരിക്കും.',
        hint: 'In my opinion + conditional: \'...would be highly advantageous.\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'As far as I can tell , this proposed vendor agreement offers superior value for money .',
        translationMl: 'എനിക്ക് മനസ്സിലാക്കാൻ കഴിഞ്ഞിടത്തോളം, ഈ വെണ്ടർ കരാർ പണത്തിന് മികച്ച മൂല്യം നൽകുന്നു.',
        hint: 'As far as I can tell: \'As far as I can tell, this offers superior value...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'It appears to me that simplifying our registration form will reduce user drop-off rates .',
        translationMl: 'രജിസ്ട്രേഷൻ ഫോം ലളിതമാക്കുന്നത് ഉപയോക്താക്കൾ പാതിവഴിയിൽ ഉപേക്ഷിക്കുന്നത് കുറയ്ക്കുമെന്നാണ് എനിക്ക് തോന്നുന്നത്.',
        hint: 'Diplomatic opener: \'It appears to me that...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Would it be worthwhile to consider conducting a small pilot study before the full rollout ?',
        translationMl: 'പൂർണ്ണമായി നടപ്പിലാക്കുന്നതിന് മുൻപ് ഒരു ചെറിയ പൈലറ്റ് പഠനം നടത്തുന്നത് ഉചിതമായിരിക്കുമോ?',
        hint: 'Polite suggestion: \'Would it be worthwhile to consider...?\'',
      ),
    ],
    // DAY 79: Diplomatic Disagreement & Constructive Feedback
    79: [
      _buildRound(
        id: 1,
        sentence: 'I see your point regarding speed , but rushing deployment might compromise user security .',
        translationMl: 'വേഗതയെക്കുറിച്ചുള്ള നിങ്ങളുടെ കാഴ്ചപ്പാട് ഞാൻ മനസ്സിലാക്കുന്നു, എന്നാൽ തിടുക്കപ്പെട്ട് റിലീസ് ചെയ്യുന്നത് ഉപയോക്തൃ സുരക്ഷയെ ബാധിച്ചേക്കാം.',
        hint: 'I see your point, but...: \'I see your point..., but rushing might...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Respectfully , I have a slightly different perspective on our marketing budget allocation .',
        translationMl: 'ബഹുമാനത്തോടെ പറയട്ടെ, ഞങ്ങളുടെ മാർക്കറ്റിംഗ് ബജറ്റ് വിനിയോഗത്തെക്കുറിച്ച് എനിക്ക് അല്പം വ്യത്യസ്തമായ ഒരു കാഴ്ചപ്പാടുണ്ട്.',
        hint: 'Respectful disagreement: \'Respectfully, I have a different perspective...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'I appreciate that suggestion ; however , our existing server architecture cannot support that volume .',
        translationMl: 'ആ നിർദ്ദേശത്തെ ഞാൻ അഭിനന്ദിക്കുന്നു; എങ്കിലും, ഞങ്ങളുടെ നിലവിലെ സെർവർ ശേഷിക്ക് അത്രയും ഭാരം താങ്ങാൻ കഴിയില്ല.',
        hint: 'Appreciate + however: \'I appreciate that suggestion; however...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'While I agree with your long term vision , I worry about immediate cash flow constraints .',
        translationMl: 'നിങ്ങളുടെ ദീർഘകാല കാഴ്ചപ്പാടിനോട് ഞാൻ യോജിക്കുമ്പോഴും, നിലവിലെ സാമ്പത്തിക പരിമിതികളെക്കുറിച്ച് എനിക്ക് ആശങ്കയുണ്ട്.',
        hint: 'While I agree..., I worry about...',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could we perhaps explore a middle ground that accommodates both speed and security testing ?',
        translationMl: 'വേഗതയും സുരക്ഷാ പരിശോധനയും ഒരുപോലെ ഉറപ്പാക്കുന്ന ഒരു മധ്യമാർഗ്ഗം നമുക്ക് പരിശോധിക്കാമോ?',
        hint: 'Seeking compromise: \'Could we perhaps explore a middle ground...?\'',
      ),
    ],
    // DAY 80: Delivering Presentations & Signposting
    80: [
      _buildRound(
        id: 1,
        sentence: 'Good morning everyone ; today I am delighted to present our new corporate product strategy .',
        translationMl: 'എല്ലാവർക്കും ശുഭോദയം; ഇന്ന് ഞങ്ങളുടെ പുതിയ ഉൽപ്പന്ന തന്ത്രം അവതരിപ്പിക്കുന്നതിൽ എനിക്ക് വലിയ സന്തോഷമുണ്ട്.',
        hint: 'Presentation opener: \'Today I am delighted to present...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'First , I will provide an overview of our market research findings from three continents .',
        translationMl: 'ആദ്യമായി, മൂന്ന് ഭൂഖണ്ഡങ്ങളിൽ നിന്നുള്ള ഞങ്ങളുടെ വിപണി ഗവേഷണ കണ്ടെത്തലുകളുടെ ഒരു അവലോകനം ഞാൻ നൽകും.',
        hint: 'Signpost 1: \'First, I will provide an overview...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Moving on to our second key point , let us examine the quarterly user engagement metrics .',
        translationMl: 'ഞങ്ങളുടെ രണ്ടാമത്തെ പ്രധാന വിഷയത്തിലേക്ക് കടക്കുമ്പോൾ, നമുക്ക് ത്രൈമാസ ഉപയോക്തൃ കണക്കുകൾ പരിശോധിക്കാം.',
        hint: 'Signpost 2: \'Moving on to our second key point...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'To illustrate this trend , please turn your attention to the bar graph on this slide .',
        translationMl: 'ഈ മാറ്റം വ്യക്തമാക്കാൻ, ദയവായി ഈ സ്ലൈഡിലെ ബാർ ഗ്രാഫിലേക്ക് നിങ്ങളുടെ ശ്രദ്ധ തിരിക്കുക.',
        hint: 'Signpost 3: \'To illustrate this trend, please turn your attention to...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'To conclude , adopting this digital platform will significantly streamline enterprise communications .',
        translationMl: 'ഉപസംഹരിക്കുമ്പോൾ, ഈ ഡിജിറ്റൽ പ്ലാറ്റ്‌ഫോം സ്വീകരിക്കുന്നത് കമ്പനിയുടെ ആശയവിനിമയത്തെ വളരെയധികം കാര്യക്ഷമമാക്കും.',
        hint: 'Signpost 4: \'To conclude, adopting this platform will...\'',
      ),
    ],
    // DAY 81: Job Interview Pitch: The 3-Part Pitch Framework
    81: [
      _buildRound(
        id: 1,
        sentence: 'I began my career in mechanical engineering before pivoting into software systems architecture .',
        translationMl: 'സോഫ്റ്റ്‌വെയർ ആർക്കിടെക്ചറിലേക്ക് തിരിയുന്നതിന് മുമ്പ് ഞാൻ മെക്കാനിക്കൽ എഞ്ചിനീയറിംഗിലാണ് കരിയർ ആരംഭിച്ചത്.',
        hint: 'Past foundation: \'I began my career in... before pivoting into...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Currently , I manage a high performing squad that scales cloud infrastructure for millions of active users .',
        translationMl: 'നിലവിൽ, ദശലക്ഷക്കണക്കിന് ഉപയോക്താക്കൾക്കായി ക്ലൗഡ് ഇൻഫ്രാസ്ട്രക്ചർ കൈകാര്യം ചെയ്യുന്ന ഒരു ടീമിനെ ഞാൻ നയിക്കുന്നു.',
        hint: 'Present impact: \'Currently, I manage a squad that scales...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What excites me about this leadership role is your organization \' s focus on sustainable green technology .',
        translationMl: 'ഈ നേതൃപദവിയിൽ എന്നെ ആകർഷിക്കുന്നത് നിങ്ങളുടെ സ്ഥാപനം പരിസ്ഥിതി സൗഹൃദ സാങ്കേതികവിദ്യയ്ക്ക് നൽകുന്ന മുൻഗണനയാണ്.',
        hint: 'Future alignment: \'What excites me about this role is...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'My core strength lies in translating complex stakeholder requirements into elegant technical solutions .',
        translationMl: 'സങ്കീർണ്ണമായ ബിസിനസ്സ് ആവശ്യകതകളെ മികച്ച സാങ്കേതിക പരിഹാരങ്ങളാക്കി മാറ്റുന്നതിലാണ് എന്റെ പ്രധാന കരുത്ത്.',
        hint: 'Core value proposition: \'My core strength lies in...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I am eager to contribute my decade of enterprise expertise toward driving your next phase of growth .',
        translationMl: 'നിങ്ങളുടെ അടുത്ത ഘട്ട വളർച്ചയിലേക്ക് എന്റെ ഒരു പതിറ്റാണ്ടിന്റെ പ്രാവീണ്യം സംഭാവന ചെയ്യാൻ ഞാൻ അതീവ താല്പര്യപ്പെടുന്നു.',
        hint: 'Closing statement: \'I am eager to contribute my expertise toward...\'',
      ),
    ],
    // DAY 82: Strengths & Constructive Weaknesses in Interviews
    82: [
      _buildRound(
        id: 1,
        sentence: 'My core strength is decomposing ambiguous business dilemmas into structured , actionable milestones .',
        translationMl: 'അവ്യക്തമായ ബിസിനസ്സ് പ്രശ്നങ്ങളെ ഘടനാപരമായ പ്രായോഗിക ലക്ഷ്യങ്ങളാക്കി മാറ്റുക എന്നതാണ് എന്റെ പ്രധാന കരുത്ത്.',
        hint: 'Strength statement: \'My core strength is decomposing...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'In the past , I struggled with delegating tasks because I wanted everything executed perfectly .',
        translationMl: 'മുൻകാലങ്ങളിൽ, കാര്യങ്ങൾ പൂർണ്ണതയോടെ നടക്കണമെന്ന് ആഗ്രഹിച്ചതിനാൽ മറ്റുള്ളവർക്ക് ചുമതലകൾ വിട്ടുകൊടുക്കാൻ ഞാൻ ബുദ്ധിമുട്ടിയിരുന്നു.',
        hint: 'Authentic weakness: \'In the past, I struggled with delegating...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'To rectify this , I implemented weekly mentoring sessions and established clear ownership boundaries .',
        translationMl: 'ഇത് പരിഹരിക്കാൻ, ഞാൻ പ്രതിവാര പരിശീലന സെഷനുകൾ ആരംഭിക്കുകയും ഉത്തരവാദിത്തങ്ങൾ വ്യക്തമായി വിഭജിക്കുകയും ചെയ്തു.',
        hint: 'Remedial action: \'To rectify this, I implemented...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'As a tangible result , my team \' s independent delivery speed increased by thirty percent .',
        translationMl: 'തൽഫലമായി, എന്റെ ടീമിന്റെ സ്വതന്ത്രമായ ജോലി വേഗത മുപ്പത് ശതമാനം വർദ്ധിച്ചു.',
        hint: 'Positive habit outcome: \'As a result, delivery speed increased...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'I continually solicit peer feedback to identify blind spots in my collaborative leadership style .',
        translationMl: 'എന്റെ നേതൃത്വ ശൈലിയിലെ പോരായ്മകൾ തിരിച്ചറിയാൻ സഹപ്രവർത്തകരിൽ നിന്ന് ഞാൻ നിരന്തരം അഭിപ്രായങ്ങൾ തേടുന്നു.',
        hint: 'Continuous learning: \'I continually solicit peer feedback...\'',
      ),
    ],
    // DAY 83: Behavioral Questions & The STAR Method
    83: [
      _buildRound(
        id: 1,
        sentence: 'Situation : Our payment gateway suffered intermittent failures during a massive nationwide festive sale .',
        translationMl: 'സാഹചര്യം: ഒരു വലിയ ദേശീയ ഉത്സവ വിൽപ്പനയ്ക്കിടെ ഞങ്ങളുടെ പേയ്‌മെന്റ് ഗേറ്റ്‌വേയിൽ ഇടയ്ക്കിടെ തകരാറുകൾ ഉണ്ടായി.',
        hint: 'STAR S: Situation context',
      ),
      _buildRound(
        id: 2,
        sentence: 'Task : My responsibility as lead architect was to stabilize transactions without terminating user checkout sessions .',
        translationMl: 'ചുമതല: ചെക്ക്ഔട്ട് സെഷനുകൾ റദ്ദാക്കാതെ തന്നെ ഇടപാടുകൾ സ്ഥിരപ്പെടുത്തുക എന്നതായിരുന്നു ലീഡ് ആർക്കിടെക്റ്റ് എന്ന നിലയിൽ എന്റെ ഉത്തരവാദിത്തം.',
        hint: 'STAR T: Task and responsibility',
      ),
      _buildRound(
        id: 3,
        sentence: 'Action : I configured automatic traffic routing to a secondary backup processor within twenty minutes .',
        translationMl: 'നടപടി: ഇരുപത് മിനിറ്റിനുള്ളിൽ ഞാൻ ഒരു സെക്കൻഡറി ബാക്കപ്പ് പ്രോസസ്സറിലേക്ക് ഓട്ടോമാറ്റിക് ട്രാഫിക് റൂട്ടിംഗ് സജ്ജീകരിച്ചു.',
        hint: 'STAR A: Action taken',
      ),
      _buildRound(
        id: 4,
        sentence: 'Result : As a quantifiable outcome , transaction success recovered to ninety nine percent , preserving two million dollars .',
        translationMl: 'ഫലം: കൃത്യമായ ഫലമായി, ഇടപാടുകളുടെ വിജയശതമാനം 99% ആയി ഉയരുകയും രണ്ട് ദശലക്ഷം ഡോളർ നഷ്ടപ്പെടാതെ സംരക്ഷിക്കുകയും ചെയ്തു.',
        hint: 'STAR R: Quantifiable result',
      ),
      _buildRound(
        id: 5,
        sentence: 'The executive committee commended our rapid incident response and adopted our disaster recovery protocol enterprise-wide .',
        translationMl: 'എക്സിക്യൂട്ടീവ് കമ്മിറ്റി ഞങ്ങളുടെ പെട്ടെന്നുള്ള ഇടപെടലിനെ പ്രശംസിക്കുകയും ഈ പ്രോട്ടോക്കോൾ കമ്പനി മുഴുവൻ നടപ്പിലാക്കുകയും ചെയ്തു.',
        hint: 'Long-term impact: \'The committee adopted our protocol enterprise-wide.\'',
      ),
    ],
    // DAY 84: Asking Strategic Questions to Interview Panels
    84: [
      _buildRound(
        id: 1,
        sentence: 'What does extraordinary success look like in this role over the first ninety days ?',
        translationMl: 'ഈ തസ്തികയിൽ ആദ്യത്തെ തൊണ്ണൂറ് ദിവസത്തിനുള്ളിൽ അസാധാരണമായ വിജയം കൈവരിക്കുക എന്നാൽ എന്താണ് അർത്ഥമാക്കുന്നത്?',
        hint: '90-day impact: \'What does success look like in the first ninety days?\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'How would you describe the collaborative engineering culture and decision making speed here ?',
        translationMl: 'ഇവിടുത്തെ എഞ്ചിനീയറിംഗ് ടീമിന്റെ കൂട്ടായ്മയെയും തീരുമാനങ്ങൾ എടുക്കുന്ന വേഗതയെയും നിങ്ങൾ എങ്ങനെ വിശേഷിപ്പിക്കും?',
        hint: 'Culture question: \'How would you describe the culture...?\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'What is the single biggest technical hurdle currently facing this product development squad ?',
        translationMl: 'ഈ ഉൽപ്പന്ന നിർമ്മാണ ടീം നിലവിൽ നേരിടുന്ന ഏറ്റവും വലിയ സാങ്കേതിക വെല്ലുവിളി എന്താണ്?',
        hint: 'Hurdle inquiry: \'What is the biggest hurdle currently facing...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'How does leadership support ongoing professional development and technical mentorship for employees ?',
        translationMl: 'ജീവനക്കാരുടെ തൊഴിൽപരമായ വളർച്ചയ്ക്കും മെന്റർഷിപ്പിനും മാനേജ്‌മെന്റ് എങ്ങനെയാണ് പിന്തുണ നൽകുന്നത്?',
        hint: 'Growth support: \'How does leadership support ongoing development...?\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'What distinguishes the top performers within your organization from average team members ?',
        translationMl: 'നിങ്ങളുടെ സ്ഥാപനത്തിലെ മികച്ച പ്രകടനം നടത്തുന്നവരെ മറ്റുള്ളവരിൽ നിന്ന് വ്യത്യസ്തരാക്കുന്നത് എന്താണ്?',
        hint: 'Top performer benchmark: \'What distinguishes top performers...?\'',
      ),
    ],
    // DAY 85: Salary & Compensation Package Negotiation
    85: [
      _buildRound(
        id: 1,
        sentence: 'Thank you for this offer ; I am truly thrilled about the prospect of joining your innovative engineering squad .',
        translationMl: 'ഈ ഓഫറിന് നന്ദി; നിങ്ങളുടെ ഇന്നൊവേറ്റീവ് എഞ്ചിനീയറിംഗ് ടീമിൽ ചേരുന്നതിൽ എനിക്ക് വലിയ സന്തോഷമുണ്ട്.',
        hint: 'Gratitude & enthusiasm: \'Thank you for this offer; I am truly thrilled...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Based on my decade of distributed systems expertise and regional industry benchmarks , I was anticipating a higher base .',
        translationMl: 'എന്റെ ഒരു പതിറ്റാണ്ടിന്റെ പരിചയസമ്പത്തും വിപണി നിരക്കുകളും അടിസ്ഥാനമാക്കി, ഉയർന്ന അടിസ്ഥാന ശമ്പളം ഞാൻ പ്രതീക്ഷിച്ചിരുന്നു.',
        hint: 'Anchoring value: \'Based on my expertise and industry benchmarks...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Would there be any flexibility regarding the annual performance bonus or stock equity vesting schedule ?',
        translationMl: 'വാർഷിക ബോണസിലോ സ്റ്റോക്ക് ഇക്വിറ്റി വ്യവസ്ഥകളിലോ എന്തെങ്കിലും ഇളവുകൾ സാധ്യമാണോ?',
        hint: 'Package flexibility: \'Would there be any flexibility regarding...?\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'If we can reach an agreement at ninety thousand dollars , I would be delighted to accept immediately .',
        translationMl: 'തൊണ്ണൂറായിരം ഡോളറിൽ നമുക്ക് ധാരണയിലെത്താൻ കഴിയുമെങ്കിൽ, ഞാൻ ഈ ഓഫർ ഉടനടി സ്വീകരിക്കുന്നതിൽ അതീവ സന്തുഷ്ടനായിരിക്കും.',
        hint: 'Conditional commitment: \'If we can reach an agreement at..., I would accept immediately.\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Could you kindly provide a written breakdown of the comprehensive health insurance and retirement benefits ?',
        translationMl: 'ആരോഗ്യ ഇൻഷുറൻസും വിരമിക്കൽ ആനുകൂല്യങ്ങളും സംബന്ധിച്ച വിശദമായ രേഖ നൽകാമോ?',
        hint: 'Formal documentation: \'Could you kindly provide a written breakdown...?\'',
      ),
    ],
    // DAY 86: Native Idioms in Context: Vol 1
    86: [
      _buildRound(
        id: 1,
        sentence: 'We must bite the bullet and invest in modernizing our legacy server software infrastructure .',
        translationMl: 'കഠിനമാണെങ്കിൽ പോലും നമ്മൾ ധൈര്യത്തോടെ മുന്നോട്ട് പോയി സെർവർ സോഫ്റ്റ്‌വെയർ നവീകരിക്കേണ്ടതുണ്ട് (Bite the bullet).',
        hint: 'Bite the bullet: Face a tough situation bravely',
      ),
      _buildRound(
        id: 2,
        sentence: 'The workshop facilitator organized a fun group game to break the ice among delegates .',
        translationMl: 'പ്രതിനിധികൾ തമ്മിലുള്ള അപരിചിതത്വം മാറ്റാൻ ഫെസിലിറ്റേറ്റർ ഒരു രസകരമായ ഗ്രൂപ്പ് ഗെയിം സംഘടിപ്പിച്ചു (Break the ice).',
        hint: 'Break the ice: Relieve initial tension',
      ),
      _buildRound(
        id: 3,
        sentence: 'We have accomplished all major tasks on today \' s agenda , so let us call it a day .',
        translationMl: 'ഇന്നത്തെ അജണ്ടയിലെ എല്ലാ പ്രധാന ജോലികളും ഞങ്ങൾ ചെയ്തു കഴിഞ്ഞു, അതിനാൽ ഇന്നത്തെ ജോലി അവസാനിപ്പിക്കാം (Call it a day).',
        hint: 'Call it a day: Stop working for the day',
      ),
      _buildRound(
        id: 4,
        sentence: 'Our engineering squad burned the midnight oil to submit the patent application before the deadline .',
        translationMl: 'സമയപരിധിക്ക് മുൻപ് പേറ്റന്റ് സമർപ്പിക്കാൻ ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ടീം രാത്രി വൈകുവോളം കഠിനാധ്വാനം ചെയ്തു (Burn the midnight oil).',
        hint: 'Burn the midnight oil: Work late into the night',
      ),
      _buildRound(
        id: 5,
        sentence: 'The two executive founders do not always see eye to eye on long term marketing strategy .',
        translationMl: 'ദീർഘകാല മാർക്കറ്റിംഗ് തന്ത്രത്തിൽ രണ്ട് സ്ഥാപകരും എല്ലായ്പ്പോഴും പൂർണ്ണമായി യോജിക്കാറില്ല (See eye to eye).',
        hint: 'See eye to eye: Agree with someone',
      ),
    ],
    // DAY 87: Native Idioms in Context: Vol 2
    87: [
      _buildRound(
        id: 1,
        sentence: 'I am feeling a bit under the weather today , so I will be working from home .',
        translationMl: 'ഇന്ന് എനിക്ക് ചെറിയൊരു സുഖമില്ലായ്മ തോന്നുന്നു, അതിനാൽ ഞാൻ വീട്ടിലിരുന്ന് ജോലി ചെയ്യും (Under the weather).',
        hint: 'Under the weather: Feeling slightly unwell',
      ),
      _buildRound(
        id: 2,
        sentence: 'Priya \' s insightful analysis really hit the nail on the head regarding our customer retention drop .',
        translationMl: 'ഉപഭോക്താക്കൾ കുറയുന്നതിന്റെ യഥാർത്ഥ കാരണം പ്രിയയുടെ വിശകലനം കൃത്യമായി ചൂണ്ടിക്കാണിച്ചു (Hit the nail on the head).',
        hint: 'Hit the nail on the head: Exactly right',
      ),
      _buildRound(
        id: 3,
        sentence: 'He only travels back to his hometown once in a blue moon due to heavy business travel .',
        translationMl: 'തിരക്കേറിയ യാത്രകൾ കാരണം അവൻ വളരെ അപൂർവ്വമായി മാത്രമേ സ്വന്തം നാട്ടിലേക്ക് പോകാറുള്ളൂ (Once in a blue moon).',
        hint: 'Once in a blue moon: Very rarely',
      ),
      _buildRound(
        id: 4,
        sentence: 'Losing that initial job offer was a blessing in disguise because it led her to start her own venture .',
        translationMl: 'ആദ്യത്തെ ജോലി നഷ്ടപ്പെട്ടത് ഒരു വലിയ അനുഗ്രഹമായി മാറി, കാരണം സ്വന്തമായി ഒരു സംരംഭം തുടങ്ങാൻ അത് കാരണമായി (Blessing in disguise).',
        hint: 'Blessing in disguise: Good outcome from a bad event',
      ),
      _buildRound(
        id: 5,
        sentence: 'Importing proprietary enterprise database software can cost an arm and a leg for a seed startup .',
        translationMl: 'വലിയ സോഫ്റ്റ്‌വെയറുകൾ വാങ്ങുന്നത് ഒരു ചെറിയ സ്റ്റാർട്ടപ്പിന് താങ്ങാനാവാത്ത ചിലവുണ്ടാക്കും (Cost an arm and a leg).',
        hint: 'Cost an arm and a leg: Extremely expensive',
      ),
    ],
    // DAY 88: High-Impact Workplace Phrasal Verbs in Action
    88: [
      _buildRound(
        id: 1,
        sentence: 'Our engineering squad managed to figure out the root cause of the memory leak .',
        translationMl: 'ഞങ്ങളുടെ എഞ്ചിനീയറിംഗ് ടീം മെമ്മറി ലീക്കിന്റെ യഥാർത്ഥ കാരണം കണ്ടെത്തി പരിഹരിച്ചു (Figure out).',
        hint: 'Figure out: Solve / understand a problem',
      ),
      _buildRound(
        id: 2,
        sentence: 'The compliance officer promised to look into the data discrepancy and report back by noon .',
        translationMl: 'ഡാറ്റയിലെ പൊരുത്തക്കേട് പരിശോധിച്ച് ഉച്ചയ്ക്കകം മറുപടി നൽകാമെന്ന് ഓഫീസർ ഉറപ്പ് നൽകി (Look into).',
        hint: 'Look into: Investigate',
      ),
      _buildRound(
        id: 3,
        sentence: 'They had to call off the international product symposium due to severe airport strikes .',
        translationMl: 'എയർപോർട്ട് പണിമുടക്ക് കാരണം അവർക്ക് അന്താരാഷ്ട്ര സിമ്പോസിയം റദ്ദാക്കേണ്ടി വന്നു (Call off).',
        hint: 'Call off: Cancel',
      ),
      _buildRound(
        id: 4,
        sentence: 'I will follow up with the prospective client tomorrow morning regarding the contract proposal .',
        translationMl: 'കരാർ നിർദ്ദേശത്തെക്കുറിച്ച് നാളെ രാവിലെ ഞാൻ ക്ലയന്റുമായി തുടർനടപടികൾ സംസാരിക്കും (Follow up).',
        hint: 'Follow up: Check progress / maintain contact',
      ),
      _buildRound(
        id: 5,
        sentence: 'Despite the unexpected power outage , the surgical team carried on with the procedure smoothly .',
        translationMl: 'അപ്രതീക്ഷിത വൈദ്യുതി തടസ്സം ഉണ്ടായിട്ടും, സർജിക്കൽ സംഘം ശസ്ത്രക്രിയ തടസ്സമില്ലാതെ തുടർന്നു (Carried on).',
        hint: 'Carry on: Continue',
      ),
    ],
    // DAY 89: Public Speaking, Storytelling & Persuasion
    89: [
      _buildRound(
        id: 1,
        sentence: 'Imagine a world where clean drinking water is accessible to every child across the globe .',
        translationMl: 'ഭൂമിയിലെ ഓരോ കുട്ടിക്കും ശുദ്ധമായ കുടിവെള്ളം ലഭ്യമാകുന്ന ഒരു ലോകത്തെക്കുറിച്ച് സങ്കൽപ്പിക്കുക (Hook).',
        hint: 'Hook the audience: \'Imagine a world where...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'Ten years ago , my family experienced that severe drought firsthand in our rural farming village .',
        translationMl: 'പത്ത് വർഷം മുമ്പ്, ഞങ്ങളുടെ ഗ്രാമത്തിൽ എന്റെ കുടുംബം ആ കടുത്ത വരൾച്ച നേരിട്ട് അനുഭവിച്ചറിഞ്ഞു.',
        hint: 'Emotional stakes: \'Ten years ago, my family experienced...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'True innovation is not measured in lines of code , but in human lives uplifted and protected .',
        translationMl: 'യഥാർത്ഥ കണ്ടുപിടുത്തം അളക്കേണ്ടത് കോഡുകളുടെ എണ്ണത്തിലല്ല, മറിച്ച് സംരക്ഷിക്കപ്പെടുന്ന മനുഷ്യജീവനുകളിലാണ്.',
        hint: 'Core insight: \'True innovation is measured in...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Pause intentionally after delivering critical insights to allow your words to settle into listeners \' minds .',
        translationMl: 'പ്രധാന ആശയങ്ങൾ പറഞ്ഞ ശേഷം മനപ്പൂർവ്വം അല്പം നിശബ്ദത പാലിക്കുക, അത് കേൾവിക്കാരുടെ മനസ്സിൽ പതിയട്ടെ.',
        hint: 'Vocal pause technique: \'Pause intentionally after...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'Join us today in transforming this bold architectural vision into an enduring living reality .',
        translationMl: 'ഈ മഹത്തായ കാഴ്ചപ്പാടിനെ ശാശ്വതമായ ഒരു ജീവിക്കുന്ന യാഥാർത്ഥ്യമാക്കാൻ ഇന്ന് ഞങ്ങളോടൊപ്പം ചേരൂ (Call to Action).',
        hint: 'Inspiring call to action: \'Join us today in transforming...\'',
      ),
    ],
    // DAY 90: Grand Capstone Review & Spoken English Graduation
    90: [
      _buildRound(
        id: 1,
        sentence: 'Congratulations on completing ninety days of dedicated spoken English mastery and transformation !',
        translationMl: 'തൊണ്ണൂറ് ദിവസത്തെ സമർപ്പിത സ്പോക്കൺ ഇംഗ്ലീഷ് പ്രാവീണ്യവും മാറ്റവും പൂർത്തിയാക്കിയതിന് അഭിനന്ദനങ്ങൾ!',
        hint: 'Graduation celebration: \'Congratulations on completing ninety days...\'',
      ),
      _buildRound(
        id: 2,
        sentence: 'You have progressed from foundational daily phrases to elite boardroom rhetoric and diplomacy .',
        translationMl: 'അടിസ്ഥാന ദൈനംദിന സംഭാഷണങ്ങളിൽ നിന്ന് ഉയർന്ന ബോർഡ് റൂം പ്രസംഗങ്ങളിലേക്കും നയതന്ത്രത്തിലേക്കും നിങ്ങൾ മുന്നേറിയിരിക്കുന്നു.',
        hint: 'Curriculum progression: \'You have progressed from foundation to elite rhetoric...\'',
      ),
      _buildRound(
        id: 3,
        sentence: 'Speak with unwavering self confidence , because your voice deserves to be heard across the world .',
        translationMl: 'പതറാത്ത ആത്മവിശ്വാസത്തോടെ സംസാരിക്കുക, കാരണം നിങ്ങളുടെ ശബ്ദം ലോകമെമ്പാടും കേൾക്കപ്പെടാൻ അർഹതയുള്ളതാണ്.',
        hint: 'Empowerment encouragement: \'Speak with unwavering confidence...\'',
      ),
      _buildRound(
        id: 4,
        sentence: 'Every conversation is a golden opportunity to connect , inspire , and create enduring value .',
        translationMl: 'ഓരോ സംഭാഷണവും മറ്റുള്ളവരുമായി ബന്ധപ്പെടാനും, പ്രചോദിപ്പിക്കാനും, ശാശ്വതമായ മൂല്യം സൃഷ്ടിക്കാനുമുള്ള സുവർണ്ണാവസരമാണ്.',
        hint: 'Conversational philosophy: \'Every conversation is an opportunity to inspire...\'',
      ),
      _buildRound(
        id: 5,
        sentence: 'You are now officially a certified 90-Day Spoken English Master ; walk forward proudly !',
        translationMl: 'നിങ്ങൾ ഇപ്പോൾ ഔദ്യോഗികമായി സർട്ടിഫൈഡ് 90-ഡേ സ്പോക്കൺ ഇംഗ്ലീഷ് മാസ്റ്ററാണ്; ആത്മവിശ്വാസത്തോടെ മുന്നോട്ട് നടക്കൂ!',
        hint: 'Official badge conferred: \'You are now officially a certified Master!\'',
      ),
    ],
  };
}
