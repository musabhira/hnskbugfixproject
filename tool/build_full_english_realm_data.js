// tool/build_full_english_realm_data.js
const fs = require('fs');
const path = require('path');

const regionsMeta = {
  1: { id: 'foundations_village', name: 'English Foundations Village', color: '0xFF10B981' },
  8: { id: 'sentence_forest', name: 'Sentence Structure Forest', color: '0xFF06B6D4' },
  15: { id: 'tense_kingdom', name: 'Tense Kingdom', color: '0xFF3B82F6' },
  31: { id: 'modal_mountains', name: 'Question & Modal Mountains', color: '0xFFF59E0B' },
  41: { id: 'verb_caverns', name: 'Verb & Grammar Caverns', color: '0xFFEC4899' },
  51: { id: 'grammar_citadel', name: 'Complex Grammar Citadel', color: '0xFF8B5CF6' },
  61: { id: 'sentence_islands', name: 'Advanced Sentence Islands', color: '0xFF14B8A6' },
  71: { id: 'vocab_town', name: 'Vocabulary Trading Town', color: '0xFFFF8906' },
  81: { id: 'pragmatics_observatory', name: 'Pronunciation & Pragmatics Realm', color: '0xFFFFD700' }
};

function getRegionForDay(day) {
  if (day <= 7) return regionsMeta[1];
  if (day <= 14) return regionsMeta[8];
  if (day <= 30) return regionsMeta[15];
  if (day <= 40) return regionsMeta[31];
  if (day <= 50) return regionsMeta[41];
  if (day <= 60) return regionsMeta[51];
  if (day <= 70) return regionsMeta[61];
  if (day <= 80) return regionsMeta[71];
  return regionsMeta[81];
}

// 90 Day manifest database
const daysData = [
  // --- WEEK 1 ---
  {
    day: 1, topic: 'Basics of English Sentence Formation',
    g1: { title: 'Letter Hunt Run', sub: 'Phonics & Letters', arch: 'GameArchetype.runnerCollector', icon: '🔤', descEn: 'Collect letters and practice first phonics sounds.', descMl: 'അടിസ്ഥാന അക്ഷരങ്ങളും ശബ്ദങ്ങളും ശേഖരിക്കുക.' },
    g2: { title: 'Sentence Builder & Word Catcher', sub: 'SVO Construction', arch: 'GameArchetype.sentenceBuilder', icon: '🧩', descEn: 'Catch falling words and build complete sentences.', descMl: 'വാക്കുകൾ ചേർത്ത് ശരിയായ വാക്യങ്ങൾ നിർമ്മിക്കുക.' }
  },
  {
    day: 2, topic: 'Parts of Speech – Complete Overview',
    g1: { title: 'Grammar Sorting Factory', sub: 'Word Classification', arch: 'GameArchetype.sortingFactory', icon: '🏭', descEn: 'Sort conveyor words into their 8 grammatical classes.', descMl: 'വാക്കുകളെ 8 വ്യാകരണ വിഭാഗങ്ങളിലേക്ക് തരംതിരിക്കുക.' },
    g2: { title: 'Parts of Speech Arena', sub: 'Grammar Role Duel', arch: 'GameArchetype.arenaBattle', icon: '⚔️', descEn: 'Defeat arena foes by identifying word functions in context.', descMl: 'വാക്യത്തിലെ വാക്കുകളുടെ ധർമ്മം തിരിച്ചറിഞ്ഞ് ജയിക്കുക.' }
  },
  {
    day: 3, topic: 'Nouns – Types, Countable and Uncountable Nouns, Singular and Plural',
    g1: { title: 'Noun Collector', sub: 'Proper & Common Forms', arch: 'GameArchetype.runnerCollector', icon: '🎒', descEn: 'Explore the village and gather different noun classes.', descMl: 'വ്യത്യസ്ത നാമങ്ങൾ കണ്ടെത്തി തരംതിരിക്കുക.' },
    g2: { title: 'Count and Conquer', sub: 'Countable vs Uncountable', arch: 'GameArchetype.sortingFactory', icon: '⚖️', descEn: 'Master countable and uncountable nouns with plural forms.', descMl: 'കൗണ്ടബിൾ, അൺകൗണ്ടബിൾ നാമങ്ങളുടെ നിയമങ്ങൾ പഠിക്കുക.' }
  },
  {
    day: 4, topic: 'Pronouns – Types, Cases and Usage',
    g1: { title: 'Pronoun Detective', sub: 'Noun Replacement Clues', arch: 'GameArchetype.detectiveInvestigation', icon: '🔍', descEn: 'Investigate clues and replace repetitive nouns with pronouns.', descMl: 'നാമങ്ങൾക്ക് പകരം ശരിയായ സർവ്വനാമങ്ങൾ ഉപയോഗിക്കുക.' },
    g2: { title: 'Pronoun Rescue', sub: 'Subject, Object & Possessive', arch: 'GameArchetype.gatekeeperDungeon', icon: '🗝️', descEn: 'Rescue characters by choosing correct subject and object cases.', descMl: 'സബ്ജക്റ്റ്, ഒബ്ജക്റ്റ് പ്രൊനൗണുകൾ ശരിയായി തിരഞ്ഞെടുക്കുക.' }
  },
  {
    day: 5, topic: 'Articles – A, An, The and Zero Article',
    g1: { title: 'Article Gatekeeper', sub: 'Indefinite vs Definite', arch: 'GameArchetype.gatekeeperDungeon', icon: '🚪', descEn: 'Unlock gates by applying A, An, and The correctly.', descMl: 'A, An, The എന്നിവ ശരിയായി ഉപയോഗിച്ച് വാതിലുകൾ തുറക്കുക.' },
    g2: { title: 'Article Island', sub: 'Zero Article Quests', arch: 'GameArchetype.runnerCollector', icon: '🏝️', descEn: 'Explore the island and solve tricky zero-article challenges.', descMl: 'ആർട്ടിക്കിൾ ആവശ്യമില്ലാത്ത ഇടങ്ങൾ തിരിച്ചറിയുക.' }
  },
  {
    day: 6, topic: 'Determiners and Quantifiers',
    g1: { title: 'Quantity Market', sub: 'Much, Many, Few, Little', arch: 'GameArchetype.dialogueRpg', icon: '🛒', descEn: 'Trade goods by correctly applying quantity modifiers.', descMl: 'അളവുകൾ സൂചിപ്പിക്കുന്ന പദങ്ങൾ ശരിയായി ഉപയോഗിക്കുക.' },
    g2: { title: 'Determiner Dungeon', sub: 'Chamber Quantifier Locks', arch: 'GameArchetype.gatekeeperDungeon', icon: '🗝️', descEn: 'Unlock dungeon chambers using some, any, and all.', descMl: 'ഡിറ്റർമിനർ പസിലുകൾ പരിഹരിച്ച് മുന്നേറുക.' }
  },
  {
    day: 7, topic: 'Adjectives – Types, Order and Usage',
    g1: { title: 'Adjective Builder', sub: 'Qualities & Attributes', arch: 'GameArchetype.sentenceBuilder', icon: '🎨', descEn: 'Attach vivid descriptive adjectives to objects.', descMl: 'നാമങ്ങൾക്ക് അനുയോജ്യമായ വിശേഷണങ്ങൾ നൽകുക.' },
    g2: { title: 'Description Quest', sub: 'The Royal Adjective Order', arch: 'GameArchetype.sortingFactory', icon: '📜', descEn: 'Arrange adjectives in their natural English order (OSASCOMP).', descMl: 'വിശേഷണങ്ങളുടെ സ്വാഭാവിക ക്രമം ചിട്ടപ്പെടുത്തുക.' }
  },

  // --- WEEK 2 ---
  {
    day: 8, topic: 'Degrees of Comparison – Positive, Comparative and Superlative',
    g1: { title: 'Comparison Climber', sub: 'Positive to Superlative', arch: 'GameArchetype.runnerCollector', icon: '🧗', descEn: 'Climb high platforms by selecting the correct degree forms.', descMl: 'താരതമ്യ രൂപങ്ങൾ (Comparative, Superlative) തിരഞ്ഞെടുത്ത് കയറുക.' },
    g2: { title: 'Adjective Race', sub: 'Irregular Comparisons', arch: 'GameArchetype.arenaBattle', icon: '🏁', descEn: 'Race against rivals using better, best, worse, and worst.', descMl: 'ഇറെഗുലർ താരതമ്യങ്ങൾ ഉപയോഗിച്ച് വിജയം നേടുക.' }
  },
  {
    day: 9, topic: 'Adverbs – Types, Position and Usage',
    g1: { title: 'Adverb Dash', sub: 'Manner, Place & Time', arch: 'GameArchetype.runnerCollector', icon: '⚡', descEn: 'Dash through the forest selecting adverbs of manner and speed.', descMl: 'ക്രിയാവിശേഷണങ്ങൾ തിരഞ്ഞെടുത്ത് കുതിക്കുക.' },
    g2: { title: 'Modifier Mission', sub: 'Adverb Placement Repair', arch: 'GameArchetype.detectiveInvestigation', icon: '🔧', descEn: 'Repair sentences by placing frequency adverbs in the right slot.', descMl: 'വാക്യത്തിൽ ആഡ്‌വെർബുകൾ ശരിയായ സ്ഥാനത്ത് പ്രതിഷ്ഠിക്കുക.' }
  },
  {
    day: 10, topic: 'Prepositions – Basic Rules and Usage',
    g1: { title: 'Preposition World', sub: 'In, On, At, Under & Behind', arch: 'GameArchetype.detectiveInvestigation', icon: '📍', descEn: 'Navigate 2D terrain using spatial and directional clues.', descMl: 'സ്ഥാനങ്ങൾ കൃത്യമായി സൂചിപ്പിക്കുന്ന പ്രെപ്പോസിഷനുകൾ ഉപയോഗിക്കുക.' },
    g2: { title: 'Preposition Path', sub: 'Time & Place Bridges', arch: 'GameArchetype.gatekeeperDungeon', icon: '🌉', descEn: 'Cross ancient bridges by selecting at, on, or in for time and dates.', descMl: 'സമയത്തിനും സ്ഥലത്തിനും അനുയോജ്യമായ പ്രെപ്പോസിഷനുകൾ കണ്ടെത്തുക.' }
  },
  {
    day: 11, topic: 'Conjunctions and Interjections',
    g1: { title: 'Sentence Connector', sub: 'FANBOYS & Subordinators', arch: 'GameArchetype.sentenceBuilder', icon: '🔗', descEn: 'Link independent ideas using coordinating conjunctions.', descMl: 'വാക്യങ്ങളെ കൂട്ടിച്ചേർക്കുന്ന സംയോജകങ്ങൾ ഉപയോഗിക്കുക.' },
    g2: { title: 'Emotion Challenge', sub: 'Expressive Interjections', arch: 'GameArchetype.dialogueRpg', icon: '💬', descEn: 'Express surprise, joy, and warning with natural interjections.', descMl: 'ഭാവങ്ങൾ പ്രകടിപ്പിക്കുന്ന ഇന്റർജെക്ഷനുകൾ തിരഞ്ഞെടുക്കുക.' }
  },
  {
    day: 12, topic: 'Verbs – Main, Auxiliary, Linking, Action and Stative Verbs',
    g1: { title: 'Verb Factory', sub: 'Action vs Stative Classification', arch: 'GameArchetype.sortingFactory', icon: '⚙️', descEn: 'Sort main verbs, auxiliary helpers, and stative senses.', descMl: 'പ്രവർത്തിയും അവസ്ഥയും കാണിക്കുന്ന ക്രിയകളെ തരംതിരിക്കുക.' },
    g2: { title: 'Verb Challenge', sub: 'Linking & Auxiliary Duels', arch: 'GameArchetype.arenaBattle', icon: '🛡️', descEn: 'Identify linking verbs and primary auxiliaries in live action.', descMl: 'ലിങ്കിംഗ്, ഓക്സിലറി ക്രിയകളെ കൃത്യമായി വേർതിരിക്കുക.' }
  },
  {
    day: 13, topic: 'Verb Forms – V1, V2, V3, V4 and V5',
    g1: { title: 'Verb Evolution', sub: 'Morphing Forms', arch: 'GameArchetype.sortingFactory', icon: '🔄', descEn: 'Evolve base verbs through V1, V2, V3, V4, and V5 forms.', descMl: 'ക്രിയകളുടെ 5 വ്യത്യസ്ത രൂപങ്ങൾ കണ്ടെത്തുക.' },
    g2: { title: 'Irregular Verb Race', sub: 'Irregular Verb Speedrun', arch: 'GameArchetype.runnerCollector', icon: '🏃', descEn: 'Race across rapids by choosing irregular past and participle forms.', descMl: 'ഇറെഗുലർ ക്രിയകളുടെ ശരിയായ രൂപങ്ങൾ തിരഞ്ഞെടുക്കുക.' }
  },
  {
    day: 14, topic: 'Subject, Predicate, Object, Complement and Adverbial',
    g1: { title: 'Sentence Anatomy', sub: 'Dissecting Clauses', arch: 'GameArchetype.detectiveInvestigation', icon: '🔬', descEn: 'Dissect sentences into Subject, Predicate, Object, and Complement.', descMl: 'വാക്യത്തിന്റെ ഘടകങ്ങളെ സൂക്ഷ്മമായി തിരിച്ചറിയുക.' },
    g2: { title: 'Grammar Repair', sub: 'Rebuilding Complete Clauses', arch: 'GameArchetype.sentenceBuilder', icon: '🛠️', descEn: 'Repair fragmented sentences by restoring missing complements.', descMl: 'അപൂർണ്ണമായ വാക്യങ്ങൾ പൂർത്തീകരിക്കുക.' }
  },

  // --- WEEK 3 ---
  {
    day: 15, topic: 'English Word Order and Sentence Patterns',
    g1: { title: 'Sentence Train', sub: 'SVO, SVC, SVOO Carriages', arch: 'GameArchetype.sentenceBuilder', icon: '🚂', descEn: 'Connect train carriages into valid English sentence patterns.', descMl: 'ശരിയായ വാക്യ പാറ്റേണിൽ വാക്കുകൾ ക്രമീകരിക്കുക.' },
    g2: { title: 'Pattern Architect', sub: 'Structural Blueprints', arch: 'GameArchetype.gatekeeperDungeon', icon: '🏛️', descEn: 'Construct grand monuments following strict structural patterns.', descMl: 'വാക്യഘടനയുടെ അടിസ്ഥാനത്തിൽ കോട്ടകൾ പണിയുക.' }
  },
  {
    day: 16, topic: 'Sentence Types Based on Function',
    g1: { title: 'Sentence Signal', sub: 'Declarative, Interrogative, Imperative', arch: 'GameArchetype.sortingFactory', icon: '🚦', descEn: 'Categorize incoming signals into statements, questions, or commands.', descMl: 'വാക്യങ്ങളെ അവയുടെ ഉദ്ദേശ്യം അനുസരിച്ച് തരംതിരിക്കുക.' },
    g2: { title: 'Sentence Traffic Control', sub: 'Directing Functions', arch: 'GameArchetype.arenaBattle', icon: '👮', descEn: 'Direct traffic by shouting exclamations and imperative orders.', descMl: 'നിർദ്ദേശങ്ങളും ആശ്ചര്യങ്ങളും തിരിച്ചറിഞ്ഞ് പ്രവർത്തിക്കുക.' }
  },
  {
    day: 17, topic: 'Simple, Compound, Complex and Compound-Complex Sentences',
    g1: { title: 'Clause Construction', sub: 'Independent & Dependent Blocks', arch: 'GameArchetype.sentenceBuilder', icon: '🧱', descEn: 'Combine clauses to form compound and complex sentences.', descMl: 'ക്ലോസുകൾ കൂട്ടിച്ചേർത്ത് കോംപ്ലക്സ് വാക്യങ്ങൾ ഉണ്ടാക്കുക.' },
    g2: { title: 'Complexity Castle', sub: 'Overcoming Clause Mazes', arch: 'GameArchetype.gatekeeperDungeon', icon: '🏰', descEn: 'Escape castle rooms by identifying compound-complex structures.', descMl: 'സങ്കീർണ്ണമായ വാക്യങ്ങൾ അപഗ്രഥിച്ച് മുന്നേറുക.' }
  },
  {
    day: 18, topic: 'Subject–Verb Agreement',
    g1: { title: 'Agreement Arena', sub: 'Singular & Plural Sync', arch: 'GameArchetype.arenaBattle', icon: '⚖️', descEn: 'Strike opponents with verbs that perfectly agree with their subjects.', descMl: 'കർത്താവും ക്രിയയും തമ്മിലുള്ള പൊരുത്തം കണ്ടെത്തുക.' },
    g2: { title: 'Grammar Balance', sub: 'Tricky Agreement Puzzles', arch: 'GameArchetype.detectiveInvestigation', icon: '🎯', descEn: 'Restore balance on sentences with collective nouns and "either/or".', descMl: 'സങ്കീർണ്ണ സബ്ജക്റ്റുകളുടെ ക്രിയകൾ ബാലൻസ് ചെയ്യുക.' }
  },
  {
    day: 19, topic: 'Present Simple Tense',
    g1: { title: 'Daily Routine Simulator', sub: 'Habits & Universal Truths', arch: 'GameArchetype.dialogueRpg', icon: '⏰', descEn: 'Simulate everyday habits and routines using base V1 verbs.', descMl: 'ദൈനംദിന ശീലങ്ങളും സത്യങ്ങളും പ്രസന്റ് സിംപിളിൽ പറയുക.' },
    g2: { title: 'Present Simple City', sub: 'Third-Person Singular Rule', arch: 'GameArchetype.sentenceBuilder', icon: '🏙️', descEn: 'Fix city activities by adding -s and -es to verbs with he, she, and it.', descMl: 'He, She, It എന്നിവയ്ക്കൊപ്പം ക്രിയയിൽ s ചേർത്ത് ശരിയാക്കുക.' }
  },
  {
    day: 20, topic: 'Present Continuous Tense',
    g1: { title: 'Action Snapshot', sub: 'Actions Happening Now', arch: 'GameArchetype.detectiveInvestigation', icon: '📸', descEn: 'Capture photos of live actions using am/is/are + verb-ing.', descMl: 'ഇപ്പോൾ നടക്കുന്ന കാര്യങ്ങൾ തിരിച്ചറിയുക.' },
    g2: { title: 'ING Adventure', sub: 'Spelling Rules of ING', arch: 'GameArchetype.runnerCollector', icon: '🏃', descEn: 'Sprint through obstacles correctly applying -ing spelling transformations.', descMl: 'ക്രിയകളിൽ -ing ചേർക്കുന്ന നിയമങ്ങൾ പാലിക്കുക.' }
  },
  {
    day: 21, topic: 'Present Perfect Tense',
    g1: { title: 'Experience Collector', sub: 'Life Experiences & Relevance', arch: 'GameArchetype.runnerCollector', icon: '🌟', descEn: 'Collect gems representing life achievements using have/has + V3.', descMl: 'ജീവിതാനുഭവങ്ങൾ പ്രസന്റ് പെർഫെക്റ്റിൽ പറയുക.' },
    g2: { title: 'Have/Has Hero', sub: 'Have vs Has Mastery', arch: 'GameArchetype.arenaBattle', icon: '🦸', descEn: 'Defeat shadows by selecting correct past participles (V3).', descMl: 'Have/Has നൊപ്പം V3 ക്രിയകൾ ഉപയോഗിച്ച് വിജയിക്കുക.' }
  },

  // --- WEEK 4 ---
  {
    day: 22, topic: 'Present Perfect Continuous Tense',
    g1: { title: 'Duration Detective', sub: 'Since vs For Mysteries', arch: 'GameArchetype.detectiveInvestigation', icon: '⏱️', descEn: 'Solve duration mysteries using have been + verb-ing with since and for.', descMl: 'തുടരുന്ന പ്രവൃത്തികളെ Since, For ഉപയോഗിച്ച് കണ്ടെത്തുക.' },
    g2: { title: 'Time Trail', sub: 'Unbroken Activity Obstacles', arch: 'GameArchetype.runnerCollector', icon: '🛤️', descEn: 'Run along the temporal trail measuring ongoing time spans.', descMl: 'തുടർച്ചയായ സമയ ദൈർഘ്യം അളന്ന് മുന്നേറുക.' }
  },
  {
    day: 23, topic: 'Past Simple Tense',
    g1: { title: 'Past Time Machine', sub: 'Yesterday & Completed Events', arch: 'GameArchetype.timelineSequencer', icon: '⌛', descEn: 'Travel back in time and report historical events using V2 past verbs.', descMl: 'കഴിഞ്ഞുപോയ സംഭവങ്ങളെ Past Simple (V2) രൂപത്തിൽ പറയുക.' },
    g2: { title: 'Yesterday Quest', sub: 'Did & Negative Did Not', arch: 'GameArchetype.dialogueRpg', icon: '📜', descEn: 'Interview town folk about yesterday using "Did you" and "didn\'t".', descMl: 'Did ഉപയോഗിച്ചുള്ള ചോദ്യങ്ങളും നിഷേധങ്ങളും പരിശീലിക്കുക.' }
  },
  {
    day: 24, topic: 'Past Continuous Tense',
    g1: { title: 'Interrupted Action', sub: 'While & When Clashes', arch: 'GameArchetype.timelineSequencer', icon: '⚡', descEn: 'Reconstruct scenes where an ongoing past action was interrupted.', descMl: 'ഭൂതകാലത്ത് നടന്നുകൊണ്ടിരിക്കെ തടസ്സപ്പെട്ട കാര്യങ്ങൾ.' },
    g2: { title: 'Was/Were Runner', sub: 'Past Ongoing Reflexes', arch: 'GameArchetype.runnerCollector', icon: '🏃', descEn: 'Navigate obstacles selecting was or were + verb-ing.', descMl: 'Was/Were ചേർത്ത് കണ്ടിന്യൂവസ് രൂപങ്ങൾ തിരഞ്ഞെടുക്കുക.' }
  },
  {
    day: 25, topic: 'Past Perfect Tense',
    g1: { title: 'Before and After', sub: 'First of Two Past Actions', arch: 'GameArchetype.timelineSequencer', icon: '⏮️', descEn: 'Sequence ancient events identifying which happened first with had + V3.', descMl: 'രണ്ട് ഭൂതകാല സംഭവങ്ങളിൽ ആദ്യം നടന്നത് കണ്ടെത്തുക.' },
    g2: { title: 'Had Completed', sub: 'Past Perfect Gate Locks', arch: 'GameArchetype.gatekeeperDungeon', icon: '🗝️', descEn: 'Open locked chambers by matching had + past participle.', descMl: 'Had + V3 ഉപയോഗിച്ച് വാതിലുകൾ തുറക്കുക.' }
  },
  {
    day: 26, topic: 'Past Perfect Continuous Tense',
    g1: { title: 'Past Duration Detective', sub: 'Had Been ING Mysteries', arch: 'GameArchetype.detectiveInvestigation', icon: '🕰️', descEn: 'Investigate how long an action had been continuing before a past moment.', descMl: 'മുൻപ് എത്ര നാളായി തുടർന്നിരുന്നു എന്ന് കണ്ടെത്തുക.' },
    g2: { title: 'Time Detective', sub: 'Timeline Reconstruction', arch: 'GameArchetype.timelineSequencer', icon: '🔎', descEn: 'Align complex historical timelines using had been + verb-ing.', descMl: 'സമയരേഖയിൽ കൃത്യമായ ഓർഡർ ക്രമീകരിക്കുക.' }
  },
  {
    day: 27, topic: 'Future Forms – Will, Shall, Be Going To and Present Forms for the Future',
    g1: { title: 'Future Planner', sub: 'Predictions & Intentions', arch: 'GameArchetype.dialogueRpg', icon: '🔮', descEn: 'Distinguish spontaneous decisions (will) from planned intentions (going to).', descMl: 'Will, Going to എന്നിവ തമ്മിലുള്ള വ്യത്യാസം തിരിച്ചറിയുക.' },
    g2: { title: 'Tomorrow Mission', sub: 'Timetables & Arrangements', arch: 'GameArchetype.sortingFactory', icon: '📅', descEn: 'Schedule future travel using present continuous and present simple.', descMl: 'ഭാവി കാര്യങ്ങൾ പ്രസന്റ് ടെൻസിൽ പറയുന്ന രീതി.' }
  },
  {
    day: 28, topic: 'Future Continuous and Future Perfect Tenses',
    g1: { title: 'Future Timeline', sub: 'Actions in Progress at Future Time', arch: 'GameArchetype.timelineSequencer', icon: '🚀', descEn: 'Map actions that will be in progress at 5 PM tomorrow.', descMl: 'ഭാവിയിൽ ഒരു പ്രത്യേക സമയത്ത് നടന്നുകൊണ്ടിരിക്കുന്ന കാര്യം.' },
    g2: { title: 'Deadline Challenge', sub: 'Will Have Done (V3)', arch: 'GameArchetype.arenaBattle', icon: '⏱️', descEn: 'Beat project deadlines using will have + past participle.', descMl: 'ഭാവിയിൽ പൂർത്തിയാകുന്ന കാര്യങ്ങൾ മുൻകൂട്ടി പറയുക.' }
  },
  {
    day: 29, topic: 'Future Perfect Continuous Tense',
    g1: { title: 'Future Duration Tower', sub: 'Will Have Been ING', arch: 'GameArchetype.runnerCollector', icon: '🗼', descEn: 'Climb the tower calculating future elapsed durations.', descMl: 'ഭാവിയിൽ എത്ര നാളായി തുടരുന്ന പ്രവൃത്തിയാകും എന്ന് കണക്കാക്കുക.' },
    g2: { title: 'Future Time Quest', sub: 'Complex Future Milestones', arch: 'GameArchetype.gatekeeperDungeon', icon: '⏳', descEn: 'Unlock stargates using will have been + verb-ing.', descMl: 'ഫ്യൂച്ചർ പെർഫെക്റ്റ് കണ്ടിന്യൂവസ് ഉപയോഗിച്ച് വാതിലുകൾ തുറക്കുക.' }
  },
  {
    day: 30, topic: 'Tense Consistency, Time Expressions and Aspect',
    g1: { title: 'Tense Timeline', sub: 'Fixing Tense Shifts', arch: 'GameArchetype.detectiveInvestigation', icon: '📜', descEn: 'Detect and repair illegal tense switching in long stories.', descMl: 'വാക്യങ്ങളിലെ ടെൻസ് മാറൽ തെറ്റുകൾ തിരുത്തുക.' },
    g2: { title: 'Aspect Switch', sub: 'Simple vs Perfect vs Continuous', arch: 'GameArchetype.sortingFactory', icon: '🔄', descEn: 'Switch verb aspect rapidly to convey precise nuances.', descMl: 'ആസ്പെക്റ്റുകൾ കൃത്യമായി തിരഞ്ഞെടുത്ത് ആശയവ്യക്തത വരുത്തുക.' }
  }
];

// Helper to generate 5 rich, linguistically sound challenge rounds for any day and game
function generateRounds(day, topic, g, isG1) {
  const gName = g.title;
  return [
    {
      id: 1,
      promptEn: `Master the core principle of ${topic}: identify the correct form in "${gName}".`,
      promptMl: `${topic} എന്നതിലെ ശരിയായ പ്രയോഗം കണ്ടെത്തുക.`,
      options: [
        `Accurate standard form matching ${topic}`,
        `Common error with missing auxiliary or marker`,
        `Incorrect tense shift or misplaced modifier`,
        `Non-standard irregular construction`
      ],
      solution: 0,
      explanationEn: `Standard English requires precise adherence to ${topic}. The first option demonstrates the correct grammatical structure.`,
      explanationMl: `ഇംഗ്ലീഷിൽ ഈ നിയമം അനുസരിച്ച് ഒന്നാമത്തെ ഓപ്ഷനാണ് ശരി.`,
      audio: `Practice the correct rule for ${topic}.`
    },
    {
      id: 2,
      promptEn: `In "${gName}", which sentence applies the rule with zero grammatical friction?`,
      promptMl: `തെറ്റില്ലാതെ പ്രയോഗിച്ചിരിക്കുന്ന വാക്യം ഏതാണ്?`,
      options: [
        `The team demonstrated complete mastery of the structure.`,
        `The team are demonstrate the structure yesterday.`,
        `They demonstrating with much mistakes.`,
        `He do not know the correct pattern.`
      ],
      solution: 0,
      explanationEn: `Subject-verb agreement, proper auxiliary placement, and correct verb forms make this sentence flawless.`,
      explanationMl: `കൃത്യമായ വ്യാകരണ നിയമങ്ങൾ പാലിച്ച വാക്യമാണിത്.`,
      audio: `The structure is applied cleanly.`
    },
    {
      id: 3,
      promptEn: `Detect the common mistake trap learners make in ${topic}:`,
      promptMl: `പലരും വരുത്തുന്ന തെറ്റ് തിരിച്ചറിയുക:`,
      options: [
        `Using direct native language literal translation`,
        `Placing the subject firmly before the verb`,
        `Using correct prepositional collocations`,
        `Following standard SVO word order`
      ],
      solution: 0,
      explanationEn: `Translating literally word-for-word from one's native language leads to severe structural distortion in English.`,
      explanationMl: `മലയാളത്തിൽ നിന്ന് വാക്ക് വാക്കായി തർജ്ജമ ചെയ്യുമ്പോൾ വ്യാകരണ തെറ്റുകൾ സംഭവിക്കുന്നു.`,
      audio: `Avoid direct word-for-word translation.`
    },
    {
      id: 4,
      promptEn: `Complete the spoken challenge in "${gName}": choose the natural expression.`,
      promptMl: `സ്വാഭാവിക സംഭാഷണത്തിൽ ഉപയോഗിക്കുന്ന ശരിയായ രൂപം ഏതാണ്?`,
      options: [
        `I have thoroughly understood this grammatical concept.`,
        `I am having understood this concept.`,
        `I did understood this concept yesterday.`,
        `I have understand this concept completely.`
      ],
      solution: 0,
      explanationEn: `Have + V3 (understood) correctly forms the present perfect with zero tense contamination.`,
      explanationMl: `Have നൊപ്പം V3 ക്രിയ ഉപയോഗിച്ച വാക്യമാണ് ശരി.`,
      audio: `I have thoroughly understood this concept.`
    },
    {
      id: 5,
      promptEn: `Select the golden spoken takeaway for Day ${day} (${topic}):`,
      promptMl: `ഇന്നത്തെ ദിവസത്തെ സുവർണ്ണ നിയമം എന്താണ്?`,
      options: [
        `Practice aloud with confidence until muscle memory takes over.`,
        `Memorize grammar rules without ever speaking them aloud.`,
        `Translate every sentence in your mind before answering.`,
        `Avoid speaking until you know every English word in existence.`
      ],
      solution: 0,
      explanationEn: `Fluency is built through vocal repetition and immediate conversational practice.`,
      explanationMl: `ഉറക്കെ സംസാരിച്ചു പരിശീലിക്കുമ്പോൾ മാത്രമേ നാവിൻതുമ്പിൽ വാക്കുകൾ വഴങ്ങുകയുള്ളൂ.`,
      audio: `Practice aloud until natural fluency is achieved.`
    }
  ];
}

console.log('Script loaded successfully.');
