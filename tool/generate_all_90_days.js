// tool/generate_all_90_days.js
const fs = require('fs');
const path = require('path');

// Complete 90-Day manifest from user prompt
const manifest = [
  // WEEK 1
  [1, 'Basics of English Sentence Formation', 'Letter Hunt Run', 'GameArchetype.runnerCollector', 'Sentence Builder & Word Catcher', 'GameArchetype.sentenceBuilder', 'Phonics & Basic SVO', 'Word Catching & Sentence Construction'],
  [2, 'Parts of Speech – Complete Overview', 'Grammar Sorting Factory', 'GameArchetype.sortingFactory', 'Parts of Speech Arena', 'GameArchetype.arenaBattle', 'Word Classification into 8 Classes', 'Identifying Grammatical Roles'],
  [3, 'Nouns – Types, Countable and Uncountable Nouns, Singular and Plural', 'Noun Collector', 'GameArchetype.runnerCollector', 'Count and Conquer', 'GameArchetype.sortingFactory', 'Collecting Noun Types', 'Countable & Uncountable Plurals'],
  [4, 'Pronouns – Types, Cases and Usage', 'Pronoun Detective', 'GameArchetype.detectiveInvestigation', 'Pronoun Rescue', 'GameArchetype.gatekeeperDungeon', 'Replacing Nouns with Pronouns', 'Subject, Object & Possessive Cases'],
  [5, 'Articles – A, An, The and Zero Article', 'Article Gatekeeper', 'GameArchetype.gatekeeperDungeon', 'Article Island', 'GameArchetype.runnerCollector', 'Unlocking Doors with A, An, The', 'Zero-Article Challenges'],
  [6, 'Determiners and Quantifiers', 'Quantity Market', 'GameArchetype.dialogueRpg', 'Determiner Dungeon', 'GameArchetype.gatekeeperDungeon', 'Using Some, Any, Much, Many', 'Chamber Quantifier Locks'],
  [7, 'Adjectives – Types, Order and Usage', 'Adjective Builder', 'GameArchetype.sentenceBuilder', 'Description Quest', 'GameArchetype.sortingFactory', 'Combining Adjectives with Nouns', 'Royal Adjective Order OSASCOMP'],

  // WEEK 2
  [8, 'Degrees of Comparison – Positive, Comparative and Superlative', 'Comparison Climber', 'GameArchetype.runnerCollector', 'Adjective Race', 'GameArchetype.arenaBattle', 'Positive, Comparative & Superlative', 'Irregular Comparison Speedrun'],
  [9, 'Adverbs – Types, Position and Usage', 'Adverb Dash', 'GameArchetype.runnerCollector', 'Modifier Mission', 'GameArchetype.detectiveInvestigation', 'Manner, Place & Time Adverbs', 'Repairing Adverb Positions'],
  [10, 'Prepositions – Basic Rules and Usage', 'Preposition World', 'GameArchetype.detectiveInvestigation', 'Preposition Path', 'GameArchetype.gatekeeperDungeon', 'Spatial In, On, Under, Between', 'Context-Based Preposition Locks'],
  [11, 'Conjunctions and Interjections', 'Sentence Connector', 'GameArchetype.sentenceBuilder', 'Emotion Challenge', 'GameArchetype.dialogueRpg', 'Connecting Clauses with FANBOYS', 'Expressive Interjections'],
  [12, 'Verbs – Main, Auxiliary, Linking, Action and Stative Verbs', 'Verb Factory', 'GameArchetype.sortingFactory', 'Verb Challenge', 'GameArchetype.arenaBattle', 'Classifying Main, Action & Stative', 'Auxiliary & Linking Missions'],
  [13, 'Verb Forms – V1, V2, V3, V4 and V5', 'Verb Evolution', 'GameArchetype.sortingFactory', 'Irregular Verb Race', 'GameArchetype.runnerCollector', 'Transforming V1, V2, V3, V4, V5', 'Irregular Verb Sequences'],
  [14, 'Subject, Predicate, Object, Complement and Adverbial', 'Sentence Anatomy', 'GameArchetype.detectiveInvestigation', 'Grammar Repair', 'GameArchetype.sentenceBuilder', 'Identifying S, P, O, C, and A', 'Placing Elements in Grammatical Roles'],

  // WEEK 3
  [15, 'English Word Order and Sentence Patterns', 'Sentence Train', 'GameArchetype.sentenceBuilder', 'Pattern Architect', 'GameArchetype.gatekeeperDungeon', 'Arranging Word Blocks into Patterns', 'Constructing SVO, SVI, SVOC Blueprints'],
  [16, 'Sentence Types Based on Function', 'Sentence Signal', 'GameArchetype.sortingFactory', 'Sentence Traffic Control', 'GameArchetype.arenaBattle', 'Classifying Statements, Questions & Commands', 'Directing Sentences to Destinations'],
  [17, 'Simple, Compound, Complex and Compound-Complex Sentences', 'Clause Construction', 'GameArchetype.sentenceBuilder', 'Complexity Castle', 'GameArchetype.gatekeeperDungeon', 'Combining Clause Blocks', 'Overcoming Clause Mazes'],
  [18, 'Subject–Verb Agreement', 'Agreement Arena', 'GameArchetype.arenaBattle', 'Grammar Balance', 'GameArchetype.detectiveInvestigation', 'Defeating Foes with Agreeing Verbs', 'Restoring Subject-Verb Balance'],
  [19, 'Present Simple Tense', 'Daily Routine Simulator', 'GameArchetype.dialogueRpg', 'Present Simple City', 'GameArchetype.sentenceBuilder', 'Habits and Facts with Base Verbs', 'Third-Person Singular S/ES Rule'],
  [20, 'Present Continuous Tense', 'Action Snapshot', 'GameArchetype.detectiveInvestigation', 'ING Adventure', 'GameArchetype.runnerCollector', 'Actions Happening Now', 'Am/Is/Are + Verb-ING Formations'],
  [21, 'Present Perfect Tense', 'Experience Collector', 'GameArchetype.runnerCollector', 'Have/Has Hero', 'GameArchetype.arenaBattle', 'Past Actions with Present Relevance', 'Completing Missions with Have/Has + V3'],

  // WEEK 4
  [22, 'Present Perfect Continuous Tense', 'Duration Detective', 'GameArchetype.detectiveInvestigation', 'Time Trail', 'GameArchetype.runnerCollector', 'Duration Mysteries with Since and For', 'Obstacle Course with Have/Has Been ING'],
  [23, 'Past Simple Tense', 'Past Time Machine', 'GameArchetype.timelineSequencer', 'Yesterday Quest', 'GameArchetype.dialogueRpg', 'Traveling to Past Events with V2 Verbs', 'Event Clues with Did and Regular/Irregular Verbs'],
  [24, 'Past Continuous Tense', 'Interrupted Action', 'GameArchetype.timelineSequencer', 'Was/Were Runner', 'GameArchetype.runnerCollector', 'Ongoing and Interrupting Past Actions', 'Overcoming Obstacles with Was/Were ING'],
  [25, 'Past Perfect Tense', 'Before and After', 'GameArchetype.timelineSequencer', 'Had Completed', 'GameArchetype.gatekeeperDungeon', 'Sequencing First Past Actions', 'Unlocking Missions with Had + V3'],
  [26, 'Past Perfect Continuous Tense', 'Past Duration Detective', 'GameArchetype.detectiveInvestigation', 'Time Detective', 'GameArchetype.timelineSequencer', 'Duration Before a Past Event', 'Timeline Missions with Had Been ING'],
  [27, 'Future Forms – Will, Shall, Be Going To and Present Forms for the Future', 'Future Planner', 'GameArchetype.dialogueRpg', 'Tomorrow Mission', 'GameArchetype.sortingFactory', 'Predictions, Intentions & Arrangements', 'Missions with Will, Going to, Present Forms'],
  [28, 'Future Continuous and Future Perfect Tenses', 'Future Timeline', 'GameArchetype.timelineSequencer', 'Deadline Challenge', 'GameArchetype.arenaBattle', 'Actions in Progress at Future Times', 'Completion Before Deadlines with Will Have V3'],
  [29, 'Future Perfect Continuous Tense', 'Future Duration Tower', 'GameArchetype.runnerCollector', 'Future Time Quest', 'GameArchetype.gatekeeperDungeon', 'Duration Problems up to Future Reference', 'Timeline Puzzles with Will Have Been ING'],
  [30, 'Tense Consistency, Time Expressions and Aspect', 'Tense Timeline', 'GameArchetype.detectiveInvestigation', 'Aspect Switch', 'GameArchetype.sortingFactory', 'Repairing Inconsistent Tense Sequences', 'Distinguishing Simple, Perfect, Continuous Aspects'],

  // WEEK 5
  [31, 'Stative Verbs vs Dynamic Verbs', 'Verb Nature Lab', 'GameArchetype.sortingFactory', 'Meaning Switch', 'GameArchetype.detectiveInvestigation', 'Classifying Stative and Dynamic Verbs', 'Interpreting Contextual Shift Verbs'],
  [32, 'Auxiliary Verbs – Be, Do and Have', 'Auxiliary Workshop', 'GameArchetype.sentenceBuilder', 'Helper Challenge', 'GameArchetype.arenaBattle', 'Using Be, Do, and Have to Repair Sentences', 'Unlocking Question Structures with Auxiliaries'],
  [33, 'Negative Sentences and Contractions', 'Negative Zone', 'GameArchetype.sortingFactory', 'Contraction Challenge', 'GameArchetype.runnerCollector', 'Transforming into Correct Negative Forms', 'Identifying Contractions and Full Forms'],
  [34, 'Yes/No Questions and Question Formation', 'Question Builder', 'GameArchetype.sentenceBuilder', 'Answer Gate', 'GameArchetype.gatekeeperDungeon', 'Constructing Questions with Inversion', 'Matching Questions with Short Answers'],
  [35, 'WH-Questions – Who, What, When, Where, Why, Which, Whose, Whom and How', 'WH-Question Detective', 'GameArchetype.detectiveInvestigation', 'Mystery Question Maze', 'GameArchetype.gatekeeperDungeon', 'Investigating Missing Info with WH-Words', 'Question Formation Puzzles with 9 WH-Words'],
  [36, 'Question Tags and Short Answers', 'Tag Tail Challenge', 'GameArchetype.arenaBattle', 'Quick Answer Arena', 'GameArchetype.dialogueRpg', 'Completing Sentences with Question Tags', 'Producing Auxiliary-Based Short Answers'],
  [37, 'Indirect Questions and Embedded Questions', 'Polite Question Café', 'GameArchetype.dialogueRpg', 'Embedded Question Escape', 'GameArchetype.gatekeeperDungeon', 'Converting Direct Questions into Indirect', 'Correcting Embedded Word Order in Puzzles'],
  [38, 'Imperatives, Instructions, Suggestions and Commands', 'Mission Commander', 'GameArchetype.arenaBattle', 'Instruction Builder', 'GameArchetype.sentenceBuilder', 'Carrying Out Commands and Instructions', 'Constructing Imperatives, Requests & Suggestions'],
  [39, 'Modal Verbs – Can, Could, May and Might', 'Modal Power-Up', 'GameArchetype.runnerCollector', 'Possibility Portal', 'GameArchetype.gatekeeperDungeon', 'Distinguishing Ability, Permission, Possibility', 'Choosing Modals from Contextual Clues'],
  [40, 'Modal Verbs – Must, Have To, Need To, Should, Ought To and Had Better', 'Obligation Tower', 'GameArchetype.runnerCollector', 'Decision Dungeon', 'GameArchetype.gatekeeperDungeon', 'Distinguishing Advice, Necessity, Obligation', 'Situational Modal Decision Puzzles'],

  // WEEK 6
  [41, 'Modal Verbs for Probability, Possibility and Deduction', 'Evidence Detective', 'GameArchetype.detectiveInvestigation', 'Deduction Challenge', 'GameArchetype.arenaBattle', 'Investigating Evidence with Modal Deductions', 'Mysteries Involving Possibility and Certainty'],
  [42, 'Past Modals – Should Have, Could Have, Would Have, Might Have and Must Have', 'Past Possibility Machine', 'GameArchetype.timelineSequencer', 'Regret Repair Shop', 'GameArchetype.dialogueRpg', 'Solving Past Scenarios with Past Modals', 'Examining Past Decisions with Should/Could Have'],
  [43, 'Gerunds – Verbs Ending in -ing Used as Nouns', 'ING Collector', 'GameArchetype.runnerCollector', 'Gerund Garden', 'GameArchetype.sentenceBuilder', 'Finding Words Functioning as Gerunds', 'Sentence Missions Using Gerunds as Subjects/Objects'],
  [44, 'Infinitives – To-Infinitives and Bare Infinitives', 'Infinitive Launcher', 'GameArchetype.runnerCollector', 'Infinitive Portal', 'GameArchetype.gatekeeperDungeon', 'Distinguishing To-Infinitives from Bare Infinitives', 'Verb Pattern Challenges with Infinitives'],
  [45, 'Gerunds vs Infinitives – Rules and Verb Patterns', 'Verb Choice Lab', 'GameArchetype.sortingFactory', 'Meaning Switch Puzzle', 'GameArchetype.detectiveInvestigation', 'Identifying Gerund vs Infinitive Requirements', 'Verbs Changing Meaning with Gerund/Infinitive'],
  [46, 'Participles – Present, Past and Perfect Participles', 'Participle Workshop', 'GameArchetype.sortingFactory', 'Modifier Builder', 'GameArchetype.sentenceBuilder', 'Classifying Present, Past, Perfect Participles', 'Constructing Sentences with Participle Modifiers'],
  [47, 'Transitive, Intransitive, Ditransitive and Complex Verbs', 'Verb Object Detective', 'GameArchetype.detectiveInvestigation', 'Object Delivery', 'GameArchetype.runnerCollector', 'Identifying Transitive vs Intransitive Verbs', 'Delivering Elements to Direct & Indirect Positions'],
  [48, 'Verb Patterns – Verb + Object, Verb + To-Infinitive and Verb + -ing', 'Pattern Factory', 'GameArchetype.sortingFactory', 'Verb Pattern Puzzle', 'GameArchetype.sentenceBuilder', 'Practicing Verb + Object + To-Infinitive Patterns', 'Repairing Incomplete Verb Constructions'],
  [49, 'Phrasal Verbs – Types, Meanings and Usage', 'Phrasal Verb Quest', 'GameArchetype.detectiveInvestigation', 'Particle Challenge', 'GameArchetype.runnerCollector', 'Discovering Phrasal Meanings in Adventure', 'Solving Puzzles Involving Verbs & Particles'],
  [50, 'Prepositional Verbs and Dependent Prepositions', 'Preposition Partner', 'GameArchetype.sortingFactory', 'Expression Lock', 'GameArchetype.gatekeeperDungeon', 'Matching Verbs with Required Prepositions', 'Opening Doors with Fixed Preposition Combos'],

  // WEEK 7
  [51, 'Active Voice and Passive Voice – All Major Tenses', 'Voice Transformer', 'GameArchetype.sentenceBuilder', 'Passive Factory', 'GameArchetype.sortingFactory', 'Converting Active Sentences into Passive', 'Completing Passive Across All Major Tenses'],
  [52, 'Causative Structures – Have, Get, Make, Let and Help', 'Action Director', 'GameArchetype.dialogueRpg', 'Causative Control Room', 'GameArchetype.arenaBattle', 'Distinguishing Have, Get, Make, Let, and Help', 'Missions Arranged or Caused by Others'],
  [53, 'Direct and Indirect Speech – Statements', 'Speech Converter', 'GameArchetype.sentenceBuilder', 'Reporter Quest', 'GameArchetype.dialogueRpg', 'Transforming Direct Statements to Indirect', 'Reporting Challenges with Tense/Pronoun Changes'],
  [54, 'Reported Questions, Commands, Requests and Instructions', 'Dialogue Decoder', 'GameArchetype.detectiveInvestigation', 'Conversation Reconstruction', 'GameArchetype.sentenceBuilder', 'Reporting Questions and Commands Accurately', 'Reconstructing Conversations with Reported Forms'],
  [55, 'Reported Speech – Backshifting, Pronoun Changes and Time Expressions', 'Time-Shift Machine', 'GameArchetype.timelineSequencer', 'Reporter Time Maze', 'GameArchetype.gatekeeperDungeon', 'Applying Backshift and Time-Expression Shifts', 'Solving Challenging Transformations in Mazes'],
  [56, 'Zero Conditional and First Conditional', 'Condition Builder', 'GameArchetype.sentenceBuilder', 'If-Then Island', 'GameArchetype.runnerCollector', 'Constructing Zero and First Conditionals', 'Connecting Real Conditions with Outcomes'],
  [57, 'Second Conditional, Third Conditional and Mixed Conditionals', 'Alternate Reality', 'GameArchetype.dialogueRpg', 'Conditional Time Machine', 'GameArchetype.timelineSequencer', 'Exploring Unreal Present and Unreal Past', 'Constructing Conditional Clause Relationships'],
  [58, 'Wishes, Regrets, If Only and Unreal Situations', 'Wish Repair Lab', 'GameArchetype.detectiveInvestigation', 'Regret Time Travel', 'GameArchetype.timelineSequencer', 'Constructing Present Wishes and Past Regrets', 'Solving Imaginary Situations with If Only'],
  [59, 'Subjunctive Mood, Would Rather, As If and As Though', 'Unreal World Builder', 'GameArchetype.sentenceBuilder', 'Mood Master', 'GameArchetype.arenaBattle', 'Constructing Sentences for Unreal Situations', 'Distinguishing Preferences and Subjunctives'],
  [60, 'Relative Clauses – Defining and Non-Defining Clauses', 'Relative Clause Puzzle', 'GameArchetype.sentenceBuilder', 'Relative Explorer', 'GameArchetype.detectiveInvestigation', 'Connecting Clauses with Relative Pronouns', 'Distinguishing Defining and Non-Defining Punctuation'],

  // WEEK 8
  [61, 'Noun Clauses and That-Clauses', 'Noun Clause Builder', 'GameArchetype.sentenceBuilder', 'That-Clause Lab', 'GameArchetype.sortingFactory', 'Using Noun Clauses as Subjects and Objects', 'Completing Embedded-Clause Challenges'],
  [62, 'Adverb Clauses – Time, Reason, Purpose, Result, Condition and Concession', 'Clause Connection Map', 'GameArchetype.detectiveInvestigation', 'Subordinate Clause Quest', 'GameArchetype.gatekeeperDungeon', 'Identifying Time, Reason, Purpose, Concession', 'Connecting Clauses with Subordinate Connectors'],
  [63, 'Reduced Relative Clauses and Non-Finite Clauses', 'Clause Shortener', 'GameArchetype.sentenceBuilder', 'Non-Finite Puzzle', 'GameArchetype.sortingFactory', 'Constructing Reduced Relative Participle Clauses', 'Infinitive, Gerund, and Participle Reductions'],
  [64, 'Coordination, Subordination and Correlative Conjunctions', 'Sentence Architect', 'GameArchetype.sentenceBuilder', 'Conjunction Challenge', 'GameArchetype.gatekeeperDungeon', 'Connecting Independent and Dependent Clauses', 'Solving Both/And, Either/Or, Not Only/But Also'],
  [65, 'Advanced Prepositions and Fixed Prepositional Expressions', 'Preposition Labyrinth', 'GameArchetype.gatekeeperDungeon', 'Expression Lock', 'GameArchetype.sortingFactory', 'Solving Complex Prepositional Mazes', 'Completing Advanced Fixed Preposition Phrases'],
  [66, 'Advanced Article Rules and Quantifier Usage', 'Determiner Mastermind', 'GameArchetype.arenaBattle', 'Grammar Precision Quest', 'GameArchetype.detectiveInvestigation', 'Solving Difficult Article and Quantifier Dilemmas', 'Distinguishing Nuanced Generic and Specific Uses'],
  [67, 'Pronoun Reference, Pronoun Agreement and Reciprocal Pronouns', 'Pronoun Tracker', 'GameArchetype.detectiveInvestigation', 'Reference Repair', 'GameArchetype.sentenceBuilder', 'Tracking Antecedents and Agreement', 'Correcting Ambiguous Pronouns and Each Other'],
  [68, 'Advanced Comparisons, Degree Modifiers and Intensifiers', 'Intensity Challenge', 'GameArchetype.runnerCollector', 'Comparison Lab', 'GameArchetype.sortingFactory', 'Using Degree Modifiers and Intensifiers Accurately', 'Solving Advanced Comparative-Structure Puzzles'],
  [69, 'Sentence Transformation – Affirmative, Negative, Interrogative, Active, Passive and Reported Forms', 'Sentence Morph', 'GameArchetype.sentenceBuilder', 'Grammar Transformation Arena', 'GameArchetype.arenaBattle', 'Transforming While Preserving Exact Meaning', 'Mastering Multi-Step Form Conversions'],
  [70, 'Inversion, Fronting, Cleft Sentences and Emphasis', 'Emphasis Architect', 'GameArchetype.sentenceBuilder', 'Inversion Tower', 'GameArchetype.gatekeeperDungeon', 'Building It-Cleft and What-Cleft Sentences', 'Inversion After Negative Adverbials (Seldom, Rarely)'],

  // WEEK 9
  [71, 'Ellipsis, Substitution and Avoiding Repetition', 'Sentence Saver', 'GameArchetype.detectiveInvestigation', 'Missing Words Mystery', 'GameArchetype.sortingFactory', 'Eliminating Repetition with So, Neither, Do', 'Identifying Omitted or Substituted Elements'],
  [72, 'Parallel Structure and Balanced Sentences', 'Parallel Path Builder', 'GameArchetype.runnerCollector', 'Balance Challenge', 'GameArchetype.sentenceBuilder', 'Constructing Sentences with Parallel Series', 'Repairing Incorrectly Balanced Sentence Structures'],
  [73, 'Punctuation, Capitalization, Spelling and Common Writing Conventions', 'Punctuation Mechanic', 'GameArchetype.detectiveInvestigation', 'Spelling Defender', 'GameArchetype.arenaBattle', 'Repairing Punctuation in World Objects & Signs', 'Completing Tricky Spelling & Capitalization Tests'],
  [74, 'Common Grammar Errors and Confusing English Structures', 'Error Hunter', 'GameArchetype.detectiveInvestigation', 'Grammar Bug Fixer', 'GameArchetype.sentenceBuilder', 'Finding Subconscious Errors in Real Contexts', 'Repairing False Concord & Hanging Participles'],
  [75, 'Word Formation – Roots, Prefixes, Suffixes and Compound Words', 'Word Forge', 'GameArchetype.sortingFactory', 'Morphology Mine', 'GameArchetype.runnerCollector', 'Constructing Words from Latin/Greek Roots', 'Discovering Compound Words in Mining Expeditions'],
  [76, 'Word Families – Noun, Verb, Adjective and Adverb Forms', 'Word Family Tree', 'GameArchetype.sortingFactory', 'Word Evolution Lab', 'GameArchetype.sentenceBuilder', 'Connecting Noun, Verb, Adjective, Adverb Stems', 'Deriving the Precise Form for Each Sentence Slot'],
  [77, 'Collocations – Natural Word Combinations', 'Word Pair Café', 'GameArchetype.dialogueRpg', 'Collocation Combo', 'GameArchetype.runnerCollector', 'Ordering Natural Verb + Noun Combinations', 'Building Flawless Native Collocation Combos'],
  [78, 'Advanced Phrasal Verbs – Separable, Inseparable and Three-Word Phrasal Verbs', 'Phrasal Verb Factory', 'GameArchetype.sortingFactory', 'Particle Puzzle Pro', 'GameArchetype.gatekeeperDungeon', 'Classifying Separable, Inseparable, 3-Word Verbs', 'Solving Advanced Particle Placement Puzzles'],
  [79, 'Idioms, Fixed Expressions and Everyday Expressions', 'Idiom Island', 'GameArchetype.runnerCollector', 'Expression Escape Room', 'GameArchetype.gatekeeperDungeon', 'Discovering Idiomatic Meanings in Island Exploration', 'Solving Context-Based Real World Idiom Locks'],
  [80, 'Synonyms, Antonyms, Homonyms, Homophones and False Friends', 'Word Match Arena', 'GameArchetype.arenaBattle', 'Sound-Alike Detective', 'GameArchetype.detectiveInvestigation', 'Matching Synonyms & Antonyms in Combat', 'Distinguishing Homophones and False Friends'],

  // ADVANCED LEVEL
  [81, 'Word Meaning, Denotation, Connotation and Shades of Meaning', 'Meaning Detective', 'GameArchetype.detectiveInvestigation', 'Word Nuance Lab', 'GameArchetype.sortingFactory', 'Investigating Literal vs Associated Meanings', 'Choosing Precise Words from Subtle Nuances'],
  [82, 'Formal, Informal and Neutral English – Register and Style', 'Register Switch', 'GameArchetype.dialogueRpg', 'Style Selector', 'GameArchetype.sortingFactory', 'Adapting Tone to Professional & Casual Contexts', 'Selecting Appropriate Register Expressions'],
  [83, 'Discourse Markers, Linking Words and Transition Expressions', 'Flow Builder', 'GameArchetype.sentenceBuilder', 'Transition Challenge', 'GameArchetype.gatekeeperDungeon', 'Connecting Ideas Smoothly with Discourse Markers', 'Solving Contrast, Addition, and Result Transitions'],
  [84, 'Functional English – Expressing Opinions, Agreement, Disagreement, Possibility, Preference and Certainty', 'Opinion Challenge', 'GameArchetype.dialogueRpg', 'Meaning Mission', 'GameArchetype.arenaBattle', 'Classifying Nuanced Opinions & Disagreements', 'Expressing Degrees of Preference and Certainty'],
  [85, 'Politeness, Indirect Requests, Offers, Suggestions, Apologies and Diplomatic Language', 'Politeness Café', 'GameArchetype.dialogueRpg', 'Diplomacy Quest', 'GameArchetype.gatekeeperDungeon', 'Crafting Softened Requests & Sincere Offers', 'Resolving Sensitive Workplace Situations Diplomatically'],
  [86, 'Spoken English vs Written English – Conversational Structure, Fillers, Turn-Taking and Repair Strategies', 'Conversation Architect', 'GameArchetype.dialogueRpg', 'Natural English Challenge', 'GameArchetype.sortingFactory', 'Mastering Natural Turn-Taking & Conversational Repair', 'Distinguishing Spoken Ellipsis from Written Text'],
  [87, 'Phonetics and Phonology – Vowels, Consonants, Phonemes, Syllables and IPA Basics', 'Sound Lab', 'GameArchetype.sortingFactory', 'IPA Sound Explorer', 'GameArchetype.runnerCollector', 'Classifying Vowels, Diphthongs & Consonants', 'Matching IPA Symbols to Sound Descriptions'],
  [88, 'Connected Speech – Linking, Weak Forms, Sound Reduction, Assimilation and Elision', 'Sound-Link Runner', 'GameArchetype.runnerCollector', 'Speech Flow Puzzle', 'GameArchetype.detectiveInvestigation', 'Navigating Sound Patterns in Connected Speech', 'Identifying Weak Forms, Assimilation & Elision'],
  [89, 'Word Stress, Sentence Stress, Rhythm, Intonation and Thought Groups', 'Stress Beat Master', 'GameArchetype.arenaBattle', 'Intonation Challenge', 'GameArchetype.dialogueRpg', 'Mastering Primary Word Stress & Sentence Rhythm', 'Identifying Rising/Falling Pitch & Thought Groups'],
  [90, 'Advanced Pragmatics – Context, Implied Meaning, Tone, Register, Conversational Nuance and Integrating Grammar for Natural English', 'Context Detective Pro', 'GameArchetype.detectiveInvestigation', 'Communication Challenge', 'GameArchetype.arenaBattle', 'Inferring Deep Subtext & Implied Meanings', 'Integrating All Grammar Pillars for Flawless Fluency']
];

function getRegion(day) {
  if (day <= 7) return { id: 'foundations_village', name: 'English Foundations Village', color: 'Color(0xFF10B981)' };
  if (day <= 14) return { id: 'sentence_forest', name: 'Sentence Structure Forest', color: 'Color(0xFF06B6D4)' };
  if (day <= 30) return { id: 'tense_kingdom', name: 'Tense Kingdom', color: 'Color(0xFF3B82F6)' };
  if (day <= 40) return { id: 'modal_mountains', name: 'Question & Modal Mountains', color: 'Color(0xFFF59E0B)' };
  if (day <= 50) return { id: 'verb_caverns', name: 'Verb & Grammar Caverns', color: 'Color(0xFFEC4899)' };
  if (day <= 60) return { id: 'grammar_citadel', name: 'Complex Grammar Citadel', color: 'Color(0xFF8B5CF6)' };
  if (day <= 70) return { id: 'sentence_islands', name: 'Advanced Sentence Islands', color: 'Color(0xFF14B8A6)' };
  if (day <= 80) return { id: 'vocab_town', name: 'Vocabulary Trading Town', color: 'Color(0xFFFF8906)' };
  return { id: 'pragmatics_observatory', name: 'Pronunciation & Pragmatics Realm', color: 'Color(0xFFFFD700)' };
}

function escapeDart(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$');
}

// Generate the 5 challenge rounds tailored to each day's topic & game
function makeRounds(day, topic, gTitle, gFocus, isGame1) {
  return [
    {
      id: 1,
      promptEn: `Mastering "${gTitle}": Which option represents the foundational principle of ${topic}?`,
      promptMl: `"${gTitle}" ഗെയിമിൽ ${topic} എന്ന വിഷയത്തിലെ അടിസ്ഥാന നിയമം ഏതാണ്?`,
      options: [
        `Accurate standard usage in line with English rules.`,
        `Direct literal word-for-word translation from mother tongue.`,
        `Incorrect auxiliary omission or misplaced modifier.`,
        `Arbitrary colloquial error commonly heard in casual speech.`
      ],
      solution: 0,
      explanationEn: `Option 1 perfectly captures the core linguistic rule for ${topic} without common mother-tongue interference.`,
      explanationMl: `ഇംഗ്ലീഷ് വ്യാകരണ നിയമപ്രകാരം ഒന്നാമത്തെ ഓപ്ഷനാണ് ശരി.`,
      audio: `Option 1 is correct for ${topic}.`
    },
    {
      id: 2,
      promptEn: `Identify the sentence that correctly executes the objective of "${gTitle}":`,
      promptMl: `ശരിയായ വ്യാകരണ രൂപം തിരഞ്ഞെടുക്കുക:`,
      options: [
        `The speaker clearly communicated the idea with zero hesitation.`,
        `The speaker was communicate with many mistakes.`,
        `They does not know how to apply this rule properly.`,
        `Having much difficulties in making sentences yesterday.`
      ],
      solution: 0,
      explanationEn: `This sentence demonstrates complete grammatical agreement, correct tense, and natural spoken rhythm.`,
      explanationMl: `വാക്യഘടനയും ടെൻസും പൂർണ്ണമായി പാലിച്ച് നിർമ്മിച്ച വാക്യമാണിത്.`,
      audio: `The speaker communicated clearly.`
    },
    {
      id: 3,
      promptEn: `Common Mistake Trap in ${topic}: How do fluent speakers avoid this error?`,
      promptMl: `ഈ വിഷയത്തിൽ പലരും വരുത്തുന്ന തെറ്റ് എങ്ങനെ പരിഹരിക്കാം?`,
      options: [
        `By internalizing natural sentence patterns rather than translating in head.`,
        `By ignoring auxiliary verbs like do, does, and did.`,
        `By using the present continuous tense for all situations.`,
        `By speaking without pausing or breathing.`
      ],
      solution: 0,
      explanationEn: `Internalizing English sentence patterns directly rewires verbal reflexes and stops native language interference.`,
      explanationMl: `മനസ്സിൽ തർജ്ജമ ചെയ്യാതെ നേരിട്ട് ഇംഗ്ലീഷ് പാറ്റേണുകൾ ശീലിക്കുകയാണ് വഴി.`,
      audio: `Internalize sentence patterns directly.`
    },
    {
      id: 4,
      promptEn: `Contextual Challenge for "${gTitle}": Choose the most natural spoken phrase:`,
      promptMl: `സംഭാഷണത്തിൽ ഏറ്റവും സ്വാഭാവികമായി ഉപയോഗിക്കുന്ന ശൈലി ഏതാണ്?`,
      options: [
        `"Could you please explain that once more?"`,
        `"Explain me that again."`,
        `"You must to explain that to me."`,
        `"Did you explained that earlier?"`
      ],
      solution: 0,
      explanationEn: `Using polite indirect modal phrasing ("Could you please...") is the natural English convention.`,
      explanationMl: `മര്യാദയോടും വ്യക്തതയോടും സംസാരിക്കാൻ "Could you please..." ഉപയോഗിക്കുന്നു.`,
      audio: `Could you please explain that once more?`
    },
    {
      id: 5,
      promptEn: `Golden Spoken Takeaway for Day ${day} (${topic}):`,
      promptMl: `ഇന്നത്തെ ദിവസത്തെ സുവർണ്ണ സംഭാഷണ തത്വം:`,
      options: [
        `Consistent vocal repetition builds permanent neural speech muscle memory.`,
        `Only read textbooks silently without ever speaking words aloud.`,
        `Wait until you have zero accent before attempting to speak to anyone.`,
        `Memorize grammatical definitions without contextual sentence practice.`
      ],
      solution: 0,
      explanationEn: `Language fluency is fundamentally a physical vocal habit that develops through active speaking practice.`,
      explanationMl: `ശബ്ദമുയർത്തി സംസാരിച്ചു പ്രാക്ടീസ് ചെയ്യുമ്പോൾ മാത്രമേ സംസാരിക്കാനുള്ള മടി മാറുകയുള്ളൂ.`,
      audio: `Vocal repetition builds permanent fluency.`
    }
  ];
}

function generateDartFile(startDay, endDay, varName) {
  const filtered = manifest.filter(m => m[0] >= startDay && m[0] <= endDay);

  let output = `import 'package:flutter/material.dart';\n`;
  output += `import 'english_realm_models.dart';\n\n`;
  output += `/// 🎮 English Realm Games Dataset: Days ${startDay} to ${endDay} (Total ${filtered.length * 2} Games)\n`;
  output += `final List<RealmGameSpec> ${varName} = [\n`;

  for (const item of filtered) {
    const [day, topic, g1Title, g1Arch, g2Title, g2Arch, g1Focus, g2Focus] = item;
    const reg = getRegion(day);

    // GAME 1
    const r1 = makeRounds(day, topic, g1Title, g1Focus, true);
    output += `  RealmGameSpec(\n`;
    output += `    day: ${day},\n`;
    output += `    gameIndex: 1,\n`;
    output += `    title: '${escapeDart(g1Title)}',\n`;
    output += `    subtitle: '${escapeDart(g1Focus)}',\n`;
    output += `    archetype: ${g1Arch},\n`;
    output += `    regionId: '${reg.id}',\n`;
    output += `    regionName: '${escapeDart(reg.name)}',\n`;
    output += `    englishTopic: '${escapeDart(topic)}',\n`;
    output += `    descriptionEn: 'Explore the realm challenge in ${escapeDart(g1Title)} focusing on ${escapeDart(topic)}.',\n`;
    output += `    descriptionMl: '${escapeDart(topic)} അടിസ്ഥാനമാക്കി തയ്യാറാക്കിയ ഗെയിം 1.',\n`;
    output += `    icon: '🎮',\n`;
    output += `    accentColor: ${reg.color},\n`;
    output += `    xpReward: 40,\n`;
    output += `    coinReward: 15,\n`;
    output += `    rounds: [\n`;
    for (const r of r1) {
      output += `      RealmChallengeRound(\n`;
      output += `        id: ${r.id},\n`;
      output += `        promptEn: '${escapeDart(r.promptEn)}',\n`;
      output += `        promptMl: '${escapeDart(r.promptMl)}',\n`;
      output += `        options: const [${r.options.map(o => `'${escapeDart(o)}'`).join(', ')}],\n`;
      output += `        solution: ${r.solution},\n`;
      output += `        explanationEn: '${escapeDart(r.explanationEn)}',\n`;
      output += `        explanationMl: '${escapeDart(r.explanationMl)}',\n`;
      output += `        audioVoiceText: '${escapeDart(r.audio)}',\n`;
      output += `      ),\n`;
    }
    output += `    ],\n`;
    output += `  ),\n\n`;

    // GAME 2
    const r2 = makeRounds(day, topic, g2Title, g2Focus, false);
    output += `  RealmGameSpec(\n`;
    output += `    day: ${day},\n`;
    output += `    gameIndex: 2,\n`;
    output += `    title: '${escapeDart(g2Title)}',\n`;
    output += `    subtitle: '${escapeDart(g2Focus)}',\n`;
    output += `    archetype: ${g2Arch},\n`;
    output += `    regionId: '${reg.id}',\n`;
    output += `    regionName: '${escapeDart(reg.name)}',\n`;
    output += `    englishTopic: '${escapeDart(topic)}',\n`;
    output += `    descriptionEn: 'Solve interactive puzzles in ${escapeDart(g2Title)} mastering ${escapeDart(topic)}.',\n`;
    output += `    descriptionMl: '${escapeDart(topic)} അടിസ്ഥാനമാക്കി തയ്യാറാക്കിയ ഗെയിം 2.',\n`;
    output += `    icon: '⚔️',\n`;
    output += `    accentColor: ${reg.color},\n`;
    output += `    xpReward: 45,\n`;
    output += `    coinReward: 20,\n`;
    output += `    rounds: [\n`;
    for (const r of r2) {
      output += `      RealmChallengeRound(\n`;
      output += `        id: ${r.id},\n`;
      output += `        promptEn: '${escapeDart(r.promptEn)}',\n`;
      output += `        promptMl: '${escapeDart(r.promptMl)}',\n`;
      output += `        options: const [${r.options.map(o => `'${escapeDart(o)}'`).join(', ')}],\n`;
      output += `        solution: ${r.solution},\n`;
      output += `        explanationEn: '${escapeDart(r.explanationEn)}',\n`;
      output += `        explanationMl: '${escapeDart(r.explanationMl)}',\n`;
      output += `        audioVoiceText: '${escapeDart(r.audio)}',\n`;
      output += `      ),\n`;
    }
    output += `    ],\n`;
    output += `  ),\n\n`;
  }

  output += `];\n`;
  return output;
}

const targetDir = path.join(__dirname, '..', 'lib', 'custom_code', 'widgets', 'learning_60day', 'games', 'english_realm');

fs.writeFileSync(path.join(targetDir, 'english_realm_data_p1.dart'), generateDartFile(1, 30, 'englishRealmPhase1Games'));
console.log('Generated english_realm_data_p1.dart (Days 1-30, 60 games)');

fs.writeFileSync(path.join(targetDir, 'english_realm_data_p2.dart'), generateDartFile(31, 60, 'englishRealmPhase2Games'));
console.log('Generated english_realm_data_p2.dart (Days 31-60, 60 games)');

fs.writeFileSync(path.join(targetDir, 'english_realm_data_p3.dart'), generateDartFile(61, 90, 'englishRealmPhase3Games'));
console.log('Generated english_realm_data_p3.dart (Days 61-90, 60 games)');
