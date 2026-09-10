import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📜 Model for Comprehensive Game Rules with Native Translations
class PocketWorldRuleItem {
  final String id;
  final String icon;
  final String category;
  final Color themeColor;
  final String titleEn;
  final String descEn;
  final Map<String, String> translationTitle;
  final Map<String, String> translationDesc;
  final String dailyTaskEn;
  final String dailyTaskMl;
  final String growthOutcomeEn;
  final String growthOutcomeMl;

  const PocketWorldRuleItem({
    required this.id,
    required this.icon,
    required this.category,
    required this.themeColor,
    required this.titleEn,
    required this.descEn,
    required this.translationTitle,
    required this.translationDesc,
    this.dailyTaskEn = 'Complete daily interactive practice drills and vocabulary challenges.',
    this.dailyTaskMl = 'ദിവസേനയുള്ള ഇംഗ്ലീഷ് പരിശീലന ടാസ്കുകൾ മുടങ്ങാതെ പൂർത്തിയാക്കുക.',
    this.growthOutcomeEn = 'Builds natural spoken fluency, eliminates hesitation, and cements grammatical agility.',
    this.growthOutcomeMl = 'സംസാരത്തിലുള്ള മടി പൂർണ്ണമായി മാറുകയും മാതൃഭാഷയിൽ ചിന്തിക്കാതെ ഇംഗ്ലീഷ് സംസാരിക്കാൻ സാധിക്കുകയും ചെയ്യുന്നു.',
  });
}

/// Complete List of 12 Comprehensive Game Rules Implemented in the App
final List<PocketWorldRuleItem> kPocketWorldMasterRulesList = [
  const PocketWorldRuleItem(
    id: 'rule_1_guarantee',
    icon: '🏆',
    category: 'Accreditation',
    themeColor: Color(0xFFFFD700),
    titleEn: '100% Fluency Assurance & Official Certificate',
    descEn: 'Complete the 90-day progressive curriculum to unlock your official Certificate of Fluency Mastery. 100% confidence in professional speaking, grammar, and workplace English is guaranteed.',
    translationTitle: {
      'malayalam': '100% ഫ്ലുവെൻസി ഗ്യാരണ്ടിയും ഒഫീഷ്യൽ സർട്ടിഫിക്കറ്റും',
      'tamil': '100% சரள ஆங்கில உத்தரவாதம் மற்றும் சான்றிதழ்',
      'telugu': '100% ఆంగ్ల ప్రావీణ్య హామీ & అధికారిక సర్టిఫికెట్',
      'kannada': '100% ಇಂಗ್ಲಿಷ್ ನಿರರ್ಗಳತೆ ಭರವಸೆ & ಅಧಿಕೃತ ಪ್ರಮಾಣಪತ್ರ',
      'hindi': '100% धाराप्रवाह अंग्रेजी गारंटी और आधिकारिक प्रमाण पत्र',
    },
    translationDesc: {
      'malayalam': '90 ദിവസത്തെ സമ്പൂർണ്ണ കരിക്കുലം പൂർത്തിയാക്കുന്ന ഓരോ പഠിതാവിനും ഒഫീഷ്യൽ അക്രഡിറ്റഡ് സർട്ടിഫിക്കറ്റ് ലഭിക്കും. സംസാരത്തിലും എഴുത്തിലും ഇന്റർവ്യൂവിലും 100% ആത്മവിശ്വാസം ഉറപ്പ്!',
      'tamil': '90 நாள் பாடத்திட்டத்தை முடிக்கும் ஒவ்வொருவருக்கும் அதிகாரப்பூர்வ சான்றிதழ் வழங்கப்படும். நேர்காணல் மற்றும் அன்றாட பேச்சில் 100% தன்னம்பிக்கை உறுதி!',
      'telugu': '90 రోజుల కోర్సు పూర్తి చేసిన ప్రతి ఒక్కరికీ అధికారిక సర్టిఫికెట్ లభిస్తుంది. ఇంగ్లీష్ మాట్లాడటంలో మరియు ఇంటర్వ్యూలలో 100% విశ్వాసం గ్యారెంటీ!',
      'kannada': '90 ದಿನಗಳ ಕೋರ್ಸ್ ಪೂರ್ಣಗೊಳಿಸುವ ಪ್ರತಿಯೊಬ್ಬರಿಗೂ ಅಧಿಕೃತ ಪ್ರಮಾಣಪತ್ರ ದೊರೆಯುತ್ತದೆ. ಇಂಗ್ಲಿಷ್ ಮಾತನಾಡುವಲ್ಲಿ 100% ಆತ್ಮವಿಶ್ವಾಸ ಖಚಿತ!',
      'hindi': '90 दिनों का संपूर्ण पाठ्यक्रम पूरा करने पर आधिकारिक प्रमाण पत्र प्राप्त होगा। अंग्रेजी बोलने और साक्षात्कारों में 100% आत्मविश्वास की गारंटी!',
    },
    dailyTaskEn: 'Complete 1 daily speaking synthesis and 1 audio speech shadowing drill.',
    dailyTaskMl: 'ദിവസേനയുള്ള സ്പീക്കിംഗ് മിഷനുകളും ഓഡിയോ ഷാഡോയിംഗും പൂർത്തിയാക്കുക.',
    growthOutcomeEn: 'Unlocks official CEFR C2 certificate; eliminates mother-tongue translation lag.',
    growthOutcomeMl: 'ഒഫീഷ്യൽ C2 സർട്ടിഫിക്കറ്റ് ലഭിക്കുന്നു; മാതൃഭാഷയിൽ നിന്നുള്ള ചിന്താ താമസം ഇല്ലാതാവുന്നു.',
  ),

  const PocketWorldRuleItem(
    id: 'rule_2_matrix',
    icon: '📈',
    category: 'Progression',
    themeColor: Color(0xFF10B981),
    titleEn: '4-Stage Progressive Transformation Matrix',
    descEn: 'Stage 1 (Days 1–15: Foundation Agility), Stage 2 (Days 16–30: Conversational Register & Softeners), Stage 3 (Days 31–60: Executive Oratory & Interview Mastery), Stage 4 (Days 61–90: Sovereign Grandmaster Fluency).',
    translationTitle: {
      'malayalam': '4 ഘട്ടങ്ങളായുള്ള ഘടനാപരമായ വളർച്ച',
      'tamil': '4 நிலைகள் கொண்ட படிப்படியான வளர்ச்சி',
      'telugu': '4 దశల వారీ ప్రగతిశీల పరివర్తన',
      'kannada': '4 ಹಂತಗಳ ಪ್ರಗತಿಪರ ಕಲಿಕಾ ಚೌಕಟ್ಟು',
      'hindi': '4-चरणीय प्रगतिशील परिवर्तन मैट्रिक्स',
    },
    translationDesc: {
      'malayalam': 'ഘട്ടം 1 (അടിസ്ഥാനം & മടി മാറ്റൽ), ഘട്ടം 2 (നയതന്ത്ര മൃദുഭാഷണം), ഘട്ടം 3 (എക്സിക്യൂട്ടീവ് സ്പീക്കിംഗ് & ഇന്റർവ്യൂ), ഘട്ടം 4 (ഗ്രാൻഡ് മാസ്റ്റർ പ്രൊഫഷണൽ ഇംഗ്ലീഷ്).',
      'tamil': 'நிலை 1 (அடிப்படை & தயக்கம் போக்குதல்), நிலை 2 (மென்மையான உரையாடல்), நிலை 3 (தலைமைப் பேச்சு & நேர்காணல்), நிலை 4 (முழுமையான வல்லமை).',
      'telugu': 'దశ 1 (పునాది & బెరుకు తొలగించుట), దశ 2 (వినయపూర్వక సంభాషణ), దశ 3 (నాయకత్వ శైలి & ఇంటర్వ్యూలు), దశ 4 (పరిపూర్ణ ప్రావీణ్యం).',
      'kannada': 'ಹಂತ 1 (ಮೂಲತತ್ವ & ಸಂಕೋಚ ಮುಕ್ತಿ), ಹಂತ 2 (ರಾಜತಾಂತ್ರಿಕ ಭಾಷೆ), ಹಂತ 3 (ನಾಯಕತ್ವ ಇಂಗ್ಲಿಷ್), ಹಂತ 4 (ಸಂಪೂರ್ಣ ಪ್ರಾವೀಣ್ಯತೆ).',
      'hindi': 'चरण 1 (बुनियाद और झिझक दूर करना), चरण 2 (संवाद शैली), चरण 3 (कार्यकारी भाषण और साक्षात्कार), चरण 4 (पूर्ण संप्रभु प्रवीणता)।',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_3_home_defense',
    icon: '🏠',
    category: 'Home Defense',
    themeColor: Color(0xFF8B5CF6),
    titleEn: '1 Day = 1 Defense Slot (Your English Castle)',
    descEn: 'Every player owns a virtual home on the street. 1 Day completed unlocks 1 Home Defense Slot. Day 1 has 1 trap; Day 90 commands 90 defense slots across 9 gates! You arm your house with real English questions you learned.',
    translationTitle: {
      'malayalam': '1 ദിവസം = 1 ഡിഫൻസ് സ്ലോട്ട് (നിങ്ങളുടെ ഇംഗ്ലീഷ് വീട്)',
      'tamil': '1 நாள் = 1 பாதுகாப்பு ஸ்லாட் (உங்கள் ஆங்கில இல்லம்)',
      'telugu': '1 రోజు = 1 రక్షణ స్లాట్ (మీ ఇంగ్లీష్ ఇల్లు)',
      'kannada': '1 ದಿನ = 1 ರಕ್ಷಣಾ ಸ್ಲಾಟ್ (ನಿಮ್ಮ ಇಂಗ್ಲಿಷ್ ಮನೆ)',
      'hindi': '1 दिन = 1 रक्षा स्लॉट (आपका अंग्रेजी घर)',
    },
    translationDesc: {
      'malayalam': 'പോക്കറ്റ് വേൾഡിൽ എല്ലാവർക്കും സ്വന്തമായി വീടുണ്ട്. നിങ്ങൾ പഠിക്കുന്ന ഇംഗ്ലീഷ് ചോദ്യങ്ങളാണ് നിങ്ങളുടെ വീടിന്റെ കോട്ടമതിലുകൾ. ഡേ 90 എത്തുമ്പോൾ 9 ഗേറ്റുകളിലായി 90 ഡിഫൻസ് സ്ലോട്ടുകൾ ഉണ്ടാകും!',
      'tamil': 'பாக்கெட் வேர்ல்டில் அனைவருக்கும் ஒரு வீடு உண்டு. நீங்கள் கற்கும் கேள்விகளே உங்கள் வீட்டின் பாதுகாப்புக் கோட்டைகள். நாள் 90-ல் 90 ஸ்லாட்டுகள் அமையும்!',
      'telugu': 'పాకెట్ వరల్డ్‌లో ప్రతి ఒక్కరికీ ఒక ఇల్లు ఉంటుంది. మీరు నేర్చుకునే ప్రశ్నలే మీ ఇంటి రక్షణ గోడలు. 90వ రోజుకు 90 రక్షణ స్లాట్‌లు లభిస్తాయి!',
      'kannada': 'ಪಾಕೆಟ್ ವರ್ಲ್ಡ್‌ನಲ್ಲಿ ಪ್ರತಿಯೊಬ್ಬರಿಗೂ ಮನೆಯಿದೆ. ನೀವು ಕಲಿಯುವ ಪ್ರಶ್ನೆಗಳೇ ನಿಮ್ಮ ಮನೆಯ ರಕ್ಷಣಾ ಗೋಡೆಗಳು. ಡೇ 90 ರಲ್ಲಿ 90 ರಕ್ಷಣಾ ಸ್ಲಾಟ್‌ಗಳು ಸಿದ್ಧವಾಗುತ್ತವೆ!',
      'hindi': 'पॉकेट वर्ल्ड में हर किसी का अपना घर है। आपके द्वारा सीखे गए प्रश्न ही आपके घर की दीवारें हैं। 90वें दिन तक आपके पास 90 रक्षा स्लॉट होंगे!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_4_house_hp_coins',
    icon: '🪙',
    category: 'Home Defense',
    themeColor: Color(0xFFF59E0B),
    titleEn: 'House 100 HP & Vault Coins Loot',
    descEn: 'Every home has 100 HP. If an attacker solves your defense traps and breaches your gate, they loot 45 coins from your vault. If the attacker fails, their raid is defeated and your vault remains secure.',
    translationTitle: {
      'malayalam': 'വീടിന്റെ 100 HP-യും നാണയ കൊള്ളയും',
      'tamil': 'வீட்டின் 100 HP மற்றும் நாணயப் பாதுகாப்பு',
      'telugu': 'ఇంటి 100 HP మరియు ఖజానా నాణేలు',
      'kannada': 'ಮನೆಯ 100 HP ಮತ್ತು ನಾಣ್ಯಗಳ ಭದ್ರತೆ',
      'hindi': 'घर का 100 HP और तिजोरी के सिक्के',
    },
    translationDesc: {
      'malayalam': 'ഓരോ വീടിനും 100 HP ഉണ്ട്. ശത്രുക്കൾ നിങ്ങളുടെ ഡിഫൻസ് ചോദ്യങ്ങൾ ശരിയായി ഉത്തരം നൽകി ബ്രീച്ച് ചെയ്താൽ 45 കോയിൻ നഷ്ടപ്പെടും. ചോദ്യങ്ങളിൽ അവർ തോറ്റാൽ കോയിനുകൾ സുരക്ഷിതമായിരിക്കും!',
      'tamil': 'ஒவ்வொரு வீட்டிற்கும் 100 HP உள்ளது. எதிரி உங்கள் கேள்விகளுக்கு சரியான விடையளித்து நுழைந்தால் 45 நாணயங்கள் பறிபோகும். தவறினால் உங்கள் நாணயங்கள் பாதுகாப்பாக இருக்கும்!',
      'telugu': 'ప్రతి ఇంటికి 100 HP ఉంటుంది. శత్రువు మీ రక్షణ ప్రశ్నలను ఛేదిస్తే 45 నాణేలు కోల్పోతారు. వారు విఫలమైతే మీ నాణేలు సురక్షితం!',
      'kannada': 'ಪ್ರತಿಯೊಂದು ಮನೆಗೂ 100 HP ಇರುತ್ತದೆ. ಶತ್ರುಗಳು ನಿಮ್ಮ ಪ್ರಶ್ನೆಗಳನ್ನು ಭೇದಿಸಿದರೆ 45 ನಾಣ್ಯಗಳನ್ನು ಕಳೆದುಕೊಳ್ಳುತ್ತೀರಿ. ಅವರು ಸೋತರೆ ನಿಮ್ಮ ನಾಣ್ಯಗಳು ಸುರಕ್ಷಿತ!',
      'hindi': 'प्रत्येक घर में 100 HP होते हैं। यदि कोई हमलावर आपके जाल को भेदता है, तो 45 सिक्के कट जाएंगे। असफल होने पर आपकी तिजोरी सुरक्षित रहेगी!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_5_street_navigation',
    icon: '⚔️',
    category: 'Pocket Battle',
    themeColor: Color(0xFFEF4444),
    titleEn: 'Pocket World Street Navigation (Pocket Battle / Attack)',
    descEn: 'All attack actions route directly to the Pocket World Street. View neighboring citadels along the boulevard, inspect their house tier and defenses, ring the doorbell, and engage in direct English battles.',
    translationTitle: {
      'malayalam': 'പോക്കറ്റ് വേൾഡ് തെരുവും അറ്റാക്കും (Pocket Battle)',
      'tamil': 'பாக்கெட் வேர்ல்ட் வீதி மற்றும் நேரடித் தாக்குதல்',
      'telugu': 'పాకెట్ వరల్డ్ వీధి మరియు ప్రత్యక్ష దాడి',
      'kannada': 'ಪಾಕೆಟ್ ವರ್ಲ್ಡ್ ರಸ್ತೆ ಮತ್ತು ನೇರ ಆಕ್ರಮಣ',
      'hindi': 'पॉकेट वर्ल्ड स्ट्रीट और सीधा हमला (Pocket Battle)',
    },
    translationDesc: {
      'malayalam': 'എല്ലാ അറ്റാക്ക് ബട്ടണുകളും ഡയറക്റ്റ് പോക്കറ്റ് വേൾഡ് തെരുവിലേക്ക് പോകുന്നു. റോഡിലൂടെ നടന്ന് വീടുകൾ കാണുക, ശത്രുവിനെ തിരഞ്ഞെടുക്കുക, ഡോർബെല്ലടിച്ച് ഇംഗ്ലീഷ് ചോദ്യങ്ങൾ ജയിച്ച് ഗേറ്റ് തകർക്കുക!',
      'tamil': 'அனைத்து தாக்குதல்களும் நேரடியாக பாக்கெட் வேர்ல்ட் வீதிக்குச் செல்லும். வீடுகளைப் பார்த்து, தேர்வு செய்து, மணியடித்து ஆங்கிலப் போரில் வெற்றி பெறுங்கள்!',
      'telugu': 'అన్ని దాడి బటన్‌లు నేరుగా పాకెట్ వరల్డ్ వీధికి వెళ్తాయి. ఇళ్లను చూసి, ఎంచుకుని, డోర్‌బెల్ కొట్టి ఆంగ్ల ప్రశ్నలతో గెలవండి!',
      'kannada': 'ಎಲ್ಲಾ ದಾಳಿಗಳು ನೇರವಾಗಿ ಪಾಕೆಟ್ ವರ್ಲ್ಡ್ ರಸ್ತೆಗೆ ಹೋಗುತ್ತವೆ. ಮನೆಗಳನ್ನು ನೋಡಿ, ಆಯ್ಕೆ ಮಾಡಿ, ಬೆಲ್ ಬಾರಿಸಿ ಇಂಗ್ಲಿಷ್ ಯುದ್ಧದಲ್ಲಿ ಗೆಲ್ಲಿರಿ!',
      'hindi': 'सभी हमले सीधे पॉकेट वर्ल्ड स्ट्रीट पर जाते हैं। घरों को देखें, विरोधी चुनें, डोरबेल बजाएं और अंग्रेजी मुकाबले में जीत हासिल करें!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_6_matchmaking',
    icon: '🎯',
    category: 'Pocket Battle',
    themeColor: Color(0xFF38BDF8),
    titleEn: 'Target Matchmaking Rule (Higher Citadels Before Day 20)',
    descEn: 'Attacks unlock at Level 4. Before Day 20 (Days 1–19), players cannot attack same-level peers; you must challenge tougher citadels (+1 to +3 levels higher) to stretch your vocabulary. Day 20+ unlocks open matchmaking.',
    translationTitle: {
      'malayalam': 'മാച്ച് മേക്കിംഗ് നിയമം (ഡേ 20-ന് മുമ്പ് ഉയർന്ന ലെവലുകൾ)',
      'tamil': 'மேட்ச்மேக்கிங் விதி (நாள் 20-க்கு முன் உயர் நிலைகள்)',
      'telugu': 'మ్యాచ్ మేకింగ్ నిబంధన (డే 20 కి ముందు పై స్థాయిలు)',
      'kannada': 'ಹೊಂದಾಣಿಕೆ ನಿಯಮ (ದಿನ 20 ಕ್ಕಿಂತ ಮೊದಲು ಉನ್ನತ ಮಟ್ಟಗಳು)',
      'hindi': 'मैचमेकिंग नियम (दिन 20 से पहले उच्च स्तर)',
    },
    translationDesc: {
      'malayalam': 'അറ്റാക്ക് ലെവൽ 4-ൽ അൺലോക്കാകുന്നു. ഡേ 20-ന് മുമ്പ് നിങ്ങളെക്കാൾ ഉയർന്ന ലെവൽ വീടുകളെ മാത്രമേ അറ്റാക്ക് ചെയ്യാവൂ (+1 മുതൽ +3 ലെവലുകൾ വരെ). ഡേ 20-ന് ശേഷം ആരെയും തിരഞ്ഞെടുക്കാം.',
      'tamil': 'லெவல் 4-ல் தாக்குதல் திறக்கப்படும். நாள் 20-க்கு முன் உங்களை விட உயர்ந்த (+1 முதல் +3) நிலைகளை மட்டுமே தாக்க முடியும். நாள் 20-க்கு பின் முழு சுதந்திரம்.',
      'telugu': 'లెవల్ 4 లో దాడి అన్‌లాక్ అవుతుంది. డే 20 కంటే ముందు మీ కంటే పై స్థాయి (+1 నుండి +3) ఇళ్లపైనే దాడి చేయాలి. 20వ రోజు తర్వాత ఎవరినైనా ఎంచుకోవచ్చు.',
      'kannada': 'ಲೆವೆಲ್ 4 ರಲ್ಲಿ ಆಕ್ರಮಣ ಅನ್‌ಲಾಕ್ ಆಗುತ್ತದೆ. ಡೇ 20 ಕ್ಕಿಂತ ಮೊದಲು ನಿಮ್ಮಗಿಂತ ಉನ್ನತ (+1 ರಿಂದ +3) ಮನೆಗಳನ್ನಷ್ಟೇ ಆಕ್ರಮಿಸಬೇಕು. ನಂತರ ಮುಕ್ತ ಆಯ್ಕೆ.',
      'hindi': 'लेवल 4 पर हमला अनलॉक होता है। दिन 20 से पहले केवल अपने से उच्च (+1 से +3) स्तर के घरों पर ही हमला किया जा सकता है।',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_7_pocket_robo',
    icon: '🤖',
    category: 'Pocket Battle',
    themeColor: Color(0xFFEC4899),
    titleEn: 'Pocket Robo 🤖 24/7 AI Citadel Fallback',
    descEn: 'If no real peer is active in your target level bracket, Pocket Robo automatically steps in as an authentic AI home defender calibrated to your exact curriculum. Raids and coin rewards never stall!',
    translationTitle: {
      'malayalam': 'പോക്കറ്റ് റോബോ 🤖 24/7 AI കാവൽക്കാരൻ',
      'tamil': 'பாக்கெட் ரோபோ 🤖 24/7 AI பாதுகாவலர்',
      'telugu': 'పాకెట్ రోబో 🤖 24/7 AI రక్షకుడు',
      'kannada': 'ಪಾಕೆಟ್ ರೋಬೋ 🤖 24/7 AI ರಕ್ಷಕ',
      'hindi': 'पॉकेट रोबो 🤖 24/7 AI रक्षक',
    },
    translationDesc: {
      'malayalam': 'നിങ്ങളുടെ ലെവലിൽ കളിക്കാൻ റിയൽ പ്ലെയേഴ്സ് ഇല്ലെങ്കിലും കളി നിന്നുപോകില്ല. പോക്കറ്റ് റോബോ കൃത്യമായ ചോദ്യങ്ങളുമായി വീടിന് കാവൽ നിൽക്കും. പ്രാക്ടീസും നാണയങ്ങളും 24 മണിക്കൂറും റെഡി!',
      'tamil': 'உங்கள் லெவலில் வீரர்கள் இல்லாதபோதும், பாக்கெட் ரோபோ தானாகவே வந்து பாதுகாக்கும். பயிற்சிகளும் நாணயப் பரிசுகளும் எப்போதும் கிடைக்கும்!',
      'telugu': 'మీ స్థాయిలో నిజమైన ఆటగాళ్ళు లేకపోయినా, పాకెట్ రోబో రక్షణగా నిలుస్తుంది. ప్రాక్టీస్ మరియు నాణేలు 24 గంటలూ అందుబాటులో ఉంటాయి!',
      'kannada': 'ನಿಮ್ಮ ಮಟ್ಟದಲ್ಲಿ ನೈಜ ಆಟಗಾರರು ಇಲ್ಲದಿದ್ದರೂ, ಪಾಕೆಟ್ ರೋಬೋ ರಕ್ಷಣೆಗೆ ನಿಲ್ಲುತ್ತದೆ. ಅಭ್ಯಾಸ ಮತ್ತು ನಾಣ್ಯಗಳು ಯಾವಾಗಲೂ ಲಭ್ಯ!',
      'hindi': 'आपके स्तर पर खिलाड़ी न होने पर भी पॉकेट रोबो स्वचालित रूप से उपस्थित होगा। अभ्यास और पुरस्कार कभी नहीं रुकेंगे!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_8_police_protection',
    icon: '👮‍♂️',
    category: 'President Guard',
    themeColor: Color(0xFF00E5FF),
    titleEn: '48-Hour Presidential Police Protection',
    descEn: 'Once a home suffers a raid breach, a Police Cruiser with 2 armed officers stations outside for 48 hours. Rivals cannot raid or loot during this immunity window, granting full peace to study and rebuild.',
    translationTitle: {
      'malayalam': '48-മണിക്കൂർ പ്രസിഡൻഷ്യൽ പോലീസ് പ്രൊട്ടക്ഷൻ',
      'tamil': '48 மணிநேர காவல் துறை பாதுகாப்பு',
      'telugu': '48 గంటల పోలీసు రక్షణ కవచం',
      'kannada': '48 ಗಂಟೆಗಳ ಅಧ್ಯಕ್ಷೀಯ ಪೊಲೀಸ್ ಭದ್ರತೆ',
      'hindi': '48 घंटे की राष्ट्रपति पुलिस सुरक्षा',
    },
    translationDesc: {
      'malayalam': 'ഒരു തവണ വീട് ബ്രീച്ച് ചെയ്യപ്പെട്ടാൽ ഉടൻ പോലീസ് ജീപ്പും 2 സായുധ പോലീസുകാരും 48 മണിക്കൂർ കാവൽ നിൽക്കും. ഈ സമയത്ത് ആരും നിങ്ങളെ അറ്റാക്ക് ചെയ്യില്ല. സമാധാനമായി പഠിച്ച് വീട് പുനർനിർമ്മിക്കാം!',
      'tamil': 'வீடு தாக்கப்பட்டவுடன், 48 மணிநேரத்திற்கு காவல் துறை வாகனம் மற்றும் காவலர்கள் பாதுகாப்பு தருவர். யாரும் தாக்க முடியாது. நிம்மதியாகப் படித்து பலப்படுத்தலாம்!',
      'telugu': 'ఇల్లు దాడికి గురైన వెంటనే, 48 గంటల పాటు పోలీసు జీపు మరియు సిబ్బంది రక్షణగా ఉంటారు. ఎవరూ దాడి చేయలేరు. ప్రశాంతంగా చదువుకోవచ్చు!',
      'kannada': 'ಮನೆ ಭೇದಿಸಲ್ಪಟ್ಟಾಗ, 48 ಗಂಟೆಗಳ ಕಾಲ ಪೊಲೀಸ್ ಜೀಪ್ ಮತ್ತು ಸಶಸ್ತ್ರ ಸಿಬ್ಬಂದಿ ಭದ್ರತೆ ನೀಡುತ್ತಾರೆ. ಯಾರೂ ಆಕ್ರಮಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ನೆಮ್ಮದಿಯಿಂದ ಕಲಿಯಿರಿ!',
      'hindi': 'घर पर हमला होने के बाद 48 घंटे के लिए पुलिस वाहन और सशस्त्र गार्ड सुरक्षा देते हैं। इस दौरान कोई हमला नहीं कर सकता।',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_9_daily_timer',
    icon: '⏱️',
    category: 'Focus Habit',
    themeColor: Color(0xFFF97316),
    titleEn: 'Daily 40–60 Minute Active Learning Timer',
    descEn: 'Fluency requires consistent neurological wiring. The timer records genuine practice inside the app (Reading, Speaking, Code English, Writing) and pauses automatically if backgrounded.',
    translationTitle: {
      'malayalam': 'ദിവസേനയുള്ള 40–60 മിനിറ്റ് ഫോക്കസ് ടൈമർ',
      'tamil': 'தினசரி 40–60 நிமிட கவனக் கற்றல் டைமர்',
      'telugu': 'రోజువారీ 40–60 నిమిషాల ఫోకస్ టైమర్',
      'kannada': 'ದೈನಂದಿನ 40–60 ನಿಮಿಷಗಳ ಏಕಾಗ್ರತೆ ಟೈಮರ್',
      'hindi': 'दैनिक 40–60 मिनट का अध्ययन टाइमर',
    },
    translationDesc: {
      'malayalam': 'ഇംഗ്ലീഷ് മനസ്സിൽ ഉറയ്ക്കാൻ ദിവസവും 40 മുതൽ 60 മിനിറ്റ് വരെ ശ്രദ്ധയോടെ പഠിക്കണം. ആപ്പ് ബാക്ക്ഗ്രൗണ്ടിലേക്ക് പോയാൽ ടൈമർ തനിയെ പോസ് ആകും. സത്യസന്ധമായ പരിശീലനം മാത്രം!',
      'tamil': 'ஆங்கிலம் முழுமையாக வசப்பட தினமும் 40-60 நிமிடங்கள் ஆப்பில் படிக்க வேண்டும். ஆப் பின்னணியில் சென்றால் டைமர் நிற்கும். உண்மையான பயிற்சி மட்டுமே கணக்கிடப்படும்!',
      'telugu': 'ఆంగ్లంలో నైపుణ్యం సాధించడానికి రోజుకు 40-60 నిమిషాలు శ్రద్ధగా చదవాలి. యాప్ వెనుకకు వెళ్తే టైమర్ ఆగిపోతుంది. నిజాయితీ గల అభ్యాసమే లెక్కించబడుతుంది!',
      'kannada': 'ಇಂಗ್ಲಿಷ್ ಸ್ಪಷ್ಟವಾಗಿ ಕರಗತವಾಗಲು ದಿನಕ್ಕೆ 40-60 ನಿಮಿಷ ಕಲಿಯಬೇಕು. ಆ್ಯಪ್ ಹಿನ್ನೆಲೆಗೆ ಹೋದರೆ ಟೈಮರ್ ನಿಲ್ಲುತ್ತದೆ. ನೈಜ ಅಭ್ಯಾಸಕ್ಕೆ ಮಾತ್ರ ಮಾನ್ಯತೆ!',
      'hindi': 'धाराप्रवाह अंग्रेजी के लिए रोजाना 40 से 60 मिनट ऐप में ध्यानपूर्वक अभ्यास आवश्यक है। बैकग्राउंड में जाने पर टाइमर रुक जाता है।',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_10_consistency',
    icon: '🔥',
    category: 'Focus Habit',
    themeColor: Color(0xFFEF4444),
    titleEn: 'Daily Consistency & Habit Anchor Rule',
    descEn: 'Skipping daily missions triggers consistency demotion warnings and resets unanchored streaks. Studying daily maintains your flame streak, awards +50 bonus coins, and unlocks rare animal avatars.',
    translationTitle: {
      'malayalam': 'ദിവസേനയുള്ള സ്ഥിരതയും ഫ്ലേം സ്ട്രീക്കും',
      'tamil': 'தினசரி விடாமுயற்சி மற்றும் ஸ்ட்ரீக் விதி',
      'telugu': 'రోజువారీ స్థిరత్వం & ఫ్లేమ్ స్ట్రీక్ నియమం',
      'kannada': 'ದೈನಂದಿನ ಸ್ಥಿರತೆ ಮತ್ತು ಸತತ ಕಲಿಕೆಯ ನಿಯಮ',
      'hindi': 'दैनिक निरंतरता और स्ट्रीक नियम',
    },
    translationDesc: {
      'malayalam': 'പഠനം മുടങ്ങിയാൽ റാങ്ക് താഴേക്ക് പോകും. എന്നാൽ ദിവസവും മുടങ്ങാതെ പഠിച്ചാൽ ഫ്ലേം സ്ട്രീക്കും ബോണസ് കോയിനുകളും അപൂർവ്വ ആനിമൽ അവതാറുകളും ലഭിക്കും!',
      'tamil': 'பயிற்சியைத் தவறவிட்டால் நிலைகள் குறையும். தினமும் தொடர்ந்து படித்தால் ஸ்ட்ரீக், கூடுதல் நாணயங்கள் மற்றும் புதிய அவதாரங்கள் கிடைக்கும்!',
      'telugu': 'రోజువారీ ప్రాక్టీస్ తప్పితే ర్యాంక్ పడిపోతుంది. క్రమం తప్పకుండా చదివితే ఫ్లేమ్ స్ట్రీక్, బోనస్ నాణేలు మరియు కొత్త అవతారాలు లభిస్తాయి!',
      'kannada': 'ಕಲಿಕೆ ತಪ್ಪಿದರೆ ಶ್ರೇಣಿ ಕುಸಿಯುತ್ತದೆ. ನಿತ್ಯವೂ ಕಲಿತರೆ ಸತತ ಸ್ಟ್ರೀಕ್, ಬೋನಸ್ ನಾಣ್ಯಗಳು ಮತ್ತು ವಿಶಿಷ್ಟ ಅವತಾರಗಳು ನಿಮ್ಮದಾಗುತ್ತವೆ!',
      'hindi': 'अभ्यास छोड़ने पर रैंक कम हो सकती है। लेकिन रोज पढ़ने पर स्ट्रीक, बोनस सिक्के और दुर्लभ अवतार अनलॉक होंगे!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_11_lifelines',
    icon: '💖',
    category: 'Pocket Battle',
    themeColor: Color(0xFFFF69B4),
    titleEn: 'Attacker Combat Lifelines (Level 25+ Raids)',
    descEn: 'Challenging high-level citadels (Level 25+) grants combat lifelines to forgive mistakes or reset the timer, ensuring dedicated learners have a strategic second chance to conquer tough defenses.',
    translationTitle: {
      'malayalam': 'കോംബാറ്റ് ലൈഫ്‌ലൈനുകൾ (ലെവൽ 25+ അറ്റാക്കുകൾ)',
      'tamil': 'தாக்குதல் லைஃப்லைன்கள் (லெவல் 25+ போர்கள்)',
      'telugu': 'పోరాట లైఫ్‌లైన్‌లు (లెవల్ 25+ దాడులు)',
      'kannada': 'ಯುದ್ಧ ಲೈಫ್‌ಲೈನ್‌ಗಳು (ಲೆವೆಲ್ 25+ ಆಕ್ರಮಣಗಳು)',
      'hindi': 'हमलावर लाइफलाइन (लेवल 25+ हमले)',
    },
    translationDesc: {
      'malayalam': 'ഉയർന്ന ലെവൽ വീടുകളെ അറ്റാക്ക് ചെയ്യുമ്പോൾ (ലെവൽ 25+) തെറ്റ് വന്നാൽ രക്ഷപ്പെടാൻ ലൈഫ്‌ലൈനുകൾ സഹായിക്കും. ടൈമർ റീസെറ്റ് ചെയ്യാനും ഇത് അവസരം തരുന്നു!',
      'tamil': 'உயர் நிலை வீடுகளைத் தாக்கும்போது (லெவல் 25+) தவறுகளை மன்னிக்கவும், டைமரை மீட்டமைக்கவும் லைஃப்லைன்கள் கைகொடுக்கும்!',
      'telugu': 'ఉన్నత స్థాయి ఇళ్లపై దాడి చేసేటప్పుడు (లెవల్ 25+) తప్పులను సరిదిద్దుకోవడానికి మరియు టైమర్ రీసెట్ చేయడానికి లైఫ్‌లైన్‌లు ఉపయోగపడతాయి!',
      'kannada': 'ಉನ್ನತ ಮಟ್ಟದ ಮನೆಗಳನ್ನು ಆಕ್ರಮಿಸುವಾಗ (ಲೆವೆಲ್ 25+) ತಪ್ಪುಗಳನ್ನು ಸರಿಪಡಿಸಲು ಮತ್ತು ಟೈಮರ್ ಮರುಹೊಂದಿಸಲು ಲೈಫ್‌ಲೈನ್‌ಗಳು ನೆರವಾಗುತ್ತವೆ!',
      'hindi': 'उच्च स्तर के घरों पर हमले के दौरान (लेवल 25+) गलतियों से बचने और टाइमर को रीसेट करने के लिए लाइफलाइन मिलती हैं!',
    },
  ),

  const PocketWorldRuleItem(
    id: 'rule_12_anti_cheat',
    icon: '📞',
    category: 'Integrity',
    themeColor: Color(0xFF6366F1),
    titleEn: 'President Call Anti-Cheat & Quality Audit',
    descEn: 'If a neighbor equips abusive, nonsensical, or grammatically broken defense questions, report them directly via President Call for instant audit, trap purging, and integrity penalties.',
    translationTitle: {
      'malayalam': 'പ്രസിഡന്റ് കോൾ ആന്റി-ചീറ്റ് സിസ്റ്റം',
      'tamil': 'பிரசிடென்ட் கால் தரக்கட்டுப்பாட்டு வசதி',
      'telugu': 'ప్రెసిడెంట్ కాల్ మోసాల నిరోధక వ్యవస్థ',
      'kannada': 'ಅಧ್ಯಕ್ಷೀಯ ಕಾಲ್ ಗುಣಮಟ್ಟ ಪರಿಶೀಲನೆ ವ್ಯವಸ್ಥೆ',
      'hindi': 'प्रेसिडेंट कॉल धोखाधड़ी निवारण प्रणाली',
    },
    translationDesc: {
      'malayalam': 'ആരെങ്കിലും അർത്ഥമില്ലാത്തതോ തെറ്റായതോ ആയ ചോദ്യങ്ങൾ വെച്ചാൽ "President Call" വഴി ഉടൻ റിപ്പോർട്ട് ചെയ്യാം. നിയമവിരുദ്ധ ചോദ്യങ്ങൾ ഉടനടി നീക്കം ചെയ്യപ്പെടും.',
      'tamil': 'யாராவது தவறான அல்லது தரம் குறைந்த கேள்விகளை வைத்தால் "President Call" மூலம் புகார் செய்யலாம். போலி கேள்விகள் உடனே அகற்றப்படும்.',
      'telugu': 'ఎవరైనా అసమంజసమైన లేదా తప్పుడు ప్రశ్నలను పెడితే "President Call" ద్వారా వెంటనే నివేదించవచ్చు. అలాంటివి వెంటనే తొలగించబడతాయి.',
      'kannada': 'ಯಾರಾದರೂ ತಪ್ಪಾದ ಅಥವಾ ಅನುಚಿತ ಪ್ರಶ್ನೆಗಳನ್ನು ಇಟ್ಟರೆ "President Call" ಮೂಲಕ ವರದಿ ಮಾಡಬಹುದು. ನಿಯಮಬಾಹಿರ ಪ್ರಶ್ನೆಗಳನ್ನು ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ.',
      'hindi': 'यदि कोई अनुचित या गलत प्रश्न रखता है, तो "President Call" द्वारा तुरंत रिपोर्ट करें। फर्जी प्रश्नों को हटा दिया जाएगा।',
    },
  ),
];

/// 📜 Interactive Pocket World Rules & Sovereign Pledge Page
/// Full screen page allowing user to filter translations (Malayalam, Tamil, Telugu, Kannada, Hindi, English),
/// interactively check/tick all rules, and officially accept the 90-day learning charter!
class PocketWorldGameRulesPage extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onPledgeAccepted;

  const PocketWorldGameRulesPage({
    super.key,
    this.currentDay = 1,
    this.onPledgeAccepted,
  });

  /// Open full page route
  static Future<bool?> open(
    BuildContext context, {
    int currentDay = 1,
    VoidCallback? onPledgeAccepted,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => PocketWorldGameRulesPage(
          currentDay: currentDay,
          onPledgeAccepted: onPledgeAccepted,
        ),
      ),
    );
  }

  /// Backward compatible show helper that pushes the full page
  static Future<bool?> show(
    BuildContext context, {
    int currentDay = 1,
    VoidCallback? onPledgeAccepted,
  }) =>
      open(context,
          currentDay: currentDay, onPledgeAccepted: onPledgeAccepted);

  @override
  State<PocketWorldGameRulesPage> createState() =>
      _PocketWorldGameRulesPageState();
}

/// Backwards compatibility alias
typedef PocketWorldGameRulesModal = PocketWorldGameRulesPage;

class _PocketWorldGameRulesPageState extends State<PocketWorldGameRulesPage> {
  String _selectedLanguage = 'malayalam';
  bool _hasAcceptedPledge = false;
  bool _isSavingPledge = false;
  final Set<String> _checkedRuleIds = {};

  static const String kPrefsRulesAccepted = 'pocket_world_rules_accepted_v1';

  @override
  void initState() {
    super.initState();
    _loadPledgeStatus();
  }

  Future<void> _loadPledgeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(kPrefsRulesAccepted) ?? false;
    if (mounted) {
      setState(() {
        _hasAcceptedPledge = accepted;
        // If already accepted, tick all rules by default
        if (accepted) {
          _checkedRuleIds.addAll(kPocketWorldMasterRulesList.map((r) => r.id));
        }
      });
    }
  }

  void _toggleRule(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_checkedRuleIds.contains(id)) {
        _checkedRuleIds.remove(id);
      } else {
        _checkedRuleIds.add(id);
      }
    });
  }

  void _selectAllRules() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_checkedRuleIds.length == kPocketWorldMasterRulesList.length) {
        _checkedRuleIds.clear();
      } else {
        _checkedRuleIds.addAll(kPocketWorldMasterRulesList.map((r) => r.id));
      }
    });
  }

  Future<void> _acceptPledge() async {
    // If not all rules checked, tick all and proceed
    if (_checkedRuleIds.length < kPocketWorldMasterRulesList.length) {
      setState(() {
        _checkedRuleIds.addAll(kPocketWorldMasterRulesList.map((r) => r.id));
      });
    }

    setState(() => _isSavingPledge = true);
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsRulesAccepted, true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _hasAcceptedPledge = true;
        _isSavingPledge = false;
      });
      widget.onPledgeAccepted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sovereign Rules Accepted! 90-Day English Journey Locked In 🎉',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalRules = kPocketWorldMasterRulesList.length;
    final checkedCount = _checkedRuleIds.length;
    final allChecked = checkedCount == totalRules;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasAcceptedPledge);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context, _hasAcceptedPledge),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📜 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'Pocket World Rules',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '90-Day Sovereign English Charter',
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
              onPressed: () => Navigator.pop(context, _hasAcceptedPledge),
            ),
            const SizedBox(width: 6),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white10,
              height: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Overview Banner
              Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🏛️', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sovereign English Constitution',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '12 Fair Play & Learning Guarantees. Tick to pledge and begin Day 1.',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🌐 Horizontal Language Category Selector (Audio Directive: right below Sovereign English Constitution)
              _buildHorizontalLanguageCategoryBar(),

              // Action Bar: Checklist Progress & Tick All Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          allChecked
                              ? Icons.check_circle_rounded
                              : Icons.checklist_rounded,
                          color: allChecked
                              ? const Color(0xFF10B981)
                              : const Color(0xFF38BDF8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$checkedCount of $totalRules Rules Checked',
                          style: GoogleFonts.outfit(
                            color: allChecked
                                ? const Color(0xFF10B981)
                                : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _selectAllRules,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: allChecked
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: allChecked
                                ? Colors.white24
                                : const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          allChecked ? 'Deselect All' : 'Tick All Rules ✓',
                          style: GoogleFonts.outfit(
                            color: allChecked
                                ? Colors.white70
                                : const Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Rules List with Checkboxes & Translations
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: kPocketWorldMasterRulesList.length,
                  itemBuilder: (context, index) {
                    final rule = kPocketWorldMasterRulesList[index];
                    final isChecked = _checkedRuleIds.contains(rule.id);
                    return _buildRuleCard(rule, isChecked);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            _buildPledgeAgreementFooter(allChecked, checkedCount, totalRules),
      ),
    );
  }

  static const List<Map<String, String>> _kRuleLanguages = [
    {'code': 'malayalam', 'label': 'മലയാളം', 'flag': '🌴'},
    {'code': 'english', 'label': 'English', 'flag': '🇬🇧'},
    {'code': 'tamil', 'label': 'தமிழ்', 'flag': '🪔'},
    {'code': 'hindi', 'label': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'telugu', 'label': 'తెలుగు', 'flag': '🌸'},
    {'code': 'kannada', 'label': 'ಕನ್ನಡ', 'flag': '🏛️'},
  ];

  Widget _buildHorizontalLanguageCategoryBar() {
    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const BouncingScrollPhysics(),
        itemCount: _kRuleLanguages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final lang = _kRuleLanguages[index];
          final code = lang['code']!;
          final isSelected = _selectedLanguage == code;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedLanguage = code);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : Colors.white.withValues(alpha: 0.12),
                  width: isSelected ? 1.6 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lang['label']!,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRuleCard(PocketWorldRuleItem rule, bool isChecked) {
    final translatedTitle = _selectedLanguage == 'english'
        ? null
        : rule.translationTitle[_selectedLanguage];
    final translatedDesc = _selectedLanguage == 'english'
        ? null
        : rule.translationDesc[_selectedLanguage];

    String langLabel;
    switch (_selectedLanguage) {
      case 'malayalam':
        langLabel = 'മലയാളം അർത്ഥം';
        break;
      case 'tamil':
        langLabel = 'தமிழ் விளக்கம்';
        break;
      case 'telugu':
        langLabel = 'తెలుగు వివరణ';
        break;
      case 'kannada':
        langLabel = 'ಕನ್ನಡ ವಿವರಣೆ';
        break;
      case 'hindi':
        langLabel = 'हिन्दी अर्थ';
        break;
      default:
        langLabel = 'Meaning';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFF1E293B)
            : const Color(0xFF161E2E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked
              ? rule.themeColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: isChecked ? 1.4 : 0.8,
        ),
        boxShadow: isChecked
            ? [
                BoxShadow(
                  color: rule.themeColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleRule(rule.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Pill + Rule Icon + Checkbox
                Row(
                  children: [
                    Text(rule.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: rule.themeColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rule.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: rule.themeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Interactive Checkbox
                    GestureDetector(
                      onTap: () => _toggleRule(rule.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFF10B981)
                                : Colors.white38,
                            width: 1.8,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Primary Rule Title (English)
                Text(
                  rule.titleEn,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 4),

                // Primary Rule Description (English)
                Text(
                  rule.descEn,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),

                // Native Translation Section (When not English)
                if (translatedDesc != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: rule.themeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: rule.themeColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('🌐', style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              langLabel,
                              style: GoogleFonts.outfit(
                                color: rule.themeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        if (translatedTitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            translatedTitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          translatedDesc,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE2E8F0),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 🎯 Daily Mission Task
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rule.themeColor.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            _selectedLanguage == 'malayalam'
                                ? 'പ്രതിദിന ദൗത്യം (Daily Task)'
                                : 'Daily Mission Task',
                            style: GoogleFonts.outfit(
                              color: rule.themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedLanguage == 'malayalam' ? rule.dailyTaskMl : rule.dailyTaskEn,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🚀 Linguistic Growth Outcome
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            _selectedLanguage == 'malayalam'
                                ? 'ഭാഷാ വളർച്ചയും നേട്ടവും (Growth Outcome)'
                                : 'Linguistic Growth Outcome',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedLanguage == 'malayalam' ? rule.growthOutcomeMl : rule.growthOutcomeEn,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPledgeAgreementFooter(
      bool allChecked, int checkedCount, int totalRules) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          if (_hasAcceptedPledge)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified,
                      color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'You have officially verified & accepted all rules',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingPledge ? null : _acceptPledge,
              style: ElevatedButton.styleFrom(
                backgroundColor: allChecked || _hasAcceptedPledge
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSavingPledge
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          allChecked || _hasAcceptedPledge ? '✓' : '📜',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasAcceptedPledge
                              ? 'RE-AFFIRM SOVEREIGN PLEDGE'
                              : (allChecked
                                  ? 'I ACCEPT ALL 12 RULES & PLEDGE'
                                  : 'TICK ALL & ACCEPT ($checkedCount/$totalRules)'),
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
