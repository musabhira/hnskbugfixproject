// tool/generate_english_realm_manifest.js
// Generates english_realm_data_p1.dart, english_realm_data_p2.dart, and english_realm_data_p3.dart
const fs = require('fs');
const path = require('path');

// Complete manifest metadata for all 90 days
const dayManifest = [
  // WEEK 1
  {
    day: 1,
    topic: 'Basics of English Sentence Formation',
    regionId: 'foundations_village',
    regionName: 'English Foundations Village',
    color: '0xFF10B981',
    g1: {
      title: 'Letter Hunt Run',
      subtitle: 'Phonics & First Sounds',
      genre: 'GameArchetype.runnerCollector',
      icon: '🔤',
      descEn: 'Sprint across the village green collecting the foundational letters of the alphabet.',
      descMl: 'ഗ്രാമത്തിലൂടെ ഓടി അടിസ്ഥാന അക്ഷരങ്ങളും അവയുടെ ആദ്യ ശബ്ദങ്ങളും ശേഖരിക്കുക.',
      rounds: [
        {
          promptEn: 'Which letter produces the initial sound in "Apple"?',
          promptMl: '"Apple" എന്ന വാക്കിന്റെ ആദ്യ ശബ്ദം ഉണ്ടാക്കുന്ന അക്ഷരം ഏതാണ്?',
          options: ['Letter A (/æ/)', 'Letter B (/b/)', 'Letter C (/k/)', 'Letter D (/d/)'],
          solution: 0,
          explanationEn: 'The word "Apple" begins with the letter A and the short vowel sound /æ/.',
          explanationMl: '"Apple" എന്ന വാക്ക് ആരംഭിക്കുന്നത് A എന്ന അക്ഷരവും /æ/ ശബ്ദവുമാണ്.',
          audio: 'Apple begins with the letter A.'
        },
        {
          promptEn: 'Identify the letter with the /k/ sound in "Cat":',
          promptMl: '"Cat" എന്ന വാക്കിലെ /k/ ശബ്ദമുള്ള അക്ഷരം ഏതാണ്?',
          options: ['Letter S', 'Letter C', 'Letter T', 'Letter P'],
          solution: 1,
          explanationEn: 'The letter C before the vowel "a" makes the hard /k/ sound as in "Cat".',
          explanationMl: 'C എന്ന അക്ഷരം a ക്ക് മുൻപ് വരുമ്പോൾ /k/ എന്ന് ഉച്ചരിക്കുന്നു.',
          audio: 'Cat starts with letter C.'
        },
        {
          promptEn: 'Which word starts with the voiced bilabial sound of "B"?',
          promptMl: '"B" എന്ന അക്ഷരത്തിൽ തുടങ്ങുന്ന വാക്ക് ഏതാണ്?',
          options: ['Sun', 'Ball', 'Pen', 'Cup'],
          solution: 1,
          explanationEn: '"Ball" begins with the letter B.',
          explanationMl: '"Ball" എന്നത് B എന്ന അക്ഷരത്തിൽ തുടങ്ങുന്നു.',
          audio: 'B is for ball.'
        },
        {
          promptEn: 'What is the standard word order in a basic English sentence?',
          promptMl: 'ഒരു അടിസ്ഥാന ഇംഗ്ലീഷ് വാക്യത്തിന്റെ ശരിയായ ഘടന ഏതാണ്?',
          options: ['Subject + Verb + Object (SVO)', 'Verb + Subject + Object (VSO)', 'Object + Subject + Verb (OSV)', 'Subject + Object + Verb (SOV)'],
          solution: 0,
          explanationEn: 'Natural English sentences follow Subject + Verb + Object (e.g., "I drink water").',
          explanationMl: 'ഇംഗ്ലീഷിൽ വാക്യം ഉണ്ടാക്കുന്നത് Subject + Verb + Object (SVO) എന്ന ക്രമത്തിലാണ്.',
          audio: 'English follows Subject, Verb, Object word order.'
        },
        {
          promptEn: 'Assemble the correct basic sentence: "happy / am / I"',
          promptMl: 'ശരിയായ വാക്യം കണ്ടെത്തുക:',
          options: ['Am I happy.', 'I am happy.', 'Happy I am.', 'Am happy I.'],
          solution: 1,
          explanationEn: '"I am happy" correctly places Subject (I) + Linking Verb (am) + Complement (happy).',
          explanationMl: '"I am happy" എന്നതാണ് ശരിയായ വാക്യം.',
          audio: 'I am happy.'
        }
      ]
    },
    g2: {
      title: 'Sentence Builder & Word Catcher',
      subtitle: 'Core SVO Construction',
      genre: 'GameArchetype.sentenceBuilder',
      icon: '🧩',
      descEn: 'Catch falling word blocks from the sky and arrange them into correct English sentences.',
      descMl: 'താഴേക്ക് വീഴുന്ന വാക്കുകൾ പിടിച്ചെടുത്ത് ശരിയായ ക്രമത്തിൽ വാക്യങ്ങൾ നിർമ്മിക്കുക.',
      rounds: [
        {
          promptEn: 'Arrange the words into a correct sentence: [eats / John / an apple]',
          promptMl: 'ശരിയായ ക്രമം തിരഞ്ഞെടുക്കുക: [eats / John / an apple]',
          options: ['John eats an apple.', 'An apple John eats.', 'Eats John an apple.', 'John an apple eats.'],
          solution: 0,
          explanationEn: 'Subject (John) + Verb (eats) + Object (an apple).',
          explanationMl: 'കർത്താവ് (John), ക്രിയ (eats), കർമ്മം (an apple) എന്ന രീതിയിലാണ് വരേണ്ടത്.',
          audio: 'John eats an apple.'
        },
        {
          promptEn: 'Complete the sentence: "She _____ coffee every morning."',
          promptMl: 'വിടവ് പൂരിപ്പിക്കുക: "She _____ coffee every morning."',
          options: ['drinks', 'drinking', 'drink', 'dranked'],
          solution: 0,
          explanationEn: 'Third-person singular "She" requires the singular verb "drinks".',
          explanationMl: 'She എന്ന സബ്ജക്റ്റിനൊപ്പം ക്രിയയിൽ s ചേർത്ത് "drinks" എന്ന് വരണം.',
          audio: 'She drinks coffee every morning.'
        },
        {
          promptEn: 'Which is a complete, grammatically sound sentence?',
          promptMl: 'പൂർണ്ണമായ അർത്ഥമുള്ള വാക്യം ഏതാണ്?',
          options: ['In the morning with tea.', 'They play football in the park.', 'Running very fast yesterday.', 'Because it was raining.'],
          solution: 1,
          explanationEn: '"They play football in the park" has a clear subject (They) and finite verb (play).',
          explanationMl: 'ഇതിൽ മാത്രമാണ് കൃത്യമായ സബ്ജക്റ്റും ക്രിയയുമുള്ളത്.',
          audio: 'They play football in the park.'
        },
        {
          promptEn: 'Form a sentence with: [a car / drives / He]',
          promptMl: 'ശരിയായ രൂപം ഏതാണ്?',
          options: ['He drives a car.', 'Drives he a car.', 'A car drives he.', 'He a car drives.'],
          solution: 0,
          explanationEn: 'S (He) + V (drives) + O (a car).',
          explanationMl: '"He drives a car" എന്നതാണ് ശരി.',
          audio: 'He drives a car.'
        },
        {
          promptEn: 'Identify the object in: "The teacher praised the student."',
          promptMl: '"The teacher praised the student" എന്ന വാക്യത്തിലെ കർമ്മം (Object) ഏതാണ്?',
          options: ['The teacher', 'praised', 'the student', 'None'],
          solution: 2,
          explanationEn: '"The student" receives the action of praise, making it the Direct Object.',
          explanationMl: 'അധ്യാപകന്റെ പ്രശംസ ലഭിച്ചത് വിദ്യാർത്ഥിക്കാണ്, അതിനാൽ "the student" ആണ് Object.',
          audio: 'The student is the object.'
        }
      ]
    }
  },

  {
    day: 2,
    topic: 'Parts of Speech – Complete Overview',
    regionId: 'foundations_village',
    regionName: 'English Foundations Village',
    color: '0xFF10B981',
    g1: {
      title: 'Grammar Sorting Factory',
      subtitle: 'The 8 Word Classes',
      genre: 'GameArchetype.sortingFactory',
      icon: '🏭',
      descEn: 'Sort conveyor items into their exact grammatical bins: Noun, Verb, Adjective, or Adverb.',
      descMl: 'വാക്കുകളെ അവയുടെ ശരിയായ വ്യാകരണ വിഭാഗങ്ങളിലേക്ക് (Noun, Verb, Adjective, Adverb) തരംതിരിക്കുക.',
      rounds: [
        {
          promptEn: 'Classify the word "Happiness" into its correct part of speech:',
          promptMl: '"Happiness" എന്ന വാക്കിന്റെ പാർട്ട് ഓഫ് സ്പീച്ച് ഏതാണ്?',
          options: ['Noun (നാമം)', 'Verb (ക്രിയ)', 'Adjective (വിശേഷണം)', 'Preposition (സംബന്ധകം)'],
          solution: 0,
          explanationEn: '"Happiness" is an abstract noun denoting a state or emotion.',
          explanationMl: '"Happiness" (സന്തോഷം) ഒരു അവസ്ഥയെ സൂചിപ്പിക്കുന്ന Abstract Noun ആണ്.',
          audio: 'Happiness is a noun.'
        },
        {
          promptEn: 'What part of speech is "Quickly" in: "He ran quickly"?',
          promptMl: '"He ran quickly" എന്ന വാക്യത്തിൽ "Quickly" എന്താണ്?',
          options: ['Adverb (ക്രിയാവിശേഷണം)', 'Adjective (നാമവിശേഷണം)', 'Conjunction (സംയോജകം)', 'Pronoun (സർവ്വനാമം)'],
          solution: 0,
          explanationEn: '"Quickly" modifies the verb "ran", explaining HOW he ran, so it is an Adverb.',
          explanationMl: 'ഓടിയ വിധത്തെ വിശേഷിപ്പിക്കുന്നതിനാൽ "Quickly" ഒരു Adverb ആണ്.',
          audio: 'Quickly is an adverb describing the action.'
        },
        {
          promptEn: 'Identify the part of speech of "Under" in: "The cat is under the table":',
          promptMl: '"The cat is under the table" എന്നതിലെ "Under" ഏത് വിഭാഗമാണ്?',
          options: ['Preposition (വിഭക്തി പ്രത്യയം / സംബന്ധകം)', 'Interjection (ഭാവപ്രകടനം)', 'Noun (നാമം)', 'Verb (ക്രിയ)'],
          solution: 0,
          explanationEn: '"Under" shows the spatial relationship between cat and table, so it is a Preposition.',
          explanationMl: 'വസ്തുക്കളുടെ സ്ഥാനം കാണിക്കുന്നതിനാൽ "Under" ഒരു Preposition ആണ്.',
          audio: 'Under is a preposition.'
        },
        {
          promptEn: 'What role does "Brilliant" play in: "She had a brilliant idea"?',
          promptMl: '"Brilliant" എന്ന വാക്കിന്റെ വ്യാകരണ വിഭാഗം എന്താണ്?',
          options: ['Adjective (വിശേഷണം)', 'Adverb', 'Noun', 'Verb'],
          solution: 0,
          explanationEn: '"Brilliant" describes the noun "idea", making it an Adjective.',
          explanationMl: '"Idea" എന്ന നാമത്തെ വിശേഷിപ്പിക്കുന്നതിനാൽ "Brilliant" ഒരു Adjective ആണ്.',
          audio: 'Brilliant is an adjective describing the idea.'
        },
        {
          promptEn: 'Classify "Ouch!" in: "Ouch! That really hurt!":',
          promptMl: '"Ouch!" എന്ന വാക്ക് ഏത് വിഭാഗത്തിൽപ്പെടുന്നു?',
          options: ['Interjection (വികാരപ്രകടനം)', 'Conjunction', 'Adverb', 'Pronoun'],
          solution: 0,
          explanationEn: '"Ouch!" expresses sudden physical pain or emotion, which is an Interjection.',
          explanationMl: 'പെട്ടെന്നുള്ള വേദനയെ പ്രകടിപ്പിക്കുന്ന വാക്കാണ് "Ouch!", അതിനാൽ ഇത് Interjection ആണ്.',
          audio: 'Ouch is an interjection.'
        }
      ]
    },
    g2: {
      title: 'Parts of Speech Arena',
      subtitle: 'Grammar Role Duel',
      genre: 'GameArchetype.arenaBattle',
      icon: '⚔️',
      descEn: 'Defeat arena opponents by rapidly identifying the grammatical function of highlighted words in sentences.',
      descMl: 'വാക്യങ്ങളിലെ വാക്കുകളുടെ വ്യാകരണ ധർമ്മം തിരിച്ചറിഞ്ഞ് എതിരാളികളെ പരാജയപ്പെടുത്തുക.',
      rounds: [
        {
          promptEn: 'In "I like to read", what part of speech is "read"?',
          promptMl: '"I like to read" എന്നതിൽ "read" എന്താണ്?',
          options: ['Verb', 'Noun', 'Adjective', 'Pronoun'],
          solution: 0,
          explanationEn: '"Read" is a verb indicating an action or activity.',
          explanationMl: '"Read" (വായിക്കുക) ഒരു പ്രവൃത്തിയെ സൂചിപ്പിക്കുന്ന Verb ആണ്.',
          audio: 'Read is a verb.'
        },
        {
          promptEn: 'In "That was a good read", what part of speech is "read"?',
          promptMl: '"That was a good read" എന്നതിൽ "read" എന്താണ്?',
          options: ['Noun', 'Verb', 'Adjective', 'Adverb'],
          solution: 0,
          explanationEn: 'Here "read" is preceded by an adjective ("good") and an article ("a"), functioning as a Noun (meaning a book/piece of writing).',
          explanationMl: 'ഇവിടെ "a good read" എന്ന് ഉപയോഗിച്ചപ്പോൾ "read" ഒരു നാമമായി (Noun) മാറി.',
          audio: 'In this context, read functions as a noun.'
        },
        {
          promptEn: 'In "Water the plants", what is "Water"?',
          promptMl: '"Water the plants" എന്നതിൽ "Water" എന്താണ്?',
          options: ['Verb (നനയ്ക്കുക)', 'Noun (വെള്ളം)', 'Adjective', 'Preposition'],
          solution: 0,
          explanationEn: 'Here "Water" is an action verb meaning "to supply water to plants".',
          explanationMl: 'ചെടികൾ നനയ്ക്കുക എന്ന പ്രവൃത്തിയെ സൂചിപ്പിക്കുന്നതിനാൽ ഇവിടെ Water ഒരു Verb ആണ്.',
          audio: 'Water is functioning as an action verb.'
        },
        {
          promptEn: 'In "I drink fresh water", what is "Water"?',
          promptMl: '"I drink fresh water" എന്നതിൽ "Water" എന്താണ്?',
          options: ['Noun (ദ്രാവകം/വെള്ളം)', 'Verb', 'Adverb', 'Interjection'],
          solution: 0,
          explanationEn: 'Here "water" is the substance/thing being drunk, hence a Noun.',
          explanationMl: 'കുടിക്കുന്ന വസ്തുവായതിനാൽ ഇവിടെ Water ഒരു Noun ആണ്.',
          audio: 'Water is a noun representing the substance.'
        },
        {
          promptEn: 'In "We arrived early, but they were late", what is "but"?',
          promptMl: '"We arrived early, but they were late" എന്നതിലെ "but" എന്താണ്?',
          options: ['Conjunction (സംയോജകം)', 'Preposition', 'Adverb', 'Adjective'],
          solution: 0,
          explanationEn: '"But" connects two independent clauses, so it is a Coordinating Conjunction.',
          explanationMl: 'രണ്ട് വാക്യങ്ങളെ തമ്മിൽ ബന്ധിപ്പിക്കുന്നതിനാൽ "but" ഒരു Conjunction ആണ്.',
          audio: 'But is a coordinating conjunction.'
        }
      ]
    }
  },

  {
    day: 3,
    topic: 'Nouns – Types, Countable and Uncountable Nouns, Singular and Plural',
    regionId: 'foundations_village',
    regionName: 'English Foundations Village',
    color: '0xFF10B981',
    g1: {
      title: 'Noun Collector',
      subtitle: 'Noun Categories Quest',
      genre: 'GameArchetype.runnerCollector',
      icon: '🎒',
      descEn: 'Collect and classify Proper, Common, Collective, and Abstract nouns across the realm.',
      descMl: 'വ്യത്യസ്ത നാമ രൂപങ്ങൾ (Proper, Common, Collective, Abstract) ശേഖരിച്ച് തരംതിരിക്കുക.',
      rounds: [
        {
          promptEn: 'Which of the following is a Proper Noun?',
          promptMl: 'ഇതിൽ Proper Noun (വ്യക്തിനാമം) ഏതാണ്?',
          options: ['London', 'city', 'country', 'building'],
          solution: 0,
          explanationEn: '"London" is the specific capitalized name of a city, making it a Proper Noun.',
          explanationMl: 'ഒരു പ്രത്യേക നഗരത്തിന്റെ പേരായതിനാൽ "London" ഒരു Proper Noun ആണ്.',
          audio: 'London is a proper noun and capitalized.'
        },
        {
          promptEn: 'Identify the Collective Noun:',
          promptMl: 'കൂട്ടത്തെ സൂചിപ്പിക്കുന്ന Collective Noun ഏതാണ്?',
          options: ['Flock (ആട്ടിൻകൂട്ടം / പക്ഷിക്കൂട്ടം)', 'Sheep', 'Bird', 'Grass'],
          solution: 0,
          explanationEn: '"Flock" represents a group of birds or sheep, hence a Collective Noun.',
          explanationMl: 'പക്ഷികളുടെയോ ആടുകളുടെയോ കൂട്ടത്തെ കുറിക്കുന്ന പദമാണ് Flock.',
          audio: 'Flock is a collective noun.'
        },
        {
          promptEn: 'Which is an Abstract Noun?',
          promptMl: 'തൊട്ടറിയാൻ കഴിയാത്ത ഗുണത്തെയോ ആശയത്തെയോ കുറിക്കുന്ന Abstract Noun ഏതാണ്?',
          options: ['Bravery (ധീരത)', 'Sword', 'Shield', 'Soldier'],
          solution: 0,
          explanationEn: '"Bravery" is a concept or quality you cannot touch physically, making it an Abstract Noun.',
          explanationMl: '"Bravery" ഒരു ഗുണത്തെ കാണിക്കുന്നതിനാൽ Abstract Noun ആണ്.',
          audio: 'Bravery is an abstract noun.'
        },
        {
          promptEn: 'Select the Material Noun from the choices:',
          promptMl: 'വസ്തുക്കളെ ഉണ്ടാക്കാൻ ഉപയോഗിക്കുന്ന Material Noun ഏതാണ്?',
          options: ['Gold', 'Ring', 'Necklace', 'Jeweler'],
          solution: 0,
          explanationEn: '"Gold" is the raw material/substance from which ornaments are made.',
          explanationMl: '"Gold" (സ്വർണ്ണം) ഒരു അസംസ്കൃത വസ്തുവായതിനാൽ Material Noun ആണ്.',
          audio: 'Gold is a material noun.'
        },
        {
          promptEn: 'Which word represents a Common Noun?',
          promptMl: 'സാധാരണ നാമമായ Common Noun ഏതാണ്?',
          options: ['River', 'Nile', 'Amazon', 'Ganges'],
          solution: 0,
          explanationEn: '"River" is a general name applicable to any river, unlike Nile which is Proper.',
          explanationMl: '"River" എന്നത് പൊതുവായി ഉപയോഗിക്കുന്ന നാമമാണ്.',
          audio: 'River is a common noun.'
        }
      ]
    },
    g2: {
      title: 'Count and Conquer',
      subtitle: 'Countable vs Uncountable & Plurals',
      genre: 'GameArchetype.sortingFactory',
      icon: '⚖️',
      descEn: 'Conquer challenges by choosing between countable/uncountable forms and irregular plurals.',
      descMl: 'എണ്ണാവുന്നതും എണ്ണാൻ കഴിയാത്തതുമായ നാമങ്ങളും ബഹുവചന രൂപങ്ങളും കണ്ടെത്തി ജയിക്കുക.',
      rounds: [
        {
          promptEn: 'Which noun is UNCOUNTABLE in standard English?',
          promptMl: 'സാധാരണയായി എണ്ണാൻ കഴിയാത്ത (Uncountable) നാമം ഏതാണ്?',
          options: ['Information', 'Book', 'Chair', 'Bottle'],
          solution: 0,
          explanationEn: '"Information" cannot be counted as "two informations"; we say "pieces of information".',
          explanationMl: 'ഇംഗ്ലീഷിൽ "Information" എണ്ണാൻ കഴിയില്ല (Uncountable ആണ്).',
          audio: 'Information is an uncountable noun.'
        },
        {
          promptEn: 'What is the correct plural form of "Child"?',
          promptMl: '"Child" എന്ന വാക്കിന്റെ ശരിയായ ബഹുവചനം ഏതാണ്?',
          options: ['Children', 'Childs', 'Childrens', 'Childes'],
          solution: 0,
          explanationEn: 'The irregular plural of "child" is "children".',
          explanationMl: 'Child എന്നതിന്റെ ബഹുവചനം Children ആണ്.',
          audio: 'The plural of child is children.'
        },
        {
          promptEn: 'Which quantifier matches the uncountable noun "Water"?',
          promptMl: '"Water" എന്ന അൺകൗണ്ടബിൾ നാമത്തിനൊപ്പം ഏതാണ് ഉപയോഗിക്കുക?',
          options: ['Much water', 'Many water', 'A few water', 'Several water'],
          solution: 0,
          explanationEn: 'Uncountable nouns use "much" or "a little", while countable nouns use "many".',
          explanationMl: 'എണ്ണാൻ കഴിയാത്ത നാമങ്ങൾക്കൊപ്പം "much" ഉപയോഗിക്കുന്നു.',
          audio: 'Use much with uncountable nouns like water.'
        },
        {
          promptEn: 'What is the plural of "Cactus"?',
          promptMl: '"Cactus" എന്ന വാക്കിന്റെ ബഹുവചനം ഏതാണ്?',
          options: ['Cacti (or Cactuses)', 'Cactis', 'Cactum', 'Cacta'],
          solution: 0,
          explanationEn: 'The Latin irregular plural of "cactus" is "cacti".',
          explanationMl: 'Cactus എന്നതിന്റെ ശരിയായ ബഹുവചനം Cacti ആണ്.',
          audio: 'The plural of cactus is cacti.'
        },
        {
          promptEn: 'Select the correctly matched sentence:',
          promptMl: 'ശരിയായ വാക്യം തിരഞ്ഞെടുക്കുക:',
          options: ['I need some advice.', 'I need an advice.', 'I need many advices.', 'I need three advices.'],
          solution: 0,
          explanationEn: '"Advice" is uncountable, so it cannot take "an" or "advices". We say "some advice".',
          explanationMl: 'Advice എന്നത് എണ്ണാൻ കഴിയില്ല, അതിനാൽ "some advice" എന്ന് പറയണം.',
          audio: 'Advice is uncountable, so we say some advice.'
        }
      ]
    }
  }
];

console.log('Day Manifest metadata loaded.');
