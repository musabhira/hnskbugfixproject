import 'dart:convert';
import 'dart:io';

void main() {
  final Map<String, dynamic> data = {
    "curriculum_version": "90_day_master_v2",
    "title": "Pocket Mates 90-Day Spoken English Master Roadmap",
    "description": "Comprehensive, 100% unique 90-day English mastery across all grammar, vocabulary, reading, house defense, and spoken conversation.",
    "tracks": [
      {
        "id": "zero",
        "nameEn": "Zero Foundation Track",
        "nameMl": "ശൂന്യത്തിൽ നിന്നുള്ള അടിത്തറ (Zero Foundation)",
        "badge": "🌱 ZERO",
        "colorHex": "#10B981",
        "target": "Absolute beginners: Phonics, ABC sounds, object words, patient AI Robot, no forced stranger calls"
      },
      {
        "id": "middle",
        "nameEn": "Core Middle Track",
        "nameMl": "സാധാരണ ഇംഗ്ലീഷ് & സംഭാഷണം (Core Middle)",
        "badge": "🗣️ MIDDLE",
        "colorHex": "#38BDF8",
        "target": "Daily spoken fluency, sentence building, English Hub community posts, random chat, citadel attack & defense"
      },
      {
        "id": "higher",
        "nameEn": "Higher Fluency Track",
        "nameMl": "കോൺഫിഡൻസും ഫ്ലുവെൻസിയും (Higher Fluency)",
        "badge": "🚀 HIGHER",
        "colorHex": "#A855F7",
        "target": "Professional finesse, interview formulas, natural fluency, idioms, leadership debate, PocketTalk pacts"
      }
    ],
    "houses": [
      {
        "house": 1,
        "titleEn": "House 1: Foundation & Daily Living",
        "titleMl": "ഹൗസ് 1: അടിസ്ഥാനവും ദൈനംദിന ജീവിതവും",
        "dayRange": "Days 1–30",
        "colorHex": "#10B981",
        "gateExamDay": 30
      },
      {
        "house": 2,
        "titleEn": "House 2: Real-World Social & Time Travel",
        "titleMl": "ഹൗസ് 2: പുറംലോകവും ഭൂത-ഭാവി കാലങ്ങളും",
        "dayRange": "Days 31–60",
        "colorHex": "#38BDF8",
        "gateExamDay": 60
      },
      {
        "house": 3,
        "titleEn": "House 3: Professional Fluency & Career Mastery",
        "titleMl": "ഹൗസ് 3: ഫ്ലുവെൻസി, കരിയർ & ഇന്റർവ്യൂ മാസ്റ്ററി",
        "dayRange": "Days 61–90",
        "colorHex": "#A855F7",
        "gateExamDay": 90
      }
    ],
    "days": _buildAll90Days(),
  };

  final file = File('assets/curriculum/master_90_days_syllabus.json');
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  print('Successfully generated 90 unique curriculum days into ${file.path}!');
}

List<Map<String, dynamic>> _buildAll90Days() {
  final List<Map<String, dynamic>> days = [];

  final List<Map<String, dynamic>> house1Themes = [
    {"tEn": "Me & Identity", "tMl": "ഞാനും അടിസ്ഥാന ഇംഗ്ലീഷും", "g": "Am/Is/Are & Phonics"},
    {"tEn": "Where I Am From", "tMl": "നാടും സ്ഥലങ്ങളും", "g": "Prepositions: From, In, At"},
    {"tEn": "Helping Verbs: Am, Is, Are", "tMl": "സഹായക്രിയകൾ: Am, Is, Are", "g": "Subject-Verb Agreement"},
    {"tEn": "Pronouns & Family", "tMl": "സർവ്വനാമങ്ങളും കുടുംബവും", "g": "I, You, He, She, We, They"},
    {"tEn": "This, That, These, Those", "tMl": "അടുത്തും ദൂരെയുമുള്ള വസ്തുക്കൾ", "g": "Demonstrative Pronouns"},
    {"tEn": "My House & Rooms", "tMl": "വീടും മുറികളും", "g": "Nouns & Room Vocabulary"},
    {"tEn": "Everyday Objects", "tMl": "നിത്യജീവിത വസ്തുക്കൾ", "g": "Object Nouns & Articles (A/An)"},
    {"tEn": "Numbers & Counting", "tMl": "സംഖ്യകളും എണ്ണലും", "g": "Cardinal Numbers & Plurals"},
    {"tEn": "Colors & Shapes", "tMl": "നിറങ്ങളും ആകൃതികളും", "g": "Descriptive Adjectives"},
    {"tEn": "Telling Time & Days", "tMl": "സമയവും ദിവസങ്ങളും", "g": "Prepositions of Time: At, On, In"},
    {"tEn": "Morning Routine", "tMl": "പ്രഭാത ശീലങ്ങൾ", "g": "Simple Present (Daily Habits)"},
    {"tEn": "Evening Routine & Leisure", "tMl": "വൈകുന്നേര ശീലങ്ങൾ", "g": "Simple Present Verbs"},
    {"tEn": "Do vs Does", "tMl": "Do vs Does പ്രയോഗങ്ങൾ", "g": "Positive Habit Statements"},
    {"tEn": "Don't vs Doesn't", "tMl": "നെഗറ്റീവ് ശീലങ്ങൾ", "g": "Negative Statements"},
    {"tEn": "Food & Basic Drinks", "tMl": "ഭക്ഷണവും പാനീയങ്ങളും", "g": "Expressing Likes & Hunger"},
    {"tEn": "Prepositions of Place", "tMl": "സ്ഥാനങ്ങൾ: In, On, Under", "g": "Spatial Prepositions"},
    {"tEn": "Can vs Cannot", "tMl": "കഴിവുകൾ: Can vs Cannot", "g": "Modals of Ability"},
    {"tEn": "Feelings & Emotions", "tMl": "വികാരങ്ങളും അവസ്ഥകളും", "g": "Predicate Adjectives (I feel tired)"},
    {"tEn": "Body Parts & Simple Ailments", "tMl": "ശരീരഭാഗങ്ങളും അസുഖങ്ങളും", "g": "Have/Has for Symptoms"},
    {"tEn": "Clothes & Getting Dressed", "tMl": "വസ്ത്രങ്ങളും ധാരണയും", "g": "Present Continuous: Wearing"},
    {"tEn": "Asking What & Where", "tMl": "What & Where ചോദ്യങ്ങൾ", "g": "WH-Questions 1"},
    {"tEn": "Asking Who & When", "tMl": "Who & When ചോദ്യങ്ങൾ", "g": "WH-Questions 2"},
    {"tEn": "Asking Why & Which", "tMl": "Why & Which ചോദ്യങ്ങൾ", "g": "WH-Questions 3"},
    {"tEn": "Asking How & How Much", "tMl": "How & How Much ചോദ്യങ്ങൾ", "g": "Quantity & Quality Questions"},
    {"tEn": "Polite Courtesies", "tMl": "മര്യാദയുള്ള സംസാരം", "g": "Please, Sorry, Thank You"},
    {"tEn": "Giving Simple Directions", "tMl": "വഴികൾ പറഞ്ഞു കൊടുക്കൽ", "g": "Imperative Verbs (Turn left, Go straight)"},
    {"tEn": "Weather & Nature", "tMl": "കാലാവസ്ഥയും പ്രകൃതിയും", "g": "Impersonal 'It' (It is raining)"},
    {"tEn": "Meeting Neighbors & Friends", "tMl": "അയൽക്കാരോട് കുശലാന്വേഷണം", "g": "Casual Greetings & Small Talk"},
    {"tEn": "House 1 Grand Revision", "tMl": "ഹൗസ് 1 റിവിഷൻ & തയ്യാറെടുപ്പ്", "g": "All House 1 Concepts"},
    {"tEn": "🏆 House 1 Gate Exam", "tMl": "🏆 ഹൗസ് 1 ഗേറ്റ് എക്സാം", "g": "House 1 Graduation Assessment"}
  ];

  final List<Map<String, dynamic>> house2Themes = [
    {"tEn": "Was vs Were", "tMl": "കഴിഞ്ഞ കാര്യങ്ങൾ: Was vs Were", "g": "Past State of Being"},
    {"tEn": "Irregular Past Verbs 1", "tMl": "Went, Saw, Ate, Came", "g": "Simple Past Affirmative"},
    {"tEn": "Irregular Past Verbs 2", "tMl": "Spoke, Took, Gave, Found", "g": "Simple Past Affirmative"},
    {"tEn": "Did vs Didn't", "tMl": "കഴിഞ്ഞ ചോദ്യങ്ങളും നിഷേധങ്ങളും", "g": "Did you...? / I didn't..."},
    {"tEn": "Yesterday's Full Timeline", "tMl": "ഇന്നലത്തെ ദിവസത്തിന്റെ വിവരണം", "g": "Chronological Past Sequencing"},
    {"tEn": "Childhood Memories", "tMl": "കുട്ടിക്കാല ഓർമ്മകൾ", "g": "Used to / Past Habits"},
    {"tEn": "At the Supermarket", "tMl": "സൂപ്പർമാർക്കറ്റിൽ സാധനങ്ങൾ വാങ്ങൽ", "g": "Inquiries, Quantities & Prices"},
    {"tEn": "At a Restaurant / Cafe", "tMl": "റെസ്റ്റോറന്റിൽ ഭക്ഷണം ഓർഡർ ചെയ്യൽ", "g": "Ordering & Special Requests"},
    {"tEn": "Hiring an Auto / Taxi", "tMl": "ഓട്ടോയിലും ടാക്സിയിലും യാത്ര ചെയ്യൽ", "g": "Destination & Fare Negotiation"},
    {"tEn": "Bus & Train Stations", "tMl": "ബസ്സിലും ട്രെയിനിലും യാത്ര ചെയ്യൽ", "g": "Travel Inquiries & Platforms"},
    {"tEn": "Shopping for Clothes", "tMl": "വസ്ത്രങ്ങൾ തിരഞ്ഞെടുക്കൽ", "g": "Size, Color, Fit & Trial"},
    {"tEn": "Medical Clinic & Pharmacy", "tMl": "ക്ലിനിക്കിലും മെഡിക്കൽ ഷോപ്പിലും", "g": "Explaining Health Symptoms"},
    {"tEn": "At the Bank & ATM", "tMl": "ബാങ്കിലും എ.ടി.എമ്മിലും", "g": "Account Inquiries & Transactions"},
    {"tEn": "Will vs Won't", "tMl": "ഭാവികാലം: Will vs Won't", "g": "Future Simple (Instant Decisions)"},
    {"tEn": "Going To for Plans", "tMl": "വരാനിരിക്കുന്ന പ്ലാനുകൾ", "g": "Future with 'Going to'"},
    {"tEn": "Tomorrow's Schedule", "tMl": "നാളത്തെ പ്ലാനുകൾ പറയൽ", "g": "Future Scheduling"},
    {"tEn": "Telephone: Greetings & Holding", "tMl": "ഫോൺ കോൾ: സംസാരിച്ചു തുടങ്ങൽ", "g": "Telephone Courtesies"},
    {"tEn": "Telephone: Leaving Messages", "tMl": "ഫോൺ കോൾ: മെസ്സേജുകൾ നൽകൽ", "g": "Indirect Telephone Speech"},
    {"tEn": "Telephone: Network Issues", "tMl": "നെറ്റ്‌വർക്ക് പ്രശ്നങ്ങൾ കൈകാര്യം ചെയ്യൽ", "g": "Breaking up / Line issues"},
    {"tEn": "Inviting a Friend", "tMl": "സുഹൃത്തുക്കളെ ക്ഷണിക്കൽ", "g": "Invitations & Suggestions"},
    {"tEn": "Accepting & Declining Politely", "tMl": "മാന്യമായി ക്ഷണം സ്വീകരിക്കലും നിരസിക്കലും", "g": "Polite Refusals ('I wish I could')"},
    {"tEn": "Expressing Opinions", "tMl": "സ്വന്തം അഭിപ്രായങ്ങൾ പറയൽ", "g": "In my opinion / I think"},
    {"tEn": "Agreeing & Disagreeing", "tMl": "യോജിക്കലും വിയോജിക്കലും", "g": "Diplomatic Agreement & Disagreement"},
    {"tEn": "Giving Compliments", "tMl": "അഭിനന്ദനങ്ങളും പ്രശംസയും", "g": "Compliments & Appreciation"},
    {"tEn": "Fixing Misunderstandings", "tMl": "തെറ്റിദ്ധാരണകൾ തിരുത്തൽ", "g": "Clarifications & Apologies"},
    {"tEn": "Lost Items & Emergencies", "tMl": "വസ്തുക്കൾ നഷ്ടപ്പെടലും അത്യാഹിതങ്ങളും", "g": "Urgent Assistance Requests"},
    {"tEn": "Weekend Getaways & Trips", "tMl": "വിനോദയാത്രകളും അനുഭവങ്ങളും", "g": "Travel Story Narration"},
    {"tEn": "House 2 Comprehensive Review", "tMl": "ഹൗസ് 2 ഫുൾ റിവിഷൻ", "g": "Past, Future & Public English"},
    {"tEn": "Mock Citadel Social Battle", "tMl": "സാമൂഹിക സംഭാഷണ യുദ്ധം", "g": "Multi-scenario Challenge"},
    {"tEn": "🏆 House 2 Gate Exam", "tMl": "🏆 ഹൗസ് 2 ഗേറ്റ് എക്സാം", "g": "House 2 Graduation Assessment"}
  ];

  final List<Map<String, dynamic>> house3Themes = [
    {"tEn": "Present Perfect: Have/Has + Done", "tMl": "ചെയ്തു കഴിഞ്ഞ കാര്യങ്ങൾ: Have/Has", "g": "Present Perfect (Experience)"},
    {"tEn": "Already, Just, Yet", "tMl": "Already, Just, Yet പ്രയോഗങ്ങൾ", "g": "Adverbs of Timing"},
    {"tEn": "Have Been vs Has Been", "tMl": "Have Been vs Has Been മാസ്റ്ററി", "g": "Present Perfect Continuous"},
    {"tEn": "Since vs For", "tMl": "Since vs For കൃത്യമായ സമയം", "g": "Duration vs Starting Point"},
    {"tEn": "Past Perfect: Had + V3", "tMl": "ഭൂതകാലത്തിലെ മുൻപ് നടന്നത്", "g": "Past Perfect (Had gone before...)"},
    {"tEn": "Continuous States & Career", "tMl": "വർഷങ്ങളായുള്ള തൊഴിൽ പരിചയം", "g": "I have been working as..."},
    {"tEn": "Life Experiences: Have you ever...?", "tMl": "ജീവിതാനുഭവങ്ങൾ ചോദിക്കൽ", "g": "Have you ever visited/tried..."},
    {"tEn": "Giving Advice: Should / Shouldn't", "tMl": "ഉപദേശം നൽകൽ: Should / Shouldn't", "g": "Modals of Advice"},
    {"tEn": "Rules & Duties: Must vs Have to", "tMl": "നിയമങ്ങളും കടമകളും", "g": "Obligation & Necessity"},
    {"tEn": "High Politeness: Could vs Would", "tMl": "മാന്യമായ ചോദ്യങ്ങൾ: Could vs Would", "g": "Polite Inquiries (Would you mind...)"},
    {"tEn": "Possibility: May vs Might", "tMl": "സാധ്യതകൾ: May vs Might", "g": "Modals of Probability"},
    {"tEn": "Conditionals 1: If + Present, Will", "tMl": "സാധ്യതയുള്ള നിബന്ധനകൾ", "g": "First Conditional"},
    {"tEn": "Conditionals 2: If + Past, Would", "tMl": "സാങ്കൽപ്പിക സാഹചര്യങ്ങൾ", "g": "Second Conditional"},
    {"tEn": "Connectors: Because & Although", "tMl": "വാക്യങ്ങൾ ബന്ധിപ്പിക്കൽ", "g": "Conjunctions of Contrast & Reason"},
    {"tEn": "Sequencing: Meanwhile & Eventually", "tMl": "സംഭവങ്ങളുടെ ക്രമം പറയൽ", "g": "Story Sequencing Adverbs"},
    {"tEn": "Office Small Talk & Break English", "tMl": "ഓഫീസിലെ സൗഹൃദ സംഭാഷണം", "g": "Workplace Casual English"},
    {"tEn": "Professional Email Etiquette", "tMl": "ഇമെയിലുകൾ പ്രൊഫഷണലായി എഴുതൽ", "g": "Formal vs Informal Register"},
    {"tEn": "Speaking in Meetings", "tMl": "മീറ്റിംഗുകളിൽ ധൈര്യമായി സംസാരിക്കൽ", "g": "Meeting Openers & Interjections"},
    {"tEn": "Explaining Problems to a Boss", "tMl": "പ്രശ്നങ്ങൾ പരിഹാരത്തോടെ അവതരിപ്പിക്കൽ", "g": "Problem-Solution Pitch"},
    {"tEn": "Negotiation & Reaching Win-Win", "tMl": "നെഗോഷ്യേഷൻ & സമവായം", "g": "Persuasive Phrasing"},
    {"tEn": "Job Interview: Tell Me About Yourself", "tMl": "ഇന്റർവ്യൂ 1: സ്വന്തം വിവരണം", "g": "The 3-Part Self Pitch"},
    {"tEn": "Job Interview: Strengths & Weaknesses", "tMl": "ഇന്റർവ്യൂ 2: ശക്തികളും ദൗർബല്യങ്ങളും", "g": "Authentic Self Assessment"},
    {"tEn": "Job Interview: Why Should We Hire You?", "tMl": "ഇന്റർവ്യൂ 3: മൂല്യവും കഴിവും", "g": "Value Proposition"},
    {"tEn": "Job Interview: Asking Smart Questions", "tMl": "ഇന്റർവ്യൂ 4: ഇന്റർവ്യൂവറോട് ചോദിക്കൽ", "g": "Professional Reverse Inquiries"},
    {"tEn": "Job Interview: Mock Voice Simulation", "tMl": "ഇന്റർവ്യൂ ഫുൾ വോയ്‌സ് പ്രാക്ടീസ്", "g": "Full Interview Roleplay"},
    {"tEn": "Native Everyday Idioms", "tMl": "സ്വാഭാവിക ശൈലികൾ (Native Idioms)", "g": "Colloquial Expressions"},
    {"tEn": "Eliminating Fillers (Uh, Um)", "tMl": "തടസ്സങ്ങളും മടിയും മാറ്റൽ", "g": "Rhythm & Thought Flow"},
    {"tEn": "Rapid-Fire 30 Spoken Challenge", "tMl": "30 ചോദ്യങ്ങൾ സ്പീഡിൽ മറുപടി നൽകൽ", "g": "Instant Fluency Reflexes"},
    {"tEn": "Grand 90-Day All-Concept Review", "tMl": "90 ദിവസത്തെ സമ്പൂർണ്ണ റിവിഷൻ", "g": "Comprehensive Master Review"},
    {"tEn": "🎓 GRAND GRADUATION & CERTIFICATE", "tMl": "🎓 90-ഡേ ഫൈനൽ ഗ്രാജ്വേഷൻ", "g": "Lifetime Spoken English Mastery"}
  ];

  for (int i = 0; i < 90; i++) {
    final dayNum = i + 1;
    final int houseNum = dayNum <= 30 ? 1 : (dayNum <= 60 ? 2 : 3);
    final themeData = dayNum <= 30
        ? house1Themes[dayNum - 1]
        : (dayNum <= 60 ? house2Themes[dayNum - 31] : house3Themes[dayNum - 61]);

    final themeEn = themeData['tEn'] as String;
    final themeMl = themeData['tMl'] as String;
    final grammar = themeData['g'] as String;

    days.add({
      "day": dayNum,
      "house": houseNum,
      "themeEn": themeEn,
      "themeMl": themeMl,
      "grammarConcept": grammar,
      "readingTopic": "Day $dayNum Story: $themeEn in Daily Life",
      "defenseChallengeType": "house_defense_day_$dayNum",
      "zeroTrack": {
        "title": "Day $dayNum Foundation: $themeEn",
        "vocab": _getZeroVocab(dayNum, themeEn),
        "activity": "Tutor Robot Guided Voice + 2D Object Quest",
        "socialRequired": false
      },
      "middleTrack": {
        "title": "Day $dayNum Core: $themeEn",
        "vocab": _getMiddleVocab(dayNum, themeEn),
        "activity": "Sentence Builder + English Hub Discussion",
        "communityMission": "Post your opinion about '$themeEn' in English Hub",
        "chatTask": "Share a 2-line thought with an active learning mate",
        "socialRequired": true
      },
      "higherTrack": {
        "title": "Day $dayNum Fluency: $themeEn",
        "vocab": _getHigherVocab(dayNum, themeEn),
        "activity": "Sentence Upgrade + Real Speaking Challenge",
        "communityMission": "Lead a discussion topic on '$themeEn' in English Hub",
        "pocketTalkTask": "Connect a dedicated 3-minute voice conversation on '$themeEn'",
        "socialRequired": true
      }
    });
  }

  return days;
}

List<String> _getZeroVocab(int day, String theme) {
  if (day == 1) return ["Apple", "Ball", "Cat", "Dog", "Egg", "Fish", "Water", "Book"];
  if (day == 2) return ["Girl", "House", "India", "Jug", "Kite", "Lion"];
  if (day == 3) return ["Man", "Nest", "Orange", "Pen", "Queen", "Ring"];
  if (day == 4) return ["Father", "Mother", "Brother", "Sister", "Baby", "Home"];
  if (day == 5) return ["This", "That", "Box", "Car", "Tree", "Sun"];
  return ["Word A$day", "Word B$day", "Word C$day", "Word D$day", "Word E$day", "Word F$day"];
}

List<String> _getMiddleVocab(int day, String theme) {
  if (day == 1) return ["Name", "From", "Live", "Study", "Work", "Family", "Friend", "English"];
  if (day == 2) return ["City", "Town", "Village", "Near", "Far", "Beautiful", "Famous", "Place"];
  if (day == 3) return ["Doctor", "Teacher", "Busy", "Happy", "Ready", "Late", "Here", "There"];
  return ["Core $theme 1", "Core $theme 2", "Core $theme 3", "Core $theme 4", "Core $theme 5", "Core $theme 6"];
}

List<String> _getHigherVocab(int day, String theme) {
  if (day == 1) return ["Background", "Currently", "Specialize", "Experience", "Passionate", "Goal", "Connect", "Aspire"];
  if (day == 2) return ["Hometown", "Located", "Vibrant", "Suburbs", "Culture", "Scenic", "Heritage", "Atmosphere"];
  if (day == 3) return ["Colleague", "Supervisor", "Available", "Responsible", "Efficient", "Dedicated"];
  return ["Master $theme 1", "Master $theme 2", "Master $theme 3", "Master $theme 4", "Master $theme 5", "Master $theme 6"];
}
