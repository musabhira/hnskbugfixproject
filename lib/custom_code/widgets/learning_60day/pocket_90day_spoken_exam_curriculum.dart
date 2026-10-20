/// 🎙️ Master 90-Day Spoken Gate Exam Curriculum (House Gate 1 to Gate 90)
/// Features:
/// - 100% Unique Practical Questions per Day tailored to that day's specific topic!
/// - ZERO DUPLICATES across all 14 days (and scalable to 90 days).
/// - English prompt, Malayalam prompt, exact target text for speech evaluation, and 4 multiple-choice options.
class Pocket90DaySpokenExamCurriculum {
  /// Returns the curated list of 4 spoken exam questions for any given day (1 to 90)
  static List<Map<String, dynamic>> getExamForDay(int day) {
    if (day < 1) day = 1;
    if (day > 90) day = 90;

    final exam = _curriculum[day];
    if (exam != null && exam.isNotEmpty) {
      return exam;
    }

    // Dynamic procedural fallback for any day beyond pre-compiled list
    return [
      {
        'id': 1,
        'question': {
          'en': 'Speak aloud your daily English practice goal for Day $day:',
          'ml': 'ഡേ $day-ലെ നിങ്ങളുടെ ഇംഗ്ലീഷ് പരിശീലന ലക്ഷ്യം ഉറക്കെ പറയുക:',
        },
        'targetText': 'I practice English every day',
        'voicePrompt': 'Say: I practice English every day',
        'options': [
          'I practice English every day',
          'I sleep all day',
          'I never speak English',
          'I forget my practice',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സ്ഥിരമായി ഇംഗ്ലീഷ് സംസാരിച്ചു പരിശീലിക്കുക.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Speak aloud a confident English sentence for Day $day:',
          'ml': 'ഡേ $day-ൽ ആത്മവിശ്വാസത്തോടെ ഇംഗ്ലീഷിൽ സംസാരിക്കുക:',
        },
        'targetText': 'I am learning to speak fluently',
        'voicePrompt': 'Say: I am learning to speak fluently',
        'options': [
          'I am learning to speak fluently',
          'I cannot speak at all',
          'Speaking is impossible for me',
          'I give up learning',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ആത്മവിശ്വാസത്തോടെയുള്ള ഇംഗ്ലീഷ് സംഭാഷണം.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Speak aloud an encouraging phrase to your study partner:',
          'ml': 'നിങ്ങളുടെ സുഹൃത്തിനോട് പ്രോത്സാഹന വാക്ക് ഉറക്കെ പറയുക:',
        },
        'targetText': 'Keep up the great work',
        'voicePrompt': 'Say: Keep up the great work',
        'options': [
          'Keep up the great work',
          'Stop doing your work',
          'You are doing terrible',
          'Never try again',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മറ്റുള്ളവരെ പ്രോത്സാഹിപ്പിക്കാൻ ഈ വാക്യം ഉപയോഗിക്കാം.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Express your commitment to completing the 90-day journey:',
          'ml': '90 ദിവസത്തെ ഇംഗ്ലീഷ് യാത്ര പൂർത്തിയാക്കുമെന്ന് ഉറക്കെ പറയുക:',
        },
        'targetText': 'I will complete all ninety days',
        'voicePrompt': 'Say: I will complete all ninety days',
        'options': [
          'I will complete all ninety days',
          'I will stop after one week',
          'I do not care about learning',
          'Ninety days is too long',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ലക്ഷ്യം നേടാനുള്ള പ്രതിബദ്ധത വ്യക്തമാക്കുക.'},
      },
    ];
  }

  // =========================================================================
  // 🌟 MASTER SPOKEN EXAMS (DAYS 1 TO 14 DEDICATED CONTENT)
  // =========================================================================
  static final Map<int, List<Map<String, dynamic>>> _curriculum = {
    // -----------------------------------------------------------------------
    // DAY 1: Everyday Basics, Greetings & Names
    // -----------------------------------------------------------------------
    1: [
      {
        'id': 1,
        'question': {
          'en': 'Greet your teacher politely in the morning:',
          'ml': 'രാവിലെ നിങ്ങളുടെ അധ്യാപകനെ മാന്യമായി അഭിസംബോധന ചെയ്യുക:',
        },
        'targetText': 'Good morning, how are you today?',
        'voicePrompt': 'Say: Good morning, how are you today?',
        'options': [
          'Good morning, how are you today?',
          'Good night, go to sleep.',
          'Goodbye, see you never.',
          'Silence is better.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'രാവിലെയുള്ള മാന്യമായ അഭിസംബോധന.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Introduce yourself by stating your name clearly:',
          'ml': 'നിങ്ങളുടെ പേര് പറഞ്ഞ് സ്വയം പരിചയപ്പെടുത്തുക:',
        },
        'targetText': 'My name is Rahul and I am glad to meet you.',
        'voicePrompt': 'Say: My name is Rahul and I am glad to meet you.',
        'options': [
          'My name is Rahul and I am glad to meet you.',
          'Who are you to ask my name?',
          'I have no name at all.',
          'Names are not important.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സ്വയം പരിചയപ്പെടുത്താൻ ഈ വാക്യം ഉപയോഗിക്കുന്നു.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Politely ask someone for a glass of water:',
          'ml': 'ദാഹിക്കുമ്പോൾ ഒരാളോട് ഒരു ഗ്ലാസ് വെള്ളം ചോദിക്കുക:',
        },
        'targetText': 'Could I please have a glass of water?',
        'voicePrompt': 'Say: Could I please have a glass of water?',
        'options': [
          'Could I please have a glass of water?',
          'Give me water right now!',
          'I never drink water.',
          'Water is too cold.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മാന്യമായി വെള്ളം ചോദിക്കുന്ന വിധം.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Express heartfelt thanks to a friend for helping you:',
          'ml': 'സഹായിച്ച സുഹൃത്തിനോട് സ്നേഹത്തോടെ നന്ദി പറയുക:',
        },
        'targetText': 'Thank you so much for your kind help.',
        'voicePrompt': 'Say: Thank you so much for your kind help.',
        'options': [
          'Thank you so much for your kind help.',
          'You did not help me at all.',
          'I do not care about your help.',
          'Why did you help me?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സഹായത്തിന് നന്ദി പ്രകടിപ്പിക്കുന്ന വിധം.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 2: Where I Live & Daily Routine ("am, is, are, in, at")
    // -----------------------------------------------------------------------
    2: [
      {
        'id': 1,
        'question': {
          'en': 'Tell someone clearly where you live:',
          'ml': 'നിങ്ങൾ എവിടെയാണ് താമസിക്കുന്നത് എന്ന് വ്യക്തമായി പറയുക:',
        },
        'targetText': 'I live in Kerala with my family.',
        'voicePrompt': 'Say: I live in Kerala with my family.',
        'options': [
          'I live in Kerala with my family.',
          'I from Kerala.',
          'My family living no place.',
          'I live nowhere.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'താമസസ്ഥലം പറയുമ്പോൾ "live in" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'State what time you wake up every morning:',
          'ml': 'എല്ലാ ദിവസവും രാവിലെ എത്ര മണിക്കാണ് എഴുന്നേൽക്കുന്നത് എന്ന് പറയുക:',
        },
        'targetText': 'I wake up at six o\'clock every morning.',
        'voicePrompt': 'Say: I wake up at six o\'clock every morning.',
        'options': [
          'I wake up at six o\'clock every morning.',
          'I waking up yesterday.',
          'Morning wake me never.',
          'Six o\'clock wake up I.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പ്രഭാത ദിനചര്യ പറയാൻ "I wake up at..." ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Tell a friend that you are at home today:',
          'ml': 'ഇന്ന് നിങ്ങൾ വീട്ടിലുണ്ടെന്ന് സുഹൃത്തിനോട് പറയുക:',
        },
        'targetText': 'I am at home and relaxing today.',
        'voicePrompt': 'Say: I am at home and relaxing today.',
        'options': [
          'I am at home and relaxing today.',
          'I home today.',
          'I are in the home.',
          'Relaxing is not at home.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': '"at home" ആണ് വീട്ടിനുള്ളിലുണ്ട് എന്ന് പറയാൻ ശരിയായ പ്രയോഗം.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Warmly invite a friend to visit your house this evening:',
          'ml': 'ഇന്ന് വൈകുന്നേരം വീട്ടിലേക്ക് വരാൻ സുഹൃത്തിനെ ക്ഷണിക്കുക:',
        },
        'targetText': 'Please come to my house this evening for tea.',
        'voicePrompt': 'Say: Please come to my house this evening for tea.',
        'options': [
          'Please come to my house this evening for tea.',
          'Never visit my house.',
          'Tea is finished at house.',
          'Go away from my house.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സുഹൃത്തുക്കളെ സ്നേഹത്തോടെ വീട്ടിലേക്ക് ക്ഷണിക്കാൻ ഇത് ഉപയോഗിക്കാം.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 3: Family Members, Roles & Affection
    // -----------------------------------------------------------------------
    3: [
      {
        'id': 1,
        'question': {
          'en': 'State how many members are in your family:',
          'ml': 'കുടുംബത്തിൽ എത്ര അംഗങ്ങളുണ്ടെന്ന് വ്യക്തമാക്കുക:',
        },
        'targetText': 'There are four members in my family.',
        'voicePrompt': 'Say: There are four members in my family.',
        'options': [
          'There are four members in my family.',
          'Four members is my family.',
          'My family have no people.',
          'Family are counting zero.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'കുടുംബാംഗങ്ങളുടെ എണ്ണം പറയാൻ "There are..." ഉപയോഗിക്കാം.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Describe your father\'s occupation with pride:',
          'ml': 'നിങ്ങളുടെ പിതാവിന്റെ ജോലിയെക്കുറിച്ച് അഭിമാനത്തോടെ പറയുക:',
        },
        'targetText': 'My father works as a dedicated high school teacher.',
        'voicePrompt': 'Say: My father works as a dedicated high school teacher.',
        'options': [
          'My father works as a dedicated high school teacher.',
          'Father working nowhere.',
          'He teacher no job.',
          'My father is not work.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ജോലി വിവരിക്കുമ്പോൾ "works as a..." ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Tell someone that your mother prepares delicious food:',
          'ml': 'അമ്മ സ്വാദിഷ്ടമായ ഭക്ഷണം പാചകം ചെയ്യുന്നു എന്ന് പറയുക:',
        },
        'targetText': 'My mother cooks very delicious traditional meals.',
        'voicePrompt': 'Say: My mother cooks very delicious traditional meals.',
        'options': [
          'My mother cooks very delicious traditional meals.',
          'Mother no cook food.',
          'Food is bad at house.',
          'Cooking not done by mother.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'അമ്മയുടെ പാചകത്തെക്കുറിച്ച് പറയാൻ.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Express how much you value spending time with family:',
          'ml': 'കുടുംബത്തോടൊപ്പം സമയം ചിലവഴിക്കുന്നത് എത്രത്തോളം ഇഷ്ടപ്പെടുന്നു എന്ന് പറയുക:',
        },
        'targetText': 'I love spending quality time with my parents and siblings.',
        'voicePrompt': 'Say: I love spending quality time with my parents and siblings.',
        'options': [
          'I love spending quality time with my parents and siblings.',
          'I hate sitting with family.',
          'Family time is boring.',
          'I never speak to my siblings.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'കുടുംബസ്നേഹം പ്രകടിപ്പിക്കാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 4: Daily Habits, Time & Activity Sequencing
    // -----------------------------------------------------------------------
    4: [
      {
        'id': 1,
        'question': {
          'en': 'Describe your routine right after getting out of bed:',
          'ml': 'എഴുന്നേറ്റയുടൻ ചെയ്യുന്ന ദിനചര്യ വിവരിക്കുക:',
        },
        'targetText': 'I brush my teeth and wash my face thoroughly.',
        'voicePrompt': 'Say: I brush my teeth and wash my face thoroughly.',
        'options': [
          'I brush my teeth and wash my face thoroughly.',
          'I sleep again immediately.',
          'Face wash is not my habit.',
          'Brushing is forgotten today.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പ്രഭാത ദിനചര്യകളുടെ വിവരണം.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Ask a colleague politely for the current time:',
          'ml': 'സഹപ്രവർത്തകനോട് സമയം എത്രയായി എന്ന് മാന്യമായി ചോദിക്കുക:',
        },
        'targetText': 'Excuse me, could you please tell me the time?',
        'voicePrompt': 'Say: Excuse me, could you please tell me the time?',
        'options': [
          'Excuse me, could you please tell me the time?',
          'What is the clock saying?',
          'Time is running fast.',
          'Give me your watch right now.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സമയം ചോദിക്കാനുള്ള മാന്യമായ ഇംഗ്ലീഷ് ശൈലി.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Say that you eat a nutritious lunch at one in the afternoon:',
          'ml': 'ഉച്ചയ്ക്ക് ഒരു മണിക്ക് ആഹാരം കഴിക്കുന്നു എന്ന് പറയുക:',
        },
        'targetText': 'I always have my lunch at one in the afternoon.',
        'voicePrompt': 'Say: I always have my lunch at one in the afternoon.',
        'options': [
          'I always have my lunch at one in the afternoon.',
          'Lunch is skipped at night.',
          'I eating breakfast at midnight.',
          'Food is never eaten by me.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഭക്ഷണ സമയം വ്യക്തമാക്കാൻ.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'State what time you usually go to sleep at night:',
          'ml': 'സാധാരണയായി രാത്രി എത്ര മണിക്കാണ് ഉറങ്ങാൻ പോകുന്നത് എന്ന് പറയുക:',
        },
        'targetText': 'I usually go to bed around ten thirty at night.',
        'voicePrompt': 'Say: I usually go to bed around ten thirty at night.',
        'options': [
          'I usually go to bed around ten thirty at night.',
          'Sleep is not coming to me.',
          'I wake up at midnight.',
          'Night is for working only.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഉറങ്ങുന്ന സമയം വ്യക്തമാക്കാൻ "go to bed" ഉപയോഗിക്കുക.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 5: Shopping, Bakery & Restaurant Dining
    // -----------------------------------------------------------------------
    5: [
      {
        'id': 1,
        'question': {
          'en': 'Ask the storekeeper for the price of a shirt:',
          'ml': 'കടക്കാരനോട് ഒരു ഷർട്ടിന്റെ വില ചോദിക്കുക:',
        },
        'targetText': 'Excuse me, how much does this blue shirt cost?',
        'voicePrompt': 'Say: Excuse me, how much does this blue shirt cost?',
        'options': [
          'Excuse me, how much does this blue shirt cost?',
          'Why this shirt here?',
          'Give shirt free of cost.',
          'Price is not my business.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സാധനങ്ങളുടെ വില ചോദിക്കാൻ "how much does this cost" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Request a table for two at a busy restaurant:',
          'ml': 'റെസ്റ്റോറന്റിൽ ചെന്ന് രണ്ട് പേർക്കുള്ള മേശ ആവശ്യപ്പെടുക:',
        },
        'targetText': 'Good evening, could we get a table for two please?',
        'voicePrompt': 'Say: Good evening, could we get a table for two please?',
        'options': [
          'Good evening, could we get a table for two please?',
          'Where is food sitting place?',
          'I want twenty chairs right now.',
          'Tables are empty or not?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'റെസ്റ്റോറന്റിൽ ടേബിൾ ചോദിക്കുന്ന രീതി.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Politely request the chef to make the curry less spicy:',
          'ml': 'ഭക്ഷണത്തിൽ എരിവ് കുറച്ച് നൽകാൻ വെയിറ്ററോട് അഭ്യർത്ഥിക്കുക:',
        },
        'targetText': 'Could you please make the chicken curry less spicy?',
        'voicePrompt': 'Say: Could you please make the chicken curry less spicy?',
        'options': [
          'Could you please make the chicken curry less spicy?',
          'Put full chili in my food.',
          'Spicy is good for burning.',
          'Curry is not cooked.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'എരിവ് കുറയ്ക്കാൻ "less spicy" അല്ലെങ്കിൽ "mild" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Ask the waiter for the food bill and inquire about UPI payment:',
          'ml': 'വെയിറ്ററോട് ബിൽ ആവശ്യപ്പെടുകയും ഗൂഗിൾ പേ/UPI സാധ്യമാണോ എന്ന് ചോദിക്കുകയും ചെയ്യുക:',
        },
        'targetText': 'Could you bring the bill please? Do you accept UPI payment?',
        'voicePrompt': 'Say: Could you bring the bill please? Do you accept UPI payment?',
        'options': [
          'Could you bring the bill please? Do you accept UPI payment?',
          'I will run away without paying bill.',
          'Bill is too much money.',
          'Take cash only no phone.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഭക്ഷണ ശേഷം ബിൽ ചോദിക്കുന്ന ശരിയായ ശൈലി.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 6: Travel, Train Station, Auto Hailing & Asking Directions
    // -----------------------------------------------------------------------
    6: [
      {
        'id': 1,
        'question': {
          'en': 'Inquire at the railway counter about your train platform:',
          'ml': 'റെയിൽവേ ഇൻഫർമേഷൻ കൗണ്ടറിൽ ട്രെയിൻ ഏത് പ്ലാറ്റ്ഫോമിലാണ് വരുന്നതെന്ന് ചോദിക്കുക:',
        },
        'targetText': 'Excuse me, which platform does the Netravati Express arrive on?',
        'voicePrompt': 'Say: Excuse me, which platform does the Netravati Express arrive on?',
        'options': [
          'Excuse me, which platform does the Netravati Express arrive on?',
          'Where train is going now?',
          'Platform is broken today.',
          'Train cancelled no journey.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ട്രെയിൻ പ്ലാറ്റ്ഫോം നമ്പർ തിരക്കാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Ask a pedestrian politely for directions to the nearest bus stand:',
          'ml': 'വഴിപോക്കനോട് അടുത്തുള്ള ബസ് സ്റ്റാൻഡിലേക്കുള്ള വഴി ചോദിക്കുക:',
        },
        'targetText': 'Excuse me, could you tell me the way to the bus stand?',
        'voicePrompt': 'Say: Excuse me, could you tell me the way to the bus stand?',
        'options': [
          'Excuse me, could you tell me the way to the bus stand?',
          'Bus stand is far away from here.',
          'I am lost and crying.',
          'Where is every bus going?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മാന്യമായി വഴി ചോദിക്കുന്ന വിധം.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Give clear directions to turn right at the traffic signal:',
          'ml': 'ട്രാഫിക് സിഗ്നലിൽ നിന്ന് വലത്തോട്ട് തിരിയണമെന്ന് വഴി പറഞ്ഞു നൽകുക:',
        },
        'targetText': 'Go straight ahead and take the first right turn at the signal.',
        'voicePrompt': 'Say: Go straight ahead and take the first right turn at the signal.',
        'options': [
          'Go straight ahead and take the first right turn at the signal.',
          'Turn around and walk backward.',
          'Signals are red do not move.',
          'Left is right and right is wrong.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ദിശാസൂചന നൽകാൻ "Go straight and take the right turn" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Hail an auto-rickshaw and request to run by fare meter:',
          'ml': 'ഓട്ടോഡ്രൈവറോട് മീറ്റർ ഇട്ട് റെയിൽവേ സ്റ്റേഷനിലേക്ക് പോകാൻ ആവശ്യപ്പെടുക:',
        },
        'targetText': 'Railway station, please. Will you turn on the fare meter?',
        'voicePrompt': 'Say: Railway station, please. Will you turn on the fare meter?',
        'options': [
          'Railway station, please. Will you turn on the fare meter?',
          'Take hundred rupees extra.',
          'I will drive auto rickshaw.',
          'Meter is not working.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഓട്ടോയിൽ മീറ്റർ ആവശ്യപ്പെടാൻ ഇത് ഉപയോഗിക്കാം.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 7: Health, Doctor Visit & Pharmacy
    // -----------------------------------------------------------------------
    7: [
      {
        'id': 1,
        'question': {
          'en': 'Explain your health symptoms clearly to the doctor:',
          'ml': 'കഴിഞ്ഞ രണ്ട് ദിവസമായി പനിയും തൊണ്ടവേദനയുമുണ്ടെന്ന് ഡോക്ടറോട് പറയുക:',
        },
        'targetText': 'Doctor, I have had a severe fever and throat pain for two days.',
        'voicePrompt': 'Say: Doctor, I have had a severe fever and throat pain for two days.',
        'options': [
          'Doctor, I have had a severe fever and throat pain for two days.',
          'I am completely healthy today.',
          'No medicine required for fever.',
          'Throat is singing well.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'രോഗലക്ഷണങ്ങൾ ഡോക്ടറോട് വ്യക്തമാക്കുന്ന വിധം.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Ask the pharmacist about the correct medicine dosage:',
          'ml': 'മരുന്ന് എപ്പോഴൊക്കെയാണ് കഴിക്കേണ്ടതെന്ന് ഫാർമസിസ്റ്റിനോട് ചോദിക്കുക:',
        },
        'targetText': 'How many times a day should I take this antibiotic tablet?',
        'voicePrompt': 'Say: How many times a day should I take this antibiotic tablet?',
        'options': [
          'How many times a day should I take this antibiotic tablet?',
          'Can I eat all tablets together?',
          'Tablets taste bitter throw away.',
          'Medicine is water or sweet?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മരുന്ന് കഴിക്കേണ്ട അളവും സമയവും ചോദിക്കാൻ.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Inquire if this tablet should be taken before or after meals:',
          'ml': 'ഈ ഗുളിക ഭക്ഷണത്തിന് മുമ്പാണോ ശേഷമാണോ കഴിക്കേണ്ടതെന്ന് ചോദിക്കുക:',
        },
        'targetText': 'Should I take this medicine before food or after meals?',
        'voicePrompt': 'Say: Should I take this medicine before food or after meals?',
        'options': [
          'Should I take this medicine before food or after meals?',
          'Never eat food after medicine.',
          'Before meals is always after meals.',
          'Food has no relation to tablets.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഭക്ഷണത്തിന് മുൻപോ ശേഷമോ എന്ന് വ്യക്തത വരുത്താൻ.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Advise a resting patient to drink warm water and get adequate sleep:',
          'ml': 'രോഗിയോട് ചൂടുവെള്ളം കുടിക്കാനും വിശ്രമിക്കാനും സ്നേഹത്തോടെ ഉപദേശിക്കുക:',
        },
        'targetText': 'Please drink plenty of warm water and take complete rest.',
        'voicePrompt': 'Say: Please drink plenty of warm water and take complete rest.',
        'options': [
          'Please drink plenty of warm water and take complete rest.',
          'Run ten miles in hot sun.',
          'Drink ice cold soda immediately.',
          'Resting is waste of time.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'രോഗിക്ക് ആശ്വാസവും ആരോഗ്യോപദേശവും നൽകാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 8: Banking, Cash Deposit & UPI Transactions
    // -----------------------------------------------------------------------
    8: [
      {
        'id': 1,
        'question': {
          'en': 'Tell the bank teller you want to deposit cash into your account:',
          'ml': 'അക്കൗണ്ടിലേക്ക് പണം നിക്ഷേപിക്കണമെന്ന് ബാങ്ക് ഉദ്യോഗസ്ഥനോട് പറയുക:',
        },
        'targetText': 'I would like to deposit five thousand rupees into my savings account.',
        'voicePrompt': 'Say: I would like to deposit five thousand rupees into my savings account.',
        'options': [
          'I would like to deposit five thousand rupees into my savings account.',
          'Take all bank money away.',
          'Deposit slip is torn.',
          'Savings account has zero balance.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ബാങ്കിൽ പണം നിക്ഷേപിക്കാൻ ഈ വാക്യം ഉപയോഗിക്കാം.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Request the customer service desk to check your account balance:',
          'ml': 'അക്കൗണ്ടിലെ ബാക്കി തുക എത്രയെന്ന് പരിശോധിച്ചു തരാൻ ആവശ്യപ്പെടുക:',
        },
        'targetText': 'Could you please check my available account balance?',
        'voicePrompt': 'Say: Could you please check my available account balance?',
        'options': [
          'Could you please check my available account balance?',
          'Money is hidden in locker.',
          'Balance is zero or negative.',
          'Why balance inquiry today?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'അക്കൗണ്ട് ബാലൻസ് ചോദിക്കാനുള്ള മാന്യമായ ശൈലി.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Report that you forgot your debit card ATM PIN:',
          'ml': 'എടിഎം കാർഡിന്റെ പിൻ നമ്പർ മറന്നുപോയെന്ന് ബാങ്കിൽ അറിയിക്കുക:',
        },
        'targetText': 'I have forgotten my ATM debit card PIN number.',
        'voicePrompt': 'Say: I have forgotten my ATM debit card PIN number.',
        'options': [
          'I have forgotten my ATM debit card PIN number.',
          'ATM machine took my shoes.',
          'Cards are plastic waste.',
          'PIN is secret even to me.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'എടിഎം പിൻ മറന്നാൽ ബാങ്കിൽ പറയേണ്ട വിധം.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Ask if a bank transfer transaction has been credited:',
          'ml': 'അയച്ച പണം അക്കൗണ്ടിൽ വന്നിട്ടുണ്ടോ എന്ന് അന്വേഷിക്കുക:',
        },
        'targetText': 'Has the online transfer amount been credited to my account yet?',
        'voicePrompt': 'Say: Has the online transfer amount been credited to my account yet?',
        'options': [
          'Has the online transfer amount been credited to my account yet?',
          'Money vanished in thin air.',
          'No transfer ever happened.',
          'Credit debit are confusing words.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പണം അക്കൗണ്ടിൽ എത്തിയോ എന്നറിയാൻ "credited" ഉപയോഗിക്കുക.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 9: Renting a Home, Flat Hunting & Lease Terms
    // -----------------------------------------------------------------------
    9: [
      {
        'id': 1,
        'question': {
          'en': 'Ask the landlord about the monthly rent for the apartment:',
          'ml': 'ഫ്ലാറ്റിന്റെ പ്രതിമാസ വാടക എത്രയാണെന്ന് ഉടമസ്ഥനോട് ചോദിക്കുക:',
        },
        'targetText': 'What is the monthly rent and advance security deposit for this flat?',
        'voicePrompt': 'Say: What is the monthly rent and advance security deposit for this flat?',
        'options': [
          'What is the monthly rent and advance security deposit for this flat?',
          'Rent is free for whole year.',
          'Advance deposit never returned.',
          'I will not pay any rent.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'വാടകയും അഡ്വാൻസും അന്വേഷിക്കാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Inquire if building maintenance and water charges are included:',
          'ml': 'കെട്ടിട മെയിന്റനൻസും വെള്ളക്കരവും വാടകയിൽ ഉൾപ്പെട്ടിട്ടുണ്ടോ എന്ന് ചോദിക്കുക:',
        },
        'targetText': 'Are maintenance charges and water supply included in the monthly rent?',
        'voicePrompt': 'Say: Are maintenance charges and water supply included in the monthly rent?',
        'options': [
          'Are maintenance charges and water supply included in the monthly rent?',
          'Water is leaking everywhere.',
          'Maintenance is broken roof.',
          'No charge for anything.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മെയിന്റനൻസ് വിവരങ്ങൾ ചോദിച്ചറിയാൻ.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Ask if designated car parking space is available:',
          'ml': 'പ്രത്യേകം കാർ പാർക്കിംഗ് സ്ഥലം ലഭ്യമാണോ എന്ന് ചോദിക്കുക:',
        },
        'targetText': 'Is there dedicated covered car parking space available for tenants?',
        'voicePrompt': 'Say: Is there dedicated covered car parking space available for tenants?',
        'options': [
          'Is there dedicated covered car parking space available for tenants?',
          'Park car on the roof.',
          'No cars allowed in society.',
          'Parking is outside on main road.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'കാർ പാർക്കിംഗ് സൗകര്യം ചോദിക്കാൻ.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Ask the owner when the flat will be ready for moving in:',
          'ml': 'എപ്പോഴാണ് താമസം മാറാൻ സാധിക്കുക എന്ന് ഉടമയോട് ചോദിക്കുക:',
        },
        'targetText': 'When will the apartment be painted and ready for us to move in?',
        'voicePrompt': 'Say: When will the apartment be painted and ready for us to move in?',
        'options': [
          'When will the apartment be painted and ready for us to move in?',
          'Move in after twenty years.',
          'Paint is still wet do not touch.',
          'Keys are lost forever.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'താമസം മാറാനുള്ള തീയതി അന്വേഷിക്കാൻ "ready to move in" ഉപയോഗിക്കുക.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 10: Tech Support, Hardware Glitches & Devices
    // -----------------------------------------------------------------------
    10: [
      {
        'id': 1,
        'question': {
          'en': 'Report a battery draining issue to the laptop service center:',
          'ml': 'ലാപ്‌ടോപ്പ് ബാറ്ററി വളരെ പെട്ടെന്ന് തീർന്നുപോകുന്നു എന്ന് ടെക്നീഷ്യനോട് പറയുക:',
        },
        'targetText': 'My laptop battery is draining very fast even after a full charge.',
        'voicePrompt': 'Say: My laptop battery is draining very fast even after a full charge.',
        'options': [
          'My laptop battery is draining very fast even after a full charge.',
          'Battery is full forever.',
          'Charger is made of stone.',
          'Laptop does not need power.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ബാറ്ററി തകരാർ റിപ്പോർട്ട് ചെയ്യാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Explain that your mobile screen is completely frozen:',
          'ml': 'ഫോൺ സ്ക്രീൻ അനങ്ങാതെ ഹാങ്ങായി നിൽക്കുന്നു എന്ന് പറയുക:',
        },
        'targetText': 'The touchscreen is completely frozen and not responding to touch.',
        'voicePrompt': 'Say: The touchscreen is completely frozen and not responding to touch.',
        'options': [
          'The touchscreen is completely frozen and not responding to touch.',
          'Screen is dancing happily.',
          'Glass is shattered to pieces.',
          'Touch is working on air.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'സ്ക്രീൻ ഫ്രീസ് ആയത് വിവരിക്കാൻ "frozen / not responding" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Inquire if the device repair is covered under warranty:',
          'ml': 'ഈ റിപ്പയറിംഗ് വാറന്റിയിൽ ഉൾപ്പെടുമോ എന്ന് ചോദിക്കുക:',
        },
        'targetText': 'Is this hardware repair covered under the one-year warranty?',
        'voicePrompt': 'Say: Is this hardware repair covered under the one-year warranty?',
        'options': [
          'Is this hardware repair covered under the one-year warranty?',
          'Warranty expired ten years ago.',
          'Repair will cost one lakh rupees.',
          'No warranty paper in hand.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'വാറന്റി കവറേജ് അറിയാൻ "covered under warranty" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Advise restarting the Wi-Fi router to fix network connectivity:',
          'ml': 'ഇന്റർനെറ്റ് പ്രശ്നം മാറാൻ വൈഫൈ റൂട്ടർ റീസ്റ്റാർട്ട് ചെയ്യാൻ പറയുക:',
        },
        'targetText': 'Please restart your Wi-Fi router and try reconnecting the device.',
        'voicePrompt': 'Say: Please restart your Wi-Fi router and try reconnecting the device.',
        'options': [
          'Please restart your Wi-Fi router and try reconnecting the device.',
          'Throw the router in the river.',
          'Cables are cut into halves.',
          'Internet never works anywhere.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'റൂട്ടർ റീസ്റ്റാർട്ട് ചെയ്യാൻ ഉപദേശിക്കാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 11: Job Interview, Self-Pitch & Professional Strengths
    // -----------------------------------------------------------------------
    11: [
      {
        'id': 1,
        'question': {
          'en': 'Answer the interview question about your work experience:',
          'ml': 'നിങ്ങളുടെ പ്രവൃത്തിപരിചയം ഇന്റർവ്യൂവിൽ വ്യക്തമാക്കുക:',
        },
        'targetText': 'I have three years of professional experience in customer relations.',
        'voicePrompt': 'Say: I have three years of professional experience in customer relations.',
        'options': [
          'I have three years of professional experience in customer relations.',
          'I never worked anywhere in my life.',
          'Experience is overrated.',
          'I forgot what my previous job was.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പ്രവൃത്തിപരിചയം വ്യക്തമാക്കാൻ "years of professional experience" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'State your greatest professional strength confidently:',
          'ml': 'നിങ്ങളുടെ ഏറ്റവും വലിയ കരുത്ത് എന്താണെന്ന് അഭിമുഖത്തിൽ പറയുക:',
        },
        'targetText': 'My greatest strength is my problem-solving ability under pressure.',
        'voicePrompt': 'Say: My greatest strength is my problem-solving ability under pressure.',
        'options': [
          'My greatest strength is my problem-solving ability under pressure.',
          'I panic easily in every situation.',
          'I have no strengths to mention.',
          'Working hard is difficult for me.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'കരുത്ത് വ്യക്തമാക്കാൻ "My greatest strength is..." ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Express your enthusiasm for working in cross-functional teams:',
          'ml': 'ടീമായി സഹകരിച്ച് പ്രവർത്തിക്കാനുള്ള താൽപ്പര്യം വ്യക്തമാക്കുക:',
        },
        'targetText': 'I enjoy collaborating with dynamic teams to achieve common goals.',
        'voicePrompt': 'Say: I enjoy collaborating with dynamic teams to achieve common goals.',
        'options': [
          'I enjoy collaborating with dynamic teams to achieve common goals.',
          'I refuse to talk to any teammates.',
          'Teamwork is useless for me.',
          'I prefer working alone in darkness.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ടീം വർക്ക് മികവ് അവതരിപ്പിക്കാൻ.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'State why you are eager to join this specific company:',
          'ml': 'എന്തുകൊണ്ടാണ് ഈ കമ്പനിയിൽ ജോലി ചെയ്യാൻ ആഗ്രഹിക്കുന്നതെന്ന് പറയുക:',
        },
        'targetText': 'I am impressed by your company\'s innovation and work culture.',
        'voicePrompt': 'Say: I am impressed by your company\'s innovation and work culture.',
        'options': [
          'I am impressed by your company\'s innovation and work culture.',
          'I just want money without working.',
          'No other company gave me an interview.',
          'Your company is very ordinary.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'കമ്പനിയെക്കുറിച്ചുള്ള മതിപ്പ് വ്യക്തമാക്കാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 12: International Airport, Flight & Hotel Check-in
    // -----------------------------------------------------------------------
    12: [
      {
        'id': 1,
        'question': {
          'en': 'Check in for your flight at the airport airline counter:',
          'ml': 'എയർപോർട്ട് കൗണ്ടറിൽ ഫ്ലൈറ്റിനായി ചെക്ക്-ഇൻ ചെയ്യുക:',
        },
        'targetText': 'Good morning, I would like to check in for my flight to Dubai.',
        'voicePrompt': 'Say: Good morning, I would like to check in for my flight to Dubai.',
        'options': [
          'Good morning, I would like to check in for my flight to Dubai.',
          'Plane is leaving without passengers.',
          'Passport is left at home.',
          'Luggage is missing already.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'എയർപോർട്ടിൽ ഫ്ലൈറ്റ് ചെക്ക്-ഇൻ ചെയ്യാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Politely request a window seat on the aircraft:',
          'ml': 'വിമാനത്തിൽ ജനലിനടുത്തുള്ള സീറ്റ് നൽകാൻ മാന്യമായി അഭ്യർത്ഥിക്കുക:',
        },
        'targetText': 'Could I please get a window seat if one is available?',
        'voicePrompt': 'Say: Could I please get a window seat if one is available?',
        'options': [
          'Could I please get a window seat if one is available?',
          'Sit on the wing outside.',
          'Window seats are illegal.',
          'I want pilot seat right now.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'വിൻഡോ സീറ്റ് ചോദിക്കാൻ "window seat" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Check in at the hotel reception desk with your reservation:',
          'ml': 'ഹോട്ടൽ റിസപ്ഷനിൽ ബുക്കിംഗ് പറഞ്ഞ് ചെക്ക്-ഇൻ ചെയ്യുക:',
        },
        'targetText': 'Hello, I have a room reservation under the name of Thomas.',
        'voicePrompt': 'Say: Hello, I have a room reservation under the name of Thomas.',
        'options': [
          'Hello, I have a room reservation under the name of Thomas.',
          'Hotel rooms are all occupied.',
          'Give me presidential suite for free.',
          'No booking done by anyone.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഹോട്ടലിൽ ബുക്കിംഗ് വിവരം പറയാൻ "reservation under the name of..." ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Inquire about the complimentary breakfast timings at the hotel:',
          'ml': 'ഹോട്ടലിൽ സൗജന്യ പ്രഭാതഭക്ഷണം ഏത് സമയം വരെയാണ് ലഭിക്കുക എന്ന് ചോദിക്കുക:',
        },
        'targetText': 'What time is the complimentary morning breakfast served in the dining hall?',
        'voicePrompt': 'Say: What time is the complimentary morning breakfast served in the dining hall?',
        'options': [
          'What time is the complimentary morning breakfast served in the dining hall?',
          'Breakfast is only for managers.',
          'Food is served at midnight.',
          'Dining hall is closed today.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'ഹോട്ടൽ ബ്രേക്ക്ഫാസ്റ്റ് സമയം തിരക്കാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 13: Workplace Presentations, Meetings & Project Timelines
    // -----------------------------------------------------------------------
    13: [
      {
        'id': 1,
        'question': {
          'en': 'Open a business meeting by introducing today\'s agenda:',
          'ml': 'ഇന്നത്തെ മീറ്റിംഗിന്റെ അജണ്ട വിശദീകരിച്ച് യോഗം ആരംഭിക്കുക:',
        },
        'targetText': 'Welcome everyone, let us quickly review today\'s meeting agenda.',
        'voicePrompt': 'Say: Welcome everyone, let us quickly review today\'s meeting agenda.',
        'options': [
          'Welcome everyone, let us quickly review today\'s meeting agenda.',
          'Meeting is over, go home now.',
          'Nobody has an agenda today.',
          'Why are we sitting together?',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'യോഗം ആരംഭിക്കുമ്പോൾ അജണ്ട അവതരിപ്പിക്കാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Announce that the project was delivered on schedule:',
          'ml': 'പദ്ധതി കൃത്യസമയത്ത് വിജയകരമായി പൂർത്തിയാക്കി എന്ന് സഹപ്രവർത്തകരെ അറിയിക്കുക:',
        },
        'targetText': 'We have successfully delivered the project milestone right on schedule.',
        'voicePrompt': 'Say: We have successfully delivered the project milestone right on schedule.',
        'options': [
          'We have successfully delivered the project milestone right on schedule.',
          'Project failed and crashed.',
          'Deadlines are meant to be broken.',
          'No milestone achieved.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പ്രോജക്റ്റ് വിജയം പ്രഖ്യാപിക്കാൻ "delivered on schedule" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Politely ask a presenter to clarify an important slide:',
          'ml': 'പ്രസന്റേഷനിലെ പ്രധാനപ്പെട്ട ഒരു കാര്യത്തിൽ വ്യക്തത ചോദിക്കുക:',
        },
        'targetText': 'Could you please elaborate on the fourth slide regarding budget allocation?',
        'voicePrompt': 'Say: Could you please elaborate on the fourth slide regarding budget allocation?',
        'options': [
          'Could you please elaborate on the fourth slide regarding budget allocation?',
          'Slides are unreadable nonsense.',
          'Budget is none of our business.',
          'Skip all remaining slides.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'വ്യക്തത തേടാൻ "elaborate on..." ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Wrap up the meeting and propose a follow-up session next Monday:',
          'ml': 'അടുത്ത തിങ്കളാഴ്ച തുടർചർച്ച നടത്താമെന്ന് നിർദ്ദേശിച്ച് യോഗം അവസാനിപ്പിക്കുക:',
        },
        'targetText': 'Thank you all for your time, let us schedule a follow-up call next Monday.',
        'voicePrompt': 'Say: Thank you all for your time, let us schedule a follow-up call next Monday.',
        'options': [
          'Thank you all for your time, let us schedule a follow-up call next Monday.',
          'Never speak to me again.',
          'Monday is cancelled worldwide.',
          'No follow-up needed ever.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'മീറ്റിംഗ് കൃത്യമായി അവസാനിപ്പിക്കാൻ.'},
      },
    ],

    // -----------------------------------------------------------------------
    // DAY 14: Emergencies, Police, First-Aid & Urgent Assistance
    // -----------------------------------------------------------------------
    14: [
      {
        'id': 1,
        'question': {
          'en': 'Call emergency services urgently to report a road accident:',
          'ml': 'റോഡപകടം കണ്ട് ഉടൻ തന്നെ ആംബുലൻസിനെ വിളിച്ച് വിവരം പറയുക:',
        },
        'targetText': 'Please send an ambulance immediately to the Highway Bypass Junction.',
        'voicePrompt': 'Say: Please send an ambulance immediately to the Highway Bypass Junction.',
        'options': [
          'Please send an ambulance immediately to the Highway Bypass Junction.',
          'Ambulance can come next week.',
          'Accidents are normal ignore it.',
          'No emergency here at all.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'അടിയന്തിര ഘട്ടങ്ങളിൽ ആംബുലൻസ് വിളിക്കാൻ.'},
      },
      {
        'id': 2,
        'question': {
          'en': 'Report a stolen bag to the police control room:',
          'ml': 'ബാഗ് മോഷണം പോയ വിവരം പോലീസ് കൺട്രോൾ റൂമിൽ അറിയിക്കുക:',
        },
        'targetText': 'Officer, my backpack containing documents was stolen at the bus terminal.',
        'voicePrompt': 'Say: Officer, my backpack containing documents was stolen at the bus terminal.',
        'options': [
          'Officer, my backpack containing documents was stolen at the bus terminal.',
          'I threw my bag in the trash.',
          'Police cannot help anyone.',
          'Stealing is allowed here.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പോലീസിനോട് മോഷണ വിവരം വ്യക്തമായി പറയാൻ.'},
      },
      {
        'id': 3,
        'question': {
          'en': 'Reassure an injured pedestrian that medical help is arriving soon:',
          'ml': 'പരിക്കേറ്റ ആളോട് ആശ്വാസവാക്കുകൾ പറഞ്ഞ് ധൈര്യം പകരുക:',
        },
        'targetText': 'Please stay calm and do not worry, medical help is on the way.',
        'voicePrompt': 'Say: Please stay calm and do not worry, medical help is on the way.',
        'options': [
          'Please stay calm and do not worry, medical help is on the way.',
          'There is no hope for you.',
          'Nobody is coming to help.',
          'Run around and scream aloud.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'അപകടത്തിൽപ്പെട്ടവർക്ക് ധൈര്യം പകരാൻ "stay calm, help is on the way" ഉപയോഗിക്കുക.'},
      },
      {
        'id': 4,
        'question': {
          'en': 'Ask bystanders urgently for a first-aid kit or clean bandage:',
          'ml': 'അടുത്തുള്ളവരോട് പ്രഥമശുശ്രൂഷാ പെട്ടി (First-aid kit) ആവശ്യപ്പെടുക:',
        },
        'targetText': 'Does anyone nearby have a first-aid kit with clean bandages?',
        'voicePrompt': 'Say: Does anyone nearby have a first-aid kit with clean bandages?',
        'options': [
          'Does anyone nearby have a first-aid kit with clean bandages?',
          'Bandages are useless for bleeding.',
          'Keep first-aid kits locked away.',
          'First-aid is not required here.',
        ],
        'correctIndex': 0,
        'explanation': {'ml': 'പ്രഥമശുശ്രൂഷാ സാമഗ്രികൾ ചോദിച്ചറിയാൻ.'},
      },
    ],
  };
}
