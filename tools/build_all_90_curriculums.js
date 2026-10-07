const fs = require('fs');
const path = require('path');

// 90 Comprehensive Days Metadata Table
const DAYS_DATA = [
  // HOUSE 1 (1-30): Foundation & Daily Living
  { day: 1, themeEn: "Me & Identity", themeMl: "ഞാനും അടിസ്ഥാന ഇംഗ്ലീഷും", rule: "Am/Is/Are & Phonics", v: [["be","was","been","ആയിരിക്കുക","I am happy."],["call","called","called","വിളിക്കുക","Call my name."],["have","had","had","ഉണ്ടായിരിക്കുക","I have a pen."],["see","saw","seen","കാണുക","I see you."]], n: [["name","പേര്"],["apple","ആപ്പിൾ"],["book","പുസ്തകം"],["friend","സുഹൃത്ത്"],["water","വെള്ളം"]] },
  { day: 2, themeEn: "Where I Am From & Locations", themeMl: "നാടും സ്ഥലങ്ങളും", rule: "From, In, At (Origins & Locations)", v: [["live","lived","lived","താമസിക്കുക","I live in Kerala."],["stay","stayed","stayed","നിൽക്കുക","I stay at home."],["come","came","come","വരുക","Come to my house."],["reach","reached","reached","എത്തിച്ചേരുക","Reach on time."]], n: [["home","വീട്"],["city","നഗരം"],["village","ഗ്രാമം"],["country","രാജ്യം"],["street","റോഡ്"]] },
  { day: 3, themeEn: "My Family & Relationships", themeMl: "കുടുംബവും ബന്ധങ്ങളും", rule: "This is / These are + Pronouns (My, His, Her)", v: [["love","loved","loved","സ്നേഹിക്കുക","I love my family."],["help","helped","helped","സഹായിക്കുക","Help your brother."],["care","cared","cared","ശ്രദ്ധിക്കുക","Care for parents."],["talk","talked","talked","സംസാരിക്കുക","Talk with sister."]], n: [["father","അച്ഛൻ"],["mother","അമ്മ"],["brother","സഹോദരൻ"],["sister","സഹോദരി"],["family","കുടുംബം"]] },
  { day: 4, themeEn: "Daily Routines & Time", themeMl: "ദൈനംദിന ശീലങ്ങളും സമയവും", rule: "Simple Present V1 (Routines without 'am')", v: [["wake","woke","woken","ഉണരുക","I wake up at 6 AM."],["wash","washed","washed","കഴുകുക","Wash your hands."],["eat","ate","eaten","കഴിക്കുക","Eat breakfast."],["sleep","slept","slept","ഉറങ്ങുക","Sleep early."]], n: [["morning","രാവിലെ"],["night","രാത്രി"],["time","സമയം"],["clock","ക്ലോക്ക്"],["bed","കിടക്ക"]] },
  { day: 5, themeEn: "Demonstratives & Objects", themeMl: "അടുത്തും ദൂരെയുമുള്ള വസ്തുക്കൾ", rule: "This, That, These, Those", v: [["point","pointed","pointed","ചൂണ്ടിക്കാണിക്കുക","Point to that car."],["take","took","taken","എടുക്കുക","Take this book."],["give","gave","given","നൽകുക","Give me that pen."],["keep","kept","kept","വെയ്ക്കുക","Keep those shoes outside."]], n: [["this","ഇത്"],["that","അത്"],["these","ഇവ"],["those","അവ"],["thing","വസ്തു"]] },
  { day: 6, themeEn: "My House & Rooms", themeMl: "വീടും മുറികളും", rule: "Prepositions with Rooms (In the kitchen, bedroom)", v: [["cook","cooked","cooked","പാകം ചെയ്യുക","Cook in the kitchen."],["clean","cleaned","cleaned","വൃത്തിയാക്കുക","Clean your room."],["open","opened","opened","തുറക്കുക","Open the door."],["shut","shut","shut","അടയ്ക്കുക","Shut the window."]], n: [["kitchen","അടുക്കള"],["bedroom","കിടപ്പുമുറി"],["hall","ഹാൾ"],["door","വാതിൽ"],["window","ജനൽ"]] },
  { day: 7, themeEn: "Everyday Household Objects", themeMl: "നിത്യജീവിത സാധനങ്ങൾ", rule: "Articles A & An (A table, An umbrella)", v: [["use","used","used","ഉപയോഗിക്കുക","Use a clean plate."],["hold","held","held","പിടിക്കുക","Hold the cup."],["drop","dropped","dropped","താഴെയിടുക","Don't drop the glass."],["find","found","found","കണ്ടെത്തുക","Find my keys."]], n: [["plate","പ്ലേറ്റ്"],["cup","കപ്പ്"],["chair","കസേര"],["table","മേശ"],["phone","ഫോൺ"]] },
  { day: 8, themeEn: "Numbers, Counting & Plurals", themeMl: "സംഖ്യകളും എണ്ണലും", rule: "Singular vs Plural Nouns (-s / -es)", v: [["count","counted","counted","എണ്ണുക","Count the coins."],["add","added","added","കൂട്ടിച്ചേർക്കുക","Add two spoons."],["buy","bought","bought","വാങ്ങുക","Buy three pens."],["pay","paid","paid","പണം നൽകുക","Pay ten rupees."]], n: [["number","സംഖ്യ"],["money","പണം"],["coin","നാണയം"],["price","വില"],["total","ആകെ"]] },
  { day: 9, themeEn: "Colors & Appearance", themeMl: "നിറങ്ങളും രൂപങ്ങളും", rule: "Adjectives before Nouns (Red car, Big house)", v: [["look","looked","looked","നോക്കുക","Look at the red bird."],["wear","wore","worn","ധരിക്കുക","Wear a blue shirt."],["paint","painted","painted","പെയിന്റ് ചെയ്യുക","Paint it green."],["shine","shone","shone","തിളങ്ങുക","Stars shine bright."]], n: [["color","നിറം"],["red","ചുവപ്പ്"],["blue","നീല"],["green","പച്ച"],["black","കറുപ്പ്"]] },
  { day: 10, themeEn: "Telling Time & Days", themeMl: "സമയവും ദിവസങ്ങളും", rule: "Prepositions of Time: At 5 PM, On Monday, In May", v: [["start","started","started","ആരംഭിക്കുക","Start at 9 AM."],["finish","finished","finished","തീർക്കുക","Finish on Monday."],["wait","waited","waited","കാത്തിരിക്കുക","Wait for 10 minutes."],["hurry","hurried","hurried","തിടുക്കം കൂട്ടുക","Hurry up, time is up."]], n: [["today","ഇന്ന്"],["tomorrow","നാളെ"],["yesterday","ഇന്നലെ"],["week","ആഴ്ച"],["hour","മണിക്കൂർ"]] },
  { day: 11, themeEn: "Morning Productivity", themeMl: "രാവിലത്തെ ശീലങ്ങൾ", rule: "Subject-Verb Agreement (I go vs He goes)", v: [["brush","brushed","brushed","പല്ല് തേക്കുക","Brush twice daily."],["bath","bathed","bathed","കുളിക്കുക","Take a quick bath."],["dress","dressed","dressed","വസ്ത്രം ധരിക്കുക","Dress up neatly."],["leave","left","left","ഇറങ്ങുക","Leave home at 8."]], n: [["teeth","പല്ലുകൾ"],["soap","സോപ്പ്"],["water","വെള്ളം"],["clothes","വസ്ത്രങ്ങൾ"],["bag","ബാഗ്"]] },
  { day: 12, themeEn: "Evening Leisure & Family Time", themeMl: "വൈകുന്നേര ശീലങ്ങൾ", rule: "Habitual Verbs in Daily Routine", v: [["return","returned","returned","തിരികെ എത്തുക","Return home at 6."],["relax","relaxed","relaxed","വിശ്രമിക്കുക","Relax for an hour."],["watch","watched","watched","കാണുക","Watch evening news."],["read","read","read","വായിക്കുക","Read a book."]], n: [["evening","വൈകുന്നേരം"],["tea","ചായ"],["news","വാർത്ത"],["music","സംഗീതം"],["rest","വിശ്രമം"]] },
  { day: 13, themeEn: "Habits with Do vs Does", themeMl: "Do vs Does ശീലങ്ങൾ", rule: "Do with I/You/We/They | Does with He/She/It", v: [["work","worked","worked","ജോലി ചെയ്യുക","He works hard."],["study","studied","studied","പഠിക്കുക","She studies well."],["play","played","played","കളിക്കുക","They play football."],["know","knew","known","അറിയുക","Do you know him?"]], n: [["habit","ശീലം"],["routine","പതിവ്"],["duty","കടമ"],["job","ജോലി"],["skill","കഴിവ്"]] },
  { day: 14, themeEn: "Negatives with Don't & Doesn't", themeMl: "നെഗറ്റീവ് ശീലങ്ങൾ (Don't / Doesn't)", rule: "Don't / Doesn't + V1 (Never add 's' after doesn't)", v: [["like","liked","liked","ഇഷ്ടപ്പെടുക","I don't like junk food."],["smoke","smoked","smoked","പുകവലിക്കുക","He doesn't smoke."],["waste","wasted","wasted","പാഴാക്കുക","Don't waste time."],["fight","fought","fought","വഴക്കിടുക","Don't fight."]], n: [["problem","പ്രശ്നം"],["mistake","തെറ്റ്"],["trouble","ബുദ്ധിമുട്ട്"],["lie","നുണ"],["truth","സത്യം"]] },
  { day: 15, themeEn: "Food, Drinks & Taste", themeMl: "ഭക്ഷണവും പാനീയങ്ങളും", rule: "Expressing Taste & Likes (Spicy, Sweet, Bitter)", v: [["taste","tasted","tasted","രുചിക്കുക","Taste this curry."],["drink","drank","drunk","കുടിക്കുക","Drink warm water."],["smell","smelt","smelt","മണക്കുക","It smells great."],["serve","served","served","വിളമ്പുക","Serve dinner hot."]], n: [["rice","ചോറ്"],["curry","കറി"],["milk","പാൽ"],["sugar","പഞ്ചസാര"],["salt","ഉപ്പ്"]] },
  { day: 16, themeEn: "Spatial Prepositions: In, On, Under, Behind", themeMl: "വസ്തുക്കളുടെ സ്ഥാനങ്ങൾ", rule: "Under, Behind, In front of, Next to", v: [["put","put","put","വെയ്ക്കുക","Put it on the table."],["hide","hid","hidden","ഒളിക്കുക","Hide under the bed."],["stand","stood","stood","നിൽക്കുക","Stand in front of me."],["sit","sat","sat","ഇരിക്കുക","Sit next to him."]], n: [["box","പെട്ടി"],["corner","മൂല"],["wall","മതിൽ"],["floor","തറ"],["roof","മേൽക്കൂര"]] },
  { day: 17, themeEn: "Expressing Abilities: Can & Can't", themeMl: "കഴിവുകൾ (Can & Can't)", rule: "Can / Cannot + V1 (I can speak English)", v: [["speak","spoke","spoken","സംസാരിക്കുക","I can speak English."],["drive","drove","driven","ഓടിക്കുക","He can drive a car."],["swim","swam","swum","നീന്തുക","Can you swim?"],["sing","sang","sung","പാടുക","She can sing well."]], n: [["car","കാർ"],["bike","ബൈക്ക്"],["song","പാട്ട്"],["language","ഭാഷ"],["power","ശക്തി"]] },
  { day: 18, themeEn: "Polite Requests: Can you / Could you?", themeMl: "വിനയത്തോടെയുള്ള ചോദ്യങ്ങൾ", rule: "Could you please + V1 (Polite Requests)", v: [["pass","passed","passed","കൈമാറുക","Could you pass the salt?"],["repeat","repeated","repeated","ആവർത്തിക്കുക","Could you repeat that?"],["explain","explained","explained","വിശദീകരിക്കുക","Please explain this."],["send","sent","sent","അയക്കുക","Could you send the file?"]], n: [["favor","സഹായം"],["message","സന്ദേശം"],["request","അഭ്യർത്ഥന"],["file","ഫയൽ"],["link","ലിങ്ക്"]] },
  { day: 19, themeEn: "Expressing Needs & Desires: Need vs Want", themeMl: "ആവശ്യങ്ങളും ആഗ്രഹങ്ങളും", rule: "Need to + V1 vs Want to + V1", v: [["need","needed","needed","ആവശ്യമായി വരിക","I need to buy medicine."],["want","wanted","wanted","ആഗ്രഹിക്കുക","I want to learn English."],["wish","wished","wished","ആഗ്രഹിക്കുക","I wish you success."],["hope","hoped","hoped","പ്രതീക്ഷിക്കുക","I hope it works."]], n: [["need","ആവശ്യം"],["wish","ആഗ്രഹം"],["plan","പദ്ധതി"],["goal","ലക്ഷ്യം"],["dream","സ്വപ്നം"]] },
  { day: 20, themeEn: "Likes, Preferences & Hobbies", themeMl: "ഇഷ്ടങ്ങളും വിനോദങ്ങളും", rule: "Prefer X to Y / Enjoy + V-ing", v: [["enjoy","enjoyed","enjoyed","ആസ്വദിക്കുക","I enjoy cooking."],["prefer","preferred","preferred","കൂടുതൽ ഇഷ്ടപ്പെടുക","I prefer tea to coffee."],["choose","chose","chosen","തിരഞ്ഞെടുക്കുക","Choose your favorite."],["spend","spent","spent","ചെലവഴിക്കുക","Spend time wisely."]], n: [["hobby","വിനോദം"],["game","കളി"],["movie","സിനിമ"],["travel","യാത്ര"],["book","പുസ്തകം"]] },
  { day: 21, themeEn: "Asking Questions: What & Where", themeMl: "What & Where ചോദ്യങ്ങൾ", rule: "What is...? / Where is...?", v: [["ask","asked","asked","ചോദിക്കുക","Ask a question."],["search","searched","searched","തിരയുക","Search for the keys."],["lose","lost","lost","നഷ്ടപ്പെടുക","Where did you lose it?"],["locate","located","located","കണ്ടെത്തുക","Locate the shop."]], n: [["what","എന്ത്"],["where","എവിടെ"],["place","സ്ഥലം"],["address","മേൽവിലാസം"],["map","മാപ്പ്"]] },
  { day: 22, themeEn: "Asking Questions: When & Why", themeMl: "When & Why ചോദ്യങ്ങൾ", rule: "When do you...? / Why are you...?", v: [["arrive","arrived","arrived","എത്തിച്ചേരുക","When will the bus arrive?"],["delay","delayed","delayed","വൈകിക്കുക","Why was it delayed?"],["leave","left","left","ഇറങ്ങുക","When do you leave?"],["stop","stopped","stopped","നിർത്തുക","Why did you stop?"]], n: [["when","എപ്പോൾ"],["why","എന്തുകൊണ്ട്"],["reason","കാരണം"],["date","തീയതി"],["schedule","സമയം"]] },
  { day: 23, themeEn: "Asking Questions: Who & Which", themeMl: "Who & Which ചോദ്യങ്ങൾ", rule: "Who is that? / Which one do you like?", v: [["meet","met","met","കണ്ടുമുട്ടുക","Who did you meet?"],["pick","picked","picked","തിരഞ്ഞെടുക്കുക","Which color do you pick?"],["know","knew","known","അറിയുക","Who knows the answer?"],["bring","brought","brought","കൊണ്ടുവരിക","Who brought this?"]], n: [["who","ആര്"],["which","ഏത്"],["person","വ്യക്തി"],["choice","തിരഞ്ഞെടുപ്പ്"],["item","വസ്തു"]] },
  { day: 24, themeEn: "Asking Questions: How & How Much", themeMl: "How & How Much ചോദ്യങ്ങൾ", rule: "How are you? / How much does it cost?", v: [["cost","cost","cost","വിലയാകുക","How much does it cost?"],["measure","measured","measured","അളക്കുക","How far is the town?"],["feel","felt","felt","തോന്നുക","How do you feel?"],["weigh","weighed","weighed","ഭാരം തൂക്കുക","How much does it weigh?"]], n: [["how","എങ്ങനെ"],["distance","ദൂരം"],["weight","ഭാരം"],["speed","വേഗത"],["cost","ചെലവ്"]] },
  { day: 25, themeEn: "Buying Groceries & Market Talk", themeMl: "കടയും പച്ചക്കറി വാങ്ങലും", rule: "Quantity Words: Kilo, Packet, Bottle, Dozen", v: [["sell","sold","sold","വിൽക്കുക","He sells fresh fruits."],["bargain","bargained","bargained","വിലപേശുക","Don't bargain here."],["carry","carried","carried","ചുമക്കുക","Carry the grocery bag."],["check","checked","checked","പരിശോധിക്കുക","Check the bill."]], n: [["market","ചന്ത"],["shop","കട"],["vegetable","പച്ചക്കറി"],["fruit","പഴം"],["bill","ബിൽ"]] },
  { day: 26, themeEn: "Giving Simple Directions", themeMl: "വഴികൾ പറഞ്ഞു കൊടുക്കൽ", rule: "Imperative Commands: Turn left, Go straight", v: [["turn","turned","turned","തിരിയുക","Turn left at the signal."],["cross","crossed","crossed","മുറിച്ചുകടക്കുക","Cross the road safely."],["follow","followed","followed","പിന്തുടരുക","Follow this road."],["pass","passed","passed","കടന്നുപോകുക","Pass the temple."]], n: [["left","ഇടത്"],["right","വലത്"],["straight","നേരെ"],["signal","സിഗ്നൽ"],["junction","കവല"]] },
  { day: 27, themeEn: "Health, Body & Minor Ailments", themeMl: "ആരോഗ്യവും അസുഖങ്ങളും", rule: "I have a headache / stomach ache / fever", v: [["hurt","hurt","hurt","വേദനിക്കൽ","My knee hurts."],["ache","ached","ached","വേദനിക്കുക","My head aches."],["cough","coughed","coughed","ചുമയ്ക്കുക","He is coughing."],["rest","rested","rested","വിശ്രമിക്കുക","Take complete rest."]], n: [["headache","തലവേദന"],["fever","പനി"],["cold","ജലദോഷം"],["pain","വേദന"],["doctor","ഡോക്ടർ"]] },
  { day: 28, themeEn: "At the Pharmacy & Medicine", themeMl: "മരുന്നുകടയും കുറിപ്പടിയും", rule: "Dosage instructions: Before/After food, Twice daily", v: [["take","took","taken","കഴിക്കുക","Take this after food."],["prescribe","prescribed","prescribed","കുറിച്ചു നൽകുക","Doctor prescribed pills."],["heal","healed","healed","സുഖപ്പെടുക","It will heal fast."],["swallow","swallowed","swallowed","വിഴുങ്ങുക","Swallow with water."]], n: [["tablet","ഗുളിക"],["syrup","സിറപ്പ്"],["pharmacy","മെഡിക്കൽ ഷോപ്പ്"],["dose","അളവ്"],["prescription","കുറിപ്പടി"]] },
  { day: 29, themeEn: "Weather, Climate & Nature", themeMl: "കാലാവസ്ഥയും പ്രകൃതിയും", rule: "It is sunny / rainy / cloudy / humid", v: [["rain","rained","rained","പെയ്യുക","It is raining outside."],["blow","blew","blown","വീശുക","Cool wind is blowing."],["freeze","froze","frozen","തണുത്തുറയുക","It is freezing cold."],["change","changed","changed","മാറുക","Weather changes fast."]], n: [["weather","കാലാവസ്ഥ"],["rain","മഴ"],["sun","വെയിൽ"],["wind","കാറ്റ്"],["cloud","മേഘം"]] },
  { day: 30, themeEn: "House 1 Grand Review & Gate Exam", themeMl: "ഹൗസ് 1 ഫൈനൽ റിവ്യൂ & എക്സാം", rule: "Full Foundation Integration (Days 1–29)", v: [["review","reviewed","reviewed","വിലയിരുത്തുക","Review your lessons."],["master","mastered","mastered","സ്വായത്തമാക്കുക","Master your grammar."],["pass","passed","passed","വിജയിക്കുക","Pass the gate exam."],["celebrate","celebrated","celebrated","ആഘോഷിക്കുക","Celebrate Day 30."]], n: [["gate","ഗേറ്റ്"],["exam","പരീക്ഷ"],["badge","ബാഡ്ജ്"],["shield","ഷീൽഡ്"],["trophy","ട്രോഫി"]] },

  // HOUSE 2 (31-60): Real-World Social & Time Travel
  { day: 31, themeEn: "Past State: Was vs Were", themeMl: "കഴിഞ്ഞ അവസ്ഥകൾ: Was vs Were", rule: "Was (I/He/She/It) vs Were (You/We/They)", v: [["be","was","been","ആയിരുന്നു","I was at home."],["feel","felt","felt","തോന്നിയിരുന്നു","She felt tired."],["become","became","become","ആയിത്തീരുക","They became happy."],["remain","remained","remained","തുടരുക","He remained silent."]], n: [["past","ഭൂതകാലം"],["state","അവസ്ഥ"],["mood","മനോഭാവം"],["feeling","വികാരം"],["memory","ഓർമ്മ"]] },
  { day: 32, themeEn: "Past Actions: Simple Past V2", themeMl: "ഇന്നലെ ചെയ്ത കാര്യങ്ങൾ (V2)", rule: "Subject + V2 past verb (I visited, I bought)", v: [["visit","visited","visited","സന്ദർശിക്കുക","I visited Munnar."],["cook","cooked","cooked","പാകം ചെയ്തു","Mom cooked biryani."],["buy","bought","bought","വാങ്ങി","I bought a shirt."],["watch","watched","watched","കണ്ടു","We watched a movie."]], n: [["yesterday","ഇന്നലെ"],["trip","യാത്ര"],["dinner","അത്താഴം"],["show","ഷോ"],["event","പരിപാടി"]] },
  { day: 33, themeEn: "Asking in the Past: Did you...?", themeMl: "കഴിഞ്ഞ കാര്യങ്ങൾ ചോദിക്കൽ", rule: "Did + Subject + V1 base verb (Did you go?)", v: [["see","saw","seen","കാണുക","Did you see the match?"],["hear","heard","heard","കേൾക്കുക","Did you hear the news?"],["call","called","called","വിളിക്കുക","Did she call you?"],["understand","understood","understood","മനസ്സിലാക്കുക","Did you understand?"]], n: [["question","ചോദ്യം"],["answer","ഉത്തരം"],["news","വാർത്ത"],["call","കോൾ"],["match","കളി"]] },
  { day: 34, themeEn: "Negative Past: Didn't + V1", themeMl: "ചെയ്യാതിരുന്ന കാര്യങ്ങൾ", rule: "Didn't + V1 (Never use V2 after didn't!)", v: [["know","knew","known","അറിയുക","I didn't know that."],["receive","received","received","ലഭിക്കുക","I didn't receive it."],["attend","attended","attended","പങ്കെടുക്കുക","He didn't attend class."],["agree","agreed","agreed","സമ്മതിക്കുക","They didn't agree."]], n: [["reason","കാരണം"],["excuse","ന്യായീകരണം"],["fault","കുറ്റം"],["doubt","സംശയം"],["notice","അറിയിപ്പ്"]] },
  { day: 35, themeEn: "Yesterday's Full Story", themeMl: "ഇന്നലത്തെ ദിവസത്തിന്റെ വിവരണം", rule: "Time Sequencers: In the morning, Then, Later", v: [["wake","woke","woken","ഉണർന്നു","Yesterday I woke at 7."],["reach","reached","reached","എത്തി","I reached office late."],["complete","completed","completed","പൂർത്തിയാക്കി","I completed the task."],["return","returned","returned","മടങ്ങി","I returned at 8 PM."]], n: [["day","ദിവസം"],["routine","പതിവ്"],["work","ജോലി"],["traffic","ട്രാഫിക്"],["dinner","അത്താഴം"]] },
  { day: 36, themeEn: "Childhood Habits: Used to", themeMl: "പഴയ ശീലങ്ങൾ (Used to)", rule: "Used to + V1 (Things you did in the past but not now)", v: [["play","played","played","കളിച്ചിരുന്നു","I used to play cricket."],["live","lived","lived","താമസിച്ചിരുന്നു","We used to live there."],["read","read","read","വായിച്ചിരുന്നു","I used to read comics."],["swim","swam","swum","നീന്തിയിരുന്നു","I used to swim in river."]], n: [["childhood","കുട്ടിക്കാലം"],["school","സ്കൂൾ"],["village","ഗ്രാമം"],["game","കളി"],["memory","ഓർമ്മ"]] },
  { day: 37, themeEn: "Past Continuous: Was/Were + ing", themeMl: "അപ്പോൾ ചെയ്തുകൊണ്ടിരുന്ന കാര്യങ്ങൾ", rule: "Was/Were + Verb-ing (While I was sleeping)", v: [["sleep","slept","slept","ഉറങ്ങുകയായിരുന്നു","I was sleeping then."],["drive","drove","driven","ഓടിക്കുകയായിരുന്നു","He was driving home."],["study","studied","studied","പഠിക്കുകയായിരുന്നു","They were studying."],["rain","rained","rained","പെയ്യുകയായിരുന്നു","It was raining heavily."]], n: [["moment","നിമിഷം"],["accident","അപകടം"],["call","ഫോൺകോൾ"],["storm","കൊടുങ്കാറ്റ്"],["sound","ശബ്ദം"]] },
  { day: 38, themeEn: "Past Narrative & Incident Storytelling", themeMl: "കഥ പറയൽ: First, Then, Suddenly", v: [["happen","happened","happened","സംഭവിക്കുക","What happened suddenly?"],["shout","shouted","shouted","നിലവിളിക്കുക","Someone shouted loudly."],["run","ran","run","ഓടുക","We ran outside."],["realize","realized","realized","മനസ്സിലാക്കുക","Then I realized the truth."]], n: [["incident","സംഭവം"],["story","കഥ"],["shock","ഞെട്ടൽ"],["crowd","ആളുകൾ"],["end","അവസാനം"]] },
  { day: 39, themeEn: "Future Promises & Instant Decisions: Will", themeMl: "ഭാവി കാര്യങ്ങൾ: Will", rule: "Subject + Will + V1 (I will help you)", v: [["promise","promised","promised","വാഗ്ദാനം ചെയ്യുക","I promise I will help."],["call","called","called","വിളിക്കുക","I will call you tonight."],["send","sent","sent","അയക്കുക","I will send the photo."],["join","joined","joined","ചേരുക","We will join tomorrow."]], n: [["future","ഭാവി"],["promise","വാക്ക്"],["plan","പ്ലാൻ"],["decision","തീരുമാനം"],["hope","പ്രതീക്ഷ"]] },
  { day: 40, themeEn: "Definite Future Plans: Going to", themeMl: "ഉറച്ച പ്ലാനുകൾ: Going to", rule: "Am/Is/Are + Going to + V1 (I am going to buy a car)", v: [["plan","planned","planned","പ്ലാൻ ചെയ്യുക","I am going to buy a car."],["start","started","started","തുടങ്ങാൻ പോകുന്നു","She is going to start gym."],["shift","shifted","shifted","താമസം മാറുക","We are going to shift home."],["travel","traveled","traveled","യാത്ര പോകാൻ പോകുന്നു","He is going to travel."]], n: [["intention","ഉദ്ദേശ്യം"],["preparation","ഒരുക്കം"],["ticket","ടിക്കറ്റ്"],["goal","ലക്ഷ്യം"],["target","ടാർഗെറ്റ്"]] },
  { day: 41, themeEn: "Shopping for Clothes & Trial Room", themeMl: "വസ്ത്രങ്ങൾ വാങ്ങലും ട്രയലും", rule: "Size, Fit, Color & Trial Room Conversation", v: [["fit","fitted","fitted","പാകമാകുക","Does this shirt fit you?"],["try","tried","tried","ധരിച്ചു നോക്കുക","Try this in the trial room."],["change","changed","changed","മാറ്റി വാങ്ങുക","Can I change this size?"],["select","selected","selected","തിരഞ്ഞെടുക്കുക","Select your color."]], n: [["size","സൈസ്"],["shirt","ഷർട്ട്"],["dress","വസ്ത്രം"],["trial","ട്രയൽ"],["discount","കിഴിവ്"]] },
  { day: 42, themeEn: "At a Restaurant: Ordering & Bill", themeMl: "ഹോട്ടലിൽ ഓർഡർ ചെയ്യലും ബില്ലും", rule: "Can I have...? / Could we get the bill?", v: [["order","ordered","ordered","ഓർഡർ ചെയ്യുക","Are you ready to order?"],["taste","tasted","tasted","രുചിക്കുക","The soup tastes great."],["serve","served","served","വിളമ്പുക","Please serve it hot."],["pay","paid","paid","പണം നൽകുക","Can I pay by card?"]], n: [["menu","മെനു"],["waiter","സപ്ലയർ"],["bill","ബിൽ"],["table","മേശ"],["tip","ടിപ്പ്"]] },
  { day: 43, themeEn: "Public Transport: Bus & Train Travel", themeMl: "ബസ്, ട്രെയിൻ യാത്രകൾ", rule: "Asking Timing, Stops & Platforms", v: [["board","boarded","boarded","കയറുക","Board train at platform 2."],["alight","alighted","alighted","ഇറങ്ങുക","Alight at next station."],["miss","missed","missed","നഷ്ടപ്പെടുക","Don't miss the bus."],["announce","announced","announced","അറിയിക്കുക","They announced delay."]], n: [["bus","ബസ്"],["train","ട്രെയിൻ"],["platform","പ്ലാറ്റ്ഫോം"],["seat","സീറ്റ്"],["station","സ്റ്റേഷൻ"]] },
  { day: 44, themeEn: "At the Airport & Flight Journey", themeMl: "വിമാനത്താവളവും ഫ്ലൈറ്റ് യാത്രയും", rule: "Check-in, Boarding, Luggage & Security", v: [["check in","checked in","checked in","ചെക്ക്-ഇൻ ചെയ്യുക","Check in your luggage."],["board","boarded","boarded","കയറുക","Board the flight."],["land","landed","landed","ഇറങ്ങുക","Flight landed safely."],["fly","flew","flown","പറക്കുക","We are flying to Dubai."]], n: [["airport","എയർപോർട്ട്"],["flight","ഫ്ലൈറ്റ്"],["passport","പാസ്പോർട്ട്"],["gate","ഗേറ്റ്"],["luggage","ലഗേജ്"]] },
  { day: 45, themeEn: "Hotel Stay & Check-in", themeMl: "ഹോട്ടൽ ബുക്കിംഗും താമസവും", rule: "I have a reservation under the name...", v: [["book","booked","booked","ബുക്ക് ചെയ്യുക","I booked a room online."],["stay","stayed","stayed","താമസിക്കുക","We stay for two nights."],["request","requested","requested","ആവശ്യപ്പെടുക","Request extra towel."],["check out","checked out","checked out","റൂം ഒഴിയുക","Check out is at 11 AM."]], n: [["room","മുറി"],["key","താക്കോൽ"],["reception","റിസപ്ഷൻ"],["wifi","വൈഫൈ"],["breakfast","പ്രഭാതഭക്ഷണം"]] },
  { day: 46, themeEn: "Tomorrow's Schedule & Appointments", themeMl: "നാളത്തെ അപ്പോയിന്റ്മെന്റുകൾ", rule: "Setting & Confirming Meeting Times", v: [["schedule","scheduled","scheduled","സമയം നിശ്ചയിക്കുക","Schedule a meeting."],["confirm","confirmed","confirmed","ഉറപ്പാക്കുക","Please confirm my slot."],["postpone","postponed","postponed","മാറ്റിവെയ്ക്കുക","Can we postpone it?"],["attend","attended","attended","പങ്കെടുക്കുക","I will attend on time."]], n: [["appointment","അപ്പോയിന്റ്മെന്റ്"],["meeting","മീറ്റിംഗ്"],["calendar","കലണ്ടർ"],["reminder","ഓർമ്മപ്പെടുത്തൽ"],["time","സമയം"]] },
  { day: 47, themeEn: "Polite Invitations: Would you like to...?", themeMl: "വിനയത്തോടെ ക്ഷണിക്കൽ", rule: "Would you like + to V1 / noun (Would you like tea?)", v: [["invite","invited","invited","ക്ഷണിക്കുക","I invite you to dinner."],["join","joined","joined","കൂടുക","Would you like to join?"],["visit","visited","visited","സന്ദർശിക്കുക","Would you like to visit?"],["come","came","come","വരുക","Please come over."]], n: [["invitation","ക്ഷണം"],["party","പാർട്ടി"],["tea","ചായ"],["guest","അതിഥി"],["weekend","വാരാന്ത്യം"]] },
  { day: 48, themeEn: "Polite Requests: Could you please...", themeMl: "മാന്യമായ ആവശ്യപ്പെടലുകൾ", rule: "Could you please + V1 / Would you mind + V-ing", v: [["mind","minded","minded","വിഷമമാവുക","Would you mind closing door?"],["favor","favored","favored","സഹായിക്കുക","Could you do me a favor?"],["pass","passed","passed","കൈമാറുക","Could you pass the water?"],["lend","lent","lent","കടം നൽകുക","Could you lend your pen?"]], n: [["politeness","വിനയം"],["favor","സഹായം"],["help","സഹായം"],["respect","ബഹുമാനം"],["tone","ശബ്ദരീതി"]] },
  { day: 49, themeEn: "Giving Advice: Should & Ought to", themeMl: "ഉപദേശങ്ങൾ നൽകൽ (Should)", rule: "You should + V1 (You should sleep early)", v: [["advise","advised","advised","ഉപദേശിക്കുക","Doctor advised rest."],["exercise","exercised","exercised","വ്യായാമം ചെയ്യുക","You should exercise daily."],["avoid","avoided","avoided","ഒഴിവാക്കുക","You should avoid sugar."],["consult","consulted","consulted","കാണുക","You should consult doctor."]], n: [["advice","ഉപദേശം"],["health","ആരോഗ്യം"],["diet","ഭക്ഷണരീതി"],["habit","ശീലം"],["tip","നുറുങ്ങുവിദ്യ"]] },
  { day: 50, themeEn: "Compulsion & Rules: Must vs Have to", themeMl: "നിർബന്ധങ്ങൾ: Must vs Have to", rule: "Must (Personal/Strict) vs Have to (External rule)", v: [["follow","followed","followed","പാലിക്കുക","You must follow rules."],["wear","wore","worn","ധരിക്കുക","You must wear a helmet."],["submit","submitted","submitted","സമർപ്പിക്കുക","I have to submit today."],["obey","obeyed","obeyed","അനുസരിക്കുക","We must obey traffic."]], n: [["rule","നിയമം"],["law","നിയമം"],["helmet","ഹെൽമെറ്റ്"],["duty","കടമ"],["license","ലൈസൻസ്"]] },
  { day: 51, themeEn: "Accepting & Declining Politely", themeMl: "ക്ഷണം സ്വീകരിക്കലും നിരസിക്കലും", rule: "I'd love to! vs I wish I could, but...", v: [["accept","accepted","accepted","സ്വീകരിക്കുക","I happily accept."],["decline","declined","declined","നിരസിക്കുക","I must decline politely."],["apologize","apologized","apologized","ക്ഷമ ചോദിക്കുക","I apologize for the delay."],["appreciate","appreciated","appreciated","വിലമതിക്കുക","I appreciate your invite."]], n: [["excuse","കാരണം"],["regret","വിഷമം"],["thanks","നന്ദി"],["chance","അവസരം"],["next time","അടുത്ത തവണ"]] },
  { day: 52, themeEn: "Expressing Feelings & Emotions", themeMl: "വികാരങ്ങളും മാനസികാവസ്ഥയും", rule: "I feel proud / nervous / thrilled / upset", v: [["feel","felt","felt","തോന്നുക","I feel confident now."],["worry","worried","worried","ആശങ്കപ്പെടുക","Don't worry at all."],["cheer","cheered","cheered","സന്തോഷിപ്പിക്കുക","Cheer up, all is well."],["calm","calmed","calmed","ശാന്തമാവുക","Calm down and breathe."]], n: [["emotion","വികാരം"],["happy","സന്തോഷം"],["fear","ഭയം"],["courage","ധൈര്യം"],["peace","സമാധാനം"]] },
  { day: 53, themeEn: "Handling Complaints & Polite Feedback", themeMl: "പരാതികളും ഫീഡ്ബാക്കും", rule: "I am afraid there is a problem with...", v: [["complain","complained","complained","പരാതിപ്പെടുക","I have a small complaint."],["replace","replaced","replaced","മാറ്റി നൽകുക","Could you replace this?"],["fix","fixed","fixed","നന്നാക്കുക","Please fix the issue."],["refund","refunded","refunded","പണം തിരികെ നൽകുക","Can I get a refund?"]], n: [["issue","പ്രശ്നം"],["damage","കേടുപാട്"],["service","സേവനം"],["feedback","അഭിപ്രായം"],["manager","മാനേജർ"]] },
  { day: 54, themeEn: "Banking & Money Transactions", themeMl: "ബാങ്കും പണമിടപാടുകളും", rule: "Deposit, Withdraw, Transfer, UPI & Balance", v: [["deposit","deposited","deposited","നിക്ഷേപിക്കുക","Deposit money in account."],["withdraw","withdrew","withdrawn","പിൻവലിക്കുക","Withdraw cash from ATM."],["transfer","transferred","transferred","കൈമാറുക","Transfer via UPI."],["save","saved","saved","സൂക്ഷിക്കുക","Save monthly income."]], n: [["bank","ബാങ്ക്"],["account","അക്കൗണ്ട്"],["atm","എടിഎം"],["balance","ബാക്കി തുക"],["cash","പണം"]] },
  { day: 55, themeEn: "Technology, Mobiles & Connectivity", themeMl: "മൊബൈൽ, വൈഫൈ, സാങ്കേതികവിദ്യ", rule: "My battery is low / Network is weak / Restart", v: [["charge","charged","charged","ചാർജ് ചെയ്യുക","Charge your phone."],["connect","connected","connected","ബന്ധിപ്പിക്കുക","Connect to WiFi."],["download","downloaded","downloaded","ഡൗൺലോഡ് ചെയ്യുക","Download the update."],["restart","restarted","restarted","റീസ്റ്റാർട്ട് ചെയ്യുക","Restart the device."]], n: [["mobile","മൊബൈൽ"],["battery","ബാറ്ററി"],["network","നെറ്റ്‌വർക്ക്"],["wifi","വൈഫൈ"],["password","പാസ്‌വേഡ്"]] },
  { day: 56, themeEn: "Lost Items & Urgent Emergencies", themeMl: "സാധനങ്ങൾ നഷ്ടപ്പെടലും അത്യാഹിതങ്ങളും", rule: "I lost my... / Please call an ambulance / Urgent", v: [["lose","lost","lost","നഷ്ടപ്പെടുക","I lost my wallet."],["search","searched","searched","തിരയുക","We searched everywhere."],["report","reported","reported","പരാതി നൽകുക","Report to local police."],["rescue","rescued","rescued","രക്ഷിക്കുക","Rescue team arrived."]], n: [["wallet","വാലറ്റ്"],["police","പോലീസ്"],["emergency","അടിയന്തരാവസ്ഥ"],["help","സഹായം"],["danger","അപകടം"]] },
  { day: 57, themeEn: "Doctor Consultation: Explaining Symptoms", themeMl: "ഡോക്ടറോട് ലക്ഷണങ്ങൾ പറയൽ", rule: "I have been having this pain since yesterday", v: [["examine","examined","examined","പരിശോധിക്കുക","Doctor examined my chest."],["suffer","suffered","suffered","കഷ്ടപ്പെടുക","I am suffering from flu."],["recover","recovered","recovered","സുഖപ്പെടുക","You will recover soon."],["inject","injected","injected","കുത്തിവെയ്ക്കുക","Nurse injected medicine."]], n: [["symptom","ലക്ഷണം"],["clinic","ക്ലിനിക്ക്"],["infection","അണുബാധ"],["rest","വിശ്രമം"],["health","ആരോഗ്യം"]] },
  { day: 58, themeEn: "Rapid Fire Reflex Drills: Spontaneous Speech", themeMl: "വേഗത്തിലുള്ള മറുപടികൾ (Reflex)", rule: "Eliminating Translation Delay: Direct English Response", v: [["react","reacted","reacted","പ്രതികരിക്കുക","React within 3 seconds."],["speak","spoke","spoken","സംസാരിക്കുക","Speak without pause."],["think","thought","thought","ചിന്തിക്കുക","Think directly in English."],["reply","replied","replied","മറുപടി നൽകുക","Reply with confidence."]], n: [["speed","വേഗത"],["reflex","പ്രതികരണം"],["fluency","ഒഴുക്ക്"],["habit","ശീലം"],["confidence","ആത്മവിശ്വാസം"]] },
  { day: 59, themeEn: "Social Small Talk with Strangers", themeMl: "അപരിചിതരുമായുള്ള സൗഹൃദ സംഭാഷണം", rule: "Weather, Commute, Compliments & Safe Topics", v: [["compliment","complimented","complimented","പ്രശംസിക്കുക","Compliment their watch."],["chat","chatted","chatted","സൊറ പറയുക","Chat during the train ride."],["smile","smiled","smiled","പുഞ്ചിരിക്കുക","Smile and greet."],["introduce","introduced","introduced","പരിചയപ്പെടുത്തുക","Introduce casually."]], n: [["stranger","അപരിചിതൻ"],["weather","കാലാവസ്ഥ"],["journey","യാത്ര"],["topic","വിഷയം"],["smile","ചിരി"]] },
  { day: 60, themeEn: "House 2 Grand Review & Gate Exam", themeMl: "ഹൗസ് 2 ഫൈനൽ റിവ്യൂ & എക്സാം", rule: "Past, Future, Modals & Situation Integration", v: [["conquer","conquered","conquered","കീഴടക്കുക","Conquer House 2."],["celebrate","celebrated","celebrated","ആഘോഷിക്കുക","Celebrate milestone."],["advance","advanced","advanced","മുന്നേറുക","Advance to House 3."],["prove","proved","proved","തെളിയിക്കുക","Prove your fluency."]], n: [["trophy","ട്രോഫി"],["level","ലെവൽ"],["milestone","മൈൽസ്റ്റോൺ"],["exam","പരീക്ഷ"],["success","വിജയം"]] },

  // HOUSE 3 (61-90): Professional Fluency & Career Mastery
  { day: 61, themeEn: "Present Perfect: Have/Has + V3", themeMl: "ചെയ്തു കഴിഞ്ഞ കാര്യങ്ങൾ: Have/Has + V3", rule: "Have/Has + V3 (Action completed with present connection)", v: [["finish","finished","finished","പൂർത്തിയാക്കി","I have finished my work."],["eat","ate","eaten","കഴിച്ചു","She has eaten lunch."],["clean","cleaned","cleaned","വൃത്തിയാക്കി","We have cleaned the room."],["write","wrote","written","എഴുതിക്കഴിഞ്ഞു","He has written the email."]], n: [["action","പ്രവൃത്തി"],["result","ഫലം"],["completion","പൂർത്തീകരണം"],["task","ജോലി"],["status","അവസ്ഥ"]] },
  { day: 62, themeEn: "Life Experiences: Have you ever...?", themeMl: "ജീവിതാനുഭവങ്ങൾ: Have you ever...?", rule: "Have you ever + V3? / I have never + V3", v: [["travel","traveled","traveled","യാത്ര ചെയ്തിട്ടുണ്ടോ","Have you ever traveled abroad?"],["taste","tasted","tasted","രുചിച്ചിട്ടുണ്ടോ","Have you ever tasted sushi?"],["fly","flew","flown","വിമാനത്തിൽ പറന്നിട്ടുണ്ടോ","Have you ever flown in a plane?"],["meet","met","met","കണ്ടിട്ടുണ്ടോ","Have you ever met a celebrity?"]], n: [["experience","അനുഭവം"],["life","ജീവിതം"],["adventure","സാഹസികത"],["abroad","വിദേശം"],["memory","ഓർമ്മ"]] },
  { day: 63, themeEn: "Just, Already & Yet", themeMl: "Just, Already, Yet പ്രയോഗങ്ങൾ", rule: "Just (ഇപ്പോൾ തന്നെ) | Already (നേരത്തെ തന്നെ) | Yet (ഇതുവരെ ഇല്ല)", v: [["arrive","arrived","arrived","എത്തിച്ചേർന്നു","Train has just arrived."],["send","sent","sent","അയച്ചു കഴിഞ്ഞു","I have already sent it."],["receive","received","received","ലഭിച്ചിട്ടില്ല","I haven't received it yet."],["decide","decided","decided","തീരുമാനിച്ചിട്ടില്ല","We haven't decided yet."]], n: [["time","സമയം"],["mail","മെയിൽ"],["status","നിലവിലെ അവസ്ഥ"],["update","വിവരം"],["reply","മറുപടി"]] },
  { day: 64, themeEn: "Since vs For: Duration of Action", themeMl: "Since vs For (കാലയളവ് പറയൽ)", rule: "Since + Starting point (Since 2020) | For + Period (For 3 years)", v: [["live","lived","lived","താമസിച്ചുവരുന്നു","I have lived here for 5 years."],["work","worked","worked","ജോലി ചെയ്യുന്നു","She has worked here since May."],["wait","waited","waited","കാത്തിരിക്കുന്നു","I have waited for two hours."],["know","knew","known","പരിചയമുണ്ട്","We have known each other since school."]], n: [["duration","കാലയളവ്"],["year","വർഷം"],["month","മാസം"],["period","സമയം"],["beginning","തുടക്കം"]] },
  { day: 65, themeEn: "Present Perfect Continuous: Have been doing", themeMl: "തുടർന്നുകൊണ്ടേയിരിക്കുന്ന കാര്യങ്ങൾ", rule: "Have/Has been + V-ing (Action started in past and still continuing)", v: [["learn","learned","learned","പഠിച്ചുകൊണ്ടിരിക്കുന്നു","I have been learning English for months."],["practice","practiced","practiced","പരിശീലിച്ചുവരുന്നു","He has been practicing speaking."],["rain","rained","rained","പെയ്തുകൊണ്ടേയിരിക്കുന്നു","It has been raining since morning."],["work","worked","worked","ജോലി ചെയ്തുകൊണ്ടിരിക്കുന്നു","I have been working on this code."]], n: [["progress","പുരോഗതി"],["continuity","തുടർച്ച"],["habit","ശീലം"],["effort","ശ്രമം"],["streak","സ്ട്രോക്ക്"]] },
  { day: 66, themeEn: "Describing Career & Work Experience", themeMl: "തൊഴിൽ പരിചയം വിവരിക്കൽ", rule: "I have been working as a [Role] for [Years]", v: [["manage","managed","managed","കൈകാര്യം ചെയ്യുക","I manage client communications."],["handle","handled","handled","നോക്കുക","I handle software projects."],["lead","led","led","നയിക്കുക","I lead a team of five."],["deliver","delivered","delivered","പൂർത്തിയാക്കുക","We deliver on deadlines."]], n: [["career","തൊഴിൽ"],["experience","പരിചയം"],["role","പദവി"],["team","ടീം"],["company","കമ്പനി"]] },
  { day: 67, themeEn: "Connecting Ideas: Because & So", themeMl: "കാരണവും ഫലവും പറയൽ (Because & So)", rule: "Cause (Because) vs Result (So)", v: [["study","studied","studied","പഠിച്ചു","I studied hard, so I passed."],["tire","tired","tired","ക്ഷീണിച്ചു","I was tired, so I slept."],["succeed","succeeded","succeeded","വിജയിച്ചു","He succeeded because he persisted."],["improve","improved","improved","മെച്ചപ്പെട്ടു","English improved because I practiced."]], n: [["reason","കാരണം"],["result","ഫലം"],["effort","പ്രയത്നം"],["success","വിജയം"],["connection","ബന്ധം"]] },
  { day: 68, themeEn: "Contrast Connectors: Although, However, But", themeMl: "വൈരുദ്ധ്യങ്ങൾ പറയൽ (Although / However)", rule: "Although + Clause (Although it rained, we enjoyed)", v: [["try","tried","tried","ശ്രമിച്ചു","Although he tried, it was hard."],["continue","continued","continued","തുടർന്നു","However, we continued forward."],["win","won","won","ജയിച്ചു","Although tired, they won."],["learn","learned","learned","പഠിച്ചു","It was tough; however, I learned."]], n: [["contrast","വൈരുദ്ധ്യം"],["challenge","വെല്ലുവിളി"],["effort","ശ്രമം"],["victory","വിജയം"],["fact","വസ്തുത"]] },
  { day: 69, themeEn: "Real Conditions: If it rains, I will stay", themeMl: "സാധ്യമായ നിബന്ധനകൾ (First Conditional)", rule: "If + Present Simple, Will + V1", v: [["rain","rained","rained","മഴ പെയ്താൽ","If it rains, we will stay home."],["call","called","called","വിളിച്ചാൽ","If you call, I will answer."],["practice","practiced","practiced","പരിശീലിച്ചാൽ","If you practice, you will speak."],["come","came","come","വന്നാൽ","If you come, I will cook."]], n: [["condition","നിബന്ധന"],["chance","സാധ്യത"],["plan","തീരുമാനം"],["future","ഭാവി"],["result","ഫലം"]] },
  { day: 70, themeEn: "Imaginary Situations: If I were... / Would", themeMl: "സങ്കൽപ്പങ്ങൾ (Second Conditional)", rule: "If + Past Simple, Would + V1 (If I had money, I would travel)", v: [["travel","traveled","traveled","യാത്ര ചെയ്യുമായിരുന്നു","If I had time, I would travel."],["buy","bought","bought","വാങ്ങുമായിരുന്നു","If I won, I would buy a house."],["help","helped","helped","സഹായിക്കുമായിരുന്നു","If I knew, I would help."],["fly","flew","flown","പറക്കുമായിരുന്നു","If I had wings, I would fly."]], n: [["dream","സ്വപ്നം"],["imagination","സങ്കൽപ്പം"],["wish","ആഗ്രഹം"],["world","ലോകം"],["freedom","സ്വാതന്ത്ര്യം"]] },
  { day: 71, themeEn: "Modals of Probability: May, Might, Could", themeMl: "സാധ്യതകൾ: May, Might, Could", rule: "Expressing 50% vs 30% Probability", v: [["rain","rained","rained","മഴ പെയ്തേക്കാം","It might rain this evening."],["visit","visited","visited","വന്നേക്കാം","He may visit us today."],["succeed","succeeded","succeeded","വിജയിച്ചേക്കാം","The plan could succeed."],["delay","delayed","delayed","വൈകിയേക്കാം","The train might be delayed."]], n: [["probability","സാധ്യത"],["guess","ഊഹം"],["chance","അവസരം"],["doubt","സംശയം"],["weather","കാലാവസ്ഥ"]] },
  { day: 72, themeEn: "Logical Deductions: Must be vs Can't be", themeMl: "യുക്തിപരമായ നിഗമനങ്ങൾ (Must be / Can't be)", rule: "Must be (തീർച്ചയായും ആയിരിക്കും) | Can't be (ഒരിക്കലും ആകില്ല)", v: [["be","was","been","ആയിരിക്കും","He must be tired after work."],["joke","joked","joked","തമാശ പറയുക","You can't be serious; it must be a joke."],["lie","lied","lied","നുണ പറയുക","She can't be lying."],["know","knew","known","അറിയുമായിരിക്കും","He must know the truth."]], n: [["logic","യുക്തി"],["deduction","നിഗമനം"],["fact","സത്യം"],["truth","സത്യം"],["proof","തെളിവ്"]] },
  { day: 73, themeEn: "Passive Voice in Daily Spoken Speech", themeMl: "നിത്യജീവിതത്തിലെ പാസ്സീവ് വോയ്സ്", rule: "The flight is delayed / I was told / It is made of...", v: [["delay","delayed","delayed","വൈകിപ്പിക്കപ്പെട്ടു","The flight was delayed."],["inform","informed","informed","അറിയിക്കപ്പെട്ടു","I was informed yesterday."],["cancel","cancelled","cancelled","റദ്ദാക്കപ്പെട്ടു","The match was cancelled."],["repair","repaired","repaired","നന്നാക്കപ്പെട്ടു","My phone is repaired."]], n: [["announcement","അറിയിപ്പ്"],["service","സേവനം"],["status","നിലവിലെ അവസ്ഥ"],["flight","ഫ്ലൈറ്റ്"],["notice","നോട്ടീസ്"]] },
  { day: 74, themeEn: "Professional Telephone Etiquette", themeMl: "ഓഫീസ് ഫോൺ കോളുകൾ", rule: "May I speak with...? / May I ask who is calling?", v: [["connect","connected","connected","ബന്ധിപ്പിക്കുക","Could you connect me to HR?"],["hold","held","held","ഹോൾഡ് ചെയ്യുക","Please hold the line."],["transfer","transferred","transferred","കൈമാറുക","I will transfer your call."],["call back","called back","called back","തിരികെ വിളിക്കുക","I will call you back shortly."]], n: [["call","കോൾ"],["line","ലൈൻ"],["reception","റിസപ്ഷൻ"],["message","മെസ്സേജ്"],["contact","കോൺടാക്ട്"]] },
  { day: 75, themeEn: "Taking Messages & Leaving Voicemails", themeMl: "വോയ്‌സ് മെസ്സേജുകളും സന്ദേശങ്ങളും", rule: "Could you take a message? / Please tell him that...", v: [["leave","left","left","നൽകുക","Can I leave a message?"],["note","noted","noted","കുറിച്ചെടുക്കുക","I have noted down your number."],["deliver","delivered","delivered","എത്തിക്കുക","I will deliver the message."],["remind","reminded","reminded","ഓർമ്മിപ്പിക്കുക","Please remind him to call."]], n: [["voicemail","വോയ്‌സ് മെയിൽ"],["note","കുറിപ്പ്"],["number","ഫോൺ നമ്പർ"],["client","ക്ലയന്റ്"],["urgent","അടിയന്തിരം"]] },
  { day: 76, themeEn: "Office Small Talk & Break Room English", themeMl: "ഓഫീസിലെ സൗഹൃദ സംഭാഷണം", rule: "Casual Workplace Interaction: Projects, Weekend, Coffee", v: [["grab","grabbed","grabbed","കുടിക്കുക","Let's grab a coffee."],["catch up","caught up","caught up","വിശേഷങ്ങൾ പങ്കിടുക","Good to catch up with you."],["wrap up","wrapped up","wrapped up","പൂർത്തിയാക്കുക","Let's wrap up this task."],["head out","headed out","headed out","ഇറങ്ങുക","Are you heading out now?"]], n: [["coffee","കോഫി"],["weekend","വാരാന്ത്യം"],["project","പ്രോജക്ട്"],["break","ഇടവേള"],["colleague","സഹപ്രവർത്തകൻ"]] },
  { day: 77, themeEn: "Daily Standups & Meeting Updates", themeMl: "ഓഫീസ് മീറ്റിംഗുകളും അപ്‌ഡേറ്റുകളും", rule: "Yesterday I completed..., Today I am working on..., No blockers.", v: [["update","updated","updated","വിവരങ്ങൾ അറിയിക്കുക","Here is my daily update."],["block","blocked","blocked","തടസ്സപ്പെടുക","I have no blockers today."],["collaborate","collaborated","collaborated","ഒരുമിച്ച് പ്രവർത്തിക്കുക","I will collaborate with team."],["sync","synced","synced","ഏകോപിപ്പിക്കുക","Let's sync up after lunch."]], n: [["standup","സ്റ്റാൻഡ് അപ്പ്"],["task","ടാസ്ക്"],["blocker","തടസ്സം"],["milestone","മൈൽസ്റ്റോൺ"],["deadline","ഡെഡ്‌ലൈൻ"]] },
  { day: 78, themeEn: "Giving Professional Opinions Politely", themeMl: "അഭിപ്രായങ്ങൾ മാന്യമായി പറയൽ", rule: "In my opinion / From my perspective / As far as I can tell", v: [["suggest","suggested","suggested","നിർദ്ദേശിക്കുക","I suggest we try this approach."],["recommend","recommended","recommended","ശുപാർശ ചെയ്യുക","I highly recommend this tool."],["view","viewed","viewed","വീക്ഷിക്കുക","From my point of view, it works."],["clarify","clarified","clarified","വ്യക്തമാക്കുക","Let me clarify my point."]], n: [["opinion","അഭിപ്രായം"],["perspective","കാഴ്ചപ്പാട്"],["viewpoint","നിലപാട്"],["solution","പരിഹാരം"],["approach","സമീപനം"]] },
  { day: 79, themeEn: "Diplomatic Disagreement & Debating", themeMl: "മാന്യമായി വിയോജിപ്പ് അറിയിക്കൽ", rule: "I see your point, but... / Respectfully, I disagree", v: [["disagree","disagreed","disagreed","വിയോജിക്കുക","I respectfully disagree."],["appreciate","appreciated","appreciated","വിലമതിക്കുക","I appreciate your thought, but..."],["reconsider","reconsidered","reconsidered","പുനഃപരിശോധിക്കുക","Can we reconsider this?"],["conclude","concluded","concluded","ഉപസംഹരിക്കുക","Let's conclude positively."]], n: [["debate","സംവാദം"],["diplomacy","നയതന്ത്രം"],["argument","വാദം"],["respect","ബഹുമാനം"],["consensus","യോജിപ്പ്"]] },
  { day: 80, themeEn: "Delivering Confident Presentations", themeMl: "പ്രസന്റേഷനുകൾ അവതരിപ്പിക്കൽ", rule: "Signposting: First, moving on to, finally, to conclude", v: [["present","presented","presented","അവതരിപ്പിക്കുക","I am excited to present this."],["highlight","highlighted","highlighted","എടുത്തുപറയുക","Let me highlight key benefits."],["summarize","summarized","summarized","ചുരുക്കി പറയുക","To summarize the main points..."],["invite","invited","invited","ക്ഷണിക്കുക","Now I invite any questions."]], n: [["slide","സ്ലൈഡ്"],["presentation","പ്രസന്റേഷൻ"],["audience","കേൾവിക്കാർ"],["topic","വിഷയം"],["overview","അവലോകനം"]] },
  { day: 81, themeEn: "Job Interview Part 1: 'Tell Me About Yourself'", themeMl: "ഇന്റർവ്യൂ 1: സ്വന്തം വിവരണം (Self Pitch)", rule: "The 3-Part Pitch: Past Background + Present Role + Future Goal", v: [["introduce","introduced","introduced","പരിചയപ്പെടുത്തുക","Allow me to introduce myself."],["graduate","graduated","graduated","ബിരുദം നേടുക","I graduated in engineering."],["specialize","specialized","specialized","പ്രാവീണ്യം നേടുക","I specialize in communication."],["aspire","aspired","aspired","ആഗ്രഹിക്കുക","I aspire to grow in this role."]], n: [["interview","ഇന്റർവ്യൂ"],["candidate","അഭ്യർത്ഥി"],["pitch","വിവരണം"],["passion","താൽപര്യം"],["opportunity","അവസരം"]] },
  { day: 82, themeEn: "Job Interview Part 2: Strengths & Weaknesses", themeMl: "ഇന്റർവ്യൂ 2: കരുത്തും ദൗർബല്യങ്ങളും", rule: "Framing weaknesses constructively into learning habits", v: [["strengthen","strengthened","strengthened","ശക്തിപ്പെടുത്തുക","My greatest strength is adaptability."],["overcome","overcame","overcome","മറികടക്കുക","I overcame stage fear through practice."],["learn","learned","learned","പഠിക്കുക","I actively learn from mistakes."],["adapt","adapted","adapted","പൊരുത്തപ്പെടുക","I adapt quickly to change."]], n: [["strength","കരുത്ത്"],["weakness","ദൗർബല്യം"],["growth","വളർച്ച"],["discipline","അച്ചടക്കം"],["focus","ശ്രദ്ധ"]] },
  { day: 83, themeEn: "Job Interview Part 3: The STAR Method", themeMl: "ഇന്റർവ്യൂ 3: STAR രീതി (Situation, Task, Action, Result)", rule: "Storytelling Framework: Situation -> Task -> Action -> Result", v: [["resolve","resolved","resolved","പരിഹരിക്കുക","I resolved the conflict effectively."],["achieve","achieved","achieved","കൈവരിക്കുക","We achieved 100% target."],["execute","executed","executed","നടപ്പിലാക്കുക","I executed the action plan."],["deliver","delivered","delivered","സമർപ്പിക്കുക","Delivered results under budget."]], n: [["situation","സാഹചര്യം"],["task","ചുമതല"],["action","നടപടി"],["result","ഫലം"],["achievement","നേട്ടം"]] },
  { day: 84, themeEn: "Job Interview Part 4: Asking Smart Questions", themeMl: "ഇന്റർവ്യൂ 4: ഇന്റർവ്യൂവറോട് ചോദ്യങ്ങൾ ചോദിക്കൽ", rule: "What does success look like in this role? / Team Culture", v: [["inquire","inquired","inquired","അന്വേഷിക്കുക","May I inquire about team culture?"],["clarify","clarified","clarified","വ്യക്തത വരുത്തുക","Could you clarify the expectations?"],["understand","understood","understood","മനസ്സിലാക്കുക","I want to understand the roadmap."],["value","valued","valued","വിലമതിക്കുക","I value long-term mentorship."]], n: [["culture","സംസ്കാരം"],["growth","വളർച്ച"],["expectation","പ്രതീക്ഷ"],["team","ടീം"],["future","ഭാവി"]] },
  { day: 85, themeEn: "Salary Negotiation & Offer Discussion", themeMl: "ശമ്പള ചർച്ചയും ജോലി ഓഫറും", rule: "Discussing compensation package with confidence & diplomacy", v: [["negotiate","negotiated","negotiated","ചർച്ച ചെയ്യുക","I would like to negotiate the offer."],["evaluate","evaluated","evaluated","വിലയിരുത്തുക","Evaluating the overall package."],["accept","accepted","accepted","സ്വീകരിക്കുക","Thrilled to accept the role."],["discuss","discussed","discussed","സംസാരിക്കുക","Can we discuss the start date?"]], n: [["salary","ശമ്പളം"],["package","പാക്കേജ്"],["offer","ഓഫർ"],["benefits","ആനുകൂല്യങ്ങൾ"],["agreement","കരാർ"]] },
  { day: 86, themeEn: "Native Everyday Idioms: Volume 1", themeMl: "സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 1", rule: "Bite the bullet, Break the ice, Piece of cake", v: [["break","broke","broken","തകർക്കുക","Break the ice with a smile."],["bite","bit","bitten","നേരിടുക","Bite the bullet and speak up."],["sail","sailed","sailed","സുഗമമായി മുന്നേറുക","Sailed through the exam."],["cost","cost","cost","വിലയാകുക","It didn't cost an arm and a leg."]], n: [["idiom","ശൈലി"],["expression","പ്രയോഗം"],["meaning","അർത്ഥം"],["flow","ഒഴുക്ക്"],["native","നേറ്റീവ്"]] },
  { day: 87, themeEn: "Native Everyday Idioms: Volume 2", themeMl: "സ്വാഭാവിക ഇംഗ്ലീഷ് ശൈലികൾ 2", rule: "Under the weather, Hit the nail on the head, Once in a blue moon", v: [["hit","hit","hit","കൃത്യമായി പറയുക","You hit the nail on the head."],["miss","missed","missed","നഷ്ടപ്പെടുക","Don't miss the boat."],["burn","burnt","burnt","അദ്ധ്വാനിക്കുക","Burn the midnight oil."],["see","saw","seen","യോജിക്കുക","We see eye to eye."]], n: [["idiom","ശൈലി"],["metaphor","ഉപമ"],["conversation","സംഭാഷണം"],["richness","സമ്പന്നത"],["fluency","ഫ്ലുവെൻസി"]] },
  { day: 88, themeEn: "Essential Workplace Phrasal Verbs", themeMl: "ഓഫീസിലെ ഫ്രേസൽ വെർബുകൾ", rule: "Figure out, Look into, Call off, Follow up, Carry on", v: [["figure out","figured out","figured out","കണ്ടെത്തുക","I figured out the solution."],["look into","looked into","looked into","അന്വേഷിക്കുക","We will look into the matter."],["call off","called off","called off","റദ്ദാക്കുക","They called off the strike."],["follow up","followed up","followed up","തുടർനടപടി സ്വീകരിക്കുക","Follow up with the customer."]], n: [["phrasal verb","ഫ്രേസൽ വെർബ്"],["solution","പരിഹാരം"],["meeting","മീറ്റിംഗ്"],["customer","ഉപഭോക്താവ്"],["matter","കാര്യം"]] },
  { day: 89, themeEn: "Public Speaking & Confident Storytelling", themeMl: "പബ്ലിക് സ്പീക്കിംഗും കഥ പറയലും", rule: "Hook the audience, Speak with conviction, Inspire action", v: [["inspire","inspired","inspired","പ്രചോദിപ്പിക്കുക","Inspire people with your words."],["engage","engaged","engaged","ആകർഷിക്കുക","Engage the audience eyes."],["express","expressed","expressed","പ്രകടിപ്പിക്കുക","Express heartfelt feelings."],["conclude","concluded","concluded","ഉപസംഹരിക്കുക","Conclude on an empowering note."]], n: [["speech","പ്രസംഗം"],["audience","സദസ്സ്"],["voice","ശബ്ദം"],["power","ശക്തി"],["conviction","ഉറച്ച വിശ്വാസം"]] },
  { day: 90, themeEn: "Grand Graduation Day & Lifetime Mastery", themeMl: "90-ഡേ ഫൈനൽ ഗ്രാജ്വേഷൻ & ലൈഫ്‌ടൈം മാസ്റ്ററി", rule: "90-Day Spoken English Master Badge & Lifetime Fluency", v: [["graduate","graduated","graduated","വിജയകരമായി പൂർത്തിയാക്കുക","I graduated the 90-day journey!"],["master","mastered","mastered","സ്വായത്തമാക്കി","I mastered English fluency."],["speak","spoke","spoken","സംസാരിക്കുന്നു","I speak English boldly."],["succeed","succeeded","succeeded","വിജയം നേടി","We succeeded together."]], n: [["certificate","സർട്ടിഫിക്കറ്റ്"],["trophy","ട്രോഫി"],["mastery","മാസ്റ്ററി"],["journey","യാത്ര"],["freedom","സ്വാതന്ത്ര്യം"]] }
];

console.log("Generating 90 individual curriculum files...");

const curriculumDir = path.join(__dirname, '..', 'assets', 'curriculum');
if (!fs.existsSync(curriculumDir)) {
  fs.mkdirSync(curriculumDir, { recursive: true });
}

let generatedCount = 0;

DAYS_DATA.forEach(dayItem => {
  const day = dayItem.day;
  const house = day <= 30 ? 1 : (day <= 60 ? 2 : 3);
  const houseTitles = {
    1: { en: "House 1: Foundation & Daily Living", ml: "ഹൗസ് 1: അടിസ്ഥാനവും ദൈനംദിന ജീവിതവും", hi: "हाउस 1: आधार और दैनिक जीवन", ta: "ஹவுஸ் 1: அடிப்படையும் அன்றாட வாழ்க்கையும்" },
    2: { en: "House 2: Real-World Social & Time Travel", ml: "ഹൗസ് 2: പുറംലോകവും ഭൂത-ഭാവി കാലങ്ങളും", hi: "हाउस 2: वास्तविक दुनिया और समय यात्रा", ta: "ஹவுஸ் 2: நிஜ உலகம் மற்றும் காலப் பயணம்" },
    3: { en: "House 3: Professional Fluency & Career Mastery", ml: "ഹൗസ് 3: ഫ്ലുവെൻസി, കരിയർ & ഇന്റർവ്യൂ മാസ്റ്ററി", hi: "हाउस 3: व्यावसायिक प्रवाह और करियर महारत", ta: "ஹவுஸ் 3: தொழில்முறை சரளமும் வேலை நேர்காணலும்" }
  };

  const isAttackUnlocked = day >= 4;
  const isZeroSocialUnlocked = day >= 10;

  // Build verbs
  const verbsList = dayItem.v.map(vArr => ({
    v1: vArr[0],
    v2: vArr[1],
    v3: vArr[2],
    meaning: { ml: vArr[3], hi: vArr[3], ta: vArr[3] },
    example: vArr[4],
    exampleMl: vArr[3] + " എന്ന അർത്ഥത്തിൽ ഉപയോഗിക്കുന്നു."
  }));

  // Build nouns
  const nounsList = dayItem.n.map(nArr => ({
    word: nArr[0],
    meaning: { ml: nArr[1], hi: nArr[1], ta: nArr[1] },
    example: "This is related to " + nArr[0] + "."
  }));

  // Reading room
  const readingSentences = [
    {
      text: dayItem.v[0][4],
      meaningMl: dayItem.v[0][3] + " - " + dayItem.v[0][4],
      audioPrompt: dayItem.v[0][4]
    },
    {
      text: dayItem.v[1][4],
      meaningMl: dayItem.v[1][3] + " - " + dayItem.v[1][4],
      audioPrompt: dayItem.v[1][4]
    },
    {
      text: "Daily practice of " + dayItem.themeEn + " gives you great confidence in English.",
      meaningMl: dayItem.themeMl + " ദിവസേന പരിശീലിക്കുന്നത് ഇംഗ്ലീഷിൽ വലിയ ആത്മവിശ്വാസം നൽകുന്നു.",
      audioPrompt: "Daily practice of " + dayItem.themeEn + " gives you great confidence in English."
    }
  ];

  // Steps array
  const steps = [
    {
      stepNumber: 1,
      id: "step_1_concept_room",
      title: { en: "Concept Room: " + dayItem.themeEn, ml: "പാഠം: " + dayItem.themeMl },
      icon: "🏛️",
      gameType: "tutor_concept",
      canBeSkipped: false,
      xpReward: 25,
      passScore: 100,
      description: { en: "Interactive Tutor explains today's grammar & spoken formula.", ml: "ഇന്നത്തെ ഗ്രാമർ റൂളും ഫോർമുലയും ട്യൂട്ടർ മലയാളത്തിൽ പറഞ്ഞു തരുന്നു." }
    },
    {
      stepNumber: 2,
      id: "step_2_vocab_vault",
      title: { en: "Vocabulary: Verbs & Key Words", ml: "പദസമ്പത്ത്: ക്രിയകളും പദങ്ങളും" },
      icon: "📦",
      gameType: "vocab_vault",
      canBeSkipped: false,
      xpReward: 30,
      passScore: 80,
      description: { en: "Learn 4 key verbs (V1, V2, V3) and essential topic nouns.", ml: "4 അത്യാവശ്യ ക്രിയകളും (V1, V2, V3) വിഷയ പദങ്ങളും ഓഡിയോയോടെ പഠിക്കുക." }
    },
    {
      stepNumber: 3,
      id: "step_3_game_hunt",
      title: { en: "Game 1: Meadow Runner Hunt", ml: "ഗെയിം 1: വേഡ് ഹണ്ട് റണ്ണർ" },
      icon: "🏃",
      gameType: "meadow_runner_hunt",
      canBeSkipped: false,
      xpReward: 40,
      passScore: 70,
      targetObjects: dayItem.n.map(x => x[0]),
      description: { en: "Dodge obstacles and grab target words in the 2D world.", ml: "2D ലോകത്ത് ഓടി നടന്ന് ഇന്നത്തെ പ്രധാന വാക്കുകൾ ശേഖരിക്കുക." }
    },
    {
      stepNumber: 4,
      id: "step_4_game_builder",
      title: { en: "Game 2: Sentence Constructor", ml: "ഗെയിം 2: സെന്റൻസ് ബിൽഡർ" },
      icon: "🧩",
      gameType: "word_catcher_builder",
      canBeSkipped: false,
      xpReward: 40,
      passScore: 80,
      challengePatterns: [
        dayItem.v[0][4],
        dayItem.v[1][4],
        dayItem.v[2][4]
      ],
      description: { en: "Assemble falling words into correct sentences.", ml: "വാക്കുകൾ ക്രമമായി അടുക്കി ശരിയായ വാചകം നിർമ്മിക്കുക." }
    },
    {
      stepNumber: 5,
      id: "step_5_reading_room",
      title: { en: "Reading Room: " + dayItem.themeEn, ml: "റീഡിങ് റൂം: " + dayItem.themeMl },
      icon: "📖",
      gameType: "reading_listening",
      canBeSkipped: false,
      xpReward: 35,
      passScore: 75,
      sentences: readingSentences,
      description: { en: "Listen to native audio, then tap microphone to read aloud.", ml: "ഓഡിയോ ശ്രദ്ധിച്ചു കേട്ട് മൈക്കിലൂടെ ഉറക്കെ വായിക്കുക." }
    },
    {
      stepNumber: 6,
      id: "step_6_spoken_lab",
      title: { en: "Spoken Speech Lab", ml: "സ്പോക്കൺ സ്പീച്ച് ലാബ്" },
      icon: "🎙️",
      gameType: "speech_analyzer",
      canBeSkipped: false,
      xpReward: 35,
      passScore: 70,
      voiceTasks: {
        zero: { prompt: "Repeat clearly with Tutor Robot: '" + dayItem.v[0][4] + "'", targetSentence: dayItem.v[0][4] },
        middle: { prompt: "Speak today's core sentence: '" + dayItem.v[1][4] + "'", targetSentence: dayItem.v[1][4] },
        higher: { prompt: "Explain your thought on " + dayItem.themeEn + " in 1-2 fluent sentences.", targetSentence: dayItem.v[2][4] }
      },
      description: { en: "Speak clearly into the microphone to test your pronunciation & speed.", ml: "മൈക്കിലൂടെ സംസാരിച്ച് ഉച്ചാരണവും ഫ്ലുവെൻസിയും മെച്ചപ്പെടുത്തുക." }
    },
    {
      stepNumber: 7,
      id: "step_7_house_defense",
      title: { en: "House Defense Shield", ml: "ഹൗസ് ഡിഫൻസ് ഷീൽഡ്" },
      icon: "🛡️",
      gameType: "house_defense_trap_builder",
      canBeSkipped: false,
      xpReward: 30,
      passScore: 100,
      traps: [
        {
          id: `trap_d${day}_1`,
          question: `What is the correct English usage for: '${dayItem.v[0][3]}'?`,
          options: [dayItem.v[0][0], "Unrelated A", "Unrelated B", "Unrelated C"],
          answer: dayItem.v[0][0],
          explanation: `${dayItem.v[0][0]} എന്നാൽ ${dayItem.v[0][3]}.`
        },
        {
          id: `trap_d${day}_2`,
          question: `What is the past form (V2) of '${dayItem.v[1][0]}'?`,
          options: [dayItem.v[1][1], dayItem.v[1][0] + "ing", dayItem.v[1][0] + "edx", "None"],
          answer: dayItem.v[1][1],
          explanation: `The V2 past form of ${dayItem.v[1][0]} is ${dayItem.v[1][1]}.`
        },
        {
          id: `trap_d${day}_3`,
          question: `Choose the correct meaning for '${dayItem.n[0][0]}':`,
          options: [dayItem.n[0][1], "തെറ്റായ ഓപ്ഷൻ 1", "തെറ്റായ ഓപ്ഷൻ 2", "തെറ്റായ ഓപ്ഷൻ 3"],
          answer: dayItem.n[0][1],
          explanation: `${dayItem.n[0][0]} എന്നാൽ ${dayItem.n[0][1]}.`
        }
      ],
      description: { en: "Install 3 English grammar trap questions to shield your house against raids.", ml: "നിങ്ങളുടെ വീട് സംരക്ഷിക്കാൻ 3 ഇംഗ്ലീഷ് ചോദ്യങ്ങൾ ഡിഫൻസ് ട്രാപ്പുകളാക്കുക." }
    }
  ];

  let nextStepNum = 8;

  // Day 4+ Attack Step
  if (isAttackUnlocked) {
    steps.push({
      stepNumber: nextStepNum++,
      id: "step_attack_raids",
      title: { en: "⚔️ Citadel Attack Raids (Active)", ml: "⚔️ സിറ്റാഡൽ അറ്റാക്ക് (സജീവം)" },
      icon: "⚔️",
      gameType: "citadel_attack_raid",
      canBeSkipped: false,
      xpReward: 45,
      passScore: 100,
      attackConfig: {
        isUnlocked: true,
        targetHousesAvailable: 3,
        objective: "Raid rival houses by solving English grammar questions to plunder coins & trophies!"
      },
      description: { en: "Raid rival learner houses by solving grammar challenges!", ml: "ഇംഗ്ലീഷ് ചോദ്യങ്ങൾക്ക് ഉത്തരം നൽകി എതിരാളികളുടെ വീടുകൾ റെയ്ഡ് ചെയ്യുക!" }
    });
  }

  // Social Arena Step
  steps.push({
    stepNumber: nextStepNum++,
    id: "step_social_arena",
    title: { en: "Community & Social Arena", ml: "സോഷ്യൽ അരീന & കൂട്ടുകാർ" },
    icon: "🤝",
    gameType: "social_arena",
    canBeSkipped: true,
    xpReward: 30,
    passScore: 100,
    socialConfig: {
      zeroTrack: {
        isLocked: !isZeroSocialUnlocked,
        unlocksOnDay: 10,
        lockedMessage: isZeroSocialUnlocked ? "" : "🌱 Stranger voice calls unlock on Day 10! Practice privately with Tutor Robot today.",
        alternativeAction: "robot_voice_practice"
      },
      middleTrack: {
        isLocked: false,
        englishHubPrompt: `Post in English Hub: 'Today on Day ${day}, I practiced ${dayItem.themeEn}! What are your thoughts?'`,
        randomCallPrompt: `Connect on an anonymous call to discuss ${dayItem.themeEn} for 2 minutes.`,
        pocketTalkPrompt: "Swipe to find a practice partner from Kerala/India."
      },
      higherTrack: {
        isLocked: false,
        englishHubPrompt: `Lead a professional discussion topic on ${dayItem.themeEn} in English Hub.`,
        randomCallPrompt: `Connect a 3-minute voice conversation on ${dayItem.themeEn}.`,
        pocketTalkPrompt: "Send a 4-Day Spoken Pact request to a fellow fluent speaker."
      }
    },
    description: { en: "Connect with real learners or chat with your AI Robot.", ml: "മറ്റു പഠിതാക്കളുമായി സംസാരിക്കുക അല്ലെങ്കിൽ റോബോട്ടിനൊപ്പം പരിശീലിക്കുക." }
  });

  // Daily Gate Exam Step
  steps.push({
    stepNumber: nextStepNum++,
    id: "step_daily_exam",
    title: { en: `Day ${day} Gate Exam (5 Qs)`, ml: `ഡേ ${day} ഗേറ്റ് എക്സാം` },
    icon: "🎓",
    gameType: "daily_exam",
    canBeSkipped: false,
    xpReward: 50,
    passScore: 70,
    examQuestions: [
      {
        q: `What is the correct English usage for: '${dayItem.v[0][3]}'?`,
        options: [dayItem.v[0][0], "Wrong A", "Wrong B", "Wrong C"],
        answer: dayItem.v[0][0]
      },
      {
        q: `Choose the sentence using '${dayItem.v[1][0]}' correctly:`,
        options: [dayItem.v[1][4], "I " + dayItem.v[1][0] + "ing not.", "He " + dayItem.v[1][0] + " wrongly.", "None"],
        answer: dayItem.v[1][4]
      },
      {
        q: `What is the past form (V2) of '${dayItem.v[2][0]}'?`,
        options: [dayItem.v[2][1], dayItem.v[2][0] + "s", dayItem.v[2][0] + "ing", "None"],
        answer: dayItem.v[2][1]
      },
      {
        q: `Which word represents: '${dayItem.n[0][1]}'?`,
        options: [dayItem.n[0][0], "Incorrect X", "Incorrect Y", "Incorrect Z"],
        answer: dayItem.n[0][0]
      },
      {
        q: `True or False: Today's topic is '${dayItem.themeEn}'?`,
        options: ["True", "False"],
        answer: "True"
      }
    ],
    description: { en: `Pass Day ${day} with 70%+ to keep your streak and unlock Day ${day+1}!`, ml: `70% മാർക്കോടെ ജയിച്ച് സ്ട്രീക്ക് നിലനിർത്തുക, അടുത്ത ദിവസം അൺലോക്ക് ചെയ്യുക!` }
  });

  // Complete JSON Object
  const curriculumObj = {
    course: {
      name: "90-Day English Game",
      day: day,
      house: house,
      houseTitle: houseTitles[house],
      version: `day-${day}-v1`,
      topic: {
        en: dayItem.themeEn,
        ml: dayItem.themeMl,
        hi: dayItem.themeEn,
        ta: dayItem.themeEn
      },
      unlockRule: `Unlocks after passing Day ${day - 1} Exam. Day ${day + 1} unlocks after scoring 70%+ in Day ${day} Exam.`,
      passPercentage: 70,
      totalXpReward: 250 + (day * 2),
      totalCoinsReward: 50 + (day * 1)
    },
    grammarRule: {
      formula: dayItem.rule,
      explanation: {
        ml: `${dayItem.themeMl} എന്ന വിഷയത്തിൽ ${dayItem.rule} എങ്ങനെ ഉപയോഗിക്കണം എന്ന് വിശദീകരിക്കുന്നു.`,
        en: `Learn how to use ${dayItem.rule} correctly in spoken English.`
      },
      goldenTip: {
        ml: `💡 ടിപ്പ്: ${dayItem.v[0][4]}`,
        en: `Golden Rule: Practice '${dayItem.v[0][4]}' with zero hesitation.`
      }
    },
    vocabulary: {
      verbs: verbsList,
      nouns: nounsList
    },
    steps: steps
  };

  const filePath = path.join(curriculumDir, `day_${day}_curriculum.json`);
  fs.writeFileSync(filePath, JSON.stringify(curriculumObj, null, 2), 'utf8');
  generatedCount++;
});

console.log(`SUCCESS: Successfully generated all ${generatedCount} day curriculum JSON files in assets/curriculum/!`);
