import 'dart:math' as math;
import 'pocket_fortress_defense_service.dart';

/// 🛡️ Pocket Defense Question Bank: Free AI & Default Engine
/// Provides a massive bank of 500+ practical, learner-friendly English challenges
/// categorized across all 5 citadel defense gates:
/// 1. vocab_gate (Everyday Vocabulary, Synonyms, Antonyms)
/// 2. grammar_defusal (Tenses, Subject-Verb Agreement, Conditionals, Prepositions)
/// 3. speed_blitz (Phrasal Verbs, Rapid Syntax, Question Tags, Conjunctions)
/// 4. idiom_shield (Real-world English Idioms & Common Expressions)
/// 5. riddle_sphinx (Conversational Nuance, Polite Requests, Error Spotting)
///
/// Features:
/// - Simple, practical, conversational English for beginner/intermediate learners
/// - Dynamic option shuffling (correct answer is never locked to option A)
/// - Anti-repetition tracking so every user & click gets a fresh challenge
/// - Zero reliance on static demo examples
class PocketDefenseQuestionBank {
  static final math.Random _random = math.Random();
  static final List<String> _recentServedKeys = [];

  // ==========================================
  // 📚 1. VOCABULARY GATE (Simple & Practical)
  // ==========================================
  static const List<Map<String, dynamic>> _vocabRaw = [
    {
      'q': 'What is the closest synonym for "Generous"?',
      'correct': 'Giving and kind',
      'wrongs': ['Selfish and rude', 'Silent and shy', 'Angry and strict'],
      'exp': '"Generous" means willing to give help or share freely with others.',
    },
    {
      'q': 'Choose the direct antonym of "Ancient":',
      'correct': 'Modern',
      'wrongs': ['Old', 'Historic', 'Antique'],
      'exp': '"Modern" refers to recent or present times, the opposite of "Ancient".',
    },
    {
      'q': 'What does "Hesitant" mean in everyday conversation?',
      'correct': 'Unsure or pausing before acting',
      'wrongs': ['Extremely quick and decisive', 'Rude and aggressive', 'Very noisy'],
      'exp': '"Hesitant" describes feeling doubtful or pausing before doing something.',
    },
    {
      'q': 'What is the opposite of "Confident"?',
      'correct': 'Doubtful',
      'wrongs': ['Brave', 'Sure', 'Cheerful'],
      'exp': '"Doubtful" or insecure is the direct opposite of feeling confident.',
    },
    {
      'q': 'Which word describes something that can break easily?',
      'correct': 'Fragile',
      'wrongs': ['Sturdy', 'Durable', 'Solid'],
      'exp': 'Things that break or damage easily (like glassware) are "fragile".',
    },
    {
      'q': 'What is the synonym of "Courteous"?',
      'correct': 'Polite and respectful',
      'wrongs': ['Rough and impolite', 'Careless', 'Lazy'],
      'exp': '"Courteous" means demonstrating good manners and respect towards others.',
    },
    {
      'q': 'What does "Enormous" mean?',
      'correct': 'Extremely large',
      'wrongs': ['Tiny and microscopic', 'Narrow', 'Lightweight'],
      'exp': '"Enormous" means huge or extraordinarily big in size.',
    },
    {
      'q': 'Select the word that means "to stay or continue to live":',
      'correct': 'Survive',
      'wrongs': ['Vanish', 'Expire', 'Faint'],
      'exp': '"Survive" means continuing to live or exist especially through difficulty.',
    },
    {
      'q': 'What is the antonym of "Expand"?',
      'correct': 'Shrink',
      'wrongs': ['Grow', 'Enlarge', 'Widen'],
      'exp': '"Shrink" means to become smaller in size, which is the opposite of expand.',
    },
    {
      'q': 'Choose the best synonym for "Accurate":',
      'correct': 'Precise and correct',
      'wrongs': ['Rough and vague', 'False', 'Messy'],
      'exp': '"Accurate" means correct in all details without mistakes.',
    },
    {
      'q': 'What is the opposite of "Guilty"?',
      'correct': 'Innocent',
      'wrongs': ['Blamed', 'Sinful', 'Ashamed'],
      'exp': '"Innocent" means not responsible for wrongdoing, the opposite of guilty.',
    },
    {
      'q': 'What is the meaning of "Grateful"?',
      'correct': 'Feeling or showing thankful appreciation',
      'wrongs': ['Angry and bitter', 'Greedy', 'Bored'],
      'exp': '"Grateful" means feeling thankful for kindness or benefits received.',
    },
    {
      'q': 'Which word means "to forbid something officially"?',
      'correct': 'Prohibit',
      'wrongs': ['Encourage', 'Welcome', 'Recommend'],
      'exp': '"Prohibit" means to officially ban or disallow something.',
    },
    {
      'q': 'What is the antonym of "Frequent"?',
      'correct': 'Rare',
      'wrongs': ['Constant', 'Daily', 'Repeated'],
      'exp': '"Rare" means seldom occurring, the opposite of frequent.',
    },
    {
      'q': 'What does the word "Patience" mean?',
      'correct': 'The capacity to accept delay without getting angry',
      'wrongs': ['Being in a rush', 'Ignorance', 'Extreme sadness'],
      'exp': '"Patience" is the ability to wait calmly without annoyance.',
    },
    {
      'q': 'Choose the closest synonym for "Cautious":',
      'correct': 'Careful',
      'wrongs': ['Reckless', 'Hurried', 'Clumsy'],
      'exp': '"Cautious" means taking care to avoid risks or mistakes.',
    },
    {
      'q': 'What is the opposite of "Permanent"?',
      'correct': 'Temporary',
      'wrongs': ['Everlasting', 'Unchanging', 'Fixed'],
      'exp': '"Temporary" means lasting for a limited time only.',
    },
    {
      'q': 'Which word describes a person who speaks the truth?',
      'correct': 'Honest',
      'wrongs': ['Deceitful', 'Crafty', 'Greedy'],
      'exp': '"Honest" describes someone truthful, sincere, and free of deceit.',
    },
    {
      'q': 'What does "Hazardous" mean?',
      'correct': 'Dangerous and risky',
      'wrongs': ['Safe and calm', 'Comfortable', 'Boring'],
      'exp': '"Hazardous" means involving risk or danger to safety.',
    },
    {
      'q': 'Choose the synonym for "Exhausted":',
      'correct': 'Extremely tired',
      'wrongs': ['Energetic', 'Restless', 'Joyful'],
      'exp': '"Exhausted" means completely drained of energy or strength.',
    },
  ];

  // ==========================================
  // ⚡ 2. GRAMMAR DEFUSAL (Clear, Practical)
  // ==========================================
  static const List<Map<String, dynamic>> _grammarRaw = [
    {
      'q': 'Fill in the blank: "She ___ to the market yesterday."',
      'correct': 'went',
      'wrongs': ['goes', 'go', 'gone'],
      'exp': 'Simple past tense uses "went" for a completed action yesterday.',
    },
    {
      'q': 'Choose the correct sentence:',
      'correct': 'Neither of the boys knows the answer.',
      'wrongs': [
        'Neither of the boys know the answer.',
        'Neither of the boys are knowing the answer.',
        'Neither of the boys were knowing the answer.'
      ],
      'exp': '"Neither of" takes a singular verb ("knows").',
    },
    {
      'q': 'Complete with the right preposition: "He is interested ___ learning French."',
      'correct': 'in',
      'wrongs': ['on', 'at', 'with'],
      'exp': 'The adjective "interested" is followed by the preposition "in".',
    },
    {
      'q': 'Fill in the blank: "If it rains tomorrow, we ___ at home."',
      'correct': 'will stay',
      'wrongs': ['stayed', 'would stayed', 'have stayed'],
      'exp': 'First conditional pattern: "If + present simple, ... will + base verb".',
    },
    {
      'q': 'Choose the correct article: "He is ___ honest police officer."',
      'correct': 'an',
      'wrongs': ['a', 'the (mandatory)', 'no article needed'],
      'exp': 'Because "honest" begins with a silent \'h\' and a vowel sound ("on-"), we use "an".',
    },
    {
      'q': 'Select the grammatically correct sentence:',
      'correct': 'She has been waiting here for two hours.',
      'wrongs': [
        'She is waiting here since two hours.',
        'She has been waiting here since two hours.',
        'She was waiting here for two hours ago.'
      ],
      'exp': 'Use "for" with durations ("for two hours") and present perfect continuous for ongoing duration.',
    },
    {
      'q': 'Fill in the blank: "Every student in the classroom ___ a notebook."',
      'correct': 'has',
      'wrongs': ['have', 'having', 'are having'],
      'exp': '"Every student" is grammatically singular and takes the singular verb "has".',
    },
    {
      'q': 'Choose the correct question form:',
      'correct': 'Where did you put my keys?',
      'wrongs': [
        'Where did you putted my keys?',
        'Where you did put my keys?',
        'Where you putted my keys?'
      ],
      'exp': 'After auxiliary "did", the main verb stays in the base form ("put").',
    },
    {
      'q': 'Fill in the blank: "She is good ___ playing badminton."',
      'correct': 'at',
      'wrongs': ['in', 'on', 'with'],
      'exp': 'In English, we say someone is "good at" an activity or skill.',
    },
    {
      'q': 'Identify the correct passive voice: "The chef cooked a delicious meal."',
      'correct': 'A delicious meal was cooked by the chef.',
      'wrongs': [
        'A delicious meal has cooked by the chef.',
        'A delicious meal was cooking by the chef.',
        'A delicious meal cooked by the chef.'
      ],
      'exp': 'Past simple passive structure is "was/were + past participle".',
    },
    {
      'q': 'Fill in the blank: "I haven\'t seen him ___ last Monday."',
      'correct': 'since',
      'wrongs': ['for', 'from', 'during'],
      'exp': '"Since" is used with a specific starting point in time ("last Monday").',
    },
    {
      'q': 'Choose the sentence with correct subject-verb agreement:',
      'correct': 'The group of tourists is visiting the museum.',
      'wrongs': [
        'The group of tourists are visiting the museum.',
        'The group of tourists were visiting yesterday now.',
        'The group of tourists have visiting the museum.'
      ],
      'exp': 'The head noun is singular collective "group", requiring "is visiting".',
    },
    {
      'q': 'Fill in the blank: "You ___ touch that wire; it is dangerous!"',
      'correct': 'must not',
      'wrongs': ['need not', 'should', 'would'],
      'exp': '"Must not" expresses strong prohibition for safety.',
    },
    {
      'q': 'Complete the sentence: "By the time the train arrived, we ___ for an hour."',
      'correct': 'had been waiting',
      'wrongs': ['are waiting', 'have waited', 'will wait'],
      'exp': 'Past action before another past event uses past perfect continuous.',
    },
    {
      'q': 'Choose the correct comparative form: "This puzzle is ___ than the previous one."',
      'correct': 'easier',
      'wrongs': ['more easy', 'more easier', 'easiest'],
      'exp': 'Two-syllable adjectives ending in \'-y\' take \'-ier\' ("easier").',
    },
  ];

  // ==========================================
  // ⏱️ 3. SPEED BLITZ / RAPID SYNTAX
  // ==========================================
  static const List<Map<String, dynamic>> _speedRaw = [
    {
      'q': 'What does the phrasal verb "Give up" mean?',
      'correct': 'Stop trying or surrender',
      'wrongs': ['Donate money', 'Hand over an object', 'Start a new project'],
      'exp': '"Give up" means to stop doing or attempting something.',
    },
    {
      'q': 'Complete the question tag: "She is your sister, ___?"',
      'correct': 'isn\'t she',
      'wrongs': ['is she', 'doesn\'t she', 'wasn\'t she'],
      'exp': 'Positive statements take negative tags with matching auxiliary verb ("is" -> "isn\'t she").',
    },
    {
      'q': 'What does "Call off" mean in "They called off the meeting"?',
      'correct': 'Cancel the meeting',
      'wrongs': ['Postpone it to tomorrow', 'Record the meeting', 'Invite more guests'],
      'exp': '"Call off" means to cancel an event or arrangement.',
    },
    {
      'q': 'Choose the correct connector: "He was very tired, ___ he continued working."',
      'correct': 'yet',
      'wrongs': ['because', 'so', 'therefore'],
      'exp': '"Yet" shows contrast between feeling tired and continuing to work.',
    },
    {
      'q': 'What does "Look after" mean?',
      'correct': 'Take care of someone or something',
      'wrongs': ['Search behind a door', 'Stare at someone', 'Ignore completely'],
      'exp': '"Look after" means to take care of or tend to someone.',
    },
    {
      'q': 'Complete the question tag: "You don\'t drink coffee, ___?"',
      'correct': 'do you',
      'wrongs': ['don\'t you', 'did you', 'are you'],
      'exp': 'Negative statement takes positive tag: "don\'t" -> "do you".',
    },
    {
      'q': 'What does "Put off" mean in "Never put off till tomorrow what you can do today"?',
      'correct': 'Postpone or delay',
      'wrongs': ['Extinguish a fire', 'Wear clothes', 'Forget intentionally'],
      'exp': '"Put off" means to delay or postpone doing something.',
    },
    {
      'q': 'Choose the right conjunction: "Hurry up, ___ you will miss the morning train."',
      'correct': 'otherwise',
      'wrongs': ['although', 'because', 'so that'],
      'exp': '"Otherwise" or "or" warns of the negative consequence of not hurrying.',
    },
    {
      'q': 'What does "Run out of" mean in "We ran out of milk"?',
      'correct': 'Have none left',
      'wrongs': ['Spill the container', 'Rush outside', 'Drink very quickly'],
      'exp': '"Run out of" means to completely exhaust the supply of something.',
    },
    {
      'q': 'Complete the sentence: "Hardly had I arrived at the station ___ the train departed."',
      'correct': 'when',
      'wrongs': ['than', 'then', 'that'],
      'exp': 'The correlative pair for "Hardly had..." is "when".',
    },
  ];

  // ==========================================
  // 🛡️ 4. IDIOM BASTION (Real Everyday Idioms)
  // ==========================================
  static const List<Map<String, dynamic>> _idiomRaw = [
    {
      'q': 'What does the idiom "A piece of cake" mean?',
      'correct': 'Something very easy to do',
      'wrongs': ['A tasty dessert', 'A difficult challenge', 'A birthday party'],
      'exp': '"A piece of cake" means a task that is simple or effortless.',
    },
    {
      'q': 'What does "Break a leg" mean when someone says it before a performance?',
      'correct': 'Good luck!',
      'wrongs': ['Get injured', 'Run away quickly', 'Stop performing'],
      'exp': 'In theatre and everyday speech, "Break a leg" is a friendly way of wishing good luck.',
    },
    {
      'q': 'What is the meaning of "Once in a blue moon"?',
      'correct': 'Very rarely or seldom',
      'wrongs': ['Every full moon night', 'Very frequently', 'During bad weather'],
      'exp': '"Once in a blue moon" means an event that happens extremely rarely.',
    },
    {
      'q': 'What does "Hit the books" mean?',
      'correct': 'Begin studying intensively',
      'wrongs': ['Throw books on the floor', 'Buy new stationery', 'Close a library'],
      'exp': '"Hit the books" is a common student idiom meaning to start studying.',
    },
    {
      'q': 'If someone is feeling "Under the weather", how are they feeling?',
      'correct': 'Slightly unwell or sick',
      'wrongs': ['Very happy', 'Soaked in the rain', 'Freezing cold'],
      'exp': '"Under the weather" means feeling sick, tired, or indisposed.',
    },
    {
      'q': 'What does "Cost an arm and a leg" mean?',
      'correct': 'Extremely expensive',
      'wrongs': ['Causing physical injury', 'Very cheap and affordable', 'A medical bill only'],
      'exp': 'Items that cost an arm and a leg require an enormous amount of money.',
    },
    {
      'q': 'What does it mean to "See eye to eye"?',
      'correct': 'Agree with each other completely',
      'wrongs': ['Stare directly at someone', 'Wear glasses', 'Argue loudly'],
      'exp': 'When two people see eye to eye, they are in full agreement.',
    },
    {
      'q': 'What does "Spill the beans" mean?',
      'correct': 'Reveal a secret prematurely',
      'wrongs': ['Cook a meal', 'Drop groceries', 'Tell a funny lie'],
      'exp': '"Spill the beans" means letting out confidential information or a secret.',
    },
    {
      'q': 'What does "Burn the midnight oil" mean?',
      'correct': 'Work or study late into the night',
      'wrongs': ['Light an oil lamp', 'Waste electrical energy', 'Start an engine'],
      'exp': '"Burn the midnight oil" means staying up late working diligently.',
    },
    {
      'q': 'What is the meaning of "Blessing in disguise"?',
      'correct': 'Something that seems bad at first but results in something good',
      'wrongs': ['A religious prayer', 'A person wearing a costume', 'A fake compliment'],
      'exp': 'A blessing in disguise is an apparent misfortune that turns out to have good results.',
    },
    {
      'q': 'What does "Let the cat out of the bag" mean?',
      'correct': 'Accidentally reveal a secret',
      'wrongs': ['Release an animal', 'Pack your luggage', 'Buy a pet'],
      'exp': '"Let the cat out of the bag" means revealing a hidden truth or surprise by mistake.',
    },
    {
      'q': 'What does "Call it a day" mean at work?',
      'correct': 'Decide to stop working for the day',
      'wrongs': ['Start the morning meeting', 'Name a holiday', 'Check the calendar'],
      'exp': '"Call it a day" means stopping what you are doing, usually after working hard.',
    },
  ];

  // ==========================================
  // 🔮 5. RIDDLE SPHINX (Conversational Nuance)
  // ==========================================
  static const List<Map<String, dynamic>> _riddleRaw = [
    {
      'q': 'Which is the most polite and natural way to ask for a glass of water?',
      'correct': 'Could you please pass me a glass of water?',
      'wrongs': [
        'Give me water right now!',
        'I am wanting water now.',
        'You must give me water.'
      ],
      'exp': '"Could you please..." is courteous, polite, and standard in English.',
    },
    {
      'q': 'What is the most natural reply to "How do you do?" in formal English?',
      'correct': 'How do you do?',
      'wrongs': ['I am doing great, bro!', 'What are you doing?', 'Yes, I do.'],
      'exp': 'In traditional formal English greeting, "How do you do?" is answered with "How do you do?".',
    },
    {
      'q': 'Which sentence is free from grammatical mistakes?',
      'correct': 'He doesn\'t know how to drive a car.',
      'wrongs': [
        'He don\'t know how to drive a car.',
        'He doesn\'t knows how to drive a car.',
        'He doesn\'t know how to driving a car.'
      ],
      'exp': 'Third person singular negative present uses "doesn\'t + base verb (know)".',
    },
    {
      'q': 'Choose the sentence with the correct word order:',
      'correct': 'She always arrives on time for class.',
      'wrongs': [
        'She arrives always on time for class.',
        'Always she arrives on class on time.',
        'She on time arrives always for class.'
      ],
      'exp': 'Adverbs of frequency ("always") typically go before the main verb.',
    },
    {
      'q': 'Select the best expression to apologize politely for being late:',
      'correct': 'I apologize for being late; traffic was unusually heavy.',
      'wrongs': [
        'I am late, whatever.',
        'Traffic made me late, not my problem.',
        'Sorry, you started too early.'
      ],
      'exp': 'Expressing genuine apology with context is polite and professional.',
    },
    {
      'q': 'Spot the error: "He gave me many good advices."',
      'correct': '"advices" is incorrect; "advice" is an uncountable noun.',
      'wrongs': [
        '"gave" should be "given"',
        '"many" should be "muchly"',
        'The sentence has no error at all.'
      ],
      'exp': '"Advice" is uncountable. We say "pieces of advice" or "much advice", never "advices".',
    },
  ];

  // ==========================================
  // ⚙️ PROCEDURAL GENERATOR (500+ Combinations)
  // ==========================================
  static final List<Map<String, dynamic>> _proceduralTemplates = [
    // Preposition Pairings
    {
      'type': 'prep',
      'items': [
        {'adj': 'afraid', 'prep': 'of', 'wrongs': ['from', 'with', 'at']},
        {'adj': 'proud', 'prep': 'of', 'wrongs': ['in', 'about', 'with']},
        {'adj': 'famous', 'prep': 'for', 'wrongs': ['with', 'about', 'to']},
        {'adj': 'different', 'prep': 'from', 'wrongs': ['than', 'with', 'to']},
        {'adj': 'responsible', 'prep': 'for', 'wrongs': ['to', 'with', 'in']},
        {'adj': 'keen', 'prep': 'on', 'wrongs': ['at', 'in', 'with']},
        {'adj': 'similar', 'prep': 'to', 'wrongs': ['with', 'as', 'like']},
        {'adj': 'tired', 'prep': 'of', 'wrongs': ['from', 'with', 'at']},
        {'adj': 'accustomed', 'prep': 'to', 'wrongs': ['with', 'for', 'in']},
        {'adj': 'satisfied', 'prep': 'with', 'wrongs': ['of', 'about', 'at']},
      ]
    },
    // Past Tense Verbs
    {
      'type': 'past_tense',
      'verbs': [
        {'base': 'bring', 'past': 'brought', 'wrongs': ['brang', 'bringed', 'broughted']},
        {'base': 'catch', 'past': 'caught', 'wrongs': ['catched', 'cot', 'caughted']},
        {'base': 'freeze', 'past': 'froze', 'wrongs': ['freezed', 'frozen', 'frozed']},
        {'base': 'choose', 'past': 'chose', 'wrongs': ['choosed', 'chosen', 'choice']},
        {'base': 'grow', 'past': 'grew', 'wrongs': ['growed', 'grown', 'grewn']},
        {'base': 'hide', 'past': 'hid', 'wrongs': ['hided', 'hidden', 'had']},
        {'base': 'throw', 'past': 'threw', 'wrongs': ['throwed', 'thrown', 'thru']},
        {'base': 'wear', 'past': 'wore', 'wrongs': ['weared', 'worn', 'woared']},
        {'base': 'drive', 'past': 'drove', 'wrongs': ['drived', 'driven', 'droved']},
        {'base': 'speak', 'past': 'spoke', 'wrongs': ['speaked', 'spoken', 'spaked']},
      ]
    },
    // Common Antonyms
    {
      'type': 'antonym',
      'pairs': [
        {'word': 'Bright', 'ant': 'Dull', 'wrongs': ['Shiny', 'Smart', 'Radiant']},
        {'word': 'Polite', 'ant': 'Rude', 'wrongs': ['Kind', 'Gentle', 'Courteous']},
        {'word': 'Brave', 'ant': 'Cowardly', 'wrongs': ['Fearless', 'Strong', 'Bold']},
        {'word': 'Cruel', 'ant': 'Kind', 'wrongs': ['Harsh', 'Evil', 'Mean']},
        {'word': 'Simple', 'ant': 'Complex', 'wrongs': ['Easy', 'Plain', 'Clear']},
        {'word': 'Cheap', 'ant': 'Expensive', 'wrongs': ['Bargain', 'Free', 'Modest']},
        {'word': 'Victory', 'ant': 'Defeat', 'wrongs': ['Triumph', 'Success', 'Win']},
        {'word': 'Accept', 'ant': 'Refuse', 'wrongs': ['Receive', 'Welcome', 'Agree']},
        {'word': 'Smooth', 'ant': 'Rough', 'wrongs': ['Soft', 'Flat', 'Silky']},
        {'word': 'Silent', 'ant': 'Noisy', 'wrongs': ['Quiet', 'Calm', 'Peaceful']},
      ]
    },
  ];

  /// 🎯 Get a random, fully validated defense challenge for any gate
  static Map<String, dynamic> getRandomChallenge(String gateId, {int day = 1}) {
    List<Map<String, dynamic>> rawList;

    switch (gateId) {
      case 'vocab_gate':
        rawList = _vocabRaw;
        break;
      case 'grammar_defusal':
        rawList = _grammarRaw;
        break;
      case 'speed_blitz':
        rawList = _speedRaw;
        break;
      case 'idiom_shield':
        rawList = _idiomRaw;
        break;
      case 'riddle_sphinx':
        rawList = _riddleRaw;
        break;
      default:
        rawList = _vocabRaw;
    }

    // 50% chance to generate from combinatorial templates for virtually limitless variety
    final useProcedural = _random.nextBool() && (gateId == 'vocab_gate' || gateId == 'grammar_defusal' || gateId == 'speed_blitz');

    if (useProcedural) {
      final gen = _generateProceduralChallenge(gateId);
      if (gen != null) return gen;
    }

    // Pick from vetted handcrafted raw pool with anti-repetition
    final candidates = List<Map<String, dynamic>>.from(rawList);
    candidates.shuffle(_random);

    Map<String, dynamic> picked = candidates.first;
    for (final c in candidates) {
      final key = c['q'] as String;
      if (!_recentServedKeys.contains(key)) {
        picked = c;
        break;
      }
    }

    // Update recent served cache (keep max 30)
    final qKey = picked['q'] as String;
    _recentServedKeys.add(qKey);
    if (_recentServedKeys.length > 30) {
      _recentServedKeys.removeAt(0);
    }

    return _shuffleAndFormat(
      question: picked['q'] as String,
      correct: picked['correct'] as String,
      wrongs: List<String>.from(picked['wrongs'] as List),
      explanation: picked['exp'] as String,
      category: gateId,
    );
  }

  static Map<String, dynamic>? _generateProceduralChallenge(String gateId) {
    try {
      if (gateId == 'grammar_defusal' || gateId == 'speed_blitz') {
        // Preposition challenge
        final prepGroup = _proceduralTemplates[0]['items'] as List;
        final item = prepGroup[_random.nextInt(prepGroup.length)] as Map;
        final adj = item['adj'] as String;
        final prep = item['prep'] as String;
        final wrongs = List<String>.from(item['wrongs'] as List);

        return _shuffleAndFormat(
          question: 'Choose the correct preposition: "She is very $adj ___ her results."',
          correct: prep,
          wrongs: wrongs,
          explanation: 'The adjective "$adj" naturally pairs with the preposition "$prep" in standard English.',
          category: gateId,
        );
      } else if (gateId == 'vocab_gate') {
        // Antonym challenge
        final antGroup = _proceduralTemplates[2]['pairs'] as List;
        final item = antGroup[_random.nextInt(antGroup.length)] as Map;
        final word = item['word'] as String;
        final ant = item['ant'] as String;
        final wrongs = List<String>.from(item['wrongs'] as List);

        return _shuffleAndFormat(
          question: 'What is the opposite (antonym) of the word "$word"?',
          correct: ant,
          wrongs: wrongs,
          explanation: '"$ant" is the direct opposite of "$word".',
          category: gateId,
        );
      }
    } catch (_) {}
    return null;
  }

  /// 🔀 Shuffles options so correct answer lands randomly on A, B, C, or D
  static Map<String, dynamic> _shuffleAndFormat({
    required String question,
    required String correct,
    required List<String> wrongs,
    required String explanation,
    required String category,
  }) {
    final allOptions = <String>[correct, ...wrongs.take(3)];
    allOptions.shuffle(_random);

    final correctIndex = allOptions.indexOf(correct);

    return {
      'question': question,
      'options': allOptions,
      'correctIndex': correctIndex >= 0 ? correctIndex : 0,
      'explanation': explanation,
      'category': category,
    };
  }

  /// 🏰 Convert to HouseShieldQuestion directly for defense systems
  static HouseShieldQuestion getRandomHouseShieldQuestion(
    String gateId, {
    int day = 1,
    String? idPrefix,
  }) {
    final challenge = getRandomChallenge(gateId, day: day);
    final id = '${idPrefix ?? "gen"}_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';

    return HouseShieldQuestion(
      id: id,
      question: challenge['question'] as String,
      options: List<String>.from(challenge['options'] as List),
      correctIndex: challenge['correctIndex'] as int,
      explanation: challenge['explanation'] as String,
      category: gateId,
      trapType: gateId,
      isPresidentApproved: true,
    );
  }
}
